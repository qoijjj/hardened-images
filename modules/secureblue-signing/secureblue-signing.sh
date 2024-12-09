#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

CONTAINER_DIR="/etc/containers"
MODULE_DIRECTORY="${MODULE_DIRECTORY:-"/tmp/modules"}"
IMAGE_NAME_FILE="${IMAGE_NAME//\//_}"
IMAGE_REGISTRY_TITLE=$(echo "$IMAGE_REGISTRY" | cut -d'/' -f2-)

echo "Setting up container signing in policy.json and cosign.yaml for $IMAGE_NAME"
echo "Registry to write: $IMAGE_REGISTRY"

if ! [ -d "$CONTAINER_DIR" ]; then
    mkdir -p "$CONTAINER_DIR"
fi

if ! [ -d $CONTAINER_DIR/registries.d ]; then
   mkdir -p "$CONTAINER_DIR/registries.d"
fi

if ! [ -d "/etc/pki/containers" ]; then
    mkdir -p "/etc/pki/containers"
fi

mv "/etc/pki/containers/$IMAGE_NAME.pub" "/etc/pki/containers/$IMAGE_REGISTRY_TITLE.pub"

TEMPLATE_POLICY="$MODULE_DIRECTORY/signing/policy.json"
POLICY_FILE="$CONTAINER_DIR/policy.json"

jq --arg image_registry "${IMAGE_REGISTRY}" \
   --arg image_registry_title "${IMAGE_REGISTRY_TITLE}" \
   '.transports.docker |= 
    { $image_registry: [
        {
            "type": "sigstoreSigned",
            "keyPath": ("/etc/pki/containers/" + $image_registry_title + ".pub"),
            "signedIdentity": {
                "type": "matchRepository"
            }
        }
    ] } + .' "${TEMPLATE_POLICY}" > "${POLICY_FILE}"

mv "$MODULE_DIRECTORY/signing/registry-config.yaml" "$CONTAINER_DIR/registries.d/$IMAGE_REGISTRY_TITLE.yaml"
sed -i "s ghcr.io/IMAGENAME $IMAGE_REGISTRY g" "$CONTAINER_DIR/registries.d/$IMAGE_REGISTRY_TITLE.yaml"
