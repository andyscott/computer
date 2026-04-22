{
  xdg.configFile."ghostty/config".text = ''
    # Avoid macOS native tabs: yabai sees each native tab as a separate window.
    keybind = cmd+t=new_window
    window-save-state = never
    macos-dock-drop-behavior = new-window
  '';
}
