package test

import (
	"strings"
	"testing"

	"github.com/cloudposse/test-helpers/pkg/atmos"
	helper "github.com/cloudposse/test-helpers/pkg/atmos/component-helper"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type ComponentSuite struct {
	helper.TestSuite
}

func (s *ComponentSuite) TestBasic() {
	const component = "security-group/basic"
	const stack = "default-test"

	defer s.DestroyAtmosComponent(s.T(), component, stack, nil)
	options, _ := s.DeployAtmosComponent(s.T(), component, stack, nil)

	// Verify security group was created
	securityGroupId := atmos.Output(s.T(), options, "security_group_id")
	require.True(s.T(), strings.HasPrefix(securityGroupId, "sg-"), "Security group ID should have correct format")

	securityGroupArn := atmos.Output(s.T(), options, "security_group_arn")
	require.True(s.T(), strings.Contains(securityGroupArn, "security-group/"), "Security group ARN should have correct format")

	securityGroupName := atmos.Output(s.T(), options, "security_group_name")
	assert.NotEmpty(s.T(), securityGroupName, "Security group name should not be empty")

	// Verify aliases work
	id := atmos.Output(s.T(), options, "id")
	assert.Equal(s.T(), securityGroupId, id, "id output should match security_group_id")

	arn := atmos.Output(s.T(), options, "arn")
	assert.Equal(s.T(), securityGroupArn, arn, "arn output should match security_group_arn")

	name := atmos.Output(s.T(), options, "name")
	assert.Equal(s.T(), securityGroupName, name, "name output should match security_group_name")

	s.DriftTest(component, stack, nil)
}

func (s *ComponentSuite) TestEgressOnly() {
	const component = "security-group/egress-only"
	const stack = "default-test"

	defer s.DestroyAtmosComponent(s.T(), component, stack, nil)
	options, _ := s.DeployAtmosComponent(s.T(), component, stack, nil)

	// Verify security group was created
	securityGroupId := atmos.Output(s.T(), options, "security_group_id")
	require.True(s.T(), strings.HasPrefix(securityGroupId, "sg-"), "Security group ID should have correct format")

	s.DriftTest(component, stack, nil)
}

func (s *ComponentSuite) TestBypass() {
	// Test the account_map bypass pattern
	// When account_map_enabled=false, the component uses the static account_map variable
	const component = "security-group/bypass"
	const stack = "default-test"

	defer s.DestroyAtmosComponent(s.T(), component, stack, nil)
	options, _ := s.DeployAtmosComponent(s.T(), component, stack, nil)

	// Verify security group was created even with bypass enabled
	securityGroupId := atmos.Output(s.T(), options, "security_group_id")
	require.True(s.T(), strings.HasPrefix(securityGroupId, "sg-"), "Security group ID should have correct format")

	s.DriftTest(component, stack, nil)
}

func (s *ComponentSuite) TestEnabledFlag() {
	const component = "security-group/disabled"
	const stack = "default-test"
	s.VerifyEnabledFlag(component, stack, nil)
}

func TestRunSuite(t *testing.T) {
	suite := new(ComponentSuite)

	suite.AddDependency(t, "vpc", "default-test", nil)
	helper.Run(t, suite)
}
