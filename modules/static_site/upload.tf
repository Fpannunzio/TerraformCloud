#Upload files of your static website
resource "aws_s3_object" "data" {
  for_each = {for f in local.file_with_type: "${f.file}.${f.mime}" => f}

  bucket = module.site_bucket.s3_bucket_id
  key    = each.value.file
  source = "${var.src}/${each.value.file}"
  etag   = filemd5("${var.src}/${each.value.file}")
  content_type = each.value.mime
}