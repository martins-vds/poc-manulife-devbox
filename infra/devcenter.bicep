import { devCenterCatalogArray } from './types.bicep'

param devCenterName string
param catalogs devCenterCatalogArray = []
param location string
param vnetResourceGroupName string
param subnetId string
param deployDefaultProject bool = false

var finalCatalogs = empty(catalogs)
  ? [
      {
        name: 'msft-quickstart-catalog'
        gitHub: {
          uri: 'https://github.com/microsoft/devcenter-catalog.git'
          branch: 'main'
          path: 'Environment-Definitions'
        }
      }
    ]
  : catalogs

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

resource devCenterCatalogs 'Microsoft.DevCenter/devcenters/catalogs@2024-05-01-preview' = [
  for catalog in finalCatalogs: {
    parent: devCenter
    name: catalog.name
    properties: {
      gitHub: {
        uri: catalog.gitHub.uri
        branch: catalog.gitHub.branch
        path: catalog.gitHub.path
      }
      syncType: 'Scheduled'
    }
  }
]

resource networkConnection 'Microsoft.DevCenter/networkConnections@2024-05-01-preview' = {
  name: '${devCenterName}-network-connection'
  location: location
  properties: {
    domainJoinType: 'AzureADJoin'
    networkingResourceGroupName: '${vnetResourceGroupName}-devbox-networking'
    subnetId: subnetId
  }
}

resource attachedNetwork 'Microsoft.DevCenter/devcenters/attachednetworks@2024-05-01-preview' = {
  parent: devCenter
  name: 'default-attached-network'
  properties: {
    networkConnectionId: networkConnection.id
  }
}

resource devCenterEnvType 'Microsoft.DevCenter/devcenters/environmentTypes@2024-05-01-preview' = {
  parent: devCenter
  name: 'sandbox'
  properties: {
    displayName: 'Sandbox'
  }
}

// Projects
resource devCenterDefaultProject 'Microsoft.DevCenter/projects@2024-05-01-preview' = if (deployDefaultProject) {
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

  resource defaultEnvironment 'environmentTypes@2024-05-01-preview' = {
    name: devCenterEnvType.name
    identity: {
      type: 'SystemAssigned'
    }
    properties: {
      deploymentTargetId: '/subscriptions/${subscription().subscriptionId}'
      creatorRoleAssignment: {
        roles: {
          'b24988ac-6180-42a0-ab88-20f7382dd24c': {}
        }
      }
      status: 'Enabled'
    }
  }

  resource pool 'pools@2024-05-01-preview' = {
    name: 'default'
    location: location
    properties: {
      devBoxDefinitionName: devCenterDevBoxDefinition.name
      licenseType: 'Windows_Client'
      virtualNetworkType: 'Unmanaged'
      displayName: 'Default'
      networkConnectionName: attachedNetwork.name
      localAdministrator: 'Enabled'
      stopOnDisconnect: {
        gracePeriodMinutes: 60
        status: 'Enabled'
      }
      singleSignOnStatus: 'Enabled'
    }

    resource schedule 'schedules@2024-05-01-preview' = {
      name: 'default'
      properties: {
        type: 'StopDevBox'
        frequency: 'Daily'
        time: '19:00'
        timeZone: 'America/Edmonton'
        state: 'Enabled'
      }
    }
  }
}

output name string = devCenter.name
output baseDevBoxDefinitionName string = devCenterDevBoxDefinition.name
output attachedNetworkName string = attachedNetwork.name
output principalId string = devCenter.identity.principalId
