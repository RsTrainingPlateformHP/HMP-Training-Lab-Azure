
var accountNames  = [
  'user1'
  'user2'
]



module stgModule './singleunit.bicep' = [for name in accountNames: {
  name: '${name}deploy'
  params: {
    accountName : name
    accountIndex: indexOf(accountNames, name )
  }
}]

/* resource createStorages 'Microsoft.Storage/storageAccounts@2021-06-01' = [for i in range(0, storageCount): {
  name: '${i}storage${uniqueString(resourceGroup().id)}'
  location: rgLocation
  sku: {
    name: 'UserID1'
  }
  kind: 'StorageV2'
}]

output names array = [for i in range(0, storageCount): {
  name: createStorages[i].name
}]
 */
