function Get-CountVariables {
	param (
		[Parameter(Mandatory=$true)]
		[string] $inputDirectory
	)

# Define the regex pattern to match the header
$pattern = "(?:\{(?=\b)|\{\s*)(.*):"

# Initiate an Array to hold header names
$newVariableNameList = @()

$scriptFormat = @()


$fileNameArray = Get-FileArray -dirPath $inputDirectory

foreach($file in $fileNameArray){
	$cleanContent = Clean-TextArray -dirPath $inputDirectory -fileName $file
# Split the content based on "}"
	$splitContent = $cleanContent -split "\}"
	
	foreach ($value in $splitContent){
		if ($value -ne ""){
			$variableName = Extract-Name -input $value -regexPattern $pattern
			$newVariableNameList += $variableName
		}	
	}
}


foreach ($name in $newVariableNameList){	
		$noWhiteSpaces = $name -replace '\s+', ''
		$arrayFormat = "`"" + $noWhiteSpaces + "`",`n"
		$scriptFormat += $arrayFormat
		
		$noWhiteSpaces = $null
		$variableFormat = $null
}

$string = ""

foreach($x in $scriptFormat){
	$string += $x
}

 $removeLastComma = $string -replace ',(?=\n\z)', ''
 $finalArray = "`$variableList = @(" + $removeLastComma + ")"


# Not Matched
foreach ($name in $newVariableNameList){
	if (($name -notmatch $positivePattern) -and ($name -notmatch $negativePattern)){
		Write-Host "$name not matched"
	}	
}

Return $finalArray

}