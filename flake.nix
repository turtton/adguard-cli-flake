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

      nixosModules = {
        adguard-cli =
          { config, lib, pkgs, ... }:
          let
            cfg = config.programs.adguard-cli;
          in
          {
            options.programs.adguard-cli = {
              enable = lib.mkEnableOption "AdGuard CLI";

              package = lib.mkOption {
                type = lib.types.package;
                default = self.packages.${pkgs.stdenv.hostPlatform.system}.adguard-cli;
                defaultText = lib.literalExpression "adguard-cli-flake.packages.\${system}.adguard-cli";
                description = "The adguard-cli package to use.";
              };
            };

            config = lib.mkIf cfg.enable {
              environment.systemPackages = [ cfg.package ];

              # adguard-cli requires a SUID-root helper next to its executable.
              # The package symlinks that path to /run/wrappers/bin/adguard_root_helper,
              # which this wrapper provides (the real binary is hidden under a
              # dot-name because the Nix store cannot hold SUID binaries).
              security.wrappers.adguard_root_helper = {
                source = "${cfg.package}/share/adguard-cli/.adguard_root_helper-real";
                owner = "root";
                group = "root";
                setuid = true;
              };
            };
          };

        default = self.nixosModules.adguard-cli;
      };
    };
}
