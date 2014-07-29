#
# Cookbook Name:: jenkins
# Recipe:: default
#
# Copyright 2014, Tomas Norre
#
# All rights reserved - Do Not Redistribute
#

# Install required packages
%w{jenkins}.each do |pkg|
  package pkg do
    action :install
  end
end

# Starting the service at boot
service 'jenkins' do
  supports restart: true
  action [:enable, :start]
end


bash "install_jenkins_plugin" do
  user "root"
  cwd "/tmp"
  code <<-EOH
  java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://127.0.0.1:8080/ install-plugin greenballs credentials ssh-credentials git git-client token-macro scm-api gravatar
  java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://127.0.0.1:8080/ install-plugin template-project run-condition flexible-publish envfile envinject
  EOH
  notifies :restart, 'service[jenkins]'
end
