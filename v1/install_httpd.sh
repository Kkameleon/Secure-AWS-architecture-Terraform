#! /bin/bash
sudo yum update
sudo yum install -y httpd
sudo chkconfig httpd on
sudo service httpd start
echo "Test page, if you see this then a web server is running fine :D" | sudo tee /var/www/html/index.html

echo "Best Hello word message " > superfile.txt
sudo aws s3 cp superfile.txt s3://bucket-logs-no-flaws-only-flag/logs/superfile.txt --region eu-west-3 --sse aws:kms


# installation CloudWatch
# wget https://s3.amazonaws.com/amazoncloudwatch-agent/centos/amd64/latest/amazon-cloudwatch-agent.rpm
# sudo rpm -U ./amazon-cloudwatch-agent.rpm
# setup CloudWatch

# lancement CloudWatch
# sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:configuration-file-path -s


# sudo yum -y install python-pip
# sudo pip install --upgrade pip
# sudo curl https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py -o /tmp/awslogs-agent-setup.py
# sudo chmod +x /tmp/awslogs-agent-setup.py

# sudo /tmp/awslogs-agent-setup.py -n -r "eu-west-3" -c /tmp/awslogs-config.conf
# sudo service awslogs restart


