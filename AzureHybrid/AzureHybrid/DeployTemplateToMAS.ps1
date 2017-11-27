<#############################################################
 #                                                           #
 # DeployTemplateToMAS.ps1									 #
 #                                                           #
 #############################################################>

<#
 .Synopsis
	The script creates a new resource group in Azure Stack subscription and deploys resources based on template file and parameters file.

 .Requirements
	Azure Stack PowerShell modules must be installed in order to run the script (https://docs.microsoft.com/en-us/azure/azure-stack/azure-stack-powershell-install).
 .Parameter ResourceGroupLocation
	Sets Azure Stack region for the deployment. Default region is 'local'.
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

     .\DeployTemplateToMAS.ps1 

.Example
     This example creates 'Test-RG02' resource group in local region and starts deployment with the name 'Test-RG-Dep02'.

     .\DeployTemplateToMAS.ps1 -ResourceGroupLocation 'local' -DeployIndex '02' -ResourceGroupPrefix 'Test-RG' -AzureUserName 'admin@mytenant.onmicrosoft.com' -AzureUserPassword 'P@ssw0rd!@#$%' 
#>


Param(
	[string] $ResourceGroupLocation = "local",
	[string] $DeployIndex = "101",
	[string] $ResourceGroupPrefix = "Test-RG",
	[string] $AzureUserName = "andvis@contosomsspb.onmicrosoft.com",
	[string] $AzureUserPassword = "@zureSt@ck"
)

# Change to the tools directory
cd E:\AzureStack-Tools-master

# After downloading the tools, navigate to the downloaded folder and import the Connect PowerShell module by using the following command: 
Import-Module .\Connect\AzureStack.Connect.psm1

# Register an AzureRM environment that targets your Azure Stack instance
Add-AzureRMEnvironment `
  -Name "AzureStackUser" `
  -ArmEndpoint "https://management.local.azurestack.external"

# Set the GraphEndpointResourceId value
# Set-AzureRmEnvironment `
#  -Name "AzureStackUser" `
#  -GraphAudience "https://graph.windows.net/"

# Get the Active Directory tenantId that is used to deploy Azure Stack
$TenantID = Get-AzsDirectoryTenantId `
  -AADTenantName "contosomsspb.onmicrosoft.com" `
  -EnvironmentName "AzureStackUser"

# Prepare credentials and login to Azure subscription. 
$AadPass = ConvertTo-SecureString $AzureUserPassword -AsPlainText -Force
$AadCred = New-Object System.Management.Automation.PSCredential ($AzureUserName, $Aadpass)

# Use this command to sign-in to the user portal.
Login-AzureRmAccount `
  -EnvironmentName "AzureStackUser" `
  -TenantId $TenantID `
  -Credential $AadCred

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