//
// Common
//

enum FlagMode { "shared", "exclusive" };

dictionary FlagOptions {
  AbortSignal signal;
};

// ======================================================================
// Proposal 1 - Auto-Release with waitUntil()
//

partial interface WindowOrWorkerGlobalScope {
  Promise<Flag> requestFlag((DOMString or sequence<DOMString>) scope, 
                            FlagMode mode,
                            optional FlagOptions options);
};

[Exposed=(Window,Worker)]
interface Flag {
  readonly attribute FrozenArray<DOMString> scope;
  readonly attribute FlagMode mode;
  readonly attribute Promise<void> released;

  void waitUntil(Promise<any> p);
};

// ======================================================================
// Proposal 2 - Explicit Release
//

partial interface WindowOrWorkerGlobalScope {
  Promise<Flag> requestFlag((DOMString or sequence<DOMString>) scope,
                            FlagMode mode,
                            optional FlagOptions options);
};

[Exposed=(Window,Worker)]
interface Flag {
  readonly attribute FrozenArray<DOMString> scope;
  readonly attribute FlagMode mode;
  readonly attribute Promise<void> released;

  void release();
};

// ======================================================================
// Proposal 3 - Scoped Release
//

callback FlagRequestCallback = Promise<any> (Flag flag);

partial interface WindowOrWorkerGlobalScope {
  Promise<any> requestFlag((DOMString or sequence<DOMString>) scope, 
                           FlagMode mode,
                           FlagRequestCallback callback,
                           optional FlagOptions options);
};

[Exposed=(Window,Worker)]
interface Flag {
  readonly attribute FrozenArray<DOMString> scope;
  readonly attribute FlagMode mode;
  readonly attribute Promise<void> released;
};
