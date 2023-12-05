### A Pluto.jl notebook ###
# v0.19.32

using Markdown
using InteractiveUtils

# ╔═╡ 59dd4339-6c9e-4214-9f9c-c837f1762692
using JuliaSyntax, DataStructures

# ╔═╡ c7ba091c-93a2-11ee-1f81-0d504adbce54
struct Interval{T<:Integer} 
	start::T
	stop::T
	Interval(a::T, b::T) where {T<:Integer} = a <= b ? new{T}(a, b) : nothing
end

# ╔═╡ 560901b7-3b29-4992-9775-0edcb2283da7
Base.minimum(a::Interval{<:Integer}) = a.start

# ╔═╡ 6ad09202-860b-414f-a5aa-364fecb22462
Base.maximum(a::Interval{<:Integer}) = a.stop

# ╔═╡ 78841661-2924-4392-a1a6-50982c0ac18d
Base.:∈(a::T, b::Interval{T}) where {T<:Integer} = minimum(b) <= a <= maximum(b)

# ╔═╡ 81f3f0ab-560e-4b9e-900d-7415c90de2ba
Base.:∩(a::Interval{T}, b::Interval{T}) where {T<:Integer} = 
	Interval(max(minimum(a), minimum(b)), min(maximum(a), maximum(b)))

# ╔═╡ d89aae30-7593-4e3e-879d-82bf193432fd
Base.:∩(a::Interval{T}, b::Set{Interval{T}}) where {T<:Integer} = Set((a,) .∩ b)

# ╔═╡ 714079a5-9ed4-454c-8cc6-b67c74bf0281
Base.:∩(b::Set{Interval{T}}, a::Interval{T}) where {T<:Integer} = Set((a,) .∩ b)

# ╔═╡ 27c7e269-50df-4fac-b5dd-b7bd1c97e99e
Base.:∩(::Union{Set{Interval{T}}, Interval{T}}, ::Nothing) where {T<:Integer} = nothing

# ╔═╡ 99750c7d-bc26-40ca-a55a-a4c2c2eb0be3
Base.:∩(::Nothing, ::Union{Set{Interval{T}}, Interval{T}}) where {T<:Integer} = nothing

# ╔═╡ 57632dc3-c7e0-489e-97e2-20063be4651a
Base.:∩(::Nothing, ::Nothing) = nothing

# ╔═╡ 75e67827-efa8-4ca8-b0ad-96816c19f402
Base.:∪(a::Interval{T}, b::Set{Interval{T}}) where {T<:Integer} = push!(b, a)

# ╔═╡ 15936ce5-0a8a-4ec1-aa2c-db37e3fcc6d7
Base.:∪(b::Set{Interval{T}}, a::Interval{T}) where {T<:Integer} = push!(b, a)

# ╔═╡ baa637f9-2c86-4e91-a148-899fafc863e5
Base.:∪(::Nothing, a::Union{Interval{T}, Set{Interval{T}}}) where {T<:Integer} = a

# ╔═╡ 4bfeb17a-38b9-4c11-a9ee-a84556360ba0
Base.:∪(::Nothing, ::Nothing) = nothing

# ╔═╡ a9e51885-4cb1-46fe-91ab-1142288ad7cd
Base.:∪(a::Union{Interval{T}, Set{Interval{T}}}, ::Nothing) where {T<:Integer} = a

# ╔═╡ 07b17b05-16f8-4fc2-a43c-a9ad4fdf34ce
Base.:∪(a::Set{Interval{T}}, b::Set{Interval{T}}) where {T<:Integer} = union(b, a)

# ╔═╡ 841f6895-8905-4045-9c9d-6ab7a4a31b00
begin
	struct Entry{T} 
		interval::Union{Interval{T}, Set{Interval{T}}} 
		diff::T
	end
	(a::Entry)(b::Integer) = b ∈ a.interval ? b + a.diff : error()
	(a::Entry)(b::Interval) = Interval(minimum(b) + a.diff, maximum(b) + a.diff)
	Base.:∈(a::Integer, b::Entry) = ∈(a, b.interval)
	Base.:∩(a::Union{Interval{T}, Set{Interval{T}}}, b::Entry) where {T<:Integer} = a ∩ b.interval
end

# ╔═╡ 36c9912c-36ee-4f98-88eb-4cfe8fea4b8f
function Base.:∪(a::Interval, b::Interval) 
	!isnothing(a ∩ b) && return Interval(
		min(minimum(a), minimum(b)), 
		max(maximum(a), maximum(b)))

	return Set([a, b])
end

# ╔═╡ c3afff72-f286-4cdd-8172-fb88ec3062e3
function Base.setdiff(a::Interval{T}, b::Interval{T}) where {T<:Integer}
	inter = a ∩ b
	Interval(minimum(a), minimum(inter)-1) ∪ Interval(maximum(inter)+1, maximum(a))
end

# ╔═╡ e7bd1c4c-0fd4-4465-8943-87f4778fddd1
inp = readlines("input");

# ╔═╡ b52330ea-a9a7-417d-927b-5c7549312f68
begin
	dict = DefaultDict{String, Vector{Entry}}([])
	global key_strings = String[]
	for line ∈ inp[3:end]
		isempty(line) && continue
	
		if occursin("map", line)
			push!(key_strings, split(line)[1])
		else
			vals = line |> split .|> x->Base.parse(Int, x)
			push!(dict[key_strings[end]], 
				Entry(Interval(vals[2], vals[2] + vals[3]-1), vals[1]-vals[2]))
		end
	end
end

# ╔═╡ 7f13cd4c-91ba-433a-85cc-8a9be63564e8
function seed2location(seed::Integer)
	val = seed
	for key in key_strings
		entry = findfirst(e->val ∈ e, dict[key])
		if !isnothing(entry)
			val = dict[key][entry](val)
		end
	end
	val
end

# ╔═╡ 1b8a8c2a-e1fb-4855-aa8e-8a2b4e155c4f
seeds = split(inp[1], ':')[end] |> split .|> x->Base.parse(Int, x);

# ╔═╡ ced41694-32a1-4449-b3c6-4a7ad8932d0d
begin
	seeds2 = []
	for (a, b) ∈ eachcol(reshape(seeds, 2, 10))
		push!(seeds2, Interval(a, a+b))
	end
	seeds2
end

# ╔═╡ 6fac10ea-4ad7-4b9f-9c7a-7a299c2578c7
function seed2location(seed::Union{Interval{T}, Set{Interval{T}}}) where {T}
	val = seed
	for key in key_strings
		new_val = Set{Interval{T}}()
		for entry in dict[key]
			tmp = intersect(val, entry.interval)
			isnothing(tmp) && continue
	
			@show val, tmp
			val = setdiff(val, tmp)

			@show val
			
			new_val = union(new_val, entry(tmp))
		end
		val = union(val, new_val)
	end
	val
end

# ╔═╡ e85ca572-a28b-4e20-83c0-74a549ad5aa2
seed2location.(seeds) |> minimum

# ╔═╡ 7078cd8f-27a6-4d3b-8602-8a0e2e28ecec
res2 = seed2location(seeds2[1])

# ╔═╡ 7de3308d-d396-4c6e-b981-841b9cafdb62
Set{Interval{Int}}()

# ╔═╡ 18784764-8a8d-4137-baf6-2d692894e72f
a = Interval(1212568077, 1327462358)

# ╔═╡ d7c79956-95df-40fe-8f0f-1074917f6083
b = Interval(1212568077, 1251723992)

# ╔═╡ 2d0808b4-d435-423d-b0c3-caef8be842d8
intersect(a, b)

# ╔═╡ a62ab9c8-9d7b-46f0-a556-c775b3e47e89
setdiff(a, b)

# ╔═╡ 74fa7145-49c7-4819-a55f-e3523612dda0
Set([nothing]) .|> isnothing |> all

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
DataStructures = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
JuliaSyntax = "70703baa-626e-46a2-a12c-08ffd08c73b4"

[compat]
DataStructures = "~0.18.15"
JuliaSyntax = "~0.4.7"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.4"
manifest_format = "2.0"
project_hash = "877ad2558e908e28c89faa4b27d644b11d5ff263"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.Compat]]
deps = ["UUIDs"]
git-tree-sha1 = "886826d76ea9e72b35fcd000e535588f7b60f21d"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.10.1"

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

    [deps.Compat.weakdeps]
    Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
    LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "3dbd312d370723b6bb43ba9d02fc36abade4518d"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.15"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.JuliaSyntax]]
git-tree-sha1 = "1a4857ab55396b2da745f07f76ce4e696207b740"
uuid = "70703baa-626e-46a2-a12c-08ffd08c73b4"
version = "0.4.7"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.OrderedCollections]]
git-tree-sha1 = "dfdf5519f235516220579f949664f1bf44e741c5"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.6.3"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
"""

# ╔═╡ Cell order:
# ╠═59dd4339-6c9e-4214-9f9c-c837f1762692
# ╠═c7ba091c-93a2-11ee-1f81-0d504adbce54
# ╠═560901b7-3b29-4992-9775-0edcb2283da7
# ╠═6ad09202-860b-414f-a5aa-364fecb22462
# ╠═78841661-2924-4392-a1a6-50982c0ac18d
# ╠═81f3f0ab-560e-4b9e-900d-7415c90de2ba
# ╠═d89aae30-7593-4e3e-879d-82bf193432fd
# ╠═714079a5-9ed4-454c-8cc6-b67c74bf0281
# ╠═27c7e269-50df-4fac-b5dd-b7bd1c97e99e
# ╠═99750c7d-bc26-40ca-a55a-a4c2c2eb0be3
# ╠═57632dc3-c7e0-489e-97e2-20063be4651a
# ╠═36c9912c-36ee-4f98-88eb-4cfe8fea4b8f
# ╠═75e67827-efa8-4ca8-b0ad-96816c19f402
# ╠═15936ce5-0a8a-4ec1-aa2c-db37e3fcc6d7
# ╠═baa637f9-2c86-4e91-a148-899fafc863e5
# ╠═4bfeb17a-38b9-4c11-a9ee-a84556360ba0
# ╠═a9e51885-4cb1-46fe-91ab-1142288ad7cd
# ╠═07b17b05-16f8-4fc2-a43c-a9ad4fdf34ce
# ╠═c3afff72-f286-4cdd-8172-fb88ec3062e3
# ╠═841f6895-8905-4045-9c9d-6ab7a4a31b00
# ╠═e7bd1c4c-0fd4-4465-8943-87f4778fddd1
# ╠═b52330ea-a9a7-417d-927b-5c7549312f68
# ╠═7f13cd4c-91ba-433a-85cc-8a9be63564e8
# ╠═1b8a8c2a-e1fb-4855-aa8e-8a2b4e155c4f
# ╠═e85ca572-a28b-4e20-83c0-74a549ad5aa2
# ╠═ced41694-32a1-4449-b3c6-4a7ad8932d0d
# ╠═6fac10ea-4ad7-4b9f-9c7a-7a299c2578c7
# ╠═7078cd8f-27a6-4d3b-8602-8a0e2e28ecec
# ╠═7de3308d-d396-4c6e-b981-841b9cafdb62
# ╠═18784764-8a8d-4137-baf6-2d692894e72f
# ╠═d7c79956-95df-40fe-8f0f-1074917f6083
# ╠═2d0808b4-d435-423d-b0c3-caef8be842d8
# ╠═a62ab9c8-9d7b-46f0-a556-c775b3e47e89
# ╠═74fa7145-49c7-4819-a55f-e3523612dda0
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
