# PostgreSQL

PostgreSQL is a powerful, open-source object-relational database system known
for its reliability, feature robustness, and performance. It supports a wide
range of data types and offers advanced features like transactions, subselects,
and foreign keys.

## Installation

### Install

```bash
# ensure required packages are installed
sudo apt install -y lsb-release curl gpg

# download and store PostgreSQL GPG key
curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo gpg --dearmor -o /etc/apt/keyrings/postgresql.gpg

# add the PostgreSQL APT source
echo "deb [signed-by=/etc/apt/keyrings/postgresql.gpg] http://apt.postgresql.org/pub/repos/apt noble-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list

# update and install PostgreSQL
sudo apt update
sudo apt install postgresql-17 postgresql-contrib-17 libpq-dev

# verify installation
psql --version
```

### Uninstall

```bash
# stop PostgreSQL if running
sudo systemctl stop postgresql postgresql@*-main

# purge PostgreSQL and remove its dependencies
sudo apt purge -y postgresql* postgresql-contrib* libpq-dev libpq5
sudo apt autoremove --purge -y

# remove leftover config and data
sudo rm -rf /etc/postgresql* /var/lib/postgresql /var/log/postgresql /var/run/postgresql /usr/lib/postgresql

# delete PostgreSQL system user and group
sudo deluser --remove-home postgres
```

## Configuration

Create a new user and database:

```bash
# create user and database with password prompt
sudo su postgres -l -c 'createuser your_user -s -P; createdb your_user -O your_database'

# create a .pgpass file for passwordless access
echo localhost:5432:*:your_user:your_password > ~/.pgpass
chmod 600 ~/.pgpass
```
