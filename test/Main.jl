import Base.Iterators: drop, take
import SHAKE: shake128, shake128_xof, shake256, shake256_xof

extract(it, first, length) = collect(take(drop(it, first - 1), length))

@testset "Main.jl" begin
    for data ∈ [Vector{UInt8}(), b"", "", SubString("")]
        @test shake128(data, 15) == hex2bytes("7f9c2ba4e88f827d61604550760585")
        @test shake256(data, 15) == hex2bytes("46b9dd2b0ba88d13233b3feb743eeb")

        @test extract(shake128_xof(data), 10_000, 10) == hex2bytes("d685d34876d1b9407723")
        @test extract(shake256_xof(data), 10_000, 10) == hex2bytes("fb9f61d36cc42fbc919e")
    end

    @test extract(shake128_xof(zeros(UInt8, 167)), 10_000, 5) == hex2bytes("a603dfab23")
end
