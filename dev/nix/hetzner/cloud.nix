let
  sources = import ../nix/sources.nix;
  resilio = {
    listeningPort = 18776;
    dirs = [ "music" "photo" "books" "jasper" "hiske" "hjgames" ];
    pathFor = dir: "/srv/volume1/${dir}";
  };
in {
  network = { pkgs = import sources.nixpkgs { system = "x86_64-linux"; }; };

  "ai-banana.jasperwoudenberg.com" = { pkgs, ... }: {
    # Morph
    deployment.targetUser = "root";

    # Nix
    nixpkgs = (import ../config.nix) // {
      localSystem.system = "x86_64-linux";
    };
    system.stateVersion = "20.03";
    networking.hostName = "ai-banana";
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    # Hardware
    imports = [ <nixpkgs/nixos/modules/profiles/qemu-guest.nix> ];
    boot.loader.grub.device = "/dev/sda";
    fileSystems."/" = {
      device = "/dev/sda1";
      fsType = "ext4";
    };
    fileSystems."/srv/volume1" = {
      device = "/dev/disk/by-id/scsi-0HC_Volume_6344799";
      fsType = "ext4";
      options = [ "discard" "defaults" ];
    };

    # Packages
    environment.systemPackages = [ pkgs.comma ];

    # SSH
    services.openssh.enable = true;
    users.users.root.openssh.authorizedKeys.keys = let
      sshKeysSrc = builtins.fetchurl {
        url = "https://github.com/jwoudenberg.keys";
        sha256 = "1hz1m98r8lln50bba9d4f7gcadj4rk5mj5v6zlzxa3lxwiplc6fc";
      };
    in builtins.filter (line: line != "")
    (pkgs.lib.splitString "\n" (builtins.readFile sshKeysSrc));

    # Mosh
    programs.mosh.enable = true;

    # Network
    networking.firewall.allowedTCPPorts = [ resilio.listeningPort 80 443 2022 ];
    networking.firewall.allowedUDPPorts = [ resilio.listeningPort 80 443 2022 ];

    # healthchecks.io
    services.cron.enable = true;
    services.cron.systemCronJobs = [
      "0 * * * *      root    systemctl is-active --quiet plex && curl -fsS -m 10 --retry 5 -o /dev/null https://hc-ping.com/8177d382-5f65-465c-8e41-50b0a9291c9f"
    ];

    # Resilio Sync
    system.activationScripts.mkResilioSharedFolders = let
      pathList = pkgs.lib.concatMapStringsSep " " resilio.pathFor resilio.dirs;
    in ''
      mkdir -p ${pathList}
      chown rslsync:rslsync -R ${pathList}
    '';

    services.resilio = {
      enable = true;
      enableWebUI = false;
      listeningPort = resilio.listeningPort;
      sharedFolders = let
        configFor = dir: {
          secret =
            builtins.getEnv "RESILIO_KEY_${pkgs.lib.toUpper dir}_READONLY";
          directory = resilio.pathFor dir;
          useRelayServer = false;
          useTracker = true;
          useDHT = true;
          searchLAN = true;
          useSyncTrash = false;
          knownHosts = [ ];
        };
      in builtins.map configFor resilio.dirs;
    };

    # Plex
    # When recreating we need to run Plex setup again. To do so:
    # 1. Set `openFirewall = false;` (so no-one can claim the unconfigured server)
    # 2. ssh -L 32400:localhost:32400 root@ai-banana.jasperwoudenberg.com
    # 3. In the browser login at localhost:32400/web and follow the instructions
    # 4. Set `openFirewall = true;`
    services.plex = {
      enable = true;
      openFirewall = true;
    };

    # Caddy
    services.caddy = {
      enable = true;
      agree = true;
      email = "letsencrypt@jasperwoudenberg.com";
      # Hashes generated with the `caddy hash-password` command.
      config = ''
        ai-banana.jasperwoudenberg.com {
          basicauth {
            jasper JDJhJDEwJHU5ZVlVeDRJREFMYU1QbU5vdVpXVE9weWtnNHBGR255ZUhKRUp3a21xaWpzcC80aVFtOUl5
            hiske JDJhJDEwJEtac3JYQjNHMDY3WXpLcFVKQzYuZHVBVlJHamI5OWRwc1NsamZlL1ROYUo0WHFtZnZCVkU2 n3SxWJ2AgsVTq7xralHp1nQCe1YQutlN2jdtlzsclCI=
          }
          reverse_proxy {
            to localhost:8080
          }
        }
      '';
    };

    # rclone
    systemd.services.rclone-serve-webdav = {
      description = "Rclone Serve";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        User = "rslsync";
        Group = "rslsync";
        ExecStart =
          "${pkgs.rclone}/bin/rclone serve webdav /srv/volume1 --addr localhost:8080";
        Restart = "on-failure";
      };
    };

    systemd.services.rclone-serve-sftp = {
      description = "Rclone Serve";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        User = "rslsync";
        Group = "rslsync";
        ExecStart = let
          start = pkgs.writeShellScriptBin "rclone-serve-sftp" ''
            #!/usr/bin/env bash
            exec ${pkgs.rclone}/bin/rclone serve sftp \
              /srv/volume1/hjgames/scans-to-process \
              --user sftp \
              --pass "$RCLONE_PASS" \
              --addr :2022
          '';
        in "${start}/bin/rclone-serve-sftp";
        Restart = "on-failure";
        EnvironmentFile = "/var/secrets/sftp-password";
      };
    };

    deployment.secrets.sftp-password = {
      source = "/tmp/secrets/sftp-password";
      destination = "/var/secrets/sftp-password";
    };

    # restic
    services.restic.backups.daily = {
      paths = builtins.map resilio.pathFor resilio.dirs;
      repository = "sftp:19438@ch-s012.rsync.net:restic-backups";
      passwordFile = "/var/secrets/restic-password";
      timerConfig = { OnCalendar = "00:05"; };
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 12"
        "--keep-yearly 75"
      ];
    };

    deployment.secrets.restic-password = {
      source = "/tmp/secrets/restic-password";
      destination = "/var/secrets/restic-password";
    };

    systemd.services.restic-backups-daily.serviceConfig.ExecStartPost =
      "${pkgs.curl}/bin/curl -m 10 --retry 5 https://hc-ping.com/528b3b90-9fc4-4dd7-b032-abb0c7019b88";
  };
}
