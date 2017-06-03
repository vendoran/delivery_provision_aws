/*
// node variables
variable "ec2_ami_id" {
    type = "string"
    description = "EC2 AMI ID to use for provisioned instances"
}

variable "ec2_instance_type" {
    type = "string"
    description = "AWS EC2 instance type. Ex: t2.small"
}

variable "ec2_connection_type" {
    type = "string"
    description = "Protocol for connecting to the EC2 instance (ssh, winrm)"
}

variable "ec2_login_user" {
    type = "string"
    description = "User account for logging into the EC2 instance"
}

variable "chef_recipe" {
    type = "string"
    description = "Recipe to run during provisioning"
}
*/

// run variables
variable "aws_region" {
  type        = "string"
  description = "AWS region to deploy in. Ex: us-west-1"
}

variable "aws_resource_prefix" {
  type        = "string"
  description = "String to prepend to the name of resources created in AWS"
}

variable "ec2_keypair_name" {
  type        = "string"
  description = "EC2 SSH Key Pair Name"
}

variable "vpc_subnet" {
  type        = "string"
  description = "VPC Subnet to deploy instance within"
}

variable "vpc_security_groups" {
  type        = "list"
  description = "List of VPC Security Group IDs to apply to the instance"
}

variable "ec2_tags" {
  type        = "map"
  description = "EC2 Tags to use for provisioned instances"
}

variable "chef_server_url" {
  type        = "string"
  description = "Chef Server URL"
}

variable "chef_user_name" {
  type        = "string"
  description = "Chef Server user name"
}

variable "ec2_login_user_pw" {
  type        = "string"
  description = "User password to use for the Windows Admin Account"
}

variable "chef_environment" {
  type        = "string"
  description = "Chef Server Environment name"
}

variable "chef_client_version" {
  type        = "string"
  description = "Chef Client Version"
}

variable "chef_cookbook" {
  type        = "string"
  description = "Cookbook to run during provisioning"
}

// Provider specific configs
provider "aws" {
  region = "${var.aws_region}"
}
