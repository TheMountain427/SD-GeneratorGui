#------[Initialisations]------
# Init PowerShell Gui
Add-Type -AssemblyName System.Windows.Forms

$inputDirectory = "$PSScriptRoot\Prompt Collections"
$outputDirectory = "$PSScriptRoot\z.PromptOutput.txt"
$workingDirectory = "$PSScriptRoot"
$pathToVariableList =  Join-Path -Path $workingDirectory -ChildPath "VariableListSettings.ps1"
$pathToVariableCount = Join-Path -Path $workingDirectory -ChildPath "VariableCountSettings.ps1"
$pathToVariableAcceptsAdj = Join-Path -Path $workingDirectory -ChildPath "VariableAcceptsAdj.ps1"

$pathToFunctions = Join-Path -Path $workingDirectory -ChildPath "BaseFunctions.ps1"
$pathToGetCountVariables = Join-Path -Path $workingDirectory -ChildPath "CountVariablesFunctionForGui.ps1"
$pathToGeneratePrompt = Join-Path -Path $workingDirectory -ChildPath "GeneratePromptFunctionForGui.ps1"


#---------[Form Functions]----------
function AutoSizeControl {
    param (
        [System.Windows.Forms.Control]$control,
        [int]$textPadding
    )

    # Create a Graphics object for the Control.
    $g = $control.CreateGraphics()

    # Get the Size needed to accommodate the formatted Text.
    $preferredSize = $g.MeasureString($control.Text, $control.Font).ToSize()

    # Pad the text and calculate the new size.
    $newWidth = $preferredSize.Width + ($textPadding * 2)
    $newHeight = $preferredSize.Height + ($textPadding * 2)

    # Set the new size of the control.
    $control.Width = $newWidth
    $control.Height = $newHeight

    # Clean up the Graphics object.
    $g.Dispose()
}

#---------[Form]------------

# Create a new form
$generatorForm                             = New-Object system.Windows.Forms.Form

# Define the size, title and background color
$generatorForm.ClientSize                  = '1000,550'
$generatorForm.text                        = "Generator"
$generatorForm.BackColor                   = "#232323"
$generatorForm.StartPosition               =  [System.Windows.Forms.FormStartPosition]::CenterScreen
$generatorForm.TopLevel                    = $true
$generatorForm.TopMost                     = $false

# Create a Title for our form. We will use a label for it.
$Header                                    = New-Object system.Windows.Forms.Label
$Header.text                               = "Variables"
$Header.AutoSize                           = $true
$Header.location                           = New-Object System.Drawing.Point(20,20)
$Header.Font                               = 'Microsoft Sans Serif,13'
$Header.ForeColor                          = "#ffffff"

$headerDescription                         = New-Object system.Windows.Forms.Label
$headerDescription.text                    = "Change variable counts:"
$headerDescription.AutoSize                = $true
$headerDescription.location                = New-Object System.Drawing.Point(20,50)
$headerDescription.Font                    = 'Microsoft Sans Serif,10'
$headerDescription.ForeColor               = "#ffffff"
AutoSizeControl -control $headerDescription -textPadding 5

$refreshVariablesBtn                       = New-Object system.Windows.Forms.Button
$refreshVariablesBtn.BackColor             = "#e6e0c8"
$refreshVariablesBtn.text                  = "Refresh Variables"
$refreshVariablesBtn.AutoSize              = $true
$refreshVariablesBtn.location              = New-Object System.Drawing.Point(($headerDescription.Left),($headerDescription.Top + 20))
$refreshVariablesBtn.Font                  = 'Microsoft Sans Serif,10'
$refreshVariablesBtn.ForeColor             = "#313131"

$guideVariableLabel                        = New-Object system.Windows.Forms.Label
$guideVariableLabel.text                   = "I SHOULD BE HIDDEN"
$guideVariableLabel.AutoSize               = $true
$guideVariableLabel.location               = New-Object System.Drawing.Point(20,($headerDescription.Bottom + 10))
$guideVariableLabel.Font                   = 'Microsoft Sans Serif,10'
$guideVariableLabel.Visible                = $false

$guideTxtBox                               = New-Object system.Windows.Forms.TextBox
$guideTxtBox.Height                        = 20
$guideTxtBox.Width                         = 50
$guideTxtBox.location                      = New-Object System.Drawing.Point(200,$guideVariableLabel.Top)
$guideTxtBox.Visible	                   = $false
# $varibleTxtBox.MaxLength                 =

$setVariablesBtn                           = New-Object system.Windows.Forms.Button
$setVariablesBtn.BackColor                 = "#e6e0c8"
$setVariablesBtn.text                      = "Set Variables"
$setVariablesBtn.AutoSize                  = $true
$setVariablesBtn.location                  = New-Object System.Drawing.Point(($refreshVariablesBtn.Right + 90),($refreshVariablesBtn.Top))
$setVariablesBtn.Font                      = 'Microsoft Sans Serif,10'
$setVariablesBtn.ForeColor                 = "#313131"
$setVariablesBtn.Visible                   = $true

$generatePromptBtn                         = New-Object system.Windows.Forms.Button
$generatePromptBtn.BackColor               = "#e6e0c8"
$generatePromptBtn.text                    = "Generate Prompt"
$generatePromptBtn.AutoSize                = $true
$generatePromptBtn.location                = New-Object System.Drawing.Point(($setVariablesBtn.Right + 120),($setVariablesBtn.Top))
$generatePromptBtn.Font                    = 'Microsoft Sans Serif,10'
$generatePromptBtn.ForeColor               = "#313131"
$generatePromptBtn.Visible                 = $true

$promptTxtBox                              = New-Object system.Windows.Forms.TextBox
$promptTxtBox.Multiline                    = $true
$promptTxtBox.ScrollBars                   = [System.Windows.Forms.ScrollBars]::Vertical
$promptTxtBox.AcceptsReturn                = $true
# $promptTxtBox.
$promptTxtBox.Height                       = 200
$promptTxtBox.Width                        = 500
$promptTxtBox.location                     = New-Object System.Drawing.Point(($guideTxtBox.Right + 100),($guideVariableLabel.Top + 50))
$promptTxtBox.Visible	                   = $true
$promptTxtBox.ForeColor                    = "#ffffff"
$promptTxtBox.BackColor                    = "#555555"
$promptTxtBox.Font                         = 'Microsoft Sans Serif,10'
$promptTxtBox.Add_KeyDown({
    param($sender, $event)
    if ($event.Control -and $event.KeyCode -eq 'A') {
        $sender.SelectAll()
        $event.Handled                     = $true
    }
})

$promptAmountLabel                         = New-Object system.Windows.Forms.Label
$promptAmountLabel.text                    = "Number of Prompts to Generate:"
$promptAmountLabel.AutoSize                = $true
$promptAmountLabel.location                = New-Object System.Drawing.Point(($guideTxtBox.Right + 100),($guideVariableLabel.Top + 20))
$promptAmountLabel.Font                    = 'Microsoft Sans Serif,10'
$promptAmountLabel.ForeColor               = "#ffffff"
AutoSizeControl -control $promptAmountLabel -textPadding 5

$promptAmountBox                           = New-Object system.Windows.Forms.NumericUpDown
$promptAmountBox.Value                     = 1
$promptAmountBox.Minimum                   = 1
$promptAmountBox.Maximum                   = 100
$promptAmountBox.Width                     = 50
$promptAmountBox.Increment                 = 1
$promptAmountBox.ForeColor                 = "#ffffff"
$promptAmountBox.BackColor                 = "#555555"
$promptAmountBox.location                  = New-Object System.Drawing.Point(($promptAmountLabel.Right),($promptAmountLabel.Top))


$copyBtn                                   = New-Object System.Windows.Forms.Button
$copyBtn.Text                              = "Copy"
$copyBtn.AutoSize                          = $true
$copyBtn.BackColor                         = "#e6e0c8"
$copyBtn.ForeColor                         = "#313131"
$copyBtn.Font                              = 'Microsoft Sans Serif,10'
$copyBtn.Location                          = New-Object System.Drawing.Point(($generatePromptBtn.Right + 50), $generatePromptBtn.Top )
$copyBtn.Add_Click({ [System.Windows.Forms.Clipboard]::SetText($promptTxtBox.Text)})


$enableAdjLabel                         = New-Object system.Windows.Forms.Label
$enableAdjLabel.text                    = "Enable Adj addition?:"
$enableAdjLabel.AutoSize                = $true
$enableAdjLabel.location                = New-Object System.Drawing.Point(($promptAmountBox.Right + 20),($guideVariableLabel.Top + 20))
$enableAdjLabel.Font                    = 'Microsoft Sans Serif,10'
$enableAdjLabel.ForeColor               = "#ffffff"

$enableAdjCheckBox 		= New-Object System.Windows.Forms.CheckBox
$enableAdjCheckBox.Location = New-Object System.Drawing.Point(($enableAdjLabel.Right + 35), ($enableAdjLabel.Top - 3))
$enableAdjCheckBox.Name = "EnableAdj"


$generatorForm.controls.AddRange(@($Header,$headerDescription,$refreshVariablesBtn,$varibleTxtBox,$variableLabel,$setVariablesBtn,$generatePromptBtn,$promptTxtBox,$promptAmountLabel,$promptAmountBox,$copyBtn,$enableAdjLabel,$enableAdjCheckBox))


#---------[Script Functions]----------

# function Base Functions
. $pathToFunctions

# function Get-CountVariables
. $pathToGetCountVariables

# function Generate-Prompt
. $pathToGeneratePrompt

function GetAndDrawVariables{
	
	Get-CountVariables -inputDirectory $inputDirectory | Out-File -FilePath $pathToVariableList
	$pad = 20

	# dot source variables from a settings.ps1 file
	. $pathToVariableList

	foreach ($name in $variableList){
		$label             = New-Object system.Windows.Forms.Label
		$label.text        = "$name ="
		$label.AutoSize    = $true
		$label.location    = New-Object System.Drawing.Point($guideVariableLabel.Left,($guideVariableLabel.Top + $pad))
		$label.font        = 'Microsoft Sans Serif,10'
		$label.ForeColor   = "#ffffff"
		$label.Name        = $name + "_label"
		$label.Tag         = $labelTag
		AutoSizeControl -control $label -textPadding 5

		$generatorForm.controls.Add($label)
		
		$countName  = $name + "_CT"
		$countValuePattern = "(?<=\$" + $countName + " = )(\d+)"
		$countValueFile = Get-Content -Path $pathToVariableCount -Raw
		$countMatch  = $countValueFile | Select-String -Pattern $countValuePattern
		$countValue = $countMatch.Matches.Value
		
		$txtBox            = New-Object system.Windows.Forms.NumericUpDown
		$txtBox.Text       = "$countValue"
		$txtBox.Height     = $guideTxtBox.Height
		$txtBox.Width      = $guideTxtBox.Width
		$txtBox.Minimum    = 0
		$txtBox.Maximum    = 100
		$txtBox.location   = New-Object System.Drawing.Point($guideTxtBox.Left,$label.Top)
		$txtBox.ForeColor  = "#ffffff"
		$txtBox.BackColor  = "#555555" 
		$txtBox.Name       = $name + "_TxtBox"
		$txtBox.Tag        = $txtBoxTag
		$generatorForm.controls.Add(($TxtBox))
		$pad               = $pad + 20
		
		$adjName = $name + "_Adj"
		$adjValuePattern = "(?<=\$" + $adjName + " = )(\d+)"
		$adjValueFile = Get-Content -Path $pathToVariableAcceptsAdj -Raw
		$adjMatch  = $adjValueFile | Select-String -Pattern $adjValuePattern
		$adjValue = $adjMatch.Matches.Value
		
		$checkBox          = New-Object System.Windows.Forms.CheckBox
		$checkBox.Location = New-Object System.Drawing.Point(($TxtBox.Right + 10), $label.Top)
		$checkBox.Name     = $name + "_CheckBox"
		$checkBox.Tag      = $checkBoxTag
		if ($adjValue -eq 1){
			$checkBox.Checked = $true
		} else {
			$checkBox.Checked = $false
		}
		$generatorForm.controls.Add(($checkBox))
	}
}

function SetCount {
	# dot source variables from a settings.ps1 file
	. $pathToVariableList
	
	$numberPattern = "\d+"
	if (Test-Path $pathToVariableCount){
		Clear-Content -Path $pathToVariableCount
	}
	foreach ($name in $variableList){	
		$varibleToGet = $name + "_TxtBox"
		$x = $generatorForm.Controls | Where-Object { $_.Name -eq "$varibleToGet" } | ForEach-Object { $_.Text }
		if ($x -notmatch $numberPattern){
			$x = 0
		}
		$outputCountVariable = "`$" + $name + "_CT" + " = " + $x
		$outputCountVariable | Out-File -FilePath $pathToVariableCount -Append
	}
}

function SetAdj {
	# dot source variables from a settings.ps1 file
	. $pathToVariableList
	
	if (Test-Path $pathToVariableAcceptsAdj){
		Clear-Content -Path $pathToVariableAcceptsAdj
	}
	foreach ($name in $variableList){	
		$varibleToGet = $name + "_CheckBox"
		$x = $generatorForm.Controls | Where-Object { $_.Name -eq "$varibleToGet" } | ForEach-Object { $_.Checked }
		if ($x -eq 'True'){
			$x = 1
		} else {
			$x = 0
		}
		$outputAcceptsAdjVariable = "`$" + $name + "_Adj" + " = " + $x
		$outputAcceptsAdjVariable | Out-File -FilePath $pathToVariableAcceptsAdj -Append
	}
}

function SetVariables {
	SetCount
	SetAdj
}

function RemoveVariables {
		$taggedControls = $generatorForm.Controls | Where-Object { (($_.Tag -eq "$labelTag") -or ($_.Tag -eq "$txtBoxTag") -or ($_.Tag -eq "$checkBoxTag")) } 
		foreach ($control in $taggedControls){
			$generatorForm.Controls.Remove($control)
	}
}

function RefreshVariables {
	RemoveVariables
	GetAndDrawVariables
}

function GeneratePrompt {
	. $pathToVariableList
	. $pathToVariableCount
	. $pathToVariableAcceptsAdj
	Clear-Content -Path $outputDirectory
	$number = $promptAmountBox.Value
	$x = $generatorForm.Controls | Where-Object { $_.Name -eq "EnableAdj" } | ForEach-Object { $_.Checked }
	$i=0
	while ($i -lt $number){
		if($x -eq $true){
			$generatedPrompt = Generate-Prompt -inputNameArray $variableList -inputDirectory $inputDirectory -AddAdj $true
			$generatedPrompt | Out-File $outputDirectory -Append -Encoding ASCII
		} else {
			$generatedPrompt = Generate-Prompt -inputNameArray $variableList -inputDirectory $inputDirectory -AddAdj $false
			$generatedPrompt | Out-File $outputDirectory -Append -Encoding ASCII
		}
		$i++
	}
	$promptOutput = Get-Content -Path $outputDirectory -Raw
	$promptTxtBox.Text = "$promptOutput"
}




$labelTag = "Varlabel"
$txtBoxTag = "VarTxtBox"
$checkBoxTag = "VarCheckBox"

GetAndDrawVariables

$setVariablesBtn.Add_Click({ SetVariables })
$refreshVariablesBtn.Add_Click({ RefreshVariables })
$generatePromptBtn.Add_Click({ GeneratePrompt })


[void]$generatorForm.ShowDialog()

# $result = $generatorForm.ShowDialog()

# if ($result -eq [System.Windows.Forms.DialogResult]::Ok)
 # {
    # foreach ($name in $variableList){
		# $variableToGet = $name + "_TxtBox"
		# Get-Variable -Name $name | Set-Variable -Name $PSVariable -Value $variableToGet.Text
	# }
 # }