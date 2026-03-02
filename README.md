# Lafayette LA Transit System Bus Stop Kiosk


Real-time lobby kiosk displaying Lafayette Transit System (LTS) arrivals and live bus map data for:

**Congress & Lafayette – Stop #1633019**  
Route: 2050  
Direction: 25790
Via: http://www.ridelts.com/

Runs 24/7 on a Raspberry Pi with fullscreen Chromium kiosk mode.

---

# System Overview

## Hardware

- Raspberry Pi (aarch64)
- 24" HDMI monitor
- Wi-Fi network
    

---

## Operating System

- Debian GNU/Linux 13 (Trixie)
- Kernel: 6.12.x (rpt-rpi-v8)
- Display stack: **X11 (Wayland disabled)**
- Window manager: Openbox-based X session

Wayland was disabled for:

- Stable VNC mirroring
- Predictable Chromium behavior
- Reliable HDMI timing
- Kiosk-grade stability

---

# Project Directory

Location:
/home/pi/kiosk/

Contents:

index.html  
editkioskservice.sh  
restartkioskservice.sh  
statuskiosk.sh  
wifi-watchdog.sh  
backups/

Backups folder contains:

- Historical index variants
- Original kiosk.service backup
- installcommands.txt (build history)

---

# Web Application

File:
/home/pi/kiosk/index.html

## Layout

- Header (Title + Stop Info + Live Clock)
- Top iframe → Arrivals
- Bottom iframe → Live Map

Layout controlled via CSS variable:

:root {  
  --header-h: 72px;  
  --split: 60%;  
}

Increase `--split` to show more arrival rows and reduce map height.

---

## Data Sources (Embedded)

Arrivals:
https://lts.syncromatics.com/m/routes/2050/direction/25790/stops/1633019/pattern

Map:
https://lts.syncromatics.com/m/regions/0/routes/2050/direction/25790/stops/1633019/map

No API keys required. Uses mobile endpoints via iframe.

---

## Refresh Behavior

Arrivals refresh every **30 seconds**:

setInterval(()=>reloadFrame("arrivalsFrame", ARRIVALS_URL), 30000);

Map refreshes every **10 minutes** (failsafe only):

setInterval(()=>reloadFrame("mapFrame", MAP_URL), 600000);

The map itself updates live internally via Syncromatics scripts.

## Reliable Data Refresh (Cache Busting)
The kiosk ensures that commuters always see the most recent data by using a "cache-busting" technique. The background refresh script appends a unique timestamp (`?t=Date.now()`) to the URL every 30 seconds. This forces the browser to bypass any saved local files and fetch fresh coordinates and arrival predictions directly from the LTS servers.

---

# Kiosk Service

Systemd file:
/etc/systemd/system/kiosk.service

## Startup Logic

- Waits for X socket
- Waits for DBus session bus
- Adds 3-second delay
- Launches Chromium fullscreen
- Auto-restarts on crash

### Key configuration

Environment=DISPLAY=:0  
Environment=XDG_RUNTIME_DIR=/run/user/1000  
Environment=DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus

### Restart policy

Restart=always  
RestartSec=5

### Chromium flags used

--kiosk  
--incognito  
--disable-geolocation  
--password-store=basic  
--disable-dev-shm-usage  
--force-device-scale-factor=1.5

---

# Convenience Scripts

Located in `/home/pi/kiosk/`

### Restart kiosk

./restartkioskservice.sh

### Check kiosk status

./statuskiosk.sh

### Edit kiosk service

./editkioskservice.sh

---

# Network Watchdog

File:

/home/pi/kiosk/wifi-watchdog.sh

Behavior:

- Pings 8.8.8.8
- If unreachable, restarts NetworkManager
- Logs events to:

/var/log/wifi-watchdog.log

## Scheduled via cron

File:
/etc/cron.d/wifi-watchdog

Runs every 5 minutes:
*/5 * * * * /home/pi/kiosk/wifi-watchdog.sh

---

# Display Hardening

Screen blanking disabled at:

- Xorg level
- Kernel console level (`consoleblank=0`)
- DPMS disabled via systemd service
    

Result:

- No dimming
- No sleep
- No blank screen
- 24/7 always-on display

---

# Remote Management

VNC:
vncserver-x11-serviced

Requires:

- X11 session
- RealVNC Viewer (UltraVNC incompatible)

Authentication:

- System authentication (Linux username/password)

---

# Troubleshooting Checklist

## Black Screen on Boot

Check service:
sudo systemctl status kiosk.service -l

Restart if needed:
sudo systemctl restart kiosk.service

Verify X session:
loginctl show-session 1 -p Type
Should return:
Type=x11

---

## Screen Blanking

Confirm:
cat /etc/X11/xorg.conf.d/10-no-blanking.conf  
cat /proc/cmdline

Ensure `consoleblank=0` is present.

---

## No Network / Lost IP

Check interface:
ip addr show wlan0

Check NetworkManager logs:
journalctl -u NetworkManager -b

Check watchdog log:
cat /var/log/wifi-watchdog.log

---

## Map or Arrivals Not Updating

Restart kiosk:
./restartkioskservice.sh

Or full reboot:
sudo reboot

---

## VNC Not Connecting

Check VNC service:
sudo systemctl status vncserver-x11-serviced

Confirm port listening:
sudo ss -tlnp | grep 5900

Ensure firewall allows TCP 5900.

    

    

---

# Deployment Notes

To reload kiosk after editing index.html:
./restartkioskservice.sh

To edit kiosk service safely:
./editkioskservice.sh
