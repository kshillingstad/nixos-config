{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    chaotic = {
      url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
      inputs.nixpkgs.follows = "nixpkgs";  # Force chaotic to use your nixpkgs
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    lazyvim = {
      url = "github:LazyVim/starter";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, chaotic, home-manager, nixos-hardware, lazyvim, ... }@inputs: {
    nixosConfigurations = {
       # High-performance workstation with NVIDIA GPU
       bfgpu = nixpkgs.lib.nixosSystem {
         system = "x86_64-linux";
         specialArgs = { inherit inputs; };
         modules = [
           ./base.nix
           ./hosts/bfgpu
           # Only import chaotic modules, not the full nixpkgs overlay
           chaotic.nixosModules.default
           home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; theme = "nord"; };
              home-manager.users.kyle = import ./home.nix;
            }
         ];
       };

       surface = nixpkgs.lib.nixosSystem {
         system = "x86_64-linux";
         specialArgs = { inherit inputs; };
         modules = [
           ./base.nix
           ./hosts/surface
           nixos-hardware.nixosModules.microsoft-surface-common
           chaotic.nixosModules.default
           home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.kyle = import ./home.nix;
            }
         ];
       };

       threadripper = nixpkgs.lib.nixosSystem {
         system = "x86_64-linux";
         specialArgs = { inherit inputs; };
         modules = [
           ./base.nix
           ./hosts/threadripper
           chaotic.nixosModules.default
           home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = { inherit inputs; theme = "nord"; };
              home-manager.users.kyle = import ./home.nix;
            }
         ];
       };
    };

    # To add another machine, copy one of the existing host directories
    # into hosts/<newname> and add a new entry here similar to bfgpu/threadripper.
    # Keep host-specific logic inside hosts/<name>/default.nix and reuse modules/.
  };
}
