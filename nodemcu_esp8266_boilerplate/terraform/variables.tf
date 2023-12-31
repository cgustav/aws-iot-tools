

# List of available regions:
# https://docs.aws.amazon.com/general/latest/gr/rande.html

variable "aws_region" {
  type        = string
  description = "Change the region if you want to deploy the resources in another region."
  default     = "us-east-1"
}

variable "aws_profile" {
  type        = string
  description = "Change the profile if you want to deploy the resources in another account/role."
  default     = "default"
}
