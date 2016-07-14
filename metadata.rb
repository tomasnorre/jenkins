name 'jenkins'
maintainer 'Tomas Norre Mikkelsen'
maintainer_email 'tomasnorre@gmail.com'
license 'All rights reserved'
description 'Installs/Configures jenkins'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.3.0'
issues_url 'https://github.com/tomasnorre/jenkins/issues' if respond_to?(:issues_url)
source_url 'https://github.com/tomasnorre/jenkins' if respond_to?(:source_url)

depends 'java'

%w(debian ubuntu).each do |os|
  supports os
end
