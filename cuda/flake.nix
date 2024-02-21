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
              nativeBuildInputs = with unstable_pkgs; [
                 cudaPackages.autoAddOpenGLRunpathHook
                  # cudaPackages_11_8.cuda_cccl 
                  # cudaPackages_11_8.cuda_cudart 
                  # cudaPackages_11_8.cuda_cuobjdump 
                  # cudaPackages_11_8.cuda_cupti 
                  # cudaPackages_11_8.cuda_cuxxfilt 
                  # cudaPackages_11_8.cuda_demo_suite 
                  # cudaPackages_11_8.cuda_documentation 
                  # # cudaPackages_11_8.cuda_gdb 
                  # cudaPackages_11_8.cuda_memcheck 
                  # cudaPackages_11_8.cuda_nsight 
                  # cudaPackages_11_8.cuda_nvcc 
                  # # cudaPackages_11_8.cuda_nvdisasm 
                  # cudaPackages_11_8.cuda_nvml_dev 
                  # cudaPackages_11_8.cuda_nvprof 
                  # cudaPackages_11_8.cuda_nvprune 
                  # cudaPackages_11_8.cuda_nvrtc 
                  # cudaPackages_11_8.cuda_nvtx 
                  # cudaPackages_11_8.cuda_nvvp 
                  # cudaPackages_11_8.cuda_sanitizer_api 
                  # cudaPackages_11_8.cudatoolkit 
                  # cudaPackages_11_8.cudnn 
                  # cudaPackages_11_8.cutensor 
                  # cudaPackages_11_8.fabricmanager 
                  # cudaPackages_11_8.libcublas 
                  # cudaPackages_11_8.libcufft 
                  # cudaPackages_11_8.libcufile 
                  # cudaPackages_11_8.libcurand 
                  # cudaPackages_11_8.libcusolver 
                  # cudaPackages_11_8.libcusparse 
                  # cudaPackages_11_8.libnpp 
                  # cudaPackages_11_8.libnvidia_nscq 
                  # cudaPackages_11_8.libnvjpeg 
                  # cudaPackages_11_8.nccl 
                 #  #completly unusable
                  # cudaPackages_12_0.nsight_compute 
                 # # broken, only non ui works
                 #
                 #  cudaPackages.nsight_systems 
                # cudaPackages_12.cudatoolkit
                pkgs.cudaPackages_11.cudatoolkit
                pkgs.cudaPackages_11.nsight_compute

                (writeShellScriptBin "wncu" ''
                # CUDA_PATH=${pkgs.cudaPackages_11.cudatoolkit}
                # CUDA_TOOLKIT_BIN_DIR=${pkgs.cudaPackages_11.cudatoolkit}
                # LD_LIBRARY_PATH="${pkgs.linuxPackages.nvidia_x11_production}/lib"
                ${pkgs.cudaPackages_11.nsight_compute}/nsight-compute/2022.3.0/ncu "$@"
                '')
              ];
              # propgatedBuildInputs = [
              #   pkgs.gst_all_1.gst-plugins-base
              # ];
              buildInputs = with unstable_pkgs; [
                # pkgs.util-linux
                # libGLU 
                # libGL
                # pkgs.auto.nixGLDefault
                # unstable_pkgs.cudaPackages_12_1.cudatoolkit
                pkgs.linuxPackages.nvidia_x11
                # xorg.libXi xorg.libXmu freeglut
                # xorg.libXext xorg.libX11 xorg.libXv xorg.libXrandr zlib 
                # ncurses5 binutils
                # unstable_pkgs.cudaPackages.nsight_systems
              ] ;
              packages = with pkgs; [
                gcc11
                # (writeShellScriptBin "wncu" ''
                # .${unstable_pkgs.cudaPackages_11.nsight_compute.out}/nsight-compute/2022.3.0/ncu "$@"
                # '')
              ];
              LD_LIBRARY_PATH= pkgs.lib.makeLibraryPath(with pkgs;[
                  "/run/opengl-driver/lib"
                  pkgs.linuxPackages.nvidia_x11_production
                    # xorg.libX11
                    # xorg.libXcursor
                    # xorg.libXrandr
                    # xorg.libXi
              ]);
              shellHook =''
                CUDA_PATH=${pkgs.cudaPackages_11.cudatoolkit}
                CUDA_TOOLKIT_BIN_DIR=${pkgs.cudaPackages_11.cudatoolkit}
                # LD_LIBRARY_PATH="${pkgs.linuxPackages.nvidia_x11}/lib"
                # export EXTRA_LDFLAGS="-L/lib -L${pkgs.linuxPackages.nvidia_x11}/lib"
                # export EXTRA_CCFLAGS="-I/usr/include"
                $SHELL
                exit
              '';
          };
          devShell = self.devSHells.${system}.default;
        }
    );
}
