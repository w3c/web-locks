//
// Common
//

enum FlagMode { "shared", "exclusive" };

dictionary FlagOptions {
  AbortSignal signal;
};

// [SecureContext] ?
partial interface WindowOrWorkerGlobalScope {
  Promise<Flag> requestFlag((DOMString or sequence<DOMString>) scope, FlagMode mode, optional FlagOptions options);
};

// [SecureContext] ?
[Exposed=(Window,Worker)]
interface Flag {
  readonly attribute FrozenArray<DOMString> scope;
  readonly attribute FlagMode mode;
  readonly attribute Promise<void> released;
  
  // NOTE: Not useful as-is - needs one of the lifecycle proposals (below)
};

//
// Lifecycle Proposal 1: Auto-Releasing w/ waitUntil
//

partial interface Flag {
  void waitUntil(Promise<any> p);
};

//
// Lifecycle Proposal 2: Explicit Release
//

partial interface Flag {
  void release();
};
