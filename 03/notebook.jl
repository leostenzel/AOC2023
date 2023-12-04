### A Pluto.jl notebook ###
# v0.19.32

using Markdown
using InteractiveUtils

# ╔═╡ 72eed82a-d7b2-4930-b552-50b1b9255991
using JuliaSyntax, Base.Iterators

# ╔═╡ 195f97cf-5898-46ce-9eb2-f09fc6916d06
inp = "input" |> readlines .|> Vector{Char} |> stack;

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
