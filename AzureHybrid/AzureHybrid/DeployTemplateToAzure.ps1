<#############################################################
 #                                                           #
 # DeployTemplateToAzure.ps1								 #
 #                                                           #
 #############################################################>

<#
 .Synopsis
	The script creates a new resource group in Azure subscription and deploys resources based on template file and parameters file.

 .Requirements
	Azure PowerShell modules must be installed in order to run the script (https://www.microsoft.com/web/handlers/webpi.ashx/getinstaller/WindowsAzurePowershellGet.3f.3f.3fnew.appids).
 .Parameter ResourceGroupLocation
	Sets Azure region for the deployment. Default region is 'westeurope'.
 .Parameter DeployIndex
	Sets a number for the deployment iteration.
 .Parameter ResourceGroupPrefix
	Used to form resource group name and deployment name.  
 .Parameter AzureUserName
	Azure Active Directory tenant user name. This account is used to deploy all resources and should have necessary permissions. 
 .Parameter AzureUserPassword
	Azure Active Directory tenant password. 

.Example
     If no parameters are provided, default values are used.

     .\DeployTemplateToAzure.ps1 

.Example
     This example creates 'Test-RG02' resource group in West Europe region and starts deployment with the name 'Test-RG-Dep02'.

     .\DeployTemplateToAzure.ps1 -ResourceGroupLocation 'westeurope' -DeployIndex '02' -ResourceGroupPrefix 'Test-RG' -AzureUserName 'admin@mytenant.onmicrosoft.com' -AzureUserPassword 'P@ssw0rd!@#$%' 
#>


Param(
	[string] $ResourceGroupLocation = "westeurope",
	[string] $DeployIndex = "101",
	[string] $ResourceGroupPrefix = "Test-RG",
	[string] $AzureUserName = "admin@mytenant.onmicrosoft.com",
	[string] $AzureUserPassword = "password"
)

# Prepare credentials and login to Azure subscription. 
$AadPass = ConvertTo-SecureString $AzureUserPassword -AsPlainText -Force
$AadCred = New-Object System.Management.Automation.PSCredential ($AzureUserName, $Aadpass)
Login-AzureRmAccount -Credential $AadCred

# Prepare environment variables.  
$ResourceGroupName = $ResourceGroupPrefix + $DeployIndex
$DeploymentName = $ResourceGroupPrefix + "-Dep" + $DeployIndex
$TemplateUri = "https://raw.githubusercontent.com/ashapoms/azureHybrid/master/AzureHybrid/AzureHybrid/azureHybrid.json"
$TemplateParameterUri = "https://raw.githubusercontent.com/ashapoms/azureHybrid/master/AzureHybrid/AzureHybrid/azureHybrid.parameters.json"

# Create a new resource group in given region.  
New-AzureRmResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLocation -Verbose -Force

# Start a new deployment in created resource group using local files.
New-AzureRmResourceGroupDeployment -Name $DeploymentName `
                                       -ResourceGroupName $ResourceGroupName `
                                       -TemplateUri $TemplateUri `
                                       -TemplateParameterUri $TemplateParameterUri `
                                       -Verbose