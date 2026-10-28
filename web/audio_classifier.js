/* Promise bridge used by dart:js_interop. No microphone or alert requests. */
(() => {
  let worker, ready;
  let sequence = 0;
  const pending = new Map();
  function close(reason = 'Audio worker disposed') {
    if (worker) worker.terminate();
    worker = undefined;
    ready = undefined;
    for (const task of pending.values()) { clearTimeout(task.timer); task.reject(new Error(reason)); }
    pending.clear();
  }
  function request(type, values, timeout) {
    return new Promise((resolve, reject) => {
      const id = ++sequence;
      const timer = setTimeout(() => close('Audio worker deadline exceeded'), timeout);
      pending.set(id, {resolve, reject, timer});
      worker.postMessage({id, type, ...values});
    });
  }
  function initialize() {
    if (ready) return ready;
    worker = new Worker(new URL('audio_classifier_worker.js', document.baseURI));
    worker.onmessage = ({data}) => {
      const task = pending.get(data.id);
      if (!task) return;
      pending.delete(data.id);
      clearTimeout(task.timer);
      if (data.error) task.reject(new Error(data.error));
      else task.resolve(data.scores || true);
    };
    worker.onerror = () => close('Audio worker failed');
    const modelUrl = new URL('assets/assets/models/yamnet.onnx', document.baseURI).href;
    ready = request('initialize', {modelUrl}, 120000).catch(error => { close(); throw error; });
    return ready;
  }
  globalThis.guardianAudioClassifier = {
    initialize,
    classify: async waveform => { await initialize(); return request('classify', {waveform}, 3000); },
    dispose: () => close(),
  };
})();
