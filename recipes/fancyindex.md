# Fancy Index

Fancy index is an Nginx module that provides a more visually appealing directory
listing than the default one. It allows for customization of the appearance and
layout of the index page.

## Installation

Install nginx with extras package to get fancyindex module:

```bash
sudo apt install nginx-extras
```

Optionally, create an authentication file with username and hashed password for
basic auth:

```bash
sudo mkdir /etc/nginx/auth
sudo sh -c "echo -n 'your_username:' >> /etc/nginx/auth/your_server_name"
sudo sh -c "openssl passwd -apr1 >> /etc/nginx/auth/your_server_name"
```

If you want to serve files from a user directory, home must be traverasable by
nginx and folders readable:

```bash
chmod o+x /home/your_user
chmod -R o+r /home/your_user/your_files
```

A better approach is to use ACLs specifically for the nginx user:

```bash
sudo apt install acl
setfacl -m u:www-data:--x /home/your_user
setfacl -R -m u:www-data:rX /home/your_user/your_files
```

Optionally, you can add a fancyindex theme in the root of the served directory.

```bash
git clone https://github.com/xbmc/Nginx-Fancyindex-Theme.git fancyindex
```

Edit your nginx site configuration to enable basic auth and fancyindex:

```bash
sudo vi /etc/nginx/sites-available/your_server_name
```
```nginx
location /files {
    alias /home/your_user/your_files;

    fancyindex on;
    fancyindex_exact_size off;
    fancyindex_localtime on;
    fancyindex_header "/fancyindex/header.html";
    fancyindex_footer "/fancyindex/footer.html";
    fancyindex_ignore "fancyindex";
    fancyindex_name_length 85;
    fancyindex_time_format "%Y-%m-%d %H:%M";

    auth_basic "Authentication Required";
    auth_basic_user_file /etc/nginx/auth/your_server_name;
}
```
