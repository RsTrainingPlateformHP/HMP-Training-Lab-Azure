param location string = 'francecentral'
param owner string
param approver string
param endDate string

@description('Nombre d\'instances à déployer')
param count int

module deploy_tp_ad 'main.bicep' = [for i in range(0, count): {
  name: '${i}tpADCS'
  params: {
    location: location
    owner: owner
    approver: approver
    endDate: endDate
    VM_EJBCA_name: '${i}_VM-ADCS-TP-DC'
    NSG_name: '${i}_NSG-ONLINE-ADCS-TP'
    VNET_name: '${i}_VNET-ADCS-TP'
  }
}]
