# Puppeteer Node for CI

The motivation of this repo is to provide all versions of [nodejs images](https://hub.docker.com/_/node) with a single layer on top
that contains only dependencies for [puppeteer](https://pptr.dev).

Therefore, which [puppeteer](https://pptr.dev) to install and to use is up to you, it is just one line of code.

[`satantime/puppeteer-node` images](https://hub.docker.com/r/satantime/puppeteer-node) do not contain [puppeteer](https://pptr.dev) itself,
because different versions of different libraries, such as [webdriver](https://webdriver.io), might require
specific versions of [Chrome Browser](https://www.chromium.org/Home/).
This makes tough providing images for all possible combinations.

## Warnings

- no alpine images
- should you not find node version you want, please open [an issue on GitHub](https://github.com/satanTime/puppeteer-node/issues/new)

## Testing Angular

Documentation how to configure continuous integration for Angular applications is on [https://satantime.github.io/puppeteer-node/](https://satantime.github.io/puppeteer-node/).
