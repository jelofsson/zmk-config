#!/bin/bash

# Variables
source .env
REPO="$REPO" # Repository from .env
TOKEN="$TOKEN" # GitHub token from .env
OUTPUT_DIR="$OUTPUT_DIR" # Output directory from .env

# Get the latest workflow run ID
LATEST_RUN_ID=$(curl -s -H "Authorization: token $TOKEN" \
  "https://api.github.com/repos/$REPO/actions/runs?per_page=1" | \
  jq -r '.workflow_runs[0].id')

if [ -z "$LATEST_RUN_ID" ] || [ "$LATEST_RUN_ID" == "null" ]; then
  echo "Error: Unable to fetch the latest workflow run ID. Check your repository and token."
  exit 1
fi

# Get the artifact download URL
ARTIFACT_URL=$(curl -s -H "Authorization: token $TOKEN" \
  "https://api.github.com/repos/$REPO/actions/runs/$LATEST_RUN_ID/artifacts" | \
  jq -r '.artifacts[0].archive_download_url')

if [ -z "$ARTIFACT_URL" ] || [ "$ARTIFACT_URL" == "null" ]; then
  echo "Error: Unable to fetch the artifact download URL. Check if artifacts are available."
  exit 1
fi

# Download the artifact
curl -L -H "Authorization: token $TOKEN" \
  -o "$OUTPUT_DIR/latest_artifact.zip" "$ARTIFACT_URL"

if [ $? -ne 0 ]; then
  echo "Error: Failed to download the artifact."
  exit 1
fi

echo "Artifact downloaded to $OUTPUT_DIR/latest_artifact.zip"

# Extract the artifact and overwrite any existing files
unzip -o "$OUTPUT_DIR/latest_artifact.zip" -d "$OUTPUT_DIR"

if [ $? -ne 0 ]; then
  echo "Error: Failed to extract the artifact."
  exit 1
fi
