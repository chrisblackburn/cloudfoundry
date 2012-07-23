repo_dir = "/tmp/cloudfoundry"
install_config = "/tmp/cf-node-config.yml"
remote_repo = "https://github.com/cloudfoundry"

# Update apt repository
package "apt" do
  notifies :run, "execute[apt-get update]", :immediately
end

# Create installation configuration
template install_config do
  source "#{node['cloudfoundry']['role']}.yml"
  mode "0660"
  variables(
    :nats_host => node['cloudfoundry']['nats_host'],
    :nats_user => node['cloudfoundry']['nats_user'],
    :nats_pass => node['cloudfoundry']['nats_pass']
  )
end

# Create directory to hold codebase
directory repo_dir do
  action :create
  recursive true
end

# Grab latest components from GitHub
%w{vcap cloud_controller dea router health_manager stager}.each do |component|
  execute "git clone #{component}" do
    command "git clone #{repo_path}/#{component}.git #{component}"
    cwd repo_dir
    not_if {File.exists?("#{repo_dir}/#{component}/.git/")}
  end
end

# Execute CloudFoundry installer
execute "cloudfoundry installer" do
  command %Q{"sudo #{repo_dir}/vcap/dev_setup/bin/vcap_dev_setup
          -c #{install_config}
          -d #{node['cloudfoundry']['install_dir']} 
          -D #{node['cloudfoundry']['domain']} 
          -r #{repo_dir}"}
  ENV['CLOUD_FOUNDRY_EXCLUDED_COMPONENT'] = 
    node['cloudfoundry']['excluded_components']
  ENV['USER'] = node['cloudfoundry']['user']
end

# Fix file permissions
[node['cloudfoundry']['install_dir'], 
 "#{node['cloudfoundry']['install_dir']}/.deployments", 
 "/var/vcap/", 
 "/var/vcap.local/"].each do |dir|
  execute 'change file owner' do
    command "sudo chown -R #{node['cloudfoundry']['user']} #{dir}"
  end
end

# Add upstart script to ensure CloudFoundry starts with system
template "/etc/init/cloudfoundry.conf" do
  source "cloudfoundry.conf"
  mode "0760"
  variables(
    :install_dir  => node['cloudfoundry']['install_dir'],
    :role         => node['cloudfoundry']['role'],
    :user         => node['cloudfoundry']['user']
  )
end
