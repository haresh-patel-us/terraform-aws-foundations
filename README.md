# Terraform AWS Foundations

Portfolio sample: the account-level foundations I put under every workload —
remote state, baseline tagging, a default security posture, centralized
logging, and budget/alarms. Complements the `aws-eks-platform-terraform`
repo, which consumes these primitives.

## Layout

- `main.tf` — S3+DynamoDB remote-state backend, baseline tags, default
  security group posture, CloudWatch log group, SNS alarm topic, AWS budget
- `variables.tf` — account alias, region, budget limit, alert emails
- `outputs.tf` — state bucket, log group, alarm topic

## Usage

```bash
terraform init -backend-config=envs/dev.backend.hcl
terraform plan -var-file=envs/dev.tfvars
terraform apply -var-file=envs/dev.tfvars
```

## Patterns demonstrated

- Remote state with locking and versioning (state loss is unrecoverable)
- Mandatory tag policy inputs enforced at plan time
- No 0.0.0.0/0 ingress in the baseline security group
- Monthly budget with forecasted-spend alerting
- Centralized log retention with KMS encryption
