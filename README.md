# SHAKE

[![Build Status](https://github.com/erich-9/SHAKE.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/erich-9/SHAKE.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/erich-9/SHAKE.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/erich-9/SHAKE.jl)

Implementation of the [extendable-output functions](https://en.wikipedia.org/wiki/Extendable-output_function) (XOF's) SHAKE128 and SHAKE256 based on the [SHA-3](https://en.wikipedia.org/wiki/SHA-3) implementation in the Julia Standard Library.

## Installation

Install with the Julia package manager [Pkg](https://pkgdocs.julialang.org/), just like any other registered Julia package:

```jl
pkg> add SHAKE  # Press ']' to enter the Pkg REPL mode.
```

or

```jl
julia> using Pkg; Pkg.add("SHAKE")
```

## Usage

Loading the package will export `shake128_xof` and `shake256_xof` as well as `shake128` and `shake256`:

```jl
using SHAKE
```

The methods `shake128_xof` and `shake256_xof` may be used as infinite iterators:

```jl
for (i, b) in enumerate(shake256_xof(b"Hash me!"))
    if iszero(b)
        println("Found first null byte at position $i")
        break
    end
end
```

For convenience, there also are `shake128` and `shake256`, which compute an output of a specified, fixed length:

```jl
shake128(b"Hash me!", 32)
```
