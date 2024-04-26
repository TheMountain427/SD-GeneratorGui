# Loop through each file name and add it to the array
function Get-FileArray {
	param (
		[Parameter(Mandatory=$true)]
		[string] $dirPath
	)
	# Create an empty array to store the file names
	$nameArray = @()
	
	# Get the list of file names in the directory
	$fileNames = Get-ChildItem -Path $dirPath | Select-Object -ExpandProperty Name
	
	# Loop through each file name and add it to the array
	foreach ($fileName in $fileNames) {
		$nameArray += $fileName
	}
	Return $nameArray
}

function Extract-Name {
	param (
		[Parameter(Mandatory=$true)]
		[string] $input,
		[Parameter(Mandatory=$true)]
		[string] $regexPattern
	)
	if ($value -match $pattern) {
		# Temporary variable to hold the Header name
		$variableName = $Matches[1] # $Matches[1] = the value returned by the regex match
		
		# Add header name to an array so it can be called later			
		Return $variableName
	}
}

function Clean-TextFile {
	param (
		[Parameter(Mandatory=$true)]
		[string] $dirPath,
		[Parameter(Mandatory=$true)]
		[string] $fileName
	)
	$filePath = Join-Path -Path $dirPath -ChildPath $fileName
	# Read the content of the text file
	$content = Get-Content -Path $filePath -Raw

	# Remove empty lines and join the non-empty lines with newline characters
	$content = ($content -split "`r?`n" | Where-Object { $_ -match '\S' }) -join "`r`n"

	Return $content
}
# Create a function to randomly select values from an array, with parameters of input array an count
function Get-RandomElements {
	# $RandomSelection = Get-RandomElements -Array $MyArray -NumberOfElements $NumberOfElementsToSelect
    param (
        [Parameter(Mandatory=$true)]
        [array]$Array,
        [Parameter(Mandatory=$true)]
        [int]$NumberOfElements
    )

    # Check if the number of elements to select is greater than the array size
    if ($NumberOfElements -gt $Array.Count) {
        Write-Error "Number of elements to select exceeds array size of $Array"
        return
    }

    # Create an array to store randomly selected elements
    $RandomElements = @()
	$previousElements = @()
    # Generate random indexes and select elements
    for ($i = 0; $i -lt $NumberOfElements; $i++) {
        $RandomIndex = Get-Random -Minimum 0 -Maximum $Array.Count
		while ($previousElements -contains $Array[$RandomIndex]){
			$RandomIndex = Get-Random -Minimum 0 -Maximum $Array.Count
		}
		$RandomElements += $Array[$RandomIndex]
		$previousElements += $Array[$RandomIndex]
    }

    # Output the randomly selected elements
    return $RandomElements
}

function Clean-Values {
	 param (
		[Parameter(Mandatory=$true)]
		[string]$InputValue
    )
		$noTabs = $inputValue -replace '\t+', ''
		$cleanCommas = $noTabs -replace "(?<=\b|[\]\)\>])\s*,\s*", ', '
		$cleanNewLines = $cleanCommas -replace "^\s+\b", ''
		$oneSpace = $cleanNewLines -replace "\s\s+", ' '
		$outputValues = $oneSpace
	Return $outputValues
}

function Clean-TextArray {
	param (
		[Parameter(Mandatory=$true)]
		[string] $dirPath,
		[Parameter(Mandatory=$true)]
		[string] $fileName
	)
	$filePath = Join-Path -Path $dirPath -ChildPath $fileName
	# Read the content of the text file
	$content = Get-Content -Path $filePath -Raw

	# Remove empty lines and join the non-empty lines with newline characters
	$content = ($content -split "`r?`n" | Where-Object { $_ -match '\S' }) -join "`r`n"

	Return $content
}

function Build-Flag {
    param (
        [Parameter(Mandatory=$true)]
        [array]$NameArray,
		[Parameter(Mandatory=$true)]
		[string]$NamePattern,
		[Parameter(Mandatory=$true)]
		[string]$InputSwitch,
		[ValidateSet("True","False")]
		[string]$AddAdj = $false
    )
	$cleanArray = @()
	$partialFlags = ""
	# $adjPattern = "(Adjectives)"
	# find the adjectives
	# if($addAdj = $true){
		# foreach ($nameValue in $NameArray){
			# if ($nameValue -match $adjPattern){
				# $adjArray = Get-Variable
			# }
	# }
	foreach ($nameValue in $NameArray){
		if ($nameValue -match $NamePattern){
			# Find the created variable that matches the current variable, set its value to a temporary array
			$nameValueArray = Get-Variable -Name $nameValue -ValueOnly
			# Find the count that matches the created variables name 
			$nameValueCount = $nameValue + "_CT" 
			$nameAdjVariable = $nameValue + "_Adj"
			$adjVariableValue = Get-Variable -Name $nameAdjVariable -ValueOnly
			# Test that a count has been defined for the variable
			if(Get-Variable -Name $nameValueCount){ 
				$numberOfValues = Get-Variable -Name $nameValueCount -ValueOnly
				# Get random values in the array and store them in a temporary variable
				$randomElementArray = Get-RandomElements -Array $nameValueArray -NumberOfElements $numberOfValues
				$randomAdjElementArray = @()
				# if adj switch is enabled for both globally and for the variable, give a 50% chance to add an adj to each token
				if(($AddAdj -eq $true) -and ($adjVariableValue -eq 1)){
					foreach ($element in $randomElementArray){
						$rejoinedElement = ""
						$splitElements = $element -split ','
						foreach($splitElement in $splitElements){
							if($splitElement -notmatch "^\s+$|\0|^$" ){
								$adj = $Adjectives | Get-Random 
								$randomNumber = Get-Random -Minimum 1 -Maximum 100
								if ($randomNumber -le 50){
									$splitElement = $adj + $splitElement
								}
							}
							if($splitElement -notmatch "^\s+$|\0|^$" ){
								$splitElement += ", "
								$rejoinedElement += $splitElement
							}								
						}
						$element = $rejoinedElement
						$randomAdjElementArray += $element
					}
				$randomElementArray = $randomAdjElementArray
				}
				
				# Join the randomly chosen values to the prompt
				foreach ($element in $randomElementArray){
					$cleanValue = Clean-Values -InputValue $element
					$cleanArray += $cleanValue
					
					
				}
				$randomAdjElementArray = @()
			}
		}
	}
	if ($cleanArray.Count -gt 0) {
	$randomOrderArray = $cleanArray | Get-Random -Count $cleanArray.Count
	}
	foreach ($string in $randomOrderArray){
		$partialFlags = $partialFlags + $string
	}
	
	$removedLastComma = $partialFlags -replace ",\s$", ''
	$outputFlag = $InputSwitch + " `"" + $removedLastComma + "`"`t"
	$emptyFlag = $InputSwitch + " `"" + ""+ "`"`t"
	if($outputFlag -match $emptyFlag){
		$outputFlag = ""
	}
	Return $outputFlag
}
