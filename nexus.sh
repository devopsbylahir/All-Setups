# Update and install required packages
sudo yum update -y
sudo yum install wget -y
sudo yum install java-17-amazon-corretto -y

# Create app directory and download Nexus
cd /opt
sudo wget https://download.sonatype.com/nexus/3/nexus-unix-x86-64-3.79.0-09.tar.gz
sudo tar -zxvf nexus-unix-x86-64-3.79.0-09.tar.gz
sudo ln -s nexus-3.79.0-09 nexus

# Create Nexus user
sudo useradd nexus
sudo chown -R nexus:nexus /opt/nexus /opt/sonatype-work

# Configure Nexus to run as 'nexus' user
echo 'run_as_user="nexus"' | sudo tee /opt/nexus/bin/nexus.rc

# Create systemd service file
sudo tee /etc/systemd/system/nexus.service > /dev/null <<EOF
[Unit]
Description=nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
User=nexus
Group=nexus
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable nexus
sudo systemctl start nexus
sudo systemctl status nexus
