{
  lib,
  stdenv,
  appstream,
  blueprint-compiler,
  cargo,
  dav1d,
  desktop-file-utils,
  fetchFromGitLab,
  glib,
  gst_all_1,
  gtk4,
  lcms,
  libadwaita,
  libseccomp,
  libwebp,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  rustPlatform,
  rustc,
  versionCheckHook,
  wrapGAppsHook4,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "identity";
  version = "25.03";

  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "YaLTeR";
    repo = "identity";
    tag = "v${finalAttrs.version}";
    hash = "sha256-JZyhT220ARZ2rX0CZYeFkHx8i9ops7TcfGje0NKebnU=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-RCSTxtHXkLsH8smGp2XzQeV9SSpLx5llrFg3cgIsWKY=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    appstream
    blueprint-compiler
    cargo
    desktop-file-utils # for `desktop-file-validate`
    glib # for `glib-compile-schemas`
    gtk4 # for `gtk-update-icon-cache`
    meson
    ninja
    pkg-config
    rustPlatform.cargoCheckHook
    rustPlatform.cargoSetupHook
    rustc
    wrapGAppsHook4
  ];

  buildInputs = [
    dav1d
    gst_all_1.gst-libav
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gstreamer
    gtk4
    lcms
    libadwaita
    libseccomp
    libwebp
  ];

  mesonBuildType = "release";

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  cargoCheckType = if (finalAttrs.mesonBuildType != "debug") then "release" else "debug";

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  checkPhase = ''
    runHook preCheck

    cargoCheckHook
    mesonCheckPhase

    runHook postCheck
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Program for comparing multiple versions of an image or video";
    homepage = "https://gitlab.gnome.org/YaLTeR/identity";
    changelog = "https://gitlab.gnome.org/YaLTeR/identity/-/releases/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    teams = [ lib.teams.gnome-circle ];
    mainProgram = "identity";
    platforms = lib.platforms.linux;
  };
})
