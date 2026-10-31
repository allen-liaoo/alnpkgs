# fish (with ./fish.nix config) + every tool on PATH with their fish integrations merged.
# Wrappable: `shell.wrap { tools.btop = ...; integrations.git = { ... }; }`
{ alnPkgs, inputs }:

{ lib, pkgs, ... }:

let
  delta = lib.getExe alnPkgs.delta;
  nvimx = inputs.nvimx.makeNvimxWithModule pkgs.stdenv.hostPlatform.system {
    nvimx.treesitter.enableAllGrammars = true;
    nvimx.preset.nix.enable = true;
    nvimx.preset.shells.enable = true;
  };
in
{
  imports = [ ./fish.nix ];

  # mkDefault so `shell.wrap { tools.<name> = ...; }` replaces a tool without mkForce
  tools = lib.mapAttrs (_: lib.mkDefault) {
    inherit (alnPkgs)
      starship
      yazi
      fastfetch
      btop
      lazygit
      tmux
      direnv
      television
      delta
      eza
      comma
      ;
    inherit nvimx;
    inherit (pkgs)
      bat
      fd
      fzf
      ripgrep
      just
      nix-your-shell
      claude-code
      ;
    # git pages through delta
    git = alnPkgs.git.wrap {
      settings.core.pager = delta;
      settings.interactive.diffFilter = "${delta} --color-only";
    };
  };
}
