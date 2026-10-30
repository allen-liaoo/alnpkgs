{ config, lib, ... }:

{
  settings = {
    user = {
      name = "Allen Liao";
      email = "wcliaw610@gmail.com";
    };
    push.autoSetupRemote = true;
    core.attributesFile = config.constructFiles.gitattributes.path;
  };

  constructFiles.gitattributes = {
    relPath = "${config.binName}attributes";
    content = lib.concatMapStrings (p: "${p} binary\n") [
      "*.pdf"
      "*.png"
      "*.jpg"
      "*.jpeg"
      "*.webp"
    ];
  };

  fishIntegration.abbreviations = {
    g = "git";
    gs = "git status";
    ga = "git add";
    gb = "git branch";
    gch = "git checkout";
    gc = "git commit -m";
    gd = "git diff";
    gf = "git fetch";
    gp = "git push";
    gpl = "git pull";
    grb = "git rebase";
    gm = "git merge";
    gl = "git log";
  };
}
