{
  flags = {
    "--icons" = "never";
    "--color" = "always";
    "--header" = true;
    "--group-directories-first" = true;
  };

  fishIntegration = {
    shellAliases = {
      l = "eza";
      ls = "eza";
    };
    abbreviations = {
      ll = "eza -l";
      la = "eza -lah";
      lt = "eza --tree";
    };
  };
}
