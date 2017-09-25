//
// Common
//

enum LockMode { "shared", "exclusive" };

dictionary LockOptions {
  AbortSignal signal;
};

// ======================================================================
// Proposal 1 - Auto-Release with waitUntil()
//

partial interface WindowOrWorkerGlobalScope {
  Promise<Lock> requestLock((DOMString or sequence<DOMString>) scope, 
                            LockMode mode,
                            optional LockOptions options);
};

[Exposed=(Window,Worker)]
interface Lock {
  readonly attribute FrozenArray<DOMString> scope;
  readonly attribute LockMode mode;
  readonly attribute Promise<void> released;

  void waitUntil(Promise<any> p);
};

// ======================================================================
// Proposal 2 - Explicit Release
//

partial interface WindowOrWorkerGlobalScope {
  Promise<Lock> requestLock((DOMString or sequence<DOMString>) scope,
                            LockMode mode,
                            optional LockOptions options);
};

[Exposed=(Window,Worker)]
interface Lock {
  readonly attribute FrozenArray<DOMString> scope;
  readonly attribute LockMode mode;
  readonly attribute Promise<void> released;

  void release();
};

// ======================================================================
// Proposal 3 - Scoped Release
//

callback LockRequestCallback = Promise<any> (Lock lock);

partial interface WindowOrWorkerGlobalScope {
  Promise<any> requestLock((DOMString or sequence<DOMString>) scope, 
                           LockMode mode,
                           LockRequestCallback callback,
                           optional LockOptions options);
};

[Exposed=(Window,Worker)]
interface Lock {
  readonly attribute FrozenArray<DOMString> scope;
  readonly attribute LockMode mode;
  readonly attribute Promise<void> released;
};
