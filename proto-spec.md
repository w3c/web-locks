**This is an early iteration focused on defining the algorithms for flag acquisition/release
and a Promise-centric auto-releasing API. We not focus on this right now and instead get
the desired API/behavior sorted out.**

----


## Concepts

### Flag

A **flag** has an associated **state** which is one of "held", or "released".

A **flag** has an associated **scope** which is a set of DOMStrings.

A **flag** has an associated **mode** which is one of "`exclusive`" or "`shared`".

A **flag** has an associated **waiting promise set** which is a set of Promises.

A **flag** has an associated **released promise** which is a Promise.

When every promise in **flag**'s **waiting promise set** fulfills:

1. set **flag**'s **state** to "`released`".
2. fulfill **flag**'s **released promise**.

If any promise in **flag**'s **waiting promise set** rejects:

1. set **flag**'s **state** to "`released`".
2. reject **flag**'s **released promise**.

### Flag Requests

A **flag request** is a tuple of (*scope*, *mode*).

Each origin has an associated **flag request queue**, which is a queue of **flag requests**.

A **flag request** _request_ is said to be **grantable** if the following steps return true:

1. Let _queue_ be the origin's **flag request queue**
3. Let _mode_ be _request_'s associated **mode**
4. Let _scope_ be _request_'s associated **scope**
5. If _mode_ is "exclusive", return true if all of the following conditions are true, and false otherwise:
  * No **flag** in the origin has **state** "`held`" and has a **scope** that intersects _scope_
  * No entry in _queue_ earlier than _request_ has a **scope** that intersects _scope_.
6. Otherwise, mode is "shared"; return true if all of the following conditions are true, and false otherwise:
  * No **flag** in the origin has **state** "`held`" and has **mode** "exclusive" and has a **scope** that intersects _scope_
  * No entry in _queue_ earlier than _request_ has a **mode** "exclusive" and **scope** that intersects _scope_.


## API

### `Flag` class

A `Flag` object has an associated **flag**.

#### `Flag.prototype.scope`

Returns a frozen array containing the DOMStrings from the associated **scope** of the **flag**, in sorted in lexicographic order.

#### `Flag.prototype.mode`

Returns a DOMString containing the associated **mode** of the **flag**.

#### `Flag.prototype.released`

Returns the associated **released promise** of the **flag**.

#### `Flag.prototype.waitUntil()`

1. If `waitUntil(p)` is called and state is "released", then return `Promise.reject(new TypeError)`
2. Add `p` to flag's **waiting promise set**
3. Return flag's **released promise**.

#### `requestFlag()`

1. Let _scope_ be the set of unique DOMStrings in `scope` if a sequence was passed, otherwise a set containing just the string passed as `scope`
2. If _scope_ is empty, return a new Promise rejected with `TypeError`
3. Let _mode_ be the value of `mode`
4. Let _timeout_ be the value of `options.timeout` if passed, or +∞ otherwise.
5. Return the result of running the **request a flag** algorithm, passing _scope_, _mode_ and _timeout_.

#### Algorithm: request a flag

To *request a flag* with _scope_, _mode_ and _timeout_:

1. Let _p_ be a new promise
2. Run the following steps in parallel:
  1. Let _queue_ be the origin's **flag request queue**
  2. Let _request_ be a new **flag request** (_scope_, _mode_)
  3. Append _request_ to _queue_
  4. Run the following in parallel:
    1. Wait until _timeout_ microseconds have passed
    2. Remove _request_ from _queue_
    3. Reject _p_ with a new `TimeoutError`
    4. Abort any steps running in parallel.
  5. Wait until _request_ is **grantable**
  6. Let _waiting_ be a new promise.
  7. Let _flag_ be a **flag** with **state** "`held`", **mode** _mode_, **scope** _scope_, and add _waiting_ to _flag_'s **waiting promise set**.
  8. Remove _request_ from _queue_
  9. Resolve _p_ with a new `Flag` object associated with _flag_
  10. Schedule a microtask to resolve _waiting_.
  11. Abort any steps running in parallel.
3. Return _p_.

> NOTE: The final steps ensure that script waiting on the Promise from `requestFlag()` will run before _waiting_ resolves.

> NOTE: The phrasing "wait until..." is intended to implicitly handle the case where an execution context is terminated; associated flags should cease to exist, unblocking the queue.

> TODO: Do we need to be explicit about dequeing requests from terminated execution contexts, or does that similarly "fall out" of the algorithm?

> TODO: More explicitly define _"in the origin"_

> TODO: Clarify that timeout 0 should at least try to acquire the flags.
