import jinja2
import os
import yaml
import boto3


def main():
    if 'AWS_PROFILE' in os.environ:
        boto3.setup_default_session(profile_name=os.environ['AWS_PROFILE'])
    if 'AWS_REGION' in os.environ:
        ssm = boto3.client('ssm', region_name=os.environ['AWS_REGION'])
    else:
        ssm = boto3.client('ssm')
    parameter = ssm.get_parameter(Name='terraform_bootstrap_config', WithDecryption=False)
    config_data = yaml.load(parameter['Parameter']['Value'], Loader=yaml.FullLoader)
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

