#!/usr/bin/env bash

####################################################################################################
# 1. Buat vagrant virtualbox dan buat user 'awan' dengan password 'buayakecil'

# create a new user 'awan' with password 'buayakecil'
 sudo useradd \
    awan \
    -p $(echo buayakecil | openssl passwd -1 -stdin) \
    -d /home/awan -m

####################################################################################################

####################################################################################################
# 2. Buat vagrant virtualbox dan lakukan provisioning install Phoenix Web Framework

# fix locale warning for elixir and add-apt-repository
locale-gen en_US.UTF-8
sudo dpkg-reconfigure locales

# install Erlang/OTP platform and Elixir
wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
sudo dpkg -i erlang-solutions_1.0_all.deb
sudo apt-get update
sudo apt-get -y -f install esl-erlang elixir
mix local.hex --force
rm erlang-solutions_1.0_all.deb

# install nodejs
wget https://nodejs.org/dist/v8.10.0/node-v8.10.0-linux-x64.tar.xz
tar xf node-v8.10.0-linux-x64.tar.xz
sudo mkdir /usr/local/lib/nodejs
sudo mv node-v8.10.0-linux-x64 /usr/local/lib/nodejs/node-v8.10.0
rm -r node-v8.10.0-linux-x64.tar.xz
export NODE_HOME=/usr/local/lib/nodejs/node-v8.10.0
export PATH=$NODE_HOME/bin:$PATH
. ~/.profile

# install Phoenix
mix archive.install --force https://github.com/phoenixframework/archives/raw/master/phx_new.ez

# create new Phoenix application (beyond this point is optional)
mix phx.new /home/vagrant/hello

cd hello
mix local.hex --force
mix deps.get

cd assets
npm install
node node_modules/brunch/bin/brunch build

cd ..
sudo apt-get -y -f install postgresql postgresql-contrib
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"
sudo -u postgres psql -c "CREATE DATABASE hello_dev;"
sudo service postgresql restart
mix local.rebar --force
mix ecto.create
# mix phx.server

####################################################################################################

####################################################################################################
# 3. Buat vagrant virtualbox dan lakukan provisioning install: php, mysql, composer, nginx

# install php
sudo apt-get -y -f install python-software-properties software-properties-common
sudo apt-add-repository -y ppa:ondrej/php
sudo apt-get -y -f install php7.2
sudo apt-get -y -f install php7.2-fpm php7.2-cgi
sudo apt-get -y -f install php7.2-mysql php7.2-mbstring php7.2-tokenizer php7.2-xml php7.2-ctype php7.2-json
sudo apt-get -y -f install zip unzip

# install mysql
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password \"''\""
sudo debconf-set-selections <<<  "mysql-server mysql-server/root_password_again password \"''\""
sudo apt-get install -y -f mysql-server
mysql_install_db

# install composer (and laravel)
curl 'https://getcomposer.org/installer' | php
sudo mv composer.phar /usr/local/bin/composer
composer global require "laravel/installer"

# install nginx
sudo apt-get -y --purge apache2
sudo apt-get -y -f install nginx
sudo rm -f /etc/nginx/sites-enabled/*
sudo ln -s /vagrant/pelatihan-laravel.conf /etc/nginx/sites-enabled
sudo nginx -t
sudo service nginx start
sudo service php7.2-fpm start

# config project
cd /var/www/web
composer install
php artisan key:generate
sudo chmod 777 storage bootstrap/cache

####################################################################################################

####################################################################################################
# 4. Buat vagrant virtualbox dan lakukan provisioning install: squid proxy, bind9

# install squid proxy
apt-get install -y -f squid

# install bind9
apt-get install -y -f bind9

####################################################################################################

# clean up
sudo apt-get autoremove