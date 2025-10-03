# Random string for unique bucket name
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# S3 bucket for static website
resource "aws_s3_bucket" "website" {
  bucket = "cloud-cost-tracker-dashboard-${var.environment}-${random_string.bucket_suffix.result}"
}

# Upload frontend files to S3
resource "aws_s3_object" "index_html" {
  bucket = aws_s3_bucket.website.id
  key    = "index.html"
  source = "${path.module}/../frontend/index.html"
  content_type = "text/html"
}

resource "aws_s3_object" "config_js" {
  bucket = aws_s3_bucket.website.id
  key    = "config.js"
  source = "${path.module}/../frontend/config.js"
  content_type = "application/javascript"
}

# Block public access to S3 bucket
resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# S3 bucket policy for public read access
resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website.arn}/*"
      }
    ]
  })
}

# Enable S3 website hosting
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }
}