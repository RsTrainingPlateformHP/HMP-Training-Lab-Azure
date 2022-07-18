param location string = 'francecentral'
param owner string
param approver string
param endDate string
@description('Nombre d\'instances à déployer')
param count int
@description('Choisir nom du compte admin et son password')
param vm_username string
@secure()
param vm_password string

module deploy_tp_ad 'azuredeploytest.bicep' = [for i in range(0, count): {
  name: '${i}tpAD'
  params: {
    location:location
    owner: owner
    approver: approver
    endDate: endDate
    vm_username:vm_username
    vm_password:vm_password
    subnet_win:'sub_vnet_winClient_${i}'
    vnet_tp_name:'vnet_tp_ad_${i}'
    subnet_dc:'sub_vnet_dc_${i}'
    win01_ip:'IP_Public_WINClient_${i}'
    winInterface:'WIN_interface_${i}'
    win01:'beijaWIN${i}'
    nsg_Win01:'nsg_beijaWIN${i}'
    dc01:'beijaDC${i}'
    dcInterface:'DC_interface${i}'
    dcPublicIP:'IP_Public_DC_${i}'
  }
}]
