# == Class: openfire::plugin
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
define openfire::plugin (
  $pluginsfile = '',
){
  $file = $pluginsfile

  $regex = "${name}.*url=\"([^\"]*)\""

  if $file == '' {
    warning("Plugins file does not exists. Skipping ${name}")
  }

  $plugin = inline_template("<%= @file.match('${regex}') %>")
  $download_url = inline_template("<%= @plugin.match('url=\"([^\"]*)')[1] %>")
  $jarfile = inline_template("<%= @download_url.match('\\/\\/(.+\\/)*(.+)\\/(.*)$')[3] %>")

  if ($download_url != '') and ($jarfile != '') {
    #Download
    exec { "Plugin:${name}":
      command => "wget ${download_url} -O ${::openfire::user_home}/plugins/${jarfile}",
      path    => '/bin:/usr/bin',
      creates => "${::openfire::user_home}/plugins/${jarfile}",
      unless  => "test -f ${::openfire::user_home}/plugins/${jarfile}",
    }
  } else {
    fail('Download url or file name could not be determined.')
  }

}