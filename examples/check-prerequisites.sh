#!/bin/bash

set -euo pipefail

echo "🔍 Stratus Red Team - Prerequisites Check"
echo "========================================"
echo ""

check_command() {
    local cmd=$1
    local name=$2

    if command -v "$cmd" >/dev/null 2>&1; then
        local version
        case $cmd in
            "terraform")
                version=$(terraform version | head -n1 | cut -d' ' -f2)
                ;;
            "stratus")
                version=$(stratus version 2>/dev/null | head -n1 || echo "unknown")
                ;;
            "aws")
                version=$(aws --version | cut -d' ' -f1 | cut -d'/' -f2)
                ;;
            "jq")
                version=$(jq --version | cut -d'-' -f2)
                ;;
            *)
                version="present"
                ;;
        esac
        echo "✅ $name: $version"
        return 0
    else
        echo "❌ $name: not found"
        return 1
    fi
}

check_aws_config() {
    echo ""
    echo "🔐 Checking AWS Configuration..."

    if aws sts get-caller-identity >/dev/null 2>&1; then
        local account_id region user_arn
        account_id=$(aws sts get-caller-identity --query 'Account' --output text)
        user_arn=$(aws sts get-caller-identity --query 'Arn' --output text)
        region=$(aws configure get region || echo "not-set")

        echo "✅ AWS CLI authenticated"
        echo "   Account ID: $account_id"
        echo "   User/Role: $user_arn"
        echo "   Region: $region"

        if [ "$region" = "not-set" ]; then
            echo "⚠️  No default region set. Consider setting one:"
            echo "   aws configure set region us-east-1"
        fi
    else
        echo "❌ AWS CLI not authenticated"
        echo "   Please configure AWS credentials"
        return 1
    fi
}

check_permissions() {
    echo ""
    echo "🛡️  Checking Basic AWS Permissions..."

    local tests=(
        "sts:GetCallerIdentity"
        "iam:GetUser"
        "ec2:DescribeInstances"
        "logs:DescribeLogGroups"
    )

    for test in "${tests[@]}"; do
        local service action
        service=$(echo "$test" | cut -d':' -f1)
        action=$(echo "$test" | cut -d':' -f2)

        case $service in
            "sts")
                if aws sts get-caller-identity >/dev/null 2>&1; then
                    echo "✅ $test"
                else
                    echo "❌ $test"
                fi
                ;;
            "iam")
                if aws iam get-user >/dev/null 2>&1; then
                    echo "✅ $test"
                else
                    echo "⚠️  $test (may not be available for some role types)"
                fi
                ;;
            "ec2")
                if aws ec2 describe-instances --max-items 1 >/dev/null 2>&1; then
                    echo "✅ $test"
                else
                    echo "❌ $test"
                fi
                ;;
            "logs")
                if aws logs describe-log-groups --max-items 1 >/dev/null 2>&1; then
                    echo "✅ $test"
                else
                    echo "❌ $test"
                fi
                ;;
        esac
    done
}

check_environment() {
    echo ""
    echo "🌍 Environment Information..."

    echo "OS: $(uname -s) $(uname -r)"
    echo "Architecture: $(uname -m)"

    if [ -n "${AWS_EXECUTION_ENV:-}" ]; then
        echo "✅ Running in AWS CloudShell"
    elif [ -n "${AWS_LAMBDA_FUNCTION_NAME:-}" ]; then
        echo "✅ Running in AWS Lambda"
    elif curl -s -m 2 http://169.254.169.254/latest/meta-data/instance-id >/dev/null 2>&1; then
        echo "✅ Running on AWS EC2 instance"
    else
        echo "⚠️  Not detected as AWS-managed environment"
        echo "   Ensure AWS credentials are properly configured"
    fi
}

main() {
    local all_good=true

    echo "📋 Checking required tools..."
    check_command "bash" "Bash" || all_good=false
    check_command "curl" "cURL" || all_good=false
    check_command "wget" "wget" || all_good=false
    check_command "unzip" "unzip" || all_good=false
    check_command "jq" "jq" || all_good=false
    check_command "aws" "AWS CLI" || all_good=false

    echo ""
    echo "🔧 Checking Stratus components..."
    check_command "terraform" "Terraform" || echo "   Will be installed by setup script"
    check_command "stratus" "Stratus Red Team" || echo "   Will be installed by setup script"

    check_aws_config || all_good=false
    check_permissions
    check_environment

    echo ""
    echo "📊 Prerequisites Summary"
    echo "======================="

    if [ "$all_good" = true ]; then
        echo "✅ All prerequisites met! Ready to run setup-stratus.sh"
    else
        echo "❌ Some prerequisites not met. Please address the issues above."
        echo ""
        echo "💡 Common solutions:"
        echo "   - Install missing tools: sudo yum install -y jq curl wget unzip"
        echo "   - Configure AWS CLI: aws configure"
        echo "   - Verify AWS permissions with your administrator"
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi