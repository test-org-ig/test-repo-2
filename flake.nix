{
  description = "test-repo-2: a small flake shaped like umbriel (extra input that update must leave alone).";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
    systems.url = "github:nix-systems/default-linux";
    test-repo-1 = {
      url = "github:test-org-ig/test-repo-1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      systems,
      ...
    }:
    let
      inherit (nixpkgs.lib) genAttrs;

      rev = self.shortRev or self.dirtyShortRev;

      forEachSystem =
        perSystem: genAttrs (import systems) (system: perSystem nixpkgs.legacyPackages.${system});
    in
    {
      formatter = forEachSystem (pkgs: pkgs.nixfmt-tree);

      packages = forEachSystem (pkgs: {
        default = pkgs.runCommand "test-repo-2-${rev}" { } ''
          echo ${rev} > $out
        '';
      });
    };
}
