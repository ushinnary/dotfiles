# Agent instructions

Each evolution of files should keep in mind modularity.
Nixos related changes will touch multiple hosts at the time.
If options don't exist for something that we should condition on so we avoid breaking other hosts, so create this option and do needed conditions in a nix way.

Main nixos entry point is in `./nix` directory, you may run multiple commands inside of it :

- `nfc` - Will run checks for all hosts. This is what we should do after each modification that could break any host.
- `nfu` - Will update all flakes of the system with upgrade of `flake.lock` file.

Do not run `rebuild` in any manner, it is up to me to do that.
