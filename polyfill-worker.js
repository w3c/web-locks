// Part 2 of a polyfill. See Part 1 for the caveats.
//
// This runs in a SharedWorker and is loaded automatically by part 1.

'use strict';
let requests = [];
let held = new Map();
let counter = 0;

// TODO: handle disconnects!

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
    let id = entry[0], flag = entry[1];
    let set = flag.mode === 'shared' ? shared : exclusive;
    for (let s of flag.scope)
      set.add(s);
  }

  let now = Date.now();

  let i = 0;
  while (i < requests.length) {
    let granted = false;
    let flag = requests[i];

    if (Number.isFinite(flag.timeout) && !flag.expires) {
      flag.expires = now + flag.timeout;
      if (flag.timeout > 0)
        setTimeout(processRequests, flag.timeout);
    }

    if (flag.mode === 'exclusive') {
      if (!intersects(flag.scope, shared) &&
          !intersects(flag.scope, exclusive)) {
        granted = true;
      }
      for (let s of flag.scope)
        exclusive.add(s);
    } else {
      if (!intersects(flag.scope, exclusive))
        granted = true;
      for (let s of flag.scope)
        shared.add(s);
    }

    if (granted) {
      requests.splice(i, 1);
      var id = ++counter;
      held.set(id, flag);
      flag.port.postMessage({
        request_id: flag.request_id,
        timeout: false,
        id: id
      });
    } else if (flag.expires <= now) {
      requests.splice(i, 1);
      flag.port.postMessage({
        request_id: flag.request_id,
        timeout: true
      });
    } else {
      ++i;
    }
  }
}
