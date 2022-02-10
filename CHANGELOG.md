# Changelog

## v2.3.1

* Force bleeding edge or stable builds of all dependencies when meta package is installed with @be or @stable

## v2.3.0

* Add concept of pixl8-meta-packages. Allows defining of packages that just install other packages.

## v2.1.3

* Defend against attempting to create auto docs for components that extend at various levels that we do not have available


## v2.1.2

Upgrade testbox in project scaffolds.

## v2.1.1

Fix readme reference to box install instructions

## v2.1.0

* Update mis publish command to not have to push entire package zip up to MIS

## v2.0.0

* Update 'pixl8 new extension' command to use our 'new' gitlab ci approach with re-usable pipelines
* Fix issue with missing test.sh for 'pixl8 new extension' command

## v0.3.1

* Refinements to pixl8 new site command (allow choice of admin webapp or website)
* Fix for docuemtnation builder and forms documentation

## v0.3.0

* Added `pixl8 new static` command
* Added `pixl8 new site` command

## v0.2.6

* Add mermaid.js to the docs scaffold so that devs can embed diagrams in their docs easily
* Make forms + preside objects index pages more simple (just show child pages)
* Attempt to fudge over issues with documenting service components that implement components outside of the scope of the generator (i.e. from other extensions)

## v0.2.5

* Fix jekyll + read the docs version + allow excluding of grand-child pages from the nav

## v0.2.4

* adding command for auto building docs

## v0.2.2

* Fix case sensitivity of Gruntfile.js

## v0.2.1

* Fix cache artifacts path for windows (contained ':' which cannot exist in windows folder names)

## v0.2.0

* Add "pixl8 new extension" command for creating private pixl8 extension skeletons

## v0.1.8

* Fix issue with installing packages that already exist in the artifacts cache. Fixes errors like 'Duplicate entry: build/', etc. during box install.

## v0.1.7

* Store the actual version number in the artifacts cache, not 'stable', or 'be', etc.

## v0.1.6

* Only put into the cache when not a snapshot release

## v0.1.5

* Tweak logic so that pre-release versions are never fetched from cache (rather than always leading to not being able to install pre-release versions)

## v0.1.4

* Ensure that box install pixl8:my-package adds a @^x.x.x to set a sensible default stable version to box.json

## v0.1.3

* Add a publish package method

## v0.1.2

* Do not use any specific API enpoints in the system
* Rename endpoint to pixl8

## v0.1.1

* Fixing version numbers

## v0.1.0

* Initial commit (custom forgebox endpoint to interact with MIS API)
