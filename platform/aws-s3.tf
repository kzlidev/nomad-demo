resource "aws_s3_bucket" "my_bucket" {
  bucket = "${var.prefix}-nomad-bucket"
}

resource "aws_s3_bucket_object" "file_upload" {
  bucket = aws_s3_bucket.my_bucket.bucket
  key    = "update-certificate-store.sh"
  source = "${path.module}/script/update-certificate-store.sh"
}