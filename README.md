# Server Kit

A collection of scripts, configurations, and tools for server management.

## Usage

Clone the repository somewhere on your system, and then install the components
you need.

```bash
git clone https://github.com/epistrephein/serverkit.git /tmp/serverkit
```

### colors

```bash
mkdir -p ~/.local/share/mc/skins
cp /tmp/serverkit/colors/mc/nord16M.ini ~/.local/share/mc/skins/

mkdir -p ~/.vim/colors
cp /tmp/serverkit/colors/vim/nord.vim ~/.vim/colors/
```

### dotfiles

```bash
cat /tmp/serverkit/dotfiles/bashrc >> ~/.bashrc
cat /tmp/serverkit/dotfiles/inputrc > ~/.inputrc
cat /tmp/serverkit/dotfiles/vimrc > ~/.vimrc
cat /tmp/serverkit/dotfiles/tmux.conf > ~/.tmux.conf
```

### motd

```bash
sudo cp /tmp/serverkit/motd/20-banner /etc/update-motd.d/20-banner
sudo chmod +x /etc/update-motd.d/20-banner
```

### nginx & www

```bash
SERVER_NAME=myserver
SERVER_URL="$SERVER_NAME.domain.com"

# Create the website directory and set permissions
sudo mkdir -p /var/www/$SERVER_URL/
sudo chown -R $USER:$USER /var/www/$SERVER_URL
sudo chmod -R 755 /var/www

# Copy the website files and update the HTML files
cp /tmp/serverkit/www/* /var/www/$SERVER_URL/
sed -i "s|machine|$SERVER_NAME|g" /var/www/$SERVER_URL/*.html

# Copy the nginx configuration and set it up
sudo cp /tmp/serverkit/nginx/basic /etc/nginx/sites-available/$SERVER_URL
sudo sed -i "s|your\.domain\.com|$SERVER_URL|g" /etc/nginx/sites-available/$SERVER_URL
sudo sed -i "s|/var/www/html|/var/www/$SERVER_URL|g" /etc/nginx/sites-available/$SERVER_URL
sudo ln -s /etc/nginx/sites-available/$SERVER_URL /etc/nginx/sites-enabled/$SERVER_URL

# Remove the default nginx configuration and reload nginx
sudo rm /etc/nginx/sites-enabled/default
sudo rm /etc/nginx/sites-available/default
sudo rm -rf /var/www/html
sudo systemctl reload nginx

# Create the SSL directory for site certificates
sudo mkdir -p /etc/nginx/certs/$SERVER_URL
sudo chown -R $USER:$USER /etc/nginx/certs/$SERVER_URL

# Issue and install the SSL certificate using acme.sh, which will verify the domain ownership
acme.sh --issue -d $SERVER_URL -w /var/www/$SERVER_URL
acme.sh --install-cert -d $SERVER_URL --key-file /etc/nginx/certs/$SERVER_URL/key.pem --fullchain-file /etc/nginx/certs/$SERVER_URL/fullchain.pem --reloadcmd "sudo systemctl restart nginx"

# Copy the SSL nginx configuration and set it up
sudo cp /tmp/serverkit/nginx/main+ssl /etc/nginx/sites-available/$SERVER_URL
sudo sed -i "s|your\.domain\.com|$SERVER_URL|g" /etc/nginx/sites-available/$SERVER_URL
sudo sed -i "s|/var/www/html|/var/www/$SERVER_URL|g" /etc/nginx/sites-available/$SERVER_URL
sudo systemctl reload nginx
```

### setup

This contains a script for the initial setup of a server.  
Customize the variables at the top and then run it as root:

```bash
sudo su -
/tmp/serverkit/setup/ubuntu-24.04.sh
```

### scripts

```bash
mkdir -p ~/.local/scripts
cp /tmp/serverkit/scripts/* ~/.local/scripts/
chmod +x ~/.local/scripts/*.sh
```

You can add the scripts to cron to run them periodically:

```
# -- SCRIPTS -------------------
15 */3 * * * "/home/your_user/.local/scripts/notify-disk-full.sh"
20 */3 * * * "/home/your_user/.local/scripts/notify-public-ipv4.sh"

0 5 * * 2 "/home/your_user/.local/scripts/dump-settings.sh"

30 6 25 * * "/home/your_user/.local/scripts/backup-postgresql.sh"
40 6 25 * * "/home/your_user/.local/scripts/backup-settings.sh"
# ------------------------------
```
