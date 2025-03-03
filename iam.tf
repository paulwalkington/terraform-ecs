resource "aws_iam_policy" "get_secrets_access" {
 name = "get_secrets_access"

 policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "secretsmanager:GetSecretValue"
            ],
            "Resource": [
                "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:*"
            ],
            "Effect": "Allow"
        },
        {
            "Action": [
                "ssm:GetParameters"
            ],
            "Resource": [
              "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/*"
            ]
            "Effect": "Allow"
        }
    ]
})
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role"
 
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_policy" "rds_full_access" {
 name = "rds_full_access"

 policy = jsonencode({
   Version = "2012-10-17"
   Statement = [{
     Effect = "Allow"
     Action = [
       "rds:*"
     ]
     Resource = "*"
   }]
 })
}

resource "aws_iam_role" "ecs_task_role" {
  name = "ecs_task_role"
 
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }

 ]
}
EOF
}
 
resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
resource "aws_iam_role_policy_attachment" "ecs-task-execution-get-secrets-access-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.get_secrets_access.arn
}


resource "aws_iam_role_policy_attachment" "task_s3" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "rds_full_access_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.rds_full_access.arn
}

data "aws_iam_policy_document" "ecs_auto_scale_role" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["application-autoscaling.amazonaws.com"]
    }
  }
}

# ECS auto scale role
resource "aws_iam_role" "ecs_auto_scale_role" {
  name               = var.ecs_auto_scale_role_name
  assume_role_policy = data.aws_iam_policy_document.ecs_auto_scale_role.json
}

# ECS auto scale role policy attachment
resource "aws_iam_role_policy_attachment" "ecs_auto_scale_role" {
  role       = aws_iam_role.ecs_auto_scale_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
}