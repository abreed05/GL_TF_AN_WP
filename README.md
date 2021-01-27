## About this project 

This was a simple project to learn a few devops tools including Gitlab CI, Ansible, Terraform, and Python. 

Terraform is done in two separte instances. The first sets up the Public Route53 Zone. After the zone is created a simply python script is called to update the DNS through Godaddy. 

Once the Hosted zone and DNS records have been updated the rest of the infrastructure is stood up including two EC2 instances (1 webserver and 1 database server), a new VPC, subnet, and security groups for permitting certain traffic. In these instances that is SSH traffic from my home IP, mysql traffic on the private subnet, http and https traffic from any IP. 

After all of the instrastructure is stood up an ansible playbook is called that installs a number of required software on the webserver including PHP, Nginx, and the wordpress files. There are a few template files that copied over including the Nginx configuration, and the WP-Config file. 

The database server is configured to use MySQL and allow remote connections from the private subnet. 

## Gitlab CI configuration 

The .gitlab-ci.yml file contains all of the stages that will be run through to completely deploy wordpress. The Gitlab runner runs a custom built docker image that has Ansible, Terraform, AWS, and python3 preinstalled.

There are a number of variables that actually need to be set up in Gitlab including an AWS Secret Key, AWS Access key, the private key for an EC2 instance, and a variable that stores the password to the ansible vault file. 

By storing the ssh keys, api keys, and vault passwords within Gitlab this ensures that the passwords are not accidentally included in source code. If you look through the project there is reference to a config file in the python script. The API keys for godaddy are also stored in a variable rather than accidentally commited to source code. 

Admittedly I have reservations about the Ansible vault file being stored in source as well. But since this is learning project and Ansible Vault encorporates fairly strong encryption I am not too worried in this instance. But in production I would look for a more secure way to potentially store this. 

The last stage in this pipeline is a destroy stage that will tear down all of the stood up infrastructure. 

### List of Variables 

- ANSIBLE_SSHKEY (contents of private key for AWS Instance)
- ANSIBLE_VAULT_PASS (stores the password for the Ansible-Vault vault.yml file)
- AWS_ACCESS_KEY_ID (Stores the access key for AWS)
- AWS_SECRET_ACCESS_KEY (Stores the AWS secret key)
- AWS_DEFAULT_REGION (Sets the AWS default region)
- dnsconfig (stores the content of config.py)
  - Houses the following variables 
    - api_key (godaddy api key)
    - api_secret (godaddy api secret)
    - domainname (your domain name with the TLD)

### Ansible Vault Variables 

- mysql_wp_local_pass (wp user password on the local DB server)
- mysql_wp_pass (remote wordpress user password. The one stored in wp-config.php)
- mysql_pass (sets the root user pass for mysql)

## Terraform 

Managing the state file for Terraform is the biggest issue for Gitlab. Technically the statefile can be stored within the job as an artifact and that works well enough. But a better solution is to use Dynamodb and an S3 bucket. The AWS S3 bucket stores the Terraform State files and the DynamoDB instance house the lock file created by Terraform. 

There are actually two separate Terraform jobs that run in this pipeline. The first configures the Hosted zone and the second configures everything else. I chose to break them up since a Python script is also ran that updates the DNS registrar. In the future I could move this under one job and run the Python script later in the pipeline. Something I may look into. 

