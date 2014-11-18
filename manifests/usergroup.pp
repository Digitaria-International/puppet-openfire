# == Class: openfire::usergroup
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
define openfire::usergroup (
  $user     = '',
  $group    = '',
  $is_admin = false,
) {

  if $user == '' {
    fail('User name is required.')
  }
  if $group == '' {
    fail('Group name is required.')
  }

  $admin_flag = $is_admin ? {
    true  => 1,
    false => 0,
  }

  $sql =
"INSERT INTO ofGroupUser (groupName, username, administrator)
SELECT * 
  FROM (SELECT '${group}', '${user}', ${admin_flag}) AS tmp
 WHERE NOT EXISTS
       (SELECT 1 FROM ofGroupUser WHERE groupName = '${group}' 
           AND username = '${user}' ) LIMIT 1;"

  $validate =
    "SELECT 1 FROM ofGroupUser WHERE groupName='${group}' AND username='${user}' AND administrator='${admin_flag}'"

  exec { "CreateGroup:${name}":
    command   => "mysql ${::openfire::dbname} -e \"${sql}\"",
    path      => '/usr/bin/',
    logoutput => 'on_failure',
    onlyif    => "test -z $(mysql ${::openfire::dbname} -e \"${validate}\")",
  }
}