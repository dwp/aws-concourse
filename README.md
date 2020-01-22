# AWS Concourse

An AWS based Concourse platform

Built on top of [concourse-control-tower](https://github.com/dwp/concourse-control-tower)

## Setting up on first use

In order to install dependencies required by this repo, run `make bootstrap`

## Deploying Concourse to Development Account

```
make boostrap-terraform-dev
cd terraform/deploy
terraform init
terraform plan
terraform apply
```

## Deploying Concourse to Management Account

```
make bootstrap-terraform
cd terraform/deploy
terraform init
terraform plan
terraform apply
```

## Resources

* https://concoursetutorial.com/
* https://github.com/skyscrapers/terraform-concourse
