### A Pluto.jl notebook ###
# v0.19.35

using Markdown
using InteractiveUtils

# ╔═╡ 8d693338-c3db-402d-94b9-82cffc8e723a
using DataStructures

# ╔═╡ 52a4c14c-9b15-11ee-3675-7ddfa9ea6186
input = "input" |> readline

# ╔═╡ 966c964b-41c5-4f50-b252-e2433b71d87b
function hash256(s::AbstractString)
	res = 0
	for sᵢ ∈ s
		res += Int(sᵢ)
		res *= 17
		res %= 256 
	end
	res
end

# ╔═╡ 663fe324-3b31-4a2a-b595-726d9d1474f1
hash256.(split(input, ',')) |> sum

# ╔═╡ 6d47c2a0-2cf3-46c4-9f9e-1d6a6742f1a2
md"## Part II"

# ╔═╡ 7d866eb3-f94e-4be7-a0d0-b0d66ddfc8c1
result = let 
	in_split = split(input, ',') .|> x->split(x, ['-', '='], keepempty=false)
	S = OrderedDict{String, Int}
	res = DefaultDict{Int, S}(S)
	for s in in_split
		idx = hash256(s[1])
		
		if length(s) == 1
			delete!(res[idx], s[1])
		else
			res[idx][s[1]] = parse(Int, s[2])
		end
	end
	res
end;		

# ╔═╡ 81b118cb-61f7-48f8-b9c8-fae0248a4cb9
let
	res = 0
	for (box, bd) in pairs(result)
		for (i, focal) in enumerate(values(bd))
			res += (box + 1) * i * focal
		end
	end
	res
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DataStructures = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"

[compat]
DataStructures = "~0.18.15"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.4"
manifest_format = "2.0"
project_hash = "afddc9afffcecddf8e73c1b53d6c212c657b17e6"

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
# ╠═52a4c14c-9b15-11ee-3675-7ddfa9ea6186
# ╠═966c964b-41c5-4f50-b252-e2433b71d87b
# ╠═663fe324-3b31-4a2a-b595-726d9d1474f1
# ╟─6d47c2a0-2cf3-46c4-9f9e-1d6a6742f1a2
# ╠═8d693338-c3db-402d-94b9-82cffc8e723a
# ╠═7d866eb3-f94e-4be7-a0d0-b0d66ddfc8c1
# ╠═81b118cb-61f7-48f8-b9c8-fae0248a4cb9
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
