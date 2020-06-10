# Ahikar Backend

This aims to serve the complete backend for the Ahikar project.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Architecture](#architecture)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Build](#build)
    - [eXist-db App and Dependencies](#exist-db-app-and-dependencies)
    - [Get the Frontend](#get-the-frontend)
  - [Environment variables](#environment-variables)
  - [Building All Docker Container Images](#building-all-docker-container-images)
  - [Start the Backend](#start-the-backend)
- [Connecting the Backend with the Frontend](#connecting-the-backend-with-the-frontend)
- [Contributing](#contributing)
- [Versioning](#versioning)
- [Authors](#authors)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Architecture

## Getting Started

### Prerequisites

Please make sure you have the following software installed before building the
backend:

* ant
* Docker
* docker-compose

The following programs/commands are used, but usually preinstalled with your Linux distribution and corresponding shell:

* bash
* curl
* echo
* mv
* rm
* touch
* unzip

### Build

#### eXist-db App and Dependencies

```bash
# load eXist-db dependencies (mainly SADE)
ant -f exist-app/build.xml dependencies

# build eXist-db package for Ahikar
ant -f exist-app/build.xml xar

# optionally in one line
# ant -f exist-app/build.xml dependencies xar
```

#### Get the Frontend

```bash
# as long as the frontend repo is internal set a valid access token
# https://gitlab.gwdg.de/profile/personal_access_tokens
# see https://gitlab.gwdg.de/subugoe/ahiqar/backend/-/issues/4
GITLAB_TOKEN=""
curl --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "https://gitlab.gwdg.de/api/v4/projects/9882/jobs/artifacts/develop/download?job=build" --output frontend.zip
unzip frontend.zip -d docker/frontend
mv docker/frontend/Qviewer/dist/spa/* docker/frontend && rm -rf docker/frontend/Qviewer
```

### Environment variables

To pass credentials to the container, we use the file `ahikar.env` which is not part of this repository. For loading data from TextGrid, this file should contain the following parameters:

* TGUSER
* TGPASS

For local development this file MUST be present but can be left empty. In this case, the SADE Publish Tool may be used to import data from TextGrid.

```bash
touch docker/ahikar.env
```

In addition we use a `.env` file for passing parameters to docker-compose and set variables named in the `docker-compose.yml`. The parameters depend on the deployment target and are set by the script.

```bash
./docker/set-env-for-docker-compose.sh
```

`APP_NAME` will be set here as well. This is used to determine the deployed container (docker-compose APP_NAME) but CAN be used to determine the eXist-db application to load in the environment as the app is named in accordance to this value.

### Building All Docker Container Images

```bash
docker-compose --env-file docker/.env --file docker/docker-compose.yml build
```

### Start the Backend

```bash
docker-compose --env-file docker/.env --file docker/docker-compose.yml up --detach
```

## Connecting the Backend with the Frontend

The corresponding frontend for the Ahiwar backend is the [EMo viewer](https://gitlab.gwdg.de/subugoe/emo/Qviewer).
In order to connect it with the simply has to expose a REST API that complies to the specification of the [SUB's generic TextAPI](https://subugoe.pages.gwdg.de/emo/text-api/).
The frontend takes care of the data transfer as described in the [frontend's README](https://gitlab.gwdg.de/subugoe/emo/Qviewer/-/blob/develop/README.md#connecting-the-viewer-with-a-backend).

## License

See the [LICENSE file](LICENSE.md) for more information on how to re-use this software.

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](https://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://gitlab.gwdg.de/subugoe/ahiqar/backend/-/tags).

## Authors

* [Mathias Göbel](https://gitlab.gwdg.de/mgoebel)
* [Michelle Weidling](https://gitlab.gwdg.de/mrodzis)

See also the list of contributors who participated in this project.
