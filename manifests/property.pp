# == Class: openfire::property
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
define openfire::property (
  $value = '',
) {

  if $value == '' {
    fail('Property value is required.')
  }

  $sql =
"INSERT INTO ofProperty (name, propValue) 
             VALUES ('${name}', '${value}')
ON DUPLICATE KEY UPDATE name=VALUES(name), propValue=VALUES(propValue);"

  $validate =
"SELECT 1 FROM ofProperty WHERE name='${name}' AND propValue='${value}'"

  exec { "CreateProperty:${name}":
    command   => "mysql ${::openfire::dbname} -e \"${sql}\"",
    path      => '/usr/bin/',
    onlyif    => "test -z $(mysql ${::openfire::dbname} -e \"${validate}\")",
    logoutput => 'on_failure',
  }
}