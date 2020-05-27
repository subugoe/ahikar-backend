# Ahikar Backend

This aims to serve the complete backend for the Ahikar project.

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

## Start the Backend

```bash
docker-compose --env-file docker/.env --file docker/docker-compose.yml up --detach
```
