**This is an early iteration focused on defining the algorithms for lock acquisition/release
and a Promise-centric auto-releasing API. We not focus on this right now and instead get
the desired API/behavior sorted out.**

----


## Concepts

### Lock

A **lock** has an associated **state** which is one of "held", or "released".

A **lock** has an associated **scope** which is a set of DOMStrings.

A **lock** has an associated **mode** which is one of "`exclusive`" or "`shared`".

A **lock** has an associated **waiting promise set** which is a set of Promises.

A **lock** has an associated **released promise** which is a Promise.

When every promise in **lock**'s **waiting promise set** fulfills:

1. set **lock**'s **state** to "`released`".
2. fulfill **lock**'s **released promise**.

If any promise in **lock**'s **waiting promise set** rejects:

1. set **lock**'s **state** to "`released`".
2. reject **lock**'s **released promise**.

### Lock Requests

A **lock request** is a tuple of (*scope*, *mode*).

Each origin has an associated **lock request queue**, which is a queue of **lock requests**.

A **lock request** _request_ is said to be **grantable** if the following steps return true:

1. Let _queue_ be the origin's **lock request queue**
3. Let _mode_ be _request_'s associated **mode**
4. Let _scope_ be _request_'s associated **scope**
5. If _mode_ is "exclusive", return true if all of the following conditions are true, and false otherwise:
  * No **lock** in the origin has **state** "`held`" and has a **scope** that intersects _scope_
  * No entry in _queue_ earlier than _request_ has a **scope** that intersects _scope_.
6. Otherwise, mode is "shared"; return true if all of the following conditions are true, and false otherwise:
  * No **lock** in the origin has **state** "`held`" and has **mode** "exclusive" and has a **scope** that intersects _scope_
  * No entry in _queue_ earlier than _request_ has a **mode** "exclusive" and **scope** that intersects _scope_.


## API

### `Lock` class

A `Lock` object has an associated **lock**.

#### `Lock.prototype.scope`

Returns a frozen array containing the DOMStrings from the associated **scope** of the **lock**, in sorted in lexicographic order.

#### `Lock.prototype.mode`

Returns a DOMString containing the associated **mode** of the **lock**.

#### `Lock.prototype.released`

Returns the associated **released promise** of the **lock**.

#### `Lock.prototype.waitUntil(p)`

1. If `waitUntil(p)` is called and state is "released", then return `Promise.reject(new TypeError)`
2. Add `p` to lock's **waiting promise set**
3. Return lock's **released promise**.

#### `requestLock(scope, options)`

1. Let _scope_ be the set of unique DOMStrings in `scope` if a sequence was passed, otherwise a set containing just the string passed as `scope`
2. If _scope_ is empty, return a new Promise rejected with `TypeError`
3. Let _mode_ be the _options_' _mode_ if present, and "`exclusive`" otherwise.
5. Return the result of running the **request a lock** algorithm, passing _scope_, _mode_ and _options_' _signal_ (if present).

#### Algorithm: request a lock

To *request a lock* with _scope_, _mode_ and optional _signal_:

1. Let _p_ be a new promise.
2. Let _queue_ be the origin's **lock request queue**.
3. Let _request_ be a new **lock request** (_scope_, _mode_).
4. Append _request_ to _queue_.
5. If _signal_ was given, run the following in parallel:
   1. Wait until _signal_'s **aborted lock** is set.
   2. Abort any other steps running in parallel.
   3. Remove _request_ from _queue_.
   4. Reject _p_ with a new "`AbortError`" **DOMException**.
6. Run the following in parallel:
   1. Wait until _request_ is **grantable**
   2. Abort any other steps running in parallel.
   3. Let _waiting_ be a new promise.
   4. Let _lock_ be a **lock** with **state** "`held`", **mode** _mode_, **scope** _scope_, and add _waiting_ to _lock_'s **waiting promise set**.
   5. Remove _request_ from _queue_
   6. Resolve _p_ with a new `Lock` object associated with _lock_
   7. Schedule a microtask to resolve _waiting_.
7. Return _p_.

> NOTE: The final steps ensure that script waiting on the Promise from `requestLock()` will run before _waiting_ resolves.

> NOTE: The phrasing "wait until..." is intended to implicitly handle the case where an execution context is terminated; associated locks should cease to exist, unblocking the queue.

> TODO: Do we need to be explicit about dequeing requests from terminated execution contexts, or does that similarly "fall out" of the algorithm?

> TODO: More explicitly define _"in the origin"_
