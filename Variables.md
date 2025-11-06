resourceGroup="techworkshop-l300-ai-agents-sweden"
cosmosDbAccountName="sa2imut7hmo46-cosmosdb"
# This is the name of your Azure AI Search account. It will be something like xxxxxxxxxxxxx-search
aiSearchName="sa2imut7hmo46-search"
# This is the name of your Azure AI Foundry account. It will be something like xxxxxxxxxxxxx
# In the deployment script, the Type is Microsoft.CognitiveServices/accounts
aiFoundryName="aif-sa2imut7hmo46"
# This is the name of your Azure AI Foundry project. It will be something like proj-xxxxxxxxxx.
# Its Type in the deployment script is Microsoft.CognitiveServices/accounts/projects
aiProjectName="proj-sa2imut7hmo46"



# Retrieve Cosmos DB account resource ID
cosmosId=$(az cosmosdb show \
  --name sa2imut7hmo46-cosmosdb \
  --resource-group techworkshop-l300-ai-agents-sweden \
  --query id -o tsv)

# Disable local authentication (master keys)
az resource update \
  --ids "$cosmosId" \
  --set properties.disableLocalAuth=true \
  --api-version 2021-06-15