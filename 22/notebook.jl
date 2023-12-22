### A Pluto.jl notebook ###
# v0.19.36

using Markdown
using InteractiveUtils

# ╔═╡ 2cf9da12-d180-4d3a-8796-3e6a50650c6a
using Graphs, DataStructures, Base.Iterators

# ╔═╡ cd255d96-a08d-11ee-3206-596160d7f6ad
input = "input" |> readlines 

# ╔═╡ d0882c0d-6788-4b13-8488-82fa9650d78c
begin
	struct Brick{T<:AbstractVector}
		x::T; y::T; z::T
	end
	Brick(; x::T, y::T, z::T) where {T} = Brick{T}(x,y,z)
	function Brick(y::Brick; args...) 
		names = fieldnames(Brick)
		Brick(; (names .=> getfield.((y,), names))..., args...)
	end
	for field ∈ fieldnames(Brick)
		@eval $(field)(a::Brick) = getfield(a, Symbol($field))
	end
end

# ╔═╡ ca2bb9a9-15e4-4e68-a877-bdfdc1a5bc48
fields(a::Brick) = getfield.((a,), fieldnames(Brick))

# ╔═╡ e78a4239-eab0-4c89-91a3-2cc23a3bd239
begin
	Base.:+(a::Brick, b::CartesianIndex{3}) = 
		Brick(a.x .+ b[1], a.y .+ b[2], a.z .+ b[3])
	Base.:+(a::CartesianIndex{3}, b::Brick) = +(b, a)
	Base.isdisjoint(a::Brick, b::Brick) = any(isdisjoint.(fields.((a,b))...))
	project(a::Brick, b::Symbol) = Brick(a; b=>1:1)
end

# ╔═╡ d075a36c-6356-4cdc-adc3-a0eaf9e72fcf
function parse_bricks(input)
	bricks = Vector{Brick{UnitRange{Int}}}(undef, length(input)) 
	for (i, line) ∈ enumerate(input)
		l, r = split(line, '~') .|> x->split(x, ',') |> x->parse.(Int, x)
		bricks[i] = Brick(range.(l, r)...)
	end
	bricks
end

# ╔═╡ 47afb513-c8f0-42b0-89cf-806d049e7624
function drop_bricks!(bricks::Vector{<:Brick})
	sort!(bricks; by=b->last(b.z))
	
	down = CartesianIndex(0,0,-1)
	b_stack = DefaultDict{NTuple{2, Int}, Int}(zero(Int))

	for (i, brick) ∈ enumerate(bricks)
		zpos = maximum(b_stack[idx] for idx ∈ product(x(brick), y(brick)))
		brick += (first(z(brick)) - zpos - 1) * down
		
		setindex!.((b_stack,), last(z(brick)), product(x(brick), y(brick)))
		bricks[i] = brick
	end
	sort!(bricks; by=b->last(b.z))
end

# ╔═╡ 0d2b8c37-93a8-4f40-8d2f-d7df2cdabcee
function build_graph(bricks::Vector{<:Brick})
	bricks = sort(bricks; by=last∘z)

	T = NTuple{2, Int}
	b_stack = DefaultDict{T, T}((0,0))

	g = SimpleDiGraph(length(bricks))

	for (i, brick) ∈ enumerate(bricks)

		zpos = maximum(first(b_stack[idx]) for idx ∈ product(x(brick), y(brick)))

		for idx ∈ product(x(brick), y(brick))
			if first(b_stack[idx]) == zpos
				add_edge!(g, last(b_stack[idx]), i)
			end
		end
		
		zpos += z(brick) |> length
				
		setindex!.((b_stack,), ((zpos, i),), product(x(brick), y(brick)))
	end
	g
end

# ╔═╡ 3ca1efe5-cefc-48d7-b91d-e0c10afe7363
function count_removable(g::DiGraph)
	count = 0
	for v ∈ vertices(g)
		n = outneighbors(g, v)
		all(length.(inneighbors.((g,), n)) .> 1) && (count += 1)
	end
	count
end

# ╔═╡ e61a84e5-b6af-4877-b7ff-9e584fe1f089
input |> parse_bricks |> build_graph |> count_removable

# ╔═╡ c840433f-3caa-4997-8de5-5ed8191b8f68
md"## Part II"

# ╔═╡ 45d613ac-93ec-4bb7-aee9-0dbece94c9d2
function count_falling(g::DiGraph{T}, v::T) where {T}
	Q = Queue{T}()
	enqueue!.((Q,), outneighbors(g, v))
	falling = Set{Int}(v)
	
	while !isempty(Q)
		v = dequeue!(Q)
		inneighbors(g, v) ⊈ falling && continue
		
		push!(falling, v)
		enqueue!.((Q,), outneighbors(g, v))
	end
	length(falling) - 1
end

# ╔═╡ b415e0ee-4c96-4110-9050-07d4afcc7756
g = input |> parse_bricks |> build_graph

# ╔═╡ de7b5beb-2845-4e5b-9a60-cee570efa431
mapreduce(+, vertices(g)) do v
	count_falling(g, v)
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DataStructures = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
Graphs = "86223c79-3864-5bf0-83f7-82e725a168b6"

[compat]
DataStructures = "~0.18.15"
Graphs = "~1.9.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.4"
manifest_format = "2.0"
project_hash = "7f66f5076c1b79c789c059c40e710c568a536d73"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.ArnoldiMethod]]
deps = ["LinearAlgebra", "Random", "StaticArrays"]
git-tree-sha1 = "62e51b39331de8911e4a7ff6f5aaf38a5f4cc0ae"
uuid = "ec485272-7323-5ecc-a04f-4719b315124d"
version = "0.2.0"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Compat]]
deps = ["UUIDs"]
git-tree-sha1 = "886826d76ea9e72b35fcd000e535588f7b60f21d"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.10.1"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.5+0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3dbd312d370723b6bb43ba9d02fc36abade4518d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.15"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.Graphs]]
deps = ["ArnoldiMethod", "Compat", "DataStructures", "Distributed", "Inflate", "LinearAlgebra", "Random", "SharedArrays", "SimpleTraits", "SparseArrays", "Statistics"]
git-tree-sha1 = "899050ace26649433ef1af25bc17a815b3db52b7"
uuid = "86223c79-3864-5bf0-83f7-82e725a168b6"
version = "1.9.0"

[[deps.Inflate]]
git-tree-sha1 = "ea8031dea4aff6bd41f1df8f2fdfb25b33626381"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.4"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.4.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "9ee1618cbf5240e6d4e0371d6f24065083f60c48"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.11"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.10.11"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.21+4"

[[deps.OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.9.2"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "03b4c25b43cb84cee5c90aa9b5ea0a78fd848d2f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.0"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00805cd429dcb4870060ff49ef443486c262e38e"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.1"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[deps.SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "PrecompileTools", "Random", "StaticArraysCore"]
git-tree-sha1 = "2aded4182a14b19e9b62b063c0ab561809b5af2c"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.8.0"

    [deps.StaticArrays.extensions]
    StaticArraysChainRulesCoreExt = "ChainRulesCore"
    StaticArraysStatisticsExt = "Statistics"

    [deps.StaticArrays.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StaticArraysCore]]
git-tree-sha1 = "36b3d696ce6366023a0ea192b4cd442268995a0d"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.2"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.9.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "Pkg", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "5.10.1+6"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.52.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"
"""

# ╔═╡ Cell order:
# ╠═2cf9da12-d180-4d3a-8796-3e6a50650c6a
# ╠═cd255d96-a08d-11ee-3206-596160d7f6ad
# ╠═d0882c0d-6788-4b13-8488-82fa9650d78c
# ╠═ca2bb9a9-15e4-4e68-a877-bdfdc1a5bc48
# ╠═e78a4239-eab0-4c89-91a3-2cc23a3bd239
# ╠═d075a36c-6356-4cdc-adc3-a0eaf9e72fcf
# ╠═47afb513-c8f0-42b0-89cf-806d049e7624
# ╠═0d2b8c37-93a8-4f40-8d2f-d7df2cdabcee
# ╠═3ca1efe5-cefc-48d7-b91d-e0c10afe7363
# ╠═e61a84e5-b6af-4877-b7ff-9e584fe1f089
# ╟─c840433f-3caa-4997-8de5-5ed8191b8f68
# ╠═45d613ac-93ec-4bb7-aee9-0dbece94c9d2
# ╠═b415e0ee-4c96-4110-9050-07d4afcc7756
# ╠═de7b5beb-2845-4e5b-9a60-cee570efa431
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
