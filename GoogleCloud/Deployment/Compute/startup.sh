#!/bin/sh
echo "10.0.2.24 salt_master" >> /etc/hosts
curl -L https://bootstrap.saltstack.com -o install_salt.sh | sudo sh install_salt.sh
sed -i -e 's/#master: salt/master: [salt_master]/g' /etc/salt/minion
service salt-minion restart
