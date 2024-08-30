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
    nixpkgs.url = "github:nixos/nixpkgs/release-24.05";
    # nixpkgs.url = "github:nixos/nixpkgs/master";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  # stuff provided by the flake , keep it minimal
  outputs = {
    self,
    nixpkgs,
    unstable,
    flake-utils,
    ...
  } @ inputs: let
    systems = ["x86_64-linux"];
  in
    flake-utils.lib.eachSystem systems (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          # config.cudaSupport = true;
        };
        unstable_pkgs = import unstable {
          inherit system;
          config.allowUnfree = true;
          config.cudaSupport = true;
        };
      in rec {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            unstable_pkgs.linuxPackages.nvidia_x11
            cudaPackages.autoAddOpenGLRunpathHook
              # anyother version is broken beyond repair
            unstable_pkgs.cudaPackages_11_8.cudatoolkit-legacy-runfile
            unstable_pkgs.cudaPackages_11_8.nsight_compute
            (writeShellScriptBin "wncu" ''
              ${pkgs.cudaPackages_11.nsight_compute}/nsight-compute/2022.3.0/ncu "$@"
            '')
          ];
          packages = with pkgs; [
            gcc11
          ];
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (with pkgs; [
            "/run/opengl-driver/lib"
            unstable_pkgs.linuxPackages.nvidia_x11
          ]);
          shellHook = ''
            export CUDA_PATH=${unstable_pkgs.cudaPackages_11_8.cudatoolkit-legacy-runfile}
            export CUDA_TOOLKIT_BIN_DIR=${unstable_pkgs.cudaPackages_11_8.cudatoolkit-legacy-runfile}
          '';
        };
        devShell = self.devSHells.${system}.default;
      }
    );
}
