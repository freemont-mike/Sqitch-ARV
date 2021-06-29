param([string]$param) #Accepts directory, file and environment

$connFile = Get-Content sqitch.conf #Gets content of the Sqitch configuration file

#Fetching syntaxes defined in the dictionary, add more as per your need on the CSV
$csv = Import-Csv -Path .\PostgreSQLDictionary.csv
$expression = $csv.Expression  
$revert = $csv.Revert   
$verify = $csv.Verify
$check = $csv.Check  
$fetch = $csv.Fetch

$folder = $param.Split("/")[0]
$filename = $param.Split("/")[1]
$path = $folder+"/"+$fileName

if(test-path deploy/$path.sql) #Checks if the file exists
    {
    $file = Get-Content deploy/$path.sql #Gets content of the deploy script

    $options = [Text.RegularExpressions.RegexOptions]'IgnoreCase, Multiline' 

    $name, $val, $tval, $rev, $ver, $ind, $pos = @{}, @{}, @{}, @{}, @{}, @{}, 0 #Initializing variables

    #Compiling connection string from sqitch.conf based on the last parameter of the user input
    $environment= $param.Split("/")[2]
    $expression_ = '[target[\s]+"'+$environment+'"][\s]+uri[\s]+= (.*?) \['
    $conn = [regex]::Matches($connFile,($expression_),$options)  
    $conf = $conn[0][0].Groups[1].value -replace '\s\s',''
    $connstr = "postgresql"+ $conf -replace 'db:pg',''

    for($a=0; $a -lt $expression.Count; $a++) 
    {
        $name[$a] = [regex]::Matches($file,($expression[$a]),$options) #Fetches matching scripts using the Regex on CSV
        for($j=0; $j -lt $name[$a].Count; $j++) 
            { 
            $pos++
            $ind[$pos] = $name[$a][$j].Index 
            $val[$name[$a][$j].Index] = $name[$a][$j].Groups[1].value -replace '\s\s',''
            
            #Check if the function/view exists
            $tval[$name[$a][$j].Index] = $val[$name[$a][$j].Index] -replace '\((.*?)\)', '' ` -replace '\s', ''
            $check_ = $check[$a] -replace '%%%', $tval[$name[$a][$j].Index] 
            $flag = "$check_" | psql -t $connstr
            $flag = $flag -replace '\s',''
            
            #If function or view exists, fetch definition from the DB to generate revert script for returning to current state
            if($flag -eq 0)
            {  
                $script = $fetch[$a] -replace '%%%', $tval[$name[$a][$j].Index] 
                $old_Script = "$script" | psql -t  -A -notemp $connstr
                (gc temp) | ? {$_.trim() -ne "" } | set-content temp
                $temp = Get-Content temp -Encoding UTF8 -Raw 
                $rev[$name[$a][$j].Index] = "$temp;"
                remove-item temp  
            } 

            #Fetches the revert script from CSV
            elseif($flag -eq 1)
            {
                $rev[$name[$a][$j].Index] = $revert[$a] -replace '%%%', $val[$name[$a][$j].Index] 
            }

            #Fetches the verify script from CSV 
            $ver[$name[$a][$j].Index] = $verify[$a] -replace '%%%', $tval[$name[$a][$j].Index] 
            }
            
    }

    #Sorting descending as we need to revert starting from the last deploy command to the first, to avoid dependency errors.
    $ind = $ind.Values | Sort -Descending 

    #Constructing content of revert and verify scripts
    $revert = "-- Revert for $path`n`nBEGIN;`n`n"
    $verify = "-- Verify for $path`n`nBEGIN;`n`n"

    for($a=0; $a -lt $ind.Count; $a++) 
    {
        $revert += $rev[$ind[$a]] + "`n"
        $verify += $ver[$ind[$a]] + "`n"
    }

    $revert += "`nCOMMIT;"
    $verify += "`nROLLBACK;"
    #End of script construction

    #Creating and writing to revert and verify scripts
    Write-Output $revert | out-file -filepath revert/$path.sql
    Write-Output $verify | out-file -filepath verify/$path.sql
    #End of writing

    echo "`nSuccessfully generated revert and verify scripts.`n"
    }

else
    {
    echo "`nUnable to find 'deploy\$path.sql'.`nGenerating revert and verify scripts failed.`n"
    }
 





 
 




