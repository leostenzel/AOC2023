### A Pluto.jl notebook ###
# v0.19.36

using Markdown
using InteractiveUtils

# ╔═╡ 666bf9df-0f23-40ec-a61d-b78bcb5eece5
using LinearAlgebra

# ╔═╡ 17591aaa-594b-4f33-bff0-2415255356a1
using GeometryBasics

# ╔═╡ 8a5c7614-a224-11ee-385d-99c076e7dfb7
input = "input" |> readlines

# ╔═╡ aa7cf25f-019b-480a-a4cb-1a562b583924
struct Hailstone{T}
	x::Vector{T}
	v::Vector{T}
end

# ╔═╡ c1f106b2-42bf-400f-8ea8-2c293108fd00
stones = input .|> 
	x->split(x, '@') .|> 
	(x->split(x, ',') .|>
	 x->replace(x, ' '=>"") |>
	 x->Base.parse(Int, x)) |> 
	x->Hailstone(x...)

# ╔═╡ 6d9d5740-6086-40e1-a1cd-590ff8c638bc
function intersect2d(a::Hailstone, b::Hailstone)
	
	a.v[1:2] == b.v[1:2] && return (Inf, Inf)

	t = det([a.x[1]-b.x[1] -b.v[1]; a.x[2]-b.x[2] -b.v[2]])
	
	t /= det([-a.v[1] -b.v[1]; -a.v[2] -b.v[2]])

	t < 0 && return (Inf, Inf)

	inter = (a.x[1] + t*a.v[1], a.x[2] + t*a.v[2])

	(inter[1] - b.x[1]) / b.v[1] < 0 && return (Inf, Inf)

	inter
end

# ╔═╡ 7d4221a3-66e8-4805-a33c-d7f55b1526ab
let
	res = 0
	xymin = 200000000000000
	xymax = 400000000000000

	for (i, stonei) ∈ enumerate(stones[begin:end-1])
		for stonej ∈ stones[i+1:end]
			inter = intersect2d(stonei, stonej)
			if xymin < inter[1] < xymax &&
				xymin < inter[2] < xymax
				res += 1
			end
		end
	end
	res
end

# ╔═╡ 5a82f083-409a-4214-a1ca-24766aebc48c
md"## Part II"

# ╔═╡ 0e5b0218-60f6-432f-b957-685fb659de11
md"""
A hailstone $i$ ($\vec x_i, \vec v_i$) collides with the rock ($\vec x, \vec v$) at time $t_i$ iff

$$\vec{x}_i +\vec{v}_i t_i = \vec x + \vec v t_i$$
"""

# ╔═╡ 4142fad3-4aa9-42b9-a40f-0cbfed5dc9a5
md"""
$$\vec x- \vec x_i = t_i(\vec v_i-\vec v)$$
"""

# ╔═╡ dd6563e5-dbb2-4662-9973-6aa9786e7ded
md"""
$$(\vec v_i-\vec v)\times(\vec x- \vec x_i) = 0$$
"""

# ╔═╡ 13d8b6d3-8cb8-4bf3-a4ff-12f49cb168a0
md"""
Expanding the cross product yields,

$$\vec v_i\times \vec x - \vec v_i\times \vec x_i - \vec v \times\vec x+ \vec v\times \vec x_i = 0\,.$$
"""

# ╔═╡ efaa0123-c51d-4d27-b6bf-0509758bfe25
md"""
$$\vec v_i\times \vec x - \vec v \times\vec x+ \vec v\times \vec x_i = \vec v_i\times \vec x_i\,.$$
"""

# ╔═╡ 06967631-8785-4b6f-8ae2-91f58b3cea24
md"""There is a non-linear term $\vec v\times \vec x$, but it's the same for every hailstone, so we can get rid of it by subtracting the equations for hailstone $i$ and $l$:"""

# ╔═╡ 1393da01-032f-412f-8af7-3a7a22a9c7ba
md"""$$(\vec v_l- \vec v_i) \times \vec x - (\vec x_l -\vec x_i) \times \vec v = \vec v_l\times \vec x_l - \vec v_i\times \vec x_i$$"""

# ╔═╡ 10da55e8-c123-45d6-8dd6-60f7ec45ed57
md"""We can compute the right-hand side directly, for any two hailstones, """

# ╔═╡ 22b24dd5-6289-4069-8e08-532d50f5ba9c
rhs(a::Hailstone, b::Hailstone) = cross(a.v, a.x) - cross(b.v, b.x) 

# ╔═╡ 0a03bcb3-66db-40cc-821c-f24f849d8858
md"""But we want to get rid of the cross product on the left-hand side, because I don't know how to use it directly with `\`.

Following the [wikipedia article](https://en.wikipedia.org/wiki/Cross_product#Alternative_ways_to_compute), we can find a matrix $[a]_\times$ such that $\vec a\times \vec b = [a]_\times \vec b$, i.e., as normal matrix-vector multiplication:
"""

# ╔═╡ 8b1dc0ba-f473-4522-85ee-9ca4554f0324
cross_matrix(a::AbstractVector) = [ 0  -a[3] a[2]
	  							   a[3]  0  -a[1]
	 							  -a[2] a[1]  0  ]

# ╔═╡ 7d678802-4bb1-4596-98a3-79a3c45ac342
md"""To obtain the left-hand side as matrix-vector multiplication we concatinate the `cross_matrix` for the relative velocity and relative position horizontally:"""

# ╔═╡ ccd5eceb-af13-441a-8790-41d3e8ca2c00
lhs(a::Hailstone, b::Hailstone) = 
	hcat(cross_matrix(a.v - b.v), -cross_matrix(a.x - b.x))

# ╔═╡ a1e36033-b236-4473-8320-85d945c612d9
md"""We need to use at least three hailstones to find the solution. But using more shouldn't change the result…"""

# ╔═╡ fe4f9522-f938-4407-a77c-defe4fd5e490
n_stones = 3

# ╔═╡ 92788642-14c2-4580-9fa1-658a2e63ee65
A = vcat(lhs.(stones[1:n_stones-1], stones[2:n_stones])...)

# ╔═╡ 64b961fe-0e9e-4054-85d9-ff64d0bc554e
# ╠═╡ disabled = true
#=╠═╡
b = vcat(rhs.(stones[1:n_stones-1], stones[2:n_stones])...)
  ╠═╡ =#

# ╔═╡ 5e7c138c-1224-40a5-92d5-c5329a08b52e
#=╠═╡
res = A \ b
  ╠═╡ =#

# ╔═╡ 55cfe97a-1ffd-4bc5-9378-d953ed2b21bd
#=╠═╡
res[1:3] .|> round .|> Int |> sum 
  ╠═╡ =#

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
GeometryBasics = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[compat]
GeometryBasics = "~0.4.9"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.0"
manifest_format = "2.0"
project_hash = "ba9c14c35944356769d0dd40ad54531b56fd62ef"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "cde29ddf7e5726c9fb511f340244ea3481267608"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.7.2"
weakdeps = ["StaticArrays"]

    [deps.Adapt.extensions]
    AdaptStaticArraysExt = "StaticArrays"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.5+1"

[[deps.ConstructionBase]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "c53fc348ca4d40d7b371e71fd52251839080cbc9"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.5.4"

    [deps.ConstructionBase.extensions]
    ConstructionBaseIntervalSetsExt = "IntervalSets"
    ConstructionBaseStaticArraysExt = "StaticArrays"

    [deps.ConstructionBase.weakdeps]
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.DataAPI]]
git-tree-sha1 = "8da84edb865b0b5b0100c0666a9bc9a0b71c553c"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.15.0"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e3290f2d49e661fbd94046d7e3726ffcb2d41053"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.4+0"

[[deps.Extents]]
git-tree-sha1 = "2140cd04483da90b2da7f99b2add0750504fc39c"
uuid = "411431e0-e8b7-467b-b5e0-f676ba4f2910"
version = "0.1.2"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.GPUArraysCore]]
deps = ["Adapt"]
git-tree-sha1 = "2d6ca471a6c7b536127afccfa7564b5b39227fe0"
uuid = "46192b85-c4d5-4398-a991-12ede77f4527"
version = "0.1.5"

[[deps.GeoInterface]]
deps = ["Extents"]
git-tree-sha1 = "d4f85701f569584f2cff7ba67a137d03f0cfb7d0"
uuid = "cf35fbd7-0cd7-5166-be24-54bfbe79505f"
version = "1.3.3"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "Extents", "GeoInterface", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "424a5a6ce7c5d97cca7bcc4eac551b97294c54af"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.9"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.IterTools]]
git-tree-sha1 = "274c38bd733f9d29036d0a73658fff1dc1d3a065"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.9.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "7e5d6779a1e09a36db2a7b6cff50942a0a7d0fca"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.5.0"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.4.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.6.4+0"

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

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.2+1"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.1.10"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.23+2"

[[deps.OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.10.0"

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
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

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

[[deps.StructArrays]]
deps = ["Adapt", "ConstructionBase", "DataAPI", "GPUArraysCore", "StaticArraysCore", "Tables"]
git-tree-sha1 = "0a3db38e4cce3c54fe7a71f831cd7b6194a54213"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.16"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "cb76cf677714c095e535e3501ac7954732aeea2d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.11.1"

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
version = "1.2.13+1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+1"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.52.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"
"""

# ╔═╡ Cell order:
# ╠═666bf9df-0f23-40ec-a61d-b78bcb5eece5
# ╠═8a5c7614-a224-11ee-385d-99c076e7dfb7
# ╠═aa7cf25f-019b-480a-a4cb-1a562b583924
# ╠═c1f106b2-42bf-400f-8ea8-2c293108fd00
# ╠═6d9d5740-6086-40e1-a1cd-590ff8c638bc
# ╠═17591aaa-594b-4f33-bff0-2415255356a1
# ╠═7d4221a3-66e8-4805-a33c-d7f55b1526ab
# ╟─5a82f083-409a-4214-a1ca-24766aebc48c
# ╟─0e5b0218-60f6-432f-b957-685fb659de11
# ╟─4142fad3-4aa9-42b9-a40f-0cbfed5dc9a5
# ╟─dd6563e5-dbb2-4662-9973-6aa9786e7ded
# ╟─13d8b6d3-8cb8-4bf3-a4ff-12f49cb168a0
# ╟─efaa0123-c51d-4d27-b6bf-0509758bfe25
# ╟─06967631-8785-4b6f-8ae2-91f58b3cea24
# ╟─1393da01-032f-412f-8af7-3a7a22a9c7ba
# ╟─10da55e8-c123-45d6-8dd6-60f7ec45ed57
# ╠═22b24dd5-6289-4069-8e08-532d50f5ba9c
# ╟─0a03bcb3-66db-40cc-821c-f24f849d8858
# ╠═8b1dc0ba-f473-4522-85ee-9ca4554f0324
# ╟─7d678802-4bb1-4596-98a3-79a3c45ac342
# ╠═ccd5eceb-af13-441a-8790-41d3e8ca2c00
# ╟─a1e36033-b236-4473-8320-85d945c612d9
# ╠═fe4f9522-f938-4407-a77c-defe4fd5e490
# ╠═92788642-14c2-4580-9fa1-658a2e63ee65
# ╠═64b961fe-0e9e-4054-85d9-ff64d0bc554e
# ╠═5e7c138c-1224-40a5-92d5-c5329a08b52e
# ╠═55cfe97a-1ffd-4bc5-9378-d953ed2b21bd
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
