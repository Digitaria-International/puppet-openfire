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

  #Adding Required plugin for Room handling
  openfire::plugin { 'mucservice.jar': }

  if $::openfire::plugins {
    $install_plugins = reject($::openfire::plugins, 'mucservice.jar')
    if $install_plugins {
      openfire::plugin { $install_plugins: }
    }
  }
  if $::openfire::of_config {
    create_resources('openfire::property', $::openfire::of_config)
  }
}