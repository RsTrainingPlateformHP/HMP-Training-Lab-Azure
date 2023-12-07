param location string = 'francecentral'
param owner string
param approver string
param endDate string
@description('Nombre d\'instances à déployer')
param count int

module deploy_tp_ad 'main.bicep' = [for i in range(0, count): {
  name: '${i}tpDemo'
  params: {
    location:location
    owner: owner
    approver: approver
    endDate: endDate
    VM_WINDOWS_name: '${i}_VM-NESSUS-TP-WINDOWS'
    VM_LINUX_name:'${i}_VM-NESSUS-TP-LINUX'
    NSG_Name: '${i}_NSG-NESSUS-TP'
    VNET_name: '${i}_VNET-NESSUS-TP'
  }
}]
