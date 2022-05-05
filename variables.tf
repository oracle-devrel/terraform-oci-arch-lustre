## Copyright (c) 2022, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# Variables required by the OCI Provider only when running Terraform CLI with standard user based Authentication
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}

variable "release" {
  description = "Reference Architecture Release (OCI Architecture Center)"
  default     = "1.2"
}

variable "vpc_cidr" { default = "10.0.0.0/16" }

/*
Do not change fs_name value.
*/
variable "fs_name" { default = "Lustre" }
# Scratch or Persistent
variable "fs_type" { default = "Persistent" }
# Valid values:  Large Files, Small Files,  Mixed.  Select Mixed, if your workload generates a lot of Small files and Large files and you want to optimize filesystem cluster for both.  Small Files (Random IO),  Large Files (Sequential IO).
variable "fs_workload_type" { default = "Large Files" }


variable "bastion_shape" { default = "VM.Standard2.1" }
variable "bastion_flex_shape_ocpus" { default = 1 }
variable "bastion_flex_shape_mem" { default = 1 }
variable "bastion_node_count" { default = 1 }
variable "bastion_hostname_prefix" { default = "bastion-" }


# DO NOT CHANGE - Management Server settings. If required, you can change shape to another Standard Compute shape.  
# Management (MGS) Server nodes variables VM.Standard2.1 / VM.DenseIO2.8
variable "management_server_shape" { default = "VM.Standard2.1" }
variable "management_server_flex_shape_ocpus" { default = 2 }
variable "management_server_flex_shape_mem" { default = 15 }
variable "management_server_node_count" { default = 1 }
variable "management_server_disk_count" { default = 1 }
variable "management_server_disk_size" { default = 50 }
# Block volume elastic performance tier. See https://docs.cloud.oracle.com/en-us/iaas/Content/Block/Concepts/blockvolumeelasticperformance.htm for more information.
variable "management_server_disk_perf_tier" { default = "Balanced" }
variable "management_server_hostname_prefix" { default = "mgs-server-" }



# BeeGFS Metadata (MDS) Server nodes variables
variable "persistent_metadata_server_shape" { default = "VM.Standard2.8" }
variable "persistent_metadata_server_flex_shape_ocpus" { default = 8 }
variable "persistent_metadata_server_flex_shape_mem" { default = 120 }
variable "scratch_metadata_server_shape" { default = "VM.DenseIO2.8" }
variable "metadata_server_node_count" { default = 1 }
# if disk_count > 1, then it create multiple MDS instance, each with 1 disk as MDT for optimal performance. If node has both local nvme ssd and block storage, block storage volumes will be ignored.
variable "metadata_server_disk_count" { default = 1 }
variable "metadata_server_disk_size" { default = 400 }
# Block volume elastic performance tier. See https://docs.cloud.oracle.com/en-us/iaas/Content/Block/Concepts/blockvolumeelasticperformance.htm for more information.
variable "metadata_server_disk_perf_tier" { default = "Higher Performance" }
variable "metadata_server_hostname_prefix" { default = "metadata-server-" }



# BeeGFS Stoarage/Object (OSS) Server nodes variables
variable "persistent_storage_server_shape" { default = "VM.Standard2.24" }
variable "persistent_storage_server_flex_shape_ocpus" { default = 24 }
variable "persistent_storage_server_flex_shape_mem" { default = 320 }
variable "scratch_storage_server_shape" { default = "VM.DenseIO2.24" }
variable "storage_server_node_count" { default = 2 }
variable "storage_server_hostname_prefix" { default = "storage-server-" }

# Client nodes variables
variable "client_node_shape" { default = "VM.Standard2.4" }
variable "client_node_flex_shape_ocpus" { default = 4 }
variable "client_node_flex_shape_mem" { default = 60 }
variable "client_node_count" { default = 1 }
variable "client_node_hostname_prefix" { default = "client-" }



# FS related variables
# Default file stripe size (aka chunk_size) used by clients to striping file data and send to desired number of storage targets (OSTs). Example: 1m, 512k, 2m, etc
variable "stripe_size" { default = "1m" }
variable "mount_point" { default = "/mnt/fs" }


# This is currently used for the deployment.  
variable "ad_number" {
  default = "-1"
}


variable "storage_tier_1_disk_perf_tier" {
  default     = "Higher Performance"
  description = "Select block volume storage performance tier based on your performance needs. Valid values are Higher Performance, Balanced, Lower Cost"
}

variable "storage_tier_1_disk_count" {
  default     = "6"
  description = "Number of block volume disk per file server. Each attached as JBOD (no RAID)."
}

variable "storage_tier_1_disk_size" {
  default     = "800"
  description = "Select size in GB for each block volume/disk, min 50."
}


################################################################
## Variables which in most cases do not require change by user
################################################################

variable "scripts_directory" { default = "scripts" }

variable "tenancy_ocid" {}
variable "region" {}
#variable "user_ocid" { default = "" }
#variable "fingerprint" { default = "" }
#variable "private_key_path" { default = "" }


variable "compartment_ocid" {
  description = "Compartment where infrastructure resources will be created"
}

variable "ssh_user" { default = "opc" }


locals {
  management_server_dual_nics                       = (length(regexall("^BM", var.management_server_shape)) > 0 ? true : false)
  metadata_server_dual_nics                         = (length(regexall("^BM", local.derived_metadata_server_shape)) > 0 ? true : false)
  storage_server_dual_nics                          = (length(regexall("^BM", local.derived_storage_server_shape)) > 0 ? true : false)
  storage_server_hpc_shape                          = (length(regexall("HPC2", local.derived_storage_server_shape)) > 0 ? true : false)
  metadata_server_hpc_shape                         = (length(regexall("HPC2", local.derived_metadata_server_shape)) > 0 ? true : false)
  management_server_hpc_shape                       = (length(regexall("HPC2", var.management_server_shape)) > 0 ? true : false)
  storage_subnet_domain_name                        = join("", [data.oci_core_subnet.private_storage_subnet.dns_label, ".", data.oci_core_vcn.hfs.dns_label, ".oraclevcn.com"])
  filesystem_subnet_domain_name                     = join("", [data.oci_core_subnet.private_fs_subnet.dns_label, ".", data.oci_core_vcn.hfs.dns_label, ".oraclevcn.com"])
  vcn_domain_name                                   = join("", [data.oci_core_vcn.hfs.dns_label, ".oraclevcn.com"])
  management_server_filesystem_vnic_hostname_prefix = join("", [var.management_server_hostname_prefix, "fs-vnic-"])
  metadata_server_filesystem_vnic_hostname_prefix   = join("", [var.metadata_server_hostname_prefix, "fs-vnic-"])
  storage_server_filesystem_vnic_hostname_prefix    = join("", [var.storage_server_hostname_prefix, "fs-vnic-"])

  # If ad_number is non-negative use it for AD lookup, else use ad_name.
  # Allows for use of ad_number in TF deploys, and ad_name in ORM.
  # Use of max() prevents out of index lookup call.
  ad = var.ad_number >= 0 ? lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[max(0, var.ad_number)], "name") : var.ad_name

}

# Not used for normal terraform apply, added for ORM deployments.
variable "ad_name" {
  default = ""
}

variable "volume_attach_device_mapping" {
  type = map(string)
  default = {
    "0"  = "/dev/oracleoci/oraclevdb"
    "1"  = "/dev/oracleoci/oraclevdc"
    "2"  = "/dev/oracleoci/oraclevdd"
    "3"  = "/dev/oracleoci/oraclevde"
    "4"  = "/dev/oracleoci/oraclevdf"
    "5"  = "/dev/oracleoci/oraclevdg"
    "6"  = "/dev/oracleoci/oraclevdh"
    "7"  = "/dev/oracleoci/oraclevdi"
    "8"  = "/dev/oracleoci/oraclevdj"
    "9"  = "/dev/oracleoci/oraclevdk"
    "10" = "/dev/oracleoci/oraclevdl"
    "11" = "/dev/oracleoci/oraclevdm"
    "12" = "/dev/oracleoci/oraclevdn"
    "13" = "/dev/oracleoci/oraclevdo"
    "14" = "/dev/oracleoci/oraclevdp"
    "15" = "/dev/oracleoci/oraclevdq"
    "16" = "/dev/oracleoci/oraclevdr"
    "17" = "/dev/oracleoci/oraclevds"
    "18" = "/dev/oracleoci/oraclevdt"
    "19" = "/dev/oracleoci/oraclevdu"
    "20" = "/dev/oracleoci/oraclevdv"
    "21" = "/dev/oracleoci/oraclevdw"
    "22" = "/dev/oracleoci/oraclevdx"
    "23" = "/dev/oracleoci/oraclevdy"
    "24" = "/dev/oracleoci/oraclevdz"
    "25" = "/dev/oracleoci/oraclevdaa"
    "26" = "/dev/oracleoci/oraclevdab"
    "27" = "/dev/oracleoci/oraclevdac"
    "28" = "/dev/oracleoci/oraclevdad"
    "29" = "/dev/oracleoci/oraclevdae"
    "30" = "/dev/oracleoci/oraclevdaf"
    "31" = "/dev/oracleoci/oraclevdag"
  }
}

variable "volume_type_vpus_per_gb_mapping" {
  type = map(string)
  default = {
    "Higher Performance" = "20"
    "Balanced"           = "10"
    "Lower Cost"         = "0"
    "None"               = "-1"
  }
}

/*
#-------------------------------------------------------------------------------------------------------------
# Marketplace variables
# hpc-filesystem-BeeGFS-OL77_3.10.0-1062.9.1.el7.x86_64
# ------------------------------------------------------------------------------------------------------------
variable "mp_listing_id" {
  default = "ocid1.appcataloglisting.oc1..aaaaaaaajmdokvtzailtlchqxk7nai45fxar6em7dfbdibxmspjsvs4uz3uq"
}
variable "mp_listing_resource_id" {
  default = "ocid1.image.oc1..aaaaaaaacnodhlnuidkvnlvu3dpu4n26knkqudjxzfpq3vexi7cobbclmbxa"
}
variable "mp_listing_resource_version" {
 default = "1.0"
}

variable "use_marketplace_image" {
  default = true
}
# ------------------------------------------------------------------------------------------------------------
*/

#-------------------------------------------------------------------------------------------------------------
# Marketplace variables
# Oracle Linux RHCK 7.9 Image for HPC filesystem
# hpc-filesystem-Oracle-Linux-7.9-2021.04.09-0-K3.10.0-1160.21.1.el7.x86_64-noselinux
# ------------------------------------------------------------------------------------------------------------

variable "mp_listing_id" {
  default = "ocid1.appcataloglisting.oc1..aaaaaaaa566vc2hugxw2ia2d5bj46a23wul5sk45aka3qs22d5qyjc7ifzja"
}
variable "mp_listing_resource_id" {
  default = "ocid1.image.oc1..aaaaaaaaxu7ah2adlodko6plfg72yqwaxafiz3wpzmhlcpvpyuen4mrqs6cq"
}
variable "mp_listing_resource_version" {
  default = "1.0"
}
variable "use_marketplace_image" {
  default = true
}

variable "use_existing_vcn" {
  default = "false"
}

variable "vcn_id" {
  default = ""
}

variable "bastion_subnet_id" {
  default = ""
}

variable "storage_subnet_id" {
  default = ""
}

variable "fs_subnet_id" {
  default = ""
}

variable "create_compute_nodes" {
  default = "false"
}


# OS Images  CentOS 7.x
variable "instance_os" {
  description = "Operating system for compute instances"
  default     = "Oracle Linux"
}

variable "linux_os_version" {
  description = "Operating system version for all Linux instances"
  default     = "7.9"
}

