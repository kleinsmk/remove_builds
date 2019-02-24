Function Replace-iRule 
{
    <#
        .SYNOPSIS
            Updates the content of an irule
        .DESCRIPTION
            Update an existing iRule.
     
        .PARAMETER iRuleContent
            The content of the iRule (as a string).
            Alias: iRuleContent
        .PARAMETER Partition
            The partition on the F5 to put the iRule on. The full path will be /Partition/iRuleName.
        .EXAMPLE
            Set-iRule -name 'NameThatMakesSense' -iruleConente $string
    #>
    [cmdletbinding(SupportsShouldProcess = $True)]
    param (
        $F5Session = $Script:F5Session,
        [Parameter(Mandatory)]
        [string]$Name,
        [Alias('apiAnonymous')]
        [Parameter(Mandatory)]
        [string]$iRuleContent,
        [string]$Partition = 'Common'
    )
    
    begin {
        $URI = ($F5Session.BaseURL + "rule/$Name")
    }
    
    process {
        
        $kind = 'tm:ltm:rule:rulestate'
        
        $iRuleFullName = "/$Partition/$Name"
            
        $JSONBody = @{
            kind         = $kind
            name         = $Name
            partition    = $Partition
            fullPath     = $Name
            apiAnonymous = $iRuleContent
        }
                
        $JSONBody = $JSONBody | ConvertTo-Json -Compress
        
        # Caused by a bug in ConvertTo-Json https://windowsserver.uservoice.com/forums/301869-powershell/suggestions/11088243-provide-option-to-not-encode-html-special-characte
        # '<', '>', ''' and '&' are replaced by ConvertTo-Json to \\u003c, \\u003e, \\u0027, and \\u0026. The F5 API doesn't understand this. Change them back.
        $ReplaceChars = @{
            '\\u003c' = '<'
            '\\u003e' = '>'
            '\\u0027' = "'"
            '\\u0026' = "&"
        }

        foreach ($Char in $ReplaceChars.GetEnumerator()) 
        {
            $JSONBody = $JSONBody -replace $Char.Key, $Char.Value
        }
        
            if ($pscmdlet.ShouldProcess($F5Session.Name, "Uploading iRule $Name"))
            {
                Invoke-RestMethodOverride -Method PATCH -URI "$URI" -Body $JSONBody -ContentType 'application/json' -WebSession $F5Session.WebSession
            }
            
            }
        
    }
