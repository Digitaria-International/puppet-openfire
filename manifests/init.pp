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
class openfire (
  $install_java   = $::openfire::params::install_java,
  $url            = $::openfire::params::url,
  $user_home      = $::openfire::params::user_home,
  $dbhost         = $::openfire::params::dbhost,
  $dbname         = $::openfire::params::dbname,
  $dbuser_name    = $::openfire::params::dbuser_name,
  $dbuser_pass    = $::openfire::params::dbuser_pass,
  $of_port        = $::openfire::params::of_port,
  $of_secure_port = $::openfire::params::of_secure_port,
  $of_admin_pass  = $::openfire::params::of_admin_pass,
  $of_config      = $::openfire::params::of_config,
  $plugins        = $::openfire::params::plugins,
) inherits openfire::params {

  validate_bool($install_java)
  validate_string($url, $user_home, $dbhost, $dbname, $dbuser_name,
    $dbuser_pass, $of_port, $of_secure_port, $of_admin_pass)
  validate_hash($of_config)

  if $of_port == '' {
    fail('Openfire default port cannot be null')
  }
  if $of_secure_port == '' {
    fail('Openfire secure port cannot be null')
  }

  anchor { 'openfire::begin': }
  anchor { 'openfire::end': }

  class { '::openfire::install': }
  class { '::openfire::config': }
  class { '::openfire::service': }

  #Plugins
  if $plugins {
    openfire::plugin { $plugins:
      pluginsfile => file("${user_home}/conf/available-plugins.xml"),
    }
  }

  #Containment
  Anchor['openfire::begin'] ->
  Class['::openfire::install'] ->
  Class['::openfire::config'] ~>
  Class['::openfire::service'] ->
  Openfire::Plugin[$plugins] ->
  Anchor['openfire::end']
}