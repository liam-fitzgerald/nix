{ lib, ... }:

{
  imports = [ ./linux.nix ];

  # Generic EFI defaults so the flake's built-in NixOS configurations
  # evaluate and can be used directly on a conventional install. A real
  # host hardware module can override these with normal-priority settings.
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/NIXOS";
    fsType = "ext4";
  };
}
