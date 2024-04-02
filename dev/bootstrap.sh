#!/bin/bash
set -e

cwd=$(dirname "$0")
project_root=$(dirname "$cwd")
envrc_file=$project_root/.envrc.template

command -v terraform > /dev/null 2>&1 || {
  echo "Terraform is not installed. Please install Terraform first."
  exit 1
}

echo "Setting environment variables in .env file"
echo "export AWS_SECRET_ACCESS_KEY=123" > $envrc_file
echo "export AWS_ACCESS_KEY_ID=123" >> $envrc_file
echo "export AWS_DEFAULT_REGION=eu-west-1" >> $envrc_file


echo "Human things to do:"
echo "  0. cp .envrc.template .envrc"
echo "  1. Update the .envrc.template file with your AWS credentials"
echo "  2. Run 'direnv allow' to load the environment variables"
