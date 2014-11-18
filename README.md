OpenFire
--------

This module installs [Openfire](http://www.igniterealtime.org/projects/openfire/) chat server.

Simple config:

    class { 'openfire':
      of_config => {
        'xmpp.domain' => { value => $fqdn },
      },
      plugins   => ['Monitoring Service' ],
    }

To create a new chat group:

    openfire::room { 'group_id':
      room_name   => 'group_friendly_name',
      description => 'group description',
    }

To create a new user of modify it:

    openfire::user { 'user_name':
      password => 'user_password',
    }

To create a Group:

    openfire::group { 'group_name': }

To Add a User to an existing group:

    openfire::usergroup { 'Openfire:user_name>group_name' :
      user     => 'user_name',
      group    => 'group_name',
      requiere => [ Openfire::User['user_name'], Openfire::Group['group_name'] ],
    }

To Add or modify a system setting:

    openfire::property { 'complete-setting-name':
      value => 'value_string',
    }

License
-------

Released under the Apache 2.0 licence

Contact
-------

Isaias Piña <isaias.pina@hp.com>

Known Issues:
-------------

* Only tested on Ubuntu 12.04 LTS
* Only works with mysql
* If you change the port of an already running instance you will need to restart the service manually
* Plugin instalation won't work if openfire hasn't run at least once
* Specs missing

Support
-------

Please log tickets and issues at our [GitHub repository](https://github.com/forj-oss/puppet-openfire)

Contribute:
-----------
* Fork it
* Create a topic branch
* Improve/fix (with spec tests)
* Push new topic branch
* Submit a Pull Request