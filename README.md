# About this project 

This was a simple project to learn a few devops tools including Gitlab CI, Ansible, Terraform, and Python. 

Terraform is done in two separte instances. The first sets up the Public Route53 Zone. After the zone is created a simply python script is called to update the DNS through Godaddy. 

Once the Hosted zone and DNS records have been updated the rest of the infrastructure is stood up including two EC2 instances (1 webserver and 1 database server), a new VPC, subnet, and security groups for permitting certain traffic. In these instances that is SSH traffic from my home IP, mysql traffic on the private subnet, http and https traffic from any IP. 

After all of the instrastructure is stood up an ansible playbook is called that installs a number of required software on the webserver including PHP, Nginx, and the wordpress files. There are a few template files that copied over including the Nginx configuration, and the WP-Config file. 

The database server is configured to use MySQL and allow remote connections from the private subnet. 

# Gitlab CI configuration 

