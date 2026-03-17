{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # ── Common Lisp ───────────────────────────────────────────
    sbcl
    # roswell          # if you prefer ros for CL management

    # ── Rust ──────────────────────────────────────────────────
    rustup             # manages toolchains itself; don't also add cargo/rustc
    git-lfs

    # ── C / systems ──────────────────────────────────────────
    gcc
    gnumake
    cmake
    pkg-config
    lldb

    # ── Nix tooling ──────────────────────────────────────────
    nil                # nix LSP
    nixfmt-rfc-style   # nix formatter
    nix-tree           # visualize derivation trees
    nix-diff           # diff closures

    # ── Data / serialisation ─────────────────────────────────
    sqlite
    lmdb               # for PLAN/Shrine dev

    # ── Misc dev ─────────────────────────────────────────────
    gh                 # GitHub CLI (also in git.nix via programs.gh)
    just               # task runner
    watchexec          # file watcher
  ];

  # ── Emacs ─────────────────────────────────────────────────
  # Using overlay-free emacs — you manage packages via init.el / use-package.
  # If you want full nix-managed emacs packages, switch to emacs + emacsPackagesFor.
  programs.emacs = {
    enable = true;
    package = pkgs.emacs30-macport;  # native macOS build
    # extraPackages = epkgs: with epkgs; [
    #   slime
    #   magit
    #   which-key
    #   vertico
    #   orderless
    #   consult
    # ];
  };

  # ── Direnv (auto-load per-project shells) ──────────────────
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;  # cached nix shells — huge speedup
  };
}
