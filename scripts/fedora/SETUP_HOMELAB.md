# Setup for fedora IOT homelab

* Put the following to the /etc/ssh/sshd_config

```
Match Group homelab-dev
    # Security restrictions
    X11Forwarding no
    AllowTcpForwarding yes
    PermitTunnel no

    # Force the smart script we created above
    ForceCommand /usr/local/bin/box-login.sh
```

* Next, copy `box-login.sh` to `/usr/local/bin/`
