Start-Transcript -Append C:\cbltemp\Logs\Chris-Lorentzen-Azure-Stack-HCI-PoC-Deploy.txt

######################################################################################
#                                                                                    #
# Chris Lorentzen Azure Stack HCI PoC Build Script                                   #
#                                                                                    #
# Change Log                                                                         #
#                                                                                    #
# Version 1.0 - Initial Release - 28/04/2022                                         #
# Version 1.1 - Updates to deploy based on eval guide - 03/05/2022                   #
# Version 1.2 - Added Key Vault Stage for secure details - 09/05/2022                #
#                                                                                    #
######################################################################################

Write-Host "Chris Lorentzen Azure Stack HCI PoC Build" -ForegroundColor Green
Write-Host "Version 1.2" -ForegroundColor Green
Get-Date -UFormat "%d-%m-%Y %T"

Write-Host "Stage 1 - Update Powershell Modules" -ForegroundColor Green
Get-Date -UFormat "%d-%m-%Y %T"
Update-Module Az

Write-Host "Stage 2 - Authenticate to Azure" -ForegroundColor Green
Get-Date -UFormat "%d-%m-%Y %T"
Login-AzAccount

Write-Host "Stage 3 - List Available Azure Subscriptions for Your Account" -ForegroundColor Green
Get-Date -UFormat "%d-%m-%Y %T"
Get-AzSubscription

Write-Host "Stage 4 - Specify Subscription" -ForegroundColor Green
Get-Date -UFormat "%d-%m-%Y %T"
Write-Host "Please provide the name of the Subscription you wish to connect to" -ForegroundColor Green
$subscriptionname= Read-Host -Prompt "Enter Subscription name"
Write-Host "The entered Subscription name is" $subscriptionname -ForegroundColor Green
Select-AzSubscription $subscriptionname

Write-Host "Stage 5 - Setting Variables for Deployment" -ForegroundColor Green
Get-Date -UFormat "%d-%m-%Y %T"
$resourceGroupName = Read-Host -Prompt "Enter the Resource Group name"

Write-Host "Stage 6 - Create Deployment Key Vault" -ForegroundColor Green
Get-Date -UFormat "%d-%m-%Y %T"
New-AzKeyvault -name 'kv-uks-azshci-poc-deploy-01' -ResourceGroupName $resourceGroupName -Location 'UK South' -EnabledForTemplateDeployment -Tag @{costcentre='jtch';wbscode='o1-0001400';owner='chris lorentzen p10357509@capita.co.uk';purpose='key vault';region='uks';status='notsupported';environment='r&d';monitoring='no';supporthours='08:00-18:00 M-F';general='azure stack hci poc environment key vault for deployment';dr='no'}
Set-AzKeyVaultAccessPolicy -ObjectID 78d5de75-79c9-4426-8e0d-8bf77a4c9888 -VaultName 'kv-uks-azshci-poc-deploy-01' -PermissionsToSecrets get,list,set,delete,backup,restore,recover -PermissionsToKeys get,list,update,create,import,delete,backup,restore,recover -PassThru
Set-AzKeyVaultSecret -VaultName 'kv-uks-azshci-poc-deploy-01' -Name 'adminPassword' -SecretValue (Read-Host -Prompt 'Enter default domain admin account password' -AsSecureString)

Write-Host "Stage 7 - Deploy AzureStack HCI PoC Environment" -ForegroundColor Green
Get-Date -UFormat "%d-%m-%Y %T"
New-AzResourceGroupDeployment -Name Azure_Stack_HCI_Deployment `
  -ResourceGroupName $resourceGroupName `
  -TemplateFile azshci-poc-template.json `
  -TemplateParameterFile azshci-poc-template-parameters.json
 
Write-Host "Stage 8 - Get Deployed VM Details" -ForegroundColor Green
Get-Date -UFormat "%d-%m-%Y %T" 
(Get-AzVm -ResourceGroupName $resourceGroupName).name

Stop-Transcript