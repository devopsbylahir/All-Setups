#!/bin/bash

# Install necessary packages
dnf install -y httpd git || yum install -y httpd git

# Start & Enable Apache Web Server
systemctl start httpd
systemctl enable httpd

# Verify if HTTPD is running
systemctl status httpd --no-pager

# Navigate to the web root directory
cd /var/www/html || exit

# Clone the repository
if git clone https://github.com/karishma1521success/swiggy-clone.git; then
    mv swiggy-clone/* . && rm -rf swiggy-clone
else
    echo "Git clone failed! Exiting..."
    exit 1
fi

# Restart HTTPD to apply changes
systemctl restart httpd

# Monitor Apache access log in the background
tail -f /var/log/httpd/access_log &
