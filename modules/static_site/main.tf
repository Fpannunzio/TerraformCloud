resource "aws_s3_bucket" "site" {
  bucket_prefix = "site"
}

resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket" "www" {
  bucket = "www.${aws_s3_bucket.site.id}"
}

resource "aws_s3_bucket_website_configuration" "www" {
  bucket = aws_s3_bucket.www.id

  redirect_all_requests_to {
    host_name = aws_s3_bucket.site.id
  }
}