targetScope = 'resourceGroup'

@minLength(1)
@maxLength(16)
@description( 'Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string = 'test'

@description('The workload name. Replaces {workloadName} in namingConvention.')
param workloadName string = 'pj'

var suffixResourceName = '-${workloadName}'
var suffixResourceNaneWithoutHyphen = replace(suffixResourceName, '-', '')

param eventGridFunctionsInJson object
var eventGridFunctions = eventGridFunctionsInJson.eventGridFunctions

param eventGridStorageName string

param functionAppName string

// タグを定義する。ここで定義されたタグは、すべてのリソースに付与される。
var tags = { 'workload': workloadName, 'environment': environmentName }

// Cloud.Adoption Frameworkのリソース命名規則に準じた省略語を読み込む。
var abbrs = loadJsonContent('./abbreviations.json')

// Event Grid 用のストレージアカウントを参照する。
module eventGridStorage './modules/storage/storage.bicep' = {
  name: 'eventGridStorage'
  params: {
    name: eventGridStorageName
  }
}

// NOTE: Function App I Event Grid Trigger ZEhlal. Event Grid System Topic & Event Grid Subscription 1F5&93.
// Event Grid (System Topic) , Event Grid Subscription Z/F₫.
// https://learn.microsoft.com/ja-ip/azure/templates/microsoft.storage/storageaccounts/blobservices/containers?pivots=deployment-1
// https://learn.microsoft.com/ja-jp/azure/templates/microsoft.eventgrid/eventsubscriptions?pivots=deployment-language-bicep
module eventGridSystemTopic './modules/event/systemTopic.bicep' = {
  name: 'eventGridSystemTopic'
  params: {
    eventGridSystemTopicName: '${abbrs.eventGridSystemTopics}${environmentName}${suffixResourceName}'
    eventGridSystemTopicSubscriptionName: '${abbrs.eventGridEventSubscriptions}${environmentName}${suffixResourceName}'
    location: eventGridStorage.outputs.location  //NOTE: eventGrid Storage と同じRegionにする
    storageAccountId: eventGridStorage.outputs.id
    functionAppName: functionAppName
    functions: eventGridFunctions
    tags: tags
  }
}
