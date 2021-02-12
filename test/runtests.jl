using PrintTypesTersely
using Test

struct A{T}
end

struct B{C,D}
	data::D
end

const B{C} = B{C, D} where {D}

@testset "PrintTypesTersely.jl" begin

	@testset "testing modes" begin
		PrintTypesTersely.on()
		@test PrintTypesTersely._terseprint[] == true
		PrintTypesTersely.off()
		@test PrintTypesTersely._terseprint[] == false
        PrintTypesTersely.with_state(true) do
			@test PrintTypesTersely._terseprint[] == true
        end
		PrintTypesTersely.with_state(false) do
			@test PrintTypesTersely._terseprint[] == false
        end
    end

    @testset "testing terseprint on" begin
        PrintTypesTersely.with_state(true) do
            @test repr(A{Vector{Int}}) == "A{…}"
            @test repr(A{Union{Int, Missing}}) == "A{…}"
            @test repr(B{Int, Float32}) == "B{…}"
            @test repr(B{Int}) == "B{…}"
            @test repr(DenseMatrix{Int}) == "DenseArray{…}"
            @test repr(StridedVector{Int}) == (VERSION < v"1.6.0-" ?
				"Union{DenseArray{…}, Base.ReinterpretArray{…}, Base.ReshapedArray{…}, SubArray{…}}" :
				"Union{DenseArray{…}, ReinterpretArray{…}, ReshapedArray{…}, SubArray{…}}")
            @test repr(StridedVecOrMat{Int}) == (VERSION < v"1.6.0-" ?
				"Union{DenseArray{…}, DenseArray{…}, Base.ReinterpretArray{…}, Base.ReinterpretArray{…}, Base.ReshapedArray{…}, Base.ReshapedArray{…}, SubArray{…}, SubArray{…}}" :
				"Union{DenseArray{…}, DenseArray{…}, ReinterpretArray{…}, ReinterpretArray{…}, ReshapedArray{…}, ReshapedArray{…}, SubArray{…}, SubArray{…}}")
            @test repr(Union{StridedVector{Int}, Int}) == (VERSION < v"1.6.0-" ?
				"Union{Int64{…}, DenseArray{…}, Base.ReinterpretArray{…}, Base.ReshapedArray{…}, SubArray{…}}" :
				"Union{Int64{…}, DenseArray{…}, ReinterpretArray{…}, ReshapedArray{…}, SubArray{…}}")
            @test repr(UnionAll(TypeVar(:T,Integer), Array)) == "Array{…}"
            @test repr(Union{StridedMatrix{Int}, StridedArray{Int,3}}) == (VERSION < v"1.6.0-" ?
				"Union{DenseArray{…}, DenseArray{…}, Base.ReinterpretArray{…}, Base.ReinterpretArray{…}, Base.ReshapedArray{…}, Base.ReshapedArray{…}, SubArray{…}, SubArray{…}}" :
				"Union{DenseArray{…}, DenseArray{…}, ReinterpretArray{…}, ReinterpretArray{…}, ReshapedArray{…}, ReshapedArray{…}, SubArray{…}, SubArray{…}}")
			t_ = TypeVar(:_,Integer)
			@test repr(UnionAll(t_, Array{t_})) == "Array{…}"
		    u_ = TypeVar(:_,Complex)
			@test repr(UnionAll(u_, Array{UnionAll(t_, Array{t_, u_})})) == "Array{…}"
        end
    end

    @testset "testing terseprint off" begin
        PrintTypesTersely.with_state(false) do
            @test repr(A{Vector{Int}}) == (VERSION < v"1.6.0-" ? "A{Array{Int64,1}}" : "A{Vector{Int64}}")
			@test repr(A{Union{Int, Missing}}) == "A{Union{Missing, Int64}}"
			@test repr(B{Int, Float32}) == (VERSION < v"1.6.0-" ? "B{Int64,Float32}" : "B{Int64, Float32}")
            @test repr(B{Int}) == (VERSION < v"1.6.0-" ? "B{Int64,D} where D" : "B{Int64, D} where D")
            @test repr(DenseMatrix{Int}) == (VERSION < v"1.6.0-" ? "DenseArray{Int64,2}" : "DenseMatrix{Int64}")
            @test repr(StridedVector{Int}) == (VERSION < v"1.6.0-" ? "StridedArray{Int64, 1}" : "StridedVector{Int64}")
            @test repr(StridedVecOrMat{Int}) == "StridedVecOrMat{Int64}"
			expected_1_3 = "Union{Int64, DenseArray{Int64,1}, Base.ReinterpretArray{Int64,1,S,A} where S where A<:Union{SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray}, Base.ReshapedArray{Int64,1,A,MI} where MI<:Tuple{Vararg{Base.MultiplicativeInverses.SignedMultiplicativeInverse{Int64},N} where N} where A<:Union{Base.ReinterpretArray{T,N,S,A} where S where A<:Union{SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray} where N where T, SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray}, SubArray{Int64,1,A,I,L} where L where I<:Tuple{Vararg{Union{Int64, AbstractRange{Int64}, Base.AbstractCartesianIndex},N} where N} where A<:Union{Base.ReinterpretArray{T,N,S,A} where S where A<:Union{SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray} where N where T, Base.ReshapedArray{T,N,A,MI} where MI<:Tuple{Vararg{Base.MultiplicativeInverses.SignedMultiplicativeInverse{Int64},N} where N} where A<:Union{Base.ReinterpretArray{T,N,S,A} where S where A<:Union{SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray} where N where T, SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray} where N where T, DenseArray}}"
			expected_1_4 = "Union{Int64, DenseArray{Int64,1}, Base.ReinterpretArray{Int64,1,S,A} where S where A<:Union{SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray}, Base.ReshapedArray{Int64,1,A,MI} where MI<:Tuple{Vararg{Base.MultiplicativeInverses.SignedMultiplicativeInverse{Int64},N} where N} where A<:Union{Base.ReinterpretArray{T,N,S,A} where S where A<:Union{SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray} where N where T, SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray}, SubArray{Int64,1,A,I,L} where L where I<:Tuple{Vararg{Union{Int64, AbstractRange{Int64}, Base.AbstractCartesianIndex},N} where N} where A<:Union{Base.ReinterpretArray{T,N,S,A} where S where A<:Union{SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray} where N where T, Base.ReshapedArray{T,N,A,MI} where MI<:Tuple{Vararg{Base.MultiplicativeInverses.SignedMultiplicativeInverse{Int64},N} where N} where A<:Union{Base.ReinterpretArray{T,N,S,A} where S where A<:Union{SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray} where N where T, SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray} where N where T, DenseArray}}"
			expected_1_5 = "Union{Int64, DenseArray{Int64,1}, Base.ReinterpretArray{Int64,1,S,A} where S where A<:Union{SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray}, Base.ReshapedArray{Int64,1,A,MI} where MI<:Tuple{Vararg{Base.MultiplicativeInverses.SignedMultiplicativeInverse{Int64},N} where N} where A<:Union{Base.ReinterpretArray{T,N,S,A} where S where A<:Union{SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray} where N where T, SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray}, SubArray{Int64,1,A,I,L} where L where I<:Tuple{Vararg{Union{Int64, AbstractRange{Int64}, Base.AbstractCartesianIndex, Base.ReshapedArray{T,N,A,Tuple{}} where A<:AbstractUnitRange where N where T},N} where N} where A<:Union{Base.ReinterpretArray{T,N,S,A} where S where A<:Union{SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray} where N where T, Base.ReshapedArray{T,N,A,MI} where MI<:Tuple{Vararg{Base.MultiplicativeInverses.SignedMultiplicativeInverse{Int64},N} where N} where A<:Union{Base.ReinterpretArray{T,N,S,A} where S where A<:Union{SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray} where N where T, SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray} where N where T, DenseArray}}"
			expected_1_6 = "Union{Int64, StridedVector{Int64}}"
			expected = VERSION < v"1.6.0-" ? VERSION < v"1.5" ? VERSION < v"1.4" ? expected_1_3 : expected_1_4 : expected_1_5 : expected_1_6
			@test repr(Union{StridedVector{Int}, Int}) == expected
			@test repr(UnionAll(TypeVar(:T,Integer), Array)) == "Array"
			expected_1_3_linux = "Union{StridedArray{Int64, 2}, DenseArray{Int64,3}, Base.ReinterpretArray{Int64,3,S,A} where S where A<:Union{SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray}, Base.ReshapedArray{Int64,3,A,MI} where MI<:Tuple{Vararg{Base.MultiplicativeInverses.SignedMultiplicativeInverse{Int64},N} where N} where A<:Union{Base.ReinterpretArray{T,N,S,A} where S where A<:Union{SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray} where N where T, SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray}, SubArray{Int64,3,A,I,L} where L where I<:Tuple{Vararg{Union{Int64, AbstractRange{Int64}, Base.AbstractCartesianIndex},N} where N} where A<:Union{Base.ReinterpretArray{T,N,S,A} where S where A<:Union{SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray} where N where T, Base.ReshapedArray{T,N,A,MI} where MI<:Tuple{Vararg{Base.MultiplicativeInverses.SignedMultiplicativeInverse{Int64},N} where N} where A<:Union{Base.ReinterpretArray{T,N,S,A} where S where A<:Union{SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray} where N where T, SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray} where N where T, DenseArray}}"
			expected_1_3_win = "Union{StridedArray{Int64, 3}, DenseArray{Int64,2}, Base.ReinterpretArray{Int64,2,S,A} where S where A<:Union{SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray}, Base.ReshapedArray{Int64,2,A,MI} where MI<:Tuple{Vararg{Base.MultiplicativeInverses.SignedMultiplicativeInverse{Int64},N} where N} where A<:Union{Base.ReinterpretArray{T,N,S,A} where S where A<:Union{SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray} where N where T, SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray}, SubArray{Int64,2,A,I,L} where L where I<:Tuple{Vararg{Union{Int64, AbstractRange{Int64}, Base.AbstractCartesianIndex},N} where N} where A<:Union{Base.ReinterpretArray{T,N,S,A} where S where A<:Union{SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray} where N where T, Base.ReshapedArray{T,N,A,MI} where MI<:Tuple{Vararg{Base.MultiplicativeInverses.SignedMultiplicativeInverse{Int64},N} where N} where A<:Union{Base.ReinterpretArray{T,N,S,A} where S where A<:Union{SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray} where N where T, SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray} where N where T, DenseArray}}"
			expected_1_4 = "Union{StridedArray{Int64, 2}, DenseArray{Int64,3}, Base.ReinterpretArray{Int64,3,S,A} where S where A<:Union{SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray}, Base.ReshapedArray{Int64,3,A,MI} where MI<:Tuple{Vararg{Base.MultiplicativeInverses.SignedMultiplicativeInverse{Int64},N} where N} where A<:Union{Base.ReinterpretArray{T,N,S,A} where S where A<:Union{SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray} where N where T, SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray}, SubArray{Int64,3,A,I,L} where L where I<:Tuple{Vararg{Union{Int64, AbstractRange{Int64}, Base.AbstractCartesianIndex},N} where N} where A<:Union{Base.ReinterpretArray{T,N,S,A} where S where A<:Union{SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray} where N where T, Base.ReshapedArray{T,N,A,MI} where MI<:Tuple{Vararg{Base.MultiplicativeInverses.SignedMultiplicativeInverse{Int64},N} where N} where A<:Union{Base.ReinterpretArray{T,N,S,A} where S where A<:Union{SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray} where N where T, SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray} where N where T, DenseArray}}"
			expected_1_5_linux = "Union{StridedArray{Int64, 2}, DenseArray{Int64,3}, Base.ReinterpretArray{Int64,3,S,A} where S where A<:Union{SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray}, Base.ReshapedArray{Int64,3,A,MI} where MI<:Tuple{Vararg{Base.MultiplicativeInverses.SignedMultiplicativeInverse{Int64},N} where N} where A<:Union{Base.ReinterpretArray{T,N,S,A} where S where A<:Union{SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray} where N where T, SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray}, SubArray{Int64,3,A,I,L} where L where I<:Tuple{Vararg{Union{Int64, AbstractRange{Int64}, Base.AbstractCartesianIndex, Base.ReshapedArray{T,N,A,Tuple{}} where A<:AbstractUnitRange where N where T},N} where N} where A<:Union{Base.ReinterpretArray{T,N,S,A} where S where A<:Union{SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray} where N where T, Base.ReshapedArray{T,N,A,MI} where MI<:Tuple{Vararg{Base.MultiplicativeInverses.SignedMultiplicativeInverse{Int64},N} where N} where A<:Union{Base.ReinterpretArray{T,N,S,A} where S where A<:Union{SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray} where N where T, SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray} where N where T, DenseArray}}"
			expected_1_5_win = "Union{StridedArray{Int64, 3}, DenseArray{Int64,2}, Base.ReinterpretArray{Int64,2,S,A} where S where A<:Union{SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray}, Base.ReshapedArray{Int64,2,A,MI} where MI<:Tuple{Vararg{Base.MultiplicativeInverses.SignedMultiplicativeInverse{Int64},N} where N} where A<:Union{Base.ReinterpretArray{T,N,S,A} where S where A<:Union{SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray} where N where T, SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray}, SubArray{Int64,2,A,I,L} where L where I<:Tuple{Vararg{Union{Int64, AbstractRange{Int64}, Base.AbstractCartesianIndex, Base.ReshapedArray{T,N,A,Tuple{}} where A<:AbstractUnitRange where N where T},N} where N} where A<:Union{Base.ReinterpretArray{T,N,S,A} where S where A<:Union{SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray} where N where T, Base.ReshapedArray{T,N,A,MI} where MI<:Tuple{Vararg{Base.MultiplicativeInverses.SignedMultiplicativeInverse{Int64},N} where N} where A<:Union{Base.ReinterpretArray{T,N,S,A} where S where A<:Union{SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray} where N where T, SubArray{T,N,A,I,true} where I<:Union{Tuple{Vararg{Real,N} where N}, Tuple{AbstractUnitRange,Vararg{Any,N} where N}} where A<:DenseArray where N where T, DenseArray} where N where T, DenseArray}}"
			expected_1_6 = "Union{DenseArray{Int64, 3}, Base.ReinterpretArray{Int64, 3, S, A, IsReshaped} where {A<:Union{SubArray{T, N, A, I, true} where {T, N, A<:DenseArray, I<:Union{Tuple{Vararg{Real, N} where N}, Tuple{AbstractUnitRange, Vararg{Any, N} where N}}}, DenseArray}, IsReshaped, S}, Base.ReshapedArray{Int64, 3, A, MI} where {A<:Union{Base.ReinterpretArray{T, N, S, A, IsReshaped} where {T, N, A<:Union{SubArray{T, N, A, I, true} where {T, N, A<:DenseArray, I<:Union{Tuple{Vararg{Real, N} where N}, Tuple{AbstractUnitRange, Vararg{Any, N} where N}}}, DenseArray}, IsReshaped, S}, SubArray{T, N, A, I, true} where {T, N, A<:DenseArray, I<:Union{Tuple{Vararg{Real, N} where N}, Tuple{AbstractUnitRange, Vararg{Any, N} where N}}}, DenseArray}, MI<:Tuple{Vararg{Base.MultiplicativeInverses.SignedMultiplicativeInverse{Int64}, N} where N}}, SubArray{Int64, 3, A, I, L} where {A<:Union{Base.ReinterpretArray{T, N, S, A, IsReshaped} where {T, N, A<:Union{SubArray{T, N, A, I, true} where {T, N, A<:DenseArray, I<:Union{Tuple{Vararg{Real, N} where N}, Tuple{AbstractUnitRange, Vararg{Any, N} where N}}}, DenseArray}, IsReshaped, S}, Base.ReshapedArray{T, N, A, MI} where {T, N, A<:Union{Base.ReinterpretArray{T, N, S, A, IsReshaped} where {T, N, A<:Union{SubArray{T, N, A, I, true} where {T, N, A<:DenseArray, I<:Union{Tuple{Vararg{Real, N} where N}, Tuple{AbstractUnitRange, Vararg{Any, N} where N}}}, DenseArray}, IsReshaped, S}, SubArray{T, N, A, I, true} where {T, N, A<:DenseArray, I<:Union{Tuple{Vararg{Real, N} where N}, Tuple{AbstractUnitRange, Vararg{Any, N} where N}}}, DenseArray}, MI<:Tuple{Vararg{Base.MultiplicativeInverses.SignedMultiplicativeInverse{Int64}, N} where N}}, DenseArray}, I<:Tuple{Vararg{Union{Int64, AbstractRange{Int64}, Base.AbstractCartesianIndex, Base.ReshapedArray{T, N, A, Tuple{}} where {T, N, A<:AbstractUnitRange}}, N} where N}, L}, StridedMatrix{Int64}}"
			expected = VERSION < v"1.6.0-" ? VERSION < v"1.5" ? VERSION < v"1.4" ? Sys.iswindows() ? expected_1_3_win : expected_1_3_linux : expected_1_4 : (Sys.iswindows() ? expected_1_5_win : expected_1_5_linux) : expected_1_6
			@test repr(Union{StridedMatrix{Int}, StridedArray{Int,3}}) == expected
			t_ = TypeVar(:_,Integer)
			@test repr(UnionAll(t_, Array{t_})) == (VERSION < v"1.6.0-" ? "Array{_1,N} where N where _1<:Integer" : "Array{_1, N} where {_1<:Integer, N}")
			u_ = TypeVar(:_,Complex)
			@test repr(UnionAll(u_, Array{UnionAll(t_, Array{t_, u_})})) == (VERSION < v"1.6.0-" ?
				"Array{Array{_2,_1} where _2<:Integer,N} where N where _1<:Complex" :
				"Array{Array{_2, _1} where _2<:Integer, N} where {_1<:Complex, N}")
        end
    end

	# make it run Mill tests only for Julia 1.5 and higher because that's where Mil 2 works
	@static if VERSION >= "1.5.0"
		include("mill_jsongrinder_integration.jl")
	end
end
