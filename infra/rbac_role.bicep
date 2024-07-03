@description('Array of actions for the roleDefinition')
param actions array = [
  'Microsoft.Compute/galleries/read'
  'Microsoft.Compute/galleries/images/read'
  'Microsoft.Compute/galleries/images/versions/read'
  'Microsoft.Compute/galleries/images/versions/write'
  'Microsoft.Compute/images/write'
  'Microsoft.Compute/images/read'
  'Microsoft.Compute/images/delete'
]

@description('Array of notActions for the roleDefinition')
param notActions array = []

@description('Friendly name of the role definition')
param roleName string = 'Custom Role'

@description('Detailed description of the role definition')
param roleDescription string = 'Subscription Level Deployment of a Role Definition'

var roleDefName = guid(roleName)

resource roleDef 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: roleDefName
  properties: {
    roleName: roleName
    description: roleDescription
    type: 'customRole'
    permissions: [
      {
        actions: actions
        notActions: notActions
      }
    ]
    assignableScopes: [
      resourceGroup().id
    ]
  }
}

output roleDefinitionID string = roleDef.id
