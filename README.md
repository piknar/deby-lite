# Deby Lite 🤖

A customized [Agent Zero](https://github.com/frdel/agent-zero) AI agent system running in Docker.
Built on **Debian Trixie 13.3** with specialized agent profiles, an intuitive web UI, and **Web3-native token inference support**.

> 🐧 **Platform Note:** Deby Lite runs on **Debian Trixie 13.3** (stable/testing), whereas the base [Agent Zero](https://github.com/frdel/agent-zero) framework runs on a **Kali Linux** flavored Docker image. Deby is optimized for clean Debian environments prioritizing stability and production deployments.

## 🌐 Web3 Compliant Agent

Deby Lite is a **Web3 compliant AI agent** that supports decentralized token-based inference — compatible with the Agent Zero token ecosystem.

### 💎 Supported Tokens

| Token | Description |
|-------|-------------|
| **A0T** (Agent Zero Token) | Native utility token for Agent Zero ecosystem inference and compute credits |
| **Diem** | Stablecoin-backed token for inference payments and agent service transactions |

- Pay for LLM inference using **A0T** or **Diem** tokens
- Compatible with Agent Zero's decentralized inference marketplace
- Token-gated agent capabilities and compute tiers
- Wallet integration for seamless on-chain inference billing
- Works alongside traditional API key providers (OpenAI, Anthropic, etc.)

## Features

- 🐧 **Debian Trixie 13.3** - Stable production-grade Linux base (vs Kali in base Agent Zero)
- 🧠 **Multiple Agent Profiles** - Default, Agent0, Developer, Researcher, Hacker, Deby
- 🛠️ **Built-in Tools** - Code execution, browser control, memory management, file operations, web search
- 🌐 **Web UI** - Full-featured chat interface with settings, scheduler, and project management
- 💡 **Skills System** - Extensible skill framework (AgentSkills.io standard)
- 📅 **Task Scheduler** - Cron-based, planned, and ad-hoc task scheduling
- 🔌 **A2A Protocol** - Agent-to-agent communication support
- 🔍 **Vector Memory** - FAISS-powered persistent memory with semantic search
- 🖥️ **Multi-LLM Support** - OpenAI, Anthropic, Google, Ollama, OpenRouter + more
- 🌐 **Web3 Ready** - A0T & Diem token inference payments

## Deby vs Agent Zero

| Feature | Deby Lite | Agent Zero |
|---------|-----------|------------|
| **Base OS** | Debian Trixie 13.3 | Kali Linux |
| **Focus** | Production / Stable | Hacking / Pentesting |
| **Web3 Tokens** | ✅ A0T + Diem | ✅ A0T + Diem |
| **Agent Profiles** | Agent0, Developer, Researcher, Hacker, Deby | Agent0, Default |
| **Custom Skills** | ✅ Extended skill set | ✅ Base skills |

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
# Add your API keys (OpenAI, Anthropic, etc.) or configure Web3 wallet for A0T/Diem inference
```

## Skills

Skills extend agent capabilities. Install from [AgentSkills.io](https://agentskills.io) or create your own using the built-in `create-skill` wizard.

## License

Based on [Agent Zero](https://github.com/frdel/agent-zero) by frdel.
