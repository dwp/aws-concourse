#!/usr/bin/env python3

import boto3
import botocore
import jinja2
import os
import sys
import yaml


def main():
    region_name = os.environ.get('AWS_DEFAULT_REGION')
    if 'AWS_PROFILE' in os.environ:
        session = boto3.Session(profile_name=os.environ['AWS_PROFILE'])
    elif 'AWS_ROLE_ARN' in os.environ:
        sts = boto3.client('sts')
        response = sts.assume_role(
            RoleArn=os.environ['AWS_ROLE_ARN'],
            RoleSessionName='Bootstrap')
        session = boto3.Session(
            aws_access_key_id=response['Credentials']['AccessKeyId'],
            aws_secret_access_key=response['Credentials']['SecretAccessKey'],
            aws_session_token=response['Credentials']['SessionToken'])
    else:
        session = boto3.Session()
    ssm = boto3.client('ssm', region_name=region_name)

    try:
        parameter = ssm.get_parameter(
            Name='terraform_bootstrap_config', WithDecryption=False)
    except botocore.exceptions.ClientError as e:
        error_message = e.response["Error"]["Message"]
        if "The security token included in the request is invalid" in error_message:
            print(
                "ERROR: Invalid security token used when calling AWS SSM. Have you run `aws-sts` recently?")
        else:
            print("ERROR: Problem calling AWS SSM: {}".format(error_message))
        sys.exit(1)

    config_data = yaml.load(
        parameter['Parameter']['Value'], Loader=yaml.FullLoader)
    with open('terraform/deploy/terraform.tf.j2') as in_template:
        template = jinja2.Template(in_template.read())
    with open('terraform/deploy/terraform.tf', 'w+') as terraform_tf:
        terraform_tf.write(template.render(config_data))
    with open('terraform/deploy/terraform.tfvars.j2') as in_template:
        template = jinja2.Template(in_template.read())
    with open('terraform/deploy/terraform.tfvars', 'w+') as terraform_tfvars:
        terraform_tfvars.write(template.render(config_data))
    print("Terraform config successfully created")


if __name__ == "__main__":
    main()
