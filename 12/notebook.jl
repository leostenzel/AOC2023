### A Pluto.jl notebook ###
# v0.19.36

using Markdown
using InteractiveUtils

# ╔═╡ 8e1cdaa4-a451-4243-ae2f-8178962482cc
using JuliaSyntax, Combinatorics, Memoize

# ╔═╡ 8a9a842e-98b1-11ee-085a-b7bf99fe6a48
input = "input" |> readlines

# ╔═╡ b4bda11d-f0ca-45dc-8bbe-fad5162c56e2
function parse_line(line)
	s, cnt = line |> split
	cnt = Base.parse.(Int, split(cnt, ','))
	s, cnt
end

# ╔═╡ 6cdc5a2e-7164-4025-8da0-e3d4315d7068
issolution(s, count) = length.(split(s, '.', keepempty=false)) == count

# ╔═╡ 1c8e864a-6f64-43fd-960a-9f82c28aef64
function count_combinations(s, cnt)
	res = 0
	nsprings = sum(cnt) - count('#', s)
	for comb in combinations(findall('?', s), nsprings)
		s2 = collect(s)
		for idx in comb
			s2[idx] = '#'
		end
		s2 = String(s2)
		s2 = replace(s2, '?'=>'.')
		if issolution(s2, cnt)
			res += 1
		end
	end
	return res
end

# ╔═╡ 47304d06-80bd-4359-b279-b920b547038e
(input .|> parse_line .|> x->count_combinations(x...)) |> sum

# ╔═╡ d2bdb8ab-93f4-4aac-86a5-3f5e77c3862d
md"## Part II"

# ╔═╡ 297e4a90-5ae4-4e8f-9e76-29fb58dd1512
@memoize function count_recursive(s::AbstractString, cnt::Tuple{Vararg{<:Integer}})	
	if isempty(cnt)
		iszero(count('#', s)) && return 1
		return 0
	end	
	
	sum(cnt) > length(s) - count('.', s) && return 0

	# we won't find a solution anymore
	count('#', s) > sum(cnt) && return 0 
	
	# if there's a `#` it needs to be included in this segment
	stop = findfirst('#', s)

	# if there's no `#`, we could go all the way to the last `?`
	isnothing(stop) && (stop = findlast('?', s))

	# first possible start position is at the first `?`
	start = findfirst('?', s)
	isnothing(start) && (start = stop)

	# if the first `#` is before the first `?`, we have to start there…
	start = min(start,stop)
	
	c = first(cnt)
	res = 0
	
	for idx ∈ start:stop
		# block is longer than line
		idx+c-1 > length(s) && break

		# can't put a block over the `.`
		'.' ∈ s[idx:idx+c-1] && continue

		if length(s) < idx+c || s[idx+c] != '#'
			res += count_recursive(s[idx+c+1:end], cnt[2:end])
		end
	end
	res
end

# ╔═╡ 0d37412c-e3b3-4132-a268-94474787e8f7
count_recursive(s::AbstractString, cnt::Vector{<:Integer}) = count_recursive(s, Tuple(cnt))

# ╔═╡ 989b86bc-caaa-41d0-9c66-88841459897c
repeat_rec(s, cnt; n=5) = reduce(*, repeat(['?', s], n-1); init=s), repeat(cnt, n)

# ╔═╡ 1f5690f0-f8f6-45af-bb20-208ac9f04145
(input .|> parse_line .|> 
	x->repeat_rec(x...) |> 
	x->count_recursive(x...)
) |> sum

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Combinatorics = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
JuliaSyntax = "70703baa-626e-46a2-a12c-08ffd08c73b4"
Memoize = "c03570c3-d221-55d1-a50c-7939bbd78826"

[compat]
Combinatorics = "~1.0.2"
JuliaSyntax = "~0.4.8"
Memoize = "~0.4.4"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.4"
manifest_format = "2.0"
project_hash = "889f570bdf63b52aad26e96a8dee9e80645b8e7c"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Combinatorics]]
git-tree-sha1 = "08c8b6831dc00bfea825826be0bc8336fc369860"
uuid = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
version = "1.0.2"

[[deps.JuliaSyntax]]
git-tree-sha1 = "e00e2b013f3bd98d3789f889b9305c1546ecd1ab"
uuid = "70703baa-626e-46a2-a12c-08ffd08c73b4"
version = "0.4.8"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "9ee1618cbf5240e6d4e0371d6f24065083f60c48"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.11"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.Memoize]]
deps = ["MacroTools"]
git-tree-sha1 = "2b1dfcba103de714d31c033b5dacc2e4a12c7caa"
uuid = "c03570c3-d221-55d1-a50c-7939bbd78826"
version = "0.4.4"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
"""

# ╔═╡ Cell order:
# ╠═8e1cdaa4-a451-4243-ae2f-8178962482cc
# ╠═8a9a842e-98b1-11ee-085a-b7bf99fe6a48
# ╠═b4bda11d-f0ca-45dc-8bbe-fad5162c56e2
# ╠═1c8e864a-6f64-43fd-960a-9f82c28aef64
# ╠═47304d06-80bd-4359-b279-b920b547038e
# ╠═6cdc5a2e-7164-4025-8da0-e3d4315d7068
# ╟─d2bdb8ab-93f4-4aac-86a5-3f5e77c3862d
# ╠═297e4a90-5ae4-4e8f-9e76-29fb58dd1512
# ╠═0d37412c-e3b3-4132-a268-94474787e8f7
# ╠═989b86bc-caaa-41d0-9c66-88841459897c
# ╠═1f5690f0-f8f6-45af-bb20-208ac9f04145
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
