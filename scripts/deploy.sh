# Usage: ./deploy.sh <resource-group-name>

resourceGroupName="$1"

if [ -z "$resourceGroupName" ]; then
    echo "Resource group name is required"
    exit 1
fi

uniqueness=$(date +%s)
deploymentName="devbox-deployment-$uniqueness"

# Check if the resource group exists
az group show -n $resourceGroupName > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "Resource group $resourceGroupName does not exist"
    exit 1
fi

# Lint the Bicep file
az bicep build ./infra/main.bicep

# Validate and deploy the Bicep file
az deployment group validate -n $deploymentName -g $resourceGroupName --template-file ./infra/main.bicep
az deployment group create -n $deploymentName -g $resourceGroupName --template-file ./infra/main.bicep --rollback-on-error