{
  inputs = {
    nixpkgs.url = "github:NixOs/nixpkgs/24.05";
    unstable.url = "github:NixOs/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
    utils.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = {self,nixpkgs,unstable,utils,...} @inputs : inputs.utils.lib.eachSystem[
    "x86_64-linux"
  ](system:
    let 
      pkgs = nixpkgs.legacyPackages.${system};
      unstable_pkgs = unstable.legacyPackages.${system};
    in 
    {
      devShell = pkgs.mkShell {
        name = "python env";
        buildInputs = with pkgs ; [
            unstable_pkgs.uv
            python3
            # just activates the env
            python3Packages.venvShellHook
        ];
        propoagtedBuildInputs=[pkgs.stdenv.cc.cc.lib];
        venvDir = "./venv";
        postVenvCreation = ''
          # unset SOURCE_DATE_EPOCH
          uv pip install -U pip setuptools wheel
          uv pip install -r requirements.txt
          uv pip install -e 
        '';

      };
    }
  );
}
