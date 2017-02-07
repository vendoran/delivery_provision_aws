# S3 Bucket to store Terraform remote state files
default['delivery_provision_aws']['s3_bucket_name']    = nil # 'terraform_state'
default['delivery_provision_aws']['s3_bucket_region']  = nil # 'us-east-1'

# EC2 Instance Configuration
default['delivery_provision_aws']['aws_resource_prefix']   = nil # 'chef_automate'
default['delivery_provision_aws']['aws_region']            = nil # 'us-east-1'
default['delivery_provision_aws']['ec2_keypair_name']      = nil # 'chef-automate'
default['delivery_provision_aws']['vpc_security_groups']   = nil # ['sg-xxxxxxxx']
default['delivery_provision_aws']['vpc_subnet']            = nil # 'subnet-xxxxxxxx'
default['delivery_provision_aws']['ec2_login_user_pw']     = 'P@ssw0rd!' # Windows only

# Chef Client bootstrap configuration
default['delivery_provision_aws']['automate_chef_server_url']  = nil # 'https://ChefAutomateURL.com/organizations/OrgName'
default['delivery_provision_aws']['automate_chef_user_name']   = nil # 'username'

# default['delivery_provision_aws']['provision']['0'] = { 'platform' => 'ubuntu-14.04', 'size' => 't2.micro', 'recipe' => 'default' }
# default['delivery_provision_aws']['provision']['1'] = { 'platform' => 'ubuntu-14.04', 'size' => 't2.micro', 'recipe' => 'default' }
default['delivery_provision_aws']['provision']['0'] = nil
