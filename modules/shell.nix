# A fish wrapper bundling programs (on PATH) and merging their fish integrations
{
  config,
  lib,
  wlib,
  ...
}:

let
  tools = lib.filterAttrs (_: t: t != null) config.tools;
  active = lib.attrValues (lib.filterAttrs (_: i: i.enable) config.integrations);
  collect = f: lib.mkMerge (map f active);
  joinLines = f: lib.concatStringsSep "\n" (lib.filter (s: s != "") (map f active));
in
{
  imports = [ wlib.wrapperModules.fish ];

  options = {
    tools = lib.mkOption {
      type = with lib.types; attrsOf (nullOr package);
      description = ''
        Programs bundled into the shell (put on PATH). Set one to `null` to remove it
        and its integration; replace one to customize it (e.g. a re-themed btop).
      '';
    };
    integrations = lib.mkOption {
      type = with lib.types; attrsOf (submodule ../lib/fish-integration-type.nix);
      default = { };
      description = ''
        Fish integrations keyed by program name. Defaults to each tool's
        `passthru.fishIntegration`; programs without one are declared here.
      '';
    };
  };

  config = {
    # prepend (runtimePkgs appends), so bundled tools win over same-named ones already on PATH
    prefixVar = [
      [
        "PATH"
        ":"
        (lib.makeBinPath (lib.attrValues tools))
      ]
    ];

    integrations = lib.mkMerge [
      # tools that carry their own integration
      (lib.mapAttrs (_: t: lib.mkIf (t ? fishIntegration) t.fishIntegration) tools)

      # plain packages have no fishIntegration, so declare theirs here
      {
        bat.shellAliases.cat = "bat";
        eza.shellAliases = {
          l = "eza";
          ls = "eza";
        };
        eza.abbreviations = {
          ll = "eza -l";
          la = "eza -lah";
          lt = "eza --tree";
        };
        just.abbreviations.js = "just";
        nvimx.env = {
          EDITOR = "nvim";
          VISUAL = "nvim";
        };
        nvimx.shellAliases = {
          v = "nvim";
          vi = "nvim";
          vim = "nvim";
        };
        nix-your-shell.interactiveInit = "${lib.getExe config.tools.nix-your-shell} fish | source";
      }

      # a tool set to null turns its integration off; integrations for programs
      # outside `tools` (e.g. ones from home-manager) stay on
      (lib.genAttrs (lib.attrNames config.tools) (n: {
        enable = lib.mkDefault (config.tools.${n} != null);
      }))
    ];

    env = collect (i: i.env);
    shellAliases = collect (i: i.shellAliases);
    abbreviations = collect (i: i.abbreviations);
    configFile.content = lib.mkAfter ''
      ${joinLines (i: i.init)}
      if status is-interactive
        ${joinLines (i: i.interactiveInit)}
      end
    '';
  };
}
