This is a guide how to deploy and run Service Stack application on Ubuntu Linux.

#Step 1: Build and Deploy Application

Create Project from ServiceStack Blank template. If you don't have ServiceStack templates
in Visual Studio, you should install [ServiceStack Visual Studio extension](https://github.com/ServiceStack/ServiceStack/wiki/Creating-your-first-project)
first.

[[https://github.com/ServiceStackApps/mono-server-config/blob/master/images/create.png|alt=create project]]

Publish it into directory

[[https://github.com/ServiceStackApps/mono-server-config/blob/master/images/2-publish-1.png|alt=create project]]

[[https://github.com/ServiceStackApps/mono-server-config/blob/master/images/2-publish-2.png|alt=create project]]

[[https://github.com/ServiceStackApps/mono-server-config/blob/master/images/2-publish-3.png|alt=create project]]

Upload content of the published directory to your linux server into `~/hello-app` directory. You
can use WinSCP or other scp client to do this.


#Step 2: Install mono, nginx and HyperFastCGI

To run ServiceStack application on Linux you need to install mono, nginx and hyperfastcgi
server. Connect to your server via ssh and run these commands in terminal

      #installing mono
      sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
      echo "deb http://download.mono-project.com/repo/debian wheezy main" | sudo tee /etc/apt/sources.list.d/mono-xamarin.list
      sudo apt-get update
      sudo apt-get install mono-complete

      #installing nginx
      sudo apt-get install nginx
      
      #installing HyperFastCGI
      cd ~
      sudo apt-get install git autoconf automake libtool make libglib2.0-dev libevent-dev
      git clone https://github.com/xplicit/hyperfastcgi
      cd hyperfastcgi
      ./autogen.sh --prefix=/usr && make && sudo make install

#Step 3: Configure nginx and HyperFastCGI
      
Download and copy configs

      curl -sL https://github.com/ServiceStackApps/mono-server-config/raw/master/nginx-config/hello-app.conf --output hello-app.conf
      curl -sL https://github.com/ServiceStackApps/mono-server-config/raw/master/hfc-config/hfc.conf --output hfc.config
      sudo cp hello-app.conf /etc/nginx/sites-available/
      sudo mkdir -p /etc/hyperfastcgi
      sudo mkdir -p /var/log/hyperfastcgi
      sudo chown -R www-data:www-data /var/log/hyperdfastcgi
      sudo cp hfc.config /etc/hyperfastcgi

You need to edit `/etc/nginx/fastcgi_params` file

      sudo apt-get mc
      sudo mcedit /etc/nginx/fastcgi_params

Find parameters `SCRIPT_FILENAME` and `PATH_INFO`. If you have such in config file, remove 
them or mark it as comments using hash sign `#`

    #fastcgi_param	SCRIPT_FILENAME		$request_filename;

When you end editing press `F2` to save changes and `F10` to exit from editor.

Then you need to change server name in configs to your server name. This can be
domain name like www.yourdomain.com or an IP address if you don't have a domain yet.
Open nginx config for editing:

      sudo apt-get mc
      sudo mcedit /etc/nginx/sites-available/hello-app.conf

Then find and change line `server_name hello-app;` to `server_name www.yourdomain.com`
      
[[https://github.com/ServiceStackApps/mono-server-config/blob/master/images/nginx-conf.png|alt=nginx configuraion]]

Change server name in hyperfastCGI config too.

      sudo mcedit /etc/hyperfastcgi

find and change line `<vhost>hello-app</vhost>` to host name 

[[https://github.com/ServiceStackApps/mono-server-config/blob/master/images/hfc-config.png|alt=hyperfastcgi configuraion]]


#Step 4: Run the application

      cd /var/log/hyperfastcgi
      sudo -H -u www-data nohup hyperfastcgi4 /config=hfc.config


#Step 5: Check access to web services

Open in browser http://www.yourdomain.com/ and check availability of services.
