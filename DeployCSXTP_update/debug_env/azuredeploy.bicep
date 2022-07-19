
param location string = 'francecentral'


param owner string
param approver string
param endDate string

//var accountNamesJson = array(json(loadTextContent('arrayContent.json')))


var accountNames  = [
  'user1'
  'user2'
]

var IpFlexConfig = [  
  100
  100
  100
]



module stgModule './singleunit_dbg.bicep' = [for name in accountNames: {
  name: '${name}deploy'
  params: {
    accountName : name
    accountIndex: indexOf(accountNames, name )
    location : location
    owner : owner
    approver:approver
    endDate: endDate

  }
}]

  output namesArray string = first(accountNames)
  output testOutput int = 10
  output testOutput_2 string = 'this is a sample string'

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
