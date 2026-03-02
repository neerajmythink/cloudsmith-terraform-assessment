# Cloudsmith Terraform Assessment

## Objectives

This assessment demonstrates your understanding of Terraform state files and Cloudsmith repository management.

## Instructions

### 1. Repository Setup

- **Create 3 repositories:**  
    - `QA`  
    - `Staging`  
    - `Production`

- **Add upstreams:**  
    - `QA`: NPM and Maven  
    - `Staging`: Python  
    - `Production`: None

### 2. Team Management

- **Create 3 teams:**  
    - `Dev`  
    - `DevOps`  
    - `Admin`

- **Assign privileges:**  
    - `QA` & `Staging`: Write access for all teams  
    - `Production`:  
        - Admin: Write  
        - DevOps: Read  
        - Dev: No access

### 3. Security & Policies

- **Geo/IP Rule:**  
    - Block all traffic from Russia

- **Production Repository Settings:**  
    - Enable "replace packages" by default

- **Service Account:**  
    - Create a service account with the same permissions as the DevOps team

- **Vulnerability Policy:**  
    - Block any NPM packages with a critical security scan result

# what a terraform state file is/does

A Terraform state file is a JSON file that Terraform uses to keep track of the resources it manages. It contains information about the current state of the infrastructure, including the resources that have been created, their attributes, and their relationships. The state file allows Terraform to determine what changes need to be made to the infrastructure when you run `terraform apply`, and it helps ensure that your infrastructure remains consistent with your configuration files.

The state file is typically stored locally on your machine, but it can also be stored remotely (e.g., in an S3 bucket) for collaboration purposes. It is important to manage the state file carefully, as it contains sensitive information and can be a single point of failure if not handled properly.

## Prerequisites

- Terraform installed and configured
- Understanding of Terraform state file concepts
- Access to Cloudsmith credentials/API tokens

## Steps to create the resouces using Terraform:

1. **Create a terraform.tfvars file**: This file will contain your Cloudsmith API key and organization name as shown below:
```hcl
cloudsmith_api_key = "your_actual_api_key_here"
organization       = "your_actual_organization_name_here"
```
Make sure to replace the placeholders with your actual API key and organization name.

2. **Initialize Terraform**: Run `terraform init` to set up the working directory and download necessary providers.
3. **Plan the Deployment**: Use `terraform plan` to see the changes that will be made to your infrastructure based on the configuration files.
4. **Apply the Configuration**: Execute `terraform apply` to create the resources defined in your Terraform configuration files. Review the proposed changes and confirm to proceed with the deployment.
5. ** Verify the Resources**: After applying, check the Cloudsmith dashboard to ensure that the repositories, teams, permissions, and policies have been created as specified in the instructions.

## Reviewer Notes

- Verify that all repositories, teams, and permissions are correctly configured.
- Check that the Geo/IP rule and vulnerability policy are active.
- Confirm the service account permissions match the DevOps team.
- Ensure the production repository allows package replacement by default.

## Conclusion

This assessment tests your ability to manage Cloudsmith repositories and teams using Terraform, as well as your understanding of security policies and service accounts. Make sure to follow the instructions carefully and verify that all configurations are correctly applied.

## Key Commands for Cloudsmith Resources

- `terraform state list` - View all managed Cloudsmith resources
- `terraform state show <resource>` - Inspect specific resource details
- `terraform plan -out=tfplan` - Save execution plan for review

## State File Management

- Store state files securely (use remote backends for team collaboration)
- Never commit sensitive state files to version control
- Regular backups are essential for disaster recovery