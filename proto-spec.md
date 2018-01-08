<img src="https://cdn.rawgit.com/inexorabletash/web-locks/master/logo-lock.svg" height="100" align=right>

## Concepts

A user agent has an associated **lock task queue** which is the result of [starting a new parallel queue](https://html.spec.whatwg.org/multipage/infrastructure.html#starting-a-new-parallel-queue).

### Lock

A **lock** has an associated **agent** which is an [agent](https://tc39.github.io/ecma262/#agent).

A **lock** has an associated **origin** which is an [origin](https://html.spec.whatwg.org/multipage/webappapis.html#concept-settings-object-origin).

A **lock** has an associated **name** which is a DOMString.

A **lock** has an associated **mode** which is one of "`exclusive`" or "`shared`".

A **lock** has an associated **waiting promise** which is a Promise.

A **lock** has an associated **released promise** which is a Promise.

> Note: There are two promises associated with a lock's lifecycle:
> * A promise provided either implicitly or explicitly by the callback when the lock is granted which determines how long the lock is held. When this promise settles, the lock is released. This is known as the lock's _waiting promise_.
> * A promise returned by the `acquire()` method that settles when the lock is released or the request is aborted. This is known as the lock's _released promise_.
> ```js
> const p1 = navigator.locks.acquire('resource', lock => {
>   const p2 = new Promise(r => { /* logic to use lock and resolve promise */ });
>   return p2;
> });
> ```
> In the above example, `p1` is the _released promise_ and `p2` is the _waiting promise_.
> Note that in most code the callback would be implemented as an `async` function and the returned promise would be implicit, as in the following example:
> ```js
> const p1 = navigator.locks.acquire('resource', async lock => {
>   /* logic to use lock */
> });
> ```
> The _waiting promise_ is not named in the above code, but is still present as the return value from the `async` callback.
> Further note that if the callback is not `async` and returns a non-promise, the return value is wrapped in a promise that is immediately resolved; so the lock will be released in an upcoming microtask, and the _released promise_ will also resolve in a subsequent microtask.

Each origin has an associated **held lock set** which is an [ordered set](https://infra.spec.whatwg.org/#ordered-set) of **locks**.

When **lock** _lock_'s **waiting promise** settles (fulfills or rejects), [enqueue the following steps](https://html.spec.whatwg.org/multipage/infrastructure.html#enqueue-the-following-steps) on the **lock task queue**:

1. **Release the lock** _lock_.
1. Resolve _lock_'s **released promise** with _lock_'s **waiting promise**.

### Lock Requests

A **lock request** is a tuple of (*agent*, *origin*, *name*, *mode*, *promise*).

Each origin has an associated **lock request queue**, which is a [queue](https://infra.spec.whatwg.org/#queue) of **lock requests**.

A **lock request** _request_ is said to be **grantable** if the following steps return true:

1. Let _origin_ be _request_'s **origin**.
1. Let _queue_ be _origin_'s **lock request queue**
1. Let _held_ be _origin_'s **held lock set**
1. Let _mode_ be _request_'s associated **mode**
1. Let _name_ be _request_'s associated **name**
1. If _mode_ is "`exclusive`", return true if all of the following conditions are true, and false otherwise:
    * No **lock** in _held_ has a **name** that equals _name_
    * No **lock request** in _queue_ earlier than _request_ has a **name** that equals _name_.
1. Otherwise, mode is "`shared`"; return true if all of the following conditions are true, and false otherwise:
    * No **lock** in _held_ has **mode** "`exclusive`" and has a **name** that equals _name_.
    * No **lock request** in _queue_ earlier than _request_ has a **mode** "`exclusive`" and **name** that equals _name_.

### Agent Integration

When an [agent](https://tc39.github.io/ecma262/#agent) _terminates_ [TBD], [enqueue the following steps](https://html.spec.whatwg.org/multipage/infrastructure.html#enqueue-the-following-steps) on the **lock task queue**:

1. For each **lock request** _request_ with **agent** equal to the terminating agent:
    1. **Abort the request** _request_.
1. For each **lock** _lock_ with **agent** equal to the terminating agent:
    1. **Release the lock** _lock_.
    
## API

### Navigator Mixins

```webidl
[SecureContext]
interface mixin NavigatorLocks {
  readonly attribute LockManager locks;
};
Navigator includes NavigatorLocks;
WorkerNavigator includes NavigatorLocks;
```

Each [environment settings object](https://html.spec.whatwg.org/multipage/webappapis.html#environment-settings-object) has an associated `LockManager` object.

The `storage` attribute’s getter must return [context object](https://dom.spec.whatwg.org/#context-object)’s [relevant settings object](https://html.spec.whatwg.org/multipage/webappapis.html#relevant-settings-object)’s `LockManager` object.

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
  sequence<LockInfo> held;
  sequence<LockInfo> pending;
};

dictionary LockInfo {
  DOMString name;
  LockMode mode;
};
```

#### `LockManager.prototype.acquire(name, callback)`
#### `LockManager.prototype.acquire(name, options, callback)`

1. Let _promise_ be a new promise.
1. If _options_ was not passed, let _options_ be a new `LockOptions` dictionary with default members.
1. Let _origin_ be [context object](https://dom.spec.whatwg.org/#context-object)’s [relevant settings object](https://html.spec.whatwg.org/multipage/webappapis.html#relevant-settings-object)’s [origin](https://html.spec.whatwg.org/multipage/webappapis.html#concept-settings-object-origin).
1. If _origin_ is an [opaque origin](https://html.spec.whatwg.org/multipage/origin.html#concept-origin-opaque), reject _promise_ with a "`SecurityError`" DOMException.
1. Otherwise, [enqueue the steps](https://html.spec.whatwg.org/multipage/infrastructure.html#enqueue-the-following-steps) to **request a lock** with _promise_, the current [agent](https://tc39.github.io/ecma262/#agent), _origin_, _callback_, _name_, _options_'s _mode_ dictionary member, _options_'s _ifAvailable_ dictionary member, _option_'s _steal_ dictionary member, and _options_'s _signal_ dictionary member (if present) to the **lock task queue**.
1. Return _promise_.

> Note: An overloaded method is provided so that the callback always appears as the last argument.
> This assures that options, if present, appear near the call site where they are synchronously processed, rather than after the callback which may include a significant amount of code which will execute asynchronously.

> Note: The `steal` option should be used with caution.
> When used, code previously holding a lock will now be executing without guarantees that it is the sole context with access to the abstract resource.
> Similarly, the code that used the option has no guarantees that other contexts will not still be executing as if they have access to the abstract resource.
> It is intended for use by web applications that need to attempt recovery in the face of application and/or user-agent defects, where behavior is already unpredictable.

#### `LockManager.prototype.query()`

> Note: The intent of this method is for web applications to introspect the locks that are requested/held for debugging purposes. It provides a snapshot of the lock state at an arbitrary point in time.

1. Let _promise_ be a new promise.
1. Let _origin_ be [context object](https://dom.spec.whatwg.org/#context-object)’s [relevant settings object](https://html.spec.whatwg.org/multipage/webappapis.html#relevant-settings-object)’s [origin](https://html.spec.whatwg.org/multipage/webappapis.html#concept-settings-object-origin).
1. If _origin_ is an [opaque origin](https://html.spec.whatwg.org/multipage/origin.html#concept-origin-opaque), reject _promise_ with a "`SecurityError`" DOMException and abort these steps.
1. Otherwise, [enqueue the steps](https://html.spec.whatwg.org/multipage/infrastructure.html#enqueue-the-following-steps) for to **snapshot the lock state** for _origin_ with _promise_ to the **lock task queue**.
1. Return _promise_.


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

### Algorithm: Request a lock

To **request a lock** with _promise_, _agent_, _origin_, _callback_, _name_, _mode_, _ifAvailable_, _steal_, and optional _signal_:

1. [Assert](https://infra.spec.whatwg.org/#assert): these steps are running on the **lock task queue**.
1. Let _queue_ be _origin_'s **lock request queue**.
1. Let _held_ be _origin_'s **held lock set**.
1. Let _request_ be a new **lock request** (_origin_, _agent_, _name_, _mode_, _promise_).
1. If _steal_ is true, then run these steps:
   1. [For each](https://infra.spec.whatwg.org/#list-iterate) _lock_ of _held_:
      1. If _lock_'s **name** is _name_:
         1. [Remove](https://infra.spec.whatwg.org/#list-remove) **lock** from _held_.
         1. Reject _lock_'s **released promise** with a new "`AbortError`" **DOMException**.
   1. [For each](https://infra.spec.whatwg.org/#list-iterate) _rq_ of _queue_:
      1. If _rq_'s **name** is _name_:
         1. [Remove](https://infra.spec.whatwg.org/#list-remove) _rq_ from _queue_.
         1. Reject _rq_'s **promise** with a new "`AbortError`" **DOMException**.
   1. Assert: _request_ is **grantable**.
1. If _ifAvailable_ is true and _request_ is not **grantable**, then run these steps:
   1. Let _r_ be the result of invoking _callback_ with `null` as the only argument. (Note that _r_ may be a regular completion, an abrupt completion, or an unresolved Promise.)
   1. Resolve _promise_ with _r_ and abort these steps.
1. [Enqueue](https://infra.spec.whatwg.org/#queue-enqueue) _request_ in _origin_'s **lock request queue**.
1. If _signal_ was given, [add the following abort steps](https://dom.spec.whatwg.org/#abortsignal-add) to _signal_:
   1. [Remove](https://infra.spec.whatwg.org/#list-remove) _request_ from _queue_.
   1. Reject _promise_ with a new "`AbortError`" **DOMException**.
   1. **Process the lock request queue** for _origin_.
1. **Process the lock request queue** for _origin_.

### Algorithm: Release a lock

To **release the lock** _lock_:

1. [Assert](https://infra.spec.whatwg.org/#assert): these steps are running on the **lock task queue**.
1. Let _origin_ be _lock_'s **origin**.
1. [Remove](https://infra.spec.whatwg.org/#list-remove) **lock** from the _origin_'s **held lock set**.
1. **Process the lock request queue** for _origin_.

### Algorithm: Abort a request

To **abort the request** _request_:

1. [Assert](https://infra.spec.whatwg.org/#assert): these steps are running on the **lock task queue**.
1. Let _origin_ be _request_'s **origin**.
1. [Remove](https://infra.spec.whatwg.org/#list-remove) _request_ from _origin_'s **lock request queue**.
1. **Process the lock request queue** for _origin_.

### Algorithm: Process a lock request queue

To **process the lock request queue** for _origin_:

1. [Assert](https://infra.spec.whatwg.org/#assert): these steps are running on the **lock task queue**.
1. Let _queue_ be _origin_'s **lock request queue**.
1. [For each](https://infra.spec.whatwg.org/#list-iterate) _request_ of _queue_:
   1. If _request_ is **grantable**, then run these steps:
      1. [Remove](https://infra.spec.whatwg.org/#list-remove) _request_ from _queue_.
      1. Let _agent_ be _request_'s **agent**
      1. Let _name_ be _request_'s **name**.
      1. Let _mode_ be _request_'s **mode**.
      1. Let _p_ be _request_'s **promise**.
      1. Let _waiting_ be a new Promise.
      1. Let _lock_ be a new **lock** with **agent** _agent_, **origin** _origin_, **mode** _mode_, **name** _name_, **released promise** _p_, and **waiting promise** _waiting_.
      1. [Append](https://infra.spec.whatwg.org/#set-append) _lock_ to _origin_'s **held lock set**.
      1. Let _r_ be the result of invoking _callback_ with a new `Lock` object associated with _lock_ as the only argument. (Note that _r_ may be a regular completion, an abrupt completion, or an unresolved Promise.)
      1. Resolve _waiting_ with _r_.

### Algorithm: Snapshot the lock state

To **snapshot the lock state** for _origin_ with _promise_:

1. [Assert](https://infra.spec.whatwg.org/#assert): these steps are running on the **lock task queue**.
1. Let _pending_ be a new [list](https://infra.spec.whatwg.org/#list).
1. [For each](https://infra.spec.whatwg.org/#list-iterate) _request_ of _origin_'s **lock request queue**:
    1. Let _info_ be a new `LockInfo` dictionary.
    1. Set _info_'s `name` dictionary member to _request_'s **name**.
    1. Set _info_'s `mode` dictionary member to _request_'s **mode**.
    1. [Append](https://infra.spec.whatwg.org/#list-append) _info_ to _pending_.
1. Let _held_ be a new [list](https://infra.spec.whatwg.org/#list).
1. [For each](https://infra.spec.whatwg.org/#list-iterate) _lock_ of _origin_'s **held lock set**:
    1. Let _info_ be a new `LockInfo` dictionary.
    1. Set _info_'s `name` dictionary member to _lock_'s **name**.
    1. Set _info_'s `mode` dictionary member to _lock_'s **mode**.
    1. [Append](https://infra.spec.whatwg.org/#list-append) _info_ to _held_.
1. Let _snapshot_ be a new `LockManagerSnapshot` dictionary.
1. Set _snapshot_'s `held` dictionary member to _held_.
1. Set _snapshot_'s `pending` dictionary member to _pending_.
1. Resolve _promise_ with _snapshot_.
