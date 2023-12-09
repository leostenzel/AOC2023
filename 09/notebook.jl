### A Pluto.jl notebook ###
# v0.19.32

using Markdown
using InteractiveUtils

# ╔═╡ c4de4099-c745-4485-9f15-5c228c6755ea
using JuliaSyntax

# ╔═╡ e262b2d0-96b5-11ee-0405-65f441202b25
lines = "input" |> readlines

# ╔═╡ 2a9c5f9f-7c70-4db2-aab0-3e6f7eccecb7
function extrapolate(a::AbstractVector{T}, f) where {T<:Integer}
	iszero(a) && return zero(T)
	f(a, extrapolate(diff(a), f))
end

# ╔═╡ 9117a1df-11a2-4bb7-94f9-a12af6cf9c23
(lines .|> split .|> 
	x->Base.parse.(Int, x) |> 
	x->extrapolate(x, (a, δ)->(last(a) + δ))) |> sum

# ╔═╡ cf39b391-df1f-41e9-bcf3-827202b1f4d6
md"## Part II"

# ╔═╡ 4c80e336-423d-44fe-825b-1f39586621e1
(lines .|> split .|> 
	x->Base.parse.(Int, x) |> 
	x->extrapolate(x, (a, δ)->(first(a) - δ))) |> sum

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
# ╠═c4de4099-c745-4485-9f15-5c228c6755ea
# ╠═e262b2d0-96b5-11ee-0405-65f441202b25
# ╠═2a9c5f9f-7c70-4db2-aab0-3e6f7eccecb7
# ╠═9117a1df-11a2-4bb7-94f9-a12af6cf9c23
# ╠═cf39b391-df1f-41e9-bcf3-827202b1f4d6
# ╠═4c80e336-423d-44fe-825b-1f39586621e1
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
