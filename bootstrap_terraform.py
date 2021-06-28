#!/usr/bin/env python3

import boto3
import botocore
import jinja2
import os
import sys
import yaml
import json
import datetime
from dateutil.tz import tzlocal


def main():
    if 'AWS_PROFILE' in os.environ:
        boto3.setup_default_session(profile_name=os.environ['AWS_PROFILE'])
    if 'AWS_PROFILE_MGT_DEV' in os.environ:
        secrets_session = boto3.Session(
            profile_name=os.environ['AWS_PROFILE_MGT_DEV'])
    elif 'AWS_SECRETS_ROLE' in os.environ:
        secrets_session = assumed_role_session(os.environ['AWS_SECRETS_ROLE'])
    if 'AWS_REGION' in os.environ:
        ssm = boto3.client('ssm', region_name=os.environ['AWS_REGION'])
        secrets_manager = secrets_session.client(
            'secretsmanager', region_name=os.environ['AWS_REGION'])
    else:
        secrets_manager = secrets_session.client('secretsmanager')

    try:
        dataworks_secret = secrets_manager.get_secret_value(
            SecretId="/concourse/dataworks/dataworks-secrets")
        terraform_secret = secrets_manager.get_secret_value(
            SecretId="/concourse/dataworks/terraform")
        concourse_secret = secrets_manager.get_secret_value(
            SecretId="/concourse/dataworks/dataworks")
    except botocore.exceptions.ClientError as e:
        error_message = e.response["Error"]["Message"]
        if "The security token included in the request is invalid" in error_message:
            print(
                "ERROR: Invalid security token used when calling AWS Secrets Manager. Have you run `aws-sts` recently?")
        else:
            print("ERROR: Problem calling AWS Secrets Manager: {}".format(error_message))
        sys.exit(1)

    config_data = yaml.load(
        terraform_secret['SecretBinary'], Loader=yaml.FullLoader)
    config_data['terraform'] = json.loads(
        terraform_secret['SecretBinary'])["terraform"]
    config_data['database_username'] = json.loads(
        dataworks_secret['SecretBinary'])["database_user"]
    config_data['database_password'] = json.loads(
        dataworks_secret['SecretBinary'])["database_password"]
    config_data['concourse_user'] = json.loads(
        dataworks_secret['SecretBinary'])["concourse_user"]
    config_data['enterprise_github_oauth_client_id'] = json.loads(
        dataworks_secret['SecretBinary'])["enterprise_github_oauth_client_id"]
    config_data['enterprise_github_oauth_client_secret'] = json.loads(
        dataworks_secret['SecretBinary'])["enterprise_github_oauth_client_secret"]
    config_data['session_signing_key'] = json.loads(
        dataworks_secret['SecretBinary'])["session_signing_key"]
    config_data['tsa_host_key'] = json.loads(
        dataworks_secret['SecretBinary'])["tsa_host_key"]
    config_data['authorized_worker_keys'] = json.loads(
        dataworks_secret['SecretBinary'])["authorized_worker_keys"]
    config_data['worker_key'] = json.loads(
        dataworks_secret['SecretBinary'])["worker_key"]
    config_data['tsa_host_pub_key'] = json.loads(
        dataworks_secret['SecretBinary'])["tsa_host_pub_key"]
    config_data['enterprise_github_url'] = json.loads(
        concourse_secret['SecretBinary'])["enterprise_github_url"]

    with open('terraform/deploy/terraform.tf.j2') as in_template:
        template = jinja2.Template(in_template.read())
    with open('terraform/deploy/terraform.tf', 'w+') as terraform_tf:
        terraform_tf.write(template.render(config_data))
    with open('terraform/deploy/terraform.tfvars.j2') as in_template:
        template = jinja2.Template(in_template.read())
    with open('terraform/deploy/terraform.tfvars', 'w+') as terraform_tfvars:
        terraform_tfvars.write(template.render(config_data))

    print("Terraform config successfully created")


def assumed_role_session(role_arn: str, base_session: botocore.session.Session = None):
    base_session = base_session or boto3.session.Session()._session
    fetcher = botocore.credentials.AssumeRoleCredentialFetcher(
        client_creator=base_session.create_client,
        source_credentials=base_session.get_credentials(),
        role_arn=role_arn,
        extra_args={
            #    'RoleSessionName': None # set this if you want something non-default
        }
    )
    creds = botocore.credentials.DeferredRefreshableCredentials(
        method='assume-role',
        refresh_using=fetcher.fetch_credentials,
        time_fetcher=lambda: datetime.datetime.now(tzlocal())
    )
    botocore_session = botocore.session.Session()
    botocore_session._credentials = creds
    return boto3.Session(botocore_session=botocore_session)


if __name__ == "__main__":
    main()
