#!/bin/bash
# show command being ran as logs and if there is an error jump out if the function set -ex

set -x
updateUbuntu () {
  echo "========================= Update Ubuntu ============================="

  sudo apt-get update && sudo apt-get -y upgrade
}

installNPM () {
  echo "====================== Install Node Package Manager ======================="

  sudo apt install -y npm 
  sudo apt-get install -y curl apt-transport-https ca-certificates &&   curl --fail -ssL -o setup-nodejs https://deb.nodesource.com/setup_6.x &&   sudo bash setup-nodejs &&   sudo apt-get install -y nodejs build-essential

  nodejs -v
  npm -v
  git --version
  ls
}

cloneRepository () {
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
}

configureNGINX () {
  echo "====================== NGINX Configuration ===================="

  sudo apt-get install -y nginx
  sudo systemctl start nginx
  sudo rm /etc/nginx/sites-available/default
  sudo nginx -t
  if [[ -d /etc/nginx/sites-enabled/default ]]
    then
      sudo rm -rf /etc/nginx/sites-enabled/default
    fi
      sudo bash -c 'cat > /etc/nginx/sites-available/default <<EOF
      server {
      listen 80;
      return 301 https://\$host\$request_uri;
    }

  server {
      server_name sardaunan.ml www.sardaunan.ml;
      location / {
          proxy_pass http://localhost:3000;
          proxy_set_header Host \$host;
          proxy_set_header X-Real-IP \$remote_addr;
          proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto \$scheme;
      }

      listen 443 ssl; # managed by Certbot
      ssl_certificate /etc/letsencrypt/live/sardaunan.ml/fullchain.pem; # managed by Certbot
      ssl_certificate_key /etc/letsencrypt/live/sardaunan.ml/privkey.pem; # managed by Certbot
      include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
      ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

  }
EOF'
  sudo nginx -t
  sudo systemctl restart nginx
}

installPM2 () {
  echo "====================== Install  PM2 ==========================="
  sudo npm install pm2 -g
}

startApp () {
  echo "==================== Start the App ============================"

  sudo pm2 start npm -- start
}

getSSLCertificate () {
  echo "===================== Get SSL Certificate ====================="

  sudo apt-get update -y
  sudo apt-get install -y software-properties-common
  sudo add-apt-repository ppa:certbot/certbot -y
  sudo apt-get update -y
  sudo apt-get install -y certbot python-certbot-nginx
  sudo certbot --nginx -d sardaunan.ml -d www.sardaunan.ml
}

deployNodeAPP () {
  updateUbuntu
  installNPM
  cloneRepository
  configureNGINX
  installPM2
  startApp
  getSSLCertificate
}

deployNodeAPP