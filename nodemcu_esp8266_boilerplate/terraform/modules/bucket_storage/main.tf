

# ------------------------------
# Rules
# ------------------------------
# The following policy grants the device permission to store
# data in the S3 bucket.

resource "aws_iam_policy" "iot_s3_writer_policy" {
  name = "IoTS3WriterPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:iot:${var.thing_region}:${var.thing_account}:topic/${var.thing_name}/*"
      }
    ]
    },

  )
}

resource "aws_iam_role" "iot_role" {
  name = "IoTS3Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "iot.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "iot_policy_attachment" {
  role       = aws_iam_role.iot_role.name
  policy_arn = aws_iam_policy.iot_s3_writer_policy.arn
}


resource "aws_s3_bucket" "iot_storage_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_ownership_controls" "iot_storage_bucket_ownership_controls" {
  bucket = aws_s3_bucket.iot_storage_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# TODO - Enhance Bucket ACL to be more restrictive
resource "aws_s3_bucket_public_access_block" "iot_storage_bucket_ablock" {
  bucket = aws_s3_bucket.iot_storage_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# TODO - Enhance Bucket ACL to be more restrictive
resource "aws_s3_bucket_acl" "iot_storage_bucket_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.iot_storage_bucket_ownership_controls,
    aws_s3_bucket_public_access_block.iot_storage_bucket_ablock,
  ]

  bucket = aws_s3_bucket.iot_storage_bucket.id
  acl    = "public-read"
}

# TODO - Review Bucket Lifecycle Policies
resource "aws_s3_bucket_lifecycle_configuration" "iot_storage_bucket_lifecycle" {
  bucket = aws_s3_bucket.iot_storage_bucket.id

  rule {
    id     = "transition_to_ia_then_glacier"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 365
      storage_class = "GLACIER"
    }
  }

  rule {
    id = "tmp_expiration"

    filter {
      prefix = "tmp/"
    }

    expiration {
      days = abs(500)
    }

    status = "Enabled"
  }
}


# Define an AWS IoT Topic Rule to store the data in S3 to be ingested 
# later.
resource "aws_iot_topic_rule" "rule" {
  name        = replace("${var.thing_name}-s3-writer-rule", "/[^0-9A-Za-z_]/", "")
  description = "S3 Writer Rule"
  enabled     = true
  sql         = "SELECT * FROM 'topic/${var.thing_name}/*'"
  sql_version = "2016-03-23"


  s3 {

    bucket_name = aws_s3_bucket.iot_storage_bucket.id
    canned_acl  = "public-read"
    key         = "${var.thing_name}/${timestamp()}"
    role_arn    = aws_iam_role.iot_role.arn
  }

}
