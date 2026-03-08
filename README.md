# Deby Lite 🤖

A customized [Agent Zero](https://github.com/frdel/agent-zero) AI agent system running in Docker.
Built on Debian/Kali Linux with specialized agent profiles and an intuitive web UI.

## Features

- 🧠 **Multiple Agent Profiles** - Default, Agent0, Developer, Researcher, Hacker, Deby
- 🛠️ **Built-in Tools** - Code execution, browser control, memory management, file operations, web search
- 🌐 **Web UI** - Full-featured chat interface with settings, scheduler, and project management
- 💡 **Skills System** - Extensible skill framework (AgentSkills.io standard)
- 📅 **Task Scheduler** - Cron-based, planned, and ad-hoc task scheduling
- 🔌 **A2A Protocol** - Agent-to-agent communication support
- 🔍 **Vector Memory** - FAISS-powered persistent memory with semantic search
- 🖥️ **Multi-LLM Support** - OpenAI, Anthropic, Google, Ollama, OpenRouter + more

## Project Structure

```
deby-lite/
├── agent.py              # Core agent logic
├── models.py             # LLM model definitions
├── run_ui.py             # Web UI server entry point
├── initialize.py         # System initialization
├── start_deby_lite.sh    # Docker startup script
├── requirements.txt      # Python dependencies
├── agents/               # Agent profile definitions
│   ├── agent0/           # Primary user-facing agent
│   ├── developer/        # Code-focused agent
│   ├── researcher/       # Research-focused agent
│   ├── hacker/           # Cybersecurity agent
│   ├── deby/             # Deby custom agent
│   └── _example/         # Template for custom agents
├── prompts/              # System prompt templates
├── conf/                 # Configuration files
├── python/               # Framework internals
│   ├── api/              # REST API endpoints
│   ├── tools/            # Agent tool implementations
│   ├── helpers/          # Utility modules
│   └── extensions/       # Hook-based extensions
├── webui/                # Frontend web interface
├── skills/               # Installed skills
│   └── create-skill/     # Skill creation wizard
├── knowledge/            # Knowledge base (gitkeep)
└── lib/                  # Browser automation scripts
```

## Quick Start

### Docker
```bash
docker run -p 8080:8080 \
  -e A0_ROOT=/deby \
  -v ./usr:/deby/usr \
  deby-lite
```

### Manual
```bash
# Install dependencies
pip install -r requirements.txt

# Start the web UI
bash start_deby_lite.sh
```

Then open http://localhost:8080 in your browser.

## Configuration

Copy and edit the environment file:
```bash
cp .env.example usr/.env
# Add your API keys (OpenAI, Anthropic, etc.)
```

## Skills

Skills extend agent capabilities. Install from [AgentSkills.io](https://agentskills.io) or create your own using the built-in `create-skill` wizard.

## License

Based on [Agent Zero](https://github.com/frdel/agent-zero) by frdel.
