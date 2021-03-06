#
# Cookbook:: delivery_provision_aws
# Recipe:: install_terraform
#
# Copyright:: 2017, The Authors, All Rights Reserved.

# Location where the Terraform binary will be installed to
# We install this in the Workflow workspace as the Chef Client
# run does not run as root
terraform_install_dir = workflow_workspace

package 'unzip' do
  action :install
end

# Using the ark cookbook to install Terraform
ark 'terraform' do
  path terraform_install_dir
  url node['delivery_provision_aws']['install_url']
  checksum node['delivery_provision_aws']['package_checksum']
  strip_components 0
  owner 'dbuild'
  group 'dbuild'
  action :put
end
