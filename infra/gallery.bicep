param galleryName string
param devCenterName string
param devCenterPrincipalId string
param location string

var contributorRoleDefinitionId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')

resource gallery 'Microsoft.Compute/galleries@2023-07-03' = {
  name: galleryName
  location: location  
}

resource devCenter 'Microsoft.DevCenter/devcenters@2024-05-01-preview' existing = {
  name: devCenterName
}

resource devCenterExternalGallery 'Microsoft.DevCenter/devcenters/galleries@2024-05-01-preview' = {
  parent: devCenter
  name: 'External'
  properties: {
    galleryResourceId: gallery.id
  }
}

resource galleryContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(gallery.id, devCenterPrincipalId, contributorRoleDefinitionId)
  scope: devCenterExternalGallery
  properties: {
    principalId: devCenterPrincipalId
    roleDefinitionId: contributorRoleDefinitionId
  }
}
