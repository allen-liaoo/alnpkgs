{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.theme = lib.mkOption {
    type = lib.types.str;
    default = "${pkgs.btop}/share/btop/themes/nord.theme";
    description = ''
      Path to a btop `.theme` file. May be out of store (pass a string, not a nix path).
      btop only resolves `color_theme` by name inside its theme dirs,
      so the file's directory is passed as `--themes-dir`.
    '';
  };

  config = {
    settings = {
      theme_background = false;
      truecolor = true;
      color_theme = lib.removeSuffix ".theme" (baseNameOf config.theme);
    };
    flags."--themes-dir" = dirOf config.theme;
  };
}
