{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05"
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
      ];
    };
    nixosConfigurations.cavendish = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        ./copyparty.nix
      ];
    };
  };
}
