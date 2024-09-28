param location string
param logAnalyticsName string
param tags object = {}

@minValue(30)
@maxValue(730)
param retentionInDays int = 30

resource logAnalyticcsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: logAnalyticsName
  location: location
  tags: tags
  properties: {
    retentionInDays: retentionInDays
  }
}

output id string = logAnalyticcsWorkspace.id
