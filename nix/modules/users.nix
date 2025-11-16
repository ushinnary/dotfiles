{ pkgs, ... }:
{
  users.users.ushinnary = {
    isNormalUser = true;
    description = "Alexander";
    extraGroups = [
      "networkmanager"
      "wheel"
      "i2c"
    ];
  };
}
