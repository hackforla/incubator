# The civictechindex.org production frontend. This bucket serves the live site
# directly as an S3 website -- there is no CloudFront distribution in front of it
# and it is the only S3-backed frontend in the account, so it does not resemble
# any other project here. Do not delete it.
#
# The apex A record in Route 53 is an alias to the us-west-2 S3 website endpoint.
# Ownership controls (ObjectWriter) and default encryption (AES256) are left
# unmanaged: both are set on the bucket and neither is modelled here, so
# Terraform will not touch them.

resource "aws_s3_bucket" "website" {
  bucket = "civictechindex.org"
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

  # The site is a single-page app, so a missing key serves the app rather than an
  # error page. S3 still returns 404 with it, which is expected.
  error_document {
    key = "index.html"
  }
}

# Public reads are what makes the website endpoint work. All four blocks are off
# deliberately; turning any of them on makes the site return 403.
resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicReadGetObject"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.website.arn}/*"
    }]
  })
}
