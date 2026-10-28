/* Inference stays off the Flutter UI thread. All assets are same-origin. */
let session;
self.onmessage = async ({data}) => {
  const {id, type} = data;
  try {
    if (type === 'initialize') {
      importScripts('vendor/onnxruntime/ort.wasm.min.js');
      ort.env.wasm.wasmPaths = new URL('vendor/onnxruntime/', self.location.href).href;
      ort.env.wasm.numThreads = 1;
      ort.env.wasm.proxy = false;
      session = await ort.InferenceSession.create(data.modelUrl, {
        executionProviders: ['wasm'], graphOptimizationLevel: 'all',
      });
      const result = await session.run({waveform: new ort.Tensor('float32', new Float32Array(32000), [32000])});
      if (!result[session.outputNames[0]] || result[session.outputNames[0]].dims.at(-1) !== 521) {
        throw new Error('Unexpected YAMNet output');
      }
      self.postMessage({id, ok: true});
    } else if (type === 'classify') {
      if (!session) throw new Error('Model not initialized');
      const waveform = new Float32Array(data.waveform);
      const outputs = await session.run({waveform: new ort.Tensor('float32', waveform, [waveform.length])});
      const scores = outputs[session.outputNames[0]].data;
      const maxima = new Float32Array(521);
      for (let i = 0; i < scores.length; i++) {
        const label = i % 521;
        if (scores[i] > maxima[label]) maxima[label] = scores[i];
      }
      self.postMessage({id, scores: maxima}, [maxima.buffer]);
    } else { throw new Error('Unknown audio worker request'); }
  } catch (error) { self.postMessage({id, error: String(error)}); }
};
