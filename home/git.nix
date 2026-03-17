{ pkgs, ... }:

{
  programs.git = {
    enable = true;

    # ── Identity (change these) ─────────────────────────────
    userName  = "Liam";
    userEmail = "liam@axiomatic.systems";  # adjust

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      rerere.enabled = true;               # remember conflict resolutions
      diff.algorithm = "histogram";
      merge.conflictstyle = "zdiff3";

      # SSH signing (if using 1Password or similar)
      # gpg.format = "ssh";
      # user.signingkey = "ssh-ed25519 AAAA...";
      # commit.gpgsign = true;
    };

    delta = {
      enable = true;    # better diffs
      options = {
        navigate = true;
        side-by-side = true;
        line-numbers = true;
      };
    };

    ignores = [
      ".DS_Store"
      "*.swp"
      ".direnv/"
      ".envrc.local"
      "result"           # nix build output symlink
    ];
  };

  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };
}
