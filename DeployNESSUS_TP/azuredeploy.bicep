param location string = 'francecentral'
param owner string
param approver string
param endDate string
@description('Nombre d\'instances à déployer')
param count int

module deploy_tp_ad 'main.bicep' = [for i in range(0, count): {
  name: '${i}tpNESSUS'
  params: {
    location:location
    owner: owner
    approver: approver
    endDate: endDate
    VM_WINDOWS_name: '${i}_VM-NESSUS-TP-WINDOWS'
    VM_SERVER_name: '${i}_VM-NESSUS-TP-SERVER'
    VM_LINUX_name:'${i}_VM-NESSUS-TP-LINUX'
    NSG_Name_SERVER: '${i}_NSG-NESSUS-TP-SERVER'
    NSG_Name_LINUX: '${i}_NSG-NESSUS-TP-LINUX'
    NSG_Name_WINDOWS: '${i}_NSG-NESSUS-TP-WINDOWS'
    VNET_name: '${i}_VNET-NESSUS-TP'
  }
}]
