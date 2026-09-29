{
  programs.zsh = {
    enable = true;

    autocd = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      save = 10000;
      size = 10000;
      share = true;
      append = true;
      findNoDups = true;
      ignoreAllDups = true;
      ignoreDups = true;
      ignoreSpace = true;
      saveNoDups = true;
    };

    initContent = ''
      # ---Disable beep sound---
      setopt NO_BEEP

      # ---Custom keybind---
      bindkey '^p' history-search-backward
      bindkey '^n' history-search-forward

      # ---Misc---
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
      zstyle ':completion:*' menu select
    '';
  };
}
