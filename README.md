Jenkins Cookbook
================

This cookbook installs Jenkins on your Ubuntu or Debian system

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

This cookbook creates a system user "jenkins", it's recommended to create a ssh key pair for this user, and map it to a jenkins user, that can install plugins etc.

```sh
$ sudo su jenkins
$ ssh-keygen -t rsa -C "jenkins@domain.tld"
```

Options
-------

If the `jenkins-cli.jar` is not located in `/run/jenkins/war/WEB-INF/` which is the cookbook default, then you can set it in you node configuration

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

Authors
-------
Authors:
  * [Tomas Norre Mikkelsen](http://github.com/tomasnorre)
