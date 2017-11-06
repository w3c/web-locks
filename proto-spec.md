**This is an early iteration focused on defining the algorithms for lock acquisition/release.
This may not match all the details of the README while we iterate on the API.**

----


## Concepts

### Lock

A **lock** has an associated **state** which is one of "`held`", or "`released`".

A **lock** has an associated **scope** which is a set of DOMStrings.

A **lock** has an associated **mode** which is one of "`exclusive`" or "`shared`".

A **lock** has an associated **waiting promise** which is a Promise.

When **lock**'s **waiting promise** settles (fulfills or rejects):

1. set **lock**'s **state** to "`released`".

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

#### `Lock.prototype.waitUntil(p)`

1. If `waitUntil(p)` is called and state is "`released`", then return `Promise.reject(new TypeError)`
2. Add `p` to lock's **waiting promise set**
3. Return lock's **released promise**.

#### `requestLock(scope, callback, options)`

1. Let _origin_ be the origin of the global scope.
2. If _origin_ is an opaque origin, return a promise rejected with a "`SecurityError`" DOMException and abort these steps.
3. Let _scope_ be the set of unique DOMStrings in `scope` if a sequence was passed, otherwise a set containing just the string passed as `scope`
4. If _scope_ is empty, return a new Promise rejected with `TypeError`
5. Return the result of running the **request a lock** algorithm, passing _origin_, _callback_, _scope_, _option_'s _mode_, _option_'s _ifAvailable_, and _options_'s _signal_ (if present).

#### Algorithm: request a lock

To *request a lock* with _origin_, _callback_, _scope_, _mode_, _ifAvailable_, and optional _signal_:

1. Let _p_ be a new promise.
2. Let _queue_ be _origin_'s **lock request queue**.
3. Let _request_ be a new **lock request** (_scope_, _mode_).
4. If _ifAvailable_ is true and _request_ is not **grantable**, then run these steps:
   1. Let _r_ be the result of invoking _callback_ with `null` as the only argument. (Note that _r_ may be a regular completion, an abrupt completion, or an unresolved Promise.)
   2. Resolve _p_ with _r_.
   3. Return _p_. (The remaining steps of this algorithm are not run.)
5. Append _request_ to _queue_.
6. If _signal_ was given, run the following in parallel:
   1. Wait until _signal_'s **aborted lock** is set.
   2. Abort any other steps running in parallel.
   3. Remove _request_ from _queue_.
   4. Reject _p_ with a new "`AbortError`" **DOMException**.
7. Run the following in parallel:
   1. Wait until _request_ is **grantable**
   2. Abort any other steps running in parallel.
   3. Let _waiting_ be a new Promise.
   4. Let _lock_ be a **lock** with **state** "`held`", **mode** _mode_, **scope** _scope_, and **waiting promise** _waiting_.
   5. Remove _request_ from _queue_
   6. Let _r_ be the result of invoking _callback_ with a new `Lock` object associated with _lock_ as the only argument. (Note that _r_ may be a regular completion, an abrupt completion, or an unresolved Promise.)
   7. Resolve _waiting_ with _r_.
   8. Resolve _p_ with _r_.
8. Run the following in parallel:
   1. Wait until the agent from which this algorithm was invoked was terminated.
   2. Abort any other steps running in parallel.
   3. Remove _request_ from _queue_.
   4. Abort these steps.
9. Return _p_.

> TODO: Define how a lock held in a terminated agent is released.

> TODO: More explicitly define _"in the origin"_
