#!/bin/bash

yum update -y
yum install squid -y

# Configure Squid to allow traffic only to AWS IP ranges
echo "acl allowed_aws dstdomain .amazonaws.com
http_access allow allowed_aws
http_access deny all" >> /etc/squid/squid.conf

systemctl restart squid
systemctl enable squid

# starting and Enabling SSM
echo "Starting ssm agent..."
sudo systemctl start amazon-ssm-agent