[root@owctdbadm01 oracle.SupportTools]# cat setup_ssh_eq.sh
#!/bin/bash
#
# Copyright (c) 2009, 2014, Oracle and/or its affiliates. All rights reserved.
#
#

# Source required Exadata environment file
if [ -e /opt/oracle.cellos/exadata.img.env ]; then
  source /opt/oracle.cellos/exadata.img.env
  if [ $? -ne 0 ]; then
    echo "[ERROR] Unable to source required Exadata environment file, exadata.img.env."
    exit 1
  fi
else
  echo "[ERROR] Required Exadata environment file, exadata.img.env, not found."
  exit 1
fi

set_ssh_eq ()
{
  for anode in `cat $1`;
  do
  /usr/bin/expect -f - << IBEOF
  set timeout 3
  # now connect to remote UNIX box with given script to execute
  spawn dcli -c "$anode" -l $2 -k
  match_max 100000
  expect {
    "no)?" { 
          send -- "yes\n"
          }
   }
  # Look for passwd prompt
  expect "*?assword:*"
  # Send Passwd 
  send -- "$3\n"
  # Stop the on logon tests and if asked to connect to master switch choose no
  expect eof
IBEOF
  done
}

if [ ! -z "$1" ] || [ ! -z "$2" ] || [ ! -z "$3" ]; then
  if [ ! -d "$HOME/.ssh/id_dsa" ]; then
    /usr/bin/ssh-keygen -q -t dsa -f $HOME/.ssh/id_dsa -N ''
    /bin/sleep 1
  fi
  if [ ! -d "$HOME/.ssh/id_rsa" ]; then
    /usr/bin/ssh-keygen -q -t rsa -f $HOME/.ssh/id_rsa -N ''
    /bin/sleep 1
  fi
  /bin/sync
  set_ssh_eq $1 $2 $3
else
  echo "Usage: $0 <node list file> <username> <user password. Must be same for all nodes>"
  echo "Sets up ssh equivalence for the user `id -u` on this node to user <username> on all nodes listed in file <node list file>"
  exit 1
fi

exit 0

[root@owctdbadm01 oracle.SupportTools]# 
