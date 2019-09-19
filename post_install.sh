#!/bin/sh
# Post install script for iocage-plugin-synapse
# Copyright 2019 Andre Poley <andre.poley@mailbox.org> 
: ${matrix-synapse_name="matrix-synapse"}
: ${matrix-synapse_user="synapse"}
: ${matrix-synapse_data="/var/db/matrix-synapse"}
: ${matrix-synapse_log="/var/log/matrix-synapse.log"}
: ${matrix-synapse_listen="0.0.0.0,::"}
: ${matrix-synapse_server="synapse.example.com"}

# Generate a SSL key
sudo mkdir -p /usr/local/etc/ssl/{keys,certs}
chmod 0600 /usr/local/etc/ssl/keys
openssl genrsa -out /usr/local/etc/ssl/keys/${matrix-synapse_server}.key 4096

# Create the default directories
mkdir -p ${matrix-synapse_data}
mkdir -p ${matrix-synapse_data}/media_store
mkdir -p ${matrix-synapse_data}/uploads
chown ${matrix-synapse_user}:${matrix-synapse_user} ${matrix-synapse_data}

# Generate homeserver.yml
rm /usr/local/etc/matrix-synapse/homeserver.yml
/usr/local/bin/python3.6 -B -m synapse.app.homeserver -c /usr/local/etc/matrix-synapse/homeserver.yaml --generate-config --server-name=${matrix-synapse_server} --report-stats=no
# Note: an existing homeserver.yml(but empty) is provided by the overlay; use this and comment line 23-24 if you like
ln -s /usr/local/etc/matrix-synapse/homeserver.yaml /usr/local/etc/matrix-synapse/homeserver.yml

sed -i '' -e 's+^pid_file:.*$+pid_file: /var/run/matrix-synapse/synapse.example.com.pid+g' /usr/local/etc/matrix-synapse/homeserver.yaml
sed -i '' -e 's+^media_store_path:.*$+media_store_path: "/var/db/matrix-synapse/media_store"+g' /usr/local/etc/matrix-synapse/homeserver.yaml
sed -i '' -e 's+^uploads_path:.*$+uploads_path: "/var/db/matrix-synapse/uploads"+g' /usr/local/etc/matrix-synapse/homeserver.yaml
sed -i '' -e 's+^.*filename:.*+        filename: /var/log/matrix-synapse/synapse.example.com.log+g' /usr/local/etc/matrix-synapse/synapse.example.com.log.config

sysrc -f /etc/rc.conf synapse_enable="YES"

# Start the service
if $(service synapse start 2>/dev/null >/dev/null) ; then
    echo "Starting matrix-synapse."
fi

