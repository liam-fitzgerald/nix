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
      rlldb = " rust-lldb";

      # Rebuild system config (the one command you actually need)
      rebuild = "sudo darwin-rebuild switch --flake ~/.config/nixos";
    };

    initExtra = ''
    source ${pkgs.fzf}/share/fzf/key-bindings.zsh
    source ${pkgs.fzf}/share/fzf/completion.zsh
    export NPM_CONFIG_PREFIX="$HOME/.npm-global"
    export PATH="$HOME/.npm-global/bin:$PATH"
    export PATH="$HOME/.local/bin:$PATH"
    '' + builtins.readFile ../dot/zshrc;

    history = {
      size = 50000;
      save = 50000;
      ignoreDups = true;
      ignoreAllDups = true;
      share = true;          # share across sessions
    };
  };
  home.sessionVariables = {
    GOPATH = "$HOME/go";
    GOBIN  = "$HOME/go/bin";
  };
  home.sessionPath = [ "$HOME/go/bin" ];


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

bind -T copy-mode-vi v send -X begin-selection
bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"
bind P paste-buffer
bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "pbcopy"

unbind-key d

bind "d" run-shell "sesh connect \"$(
  sesh list --icons | fzf-tmux -p 80%,70% \
    --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
    --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
    --bind 'tab:down,btab:up' \
    --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
    --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
    --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
    --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
    --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
    --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
    --preview-window 'right:55%' \
    --preview 'sesh preview {}'
)\""

# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'christoomey/vim-tmux-navigator'
set -g @plugin 'arcticicestudio/nord-tmux'
set -g @plugin 'tmux-plugins/tmux-cowboy'

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
     '';


  };
}
