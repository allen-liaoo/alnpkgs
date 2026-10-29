{
  config,
  wlib,
  lib,
  pkgs,
  ...
}:

let
  television = pkgs.fetchFromGitHub {
    owner = "alexpasmantier";
    repo = "television";
    rev = "0.15.6";
    hash = "sha256-vA9eUzgkfh1UEjTfswJaWe0Z20xUqx29nunPIQs7oyc=";
    sparseCheckout = [
      "/cable/unix"
    ];
  };
  cable = c: {
    ${c} = builtins.fromTOML (builtins.readFile "${television}/cable/unix/${c}.toml");
  };
  nix-search-tv = {
    # see https://github.com/3timeslazy/nix-search-tv#television
    metadata = {
      name = "nix-search-tv";
      description = "Search nix options and packages";
    };
    source.command = "${lib.getExe pkgs.nix-search-tv} print";
    preview.command = ''${lib.getExe pkgs.nix-search-tv} preview "{}"'';

    actions.run = {
      command = ''nix run {replace:s/\/ /#/g}'';
      mode = "fork";
    };
    actions.shell = {
      command = ''nix shell {replace:s/\/ /#/g}'';
      mode = "execute";
    };
  };
in
{
  channels = lib.mkMerge [
    (cable "channels")
    {
      channels.preview.command = lib.mkForce "bat -pn --color always ${config.channelsDir}/{}.toml";
    }
    (cable "files") # fd
    (cable "fish-history") # fish
    (cable "fonts") # fc-list
    (cable "journal") # journalctl
    (cable "man-pages") # apropos, man
    (cable "text") # rg
    { inherit nix-search-tv; }
  ];

  runtimePkgs = with pkgs; [
    bat
    fd
    ripgrep
  ];

  fishIntegration.abbreviations = {
    tvc = "tv channels";
    tvj = "tv journal";
    tvn = "tv nix-search-tv";
    tvt = "tv text";
  };
}
