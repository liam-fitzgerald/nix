{
  description = "Liam's cross-platform Nix user environment";

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

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      zig-overlay,
      ...
    }:
    let
      # ── Change these ──────────────────────────────────────────
      username = "test";
      darwinHostname = "laptop"; # $(scutil --get LocalHostName)
      darwinSystem = "aarch64-darwin"; # or "x86_64-darwin" for Intel
      linuxSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      # ──────────────────────────────────────────────────────────
      overlays = [ zig-overlay.overlays.default ];

      mkPkgs =
        system:
        import nixpkgs {
          inherit system overlays;
          config.allowUnfree = true;
        };

      mkHome =
        system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = mkPkgs system;
          modules = [
            {
              home.username = username;
              home.homeDirectory =
                if nixpkgs.lib.hasSuffix "-darwin" system then "/Users/${username}" else "/home/${username}";
            }
            ./home
          ];
          extraSpecialArgs = {
            inherit username;
            hostname = if nixpkgs.lib.hasSuffix "-darwin" system then darwinHostname else "linux";
            homeConfigName = "${username}@${system}";
            rebuildCommand = "home-manager switch --flake ~/.config/nix#${username}@${system}";
          };
        };

      mkNixos =
        { system, hostname }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            {
              nixpkgs = {
                inherit overlays;
                config.allowUnfree = true;
              };
            }
            ./hosts/nixos.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit username hostname;
                homeConfigName = "${username}@${system}";
                rebuildCommand = "sudo nixos-rebuild switch --flake ~/.config/nix#${hostname}";
              };
              home-manager.users.${username} = {
                imports = [ ./home ];
                home.username = username;
                home.homeDirectory = "/home/${username}";
              };
            }
          ];
          specialArgs = { inherit username hostname; };
        };
    in
    {
      homeConfigurations = builtins.listToAttrs (
        map (system: {
          name = "${username}@${system}";
          value = mkHome system;
        }) linuxSystems
      );

      homeModules.default = ./home;
      nixosModules.workstation = ./hosts/linux.nix;

      nixosConfigurations = {
        linux = mkNixos {
          system = "x86_64-linux";
          hostname = "linux";
        };
        linux-aarch64 = mkNixos {
          system = "aarch64-linux";
          hostname = "linux-aarch64";
        };
      };

      darwinConfigurations.${darwinHostname} = nix-darwin.lib.darwinSystem {
        system = darwinSystem;
        modules = [
          {
            nixpkgs = {
              inherit overlays;
              config.allowUnfree = true;
            };
          }
          ./hosts/darwin.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit username;
              hostname = darwinHostname;
              homeConfigName = "${username}@${darwinSystem}";
              rebuildCommand = "sudo darwin-rebuild switch --flake ~/.config/nix#${darwinHostname}";
            };
            home-manager.users.${username} = {
              imports = [ ./home ];
              home.username = username;
              home.homeDirectory = "/Users/${username}";
            };
          }
        ];

        specialArgs = {
          inherit username;
          hostname = darwinHostname;
        };
      };
    };
}
