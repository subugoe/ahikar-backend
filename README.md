# ahikar backend

This aims to serve the complete backend for the Ahikar project.

## architecture

## build
```bash
# load eXist dependencies (mainly SADE)
ant -f exist-app/build.xml dependencies

# build eXist package for Ahikar
ant -f exist-app/build.xml xar

# build all docker container images
cd docker
docker-compose build
cd ..

# or in one line:
# docker-compose --env-file docker/.env --file docker/docker-compose.yml build
```