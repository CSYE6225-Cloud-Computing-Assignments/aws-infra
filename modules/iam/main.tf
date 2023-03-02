##IAM policy
resource "aws_iam_policy" "WebAppS3" {
  name        = "WebAppS3"
  description = "My test policy"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:ListAllMyBuckets",
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Effect": "Allow",
      "Resource": ["arn:aws:s3:::${var.created_bucket_name}/*","arn:aws:s3:::${var.created_bucket_name}"]
    }
  ]
}
EOF

}

# ##IAM policy document
# data "aws_iam_policy_document" "s3_policy" {
#   statement {
#     actions   = ["s3:*"]
#     resources = ["arn:aws:s3:::${var.created_bucket_name}"]
#     effect    = "Allow"
#   }
# }

##IAM policy attachment
resource "aws_iam_role_policy_attachment" "attachment" {
  role       = aws_iam_role.EC2_CSYE6225.name
  policy_arn = aws_iam_policy.WebAppS3.arn
}

##IAM user role
resource "aws_iam_role" "EC2_CSYE6225" {
  name               = "EC2_CSYE6225"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "EC2_CSYE6225_profile" {
  name = "EC2_CSYE6225_profile"
  role = aws_iam_role.EC2_CSYE6225.name
}


output "aws_iam_role_s3" {
  value = aws_iam_instance_profile.EC2_CSYE6225_profile.name
}
 