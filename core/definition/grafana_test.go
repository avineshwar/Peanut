// Copyright 2021 Clivern. All rights reserved.
// Use of this source code is governed by the MIT
// license that can be found in the LICENSE file.

package definition

import (
	"fmt"
	"strings"
	"testing"

	"github.com/franela/goblin"
)

// TestUnitGrafana test cases
func TestUnitGrafana(t *testing.T) {
	g := goblin.Goblin(t)

	g.Describe("#TestGrafana", func() {
		g.It("It should satisfy all provided test cases", func() {
			grafana := GetGrafanaConfig("grafana", "grafana1", "grafana2")
			result, err := grafana.ToString()

			g.Assert(strings.Contains(result, fmt.Sprintf("image: %s", GrafanaDockerImage))).Equal(true)
			g.Assert(strings.Contains(result, fmt.Sprintf(`- "%s"`, GrafanaPort))).Equal(true)
			g.Assert(strings.Contains(result, fmt.Sprintf("restart: %s", GrafanaRestartPolicy))).Equal(true)
			g.Assert(strings.Contains(result, "GF_USERS_ALLOW_SIGN_UP=false")).Equal(true)
			g.Assert(strings.Contains(result, "GF_SECURITY_ADMIN_USER=grafana1")).Equal(true)
			g.Assert(strings.Contains(result, "GF_SECURITY_ADMIN_PASSWORD=grafana2")).Equal(true)
			g.Assert(err).Equal(nil)

			grafana = GetGrafanaConfig("grafana", "", "")
			result, err = grafana.ToString()

			g.Assert(strings.Contains(result, fmt.Sprintf("image: %s", GrafanaDockerImage))).Equal(true)
			g.Assert(strings.Contains(result, fmt.Sprintf(`- "%s"`, GrafanaPort))).Equal(true)
			g.Assert(strings.Contains(result, fmt.Sprintf("restart: %s", GrafanaRestartPolicy))).Equal(true)
			g.Assert(strings.Contains(result, "GF_USERS_ALLOW_SIGN_UP=false")).Equal(true)
			g.Assert(strings.Contains(result, fmt.Sprintf("GF_SECURITY_ADMIN_USER=%s", GrafanaDefaultUsername))).Equal(true)
			g.Assert(strings.Contains(result, fmt.Sprintf("GF_SECURITY_ADMIN_PASSWORD=%s", GrafanaDefaultPassword))).Equal(true)
			g.Assert(err).Equal(nil)
		})
	})
}
