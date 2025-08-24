# Google Chrome

Google Chrome is a popular web browser developed by Google, known for its speed,
simplicity, and security features. It can be used in headless mode for automated
testing or web scraping.

## Installation

### Install

```bash
# ensure required packages are installed
sudo apt install -y lsb-release curl gpg

# download and store Google GPG key
curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /etc/apt/keyrings/google-linux.gpg

# add the Google Chrome APT source
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/google-linux.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list

# update and install Google Chrome
sudo apt update
sudo apt install -y google-chrome-stable

# verify installation
google-chrome-stable --version
```

### Uninstall

```bash
# purge Google Chrome and remove its dependencies
sudo apt purge -y google-chrome-stable
sudo apt autoremove --purge -y

# remove the Google Chrome APT source
sudo rm -f /etc/apt/sources.list.d/google-chrome.list

# remove the Google GPG keyring
sudo rm -f /etc/apt/keyrings/google-linux.gpg

# update package lists
sudo apt update
```
