## Since 0.12

Swapped to native LSP and treesitter configs. `queries/` files were extracted from
nvim-treesitter's main branch before archive.

`parser/` files built by cloning the repo and running `tree-sitter build`.
On Linux this makes a `.so`. On Mac: `.dylib`. Copy these to the `parser/` folder
named after the nvim filetype

Currently-used parsers:

Go: https://github.com/alienvspredator/tree-sitter-go/releases/tag/v0.27.0
Gomod: https://github.com/camdencheeck/tree-sitter-go-mod

