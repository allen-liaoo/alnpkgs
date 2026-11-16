{
  buildGoModule,
  fetchFromGitHub,
  lib,
  makeWrapper,

  glib,
  gst_all_1,
  libheif,
  pipewire,
  pulseaudio,
}:

let
  # dlopen'd through purego, so they never show up as linked libraries
  gstLibs = [
    glib
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
  ];
  gstPlugins = with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad # also provides the va elements used for mirroring
    gst-libav
    pipewire
  ];
in
buildGoModule (finalAttrs: {
  pname = "dux-cast";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "Conava";
    repo = finalAttrs.pname;
    rev = "v${finalAttrs.version}";
    hash = "sha256-39pZjbktT/mFBesS089QnW01qefsQQAE4iHJb4wMeDg=";
  };

  vendorHash = "sha256-JdnJBwV2DHo/1EZ5v6bxC1JK/5PUIZeRmjroMnZrQoQ=";

  env.CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
  ];

  nativeBuildInputs = [ makeWrapper ];

  postInstall = ''
    mv $out/bin/dux-cast $out/bin/cast-helper
    wrapProgram $out/bin/cast-helper \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath gstLibs} \
      --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : ${lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" gstPlugins} \
      --prefix PATH : ${
        lib.makeBinPath [
          gst_all_1.gstreamer # gst-launch-1.0, gst-inspect-1.0 for doubletake
          libheif # heif-dec
          pipewire # pw-metadata
          pulseaudio # pactl for doubletake
        ]
      }
  '';

  meta = {
    description = "Cast the screen, files, music and links from Linux to Chromecast and AirPlay devices";
    longDescription = ''
      Backend of the Dux Shell Cast plugin. Device discovery needs a running avahi-daemon
      (services.avahi.enable on NixOS) and mirroring needs a VA-API driver that can encode H.264 or HEVC.
      AirPlay mirroring additionally needs doubletake on PATH.
    '';
    homepage = "https://github.com/Conava/dux-cast";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "cast-helper";
  };
})
