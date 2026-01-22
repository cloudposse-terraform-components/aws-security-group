# Tests

This directory contains tests for the `aws-security-group` component.

## Prerequisites

- Go 1.23+
- Atmos CLI
- AWS credentials configured for the test account
- Environment variable `TEST_ACCOUNT_ID` set to the AWS account ID

## Running Tests

```bash
# Authenticate with AWS
export AWS_PROFILE=cptest-test-gbl-sandbox-admin
aws sts get-caller-identity

# Run tests with Atmos
atmos test run
```

## Test Cases

- **TestBasic**: Creates a security group with HTTPS ingress and all egress rules
- **TestEgressOnly**: Creates a security group with only egress rules (common for Lambda functions)
- **TestEnabledFlag**: Verifies the component respects the `enabled: false` flag
