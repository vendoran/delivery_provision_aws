# delivery_provision_aws

Based upon John Byrne's [chef_workflow_terraform](https://github.com/johnbyrneio/chef_workflow_terraform) cookbook

This cookbook provisions multiple nodes within AWS via terraform.
It is called from a Chef Automate [build_cookboook](https://docs.chef.io/delivery_build_cookbook.html)

Once the AWS attribtues are set, the primary attribute is:
<code>default['delivery_provision_aws']['provision']['0'] = { 'platform' => 'ubuntu-14.04', 'size' => 't2.micro', 'recipe' => 'default' }</code>

There can be multiple values, just increament the digit, the recipe loops through them.

This also allows for running of a non-default recipe.  Perhaps your cookbook has both a client and server recipes that do different things, well that can be specied like:<br />
<code>
default['delivery_provision_aws']['provision']['0'] = { 'platform' => 'ubuntu-14.04', 'size' => 't2.micro', 'recipe' => 'client' }<br />
default['delivery_provision_aws']['provision']['0'] = { 'platform' => 'ubuntu-16.04', 'size' => 't2.micro', 'recipe' => 'server' }
</code>

Each node can be a different platform, size and recipe.  The cookbooks writes terraform tf files and then combines them all into a single parallel execution.