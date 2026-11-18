{
  settings = {
    gui.tabWidth = 2;
    git.diffRenderers = [{ command = "delta --paging=never --line-numbers"; }];
  };

  fishIntegration.abbreviations = {
    lg = "lazygit";
  };
}
