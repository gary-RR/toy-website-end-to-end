githubOrganizationName='gary-RR'
githubRepositoryName='toy-website-end-to-end'

#****************************************************************Test********************************************************************************************
testApplicationRegistrationDetails=$(az ad app create --display-name 'toy-website-end-to-end-test')
testApplicationRegistrationObjectId=$(echo $testApplicationRegistrationDetails | jq -r '.id')
testApplicationRegistrationAppId=$(echo $testApplicationRegistrationDetails | jq -r '.appId')

az ad app federated-credential create \
   --id $testApplicationRegistrationObjectId \
   --parameters "{\"name\":\"toy-website-end-to-end-test\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:${githubOrganizationName}/${githubRepositoryName}:environment:Test\",\"audiences\":[\"api://AzureADTokenExchange\"]}"

az ad app federated-credential create \
   --id $testApplicationRegistrationObjectId \
   --parameters "{\"name\":\"toy-website-end-to-end-test-branch\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:${githubOrganizationName}/${githubRepositoryName}:ref:refs/heads/main\",\"audiences\":[\"api://AzureADTokenExchange\"]}"


#*********************************************************Prod*************************************************************************************************************
productionApplicationRegistrationDetails=$(az ad app create --display-name 'toy-website-end-to-end-production')
productionApplicationRegistrationObjectId=$(echo $productionApplicationRegistrationDetails | jq -r '.id')
productionApplicationRegistrationAppId=$(echo $productionApplicationRegistrationDetails | jq -r '.appId')

az ad app federated-credential create \
   --id $productionApplicationRegistrationObjectId \
   --parameters "{\"name\":\"toy-website-end-to-end-production\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:${githubOrganizationName}/${githubRepositoryName}:environment:Production\",\"audiences\":[\"api://AzureADTokenExchange\"]}"

az ad app federated-credential create \
   --id $productionApplicationRegistrationObjectId \
   --parameters "{\"name\":\"toy-website-end-to-end-production-branch\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:${githubOrganizationName}/${githubRepositoryName}:ref:refs/heads/main\",\"audiences\":[\"api://AzureADTokenExchange\"]}"


#*******************************************************Create a test Resource group and a SP and give contibutor access to the SP.
testResourceGroupResourceId=$(az group create --name ToyWebsiteTest --location westus3 --query id --output tsv)

# There is a bug in git bash and Azure CLI where we must remove the starting "/" from "/subscriptions"
testResourceGroupResourceId=${testResourceGroupResourceId:1}

az ad sp create --id $testApplicationRegistrationObjectId

az role assignment create \
   --assignee $testApplicationRegistrationAppId \
   --role Contributor \
   --scope $testResourceGroupResourceId

#*******************************************************Create a prod Resource group and a SP and give contibutor access to the SP.
productionResourceGroupResourceId=$(az group create --name ToyWebsiteProduction --location westus3 --query id --output tsv)

# There is a bug in git bash and Azure CLI where we must remove the starting "/" from "/subscriptions"
productionResourceGroupResourceId=${productionResourceGroupResourceId:1}

az ad sp create --id $productionApplicationRegistrationObjectId

az role assignment create \
   --assignee $productionApplicationRegistrationAppId \
   --role Contributor \
   --scope $productionResourceGroupResourceId

echo "AZURE_CLIENT_ID_TEST: $testApplicationRegistrationAppId"
echo "AZURE_CLIENT_ID_PRODUCTION: $productionApplicationRegistrationAppId"
echo "AZURE_TENANT_ID: $(az account show --query tenantId --output tsv)"
echo "AZURE_SUBSCRIPTION_ID: $(az account show --query id --output tsv)"