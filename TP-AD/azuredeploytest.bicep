
param location string = 'francecentral'
param owner string
param approver string
param endDate string
@description('Choisir nom du compte admin et son password')
param vm_username string
@secure()
param vm_password string

var vnet_tp_name = 'vnet_tp_ad'
var subnet_win = 'sub_vnet_win'
var subnet_dc = 'sub_vnet_dc'
var win01_ip = 'beijaWIN01-ip'
var winInterface = 'beijaWIN01895'
var win01 = 'beijaWIN01'

var dc01 = 'beijaDC01'
var domain = 'beijflore.racine'
var dcInterface = 'beijaDCinterface'
var dcPublicIP = 'beijaDC01-ip'

resource nsg_win01 'Microsoft.Network/networkSecurityGroups@2021-08-01' = {
  name: 'beijaWIN01'
  location: location
  tags:{
    owner: owner
    approver: approver
    endDate: endDate
  }
  properties: {
    securityRules: [ {
      name: 'default-allow-rdp'
      properties: {
          priority: 1000
          protocol: 'TCP'
          access: 'Allow'
          direction: 'Inbound'
          sourceApplicationSecurityGroups: []
          destinationApplicationSecurityGroups: []
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '3389'
      } 
    }
  ]
  }
  


}

resource vnet_tp_ad 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: vnet_tp_name
  location: location
  tags:{
    owner: owner
    approver: approver
    endDate: endDate
  }
  properties:{
    addressSpace: {
      addressPrefixes: [
        '10.5.0.0/16'
      ]
    }
    subnets: [
      {
        name: subnet_win
        properties: {
          addressPrefix: '10.5.0.0/24'
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: subnet_dc
        properties: {
          addressPrefix: '10.5.1.0/24'
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
}

resource networkInterface_resource 'Microsoft.Network/networkInterfaces@2021-08-01' = {
  name: winInterface
  location: location
  tags: {
    owner: owner
    approver: approver
    endDate: endDate
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/VirtualNetworks/subnets', vnet_tp_name, subnet_win)
          }
          privateIPAddress: '10.5.0.4'
          publicIPAddress: {
            id: resourceId(resourceGroup().name, 'Microsoft.Network/publicIpAddresses', win01_ip)
            properties: {
              deleteOption: 'Delete'
            }
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg_win01.id
    }
  }
  dependsOn: [
    publicIpAddress_resource
  ]
}

resource publicIpAddress_resource 'Microsoft.Network/publicIpAddresses@2021-08-01' = {
  name: win01_ip
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
}

resource virtualMachineWIN_resource 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: win01
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s'
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
        deleteOption: 'Delete'
      }
      imageReference: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'Windows-10'
        sku: '21h1-ent'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface_resource.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    osProfile: {
      computerName: win01
      adminUsername: vm_username
      adminPassword: vm_password
      windowsConfiguration: {
        enableAutomaticUpdates: false
        provisionVMAgent: true
        patchSettings: {
          enableHotpatching: false
          patchMode: 'Manual'
        }
      }
    }
    licenseType: 'Windows_Client'
  }
}






resource DCnetworkInterface_resource 'Microsoft.Network/networkInterfaces@2021-08-01' = {
  name: dcInterface
  location: location
  tags: {
    owner: owner
    approver: approver
    endDate: endDate
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/VirtualNetworks/subnets', vnet_tp_name, subnet_dc)
          }
          privateIPAddress: '10.5.1.4'
          publicIPAddress: {
            id: resourceId(resourceGroup().name, 'Microsoft.Network/publicIpAddresses', dcPublicIP)
            properties: {
              deleteOption: 'Delete'
            }
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg_win01.id
    }
  }
  dependsOn: [
    DCpublicIpAddress_resource
  ]
}

resource DCpublicIpAddress_resource 'Microsoft.Network/publicIpAddresses@2021-08-01' = {
  name: dcPublicIP
  location: location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
}


resource virtualMachineDC 'Microsoft.Compute/virtualMachines@2021-07-01' ={
  name: dc01
  location: location
  properties: {
    hardwareProfile: {
    vmSize: 'Standard_B2s'
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
        deleteOption: 'Delete'
      }
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: DCnetworkInterface_resource.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    osProfile: {
      computerName: win01
      adminUsername: vm_username
      adminPassword: vm_password
      windowsConfiguration: {
        enableAutomaticUpdates: false
        provisionVMAgent: true
        patchSettings: {
          enableHotpatching: false
          patchMode: 'Manual'
        }
      }
    }
    licenseType: 'Windows_Server'
  }
}
