{ config, pkgs, ... }:

let
  vcd = pkgs.stdenv.mkDerivation {
    name = "vcd";
    src = pkgs.fetchFromGitHub {
      owner = "yne";
      repo = "vcd";
      rev = "8c5455fd09a32819f9a77695f5508c14f4329d15";  # Specify the commit or tag you want to use
      sha256 = "sha256-x482LpK0cVj+MvS3UstSeRnzsxh5Yax89Atvh4gFF5M=";  # Replace with the correct hash
    };
    
    buildInputs = [ pkgs.gcc13 pkgs.gnumake ];

    buildPhase = ''
      make
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp vcd $out/bin/
    '';
  };
in
{
  home.username = "jared_stanbrough";
  home.homeDirectory = "/home/jared_stanbrough";
  home.stateVersion = "23.11"; # Please read the comment before changing.

  home.packages = with pkgs; [
    git
    gh
    svls
    verilator
    gnumake
    gcc13
    nix-prefetch-github
    svlint
    yq
    zsh
    oh-my-zsh
  ] ++ [ vcd ];

  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  home.sessionVariables = {
    EDITOR = "vim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      vim-lsp 
      SpaceCamp
    ];

    extraConfig = ''
      set encoding=utf-8
      set mouse=v
      syntax on
      set expandtab
      set ts=2
      set softtabstop=2
      set shiftwidth=2
      set ai
      set si
      set backspace=indent,eol,start
      filetype on 
      filetype plugin on
      filetype indent on
      colorscheme spacecamp

      au User lsp_setup call lsp#register_server({
        \ 'name': 'svls',
        \ 'cmd': {server_info->['svls']},
        \ 'whitelist': ['systemverilog'],
        \ })
    '';
  };
  
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    oh-my-zsh = {
      enable = true;
      theme = "af-magic";
      plugins = [ "debian" "git" "dirhistory" "gh" ];
    };
    initExtra = ''
      bindkey -v
      source ~/.nix-profile/etc/profile.d/hm-session-vars.sh
    '';
  };
}
