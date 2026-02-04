{
  pkgs,
  ...
}:
{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    cifs-utils
    wayland-utils
    wl-clipboard
    nushell
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.symbols-only
  ];
  fonts.fontDir.enable = true;

  programs.git = {
    enable = true;
    package = pkgs.gitFull;
    config = {
      credential = {
        helper = "manager";
        credentialStore = "secretservice";
      };
    };
  };
}
