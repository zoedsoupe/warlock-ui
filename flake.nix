{
  description = "Warlock UI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05-small";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      inherit (pkgs) beam mkShell;
      inherit (beamPkgs) buildMix;
      pkgs = import nixpkgs {inherit system;};
      beamPkgs = beam.packagesWith beam.interpreters.erlang_26;
    in {
      packages = {
        warlock-ui = buildMix {
          name = "warlock_ui";
          version = "0.1.0-alpha";
          src = ./.;
        };
      };

      devShells.default = mkShell {
        name = "warlock-dev";
        shellHook = "mkdir -p .nix-mix";
        packages = with pkgs;
        with beamPkgs;
          [elixir erlang nodejs openssl zlib libiconv gcc gnumake]
          ++ lib.optional stdenv.isLinux [
            inotify-tools
            gtk-engine-murrine
          ]
          ++ lib.optional stdenv.isDarwin [
            darwin.apple_sdk.frameworks.CoreServices
            darwin.apple_sdk.frameworks.CoreFoundation
          ];
      };
    });
}
