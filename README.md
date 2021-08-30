[![CI](https://github.com/tanayseven/code-server-infra/actions/workflows/ci.yml/badge.svg)](https://github.com/tanayseven/code-server-infra/actions/workflows/ci.yml)

Code Server Infra
=================

Local setup steps
-----------------

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
5. To spin up the infrastructure, run `terraform apply`
6. To shut down the infrastructure run `terraform destroy`
