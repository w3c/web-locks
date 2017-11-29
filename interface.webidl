[SecureContext, Exposed=Window] 
partial interface Navigator {
  readonly attribute LockManager locks;
};
[SecureContext, Exposed=Worker] 
partial interface WorkerNavigator {
  readonly attribute LockManager locks;
};

[SecureContext]
interface LockManager {
  Promise<any> acquire(LockScope scope,
                       LockRequestCallback callback);
  Promise<any> acquire(LockScope scope,
                       optional LockOptions options,
                       LockRequestCallback callback);

  Promise<LockState> queryState();
  void forceRelease((DOMString or sequence<DOMString>) scope);
};

typedef (DOMString or sequence<DOMString>) LockScope;

callback LockRequestCallback = Promise<any> (Lock lock);

dictionary LockOptions {
  LockMode mode = "exclusive";
  boolean ifAvailable = false;
  AbortSignal signal;
};

enum LockMode { "shared", "exclusive" };

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
