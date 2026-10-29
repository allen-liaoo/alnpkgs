# fish (with ./fish.nix config) + every tool on PATH with their fish integrations merged.
# Wrappable: `shell.wrap { tools.btop = ...; integrations.git = { ... }; }`
{ alnPkgs }:

{ lib, pkgs, ... }:

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
      ;
    inherit (pkgs)
      bat
      fd
      fzf
      ripgrep
      just
      eza
      nix-your-shell
      ;
  };
}
