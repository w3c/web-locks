**This is an early iteration focused on defining the algorithms for lock acquisition/release.
This may not match all the details of the README while we iterate on the API.**

----

## Concepts

A user agent has an associated **lock task queue** which is the result of [starting a new parallel queue](https://html.spec.whatwg.org/multipage/infrastructure.html#starting-a-new-parallel-queue).

### Lock

A **lock** has an associated **origin** which is an _origin_.

A **lock** has an associated **name** which is a DOMStrings.

A **lock** has an associated **mode** which is one of "`exclusive`" or "`shared`".

A **lock** has an associated **waiting promise** which is a Promise.

A **lock** has an associated **released promise** which is a Promise.

Each origin has an associated **held lock set** which is an [ordered set](https://infra.spec.whatwg.org/#ordered-set) of **locks**.

When **lock** _lock_'s **waiting promise** settles (fulfills or rejects), run the following steps on the **lock task queue**:

1. Let _origin_ be _lock_'s **origin**.
1. [Remove](https://infra.spec.whatwg.org/#list-remove) **lock** from the _origin_'s **held lock set**.
1. **Process the lock request queue** for _origin_.
1. Resolve _lock_'s **released promise** with _lock_'s **waiting promise**.

> TODO: Define how a lock held in a terminated agent is released.

### Lock Requests

A **lock request** is a tuple of (*name*, *mode*, *promise*).

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

### Navigator Mixins

```webidl
[SecureContext, Exposed=Window]
partial interface Navigator {
  readonly attribute LockManager locks;
};
[SecureContext, Exposed=Worker]
partial interface WorkerNavigator {
  readonly attribute LockManager locks;
};
```

### `LockManager` class

```webidl
[SecureContext]
interface LockManager {
  Promise<any> acquire(DOMString name,
                       LockGrantedCallback callback);
  Promise<any> acquire(DOMString name,
                       optional LockOptions options,
                       LockGrantedCallback callback);

  Promise<LockManagerSnapshot> query();
  
  void forceRelease(DOMString name);
};

callback LockGrantedCallback = Promise<any> (Lock lock);

enum LockMode { "shared", "exclusive" };

dictionary LockOptions {
  LockMode mode = "exclusive";
  boolean ifAvailable = false;
  boolean steal = true;
  AbortSignal signal;
};

dictionary LockManagerSnapshot {
  held sequence<LockInfo>;
  pending sequence<LockInfo>;
};

dictionary LockInfo {
  DOMString name;
  LockMode mode;
};
```

#### `LockManager.prototype.acquire(name, callback)`
#### `LockManager.prototype.acquire(name, options, callback)`

1. If _options_ was not passed, let _options_ be a new _LockOptions_ dictionary with default members.
1. Let _origin_ be context object’s relevant settings object’s origin.
1. If _origin_ is an opaque origin, return a Promise rejected with a "`SecurityError`" DOMException and abort these steps.
1. Return the result of running the **request a lock** algorithm, passing _origin_, _callback_, _name_, _options_'s _mode_, _options_'s _ifAvailable_, _option_'s _steal_, and _options_'s _signal_ (if present).

#### `LockManager.prototype.query()`

> The intent of this method is for web applications to introspect the locks that are requested/held for debugging purposes. It provides a snapshot of the lock state at an arbitrary point in time.

1. Let _origin_ be context object’s relevant settings object’s origin.
1. If _origin_ is an opaque origin, return a Promise rejected with a "`SecurityError`" DOMException and abort these steps.
1. Let _p_ be a new Promise.
1. [Enqueue the following steps](https://html.spec.whatwg.org/multipage/infrastructure.html#enqueue-the-following-steps) to the **lock task queue**:
    1. Let _pending_ be a new [list](https://infra.spec.whatwg.org/#list).
    1. For each _request_ in _origin_'s **lock request queue**:
        1. Let _info_ be a new `LockInfo` dictionary.
        1. Set _info_'s `name` dictionary member to _request_'s **name**.
        1. Set _info_'s `mode` dictionary member to _request_'s **mode**.
        1. [Append](https://infra.spec.whatwg.org/#list-append) _info_ to _pending_.
    1. Let _held_ be a new [list](https://infra.spec.whatwg.org/#list).
    1. For each _lock_ in _origin_'s **held lock set**:
        1. Let _info_ be a new `LockInfo` dictionary.
        1. Set _info_'s `name` dictionary member to _lock_'s **name**.
        1. Set _info_'s `mode` dictionary member to _lock_'s **mode**.
        1. [Append](https://infra.spec.whatwg.org/#list-append) _info_ to _held_.
    1. Let _snapshot_ be a new `LockManagerSnapshot` dictionary.
    1. Set _snapshot_'s `held` dictionary member to _held_.
    1. Set _snapshot_'s `pending` dictionary member to _pending_.
    1. Resolve _p_ with _snapshot_.
1. Return _p_.


### `Lock` class

```webidl
[SecureContext, Exposed=(Window,Worker)]
interface Lock {
  readonly attribute DOMString name;
  readonly attribute LockMode mode;
};
```

A `Lock` object has an associated **lock**.

#### `Lock.prototype.name`

Returns a DOMString with the associated **name** of the **lock**.

#### `Lock.prototype.mode`

Returns a DOMString containing the associated **mode** of the **lock**.

## Algorithms

### Algorithm: request a lock

To **request a lock** with _origin_, _callback_, _name_, _mode_, _ifAvailable_, _steal_, and optional _signal_:

1. Let _p_ be a new Promise.
1. [Enqueue the following steps](https://html.spec.whatwg.org/multipage/infrastructure.html#enqueue-the-following-steps) to the **lock task queue**:
   1. Let _queue_ be _origin_'s **lock request queue**.
   1. Let _held_ be _origin_'s **held lock set**.
   1. Let _request_ be a new **lock request** (_name_, _mode_, _p_).
   1. If _steal_ is true, then run these steps:
      1. For each _lock_ in _held_:
         1. If _lock_'s **name** is _name_:
            1. [Remove](https://infra.spec.whatwg.org/#list-remove) **lock** from _held_.
            1. Reject _lock_'s **released promise** with a new "`AbortError`" **DOMException**.
      1. For each _rq_ in _queue_:
         1. If _rq_'s **name** is _name_:
            1. [Remove](https://infra.spec.whatwg.org/#list-remove) _rq_ from _queue_.
            1. Reject _rq_'s **promise** with a new "`AbortError`" **DOMException**.
      1. Assert: _request_ is **grantable**.
   1. If _ifAvailable_ is true and _request_ is not **grantable**, then run these steps:
      1. Let _r_ be the result of invoking _callback_ with `null` as the only argument. (Note that _r_ may be a regular completion, an abrupt completion, or an unresolved Promise.)
      1. Resolve _p_ with _r_ and abort these steps.
   1. [Enqueue](https://infra.spec.whatwg.org/#queue-enqueue) _request_ in _origin_'s **lock request queue**.
   1. If _signal_ was given, [add the following abort steps](https://dom.spec.whatwg.org/#abortsignal-add) to _signal_:
      1. [Remove](https://infra.spec.whatwg.org/#list-remove) _request_ from _queue_.
      1. Reject _p_ with a new "`AbortError`" **DOMException**.
      1. **Process the lock request queue** for _origin_.
   1. **Process the lock request queue** for _origin_.
1. Return _p_.

To **process the lock request queue** for _origin_:

1. Let _queue_ be _origin_'s **lock request queue**.
1. For each _request_ in _queue_:
   1. If _request_ is **grantable**, then run these steps:
      1. [Remove](https://infra.spec.whatwg.org/#list-remove) _request_ from _queue_.
      1. Let _name_ be _request_'s **name**.
      1. Let _mode_ be _request_'s **mode**.
      1. Let _p_ be _request_'s **promise**.
      1. Let _waiting_ be a new Promise.
      1. Let _lock_ be a new **lock** with **origin** _origin_, **mode** _mode_, **name** _name_, **released promise** _p_, and **waiting promise** _waiting_.
      1. [Append](https://infra.spec.whatwg.org/#set-append) _lock_ to _origin_'s **held lock set**.
      1. Let _r_ be the result of invoking _callback_ with a new `Lock` object associated with _lock_ as the only argument. (Note that _r_ may be a regular completion, an abrupt completion, or an unresolved Promise.)
      1. Resolve _waiting_ with _r_.

> TODO: Define how a _lock request_ from a terminated agent is dequeued. 
