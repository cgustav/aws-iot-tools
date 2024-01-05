

#athena.tf
resource "aws_glue_catalog_database" "iot_athena_db" {
  name = var.athena_db_name
}


resource "aws_glue_catalog_table" "iot_athena_table" {
  name          = var.athena_main_table_name
  database_name = aws_glue_catalog_database.iot_athena_db.name
  description   = "Table containing the results stored in S3 as source"


  table_type = "EXTERNAL_TABLE"

  storage_descriptor {
    location      = "s3://${var.s3_source_bucket_name}/${var.s3_source_bucket_address}"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.IgnoreKeyTextOutputFormat"


    ser_de_info {
      name                  = "s3-stream"
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"


      parameters = {
        "ignore.malformed.json" = "TRUE"
        "dots.in.keys"          = "FALSE"
        "case.insensitive"      = "TRUE"
        "mapping"               = "TRUE"
      }
    }


    dynamic "columns" {
      for_each = var.columns
      iterator = column

      content {
        name = column.value.name
        type = column.value.type
      }
    }
  }
}


resource "aws_athena_workgroup" "iot_athena_workgroup" {
  name = "iot_athena_workgroup"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${var.s3_source_bucket_name}/output/"
    }
  }
}

resource "aws_athena_named_query" "iot_athena_query" {
  name      = "standard_query"
  workgroup = aws_athena_workgroup.iot_athena_workgroup.id
  database  = aws_glue_catalog_database.iot_athena_db.name
  query     = "SELECT humidity, temperature, timestamp FROM ${aws_glue_catalog_database.iot_athena_db.name}.${aws_glue_catalog_table.iot_athena_table.name};"
}
