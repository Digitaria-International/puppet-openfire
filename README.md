# OpenFire

[![Puppet Forge](http://img.shields.io/puppetforge/v/forj/openfire.svg)](https://forge.puppetlabs.com/forj/openfire)
[![License](http://img.shields.io/:license-ALv2-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.html)

This module installs [Openfire](http://www.igniterealtime.org/projects/openfire/) chat server.

# How to use

##Simple config:

```puppet
include openfire
```

In this way it will install using all the default values, you can access your new server this way:

1. In your browser go to http://server_address:9090
2. Login using: admin/changeme

##To create a new chat group:

```puppet
openfire::room { 'group_id':
  room_name   => 'group_friendly_name',
  description => 'group description',
}
```

##To create a new user of modify it:

```puppet
openfire::user { 'user_name':
  password => 'user_password',
}
```

##To create a Group:

```puppet
openfire::group { 'group_name': }
```

##To create a Room:

```puppet
openfire::room { 'room_id':
  room_name   => 'room name',
  description => 'description',
}
```

###If you want to delete a room:

```puppet
openfire::room { 'room_id':
  room_name   => 'room name',
  description => 'description',
  ensure      => 'absent',
}
```

##To Add a User to an existing group:

```puppet
openfire::usergroup { 'Openfire:user_name>group_name' :
  user    => 'user_name',
  group   => 'group_name',
  require => [ Openfire::User['user_name'], Openfire::Group['group_name'] ],
}
```

##To add a plug-in:

just add it in the main class declaration, the name is the jar file name that is listed in [openfire plugin page](https://www.igniterealtime.org/projects/openfire/plugins.jsp):

```puppet
class { '::openfire':
  plugins   => ['monitoring.jar'],
}
```

##Prepare your server to use it with hubot:

You can use this example to configure openfire to accept hubot connections.

```puppet
class { '::openfire':
  of_admin_pass => 'secret',
  of_config     => {
    'xmpp.domain'                               => { value => $::fqdn },
    #Disable TLS
    'xmpp.client.tls.policy'                    => { value => 'disabled' },
    'xmpp.server.tls.enabled'                   => { value => 'true' },
    'xmpp.server.dialback.enabled'              => { value => 'true' },
    'xmpp.server.certificate.accept-selfsigned' => { value => 'false' },
    #Disable SSL
    'xmpp.socket.ssl.active'                    => { value => 'false' },
  },
  plugins       => ['monitoring.jar'],
}
```

# Parameters
* `install_java`     : installs java jre (default: true)
* `tar_url`          : Openfire tar url (default: 'http://www.igniterealtime.org/downloadServlet?filename=openfire/openfire_3_9_3.tar.gz')
* `plugins_base_url` : Openfire's plugins url (default: 'http://www.igniterealtime.org/projects/openfire/plugins')
* `user_home`        : Openfire installation path (default: '/opt/openfire')
* `dbhost`           : MySQL server (default: 'localhost')
* `dbport`           : MySQL server port (default: '3306')
* `dbname`           : MySQL Database name to create (default: 'openfiredb')
* `dbuser_name`      : MySQL user for the database (default: 'openfire')
* `dbuser_pass`      : MySQL user's password (default: 'changeme')
* `of_port`          : Openfire port (default: '9090')
* `of_secure_port`   : Openfire secure port (default: '9091')
* `of_admin_pass`    : Openfire admin password (default: 'changeme')
* `of_config`        : Openfire configuration values (Hash) (default: { 'xmpp.domain' => { value => $::fqdn }})
* `plugins`          : Openfire plgins to install (default: [])

# License

Released under the Apache 2.0 licence

# Contact

* Isaias Piña <isaias.pina@hp.com>
* [IRC channel](http://webchat.freenode.net/?channels=forj)


# Known Issues:

* Only tested on Ubuntu
* Only works with mysql
* Specs missing
* Port changing only works in the first run, this is due Openfire changes config files checksum whenever it runs.

# Support

Please log tickets and issues at our [GitHub repository](https://github.com/forj-oss/puppet-openfire)

# Contribute:

[Contribute to this project here](http://docs.forj.io/en/latest/dev/contribute.html)