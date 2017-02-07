#
# Cookbook:: delivery_provision_aws
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.
if node['delivery_provision_aws']['install']
  include_recipe 'delivery_provision_aws::install_terraform'
end

# Load the delivery-secrets data bag item for this project
# See README for details on the contents of this data bag item
project_secrets = get_project_secrets

# Path to the Terraform binary once installed
terraform_cmd = "#{workflow_workspace}/terraform/terraform"

# Location where the Terraform module will be generated
terraform_module_dir = "#{node['delivery']['workspace']['cache']}/terraform/module"

# Location where the Terraform plan will be staged
terraform_plan_dir = "#{node['delivery']['workspace']['cache']}/terraform/plan"

# Clean up Terraform workspace
[terraform_module_dir, terraform_plan_dir].each do |dir|
  directory dir do
    recursive true
    action :delete
  end
end

# Create Terraform module and plan directories
[terraform_module_dir, terraform_plan_dir].each do |dir|
  directory dir do
    owner 'dbuild'
    group 'dbuild'
    mode '0755'
    recursive true
    action :create
  end
end

node['delivery_provision_aws']['provision'].each do |n, d|
  instance = n
  platform = d['platform']
  ec2_instance_type = d['size']
  chef_recipe = d['recipe']

  case platform
  when 'ubuntu-14.04'
    ec2_ami_id = 'ami-5e63d13e'
    ec2_login_user = 'ubuntu'
    ec2_connection_type = 'ssh'
  when 'ubuntu-16.04'
    ec2_ami_id = 'ami-7c803d1c'
    ec2_login_user = 'ubuntu'
    ec2_connection_type = 'ssh'
  when 'windows-2008r2'
    ec2_ami_id = 'ami-6b9f200b'
    ec2_login_user = 'Administrator'
    ec2_connection_type = 'winrm'
  when 'windows-2012r2'
    ec2_ami_id = 'ami-1562d075'
    ec2_login_user = 'Administrator'
    ec2_connection_type = 'winrm'
  end

  case ec2_connection_type
  when 'ssh'
    tf_source = 'main-linux.tf.erb'
  when 'winrm'
    tf_source = 'main-windows.tf.erb'
  end

  # Generate the Terraform module from a template
  template "#{terraform_module_dir}/main#{n}.tf" do
    source tf_source
    owner 'dbuild'
    group 'dbuild'
    mode '0644'
    variables(instance: instance,
              ec2_ami_id: ec2_ami_id,
              ec2_instance_type: ec2_instance_type,
              ec2_connection_type: ec2_connection_type,
              ec2_login_user: ec2_login_user,
              chef_recipe: chef_recipe)
    action :create
  end
end

# Initialize the Terraform plan
terraform_state_dir = "#{node['delivery']['change']['project']}/#{workflow_chef_environment_for_stage}/terraform.tfstate"

execute 'Run terraform init' do
  command "#{terraform_cmd} init -backend=s3 \
    -backend-config='bucket=#{node['delivery_provision_aws']['s3_bucket_name']}' \
    -backend-config='key=#{terraform_state_dir}' \
    -backend-config='acl=bucket-owner-full-control' \
    -backend-config='region=#{node['delivery_provision_aws']['s3_bucket_region']}' \
    #{terraform_module_dir}"
  cwd terraform_plan_dir
  environment('AWS_ACCESS_KEY_ID' => project_secrets['aws_access_key_id'],
              'AWS_SECRET_ACCESS_KEY' => project_secrets['aws_secret_access_key'])
  live_stream true
  action :run
end

# Generate the Variables and provider terraform file
cookbook_file "#{terraform_plan_dir}/main-initialize.tf" do
  source 'main-initialize.tf'
  owner 'dbuild'
  group 'dbuild'
  mode '0644'
  action :create
end

# Copy the AWS EC2 ssh private key from the delivery-secrets data bag
# This key will be used to SSH into the new EC2 instance to bootstrap it
file "#{terraform_plan_dir}/aws_ssh_key.pem" do
  content project_secrets['aws_ssh_key']
  owner 'dbuild'
  group 'dbuild'
  mode '0600'
  sensitive true
  action :create
end

# Copy the Chef server user key from the delivery-secrets data bag
# This key will be used to register the EC2 instance with the Chef Server
file "#{terraform_plan_dir}/chef_user_key.pem" do
  content project_secrets['chef_user_key']
  owner 'dbuild'
  group 'dbuild'
  mode '0600'
  sensitive true
  action :create
end

# Generate the Terraform variable response file
template "#{terraform_plan_dir}/main.tfvars" do
  source 'main.tfvars.erb'
  owner 'dbuild'
  group 'dbuild'
  mode '0644'
  variables(chef_environment: workflow_chef_environment_for_stage,
            chef_cookbook: node['delivery']['change']['project'],
            ec2_login_user_pw: node['delivery_provision_aws']['ec2_login_user_pw'])
  action :create
end

# Generate the Refresh Data Vault command from a file
cookbook_file "#{terraform_plan_dir}/refresh_data_vaults.sh" do
  source 'refresh_data_vaults.sh'
  owner 'dbuild'
  group 'dbuild'
  mode '0744'
  action :create
end

# Generate the Windows user_data from a file
cookbook_file "#{terraform_plan_dir}/user_data.ps1" do
  source 'user_data.ps1'
  owner 'dbuild'
  group 'dbuild'
  mode '0644'
  action :create
end

# Destroy existing acceptance environment. We want to test against a clean instance
execute 'Destroy existing acceptance environment' do
  command "#{terraform_cmd} destroy -var-file main.tfvars -force"
  cwd terraform_plan_dir
  environment('AWS_ACCESS_KEY_ID' => project_secrets['aws_access_key_id'],
              'AWS_SECRET_ACCESS_KEY' => project_secrets['aws_secret_access_key'])
  live_stream true
  action :run
  only_if { node['delivery']['change']['stage'] == 'acceptance' }
end

# Apply the Terraform plan
execute 'Apply Terraform Plan' do
  command "#{terraform_cmd} apply --var-file main.tfvars"
  cwd terraform_plan_dir
  environment('AWS_ACCESS_KEY_ID' => project_secrets['aws_access_key_id'],
              'AWS_SECRET_ACCESS_KEY' => project_secrets['aws_secret_access_key'])
  live_stream true
  action :run
end
