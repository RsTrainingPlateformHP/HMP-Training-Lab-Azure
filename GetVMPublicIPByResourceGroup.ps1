# =======================================================
# NAME: GetVmPublicIp.ps1
# AUTHOR: FAVROT, Jean-Baptiste, Entreprise
# DATE: 31/05/2022
#
# Lists all VMs with corresponding public IPs. Takes a string with the name of the VMs you want to match in input
#
# =======================================================

param 
(
     [string]$ResourceGroupNameSearch,
     [string][Parameter(Mandatory)]$OutputName
)

function GetPublicIP ($ResourceGroupNameSearch) {
    $resourceGroups = Get-AzResourceGroup | where-object -Property Name -Match "$ResourceGroupNameSearch"
    
    foreach($ResourceGroup in $resourceGroups)
    $publicIPs = Get-AzPublicIpAddress -ResourceGroupName $ResourceGroup.ResourceGroupName
    $StringOutput = "$ResourceGroup.ResourceGroupName"
     
    foreach($publicIP in $publicIPs) {
            $StringOutput = "$StringOutput,$($publicIP.IpAddress)"
         }
    Write-Output $StringOutput
}

GetPublicIP($ResourceGroupNameSearch) | Out-File -FilePath ".\$OutputName.csv" -NoClobber