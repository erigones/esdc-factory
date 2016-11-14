log "Enabling root login via SSH"

if sed -e 's/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config > /etc/ssh/sshd_config.tmp 2>/dev/null; then
    mv /etc/ssh/sshd_config{.tmp,}
fi
rm -f /etc/ssh/sshd_config.tmp