Add-Type -assembly System.Windows.Forms
Add-Type -assembly System.Drawing

Function FileRepl([string]$fromfile, [string]$tofile)
{
    Get-Content -Path $fromfile | ForEach-Object {
        $line = $_
 
        $lookuptable.GetEnumerator() | ForEach-Object {
            if ($line -match $_.Key)
            {
                $line = $line -replace $_.Key, $_.Value
            }
        }
        $line
    } | Set-Content -Path $tofile
}


# Function when cancel is 
function DoCancelBtn {
  $main_form.Close()
}

# Create a Function to make use of our data
function UpdateRepository {

    $env = ""
    $server = ""
    $database = ""
    $newfile = ""
    $keep = $false
    $didwekeep = $false

    $main_form.Text = $lookupTable['{repos}']
    $rmtmp = '..\readme.tmp'
    Set-Content -Path $rmtmp -Value '<table><tr><th>Env</tn><th>Server</th><th>Database</th></tr>'
  
    foreach ($child in $main_form.Controls) 
    {
        $childctrl = $child.getType()
        if ($childctrl.Name -eq 'GroupBox') 
        {
            'I have a group box'
            foreach ($gbctrl in $child.Controls) 
            {
                $x = $gbctrl.Tag
                switch ($x) 
                {
                    'env'      {
                                $env = $gbctrl.Text
                                $keep = $gbctrl.Checked
                                $lookupTable['{env}'] = $env
                                break
                               }
                    'server'   {
                                $server = $gbctrl.Text
                                $lookupTable['{server}'] = $server
                                break
                               }
                    'database' {
                                $database = $gbctrl.Text
                                $lookupTable['{databaseName}'] = $database
                                break
                               }
                }
            }

            if ($keep -eq $true ) 
            {
                $didwekeep = $true

                $newfile = "..\README.md"
                #Add-Content -Path $rmtmp -Value ($env + ": " + $server + '/' + $database + '<br>')
                Add-Content -Path $rmtmp -Value ('<tr><td>' + $env + '</td><td>' + $server + '</td><td>' + $database + '</td></tr>')
                $original_file = '..\conf\flyway.conf'
                $destination_file =  "..\conf\flyway.$env.conf"
                FileRepl $original_file $destination_file $lookupTable
            }
        }
        if ($didwekeep -eq $true) 
        {
            $original_file = '..\README1.md'
            $destination_file =  "..\README.md"
            FileRepl $original_file $destination_file $lookupTable
            cat $rmtmp | Add-Content -Path $destination_file
            Add-Content -Path $destination_file -Value '</table>'
        }
    }
}

$therepos = (get-item -Path '.').parent.name
$lookupTable = @{
    '{env}'          = 'xxx'
    '{server}'       = 'xxx'
    '{databasename}' = 'xxx'
    '{repos}'        = $therepos
 }

$main_form = New-Object System.Windows.Forms.Form
$main_form.Text = $lookupTable['{repos}']
$main_form.AutoSize = $true

$cpx = 0

$tbx = New-Object System.Windows.Forms.TextBox
$tbx.Font = 'Microsoft Sans Serif, 12'
$tbx.text = 'XXXXXXXXXXXXXX'
$tbx.AutoSize = $true
$tbwidth = $tbx.Width
$tbheight = $tbx.Height
$tbwidth += 50

$cpx += 30

$envs = @("prod", "uat", "qa", "dev")

$gbx = 0
$gby = 0
$gbf = 14
$gbh = 0
$cpy = 10
foreach ($envx in $envs) {
    $gbx += 10
    $icy = 10
    
    $GroupBox = New-Object System.Windows.Forms.GroupBox
    $GroupBox.AutoSize = $true
    $GroupBox.Location = New-Object System.Drawing.Point($cpx,$cpy)

    $CheckBox = New-Object System.Windows.Forms.CheckBox
    $CheckBox.Font     = 'Microsoft Sans Serif,14'
    $CheckBox.Location = New-Object System.Drawing.Point(10,$icy)
    if ($envx -eq $envs[0]) {
        $CheckBox.checked  = $true
    } else {
        $CheckBox.checked = $false
    }
    $CheckBox.Text = $envx
    $CheckBox.Tag = 'env'
    $GroupBox.Controls.Add($CheckBox)

    $icy += $CheckBox.Height
    $icy += 10

    $Label1          = New-Object System.Windows.Forms.Label
    $Label1.Location = New-Object System.Drawing.Point(10,$icy)
    $Label1.text     = 'Server:'
    $Label1.AutoSize = $true
    $Label1.Font     = 'Microsoft Sans Serif,10'
    $GroupBox.Controls.Add($Label1)

    $icy += $Label1.Height

    $srvtxt = New-Object System.Windows.Forms.TextBox
    $srvtxt.Location = New-Object System.Drawing.Point(10,$icy)
    $srvtxt.Font = 'Microsoft Sans Serif, 12'
    $srvtxt.Height = $tbheight
    $srvtxt.Width  = $tbwidth
    $srvtxt.tag = 'server'
    $GroupBox.Controls.Add($srvtxt)

    $icy += $srvtxt.Height
    $icy += 10

    $Label2          = New-Object System.Windows.Forms.Label
    $Label2.Location = New-Object System.Drawing.Point(10,$icy)
    $Label2.text     = 'Database:'
    $Label2.AutoSize = $true
    $Label2.Font     = 'Microsoft Sans Serif,10'
    $GroupBox.Controls.Add($Label2)

    $icy += $Label2.Height

    $dbtxt = New-Object System.Windows.Forms.TextBox
    $dbtxt.Location = New-Object System.Drawing.Point(10,$icy)
    $dbtxt.Font = 'Microsoft Sans Serif, 12'
    $dbtxt.Height = $tbheight
    $dbtxt.Width  = $tbwidth
    #$dbtxt.AutoSize = $true
    $dbtxt.tag = 'database'
    $GroupBox.Controls.Add($dbtxt)

    $icy += $srvtxt.Height
    $icy += 10

    $main_form.Controls.Add($GroupBox)

    $cpx += $GroupBox.Width
    $cpx +=10
    $gbh = $GroupBox.Height
}

$gbh += 40

$midForm = $main_form.Width 
$midForm /= 2
$cstart = $midForm
$cstart += 30

$btnCancel = New-Object System.Windows.Forms.Button
$btnCancel.Location = New-Object System.Drawing.Point($cstart, $gbh)
$btnCancel.Font = 'Microsoft San Serif, 14'
$btnCancel.Text = "Cancel"
$btnCancel.Add_Click( { DoCancelBtn } )
$main_form.Controls.Add($btnCancel)

$ostart = $midForm
$ostart -= 30
$ostart -= $btnCancel.Width

$btnOK = New-Object System.Windows.Forms.Button
$btnOK.Location = New-Object System.Drawing.Point($ostart, $gbh)
$btnok.Font = 'Microsoft San Serif, 14'
$btnOK.Text = 'Save'
$btnOk.Width = $btnCancel.Width
$btnOK.Add_Click( { UpdateRepository } )
$main_form.Controls.Add($btnok)

$fw = $main_form.Width
$fw += 30
$main_form.Width = $fw

$main_form.ShowDialog()
