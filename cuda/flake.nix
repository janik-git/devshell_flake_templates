{
  description = "cuda shell";
  # declares overlays/channels etc for packages to use 
nixConfig = {
    extra-substituters = [
      "https://cuda-maintainers.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    ];
  };
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-23.11";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  # stuff provided by the flake , keep it minimal
  outputs = {
    self,
    nixpkgs,
    unstable,
    flake-utils,
    # cudaPackages,
    ...
  } @ inputs: let
    systems = ["x86_64-linux"];
    in
    flake-utils.lib.eachSystem systems (
      system: let 
        pkgs = import nixpkgs{
          inherit system ; 
          config.allowUnfree = true;
          # config.cudaSupport=true;
          };
        unstable_pkgs = import unstable {
          inherit system;
          config.allowUnfree = true;
          config.cudaSupport=true;
        };
        in rec {
          devShells.default = pkgs.mkShell {
              buildInputs = with unstable_pkgs; [
                pkgs.linuxPackages.nvidia_x11
                cudaPackages.autoAddOpenGLRunpathHook
                pkgs.cudaPackages_11.cudatoolkit
                pkgs.cudaPackages_11.nsight_compute
                (writeShellScriptBin "wncu" ''
                ${pkgs.cudaPackages_11.nsight_compute}/nsight-compute/2022.3.0/ncu "$@"
                '')
              ] ;
              packages = with pkgs; [
                gcc11
              ];
              LD_LIBRARY_PATH= pkgs.lib.makeLibraryPath(with pkgs;[
                  "/run/opengl-driver/lib"
                  pkgs.linuxPackages.nvidia_x11_production
              ]);
              shellHook =''
                CUDA_PATH=${pkgs.cudaPackages_11.cudatoolkit}
                CUDA_TOOLKIT_BIN_DIR=${pkgs.cudaPackages_11.cudatoolkit}
              '';
          };
          devShell = self.devSHells.${system}.default;
        }
    );
}
