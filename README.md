# AWS Concourse

An AWS based Concourse platform

Built on top of [concourse-control-tower](https://github.com/dwp/concourse-control-tower)

## Setting up on first use

In order to install dependencies required by this repo, run `make bootstrap`

## Deploying Concourse

```
make terraform-init
make terraform-plan
make terraform-apply
```

## Resources

* https://concoursetutorial.com/
* https://github.com/skyscrapers/terraform-concourse

## Destroying
Destroy isn't always possible from Terraform. Manual steps found to be:
- remove prevent destroy in [terraform/modules/cloudwatch_log_group/log_group.tf](terraform/modules/cloudwatch_log_group/log_group.tf) (still valid 11/09/20)
- Delete NAT gateways (still valid 11/09/20)
- The module.vpc.aws_route_table.public resource will remain, due to a peering connection to metrics infrastructure keeping everything alive. (valid 11/09/20))

## GitHub Actions user

Details on managing the user credentials can be found [here](https://git.ucd.gpn.gov.uk/dip/aws-common-infrastructure/wiki/Manual-CI-Credential-Rotation#github-actions-user)

This user will deactivate its own credentials after every use.  In order to activate them again, you must run [this job](https://ci.dataworks.dwp.gov.uk/teams/dataworks/pipelines/concourse-admin?group=credentials).
