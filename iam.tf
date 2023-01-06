# Iam role allowing access to the s3 bucket to cp the java rpm

resource "aws_iam_role" "tomcat_ec2" {
  name = "tomcat_iam"

  assume_role_policy = <<EOF
{
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "tomcat_s3" {
  name = "tomcat_s3"
  role = "${aws_iam_role.tomcat_ec2.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
            "Resource": [
                "arn:aws:s3:::${var.s3bucket}",
                "arn:aws:s3:::${var.s3bucket}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:PutObjectAcl",
                "s3:GetObject",
                "s3:GetObjectAcl",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::${var.s3bucket}",
                "arn:aws:s3:::${var.s3bucket}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_instance_profile" "tomcat_ec2_profile" {
  name = "tomcat_ec2_profile"
  role = "${aws_iam_role.tomcat_ec2.name}"
}