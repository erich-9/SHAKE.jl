module SHAKE

export shake128, shake256, shake128_xof, shake256_xof

import SHA:
    blocklen,
    digestlen,
    update!,
    AbstractBytes,
    L64,
    SHA3_CTX,
    SHA3_PILN,
    SHA3_ROTC,
    SHA3_ROUND_CONSTS

abstract type SHAKE_CTX <: SHA3_CTX end
abstract type SHAKE_XOF end

for n ∈ (128, 256)
    d = UInt64(n >> 3)
    b = UInt64(25 << 3 - 2 * d)

    CTX = Symbol(:SHAKE_, n, :_CTX)

    xof_truncated = Symbol(:shake, n)
    xof = Symbol(xof_truncated, :_xof)

    @eval begin
        Base.@kwdef mutable struct $CTX <: SHAKE_CTX
            state::Vector{UInt64} = zeros(UInt64, 25)
            bytecount::UInt128 = 0
            buffer::Vector{UInt8} = zeros(UInt8, $b)
            bc::Vector{UInt64} = Vector{UInt64}(undef, 5)
            used::Bool = false
        end

        digestlen(::Type{$CTX}) = $d
        blocklen(::Type{$CTX}) = $b

        struct $xof <: SHAKE_XOF
            data::Vector{UInt8}
        end

        shake_ctx(::Type{$xof}) = $CTX

        $xof_truncated(data::AbstractBytes, length::Integer) =
            collect(UInt8, Iterators.take($xof(data), length))
    end
end

Base.eltype(::Type{T}) where {T <: SHAKE_XOF} = UInt8
Base.IteratorSize(::Type{T}) where {T <: SHAKE_XOF} = Base.IsInfinite()

function Base.iterate(shake_xof::T) where {T <: SHAKE_XOF}
    context = shake_ctx(T)()
    update!(context, shake_xof.data)
    init_buffer!(context)
    update_state_with_buffer!(context)
    Base.iterate(shake_xof, (1, context))
end

function Base.iterate(::T, state) where {T <: SHAKE_XOF}
    (i, context) = state
    p = (i - 1) % blocklen(shake_ctx(T))
    if p == 0
        permute_blocks!(context)
    end
    (reinterpret(UInt8, context.state)[p + 1], (i + 1, context))
end

# extracted verbatim from digest! in JuliaCrypto/SHA.jl/src/shake.jl
function init_buffer!(context::T) where {T <: SHAKE_CTX}
    usedspace = context.bytecount % blocklen(T)
    if usedspace < blocklen(T) - 1
        context.buffer[usedspace + 1] = 0x1f
        context.buffer[(usedspace + 2):(end - 1)] .= 0x00
        context.buffer[end] = 0x80
    else
        context.buffer[end] = 0x9f
    end
end

# extracted verbatim from transform! in stdlib/v1.10/SHA/src/sha3.jl
function update_state_with_buffer!(context::T) where {T <: SHAKE_CTX}
    pbuf = Ptr{eltype(context.state)}(pointer(context.buffer))
    for idx ∈ 1:div(blocklen(T), 8)
        context.state[idx] = context.state[idx] ⊻ unsafe_load(pbuf, idx)
    end
end

# extracted verbatim from transform! in stdlib/v1.10/SHA/src/sha3.jl
function permute_blocks!(context::T) where {T <: SHAKE_CTX}
    bc = context.bc
    state = context.state

    # We always assume 24 rounds
    @inbounds for round ∈ 0:23
        # Theta function
        for i ∈ 1:5
            bc[i] = state[i] ⊻ state[i + 5] ⊻ state[i + 10] ⊻ state[i + 15] ⊻ state[i + 20]
        end

        for i ∈ 0:4
            temp = bc[rem(i + 4, 5) + 1] ⊻ L64(1, bc[rem(i + 1, 5) + 1])
            j = 0
            while j <= 20
                state[Int(i + j + 1)] = state[i + j + 1] ⊻ temp
                j += 5
            end
        end

        # Rho Pi
        temp = state[2]
        for i ∈ 1:24
            j = SHA3_PILN[i]
            bc[1] = state[j]
            state[j] = L64(SHA3_ROTC[i], temp)
            temp = bc[1]
        end

        # Chi
        j = 0
        while j <= 20
            for i ∈ 1:5
                bc[i] = state[i + j]
            end
            for i ∈ 0:4
                state[j + i + 1] =
                    state[j + i + 1] ⊻ (~bc[rem(i + 1, 5) + 1] & bc[rem(i + 2, 5) + 1])
            end
            j += 5
        end

        # Iota
        state[1] = state[1] ⊻ SHA3_ROUND_CONSTS[round + 1]
    end
end

end # module
