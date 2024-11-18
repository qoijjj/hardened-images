#!/usr/bin/env bash

if ! command -v rpm-ostree &> /dev/null
then
    echo "This script only runs on Fedora Atomic"
    exit 1
fi

function is_yes {
    case $(echo "$1" | tr '[:upper:]' '[:lower:]') in
        y|yes) return 0;;
        *) return 1;;
    esac
}

# Define image configurations
desktop_image_types=(
    "silverblue"
    "kinoite"
    "sericea"
    "wayblue-wayfire"
    "wayblue-sway"
    "wayblue-river"
    "wayblue-hyprland"
    "cosmic"
)

image_name=""
additional_params=""

echo "Welcome to the secureblue interactive installer!" 
echo "After answering the following questions, your system will be rebased to secureblue." 
echo "-----------------------------------------------------------------------------------"

# Determine if it's a server or desktop
read -p "Is this for a server? (yes/No): " is_server
if is_yes "$is_server"; then
    read -p "Do you need ZFS support? (yes/No): " use_zfs
    image_name=$(is_yes "$use_zfs" && echo "securecore-zfs" || echo "securecore")
else
    echo "Select a desktop. Silverblue is recommended."
    select image_name in "${desktop_image_types[@]}"; do
        if [[ -n "$image_name" ]]; then        
            echo "Selected desktop: $image_name"
            if [[ "$image_name" == "cosmic" ]]; then
                echo "Warning: Cosmic images are experimental."
            fi

            if [[ "$image_name" == *"wayblue"* ]]; then
                echo "Warning: Wayblue images are in beta."
            fi

            break
        else
            echo "Invalid option, please select a valid number."
        fi
    done
    
fi

# Ask about Nvidia for all options
read -p "Do you have Nvidia? (yes/No): " use_nvidia
if is_yes "$use_nvidia"; then
    additional_params+="-nvidia" 
    read -p "Do you need Nvidia's open drivers? (yes/No): " use_open
    is_yes "$use_open" && additional_params+="-open"
else
    additional_params+="-main"
fi

# Ask about user namespaces for all options
read -p "Do you need unprivileged user namespaces? (yes/No): " use_userns
is_yes "$use_userns" && additional_params+="-userns"

image_name+="$additional_params-hardened"

rebase_command="rpm-ostree rebase ostree-unverified-registry:ghcr.io/secureblue/$image_name:latest"

echo "Commands to execute:"
echo "$rebase_command"
echo ""

read -p "Proceed? (yes/No): " rebase_proceed
if is_yes "$rebase_proceed"; then
    $rebase_command
fi
