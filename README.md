# Docker Build Tools CI

This is a custom Dockerfile based on the [pantheon-public/build-tools-ci](https://quay.io/repository/pantheon-public/build-tools-ci) docker image.

## Image Contents

### Differences from source image

- [CircleCI PHP 7.4, Node, Headless browser Docker base image](https://hub.docker.com/r/circleci/php)
- gulp
- lighthouse
- lighthouse-batch
- lighthouse-ci
- circle-github-bot (for posting lighthouse scores back to github)
- puppeteer + chrome launcher (for controlling lighthouse)
- pa11y-ci
- drush 10
- phpunit 8
- vim (useful for checking stuff when using ssh)
- vnc4server / metacity (for vnc: https://circleci.com/docs/2.0/browser-testing/)
- x11vnc (for automatically running vnc)
- ping (for debugging network issues)

### Same as source image
- [Terminus](https://github.com/pantheon-systems/terminus)
- Terminus plugins
  - [Terminus Build Tools Plugin](https://github.com/pantheon-systems/terminus-build-tools-plugin)
  - [Terminus Secrets Plugin](https://github.com/pantheon-systems/terminus-secrets-plugin)
  - [Terminus Rsync Plugin](https://github.com/pantheon-systems/terminus-rsync-plugin)
  - [Terminus Quicksilver Plugin](https://github.com/pantheon-systems/terminus-quicksilver-plugin)
  - [Terminus Composer Plugin](https://github.com/pantheon-systems/terminus-composer-plugin)
  - [Terminus Drupal Console Plugin](https://github.com/pantheon-systems/terminus-drupal-console-plugin)
  - [Terminus Mass Update Plugin](https://github.com/pantheon-systems/terminus-mass-update)
  - [Terminus Aliases Plugin](https://github.com/pantheon-systems/terminus-aliases-plugin)
  - [Terminus CLU Plugin](https://github.com/pantheon-systems/terminus-clu-plugin)
- Test tools
  - headless chrome
  - phpunit
  - bats
  - behat
  - php_codesniffer
  - hub
  - lab
- Test scripts

## Branches

- 6.x: Use a CircleCI base image with Node JS
