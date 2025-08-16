# Redis

Redis is an open-source, in-memory data structure store, used as a database,
cache, and message broker. It supports various data structures such as strings,
hashes, lists, sets, and more. It is known for its high performance, flexibility,
and ease of use.

## Installation

### Install

```bash
# ensure required packages are installed
sudo apt install -y lsb-release curl gpg

# download and store Redis GPG key
curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/redis-archive-keyring.gpg

# add the Redis APT source
echo "deb [signed-by=/etc/apt/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list

# update and install Redis
sudo apt update
sudo apt install redis

# verify installation
redis-cli --version
```

### Uninstall

```bash
# stop Redis if running
sudo systemctl stop redis

# also stop any Redis instance if it's named differently
sudo systemctl list-units | grep redis

# purge Redis and remove its dependencies
sudo apt purge -y redis redis-server redis-tools
sudo apt autoremove --purge -y

# remove leftover config and data
sudo rm -rf /etc/redis /var/lib/redis /var/log/redis

# delete Redis system user and group
sudo deluser --remove-home redis
sudo delgroup redis

# verify removal
which redis-server   # should return nothing
dpkg -l | grep redis # should return nothing

# remove the Redis APT source
sudo rm -f /etc/apt/sources.list.d/redis.list

# remove the Redis GPG keyring
sudo rm -f /etc/apt/keyrings/redis-archive-keyring.gpg

# update package lists
sudo apt update
```
