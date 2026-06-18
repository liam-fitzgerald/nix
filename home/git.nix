{ pkgs, ... }:

{
  programs.git = {
    enable = true;

    # ── Identity (change these) ─────────────────────────────
    lfs.enable = true;

    settings = {
      user = {
        name = "Liam";
        email = "liam@axiomatic.systems"; # adjust
      };
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      rerere.enabled = true; # remember conflict resolutions
      diff.algorithm = "histogram";
      merge.conflictstyle = "zdiff3";

      # SSH signing (if using 1Password or similar)
      # gpg.format = "ssh";
      # user.signingkey = "ssh-ed25519 AAAA...";
      # commit.gpgsign = true;
    };

    ignores = [
      ".DS_Store"
      "*.swp"
      ".direnv/"
      ".envrc.local"
      "result" # nix build output symlink
    ];
  };

  programs.delta = {
    enable = true; # better diffs
    enableGitIntegration = true;
    options = {
      navigate = true;
      side-by-side = true;
      line-numbers = true;
    };
  };

  programs.gh = {
    enable = true;
    settings.git_protocol = "ssh";
  };
}
