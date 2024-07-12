import { devCenterProject } from './types.bicep'

param devCenterName string
param devCenterAttachedNetworkName string
param devCenterProjectParams devCenterProject
param baseDevBoxDefinitionName string
param location string

var roleDefinitions = {
  user: '45d50f46-0b78-4001-a660-4198cbe8cd05'
  admin: '331c37c6-af14-46d9-b9f4-e1909e1b95a0'
}

resource devCenter 'Microsoft.DevCenter/devcenters@2024-05-01-preview' existing = {
  name: devCenterName
}

resource devCenterDefaultProject 'Microsoft.DevCenter/projects@2024-05-01-preview' = {
  name: devCenterProjectParams.projectName
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

  resource envTypes 'environmentTypes@2024-05-01-preview' = [for env in devCenterProjectParams.environmentTypes: {
    name: env.name
    identity: {
      type: 'SystemAssigned'
    }
    properties: {
      deploymentTargetId: env.subscriptionId
      creatorRoleAssignment: {
        roles: env.roles
      }
      status: 'Enabled'
    }
  }]

  resource projectCatalogs 'catalogs@2024-05-01-preview' = [
    for catalog in devCenterProjectParams.catalogs: {
      name: '${catalog.name}-${uniqueString(devCenterName, devCenterProjectParams.projectName, catalog.name)}'
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

  resource pool 'pools@2024-05-01-preview' = {
    name: 'default'
    location: location
    properties: {
      devBoxDefinitionName: empty(devCenterProjectParams.devBoxDefinitionName) ? baseDevBoxDefinitionName : devCenterProjectParams.devBoxDefinitionName
      licenseType: 'Windows_Client'
      virtualNetworkType: 'Unmanaged'
      displayName: 'Default Pool'
      networkConnectionName: devCenterAttachedNetworkName
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

// assign the devCenterProjectParams.acl to the project

resource devCenterProjectAdminRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for admin in devCenterProjectParams.permissions.devBoxAdmins: {
  name: guid(devCenterDefaultProject.id, admin, roleDefinitions.admin)
  scope: devCenterDefaultProject
  properties: {
    principalId: admin
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitions.admin)
  }
}]

resource devCenterProjectUserRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for user in devCenterProjectParams.permissions.devBoxUsers: {
  name: guid(devCenterDefaultProject.id, user, roleDefinitions.user)
  scope: devCenterDefaultProject
  properties: {
    principalId: user
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitions.user)
  }
}]
