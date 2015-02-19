#!/bin/bash
# Copyright 2015 Hewlett-Packard Development Company, L.P.
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
update_change_file()
{
  echo "${room_string}" > ${change_file}
}

room_add()
{
  #Check if exists already
  curl -s  \
       -u admin:${of_admin_pass} \
       http://${of_ip}:${of_port}/plugins/mucservice/chatrooms/${room_id} \
     | grep 'Chat room could be not found'
  #found
  if [ $? -eq 0 ]; then
    echo "Creating new Room [${room_id}] ..."
    curl -X POST                                  \
         -u admin:${of_admin_pass}                \
         --header 'Content-Type: application/xml' \
         -d "<chatRoom>${room_string}</chatRoom>" \
         http://${of_ip}:${of_port}/plugins/mucservice/chatrooms/
    test $? -eq 0 && echo 'Created.' && update_change_file
  else
    echo "Room found already, updating..."
    grep -E "^${room_string}\$" "${change_file}" &>/dev/null
    if [ $? -ne 0 ]; then
      curl -X PUT                                   \
           -u admin:${of_admin_pass}                \
           --header 'Content-Type: application/xml' \
           -d "<chatRoom>${room_string}</chatRoom>" \
           http://${of_ip}:${of_port}/plugins/mucservice/chatrooms/${room_id}
      test $? -eq 0 && echo 'Updated.' && update_change_file
    else
      echo 'Update skipped, file and string match'
    fi
  fi
}
room_delete()
{
  if [ "${id}" == '0' ]; then
    echo 'Deleting room...'
    grep ${room_id} ".${room_id}" && \
    curl -X DELETE                              \
         -u admin:${of_admin_pass}              \
         http://${of_ip}:${of_port}/plugins/mucservice/chatrooms/${room_id}
  fi
}

#CASE SELECTION --------------------
option="$1"
shift

of_ip="$1"
of_port="$2"
of_admin_pass="$3"
room_id="$4"
room_string="$5"

home=$(getent passwd "jive" | cut -d: -f6)
change_file="${home}/.${room_id}"

case ${option} in
  '--add')
    room_add "$@"
    ;;
  '--delete')
    room_delete "$@"
    ;;
  *)
    echo 'Not recognized option.'
    exit 1
    ;;
esac