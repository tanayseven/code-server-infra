[![CI](https://github.com/tanayseven/code-server-infra/actions/workflows/ci.yml/badge.svg)](https://github.com/tanayseven/code-server-infra/actions/workflows/ci.yml)

[![License](https://img.shields.io/github/license/tanayseven/code-server-infra.svg)](https://opensource.org/licenses/MIT)

Code Server Infra
=================

Steps to build the AMI
----------------------

1. To perform the build, run `packer build config.pkr.hcl`
2. This will create a Snapshot and register an AMI
3. This is chargable so be aware of that (deregister the AMI and delete the snapshot if not needed anymore)
4. If you want to delete and deregister image, run `aws ec2 deregister-image --image-id ami-0a1b2c3d4e && aws ec2 delete-snapshot --snapshot-id snap-0a1b2c3d4e` (make sure your region is configured correctly, check the file `~/.aws/config`)

Steps to run the VM in cloud
----------------------------

1. Install [tfenv](https://github.com/tfutils/tfenv)
2. Login into your AWS account from CLI `aws login`
3. After the above login the following credentials should be in the file `~/.aws/credentials`
```
[default]
aws_access_key_id = ABCDEFGHIJKLMNOPQRSTUV
aws_secret_access_key = aa1234b56cD7EFgHIJklMn0pqRSTUvWxY8ab9cDE
```
4. Install the right terraform version with the following two commands:
```
tfenv install
tfenv use
```
4a. To setup a new keypair run: `ssh-keygen -t rsa -f ~/.ssh/code_server -P ""`
5. To spin up the infrastructure, run `terraform apply`
6. To shut down the infrastructure run `terraform destroy`
