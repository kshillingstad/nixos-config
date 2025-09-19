{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
  };

  outputs = { self, nixpkgs, chaotic, ... }: {
    nixosConfigurations = {
      # Gaming desktop with NVIDIA GPU
      bfgpu = nixpkgs.lib.nixosSystem {
        modules = [
          ./base.nix
          ./hosts/bfgpu
          chaotic.nixosModules.default
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
