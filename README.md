# IBM Cloud Database on top of IBM Cloud Satellite location on VPC using Terraform

> Estimated duration: 2+ hours

The `install-icd.sh` script will provision

* an IBM Cloud Satellite location
* an IBM Cloud VPC with 9 hosts
* an IBM Cloud Database (ICD) instance in this location that uses VPC block storage.

## Pre-requisites

* IAM API key with full access to Satellite, ICD services, VPC infrastructure and VPC block storage
* a working Terraform installation

### IBM Cloud API key

The script expects the API key in `TF_VAR_ibmcloud_api_key`, e.g. run 

```sh
export TF_VAR_ibmcloud_api_key=<API key>
```

before executing the `install-icd.sh` script.

### IBM Cloud VPC SSH key

Create an SSH key in IBM Cloud VPC named `<ssh key name>`. You need one in each region you want to provision to. For the example below make sure you've at least created one in us-east!

### Create terraform input variable file

Create a file named `<location name>.tfvars` (substitute your desired location name) in the root directory of the repo (same directory as `install-icd.sh` script). This file
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

```sh
terraform init
```

Then trigger the installation script by running

```sh
./install-icd.sh <location name> <ICD service name> <pg-instance-name>
```

For example,

```sh
./install-icd.sh my-demo-location databases-for-postgresql pg-test-instance-for-demo
```

## Post Installation

Once all the components have been installed successfully, the [Resources list](http://cloud.ibm.com/resources) will be similar to

![resources](images/ibmcloud-resources.png)

The [Satellite Location](https://cloud.ibm.com/satellite/locations) console will be similar to

![hosts](images/sat-hosts.png)

![service](images/sat-service.png)
