# Stratus Red Team AWS CloudShell Setup

This repository provides an automated setup script for installing and running Stratus Red Team in AWS CloudShell for defensive security testing and purple team exercises.

## 🎯 What is Stratus Red Team?

Stratus Red Team is an open-source framework that allows security teams to simulate realistic attack techniques in AWS environments. It's designed for:

- **Purple Team Exercises**: Testing detection capabilities
- **Security Research**: Understanding attack patterns
- **Training**: Learning cloud security concepts
- **Validation**: Confirming security controls work as expected

## 🚀 Quick Start

### Prerequisites

- Access to AWS CloudShell (recommended) or an EC2 instance with appropriate permissions
- AWS credentials configured with sufficient permissions to create/modify resources
- Internet connectivity to download tools and packages

### One-Line Installation

```bash
curl -fsSL https://raw.githubusercontent.com/andrewkrug/stratus_cloudshell_example/refs/heads/main/setup-stratus.sh | bash
```

Or clone and run manually:

```bash
git clone https://github.com/andrewkrug/stratus_cloudshell_example.git
cd stratus-cloudshell-setup
chmod +x setup-stratus.sh
./setup-stratus.sh
```

## 📋 What the Script Does

### 1. Environment Verification
- ✅ Checks AWS CLI configuration
- ✅ Validates AWS credentials and permissions
- ✅ Ensures running in supported environment

### 2. Terraform Installation
- 📦 Downloads Terraform v1.5.7 (latest stable)
- 🔧 Installs to `/usr/local/bin/terraform`
- ✅ Verifies installation with version check

### 3. Stratus Red Team Installation
- 📥 Downloads latest Stratus Red Team release from GitHub
- 🔧 Installs binary to `/usr/local/bin/stratus`
- 🎯 Initializes Stratus workspace

### 4. Workspace Setup
- 📁 Creates `~/stratus-workspace` directory
- 🔄 Initializes Stratus configuration
- 📝 Lists available attack techniques

### 5. Example Execution (Optional)
- 🎯 Demonstrates `aws.defense-evasion.cloudtrail-stop` technique
- 🚀 Shows complete warmup → detonate → cleanup cycle
- 📊 Provides execution feedback

## 🛠️ Manual Usage

After installation, you can use Stratus Red Team with these commands:

### Basic Commands

```bash
# Navigate to workspace
cd ~/stratus-workspace

# List all available techniques
stratus list

# List techniques by category
stratus list --platform aws
stratus list --tactic defense-evasion

# Get information about a specific technique
stratus show aws.defense-evasion.cloudtrail-stop
```

### Technique Execution Workflow

```bash
# 1. Warm up (provision required infrastructure)
stratus warmup <technique-id>

# 2. Detonate (execute the attack)
stratus detonate <technique-id>

# 3. Clean up (remove provisioned resources)
stratus cleanup <technique-id>
```

### Example Technique Executions

#### CloudTrail Evasion
```bash
# Stop CloudTrail logging (defense evasion)
stratus warmup aws.defense-evasion.cloudtrail-stop
stratus detonate aws.defense-evasion.cloudtrail-stop
stratus cleanup aws.defense-evasion.cloudtrail-stop
```

#### Credential Access
```bash
# Retrieve EC2 instance password
stratus warmup aws.credential-access.ec2-get-password-data
stratus detonate aws.credential-access.ec2-get-password-data
stratus cleanup aws.credential-access.ec2-get-password-data
```

#### Persistence
```bash
# Create administrative IAM user
stratus warmup aws.persistence.iam-create-admin-user
stratus detonate aws.persistence.iam-create-admin-user
stratus cleanup aws.persistence.iam-create-admin-user
```

#### Discovery
```bash
# Enumerate EC2 instances from within an instance
stratus warmup aws.discovery.ec2-enumerate-from-instance
stratus detonate aws.discovery.ec2-enumerate-from-instance
stratus cleanup aws.discovery.ec2-enumerate-from-instance
```

## 🔍 Understanding Technique Categories

### Available MITRE ATT&CK Tactics

- **Initial Access**: Gaining entry to AWS environment
- **Execution**: Running malicious code
- **Persistence**: Maintaining access
- **Privilege Escalation**: Gaining higher permissions
- **Defense Evasion**: Avoiding detection
- **Credential Access**: Stealing credentials
- **Discovery**: Gathering information
- **Lateral Movement**: Moving through environment
- **Collection**: Gathering data
- **Impact**: Disrupting availability or integrity

## 🛡️ Security Best Practices

### Before Running Techniques

1. **Isolated Environment**: Use dedicated AWS accounts for testing
2. **Permission Boundaries**: Implement least-privilege access
3. **Monitoring**: Enable CloudTrail, GuardDuty, and other monitoring
4. **Backup**: Ensure critical data is backed up
5. **Team Coordination**: Notify team members of planned exercises

### During Execution

1. **Documentation**: Record all techniques executed
2. **Timing**: Note execution times for correlation
3. **Monitoring**: Watch security alerts and logs
4. **Screenshots**: Capture evidence for reporting

### After Execution

1. **Cleanup**: Always run cleanup commands
2. **Verification**: Confirm all resources are removed
3. **Analysis**: Review security tool responses
4. **Reporting**: Document findings and improvements

## 🔧 Troubleshooting

### Common Issues

#### Permission Errors
```bash
# Check current AWS identity
aws sts get-caller-identity

# Verify required permissions
aws iam get-user
aws iam list-attached-user-policies --user-name $(aws sts get-caller-identity --query 'Arn' --output text | cut -d'/' -f2)
```

#### Installation Issues
```bash
# Check if tools are in PATH
which terraform
which stratus

# Verify versions
terraform version
stratus version
```

#### Technique Failures
```bash
# Check Stratus logs
stratus --log-level debug detonate <technique-id>

# Verify Terraform state
cd ~/stratus-workspace
terraform show
```

### Required AWS Permissions

The following IAM permissions are typically required:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:*",
                "iam:*",
                "logs:*",
                "cloudtrail:*",
                "s3:*",
                "lambda:*",
                "sts:*"
            ],
            "Resource": "*"
        }
    ]
}
```

**Note**: This is a broad permission set. In production, use more restrictive policies.

## 📚 Additional Resources

### Stratus Red Team Documentation
- [Official Documentation](https://stratus-red-team.cloud/)
- [GitHub Repository](https://github.com/DataDog/stratus-red-team)
- [Technique Reference](https://stratus-red-team.cloud/attack-techniques/)

### MITRE ATT&CK Framework
- [Cloud Matrix](https://attack.mitre.org/matrices/enterprise/cloud/)
- [AWS-Specific Techniques](https://attack.mitre.org/techniques/enterprise/cloud/)

### AWS Security Resources
- [AWS Security Best Practices](https://aws.amazon.com/security/security-learning/)
- [AWS CloudTrail Documentation](https://docs.aws.amazon.com/cloudtrail/)
- [AWS GuardDuty Documentation](https://docs.aws.amazon.com/guardduty/)

## 🤝 Contributing

We welcome contributions! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## ⚠️ Disclaimer

This tool is intended for legitimate security testing and educational purposes only. Users are responsible for:

- Ensuring proper authorization before testing
- Complying with applicable laws and regulations
- Using only in environments they own or have explicit permission to test
- Properly cleaning up all resources after testing

The authors are not responsible for any misuse or damage caused by this tool.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

If you encounter issues:

1. Check the troubleshooting section above
2. Review [Stratus Red Team Issues](https://github.com/DataDog/stratus-red-team/issues)
3. Create an issue in this repository
4. Contact your security team for guidance

---

**Happy Purple Teaming! 🟣**