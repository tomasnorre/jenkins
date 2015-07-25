Jenkins Cookbook
================

This cookbook installs Jenkins on your Ubuntu or Debian system

Build status
------------
[![Build Status](https://travis-ci.org/tomasnorre/jenkins.svg)](https://travis-ci.org/tomasnorre/jenkins)

Usage
-----

Include `jenkins` in your node's `run_list` and add your list of jenkins-plugins to install:

```json
{
  "jenkins": {
    "plugins": [
      "greenballs",
      "git",
      "build-pipeline-plugin",
      "credentials"
    ]
  },
  "run_list": [
    "recipe[jenkins]"
  ]
}
```

This cookbook creates a system user "jenkins", it's recommended to create a ssh key pair for this user, and map it to a jenkins user, that can install plugins etc. this can be done under `http://host.tld:8080/user/<username>/configure`

```sh
$ sudo su jenkins
$ ssh-keygen -t rsa -C "jenkins@domain.tld"
$ cat .ssh/id_rsa.pub >> .ssh/authorized_keys
```

Options
-------

If the `jenkins-cli.jar` is not located in `/run/jenkins/war/WEB-INF/` which is the cookbook default, then you can set it in your node configuration

```json
{
    "jenkins": {
        "cli": "/run/jenkins/war/WEB-INF/jenkins-cli.jar",
    },
    "run_list": [
        "recipe[jenkins]"
    ]
}
```

If you want specify which java version to use it can be done in your node configuration

```json
    "java": {
      "install_flavor": "openjdk",
      "jdk_version": "7"
    },
```

Contributing
------------
e.g.

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

Authors
-------------------
* [Tomas Norre Mikkelsen](http://github.com/tomasnorre)

License
-------

The MIT License (MIT)

Copyright (c) 2015 - Tomas Norre Mikkelsen

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
