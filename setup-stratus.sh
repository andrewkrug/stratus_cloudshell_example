#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STRATUS_VERSION="latest"
TERRAFORM_VERSION="1.5.7"

echo "🚀 Setting up Stratus Red Team in AWS CloudShell"
echo "================================================"

check_aws_cli() {
    echo "📋 Checking AWS CLI configuration..."
    if ! aws sts get-caller-identity >/dev/null 2>&1; then
        echo "❌ AWS CLI is not configured or credentials are invalid"
        echo "Please ensure you're running this in AWS CloudShell or have valid AWS credentials"
        exit 1
    fi
    echo "✅ AWS CLI is properly configured"
}

install_terraform() {
    echo "🔧 Installing Terraform..."

    if command -v terraform >/dev/null 2>&1; then
        CURRENT_VERSION=$(terraform version -json | jq -r '.terraform_version')
        echo "✅ Terraform already installed (version: $CURRENT_VERSION)"
        return 0
    fi

    cd /tmp
    wget -q "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
    unzip -q "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"

    sudo mv terraform /usr/local/bin/
    rm -f "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"

    echo "✅ Terraform ${TERRAFORM_VERSION} installed successfully"
    terraform version
}

install_stratus() {
    echo "🔧 Installing Stratus Red Team..."

    cd /tmp

    # Get the latest release URL
    STRATUS_URL=$(curl -s https://api.github.com/repos/DataDog/stratus-red-team/releases/latest | \
                  jq -r '.assets[] | select(.name | contains("linux") and contains("amd64")) | .browser_download_url')

    if [ -z "$STRATUS_URL" ]; then
        echo "❌ Failed to get Stratus Red Team download URL"
        exit 1
    fi

    echo "📥 Downloading Stratus Red Team from: $STRATUS_URL"
    wget -q "$STRATUS_URL" -O stratus.tar.gz

    tar -xzf stratus.tar.gz
    sudo mv stratus /usr/local/bin/
    rm -f stratus.tar.gz

    echo "✅ Stratus Red Team installed successfully"
    stratus version
}

setup_workspace() {
    echo "📁 Setting up workspace..."

    WORKSPACE_DIR="$HOME/stratus-workspace"
    mkdir -p "$WORKSPACE_DIR"
    cd "$WORKSPACE_DIR"

    # Initialize Stratus
    echo "🔄 Initializing Stratus Red Team..."
    stratus list

    echo "✅ Workspace created at: $WORKSPACE_DIR"
    echo "💡 Navigate to this directory to run Stratus techniques"
}

run_example_technique() {
    echo "🎯 Running example technique: aws.defense-evasion.cloudtrail-stop"
    echo "This is a safe technique that demonstrates Stratus capabilities"
    echo ""

    read -p "Do you want to run an example technique? (y/N): " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🚀 Warming up technique..."
        stratus warmup aws.defense-evasion.cloudtrail-stop

        echo "💥 Detonating technique..."
        stratus detonate aws.defense-evasion.cloudtrail-stop

        echo "🧹 Cleaning up..."
        stratus cleanup aws.defense-evasion.cloudtrail-stop

        echo "✅ Example technique completed successfully!"
    else
        echo "⏭️  Skipping example technique execution"
    fi
}

show_next_steps() {
    echo ""
    echo "🎉 Setup completed successfully!"
    echo "================================"
    echo ""
    echo "Next steps:"
    echo "1. Navigate to workspace: cd ~/stratus-workspace"
    echo "2. List available techniques: stratus list"
    echo "3. Warm up a technique: stratus warmup <technique-id>"
    echo "4. Detonate a technique: stratus detonate <technique-id>"
    echo "5. Clean up resources: stratus cleanup <technique-id>"
    echo ""
    echo "Popular techniques to try:"
    echo "- aws.credential-access.ec2-get-password-data"
    echo "- aws.defense-evasion.cloudtrail-stop"
    echo "- aws.persistence.iam-create-admin-user"
    echo "- aws.discovery.ec2-enumerate-from-instance"
    echo ""
    echo "⚠️  Remember to clean up resources after testing!"
    echo "📖 Check the README.md for detailed usage instructions"
}

main() {
    echo "Starting Stratus Red Team setup..."

    check_aws_cli
    install_terraform
    install_stratus
    setup_workspace
    run_example_technique
    show_next_steps
}

if [[ "${BASH_SOURCE[0]:-$0}" == "${0}" ]]; then
    main "$@"
fi