#!/bin/bash
set -e

echo "Setting up SSH server and user configuration..."

# Install SSH server and related packages
apt update && apt install -y \
    openssh-server \
    sudo \
    curl \
    wget \
    git \
    vim \
    htop \
    net-tools \
    iputils-ping \
    x11-apps \
    xauth \
    xorg

# Create SSH user with configurable username and password
SSH_USERNAME=${SSH_USERNAME:-me}
SSH_PASSWORD=${SSH_PASSWORD:-123456}

echo "Creating SSH user: $SSH_USERNAME"

# Create user with home directory
useradd -m -s /bin/bash "$SSH_USERNAME"

# Set password
echo "$SSH_USERNAME:$SSH_PASSWORD" | chpasswd

# Add user to sudo group for admin rights
usermod -aG sudo "$SSH_USERNAME"

# Allow passwordless sudo for the user
echo "$SSH_USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Configure SSH server
mkdir -p /var/run/sshd

# Create SSH config that allows password and key authentication
cat > /etc/ssh/sshd_config << 'EOF'
# SSH Server Configuration for D2SLAM Container

Port 22
Protocol 2

# Authentication
PermitRootLogin yes
PasswordAuthentication yes
PubkeyAuthentication yes
AuthorizedKeysFile %h/.ssh/authorized_keys
PermitEmptyPasswords no
ChallengeResponseAuthentication no

# X11 Forwarding
X11Forwarding yes
X11DisplayOffset 10
X11UseLocalhost no

# SFTP support
Subsystem sftp /usr/lib/openssh/sftp-server

# Other settings
UsePAM yes
AcceptEnv LANG LC_*
PrintMotd no
ClientAliveInterval 30
ClientAliveCountMax 3

# Security settings
StrictModes yes
MaxAuthTries 6
EOF

# Set proper permissions for SSH
chmod 644 /etc/ssh/sshd_config

# Create SSH directory for root and user
mkdir -p /root/.ssh
mkdir -p /home/"$SSH_USERNAME"/.ssh
chown "$SSH_USERNAME":"$SSH_USERNAME" /home/"$SSH_USERNAME"/.ssh
chmod 700 /root/.ssh /home/"$SSH_USERNAME"/.ssh

# Generate host keys if they don't exist
ssh-keygen -A

# Create a startup script for SSH and environment setup
cat > /usr/local/bin/start-ssh.sh << 'EOF'
#!/bin/bash

# Set DISPLAY variable for X11 forwarding
export DISPLAY=${DISPLAY:-:10.0}

# Start SSH service
service ssh start

# Keep container running
exec "$@"
EOF

chmod +x /usr/local/bin/start-ssh.sh

# Create systemd-like service script
cat > /etc/init.d/ssh-setup << 'EOF'
#!/bin/bash
### BEGIN INIT INFO
# Provides:          ssh-setup
# Required-Start:    $local_fs $network
# Required-Stop:     $local_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Description:       SSH setup for D2SLAM container
### END INIT INFO

case "$1" in
    start)
        echo "Starting SSH service..."
        service ssh start
        ;;
    stop)
        echo "Stopping SSH service..."
        service ssh stop
        ;;
    restart)
        echo "Restarting SSH service..."
        service ssh restart
        ;;
    *)
        echo "Usage: $0 {start|stop|restart}"
        exit 1
        ;;
esac
EOF

chmod +x /etc/init.d/ssh-setup

# Set up environment for SSH users
cat >> /etc/environment << 'EOF'
# D2SLAM Container Environment
DISPLAY=:10.0
NVIDIA_VISIBLE_DEVICES=all
NVIDIA_DRIVER_CAPABILITIES=all
EOF

# Add environment setup to bashrc for SSH users
cat >> /home/"$SSH_USERNAME"/.bashrc << 'EOF'

# D2SLAM Environment Setup
export DISPLAY=${DISPLAY:-:10.0}
export NVIDIA_VISIBLE_DEVICES=all
export NVIDIA_DRIVER_CAPABILITIES=all

# ROS Environment
if [ -f /opt/ros/noetic/setup.bash ]; then
    source /opt/ros/noetic/setup.bash
fi

# D2SLAM Workspace
if [ -f /root/swarm_ws/devel/setup.bash ]; then
    source /root/swarm_ws/devel/setup.bash
fi

echo "Welcome to D2SLAM Container!"
echo "SSH User: $USER"
echo "DISPLAY: $DISPLAY"
EOF

# Also add to root's bashrc
cat >> /root/.bashrc << 'EOF'

# D2SLAM Environment Setup
export DISPLAY=${DISPLAY:-:10.0}
export NVIDIA_VISIBLE_DEVICES=all
export NVIDIA_DRIVER_CAPABILITIES=all

# ROS Environment
if [ -f /opt/ros/noetic/setup.bash ]; then
    source /opt/ros/noetic/setup.bash
fi

# D2SLAM Workspace
if [ -f /root/swarm_ws/devel/setup.bash ]; then
    source /root/swarm_ws/devel/setup.bash
fi
EOF

echo "SSH server setup completed successfully!"
echo "SSH Username: $SSH_USERNAME"
echo "SSH Password: $SSH_PASSWORD"
echo "Root SSH: Enabled"
echo "X11 Forwarding: Enabled"
echo "SFTP: Enabled"
