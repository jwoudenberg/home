{
  config = { allowUnfree = true; };
  overlays = [
    (import ./overlays/filebrowser.nix)
    (import ./overlays/nixfmt.nix)
    (import ./overlays/pass.nix)
    (import ./overlays/pdfrg.nix)
    (import ./overlays/random-colors.nix)
    (import ./overlays/similar-sort.nix)
    (import ./overlays/todo.nix)
    (import ./overlays/wofi.nix)
  ];
}
