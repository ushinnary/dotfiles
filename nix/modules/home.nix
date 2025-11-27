# { config, pkgs, ... }:
#
# {
#   home.stateVersion = "25.05";
#
#   home.packages = with pkgs; [
#     gnomeExtensions.blur-my-shell
#     gnomeExtensions.just-perfection
#     gnomeExtensions.appindicator
#     gnomeExtensions.night-theme-switcher
#     gnomeExtensions.dash-to-dock
#     gnomeExtensions.vitals
#   ];
#
#   dconf.settings = {
#     "org/gnome/mutter" = {
#       experimental-features = [
#         "scale-monitor-framebuffer" # Enables fractional scaling (125% 150% 175%)
#         "variable-refresh-rate" # Enables Variable Refresh Rate (VRR) on compatible displays
#         "xwayland-native-scaling" # Scales Xwayland applications to look crisp on HiDPI screens
#       ];
#     };
#     "org/gnome/shell" = {
#       disable-user-extensions = false;
#       # enabled-extensions = [
#       #   "user-theme@gnome-shell-extensions.gcampax.github.com"
#       #   "blur-my-shell@aunetx.gnome.org"
#       #   "dash-to-dock@micxgx.gmail.com"
#       #   "burn-my-windows@schneegans.github.com"
#       #   "compiz-windows-effect@hermes83.github.com"
#       #   "gesture-improvements@gesture-improvements.github.com"
#       # ];
#     };
#
#     # Настройки шрифтов
#     "org/gnome/desktop/interface" = {
#       font-name = "Inter 11";
#       document-font-name = "Inter 11";
#       monospace-font-name = "JetBrains Mono 10";
#     };
#   };
# }
