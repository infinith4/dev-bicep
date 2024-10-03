targetScope = 'resourceGroup'

param location string = resourceGroup().location
@description('The environment designator for the deployment. Replaces {env} in namingConvention.')
@allowed([
  'dev' //Develop
  'stg' //Staging
  'prd' //Production
])
param enviromentName string = 'dev'
var enviromentResourceNameWithoutHyphen = replace(enviromentName, '-', '')

@allowed(['eastasia', 'eastus'])
param hostingPlanLocation string = 'eastasia'

@description('The workload name. Replaces {workloadName} in namingConvention.')
param workloadName string = 'pj'

param deploymentStorageContainerName string = 'testcontainer'


var suffixResourceName = '-${workloadName}'
var suffixResourceNameWithoutHyphen = replace(suffixResourceName, '-', '')

param convertedEpoch int = dateTimeToEpoch(dateTimeAdd(utcNow(), 'P1Y'))

var abbrs = json(loadTextContent('abbreviations.json'))

var tags = {
  workload: workloadName
  environment: enviromentName
}

//https://learn.microsoft.com/ja-jp/dotnet/api/microsoft.azure.management.operationalinsights.models.workspacesku?view=azure-dotnet-legacy
////https://github.com/mspnp/microservices-reference-implementation/blob/e903447c7b8b6af6302a5f5a7c672572471d01e4/azuredeploy.bicep#L77
module logAnalyticsWorkspace 'modules/monitor/logAnayticsWorkspace.bicep' = {
  name: 'logAnalyticsWorkspace'
  params:{
    logAnalyticsName: '${abbrs.operationalInsightsWorkspaces}${enviromentName}${suffixResourceName}'
    location: location
  }
}

module appInsights 'modules/monitor/appInsights.bicep' = {
  name: 'appInsights'
  params:{
    name: '${abbrs.insightsComponents}${enviromentName}${suffixResourceName}'
    location: location
    tags: tags
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.outputs.id
  }
}

module storage 'modules/storage/storage.bicep' = {
  name: 'storage'
  params: {
    storageAccountName: '${abbrs.storageStorageAccounts}${enviromentResourceNameWithoutHyphen}${suffixResourceNameWithoutHyphen}'
    location: location
    tags: tags
    storageAccountType: 'Standard_LRS'
  }
}

// var aspSku = {
//   tier: 'Standard'
//   name: 'S1'
// }

var aspSku = {
  tier: 'FlexConsumption'
  name: 'FC1'
}


module hostingPlan 'modules/host/asp.bicep' = {
  name: 'hostingPlan'
  params:{
    hostingPlanName: '${abbrs.webServerFarms}${enviromentName}${suffixResourceName}'
    location: !empty(hostingPlanLocation) ? hostingPlanLocation : location
    tags: tags
    sku: aspSku
    kind: 'functionapp,linux'
  }
}

module function 'modules/function/function.bicep' = if(aspSku.tier == 'Standard'){
  name: 'function'
  params:{
    functionName: '${abbrs.webSitesFunctions}${enviromentName}${suffixResourceName}'
    location: hostingPlanLocation
    tags: tags
    hostingPlanName: hostingPlan.outputs.name
    storageAccountName: storage.outputs.storageAccountName
    applicationInsightsName: appInsights.outputs.appInsightsName
    appInsightsInstrumentationKey: appInsights.outputs.appInsightsInstrumentationKey
    
  }
}

module flexFunction 'modules/function/flexFunction.bicep' = if(aspSku.tier == 'FlexConsumption'){
  name: 'flexFunction'
  params:{
    functionName: '${abbrs.webSitesFunctions}${enviromentName}-flex${suffixResourceName}'
    location: hostingPlanLocation
    tags: tags
    hostingPlanName: hostingPlan.outputs.name
    storageAccountName: storage.outputs.storageAccountName
    applicationInsightsName: appInsights.outputs.appInsightsName
    functionAppRuntime: 'python'
    functionAppRuntimeVersion: '3.11'
    functionNameComputed: 'MyTestEventGridTrigger01'
    deploymentStorageContainerName: deploymentStorageContainerName
  }
}


