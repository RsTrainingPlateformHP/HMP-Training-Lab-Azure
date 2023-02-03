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
    NSG_Name: '${i}_NSG-NESSUS-TP'
    VNET_name: '${i}_VNET-NESSUS-TP'
    ImageID_VM_SERVER : '/subscriptions/a4038696-ce0f-492d-9049-38720738d4fe/resourceGroups/RG_Compute_Gallery/providers/Microsoft.Compute/galleries/Compute_gallery_TP/images/TP_NESSUS_SERVER_VM/versions/1.0.0'
    ImageID_VM_WINDOWS : '/subscriptions/a4038696-ce0f-492d-9049-38720738d4fe/resourceGroups/RG_Compute_Gallery/providers/Microsoft.Compute/galleries/Compute_gallery_TP/images/TP_NESSUS_WINDOWS_VM/versions/1.0.0'
    ImageID_VM_LINUX : '/subscriptions/a4038696-ce0f-492d-9049-38720738d4fe/resourceGroups/RG_Compute_Gallery/providers/Microsoft.Compute/galleries/Compute_gallery_TP/images/TP_NESSUS_LINUX_VM/versions/1.0.0'
  }
}]
