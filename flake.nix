{
  description = "duolok's NixOS + home-manager configuration";

  inputs = {
    # Pinned to the 26.05 release. Bump both refs together when moving to a
    # newer NixOS release, then run `nix flake update`.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      # Make home-manager build against the exact same nixpkgs as the system,
      # so packages and modules stay in lockstep.
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    # Rebuild with:  sudo nixos-rebuild switch --flake ~/fun/nixos-config#nixos
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        # Provides the home-manager.* options used in configuration.nix.
        home-manager.nixosModules.home-manager
      ];
    };
  };
}
