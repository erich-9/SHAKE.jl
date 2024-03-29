# SHAKE

[![Build Status](https://github.com/erich-9/SHAKE.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/erich-9/SHAKE.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/erich-9/SHAKE.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/erich-9/SHAKE.jl)
[![Aqua](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)

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

Loading the package will export `shake128_xof` and `shake256_xof` as well as `shake128` and `shake256` and finally also `SHAKE128RNG` and `SHAKE256RNG`:

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

The random byte generators `SHAKE128RNG` and `SHAKE256RNG` subtype `AbstractRNG` and can be used as follows:

```jl
rng = SHAKE128RNG(b"Hash me!")

some_random_bytes = rand(rng, UInt8, 47)
more_random_bytes = rand(rng, UInt8, 11)
```

For convenience, there also are `shake128` and `shake256`, which compute an output of a specified, fixed length:

```jl
shake128(b"Hash me!", 32)
```
