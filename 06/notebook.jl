### A Pluto.jl notebook ###
# v0.19.32

using Markdown
using InteractiveUtils

# ╔═╡ c0cd1d72-120a-4fa7-9b2d-e50f144a287d
using DelimitedFiles

# ╔═╡ c14ce566-93fe-11ee-386f-510efa27fe4f
inp = ("input" |> readdlm)[:, 2:end] |> Matrix{Int}

# ╔═╡ c94709d2-6fa9-4de8-b22f-bc8df7ad712a
check_solution(duration, time, dist) = duration * (time - duration) > dist

# ╔═╡ ddcf018a-e89b-4f7d-bddf-db3b4c339df2
md"$\frac{-b\pm \sqrt{b^2-4ac}}{2a}$"

# ╔═╡ cfec3774-38ac-4fa8-b84e-37c832908e32
float_solutions(time, dist) = (-time .+ [1, -1] * √(time^2-4*dist)) / -2 

# ╔═╡ 9f349a89-c4dd-400f-8376-8a3d9deca66b
begin
	res = 1
	for col ∈ eachcol(inp)
		f = findfirst(x -> check_solution(x, col...), 1:col[2])
		l = findlast(x -> check_solution(x, col...), 1:col[2])
		@show f, l
		@show float_solutions(col...)
		res *= l-f + 1
	end
	res
end

# ╔═╡ b6e35029-4f33-4ddd-a001-934a853e118d
md"## part II"

# ╔═╡ b68a885b-f3cc-485e-ba5f-9fab9a18962b
inf_solution(time, dist) = dist ÷ time

# ╔═╡ 9c589240-428d-4764-bacd-2e9e22ddc90c
sup_solution(time, dist) = time - inf_solution(time, dist)

# ╔═╡ 5d507ab4-890d-471a-ad0f-5225f58426f4
inp2 = prod(readdlm("input", String)[:, 2:end]; dims=2) .|> x->parse(BigInt, x) 

# ╔═╡ 9fab67bc-ac8f-49ab-824c-b1e51b94a42d
md"We should be using something like bisection here, but it's working, so let's not bother."

# ╔═╡ cefe1b20-5c86-493e-9a93-25e42d2cff32
function min_solution(time, dist)
	tmp = inf_solution(time, dist)
	findfirst(x -> check_solution(x, inp2...), tmp:inp2[2]) + tmp - 1
end

# ╔═╡ 6b5b86a5-fc59-4a95-8e8e-9ed235c53981
function max_solution(time, dist)
	tmp = sup_solution(time, dist)
	findlast(x -> check_solution(x, inp2...), 1:tmp)
end

# ╔═╡ 9889409f-6b1d-4dbf-ae33-51dacf88c905
@show min_solution(inp2...), max_solution(inp2...)

# ╔═╡ 855c43cc-4911-4083-a807-6e73ddc6e835
(float_solutions(inp2...) .|> (ceil, floor) .|> Int |> diff)[] + 1

# ╔═╡ d0446ce2-0030-459f-a34f-e14628fc6597
max_solution(inp2...) - min_solution(inp2...) + 1

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DelimitedFiles = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[compat]
DelimitedFiles = "~1.9.1"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.4"
manifest_format = "2.0"
project_hash = "eb696dba116621a072d91c57084a363ced7654e8"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
"""

# ╔═╡ Cell order:
# ╠═c0cd1d72-120a-4fa7-9b2d-e50f144a287d
# ╠═c14ce566-93fe-11ee-386f-510efa27fe4f
# ╠═c94709d2-6fa9-4de8-b22f-bc8df7ad712a
# ╠═ddcf018a-e89b-4f7d-bddf-db3b4c339df2
# ╠═cfec3774-38ac-4fa8-b84e-37c832908e32
# ╠═9f349a89-c4dd-400f-8376-8a3d9deca66b
# ╟─b6e35029-4f33-4ddd-a001-934a853e118d
# ╠═9c589240-428d-4764-bacd-2e9e22ddc90c
# ╠═b68a885b-f3cc-485e-ba5f-9fab9a18962b
# ╠═5d507ab4-890d-471a-ad0f-5225f58426f4
# ╟─9fab67bc-ac8f-49ab-824c-b1e51b94a42d
# ╠═cefe1b20-5c86-493e-9a93-25e42d2cff32
# ╠═6b5b86a5-fc59-4a95-8e8e-9ed235c53981
# ╠═9889409f-6b1d-4dbf-ae33-51dacf88c905
# ╠═d0446ce2-0030-459f-a34f-e14628fc6597
# ╠═855c43cc-4911-4083-a807-6e73ddc6e835
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
