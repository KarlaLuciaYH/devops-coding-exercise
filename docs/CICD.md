# CI/CD Pipeline

Target cloud: **Google Cloud Run** (container image stored in **Artifact Registry**).

## Workflows

### `.github/workflows/ci-cd.yml`
Triggers: push to `main`, pull requests targeting `main`.

| Job | Runs on | What it does |
|-----|---------|--------------|
| `test` | push + PR | Installs dependencies, runs `pytest` in `api/`, verifies the Docker image builds |
| `deploy` | push to `main` only, after `test` passes | Builds & pushes image (tagged with commit SHA and `latest`), deploys a new Cloud Run revision, smoke-tests `GET /` (expects `204`) |

PRs only build and test; nothing is deployed. The `deploy` job uses the `production` GitHub Environment (add required reviewers there for manual approval if desired).

### `.github/workflows/rollback.yml` (bonus)
Manual (`Actions → Rollback → Run workflow`). Every deploy creates an immutable Cloud Run revision, so rollback just shifts 100% of traffic to an older one.

- `revision` input (optional): name of the revision, e.g. `flights-api-00012-abc`. List them with `gcloud run revisions list --service <service> --region <region>`.
- If empty, it rolls back to the most recent revision that is not currently serving.
- Ends with a liveness smoke test.

Note: a later deploy sends traffic to the newest revision again, so re-roll back or fix forward after a rollback.

## Secrets (Settings → Secrets and variables → Actions)

| Name | Type | Description |
|------|------|-------------|
| `GCP_SA_KEY` | Secret | JSON key of a service account with roles `Cloud Run Admin`, `Artifact Registry Writer`, `Service Account User`, and `Secret Manager Secret Accessor` (prefer Workload Identity Federation in production) |

## Variables

| Name | Description | Example |
|------|-------------|---------|
| `GCP_PROJECT_ID` | GCP project | `my-project` |
| `GCP_REGION` | Region for Cloud Run and Artifact Registry | `us-central1` |
| `AR_REPOSITORY` | Artifact Registry Docker repo (must exist) | `flights` |
| `CLOUD_RUN_SERVICE` | Cloud Run service name | `flights-api` |
| `MONGO_DB_NAME` | Mongo database name for the app | `flights` |
| `MONGO_URI_SECRET_NAME` | Secret Manager secret that holds the `MONGO_URI` connection string | `flights-mongo-uri` |

## Application environment variables

| Name | Where it comes from |
|------|--------------------|
| `MONGO_URI` | Secret Manager (`MONGO_URI_SECRET_NAME`), mounted on Cloud Run |
| `MONGO_DB_NAME` | Repo variable, set on deploy |
| `PORT` | Injected by Cloud Run; used by the `Dockerfile` |

In CI tests, dummy `MONGO_URI`/`MONGO_DB_NAME` values are set in the workflow because the tests use `mongomock` but settings require them.

## One-time setup

```bash
gcloud services enable run.googleapis.com artifactregistry.googleapis.com secretmanager.googleapis.com
gcloud artifacts repositories create flights --repository-format=docker --location=us-central1
printf 'mongodb+srv://...' | gcloud secrets create flights-mongo-uri --data-file=-
```
Grant the Cloud Run runtime service account `Secret Manager Secret Accessor` on that secret.
