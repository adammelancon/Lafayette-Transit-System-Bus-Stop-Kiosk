# Display Hardening (No Screen Blanking / No Screensaver)

This document describes all changes made to ensure the kiosk display:

* Never blanks
* Never dims
* Never sleeps
* Never activates a screensaver
* Hides the mouse pointer
* Stays on 24/7

Tested on:

* Debian 13 (Trixie)
* X11 session (Wayland disabled)
* Raspberry Pi (aarch64)

---

# 1️⃣ Disable Wayland (Use X11)

Wayland caused:

* Inconsistent kiosk startup
* VNC mirroring issues
* Display timing instability

Disable Wayland:

```bash
sudo raspi-config
```

Navigate:

```
Advanced Options → Wayland → Disable
```

Reboot:

```bash
sudo reboot
```

Verify:

```bash
loginctl show-session 1 -p Type
```

Should return:

```
Type=x11
```

---

# 2️⃣ Disable X11 Screen Blanking (Xorg Level)

Create:

```bash
sudo mkdir -p /etc/X11/xorg.conf.d
sudo nano /etc/X11/xorg.conf.d/10-no-blanking.conf
```

Add:

```conf
Section "ServerFlags"
    Option "BlankTime" "0"
    Option "StandbyTime" "0"
    Option "SuspendTime" "0"
    Option "OffTime" "0"
EndSection
```

This prevents X11 from automatically blanking or suspending the display.

---

# 3️⃣ Disable Kernel Console Blanking

Edit:

```bash
sudo nano /boot/cmdline.txt
```

Append (to the existing single line):

```
consoleblank=0
```

⚠ Do not create a new line — this file must remain one single line.

Reboot after change.

---

# 4️⃣ Disable DPMS at Runtime

Some desktop environments override Xorg settings.

Create:

```bash
sudo nano /etc/systemd/system/disable-dpms.service
```

Add:

```ini
[Unit]
Description=Disable X11 DPMS
After=graphical.target

[Service]
Type=oneshot
User=<kiosk-user>
Environment=DISPLAY=:0
ExecStart=/usr/bin/xset s off
ExecStart=/usr/bin/xset -dpms
ExecStart=/usr/bin/xset s noblank

[Install]
WantedBy=graphical.target
```

Enable:

```bash
sudo systemctl daemon-reload
sudo systemctl enable disable-dpms.service
```

This ensures:

* No screensaver
* No DPMS power-off
* No monitor sleep

---

# 5️⃣ Hide Mouse Pointer

Install:

```bash
sudo apt install unclutter
```

Option A (Recommended): Run via systemd or autostart.

Example (X session autostart):

```bash
unclutter -idle 0 &
```

Option B (inside kiosk.service before Chromium):

```ini
ExecStartPre=/usr/bin/unclutter -idle 0
```

This hides the mouse immediately.

---

# 6️⃣ Chromium Flags (Prevents Keyring / Popup Issues)

The kiosk service uses:

```
--no-first-run
--disable-geolocation
--password-store=basic
--incognito
```

These prevent:

* Keyring prompts
* Password store popups
* Location permission prompts

---

# 7️⃣ Verification Checklist

After reboot, confirm:

### Screen never blanks

Wait 10+ minutes idle.

### DPMS disabled

```bash
xset q | grep DPMS
```

Should show:

```
DPMS is Disabled
```

### Kernel blanking disabled

```bash
cat /proc/cmdline
```

Should include:

```
consoleblank=0
```

### X11 session active

```bash
loginctl show-session 1 -p Type
```

Should return:

```
Type=x11
```

---

# Final Result

The kiosk display:

* Stays on permanently
* Never dims
* Never sleeps
* Never activates screensaver
* Hides the mouse cursor
* Recovers automatically on reboot

---

