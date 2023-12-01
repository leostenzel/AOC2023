### A Pluto.jl notebook ###
# v0.19.32

using Markdown
using InteractiveUtils

# ╔═╡ a803fefe-5a2f-4f09-99b1-2f4de27b7980
using DelimitedFiles

# ╔═╡ 70451909-5988-46f5-ba1b-af634243fa8c
using BenchmarkTools

# ╔═╡ f5a45a52-8b57-474a-869f-9067eb34ef7d
input = readdlm("input", String)

# ╔═╡ 17a2d1d2-089b-4ba4-9df4-39a01ce2e5a8
keepdigits(x) = filter(isdigit, x)

# ╔═╡ 9189bd0f-5e38-45d5-a56c-535dfe0cab49
firstlast(x) = first(x) * last(x)

# ╔═╡ 8d69e088-ae4a-4f3b-ac56-fc8989df249a
parseint(x) = parse(Int, x)

# ╔═╡ 6dbc7601-802f-4e82-9041-c26bb9945d97
input .|> keepdigits .|> firstlast .|> parseint |> sum

# ╔═╡ 732eabbf-fad7-4e78-a1ee-ffc249af55d1
md"## Part two"

# ╔═╡ ed58f513-bbd0-4a2c-898c-a671cd38b8f3
replacements = [
	"one" => "1"
	"two" => "2" 
	"three" => "3" 
	"four" => "4" 
	"five" => "5" 
	"six" => "6" 
	"seven" => "7" 
	"eight" => "8" 
	"nine" => "9"
]

# ╔═╡ 16a9e20b-64c1-44bc-9c7e-8b24ba6a5bc4
replacewords(x) = replace(x, replacements...)

# ╔═╡ 18ab5271-95b6-42b6-831a-2fdc800354bc
overlaps = [
	"oneight" => "18"
	"twone" => "21"
 	"threeight" => "38"
 	"fiveight" => "58"
 	"sevenine" => "79"
 	"eightwo" => "82"
 	"eighthree" => "83"
 	"nineight" => "98"
]

# ╔═╡ f4ba496a-3f54-4c88-87bf-0b2b63184622
overlappingwords(x) = replace(x, overlaps...)

# ╔═╡ 209fd08a-b30f-4c7e-b5ef-8ede12be0d1d
@btime input .|> overlappingwords .|> replacewords .|> keepdigits .|> firstlast .|> parseint |> sum

# ╔═╡ 5a277429-2121-4cc3-848a-41aef3139511
md"""
### Without defining overlaps manually
still not a very pretty solution…
"""

# ╔═╡ a9c00503-7d5d-4f07-ba61-cb3478b1951d
function replace_firstlast(x)
	# replace the first occurence of any spelled-out number.
	# we append the original string, because we may have to replace some of the previously matched characters again
	x = replace(x, replacements..., count=1) * x

	# reverse the replacement rule
	rev_repl = @. reverse(first(replacements)) => last(replacements)
	
	# apply the rule from the end
	reverse(replace(reverse(x), rev_repl..., count=1))
end

# ╔═╡ f195dfde-1294-4a2b-8bab-215c24bcc5fc
@btime input .|> replace_firstlast .|> keepdigits .|> firstlast .|> parseint |> sum

# ╔═╡ 08ee7e3b-dd5d-4e95-9cb5-97c061471f09
md"""
### without replacements

Clearly, replace doesn't really work well with these strings 
"""

# ╔═╡ 736257fe-864a-43c0-bf96-f6c7588b3895
function first_substring(patterns, x) 
	function f(p)
		r = findfirst(p, x)
		isnothing(r) ? length(x)+1 : r[begin]
	end
	argmin(f, patterns)
end

# ╔═╡ faf433b7-11fa-46df-8c3a-865ce4630383
function last_substring(patterns, x) 
	function f(p)
		r = findlast(p, x)
		isnothing(r) ? 0 : r[end]
	end
	argmax(f, patterns)
end

# ╔═╡ c53a9685-2960-494c-b829-a127690c6d0d
@btime begin
	patterns = first.(replacements)
	append!(patterns, string.(1:9))

	r_dict = Dict(replacements..., (string.(1:9) .=> string.(1:9))...)
	
	result = 0
	open("input") do f
		for l ∈ eachline(f)
			tmp = r_dict[first_substring(patterns, l)]
			tmp = tmp * r_dict[last_substring(patterns, l)]
			result += parse(Int, tmp)
		end
	end
	result
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
DelimitedFiles = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[compat]
BenchmarkTools = "~1.3.2"
DelimitedFiles = "~1.9.1"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.4"
manifest_format = "2.0"
project_hash = "36cbca4f55d153d3780b881a1cd64c62fe633324"

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

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

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
# ╟─a803fefe-5a2f-4f09-99b1-2f4de27b7980
# ╠═70451909-5988-46f5-ba1b-af634243fa8c
# ╠═f5a45a52-8b57-474a-869f-9067eb34ef7d
# ╠═17a2d1d2-089b-4ba4-9df4-39a01ce2e5a8
# ╠═9189bd0f-5e38-45d5-a56c-535dfe0cab49
# ╠═8d69e088-ae4a-4f3b-ac56-fc8989df249a
# ╠═6dbc7601-802f-4e82-9041-c26bb9945d97
# ╟─732eabbf-fad7-4e78-a1ee-ffc249af55d1
# ╠═ed58f513-bbd0-4a2c-898c-a671cd38b8f3
# ╠═16a9e20b-64c1-44bc-9c7e-8b24ba6a5bc4
# ╠═18ab5271-95b6-42b6-831a-2fdc800354bc
# ╠═f4ba496a-3f54-4c88-87bf-0b2b63184622
# ╠═209fd08a-b30f-4c7e-b5ef-8ede12be0d1d
# ╟─5a277429-2121-4cc3-848a-41aef3139511
# ╠═a9c00503-7d5d-4f07-ba61-cb3478b1951d
# ╠═f195dfde-1294-4a2b-8bab-215c24bcc5fc
# ╟─08ee7e3b-dd5d-4e95-9cb5-97c061471f09
# ╠═c53a9685-2960-494c-b829-a127690c6d0d
# ╠═736257fe-864a-43c0-bf96-f6c7588b3895
# ╠═faf433b7-11fa-46df-8c3a-865ce4630383
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
