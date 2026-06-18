{
  description = "Liam's macOS system config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zig-overlay = {
      url = "github:mitchellh/zig-overlay";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, zig-overlay, ... }: let
    # ── Change these ──────────────────────────────────────────
    username = "test";
    hostname = "laptop";          # $(scutil --get LocalHostName)
    system   = "aarch64-darwin"; # or "x86_64-darwin" for Intel

    # ──────────────────────────────────────────────────────────
  in {
    darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
      inherit system;
      modules = [
        {
          nixpkgs.overlays = [ zig-overlay.overlays.default ];
        }
        ./hosts/darwin.nix
        home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${username} = import ./home;
        }
      ];

      specialArgs = { inherit username hostname; };
    };
  };
}
