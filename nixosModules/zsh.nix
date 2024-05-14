{ pkgs, config, lib, ... }: {
  
  # TODO: enable option (default true)
  # TODO: home-manager

  config = {
    users.defaultUserShell = pkgs.zsh;

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      syntaxHighlighting.highlighters = [
        "main"
        "brackets"
        "pattern"
        "root"
        "line"
      ];
      ohMyZsh = {
        enable = true;
        plugins = [ "git" "direnv" ];
        theme = "robbyrussell";
      };
    };
  };
}
