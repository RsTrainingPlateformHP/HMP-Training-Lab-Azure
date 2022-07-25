
param location string = 'francecentral'


param owner string
param approver string
param endDate string

//var accountNamesJson = array(json(loadTextContent('arrayContent.json')))


var accountNames  = [
  'userA'
  'userB'
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


