param location string = 'francecentral'
param owner string
param approver string
param endDate string
@description('Nombre d\'instances à déployer')
param count int

module deploy_tp_ad 'unit.bicep' = [for i in range(0, count): {
  name: '${i}tpCSX'
  params: {
    location:location
    owner: owner
    approver: approver
    endDate: endDate
    VM_FE_WINDOWS_name: '${i}_VM-CSX-TP-WINDOWS'
    VM_BE_SERVER_name: '${i}_VM-CSX-TP-LINUX'
    VM_FE_LINUX_name:'${i}_VM-CSX-TP-SERVER'
    NSG_Name: '${i}_nsg-CSX-TP'
    VNET_name: '${i}_VNET-Lab-CSX'
    Back_End_App: '${i}_BackEndServer'
    Front_End_App: '${i}_FrontEndServer'
    RestrictVNetFlowInbound: '${i}_RestrictVNetFlowInbound'
  }
}]
