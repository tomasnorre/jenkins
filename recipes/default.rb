#
# Cookbook Name:: jenkins
# Recipe:: default
#
# Copyright 2014, Tomas Norre
#
# All rights reserved - Do Not Redistribute
#

jenkins_cli = '/run/jenkins/war/WEB-INF/jenkins-cli.jar'
if defined? node['jenkins']['cli'] && node['jenkins']['cli']
  jenkins_cli = node['jenkins']['cli']
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
  java -jar #{jenkins_cli} -s http://127.0.0.1:8080/ install-plugin greenballs git git-client token-macro
  java -jar #{jenkins_cli} -s http://127.0.0.1:8080/ install-plugin credentials ssh-credentials scm-api gravatar
  java -jar #{jenkins_cli} -s http://127.0.0.1:8080/ install-plugin template-project run-condition
  java -jar #{jenkins_cli} -s http://127.0.0.1:8080/ install-plugin flexible-publish envfile envinject ws-cleanup
  java -jar #{jenkins_cli} -s http://127.0.0.1:8080/ install-plugin config-autorefresh-plugin build-pipeline-plugin
  EOH
  notifies :restart, 'service[jenkins]'
end
