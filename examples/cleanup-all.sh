#!/bin/bash

set -euo pipefail

WORKSPACE_DIR="$HOME/stratus-workspace"

cd "$WORKSPACE_DIR" || {
    echo "❌ Stratus workspace not found."
    exit 1
}

echo "🧹 Stratus Red Team - Cleanup All Resources"
echo "==========================================="
echo ""

echo "⚠️  This will clean up ALL Stratus Red Team resources!"
echo "This includes any techniques that may be in a 'warmed up' state."
echo ""

read -p "Are you sure you want to proceed? (y/N): " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Cleanup cancelled."
    exit 0
fi

echo "🔍 Checking for active techniques..."

ACTIVE_TECHNIQUES=$(stratus list --format json | jq -r '.[] | select(.state == "warmed-up") | .id' 2>/dev/null || echo "")

if [ -z "$ACTIVE_TECHNIQUES" ]; then
    echo "✅ No active techniques found. Nothing to clean up."
    exit 0
fi

echo "📋 Found the following active techniques:"
echo "$ACTIVE_TECHNIQUES"
echo ""

for technique in $ACTIVE_TECHNIQUES; do
    echo "🧹 Cleaning up: $technique"

    if stratus cleanup "$technique"; then
        echo "✅ Successfully cleaned up: $technique"
    else
        echo "❌ Failed to clean up: $technique"
        echo "   You may need to manually clean up AWS resources"
    fi
    echo ""
done

echo "🎉 Cleanup process completed!"
echo ""
echo "💡 Recommended next steps:"
echo "1. Verify in AWS Console that resources are removed"
echo "2. Check for any lingering CloudFormation stacks"
echo "3. Review AWS billing for unexpected charges"