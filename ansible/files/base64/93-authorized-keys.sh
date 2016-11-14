log "Populating authorized_keys"

authorized_keys=$(mdata-get root_authorized_keys || echo '')

mkdir -pm 700 /root/.ssh
echo ${authorized_keys} > /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
