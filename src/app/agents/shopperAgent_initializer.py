import os
import sys
import atexit
import logging
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from azure.ai.projects import AIProjectClient
from azure.identity import DefaultAzureCredential
from azure.ai.agents.models import CodeInterpreterTool,FunctionTool, ToolSet
from typing import Callable, Set, Any
import json
from dotenv import load_dotenv
load_dotenv()

# Disable OpenTelemetry logging cleanup errors
import warnings
warnings.filterwarnings("ignore", category=RuntimeWarning)
logging.getLogger('opentelemetry').setLevel(logging.CRITICAL)

# Monkey patch to prevent the shutdown error
import threading
original_start = threading.Thread.start
def patched_start(self):
    try:
        original_start(self)
    except RuntimeError as e:
        if "can't create new thread at interpreter shutdown" in str(e):
            pass  # Ignore this specific error
        else:
            raise
threading.Thread.start = patched_start

CORA_PROMPT_TARGET = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))), 'prompts', 'ShopperAgentPrompt.txt')
with open(CORA_PROMPT_TARGET, 'r', encoding='utf-8') as file:
    CORA_PROMPT = file.read()

project_endpoint = os.environ["AZURE_AI_AGENT_ENDPOINT"]

project_client = AIProjectClient(
    endpoint=project_endpoint,
    credential=DefaultAzureCredential(),
)


def cleanup_logging():
    """Clean up logging to avoid shutdown errors"""
    try:
        # Force flush and cleanup before shutdown
        logging.shutdown()
    except:
        pass

# Register cleanup function
atexit.register(cleanup_logging)

try:
    with project_client:
        agent = project_client.agents.create_agent(
            model=os.environ["AZURE_AI_AGENT_MODEL_DEPLOYMENT_NAME"],  # Model deployment name
            name="Cora",  # Name of the agent
            instructions=CORA_PROMPT,  # Instructions for the agent
            # toolset=toolset
        )
        print(f"Created agent, ID: {agent.id}")
except Exception as e:
    print(f"Error creating agent: {e}")
    sys.exit(1)
