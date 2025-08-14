# Python

## Installation

### Install from source

Run as root (`sudo su -`):

```bash
VERSION=3.13.6

# install dependencies
apt update
apt install -y make build-essential pkg-config libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev libgdbm-compat-dev git

# move to a temporary directory and download source
cd /tmp
wget "https://www.python.org/ftp/python/$VERSION/Python-$VERSION.tgz"
tar -xvzf "Python-$VERSION.tgz"
cd "Python-$VERSION"

# configure, compile and install
./configure --enable-optimizations
make -j$(nproc)
make altinstall

# update pip
"/usr/local/bin/python${VERSION%.*}" -m pip install --upgrade pip --root-user-action=ignore

# symlink python to the installed version
update-alternatives --install /usr/local/bin/python python "/usr/local/bin/python${VERSION%.*}" 1
update-alternatives --set python "/usr/local/bin/python${VERSION%.*}"
update-alternatives --display python
```

### Update

To update patch versions (e.g. from 3.13.5 to 3.13.6), simply follow the same
installation steps as above. The `make altinstall` command will overwrite the
existing files with the new version.

When updating to a new minor version (e.g. from 3.12.4 to 3.13.6), you can keep
multiple versions installed since binaries are versioned.

If you want to clean up the old versions, remember to remove binaries as well.  
Run as root (`sudo su -`):

```bash
OLD_VERSION="3.12.4"

# symlinks
update-alternatives --remove python "/usr/local/bin/python${OLD_VERSION%.*}"

# binaries
rm -f "/usr/local/bin/idle${OLD_VERSION%.*}"
rm -f "/usr/local/bin/pip${OLD_VERSION%.*}"
rm -f "/usr/local/bin/pydoc${OLD_VERSION%.*}"
rm -f "/usr/local/bin/python${OLD_VERSION%.*}-config"
rm -f "/usr/local/bin/python${OLD_VERSION%.*}"

# libraries
rm -rf "/usr/local/lib/python${OLD_VERSION%.*}"
rm -f "/usr/local/lib/libpython${OLD_VERSION%.*}.a"

# headers
rm -rf "/usr/local/include/python${OLD_VERSION%.*}"

# pkgconfig
rm -f "/usr/local/lib/pkgconfig/python-${OLD_VERSION%.*}.pc"
rm -f "/usr/local/lib/pkgconfig/python-${OLD_VERSION%.*}-embed.pc"

# man pages
rm -f "/usr/local/share/man/man1/python${OLD_VERSION%.*}.1"
```

### Uninstall

To completely remove a Python version installed from source, just follow the
same steps as above.

## Packages

When installing user packages with a binary component, you might want to keep
them updated just like using `apt`. A good way to do this is to create a
user packages list and use it to install or upgrade packages.

```bash
# create a user packages list
mkdir -p ~/.local/share/python
echo "yt-dlp" >> ~/.local/share/python/packages.txt

# install/upgrade packages from the list
/usr/local/bin/python -m pip install --user --upgrade --requirement "$HOME/.local/share/python/packages.txt"
```
