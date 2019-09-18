#!/bin/sh
# Post install scrip for iocage-plugin-synapse
# Copyright 2019 Andre Poley <andre.poley@mailbox.org> 


echo "Generate homeserver.yml"
rm /usr/local/etc/matrix-synapse/homeserver.yml
/usr/local/bin/python3.6 -B -m synapse.app.homeserver -c /usr/local/etc/matrix-synapse/homeserver.yaml --generate-config --server-name=synapse.example.com --report-stats=no
ln -s /usr/local/etc/matrix-synapse/homeserver.yaml /usr/local/etc/matrix-synapse/homeserver.yml

echo "Add synapse to rc.conf"
echo <<EOT >>/etc/rc.conf
synapse_enable="YES"
EOT

echo "Start synapse"
service synapse start

