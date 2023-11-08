resource "aws_launch_template" "Oregon_LaunchTemplate" {
name = "Oregon_LaunchTemplate"
image_id = "ami-05c13eab67c5d8861"
instance_type = "t2.micro"


block_device_mappings {
device_name = "/dev/sda1"


ebs {
volume_size = 20
volume_type = "gp2"
}
}


network_interfaces {
associate_public_ip_address = true
security_groups = [aws_security_group.Oregon_WebserverApp1.id]
}


tag_specifications {
resource_type = "instance"
tags = {
Name = "first template"
}
}


user_data = base64encode(<<EOF
#!/bin/bash
# This is the user data script for the EC2 instance


# Update the system
sudo yum update -y


# VPC ID is available as an environment variable
VPC_ID="${aws_vpc.Oregon_app1.id}"
# Availability Zone is available as an environment variable
AVAILABILITY_ZONE="$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)"
# Output the VPC ID and Availability Zone
echo "VPC ID: $VPC_ID"
echo "Availability Zone: $AVAILABILITY_ZONE"


# Install necessary software packages
sudo yum install -y httpd


# Start the Apache web server
sudo service httpd start
sudo chkconfig httpd on


# Allow incoming traffic on port 80 (HTTP)
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo service iptables save


# Output a simple HTML page
echo "<html><h1>Hello, World!</h1></html>" > /var/www/html/index.html
