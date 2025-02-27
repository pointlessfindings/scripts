<#
    .SYNOPSIS
    This script blocks several PowerShell modules with the exception of a specified group. 

    .PARAMETER groupObjectId
    ObjectId of the group that will continue to have access to these PowerShell modules. 

    .NOTES
    Author: Pointless Findings
    https://pointlessfindings.com
#>

Param (
    [Parameter(Mandatory=$true)]
    [string] $groupObjectId
)

# connect to MS Graph with the required scopes
$session = Connect-MgGraph -Scopes "Application.ReadWrite.All", "AppRoleAssignment.ReadWrite.All", "User.ReadWrite.All", "Directory.ReadWrite.All" -NoWelcome

# collection of appIds to block access to
$appIds = @(
    "1b730954-1685-4b74-9bfd-dac224a7b894" #MSOL/AzureAD
    "14d82eec-204b-4c2f-b7e8-296a70dab67e" #MS Graph
    "fb78d390-0c51-40cd-8e17-fdbfab77341b" #EXOv3
    "9bc3ab49-b65d-410a-85ad-de819febfddc" #SharePoint
    "12128f48-ec9e-42f0-b203-ea49fb6af367" #Teams
    "aad98258-6bb0-44ed-a095-21506dfb68fe" #Universal Print
    "1950a258-227b-4e31-a9cf-717495945fc2" #Az/AzureRM/PowerApps
    "90f610bf-206d-4950-b61d-37fa6fd1b224" #AADRM/AIPService
    "23d8f6bd-1eb0-4cc2-a08c-7bf525c67bcd" #Power BI Powershell
)

Foreach ($appId in $appIds) {

    # check if service principal exists in tenant, if not then add it
    $sp = Get-MgServicePrincipal -Filter "appId eq '$appId'"
    if (-not $sp) {
        $sp = New-MgServicePrincipal -AppId $appId
    }

    # require user assignment for the service principal
    Update-MgServicePrincipal -ServicePrincipalId $sp.Id -AppRoleAssignmentRequired

    # assign the group access to the service principal
    New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $sp.Id -ResourceId $sp.Id -PrincipalId $groupObjectId
}