// Part 2 of a polyfill. See Part 1 for the caveats.
//
// This runs in a SharedWorker and is loaded automatically by part 1.

// TODO: handle disconnects (not currently possible with a SharedWorker)
// TODO: handle abort signals

'use strict';
let requests = [];
let held = new Map();
let counter = 0;

self.addEventListener('connect', e => {
  let port = e.ports[0];
  port.addEventListener('message', e => {
    if (e.data.action === 'request') {
      let request = e.data;
      request.port = port;
      requests.push(request);
      processRequests();
    } else if (e.data.action === 'release') {
      held.delete(e.data.id);
      processRequests();
    }
  });
  port.start();
});

function intersects(iter, set) {
  for (let i of iter)
    if (set.has(i)) return true;
  return false;
}

function processRequests() {
  let shared = new Set();
  let exclusive = new Set();
  for (let entry of held) {
    let id = entry[0], lock = entry[1];
    let set = lock.mode === 'shared' ? shared : exclusive;
    for (let s of lock.scope)
      set.add(s);
  }

  let now = Date.now();

  let i = 0;
  while (i < requests.length) {
    let granted = false;
    let lock = requests[i];

    if (lock.mode === 'exclusive') {
      if (!intersects(lock.scope, shared) &&
          !intersects(lock.scope, exclusive)) {
        granted = true;
      }
      for (let s of lock.scope)
        exclusive.add(s);
    } else {
      if (!intersects(lock.scope, exclusive))
        granted = true;
      for (let s of lock.scope)
        shared.add(s);
    }

    if (granted) {
      requests.splice(i, 1);
      var id = ++counter;
      held.set(id, lock);
      lock.port.postMessage({
        request_id: lock.request_id,
        id: id
      });
    } else {
      ++i;
    }
  }
}
