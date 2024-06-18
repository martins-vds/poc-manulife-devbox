param vnetName string
param location string = resourceGroup().location

resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: vnetName
  location: location

  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]      
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefixes: [
            '10.1.0.0/24'
          ]
          networkSecurityGroup: {
            id: resourceId('Microsoft.Network/networkSecurityGroups', 'nsg-default')
            location: location
            properties: {
              securityRules: []
            }
          }
        }
      }
    ]
  }
}

output resourceGroupName string = resourceGroup().name
output defaultSubnetId string = vnet.properties.subnets[0].id
