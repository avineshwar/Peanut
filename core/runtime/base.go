// Copyright 2021 Clivern. All rights reserved.
// Use of this source code is governed by the MIT
// license that can be found in the LICENSE file.

package runtime

// Containerization interface
type Containerization interface {
	Deploy(serviceID, service string, configs map[string]string) (map[string]string, error)
	Destroy(serviceID, service string, configs map[string]string) error
}
