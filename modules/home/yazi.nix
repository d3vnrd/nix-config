{
  programs.yazi = {
    enable = true;
    settings = {
      mgr = {
        ratio = [0 3 5];
        show_hidden = true;
        sort_by = "extension";
        sort_dir_first = true;
        show_symlink = true;
      };
    };
  };
}
