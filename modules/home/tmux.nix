{pkgs, ...}: {
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    terminal = "xterm-256color";
    mouse = true;
    keyMode = "vi";
    shortcut = "space";
    sensibleOnTop = true;
    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = yank;
        extraConfig = "set -g @yank_selection_mouse 'clipboard'";
      }
    ];
  };
}
