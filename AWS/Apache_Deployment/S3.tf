resource "random_id" "bucket_id" {
  byte_length = 3
}

resource "aws_s3_bucket" "S3 Bucket" {
  bucket        = "${var.apache_bucket_name}-${random_id.bucket_id.dec}"
  acl           = "private"
  force_destroy = true

  tags {
    Name = "S3 Apache Bucket"
  }
}

data = "template_file"

"S3_access_policy" {
  template = "${file("templates/s3_access_policy.tpl")}"

  vars {
    s3_ro = "${}"
    s3_rw = "${}"
  }
}
