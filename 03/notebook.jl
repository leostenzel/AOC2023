### A Pluto.jl notebook ###
# v0.19.32

using Markdown
using InteractiveUtils

# ╔═╡ 72eed82a-d7b2-4930-b552-50b1b9255991
using BenchmarkTools, JuliaSyntax, Base.Iterators

# ╔═╡ 195f97cf-5898-46ce-9eb2-f09fc6916d06
inp = "input" |> open |> readlines .|> Vector{Char} |> stack

# ╔═╡ c2a129db-55c7-4578-b9e7-6441a61874ec
symbols = delete!(Set(filter(!isdigit, unique(inp))), '.')

# ╔═╡ 07eeb0e7-bade-4e63-aefc-641e5ee30f93
begin
	struct PartNumber{T} <: Number where {T<:Integer}
		val::T
		start::T
		stop::T
		col::T
	end
	PartNumber(val::T, stop::T, col::T) where {T} = PartNumber{T}(val, stop-ndigits(val)+1, stop, col)
end

# ╔═╡ ff95582a-777f-47f0-a55d-1a2b4aecd075
function part_locs(col, line)
	locs = findall(isdigit, line)
	res = PartNumber{Int}[]

	pos = popfirst!(locs)
	num = line[pos]
	
	while !isempty(locs)
		if locs[1] == pos + 1
			pos = popfirst!(locs)
			num *= line[pos]
		else
			push!(res, PartNumber(Base.parse(Int, num), pos, col))
			pos = popfirst!(locs)
			num = line[pos]
		end
	end
	push!(res, PartNumber(Base.parse(Int, num), pos, col))
end

# ╔═╡ 62c9f705-60e5-4db7-9b56-e0db28711248
view_safe(a::AbstractArray, ranges...) = 
	view(a, (intersect(r, 1:s) for (s, r) ∈ (size(a) .=> ranges))...)

# ╔═╡ f390295b-7c7f-4b79-a845-b836ca83d0ef
parts_vec = [part_locs(i, l) for (i, l) ∈ inp |> eachcol |> enumerate]

# ╔═╡ 56939997-57c2-4de7-bbde-65f5c96a9dea
bbox(part::PartNumber{T}) where {T} = 
	(part.start-1):(part.stop+1), (-1:1) .+ part.col

# ╔═╡ d179c1dc-272f-4348-8465-5d4e5b57cc7e
begin
	local res = 0
	for parts ∈ parts_vec
		for part ∈ parts
			crop = view_safe(inp, bbox(part)...)
			if intersect(symbols, crop) |> !isempty
				res += part.val
			end
		end
	end
	@show  res
end

# ╔═╡ f0c706e0-7d7f-405a-be81-54a496c91a7c
md"## Part 2"

# ╔═╡ 652bec03-fbc6-42f1-8ec8-36577da48003
Base.:∈(idx::CartesianIndex, ranges::NTuple{2,AbstractRange}) = all(Tuple(idx) .∈ ranges)

# ╔═╡ 6741ca33-6a07-4230-aa69-faa1f12f246d
view_safe(parts_vec, 0:2)

# ╔═╡ 77dc9130-5b13-4af6-8c7b-935f83a26547
value(part::PartNumber) = part.val

# ╔═╡ 0f0ed608-4029-491a-a28f-1ca695044bda
begin 
	res2 = 0
	for idx ∈ findall(inp .== '*')
		parts = view_safe(parts_vec, (-1:1) .+ Tuple(idx)[2]) |> flatten |> collect
		
		numbers = Int[]
	
		matches = filter(p->idx ∈ bbox(p), parts)
		if length(matches) == 2
			res2 += *(value.(matches)...)
		end		
	end
	@show res2
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
JuliaSyntax = "70703baa-626e-46a2-a12c-08ffd08c73b4"

[compat]
BenchmarkTools = "~1.3.2"
JuliaSyntax = "~0.4.7"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.4"
manifest_format = "2.0"
project_hash = "9c14cd96f7390f709c4be5492e9e287dc199d82e"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "d9a9701b899b30332bbcb3e1679c41cce81fb0e8"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.3.2"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.5+0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JuliaSyntax]]
git-tree-sha1 = "1a4857ab55396b2da745f07f76ce4e696207b740"
uuid = "70703baa-626e-46a2-a12c-08ffd08c73b4"
version = "0.4.7"

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

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "a935806434c9d4c506ba941871b327b96d41f2bf"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.0"

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

[[deps.Profile]]
deps = ["Printf"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"

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

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

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
# ╠═72eed82a-d7b2-4930-b552-50b1b9255991
# ╠═195f97cf-5898-46ce-9eb2-f09fc6916d06
# ╠═c2a129db-55c7-4578-b9e7-6441a61874ec
# ╠═07eeb0e7-bade-4e63-aefc-641e5ee30f93
# ╠═ff95582a-777f-47f0-a55d-1a2b4aecd075
# ╠═62c9f705-60e5-4db7-9b56-e0db28711248
# ╠═f390295b-7c7f-4b79-a845-b836ca83d0ef
# ╠═56939997-57c2-4de7-bbde-65f5c96a9dea
# ╠═d179c1dc-272f-4348-8465-5d4e5b57cc7e
# ╟─f0c706e0-7d7f-405a-be81-54a496c91a7c
# ╠═652bec03-fbc6-42f1-8ec8-36577da48003
# ╠═6741ca33-6a07-4230-aa69-faa1f12f246d
# ╠═77dc9130-5b13-4af6-8c7b-935f83a26547
# ╠═0f0ed608-4029-491a-a28f-1ca695044bda
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
