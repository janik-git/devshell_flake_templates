{
  inputs = {
    nixpkgs.url = "github:NixOs/nixpkgs/23.11";
    unstable.url = "github:NixOs/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
    utils.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = {self,nixpkgs,unstable,utils,...} @inputs : inputs.utils.lib.eachSystem[
    "x86_64-linux"
  ](system:
    let 
      # pkgs = import nixpkgs{
      #   inherit system;
      #   config.allowUnfree=true;
      #   config.cudaSupport=true;
      # };
      pkgs = nixpkgs.legacyPackages.${system};
      unstable_pkgs = unstable.legacyPackages.${system};
    in 
    {
      devShell = pkgs.mkShell {
        name = "python env";
        buildInputs = with pkgs ; [
            unstable_pkgs.uv
            python3
            python3Packages.venvShellHook
            autoPatchelfHook
        ];
        propoagtedBuildInputs=[pkgs.stdenv.cc.cc.lib];
        venvDir = "./venv";
        postVenvCreation = ''
          unset SOURCE_DATE_EPOCH
          uv pip install -U pip setuptools wheel
          uv pip install -r requirements.txt
          uv pip install -e 
          autoPatchelf ./venv
        '';
        # shellHook = '' 
        #   $SHELL
        #   exit
        # '' ;
        postShellHook = ''
          export SOURCE_DATE_EPOCH=315532800;
          unset LD_LIBARY_PATH
        '';
        preferLocalBuild = true; 

      };
    }
  );
}
