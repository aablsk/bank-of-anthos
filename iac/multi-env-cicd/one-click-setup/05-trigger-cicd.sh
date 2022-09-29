set -Eeuo pipefail

echo '🚀  Starting ./05-trigger-cicd.sh'

echo '🌈  Triggering CI/CD for Frontend team'
gcloud beta builds triggers run frontend-ci --branch main
echo '😁  Triggering CI/CD for Accounts team'
gcloud beta builds triggers run accounts-ci --branch main
echo '📒  Triggering CI/CD for Ledger team'
gcloud beta builds triggers run ledger-ci --branch main

echo '✅  Finished ./05-trigger-cicd.sh'