// coc.nvim 0.0.81 runs each extension in a vm context seeded with a lodash
// `defaults(context, global)`, which only copies *enumerable* globals. Node 18+
// made the web globals non-enumerable, so extensions bundling anything that
// touches `URL` die with "ReferenceError: URL is not defined" and silently fail
// to activate. Marking them enumerable puts them back in the sandbox.
// Loaded via `--require` in g:coc_node_args; drop this once coc is unpinned.
for (const name of [
  'URL',
  'URLSearchParams',
  'TextEncoder',
  'TextDecoder',
  'AbortController',
  'AbortSignal',
]) {
  const d = Object.getOwnPropertyDescriptor(globalThis, name)
  if (d && !d.enumerable) {
    Object.defineProperty(globalThis, name, { ...d, enumerable: true })
  }
}
