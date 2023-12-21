### A Pluto.jl notebook ###
# v0.19.36

using Markdown
using InteractiveUtils

# ╔═╡ c39db7c6-b528-4adf-964c-ff6e21ca307e
using JuliaSyntax, LinearAlgebra

# ╔═╡ 75085004-9d70-11ee-38f6-6da0c3a3af2b
input = "input" |> readlines

# ╔═╡ 25af5d60-5079-4120-a71f-fe77667e6bb7
in1 = input .|> x->split(x)[1:2] .|> (Symbol, x->Base.parse(Int, x))

# ╔═╡ 8d74ed58-3f9d-4af9-a0bf-4bb241bc2546
begin 
	move(s::Symbol, c::CartesianIndex, n=1) = move(Val(s), c, n)
	move(::Val{:U}, c::CI, n=1) where {CI<:CartesianIndex} = CI(c[1], c[2]-n)
	move(::Val{:D}, c::CI, n=1) where {CI<:CartesianIndex} = CI(c[1], c[2]+n)
	move(::Val{:L}, c::CI, n=1) where {CI<:CartesianIndex} = CI(c[1]-n, c[2])
	move(::Val{:R}, c::CI, n=1) where {CI<:CartesianIndex} = CI(c[1]+n, c[2])
end

# ╔═╡ 1a522a8e-7213-4365-a135-f55d10e06be7
function compute_boundary(directions) 
	indices = CartesianIndex{2}[CartesianIndex(1,1)]
	boundary = 0
	
	for line ∈ directions
		push!(indices, move(line[1], indices[end], line[2]))
		boundary += line[2]
	end
	
	indices, boundary
end

# ╔═╡ 1b86587d-4026-4721-8f38-ac56bfa6df1a
md"We compute the inside with the 'shoelace formula': Adding up the determinant of consecutive points… pretty easy!"

# ╔═╡ b55a3ec1-457e-4062-8abe-a455baddd02f
function inside(indices::Vector{CartesianIndex{2}})
	mat = collect.(Tuple.(indices)) |> stack
	res = 0
	for i ∈ 2:size(mat,2)
		# det returns a Float, which is surprising…
		# Rounding here should be fairly safe, though.
		# Otherwise just implement the 2×2 determinant yourself…
		res += Int(round(det(mat[:,i-1:i])))
	end
	res ÷ 2
end

# ╔═╡ 64e4eb5d-56e4-44b7-a693-c6436528c9d3
md"""The `inside` area is, well, _inside_ the boundary. So we miss half of the boundary… 

And we miss one additional site because of the curvature of the boundary:
If we turn left, the inside only covers 1/4 of a pixel, while we get 3/4 of a pixel on right turns.
In total there are 4 more left turns than right turns…
"""

# ╔═╡ aeda89b0-16e7-452a-a986-0f3bd66bde1b
area(indices, boundary) = inside(indices) + boundary ÷ 2 + 1

# ╔═╡ e0f2cef6-5872-48de-b51c-6e6ac632cc1e
in1 |> compute_boundary |> x->area(x...)

# ╔═╡ 2b7bfecc-87a6-4674-9b59-6ac625cebb51
md"""## Part II

if you know this clever formula, there isn't anything more to do, really!"""

# ╔═╡ 49770dae-ec72-4b07-bfe2-8a5a39c88f5b
directions = [:R, :D, :L, :U]

# ╔═╡ 9a2839af-2f5e-422b-b96f-1ed58900ed95
in2 = input .|> 
	x->split(x)[end] .|> 
	x->[directions[Base.parse(Int, x[end-1])+1], Base.parse(Int, x[3:end-2], base=16)]

# ╔═╡ 2696a7cd-898d-4696-a1a5-bc112b11372d
in2 |> compute_boundary |> x->area(x...)

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
JuliaSyntax = "70703baa-626e-46a2-a12c-08ffd08c73b4"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[compat]
JuliaSyntax = "~0.4.8"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.4"
manifest_format = "2.0"
project_hash = "a25ff4158f942c398ada4d52e880db0f19233767"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.5+0"

[[deps.JuliaSyntax]]
git-tree-sha1 = "e00e2b013f3bd98d3789f889b9305c1546ecd1ab"
uuid = "70703baa-626e-46a2-a12c-08ffd08c73b4"
version = "0.4.8"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.21+4"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+0"
"""

# ╔═╡ Cell order:
# ╠═c39db7c6-b528-4adf-964c-ff6e21ca307e
# ╠═75085004-9d70-11ee-38f6-6da0c3a3af2b
# ╠═25af5d60-5079-4120-a71f-fe77667e6bb7
# ╠═8d74ed58-3f9d-4af9-a0bf-4bb241bc2546
# ╠═1a522a8e-7213-4365-a135-f55d10e06be7
# ╟─1b86587d-4026-4721-8f38-ac56bfa6df1a
# ╠═b55a3ec1-457e-4062-8abe-a455baddd02f
# ╟─64e4eb5d-56e4-44b7-a693-c6436528c9d3
# ╠═aeda89b0-16e7-452a-a986-0f3bd66bde1b
# ╠═e0f2cef6-5872-48de-b51c-6e6ac632cc1e
# ╟─2b7bfecc-87a6-4674-9b59-6ac625cebb51
# ╠═49770dae-ec72-4b07-bfe2-8a5a39c88f5b
# ╠═9a2839af-2f5e-422b-b96f-1ed58900ed95
# ╠═2696a7cd-898d-4696-a1a5-bc112b11372d
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
