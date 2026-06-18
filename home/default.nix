{ pkgs, lib, ... }:

{
  imports = [
    ./shell.nix
    ./git.nix
    ./dev.nix
    ./dot.nix
  ];

  home.stateVersion = "24.05";

  home.file."Library/Fonts/custom" = lib.mkIf pkgs.stdenv.isDarwin {
    source = ../fonts;
    recursive = true;
  };

  fonts.fontconfig.enable = lib.mkIf pkgs.stdenv.isLinux true;
  xdg.dataFile."fonts/BerkeleyMonoNerdFont-Regular.otf" = lib.mkIf pkgs.stdenv.isLinux {
    source = ../fonts/BerkeleyMonoNerdFont-Regular.otf;
  };

  # ── Core user packages ──────────────────────────────────────
  home.packages = with pkgs; [
    # CLI essentials
    ripgrep
    fd
    bat
    eza # modern ls
    jq
    fzf
    htop
    tree
    tldr
    tokei # code stats
    direnv

    # Networking / debug
    httpie
    nmap
    mtr

    # Archive
    unzip
    p7zip
  ];

  # Let home-manager manage itself
  programs.home-manager.enable = true;
}
