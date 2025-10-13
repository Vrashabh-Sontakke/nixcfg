{
  description = "My NixOS Configuration";

  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    
    # nix-ld
    nix-ld.url = "github:Mic92/nix-ld";
    nix-ld.inputs.nixpkgs.follows = "nixpkgs"; # this line assume that you also have nixpkgs as an input

    # disko (disk partition configuration)
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # nixos-hardware support
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, home-manager, nixpkgs, nix-ld, disko, nixos-hardware, ... }@inputs:
    let
      inherit (self) outputs;
      systems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      packages =
        forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
      overlays = import ./overlays { inherit inputs; };
      nixosConfigurations = {
        
        # Lenovo ThinkPad X1 Yoga Gen 3
        thinkpad = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [ 
            ./hosts/thinkpad
            # nix-ld.nixosModules.nix-ld
            # { programs.nix-ld.dev.enable = true; }
            disko.nixosModules.disko
      	    nixos-hardware.nixosModules.lenovo-thinkpad-x1-yoga
          ];
        };

        # Lenovo Legion 5 15ARH05 (AMD Ryzen 7 4800H | NVIDIA GTX 1650 Ti)
        legion = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            ./hosts/legion
            nix-ld.nixosModules.nix-ld
            { programs.nix-ld.dev.enable = true; }
            disko.nixosModules.disko
            nixos-hardware.nixosModules.lenovo-legion-15arh05h
          ];
        };
         
      };

      homeConfigurations = {

        "vrash@thinkpad" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [ ./home/vrash/thinkpad.nix ];
        };

        "vrash@legion" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [ ./home/vrash/legion.nix ];
        };
      };
    };
}
