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


## AMI testing

Upon a new releae of Concourse, or an update to the Concourse AMI config, we build a new AMI named: `untested-dw-al2-concourse-ami` using the [ami-builder](https://ci.dataworks.dwp.gov.uk/teams/dataworks/pipelines/ami-builder) pipeline in Concourse.  Upon successful creation of a new [untested-dw-al2-concourse-ami](https://ci.dataworks.dwp.gov.uk/teams/dataworks/pipelines/ami-builder/resources/untested-dw-al2-concourse-ami) resource, we will trigger the [validate-concourse-ami](https://ci.dataworks.dwp.gov.uk/teams/dataworks/pipelines/ami-builder/jobs/validate-concourse-ami) job.  The only way this job will succeed is if the test results provided by the [concourse](https://ci.dataworks.dwp.gov.uk/teams/dataworks/pipelines/ami-builder/resources/concourse) resource, match the AMI ID provided by the [untested-dw-al2-concourse-ami](https://ci.dataworks.dwp.gov.uk/teams/dataworks/pipelines/ami-builder/resources/untested-dw-al2-concourse-ami) resource, and contain the word `SUCCESS`.

The [concourse](https://ci.dataworks.dwp.gov.uk/teams/dataworks/pipelines/ami-builder/resources/concourse) resource is provided in an non-standard pattern, which differs entirely from all other test result resources in the [ami-builder](https://ci.dataworks.dwp.gov.uk/teams/dataworks/pipelines/ami-builder) pipeline.  This is mainly due to Concourse being deployed via `GitHub Actions` and not Concourse, unlike every other consumer of our AMIs.

A new [untested-dw-al2-concourse-ami](https://ci.dataworks.dwp.gov.uk/teams/dataworks/pipelines/ami-builder/resources/untested-dw-al2-concourse-ami) resource, is also consumed by the [ami-id-update](https://ci.dataworks.dwp.gov.uk/teams/dataworks/pipelines/concourse-admin?group=ami-id-update) job.  This job uses the new resource to update a secret called `ami-ids` that is stored in `AWS SecretsManager`.  It's this secret that is queried when Concourse is deployed by `GitHub Actions` [providing the AMI ID](https://github.com/dwp/aws-concourse/blob/ec998340d217353c83f8c4886b618f40de152fe5/terraform/deploy/terraform.tf.j2#L162) to use when creating/updating the infrastructure.  Upon sucessfully updating the secert, the job triggers the [AMI build and test](https://github.com/dwp/aws-concourse/actions/workflows/ami-test-apply.yml) workflow.  This workflow, when successful, deploys to only management-dev, terminates the existing Concourse EC2s and produces an new GitHub release.
It should be noted that we purposely pin the AMI ID in this job for `Management`.  We do this to ensure we do not unintentionally upgrade the Production Concourse.  The aim is to remove this pin when we have built confidence in the test and relase process.

Post-termination, new Concourse nodes will start on the new AMI, allowing the execution of a single pipeline which creates our test results.  This is the [concourse](https://ci.wip.dataworks.dwp.gov.uk/teams/dataworks/pipelines/concourse) pipeline, which only exists in management-dev.  This consumes the newly created GitHub release, then compares the AMI ID provided by the [untested-al2-concourse-ami](https://ci.wip.dataworks.dwp.gov.uk/teams/dataworks/pipelines/concourse/resources/untested-al2-concourse-ami) and the AMI ID on the current running instances of Concourse in management-dev.  If every instance matches, then a successful test result is created.

This successful test result will allow the [validate-concourse-ami](https://ci.dataworks.dwp.gov.uk/teams/dataworks/pipelines/ami-builder/jobs/validate-concourse-ami) job to now pass, creating the [dw-al2-concourse-ami](https://ci.dataworks.dwp.gov.uk/teams/dataworks/pipelines/ami-builder/jobs/dw-al2-concourse-ami) which can be deployed to Management.

Should AWS instances need to be refreshed/replaced then the [reboot-worker-nodes](https://ci.dataworks.dwp.gov.uk/teams/dataworks/pipelines/concourse-admin?group=reboot-worker-nodes) pipeline should be utilised which will 'Land' the Worker nodes (stop any jobs being sent to them) and then the ASG will replace the instances.
