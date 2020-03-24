# Secure-AWS-architecture-Terraform
Deployment of a secure aws architecture using terraform

![Aws architecture](./archv2.png "Architecture deployed")

Please note this diagram belongs to Wavestone, created for the Wavegame contest. 

We (NoFlawsOnlyFlag) won the second test thanks to this code.

We didn't have any personal website to deploy on the servers, so the Certificate Manager is replaced by an IAM certificate on *.amazonaws.com in order to get https.

Please note that varDb.tfvars should not exist for security reasons.


Run with 

$ terraform apply -var-file="varDB.tfvars" -auto-approve
