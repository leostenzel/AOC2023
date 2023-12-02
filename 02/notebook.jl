### A Pluto.jl notebook ###
# v0.19.32

using Markdown
using InteractiveUtils

# ╔═╡ 8f77d046-422c-4ba0-82ae-07c181a04d31
using JuliaSyntax

# ╔═╡ 7f12c2e0-0717-475e-bc32-8cc1a8615964
begin
	struct Round{T}
		red::T
		green::T
		blue::T
	end

	local ex = let ex = :(error())
		for c ∈ (:red, :green, :blue)
			ex = :(col == $(String(c)) ? $(Symbol(c)) = num : $(ex))
		end
		ex
	end
	
	quote
		function Round(a::AbstractString)
			red = green = blue = 0
			for c_str ∈ split(a, ',')
	
				num, col = split(c_str, ' ', keepempty=false)
				num = Base.parse(Int, num)
				
				$ex
			end
			Round(red, green, blue)
		end
	end |> eval
end

# ╔═╡ 86ee306c-bffa-462a-bdd0-f4cafd7829ea
begin
	struct Game
		id::Int
		rounds::Vector{Round}
	end
	function Game(a::AbstractString)
		head, body = split(a, ':')
		id = Base.parse(Int, split(head)[end])
		Game(id, Round.(split(body, ';')))
	end
end

# ╔═╡ 5ce3880d-3e23-42d5-967f-57e8a27a0ed6
id(g::Game) = g.id

# ╔═╡ f3408630-95c7-43ee-88f1-98726a15c174
games = "input" |> readlines .|> Game

# ╔═╡ 59f1fee5-510e-4ed2-86d3-16d14d15337e
md"one could avoid defining these functions and broadcast with `getfield`. Don't think that would be better?"

# ╔═╡ 49b4402a-3980-48ea-84dd-28b544bb8e0c
red(r::Round) = r.red

# ╔═╡ 52fa8f89-25a5-4fb8-b947-5b641bc46a52
green(r::Round) = r.green

# ╔═╡ 9e4e872c-a2dc-48f9-909e-1bf297c63857
blue(r::Round) = r.blue

# ╔═╡ ecc42bb6-b402-41ef-bebe-28acc87bfc0c
Base.maximum(g::Game) = Round((maximum(f.(g.rounds)) for f ∈ (red, green, blue))...)

# ╔═╡ c28c0fe5-1ebf-4733-b514-50d9def61c84
function isallowed(g::Game)
	m = maximum(g)
	m.red <= 12 && m.green <= 13 && m.blue <= 14
end

# ╔═╡ 94205cfb-d061-47e0-a386-79c5adde020e
filter(isallowed, games) .|> id |> sum

# ╔═╡ 3fffb506-2e3a-4efe-bf87-81443841dedc
md"## part 2"

# ╔═╡ 9545e84d-a453-4342-9d5d-281659945c64
power(r::Round) = *((f(r) for f ∈ (red, blue, green))...)

# ╔═╡ e3a8b143-4ad9-4651-bbc6-3f5f400b587d
games .|> maximum .|> power |> sum

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
JuliaSyntax = "70703baa-626e-46a2-a12c-08ffd08c73b4"

[compat]
JuliaSyntax = "~0.4.7"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.4"
manifest_format = "2.0"
project_hash = "217b45c91364b0c5cb7a0d50ee3cdf7390293d8f"

[[deps.JuliaSyntax]]
git-tree-sha1 = "1a4857ab55396b2da745f07f76ce4e696207b740"
uuid = "70703baa-626e-46a2-a12c-08ffd08c73b4"
version = "0.4.7"
"""

# ╔═╡ Cell order:
# ╠═8f77d046-422c-4ba0-82ae-07c181a04d31
# ╠═7f12c2e0-0717-475e-bc32-8cc1a8615964
# ╠═86ee306c-bffa-462a-bdd0-f4cafd7829ea
# ╠═5ce3880d-3e23-42d5-967f-57e8a27a0ed6
# ╠═ecc42bb6-b402-41ef-bebe-28acc87bfc0c
# ╠═f3408630-95c7-43ee-88f1-98726a15c174
# ╟─59f1fee5-510e-4ed2-86d3-16d14d15337e
# ╠═49b4402a-3980-48ea-84dd-28b544bb8e0c
# ╠═52fa8f89-25a5-4fb8-b947-5b641bc46a52
# ╠═9e4e872c-a2dc-48f9-909e-1bf297c63857
# ╠═c28c0fe5-1ebf-4733-b514-50d9def61c84
# ╠═94205cfb-d061-47e0-a386-79c5adde020e
# ╟─3fffb506-2e3a-4efe-bf87-81443841dedc
# ╠═9545e84d-a453-4342-9d5d-281659945c64
# ╠═e3a8b143-4ad9-4651-bbc6-3f5f400b587d
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
