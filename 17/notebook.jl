### A Pluto.jl notebook ###
# v0.19.36

using Markdown
using InteractiveUtils

# ╔═╡ 353f9142-9cf3-11ee-2361-a9ff9b2a57d3
using DataStructures, JuliaSyntax

# ╔═╡ 363d475a-d069-4daf-8bcb-530ac44537d8
input = readlines("input") |> stack .|> x->Base.parse(Int, x);

# ╔═╡ 9609406a-f74b-439b-9e19-0595667fab10
from = Dict(:north=>1, :east=>2, :south=>3, :west=>4)

# ╔═╡ 618e6eba-8267-4b1e-901c-5e7c5b6aa146
nextdir = begin
	tmp = Dict(:south=>[:east, :west], :west=>[:north, :south])
	tmp[:north] = tmp[:south]
	tmp[:east] = tmp[:west]

	Dict(getindex.((from,), keys(tmp)) .=> values(tmp))
end

# ╔═╡ 539ab110-b90f-4183-a1d8-50b74ba86436
inout = Dict(:north => :south, :south=>:north, :east => :west, :west => :east)

# ╔═╡ be96a6b4-f2cb-44cd-954a-a44d6fe75b96
begin 
	move(s, c) = move(Val(s), c)
	move(::Val{:north}, c) = (c[1], c[2]-1)
	move(::Val{:south}, c) = (c[1], c[2]+1)
	move(::Val{:west}, c) = (c[1]-1, c[2])
	move(::Val{:east}, c) = (c[1]+1, c[2])
end

# ╔═╡ 6bb2380b-9cd5-4f9c-b846-cd34d460a646
function traverse(weights, stepmin=1, stepmax=3,
	start=(1,1), stop=CartesianIndices(weights)[end] |> Tuple)

	tiles = Array{Int}(undef, size(weights)..., length(from))
	tiles .= typemax(Int)

	candidates = Set{NTuple{3, Int}}()
		
	for dir ∈ [:east, :south]
		idx = (start..., from[dir]) 
		tiles[idx...] = 0
		push!(candidates, idx)
	end
	
	while !isempty(candidates)

		idx = argmin(x->getindex(tiles, x...), candidates)
		delete!(candidates, idx)

		idx[1:2] == stop && break
		
		for dir ∈ nextdir[idx[3]]
			
			n_idx = idx[1:2]
			n_weight = tiles[idx...]
			
			for step ∈ 1:stepmax
				n_idx = move(dir, n_idx)

				CartesianIndex(n_idx) ∉ CartesianIndices(input) && break

				n_weight += input[n_idx...]

				step < stepmin && continue

				c_idx = (n_idx..., from[inout[dir]])
				
				if n_weight < tiles[c_idx...]
					
					push!(candidates, c_idx)

					tiles[c_idx...] = n_weight
				end
			end
		end
	end
	minimum(tiles; dims=3)
end

# ╔═╡ 3a868047-1926-4702-b005-45bd70c3b592
tiles = traverse(input)[end]

# ╔═╡ 89661773-fc1e-4595-bc2f-edbb38e3b437
md"## Part II"

# ╔═╡ 6efac552-590a-4dc7-882c-1fc0bbab6125
tiles2 = traverse(input, 4, 10)[end]

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DataStructures = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
JuliaSyntax = "70703baa-626e-46a2-a12c-08ffd08c73b4"

[compat]
DataStructures = "~0.18.15"
JuliaSyntax = "~0.4.8"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.4"
manifest_format = "2.0"
project_hash = "d5b46e017a3ae258b4ef20ecbdb6e71d033a4a16"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Compat]]
deps = ["UUIDs"]
git-tree-sha1 = "886826d76ea9e72b35fcd000e535588f7b60f21d"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.10.1"

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

    [deps.Compat.weakdeps]
    Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
    LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3dbd312d370723b6bb43ba9d02fc36abade4518d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.15"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.JuliaSyntax]]
git-tree-sha1 = "e00e2b013f3bd98d3789f889b9305c1546ecd1ab"
uuid = "70703baa-626e-46a2-a12c-08ffd08c73b4"
version = "0.4.8"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
"""

# ╔═╡ Cell order:
# ╠═353f9142-9cf3-11ee-2361-a9ff9b2a57d3
# ╠═363d475a-d069-4daf-8bcb-530ac44537d8
# ╠═9609406a-f74b-439b-9e19-0595667fab10
# ╠═618e6eba-8267-4b1e-901c-5e7c5b6aa146
# ╠═539ab110-b90f-4183-a1d8-50b74ba86436
# ╠═be96a6b4-f2cb-44cd-954a-a44d6fe75b96
# ╠═6bb2380b-9cd5-4f9c-b846-cd34d460a646
# ╠═3a868047-1926-4702-b005-45bd70c3b592
# ╠═89661773-fc1e-4595-bc2f-edbb38e3b437
# ╠═6efac552-590a-4dc7-882c-1fc0bbab6125
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
