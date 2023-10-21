<# 
************************************************************************************************************************************
This script joins the server to an existing XenDesktop 7.x site

This script is created using this sites as references:
archy.net - Citrix XenDesktop 7 – Unattended Installation + Site join - http://bit.ly/12kUoSR
Thx to Stephane Thirion @ archy.net

Author: Kasper Johansen, Atea Denmark - kasper.johansen@atea.dk
Date: 20-06-2015

************************************************************************************************************************************
$XDC = "" Computername of any existing XenDesktop 7.x Delivery Controller

************************************************************************************************************************************
#>

$XDC = ""

# Do not edit below this line, unless you know what you are doing!
# ---------------------------------------------------------------#
Write-Host
Write-Host -BackgroundColor Green -ForegroundColor Black "Joining existing XenDesktop 7.x site"
Write-Host

# Import modules and snapins
Import-Module Citrix.XenDesktop.Admin  
Add-PSSnapin Citrix.*

# Join XenDesktop 7.x Site
Add-XDController -SiteControllerAddress $XDC