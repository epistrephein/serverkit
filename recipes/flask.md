# Flask application

First install python from source to be the version you want, don't use system python!
Take a look at the [Python recipe](python.md) for details.

Clone the Flask repository, then create a virtual environment and install dependencies:

```bash
cd /var/www/my-flask-app
python3.11 -m venv .venv --prompt my-flask-app
source .venv/bin/activate
pip install -U pip
pip install -r requirements.txt

# if it's not already in the requirements.txt, install gunicorn
pip install gunicorn

deactivate
```

Create systemd service:

```bash
cat <<EOF | sudo tee /etc/systemd/system/my-flask-app.service
[Unit]
Description=my-flask-app
After=network.target

[Service]
User=my_user
WorkingDirectory=/var/www/my-flask-app
Environment="PATH=/var/www/my-flask-app/.venv/bin"
ExecStart=/var/www/my-flask-app/.venv/bin/gunicorn -w 4 -b 127.0.0.1:8000 app:app
Restart=on-failure
RestartSec=5
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=full

[Install]
WantedBy=multi-user.target
EOF
```

where `app:app` means that gunicorn will expect an `app.py` file with `app`
variable is defined (usually `app = Flask(__name__)`).

Activate the service

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now my-flask-app.service
systemctl status my-flask-app
```

and add the nginx directive

```nginx
location / {
    proxy_pass http://127.0.0.1:8000;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_redirect off;
}
```
