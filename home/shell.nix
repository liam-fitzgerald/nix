{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    defaultKeymap = "viins";

    shellAliases = {
      ls  = "eza --icons";
      ll  = "eza -la --icons --git";
      cat = "bat --style=plain";
      g   = "git";
      gs  = "git status -sb";
      gd  = "git diff";
      gl  = "git log --oneline --graph -20";

      # Rebuild system config (the one command you actually need)
      rebuild = "darwin-rebuild switch --flake ~/.config/nixos";
    };

    initExtra = ''
      # direnv hook (auto-load .envrc per project)
      eval "$(direnv hook zsh)"

      # fzf keybindings (Ctrl-R for history, Ctrl-T for files)
      source ${pkgs.fzf}/share/fzf/key-bindings.zsh
      source ${pkgs.fzf}/share/fzf/completion.zsh
    '';

    history = {
      size = 50000;
      save = 50000;
      ignoreDups = true;
      ignoreAllDups = true;
      share = true;          # share across sessions
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      character = {
        success_symbol = "[λ](bold green)";
        error_symbol   = "[λ](bold red)";
      };
      directory.truncation_length = 3;
      git_branch.symbol = " ";
      nix_shell = {
        symbol = " ";
        format = "via [$symbol$state]($style) ";
      };
    };
  };

  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    keyMode = "vi";
    baseIndex = 1;
    escapeTime = 0;
    extraConfig = ''
      set -g mouse on
      set -g renumber-windows on

      # Prefix: C-a instead of C-b
      unbind C-b
      set -g prefix C-a
      bind C-a send-prefix

      # Splits
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
    '';
  };
}
