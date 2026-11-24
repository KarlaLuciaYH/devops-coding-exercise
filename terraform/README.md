# AWS infrastructure (Terraform)

```
Internet ── API Gateway (HTTP API) ── Lambda (FastAPI, private subnet, app SG)
                                            │ tcp/27017 (SG → SG only)
                                     MongoDB EC2 (private subnet, mongo SG)
Public subnet: NAT gateway (outbound only for the private subnet)
```

| Resource | Notes |
|---|---|
| VPC `10.0.0.0/16`, public + private subnet (same AZ) | public RT → IGW; private RT → NAT gateway |
| `app` SG | attached to Lambda; egress only to the mongo SG on 27017 |
| `mongo` SG | ingress 27017 **only** from the app SG; no SSH; egress 80/443 (install, SSM) |
| EC2 (AL2023) + MongoDB 7 | private subnet, encrypted gp3, IMDSv2, auth enabled, access via SSM Session Manager |
| API Gateway HTTP API | `$default` route → Lambda proxy; Lambda has the app SG so it can reach Mongo |
| Secrets Manager | stores the generated `MONGO_URI` |

> API Gateway cannot open TCP connections to MongoDB, so the "access" is through the Lambda running the API inside the VPC.

## Deploy

```bash
./scripts/build_lambda.sh          # builds build/lambda.zip
cd terraform
terraform init
terraform plan
terraform apply
curl -i "$(terraform output -raw api_url)"   # 204
```

Variables are in `variables.tf` (region defaults to `us-east-1`).

## Notes
- The NAT gateway costs ~$32/month; destroy when unused (`terraform destroy`).
- `MONGO_URI` (with a generated password) is a Lambda env var and lives in Terraform state; use a remote encrypted backend.
- Single EC2, single AZ, no backups: suitable for the exercise, not production.
- The existing GitHub workflows still deploy to GCP Cloud Run; migrating them to AWS is a follow-up.
