

set -e  # Exit on error

echo "===== AgenticSeek macOS Deployment Script ====="
echo "This script will deploy AgenticSeek on your macOS system."
echo "Make sure you have the necessary permissions to install software."
echo ""

if [[ "$(uname)" != "Darwin" ]]; then
    echo "Error: This script is intended for macOS only."
    echo "Current OS: $(uname)"
    exit 1
fi

echo "Checking Python version..."
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is not installed."
    echo "Please install Python 3.10 or newer from https://www.python.org/downloads/"
    exit 1
fi

PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d'.' -f1)
PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d'.' -f2)

if [[ $PYTHON_MAJOR -lt 3 || ($PYTHON_MAJOR -eq 3 && $PYTHON_MINOR -lt 10) ]]; then
    echo "Error: Python 3.10 or newer is required."
    echo "Current version: $PYTHON_VERSION"
    echo "Please upgrade Python or install a newer version."
    exit 1
fi

echo "Python version $PYTHON_VERSION detected. ✓"

echo "Checking for Chrome browser..."
if [[ ! -d "/Applications/Google Chrome.app" ]]; then
    echo "Warning: Google Chrome not found in /Applications."
    echo "Please install Chrome from https://www.google.com/chrome/"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    CHROME_VERSION=$(/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --version | cut -d' ' -f3)
    echo "Chrome version $CHROME_VERSION detected. ✓"
fi

echo "Checking for Homebrew..."
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    if [[ -f ~/.zshrc ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f ~/.bash_profile ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.bash_profile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo "Homebrew is installed. ✓"
fi

echo "Updating Homebrew..."
brew update

echo "Installing ChromeDriver..."
brew install --cask chromedriver || brew upgrade --cask chromedriver

echo "Installing PortAudio..."
brew install portaudio || brew upgrade portaudio

echo "Checking for Docker..."
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing Docker Desktop..."
    brew install --cask docker
    
    echo "Please open Docker Desktop manually to complete setup."
    echo "After Docker is running, press any key to continue..."
    read -n 1 -s
else
    echo "Docker is installed. ✓"
fi

echo "Checking if Docker is running..."
if ! docker info &> /dev/null; then
    echo "Docker is not running. Please start Docker Desktop."
    echo "After Docker is running, press any key to continue..."
    read -n 1 -s
fi
echo "Docker is running. ✓"

echo "Setting up Python virtual environment..."
if [[ ! -d "agentic_seek_env" ]]; then
    python3 -m venv agentic_seek_env
fi

echo "Activating virtual environment..."
source agentic_seek_env/bin/activate

echo "Upgrading pip and setuptools..."
python3 -m pip install --upgrade pip
pip3 install --upgrade setuptools wheel

echo "Installing Python dependencies..."
pip3 install -r requirements.txt

echo "Checking for .env file..."
if [[ ! -f ".env" && -f ".env.example" ]]; then
    echo "Creating .env file from example..."
    cp .env.example .env
fi

echo "Configuring for macOS..."
USER_HOME=$(eval echo ~$USER)
WORKSPACE_DIR="$USER_HOME/Documents/agenticseek_workspace"

mkdir -p "$WORKSPACE_DIR"

echo "Updating config.ini..."
sed -i '' "s|work_dir =.*|work_dir = $WORKSPACE_DIR|g" config.ini

echo "Checking for Ollama..."
if ! command -v ollama &> /dev/null; then
    echo "Ollama not found. Would you like to install it? (Recommended for local LLM)"
    read -p "Install Ollama? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Installing Ollama..."
        curl -fsSL https://ollama.com/install.sh | sh
    else
        echo "Skipping Ollama installation."
        echo "You'll need to configure an API-based LLM provider in config.ini."
    fi
else
    echo "Ollama is installed. ✓"
    
    if ! curl -s http://localhost:11434/api/version &> /dev/null; then
        echo "Starting Ollama service..."
        ollama serve &
        sleep 5
    fi
    
    if ! ollama list | grep -q "deepseek-r1:14b"; then
        echo "Downloading deepseek-r1:14b model (this may take a while)..."
        ollama pull deepseek-r1:14b
    fi
fi

echo "Starting required services..."
./start_services.sh

echo ""
echo "===== Deployment Complete ====="
echo ""
echo "To run AgenticSeek:"
echo ""
echo "1. CLI Interface (recommended for first-time use):"
echo "   source agentic_seek_env/bin/activate"
echo "   python3 cli.py"
echo ""
echo "2. Web Interface:"
echo "   source agentic_seek_env/bin/activate"
echo "   python3 api.py"
echo "   Then open http://localhost:3000/ in your browser"
echo ""
echo "To exit, type or say 'goodbye'"
echo ""
echo "Enjoy using AgenticSeek on your Mac!"
