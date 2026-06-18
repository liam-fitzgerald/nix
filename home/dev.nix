{ pkgs, ... }:

let
  emacsPackage =
    if pkgs.stdenv.isDarwin && pkgs ? emacs30-macport then
      pkgs.emacs30-macport.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          rm -f $out/bin/ctags $out/bin/etags
        '';
      })
    else
      pkgs.emacs30 or pkgs.emacs;
in
{
  home.packages = with pkgs; [
    (pkgs.lib.hiPrio pkgs.universal-ctags)
    # ── Common Lisp ───────────────────────────────────────────
    sbcl
    # roswell          # if you prefer ros for CL management

    # ── Rust ──────────────────────────────────────────────────
    rustup # manages toolchains itself; don't also add cargo/rustc
    # ── C / systems ──────────────────────────────────────────
    gcc
    gnumake
    cmake
    pkg-config
    lldb

    zigpkgs."0.14.0"

    # ── Nix tooling ──────────────────────────────────────────
    nil # nix LSP
    nixfmt # nix formatter
    nix-tree # visualize derivation trees
    nix-diff # diff closures

    # ── Data / serialisation ─────────────────────────────────
    sqlite
    lmdb # for PLAN/Shrine dev

    # ── Misc dev ─────────────────────────────────────────────
    gh # GitHub CLI (also in git.nix via programs.gh)
    just # task runner
    watchexec # file watcher
    go
  ];

  # ── Emacs ─────────────────────────────────────────────────
  # Using overlay-free emacs — you manage packages via init.el / use-package.
  # If you want full nix-managed emacs packages, switch to emacs + emacsPackagesFor.
  programs.emacs = {
    enable = true;
    package = emacsPackage;
    # extraPackages = epkgs: with epkgs; [
    #   slime
    #   magit
    #   which-key
    #   vertico
    #   orderless
    #   consult
    # ];
  };

  programs.bacon.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # LSP servers and tools — available to neovim on PATH
    extraPackages = with pkgs; [
      # LSPs
      nil # nix
      lua-language-server
      rust-analyzer
      zls # zig
      clang-tools # clangd for C

      # Formatters
      nixfmt
      stylua
    ];
  };

  home.sessionVariables = {
    CC = "${pkgs.llvm}/bin/clang";
  };

  # ── Direnv (auto-load per-project shells) ──────────────────
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true; # cached nix shells — huge speedup
  };
}
