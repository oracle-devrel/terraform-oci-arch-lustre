## Deploy module with the network created within into module
This is an example of how to deploy the arch-lustre module with network cloud infrastrucutre elements created within the module.
  
### Using this example
Update terraform.tfvars with the required information.

### Deploy the module
Initialize Terraform:
```
$ terraform init
```
View what Terraform plans do before actually doing it:
```
$ terraform plan
```

Create a `terraform.tfvars` file, and specify the following variables:

```
# Authentication
tenancy_ocid         = "<tenancy_ocid>"
user_ocid            = "<user_ocid>"
fingerprint          = "<finger_print>"
private_key_path     = "<pem_private_key_path>"

# Region
region = "<oci_region>"

# Compartment
compartment_ocid = "<compartment_ocid>"

```

Use Terraform to Provision resources:
```
$ terraform apply
```
### Destroy the module 

Use Terraform to destroy resources:
```
$ terraform destroy -auto-approve
```
