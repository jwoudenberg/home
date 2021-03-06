{ pkgs, ... }:

{
  home.packages = [
    pkgs.cachix
    pkgs.calibre
    pkgs.chromium
    pkgs.comma
    pkgs.discord
    pkgs.du-dust
    pkgs.fd
    pkgs.gnupg
    pkgs.gotop
    pkgs.grim
    pkgs.i3status
    pkgs.imv
    pkgs.jq
    pkgs.keybase
    pkgs.magic-wormhole
    pkgs.mosh
    pkgs.mupdf
    pkgs.haskellPackages.niv
    pkgs.minecraft
    pkgs.nixfmt
    pkgs.nix-prefetch-github
    pkgs.nodePackages.prettier
    pkgs.pass
    pkgs.pdfgrep
    pkgs.pulsemixer
    pkgs.plex-media-player
    pkgs.podman
    pkgs.random-colors
    pkgs.ripgrep
    pkgs.sd
    pkgs.shellcheck
    pkgs.similar-sort
    pkgs.slurp
    pkgs.tmate
    pkgs.todo
    pkgs.vale
    pkgs.wally-cli
    pkgs.wl-clipboard
    pkgs.wofi
    pkgs.xdg_utils
    pkgs.zoom-us
  ];

  imports = [
    ../programs/direnv.nix
    ../programs/firefox.nix
    ../programs/fish/default.nix
    ../programs/fzf.nix
    ../programs/git.nix
    ../programs/i3status/default.nix
    ../programs/kitty.nix
    ../programs/neovim/default.nix
    ../programs/readline.nix
    ../programs/ripgrep.nix
    ../programs/ssh.nix
    ../programs/sway.nix
    ../programs/vale/default.nix
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    DEFAULT_TODO_TXT = "~/docs/todo.txt";
    MANPAGER = "nvim -c 'set ft=man' -";
    AWS_VAULT_BACKEND = "file";
  };

  home.stateVersion = "20.03";
}
