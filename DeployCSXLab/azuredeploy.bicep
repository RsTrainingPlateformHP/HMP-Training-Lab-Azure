param virtualMachines_VM_CSX_TP_LINUX_name string = 'VM-CSX-TP-LINUX'
param virtualMachines_VM_CSX_TP_SERVER_name string = 'VM-CSX-TP-SERVER'
param virtualMachines_VM_CSX_TP_WINDOWS_name string = 'VM-CSX-TP-WINDOWS'
param networkSecurityGroups_all_CSX_TP_nsg_name string = 'all-CSX-TP-nsg'
param location string = 'francecentral'

var networkInterfaces_vm_csx_tp_linux829_name = 'vm-csx-tp-linux829'
var publicIPAddresses_VM_CSX_TP_LINUX_ip_name = 'VM-CSX-TP-LINUX-ip'
var virtualNetworks_RG_CSX_TP_Admin_vnet_name = 'RG_CSX_TP_Admin-vnet'
var networkInterfaces_vm_csx_tp_server611_name = 'vm-csx-tp-server611'
var publicIPAddresses_VM_CSX_TP_SERVER_ip_name = 'VM-CSX-TP-SERVER-ip'
var networkInterfaces_vm_csx_tp_windows619_name = 'vm-csx-tp-windows619'
var publicIPAddresses_VM_CSX_TP_WINDOWS_ip_name = 'VM-CSX-TP-WINDOWS-ip'


resource networkSecurityGroups_all_CSX_TP_nsg_name_resource 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: networkSecurityGroups_all_CSX_TP_nsg_name
  location: location
  tags: {
    owner: 'Audrey Fournies'
    endDate: '31/12/2022'
    approver: 'Jean-Baptiste Favrot'
  }
  properties: {
    securityRules: [
      {
        name: 'AllowRDP-VM-Windows_Port_3389'
        properties: {
          description: 'Allow ALL inbound traffic\n- To VM-CSX-TP-WINDOWS\n- Via RDP on port 3389'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '10.0.0.5'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'AllowSSH-VM-Linux_Port_22'
        properties: {
          description: 'Allow ALL inbound traffic \n- To VM-CSX-TP-LINUX\n- Via SSH on port 22'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '10.0.0.4'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'AllowSSH-VM-Linux-TO-VM-Server'
        properties: {
          description: 'Allow outbound traffic \n- To VM-CSX-TP-SERVER\n- From VM-CSX-TP-LINUX\n- Via SSH port 22'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '10.0.0.6'
          destinationAddressPrefix: '10.0.0.4'
          access: 'Allow'
          priority: 140
          direction: 'Outbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'AllowSSH-VM-Server-FROM-VM-Linux'
        properties: {
          description: 'Allow outbound traffic \n- To VM-CSX-TP-SERVER\n- From VM-CSX-TP-LINUX\n- Via SSH port 22'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '10.0.0.4'
          destinationAddressPrefix: '10.0.0.6'
          access: 'Allow'
          priority: 150
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
    ]
  }
}

resource publicIPAddresses_VM_CSX_TP_LINUX_ip_name_resource 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: publicIPAddresses_VM_CSX_TP_LINUX_ip_name
  location: location
  tags: {
    owner: 'Audrey Fournies'
    approver: 'Jean-Baptiste Favrot'
    endDate: '31/12/2022'
  }
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Dynamic'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
}

resource publicIPAddresses_VM_CSX_TP_SERVER_ip_name_resource 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: publicIPAddresses_VM_CSX_TP_SERVER_ip_name
  location: location
  tags: {
    owner: 'Audrey Fournies'
    approver: 'Jean-Baptiste Favrot'
    endDate: '31/12/2022'
  }
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Dynamic'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
}

resource publicIPAddresses_VM_CSX_TP_WINDOWS_ip_name_resource 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: publicIPAddresses_VM_CSX_TP_WINDOWS_ip_name
  location: location
  tags: {
    owner: 'Audrey Fournies'
    approver: 'Jean-Baptiste Favrot'
    endDate: '31/12/2022'
  }
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Dynamic'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
}

resource virtualMachines_VM_CSX_TP_LINUX_name_resource 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: virtualMachines_VM_CSX_TP_LINUX_name
  location: location
  tags: {
    owner: 'Audrey Fournies'
    approver: 'Jean-Baptiste Favrot'
    endDate: '31/12/2022'
  }
  plan: {
    name: 'ubuntu-server-18-04-minimal'
    product: 'ubuntu-server-18-04-minimal'
    publisher: 'tidalmediainc'
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    storageProfile: {
      imageReference: {
        publisher: 'tidalmediainc'
        offer: 'ubuntu-server-18-04-minimal'
        sku: 'ubuntu-server-18-04-minimal'
        version: 'latest'
      }
      osDisk: {
        osType: 'Linux'
        name: '${virtualMachines_VM_CSX_TP_LINUX_name}_OsDisk_1_b67f0110e83243faba246696c0b67bf2'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          id: resourceId('Microsoft.Compute/disks', '${virtualMachines_VM_CSX_TP_LINUX_name}_OsDisk_1_b67f0110e83243faba246696c0b67bf2')
        }
        deleteOption: 'Delete'
      }
      dataDisks: []
    }
    osProfile: {
      computerName: virtualMachines_VM_CSX_TP_LINUX_name
      adminUsername: 'VM-TP-CSX-LINUX-user'
      linuxConfiguration: {
        disablePasswordAuthentication: false
        provisionVMAgent: true
        patchSettings: {
          patchMode: 'ImageDefault'
          assessmentMode: 'ImageDefault'
        }
      }
      secrets: []
      allowExtensionOperations: true
      requireGuestProvisionSignal: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaces_vm_csx_tp_linux829_name_resource.id
          properties: {
            deleteOption: 'Detach'
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

resource virtualMachines_VM_CSX_TP_SERVER_name_resource 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: virtualMachines_VM_CSX_TP_SERVER_name
  location: location
  tags: {
    owner: 'Audrey Fournies'
    approver: 'Jean-Baptiste Favrot'
    endDate: '31/12/2022'
  }
  plan: {
    name: 'ubuntu-server-18-04-minimal'
    product: 'ubuntu-server-18-04-minimal'
    publisher: 'tidalmediainc'
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    storageProfile: {
      imageReference: {
        publisher: 'tidalmediainc'
        offer: 'ubuntu-server-18-04-minimal'
        sku: 'ubuntu-server-18-04-minimal'
        version: 'latest'
      }
      osDisk: {
        osType: 'Linux'
        name: '${virtualMachines_VM_CSX_TP_SERVER_name}_disk1_1096ccff905441238d3e13b8357b5251'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          id: resourceId('Microsoft.Compute/disks', '${virtualMachines_VM_CSX_TP_SERVER_name}_disk1_1096ccff905441238d3e13b8357b5251')
        }
        deleteOption: 'Delete'
      }
      dataDisks: []
    }
    osProfile: {
      computerName: virtualMachines_VM_CSX_TP_SERVER_name
      adminUsername: 'VM-TP-CSX-SRV-user'
      linuxConfiguration: {
        disablePasswordAuthentication: false
        provisionVMAgent: true
        patchSettings: {
          patchMode: 'ImageDefault'
          assessmentMode: 'ImageDefault'
        }
      }
      secrets: []
      allowExtensionOperations: true
      requireGuestProvisionSignal: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaces_vm_csx_tp_server611_name_resource.id
          properties: {
            deleteOption: 'Detach'
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

resource virtualMachines_VM_CSX_TP_WINDOWS_name_resource 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: virtualMachines_VM_CSX_TP_WINDOWS_name
  location: location
  tags: {
    owner: 'Audrey Fournies'
    approver: 'Jean-Baptiste Favrot'
    endDate: '31/12/2022'
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-datacenter-gensecond'
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        name: '${virtualMachines_VM_CSX_TP_WINDOWS_name}_OsDisk_1_f364402b1530458f880c786b36c4e6e4'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          id: resourceId('Microsoft.Compute/disks', '${virtualMachines_VM_CSX_TP_WINDOWS_name}_OsDisk_1_f364402b1530458f880c786b36c4e6e4')
        }
        deleteOption: 'Delete'
      }
      dataDisks: []
    }
    osProfile: {
      computerName: 'VM-CSX-TP-WINDO'
      adminUsername: 'VM-TP-CSX-WDS-user'
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByOS'
          assessmentMode: 'ImageDefault'
          enableHotpatching: false
        }
      }
      secrets: []
      allowExtensionOperations: true
      requireGuestProvisionSignal: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaces_vm_csx_tp_windows619_name_resource.id
          properties: {
            deleteOption: 'Detach'
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

resource networkSecurityGroups_all_CSX_TP_nsg_name_AllowRDP_VM_Windows_Port_3389 'Microsoft.Network/networkSecurityGroups/securityRules@2020-11-01' = {
  parent: networkSecurityGroups_all_CSX_TP_nsg_name_resource
  name: 'AllowRDP-VM-Windows_Port_3389'
  properties: {
    description: 'Allow ALL inbound traffic\n- To VM-CSX-TP-WINDOWS\n- Via RDP on port 3389'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '3389'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '10.0.0.5'
    access: 'Allow'
    priority: 100
    direction: 'Inbound'
    sourcePortRanges: []
    destinationPortRanges: []
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
}

resource networkSecurityGroups_all_CSX_TP_nsg_name_AllowSSH_VM_Linux_Port_22 'Microsoft.Network/networkSecurityGroups/securityRules@2020-11-01' = {
  parent: networkSecurityGroups_all_CSX_TP_nsg_name_resource
  name: 'AllowSSH-VM-Linux_Port_22'
  properties: {
    description: 'Allow ALL inbound traffic \n- To VM-CSX-TP-LINUX\n- Via SSH on port 22'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '22'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '10.0.0.4'
    access: 'Allow'
    priority: 110
    direction: 'Inbound'
    sourcePortRanges: []
    destinationPortRanges: []
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
}

resource networkSecurityGroups_all_CSX_TP_nsg_name_AllowSSH_VM_Linux_TO_VM_Server 'Microsoft.Network/networkSecurityGroups/securityRules@2020-11-01' = {
  parent: networkSecurityGroups_all_CSX_TP_nsg_name_resource
  name: 'AllowSSH-VM-Linux-TO-VM-Server'
  properties: {
    description: 'Allow outbound traffic \n- To VM-CSX-TP-SERVER\n- From VM-CSX-TP-LINUX\n- Via SSH port 22'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '22'
    sourceAddressPrefix: '10.0.0.6'
    destinationAddressPrefix: '10.0.0.4'
    access: 'Allow'
    priority: 140
    direction: 'Outbound'
    sourcePortRanges: []
    destinationPortRanges: []
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
}

resource networkSecurityGroups_all_CSX_TP_nsg_name_AllowSSH_VM_Server_FROM_VM_Linux 'Microsoft.Network/networkSecurityGroups/securityRules@2020-11-01' = {
  parent: networkSecurityGroups_all_CSX_TP_nsg_name_resource
  name: 'AllowSSH-VM-Server-FROM-VM-Linux'
  properties: {
    description: 'Allow outbound traffic \n- To VM-CSX-TP-SERVER\n- From VM-CSX-TP-LINUX\n- Via SSH port 22'
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '22'
    sourceAddressPrefix: '10.0.0.4'
    destinationAddressPrefix: '10.0.0.6'
    access: 'Allow'
    priority: 150
    direction: 'Inbound'
    sourcePortRanges: []
    destinationPortRanges: []
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
}

resource virtualNetworks_RG_CSX_TP_Admin_vnet_name_resource 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: virtualNetworks_RG_CSX_TP_Admin_vnet_name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.0.0.0/24'
          networkSecurityGroup: {
            id: networkSecurityGroups_all_CSX_TP_nsg_name_resource.id
          }
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

resource virtualNetworks_RG_CSX_TP_Admin_vnet_name_default 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  parent: virtualNetworks_RG_CSX_TP_Admin_vnet_name_resource
  name: 'default'
  properties: {
    addressPrefix: '10.0.0.0/24'
    networkSecurityGroup: {
      id: networkSecurityGroups_all_CSX_TP_nsg_name_resource.id
    }
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource networkInterfaces_vm_csx_tp_linux829_name_resource 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: networkInterfaces_vm_csx_tp_linux829_name
  location: location
  tags: {
    owner: 'Audrey Fournies'
    approver: 'Jean-Baptiste Favrot'
    endDate: '31/12/2022'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: '10.0.0.4'
          privateIPAllocationMethod: 'Static'
          publicIPAddress: {
            id: publicIPAddresses_VM_CSX_TP_LINUX_ip_name_resource.id
          }
          subnet: {
            id: virtualNetworks_RG_CSX_TP_Admin_vnet_name_default.id
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
      id: networkSecurityGroups_all_CSX_TP_nsg_name_resource.id
    }
  }
}

resource networkInterfaces_vm_csx_tp_server611_name_resource 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: networkInterfaces_vm_csx_tp_server611_name
  location: location
  tags: {
    owner: 'Audrey Fournies'
    approver: 'Jean-Baptiste Favrot'
    endDate: '31/12/2022'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: '10.0.0.6'
          privateIPAllocationMethod: 'Static'
          publicIPAddress: {
            id: publicIPAddresses_VM_CSX_TP_SERVER_ip_name_resource.id
          }
          subnet: {
            id: virtualNetworks_RG_CSX_TP_Admin_vnet_name_default.id
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
      id: networkSecurityGroups_all_CSX_TP_nsg_name_resource.id
    }
  }
}

resource networkInterfaces_vm_csx_tp_windows619_name_resource 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: networkInterfaces_vm_csx_tp_windows619_name
  location: location
  tags: {
    owner: 'Audrey Fournies'
    approver: 'Jean-Baptiste Favrot'
    endDate: '31/12/2022'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: '10.0.0.5'
          privateIPAllocationMethod: 'Static'
          publicIPAddress: {
            id: publicIPAddresses_VM_CSX_TP_WINDOWS_ip_name_resource.id
          }
          subnet: {
            id: virtualNetworks_RG_CSX_TP_Admin_vnet_name_default.id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: true
    enableIPForwarding: false
    networkSecurityGroup: {
      id: networkSecurityGroups_all_CSX_TP_nsg_name_resource.id
    }
  }

  
}

output VM_CSX_TP_LINUX_IP string = publicIPAddresses_VM_CSX_TP_LINUX_ip_name_resource.properties.ipAddress
output VM_CSX_TP_WINDOWS_IP string = publicIPAddresses_VM_CSX_TP_WINDOWS_ip_name_resource.properties.ipAddress
output VM_CSX_TP_LINUX_SERVER_IP string = publicIPAddresses_VM_CSX_TP_SERVER_ip_name_resource.properties.ipAddress

