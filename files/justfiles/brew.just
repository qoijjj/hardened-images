alias brew := install-brew

# Install Homebrew (Brew is now included by default. This command remains included for utility.)
install-brew:
    #!/usr/bin/env bash
    source /usr/lib/ujust/ujust.sh
    if [[ ! -f "/var/home/linuxbrew/.linuxbrew/bin" || ! -x "/var/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
        echo "${b}Brew Installation${n}"
        echo "Please ${b}IGNORE${n} everything the installer tells you to do at the end"
        echo "We have already done it for you! You just need to close and re-open the terminal after installation"
        echo "Do you understand?"
        echo "Please type in \"YES I UNDERSTAND\" and press enter"
        read ACCEPT
        if [ "$ACCEPT" == "YES I UNDERSTAND" ]; then
          /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        else
          echo "Capitalization matters when you type \"YES I UNDERSTAND\""
        fi
    fi

# Removes Homebrew from system. Warning! This will break MOTD and profile.d!
remove-brew:
    #!/usr/bin/env bash
    echo "Removing Homebrew is NOT supported."
    echo "Doing so will break MOTD and profile.d!"
    echo "Do you understand?"
    echo "Please type in \"YES I UNDERSTAND\" and press enter"
    read ACCEPT
    if [ "$ACCEPT" = "YES I UNDERSTAND" ]; then
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
    else
      echo "Capitalization matters when you type \"YES I UNDERSTAND\""
    fi
