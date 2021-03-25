# Hydra

[![Stability: Experimental](https://masterminds.github.io/stability/experimental.svg)](https://masterminds.github.io/stability/experimental.html)
[![Build Status](https://travis-ci.org/benkeil/hydra.svg?branch=master)](https://travis-ci.org/benkeil/hydra) [![Go Report Card](https://goreportcard.com/badge/github.com/benkeil/hydra)](https://goreportcard.com/report/github.com/benkeil/hydra) [![codecov](https://codecov.io/gh/benkeil/hydra/branch/master/graph/badge.svg)](https://codecov.io/gh/benkeil/hydra) [![Github Release](https://img.shields.io/github/release/benkeil/hydra.svg)](https://github.com/benkeil/hydra/releases)

Hydra helps you to build docker images of your applications with [semver](https://semver.org) based tags.


## Requirements

- Go [https://golang.org/dl/]
- Dep [https://github.com/golang/dep]
  ```go get -u github.com/golang/dep/cmd/dep```

- Make sure go can access the source code as `sedoTech/hydra` package.

By default go searches the source under `$GOPATH` which is `$HOME/go` by default

So cloning the project into `$HOME/go/src/github.com/SedoTech/hydra` should work in most cases.


## Update/Install dependencies

Before you can compile the package you need to make sure required libraries are available locally

- `dep ensure`                             install the project's dependencies
- `dep ensure -update`                     update the locked versions of all dependencies

This will create `vendor` directory and put them all there


## Compile executable

- Build final binary
  `export GO111MODULE=auto; scripts/build.sh 0.0.6` will create `build/hydra` executable binary with version `0.0.6`


## How it works

Hydra uses a config file named `hydra.yaml` to configure the build process of the docker images of your applications and generates multiple tags like the offical docker community images (for example the [golang](https://hub.docker.com/_/golang/) image).

Here is an example `hydra.yaml` for a typical php base image in that companies use:

```yaml
pull: true
image:
- my.private.registry:5000/docker-common/php-base
versions:
- directory: php5.6/alpine
  tags:
  - semver-php5.6-alpine
  - php5.6-alpine
  - semver-alpine
  - php5.6
  - latest
- directory: php5.6/debian
  tags:
  - semver-php5.6-debian
  - php5.6-debian
- directory: php7.1/debian
- directory: php7.1/alpine
  tags:
  - semver-php7.1-alpine
  - php7.1-alpine
  - php7.1
```

After you build your project with `hydra build 1.3.5` you get the following images:

```bash
build images from workdir examples/php-base/ with version 1.3.5
building examples/php-base/php5.6/alpine/
Step 1/1 : FROM php:5.6-alpine
---> cad28366b86f
Successfully built cad28366b86f
Successfully tagged my.private.registry:5000/docker-common/php-base:1.3.5-php5.6-alpine
Successfully tagged my.private.registry:5000/docker-common/php-base:1.3-php5.6-alpine
Successfully tagged my.private.registry:5000/docker-common/php-base:1-php5.6-alpine
Successfully tagged my.private.registry:5000/docker-common/php-base:php5.6-alpine
Successfully tagged my.private.registry:5000/docker-common/php-base:php5.6
Successfully tagged my.private.registry:5000/docker-common/php-base:latest
building examples/php-base/php5.6/debian/
Step 1/1 : FROM php:5.6-jessie
---> ee5bce1c39ee
Successfully built ee5bce1c39ee
Successfully tagged my.private.registry:5000/docker-common/php-base:1.3.5-php5.6-debian
Successfully tagged my.private.registry:5000/docker-common/php-base:1.3-php5.6-debian
Successfully tagged my.private.registry:5000/docker-common/php-base:1-php5.6-debian
Successfully tagged my.private.registry:5000/docker-common/php-base:php5.6-debian
building examples/php-base/php7.1/debian/
Step 1/1 : FROM php:7.1-jessie
---> 7e10b050a58c
Successfully built 7e10b050a58c
Successfully tagged my.private.registry:5000/docker-common/php-base:1.3.5-php7.1-debian
building examples/php-base/php7.1/alpine/
Step 1/1 : FROM php:7.1-alpine
---> 07ecc747a915
Successfully built 07ecc747a915
Successfully tagged my.private.registry:5000/docker-common/php-base:1.3.5-php7.1-alpine
Successfully tagged my.private.registry:5000/docker-common/php-base:1.3-php7.1-alpine
Successfully tagged my.private.registry:5000/docker-common/php-base:1-php7.1-alpine
Successfully tagged my.private.registry:5000/docker-common/php-base:1.3.5-alpine
Successfully tagged my.private.registry:5000/docker-common/php-base:1.3-alpine
Successfully tagged my.private.registry:5000/docker-common/php-base:1-alpine
Successfully tagged my.private.registry:5000/docker-common/php-base:php7.1-alpine
Successfully tagged my.private.registry:5000/docker-common/php-base:php7.1
Successfully tagged my.private.registry:5000/docker-common/php-base:alpine
```


## How to install

Hydra has an installer script that will automatically grab the latest version of the Hydra client and install it locally.

You can fetch that script, and then execute it locally. It’s well documented so that you can read through it and understand what it is doing before you run it.

    curl https://raw.githubusercontent.com/benkeil/hydra/master/scripts/get > get_hydra.sh
    chmod 700 get_hydra.sh
    ./get_hydra.sh

You can also run

    curl https://raw.githubusercontent.com/benkeil/hydra/master/scripts/get | bash

## Tagging strategies

### Default

Will also be aplied if no tag is specified.

    {SEMVER-VERSION}-{DIRECTORY-PATH}


### Simple

Just adds the tag like in the config (e.g. `latest`).

### Semver

The string `semver` is a special tag that generates three convenient tags. It can be at any position in the string and will be replaced.

    {MAJOR-VERSION}.{FEATURE-VERSION}.{BUGFIX-VERSION}[-{SUFFIX}]
    {MAJOR-VERSION}.{FEATURE-VERSION}[-{SUFFIX}]
    {MAJOR-VERSION}[-{SUFFIX}]


### Replace

If your version is not a semantic version (typical a branchname) hydra just replace the `semver` tag with the version name.

```yaml
image:
- my.private.registry:5000/docker-common/nginx-base
versions:
- directory: .
  tags:
  - semver-nginx
  - semver
```

Assume we are in the branch `feature/AB-123`. Typical you would build your images with `hydra build AB-123` and hydra will create the following images:

- my.private.registry:5000/docker-common/nginx-base:AB-123-nginx
- my.private.registry:5000/docker-common/nginx-base:AB-123


### Skip

If your version is not a semantic version (typical a branchname) hydra only creates tags if the special tag `semver` is included in the tag.

```yaml
image:
- my.private.registry:5000/docker-common/nginx-base
versions:
- directory: .
  tags:
  - semver-nginx
  - semver
  - nginx
  - latest
```

Assume we are in the branch `feature/AB-123`. Typical you would build your images with `hydra build AB-123` and hydra will create the following images:

- my.private.registry:5000/docker-common/nginx-base:AB-123-nginx
- my.private.registry:5000/docker-common/nginx-base:AB-123

The tags `nginx` and `latest` are skipped.


## Commands

### Build

Can be used to build and tag your images.

    hydra build VERSION [-w WORKDIR]

### Push

Can be used to push all images to the registry.

    hydra push VERSION [-w WORKDIR]

