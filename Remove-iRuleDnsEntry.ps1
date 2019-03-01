function Remove-iruleDnsEntry {
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

#escape website string
$dnsName = [regex]::escape($dnsname)

#match  $modifiedRule = $irule.Definition -split "`n" | Select-String -Pattern "`"$dnsName`".*$"
$match = $irule.Definition -split "`n" | Select-String -Pattern "`"$dnsName`".*$"

#only if a match change irule
if ( $match ){

    #Split text into lines, return all lines without line matching DNS
    $modifiedRule = $irule.Definition -split "`n" | Select-String -Pattern "`"$dnsName`".*$" -notMatch | Out-String
    #Backup existing irule and only run replace if 
    if ( Set-iRule -name ("$iruleName" + "_backup") -iRuleContent $irule.Definition ){

        try{
            Replace-irule -name $iruleName -irulecontent $modifiedRule | Out-Null
            $match.matches
            Write-Verbose "Update succeeded.  Removing backup...."
            $remove = "$iruleName" + "_backup"
            Remove-iRule -Name $remove -Confirm: $false
            Write-Verbose "Removed backup $remove."
          
        }

        catch {
            
           Write-Warning "There was an error updating the irule. Please check the syntax of your rule."
           Write-Error $_.errordetails
        }

        
    }

    else {

        Write-Warning "Please remove existing iRule backup."
    }
}

}#end