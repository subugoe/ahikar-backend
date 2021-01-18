# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.5.1] - 2021-01-18

### Fixed

- faulty implementation of the Item Object's title key: Provides now a Title Object according to the
TextAPI specs instead of a string.

## [2.5.0] - 2021-01-14

### Changed

- switched from SADE to TextGrid Connect Standalone as a means to get data from TextGrid

## [2.4.0] - 2021-01-13

- updated the eXist application's name since it was misleading

## [2.3.0] - 2021-01-13

### Changed

- Some parts of `annotation.xqm` have been refactored to improve the code and/or make it testable.
- `test-runner.xq` now produces machine-readable output and only displays the tests that fail.

### Added

- Tests for the AnnotationAPI.

## [2.2.2.] - 2021-01-11

### Fixed

- semantic errors that lead to the application not being installed properly.

## [2.2.1] - 2020-11-16

## Changed

- When extracting the relevant plain text sections, the semantic divisions of the texts are now considered.
Each semantic division, which is indicated in the texts by a tei:milestone, is now stored in a separate file.

## [2.1.0] - 2020-11-12

### Changed

- prepared for changed endpoints at Text-API (document-page to document/page)

### Fixed

- wrong Annotation IDs

## [2.0.0] - 2020-11-06

### Changed

- The AnnotationAPI is now served at `/api/annotations` instead of `/api/textapi`.

## [1.13.1] - 2020-10-06

### Fixed

- Unit tests are executed again.

### Changed

- The CI tests if 1. the unit test API is available and 2. the XML file resulting from the test exists.

## [1.13.0] - 2020-10-13

### Added

- exist application sets admin password from env var (optionally)

## [1.12.0] - 2020-10-01

### Added

- `tei2html.xqm` and `tei2html-textprocessing.xqm` for transforming TEI documents that comply to the
Ahiqar schema to XHTML.

### Changed

- The `/content/${document}-${page}` endpoint no longer relies on TEI's XSLTs and uses a custom
XQuery module, `tei2html.xqm`, instead.

## [1.11.0] - 2020-09-22

### Changed

- In order to improve the clearity of the application, `tapi.xqm` now only holds the RESTXQ endpoints of the TextAPI.
All further functionality has been moved to separate module and furnished with tests.
- The test runner has been designed to be self-reporting, i.e. only faulty results are displayed fully.

## [1.10.1] - 2020-09-24

### Fixed

- Faulty link to OpenAPI documentation of the RESTXQ endpoints has been corrected.

## [1.10.0] - 2020-09-18

### Added

- `collate.xqm` has been introduced.
It provides plain text versions of XMLs files while only considering text passages that follow tei:milestone.
- `commons.xqm` has been introduced.
It provides variables and functions used in several other modules.

### Changed

- All functionality that deals with creating a plain text version of a given XML file has been moved to `collate.xqm`.
- `tapi.xqm` and `annotations.xqm` outsourced some variable to `commons.xqm`.

### Fixed

- The RESTAPI endpoint returning txt-files has been fixed and is available again.

## [1.9.3] - 2020-09-18

### Changed

- The data directory of eXist-db is mounted to a volume instead of a bind mount.

### Fixed

- The maximum amount of memory usable by eXist-db's Docker container has been reduced to 1GB.

## [1.9.2] - 2020-09-10

### Changed

- The GitLab templates have been tidied up according to their actual usage.
Also, a passage about updating the README as been added.

## [1.9.1] - 2020-08-31

### Fixed

- Certain manifests are excluded from being listed in a collection.
These aren't "real" editions and shouldn't be displayed in the front end.

## [1.9.0] - 2020-08-28

### Added

- Manifest Objects (i.e. editions) now hold information about the edition's editor(s), where and when the corresponding manuscript has been created and where it is stored now.
For this, we introduced the keys `x-editor`, `x-date`, `x-origin`, and `x-location`.

## [1.8.2] - 2020-08-27

### Changed

- The build process with `docker-compose` has been slightly adapted.
Instead of hard-coding the bind mounts' sources on the host these are now specified in `.env`.
For this, `set-env-for-docker-compose.sh` has been updated.
- The API endpoint `/api/info` changed to `/info` since the prefix `/api` is added automatically by Apache.

### Fixed

- The pipeline for deploying the app to the database now fails if the deployment API isn't available.

## [1.8.1] - 2020-08-05

### Fixed

- The endpoint design of all AnnotationAPI endpoints requires a leading `/api` on the servers due to the Apache configuration (this doesn't hold for the entrypoint).
This hasn't been the case so far and has been fixed in this version.
- The file `ahiqar_collection.xml` listed a dummy file and several original files in its aggregation.
This caused the AnnotationAPI function that determines to which collection a file belongs to crash since the original files listed in said XML had two possible collections they could belong to.

## [1.8.0] - 2020-07-17

### Fixed

- both the TextAPI and the AnnotationAPI have been checked for their compliance with the generic TextAPI and the W3C Annotation Model, respectively.
Any non-matching fields have been altered to ensure compliance.
The APIs are now documented at <https://subugoe.pages.gwdg.de/ahiqar/api-documentation/>.

## [1.7.2] - 2020-07-15

### Fixed

- when getting a zipped dump of the Ahikar texts, only documents with content are created.
The created documents are prefixed with the respective language which are needed for the collation.

## [1.7.1] - 2020-07-10

### Fixed

- consider processing instruction when serializing HTML.
We didn't before and that caused an error while assigning IDs to elements.

## [1.7.0] - 2020-06-30

### Added

- the AnnotationAPI which is compliant to the W3C Annotation Model.
With this API, we can expose annotations to the QViewer which can then be serialized in different ways.

### Changed

- added a field 'annotationCollection' to Collection, Manifest and Item Objects.
This connects the TextAPI with the AnnotationAPI.

## [1.6.0] - 2020-06-19

### Added

- unit tests for the genuine backend functions.
this helps us verify if everything works as intended.

## [1.5.0] - 2020-06-17

### Added

- an endpoint for getting the plain text of a resource.
this encompasses edition objects as well as XML resources.
the endpoint is available at textapi/ahikar/{$collection}/{$document}.txt and distinguishes between the different text types that exists in the Ahikar project

### Removed

- the function that returns the plain text of Sado 9, Harvard 80 and Strasbourg S4122.
instead, we now focus on an approach to meet this requirement by using the API.

## [1.4.0] - 2020-06-15

### Added

- a function that returns the plain text of Sado 9, Harvard 80 and Strasbourg S4122.
This is necessary in order to evaluate CollateX.
- OpenAPI as a means to get human readable API documentation.

### Changed

- the plain text is not only created for the transcriptions but also for the transliteration.
- removed unused function parameter from signature of tapi:item.

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
