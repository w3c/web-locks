# Origin Flags
<img src="https://s3.amazonaws.com/inexorabletash-share/standards/logo-flags.svg" height="100" align=right>

a.k.a. Locks, Mutexes, Semaphores, etc

> STATUS: Actively brainstorming and soliciting feedback

The Indexed Database API defines a transaction model allowing shared read and exclusive write access across multiple named storage partitions within an origin. We'd like to generalize this model to allow any Web Platform activity to be scheduled based on resource availability. This would allow transactions to be composed for other storage types (such as Cache Storage), across storage types, even across non-storage APIs.

Cooperative coordination takes place within the scope of same-origin contexts (TODO: formalize!); this may span multiple
[agent clusters](https://html.spec.whatwg.org/multipage/webappapis.html#integration-with-the-javascript-agent-cluster-formalism) (informally: process boundaries) and therefore [Atomics](http://lars-t-hansen.github.io/ecmascript_sharedmem/shmem.html#AtomicsObject) cannot be used to achieve the same purpose.


Previous discussions:
* [Application defined "locks" [whatwg]](https://lists.w3.org/Archives/Public/public-whatwg-archive/2009Sep/0266.html)

## Basic Usage

```js
function write() {
  requestFlag('resource', 'exclusive').then(function(flag) {
    flag.waitUntil(...);
    ...
  });
}

function read() {
  requestFlag('resource', 'shared', {timeout: 200}).then(function(flag) {
    ...
  });
}
```

Or with async/await syntax:
```js
async function write() {
  let flag = await requestFlag('resource', 'exclusive');
  flag.waitUntil(...);
}

async function read() {
  let flag = await requestFlag('resource', 'shared', {timeout: 200});
  flag.waitUntil(...);
});
```


The _scope_ (first argument) can be a string or array of strings, e.g. `['thing1', 'thing2']`. The items in the scope have no external meaning beyond the scheduling algorithm, but are global across browsing contexts within an origin. Web applications are free to use any resource naming scheme. For example, to mimic Indexed DB's transaction locking over named stores within a named database, an origin might use `encodeURIComponent(db_name) + '/' + encodeURIComponent(store_name)`.

The _mode_ (second argument) is one of "exclusive" or "shared", and can be used to model the common [readers-writer lock](http://en.wikipedia.org/wiki/Readers%E2%80%93writer_lock) pattern. If a held "exclusive' flag has an entry in its scope, no other flags with that entry in scope can become held. If a held "shared" flag has an entry in its scope, only other "shared" flags with that entry in scope can become held.

An optional _timeout_ scan be specified in milliseconds. If the timeout passes before the flag request succeeds, the promise rejects with a `TimeoutError`. A timeout of `0` can be specified to attempt to acquire the flag but fail immediately if already held.

A flag will automatically be released by a subsequent microtask if `waitUntil(p)` is not called with a promise to extend its lifetime within the callback from the initial acquisition promise.

## Notes

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
