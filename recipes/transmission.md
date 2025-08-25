# Transmission

Transmission is a lightweight, open-source BitTorrent client that is known for
its simplicity and ease of use. It is designed to be fast and efficient, making
it a popular choice for downloading and sharing files over the BitTorrent
protocol.

## Installation

### Install

Install Transmission daemon and CLI tools

```bash
sudo apt install -y transmission-daemon transmission-cli
```

Stop and disable the default service

```bash
sudo systemctl stop transmission-daemon
sudo systemctl disable transmission-daemon
```

Optionally, pin version to prevent updates

```bash
sudo apt-mark hold transmission-daemon transmission-cli transmission-common
```

Copy settings to user config directory and set ownership

```bash
sudo rsync -a /etc/transmission-daemon/ ~/.config/transmission-daemon/
sudo chown -R $USER:$USER ~/.config/transmission-daemon
```

Create a new systemd service

```bash
sudo vi /etc/systemd/system/transmission.service
```

```ini
[Unit]
Description=transmission
After=network.target

[Service]
User=your_user
ExecStart=/usr/bin/transmission-daemon --foreground --config-dir=/home/your_user/.config/transmission-daemon
Restart=on-failure
ProtectSystem=true
PrivateTmp=true
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
```

Reload systemd then enable and start the new service

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now transmission
sudo systemctl status transmission
```

### Uninstall

Stop, disable and remove the custom service

```bash
sudo systemctl disable --now transmission
sudo rm /etc/systemd/system/transmission.service
sudo systemctl daemon-reload
```

Unhold and remove installed packages

```bash
sudo apt-mark unhold transmission-daemon transmission-cli transmission-common
sudo apt purge -y transmission-daemon transmission-cli transmission-common
sudo apt autoremove -y
```

Optionally, remove user configuration

```bash
rm -rf ~/.config/transmission-daemon
```
