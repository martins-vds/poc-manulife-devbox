# Usage: ./deploy.sh <resource-group-name>

set -e
set -o pipefail

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
echo "linting bicep file..."
az bicep build --only-show-errors --file ./infra/main.bicep --outdir /tmp

# Validate and deploy the Bicep file
echo "validating bicep file..."
az deployment group validate --only-show-errors -n $deploymentName -g $resourceGroupName --template-file ./infra/main.bicep > /dev/null

echo "starting what-if deployment..."
az deployment group what-if --only-show-errors --no-pretty-print -n $deploymentName -g $resourceGroupName --template-file ./infra/main.bicep > /dev/null

echo "starting deployment..."
az deployment group create --only-show-errors -n $deploymentName -g $resourceGroupName --template-file ./infra/main.bicep