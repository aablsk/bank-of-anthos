
SHELL := /bin/bash


show-gcs-state:
	# TODO infer variable from Makefile which is really hard.
	source terraform.tfvars ; echo "project_id=${project_id}"
	. terraform.tfvars ; echo project_id=${project_id}
	# gsutil ls gs://${project_id}-mytfstate/terraform/state/