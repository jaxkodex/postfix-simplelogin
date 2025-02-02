#!/bin/sh
set -e

cat > /etc/postfix/pgsql-relay-domains.cf << EOF
user = ${POSTGRES_USER}
password = ${POSTGRES_PASSWORD}
dbname = ${POSTGRES_DB}
hosts = ${POSTGRES_HOST}
query = SELECT domain FROM custom_domain WHERE domain='%s' AND verified=true 
    UNION SELECT '%s' WHERE '%s' = '${MYDOMAIN}' LIMIT 1;
EOF

cat > /etc/postfix/pgsql-transport-maps.cf << EOF
user = ${POSTGRES_USER}
password = ${POSTGRES_PASSWORD}
dbname = ${POSTGRES_DB}
hosts = ${POSTGRES_HOST}
query = SELECT 'smtp:127.0.0.1:20381' FROM custom_domain WHERE domain = '%s' AND verified=true
    UNION SELECT 'smtp:127.0.0.1:20381' WHERE '%s' = '${MYDOMAIN}' LIMIT 1;
EOF

# Configure Postfix
postconf -e "inet_interfaces = all"

# Additional configurations can be added here
if [ ! -z "$MYHOSTNAME" ]; then
    postconf -e "myhostname = $MYHOSTNAME"
fi

if [ ! -z "$MYNETWORKS" ]; then
    postconf -e "mynetworks = $MYNETWORKS"
fi

if [ ! -z "$MYDOMAIN" ]; then
    postconf -e "mydomain = $MYDOMAIN"
fi

if [ ! -z "$MYORIGIN" ]; then
    postconf -e "myorigin = $MYORIGIN"
fi

if [ ! -z "$CERT_DIR" ]; then
    postconf -e "smtpd_tls_cert_file = $CERT_DIR/fullchain.pem"
    postconf -e "smtpd_tls_key_file  = $CERT_DIR/privkey.pem"
fi

# Start Postfix
exec postfix start-fg