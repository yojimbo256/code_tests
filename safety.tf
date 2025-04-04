terraform {
  required_providers {
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "~> 15.0"
    }
  }
}

provider "gitlab" {
  token = var.gitlab_token
  base_url = "https://gitlab.mda.mil/api/v4"
}

variable "gitlab_token" {
  type        = string
  description = "GitLab personal access token"
  sensitive   = true
}

data "gitlab_group" "target" {
  full_path = "gm-tma/infrastructure"
}

data "gitlab_project" "security_policy_project" {
  path_with_namespace = "gm-tma/infrastructure/coder-templates-security-policy-project"
}

resource "gitlab_project_push_rule" "enforce_commit_style" {
  project = data.gitlab_project.security_policy_project.id

  commit_message_regex = "^(build|chore|ci|docs|feat|fix|perf|refactor|revert|style|test)(\\(\\w+\\))?!?: .+"
  deny_delete_tag      = true
  prevent_secrets      = true
}

# Optional: mock a policy trigger if GitLab Terraform support is limited
resource "null_resource" "scan_policy_hint" {
  provisioner "local-exec" {
    command = "echo 'Ensure policy YAML is committed in .gitlab/security-policies/'"
  }
}
