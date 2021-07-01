
#Use the Base Policy "DefaultWindows_Enforced.xml" and copy it to the new created Policy
$PolicyName= "Block_App"
$BlockPolicy=$env:userprofile+"\Desktop\"+$PolicyName+".xml"
$DefaultPolicy = $env:windir+"\schemas\CodeIntegrity\ExamplePolicies\AllowALL.xml"
cp  $DefaultPolicy $BlockPolicy

#Set a unique Identifier and Policy Name and Version to the new Created Policy
Set-CIPolicyIdInfo -FilePath $BlockPolicy -PolicyName $PolicyName -ResetPolicyID
Set-CIPolicyVersion -FilePath $BlockPolicy -Version "1.0.0.0"
$path=Read-Host -Prompt 'insert the Path of the App to Block'

#Create the Rule for Blocking the application
$Exception_1 = New-CIPolicyRule   -Level  FileName -SpecificFileNameLevel OriginalFileName -Fallback Hash -DriverFilePath $path -Deny

#Merge the Policy and the rule in a new xml file
Merge-CIPolicy -OutputFilePath $BlockPolicy -PolicyPaths $BlockPolicy -Rules $Exception_1

#Set the Enforced Mode
Set-RuleOption -FilePath $BlockPolicy -Option 3 -Delete
Set-RuleOption -FilePath $BlockPolicy -Option 16


#copy the Policy ID from the Xml file and rename the Binary file with the PoicyID 
[XML]$data = Get-Content $BlockPolicy
$L = $data.SiPolicy.PolicyID
$WDACPolicyBin= ".\Desktop\"+"$L.cip"

#convert the xml to binary file and copy it to the Active path to be deployed
ConvertFrom-CIPolicy $BlockPolicy $WDACPolicyBin
$DestinPath = "C:\Windows\System32\CodeIntegrity\CiPolicies\Active"
cp $WDACPolicyBin $DestinPath -Force
Invoke-CimMethod -Namespace root\Microsoft\Windows\CI -ClassName PS_UpdateAndCompareCIPolicy -MethodName Update -Arguments @{FilePath = 'C:\Windows\System32\CodeIntegrity\CiPolicies\Active\$L.cip'}