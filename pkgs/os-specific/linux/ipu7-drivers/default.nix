{
  lib,
  stdenv,
  fetchFromGitHub,
  ivsc-driver,
  kernel,
  kernelModuleMakeFlags,
}:

stdenv.mkDerivation rec {
  pname = "ipu7-drivers";
  version = "20250921_1733_232_PTL_Beta_IoT";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "ipu7-drivers";
    rev = "62a3704433c35d3bdfa679fc4dee74e133ce815c";
    hash = "sha256-jScMYJAYtw9M4w+jyIBOF1JxO1Hv/EYWNI6I4B/8I9g=";
  };

  # REVIEW
  # patches = [
  #   "${src}/patches/0001-v6.10-IPU7-headers-used-by-PSYS.patch"
  # ];

  postPatch = ''
    cp --no-preserve=mode --recursive --verbose \
      ${ivsc-driver.src}/backport-include \
      ${ivsc-driver.src}/drivers \
      ${ivsc-driver.src}/include \
      .
  '';

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernelModuleMakeFlags ++ [
    "KERNELRELEASE=${kernel.modDirVersion}"
    "KERNEL_SRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  enableParallelBuilding = true;

  preInstall = ''
    sed -i -e "s,INSTALL_MOD_DIR=,INSTALL_MOD_PATH=$out INSTALL_MOD_DIR=," Makefile
  '';

  installTargets = [
    "modules_install"
  ];

  meta = {
    homepage = "https://github.com/intel/ipu7-drivers";
    description = "IPU7 kernel driver";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
    # REVIEW
    # requires 6.10
    broken = kernel.kernelOlder "6.10";
  };
}
