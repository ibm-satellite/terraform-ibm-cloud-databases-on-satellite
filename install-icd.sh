#!/bin/bash
set -e

if [ "$#" -ne 3 ]; then
	echo 'Illegal number of parameters - format:'
	echo './install-icd.sh <location_name> <service_name> <first_instance_name>'
	echo 'e.g. ./install-icd.sh my-sat-location databases-for-postgresql first-pg-instance'
	exit 1
fi

if [[ -z $TF_VAR_ibmcloud_api_key ]]; then
	echo "Environment variable 'TF_VAR_ibmcloud_api_key' not set"
	exit 1
fi

if [ ! -f ./$1.tfvars ]
then
	echo "File './$1.tfvars' does not exist."
	exit 1
fi

location_name=$1
service_name=$2
first_instance_name=$3

region=$(cat $1.tfvars | grep region | awk '{print $3}' | tr -d '"')

ibmcloud login --apikey $TF_VAR_ibmcloud_api_key -q

resource_group_id=$(ibmcloud resource group default --id)

terraform apply -state=./statefiles/$1.tfstate -var-file=$1.tfvars

if [ $? -eq 1 ]; then
	echo "terraform apply failed - exiting..."
	exit 1;
fi

# This line needs to come *after* terraform was run otherwise the location will not exist
location_formatted=$(ibmcloud sat location get --location $location_name --output=json -q | jq -r '"satloc_" + .location + "_" + .id')

while [ "$(ibmcloud sat host ls --location ${location_name} --output=json -q | jq -c 'map(select((.name | contains("cp")))) | if (length == 3) then true else false end')" != "true" ]; do
        ibmcloud login --apikey $TF_VAR_ibmcloud_api_key -q
	echo "waiting for control plane hosts to attach to location ${location_name}..."
	sleep 30
done

echo "Three control plane hosts are attached to the location ${location_name}"

idx=1
for name in $(ibmcloud sat host ls --location $location_name -q --output=json | jq -cr 'map(select((.name | contains("cp")) and .state=="unassigned")) | .[].name')
do
	i=$(( i%3 ))
	echo $name
	ibmcloud sat host assign --location ${location_name} --zone $region-$idx --host $name
	let "idx+=1"
done


service_cluster=$(ibmcloud sat service ls --location $location_name --output=json -q | jq -rc 'map(select(.name != "Control plane"))[0] | .name')
if [ "$service_cluster" = "null" ] 
then
	while [ "$(ibmcloud sat location get --location $location_name --output=json -q | jq .deployments.enabled)" != true ]; do 
	  ibmcloud login --apikey $TF_VAR_ibmcloud_api_key -q
	  echo "waiting for control plane to finish provisioning and location reaching normal state - retrying in 30 seconds..." 
	  sleep 30
	done
fi

#
ibmcloud login --apikey $TF_VAR_ibmcloud_api_key -q
ibmcloud target -g default

service_instances=`ibmcloud resource service-instances -q --location $location_formatted --output=json`
if [ "$service_instances" = "null" ]
then
	echo "no service instances found in location ${location_formatted} - creating a new instance..."
        ibmcloud resource service-instance-create $first_instance_name $service_name standard-satellite $location_formatted
fi
echo "service instances already exist in location ${location_formatted} - not creating a new instance..."

while [ "$(ibmcloud sat service ls --location $location_name --output=json -q | jq -rc 'map(select(.name != "Control plane"))[0] | .name')" == "null" ]; do
	echo "waiting for service cluster in location ${location_name} - retrying in 30 seconds ..."
	# TODO: log into ibmcloud once in a while to avoid token expiration
	sleep 30
	ibmcloud login --apikey $TF_VAR_ibmcloud_api_key -q
done

service_cluster=$(ibmcloud sat service ls --location $location_name --output=json -q | jq -rc 'map(select(.name != "Control plane"))[0] | .name')
service_cluster_id=$(ibmcloud sat service ls --location $location_name --output=json -q | jq -rc 'map(select(.name != "Control plane"))[0] | .id')
echo "service cluster found: ${service_cluster}/${service_cluster_id}"

while [ "$(ibmcloud sat service ls --location $location_name --output=json -q | jq -rc 'map(select(.name != "Control plane"))[0] | .state')" != "normal" ]; do
	echo "waiting for 'ready' state of service cluster ${service_cluster}/${service_cluster_id} in location ${location_name} - retrying in 30 seconds ..."
	# TODO: log into ibmcloud once in a while to avoid token expiration
	sleep 30
	ibmcloud login --apikey $TF_VAR_ibmcloud_api_key -q
done

storage_config_name=vpc-for-$location_name-config
storage_assignment_name=vpc-for-$location_name-assignment

echo "creating storage configuration ${storage_config_name}..."

# TODO: Check whether these already exist to make re-running this script idempotent

ibmcloud sat storage config create --name $storage_config_name --template-name ibm-vpc-block-csi-driver --location $location_name --param "g2_token_exchange_endpoint_url=https://iam.cloud.ibm.com" --param "g2_api_key=$TF_VAR_ibmcloud_api_key" --param "g2_riaas_endpoint_url=https://$region.iaas.cloud.ibm.com" --param "g2_resource_group_id=$resource_group_id"

# echo "creating storage assignment ${storage_assignment_name}..."

ibmcloud target -r $region

ibmcloud sat storage assignment create --name $storage_assignment_name --service-cluster-id $service_cluster_id --config $storage_config_name

