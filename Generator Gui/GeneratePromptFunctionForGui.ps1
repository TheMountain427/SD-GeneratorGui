function Generate-Prompt {
		param (
		[Parameter(Mandatory=$true)]
		[array] $inputNameArray,
		[Parameter(Mandatory=$true)]
		[string] $inputDirectory,
		[ValidateSet("True","False")]
		[string]$AddAdj = $false
	)

# Define the regex pattern to match the header
$pattern = "(?:\{(?=\b)|\{\s*)(.*):"
$cleanPattern = "(?!\{)^.*|^(?=\s*$)"
$emptyString = "^(?=\s*$)"


# Initiate an Array to hold header names
$newVariableNameList = @()

$fileNameArray = Get-FileArray -dirPath $inputDirectory

$valueArray = @()

foreach($file in $fileNameArray){
	$cleanContent = Clean-TextFile -dirPath $inputDirectory -fileName $file
	# Split the content based on "}"
	$splitContent = $cleanContent -split "\}"
	
	foreach ($value in $splitContent){
		if ($value -ne ""){
			$variableName = Extract-Name -input $value -regexPattern $pattern
			$variableName = $variableName -replace '\s+', ''
			$newVariableNameList += $variableName
			# Create a temporary array to hold the split content, remove the header and last empty newline
			$tempArray = $value -split "`r`n" 
			foreach($line in $tempArray){
				if(($line -match $cleanPattern) -and ($line -notmatch $emptyString)){
					$valueArray += $line 
				}
			}
			# Create a new variable matching the header name with the value of the split array
			if (-not(Get-Variable $variableName -ErrorAction "SilentlyContinue")){
				New-Variable -Name $variableName -Value $valueArray
				$varibleName = $null
				$valueArray = @()
			}
			
			
		}	
	}
}

$startFlagPositive = "--prompt"
$flagPattern = "(.*_Pos)"
$positiveFlag = Build-Flag -NameArray $inputNameArray -NamePattern $flagPattern -InputSwitch $startFlagPositive -AddAdj $AddAdj

$startFlagNegative = " --negative_prompt"
$flagPattern = "(.*_Neg)"
$negativeFlag = Build-Flag -NameArray $inputNameArray -NamePattern $flagPattern -InputSwitch $startFlagNegative -AddAdj $AddAdj

$startFlagSteps = " --steps"
$flagPattern = "((?i)steps)"
$stepsFlag = Build-Flag -NameArray $inputNameArray -NamePattern $flagPattern -InputSwitch $startFlagSteps

$startFlagCFG = " --cfg"
$flagPattern = "((?i)cfg)"
$CFGFlag = Build-Flag -NameArray $inputNameArray -NamePattern $flagPattern -InputSwitch $startFlagCFG

$startFlagSampler = " --sampler"
$flagPattern = "((?i)sampler)"
$samplerFlag = Build-Flag -NameArray $inputNameArray -NamePattern $flagPattern -InputSwitch $startFlagSampler

$startFlagWidth = " --width"
$flagPattern = "((?i)width)"
$widthFlag = Build-Flag -NameArray $inputNameArray -NamePattern $flagPattern -InputSwitch $startFlagWidth

$startFlagHeight = " --height"
$flagPattern = "((?i)height)"
$heightFlag = Build-Flag -NameArray $inputNameArray -NamePattern $flagPattern -InputSwitch $startFlagHeight

$startFlagSeed = " --seed"
$flagPattern = "((?i)seed$)"
$seedFlag = Build-Flag -NameArray $inputNameArray -NamePattern $flagPattern -InputSwitch $startFlagSeed

$startFlagSubSeed = " --subseed"
$flagPattern = "((?i)subseed$)"
$subseedFlag = Build-Flag -NameArray $inputNameArray -NamePattern $flagPattern -InputSwitch $startFlagSubSeed

$startFlagSubSeedStrength = " --subseed_strength"
$flagPattern = "((?i)subseedstrength$)"
$subSeedStrengthFlag = Build-Flag -NameArray $inputNameArray -NamePattern $flagPattern -InputSwitch $startFlagSubSeedStrength

$startFlagBatchSize = " --batch_size"
$flagPattern = "((?i)batchsize)"
$batchSizeFlag = Build-Flag -NameArray $inputNameArray -NamePattern $flagPattern -InputSwitch $startFlagBatchSize

$finalPrompt = $positiveFlag + $negativeFlag + $stepsFlag + $cfgFlag + $samplerFlag + $widthFlag + $heightFlag + $seedFlag + $subSeedFlag + $subSeedStrengthFlag + $batchSizeFlag + "`n"

Return $finalPrompt 

}