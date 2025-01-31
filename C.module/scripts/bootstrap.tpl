#!/bin/bash

# Enable error logging
set -e

DB="${DB_NAME}"
P="${DB_PASS}"
U="${DB_USER}"

LB_DNS="https://dev.clixx-samuel.com"
EP_DNS="wordpressdbclixx-ecs.cfmgy6w021vw.us-east-1.rds.amazonaws.com"

# Log all output to a file for debugging
exec > >(tee -a /var/log/userdata.log) 2>&1

# ECS configuration
echo "Configuring ECS..."
echo "ECS_BACKEND_HOST=ecs.us-east-1.amazonaws.com" >> /etc/ecs/ecs.config
echo "ECS_CLUSTER=new-clixx-cluster" >> /etc/ecs/ecs.config

# Ensure DNS resolution is enabled for private endpoints
echo "Ensuring DNS resolution is set up..."
sudo echo "options timeout:2 attempts:3" >> /etc/resolv.conf

# Database interaction
echo "Running database update script..."
RESULT=$(mysql -u "$U" -p"$P" -h "$EP_DNS" -D "$DB" -sse "SELECT option_value FROM wp_options WHERE option_value LIKE 'CliXX-APP-NLB%%';" || echo "DB_QUERY_FAILED")

if [ "$RESULT" != "DB_QUERY_FAILED" ] && [ -n "$RESULT" ]; then
    echo "Matching values found. Updating database..."
    mysql -u "$U" -p"$P" -h "$EP_DNS" -D "$DB" <<EOF
UPDATE wp_options SET option_value = '$LB_DNS' WHERE option_value LIKE 'CliXX-APP-NLB%%';
EOF
    echo "Database updated successfully."
else
    echo "No matching database values found, or query failed."
fi

# starting and Enabling SSM
echo "Starting ssm agent..."
sudo systemctl start amazon-ssm-agent

# Logging VPC routing information
echo "Checking route table configuration for debugging..."
sudo ip route

echo "Bootstrap script completed."
