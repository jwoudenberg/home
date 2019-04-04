{ pkgs, ... }:
let
  plugins = pkgs.vimPlugins // pkgs.callPackage ./custom-plugins.nix {};
in
{
  programs.neovim = {
    enable = true;

    withPython = true;
    withPython3 = true;
    withRuby = true;

    configure = {
      customRC = builtins.readFile ./vimrc;

      packages.plugins.start = with plugins; [
        ale
        cursor-line-current-window
        dracula
        fzfWrapper
        fzf-vim
        gitgutter
        lightline-vim
        neoformat
        polyglot
        quickfix-reflector
        todo
        unimpaired
        vim-abolish
        vim-commentary
        vim-eunuch
        vim-fugitive
        vim-highlightedyank
        vim-localvimrc
        vim-rhubarb
        vim-speeddating
        vim-surround
        vim-test
        vim-vinegar
        visual-star-search
      ];
    };
  };
}
