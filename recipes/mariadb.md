# MariaDB

MariaDB is a popular open-source relational database management system (RDBMS)
that is a fork of MySQL. It is designed to be highly compatible with MySQL,
making it easy for users to migrate from MySQL to MariaDB. MariaDB offers
improved performance, security, and features compared to its predecessor.

## Installation

### Install

```bash
VERSION=11.8

# ensure required packages are installed
sudo apt install -y lsb-release curl gpg

# download and store MariaDB GPG key
curl -fsSL https://mariadb.org/mariadb_release_signing_key.pgp | sudo gpg --dearmor -o /etc/apt/keyrings/mariadb.gpg

# add the MariaDB APT source
echo "deb [signed-by=/etc/apt/keyrings/mariadb.gpg] https://deb.mariadb.org/$VERSION/ubuntu $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/mariadb.list

# update and install MariaDB
sudo apt update
sudo apt install mariadb-server mariadb-client libmariadb-dev

# enable and start MariaDB service
sudo systemctl enable --now mariadb

# verify installation
mariadb --version

# verify alias
mysql --version

# run initial security setup
sudo mariadb-secure-installation
```

### Uninstall

```bash
# stop MariaDB service if running
sudo systemctl stop mariadb

# purge MariaDB and remove its dependencies
sudo apt purge -y mariadb-* libmariadb-dev
sudo apt autoremove --purge -y

# remove leftover config and data
sudo rm -rf /etc/mysql /var/lib/mysql /var/log/mysql

# delete MariaDB system user and group
sudo deluser --remove-home mysql
sudo delgroup mysql
```
