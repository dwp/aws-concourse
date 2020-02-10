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
- remove prevent destroy in `terraform/modules/cloudwatch_log_group/log_group.tf`
- Destroy RDS cluster if no snapshot exists
- Delete NAT gateways
- Comment out the `route` within the module.vpc.aws_route_table.private resource
