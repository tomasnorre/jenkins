#
# Cookbook Name:: jenkins
# Recipe:: default
#
# Copyright 2014, Tomas Norre
#
# All rights reserved - Do Not Redistribute
#

jenkins_cli = '/run/jenkins/war/WEB-INF/jenkins-cli.jar'
private_key = '/var/lib/jenkins/.ssh/id_rsa'
if defined? node['jenkins']['cli'] && node['jenkins']['cli']
  jenkins_cli = node['jenkins']['cli']
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

bash 'install_jenkins_plugin' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
  curl  -L http://updates.jenkins-ci.org/update-center.json | sed '1d;$d' | curl -X POST -H 'Accept: application/json' -d @- http://localhost:8080/updateCenter/byId/default/postBack
  java -jar #{jenkins_cli} -s http://127.0.0.1:8080/ -i #{private_key} install-plugin greenballs git git-client token-macro
  java -jar #{jenkins_cli} -s http://127.0.0.1:8080/ -i #{private_key} install-plugin credentials ssh-credentials scm-api gravatar
  java -jar #{jenkins_cli} -s http://127.0.0.1:8080/ -i #{private_key} install-plugin template-project run-condition
  java -jar #{jenkins_cli} -s http://127.0.0.1:8080/ -i #{private_key} install-plugin flexible-publish envfile envinject ws-cleanup
  java -jar #{jenkins_cli} -s http://127.0.0.1:8080/ -i #{private_key} install-plugin config-autorefresh-plugin build-pipeline-plugin
  EOH
  notifies :restart, 'service[jenkins]'
end
