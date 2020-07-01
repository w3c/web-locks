<img src="https://wicg.github.io/web-locks/logo-lock.svg" height="100" align=right>

# Explainer: Web Locks API

This document proposes a new web platform API that allows script to asynchronously acquire a lock over a resource, hold it while work is performed, then release it. While held, no other script in the origin can acquire a lock over the same resource. This allows contexts (windows, workers) within a web application to coordinate the usage of resources.

Participate: [GitHub issues](https://github.com/WICG/web-locks/issues) or [WICG Discourse](https://discourse.wicg.io/t/application-defined-locks/2581) &mdash;
Docs: [MDN](https://developer.mozilla.org/en-US/docs/Web/API/Web_Locks_API) &mdash;
Tests: [web-platform-tests](https://github.com/web-platform-tests/wpt/tree/master/web-locks)

## Introduction

The API is used as follows:
1. The lock is requested.
2. Work is done while holding the lock in an asynchronous task.
3. The lock is automatically released when the task completes.

```js
navigator.locks.request('my_resource', async lock => {
   // The lock has been acquired.
   await do_something();
   await do_something_else();
   // Now the lock will be released.
});
```
The API provides optional functionality that may be used as needed, including:
* returning values from the asynchronous task
* shared and exclusive lock modes
* conditional acquisition
* diagnostics to query the state of locks in an origin
* an escape hatch to protect against deadlocks

Cooperative coordination takes place within the scope of same-origin [agents](https://html.spec.whatwg.org/multipage/webappapis.html#integration-with-the-javascript-agent-formalism) (informally: frames/windows/tabs and workers); this may span multiple
[agent clusters](https://html.spec.whatwg.org/multipage/webappapis.html#integration-with-the-javascript-agent-cluster-formalism) (informally: process boundaries).

In conjunction with this informal explainer, a [work-in-progress specification](https://wicg.github.io/web-locks/) defines the precise behavior of the proposed API.

Previous discussions:
* [Application defined "locks" [whatwg]](https://lists.w3.org/Archives/Public/public-whatwg-archive/2009Sep/0266.html)


## Use Case Examples

A web-based document editor stores state in memory for fast access and persists changes (as a series of records) to a storage API such as IndexedDB for resiliency and offline use, and to a server for cross-device use. When the same document is opened for editing in two tabs the work must be coordinated across tabs, such as allowing only one tab to make changes to or synchronize the document at a time. This requires the tabs to coordinate on which will be actively making changes (and synchronizing the in-memory state with the storage API), knowing when the active tab goes away (navigated, closed, crashed) so that another tab can become active.

In a data synchronization service, a "master tab" is designated. This tab is the only one that should be performing some operations (e.g. network sync, cleaning up queued data, etc). It holds a lock and never releases it. Other tabs can attempt to acquire the lock, and such attempts will be queued. If the "master tab" crashes or is closed then one of the other tabs will get the lock and become the new master.

The [Indexed Database API](https://w3c.github.io/IndexedDB/) defines a transaction model allowing shared read and exclusive write access across multiple named storage partitions within an origin. Exposing this concept as a primitive allows any Web Platform activity to be scheduled based on resource availability, for example allowing transactions to be composed for other storage types (such as Cache Storage), across storage types, even across non-storage APIs (e.g. network fetches).


## Concepts

A _name_ is just a string chosen by the web application to represent an abstract resource.

A _mode_ is either "exclusive" or "shared".

A _lock request_ is made by script for a particular _name_ and _mode_. A scheduling algorithm looks at the state of current and previous requests, and eventually grants a lock request.

A _lock_ is a granted request; it has the _name_ of the resource and _mode_ of the lock request. It is represented as an object returned to script.

As long as the lock is _held_ it may prevent other lock requests from being granted (depending on the name and mode).

A lock can be _released_ by script, at which point it may allow other lock requests to be granted.

A user agent has a _lock manager_ for each origin, which encapsulates the state of all locks and requests for that origin.

#### Lock Manager Scope

For the purposes of this proposal:

 * Separate user profiles within a browser are considered separate user agents.
 * A [private mode](https://github.com/w3ctag/private-mode) browsing session is considered a separate user agent.

Pages and workers (agents) on a single [origin](https://html.spec.whatwg.org/multipage/origin.html#concept-origin) opened in the same user agent share a lock manager even if they are in unrelated [browsing contexts](https://html.spec.whatwg.org/multipage/browsers.html#browsing-context).

There is an equivalence between the following:

* Agents that can communicate via [BroadcastChannel](https://html.spec.whatwg.org/multipage/web-messaging.html#broadcasting-to-other-browsing-contexts)
* Agents that share [storage](https://storage.spec.whatwg.org/); e.g. a per-origin [local storage area](https://html.spec.whatwg.org/multipage/webstorage.html#the-localstorage-attribute), set of [Indexed DB](https://w3c.github.io/IndexedDB/) [https://w3c.github.io/IndexedDB/#database-construct](databases), or [Service Worker](https://w3c.github.io/ServiceWorker/) [caches](https://w3c.github.io/ServiceWorker/#cache-objects).
* Agents that share a lock manager.

This is important as it defines a privacy boundary. Locks can be used as a communication channel, and must be no more privileged than BroadcastChannel. Locks can be used as a state retention mechanism, and must be no more privileged than storage facilities. User agents that impose finer granularity on one of these services must impose it on others; for example, a user agent that exposes different storage partitions to a top-level page and a cross-origin iframe in the same origin for privacy reasons must similarly partition broadcasting and locking.

This also provides reasonable expectations for web application authors; if a lock is acquired over a storage resource, or a broadcast is made signalling that updated data has been stored, all same-origin browsing contexts should observe the same state.

> TODO: Migrate this definition to [HTML](https://html.spec.whatwg.org/multipage/) or [Storage](https://storage.spec.whatwg.org/) so it can be referenced by other standards.

#### Resources Names

The resource _name_ strings have no external meaning beyond the scheduling algorithm, but are global
across browsing contexts within an origin. Web applications are free to use any resource naming
scheme. For example, to mimic [IndexedDB](https://w3c.github.io/IndexedDB/#transaction-construct)'s transaction locking over named stores within a named
database, an origin might use `encodeURIComponent(db_name) + '/' + encodeURIComponent(store_name)`.

Names starting with `-` (dash) are reserved; requesting these will throw.

#### Modes and Scheduling

The _mode_ property can be used to model the common [readers-writer lock](http://en.wikipedia.org/wiki/Readers%E2%80%93writer_lock) pattern. If an "exclusive" lock is held, no other locks with that name can be granted. If "shared" lock is held, other "shared" locks with that name can be granted - but not any "exclusive" locks. The default mode in the API is "exclusive".

Additional properties may influence scheduling, such as timeouts, fairness, and so on.


## API Proposal

```js
async function get_lock_then_write() {
  await navigator.locks.request('resource', async lock => {
    await async_write_func();
  });
}

async function get_lock_then_read() {
  await navigator.locks.request('resource', {mode: 'shared'}, async lock => {
    await async_read_func();
  });
}
```

The _name_ (required first argument) is a string, e.g. `'thing'`.

The _callback_ (required final argument) is a callback invoked with the lock when granted. This "scoped release" API model encourages callers to pass in an async callback; the callback implicitly returns a promise and the lock is released when that promise resolves. In other words, the lock is held until the async callback completes. (If a non-async callback function is passed in, it is wrapped into a Promise that would resolve immediately, so the lock would only be held for the duration of the synchronous callback.)

> See [alternate API proposals](alternate-api-proposals.md) for slightly different API styles which were considered.

The method returns a promise that resolves/rejects with the result of the callback (so, after the lock is released), or rejects if the request is aborted.

Example:
```js
try {
  const result = await navigator.locks.request('resource', async lock => {
    // The lock is held here.
    await do_something();
    await do_something_else();
    return "ok";
    // The lock will be released now.
  });
  // |result| has the return value of the callback.
} catch (ex) {
  // if the callback threw, it will be caught here.
}
```
This guarantees that the lock will be released when the async callback exits for any reason - either when the code returns, or if it throws.

## Options

An options dictionary may be specified as a second argument (bumping the callback to the third argument).

### `mode` option to `request()`

An optional _mode_ member can be one of "exclusive" (the default if not specified) or "shared".
```js
await navigator.locks.request('resource', {mode: 'shared'}, async lock => {
  // Use |lock| here.
});
```

### `signal` option to `request()`

An optional _signal_ member can be specified which is an [AbortSignal](https://dom.spec.whatwg.org/#interface-AbortSignal). This allows aborting a lock request, for example if the request is not granted in a timely manner:
```js
const controller = new AbortController();
setTimeout(() => controller.abort(), 200); // wait at most 200ms

try {
  await navigator.locks.request('resource', {signal: controller.signal}, async lock => {
    // Use |lock| here.
  });
  // Done with lock here.
} catch (ex) {
  // |ex| will be a DOMException with error name "AbortError" if timer fired.
}
```

### `ifAvailable` option to `request()`

An optional _ifAvailable_ boolean member can be specified; the default is false. If true, then the lock is only granted if it can be without additional waiting. Note that this is still not _synchronous_; in many user agents this will require cross-process communication to see if the lock can be granted. If the lock cannot be granted, `null` is returned. (Since this is expected, the request is not rejected.)
```js
await navigator.locks.request('resource', {ifAvailable: true}, async lock => {
  if (!lock) {
    // Didn't get it. Maybe take appropriate action.
    return;
  }
  // Use |lock| here.
});
```
See [issue #13](https://github.com/WICG/web-locks/issues/13) for discussion of this option.


## Management / Debugging

One of the things we've learned from APIs with lots of hidden state like Indexed DB is that it makes diagnosing problems difficult. Developer tools can help locally, but not when a web application has been deployed and mysterious bug reports are coming in. The ability for a web app to introspect the state of such APIs is critical.

To address this, a method called `query()` can be used which provides a snapshot of the lock manager state for an origin:

```js
const state = await navigator.locks.query();
```

This resolves to a plain-old-data structure (i.e. JSON-like) with this form:
```js
{
  held: [
    { name: "resource1", mode: "exclusive", clientId: "8b1e730c-7405-47db-9265-6ee7c73ac153" },
    { name: "resource2", mode: "shared", clientId: "8b1e730c-7405-47db-9265-6ee7c73ac153" },
    { name: "resource2", mode: "shared", clientId: "fad203a5-1f31-472b-a7f7-a3236a1f6d3b" },
  ],
  pending: [
    { name: "resource1", mode: "exclusive", clientId: "fad203a5-1f31-472b-a7f7-a3236a1f6d3b" },
    { name: "resource1", mode: "exclusive", clientId: "d341a5d0-1d8d-4224-be10-704d1ef92a15" },
  ]
}
```
The `clientId` field corresponds to a unique context (frame/worker), and is the same value used in [Service Workers](https://w3c.github.io/ServiceWorker/#dom-client-id).

This data is just a _snapshot_ of the lock manager state at some point in time. Once the data is returned to script, the lock state may have changed. It should therefore not usually be used by applications to make decisions about what locks are currently held or available.

### `steal` option to `request()`

If a web application detects an unrecoverable state - for example, some coordination point like a Service Worker determines that a tab holding a lock is no longer responding - it can "steal" a lock by passing this option to `request()`. When specified, any held locks for the resource will be released (and the _released promise_ of such locks will resolve with `AbortError`), and the request will be granted, preempting any queued requests for it. This should only be used in exceptional cases; any code running in tabs that assume they hold the lock will continue to execute, violating any guarantee of exclusive access to the resource.

Discussion about this controversial option is at: https://github.com/WICG/web-locks/issues/23


## Deadlocks

[Deadlocks](https://en.wikipedia.org/wiki/Deadlock) are a concept in concurrent computing. Here's a simple example of how they can be encountered through the use of this API:

```js
// Program 1
navigator.locks.request('A', async a => {
  await navigator.locks.request('B', async b => {
    // do stuff with A and B
  });
});

// Elsewhere...

// Program 2
navigator.locks.request('B', async b => {
  await navigator.locks.request('A', async a => {
    // do stuff with A and B
  });
});
```
If program 1 and program 2 run close to the same time, there is a chance that code 1 will hold lock A and code 2 will hold lock B and neither can make further progress - a deadlock. This will not affect the user agent as a whole, pause the tab, or affect other code in the origin, but this particular functionality will be blocked.

Preventing deadlocks requires care. One approach is to always acquire multiple locks in a strict order, e.g.:

```js
async function requestMultiple(resources, callback) {
  const sortedResources = Array.from(resources);
  sortedResources.sort(); // always request in the same order

  async function requestNext() {
    return await navigator.locks.request(sortedResources.shift(), async lock => {
      if (sortedResources.length > 0) {
        return await requestNext();
      } else {
        return await callback();
      }
    });
  }
  return await requestNext();
}
```

In practice, the use of multiple locks is rarely as straightforward - libraries and other utilities may conceal their use.

See issues for further discussion:

* [Single vs multi-resource locks](https://github.com/WICG/web-locks/issues/20)
* [Deadlock detection and resolution?](https://github.com/WICG/web-locks/issues/26)
* [Avoid deadlocks entirely via crafty API design?](https://github.com/WICG/web-locks/issues/28)


## FAQ

*Why can't [Atomics](https://tc39.github.io/ecmascript_sharedmem/shmem.html#AtomicsObject) be used for this?*

The use cases for this API require coordination across multiple
[agent clusters](https://html.spec.whatwg.org/multipage/webappapis.html#integration-with-the-javascript-agent-cluster-formalism);
 whereas Atomics operations operate on [SharedArrayBuffers](https://tc39.github.io/ecmascript_sharedmem/shmem.html#StructuredData.SharedArrayBuffer) which are constrained to a single agent cluster. (Informally: tabs/workers can be multi-process and atomics only work same-process.)


*Why is the _options_ argument not the last argument?*

Since both callbacks and options are typically made the last argument, the best ordering is not obvious. Based on trying both, placing the options closer to the call site makes reading/writing the code much clearer, so the options dictionary is placed before the callback. Compare (a) and (b):

```js
// a
navigator.locks.request('resource', async lock => {
  //
  // 100 lines of code...
  // ...
  //
}, {ifAvailable: 'true'});

// b
navigator.locks.request('resource', {ifAvailable: true}, async lock => {
  //
  // 100 lines of code...
  // ...
  //
});
```
It's much clearer in (b) that the request will not wait if the lock is not available. In (a) you need to read all the way through the lock handling code (artificially short/simple here) before noting the very different behavior of the two requests.


*What happens if a tab is throttled/suspended?*

If a tab holds a lock and stops running code it can inhibit work done by other tabs. If this is because tabs are not appropriately breaking up work it's an application problem. But browsers could throttle or even suspend tabs (e.g.
background background tabs) to reduce power and/or memory consumption. With an API like this &mdash; or with IndexedDB
&mdash; this can result the [work in foreground tabs being throttled](https://bugs.chromium.org/p/chromium/issues/detail?id=675372).

To mitigate this, browsers must ensure that apps are notified before being throttled or suspended so that
they can release locks, and/or browsers must automatically release locks held by a context before it is
suspended. See [A Lifecycle for the Web](https://github.com/spanicker/web-lifecycle) for possible thoughts
around formalizing these states and notifications.


*How do you _compose_ IndexedDB transactions with these locks?*

 * To wrap a lock around a transaction:

```js
    navigator.locks.request(name, options, lock => {
      return new Promise((resolve, reject) => {
        const tx = db.transaction(...);
        tx.oncomplete = resolve;
        tx.onabort = e => reject(tx.error);
        // use tx...
      });
    });
```

 * To wrap a transaction around a lock is harder, since you can't keep an IndexedDB transaction alive arbitrarily. If [transactions supported `waitUntil()`](https://github.com/WICG/indexeddb-promises) this would be possible:

```js
  const tx = db.transaction(...);
  tx.waitUntil(locks.request(name, options, async lock => {
    // use lock and tx
  });
```

Note that we don't want to _force_ IDBTransactions into this model of waiting for a resource before you can use it: in IDB you can open a transaction and schedule work against it immediately, even though that work will be delayed until the transaction is running.

*Can we _define_ IndexedDB transactions in terms of this primitive?*

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
was not enforced by IndexedDB implementations, developers expressed significant confusion. Given
demand, we could add an option/mode to allow opting into the more subtle behavior.


*Does this leak information from e.g. Incognito/Private Browsing/etc mode?*

No - like storage APIs, browsers treat such anonymous sessions as if they were a completely separate
user agent from the point of view of specs; the data is in a separate partition. This is similar
to how some browsers support multiple user profiles; cookies, databases, certificates, etc.
are all separated. Locks held in one user profile or anonymous session have no relationship to
locks in another session, as if they in a distinct application or on another device.


*Can you hold a lock for the lifetime of a tab?*

Yes. Using the API, just pass in a promise that never resolves:
```js
navigator.locks.request(name, lock => new Promise(r => {}));
```
In practice, you may want to reserve some ability to resolve the promise, e.g. in response to a "sign out" event or indication that the tab has become inactive. But in some scenarios (e.g. master election) then never releasing the lock until the page is terminated is entirely reasonable.


*If a tab is holding an exclusive lock, what happens if another lock request for the same resource is made?*

The second request will block. A lock corresponds to a granted request, and each request is considered regardless of context. This allows libraries running in the same page to coordinate the use of a shared resource. As a consequence, nested requests for the same resource will deadlock:
```js
await navigator.locks.request('mylock', async lock => {
  await navigator.locks.request('mylock', async lock => {});
});
```


## Related APIs

* [Atomics](https://tc39.github.io/ecmascript_sharedmem/shmem.html#AtomicsObject)
  * Resource coordination within a SharedArrayBuffer, limiting use to a particular [agent cluster](https://html.spec.whatwg.org/multipage/webappapis.html#integration-with-the-javascript-agent-cluster-formalism).
* [IndexedDB Transactions](https://w3c.github.io/IndexedDB/#transaction-concept)
  * No explicit control of transaction lifetimes. Requires use of full API (e.g. schema versioning).
* [Screen Orientation API](https://w3c.github.io/screen-orientation/)
  * Acquisition of a single system-provided resource.
  * `screen.orientation.lock('portrait').then(...)`
* [Pointer Lock](https://w3c.github.io/pointerlock/)
  * Acquisition of a single system-provided resource.
  * `element.requestPointerLock() `
* [Wake Lock API](https://w3c.github.io/wake-lock/)
  * Acquisition of a single system-provided resource.
  * `navigator.getWakeLock('screen').then(wakeLock => wakeLock.createRequest())`
* [Keyboard Lock](https://w3c.github.io/keyboard-lock/)
  * Acquisition of a single system-provided resource.
  * `navigator.requestKeyboardLock().then(...)` (proposed)

## Acknowledgements

Many thanks to
Alex Russell,
Anne van Kesteren,
Boris Zbarsky,
Darin Fisher,
Domenic Denicola,
Harald Alvestrand,
Jake Archibald,
L. David Baron,
Luciano Pacheco,
Marcos Caceres,
Ralph Chelala,
Ryan Fioravanti,
and
Victor Costan
for helping craft this proposal.
