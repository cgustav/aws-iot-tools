# ------------------------------
# IOTOUTPUTS
# ------------------------------

output "thing_arn" {
  value       = data.aws_arn.thing.arn
  description = "The ARN of the thing."
}

output "thing_name" {
  value       = aws_iot_thing.thing.name
  description = "The name of the thing."
}

output "thing_region" {
  value       = data.aws_arn.thing.region
  description = "The region of the thing."
}

output "thing_account" {
  value       = data.aws_arn.thing.account
  description = "The account of the thing."
}

data "aws_iot_endpoint" "iot_endpoint" {
  endpoint_type = "iot:Data-ATS"
}

# You can use these endpoints to perform the operations in 
# the AWS IoT API Reference. The endpoints in the following 
# sections are different from the device endpoints, 
# which provide devices an MQTT publish/subscribe interface 
# and a subset of the API operations.
output "iot_endpoint" {
  value = data.aws_iot_endpoint.iot_endpoint.endpoint_address
}

data "http" "root_ca" {
  url = "https://www.amazontrust.com/repository/AmazonRootCA1.pem"
}


# Purpose: Certificate Authority (CA) certificates are used to verify 
# the authenticity of the device certificate. 
# They help establish a chain of trust from the device certificate to 
# a trusted root CA.
# 
# How to use: CA certificates are installed on the device and on AWS IoT. 
# When the device connects to AWS IoT Core, AWS uses these CA certificates 
# to validate the device's certificate.
output "root_ca_cert" {
  value       = data.http.root_ca.response_body
  description = "Certificate Authority (CA) certificates are used to verify the authenticity of the device certificate."
}

# Simple name to identify the device (thing).
output "device_name" {
  value       = aws_iot_thing.thing.name
  description = "Simple name to identify the device (thing)."
}


# Device Certificate:

# This certificate is used to uniquely identify each device (thing) 
# in AWS IoT. It acts as an identity for the device, ensuring that 
# only authorized devices can connect and communicate with AWS IoT Core.
output "device_cert" {
  value       = tls_self_signed_cert.cert.cert_pem
  description = "Used to uniquely identify each device (thing) in AWS IoT"
}


# Device Private Key:

# Purpose: The private key is used in conjunction with 
# the device's certificate to create a digital signature. 
# This signature is essential to the TLS authentication process, 
# ensuring that communications between the device and 
# AWS IoT Core are secure and verified.
# 
# How it is used: The private key must be kept secret and stored 
# securely on the device. It is used during the TLS handshake 
# process to prove that the device possesses the private key 
# corresponding to the certificate presented.
output "private_key_pem" {
  value       = tls_private_key.key.private_key_pem
  description = "This signature is essential to the TLS authentication process. Keep it secret and store it securely on the device."
  sensitive   = true
}

# Device Public Key:

# Authentication: The public key certificate is used to authenticate 
# the device to AWS IoT Core. When a device establishes a connection 
# to AWS IoT, it presents its certificate. 
# AWS IoT Core verifies this certificate against the known CA to 
# confirm the identity of the device.
output "public_key_pem" {
  value       = tls_private_key.key.public_key_pem
  description = "The public key certificate is used to authenticate the device to AWS IoT Core."
}
