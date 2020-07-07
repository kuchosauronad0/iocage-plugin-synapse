#!/bin/sh
# Post install scrip for iocage-plugin-synapse
# Copyright 2019 Andre Poley <andre.poley@mailbox.org> 
sysrc -f /etc/rc.conf synapse_enable="YES"
#mv /usr/local/etc/matrix-synapse/homeserver.yml /usr/local/etc/matrix-synapse/homeserver1.yml
service synapse start
