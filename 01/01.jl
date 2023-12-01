### A Pluto.jl notebook ###
# v0.19.32

using Markdown
using InteractiveUtils

# ╔═╡ a803fefe-5a2f-4f09-99b1-2f4de27b7980
using DelimitedFiles

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
	"one" => "1", 
	"two" => "2", 
	"three" => "3", 
	"four" => "4", 
	"five" => "5", 
	"six" => "6", 
	"seven" => "7", 
	"eight" => "8", 
	"nine" => "9"
]

# ╔═╡ 7404ff1a-c919-49ee-b3a8-7561ed587c1c
replacewords(x) = replace(x, replacements...)

# ╔═╡ 209fd08a-b30f-4c7e-b5ef-8ede12be0d1d
input .|> replacewords .|> keepdigits .|> firstlast .|> parseint |> sum

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DelimitedFiles = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[compat]
DelimitedFiles = "~1.9.1"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.4"
manifest_format = "2.0"
project_hash = "eb696dba116621a072d91c57084a363ced7654e8"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
"""

# ╔═╡ Cell order:
# ╠═a803fefe-5a2f-4f09-99b1-2f4de27b7980
# ╠═f5a45a52-8b57-474a-869f-9067eb34ef7d
# ╠═17a2d1d2-089b-4ba4-9df4-39a01ce2e5a8
# ╠═9189bd0f-5e38-45d5-a56c-535dfe0cab49
# ╠═8d69e088-ae4a-4f3b-ac56-fc8989df249a
# ╠═6dbc7601-802f-4e82-9041-c26bb9945d97
# ╟─732eabbf-fad7-4e78-a1ee-ffc249af55d1
# ╠═ed58f513-bbd0-4a2c-898c-a671cd38b8f3
# ╠═7404ff1a-c919-49ee-b3a8-7561ed587c1c
# ╠═209fd08a-b30f-4c7e-b5ef-8ede12be0d1d
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
