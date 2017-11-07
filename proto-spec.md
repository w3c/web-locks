**This is an early iteration focused on defining the algorithms for lock acquisition/release.
This may not match all the details of the README while we iterate on the API.**

----


## Concepts

### Lock

A **lock** has an associated **scope** which is a set of DOMStrings.

A **lock** has an associated **mode** which is one of "`exclusive`" or "`shared`".

A **lock** has an associated **waiting promise** which is a Promise.

Each origin has an associated **held lock set** which is an [ordered set](https://infra.spec.whatwg.org/#ordered-set) of **locks**.

When **lock**'s **waiting promise** settles (fulfills or rejects):

1. [Remove](https://infra.spec.whatwg.org/#list-remove) **lock** from the origin's **held lock set**.

### Lock Requests

A **lock request** is a tuple of (*scope*, *mode*).

Each origin has an associated **lock request queue**, which is a [queue](https://infra.spec.whatwg.org/#queue) of **lock requests**.

A **lock request** _request_ is said to be **grantable** if the following steps return true:

1. Let _queue_ be the origin's **lock request queue**
2. Let _held_ be the origin's **held lock set**
3. Let _mode_ be _request_'s associated **mode**
4. Let _scope_ be _request_'s associated **scope**
5. If _mode_ is "`exclusive`", return true if all of the following conditions are true, and false otherwise:
  * No **lock** in _held_ has a **scope** that intersects _scope_
  * No entry in _queue_ earlier than _request_ has a **scope** that intersects _scope_.
6. Otherwise, mode is "`shared`"; return true if all of the following conditions are true, and false otherwise:
  * No **lock** in _held_ has **mode** "`exclusive`" and has a **scope** that intersects _scope_.
  * No entry in _queue_ earlier than _request_ has a **mode** "`exclusive`" and **scope** that intersects _scope_.


## API

### `Lock` class

A `Lock` object has an associated **lock**.

#### `Lock.prototype.scope`

Returns a frozen array containing the DOMStrings from the associated **scope** of the **lock**, in sorted in lexicographic order.

#### `Lock.prototype.mode`

Returns a DOMString containing the associated **mode** of the **lock**.

#### `LockManager.prototype.acquire(scope, callback, options)`

1. Let _origin_ be the origin of the global scope.
2. If _origin_ is an opaque origin, return a Promise rejected with a "`SecurityError`" DOMException and abort these steps.
3. Let _scope_ be the set of unique DOMStrings in `scope` if a sequence was passed, otherwise a set containing just the string passed as `scope`
4. If _scope_ is empty, return a new Promise rejected with `TypeError`
5. Return the result of running the **request a lock** algorithm, passing _origin_, _callback_, _scope_, _option_'s _mode_, _option_'s _ifAvailable_, and _options_'s _signal_ (if present).

#### Algorithm: request a lock

To *request a lock* with _origin_, _callback_, _scope_, _mode_, _ifAvailable_, and optional _signal_:

1. Let _p_ be a new Promise.
2. Let _queue_ be _origin_'s **lock request queue**.
2. Let _held_ be _origin_'s **held lock set**.
3. Let _request_ be a new **lock request** (_scope_, _mode_).
4. If _ifAvailable_ is true and _request_ is not **grantable**, then run these steps:
   1. Let _r_ be the result of invoking _callback_ with `null` as the only argument. (Note that _r_ may be a regular completion, an abrupt completion, or an unresolved Promise.)
   2. Resolve _p_ with _r_.
   3. Return _p_. (The remaining steps of this algorithm are not run.)
5. [Enqueue](https://infra.spec.whatwg.org/#queue-enqueue) _request_ in _queue_.
6. If _signal_ was given, run the following in parallel:
   1. Wait until _signal_'s **aborted lock** is set.
   2. Abort any other steps running in parallel.
   3. [Remove](https://infra.spec.whatwg.org/#list-remove) _request_ from _queue_.
   4. Reject _p_ with a new "`AbortError`" **DOMException**.
7. Run the following in parallel:
   1. Wait until _request_ is **grantable**
   2. Abort any other steps running in parallel.
   3. Let _waiting_ be a new Promise.
   4. Let _lock_ be a **lock** with **mode** _mode_, **scope** _scope_, and **waiting promise** _waiting_.
   5. [Remove](https://infra.spec.whatwg.org/#list-remove) _request_ from _queue_
   6. [Append](https://infra.spec.whatwg.org/#set-append) _lock_ to _set_
   7. Let _r_ be the result of invoking _callback_ with a new `Lock` object associated with _lock_ as the only argument. (Note that _r_ may be a regular completion, an abrupt completion, or an unresolved Promise.)
   7. Resolve _waiting_ with _r_.
   8. Resolve _p_ with _r_.
8. Run the following in parallel:
   1. Wait until the agent from which this algorithm was invoked was terminated.
   2. Abort any other steps running in parallel.
   3. [Remove](https://infra.spec.whatwg.org/#list-remove) _request_ from _queue_.
   4. Abort these steps.
9. Return _p_.

> TODO: Define how a lock held in a terminated agent is released.

> TODO: More explicitly define _"in the origin"_

#### `LockManager.prototype.queryState()`

> The intent of this method is for web applications to introspect the locks that are requested/held for debugging purposes. It provides a snapshot of the lock state at an arbitrary point in time.

1. Let _origin_ be the origin of the global scope.
2. If _origin_ is an opaque origin, return a Promise rejected with a "`SecurityError`" DOMException and abort these steps.
3. Let _p_ be a new Promise.
4. Run the following in parallel:
    1. Let _pending_ be a new [list](https://infra.spec.whatwg.org/#list).
    2. For each _request_ in _origin_'s **lock request queue**:
        1. Let _r_ be a new _LockRequest_ dictionary.
        2. Set _r_'s `scope` dictionary member to _request_'s **scope**.
        3. Set _r_'s `mode` dictionary member to _request_'s **mode**.
        4. [Append](https://infra.spec.whatwg.org/#list-append) _r_ to _pending_.
    3. Let _held_ be a new [list](https://infra.spec.whatwg.org/#list).
    4. For each _lock_ in _origin_'s **held lock set**:
        1. Let _r_ be a new _LockRequest_ dictionary.
        2. Set _r_'s `scope` dictionary member to _lock_'s **scope**.
        3. Set _r_'s `mode` dictionary member to _lock_'s **mode**.
        4. [Append](https://infra.spec.whatwg.org/#list-append) _r_ to _held_.
    5. Let _state_ be a new `LockState` dictionary.
    6. Set _state_'s `held` dictionary member to _held_.
    7. Set _state_'s `pending` dictionary member to _pending_.
    8. Resolve _p_ with _state_.
5. Return _p_.


#### `LockManager.prototype.forceRelease(scope)`

> The intent of this method is for web applications to accomodate unexpected behavior in the applications themselves or in the user agent. A lock released by this method leaves the previous holder in a potentially untested state.

1. Let _origin_ be the origin of the global scope.
2. If _origin_ is an opaque origin, return a Promise rejected with a "`SecurityError`" DOMException and abort these steps.
3. Let _scope_ be the set of unique DOMStrings in `scope` if a sequence was passed, otherwise a set containing just the string passed as `scope`
4. If _scope_ is empty, return a new Promise rejected with `TypeError`
5. Run the following in parallel:
    1. [Remove](https://infra.spec.whatwg.org/#list-remove) all members of _origin_'s **held lock set** whose **scope** contains any member of _scope_.

> The intent is that the removal is atomic. That is, all removals occur before any of the waiting steps in _request a lock_ are allowed to proceed.

> TODO: How does the Promise returned by `acquire` get resolved in a force-release case? If `AbortError`, how/where do we spec that?
