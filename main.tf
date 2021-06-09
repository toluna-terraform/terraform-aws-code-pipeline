provider "aws" {
    region = var.aws_region
    profile = var.aws_profile
}

locals {
    repository_name = split("/",var.source_repository)[1]
    artifacts_bucket_name = "s3-codepipeline-${var.env_name}-${local.repository_name}"
    codepipeline_name = "codepipeline-${var.env_name}-${local.repository_name}"
    

}

resource "aws_codepipeline" "codepipeline" {
  name     = local.codepipeline_name
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]


      configuration = {
        ConnectionArn    = var.connection_arn
        //ConnectionArn    = var.connection_arn
        FullRepositoryId =  var.source_repository
        BranchName       = var.trigger_branch
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Build"

    dynamic "action" {
    for_each = var.code_build_projects 
    content {
      name             = action.value
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      version          = "1"

      configuration = {
        ProjectName = action.value
      }
    }
    }
  }
}


resource "aws_codestarconnections_connection" "connection" {
  name          = "${var.env_name}-${local.repository_name}-connection"
  provider_type = "Bitbucket"
}

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = local.artifacts_bucket_name
  acl    = "private"
}

resource "aws_iam_role" "codepipeline_role" {
  name = "${local.codepipeline_name}-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "codepipeline_policy"
  role = aws_iam_role.codepipeline_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObjectAcl",
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.codepipeline_bucket.arn}",
        "${aws_s3_bucket.codepipeline_bucket.arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codestar-connections:UseConnection"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}


