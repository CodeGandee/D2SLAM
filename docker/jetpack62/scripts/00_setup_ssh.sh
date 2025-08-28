#!/bin/bash

# SSH Setup Script for JetPack 6.2 Container
# Configures SSH server for remote development access

set -e

echo "🔧 Setting up SSH server for remote development..."

# Install SSH server and related packages
apt-get update
apt-get install -y openssh-server openssh-client

# Create SSH directory and configure
mkdir -p /var/run/sshd
mkdir -p /root/.ssh

# Configure SSH daemon
cat > /etc/ssh/sshd_config << 'EOF'
Port 22
Protocol 2
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_dsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key

# Logging
SyslogFacility AUTH
LogLevel INFO

# Authentication
LoginGraceTime 120
PermitRootLogin yes
StrictModes yes
RSAAuthentication yes
PubkeyAuthentication yes
AuthorizedKeysFile %h/.ssh/authorized_keys
PasswordAuthentication yes
PermitEmptyPasswords no
ChallengeResponseAuthentication no

# X11 forwarding
X11Forwarding yes
X11DisplayOffset 10
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes

# SFTP subsystem
Subsystem sftp /usr/lib/openssh/sftp-server

# Allow client to pass locale environment variables
AcceptEnv LANG LC_*
EOF

# Generate SSH host keys
ssh-keygen -A

# Set default root password (can be overridden via build args)
echo "root:${SSH_PASSWORD:-d2slam123}" | chpasswd

# Create startup script for SSH
cat > /usr/local/bin/start-ssh.sh << 'EOF'
#!/bin/bash
# Start SSH daemon if not running
if ! pgrep -x "sshd" > /dev/null; then
    echo "Starting SSH daemon..."
    /usr/sbin/sshd -D &
fi
EOF

chmod +x /usr/local/bin/start-ssh.sh

echo "✅ SSH server configured successfully"
echo "   Default credentials: root:${SSH_PASSWORD:-d2slam123}"
echo "   Port: 22"
echo "   X11 forwarding: enabled"
echo "   SFTP: enabled"
