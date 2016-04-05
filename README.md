This is a guide how to deploy and run Service Stack application on Ubuntu Linux.

#Step 1: Build and Deploy Application

Create Project from ServiceStack Blank template. If you don't have ServiceStack templates
in Visual Studio, you should install [ServiceStack Visual Studio extension](https://github.com/ServiceStack/ServiceStack/wiki/Creating-your-first-project)
first.

![Create Project](https://github.com/ServiceStackApps/mono-server-config/blob/master/images/create.png)

Publish it into directory

![Publish](https://github.com/ServiceStackApps/mono-server-config/blob/master/images/2-publish-1.png)

![Publish](https://github.com/ServiceStackApps/mono-server-config/blob/master/images/2-publish-2.png)

![Publish](https://github.com/ServiceStackApps/mono-server-config/blob/master/images/2-publish-3.png)

Upload content of the published directory to your linux server into `~/hello-app` directory. You
can use WinSCP or other scp client to do this.

Click "New" to open new connection to your linux server.

![Deploy](https://github.com/ServiceStackApps/mono-server-config/blob/master/images/3-login-0.png)

Type your server ip, user and password or use private key and click "Login"

![Deploy](https://github.com/ServiceStackApps/mono-server-config/blob/master/images/3-login-1.png)

Select folder where ServiceStack solution was deployed on the left pane and your user home folder on the right pane.

![Deploy](https://github.com/ServiceStackApps/mono-server-config/blob/master/images/3-login-2.png)

Create folder 'hello-app' in (using F7 key on the right pane)

![Deploy](https://github.com/ServiceStackApps/mono-server-config/blob/master/images/3-create-folder.png)

Select all files in deployment folder and copy them to `~/hello-app` folder on the server.

![Deploy](https://github.com/ServiceStackApps/mono-server-config/blob/master/images/3-copy-4.png)


#Step 2: Install mono, nginx and HyperFastCGI

To run ServiceStack application on Linux server you need to install mono, nginx and hyperfastcgi
server. Connect to your server via ssh and run these commands in terminal

      #installing mono
      sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
      echo "deb http://download.mono-project.com/repo/debian wheezy main" | sudo tee /etc/apt/sources.list.d/mono-xamarin.list
      sudo apt-get update
      sudo apt-get install -y mono-complete
      #installing nginx
      sudo apt-get install -y nginx
      #installing HyperFastCGI
      cd ~
      sudo apt-get install -y git autoconf automake libtool make libglib2.0-dev libevent-dev
      git clone https://github.com/xplicit/hyperfastcgi
      cd hyperfastcgi
      ./autogen.sh --prefix=/usr && make && sudo make install

#Step 3: Configure nginx and HyperFastCGI
      
Download and copy configs

      curl -sL https://github.com/ServiceStackApps/mono-server-config/raw/master/nginx-config/hello-app.conf --output hello-app.conf
      curl -sL https://github.com/ServiceStackApps/mono-server-config/raw/master/hfc-config/hfc.config --output hfc.config
      sudo cp hello-app.conf /etc/nginx/sites-available/
      sudo ln -s /etc/nginx/sites-available/hello-app.conf /etc/nginx/sites-enabled/
      sudo rm /etc/nginx/sites-enabled/default     
      sudo mkdir -p /etc/hyperfastcgi
      sudo mkdir -p /var/log/hyperfastcgi
      sudo chown -R www-data:www-data /var/log/hyperfastcgi
      sudo cp hfc.config /etc/hyperfastcgi

You need to edit `/etc/nginx/fastcgi_params` file

      sudo apt-get mc
      sudo mcedit /etc/nginx/fastcgi_params

Find parameters `SCRIPT_FILENAME` and `PATH_INFO`. If you have such parameters in config file, remove the lines or mark them as comments using hash sign `#`

    #fastcgi_param	SCRIPT_FILENAME		$request_filename;

When you end editing press `F2` to save changes and `F10` to exit from editor.

Then you need to change server name in configs to your server name. This can be
domain name like www.yourdomain.com or an IP address if you don't have a domain yet.
Open nginx config for editing:

      sudo apt-get mc
      sudo mcedit /etc/nginx/sites-available/hello-app.conf

Then find and change line `server_name hello-app;` to `server_name www.yourdomain.com;`
      
![nginx configuration](https://github.com/ServiceStackApps/mono-server-config/blob/master/images/nginx-conf.png)

Restart nginx after changes

      sudo /etc/init.d/nginx restart

Change server name in hyperfastCGI config too.

      sudo mcedit /etc/hyperfastcgi

Find and change line `<vhost>hello-app</vhost>` to host name. 

![hyperfastcgi configuration](https://github.com/ServiceStackApps/mono-server-config/blob/master/images/hfc-config.png)


#Step 4: Run the application

      cd /var/log/hyperfastcgi
      sudo -H -u www-data nohup hyperfastcgi4 /config=hfc.config


#Step 5: Check access to web services

Open in browser http://www.yourdomain.com/ and check availability of services.