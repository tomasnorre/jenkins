name 'jenkins'
maintainer 'Tomas Norre Mikkelsen'
maintainer_email 'tomasnorre@gmail.com'
license 'All rights reserved'
description 'Installs/Configures jenkins'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.3.0'

depends 'java'

%w(debian ubuntu).each do |os|
  supports os
end
