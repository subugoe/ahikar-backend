# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.1] - 2020-06-15

### Changed

- merge request templates now explicitly mention the version number in the eXist app's build properties.
this should help to remember increasing it.
- instead of just checking the API status for the staging server, the health of an endpoint is now checked after a merge as well

### Fixed

- make API more specific in where it looks up data. When people fork SADE, a new SADE application is created
in the backend which also contains project data.
This lead to error when looking up metadata for a given colleciton.

## [1.3.0] - 2020-06-10

### Changed

- exclude notes from the creation of plain text.
notes are text passages that have been added at a later stage by one or more scribes.
thus, they do not belong to the running text in a stricter sense.

## [1.2.0] - 2020-06-09

### Added

- a License file that clearifies the terms under which the backend software could be reused.
- HTTP HEAD added to the API.
This way the status of all the API's parts can be requested with e.g. `curl --head` for testing purposes.

### Fixed

- failing pipeline due to buffering problems of cURL

## [1.1.1] - 2020-06-09

## Added

- the Readme now offers a section on the interplay of front- and backend.
It has also been supplemented with missing categories according to [this gist](https://gist.github.com/PurpleBooth/109311bb0361f32d87a2).

## [1.1.0] - 2020-06-05

### Added

- suggestions for serializing the TEI sources.
these have been added to the sample file at exist-app/data/ahiqar_sample.xml.

## [1.0.1] - 2020-06-05

### Added

- a CI stage that checks the API status after each deployment.

### Changed

- moved the redeployment functionality to a separate module to make the API more robust.

### Fixed

- removed faulty parameter type for the redeploment token.

## [1.0.0] - 2020-06-04

### Added

- add document specific retrieval of metadata.
this mainly refers to the document's name as well as the languages it comprises.

### Changed

- the language of a text isn't served as a simple string anymore but as an array of strings.
the reason for this is that a TEI resource can have text in different languages.
this s breaking change, updates in the front end MAY be necessary.
- the `language` keyword has been changed to `lang` in order to comply to the generic text API.

## [0.4.2] - 2020-06-04

### Fixed

- removed the parameter type of the CI token since it caused the API to crash due to unknown reasons.

## [0.4.1] - 2020-06-04

### Added

- this CHANGELOG which keeps track of this repo's changes instead of exist-app/repo.xml
- added more detailed documentation for the text API
- added Michelle Weidling as additional author for the Ahiqar application

### Changed

- refactored the text API where necessary
