#!/bin/bash

###########################################################
#  VARIABLES
###########################################################

NEWUSER="epistrephein"
SSHPORT=4444
ALLOWEDPORTS=( 80 443 "$SSHPORT" )
TIMEZONE="Etc/UTC"
PACKAGES=( tmux git htop ncdu nload autojump unzip tree silversearcher-ag ccze nginx-extras )

###########################################################

export DEBIAN_FRONTEND=noninteractive

# define locale
locale-gen --purge --no-archive en_US.UTF-8
localedef -i en_US -f UTF-8 en_US.UTF-8
update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8

# use apt through IPv4
echo 'Acquire::ForceIPv4 "true";' | tee /etc/apt/apt.conf.d/99force-ipv4

# update packages and install basic utils
apt-get update
apt-get -y upgrade
apt-get install -y sudo curl wget vim gpg ufw fail2ban lsb-release ca-certificates unattended-upgrades landscape-common software-properties-common

# create new sudo user
adduser --gecos "" --disabled-password $NEWUSER
gpasswd -a $NEWUSER sudo
echo "$NEWUSER ALL=(ALL) NOPASSWD: ALL" | tee "/etc/sudoers.d/$NEWUSER" > /dev/null
chmod 440 "/etc/sudoers.d/$NEWUSER"

# add authorized SSH keys
su $NEWUSER -c "cd; mkdir .ssh; chmod 700 .ssh; touch .ssh/authorized_keys; chmod 600 .ssh/authorized_keys"
curl -s https://github.com/$NEWUSER.keys | tee -a /home/$NEWUSER/.ssh/authorized_keys

# change SSH port and disable root login
sed -i -e "/^#*Port/s/^.*$/Port $SSHPORT/" /etc/ssh/sshd_config
sed -i -e '/^#*PermitRootLogin/s/^.*$/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i -e '/^#*PasswordAuthentication/s/^.*$/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart ssh.service

# enable ufw
for p in "${ALLOWEDPORTS[@]}"; do
  ufw allow "$p/tcp"
done
ufw --force enable

# enable fail2ban
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sed -i 's/bantime *= *10m/bantime = 30m/g' /etc/fail2ban/jail.local
sed -i "s/port *= *ssh/port = $SSHPORT/g" /etc/fail2ban/jail.local
fail2ban-client stop
systemctl enable fail2ban.service
systemctl restart fail2ban.service

# set timezone and install ntp
timedatectl set-timezone "$TIMEZONE"
apt-get install -y ntp

# set unattended-upgrades autoinstall and reboot
sed -i 's/^\/\/Unattended-Upgrade::Automatic-Reboot "false";/Unattended-Upgrade::Automatic-Reboot "true";/g' /etc/apt/apt.conf.d/50unattended-upgrades
sed -i 's/^\/\/Unattended-Upgrade::Automatic-Reboot-Time "02:00";/Unattended-Upgrade::Automatic-Reboot-Time "02:45";/g' /etc/apt/apt.conf.d/50unattended-upgrades
sed -i 's/^\/\/Unattended-Upgrade::Remove-Unused-Dependencies "false";/Unattended-Upgrade::Remove-Unused-Dependencies "true";/g' /etc/apt/apt.conf.d/50unattended-upgrades

# enable automatic updates for regular packages
sed -i '/^\/\/.*"${distro_id}:${distro_codename}-updates";/s/^\/\///' /etc/apt/apt.conf.d/50unattended-upgrades

# activate unattended-upgrades
cat << 'EOF' >> /etc/apt/apt.conf.d/20auto-upgrades
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOF

# set vim as default editor
update-alternatives --set editor /usr/bin/vim.basic

# clone serverkit repo
git clone https://github.com/epistrephein/serverkit /tmp/serverkit

# add basic dotfiles
cat /tmp/serverkit/dotfiles/bashrc >> "/root/.bashrc"
cat /tmp/serverkit/dotfiles/bashrc >> "/home/$NEWUSER/.bashrc"

cat /tmp/serverkit/dotfiles/inputrc > "/root/.inputrc"
cat /tmp/serverkit/dotfiles/inputrc > "/home/$NEWUSER/.inputrc"

cat /tmp/serverkit/dotfiles/tmux.conf > "/root/.tmux.conf"
cat /tmp/serverkit/dotfiles/tmux.conf > "/home/$NEWUSER/.tmux.conf"

cat /tmp/serverkit/dotfiles/vimrc > "/root/.vimrc"
cat /tmp/serverkit/dotfiles/vimrc > "/home/$NEWUSER/.vimrc"

chown $NEWUSER:$NEWUSER "/home/$NEWUSER/.bashrc"
chown $NEWUSER:$NEWUSER "/home/$NEWUSER/.inputrc"
chown $NEWUSER:$NEWUSER "/home/$NEWUSER/.tmux.conf"
chown $NEWUSER:$NEWUSER "/home/$NEWUSER/.vimrc"

su $NEWUSER -c "cd && touch .viminfo"
su $NEWUSER -c "cd && touch .rsync_ignore"
su $NEWUSER -c "cd && touch .tar_ignore"

# install nord theme for vim
mkdir -p "/root/.vim/colors"
cp /tmp/serverkit/colors/vim/nord.vim "/root/.vim/colors"
chmod +x "/root/.vim/colors/nord.vim"
su $NEWUSER -c "mkdir -p /home/$NEWUSER/.vim/colors"
su $NEWUSER -c "cp /tmp/serverkit/colors/vim/nord.vim /home/$NEWUSER/.vim/colors"
su $NEWUSER -c "chmod +x /home/$NEWUSER/.vim/colors/nord.vim"

# use different color for root prompt
sed -i 's/1;33/1;37/' /root/.bashrc

# cleanup MOTD
if [ -f /etc/update-motd.d/10-help-text ]; then
  chmod -x /etc/update-motd.d/10-help-text
fi

if [ -f /etc/update-motd.d/50-motd-news ]; then
  chmod -x /etc/update-motd.d/50-motd-news
fi

if [ -f /etc/update-motd.d/51-cloudguest ]; then
  chmod -x /etc/update-motd.d/51-cloudguest
fi

if [ -f /etc/update-motd.d/80-livepatch ]; then
  chmod -x /etc/update-motd.d/80-livepatch
fi

if [ -f /etc/update-motd.d/91-contract-ua-esm-status ]; then
  chmod -x /etc/update-motd.d/91-contract-ua-esm-status
fi

if [ -f /etc/update-motd.d/97-overlayroot ]; then
  chmod -x /etc/update-motd.d/97-overlayroot
fi

# create ANSI Shadow banner
if [ ! -f /etc/update-motd.d/20-banner ]; then
  apt-get install -y figlet
  git clone https://github.com/epistrephein/figlet-fonts /tmp/figlet-fonts
  cp -n /tmp/figlet-fonts/*.flf /tmp/figlet-fonts/*.flc /usr/share/figlet

  echo -e '#!/bin/sh\n#\n# 20-banner - MOTD ascii art banner\n' >> /tmp/banner
  echo -e "cat << 'EOF'\n" >> /tmp/banner
  figlet -f "ANSI Shadow" $(hostname -s) | sed '$d' | sed 's/^/  /' >> /tmp/banner
  echo "EOF" >> /tmp/banner

  mv /tmp/banner /etc/update-motd.d/20-banner
  chmod +x /etc/update-motd.d/20-banner
fi

# disable ESM messages
sed -Ezi.orig \
  -e 's/(def _output_esm_service_status.outstream, have_esm_service, service_type.:\n)/\1    return\n/' \
  -e 's/(def _output_esm_package_alert.*?\n.*?\n.:\n)/\1    return\n/' \
  /usr/lib/update-notifier/apt_check.py
/usr/lib/update-notifier/update-motd-updates-available --force

su $NEWUSER -c "touch ~/.sudo_as_admin_successful"
su $NEWUSER -c "cd; mkdir -p .cache; touch ~/.cache/motd.legal-displayed"
touch /var/lib/cloud/instance/locale-check.skip

# install packages
apt-get install -y "${PACKAGES[@]}"

# generate dhparam
openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

# remove snapd
systemctl disable snapd.service
apt purge -y snapd
rm -rf /root/snap

# upgrade and cleanup packages
apt-get -y dist-upgrade
apt-get -y autoremove
apt-get -y autoclean

# reboot server
reboot
