{
  lib,
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,
  expat,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ipu7-camera-bins";
  version = "20250921_1733_232_PTL_Beta_IoT";

  src = fetchFromGitHub {
    repo = "ipu7-camera-bins";
    owner = "intel";
    rev = "09ccd020d5d1aa34b91e9f30b01a4166dd31f51b";
    hash = "sha256-d/WtM7oiq6zDQ5nLGqOFcjWDTLOSShPDYdC+wog3zbY=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    (lib.getLib stdenv.cc.cc)
    expat
    zlib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp --no-preserve=mode --recursive \
      lib \
      include \
      $out/

    # REVIEW file exists now
    # There is no LICENSE file in the src
    # install -m 0644 -D LICENSE $out/share/doc/LICENSE

    runHook postInstall
  '';

  postFixup = ''
    for lib in $out/lib/lib*.so.*; do \
      lib=''${lib##*/}; \
      target=$out/lib/''${lib%.*}; \
      if [ ! -e "$target" ]; then \
        ln -s "$lib" "$target"; \
      fi \
    done

    for pcfile in $out/lib/pkgconfig/*.pc; do
      substituteInPlace $pcfile \
        --replace 'prefix=/usr' "prefix=$out"
    done
  '';

  meta = with lib; {
    description = "IPU firmware and proprietary image processing libraries";
    homepage = "https://github.com/intel/ipu7-camera-bins";
    license = licenses.issl;
    sourceProvenance = with sourceTypes; [
      binaryFirmware
    ];
    maintainers = [ ];
    platforms = [ "x86_64-linux" ];
  };
})
