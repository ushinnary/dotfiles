{
  lib,
  stdenvNoCC,
  fetchurl,
}:
# Not in nixpkgs yet, and the pinned google-fonts snapshot predates it.
# Fetches only the variable TTF instead of the whole google/fonts repo.
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "google-sans-flex";
  version = "0-unstable-2026-09-24";

  src = fetchurl {
    # Store names can't contain '[' or ',', hence the explicit name.
    name = "GoogleSansFlex.ttf";
    url = "https://raw.githubusercontent.com/google/fonts/a0e3dbcdc3a3ecfafff3f071159ae0221628922d/ofl/googlesansflex/GoogleSansFlex%5BGRAD%2CROND%2Copsz%2Cslnt%2Cwdth%2Cwght%5D.ttf";
    hash = "sha256-wxpIL77L8uB+aJATTSAHhyOq33Msm5xsmkT4b4Jltv4=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm444 $src $out/share/fonts/truetype/GoogleSansFlex.ttf
    runHook postInstall
  '';

  meta = {
    description = "Google Sans Flex variable font family";
    homepage = "https://fonts.google.com/specimen/Google+Sans+Flex";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
  };
})
