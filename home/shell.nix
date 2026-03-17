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
unbind C-b
set-option -g prefix C-a
bind-key C-a send-prefix

set-window-option -g mode-keys vi
set-option -g renumber-windows on

bind J resize-pane -D 5
bind K resize-pane -U 5
bind L resize-pane -R 5
bind H resize-pane -L 5

# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'christoomey/vim-tmux-navigator'
set -g @plugin 'arcticicestudio/nord-tmux'

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
     '';


  };
}
