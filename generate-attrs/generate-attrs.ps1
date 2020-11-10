<#
    AUTHOR: MARCO LEWEKE
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [String]$Path,
    
    [Parameter(Mandatory=$true)]
    [string[]]$Components,
    
    [Parameter(Mandatory=$true)]
    [string]$Attribute,
    
    [Parameter(Mandatory=$false)]
    [string]$GeneratorPattern = "generated_{attr}_{num}_",
    
    [Parameter(Mandatory=$false)]
    [String]$DataType = "",

    [Parameter(Mandatory=$false)]
    [ValidateSet("TRACE", "DEBUG","INFO","WARN","ERROR")]
    [String]$LogLevel = "INFO",
    
    [Parameter(Mandatory=$false)]
    [switch]$Recurse,
    
    [Parameter(Mandatory=$false)]
    [switch]$SearchOnly
)
#PRESETS
if($DataType -eq "") { $DataType = "xhtml" }
#LOGGING
Function Is-RightLevel
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [String]$WriteLevel
    )

    $Levels = "TRACE", "DEBUG","INFO","WARN","ERROR"
    $LogPriority = $Levels.IndexOf($LogLevel)
    $WritePriority = $Levels.IndexOf($WriteLevel)
    return ($LogPriority -le $WritePriority)
}
Function Write-Log
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false)]
        [ValidateSet("TRACE", "DEBUG","INFO","WARN","ERROR")]
        [String]$Level = "INFO",

        [Parameter(Mandatory=$true)]
        [String]$Message,

        [Parameter(Mandatory=$false)]
        [String]$Logfile,

        [Parameter(Mandatory=$false)]
        [String]$Depth = 0
    )
    
    $stamp = (Get-Date).ToString("yyyy/MM/dd HH:mm:ss")
    $line = "$stamp $Level"
    for($i = 0; $i -le $Depth; $i++)
    {
        $line += "`t"
    }
    $line += $Message
    if(Is-RightLevel -WriteLevel $Level)
    {
        Write $line
        #TODO => write to logfile
    }

}
#FUNCTIONS
Function Pattern-HasCounter
{
    return ($GeneratorPattern -like "*{num}*")
}
Function Parse-Namespaces
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [System.IO.FileInfo]$FileParam
    )
    $IsReadableXml = $true
    try
    {
        [xml]$HelpFile = Get-Content $FileParam.FullName -ErrorAction Stop
    }
    catch
    {
        $IsReadableXml = $false
        Write-Log -Level WARN -Message ("COULD NOT PARSE FILE $FileParam")
    }
    $Namespaces = @()
    if($IsReadableXml)
    {
        foreach($Attribute in ($HelpFile.FirstChild.Attributes))
        {
            if($Attribute.Name -match "xmlns")
            {
                $_, $Identifier = $Attribute.Name.Split(":")
                $Namespaces += @{   Identifier = $Identifier 
                                    Path = $Attribute.Value }
            }
        }
    }
    return $Namespaces
}
Function Contains-Namespace
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [System.Object[]]$NamespacesParam,
        
        [Parameter(Mandatory=$true)]
        [String]$ComponentParam
    )
    $Prefix = ($ComponentParam.Split(":")[0])
    foreach($Namespace in $NamespacesParam)
    {
        if($Namespace.Identifier -eq $Prefix)
        {
            $true
        }
    }
    return $false
}
Function Is-File
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        $Item
    )

    return ((Get-Item $Item) -is [System.IO.FileInfo])
}
Function Calc-Counter
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [System.IO.FileInfo]$FileParam
    )

    $LiteralContent = [System.IO.File]::ReadAllText($FileParam.FullName)
    $NamePattern = $GeneratorPattern
    $NamePattern = $NamePattern.Replace("{attr}",$Attribute)
    $NumberRegex = "(\d+)"
    $NamePattern = $NamePattern.Replace("{num}",$NumberRegex)
    $Expression = Select-String -InputObject $LiteralContent -Pattern $NamePattern -AllMatches
    $Numbers = @()
    foreach($Match in $Expression.Matches.Value)
    {
        $LiteralNumber = Select-String -InputObject $Match -Pattern "(\d+)" -AllMatches | % { $_.Matches.Value.ToString() }
        [int32]$Number = 0
        $parsed = [int32]::TryParse($LiteralNumber, [ref] $Number)
        if($parsed)
        {
            $Numbers += $Number
        }
    }
    [int]$Result = 0
    if($Numbers.Count -gt 0)
    {
        $Result = ($Numbers | Measure-Object -Maximum).Maximum
    }
    return $Result
}
Function Create-Name
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [String]$NamePattern,

        [Parameter(Mandatory=$false)]
        [int32]$Iterator,

        [Parameter(Mandatory=$false)]
        [String]$AttributeParam
    )

    $ResultName = $NamePattern
    if($Iterator) { $ResultName = $ResultName.Replace("{num}", $Iterator) }
    if($AttributeParam) { $ResultName = $ResultName.Replace("{attr}", $AttributeParam) }
    return $ResultName
}


#GET ACTUAL LIST OF FILES
$Files = @()
if((Is-File -Item $Path) -and ($Recurse))
{
    echo "SELECTED PATH IS A FILE AND PARAMETER 'RECURSE' MAKES NO SENSE."
}
if(Is-File -Item $Path)
{
    $Files += (Get-Item $Path)
}
elseIf($Recurse)
{
    $Files = (Get-ChildItem -Recurse -Include "*.$DataType" -Path $Path)
}
else
{
    $Files = (Get-ChildItem -Include "*.$DataType" -Path $Path)
}

#PROCESS FILES
$CentralCounter = 0
$FileCounter = 0
foreach($File in $Files)
{
    $FileChanges = 0
    Write-Log -Message "PROCESS FILE $File" -Level TRACE
    $ParsedNamespaces = Parse-Namespaces -FileParam $File
    if(! ($ParsedNamespaces.Count -eq 0))
    {
        $Document = New-Object System.Xml.XmlDocument
        $Document.PreserveWhitespace = $true
        [void]$Document.Load($File.FullName)
        $NamespaceManager = New-Object System.Xml.XmlNamespaceManager($Document.NameTable)
        $ParsedNamespaces | % { $NamespaceManager.AddNamespace($_.Identifier, $_.Path) }
        $MadeChanges = $false
        $EditedComponents = @()
        if(Pattern-HasCounter)
        {
            $Counter = Calc-Counter -FileParam $File
        }
        foreach($Component in $Components)
        {
            if(Contains-Namespace -NamespacesParam $ParsedNamespaces -ComponentParam $Component)
            {
                foreach($Element in ($Document.SelectNodes("//$Component", $NamespaceManager)))
                {
                    if(! $Element.HasAttribute($Attribute))
                    {
                        $(
                            $Counter++
                            $FileChanges++
                            $CentralCounter++
                            $NewAttribute = $Element.OwnerDocument.CreateAttribute($Attribute)
                            $NewValue = Create-Name -NamePattern $GeneratorPattern -Iterator $Counter -AttributeParam $Attribute
                            $NewAttribute.Value = $NewValue
                            $Element.Attributes.Append($NewAttribute)
                            $MadeChanges = $true
                            $EditedComponents += @{ Element = $Element.Name
                                                    Value = $NewValue }
                        ) | Out-Null
                    }
                }
            }
        }
        if($MadeChanges)
        {
            $FileCounter++
            Write-Log -Message "GENERATED $FileChanges ATTRIBUTES ON $File" -Level INFO
            foreach($Component in $EditedComponents)
            {
                Write-Log -Message "-> $($Component.Value) ON $($Component.Element)" -Level DEBUG -Depth 1
            }
            if(! $SearchOnly) { $Document.Save($File.FullName) }
        }
    }
    else
    {
        Write-Log -Message "COULD NOT PARSE FILE $File" -Level WARN
    }
}
if($SearchOnly)
{
    $Conclusion = "SEARCH FINISHED: $CentralCounter MISSING ATTRIBUTES ON $FileCounter FILES."
}
else
{
    $Conclusion = "SCRIPT FINISHED: $CentralCounter CHANGES ON $FileCounter FILES."
}
Write-Log -Message $Conclusion -Level INFO