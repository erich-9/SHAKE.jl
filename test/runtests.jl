using Base.Iterators: drop, take
using SHAKE
using Test

extract(it, first, length) = collect(take(drop(it, first - 1), length))

@testset "SHAKE.jl" begin
    @test shake128(b"", 15) == hex2bytes("7f9c2ba4e88f827d61604550760585")
    @test shake256(b"", 15) == hex2bytes("46b9dd2b0ba88d13233b3feb743eeb")

    @test extract(shake128_xof(b""), 10_000, 10) == hex2bytes("d685d34876d1b9407723")
    @test extract(shake256_xof(b""), 10_000, 10) == hex2bytes("fb9f61d36cc42fbc919e")

    @test extract(shake128_xof(zeros(UInt8, 167)), 10_000, 5) == hex2bytes("a603dfab23")
end
