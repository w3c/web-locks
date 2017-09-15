//
// Part 1 of a polyfill with huge caveats:
//
// * Requires [SharedWorker support](http://caniuse.com/#feat=sharedworkers)
// * Doesn't handle disconnections (i.e. a tab holding a flag closing)
//
// This part would be used in a page or worker, and loads the SharedWorker automatically.

(function(global) {
  'use strict';
  let worker = new SharedWorker('polyfill-worker.js'), counter = 0;
  worker.port.start();

  function postAndWaitForResponse(message) {
    return new Promise(resolve => {
      let request_id = ++counter;
      message.request_id = request_id;
      let listener = function(event) {
        if (event.data.request_id !== request_id) return;
        worker.port.removeEventListener(listener);
        var response = event.data;
        delete response.request_id;
        resolve(response);
      };
      worker.port.addEventListener('message', listener);
      worker.port.postMessage(message);
    });
  }

  let secret = Symbol();
  function Flag(s, id, scope, mode, waiting) {
    if (s !== secret) throw TypeError('Illegal constructor');
    this._id = id;
    this._state = 'held';
    this._scope = Object.freeze(scope.sort());
    this._mode = mode;
    this._released_promise = new Promise((resolve, reject) => {
      this._resolve_released_promise = resolve;
      this._reject_released_promise = reject;
    });
    this._addToWaitingPromises(waiting);
  }
  Flag.prototype = {
    get scope() {
      // Returns a frozen array containing the DOMStrings from the
      // associated scope of the flag, in sorted in lexicographic
      // order.
      return this._scope;
    },
    get mode() {
      // Returns a DOMString containing the associated mode of the
      // flag.
      return this._mode;
    },
    get released() {
      // Returns the associated released promise of the flag.
      return this._released_promise;
    },
    waitUntil: function(p) {
      // 1. If waitUntil(p) is called and state is "released", then
      // return Promise.reject(new TypeError)
      if (this._state === 'released')
        return Promise.resolve(new TypeError('Flag is released'));

      // 2. Add p to flag's waiting promise set
      this._addToWaitingPromises(p);

      // 3. Return flag's released promise.
      return this._released_promise;
    },

    _addToWaitingPromises: function(p) {
      p = this._waiting_promises
        ? Promise.all([this._waiting_promises, p])
        : Promise.resolve(p);
      let latest = p.then(
        result => {
          if (latest !== this._latest) return;
          // When every promise in flag's waiting promise set
          // fulfills:

          // 1. set flag's state to "released".
          this._state = 'released';
          worker.port.postMessage({action: 'release', id: this._id});

          // 2. fulfill flag's released promise.
          this._resolve_released_promise();
        },
        reason => {
          if (latest !== this._latest) return;
          // If any promise in flag's waiting promise set rejects:

          // 1. set flag's state to "released".
          this._state = 'released';
          worker.port.postMessage({action: 'release', id: this._id});

          // 2. reject flag's released promise.
          this._reject_released_promise(reason);
        });
      this._latest = latest;
    }
  };

  global.requestFlag = function(scope, mode, options) {
    if (arguments.length < 2) throw TypeError('Expected 2 arguments');

    // 1. Let scope be the set of unique DOMStrings in scope if a
    // sequence was passed, otherwise a set containing just the string
    // passed as scope
    if (typeof scope === 'object' && Symbol.iterator in scope)
      scope = Array.from(new Set(Array.from(scope).map(i => String(i))));
    else
      scope = [String(scope)];

    // 2. If scope is empty, return a new Promise rejected with TypeError
    if (scope.length === 0)
      return Promise.reject(TypeError(
        'The "scope" argument must not be empty'));

    // 3. Let mode be the value of mode
    mode = String(mode);
    if (mode !== 'shared' && mode !== 'exclusive')
      throw TypeError('The "mode" argument must be "shared" or "exclusive"');

    // 4. Let timeout be the value of options.timeout if passed, or
    // +∞ otherwise.
    let timeout;
    if (typeof options === 'object' && 'timeout' in options)
      timeout = Math.abs(Math.floor(Number(options.timeout)));
    else
      timeout = Infinity;

    // 5. Return the result of running the request a flag algorithm,
    // passing scope, mode and timeout.

    // Algorithm: request a flag

    // 1. Let p be a new promise
    let p = new Promise((resolve, reject) => {
      // 2. Run the following steps in parallel:
      postAndWaitForResponse({
        action: 'request',
        scope: scope,
        mode: mode,
        timeout: timeout
      }).then(response => {
        // i. - iv. done in worker

        // v. Wait until request is grantable
        if (response.timeout) {
          // c. Reject p with a new TimeoutError
          reject(new DOMException('TimeoutError'));
          // d. Abort any steps running in parallel.
          return;
        }

        // vi: Let waiting be a new promise.
        let resolve_waiting;
        let waiting = new Promise(r => { resolve_waiting = r; });

        // vii. Let flag be a flag with state "held", mode mode, scope
        // scope, and add waiting to flag's waiting promise set.
        let flag = new Flag(secret, response.id, scope, mode, waiting);

        // viii. Remove request from queue
        // (done in worker)

        // ix. Resolve p with a new Flag object associated with flag
        resolve(flag);

        // x. Schedule a microtask to resolve waiting.
        Promise.resolve().then(resolve_waiting);
      });
    });

    // 3. Return p.
    return p;
  };

}(self));
