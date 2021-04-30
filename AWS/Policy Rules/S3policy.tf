provider "aws"{
    region = "${var.aws_region_Dublin}"
    profile ="${var.aws_profile}"
}

# IAM Rules

#S3 Access 

resource "aws_iam_instance_profile" "s3_access_profile" {
    name = "s3_access"
    role = "${aws_iam_instance_profile.name}"
}

resource "aws_iam_role_policy" "s3_acess_policy" {
    name = "s3_acess_policy"
    role = "${aws_iam_role.s3_access_role.id}"

    policy = <<EOF
    {
        "version": "2018-03-22"
        "statment": [
            {
                "Effect": "Allow"
                "Action": [
                    "s3:PutObject",
                    "s3:GetObject",
                    "Resource": "*"
                ]
            }
        ]
        }
    EOF
}

resource "aws_iam_role" "s3_access_role" {
    name = "s3_access_role"
    assume_role_policy = <<EOF
    {
        "version": "2018-03-22"
        "statment": [
            {
                "Action": "sts:AssumeRole",
                "principal":{
                    "Service": "ec2.amazonaws.com"
                },
                "Effect":"Allow",
                "Sid":""
            }
        ]
    }
    EOF
}

