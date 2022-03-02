param virtualMachines_VM_WINDOWS_name string = 'VM-WINDOWS'
param networkInterface_VM_Windows_Name string = 'networkInterface-vm-windows001'
param publicIP_VM_Windows_Name string = 'publicIP-VM-WINDOWS'
param NSG_Name string = 'nsg-SimpleEnvironment'
param schedules_shutdown_computevm_vm_windows_name string = 'shutdown-computevm-vm-windows'
param VNET_ string = 'RG_ADMIN_TestDeployements-vnet'
param location string = 'francecentral'
param adminUserName string = 'azureuser'
@secure()
param adminPassword string

resource NSG_SimpleEnvironment 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: NSG_Name
  location: location
  tags: {
    owner: 'Jean-Baptiste FAVROT'
    approver: 'Platform'
    endDate: '31/12/2022'
  }
}


resource publicIP_VM_Windows 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: publicIP_VM_Windows_Name
  location: location
  tags: {
    owner: 'Jean-Baptiste FAVROT'
    approver: 'Platform'
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
  }
}

resource VNET_SimpleDeployement 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: VNET_
  location: location
  tags: {
    owner: 'Jean-Baptiste FAVROT'
    approver: 'Platform'
    endDate: '31/12/2022'
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.3.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.3.0.0/24'
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

resource VM_Windows 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: virtualMachines_VM_WINDOWS_name
  location: location
  tags: {
    owner: 'Jean-Baptiste FAVROT'
    approver: 'Platform'
    endDate: '31/12/2022'
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2s'
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
        name: '${virtualMachines_VM_WINDOWS_name}_OSdisk'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          id: resourceId('Microsoft.Compute/disks', '${virtualMachines_VM_WINDOWS_name}_disk1_3a5192f7d0d44d94a2b0df55ac16ad75')
        }
        deleteOption: 'Delete'
      }
      dataDisks: []
    }
    osProfile: {
      computerName: virtualMachines_VM_WINDOWS_name
      adminUsername: adminUserName
      adminPassword: adminPassword
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
          id: networkInterface_VM_Windows_Name_resource.id
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

resource schedules_shutdown_computevm_vm_windows_name_resource 'microsoft.devtestlab/schedules@2018-09-15' = {
  name: schedules_shutdown_computevm_vm_windows_name
  location: location
  tags: {
    owner: 'Jean-Baptiste FAVROT'
    approver: 'Platform'
    endDate: '31/12/2022'
  }
  properties: {
    status: 'Enabled'
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: '1900'
    }
    timeZoneId: 'UTC'
    notificationSettings: {
      status: 'Enabled'
      timeInMinutes: 30
      emailRecipient: 'jfavrot@beijaflorecyberrsoutlook.onmicrosoft.com'
      notificationLocale: 'en'
    }
    targetResourceId: VM_Windows.id
  }
}

resource Application_Security_Group_FE 'Microsoft.Network/applicationSecurityGroups@2021-05-01' = {
  name: 'FrontEndServer'
  location : location
}

resource Application_Security_Group_BE 'Microsoft.Network/applicationSecurityGroups@2021-05-01' = {
  name: 'BackEndServer'
  location: location
}

resource NSRule_RDP 'Microsoft.Network/networkSecurityGroups/securityRules@2020-11-01' = {
  parent: NSG_SimpleEnvironment
  name: 'RDP_Inbound'
  properties: {
    protocol: 'Tcp'
    sourcePortRange: '*'
    destinationPortRange: '3389'
    sourceAddressPrefix: '*'
    destinationApplicationSecurityGroups: [
      Application_Security_Group_FE
    ]
    access: 'Allow'
    priority: 300
    direction: 'Inbound'
  }
}

resource NSRule_SSH_BE 'Microsoft.Network/networkSecurityGroups/securityRules@2021-05-01'= {
  parent: NSG_SimpleEnvironment
  name: 'SSH_FE_BE'
  properties: {
    protocol: 'Tcp'
    sourcePortRange: '*'
    sourceApplicationSecurityGroups: [
      Application_Security_Group_FE
    ]
    destinationPortRange: '22'
    destinationApplicationSecurityGroups: [
      Application_Security_Group_BE
    ]
    access: 'Allow'
    priority: 310
    direction: 'Inbound'
  }
}

resource VNET__default 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  parent: VNET_SimpleDeployement
  name: 'default'
  properties: {
    addressPrefix: '10.3.0.0/24'
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource networkInterface_VM_Windows_Name_resource 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: networkInterface_VM_Windows_Name
  location: location
  tags: {
    owner: 'Jean-Baptiste FAVROT'
    approver: 'Platform'
    endDate: '31/12/2022'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: '10.3.0.4'
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIP_VM_Windows.id
          }
          subnet: {
            id: VNET__default.id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
          applicationSecurityGroups: [
            Application_Security_Group_FE
          ]
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: false
    enableIPForwarding: false
    networkSecurityGroup: {
      id: NSG_SimpleEnvironment.id
    }
  }
}


