#!/bin/bash

APP_VERSION="${1:-development}"; shift
go build -ldflags "-X main.version=${APP_VERSION}" -o build/hydra cmd/*.go

