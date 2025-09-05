init:
	terraform -chdir=. init

plan:
	terraform -chdir=. plan -var-file=env/dev.tfvars

apply:
	terraform -chdir=. apply -auto-approve -var-file=env/dev.tfvars

destroy:
	terraform -chdir=. destroy -auto-approve -var-file=env/dev.tfvars
