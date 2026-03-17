{ pkgs, username, hostname, ... }:

{
  # ── Nix settings ────────────────────────────────────────────
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    # Avoid garbage collection while building
    keep-outputs = true;
    keep-derivations = true;
  };
  nix.enable = false;

  # Allow unfree packages (e.g. 1Password, vscode, etc.)
  nixpkgs.config.allowUnfree = true;

  # ── System packages (available to all users) ────────────────
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
  ];

  system.primaryUser = username;
  system.defaults.NSGlobalDomain."com.apple.keyboard.fnState" = true;

  # Remap Caps Lock → Control
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

  # ── macOS system defaults ───────────────────────────────────
  # These replace `defaults write` commands you'd run manually.
  system.defaults = {
    dock = {
      autohide = true;
      mru-spaces = false;          # don't rearrange Spaces
      show-recents = false;
    };

    finder = {
      AppleShowAllExtensions = true;
      FXPreferredViewStyle = "Nlsv"; # list view
    };

    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      ApplePressAndHoldEnabled = false;  # key repeat > accents
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
    };

    trackpad = {
      Clicking = true;             # tap to click
      TrackpadThreeFingerDrag = true;
    };
  };

  # ── Homebrew (for GUI apps / casks nix can't handle) ────────
  # nix-darwin manages brew declaratively — it will install/uninstall
  # to match this list.
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";  # remove anything not declared here
    };

    # CLI tools from brew (only if not in nixpkgs)
    brews = [
      # "some-brew-only-tool"
    ];

    # GUI apps
    casks = [
      "firefox"
      "iterm2"
      "1password"
      "ghostty"
      "claude"
      # "discord"
      # "obs"
      # "vlc"
    ];

    # Mac App Store apps (need `mas` CLI + signed in)
    # masApps = {
    #   "Xcode" = 497799835;
    # };
  };

  # ── Networking ──────────────────────────────────────────────
  networking.hostName = hostname;

  # ── Users ───────────────────────────────────────────────────
  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };

  # Required for nix-darwin
  programs.zsh.enable = true;

  # Used for backward compat. Don't change after initial setup.
  system.stateVersion = 5;
}
