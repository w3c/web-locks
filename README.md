<img src="https://wicg.github.io/web-locks/logo-lock.svg" height="100" align=right>

# Web Locks API

A web platform API that allows script to asynchronously acquire a lock over a resource, hold it while work is performed, then release it. While held, no other script in the origin can aquire a lock over the same resource. This allows contexts (windows, workers) within a web application to coordinate the usage of resources.

Participate: [GitHub issues](https://github.com/WICG/web-locks/issues) or [WICG Discourse](https://discourse.wicg.io/t/application-defined-locks/2581) &mdash;
Docs: [MDN](https://developer.mozilla.org/en-US/docs/Web/API/Web_Locks_API) &mdash;
Tests: [web-platform-tests](https://github.com/web-platform-tests/wpt/tree/master/web-locks)

* The [Explainer](EXPLAINER.md) is a developer-oriented preview of the API.
* The [Specification](https://wicg.github.io/web-locks/) is for browser implementers.
