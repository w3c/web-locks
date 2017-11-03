<img src="https://cdn.rawgit.com/inexorabletash/web-locks/master/logo-lock.svg" height="100" align=right>

# Web Locks API <s>Origin Flags</s>

## TL;DR

A new web platform API that allows script running in one tab to asynchronously acquire a lock, hold it while work is performed, then release it. While held, no other script in the origin can aquire the same lock.

## Background

The [Indexed Database API](https://w3c.github.io/IndexedDB/) defines a transaction model allowing shared read and exclusive write access across multiple named storage partitions within an origin. We'd like to generalize this model to allow any Web Platform activity to be scheduled based on resource availability. This would allow transactions to be composed for other storage types (such as Cache Storage), across storage types, even across non-storage APIs (e.g. network fetches).

Cooperative coordination takes place within the scope of same-origin [agents](https://html.spec.whatwg.org/multipage/webappapis.html#integration-with-the-javascript-agent-formalism) (informally: windows/tabs and workers); this may span multiple
[agent clusters](https://html.spec.whatwg.org/multipage/webappapis.html#integration-with-the-javascript-agent-cluster-formalism) (informally: process boundaries).

Previous discussions:
* [Application defined "locks" [whatwg]](https://lists.w3.org/Archives/Public/public-whatwg-archive/2009Sep/0266.html)

This document proposes an API for allow contexts (windows, workers) within a web application to coordinate the usage of resources.


## Use Case Examples

A web-based document editor stores state in memory for fast access and persists changes (as a series of records) to a storage API such as Indexed DB for resiliency and offline use, and to a server for cross-device use. When the same document is opened for editing in two tabs the work must be coordinated across tabs, such as allowing only one tab to make changes to or synchronize the document at a time. This requires the tabs to coordinate on which will be actively making changes (and synchronizing the in-memory state with the storage API), knowing when the active tab goes away (navigated, closed, crashed) so that another tab can become active.


## Concepts

A _resource_ is just a name (string) chosen by the web application.

A _scope_ is a set of one or more resources.

A _mode_ is either "exclusive" or "shared".

A _lock request_ is made by script for a particular _scope_ and _mode_. A scheduling algorithm looks at the state of current and previous requests, and eventually grants a lock request.

A _lock_ is granted request; it has the _scope_ and _mode_ of the lock request. It is represented as an object returned to script.

As long as the lock is _held_ it may prevent other lock requests from being granted (depending on the scope and mode).

A lock can be _released_ by script, at which point it may allow other lock requests to be granted.

#### Resources and Scopes

The _resource_ strings have no external meaning beyond the scheduling algorithm, but are global
across browsing contexts within an origin. Web applications are free to use any resource naming
scheme. For example, to mimic Indexed DB's transaction locking over named stores within a named
database, an origin might use `db_name + '/' + store_name` (with appropriate restrictions on
allowed names).

The _scope_ concept originates with databases, and is present in the web platform in [IndexedDB](https://w3c.github.io/IndexedDB/#transaction-scope). It allows atomic acquisition of multiple
resources without multiple asynchronous requests and the risk of deadlock from fragile algorithms.

#### Modes and Scheduling

The _mode_ property and can be used to model the common [readers-writer lock](http://en.wikipedia.org/wiki/Readers%E2%80%93writer_lock) pattern. If a held "exclusive" lock has a resource in its scope, no other locks with that resource in scope can be granted. If a held "shared" lock has a resource in its scope, other "shared" locks with that resource in scope can be granted - but not any "exclusive" locks. The default mode in the API is "exclusive".

Additional properties may influence scheduling, such as timeouts, fairness, and so on.

The model for granting lock requests is based on the transaction model for 
[Indexed DB](https://w3c.github.io/IndexedDB/) is used, with IDB's "readwrite" transactions 
the equivalent of "shared" locks and "readonly" transactions the equivalent of "exclusive" locks.
One way to conceptualize this is to consider an ordered list of held locks and requested locks
within an origin &mdash; here identified with numbers &mdash; with their respective scopes and
modes:

* Held:
  * #1: scope: ['a'], mode: "exclusive"
  * #2: scope: ['b'], mode: "shared"
* Requested:
  * #3: scope: ['b'], mode: "shared"
  * #4: scope: ['a', 'b'], mode: "exclusive"
  * #5: scope: ['b'], mode: "shared"
  * #6: scope: ['c'], mode: "exclusive"

At this point, two locks (#1, #2) are held. Request #3 can be granted immediately since it is
for a "shared" lock on 'b' and #2 is also a "shared" lock on 'b'. Request #4 is for an exclusive
lock on both 'a' and 'b'; it must wait for all of locks #1, #2 and #3 to be released before it
can be granted. Request #5 arrived after request #4 and has overlapping scope, so it is blocked
until #4 is granted then released. (See Q&A below.) The scope of request #6 doesn't overlap with
any other held or requested lock, so it can be granted immediately.

New requests get appended to the end of the list. Any lock release, request, or aborted request
causes the state to be evaluated, with requests considered in order to determine if they can be
granted.


## API Proposals

Proposal 1: Auto-Releasing with waitUntil():
```js
async function get_lock_then_write() {
  const lock = await requestLock('resource');
  lock.waitUntil(async_write_func());
}

async function get_lock_then_read() {
  const lock = await requestLock('resource', {mode: 'shared'});
  lock.waitUntil(async_read_func());
}
```

Proposal 2: Explicit release:
```js
async function get_lock_then_write() {
  const lock = await requestLock('resource');
  await async_write_func();
  lock.release();
}

async function get_lock_then_read() {
  const lock = await requestLock('resource', {mode: 'shared'});
  await async_read_func();
  lock.release();
}
```

Proposal 3: Scoped release: :star::star::star: this is the current favorite :star::star::star:
```js
async function get_lock_then_write() {
  await requestLock('resource', async lock => {
    await async_write_func();
  });
}

async function get_lock_then_read() {
  await requestLock('resource', async lock => {
    await async_read_func();
  }, {mode: 'shared'});
}
```

* The auto-release approach mirrors [Indexed DB's auto-committing transaction](https://w3c.github.io/IndexedDB/#transaction-construct) model where explicit action is needed to hold a resource, combined with [Service Worker's ExtendableEvent](https://w3c.github.io/ServiceWorker/#extendableevent-interface) `waitUntil()` method to allow promises to control the lifetime.
* The explicit release model requires callers to always call the `release()` method, e.g. even if an exception is thrown.
* The scoped release model requires callers to pass in an async callback which will be invoked with the lock. The callback implicitly returns a promise and the lock is released when that promise resolves.

_Any of the above approaches can be implemented in terms of the other. We just need to pick one._

The _scope_ (required first argument) can be a string or array of strings, e.g. `'thing'` or `['thing1', 'thing2']`.

In the auto-release approach, a lock will automatically be released by a subsequent microtask if `waitUntil(p)` is not called with a promise to extend its lifetime within the callback from the initial acquisition promise.

In the auto-release and explicit release approaches the method returns a promise that resolves with a lock, or rejects if the request was aborted. In the scoped release approach the method returns a promise that resolves/rejects with the result of the callback, or rejects if the request is aborted.

## Options

An optional final argument is an options dictionary.

An optional _mode_ member can be one of "exclusive" (the default if not specified) or "shared".

An optional _signal_ member can be specified which is an [AbortSignal](https://dom.spec.whatwg.org/#interface-AbortSignal). This allows aborting a lock request, for example if the request is not granted in a timely manner:
```js
const controller = new AbortController();
setTimeout(() => controller.abort(), 200); // wait at most 200ms

try {
  // NOTE: Using "scoped release" API proposal.
  await requestLock('resource', async lock => {
    // Use |lock| here.
  }, {signal: controller.signal});
  // Done with lock here.
} catch (ex) {
  // |ex| will be a DOMException with error name "AbortError" if timer fired.
}
```

An optional _ifAvailable_ boolean member can be specified; the default is false. If true, then the lock is only granted if it can be without additional waiting. Note that this is still not _synchronous_; in many user agents this will require cross-process communication to see if the lock can be granted. If the lock cannot be granted, `null` is returned. (Since this is expected, the request is not rejected.)



## FAQ

*Why can't [Atomics](https://tc39.github.io/ecmascript_sharedmem/shmem.html#AtomicsObject) be used for this?*

The use cases for this API require coordination across multiple
[agent clusters](https://html.spec.whatwg.org/multipage/webappapis.html#integration-with-the-javascript-agent-cluster-formalism);
 whereas Atomics operations operate on [SharedArrayBuffers](https://tc39.github.io/ecmascript_sharedmem/shmem.html#StructuredData.SharedArrayBuffer) which are constrained to a single agent cluster. (Informally: tabs/workers can be multi-process and atomics only work same-process.)


*What happens if a tab is throttled/suspended?*

If a tab holds a lock and stops running code it can inhibit work done by other tabs. If this is because tabs are not appropriately breaking up work it's an application problem. But browsers could throttle or even suspend tabs (e.g.
background background tabs) to reduce power and/or memory consumption. With an API like this &mdash; or with Indexed DB
&mdash; this can result the [work in foreground tabs being throttled](https://bugs.chromium.org/p/chromium/issues/detail?id=675372).

To mitigate this, browsers must ensure that apps are notified before being throttled or suspended so that
they can release locks, and/or browsers must automatically release locks held by a context before it is
suspended. See [A Lifecycle for the Web](https://github.com/spanicker/web-lifecycle) for possible thoughts
around formalizing these states and notifications.


*Can you implement explicit release in terms of auto-release?*
```js
async function requestExplicitLock(...args) {
  const lock = await requestLock(...args);
  lock.waitUntil(new Promise(resolve => { lock.release = resolve; }));
  return lock;
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

function requestAutoReleaseLock(...args) {
  const lock = await requestLock(...args);
  const ext = Extendable();
  ext.then(() => lock.release(), () => lock.release());
  ext.waitUntil(Promise.resolve().then(() => Promise.resolve().then()));
  lock.waitUntil = ext.waitUntil.bind(ext);
  return lock;
}
```

*Can you implement explicit release in terms of scoped release?*
```js
function requestExplicitLock(scope, ...rest) {
  return new Promise(resolve => {
    requestLock(scope, lock => {
      // p waits until lock.release() is called
      const p = new Promise(r => { lock.release = r; });
      resolve(lock);
      return p;
    }, ...rest);
  });
}
```

*Can you implement scoped release in terms of explict release?*
```js
async function requestScopedLock(scope, callback, ...rest) {
  const lock = await requestLock(scope, ...rest);
  try {
    await callback(lock);
  } finally {
    lock.release();
  }
}
```

*Can you implement...*

Staaahp!


*How do you _compose_ IndexedDB transactions with these locks?*

Assuming [Promise-specific additions to the Indexed DB API](https://github.com/inexorabletash/indexeddb-promises):

 * To wrap a lock around a transaction, use: `lock.waitUntil(tx.complete)`
 * To wrap a transaction around a lock, use: `tx.waitUntil(lock.released)`

Without such additions it's more complicated.

Also note that we don't want to _force_ IDBTransactions into this model of waiting for a resource before you can use it: in IDB you can open a transaction and schedule work against it immediately, even though that work will be delayed until the transaction is running.

*Can we _define_ Indexed DB transactions in terms of this primitive?*

Roughly:

* The IDBTransaction requests a lock when created, and holds a "request queue" which operations are appended to.
* When the lock is acquired it is waited on "complete promise". In addition an "active promise" is prepared. The request queue is then processed.
* A processed request gets a hidden promise that is resolved when the request is done. The "active promise" is extended until one turn after every processed request has completed. (Similar to the trick used here, a dependent promise is created which, when run, schedules a microtask to do the work.)
* Any new request is processed immediately.
* When the "active promise" resolves, there are no further requests, and the transaction attempts to commit.
* The "complete promise" is resolved when the transaction successfully commits or aborts.

This doesn't precisely capture the "active" vs "inactive" semantics and several other details. We may want to go through the exercise of defining this more rigorously.


*Why does a shared lock request need to wait until a previous exclusive lock request be granted/released?*

This comes from developer expectations about file and database processing; if a write is scheduled
before a read, the usual expectation is that the read will see the results of the write. When this
was not enforced by Indexed DB implementations, developers expressed significant confusion. Given
demand, we could add an option/mode to allow opting into the more subtle behavior.


*Does this leak information from e.g. Incognito/Private Browsing/etc mode?*

No - like storage APIs, browsers treat such anonymous sessions as if they were a completely separate
user agent from the point of view of specs; the data is in a separate partition. This is similar
to how some browsers support multiple user profiles; cookies, databases, certificates, etc.
are all separated. Locks held in one user profile (or anonymous) session have no relationship to
locks in another session, as if they in a distinct application or on another device.


## Related APIs

* [Atomics](https://tc39.github.io/ecmascript_sharedmem/shmem.html#AtomicsObject)
  * Resource coordination within a SharedArrayBuffer, limiting use to a particular [agent cluster](https://html.spec.whatwg.org/multipage/webappapis.html#integration-with-the-javascript-agent-cluster-formalism).
* [Indexed DB Transactions](https://w3c.github.io/IndexedDB/#transaction-concept)
  * No explicit control of transaction lifetimes. Requires use of full API (e.g. schema versioning).
* [Wake Lock API](https://w3c.github.io/wake-lock/)
  * Acquisition of a single system-provided resource.
