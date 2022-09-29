source ./iac/multi-env-cicd/one-click-setup/env.sh

if [[ ! -e iac/one-click-setup/00-one-click-setup.sh ]]; then
    echo >&2 "Please run this script from Git repository root."
    exit 1
fi

if [[ -z "${PROJECT_ID}" ]]; then
    echo >&2 "Please set \$PROJECT_ID environment variable in './iac/multi-env-cicd/one-click-setup/env.sh'"
    exit 1
fi

if [[ -z "${REGION}" ]]; then
    echo >&2 "Please set \$REGION environment variable in './iac/multi-env-cicd/one-click-setup/env.sh'"
    exit 1
fi

if [[ -z "${ZONE}" ]]; then
    echo >&2 "Please set \$ZONE environment variable in './iac/multi-env-cicd/one-click-setup/env.sh'"
    exit 1
fi

if [[ -z "${GITHUB_REPO_OWNER}" ]]; then
    echo >&2 "Please set \$GITHUB_REPO_OWNER environment variable in './iac/multi-env-cicd/one-click-setup/env.sh'"
    exit 1
fi

set -Eeuxo pipefail

echo "PROJECT_ID=$PROJECT_ID"
echo "REGION=$REGION"
echo "ZONE=$ZONE"
echo "GITHUB_REPO_OWNER=$GITHUB_REPO_OWNER"

gcloud config set project $PROJECT_ID

./iac/multi-env-cicd/one-click-setup/01-patch-acm-config.sh
./iac/multi-env-cicd/one-click-setup/02-terraform.sh
./iac/multi-env-cicd/one-click-setup/03-wait-for-asm.sh
./iac/multi-env-cicd/one-click-setup/04-init-cloud-sql.sh
./iac/multi-env-cicd/one-click-setup/05-trigger-cicd.sh
