### A Pluto.jl notebook ###
# v0.19.32

using Markdown
using InteractiveUtils

# ╔═╡ cbca2c94-926c-11ee-2d29-832ca4173fa1
using JuliaSyntax

# ╔═╡ cf6810ce-0505-403a-b8e7-44b26179fa15
games = "input" |> readlines .|> 
	x->split(x, ':')[end] .|> 
	x->split(x, '|') .|>
	x->split(x, ' '; keepempty=false) .|>
	x->Base.parse(Int, x);

# ╔═╡ 7cb27dfc-3ecf-4401-847c-498be5cd866c
begin
	local res = 0
	for game ∈ games
		res += 1 << (intersect(game...) |> length) >> 1
	end
	@show res
end

# ╔═╡ 00449ce3-7cc0-48d5-ad0a-920c3a42f3cb
begin
	local multipliers = ones(Int, length(games))
	for (i, game) ∈ enumerate(games)
		
		add_cards = intersect(game...) |> length
		if add_cards > 0
			multipliers[(1:add_cards) .+ i] .+= multipliers[i]
		end
	end
	@show sum(multipliers)
end

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
# ╠═cbca2c94-926c-11ee-2d29-832ca4173fa1
# ╠═cf6810ce-0505-403a-b8e7-44b26179fa15
# ╠═7cb27dfc-3ecf-4401-847c-498be5cd866c
# ╠═00449ce3-7cc0-48d5-ad0a-920c3a42f3cb
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
