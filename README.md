#puppet-zabbix

####Table of Contents

1. [Description](#description)
2. [How to use](#how-to-use)
3. [OS Support](#support)
4. [Todo](#todo)


##Description

This module will install an simple but basic sinatra webapp which we be executing r10k commands when something is posted to this site. When something is pushed to an git repository, you can configure it by executing so-called webhooks. 

###Github.com
When using github for example, within the settings of the repository there is an setting called "Webhooks & Services". Fill in the webadress in the "Payload url" and make sure that "application/json" (Which is default) is selected. Also select "Just the push event." and click on "Add webhook".

Please be sure, that github.com needs to be able to access this webpage. So configure the firewall for your devices to make sure it is accessible from github.com

###gitlab
When using the (standalone) gitlab, you'll need to go to the "settings" page of every repository. You'll find on the left side of the page the "Web Hooks". When page opens, you'll need to provide the correct url into "URL" field and select "Push events". After this, click on the "Add Web Hook" button.

Please be sure, that gitlab.org needs to be able to access this webpage. So configure the firewall for your devices to make sure it is accessible from gitlab.org

##How to use

Basic usage

```ruby
class { 'webhook': }
```

This will install an basic webapp which will be running as user root on port 81. The sinatra app is only available when one "JSON" information is posted to "http://fqdn:81/payload". The port can be overriden using the "webhook_port" parameter.


You can override this module with the following parameters:

###webhook_home
As default, this will be installed on '/opt/webhook'. You can override it by setting an different value

###webhook_port
On which port it is listening for requests. Default it will run on port 81. You can use this to any other port.
When changing the port higher than 1023, this app still runs as root. (See todo)

###webhook_owner
The owner of this service/script. Default it has 'root' as owner. 

###webhook_group
The group of this service/script. Default it is set to 'root'.

###repo_puppetfile
The name of the repository where the 'Puppetfile' is stored.
Default is 'undef' but this one needs to be supplied when you want this to work correctly.

###repo_hieradata
The name of the repository where the 'hieradata' is stored.
Default is 'undef' as not everyone is using hiera.


##Support

The module is only supported on:

  - CentOS 6
  - Debian 7
  - OracleLinux 6


##Todo
The following is an overview of todo actions:

  - When running on port >1023, it should not run as root, but as specified webhook_user
  - Create rspec tests
  - Better documentation
  - Probably a lot ;-)

Please send me suggestions!


