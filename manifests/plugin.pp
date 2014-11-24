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
  $plugins_base_url = $::openfire::plugins_base_url,
){
  #$file = $pluginsfile
  #$regex = "${name}.*url=\"([^\"]*)\""
  #$plugin = inline_template("<%= @file.match('${regex}') %>")
  #$download_url = inline_template("<%= @plugin.match('url=\"([^\"]*)')[1] %>")
  #$jarfile = inline_template("<%= @download_url.match('\\/\\/(.+\\/)*(.+)\\/(.*)$')[3] %>")

  $download_url = join( [$plugins_base_url, $name], '/')

  #Download
  exec { "Plugin:${name}":
    command => "wget ${download_url} -O ${::openfire::user_home}/plugins/${name}",
    path    => '/bin:/usr/bin',
    creates => "${::openfire::user_home}/plugins/${name}",
    unless  => "test -f ${::openfire::user_home}/plugins/${name}",
  }

}