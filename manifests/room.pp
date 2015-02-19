# == Class: openfire::room
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
define openfire::room (
  $room_id               = $name,
  $openfire_address      = $::ipaddress,
  $room_name             = '',
  $description           = '',
  $list_room_directory   = true,
  $is_persistent         = true,
  $is_members_only       = false,
  $broadcast_moderator   = true,
  $broadcast_participant = true,
  $broadcast_visitor     = true,
  $log_conversations     = false,
  $ensure                = 'present',
) {

  if $room_id == '' {
    fail('Room ID is required.')
  }
  if $room_name == '' {
    fail('Room name is required.')
  }
  if $description == '' {
    fail('Room description is required.')
  }

  validate_bool(
    $list_room_directory,
    $is_persistent,
    $is_members_only,
    $broadcast_moderator,
    $broadcast_participant,
    $broadcast_visitor,
    $log_conversations
  )

  validate_string(
    $room_id,
    $room_name,
    $description,
    $ensure
  )

  ## Properties set to send as a command
  $nat_name = "<naturalName>${room_name}</naturalName>"
  $roomname = "<roomName>${room_id}</roomName>"
  $desc     = "<description>${description}</description>"
  $pers     = "<persistent>${is_persistent}</persistent>"
  $log_on   = "<logEnabled>${log_conversations}</logEnabled>"
  $listpub  = "<publicRoom>${list_room_directory}</publicRoom>"
  $memb     = "<membersOnly>${is_members_only}</membersOnly>"
  $misc     = '<registrationEnabled>true</registrationEnabled><canChangeNickname>true</canChangeNickname>'

  ### Broadcast settings
  if $broadcast_moderator{
    $bc_mod = '<broadcastPresenceRole>moderator</broadcastPresenceRole>'
  }
  if $broadcast_participant {
    $bc_par = '<broadcastPresenceRole>participant</broadcastPresenceRole>'
  }
  if $broadcast_visitor {
    $bc_vis = '<broadcastPresenceRole>visitor</broadcastPresenceRole>'
  }
  $broadcast = "<broadcastPresenceRoles>${bc_mod}${bc_par}${bc_vis}</broadcastPresenceRoles>"

  $room_string = "${nat_name}${roomname}${desc}${pers}${listpub}${memb}${misc}${log_on}${broadcast}"

  exec { "Waiting for Openfire service: ${room_id}":
    command   => "wget --spider http://${openfire_address}:${openfire::of_port} && sleep 10",
    path      => '/usr/local/bin:/usr/bin:/bin',
    timeout   => 30,
    tries     => 20,
    try_sleep => 5,
    require   => Class['::openfire::service'],
    unless    => "wget --spider http://${openfire_address}:${openfire::of_port}"
  }

  if $ensure == 'present' {
    $fileaction = 'file'

    exec { "CreateOrUpdateRoom:${room_id}":
      command   => join([
        "${::openfire::user_home}/room.sh --add",
        "'${openfire_address}' '${openfire::of_port}' '${::openfire::of_admin_pass}'",
        "'${room_id}' '${room_string}'",
      ], ' '),
      path      => '/usr/local/bin:/usr/bin:/bin',
      logoutput => 'on_failure',
      require   => Exec["Waiting for Openfire service: ${room_id}"],
    }

  } else {
    $fileaction = 'absent'
    #DELETE ROOM
    exec { "DeleteRoom:${room_id}":
      command   => join([
        "${::openfire::user_home}/room.sh --add",
        "'${openfire_address}' '${openfire::of_port}' '${::openfire::of_admin_pass}'",
        "'${room_id}' '${room_string}'",
      ], ' '),
      path      => '/usr/local/bin:/usr/bin:/bin',
      logoutput => 'on_failure',
      require   => Exec["Waiting for Openfire service: ${room_id}"],
    }
  }

}
