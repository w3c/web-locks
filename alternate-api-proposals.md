
## Alternate API Proposals

Alternate 1: Auto-Releasing with waitUntil():
```js
async function get_lock_then_write() {
  const lock = await requestLock('resource');
  lock.waitUntil(async_write_func());
}

async function get_lock_then_read() {
  const lock = await requestLock('resource', {mode: 'shared'});
  lock.waitUntil(async_read_func());
}
```

Alternate 2: Explicit release:
```js
async function get_lock_then_write() {
  const lock = await requestLock('resource');
  await async_write_func();
  lock.release();
}

async function get_lock_then_read() {
  const lock = await requestLock('resource', {mode: 'shared'});
  await async_read_func();
  lock.release();
}
```


* The auto-release approach mirrors [Indexed DB's auto-committing transaction](https://w3c.github.io/IndexedDB/#transaction-construct) model where explicit action is needed to hold a resource, combined with [Service Worker's ExtendableEvent](https://w3c.github.io/ServiceWorker/#extendableevent-interface) `waitUntil()` method to allow promises to control the lifetime.
* The explicit release model requires callers to always call the `release()` method, e.g. even if an exception is thrown.

In the auto-release approach, a lock will automatically be released by a subsequent microtask if `waitUntil(p)` is not called with a promise to extend its lifetime within the callback from the initial acquisition promise.

In the auto-release and explicit release approaches the method returns a promise that resolves with a lock, or rejects if the request was aborted.


## FAQ

*Can you implement explicit release in terms of auto-release?*
```js
async function requestExplicitLock(...args) {
  const lock = await requestLock(...args);
  lock.waitUntil(new Promise(resolve => { lock.release = resolve; }));
  return lock;
}
```

*Can you implement auto-release in terms of explicit-release?*
```js
function Extendable() {
  let resolve, reject;
  const promise = new Promise((res, rej) => {
    resolve = res;
    reject = rej;
  });

  let ps;
  promise.waitUntil = function(p) {
    ps = ps ? Promise.all([ps, p]) : p;
    const snapshot = ps;
    ps.then(
      () => { if (snapshot === ps) resolve(); },
      err => { if (snapshot === ps) reject(err); }
    );
  };
  return promise;
}

function requestAutoReleaseLock(...args) {
  const lock = await requestLock(...args);
  const ext = Extendable();
  ext.then(() => lock.release(), () => lock.release());
  ext.waitUntil(Promise.resolve().then(() => Promise.resolve().then()));
  lock.waitUntil = ext.waitUntil.bind(ext);
  return lock;
}
```

*Can you implement explicit release in terms of scoped release?*
```js
function requestExplicitLock(scope, ...rest) {
  return new Promise(resolve => {
    requestLock(scope, lock => {
      // p waits until lock.release() is called
      const p = new Promise(r => { lock.release = r; });
      resolve(lock);
      return p;
    }, ...rest);
  });
}
```

*Can you implement scoped release in terms of explict release?*
```js
async function requestScopedLock(scope, callback, ...rest) {
  const lock = await requestLock(scope, ...rest);
  try {
    await callback(lock);
  } finally {
    lock.release();
  }
}
```

*Can you implement...*

Staaahp!
