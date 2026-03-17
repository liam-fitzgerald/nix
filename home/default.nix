{ pkgs, ... }:

{
  imports = [
    ./shell.nix
    ./git.nix
    ./dev.nix
  ];

  home.stateVersion = "24.05";

  # ── Core user packages ──────────────────────────────────────
  home.packages = with pkgs; [
    # CLI essentials
    ripgrep
    fd
    bat
    eza                  # modern ls
    jq
    fzf
    htop
    tree
    tldr
    tokei                # code stats
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
