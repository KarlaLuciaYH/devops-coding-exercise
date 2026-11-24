#!/usr/bin/env bash
# Builds build/lambda.zip (Linux-compatible deps + api/ code) for Terraform.
set -euo pipefail
cd "$(dirname "$0")/.."

rm -rf build && mkdir -p build/pkg
pip install --quiet --target build/pkg \
  --platform manylinux2014_x86_64 --only-binary=:all: --python-version 3.12 \
  fastapi==0.112.2 pydantic==2.8.2 pydantic-settings==2.4.0 pymongo==4.8.0 \
  python-dotenv==1.0.1 mangum==0.17.0
# Code imports both `api.*` (package) and top-level `main`/`flights`
cp -R api build/pkg/api
cp -R api/. build/pkg/
(cd build/pkg && zip -qr ../lambda.zip . -x '*__pycache__*' 'tests/*' '.env*')
echo "Built build/lambda.zip"
