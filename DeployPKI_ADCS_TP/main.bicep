param location string = 'francecentral'

param owner string
param approver string
param endDate string

param VM_CA01_name string
param VM_CA02_name string
param VM_DC_name string
param VM_SR_name string
param VM_Win10_name string

param VNET_name string
param NSG_ONLINE_name string
param NSG_OFFLINE_name string

var ImageID_VM_CA01 = '/subscriptions/a4038696-ce0f-492d-9049-38720738d4fe/resourceGroups/RG_Compute_Gallery/providers/Microsoft.Compute/galleries/Compute_gallery_TP/images/tp_pki_adcs_ca01/versions/1.0.0'
var ImageID_VM_CA02 = '/subscriptions/a4038696-ce0f-492d-9049-38720738d4fe/resourceGroups/RG_Compute_Gallery/providers/Microsoft.Compute/galleries/Compute_gallery_TP/images/tp_pki_adcs_ca02/versions/1.0.0'
var ImageID_VM_DC = '/subscriptions/a4038696-ce0f-492d-9049-38720738d4fe/resourceGroups/RG_Compute_Gallery/providers/Microsoft.Compute/galleries/Compute_gallery_TP/images/tp_pki_adcs_DC/versions/1.0.0'
var ImageID_VM_SR = '/subscriptions/a4038696-ce0f-492d-9049-38720738d4fe/resourceGroups/RG_Compute_Gallery/providers/Microsoft.Compute/galleries/Compute_gallery_TP/images/tp_pki_adcs_sr/versions/1.0.0'
var ImageID_VM_Win10 = '/subscriptions/a4038696-ce0f-492d-9049-38720738d4fe/resourceGroups/RG_Compute_Gallery/providers/Microsoft.Compute/galleries/Compute_gallery_TP/images/tp_pki_adcs_win10/versions/1.0.0'

//////////////////////////////////////////////////////////////////////////////////SERVER PUBLIC IP/////////////////////////////////////////////////////////////////////////////////////

resource publicIP_VM_DC 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: '${VM_DC_name}-public-IP'
  location: location
  tags: {
    owner: owner
    approver: approver
    endDate: endDate
  }
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Dynamic'
    idleTimeoutInMinutes: 4
  }
}

resource publicIP_VM_SR 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: '${VM_SR_name}-public-IP'
  location: location
  tags: {
    owner: owner
    approver: approver
    endDate: endDate
  }
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Dynamic'
    idleTimeoutInMinutes: 4
  }
}

resource publicIP_VM_CA01 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: '${VM_CA01_name}-public-IP'
  location: location
  tags: {
    owner: owner
    approver: approver
    endDate: endDate
  }
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Dynamic'
    idleTimeoutInMinutes: 4
  }
}

resource publicIP_VM_CA02 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: '${VM_CA02_name}-public-IP'
  location: location
  tags: {
    owner: owner
    approver: approver
    endDate: endDate
  }
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Dynamic'
    idleTimeoutInMinutes: 4
  }
}

resource publicIP_VM_Win10 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: '${VM_Win10_name}-public-IP'
  location: location
  tags: {
    owner: owner
    approver: approver
    endDate: endDate
  }
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Dynamic'
    idleTimeoutInMinutes: 4
  }
}

//////////////////////////////////////////////////////////////////////////////////VNET/////////////////////////////////////////////////////////////////////////////////////////////////

resource VNET_TP_ADCS 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: '${VNET_name}${uniqueString(subscription().subscriptionId, deployment().name)}'
  location: location
  tags: {
    owner: owner
    approver: approver
    endDate: endDate
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        '192.168.0.0/16' //plage d'adresse du réseau virtuel
      ]
    }
    subnets: [
      {
        name: 'default' //specs obligatoires
        properties: {
          addressPrefix: '192.168.0.0/24'
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

//////////////////////////////////////////////////////////////////////////////////Network Security Groups//////////////////////////////////////////////////////////////////////////////

resource NSG_TP_ADCS_ONLINE 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: NSG_ONLINE_name
  location: location
  tags: {
    owner: owner
    approver: approver
    endDate: endDate
  }
  properties: {
    securityRules: [
      {
        name: 'Allow_RDP'
        properties: {
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 300
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource NSG_TP_ADCS_OFFLINE 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: NSG_OFFLINE_name
  location: location
  tags: {
    owner: owner
    approver: approver
    endDate: endDate
  }
  properties: {
    securityRules: [
      {
        name: 'Allow_RDP'
        properties: {
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 300
          direction: 'Inbound'
        }
      }
      {
        name: 'DenyAnyCustomAnyOutbound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4096
          direction: 'Outbound'
        }
      }
      {
        name: 'DenyAnyCustomAnyInbound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4096
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowAnyCustom445Outbound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '445'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 400
          direction: 'Outbound'
        }
      }
    ]
  }
}

//////////////////////////////////////////////////////////////////////////////////Network Interface////////////////////////////////////////////////////////////////////////////////////

resource networkInterface_VM_DC 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: '${VM_DC_name}-network-interface'
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
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '192.168.0.4'
          publicIPAddress: {
            id: publicIP_VM_DC.id
          }
          subnet: {
            id: VNET_TP_ADCS.properties.subnets[0].id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: false
    enableIPForwarding: false
    networkSecurityGroup: {
      id: NSG_TP_ADCS_ONLINE.id
    }
  }
}

resource networkInterface_VM_SR 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: '${VM_SR_name}-network-interface'
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
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '192.168.0.5'
          publicIPAddress: {
            id: publicIP_VM_SR.id
          }
          subnet: {
            id: VNET_TP_ADCS.properties.subnets[0].id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: [
        '192.168.0.4'
      ]
    }
    enableAcceleratedNetworking: false
    enableIPForwarding: false
    networkSecurityGroup: {
      id: NSG_TP_ADCS_ONLINE.id
    }
  }
}

resource networkInterface_VM_CA01 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: '${VM_CA01_name}-network-interface'
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
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '192.168.0.6'
          publicIPAddress: {
            id: publicIP_VM_CA01.id
          }
          subnet: {
            id: VNET_TP_ADCS.properties.subnets[0].id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: false
    enableIPForwarding: false
    networkSecurityGroup: {
      id: NSG_TP_ADCS_OFFLINE.id
    }
  }
}

resource networkInterface_VM_CA02 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: '${VM_CA02_name}-network-interface'
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
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '192.168.0.7'
          publicIPAddress: {
            id: publicIP_VM_CA02.id
          }
          subnet: {
            id: VNET_TP_ADCS.properties.subnets[0].id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: [
        '192.168.0.4'
      ]
    }
    enableAcceleratedNetworking: false
    enableIPForwarding: false
    networkSecurityGroup: {
      id: NSG_TP_ADCS_ONLINE.id
    }
  }
}

resource networkInterface_VM_Win10 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: '${VM_Win10_name}-network-interface'
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
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '192.168.0.8'
          publicIPAddress: {
            id: publicIP_VM_Win10.id
          }
          subnet: {
            id: VNET_TP_ADCS.properties.subnets[0].id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: [
        '192.168.0.4'
      ]
    }
    enableAcceleratedNetworking: false
    enableIPForwarding: false
    networkSecurityGroup: {
      id: NSG_TP_ADCS_ONLINE.id
    }
  }
}

//////////////////////////////////////////////////////////////////////////////////Virtual Machines/////////////////////////////////////////////////////////////////////////////////////

resource VM_DC01 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: VM_DC_name
  location: location
  tags: {
    owner: owner
    approver: approver
    endDate: endDate
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s'
    }
    storageProfile: {
      osDisk: {
        name: '${VM_DC_name}_OSdisk'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
        deleteOption: 'Delete'
      }
      imageReference: {
        id: ImageID_VM_DC
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface_VM_DC.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    securityProfile: {
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
      securityType: 'TrustedLaunch'
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource VM_SR 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: VM_SR_name
  location: location
  tags: {
    owner: owner
    approver: approver
    endDate: endDate
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s'
    }
    storageProfile: {
      osDisk: {
        name: '${VM_SR_name}_OSdisk'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
        deleteOption: 'Delete'
      }
      imageReference: {
        id: ImageID_VM_SR
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface_VM_SR.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    securityProfile: {
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
      securityType: 'TrustedLaunch'
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource VM_CA01 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: VM_CA01_name
  location: location
  tags: {
    owner: owner
    approver: approver
    endDate: endDate
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s'
    }
    storageProfile: {
      osDisk: {
        name: '${VM_CA01_name}_OSdisk'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
        deleteOption: 'Delete'
      }
      imageReference: {
        id: ImageID_VM_CA01
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface_VM_CA01.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    securityProfile: {
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
      securityType: 'TrustedLaunch'
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource VM_CA02 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: VM_CA02_name
  location: location
  tags: {
    owner: owner
    approver: approver
    endDate: endDate
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s'
    }
    storageProfile: {
      osDisk: {
        name: '${VM_CA02_name}_OSdisk'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
        deleteOption: 'Delete'
      }
      imageReference: {
        id: ImageID_VM_CA02
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface_VM_CA02.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    securityProfile: {
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
      securityType: 'TrustedLaunch'
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource VM_Win10 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: VM_Win10_name
  location: location
  tags: {
    owner: owner
    approver: approver
    endDate: endDate
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s'
    }
    storageProfile: {
      osDisk: {
        name: '${VM_Win10_name}_OSdisk'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
        deleteOption: 'Delete'
      }
      imageReference: {
        id: ImageID_VM_Win10
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface_VM_Win10.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    securityProfile: {
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
      securityType: 'TrustedLaunch'
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}
