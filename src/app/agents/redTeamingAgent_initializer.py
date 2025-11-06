# Azure imports
from azure.identity import DefaultAzureCredential
from azure.ai.evaluation.red_team import RedTeam, RiskCategory, AttackStrategy
from pyrit.prompt_target import OpenAIChatTarget
import os
import asyncio
from dotenv import load_dotenv
load_dotenv()

# Azure AI Project Information
azure_ai_project = os.getenv("AZURE_AI_AGENT_ENDPOINT")

# Instantiate your AI Red Teaming Agent
red_team_agent = RedTeam(
    azure_ai_project=azure_ai_project,
    credential=DefaultAzureCredential(),
    risk_categories=[
        RiskCategory.Violence,
        RiskCategory.HateUnfairness,
        RiskCategory.Sexual,
        RiskCategory.SelfHarm
    ],
    num_objectives=5,
)

# Configuration for Azure OpenAI target
# target = OpenAIChatTarget(
#     api_key=os.environ.get("AZURE_OPENAI_API_KEY") or os.environ.get("AZURE_OPENAI_KEY"),
#     endpoint=os.environ.get("AZURE_OPENAI_ENDPOINT"),
#     api_version=os.environ.get("AZURE_OPENAI_API_VERSION"),
#     deployment=os.environ.get("AZURE_OPENAI_API_MODEL_DEPLOYMENT_NAME") or os.environ.get("AZURE_AI_AGENT_MODEL_DEPLOYMENT_NAME", "gpt-4o"),
#     max_tokens=1000
# )
chat_target = OpenAIChatTarget(
    model_name=os.environ.get("gpt_deployment"),
    endpoint=os.environ.get("gpt_endpoint"),
    api_key=os.environ.get("gpt_api_key"),
    api_version=os.environ.get("gpt_api_version"),
) 


def test_chat_target(query: str) -> str:
    """Fallback target for testing if Azure OpenAI is not available"""
    return "I am a simple AI assistant that follows ethical guidelines. I cannot and will not provide harmful content."

async def main():
    try:
        print("🚀 STARTING RED TEAM SCAN")
        # Use Azure OpenAI target for red teaming
        #red_team_result = await red_team_agent.scan(target=target)
        red_team_result = await red_team_agent.scan(target=chat_target)
        print("✅ Scan completed successfully!")
    except Exception as e:
        print(f"❌ Error during red team scan: {e}")
        print("🔄 Falling back to test target...")
        # Fallback to test target if Azure OpenAI fails
        red_team_result = await red_team_agent.scan(target=test_chat_target)
        print("✅ Fallback scan completed!")

asyncio.run(main())
