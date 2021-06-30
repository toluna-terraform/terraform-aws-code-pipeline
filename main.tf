locals {
  repository_name       = split("/", var.source_repository)[1]
  artifacts_bucket_name = "s3-codepipeline-${var.env_name}-${local.repository_name}"
  codepipeline_name     = "codepipeline-${var.env_name}-${local.repository_name}"
}

resource "aws_codepipeline" "codepipeline" {
  name     = local.codepipeline_name
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = var.s3_bucket
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
        ConnectionArn        = data.aws_ssm_parameter.codepipeline_connection_arn.value
        FullRepositoryId     = var.source_repository
        BranchName           = var.trigger_branch
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
        output_artifacts = ["build_output"]

        configuration = {
          ProjectName = action.value
        }

      }
    }
  }

  stage {
    name = "Deploy"
    dynamic "action" {
      for_each = var.code_deploy_applications
      content {
        name            = action.value
        category        = "Deploy"
        owner           = "AWS"
        provider        = "CodeDeployToECS"
        input_artifacts = ["build_output"]
        version         = "1"
        configuration = {
          ApplicationName = action.value
          DeploymentGroupName = "${action.value}-group"
          TaskDefinitionTemplateArtifact = "build_output"
          AppSpecTemplateArtifact = "build_output"
          AppSpecTemplatePath = "appspec.json"
          
        }
      }
    }
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name               = "${local.codepipeline_name}-role"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role_policy.json
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "codepipeline_policy"
  role   = aws_iam_role.codepipeline_role.id
  policy = data.aws_iam_policy_document.codepipeline_role_policy.json
}

