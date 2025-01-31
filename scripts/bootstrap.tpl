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
echo "ECS_CLUSTER=new-clixx-cluster" >> /etc/ecs/ecs.config

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
sudo systemctl start amazon-ssm-agent
sudo systemctl enable amazon-ssm-agent

echo "Bootstrap script completed."