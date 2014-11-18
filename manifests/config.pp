# == Class: openfire
# Copyright 2014 Hewlett-Packard Development Company, L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
#
class openfire::config
{
  #Required plugin for Room handling
  $muc_url = 'http://www.igniterealtime.org/projects/openfire/plugins/mucservice.jar'
  exec { "Plugin:${name}":
    command => "wget ${muc_url}",
    cwd     => "${::openfire::user_home}/plugins/",
    path    => '/bin:/usr/bin',
    unless  => "test -f ${::openfire::user_home}/plugins/mucservice.jar",
  }

  #MySql Configuration
  include mysql::server
  
  mysql::db { $::openfire::dbname:
    user     => $::openfire::dbuser_name,
    password => $::openfire::dbuser_pass,
    dbname   => $::openfire::dbname,
    host     => $::openfire::dbhost,
    grant    => ['ALL'],
    sql      => "${::openfire::user_home}/resources/database/openfire_mysql.sql",
    require  => [
                  Class['mysql::server'],
                  Class['openfire::install'],
                ],
  }

  openfire::user { 'admin':
    password => $::openfire::of_admin_pass,
    require  => Mysql::Db[$::openfire::dbname],
  }

  create_resources('openfire::property', $::openfire::of_config)
}