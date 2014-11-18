# == Class: openfire::user
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
define openfire::user (
  $password     = '',
  $creation     = '000000000000000',
  $modification = '000000000000000',
) {

  if $name == '' {
    fail('User name is required.')
  }
  if $password == '' {
    fail('Password is required.')
  }

  $sql =
    "INSERT INTO ofUser (username, plainPassword, creationDate, modificationDate)
                 VALUES ('${name}', '${password}', '${creation}', '${modification}' )
ON DUPLICATE KEY UPDATE plainPassword=VALUES(plainPassword)"

  $validate =
    "SELECT 1 FROM ofUser WHERE username = '${name}' AND plainPassword = '${password}'"

  exec { "CreateUser:${name}":
    command   => "mysql ${::openfire::dbname} -e \"${sql}\"",
    path      => '/usr/bin/',
    logoutput => 'on_failure',
    onlyif    => "test -z $(mysql ${::openfire::dbname} -e \"${validate}\")",
  }
}