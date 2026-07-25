{
  description = "Nix flake for AdGuard CLI — ad blocking in your terminal";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          adguard-cli = pkgs.callPackage ./package.nix { };
          default = self.packages.${system}.adguard-cli;
        }
      );

      checks = forAllSystems (system: {
        default = self.packages.${system}.default;
      });
    };
}
