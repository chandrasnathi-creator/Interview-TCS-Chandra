#!/bin/bash
# Install Nginx
sudo dnf update -y
sudo dnf install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Install CloudWatch Agent
sudo dnf install -y amazon-cloudwatch-agent

# Configure CloudWatch Agent to send /var/log/messages
cat <<EOF | sudo tee /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "agent": {
    "run_as_user": "root"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/messages",
            "log_group_name": "/ec2/${asg_name}/var/log/messages",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}
EOF

# Start and enable the CloudWatch Agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s