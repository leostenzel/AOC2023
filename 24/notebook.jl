### A Pluto.jl notebook ###
# v0.19.36

using Markdown
using InteractiveUtils

# ╔═╡ 666bf9df-0f23-40ec-a61d-b78bcb5eece5
using LinearAlgebra

# ╔═╡ 8a5c7614-a224-11ee-385d-99c076e7dfb7
input = "input" |> readlines

# ╔═╡ aa7cf25f-019b-480a-a4cb-1a562b583924
struct Hailstone{T}
	x::Vector{T}
	v::Vector{T}
end

# ╔═╡ c1f106b2-42bf-400f-8ea8-2c293108fd00
stones = input .|> 
	x->split(x, '@') .|> 
	(x->split(x, ',') .|>
	 x->replace(x, ' '=>"") |>
	 x->Base.parse(Int, x)) |> 
	x->Hailstone(x...)

# ╔═╡ c1a0d4b0-e1b5-4f75-bd22-38c59a96b803
function intersect2d(xa, va, xb, vb)
	va == vb && return (Inf, Inf)
	
	t = det(hcat(xa .- xb, - vb))
	
	t /= det(hcat(-va, -vb))
	
	t < 0 && return (Inf, Inf)

	inter = xa .+ t*va

	(inter[1] - xb[1]) / vb[1] < 0 && return (Inf, Inf)

	inter
end

# ╔═╡ 348d60a6-035e-473e-83b2-35df7fed327e
intersect2d(a::Hailstone, b::Hailstone) = 
	intersect2d(a.x[1:2], a.v[1:2], b.x[1:2], b.v[1:2])

# ╔═╡ 5bbe7deb-121b-4ce2-9933-d0b4fe9c111e
let
	res = 0
	xymin = 200000000000000
	xymax = 400000000000000

	for (i, stonei) ∈ enumerate(stones[begin:end-1])
		for stonej ∈ stones[i+1:end]
			inter = intersect2d(stonei, stonej)
			if xymin < inter[1] < xymax &&
				xymin < inter[2] < xymax
				res += 1
			end
		end
	end
	res
end

# ╔═╡ 5a82f083-409a-4214-a1ca-24766aebc48c
md"## Part II"

# ╔═╡ 0e5b0218-60f6-432f-b957-685fb659de11
md"""
A hailstone $i$ ($\vec x_i, \vec v_i$) collides with the rock ($\vec x, \vec v$) at time $t_i$ iff

$$\vec{x}_i +\vec{v}_i t_i = \vec x + \vec v t_i$$
"""

# ╔═╡ 4142fad3-4aa9-42b9-a40f-0cbfed5dc9a5
md"""
$$\vec x- \vec x_i = t_i(\vec v_i-\vec v)$$
"""

# ╔═╡ dd6563e5-dbb2-4662-9973-6aa9786e7ded
md"""
$$(\vec v_i-\vec v)\times(\vec x- \vec x_i) = 0$$
"""

# ╔═╡ 13d8b6d3-8cb8-4bf3-a4ff-12f49cb168a0
md"""
Expanding the cross product yields,

$$\vec v_i\times \vec x - \vec v_i\times \vec x_i - \vec v \times\vec x+ \vec v\times \vec x_i = 0\,.$$
"""

# ╔═╡ efaa0123-c51d-4d27-b6bf-0509758bfe25
md"""
$$\vec v_i\times \vec x - \vec v \times\vec x+ \vec v\times \vec x_i = \vec v_i\times \vec x_i\,.$$
"""

# ╔═╡ 06967631-8785-4b6f-8ae2-91f58b3cea24
md"""There is a non-linear term $\vec v\times \vec x$, but it's the same for every hailstone, so we can get rid of it by subtracting the equations for hailstone $i$ and $l$:"""

# ╔═╡ 1393da01-032f-412f-8af7-3a7a22a9c7ba
md"""$$(\vec v_l- \vec v_i) \times \vec x - (\vec x_l -\vec x_i) \times \vec v = \vec v_l\times \vec x_l - \vec v_i\times \vec x_i$$"""

# ╔═╡ 10da55e8-c123-45d6-8dd6-60f7ec45ed57
md"""We can compute the right-hand side directly, for any two hailstones, """

# ╔═╡ 22b24dd5-6289-4069-8e08-532d50f5ba9c
rhs(a::Hailstone, b::Hailstone) = cross(a.v, a.x) - cross(b.v, b.x) 

# ╔═╡ 0a03bcb3-66db-40cc-821c-f24f849d8858
md"""But we want to get rid of the cross product on the left-hand side, because I don't know how to use it directly with `\`.

Following the [wikipedia article](https://en.wikipedia.org/wiki/Cross_product#Alternative_ways_to_compute), we can find a matrix $[a]_\times$ such that $\vec a\times \vec b = [a]_\times \vec b$, i.e., as normal matrix-vector multiplication:
"""

# ╔═╡ 8b1dc0ba-f473-4522-85ee-9ca4554f0324
cross_matrix(a::AbstractVector) = [ 0  -a[3] a[2]
	  							   a[3]  0  -a[1]
	 							  -a[2] a[1]  0  ]

# ╔═╡ 7d678802-4bb1-4596-98a3-79a3c45ac342
md"""To obtain the left-hand side as matrix-vector multiplication we concatinate the `cross_matrix` for the relative velocity and relative position horizontally:"""

# ╔═╡ ccd5eceb-af13-441a-8790-41d3e8ca2c00
lhs(a::Hailstone, b::Hailstone) = 
	hcat(cross_matrix(a.v - b.v), -cross_matrix(a.x - b.x))

# ╔═╡ a1e36033-b236-4473-8320-85d945c612d9
md"""We need to use at least three hailstones to find the solution. But using more shouldn't change the result…"""

# ╔═╡ fe4f9522-f938-4407-a77c-defe4fd5e490
n_stones = 3

# ╔═╡ 92788642-14c2-4580-9fa1-658a2e63ee65
A = vcat(lhs.(stones[1:n_stones-1], stones[2:n_stones])...)

# ╔═╡ 64b961fe-0e9e-4054-85d9-ff64d0bc554e
b = vcat(rhs.(stones[1:n_stones-1], stones[2:n_stones])...)

# ╔═╡ 5e7c138c-1224-40a5-92d5-c5329a08b52e
res = A \ b

# ╔═╡ 55cfe97a-1ffd-4bc5-9378-d953ed2b21bd
res[1:3] .|> round .|> Int |> sum 

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.10.0"
manifest_format = "2.0"
project_hash = "ac1187e548c6ab173ac57d4e72da1620216bce54"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.0.5+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.23+2"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.8.0+1"
"""

# ╔═╡ Cell order:
# ╠═666bf9df-0f23-40ec-a61d-b78bcb5eece5
# ╠═8a5c7614-a224-11ee-385d-99c076e7dfb7
# ╠═aa7cf25f-019b-480a-a4cb-1a562b583924
# ╠═c1f106b2-42bf-400f-8ea8-2c293108fd00
# ╠═c1a0d4b0-e1b5-4f75-bd22-38c59a96b803
# ╠═348d60a6-035e-473e-83b2-35df7fed327e
# ╠═5bbe7deb-121b-4ce2-9933-d0b4fe9c111e
# ╟─5a82f083-409a-4214-a1ca-24766aebc48c
# ╟─0e5b0218-60f6-432f-b957-685fb659de11
# ╟─4142fad3-4aa9-42b9-a40f-0cbfed5dc9a5
# ╟─dd6563e5-dbb2-4662-9973-6aa9786e7ded
# ╟─13d8b6d3-8cb8-4bf3-a4ff-12f49cb168a0
# ╟─efaa0123-c51d-4d27-b6bf-0509758bfe25
# ╟─06967631-8785-4b6f-8ae2-91f58b3cea24
# ╟─1393da01-032f-412f-8af7-3a7a22a9c7ba
# ╟─10da55e8-c123-45d6-8dd6-60f7ec45ed57
# ╠═22b24dd5-6289-4069-8e08-532d50f5ba9c
# ╟─0a03bcb3-66db-40cc-821c-f24f849d8858
# ╠═8b1dc0ba-f473-4522-85ee-9ca4554f0324
# ╟─7d678802-4bb1-4596-98a3-79a3c45ac342
# ╠═ccd5eceb-af13-441a-8790-41d3e8ca2c00
# ╟─a1e36033-b236-4473-8320-85d945c612d9
# ╠═fe4f9522-f938-4407-a77c-defe4fd5e490
# ╠═92788642-14c2-4580-9fa1-658a2e63ee65
# ╠═64b961fe-0e9e-4054-85d9-ff64d0bc554e
# ╠═5e7c138c-1224-40a5-92d5-c5329a08b52e
# ╠═55cfe97a-1ffd-4bc5-9378-d953ed2b21bd
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
