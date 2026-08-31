// Package config reads and writes LabCheck's single "config" file, which
// holds the persisted student number and the global test timeout.
package config

import (
	"os"
	"path/filepath"

	"gopkg.in/yaml.v3"
)

// DefaultTimeoutSeconds is used when the config file is missing or doesn't
// specify a timeout.
const DefaultTimeoutSeconds = 60

// Config is the persisted content of the "config" file.
type Config struct {
	StudentNumber  int `yaml:"student_number"`
	TimeoutSeconds int `yaml:"timeout_seconds"`
}

// Dir returns the application's config directory (created on first Save).
func Dir() (string, error) {
	base, err := os.UserConfigDir()
	if err != nil {
		return "", err
	}
	return filepath.Join(base, "labcheck"), nil
}

// Path returns the full path to the "config" file.
func Path() (string, error) {
	dir, err := Dir()
	if err != nil {
		return "", err
	}
	return filepath.Join(dir, "config"), nil
}

// Load reads the config file. A missing file is treated as first launch and
// returns a zero-value student number with the default timeout.
func Load() (Config, error) {
	cfg := Config{TimeoutSeconds: DefaultTimeoutSeconds}

	path, err := Path()
	if err != nil {
		return cfg, err
	}

	data, err := os.ReadFile(path)
	if err != nil {
		if os.IsNotExist(err) {
			return cfg, nil
		}
		return cfg, err
	}

	if err := yaml.Unmarshal(data, &cfg); err != nil {
		return cfg, err
	}
	if cfg.TimeoutSeconds <= 0 {
		cfg.TimeoutSeconds = DefaultTimeoutSeconds
	}
	return cfg, nil
}

// Save writes the config file atomically, readable only by the current user.
func Save(cfg Config) error {
	dir, err := Dir()
	if err != nil {
		return err
	}
	if err := os.MkdirAll(dir, 0o700); err != nil {
		return err
	}

	data, err := yaml.Marshal(cfg)
	if err != nil {
		return err
	}

	path := filepath.Join(dir, "config")
	tmp := path + ".tmp"
	if err := os.WriteFile(tmp, data, 0o600); err != nil {
		return err
	}
	return os.Rename(tmp, path)
}
