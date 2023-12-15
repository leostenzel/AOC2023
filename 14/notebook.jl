### A Pluto.jl notebook ###
# v0.19.35

using Markdown
using InteractiveUtils

# ╔═╡ bda7e7bd-270b-4ff4-a77f-a6c7b60602cb
using JuliaSyntax

# ╔═╡ d4618478-9a51-11ee-30e7-c729ef2fa58b
input = "input" |> readlines |> stack

# ╔═╡ d0462424-21f3-4a0c-ad60-1b7b91e4a304
function count_shifted(s::AbstractString)
	l = length(s)
	res = 0
	for (p, g) ∈ zip(findall('#', '#'*s), split(s, '#'))
		res += sum(l+2 .- p  .- (1:count('O', g)))
	end
	res
end

# ╔═╡ 8cc96992-6321-4436-992a-caa847b43cfb
count_shifted.(String.(eachrow(input))) |> sum

# ╔═╡ 468f39bf-ccb1-4ba3-b864-9b4d75e2fed9
md"""## Part II"""

# ╔═╡ b467da43-6c5b-4fdb-aed6-5a65dd020ed8
weight(a::AbstractVector) = a |> reverse |> x->findall(==('O'), x) |> sum

# ╔═╡ 9f4ff808-ec4b-4ffe-a82c-6ef009aa3f2d
weight(a::AbstractMatrix) = sum(a |> eachrow .|> weight) 

# ╔═╡ f2e11fa7-335c-4b4e-b4b7-65a4b1cea48b
function shift_left!(a::AbstractVector)
	for pos ∈ findall(==('O'), a)
		start = findprev(!=('.'), a, pos-1)

		isnothing(start) && (start=0)
		pos == start+1 && continue
		
		a[pos] = '.'
		a[start+1] = 'O'
	end
	a
end

# ╔═╡ f6340f46-2366-4936-95e7-88c2ba9b1735
shift_right!(a::AbstractVector) = a |> reverse! |> shift_left! |> reverse!

# ╔═╡ cf524043-50d3-4ce4-bbf3-808c974a6280
shift_north!(mat::AbstractMatrix) = mat |> eachrow .|> shift_left!

# ╔═╡ bdf44a0d-d9e9-47f4-8141-170f424661aa
shift_south!(mat::AbstractMatrix) =  mat |> eachrow .|> shift_right!

# ╔═╡ 305b3ed0-ac6d-4d15-a0d0-66b15f2c337a
shift_east!(mat::AbstractMatrix) =  mat |> eachcol .|> shift_right!

# ╔═╡ 6206997f-d219-41ad-9c8a-a791d103a62f
shift_west!(mat::AbstractMatrix) =  mat |> eachcol .|> shift_left!

# ╔═╡ a1fbe866-9e56-414e-9318-5883098a3c5e
function cycle_nwse(mat::AbstractMatrix)
	mat = copy(mat)
	shift_north!(mat) 
	shift_west!(mat) 
	shift_south!(mat)
	shift_east!(mat)
	mat
end

# ╔═╡ 2fb2ed08-4b2f-49e8-87c6-cf479c40c7fb
Base.hash(a::AbstractMatrix{<:AbstractChar}) = a |> eachrow .|> String |> Tuple |> hash

# ╔═╡ f7437cbc-a18d-42d0-a98e-cfd39ddc4214
md"""We don't want to run a full 1000000000 steps, but since the process is Markovian, we will surely hit a limit cycle at some point.

So let's find the period of that cycle:
"""

# ╔═╡ 538564c9-10be-4dfe-b704-e450449372c7
function find_period(input) 
	input = copy(input)
	
	weights = Dict{Int,Int}()
	hashes = Dict{UInt,Int}()
	
	for i ∈ 1:10_000_000
		tmp = cycle_nwse(input)
		tmp == input && break

		w = weight(tmp)
		h = hash(tmp)
		
		h ∈ keys(hashes) && return i - hashes[h], weights
		
		hashes[h] = i
		weights[i] = w
		
		input = tmp
	end
end

# ╔═╡ 5dae6c6a-09b8-41e1-b686-b013af5b4f74
period, weights = find_period(input)

# ╔═╡ f1122f16-9482-4df1-8572-c2ff70429877
mkey = maximum(keys(weights))

# ╔═╡ ed7c9499-7ed3-46eb-99e4-731f1aeb0b39
md"""
Extracting the weight… can be tricky to get it right:

From the last step of our simulation, we repeat the loop a number of times (doesn't matter), and are left with some later steps: `(1_000_000_000-mkey) % period` to be precise.

The beginning of the period is at `mkey-period` so we need to add the previously found number of steps to this value:
"""

# ╔═╡ 7c3eba88-cb19-4506-b3e8-d6d9b23473f5
weights[mkey - period + (1_000_000_000-mkey) % period]

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
# ╠═bda7e7bd-270b-4ff4-a77f-a6c7b60602cb
# ╠═d4618478-9a51-11ee-30e7-c729ef2fa58b
# ╠═d0462424-21f3-4a0c-ad60-1b7b91e4a304
# ╠═8cc96992-6321-4436-992a-caa847b43cfb
# ╠═468f39bf-ccb1-4ba3-b864-9b4d75e2fed9
# ╠═b467da43-6c5b-4fdb-aed6-5a65dd020ed8
# ╠═9f4ff808-ec4b-4ffe-a82c-6ef009aa3f2d
# ╠═f2e11fa7-335c-4b4e-b4b7-65a4b1cea48b
# ╠═f6340f46-2366-4936-95e7-88c2ba9b1735
# ╠═cf524043-50d3-4ce4-bbf3-808c974a6280
# ╠═bdf44a0d-d9e9-47f4-8141-170f424661aa
# ╠═305b3ed0-ac6d-4d15-a0d0-66b15f2c337a
# ╠═6206997f-d219-41ad-9c8a-a791d103a62f
# ╠═a1fbe866-9e56-414e-9318-5883098a3c5e
# ╠═2fb2ed08-4b2f-49e8-87c6-cf479c40c7fb
# ╟─f7437cbc-a18d-42d0-a98e-cfd39ddc4214
# ╠═538564c9-10be-4dfe-b704-e450449372c7
# ╠═5dae6c6a-09b8-41e1-b686-b013af5b4f74
# ╠═f1122f16-9482-4df1-8572-c2ff70429877
# ╟─ed7c9499-7ed3-46eb-99e4-731f1aeb0b39
# ╠═7c3eba88-cb19-4506-b3e8-d6d9b23473f5
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
