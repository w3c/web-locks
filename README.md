<img src="https://w3c.github.io/web-locks/logo-lock.svg" height="100" align=right>

# Web Locks API

[![CI](https://github.com/w3c/web-locks/actions/workflows/auto-publish.yml/badge.svg)](https://github.com/w3c/web-locks/actions/workflows/auto-publish.yml)

A web platform API that allows script to asynchronously acquire a lock over a resource, hold it while work is performed, then release it. While held, no other script in the origin can aquire a lock over the same resource. This allows contexts (windows, workers) within a web application to coordinate the usage of resources.

Participate: [GitHub issues](https://github.com/w3c/web-locks/issues) &mdash;
Docs: [MDN](https://developer.mozilla.org/en-US/docs/Web/API/Web_Locks_API) &mdash;
Tests: [web-platform-tests](https://github.com/web-platform-tests/wpt/tree/master/web-locks)

* The [Explainer](EXPLAINER.md) is a developer-oriented preview of the API.
* The [Specification](https://w3c.github.io/web-locks/) is for browser implementers.
