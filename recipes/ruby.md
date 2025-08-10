# Ruby

## Install from source

Run as root (`sudo su -`):

```bash
VERSION=3.4.5

# install dependencies
apt update
apt install -y build-essential pkg-config autoconf bison git libssl-dev libreadline-dev zlib1g-dev libyaml-dev libcurl4-openssl-dev libffi-dev libgdbm-dev libncurses5-dev libtool libxml2-dev libxslt1-dev liblzma-dev

# move to a temporary directory and download source
cd /tmp
wget "https://cache.ruby-lang.org/pub/ruby/${VERSION%.*}/ruby-$VERSION.tar.gz"
tar -xvzf "ruby-$VERSION.tar.gz"
cd "ruby-$VERSION"

# configure, compile and install
./configure
make -j$(nproc)
make install

# don't install gem documentation by default
echo "gem: --no-document" > /etc/gemrc
echo "gem: --no-document" > ~/.gemrc

# update RubyGems
gem update --system

# install latest version of fundamental gems
gem install bundler irb foreman
```

## Update

To update patch versions (e.g. from 3.4.4 to 3.4.5), simply follow the same
installation steps as above. The `make install` command will overwrite the
existing files with the new version.

When updating to a new minor version (e.g. from 3.3.4 to 3.4.5), you can simply 
clean up the old version files.  
Run as root (`sudo su -`):

```bash
OLD_VERSION="3.3.4"

# libraries & gems
rm -rf "/usr/local/lib/ruby/${OLD_VERSION%.*}.0"
rm -rf "/usr/local/lib/ruby/gems/${OLD_VERSION%.*}.0"
rm -rf "/usr/local/lib/ruby/site_ruby/${OLD_VERSION%.*}.0"
rm -rf "/usr/local/lib/ruby/vendor_ruby/${OLD_VERSION%.*}.0"

# headers
rm -rf "/usr/local/include/ruby-${OLD_VERSION%.*}.0"

# documentation
rm -rf "/usr/local/share/ri/${OLD_VERSION%.*}.0"

# pkgconfig
rm -f "/usr/local/lib/pkgconfig/ruby-${OLD_VERSION%.*}.pc"
```

## Uninstall

To completely remove Ruby installed from source, you can manually delete the
files and directories created during the installation.  
Run as root (`sudo su -`):

```bash
# binaries
rm -f /usr/local/bin/{bundle,bundler,erb,gem,irb,racc,rake,rbs,rdbg,rdoc,ri,ruby,syntax_suggest,typeprof}

# libraries & gems
rm -rf /usr/local/lib/ruby/

# headers
rm -rf /usr/local/include/ruby-*

# documentation
rm -rf /usr/local/share/ri

# pkgconfig
rm -f /usr/local/lib/pkgconfig/ruby*.pc
```
