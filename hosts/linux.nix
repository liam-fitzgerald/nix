{
  pkgs,
  username,
  hostname,
  ...
}:

{
  # ── Nix settings ────────────────────────────────────────────
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    keep-outputs = true;
    keep-derivations = true;
    trusted-users = [
      "root"
      username
    ];
  };

  # ── System packages (available to all users) ────────────────
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
    nodejs_22
    corepack
    rlwrap
    scc
    llvm
    (pkgs.lib.hiPrio pkgs.universal-ctags)
    sesh
    zoxide
    cmake
    protobuf
    jdk21
    racket
    haskellPackages.lhs2tex
    texlive.combined.scheme-full
    fontforge
    fontforge-fonttools
  ];

  # ── Networking ──────────────────────────────────────────────
  networking.hostName = hostname;
  networking.networkmanager.enable = true;

  # ── Users ───────────────────────────────────────────────────
  users.users.${username} = {
    isNormalUser = true;
    home = "/home/${username}";
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  programs.zsh.enable = true;

  # Used for backward compat. Don't change after initial setup.
  system.stateVersion = "24.05";
}
