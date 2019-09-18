#!/bin/sh
# Post install scrip for iocage-plugin-synapse
# Copyright 2019 Andre Poley <andre.poley@mailbox.org> 
echo <<EOT >>/etc/rc.conf
synapse_enable=YES
EOT
/usr/local/bin/python3.6 -B -m synapse.app.homeserver -c /usr/local/etc/matrix-synapse/homeserver.yml --generate-config --server-name=synapse.example.com --report-stats=no

service synapse start

