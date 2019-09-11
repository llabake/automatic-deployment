#!/bin/bash
echo "========================= Update Ubuntu ============================="

sudo apt-get update && sudo apt-get -y upgrade

echo "====================== Install Node Package Manager ======================="

sudo apt install npm
sudo apt-get install -y curl apt-transport-https ca-certificates &&   curl --fail -ssL -o setup-nodejs https://deb.nodesource.com/setup_6.x &&   sudo bash setup-nodejs &&   sudo apt-get install -y nodejs build-essential

nodejs -v
npm -v
git --version
ls

echo "===================== Clone Repo =============================="
  if [[ -d expressapp/ ]]
  then
    rm -rf expressapp/
    git clone https://github.com/llabake/expressapp.git
  else
    git clone https://github.com/llabake/expressapp.git
  fi

cd expressapp/ || exit
npm install


echo "====================== NGINX Configuration ===================="
sudo apt-get install nginx -y
sudo systemctl status nginx
sudo systemctl start nginx
sudo systemctl enable nginx
wget -q -O - 'http://169.254.169.254/latest/meta-data/local-ipv4'
sudo rm /etc/nginx/sites-available/default
sudo nginx -t
if [[ -d /etc/nginx/sites-enabled/default ]]
  then
    sudo rm -rf /etc/nginx/sites-enabled/default
  fi
    sudo bash -c 'cat > /etc/nginx/sites-available/default <<EOF
    server {
     listen 80;
     return 301 https://$host$request_uri;
   }

server {
    server_name sardaunan.ml www.sardaunan.ml;
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
     }

    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/sardaunan.ml/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/sardaunan.ml/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

}
EOF'
sudo systemctl restart nginx
echo "====================== Install  PM2 ==========================="sudo npm install pm2 -g


echo "==================== Start the App ============================"sudo pm2 start npm -- start


echo "===================== Get SSL Certificate ====================="
sudo apt-get update
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update
sudo apt-get install certbot python-certbot-nginx
sudo certbot --nginx