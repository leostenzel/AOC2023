### A Pluto.jl notebook ###
# v0.19.32

using Markdown
using InteractiveUtils

# ╔═╡ 8d1cc649-1e75-4f7e-9d9b-009498be06a6
using Base.Iterators, JuliaSyntax

# ╔═╡ eede79a2-97e8-11ee-3db9-9fba79186601
input = "input" |> readlines |> stack

# ╔═╡ 412c7d5d-e3e6-4d1e-bde6-9d809e4cb791
exp_input = let input = input
	for (i, col) ∈ Iterators.reverse(enumerate(eachcol(input)))
		if all(col .== '.')
			input = hcat(input[:, begin:i], input[:, i:end])
		end
	end
	for (i, row) ∈ Iterators.reverse(enumerate(eachrow(input)))
		if all(row .== '.')
			input = vcat(input[begin:i,:], input[i:end,:])
		end
	end
	input
end

# ╔═╡ 908e5494-8bf8-4cf5-927e-9c49a1fe15ff
distance(a::T, b::T) where {T<:CartesianIndex{2}} = abs(a[1]-b[1]) + abs(a[2]-b[2])

# ╔═╡ a456f155-b7cd-4cb3-a502-091c0fe3a45b
md"## Part II"

# ╔═╡ 7e188b11-0ee1-412c-81f4-9266f9d53a37
empty_cols = findall(x->all(x .== '.'), eachcol(input))

# ╔═╡ 33865466-740c-4851-94aa-c687a8ecc12a
empty_rows = findall(x->all(x .== '.'), eachrow(input))

# ╔═╡ 6f5c4e10-9411-4822-b460-36ab057b4ac4
srange(a, b) = range(sort([a,b])...)

# ╔═╡ aac2697f-98e0-4490-a6a7-aadabfda6e7c
function distance(factor, a::T, b::T) where {T<:CartesianIndex{2}}
	dist = distance(a, b)
	dist += length(intersect(srange(a[1], b[1]), empty_rows)) * (factor-1)
	dist + length(intersect(srange(a[2], b[2]), empty_cols)) * (factor-1)
end

# ╔═╡ 5098bfe5-d0cc-4481-9d9e-55fb78d989a8
cum_dist = let res = 0
	positions = findall(==('#'), exp_input)
	for (i, pos_a) ∈ enumerate(positions)
		for pos_b ∈ positions[i+1:end]
			res += distance(pos_a, pos_b)
		end
	end
	res
end

# ╔═╡ f9c07659-a69c-46e5-9fab-1a3406f20405
cum_dist2 = let res = 0
	positions = findall(==('#'), input)
	for (i, pos_a) ∈ enumerate(positions)
		for pos_b ∈ positions[i+1:end]
			res += distance(1000000, pos_a, pos_b)
		end
	end
	res
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
JuliaSyntax = "70703baa-626e-46a2-a12c-08ffd08c73b4"

[compat]
JuliaSyntax = "~0.4.8"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.4"
manifest_format = "2.0"
project_hash = "b3e27a3e97c78e04ee6408efa7c2c47d5367c8c2"

[[deps.JuliaSyntax]]
git-tree-sha1 = "e00e2b013f3bd98d3789f889b9305c1546ecd1ab"
uuid = "70703baa-626e-46a2-a12c-08ffd08c73b4"
version = "0.4.8"
"""

# ╔═╡ Cell order:
# ╠═8d1cc649-1e75-4f7e-9d9b-009498be06a6
# ╠═eede79a2-97e8-11ee-3db9-9fba79186601
# ╠═412c7d5d-e3e6-4d1e-bde6-9d809e4cb791
# ╠═908e5494-8bf8-4cf5-927e-9c49a1fe15ff
# ╠═5098bfe5-d0cc-4481-9d9e-55fb78d989a8
# ╟─a456f155-b7cd-4cb3-a502-091c0fe3a45b
# ╠═7e188b11-0ee1-412c-81f4-9266f9d53a37
# ╠═33865466-740c-4851-94aa-c687a8ecc12a
# ╠═6f5c4e10-9411-4822-b460-36ab057b4ac4
# ╠═aac2697f-98e0-4490-a6a7-aadabfda6e7c
# ╠═f9c07659-a69c-46e5-9fab-1a3406f20405
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
