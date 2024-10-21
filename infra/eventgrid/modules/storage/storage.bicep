param name string

resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: name
}

output id string = storage.id
output name string = storage.name
output location string = storage.location
