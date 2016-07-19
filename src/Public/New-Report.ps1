$TemplatePath = Join-Path $PSModuleRoot Templates

$ChartTemplate = @'
    <div class="card panel ${Emphasis}">
        <div class="panel-header"><h4 class="panel-title">${Title}</h4></div>
        <div class="panel-body" id="chart${id}"></div>
        <div class="panel-body">${Description}</div>
    </div>
    <script>
        $(function() {
            new Chartkick.${ChartType}("chart${id}", ${data});
        })
    </script>
'@

$TableTemplate = @'
    <div class="row">
        <div class="col-xs-16">
            <div class="panel ${emphasis}">
                <div class="panel-heading"><h4 class="panel-title">${Title}</h4></div>
                <div class="panel-body">${Description}</div>
                <table class="table table-striped">
                ${data}
                </table>
            </div>
        </div>
    </div>
'@
function New-Report {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions")]
    [CmdletBinding()]
    param(
        # The template to use for the report (must exist in templates folder)
        [Parameter()]
        [string]
        $Template = "template.html",

        # The title of the report
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $Title,
        
        # A sentence or two describing the report
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $Description,

        # The author of the report
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $Author=${Env:UserName},

        [Parameter(ValueFromPipeline)]
        $InputObject
    )
    
    begin {
        Write-Debug "Beginning $($PSBoundParameters | Out-String)"
        if($Template -notmatch "\.html$") { $Template += ".html" }
        if(!(Test-Path $Template)) {
            $Template = Join-Path $TemplatePath $Template
            if(!(Test-Path $Template)) {
                Write-Error "Template file not found in Templates: $Template"
            }
        }

        $TemplateContent = Get-Content $Template -Raw
        $FinalTable = @()
        $FinalChart = @()
        $Index = 0
        $Finished = $false

        if($InputObject -is [ScriptBlock]) {
            $null = $PSBoundParameters.Remove("InputObject")
            & $InputObject | New-Report @PSBoundParameters
            $Finished = $true
            return
        }
    }
    
    process {
        if($Finished) { return }
        Write-Debug "Processing $($_ | Out-String)"
        if($Title) {
            $FinalTitle = [System.Security.SecurityElement]::Escape($Title)
        }
        if($Description) {
            $FinalDescription = [System.Security.SecurityElement]::Escape($Description)
        }
        if($Author) {
            $FinalAuthor = [System.Security.SecurityElement]::Escape($Author)
        }
        
        if($InputObject -is [ScriptBlock]) {
            $Data = & $InputObject
        }
        elseif($InputObject -is [DataWrapper]) {
            if($InputObject.Data -is [ScriptBlock]) {
                $Data = & $InputObject.Data
            } else {
                $Data = $InputObject.Data
            }
        }
        else {
            $Data = $InputObject
        }

        if($InputObject -is [Table]) {
            $Data = $Data | Microsoft.PowerShell.Utility\ConvertTo-Html -As Table -Fragment
            $Data = $Data | Microsoft.PowerShell.Utility\Select-Object -Skip 1 -First ($Data.Count -2)

            $Table = $TableTemplate -replace '\${Title}', $InputObject.Title `
                                    -replace '\${Description}', $InputObject.Description `
                                    -replace '\${Emphasis}', $("panel-" + $InputObject.Emphasis) `
                                    -replace '\${Data}', $Data

            $FinalTable += $Table
        }
        if($InputObject -is [Chart]) {
            if($Data -isnot [string]) {
                # Microsoft's ConvertTo-Json doesn't handle PSObject unwrapping properly
                # https://windowsserver.uservoice.com/forums/301869-powershell/suggestions/15123162-convertto-json-doesn-t-serialize-simple-objects-pr
                # To bypass this bug, we must round-trip through the CliXml serializer 
                $TP = [IO.Path]::GetTempFileName()
                Export-CliXml -InputObject $Data -LiteralPath $TP
                $Data =Import-CliXml -LiteralPath $TP | ConvertTo-json
                Remove-Item $TP
                # $Data = Microsoft.PowerShell.Utility\ConvertTo-Json -InputObject $Data
            }

            $Chart = $ChartTemplate -replace '\${Title}', $InputObject.Title `
                                    -replace '\${Description}', $InputObject.Description `
                                    -replace '\${Emphasis}', $("panel-" + $InputObject.Emphasis) `
                                    -replace '\${ChartType}', $InputObject.ChartType `
                                    -replace '\${Data}', $Data `
                                    -replace '\${id}', ($Index++)

            $FinalChart += $Chart
        }
    }
    
    end {
        if($Finished) { return }
        Write-Debug "Ending $($PSBoundParameters | Out-String)"
        $Output = $TemplateContent -replace '\${Title}', $FinalTitle `
                              -replace '\${Description}', $FinalDescription `
                              -replace '\${Author}', $FinalAuthor `
                              -replace '\${Tables}', ($FinalTable -join "`n`n") `
                              -replace '\${Charts}', ($FinalChart -join "`n")
        Write-Output $Output
    }
}