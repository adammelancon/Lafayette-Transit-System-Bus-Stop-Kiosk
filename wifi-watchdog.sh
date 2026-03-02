#!/bin/bash
if ! ping -c1 -W2 8.8.8.8 >/dev/null 2>&1; then
  echo "$(date): Wi-Fi down, restarting…" >> /var/log/wifi-watchdog.log
  sudo systemctl restart NetworkManager
fi
