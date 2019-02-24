function Remove-iruleDns {
<#
.SYNOPSIS
    Remove line from the irule switch statement in the form "training.rcrp.boozallencsn.com" { virtual uat-rcrp_https} .
    This cmdlet will backup the existing irule with the existing name and _backup applied. 

.PARAMETER dnsName

    Name of dns entry to remove.

.PARAMETER iruleName

    irule name to edit.  

.EXAMPLE
    Remove-iruleDns -dnsName pizzparty.com -iruleDName WSA_https
    
    
.EXAMPLE

#>
    [cmdletBinding()]
    param(
        
       
        [Parameter(Mandatory=$true)]
        [string]$dnsName='',

        [Alias("Allow or Deny")]
        [Parameter(Mandatory=$true)]
        [string]$iruleName=''


    )




$irule = Get-iRule -Name $iruleName

#Backup existing irule
Set-iRule -name "$iruleName" + "_backup" -iRuleContent $irule.Definition

#Split text into lines, return all lines without line matching DNS
$modifiedRule = $irule.Definition -split "`n" | Select-String -Pattern "`"$dns`"\s{\svirtual\s[a-zA-Z0-9_].*}" -NotMatch | Out-String

Replace-irule -name $iruleName -irulecontent $modifiedRule



}