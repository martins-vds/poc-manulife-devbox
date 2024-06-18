param devCenterName string
param location string
param vnetResourceGroupName string
param subnetId string

var deployVnet = false

resource devCenter 'Microsoft.DevCenter/devcenters@2024-05-01-preview' = {
  name: devCenterName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    projectCatalogSettings: {
      catalogItemSyncEnableStatus: 'Enabled'
    }
    networkSettings: {
      microsoftHostedNetworkEnableStatus: 'Disabled'
    }
  }

  resource defaultGallery 'galleries' existing = {
    name: 'Default'
  }
}

resource devCenterDevBoxDefinition 'Microsoft.DevCenter/devcenters/devboxdefinitions@2024-05-01-preview' = {
  parent: devCenter
  name: 'vs-2022-enterprise-win-11-enterprise'
  location: location
  properties: {
    imageReference: {
      id: '${devCenter::defaultGallery.id}/images/microsoftvisualstudio_visualstudioplustools_vs-2022-ent-general-win11-m365-gen2'
    }
    sku: {
      name: 'general_i_8c32gb256ssd_v2'
    }
    hibernateSupport: 'Enabled'
  }
}

resource devCenterDefaultCatalog 'Microsoft.DevCenter/devcenters/catalogs@2024-05-01-preview' = {  
  parent: devCenter
  name: 'msft-quickstart-catalog'
  properties: {
     gitHub: {
      uri: 'https://github.com/microsoft/devcenter-catalog.git'
      branch: 'main'
      path: 'Environment-Definitions'
     }
     syncType: 'Scheduled'
  }
}

resource networkConnection 'Microsoft.DevCenter/networkConnections@2024-05-01-preview' = if (deployVnet) {
  name: '${devCenterName}-network-connection'
  location: location
  properties: {
    domainJoinType: 'AzureADJoin'
    networkingResourceGroupName: '${vnetResourceGroupName}-devbox-networking'
    subnetId: subnetId
  }
}

resource attachedNetwork 'Microsoft.DevCenter/devcenters/attachednetworks@2024-05-01-preview' = if (deployVnet) {
  parent: devCenter
  name: 'default-attached-network'
  properties: {
    networkConnectionId: networkConnection.id
  }
}

resource devCenterDefaultEnvironmentDefinition 'Microsoft.DevCenter/devcenters/environmentTypes@2024-05-01-preview' = {
  parent: devCenter
  name: 'sandbox'
  properties: {
    displayName: 'Sandbox'    
  }
}

// Projects
resource devCenterDefaultProject 'Microsoft.DevCenter/projects@2024-05-01-preview' = {
  name: '${devCenterName}-default-project'
  location: location
  properties: {
    devCenterId: devCenter.id
    maxDevBoxesPerUser: 1
    catalogSettings: {
      catalogItemSyncTypes: [
        'EnvironmentDefinition'
      ]
    }    
  }  
}

output principalId string = devCenter.identity.principalId
