# terraform-oci-arch-lustre

This Terraform template deploys [Lustre](http://lustre.org/) on [Oracle Cloud Infrastructure (OCI)](https://cloud.oracle.com/en_US/cloud-infrastructure) on Bare metal or VM compute shapes (Standard or DenseIO) using local NVMe SSDs (for scratch file system) or OCI Block Volume Storage (for persistent file system).  Bare metal compute shapes with two physical NICs (2x25Gbps or 2x50Gbps)  are recommended for file servers to get maximum IO throughput performance.   

The template deploys MGS, MGS and OSS on separate compute nodes. It supports multiple MDS and OSS nodes.  

OCI offers many compute shapes and storage offerings, reach out for OCI HPC team member (pinkesh.valdria@oracle.com) for guidance on which OCI compute shapes, storage to use and architecting Lustre on OCI for optimal performance.  

For details of the architecture, see [_Deploy a scalable, distributed file system using Lustre_](https://docs.oracle.com/en/solutions/deploy-lustre-fs/index.html)

## Architecture Diagram

![](./images/lustre-oci.png)
 
## Deploy Using Oracle Resource Manager

1. Click [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?region=home&zipUrl=https://github.com/oracle-devrel/terraform-oci-arch-lustre/releases/latest/download/terraform-oci-arch-lustre-stack-latest.zip)

    If you aren't already signed in, when prompted, enter the tenancy and user credentials.

2. Review and accept the terms and conditions.

3. Select the region where you want to deploy the stack.

4. Follow the on-screen prompts and instructions to create the stack.

5. After creating the stack, click **Terraform Actions**, and select **Plan**.

6. Wait for the job to be completed, and review the plan.

    To make any changes, return to the Stack Details page, click **Edit Stack**, and make the required changes. Then, run the **Plan** action again.

7. If no further changes are necessary, return to the Stack Details page, click **Terraform Actions**, and select **Apply**. 

## Deploy Using the Terraform CLI

### Clone the Repository
Now, you'll want a local copy of this repo.  You can make that with the commands:

    git clone https://github.com/oracle-devrel/terraform-oci-arch-lustre.git
    cd terraform-oci-arch-lustre/
    ls

### Prerequisites
First off, you'll need to do some pre-deploy setup.  That's all detailed [here](https://github.com/cloud-partners/oci-prerequisites).

Secondly, create a `terraform.tfvars` file and populate with the following information:

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

# Availablity Domain 
ad_number = <ad_number> # for example 0 for the first AD in the region.

# or...
ad_name = <ad_name>   # for example "GrCH:US-ASHBURN-AD-1"

````    

## Update variables.tf file (optional)
This is optional, but you can update the variables.tf to change compute shapes, block volumes, etc. 

### Create the Resources
Run the following commands:

    terraform init
    terraform plan
    terraform apply

### Destroy the Deployment
When you no longer need the deployment, you can run this command to destroy the resources:

    terraform destroy

## Deploy as a Module
It's possible to utilize this repository as remote module, providing the necessary inputs:

```
module "terraform-oci-arch-lustre" {
  source                        = "github.com/oracle-devrel/terraform-oci-arch-lustre"
  tenancy_ocid                  = "<tenancy_ocid>"
  user_ocid                     = "<user_ocid>"
  fingerprint                   = "<finger_print>"
  private_key_path              = "<private_key_path>"
  region                        = "<oci_region>"
  compartment_ocid              = "<compartment_ocid>"
  ad_number                     = 0
  use_existing_vcn              = true # You can inject your own VCN and subnets 
  vcn_id                        = oci_core_virtual_network.my_vcn.id
  bastion_subnet_id             = oci_core_subnet.my_pub_subnet.id
  storage_subnet_id             = oci_core_subnet.my_priv_storage_subnet.id
  fs_subnet_id                  = oci_core_subnet.my_priv_fs_subnet.id
}
```

For the module's usage check the code examples below:
* [Usage of the existing network](examples/remote-module-existing-network) deploys the configuration with the VCN and Subnets provisioned outside of the module and injected into module
* [Network provisioned by the module](examples/remote-module-no-existing-network) deploys the configuration including VCN and Subnets.

## Contributing
This project is open source.  Please submit your contributions by forking this repository and submitting a pull request!  Oracle appreciates any contributions that are made by the open source community.

## Attribution & Credits
Initially, this project was created and distributed in [GitHub Oracle QuickStart space](https://github.com/oracle-quickstart). For that reason, we would like to thank all the involved contributors enlisted below:
- Pinkesh Valdria (https://github.com/pvaldria)
- mahajanarun (https://github.com/mahajanarun)
- Lukasz Feldman (https://github.com/lfeldman) 
- Ben Lackey (https://github.com/benofben)

## License
Copyright (c) 2022 Oracle and/or its affiliates.

Licensed under the Universal Permissive License (UPL), Version 1.0.

See [LICENSE](LICENSE) for more details.
