# AgenticSeek macOS Deployment Guide

This guide provides comprehensive instructions for deploying AgenticSeek on macOS, including all necessary steps from installation to configuration and running the application.

## Prerequisites

Before you begin, ensure you have the following:

- **Python 3.10 or newer**
  ```bash
  python3 --version
  ```

- **Google Chrome browser**
  ```bash
  # Check Chrome version
  /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --version
  ```

- **Docker Desktop for macOS**
  - Download and install from [https://www.docker.com/get-started/](https://www.docker.com/get-started/)

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/Fosowl/agenticSeek.git
cd agenticSeek
mv .env.example .env
```

### 2. Create a Python Virtual Environment

```bash
python3 -m venv agentic_seek_env
source agentic_seek_env/bin/activate
```

### 3. Install Dependencies

#### Option A: Automatic Installation (Recommended)

```bash
./install.sh
```

The script will automatically detect macOS and run the appropriate installation commands.

#### Option B: Manual Installation

If you prefer to install dependencies manually:

```bash
# Update Homebrew
brew update

# Install ChromeDriver
brew install --cask chromedriver

# Install PortAudio for audio support
brew install portaudio

# Upgrade pip and setuptools
python3 -m pip install --upgrade pip
pip3 install --upgrade setuptools wheel

# Install Python dependencies
pip3 install -r requirements.txt
```

### 4. ChromeDriver Setup Verification

Ensure that the ChromeDriver version matches your Chrome browser version:

```bash
# Check Chrome version
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --version

# Check ChromeDriver version
chromedriver --version
```

If you get a version mismatch error, download the matching ChromeDriver from:
[https://googlechromelabs.github.io/chrome-for-testing/](https://googlechromelabs.github.io/chrome-for-testing/)

Place the downloaded ChromeDriver in a directory in your PATH, for example:

```bash
# Move ChromeDriver to a directory in your PATH
sudo mv ~/Downloads/chromedriver /usr/local/bin/
sudo chmod +x /usr/local/bin/chromedriver
```

## Configuration

### Configure LLM Provider

#### Option A: Local LLM Setup (Recommended for Privacy)

1. Install and start Ollama:

```bash
# Install Ollama if not already installed
curl -fsSL https://ollama.com/install.sh | sh

# Start Ollama service
ollama serve
```

2. In a new terminal, pull the recommended model:

```bash
ollama pull deepseek-r1:14b
```

3. Edit the `config.ini` file to use local LLM:

```ini
[MAIN]
is_local = True
provider_name = ollama
provider_model = deepseek-r1:14b
provider_server_address = 127.0.0.1:11434
agent_name = Name_of_your_AI
recover_last_session = False
save_session = False
speak = False
listen = False
work_dir = /Users/yourusername/Documents/workspace
jarvis_personality = False
languages = en
[BROWSER]
headless_browser = True
stealth_mode = False
```

> **Note**: Replace `/Users/yourusername/Documents/workspace` with your preferred workspace directory.

#### Option B: API-based LLM Setup

1. Edit the `config.ini` file to use an API-based provider:

```ini
[MAIN]
is_local = False
provider_name = google   # or deepseek-api, togetherAI, etc.
provider_model = gemini-2.0-flash
provider_server_address = 127.0.0.1:5000  # doesn't matter for API
agent_name = Name_of_your_AI
recover_last_session = False
save_session = False
speak = False
listen = False
work_dir = /Users/yourusername/Documents/workspace
jarvis_personality = False
languages = en
[BROWSER]
headless_browser = True
stealth_mode = False
```

2. Set the API key as an environment variable:

```bash
export GOOGLE_API_KEY="your-api-key-here"  # Replace with appropriate provider
```

## Running AgenticSeek

### 1. Start Required Services

Activate the virtual environment if not already active:

```bash
source agentic_seek_env/bin/activate
```

Start Docker services:

```bash
sudo ./start_services.sh
```

### 2. Run AgenticSeek

#### Option A: CLI Interface

For CLI interface (recommended for better visibility of browser actions):

```bash
# First update config.ini to set headless_browser = False for better visibility
python3 cli.py
```

#### Option B: Web Interface

For web interface:

```bash
python3 api.py
```

Then open [http://localhost:3000/](http://localhost:3000/) in your browser.

## Verification

Test the installation with the following queries:

1. Basic functionality:
```
Hello, what can you do?
```

2. Web browsing capability:
```
Search the web for the current date and time in Paris.
```

3. Coding capability:
```
Write a simple Python function to calculate the factorial of a number.
```

## Troubleshooting

### ChromeDriver Mismatch Errors

If you encounter an error like:
```
Exception: Failed to initialize browser: Message: session not created: This version of ChromeDriver only supports Chrome version X. Current browser version is Y.
```

Follow these steps:
1. Go to [https://googlechromelabs.github.io/chrome-for-testing/](https://googlechromelabs.github.io/chrome-for-testing/)
2. Download the ChromeDriver version that matches your Chrome version
3. Replace the existing ChromeDriver with the downloaded version

### Connection Adapter Issues

If you see an error like:
```
Exception: Provider lm-studio failed: HTTP request failed: No connection adapters were found for '127.0.0.1:11434/v1/chat/completions'
```

Make sure you have `http://` in front of the provider IP address:
```
provider_server_address = http://127.0.0.1:11434
```

### SearxNG Base URL Error

If you get:
```
ValueError: SearxNG base URL must be provided either as an argument or via the SEARXNG_BASE_URL environment variable.
```

Ensure your `.env` file is set up correctly or export the environment variable:
```bash
export SEARXNG_BASE_URL="http://127.0.0.1:8080"
```

### Permission Issues with Docker

If you encounter permission issues with Docker on macOS:
1. Make sure Docker Desktop is running
2. Check that you have the necessary permissions to run Docker commands
3. Try running the command without `sudo` if you're using Docker Desktop

## Hardware Recommendations

For optimal performance on macOS:

- **For 14B models (recommended minimum)**: 12 GB VRAM (e.g., MacBook Pro with M1 Pro/Max)
- **For 32B models**: 24+ GB VRAM (e.g., Mac Studio with M1 Max/Ultra)
- **For 70B+ models**: 48+ GB VRAM (e.g., Mac Studio with M2 Ultra)

## Advanced Configuration

### Useful Environment Settings

- Set `headless_browser = False` in config.ini when using CLI mode to see browser actions
- Set `stealth_mode = True` in config.ini to reduce browser detection (requires manual installation of anticaptcha extension)
- Use `speak = True` to enable text-to-speech
- Set `listen = True` to enable speech-to-text (CLI mode only)

### Exiting the Application

Type or say "goodbye" to exit the application.

### Remote LLM Server Setup

For setting up a remote LLM server, see the "Setup to run the LLM on your own server" section in the main README.

### Multilingual Support

For multilingual support, add language codes to the `languages` setting in config.ini:
```
languages = en zh
```

## Additional Resources

- [Main AgenticSeek README](../README.md)
- [Contribution Guide](./CONTRIBUTING.md)
- [Ollama Documentation](https://github.com/ollama/ollama)
