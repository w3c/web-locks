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
  Promise<any> acquire(DOMString name,
                       LockRequestCallback callback);
  Promise<any> acquire(DOMString name,
                       optional LockOptions options,
                       LockRequestCallback callback);

  Promise<LockState> queryState();
  void forceRelease(DOMString name);
};

callback LockRequestCallback = Promise<any> (Lock lock);

dictionary LockOptions {
  LockMode mode = "exclusive";
  boolean ifAvailable = false;
  AbortSignal signal;
};

enum LockMode { "shared", "exclusive" };

[SecureContext, Exposed=(Window,Worker)]
interface Lock {
  readonly attribute DOMString name;
  readonly attribute LockMode mode;
};

dictionary LockState {
  held sequence<LockRequest>;
  pending sequence<LockRequest>;
};

dictionary LockRequest {
  DOMString name;
  LockMode mode;
};
