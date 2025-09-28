#!/bin/bash

set -euo pipefail

WORKSPACE_DIR="$HOME/stratus-workspace"
LOG_DIR="$WORKSPACE_DIR/logs"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

cd "$WORKSPACE_DIR" || {
    echo "❌ Stratus workspace not found. Please run setup-stratus.sh first."
    exit 1
}

mkdir -p "$LOG_DIR"

echo "🟣 Purple Team Exercise - Stratus Red Team"
echo "========================================"
echo "Exercise ID: purple_team_$TIMESTAMP"
echo "Log Directory: $LOG_DIR"
echo ""

TECHNIQUES=(
    "aws.defense-evasion.cloudtrail-stop"
    "aws.credential-access.ec2-get-password-data"
    "aws.discovery.ec2-enumerate-from-instance"
    "aws.persistence.iam-create-admin-user"
)

run_technique() {
    local technique=$1
    local log_file="$LOG_DIR/${technique}_${TIMESTAMP}.log"

    echo "🎯 Executing technique: $technique"
    echo "📝 Logging to: $log_file"

    {
        echo "=== TECHNIQUE: $technique ==="
        echo "Timestamp: $(date)"
        echo "Exercise ID: purple_team_$TIMESTAMP"
        echo ""

        echo "--- WARMUP PHASE ---"
        stratus warmup "$technique" 2>&1
        echo ""

        echo "--- DETONATION PHASE ---"
        stratus detonate "$technique" 2>&1
        echo ""

        echo "--- CLEANUP PHASE ---"
        stratus cleanup "$technique" 2>&1
        echo ""

        echo "=== TECHNIQUE COMPLETED ==="
        echo ""
    } | tee -a "$log_file"

    echo "✅ Technique $technique completed"
    echo ""
}

main() {
    echo "Starting purple team exercise with ${#TECHNIQUES[@]} techniques..."
    echo ""

    for technique in "${TECHNIQUES[@]}"; do
        read -p "Execute technique $technique? (y/N): " -n 1 -r
        echo

        if [[ $REPLY =~ ^[Yy]$ ]]; then
            run_technique "$technique"
        else
            echo "⏭️  Skipping $technique"
            echo ""
        fi
    done

    echo "🎉 Purple team exercise completed!"
    echo "📊 Review logs in: $LOG_DIR"
    echo ""
    echo "Next steps:"
    echo "1. Analyze security tool alerts"
    echo "2. Review CloudTrail logs"
    echo "3. Check GuardDuty findings"
    echo "4. Document lessons learned"
}

if [[ "${BASH_SOURCE[0]:-$0}" == "${0}" ]]; then
    main "$@"
fi