# == Class: openfire::install
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
class openfire::install
{
  if $::openfire::install_java {
    class { 'java':
      distribution => 'jre'
    }
  }

  #Group/User/Home
  group { 'jive':
    ensure => present,
  }

  user { 'jive':
    ensure     => present,
    comment    => 'OpenFire User',
    home       => $::openfire::user_home,
    gid        => 'jive',
    shell      => '/bin/bash',
    membership => 'minimum',
    require    => Group['jive'],
  }

  file { $::openfire::user_home:
    ensure  => directory,
    owner   => 'jive',
    group   => 'jive',
    mode    => '0644',
    require => User['jive'],
  }

#  $urlpkg = 'http://www.igniterealtime.org/downloadServlet?filename=openfire/openfire_3.9.3_all.deb'
#  exec { 'download-openfire.deb':
#    command => "wget ${urlpkg} -O /tmp/openfire.deb",
#    path    => '/bin:/usr/bin',
#    creates => "/tmp/openfire.deb",    
#    require => File["${user_home}"],
#  }
#
#  package { "openfiredeb":
#    provider => dpkg,
#    ensure   => latest,
#    source   => "/tmp/openfire.deb",
#    require  => Exec['download-openfire.deb']
#  }

  if (!defined(Package['wget'])) {
    package { 'wget' :
      ensure => present,
      before => Exec['download-openfire'],
    }
  }

  $downloaded_file = '/tmp/openfire.tar.gz'
  #Download file
  exec { 'download-openfire':
    command => "wget ${::openfire::tar_url} -O ${downloaded_file}",
    path    => '/bin:/usr/bin',
    creates => $downloaded_file,
    unless  => "test -f ${::openfire::user_home}/bin/openfire",
    require => File[$::openfire::user_home],
  }

  #Extract openfire  
  exec { "extract-${downloaded_file}":
    command => "tar -xzvf ${downloaded_file} --directory ${::openfire::user_home} --strip-components=1",
    path    => '/bin:/usr/bin',
    unless  => "test -f ${::openfire::user_home}/bin/openfire",
    require => Exec['download-openfire'],
  }

  #Initial Config Files
  file { "${::openfire::user_home}/conf/security.xml":
    ensure  => file,
    source  => 'puppet:///modules/openfire/security.xml',
    require => Exec["extract-${downloaded_file}"],
  }
  file { "${::openfire::user_home}/conf/openfire.xml":
    ensure  => file,
    content => template('openfire/openfire.xml.erb'),
    require => Exec["extract-${downloaded_file}"],
  }
}