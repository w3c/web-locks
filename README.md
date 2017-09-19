<img src="https://s3.amazonaws.com/inexorabletash-share/standards/logo-flags.svg" height="100" align=right>

# Origin Flags

## TL;DR

A new web platform API that allows script running in one tab to asynchronously acquire a flag, hold it while work is performed, then release it. While held, no other script in the origin can aquire the same flag.

## Background

a.k.a. Locks, Mutexes, Semaphores, etc

The Indexed Database API defines a transaction model allowing shared read and exclusive write access across multiple named storage partitions within an origin. We'd like to generalize this model to allow any Web Platform activity to be scheduled based on resource availability. This would allow transactions to be composed for other storage types (such as Cache Storage), across storage types, even across non-storage APIs (e.g. network fetches).

Cooperative coordination takes place within the scope of same-origin [agents](https://html.spec.whatwg.org/multipage/webappapis.html#integration-with-the-javascript-agent-formalism); this may span multiple
[agent clusters](https://html.spec.whatwg.org/multipage/webappapis.html#integration-with-the-javascript-agent-cluster-formalism) (informally: process boundaries).

Previous discussions:
* [Application defined "locks" [whatwg]](https://lists.w3.org/Archives/Public/public-whatwg-archive/2009Sep/0266.html)

This document proposes an API for allow contexts (windows, workers) within a web application to coordinate the usage of resources. 


## Examples

A web-based document editor stores state in memory for fast access and persists changes (as a series of records) to a storage API such as Indexed DB for resiliency and offline use, and to a server for cross-device use. When the same document is opened for editing in two tabs the work must be coordinated across tabs, such as allowing only one tab to make changes to or synchronouze the document at a time. This requires the tabs to coordinate on which will be actively making changes (and synchronizing the in-memory state with the storage API), knowing when the active tab goes away (navigated, closed, crashed) so that another tab can become active. 


## Concepts

A _resource_ is just a name (string) chosen by the web application.

A _scope_ is a set of one or more resources. 

A _mode_ is either "exclusive" or "shared".

A _flag request_ is made by script for a particular _scope_ and _mode_. A scheduling algorithm looks at the state of current and previous requests, and eventually grants a flag request.

A _flag_ is granted request; it has the _scope_ and _mode_ of the flag request. It is represented as an object returned to script.

As long as the flag is _held_ it may prevent other flag requests from being (depending on the scope and mode).

A flag can be _released_ by script, at which point it may allow other flag requests to be granted.

#### Resources and Scopes

The _resource_ strings have no external meaning beyond the scheduling algorithm, but are global
across browsing contexts within an origin. Web applications are free to use any resource naming
scheme. For example, to mimic Indexed DB's transaction locking over named stores within a named
database, an origin might use `encodeURIComponent(db_name) + '/' + encodeURIComponent(store_name)`.

The _scope_ concept originates with databases, and is present in the web platform in [IndexedDB](https://w3c.github.io/IndexedDB/#transaction-scope). It allows atomic acquisition of multiple
resources without multiple asynchronous requests and the risk of deadlock from fragile algorithms.

#### Modes and Scheduling

The _mode_ property and can be used to model the common [readers-writer lock](http://en.wikipedia.org/wiki/Readers%E2%80%93writer_lock) pattern. If a held "exclusive' flag has a resource in its scope, no other flags with that resource in scope can be granted. If a held "shared" flag has a resource in its scope, can other "shared" flags with that resource in scope can be granted.

Additional properties may influence scheduling, such as timeouts, fairness, and so on.


## API Proposal

Proposal 1: Auto-Releasing with waitUntil():

```js
async function get_lock_then_write() {
  const flag = await requestFlag('resource', 'exclusive');
  flag.waitUntil(async_write_func());
}

async function get_lock_then_read() {
  const flag = await requestFlag('resource', 'shared');
  flag.waitUntil(async_read_func());
}
```

Proposal 2: Explicit release:

```js
async function get_lock_then_write() {
  const flag = await requestFlag('resource', 'exclusive');
  await async_write_func();
  flag.release();
}

async function get_lock_then_read() {
  const flag = await requestFlag('resource', 'shared');
  await async_read_func();
  flag.release();
}
```

_The auto-release approach mirrors [Indexed DB's auto-committing transaction](https://w3c.github.io/IndexedDB/#transaction-construct) model where explicit action is needed to hold a resource, combined with [Service Worker's ExtendableEvent](https://w3c.github.io/ServiceWorker/#extendableevent-interface) `waitUntil()` method to allow promises to control the lifetime. The explicit release model requires callers to always call the `release()` method. Either approach can be polyfilled in terms of the other. We just need to pick one._

The _scope_ (first argument) can be a string or array of strings, e.g. `['thing1', 'thing2']`.

The _mode_ (second argument) is one of "exclusive" or "shared".

In the auto-release approach, a flag will automatically be released by a subsequent microtask if `waitUntil(p)` is not called with a promise to extend its lifetime within the callback from the initial acquisition promise.

## Options

A third argument is an options dictionary.

An optional _signal_ member can be specified which is an [AbortSignal](https://dom.spec.whatwg.org/#interface-AbortSignal). This allows aborting a flag request, for example if the request is not granted in a timely manner:
```js
const controller = new AbortController();
setTimeout(() => controller.abort(), 200); // wait at most 200ms
try {
  const flag = await requestFlag('resource', 'shared', {signal: controller.signal});
  // use flag here
} catch (ex) {
  // request rejected with a DOMException with error name "AbortError"
}
```

## FAQ

*Why can't [Atomics](https://tc39.github.io/ecmascript_sharedmem/shmem.html#AtomicsObject) be used for this?*

The use cases for this API require coordination across multiple
[agent clusters](https://html.spec.whatwg.org/multipage/webappapis.html#integration-with-the-javascript-agent-cluster-formalism); 
 whereas Atomics operations operate on [SharedArrayBuffers](https://tc39.github.io/ecmascript_sharedmem/shmem.html#StructuredData.SharedArrayBuffer) which are constrained to a single agent cluster. (Informally: tabs/workers can be multi-process and atomics only work same-process.)


*What happens if a tab is throttled/suspended?*

If a tab holds a flag and stops running code it can inhibit work done by other tabs. If this is because tabs are not appropriately breaking up work it's an application problem. But browsers could throttle or even suspend tabs (e.g.
background background tabs) to reduce power and/or memory consumption. With an API like this &mdash; or with Indexed DB 
&mdash; this can result the [work in foreground tabs being throttled](https://bugs.chromium.org/p/chromium/issues/detail?id=675372). 

To mitigate this, browsers must ensure that apps are notified before being throttled or suspended so that 
they can release flags, and/or browsers must automatically release flags held by a context before it is
suspended. See [A Lifecycle for the Web](https://github.com/spanicker/web-lifecycle) for possible thoughts
around formalizing these states and notifications.


*Can you implement explicit release in terms of auto-release?*
```js
async function requestExplicitFlag(...args) {
  const flag = await requestFlag(...args);
  flag.waitUntil(new Promise(resolve => { flag.release = resolve; }));
  return flag;
}
```

*Can you implement auto-release in terms of explicit-release?*
```js
function Extendable() {
  let resolve, reject;
  const promise = new Promise((res, rej) => {
    resolve = res;
    reject = rej;
  });

  let ps;
  promise.waitUntil = function(p) {
    ps = ps ? Promise.all([ps, p]) : p;
    const snapshot = ps;
    ps.then(
      () => { if (snapshot === ps) resolve(); },
      err => { if (snapshot === ps) reject(err); }
    );
  };
  return promise;
}

function requestAutoReleaseFlag(...args) {
  const flag = await requestFlag(...args);
  const ext = Extendable();
  ext.then(() => flag.release(), () => flag.release());
  ext.waitUntil(Promise.resolve().then(() => Promise.resolve().then()));
  flag.waitUntil = ext.waitUntil.bind(ext);
  return flag;
}


```

*How do you _compose_ IndexedDB transactions with these flags?*

* Assuming [Promise-specific additions to the Indexed DB API](https://github.com/inexorabletash/indexeddb-promises):
  * To wrap a flag around a transaction, use: `flag.waitUntil(tx.complete)`
  * To wrap a transaction around a flag, use: `tx.waitUntil(flag.released)`

* Don't want to _force_ IDBTransactions into this model, since queuing work is valuable, i.e. you can open a transaction and schedule work against it immediately without waiting for it to be "acquired"

*Can we _define_ Indexed DB transactions in terms of this primitive?*

Roughly:

* The IDBTransaction requests a flag when created, and holds a "request queue" which operations are appended to.
* When the flag is acquired it is waited on "complete promise". In addition an "active promise" is prepared. The request queue is then processed.
* A processed request gets a hidden promise that is resolved when the request is done. The "active promise" is extended until one turn after every processed request has completed. (Similar to the trick used here, a dependent promise is created which, when run, schedules a microtask to do the work.)
* Any new request is processed immediately.
* When the "active promise" resolves, there are no further requests, and the transaction attempts to commit.
* The "complete promise" is resolved when the transaction successfully commits or aborts.

This doesn't precisely capture the "active" vs "inactive" semantics and several other details. We may want to go through the exercise of defining this more rigorously.


## Related APIs

* [Atomics](https://tc39.github.io/ecmascript_sharedmem/shmem.html#AtomicsObject)
  * Resource coordination within a SharedArrayBuffer, limiting use to a particular [agent cluster](https://html.spec.whatwg.org/multipage/webappapis.html#integration-with-the-javascript-agent-cluster-formalism).
* [Indexed DB Transactions](https://w3c.github.io/IndexedDB/#transaction-concept)
  * No explicit control of transaction lifetimes. Requires use of full API (e.g. schema versioning).
* [Wake Lock API](https://w3c.github.io/wake-lock/)
  * Acquisition of a single system-provided resource.
