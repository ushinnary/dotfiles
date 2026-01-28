{ ... }:
{
  users.users.ushinnary = {
    isNormalUser = true;
    description = "Alexander";
    group = "ushinnary";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  users.groups.ushinnary = {};
}
