# Configure the Cloudsmith provider and create repositories, teams, service accounts, privileges, Geo/IP rules, and vulnerability policies as per the requirements.
terraform {
  required_providers {
    cloudsmith = {
      source  = "cloudsmith-io/cloudsmith"
      version = "0.0.68"
    }
  }
}

# Configure the Cloudsmith provider with the API key
provider "cloudsmith" {
  api_key = var.cloudsmith_api_key
}

# Create three repositories: QA, Staging, Production. The Production repository should have the "Replace packages by default" option enabled.
resource "cloudsmith_repository" "qa" {
  name        = "QA"
  namespace   = var.organization
  description = "QA repository created using Terraform"
}

resource "cloudsmith_repository" "staging" {
  name        = "Staging"
  namespace   = var.organization
  description = "Staging repository created using Terraform"
}

resource "cloudsmith_repository" "production" {
  name                        = "Production"
  namespace                   = var.organization
  description                 = "Production repository created using Terraform"
  replace_packages_by_default = true
}

# Add upstream to QA repository for npm and maven
resource "cloudsmith_repository_upstream" "qa_npm" {
  repository    = cloudsmith_repository.qa.slug
  namespace     = var.organization
  name          = "npm-upstream"
  upstream_type = "npm"
  upstream_url  = "https://registry.npmjs.org"
}

resource "cloudsmith_repository_upstream" "qa_maven" {
  repository    = cloudsmith_repository.qa.slug
  namespace     = var.organization
  name          = "maven-upstream"
  upstream_type = "maven"
  upstream_url  = "https://repo.maven.apache.org/maven2"
}

# Add upstream to Staging repository for python
resource "cloudsmith_repository_upstream" "staging_python" {
  repository    = cloudsmith_repository.staging.slug
  namespace     = var.organization
  name          = "python-upstream"
  upstream_type = "python"
  upstream_url  = "https://pypi.org/simple"
}

# Create 3 teams: Dev, DevOps, Admin
resource "cloudsmith_team" "dev" {
  organization = var.organization
  name         = "Dev"
  description  = "Dev team created using Terraform"
}

resource "cloudsmith_team" "devops" {
  organization = var.organization
  name         = "DevOps"
  description  = "DevOps team created using Terraform"
}

resource "cloudsmith_team" "admin" {
  organization = var.organization
  name         = "Admin"
  description  = "Admin team created using Terraform"
}

# Create a service account
resource "cloudsmith_service" "service_account" {
  organization = var.organization
  name         = "Service_Account"
  description  = "Service account created using Terraform"
}

# Assign the following privileges to repositories:

# team slugs for easy reference in the dynamic blocks
locals {
  all_teams = [
    cloudsmith_team.dev.slug,
    cloudsmith_team.devops.slug,
    cloudsmith_team.admin.slug
  ]
}

# QA: Write for all teams
resource "cloudsmith_repository_privileges" "qa_privs" {
  organization = var.organization
  repository   = cloudsmith_repository.qa.slug

  dynamic "team" {
    for_each = local.all_teams
    content {
      privilege = "Write"
      slug      = team.value
    }
  }
}

# Staging: Write for all teams
resource "cloudsmith_repository_privileges" "staging_privs" {
  organization = var.organization
  repository   = cloudsmith_repository.staging.slug

  dynamic "team" {
    for_each = local.all_teams
    content {
      privilege = "Write"
      slug      = team.value
    }
  }
}

# Production: Write for admin, Read for Devops, Dev shouldn’t have permissions and provide service account the same permissions as DevOps team.
resource "cloudsmith_repository_privileges" "production_privs" {
  organization = var.organization
  repository   = cloudsmith_repository.production.slug

  team {
    privilege = "Write"
    slug      = cloudsmith_team.admin.slug
  }

  team {
    privilege = "Read"
    slug      = cloudsmith_team.devops.slug
  }

  service {
    privilege = "Read"
    slug      = cloudsmith_service.service_account.slug
  }
}

# Create a Geo/IP rule to block all the traffic coming from Russia for all repositories
resource "cloudsmith_repository_geo_ip_rules" "block_russia" {
  for_each = {
    prod    = cloudsmith_repository.production.slug
    qa      = cloudsmith_repository.qa.slug
    staging = cloudsmith_repository.staging.slug
  }

  namespace         = var.organization
  repository        = each.value
  country_code_deny = ["RU"]
}

# Create a vulnerability policy that will block any NPM packages with a critical security scan result.
resource "cloudsmith_vulnerability_policy" "npm_critical" {
  organization            = var.organization
  name                    = "NPM Critical Policy"
  description             = "Policy to block NPM packages with critical vulnerabilities"
  min_severity            = "Critical"
  on_violation_quarantine = true
  allow_unknown_severity  = false
  package_query_string    = "format:npm"
}
