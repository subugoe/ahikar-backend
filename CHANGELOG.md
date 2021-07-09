# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [6.7.0] - 2021-07-08

### Added

- when creating the metadata on manifest level, the Salhani print is now considered as well.

## [6.6.0] - 2021-07-02

### Changed

- the collection title now provides information about the type of manuscripts the collection contains.

## [6.5.0] - 2021-06-25

### Added

- basic search api and lucene configuration

## [6.2.3] - 2021-06-25

### Fixed

- annotation items that are stored during the creation/update of a document are now always stored in an array.
Before this fix a singular item on an AnnotationPage has been provided as object which caused errors in TIDO.

## [6.2.2] - 2021-06-25

### Fixed

- refined XPath to main title of the project.
In the Salhani print we have several main titles which hasn't been considered when selecting the element for displaying the main title of the project.

## [6.2.1] - 2021-06-21

### Fixed

- fonts are now provided as expected.

### Changed

- the font file format has been altered to WOFF instead of OTF.

## [6.2.0] - 2021-06-10

### Changed

- in order to improve the performance of the database triggers, calling commons:get-page-fragments() several times has been reduced to calling it once per document.
This also reduces the calls to me:main(), a relatively costly operation, which is called during commons:get-page-fragments().

## [6.1.0] - 2021-06-08

### Changed

- in the AnnotationAPI the correction of faulty text now provides information about the person responsible for the correction.

## [6.0.0] - 2021-06-08

### Changed

- the fields `total` and `startIndex` have been removed from the AnnotationAPI.

## [5.16.0] - 2021-06-04

### Changed

- the HTML are now serialized after pushing TEI files to the database and stored by text type (transcription, transliteration) and page.
The TextAPI uses these pre-rendered files instead of creating them on the fly, thus saving time when a user visits a page in TIDO.

## [5.15.1] - 2021-06-07

### Fixed

- the computation of total annotations per manuscript/collection now uses the preprocessed annotation items as a basis.
This saves a lot of time since the annotations doesn't have to be recreated for counting.

## [5.15.0] - 2021-06-03

### Added

- annotation items are now preprocessed and stored to the database.
When an application wants to access an Annotation Page, the database retrieves the items from the stored files while the rest of the Page is created dynamically.
Also, a database trigger has been added that updated the stored annotation items for a TEI document each time is updated in the `data` collection.

## [5.14.2] - 2021-05-21

### Fixed

- the serialization of simple motifs is now able to deal with motifs spanning over a page's end.
Motifs that encompass more than one line are connected via a `data-next` attribute in HTML.
The AnnotationAPI exposes the first part of a motif available on a page.
- the entry point of the front end is set correctly during the CI pipelines (depending on the branch executing them).

### Changed

- the processing instructions which represent the motifs are transformed to XML elements to simplify processing the data.
- some of the Docker images in the CI config have been exchanged with smaller versions.

## [5.14.1] - 2021-05-17

### Added

- logging to `expath-repo.log` when an error is thrown in the TextAPI at collection level

## [5.14.0] - 2021-05-07

### Added

- an intermediate format that transforms simple (i.e. non-nested) motifs (encoded as processing instructions) into TEI elements.
This new intermediate format serves as a basis for the HTML creation in which the simple motifs are now considered, too.

### Changed

- the ID creation within `motifs.xqm` has been altered to fit the new intermediate format.

## [5.13.0] - 2021-05-07

### Added

- the HTML serialization now provides a `@dir="rtl"` attribute.

## [5.12.1] - 2021-05-06

### Changed

- `annotation.xqm` has been refactored to separate concerns and to speed the process up by avoiding duplicate function calls.

## [5.12.0] - 2021-05-03

### Added

- the motifs have been added to the AnnotationAPI.

## [5.11.2] - 2021-04-29

### Changed

- the ant based approach for installing this project now gets eXist-db from GitHub (and not Bintray).

## [5.11.1] - 2021-04-27

### Removed

- The changes made in [5.11.0](#5110-2021-04-27) have been removed due to performance issues.

## [5.11.0] - 2021-04-27

### Added

- the variants have been added to the AnnotationAPI.

## [5.10.0] - 2021-04-22

### Changed

- introduced a simple collction at `/textapi/http-status-test/collection/collection.json` that has items which return the HTTP status codes `403`, `404`, `405`, `500` and `503`, respectively.
For this, the unused end points introduced at [5.8.0](#580-2021-04-15) have been removed.

## [5.9.1] - 2021-04-22

### Fixed

- the `Person` and `Place` annotations now provide the actual person/place name in the annotation body instead of a dummy string.

## [5.9.0] - 2021-04-14

### Added

- the license ID for manifests now contains a link to the legal code of the license.

## [5.8.0] - 2021-04-15

### Added

- temporarily added the end points "/http-403", "/http-404", "/http-500", "/http-503" for testing TIDO's behavior when getting these status codes.

## [5.7.1] - 2021-04-13

### Fixed

- the CSS file now updated when changes have been made in ahiqar-tido.

## [5.7.0] - 2021-03-23

### Added

- the editorial comments as well as the references have been added to the AnnotationAPI.

## [5.6.1] - 2021-03-29

### Fixed

- consider encoding for Harvard 80 and references works in tokenization

## [5.6.0] - 2021-03-26

### Changed

- adapt ID/IDNO handling in the JSON creation to how they are handled during the tokenization.

## [5.5.3] - 2021-03-23

### Fixed

- sample data is no longer considered when creating the JSON files needed for the collation.

## [5.5.2] - 2021-03-23

### Fixed

- the HTML creation now reacts gracefully to variations in the rendition attribute for the rubrication.

## [5.5.1] - 2021-03-22

### Fixed

- an item of an Arabic manuscript now only has the transscription in its Content Object.

## [5.5.0] - 2021-03-15

### Changed

- the different text types, transcription and transliteration, are now considered for the HTML creation and the annotations.
The HTML endpoint now not only has a key word to distinguish the two types, but also provides the different texts now.
The AnnotationAPI now consideres both the transcription and the transliteration (where present) for the Annotation Pages so that annotations can be shown for both text types in TIDO.

## [5.4.0] - 2021-03-15

### Added

- the API endpoint `content/ahikar-json.zip` which returns a JSON file per line of transmission and semantic section.

### Removed

- from this version on we use JSON as an input for CollateX.
As a consequence, the TXT API has become obsolete and has been removed.

## [5.3.0] - 2021-03-08

### Removed

- the changes made in [4.4.0](#440-2021-02-18)

## [5.2.0] - 2021-03-09

### Added

- the fonts needed for the edition as well as an endpoint to deliver them.

## [5.1.0] - 2021-03-08

### Added

- a separate endpoint for the project specific CSS at `/content/ahikar.css`.

### Changed

- the Support Object no longer relies on GitLab but references the CSS stored in the database.

## [5.0.1] - 2021-03-05

### Fixed

- the CSS file in the Support Object now points to the raw CSS file in GitLab.
This way it is fully parsable.

## [5.0.0] - 2021-03-05

### Changed

- The API has been adjusted to the generic TextAPI's change that allows for several Content Objects instead of one content item.
- As a result of said API change, `content/some_page.html` has been changed to `content/${html-type}/some_page.html`.
This way the two relevant HTML serialization of the Ahiqar material, `transcription` and `transliteration` can easily be distinguised.
Cf. <https://gitlab.gwdg.de/subugoe/ahiqar/backend/-/issues/27> on this topic.
NOTE: Only the endpoint has been changed.
The functionality is not implemented yet.

## [4.9.4] - 2021-03-05

### Fixed

- the license key on Manifest level now provides an array of License Objects instead of a simple string.
To achieve this, the XML based structure of the manifest data has been moved to maps.
Additionally, the module has been slightly refactored.

## [4.9.3] - 2021-03-02

### Fixed

- the title on Item level now provides an array of Title Objects instead of a single one.
To achieve this, we changed the XML based structure of the `tapi-item.xqm` module to a map based one.

## [4.9.2] - 2021-03-02

### Fixed

- during the HTML serialization, a white space is set after each token
Not having set this let to the text nodes being displayed as one long text node.

## [4.9.1] - 2021-02-24

### Fixed

- the HTTP request to TextGrid for public images now has a sessionID.
While we won't need it once the images have been published in the TextGrid Repository, the sessionID is still needed in the meantime for requesting images.

## [4.9.0] - 2021-02-23

### Added

- a word-level tokenization of the relevant text. words are wrapped in a `tei:w` before further processing and equipped with a unique ID to address them.

## [4.8.2] - 2021-02-23

### Fixed

- the variable $APP_DEPLOY_TOKEN which is expected in `deploy.xqm` is now part of Docker's environment and can actually be used for conditionals.
Also, this variable has been added as a query parameter to the API call.

## [4.8.1] - 2021-02-23

### Fixed

- restructered the tests in a way that developers can execute them locally even if they don't have the credentials necessary for getting data from TextGrid.
These tests are only executed if the respective environment variable, `TGLOGIN`, is available.

## [4.8.0] - 2021-02-22

### Added

- An endpoint `deploy/$VERSION` which allows for installing a specific version of the application.
This is mainly relevant for the test server on which the application version aren't always installed in a chronological way.

## [4.7.0] - 2021-02-22

### Changed

- The license information for texts is retrieved from the TEI/XML files instead of setting a generic one.

## [4.6.0] - 2021-02-22

### Changed

- Instead of having a simple string body in the annotations, we switched to a Body Object that holds a custom parameter, `x-content-type`, which enables us to easily distinguish the annotations of different types.
Cf. <https://subugoe.pages.gwdg.de/ahiqar/api-documentation/page/annotation-api-specs/#body-object>.

## [4.5.0] - 2021-02-18

### Fixed

- move to dynamic sessionId

## [4.4.0] - 2021-02-18

### Added

- a separate endpoint for the sample file available at `/textapi/ahikar/sample/collection.json` for accessing the sample file

## [4.3.0] - 2021-02-16

### Added

- the manifests now have a Support Object which holds the URL of the project specific CSS

## [4.2.0] - 2021-02-15

### Changed

- U+073C and U+073F are sorted out during the normalization process.

## [4.1.1] - 2021-02-05

### Fixed

- introduced try/catch blocks with fitting error messages for all server requests.

## [4.1.0] - 2021-02-05

### Added

- license information within the image field on item level. As a consequence, each image is now connected with an SPDX identifier (if possible) and further notes about the image's creator.

## [4.0.1] - 2021-02-04

### Fixed

- a proper error is thrown if an image URI cannot be found in TextGrid Rep

## [4.0.0] - 2021-02-04

### Changed

- The URLs for the images have changed depending on whether an image is accessible for the public
or if it has restricted access due to license terms.
Public images are available at `images/public/${uri}` plus image section.
Restricted images are available at `images/restricted/${uri}` plus image section.

## [3.2.0] - 2021-02-04

### Changed

- the project specific metadata has been moved from separate items on manifest level to the Metadata Object on manifest level.
This allows us to use the generic Metadata Object support in the viewer instead of having to add extra code that supports
keys starting with 'x-'.

## [3.1.1] - 2021-01-27

### Fixed

- rename `master.build.properties` to `main.build.properties` to match the actual branch names.
This is necessary to build a package and upload it to our package store (ci.de.dariah.eu).

## [3.1.0] - 2021-01-27

### Changed

- provide two instances of the viewer, one for Syriac and one for Arabic/Karshuni texts

## [3.0.1] - 2021-01-27

### Changed

- `local:truncate` in `tapi-img.xqm` has been renamed to `local:round` to better grasp what the function does.

## [3.0.0] - 2021-01-18

### Changed

- The Text- and AnnotationAPI no longer accept URIs as `collection` parameter.
Callers have to choose between `syriac` or `arabic-karshuni` as `collection`.
This satifies the requirement of having one separate endpoint for the TIDO instance serving the Syriac and the Arabic/Karshuni collections each.

## [2.5.2] - 2021-01-25

### Changed

- added API health check for deploy API

## [2.5.1] - 2021-01-22

### Fixed

- a broken path in the CI config
- faulty implementation of the Item Object's title key: Provides now a Title Object according to the
TextAPI specs instead of a string.

## [2.5.0] - 2021-01-14

### Changed

- switched from SADE to TextGrid Connect Standalone as a means to get data from TextGrid

## [2.4.0] - 2021-01-13

### Changed

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
With this API, we can expose annotations to TIDO which can then be serialized in different ways.

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
