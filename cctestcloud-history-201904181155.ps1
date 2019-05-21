# cctestcloud-history 

#Connect-AzAccount
#$virtualnetwork = New-AzVirtualNetwork -ResourceGroupName ZCRG-ITSCore -Location 'US East' -Name ZC-Vnet -AddressPrefix 172.28.0.0/16
#Get-AzureRmTag
#$virtualnetwork = New-AzVirtualNetwork -ResourceGroupName ZCRG-ITSCore -Location 'US East' -Name ZC-Vnet -AddressPrefix 172.28.0.0/16 -Tag @{Owner="Jeff"}
#$virtualnetwork = New-AzVirtualNetwork -ResourceGroupName ZCRG-ITSCore -Location 'East US' -Name ZC-Vnet -AddressPrefix 172.28.0.0/16 -Tag @{Owner="Jeff"}
#$subnetConfig = Add-AzVirtualNetworkSubnetConfig -Name ZC-Backbone -AddressPrefix 172.28.1.0/24 -VirtualNetwork $virtualnetwork -Tag @{Owner="Jeff"}
#$subnetConfig = Add-AzVirtualNetworkSubnetConfig -Name ZC-Backbone -AddressPrefix 172.28.1.0/24 -VirtualNetwork $virtualnetwork
#$subnetConfig = Add-AzVirtualNetworkSubnetConfig -Name ZC-Auth -AddressPrefix 172.28.2.0/24 -VirtualNetwork $virtualnetwork
#$subnetConfig = Add-AzVirtualNetworkSubnetConfig -Name ZC-Web -AddressPrefix 172.28.3.0/24 -VirtualNetwork $virtualnetwork
#$virtualnetwork | Set-AzVirtualNetwork
#Get-AzVirtualNetwork
#Get-AzVirtualNetwork | more

