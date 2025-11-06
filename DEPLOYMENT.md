# GitHub Actions Deployment Guide

## Secure Deployment to Azure Container Registry

This repository contains a secure GitHub Actions workflow that deploys the AI Shopping Assistant to Azure Container Registry while keeping sensitive information protected.

## Required GitHub Secrets

Before the workflow can run, you need to set up the following secrets in your GitHub repository:

### Setting Up Secrets

1. Go to your GitHub repository
2. Navigate to **Settings** > **Secrets and variables** > **Actions**
3. Click **New repository secret** for each of the following:

#### Required Secrets:

| Secret Name | Description | Example Value |
|-------------|-------------|---------------|
| `ACR_REGISTRY_NAME` | Your Azure Container Registry name | `myregistry.azurecr.io` |
| `ACR_USERNAME` | ACR username (usually the registry name) | `myregistry` |
| `ACR_PASSWORD` | ACR access key or service principal password | `your-acr-password` |
| `ENV` | Complete .env file contents with all environment variables | See ENV Format below |

#### Optional Secrets (for ACI deployment):
| Secret Name | Description |
|-------------|-------------|
| `AZURE_RESOURCE_GROUP` | Resource group name for ACI deployment |

### ENV Secret Format

The `ENV` secret should contain your complete .env file contents. Example format:

```
AZURE_OPENAI_ENDPOINT=https://your-openai-resource.openai.azure.com/
AZURE_OPENAI_API_KEY=your-api-key-here
AZURE_OPENAI_API_VERSION=2024-02-01
AZURE_SEARCH_ENDPOINT=https://your-search-service.search.windows.net
AZURE_SEARCH_API_KEY=your-search-key-here
COSMOS_CONNECTION_STRING=your-cosmos-connection-string
# Add all other environment variables your app needs
```

## Security Features

✅ **Secret Management**: Environment variables are injected at build time from GitHub secrets  
✅ **No Committed Secrets**: .env files are never committed to the repository  
✅ **Build-time Creation**: .env file is created during the Docker build process  
✅ **Automatic Cleanup**: .env file is removed after build completion  
✅ **Secure Context**: Only builds from the src/ folder with necessary files  

## Workflow Triggers

The deployment workflow runs automatically when:
- Code is pushed to the `main` branch
- A pull request is merged into `main`

## Manual Deployment

To manually trigger a deployment:
1. Go to **Actions** tab in your GitHub repository
2. Select **Deploy to Azure Container Registry** workflow
3. Click **Run workflow** button
4. Select the branch and click **Run workflow**

## Getting ACR Credentials

### Using Azure CLI:
```bash
# Get ACR login server
az acr show --name <registry-name> --query loginServer --output table

# Get ACR credentials
az acr credential show --name <registry-name>
```

### Using Azure Portal:
1. Navigate to your Container Registry in Azure Portal
2. Go to **Settings** > **Access keys**
3. Enable **Admin user**
4. Copy the **Login server**, **Username**, and **Password**

## Container Image Tags

The workflow creates two tags for each build:
- `latest` - Always points to the most recent build
- `<git-sha>` - Specific commit hash for version tracking

## Troubleshooting

### Common Issues:

1. **Authentication Failed**: Verify ACR credentials in GitHub secrets
2. **Build Failed**: Check if all required environment variables are in the ENV secret
3. **Missing Dependencies**: Ensure all required packages are in requirements.txt

### Viewing Logs:
- Go to **Actions** tab > Select the failed workflow run > View logs for detailed error information

## Local Development

For local development, create your own `.env` file in the `src/` directory:

```bash
cd src/
cp env_sample.txt .env
# Edit .env with your actual values
```

**Important**: Never commit your local `.env` file to the repository!