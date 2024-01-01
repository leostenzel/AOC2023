### A Pluto.jl notebook ###
# v0.19.36

using Markdown
using InteractiveUtils

# ╔═╡ a432be69-e0b3-4c0f-b8fa-9cb80b048776
using Graphs, LinearAlgebra, DataStructures

# ╔═╡ b22ee156-6be6-4e4e-82f3-b95c2e2842ae
using SimpleWeightedGraphs

# ╔═╡ 5f0b554a-a15a-11ee-39a6-8939f2b8ad20
input = "input" |> readlines |> stack

# ╔═╡ 3ac3ada6-22d0-445f-8f4f-5cb4c3908d85
begin
	const east = CartesianIndex(1, 0)
	const west = -east
	const south = CartesianIndex(0, 1)
	const north = -south
	const boundary = CartesianIndices(input)
	const directions = Dict('.' => (north, east, south, west), 
		'>' => (east,), '<' => (west,), 'v' => (south,), '^' => (north,))
end

# ╔═╡ df4c75fe-2da2-49b4-a149-0ad79b81e5b7
begin
	indices = findall(!=('#'), input)
	idx_dict = Dict(idx => i for (i, idx) ∈ enumerate(indices))	
	g = SimpleDiGraph(length(indices))

	for (i, idx) ∈ enumerate(indices)
		for dir ∈ directions[input[idx]]
			next = idx + dir
			next ∉ boundary && continue
			next ∉ keys(idx_dict) && continue
			
			add_edge!(g, i, idx_dict[next])
		end
	end

	start = idx_dict[findfirst(==('.'), input)]
	stop = idx_dict[findlast(==('.'), input)]
	rem_edge!(g, inneighbors(g, start)[], start)
	rem_edge!(g, stop, outneighbors(g, stop)[])
	g
end

# ╔═╡ b16986cb-f683-420c-81ef-5ff70c410b55
function prune!(g::DiGraph)
	for v ∈ vertices(g)
		inn = inneighbors(g, v)
		length(inn) == 1 && rem_edge!(g, v, inn[])
		outn = outneighbors(g, v)
		length(outn) == 1 && rem_edge!(g, outn[], v)
	end
	g
end

# ╔═╡ f347df0c-89c8-4955-a8e9-6c8d0daad5a2
prune(g) = prune!(copy(g))

# ╔═╡ 705a9f1e-ef93-4d84-918e-740248b387c5
md"Cut dead ends till we converge"

# ╔═╡ a06b4015-1e96-435b-979e-870f68b96234
g2 = let
	g = copy(g)
	for _ = 1:ne(g)
		g_prev = g
		g = prune(g)
		ne(g) == ne(g_prev) && break
	end
	g
end

# ╔═╡ 2cb2466b-908e-45b5-998f-399b548bcfd2
-spfa_shortest_paths(g2, 1, -weights(g2))[stop]

# ╔═╡ d3321b6b-a252-4c1b-92fc-a721181d7349
md"## Part II"

# ╔═╡ 7d526ea6-0868-4836-8ad1-523ef11a7e1a
gu = let
	indices = findall(!=('#'), input)
	idx_dict = Dict(idx => i for (i, idx) ∈ enumerate(indices))	
	g = SimpleGraph(length(indices))

	for (i, idx) ∈ enumerate(indices)
		for dir ∈ (north, east, south, west)
			next = idx + dir
			next ∉ boundary && continue
			next ∉ keys(idx_dict) && continue
			
			add_edge!(g, i, idx_dict[next])
		end
	end

	start = idx_dict[findfirst(==('.'), input)]
	stop = idx_dict[findlast(==('.'), input)]
	g
end

# ╔═╡ 87c019ee-6918-4c5f-98b1-54746896aadb
md"Merge line segments of the graph"

# ╔═╡ 68710e9c-ee47-48c9-8fe4-1684d28910fd
wg = let 
	wg = SimpleWeightedGraph{Int, Int}(gu)
	for v ∈ vertices(wg)
		n = neighbors(wg, v)

		length(n) != 2 && continue
		n1, n2 = n
		w = get_weight.((wg,), v, n) |> sum

		rem_edge!(wg, v, n1)	
		rem_edge!(wg, v, n2)			
		add_edge!(wg, n1, n2, w)
	end
	
	for v ∈ reverse(vertices(wg))
		isempty(neighbors(wg, v)) && rem_vertex!(wg, v)
	end
	wg
end

# ╔═╡ 9f16f11c-5e8c-4bce-8ad4-4e43edeb289c
function longest_path(g::SimpleWeightedGraph{T}, 
	start::T=first(vertices(g)), 
	stop::T=last(vertices(g))) where {T}
	
	path = MutableLinkedList{T}()
	s = Stack{Tuple{T,T}}()
	
	push!(s, (start, 0))
	
	visited = falses(stop)
	longest = 0

	while !isempty(s)
		(v, prev) = pop!(s)

		while !isempty(path) && last(path) != prev			
			ṽ = pop!(path)
			visited[ṽ] = false
		end

		push!(path, v)
		visited[v] = true

		if v == stop
			l = sum(get_weight.((g,), path[1:end-1], path[2:end]))
			longest = max(longest, l)
		else
			ns = filter(n->!visited[n], neighbors(g, v))
			for n ∈ ns
				push!(s, (n, v))
			end
		end
	end
	longest
end

# ╔═╡ 2409485b-b594-4e4b-a94f-01446892bd79
longest_path(wg)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DataStructures = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
Graphs = "86223c79-3864-5bf0-83f7-82e725a168b6"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
SimpleWeightedGraphs = "47aef6b3-ad0c-573a-a1e2-d07658019622"

[compat]
DataStructures = "~0.18.15"
Graphs = "~1.9.0"
SimpleWeightedGraphs = "~1.4.0"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.0"
manifest_format = "2.0"
project_hash = "6d240822aaa81af181f2d3ba13803de5bfe7b4d9"

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
version = "1.0.5+1"

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

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "b211c553c199c111d998ecdaf7623d1b89b69f93"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.12"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.23+2"

[[deps.OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

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

[[deps.Random]]
deps = ["SHA"]
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

[[deps.SimpleWeightedGraphs]]
deps = ["Graphs", "LinearAlgebra", "Markdown", "SparseArrays"]
git-tree-sha1 = "4b33e0e081a825dbfaf314decf58fa47e53d6acb"
uuid = "47aef6b3-ad0c-573a-a1e2-d07658019622"
version = "1.4.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.10.0"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "PrecompileTools", "Random", "StaticArraysCore"]
git-tree-sha1 = "fba11dbe2562eecdfcac49a05246af09ee64d055"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.8.1"

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
version = "1.10.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.2.1+1"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+1"
"""

# ╔═╡ Cell order:
# ╠═5f0b554a-a15a-11ee-39a6-8939f2b8ad20
# ╠═a432be69-e0b3-4c0f-b8fa-9cb80b048776
# ╠═3ac3ada6-22d0-445f-8f4f-5cb4c3908d85
# ╠═df4c75fe-2da2-49b4-a149-0ad79b81e5b7
# ╠═f347df0c-89c8-4955-a8e9-6c8d0daad5a2
# ╠═b16986cb-f683-420c-81ef-5ff70c410b55
# ╟─705a9f1e-ef93-4d84-918e-740248b387c5
# ╠═a06b4015-1e96-435b-979e-870f68b96234
# ╠═2cb2466b-908e-45b5-998f-399b548bcfd2
# ╟─d3321b6b-a252-4c1b-92fc-a721181d7349
# ╠═b22ee156-6be6-4e4e-82f3-b95c2e2842ae
# ╠═7d526ea6-0868-4836-8ad1-523ef11a7e1a
# ╟─87c019ee-6918-4c5f-98b1-54746896aadb
# ╠═68710e9c-ee47-48c9-8fe4-1684d28910fd
# ╠═9f16f11c-5e8c-4bce-8ad4-4e43edeb289c
# ╠═2409485b-b594-4e4b-a94f-01446892bd79
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
