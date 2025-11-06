# Customer Loyalty Agent Deployment Guide

## GitHub Actions Workflow for Azure AI Projects Agent Deployment

This workflow automatically deploys the Customer Loyalty Agent to Azure AI Projects when specific files are changed.

## Trigger Files

The workflow runs when any of these files are modified:
- `src/app/agents/customerLoyaltyAgent_initializer.py`
- `src/prompts/CustomerLoyaltyAgentPrompt.txt` 
- `src/app/tools/discountLogic.py`

## Required GitHub Secrets

### 1. Azure Authentication (`AZURE_CREDENTIALS`)

Create a service principal for GitHub Actions authentication:

```bash
az ad sp create-for-rbac --name "TechWorkshopL300AzureAI" \
  --role contributor \
  --scopes /subscriptions/274a0ea6-0dde-4063-a199-4d5104b85cfe/resourceGroups/techworkshop-l300-ai-agents-sweden \
  --json-auth
```

Copy the entire JSON output and save it as the `AZURE_CREDENTIALS` secret:

```json
{
  "clientId": "your-client-id",
  "clientSecret": "your-client-secret", 
  "subscriptionId": "274a0ea6-0dde-4063-a199-4d5104b85cfe",
  "tenantId": "your-tenant-id"
}
```

### 2. Azure Subscription ID (`AZURE_SUBSCRIPTION_ID`)

Set this to: `274a0ea6-0dde-4063-a199-4d5104b85cfe`

### 3. Environment Variables (`ENV`)

Your complete .env file contents including all Azure AI Projects configuration:

```
AZURE_AI_AGENT_ENDPOINT=https://your-ai-project.cognitiveservices.azure.com/
AZURE_AI_AGENT_MODEL_DEPLOYMENT_NAME=your-model-deployment
AZURE_OPENAI_ENDPOINT=https://your-openai-resource.openai.azure.com/
AZURE_OPENAI_API_KEY=your-api-key
AZURE_OPENAI_API_VERSION=2024-02-01
AZURE_SEARCH_ENDPOINT=https://your-search-service.search.windows.net
AZURE_SEARCH_API_KEY=your-search-key
COSMOS_CONNECTION_STRING=your-cosmos-connection-string
# Add any other environment variables needed by your agent
```

## Setting Up GitHub Secrets

1. Go to your GitHub repository
2. Navigate to **Settings** > **Secrets and variables** > **Actions**
3. Click **New repository secret**
4. Add each secret with the exact names shown above

## Workflow Features

### 🔐 **Security Features:**
- ✅ Secure credential handling via GitHub secrets
- ✅ Automatic .env cleanup after deployment
- ✅ Azure authentication using service principal
- ✅ No hardcoded credentials in code

### 🚀 **Deployment Features:**
- ✅ Automatic Python environment setup
- ✅ Dependency installation from requirements.txt
- ✅ Azure AI Projects connection verification
- ✅ Agent deployment with error handling
- ✅ Post-deployment verification

### 🔍 **Monitoring Features:**
- ✅ Connection testing before deployment
- ✅ Agent verification after deployment
- ✅ Deployment logs upload on failure
- ✅ Detailed error reporting

## Manual Deployment

To manually trigger the workflow:

1. Go to **Actions** tab in your repository
2. Select **Deploy Customer Loyalty Agent**
3. Click **Run workflow**
4. Optionally check "Force deployment" to run regardless of file changes
5. Click **Run workflow**

## Troubleshooting

### Common Issues:

1. **Azure Authentication Failed**
   - Verify `AZURE_CREDENTIALS` secret contains valid JSON
   - Check service principal has proper permissions
   - Ensure subscription ID is correct

2. **Azure AI Projects Connection Failed**
   - Verify `AZURE_AI_AGENT_ENDPOINT` in ENV secret
   - Check Azure AI Projects resource is running
   - Ensure service principal has access to AI Projects

3. **Agent Creation Failed**
   - Check `AZURE_AI_AGENT_MODEL_DEPLOYMENT_NAME` is correct
   - Verify model deployment is available
   - Check prompt file is valid and accessible

4. **Dependencies Installation Failed**
   - Ensure requirements.txt includes all necessary packages
   - Check for version conflicts
   - Verify package availability

### Viewing Logs:

1. Go to **Actions** tab
2. Select the failed workflow run
3. Click on the failed job
4. Expand the failed step to see detailed logs
5. Download deployment logs artifact if available

## Local Testing

To test the agent locally before deployment:

```bash
cd src/
cp env_sample.txt .env
# Edit .env with your values

# Install dependencies
pip install -r requirements.txt

# Run the agent initializer
python app/agents/customerLoyaltyAgent_initializer.py
```

## Azure AI Projects Requirements

Ensure your Azure AI Projects resource has:
- ✅ Proper RBAC permissions for the service principal
- ✅ Model deployments configured
- ✅ Network access enabled for GitHub Actions runners
- ✅ Required Azure services connected (OpenAI, Search, etc.)

## File Dependencies

The workflow monitors these critical files:
- **Agent Code**: `customerLoyaltyAgent_initializer.py` - Main agent initialization
- **Agent Instructions**: `CustomerLoyaltyAgentPrompt.txt` - Agent behavior definition  
- **Tools**: `discountLogic.py` - Agent tool functions

Any changes to these files will trigger automatic deployment to keep your Azure AI agent up-to-date.