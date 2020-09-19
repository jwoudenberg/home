let
  sources = import ../nix/sources.nix;

  pkgs = import sources.nixpkgs { };

in pkgs.mkShell {
  buildInputs = [ pkgs.nixops pkgs.terraform ];
  NIX_PATH = "nixpkgs=${pkgs.path}";
  NIXOPS_STATE = "${builtins.getEnv "HOME"}/docs/nixops-state/hetzner.nixops";
  shellHook = ''
    export HCLOUD_TOKEN="$(pass show keys/hetzner_cloud_token)"
    export RESILIO_MUSIC_READONLY="$(pass show keys/resilio_music_readonly)"
    export CLOUDFLARE_API_TOKEN="$(pass show keys/cloudflare_api_token)"
  '';
}
