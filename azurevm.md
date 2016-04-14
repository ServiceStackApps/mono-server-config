#Step 1: Create Ubuntu Virtual Machine On Azure

Login to Microsoft Azure and click on `Add` button in `Virtual Machines` pane

![Deploy](https://github.com/ServiceStackApps/mono-server-config/blob/master/images/0-create-azure-1.png)

In new opened pane type `Ubuntu Server` in filter string then select `Ubuntu Server 14.04 LTS` and click button `Create`

![Deploy](https://github.com/ServiceStackApps/mono-server-config/blob/master/images/0-create-azure-2.png)

![Deploy](https://github.com/ServiceStackApps/mono-server-config/blob/master/images/0-create-azure-3.png)

Fill the name of the machine, user name and password, then create new group e. g. `deploy` by clicking on plus sign

![Deploy](https://github.com/ServiceStackApps/mono-server-config/blob/master/images/0-create-azure-4.png)

Select appropriate configuration of the virtual machine for your needs.

![Deploy](https://github.com/ServiceStackApps/mono-server-config/blob/master/images/0-create-azure-5.png)

Click on `Public IP Address` and switch it to `Static`

![Deploy](https://github.com/ServiceStackApps/mono-server-config/blob/master/images/0-create-azure-6.png)

![Deploy](https://github.com/ServiceStackApps/mono-server-config/blob/master/images/0-create-azure-7.png)

Preview all the settings and click OK. New virtual machine will be created.

![Deploy](https://github.com/ServiceStackApps/mono-server-config/blob/master/images/0-create-azure-8.png)

Wait a little while virtual machine is deploying to physical server. You will see a box with `Deploying` status.

![Deploy](https://github.com/ServiceStackApps/mono-server-config/blob/master/images/0-create-azure-9.png)

When the virtual machine has sucessfully deployed the box has change its status to 'Running`

![Deploy](https://github.com/ServiceStackApps/mono-server-config/blob/master/images/0-create-azure-10.png)

Select virtual machine and choose `Network Interfaces` menu item. On the right pane you will see public IP address of your machine. Write it down somewhere you will use it when connect to your machine. 

![Deploy](https://github.com/ServiceStackApps/mono-server-config/blob/master/images/0-create-azure-11.png)

Then you need to enable firewall to web server. Click on the `Browse` menu item at the bottom of left pane. In new pane type `Network Security` in search box and choose `Newtork Security Group` from the list.

![Deploy](https://github.com/ServiceStackApps/mono-server-config/blob/master/images/0-create-azure-12.png)

Select the group belonging to your machine and click on `Inbound security rules` and in new pane click `Add`

![Deploy](https://github.com/ServiceStackApps/mono-server-config/blob/master/images/0-create-azure-13.png)

![Deploy](https://github.com/ServiceStackApps/mono-server-config/blob/master/images/0-create-azure-14.png)


Fill the name `http` and switch the protocol to `TCP`. Source port should be `*` and destination port should be `80`. If you need your site to be accessible via HTTPS, then repeat this step and set name `HTTPS` and destination port `443`

![Deploy](https://github.com/ServiceStackApps/mono-server-config/blob/master/images/0-create-azure-15.png)

After adding you will see updated list of firewall rules.

![Deploy](https://github.com/ServiceStackApps/mono-server-config/blob/master/images/0-create-azure-16.png)

Your virtual machine is ready to use.
