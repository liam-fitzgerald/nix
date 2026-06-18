{ pkgs, ... }:

{
  xdg.configFile = {
    "ghostty/config".text =
      builtins.replaceStrings [ "command = /bin/zsh" ] [ "command = ${pkgs.zsh}/bin/zsh" ]
        (builtins.readFile ../dot/ghostty);
    "nvim" = {
      source = ../dot/nvim;
      recursive = true;
    };
  };
}
