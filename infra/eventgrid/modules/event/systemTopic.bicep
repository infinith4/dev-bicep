@description('The name of the Event Grid custom topic.')
param eventGridSystemTopicName string = 'topic-${uniqueString(resourceGroup().id)}'


@description('The name of the Event Grid custom topic\'s subscription.')
param eventGridSystemTopicSubscriptionName string = 'sub-${uniqueString(resourceGroup().id)}'

param location string = resourceGroup().location
param storageAccountId string
param tags object = {}
param functionAppName string
param functions array

// Microsoft. EventGrid/systemTopics を作成する
// https://github.com/Azure/azure-quickstart-templates/blob/master/quickstarts/microsoft.eventgrid/event-grid-subscription-and-storage/main.bicep
resource systemTopic 'Microsoft.EventGrid/systemTopics@2023-12-15-preview' = {
  name: eventGridSystemTopicName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: tags
  properties: {
    source: storageAccountId
    topicType: 'Microsoft.Storage.StorageAccounts'
  }
}

//関数の数分、Event Grid Subscription を作成する
resource eventSubscription 'Microsoft.EventGrid/systemTopics/eventSubscriptions@2023-12-15-preview' = [for function in functions: {
  parent: systemTopic
  name: '${eventGridSystemTopicSubscriptionName}-${function.name}'
  properties: {
    destination: {
      endpointType:'AzureFunction'
      properties: {
        resourceId: resourceId('Microsoft.Web/sites/functions', functionAppName, function.name)
      }
    }
    eventDeliverySchema: 'EventGridSchema'
    filter: {
      includedEventTypes: function.includedEventTypes
    }
  }
}]
