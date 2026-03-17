{ pkgs, ... }:

{
  xdg.configFile = {
    "ghostty/config".source = ../dot/ghostty;
    "nvim" = {
      source = ../dot/nvim;
      recursive = true;
    };
  };
}
