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
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKHRsmOjUoYncjrQJgnBTiUeRxkzEsuclK7TgiWxTRmq ushinnary@ryzo"
    ];
  };

  users.groups.ushinnary = { };

  security.sudo.extraRules = [
    {
      users = [ "ushinnary" ];
      commands = map (command: {
        command = command;
        options = [ "NOPASSWD" ];
      }) config.ushinnary.security.sudo.passwordlessCommands;
    }
  ];
}
