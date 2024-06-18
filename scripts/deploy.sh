# Usage: ./deploy.sh <resource-group-name>

resourceGroupName="$1"

if [ -z "$resourceGroupName" ]; then
    echo "Resource group name is required"
    exit 1
fi

uniqueness=$(date +%s)
deploymentName="devbox-deployment-$uniqueness"

az deployment create -n $deploymentName -g $resourceGroupName --template-file ../infra/main.bicep