<#
.SYNOPSIS
This script adds vanity domains to an Office 365 tenant from a csv list

.DESCRIPTION
csv input format is column A with "domains" in row 1 and list of domains to be added in row 2-X
Office 365 limits unverified domains to 95

.NOTES
1.0 - 

Add-VanityDomain.ps1
v1.0
1/23/2019
By Nathan O'Bryan, MVP|MCSM
nathan@mcsmlab.com

.LINK
https://www.mcsmlab.com/about
#>
Clear-Host

#Check for AzureAD PowerShell Module
If (-not (Get-Module -Name MSOnline) )
    {
        Write-Host -ForegroundColor Red "Azure AD Module is not installed on this machine"
        Write-Host -ForegroundColor Red "Installing Azure AD PowerShell Module"
        Write-Host -ForegroundColor Yellow "Rerun this script once install completes"
        Install-Module MSOnline
        Exit
    }

#Connect to Azure Active Directory
Import-Module MSOnline
Connect-MsolService

#Define variables
$Domains = Import-Csv .\domains.csv                                                
$TxtRecord = @()

#Add domains to Office 365 and pull verification txt records                                                                
ForEach ($Domain in $Domains)
    {                                                    
        New-MsolDomain -Name $Domain.domain                                                
        $TxtRecord += (Get-MsolDomainVerificationDNS -DomainName $Domain.domain -Mode DnsTxtRecord)        
    }                                                                    

#Output csv with verification txt records
$TxtRecord | Select-Object text,label,ttl | Export-Csv .\txtrecord.csv

#Disconnect from Azure AD
Set-AzureRmContext -Context ([Microsoft.Azure.Commands.Profile.Models.PSAzureContext]::new())
