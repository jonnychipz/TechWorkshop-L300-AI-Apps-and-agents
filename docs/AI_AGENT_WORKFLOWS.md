# AI Agent Deployment Workflows

## Overview

This repository contains four GitHub Actions workflows for deploying AI agents to Azure AI Projects. Each workflow is triggered by changes to specific agent files, prompts, and tools to ensure your Azure agents stay synchronized with your code.

## 🤖 Available Agent Workflows

### 1. Customer Loyalty Agent
- **Workflow**: `.github/workflows/deploy-loyalty-agent.yml`
- **Trigger Files**:
  - `src/app/agents/customerLoyaltyAgent_initializer.py`
  - `src/prompts/CustomerLoyaltyAgentPrompt.txt`
  - `src/app/tools/discountLogic.py`
- **Features**: Discount calculation, customer loyalty management
- **Documentation**: `docs/LOYALTY_AGENT_DEPLOYMENT.md`

### 2. Shopper Agent (Cora)
- **Workflow**: `.github/workflows/deploy-shopper-agent.yml`
- **Trigger Files**:
  - `src/app/agents/shopperAgent_initializer.py` 
  - `src/prompts/ShopperAgentPrompt.txt`
- **Features**: Personal shopping assistant, product recommendations
- **Tools**: Uses CodeInterpreter for data analysis

### 3. Inventory Agent
- **Workflow**: `.github/workflows/deploy-inventory-agent.yml`
- **Trigger Files**:
  - `src/app/agents/inventoryAgent_initializer.py`
  - `src/prompts/InventoryAgentPrompt.txt`
  - `src/app/tools/inventoryCheck.py`
- **Features**: Inventory management, stock checking
- **Tools**: Custom inventory checking functions

### 4. Interior Design Agent
- **Workflow**: `.github/workflows/deploy-interior-design-agent.yml`
- **Trigger Files**:
  - `src/app/agents/interiorDesignAgent_initializer.py`
  - `src/prompts/InteriorDesignAgentPrompt.txt`
  - `src/app/tools/imageCreationTool.py`
- **Features**: Interior design recommendations, image generation
- **Tools**: AI-powered image creation with Azure OpenAI

## 🔐 Required GitHub Secrets

All workflows use the same set of GitHub secrets. Set these up once for all agents:

### Setting Up Secrets

1. Go to **Settings** > **Secrets and variables** > **Actions**
2. Click **New repository secret** for each:

| Secret Name | Description | Value |
|-------------|-------------|-------|
| `AZURE_CREDENTIALS` | Service principal JSON for Azure authentication | Output from `az ad sp create-for-rbac` command |
| `AZURE_SUBSCRIPTION_ID` | Your Azure subscription ID | `274a0ea6-0dde-4063-a199-4d5104b85cfe` |
| `ENV` | Complete .env file contents | All environment variables needed by agents |

### Creating Service Principal

```bash
az ad sp create-for-rbac --name "TechWorkshopL300AzureAI" \
  --role contributor \
  --scopes /subscriptions/274a0ea6-0dde-4063-a199-4d5104b85cfe/resourceGroups/techworkshop-l300-ai-agents-sweden \
  --json-auth
```

### ENV Secret Format

Your ENV secret should contain all environment variables:

```
AZURE_AI_AGENT_ENDPOINT=https://your-ai-project.cognitiveservices.azure.com/
AZURE_AI_AGENT_MODEL_DEPLOYMENT_NAME=your-model-deployment
AZURE_OPENAI_ENDPOINT=https://your-openai-resource.openai.azure.com/
AZURE_OPENAI_API_KEY=your-openai-api-key
AZURE_OPENAI_API_VERSION=2024-02-01
AZURE_SEARCH_ENDPOINT=https://your-search-service.search.windows.net
AZURE_SEARCH_API_KEY=your-search-api-key
COSMOS_CONNECTION_STRING=your-cosmos-connection-string
# Add any other environment variables needed
```

## 🚀 Deployment Methods

### Automatic Deployment
- **Trigger**: Push changes to any monitored files on main branch
- **Action**: Workflow automatically runs and deploys the affected agent

### Manual Deployment
1. Go to **Actions** tab in GitHub
2. Select the desired agent workflow
3. Click **Run workflow**
4. Optionally enable "Force deployment"
5. Click **Run workflow**

### Pull Request Validation
- All workflows also run on pull requests to validate changes before merge

## 🔍 Workflow Features

### Common Features (All Workflows):
- ✅ **Python 3.12 Environment**: Latest Python with pip caching
- ✅ **Secure Authentication**: Azure service principal login
- ✅ **Connection Testing**: Validates Azure AI Projects connectivity
- ✅ **Deployment Verification**: Confirms agent creation success
- ✅ **Automatic Cleanup**: Removes sensitive files after deployment
- ✅ **Error Handling**: Detailed logging and artifact collection on failure

### Agent-Specific Features:

#### Customer Loyalty Agent:
- ✅ **Tool Validation**: Verifies discount logic tool functionality
- ✅ **Database Connectivity**: Tests Cosmos DB and SQL connections

#### Shopper Agent:
- ✅ **CodeInterpreter Support**: Enables advanced data analysis capabilities
- ✅ **JSON Processing**: Validates data structure handling

#### Inventory Agent:
- ✅ **Inventory Tool Check**: Validates inventory checking functionality
- ✅ **Database Integration**: Tests inventory database connections

#### Interior Design Agent:
- ✅ **Image Generation Test**: Validates Azure OpenAI image creation
- ✅ **Tool Dependency Check**: Ensures image creation tool availability

## 📊 Monitoring & Troubleshooting

### Viewing Workflow Status
1. Go to **Actions** tab in your repository
2. Select the workflow run to see detailed logs
3. Each step shows success/failure status with expandable logs

### Common Issues & Solutions

#### Authentication Failures
- **Issue**: Azure login fails
- **Solution**: Verify `AZURE_CREDENTIALS` secret contains valid JSON
- **Check**: Ensure service principal has proper permissions

#### Connection Failures
- **Issue**: Can't connect to Azure AI Projects
- **Solution**: Verify `AZURE_AI_AGENT_ENDPOINT` in ENV secret
- **Check**: Ensure network access is enabled for GitHub Actions

#### Agent Creation Failures
- **Issue**: Agent deployment fails
- **Solution**: Check model deployment name and availability
- **Check**: Verify prompt files are valid and accessible

#### Tool Import Failures
- **Issue**: Can't import agent tools
- **Solution**: Ensure all dependencies are in requirements.txt
- **Check**: Verify tool files exist and have correct imports

### Log Artifacts
- Failed deployments automatically upload logs as artifacts
- Download from workflow run page for detailed troubleshooting
- Logs include Python errors, Azure responses, and deployment details

## 🎯 Best Practices

### Code Organization
- Keep agent initializers focused and minimal
- Store prompts in dedicated txt files in `src/prompts/`
- Organize tools in `src/app/tools/` with clear naming

### Prompt Management
- Use descriptive, detailed prompts for better agent performance
- Version control all prompt changes to track behavior evolution
- Test prompts locally before committing changes

### Tool Development
- Make tools modular and reusable across agents
- Include proper error handling in all tool functions
- Document tool parameters and return values

### Environment Management
- Never commit .env files to repository
- Use GitHub secrets for all sensitive configuration
- Test locally with sample data before deployment

## 🔄 Workflow Dependencies

### File Change Monitoring
Each workflow monitors specific files to minimize unnecessary deployments:

```
Customer Loyalty Agent:
├── Agent: customerLoyaltyAgent_initializer.py
├── Prompt: CustomerLoyaltyAgentPrompt.txt
└── Tool: discountLogic.py

Shopper Agent:
├── Agent: shopperAgent_initializer.py
└── Prompt: ShopperAgentPrompt.txt

Inventory Agent:
├── Agent: inventoryAgent_initializer.py
├── Prompt: InventoryAgentPrompt.txt
└── Tool: inventoryCheck.py

Interior Design Agent:
├── Agent: interiorDesignAgent_initializer.py
├── Prompt: InteriorDesignAgentPrompt.txt
└── Tool: imageCreationTool.py
```

### Shared Dependencies
All agents share:
- `src/requirements.txt` - Python dependencies
- `.env` configuration - Azure service connections
- Azure AI Projects infrastructure

## 📈 Scaling Considerations

### Multi-Environment Support
- Consider separate workflows for dev/staging/prod environments
- Use environment-specific secrets and configuration
- Implement approval gates for production deployments

### Performance Optimization
- Workflows use pip caching to speed up builds
- Docker layer caching reduces build times
- Parallel execution where possible

### Security Hardening
- All workflows follow least-privilege principles
- Secrets are never logged or exposed
- Temporary files are always cleaned up
- Service principal has minimal required permissions

This comprehensive setup ensures your AI agents are always synchronized with your code changes while maintaining security and reliability throughout the deployment process.