param hostingPlanName string
param functionName string
param location string = resourceGroup().location
param storageAccountName string
param deploymentStorageContainerName string
param applicationInsightsName string
param tags object = {}
param functionAppRuntime string = 'python'
param functionAppRuntimeVersion string = '3.11'
param maximumInstanceCount int = 100
param instanceMemoryMB int = 2048
param eventGridStorageAccountName string

resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

resource eventGridStorage 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: eventGridStorageAccountName
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
}


resource flexFuncPlan 'Microsoft.Web/serverfarms@2023-12-01' existing = {
  name: hostingPlanName
}

resource flexFuncApp 'Microsoft.Web/sites@2023-12-01' = {
  name: functionName
  location: location
  tags: tags
  kind: 'functionapp,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: flexFuncPlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage__accountName'
          value: storage.name
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'BLOB_CONNECTION_STRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${eventGridStorage.name};AccountKey=${eventGridStorage.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
        }
      ]
    }
    functionAppConfig: {
      deployment: {
        storage: {
          type: 'blobContainer'
          value: '${storage.properties.primaryEndpoints.blob}${deploymentStorageContainerName}'
          authentication: {
            type: 'SystemAssignedIdentity'
          }
        }
      }
      scaleAndConcurrency: {
        maximumInstanceCount: maximumInstanceCount
        instanceMemoryMB: instanceMemoryMB
      }
      runtime: { 
        name: functionAppRuntime
        version: functionAppRuntimeVersion
      }
    }
  }
  dependsOn:[
    appInsights
    storage
    eventGridStorage
  ]
}

var storageRoleDefinitionId  = 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b' //Storage Blob Data Owner role

// Allow access from function app to storage account using a managed identity
resource storageRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(storage.id, storageRoleDefinitionId)
  scope: storage
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', storageRoleDefinitionId)
    principalId: flexFuncApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// resource function 'Microsoft.Web/sites/functions@2020-12-01' = {
//     parent: flexFuncApp 
//     name: functionNameComputed
//     properties: {
//       config: {
//         disabled: false
//         bindings: [
//           {
//             type: 'eventGridTrigger'
//             name: 'event'
//             direction: 'in'
//           }
//         ]
//       }
//       files: {
//         '__init__.py': loadTextContent('__init__.py')
//       }
//     }
// }
