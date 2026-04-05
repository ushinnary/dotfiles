{
  config,
  vars,
  ...
}:
{
  users.users."${vars.userName}" = {
    isNormalUser = true;
    description = "Alexander";
    group = vars.userName;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKHRsmOjUoYncjrQJgnBTiUeRxkzEsuclK7TgiWxTRmq ushinnary@ryzo"
    ];
  };

  users.groups."${vars.userName}" = { };

  security.sudo.extraRules = [
    {
      users = [ vars.userName ];
      commands = map (command: {
        command = command;
        options = [ "NOPASSWD" ];
      }) config.ushinnary.security.sudo.passwordlessCommands;
    }
  ];
}
