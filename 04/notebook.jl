### A Pluto.jl notebook ###
# v0.19.32

using Markdown
using InteractiveUtils

# ╔═╡ cf6810ce-0505-403a-b8e7-44b26179fa15
cards = "input" |> readlines .|> 
	x->split(x, ':')[end] |> 
	x->split(x, '|') .|>
	x->split(x; keepempty=false) .|>
	x->parse(Int, x);

# ╔═╡ 2e89d365-e6cd-43b9-b0db-88cea03b95fa
sum(cards .|> x->intersect(x...) |> length .|> x-> 1 << x >> 1)

# ╔═╡ 06762091-168b-4cc2-9c4c-eb0abd78321d
md"part 2"

# ╔═╡ 00449ce3-7cc0-48d5-ad0a-920c3a42f3cb
begin
	local multipliers = ones(Int, length(cards))
	for (i, card) ∈ enumerate(cards)
		
		add_cards = intersect(card...) |> length
		multipliers[(1:add_cards) .+ i] .+= multipliers[i]
		
	end
	sum(multipliers)
end

# ╔═╡ Cell order:
# ╠═cf6810ce-0505-403a-b8e7-44b26179fa15
# ╠═2e89d365-e6cd-43b9-b0db-88cea03b95fa
# ╟─06762091-168b-4cc2-9c4c-eb0abd78321d
# ╠═00449ce3-7cc0-48d5-ad0a-920c3a42f3cb
