{ pkgs, ... }:

{
  home.file = {
    "ghostty/config".source = "../dot/ghostty";
  }
}
