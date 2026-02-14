{
  pkgs,
  config,
  lib,
  ...
}:
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

  users.groups.ushinnary = { };

  security.sudo.extraRules = [
    {
      users = [ "ushinnary" ];
      commands = map (command: {
        command = command;
        options = [ "NOPASSWD" ];
      }) config.ushinnary.security.sudo.noPasswdCommands;
    }
  ];
}
