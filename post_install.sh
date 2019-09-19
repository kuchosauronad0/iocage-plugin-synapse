#!/bin/sh
# Post install script for iocage-plugin-synapse
# Copyright 2019 Andre Poley <andre.poley@mailbox.org>
MATRIX_SYNAPSE_NAME="matrix-synapse"
MATRIX_SYNAPSE_USER="root"
MATRIX_SYNAPSE_DATA="/var/db/matrix-synapse"
MATRIX_SYNAPSE_LOG="/var/log/matrix-synapse/synapse.example.com.log"
MATRIX_SYNAPSE_LISTEN="0.0.0.0,::"
MATRIX_SYNAPSE_SERVER="synapse.example.com"
MATRIX_SYNAPSE_HOME="/usr/local/$MATRIX_SYNAPSE_NAME"

# Generate a SSL key
mkdir -p /usr/local/etc/ssl/keys
mkdir -p /usr/local/etc/ssl/certs
chmod 0600 /usr/local/etc/ssl/keys
openssl genrsa -out /usr/local/etc/ssl/keys/$MATRIX_SYNAPSE_SERVER.key 4096

# Create the default directories
mkdir -p $MATRIX_SYNAPSE_DATA
mkdir -p $MATRIX_SYNAPSE_DATA/media_store
mkdir -p $MATRIX_SYNAPSE_DATA/uploads
chown $MATRIX_SYNAPSE_USER:wheel $MATRIX_SYNAPSE_DATA

# Generate /homeserver.yml
rm $MATRIX_SYNAPSE_HOME/homeserver.yml
/usr/local/bin/python3.6 -B -m synapse.app.homeserver -c $MATRIX_SYNAPSE_HOME/homeserver.yaml --generate-config --server-name=$MATRIX_SYNAPSE_SERVER --report-stats=no
# Note: an empty /homeserver.yml is provided by the overlay; feel free to use this instead by commenting out line 24-25 
ln -s $MATRIX_SYNAPSE_HOME/homeserver.yaml $MATRIX_SYNAPSE_HOME/homeserver.yml

sed -i '' -e 's+^pid_file:.*$+pid_file: /var/run/matrix-synapse/synapse.example.com.pid+g' $MATRIX_SYNAPSE_HOME/homeserver.yaml
sed -i '' -e 's+^media_store_path:.*$+media_store_path: "/var/db/matrix-synapse/media_store"+g' $MATRIX_SYNAPSE_HOME/homeserver.yaml
sed -i '' -e 's+^uploads_path:.*$+uploads_path: "/var/db/matrix-synapse/uploads"+g' $MATRIX_SYNAPSE_HOME/homeserver.yaml
sed -i '' -e 's+^.*filename:.*+        filename: /var/log/matrix-synapse/synapse.example.com.log+g' $MATRIX_SYNAPSE_HOME/$MATRIX_SYNAPSE_SERVER.log.config

sysrc -f /etc/rc.conf synapse_enable="YES"

echo "matrix-synapse:  $MATRIX_SYNAPSE_NAME"
echo "user:            $MATRIX_SYNAPSE_USER"
echo "data dir:        $MATRIX_SYNAPSE_DATA"
echo "log dir:         $MATRIX_SYNAPSE_LOG"
echo "listen:          $MATRIX_SYNAPSE_LISTEN"
echo "server name:     $MATRIX_SYNAPSE_SERVER"

# Start the service
if $(service synapse start 2>/dev/null >/dev/null) ; then
  echo "Starting matrix-synapse."
fi
