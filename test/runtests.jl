using Base.Iterators: drop, take
using SHAKE
using Test

extract(it, first, count) = collect(take(drop(it, first - 1), count))

@testset "SHAKE.jl" begin
    @test shake128(b"", 15) == hex2bytes("7f9c2ba4e88f827d61604550760585")
    @test shake256(b"", 15) == hex2bytes("46b9dd2b0ba88d13233b3feb743eeb")

    @test extract(shake128_xof(b""), 10_000, 15) == hex2bytes("d685d34876d1b94077236f3eaa9339")
    @test extract(shake256_xof(b""), 10_000, 15) == hex2bytes("fb9f61d36cc42fbc919e6c09bf9226")
end