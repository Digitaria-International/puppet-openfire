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
  $install_java     = $::openfire::params::install_java,
  $tar_url          = $::openfire::params::tar_url,
  $plugins_base_url = $::openfire::params::plugins_base_url,
  $user_home        = $::openfire::params::user_home,
  $dbhost           = $::openfire::params::dbhost,
  $dbport           = $::openfire::params::dbport,
  $dbname           = $::openfire::params::dbname,
  $dbuser_name      = $::openfire::params::dbuser_name,
  $dbuser_pass      = $::openfire::params::dbuser_pass,
  $of_port          = $::openfire::params::of_port,
  $of_secure_port   = $::openfire::params::of_secure_port,
  $of_admin_pass    = $::openfire::params::of_admin_pass,
  $of_config        = $::openfire::params::of_config,
  $plugins          = $::openfire::params::plugins,
) inherits openfire::params {

  validate_bool($install_java)
  validate_string($tar_url, $plugins_base_url, $user_home, $dbhost, $dbport, $dbname,
    $dbuser_name, $dbuser_pass, $of_port, $of_secure_port, $of_admin_pass)
  validate_hash($of_config)
  validate_array($plugins)

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

  #Containment
  Anchor['openfire::begin'] ->
  Class['::openfire::install'] ->
  Class['::openfire::config'] ~>
  Class['::openfire::service'] ->
  Anchor['openfire::end']
}