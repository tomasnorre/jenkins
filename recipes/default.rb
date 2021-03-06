#
# Cookbook Name:: jenkins
# Recipe:: default
#
# Copyright 2016, Tomas Norre
#
# Feel free to share and create pull requests

include_recipe 'java'
private_key = '/tmp/id_rsa_insecure_key'
public_key = '/tmp/id_rsa_insecure_key.pub'

# Setting Jenkins_cli
jenkins_cli = node['jenkins']['cli'] ? node['jenkins']['cli'] : '/run/jenkins/war/WEB-INF/jenkins-cli.jar'

if defined? node['jenkins']['plugins'] && node['jenkins']['plugins']
  jenkins_plugins = node['jenkins']['plugins'].sort.join(' ')
end

bash 'add_jenkins_to_apt' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
  wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
  sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
  sudo apt-get update
  EOH
  not_if 'test -f /etc/apt/sources.list.d/jenkins.list'
end

# Install required packages
%w(jenkins).each do |pkg|
  package pkg do
    action :install
  end
end

# Starting the service at boot
service 'jenkins' do
  supports restart: true
  action [:enable, :start]
end

#
group 'rvm' do
  action :modify
  members 'jenkins'
  append true
end

group 'www-data' do
  action :modify
  members 'jenkins'
  append true
  notifies :restart, 'service[jenkins]', :immediately
end

# Write SSH key (Private)
template '/tmp/id_rsa_insecure_key' do
  source 'id_rsa_insecure_key.erb'
  owner 'jenkins'
  group 'jenkins'
  mode '0644'
end

# Write SSH key (Public)
template '/tmp/id_rsa_insecure_key.pub' do
  source 'id_rsa_insecure_key.pub.erb'
  owner 'jenkins'
  group 'jenkins'
  mode '0644'
end
# Create default configuration
template '/var/lib/jenkins/config.xml' do
  source 'config.xml.erb'
  owner 'jenkins'
  group 'jenkins'
  mode '0644'
  notifies :restart, 'service[jenkins]', :immediately
end

# Prepare for the temporary user
bash 'prepare temporary user' do
  user 'jenkins'
  code <<-EOH
    mkdir -p /var/lib/jenkins/users/temporary
  EOH
  not_if 'test -d /var/lib/jenkins/users/temporary '
end

# Create tomas user
template '/var/lib/jenkins/users/temporary/config.xml' do
  source 'user.temporary.config.xml.erb'
  owner 'jenkins'
  group 'jenkins'
  mode '0644'
  notifies :restart, 'service[jenkins]', :immediately
end

# Removing the password prompt for unlocking
bash 'remove password prompt for unlocking' do
  user 'jenkins'
  code <<-EOH
    echo '2.0' > /var/lib/jenkins/jenkins.install.InstallUtil.lastExecVersion
  EOH
end

bash 'Create list of plugins wanted to be installed' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
    rm jenkins-plugins-wanted
    for p in #{jenkins_plugins}; do echo $p >> jenkins-plugins-wanted ; done
  EOH
end

bash 'Check plugins installed' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
    rm jenkins-plugins-installed
    java -jar #{jenkins_cli} -s http://localhost:8080/ -i #{private_key} list-plugins >> jenkins-plugins-installed
    awk '{print $1}' jenkins-plugins-installed > jenkins-plugins-installed-tmp
    rm jenkins-plugins-installed
    sort jenkins-plugins-installed-tmp > jenkins-plugins-installed
    rm jenkins-plugins-installed-tmp
  EOH
end

bash 'Check list of plugins to install' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
    grep -v -f jenkins-plugins-installed jenkins-plugins-wanted > jenkins-plugins-to-install
    rm jenkins-plugins-installed jenkins-plugins-wanted
  EOH
end

# http://goo.gl/FPN3Sf > http://updates.jenkins-ci.org/update-center.json
# http://goo.gl/2QwRkS > http://localhost:8080/updateCenter/byId/default/postBack
bash 'install_jenkins_plugin' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
    curl -L http://goo.gl/FPN3Sf | sed '1d;$d' | curl -X POST -H 'Accept: application/json' -d @- http://goo.gl/2QwRkS
    for p in `cat jenkins-plugins-to-install` ; do
      java -jar #{jenkins_cli} -s http://localhost:8080/ -i #{private_key} install-plugin $p ;
    done
  EOH
  not_if { File.zero?('/tmp/jenkins-plugins-to-install') }
  notifies :restart, 'service[jenkins]'
end

# Clean up
bash 'Remove SSH Keys' do
  user 'jenkins'
  code <<-EOH
    rm #{private_key}
    rm #{public_key}
  EOH
end
