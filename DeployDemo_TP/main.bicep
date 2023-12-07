
param location string = 'francecentral'
param owner string
param approver string
param endDate string
@description('Choisir nom du compte admin et son password')
param VM_WINDOWS_name string
param VM_LINUX_name string

param VNET_name string
param NSG_Name string

var ImageID_VM_WINDOWS = '/subscriptions/a4038696-ce0f-492d-9049-38720738d4fe/resourceGroups/RG_Compute_Gallery/providers/Microsoft.Compute/galleries/Compute_gallery_TP/images/demolinuxversion/versions/1.0.0'
var ImageID_VM_LINUX = '/subscriptions/a4038696-ce0f-492d-9049-38720738d4fe/resourceGroups/RG_Compute_Gallery/providers/Microsoft.Compute/galleries/Compute_gallery_TP/images/demoversionlinux/versions/1.0.1'

//////////////////////////////////////////////////////////////////////////////////VMS PUBLIC IPs/////////////////////////////////////////////////////////////////////////////////////

resource publicIP_VM_LINUX 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: '${VM_LINUX_name}-public-IP'
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

resource publicIP_VM_WINDOWS 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: '${VM_WINDOWS_name}-public-IP'
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

resource VNET_TP_DEMO 'Microsoft.Network/virtualNetworks@2022-07-01' = {
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
        '10.0.0.0/16' //plage d'adresse du réseau virtuel
      ]
    }
    subnets: [
      {
        name: 'sn-linux' //specs obligatoires
        properties: {
          addressPrefix: '10.0.1.0/24'
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'sn-windows' //specs obligatoires
        properties: {
          addressPrefix: '10.0.0.0/24'
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

resource NSG_TP_DEMO 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: NSG_Name
  location: location
  tags: {
    owner: owner
    approver: approver
    endDate: endDate
  }
  properties: {
    securityRules: [
      {
        name: 'Allow_SSH_Inbound' 
        properties: {
          priority: 300
          protocol: '*'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '22'
        }
      }
      {
        name: 'Allow_RDP_Inbound' //nom de la règle
        properties: {
          priority: 360
          protocol: 'TCP'
          access: 'Allow'
          direction: 'Inbound'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          destinationPortRange: '23389' //port de destination autorisé (ssh)
        }
      }
    ]
  }
}

//////////////////////////////////////////////////////////////////////////////////Network Interfaces////////////////////////////////////////////////////////////////////////////////////

resource networkInterface_VM_WINDOWS 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: '${VM_WINDOWS_name}-network-interface'
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
            id: VNET_TP_DEMO.properties.subnets[1].id
          }
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.0.0.4'
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
      id: NSG_TP_NESSUS.id
    }
  }
}

resource networkInterface_VM_LINUX 'Microsoft.Network/networkInterfaces@2022-07-01' = {
  name: '${VM_LINUX_name}-network-interface'
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
            id: VNET_TP_DEMO.properties.subnets[0].id
          }
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.0.1.4'
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
      id: NSG_TP_NESSUS.id
    }
  }
}

//////////////////////////////////////////////////////////////////////////////////Virtual Machines/////////////////////////////////////////////////////////////////////////////////////

resource VM_WINDOWS 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: VM_WINDOWS_name
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
        name: '${VM_WINDOWS_name}_OSdisk'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
        deleteOption: 'Delete'
      }
      imageReference: {
        id: ImageID_VM_WINDOWS
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface_VM_WINDOWS.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource VM_LINUX 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: VM_LINUX_name
  location: location
  tags: {
    owner: owner
    approver: approver
    endDate: endDate
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1ms'
    }
    storageProfile: {
      osDisk: {
        name: '${VM_LINUX_name}_OSdisk'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
        deleteOption: 'Delete'
      }
      imageReference: {
        id: ImageID_VM_LINUX
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface_VM_LINUX.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}
