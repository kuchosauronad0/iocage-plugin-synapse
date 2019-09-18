#!/bin/sh
# Post install scrip for iocage-plugin-synapse
# Copyright 2019 Andre Poley <andre.poley@mailbox.org> 


echo "Generate homeserver.yml"
rm /usr/local/etc/matrix-synapse/homeserver.yml
/usr/local/bin/python3.6 -B -m synapse.app.homeserver -c /usr/local/etc/matrix-synapse/homeserver.yaml --generate-config --server-name=synapse.example.com --report-stats=no
ln -s /usr/local/etc/matrix-synapse/homeserver.yaml /usr/local/etc/matrix-synapse/homeserver.yml

echo "Add synapse to rc.conf"
echo 'synapse_enable="YES"' >> /etc/rc.conf

echo "Configure /var/db/matrix-synapse for uploads and storage"   
mkdir -p /var/db/matrix-synapse/media_store
mkdir -p /var/db/matrix-synapse/uploads
chown -R synapse /var/db/matrix-synapse
sleep 100
sed -i '' -e 's+^media_store_path:.*$+media_store_path: "/var/db/matrix-synapse/media_store"+g' /usr/local/etc/matrix-synapse/homeserver.yaml
sleep 100
sed -i '' -e 's+^uploads_path:.*$+uploads_path: "/var/db/matrix-synapse/uploads"+g' /usr/local/etc/matrix-synapse/homeserver.yaml
sleep 100
sed -i '' -e 's+^filename:.*+filename: /var/log/matrix-synapse/synapse.example.com.log+g' /usr/local/etc/matrix-synapse/synapse.example.com.log.config

echo "Done"
