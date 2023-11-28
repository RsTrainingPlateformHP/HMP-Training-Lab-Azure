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
    VM_DC_name: '${i}_VM-ADCS-TP-DC'
    VM_SR_name: '${i}_VM-ADCS-TP-SR'
    VM_CA01_name: '${i}_VM-ADCS-TP-CA01'
    VM_CA02_name: '${i}_VM-ADCS-TP-CA02'
    VM_Win10_name: '${i}_VM-ADCS-TP-Win10'
    NSG_ONLINE_name: '${i}_NSG-ONLINE-ADCS-TP'
    NSG_OFFLINE_name: '${i}_NSG-OFFLINE-ADCS-TP'
    VNET_name: '${i}_VNET-ADCS-TP'
  }
}]
