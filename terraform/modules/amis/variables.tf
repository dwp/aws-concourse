variable "ami_filter_name" {
    type = string
    default = "name"
}

variable "ami_filter_values" {
    type = list(string)
    default = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
}