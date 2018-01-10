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

A web-based document editor stores state in memory for fast access and persists changes (as a series of records) to a storage API such as IndexedDB for resiliency and offline use, and to a server for cross-device use. When the same document is opened for editing in two tabs the work must be coordinated across tabs, such as allowing only one tab to make changes to or synchronize the document at a time. This requires the tabs to coordinate on which will be actively making changes (and synchronizing the in-memory state with the storage API), knowing when the active tab goes away (navigated, closed, crashed) so that another tab can become active.


## Concepts

A _name_ is just a string chosen by the web application to represent an abstract resource.

A _mode_ is either "exclusive" or "shared".

A _lock request_ is made by script for a particular _name_ and _mode_. A scheduling algorithm looks at the state of current and previous requests, and eventually grants a lock request.

A _lock_ is granted request; it has the _name_ of the resource and _mode_ of the lock request. It is represented as an object returned to script.

As long as the lock is _held_ it may prevent other lock requests from being granted (depending on the name and mode).

A lock can be _released_ by script, at which point it may allow other lock requests to be granted.

A user agent has a _lock manager_ for each origin, which encapsulates the state of all locks and requests for that origin.

#### Resources Names

The resource _name_ strings have no external meaning beyond the scheduling algorithm, but are global
across browsing contexts within an origin. Web applications are free to use any resource naming
scheme. For example, to mimic [IndexedDB](https://w3c.github.io/IndexedDB/#transaction-construct)'s transaction locking over named stores within a named
database, an origin might use `encodeURIComponent(db_name) + '/' + encodeURIComponent(store_name)`.


#### Modes and Scheduling

The _mode_ property and can be used to model the common [readers-writer lock](http://en.wikipedia.org/wiki/Readers%E2%80%93writer_lock) pattern. If an "exclusive" lock is held, no other locks with that name can be granted. If "shared" lock is held, other "shared" locks with that name can be granted - but not any "exclusive" locks. The default mode in the API is "exclusive".

Additional properties may influence scheduling, such as timeouts, fairness, and so on.


## API Proposal

```js
async function get_lock_then_write() {
  await navigator.locks.acquire('resource', async lock => {
    await async_write_func();
  });
}

async function get_lock_then_read() {
  await navigator.locks.acquire('resource', {mode: 'shared'}, async lock => {
    await async_read_func();
  });
}
```

The _name_ (required first argument) is a string, e.g. `'thing'.

The _callback_ (required final argument) is a callback invoked with the lock when granted. This "scoped release" API model encourages callers to pass in an async callback; the callback implicitly returns a promise and the lock is released when that promise resolves. In other words, the lock is held until the async callback completes. (If a non-async callback function is passed in, it is wrapped into a Promise that would resolve immediately, so the lock would only be held for the duration of the synchronous callback.)

> See [alternate API proposals](alternate-api-proposals.md) for slightly different API styles which were considered.

The method returns a promise that resolves/rejects with the result of the callback (so, after the lock is released), or rejects if the request is aborted. 

## Options

An options dictionary may be specified as a second argument (bumping the callback to the third argument).

### mode

An optional _mode_ member can be one of "exclusive" (the default if not specified) or "shared".
```js
await navigator.locks.acquire('resource', {mode: 'shared'}, async lock => {
  // Use |lock| here.
});
```

### signal

An optional _signal_ member can be specified which is an [AbortSignal](https://dom.spec.whatwg.org/#interface-AbortSignal). This allows aborting a lock request, for example if the request is not granted in a timely manner:
```js
const controller = new AbortController();
setTimeout(() => controller.abort(), 200); // wait at most 200ms

try {
  await navigator.locks.acquire('resource', {signal: controller.signal}, async lock => {
    // Use |lock| here.
  });
  // Done with lock here.
} catch (ex) {
  // |ex| will be a DOMException with error name "AbortError" if timer fired.
}
```

### ifAvailable

An optional _ifAvailable_ boolean member can be specified; the default is false. If true, then the lock is only granted if it can be without additional waiting. Note that this is still not _synchronous_; in many user agents this will require cross-process communication to see if the lock can be granted. If the lock cannot be granted, `null` is returned. (Since this is expected, the request is not rejected.)
```js
await navigator.locks.acquire('resource', {ifAvailable: true}, async lock => {
  // Use |lock| here.
});
```

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

## FAQ

*Why can't [Atomics](https://tc39.github.io/ecmascript_sharedmem/shmem.html#AtomicsObject) be used for this?*

The use cases for this API require coordination across multiple
[agent clusters](https://html.spec.whatwg.org/multipage/webappapis.html#integration-with-the-javascript-agent-cluster-formalism);
 whereas Atomics operations operate on [SharedArrayBuffers](https://tc39.github.io/ecmascript_sharedmem/shmem.html#StructuredData.SharedArrayBuffer) which are constrained to a single agent cluster. (Informally: tabs/workers can be multi-process and atomics only work same-process.)


*Why is the _options_ argument not the last argument?*

Since both callbacks and options are typically made the last argument, the best ordering is not obvious. Based on trying both, placing the options closer to the call site makes reading/writing the code much clearer, so the options dictionary is placed before the callback. Compare (a) and (b):

```js
// a
navigator.locks.acquire('resource', async lock => {
  //
  // 100 lines of code...
  // ...
  //
}, {ifAvailable: 'true'});

// b
navigator.locks.acquire('resource', {ifAvailable: true}, async lock => {
  //
  // 100 lines of code...
  // ...
  //
});
```
It's much clearer in (b) that the request will not wait if the lock is not available. In (a) you need to read all the way through the lock handling code (artificially short/simple here) before noting the very different behavior of the two requests.


*Can you lock over multiple resources at the same time?*

This is present in the [Indexed DB API](https://w3c.github.io/IndexedDB/#transaction-scope) as a _scope_.
This can be implemented in user-space with the following helper:

```js
async function acquireMultiple(resources) {
  const sortedResources = Array.from(resources);
  sortedResources.sort();
  for (const resource of sortedResources)
    await aquireSingle(resource);
}
```

Note the use of `sort()` which ensures that locks are always acquired in the same order, to avoid deadlocks. See [issue 20](https://github.com/inexorabletash/web-locks/issues/20) for further discussion.

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
    navigator.locks.acquire(name, options, lock => {
      return new Promise((resolve, reject) => {
        const tx = db.transaction(...);
        tx.oncomplete = resolve;
        tx.onabort = e => reject(tx.error);
        // use tx...
      });
    });
```

 * To wrap a transaction around a lock is harder, since you can't keep an IndexedDB transaction alive arbitrarily. If [transactions supported `waitUntil()`](https://github.com/inexorabletash/indexeddb-promises) this would be possible:

```js
  const tx = db.transaction(...);
  tx.waitUntil(locks.acquire(name, options, async lock => {
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


## Related APIs

* [Atomics](https://tc39.github.io/ecmascript_sharedmem/shmem.html#AtomicsObject)
  * Resource coordination within a SharedArrayBuffer, limiting use to a particular [agent cluster](https://html.spec.whatwg.org/multipage/webappapis.html#integration-with-the-javascript-agent-cluster-formalism).
* [IndexedDB Transactions](https://w3c.github.io/IndexedDB/#transaction-concept)
  * No explicit control of transaction lifetimes. Requires use of full API (e.g. schema versioning).
* [Wake Lock API](https://w3c.github.io/wake-lock/)
  * Acquisition of a single system-provided resource.

## Acknowledgements

Many thanks to
Alex Russell,
Anne van Kesteren,
Darin Fisher,
Domenic Denicola,
Harald Alvestrand,
Jake Archibald,
Ralph Chelala, 
Ryan Fioravanti,
and
Victor Costan
for helping craft this proposal.
