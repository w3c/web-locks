**This is an early iteration focused on defining the algorithms for lock acquisition/release.
This may not match all the details of the README while we iterate on the API.**

----

Web IDL is defined in [interface.webidl](interface.webidl)

----

## Concepts

### Lock

A **lock** has an associated **name** which is a DOMStrings.

A **lock** has an associated **mode** which is one of "`exclusive`" or "`shared`".

A **lock** has an associated **waiting promise** which is a Promise.

Each origin has an associated **held lock set** which is an [ordered set](https://infra.spec.whatwg.org/#ordered-set) of **locks**.

When **lock**'s **waiting promise** settles (fulfills or rejects):

1. [Remove](https://infra.spec.whatwg.org/#list-remove) **lock** from the origin's **held lock set**.

### Lock Requests

A **lock request** is a tuple of (*name*, *mode*).

Each origin has an associated **lock request queue**, which is a [queue](https://infra.spec.whatwg.org/#queue) of **lock requests**.

A **lock request** _request_ is said to be **grantable** if the following steps return true:

1. Let _queue_ be the origin's **lock request queue**
1. Let _held_ be the origin's **held lock set**
1. Let _mode_ be _request_'s associated **mode**
1. Let _name_ be _request_'s associated **name**
1. If _mode_ is "`exclusive`", return true if all of the following conditions are true, and false otherwise:
    * No **lock** in _held_ has a **name** that equals _name_
    * No entry in _queue_ earlier than _request_ has a **name** that equals _name_.
1. Otherwise, mode is "`shared`"; return true if all of the following conditions are true, and false otherwise:
    * No **lock** in _held_ has **mode** "`exclusive`" and has a **name** that equals _name_.
    * No entry in _queue_ earlier than _request_ has a **mode** "`exclusive`" and **name** that equals _name_.


## API

### `Lock` class

A `Lock` object has an associated **lock**.

#### `Lock.prototype.name`

Returns a DOMString with the associated **name** of the **lock**.

#### `Lock.prototype.mode`

Returns a DOMString containing the associated **mode** of the **lock**.

#### `LockManager.prototype.acquire(name, callback)`
#### `LockManager.prototype.acquire(name, options, callback)`

1. If _options_ was not passed, let _options_ be a new _LockOptions_ dictionary with default members.
1. Let _origin_ be context object’s relevant settings object’s origin.
1. If _origin_ is an opaque origin, return a Promise rejected with a "`SecurityError`" DOMException and abort these steps.
1. Return the result of running the **request a lock** algorithm, passing _origin_, _callback_, _name_, _options_'s _mode_, _options_'s _ifAvailable_, and _options_'s _signal_ (if present).

#### Algorithm: request a lock

To *request a lock* with _origin_, _callback_, _name_, _mode_, _ifAvailable_, and optional _signal_:

1. Let _p_ be a new Promise.
1. Let _queue_ be _origin_'s **lock request queue**.
1. Let _held_ be _origin_'s **held lock set**.
1. Let _request_ be a new **lock request** (_name_, _mode_).
1. If _ifAvailable_ is true and _request_ is not **grantable**, then run these steps:
   1. Let _r_ be the result of invoking _callback_ with `null` as the only argument. (Note that _r_ may be a regular completion, an abrupt completion, or an unresolved Promise.)
   1. Resolve _p_ with _r_.
   1. Return _p_. (The remaining steps of this algorithm are not run.)
1. [Enqueue](https://infra.spec.whatwg.org/#queue-enqueue) _request_ in _queue_.
1. If _signal_ was given, run the following in parallel:
   1. Wait until _signal_'s **aborted lock** is set.
   1. Abort any other steps running in parallel.
   1. [Remove](https://infra.spec.whatwg.org/#list-remove) _request_ from _queue_.
   1. Reject _p_ with a new "`AbortError`" **DOMException**.
1. Run the following in parallel:
   1. Wait until _request_ is **grantable**
   1. Abort any other steps running in parallel.
   1. Let _waiting_ be a new Promise.
   1. Let _lock_ be a **lock** with **mode** _mode_, **name** _name_, and **waiting promise** _waiting_.
   1. [Remove](https://infra.spec.whatwg.org/#list-remove) _request_ from _queue_
   1. [Append](https://infra.spec.whatwg.org/#set-append) _lock_ to _set_
   1. Let _r_ be the result of invoking _callback_ with a new `Lock` object associated with _lock_ as the only argument. (Note that _r_ may be a regular completion, an abrupt completion, or an unresolved Promise.)
   1. Resolve _waiting_ with _r_.
   1. Resolve _p_ with _r_.
1. Run the following in parallel:
   1. Wait until the agent from which this algorithm was invoked was terminated.
   1. Abort any other steps running in parallel.
   1. [Remove](https://infra.spec.whatwg.org/#list-remove) _request_ from _queue_.
   1. Abort these steps.
1. Return _p_.

> TODO: Define how a lock held in a terminated agent is released.

> TODO: More explicitly define _"in the origin"_

#### `LockManager.prototype.queryState()`

> The intent of this method is for web applications to introspect the locks that are requested/held for debugging purposes. It provides a snapshot of the lock state at an arbitrary point in time.

1. Let _origin_ be context object’s relevant settings object’s origin.
1. If _origin_ is an opaque origin, return a Promise rejected with a "`SecurityError`" DOMException and abort these steps.
1. Let _p_ be a new Promise.
1. Run the following in parallel:
    1. Let _pending_ be a new [list](https://infra.spec.whatwg.org/#list).
    1. For each _request_ in _origin_'s **lock request queue**:
        1. Let _r_ be a new `LockRequest` dictionary.
        1. Set _r_'s `name` dictionary member to _request_'s **name**.
        1. Set _r_'s `mode` dictionary member to _request_'s **mode**.
        1. [Append](https://infra.spec.whatwg.org/#list-append) _r_ to _pending_.
    1. Let _held_ be a new [list](https://infra.spec.whatwg.org/#list).
    1. For each _lock_ in _origin_'s **held lock set**:
        1. Let _r_ be a new `LockRequest` dictionary.
        1. Set _r_'s `name` dictionary member to _lock_'s **name**.
        1. Set _r_'s `mode` dictionary member to _lock_'s **mode**.
        1. [Append](https://infra.spec.whatwg.org/#list-append) _r_ to _held_.
    1. Let _state_ be a new `LockState` dictionary.
    1. Set _state_'s `held` dictionary member to _held_.
    1. Set _state_'s `pending` dictionary member to _pending_.
    1. Resolve _p_ with _state_.
1. Return _p_.


#### `LockManager.prototype.forceRelease(name)`

> The intent of this method is for web applications to accomodate unexpected behavior in the applications themselves or in the user agent. A lock released by this method leaves the previous holder in a potentially untested state.

1. Let _origin_ be context object’s relevant settings object’s origin.
1. If _origin_ is an opaque origin, return a Promise rejected with a "`SecurityError`" DOMException and abort these steps.
1. Run the following in parallel:
    1. [Remove](https://infra.spec.whatwg.org/#list-remove) all members of _origin_'s **held lock set** whose **name** equals _name_.

> The intent is that the removal is atomic. That is, all removals occur before any of the waiting steps in _request a lock_ are allowed to proceed.

> TODO: How does the Promise returned by `acquire` get resolved in a force-release case? If `AbortError`, how/where do we spec that?
