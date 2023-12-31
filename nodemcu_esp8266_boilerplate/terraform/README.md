# AWS IOT ESP8622 Boilerplate Backend Configuration

In order to use this backend you need to define if you want to configure a backend to store terraform stores in the cloud or in a local file system.

In case you choose to store everything in the cloud (strongly recommended) you should follow the steps below:

1. Create a S3 bucket in AWS (Store the name of the bucket in a safe place)

2. Create a DynamoDB table in AWS (Create an on-demand table with a name like `terraform-iot-lock-states` and a primary key `LockID`)

3. Create a user in AWS with the following permissions:

   - AmazonS3FullAccess
   - AmazonDynamoDBFullAccess
   - IAMFullAccess
   - AWSIoTFullAccess
   - AmazonAPIGatewayAdministrator
   - AmazonEC2FullAccess
   - AmazonVPCFullAccess
   - ...

4. Create private access keys for the user you created in step 3 (Store the keys in a safe place or configure via `aws configure`).

5. Create a file called `variables/backend.tfvars` in the root of the project with the following content:

   ```hcl
   bucket         = "<bucket-name>"
   key            = "terraform.tfstate"
   dynamodb_table = "<dynamodb-table-name>"
   encrypt        = true
   region         = "<aws-region>"
   ```

6. Create a file called `variables/main.tfvars` in the root of the project with the following content:

   ```hcl
    aws_region = "<aws-region>"
    aws_profile = "<aws-profile>"
   ```

   > **Note:** The profile is the name of the user you created in step 4.
   > **Note:** The region is the region where you created the S3 bucket and the DynamoDB table.

7. Execute the init command to initialize the backend:

   ```bash
   chmod +x init.sh
   ./init.sh
   ```

8. Deploy the infrastructure:

   ```bash
   chmod +x deploy.sh
   ./init.sh
   ```

## Important Notes

- The backend configuration is stored in the file `backend.tf` and the variables are stored in the file `variables.tf`.
- In case you experiment problems initializing the backend, with exceptions like `error validating provider credentials: error calling sts:GetCallerIdentity: operation error STS: GetCallerIdentity, https response error StatusCode: 403` you should check the following:
  - The user you created in step 3 has the correct permissions.
  - The user you created in step 3 has the correct access keys.
  - The user you created in step 3 has the correct region.
  - Export your secret credentials manually via System Envars or via `aws configure`.
