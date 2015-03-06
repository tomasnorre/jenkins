Jenkins Cookbook
================

This cookbook installs jenkins on your Ubuntu or Debian system

Usage
-----
e.g.
Just include `jenkins` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[jenkins]"
  ]
}
```

This cookbook creates a system user "jenkins", it's recommended to create a ssh key pair for this user, and map it to a jenkins user, that can install plugins etc.
The second you active login on jenkins, you will not be able to install plugins through this cookbook anymore without this set.

```text
sudo su jenkins
ssh-keygen -t rsa -C "jenkins@domain.tld"
```

License and Authors
-------------------
Authors:
  * Tomas Norre Mikkelsen
