#!/bin/bash

SITEDOMAIN="$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')"
SITELOCATION="/var/www/hello-app/"
HFCPORT=9000

read -p "Site address or IP, e.g. www.yourdomain.com (default: $SITEDOMAIN):" USERSITE

if [ -z "$USERSITE" ]; then
 USERSITE=$SITEDOMAIN
fi

read -p "Site location (default: $SITELOCATION):" USERLOCATION

if [ -z "$USERLOCATION" ]; then
 USERLOCATION=$SITELOCATION
fi

read -p "HyperFastCGI port (default: $HFCPORT):" USERHFCPORT

if [ -z "$USERHFCPORT" ]; then
 USERHFCPORT=$HFCPORT
fi

USERSITE=$(echo $USERSITE | sed -e 's/[\/&]/\\&/g')
USERLOCATION=$(echo $USERLOCATION | sed -e 's/[\/&]/\\&/g')
USERHFCPORT=$(echo $USERHFCPORT | sed -e 's/[\/&]/\\&/g')


echo $USERSITE $USERLOCATION $USERHFCPORT

mkdir -p hfc-install
cd hfc-install
mkdir -p config

#getting templates
curl -sL https://github.com/ServiceStackApps/mono-server-config/raw/master/nginx-config/hello-app.conf.tpl | sed -e "s/\${SITENAME}/$USERSITE/" -e "s/\${HFCPORT}/$USERHFCPORT/" -e "s/\${SITELOCATION}/$USERLOCATION/" > config/$USERSITE.conf
curl -sL https://github.com/ServiceStackApps/mono-server-config/raw/master/hfc-config/hfc.config.tpl | sed -e "s/\${SITENAME}/$USERSITE/" -e "s/\${HFCPORT}/$USERHFCPORT/" -e "s/\${SITELOCATION}/$USERLOCATION/" > config/hfc.config

#installing mono
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
echo "deb http://download.mono-project.com/repo/debian wheezy main" | sudo tee /etc/apt/sources.list.d/mono-xamarin.list
echo "Updating repositories..."
sudo apt-get -qqq update
echo "Installing mono..."
sudo apt-get install -y -q mono-complete
#installing nginx
echo "Installing nginx..."
sudo apt-get install -y nginx
#installing HyperFastCGI
echo "Installing HyperFastCGI"
#libtool-bin is required by Ubuntu 15.10 This package does not exist in Ubuntu 14.04 and lower
sudo apt-get install -y -qqq libtool-bin
sudo apt-get install -y git autoconf automake libtool make libglib2.0-dev libevent-dev
git clone https://github.com/xplicit/hyperfastcgi
cd hyperfastcgi
#double call for autogen.sh Workaround for weird error 'cannot find Makefile.in' while writing config.status
./autogen.sh --prefix=/usr
./autogen.sh --prefix=/usr && make && sudo make install
cd ..

#Configuring
echo "Configure site"
sudo cp config/$USERSITE.conf /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/$USERSITE.conf /etc/nginx/sites-enabled/
echo "Disable default nginx site"
sudo rm /etc/nginx/sites-enabled/default     
echo "Update /etc/nginx/fastcgi_params"
sed -e "s/\(fastcgi_param[[:space:]]*SCRIPT_FILENAME\)/#\1/" -e "s/\(fastcgi_param[[:space:]]*PATH_INFO\)/#\1/" /etc/nginx/fastcgi_params > config/fastcgi_params
sudo cp config/fastcgi_params /etc/nginx/fastcgi_params

sudo /etc/init.d/nginx restart

sudo mkdir -p /etc/hyperfastcgi
sudo mkdir -p /var/log/hyperfastcgi
sudo chown -R www-data:www-data /var/log/hyperfastcgi
sudo cp config/hfc.config /etc/hyperfastcgi

if [[ $(ps -p1 | grep systemd && echo systemd || echo upstart) == "upstart" ]]; then
  (cd hyperfastcgi/samples/ubuntu-startup/upstart && source install-service.sh)
  sudo start hyperfastcgi
else
  #(cd hyperfastcgi/samples/ubuntu-startup/init.d && source install-service.sh)
  #sudo /etc/init.d/hyperfastcgi4 start
  (cd hyperfastcgi/samples/ubuntu-startup/systemd && source install-service.sh)
  sudo systemctl start hyperfastcgi.service
fi

sudo /etc/init.d/nginx restart
