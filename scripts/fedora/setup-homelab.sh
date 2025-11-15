#!/bin/sh
sudo rpm-ostree install cockpit \
  cockpit-system \
  cockpit-ostree \
  cockpit-podman \
  cockpit-storaged \
  cockpit-networkmanager \
  cockpit-selinux \
  cockpit-sosreport \
  cockpit-files

