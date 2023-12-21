### A Pluto.jl notebook ###
# v0.19.36

using Markdown
using InteractiveUtils

# ╔═╡ 8fe18348-706e-42de-bdf3-1291f3582664
using JuliaSyntax

# ╔═╡ 0ba66880-9fc1-11ee-1d4c-59fba5119fbf
input = "input" |> readlines |> stack;

# ╔═╡ c4dc0686-1f0d-4aa8-86a1-619756a55082
begin 
	move(s, c::CartesianIndex) = move(Val(s), c)
	move(::Val{:north}, c::CI) where {CI<:CartesianIndex} = CI(c[1], c[2]-1)
	move(::Val{:south}, c::CI) where {CI<:CartesianIndex} = CI(c[1], c[2]+1)
	move(::Val{:west}, c::CI) where {CI<:CartesianIndex} = CI(c[1]-1, c[2])
	move(::Val{:east}, c::CI) where {CI<:CartesianIndex} = CI(c[1]+1, c[2])
end

# ╔═╡ 6a65ad4d-76ee-4469-b522-60e25068e99c
function step(input::AbstractMatrix, candidates::AbstractSet{CI}) where {CI}
	n_candidates = Set{CI}()
	for site ∈ candidates
		for dir ∈ (:north, :east, :south, :west)
			n_site = move(dir, site)
			n_site ∉ CartesianIndices(input) && continue
			input[n_site] == '#' && continue
			push!(n_candidates, n_site)
		end
	end
	n_candidates
end

# ╔═╡ 52ae6297-9302-401a-80e8-999ef8e029a5
function explore(input, n_steps, stepfun=step)
	candidates = Set([findfirst(==('S'), input)])
	lengths = Int[]
	for n ∈ 1:n_steps
		candidates = stepfun(input, candidates)
		push!(lengths, length(candidates))
	end
	lengths
end

# ╔═╡ 28d85bc3-53a3-4f72-9ae8-277bbe6992f6
explore(input, 64)[end]

# ╔═╡ b50dc523-1213-4b47-85f4-24cbcc8a44a2
md"""## Part II
So this is a bit peculiar; I don't think there's a general solution for any input.

And the AOC makes for a particularly simple solution, once you figure it out…
"""

# ╔═╡ 1655d257-cb14-4308-aa8f-f2396bc852c6
function step_periodic(input, candidates::AbstractSet{CI}) where {CI}
	n_candidates = Set{CI}()
	dims = size(input)
		
	for site ∈ candidates
		for dir ∈ (:north, :east, :south, :west)
			n_site = move(dir, site)	
			
			input[mod(n_site[1]-1,  dims[1])+1, 
				mod(n_site[2]-1,  dims[2])+1] == '#' && continue

			push!(n_candidates, n_site)
		end
	end
	n_candidates
end

# ╔═╡ ad4f7ae9-adb7-457d-ac5d-f7d37c49109d
lengths = explore(input, 2*131 + 65, step_periodic)

# ╔═╡ a1a1e02d-1f7a-4710-8773-d2d2de33e57f
f = let 
	a0 = lengths[65]
	tmp = lengths[131+65] - 4a0
	b = (9a0 + 4tmp - lengths[2*131+65]) ÷ 2
	a1 = tmp - 2b
	n -> (n+1)^2 * a0 + n^2 * a1 + n*(n+1) * b 
end

# ╔═╡ 8fe2025f-ddaf-4948-81ef-b52045bdde69
f(26501365 ÷ 131)

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
# ╠═8fe18348-706e-42de-bdf3-1291f3582664
# ╠═0ba66880-9fc1-11ee-1d4c-59fba5119fbf
# ╠═c4dc0686-1f0d-4aa8-86a1-619756a55082
# ╠═6a65ad4d-76ee-4469-b522-60e25068e99c
# ╠═52ae6297-9302-401a-80e8-999ef8e029a5
# ╠═28d85bc3-53a3-4f72-9ae8-277bbe6992f6
# ╟─b50dc523-1213-4b47-85f4-24cbcc8a44a2
# ╠═1655d257-cb14-4308-aa8f-f2396bc852c6
# ╠═ad4f7ae9-adb7-457d-ac5d-f7d37c49109d
# ╠═a1a1e02d-1f7a-4710-8773-d2d2de33e57f
# ╠═8fe2025f-ddaf-4948-81ef-b52045bdde69
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
