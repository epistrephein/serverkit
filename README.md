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
# Create the website directory and set permissions
NGINXSITE="example.com"
sudo mkdir -p /var/www/$NGINXSITE/
sudo chown -R $USER:$USER /var/www/$NGINXSITE
sudo chmod -R 755 /var/www

# Copy the website files and update the HTML files
cp /tmp/serverkit/www/* /var/www/$NGINXSITE/
sed -i "s|machine|$NGINXSITE|g" /var/www/$NGINXSITE/*.html

# Copy the nginx configuration and set it up
sudo cp /tmp/serverkit/nginx/basic /etc/nginx/sites-available/$NGINXSITE
sudo sed -i "s|your\.domain\.com|$NGINXSITE|g" /etc/nginx/sites-available/$NGINXSITE
sudo sed -i "s|/var/www/html|/var/www/$NGINXSITE|g" /etc/nginx/sites-available/$NGINXSITE
sudo ln -s /etc/nginx/sites-available/$NGINXSITE /etc/nginx/sites-enabled/$NGINXSITE
sudo systemctl reload nginx
```

### scripts

```bash
mkdir -p ~/.local/scripts
cp /tmp/serverkit/scripts/* ~/.local/scripts/
chmod +x ~/.local/scripts/*.sh
```

You can add the scripts to cron to run them periodically:

```
# -- SCRIPTS ------------------
20 */3 * * * "/home/your_user/.local/scripts/public-ipv4.sh"

0 5 * * 2 "/home/your_user/.local/scripts/dump-settings.sh"

30 6 25 * * "/home/your_user/.local/scripts/backup-postgresql.sh"
40 6 25 * * "/home/your_user/.local/scripts/backup-settings.sh"
# ------------------------------
```
