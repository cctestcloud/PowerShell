<<<<<<< HEAD
# This shows how to create the virtual network in Azure followed by the subnets
# Add this line from jrombough3
# Comment added 20190424 to test git changes y
#First we need to connect to the Azure cloud
Connect-AzAccount

#This is the stage where we create the virtual network. Can be thought of as a supernet (as opposed to subnet)
#Also note the we are getting referenced to a newly created AzVirtualNetwork object  $virtualnetwork
$virtualnetwork = New-AzVirtualNetwork -ResourceGroupName ZCRG-ITSCore -Location 'East US' -Name ZC-Vnet -AddressPrefix 172.28.0.0/16 -Tag @{Owner="Jeff"}

#Each the of the following attributes are being added to the virtualnetwork object
#to be commited once the additions are complete. 
$subnetConfig = Add-AzVirtualNetworkSubnetConfig -Name ZC-Backbone -AddressPrefix 172.28.1.0/24 -VirtualNetwork $virtualnetwork
$subnetConfig = Add-AzVirtualNetworkSubnetConfig -Name ZC-Auth -AddressPrefix 172.28.2.0/24 -VirtualNetwork $virtualnetwork
$subnetConfig = Add-AzVirtualNetworkSubnetConfig -Name ZC-Web -AddressPrefix 172.28.3.0/24 -VirtualNetwork $virtualnetwork

#The changes above are now committed to the object 
virtualnetwork | Set-AzVirtualNetwork


#The line shows all the information in the AzVirtualNetwork object 
Get-AzVirtualNetwork | more
=======
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
>>>>>>> 9575954f1982d3bf03945970150af8e285d8de69

