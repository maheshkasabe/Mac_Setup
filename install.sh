#!/bin/bash

# Function to check if Homebrew is installed
check_homebrew() {
    if ! command -v brew &> /dev/null
    then
        echo "Homebrew not found, installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "Homebrew is already installed."
    fi
}

# Function to update and upgrade Homebrew
update_homebrew() {
    echo "Updating Homebrew..."
    brew update
    echo "Upgrading installed packages..."
    brew upgrade
}

# Function to install command-line tools
install_cli_tools() {
    echo "Installing command-line tools..."
    
    # List of CLI tools to install
    CLI_TOOLS=(
        git
        node
        nvm
        python
        wget
        yarn
        go
        minikube
    )

    for TOOL in "${CLI_TOOLS[@]}"; do
        if brew list --formula | grep -q "^${TOOL}\$"; then
            echo "$TOOL is already installed."
        else
            echo "Installing $TOOL..."
            brew install $TOOL
        fi
    done
}

# Function to install graphical tools (GUI applications)
install_gui_tools() {
    echo "Installing graphical tools..."
    
    # List of GUI apps to install via Homebrew Cask
    GUI_TOOLS=(
        brave
        visual-studio-code
        hyper
        lens
        docker
        notion
    )

    for APP in "${GUI_TOOLS[@]}"; do
        if brew list --cask | grep -q "^${APP}\$"; then
            echo "$APP is already installed."
        else
            echo "Installing $APP..."
            brew install --cask $APP
        fi
    done
}

# Function to setup GitHub SSH
setup_github_ssh() {
    echo "Setting up GitHub SSH..."
    
    # Prompt for GitHub email
    read -p "Enter your GitHub email: " email
    
    # Generate SSH key
    if [ -f ~/.ssh/id_rsa ]; then
        echo "SSH key already exists, skipping generation."
    else
        echo "Generating SSH key for GitHub..."
        ssh-keygen -t rsa -b 4096 -C "$email" -f ~/.ssh/id_rsa -N ""
    fi
    
    # Start the SSH agent and add the SSH key
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_rsa
    
    # Create or update SSH config for GitHub
    if [ ! -f ~/.ssh/config ]; then
        touch ~/.ssh/config
    fi

    if ! grep -q "Host github.com" ~/.ssh/config; then
        echo "Configuring SSH for GitHub..."
        cat <<EOL >> ~/.ssh/config

Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_rsa
  AddKeysToAgent yes
EOL
    fi

    # Output SSH public key for GitHub setup
    echo "Here is your SSH public key:"
    cat ~/.ssh/id_rsa.pub

    echo "Copy this key and add it to your GitHub account: https://github.com/settings/keys"
}

# Function to cleanup Homebrew
cleanup_homebrew() {
    echo "Cleaning up Homebrew..."
    brew cleanup
}

# Execution starts here
check_homebrew
update_homebrew
install_cli_tools
install_gui_tools
cleanup_homebrew

echo "All done!"
