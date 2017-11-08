partial interface Navigator {
  [SecureContext] readonly attribute LockManager locks;
};

[SecureContext]
interface LockManager {
  Promise<any> acquire((DOMString or sequence<DOMString>) scope,
                       LockRequestCallback callback,
                       optional LockOptions options);

  Promise<LockState> queryState();
  void forceRelease((DOMString or sequence<DOMString>) scope);
};

callback LockRequestCallback = Promise<any> (Lock lock);

enum LockMode { "shared", "exclusive" };

dictionary LockOptions {
  LockMode mode = "exclusive";
  boolean ifAvailable = false;
  AbortSignal signal;
};

[SecureContext, Exposed=(Window,Worker)]
interface Lock {
  readonly attribute FrozenArray<DOMString> scope;
  readonly attribute LockMode mode;
};

dictionary LockState {
  held sequence<LockRequest>;
  pending sequence<LockRequest>;
};

dictionary LockRequest {
  sequence<DOMString> scope;
  LockMode mode;
};
