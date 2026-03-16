package conf

import (
	"os"

	"github.com/joho/godotenv"
	"github.com/kokizzu/gotro/L"
)

var VERSION = ``

const PROJECT_NAME = `BenAkun`

func IsDebug() bool {
	return VERSION == ``
}

func LoadEnv() {
	dirRetryList := []string{``, `../`, `../../`, `../../../`}
	for _, dirPrefix := range dirRetryList {
		loadedAny := false
		envFile := dirPrefix + `.env`
		if _, err := os.Stat(envFile); err == nil {
			loadedAny = true
			err = godotenv.Overload(envFile)
			L.PanicIf(err, `godotenv.Load .env`)
		}
		envOverrideFile := dirPrefix + `.env.override`
		if _, err := os.Stat(envOverrideFile); err == nil {
			loadedAny = true
			err = godotenv.Overload(envOverrideFile)
			L.PanicIf(err, `godotenv.Load .env.override`)
		}
		if loadedAny {
			return
		}
	}

	if os.Getenv(`TARANTOOL_HOST`) != `` || os.Getenv(`CLICKHOUSE_HOST`) != `` || os.Getenv(`WEB_PORT`) != `` {
		return
	}

	panic(`cannot load .env/.env.override and no runtime environment provided`)
}
