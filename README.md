# ICD Satellite location on VPC using Terraform
The `install-icd.sh` script will create a Satellite location, provision VPC workers,
and provision an ICD instance in this location that uses VPC block storage. 

## Pre-requisites
- IAM API key with full access to Satellite, ICD services, VPC infrastructure and VPC block storage
- a working Terraform installation

### IBM Cloud API key
The script expects the API key in `TF_VAR_ibmcloud_api_key`, e.g. run 

```
export TF_VAR_ibmcloud_api_key=<API key>
```

before executing the `install-icd.sh` script.


### IBM Cloud VPC SSH key
Create an SSH key in IBM Cloud VPC named `<ssh key name>`. You need
one in each region you want to provision to. For the example below make sure you've
at least created one in us-east!

### Create input file

Create a file named `<location name>.tfvars` (substitute your desired location name) in 
the root directory of the repo (same directory as `install-icd.sh` script). This file
should have the following content (make sure to adjust `location name`, `ssh key name`,
as well as `managed_from` & `region` if necessary.

```
location_name     = "<location name>"
is_location_exist = false
managed_from      = "wdc"
region            = "us-east"
image             = "ibm-redhat-7-9-minimal-amd64-4"
existing_ssh_key  = "<ssh key name>"

control_plane_hosts = { "name" : "cp", "count" : 3, "type" : "bx2-8x32" }
customer_hosts      = { "name" : "customer", "count" : 3, "type" : "bx2-32x128" }
internal_hosts      = { "name" : "internal", "count" : 3, "type" : "bx2-8x32" }
```

## Installation
When running for the first time, execute (in the repo root):

```
terraform init
```

Then trigger the installation script by running
```
./install-icd.sh <location name> <ICD service name> <pg-instance-name>
```

For example,

```
./install-icd.sh my-demo-location databases-for-postgresql pg-test-instance-for-demo
```
