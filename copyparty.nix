{
  inputs.copyparty.url = "github:9001/copyparty";
  
  outputs = { self, nixpkgs, copyparty }: {
    nixosConfigurations.cavendish = nixpkgs.lib.nixosSystem {
      modules = [
        copyparty.nixosModules.default
        ({ pkgs, ... }: {
          nixpkgs.overlays = [ copyparty.overlays.default ];
          services.copyparty = {
            enable = true;
            # TODO: finish configuration
          };
        })
      ];
    };
  };
}
