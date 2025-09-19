{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, chaotic, home-manager, ... }: {
    nixosConfigurations = {
      # Gaming desktop with NVIDIA GPU
      bfgpu = nixpkgs.lib.nixosSystem {
        modules = [
          ./base.nix
          ./hosts/bfgpu
          chaotic.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.kyle = import ./home.nix;
          }
        ];
      };

      # Template for additional machines:
      # laptop = nixpkgs.lib.nixosSystem {
      #   modules = [
      #     ./base.nix
      #     ./hosts/laptop
      #     chaotic.nixosModules.default
      #   ];
      # };
    };
  };
}
