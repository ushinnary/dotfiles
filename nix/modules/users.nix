{ pkgs, ... }:
{
  users.users.ushinnary = {
    isNormalUser = true;
    description = "Alexander";
    group = "ushinnary";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.nushell;
  };

  users.groups.ushinnary = {};
}
