# ------------------------------
# Terraform Provider Configuration (Cloud Provider API)
# ------------------------------

terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.30.0"
    }
  }


  # ------------------------------
  # Backend Configuration (S3)
  # ------------------------------

  # In case you want to use a remote backend, you should:
  # 1. Create a S3 bucket and a DynamoDB table.
  # 2. Create a backend/backend.conf file using backend/backend.conf.example 
  #    guidelines.
  # 3. Run `terraform init` to initialize the backend.
  # 4. Run `terraform apply` to create the resources.
  # 5. Run `terraform init` again to reconfigure the backend.
  # 6. Run `terraform apply` again to move the state to the backend.


  # The main advantage of using a remote backend is that you 
  # can share the state file with other developers. 
  # This is useful when you are working in a team!

  backend "s3" {
    # ...
  }
}
