### A Pluto.jl notebook ###
# v0.19.32

using Markdown
using InteractiveUtils

# ╔═╡ 99ed61f2-3b46-4d91-a46b-81d5dda160cc
using BenchmarkTools, JuliaSyntax

# ╔═╡ 3c182ebe-9596-11ee-2422-bd89eb1f3359
begin
	local input = "input" |> readlines 
	directions = popfirst!(input)
	connections = input[2:end]
end

# ╔═╡ dc830c4d-8ca0-417d-8c83-d601474f72b3
begin
	map_dict = Dict{AbstractString, NTuple{2,AbstractString}}()
	for line ∈ connections
		node, edges  = split(line, '=') .|> split
		edges = tuple(strip.(edges, (['(', ')', ','],))...)
		map_dict[node[]] = tuple(edges...)
	end
end

# ╔═╡ 76769894-9247-45e9-a445-b3b78adf28fb
function traverse(pos::T,
	map_dict::Dict{T, NTuple{2, T}}, 
	directions::T, nreps::Integer,
	condition) where {T<:AbstractString}

	idx_dict = Dict('L' => 1, 'R' => 2)
		
	for rep = 1:nreps
		for (i, dir) ∈ enumerate(directions)
			
			pos = map_dict[pos][idx_dict[dir]]

			condition(pos) && return rep, i, pos
		end
	end
end

# ╔═╡ d785268d-b393-4237-8c7d-9fe28159d033
md"""## Part II

In the generic case, we'd have to run the following solver for a very long time---At least I don't see any shortcut for generic input?
"""

# ╔═╡ ac8f2c56-9f13-422e-974e-10385b28f42a
function traverse(map_dict::Dict{T, NTuple{2, T}}, 
	directions::T, nreps::Integer) where {T<:AbstractString}

	idx_dict = Dict('L' => 1, 'R' => 2)
	
	local pos = filter(s->endswith(s, 'A'), collect(keys(map_dict)))
	local n_target = count(s->endswith(s, 'Z'), keys(map_dict))

	@assert length(pos) == n_target
	
	for rep = 0:nreps
		for (i, dir) ∈ enumerate(directions)
			for j ∈ eachindex(pos)
				pos[j] = map_dict[pos[j]][idx_dict[dir]]
			end
			cnt = count(s->endswith(s, 'Z'), pos)
			if cnt == n_target
				return length(directions) * rep + i
			elseif cnt > 2
				@show cnt
			end
		end
	end
	nothing	
end

# ╔═╡ 23c1ac98-814a-460d-bc8b-e903a13811cc
begin 
	local (rep, i, res) = traverse("AAA", map_dict, directions, 100, ==("ZZZ"))
	(rep - 1) * length(directions) + i
end

# ╔═╡ e7b134fc-94c2-48b4-b165-59f4c2164097
md"""10^4 iterations throught the `directions` already take 2 seconds, so that's not going to end well!

(Don't know why it's allocating so much… For now, I'll leave this as an exercise)
"""

# ╔═╡ e589ba5c-d3e4-458d-9772-91b1e2c0f9e9
@time traverse(map_dict, directions, 10_000)

# ╔═╡ db93dbc1-bef5-411d-83d2-b6cb5a568ca0
md"""But, if we try out all input strings separately, we see that the input is very nice:

Every starting point maps to a distinct end point, and the number of steps in the last round is always the same!

Note that actually no other end points will ever be reached from a given starting point… this is not shown here, but our solution makes use of this, too.
"""

# ╔═╡ 95347e63-be6e-4371-abb8-b8b5e8706f25
for pos ∈ filter(s->endswith(s, 'A'), map_dict |> keys)
	@show pos
	local (rep, i, res) = traverse(pos, map_dict, directions, 100, s->endswith(s, 'Z'))
	@show rep, i, res
end

# ╔═╡ 95e1f9b3-4675-4d8a-9b16-1eb0b0a01669
begin 
	local reps = Int[]
	local steps = Int[]
	for pos ∈ filter(s->endswith(s, 'A'), map_dict |> keys)
		(rep, i, _) = traverse(pos, map_dict, directions, 100, s->endswith(s, 'Z'))
		push!(reps, rep)
		push!(steps, i)
	end
	# Bit tricky to get this right: 
	# we need the least common multiple from the repetitions (which count from 1);
	# but then need to subtract 1 again… 
	(lcm(reps...) - 1) * length(directions) + unique(steps)[]
end

# ╔═╡ 0b15eda6-da48-4ac7-972d-5c729cb8a494
md"""
Of course, this is not a very helpful result for the main character…

They will just walk _many_ more loops 🐫
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
JuliaSyntax = "70703baa-626e-46a2-a12c-08ffd08c73b4"

[compat]
BenchmarkTools = "~1.4.0"
JuliaSyntax = "~0.4.8"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.4"
manifest_format = "2.0"
project_hash = "f170a871809acdab7dfab149d8ec7646e8c93421"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.BenchmarkTools]]
deps = ["JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "f1f03a9fa24271160ed7e73051fba3c1a759b53f"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.4.0"

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
git-tree-sha1 = "e00e2b013f3bd98d3789f889b9305c1546ecd1ab"
uuid = "70703baa-626e-46a2-a12c-08ffd08c73b4"
version = "0.4.8"

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
# ╠═99ed61f2-3b46-4d91-a46b-81d5dda160cc
# ╠═3c182ebe-9596-11ee-2422-bd89eb1f3359
# ╠═dc830c4d-8ca0-417d-8c83-d601474f72b3
# ╠═76769894-9247-45e9-a445-b3b78adf28fb
# ╠═23c1ac98-814a-460d-bc8b-e903a13811cc
# ╟─d785268d-b393-4237-8c7d-9fe28159d033
# ╠═ac8f2c56-9f13-422e-974e-10385b28f42a
# ╟─e7b134fc-94c2-48b4-b165-59f4c2164097
# ╠═e589ba5c-d3e4-458d-9772-91b1e2c0f9e9
# ╟─db93dbc1-bef5-411d-83d2-b6cb5a568ca0
# ╠═95347e63-be6e-4371-abb8-b8b5e8706f25
# ╠═95e1f9b3-4675-4d8a-9b16-1eb0b0a01669
# ╟─0b15eda6-da48-4ac7-972d-5c729cb8a494
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
