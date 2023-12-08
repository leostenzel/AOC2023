### A Pluto.jl notebook ###
# v0.19.32

using Markdown
using InteractiveUtils

# ╔═╡ 59dd4339-6c9e-4214-9f9c-c837f1762692
using JuliaSyntax

# ╔═╡ 92042062-da17-4b3a-a93f-05f7b203205c
abstract type AbstractInterval{T} end

# ╔═╡ fc6f75c5-80dd-469c-89e2-e59820ce13ad
struct EmptyInterval{T} <: AbstractInterval{T} end

# ╔═╡ 32d92df7-8df5-4558-9c55-a36efca323ea
begin
	Base.isempty(AbstractInterval) = false
	Base.isempty(EmptyInterval) = true
end

# ╔═╡ c7ba091c-93a2-11ee-1f81-0d504adbce54
struct Interval{T<:Integer} <: AbstractInterval{T}
	start::T
	stop::T
	Interval(a::T, b::T) where {T<:Integer} = a <= b ? new{T}(a, b) : EmptyInterval{T}()
end

# ╔═╡ 88d37adb-6e18-4594-a9a6-febb08313b03
Base.:∈(i::T, inter::Interval) where {T<: Integer} = inter.start <= i <= inter.stop

# ╔═╡ 16493a49-20ec-4a77-bdf2-96edaf76437d
inp = readlines("input");

# ╔═╡ 40845d48-1f0a-4563-8cf0-45b440fcc474
seeds = split(inp[1], ':')[end] |> split .|> x->Base.parse(Int, x);

# ╔═╡ 0faf3b9a-47ab-4014-83b0-a089a6880e52
Base.:⊆(a::Interval, b::Interval) = b.start <= a.start && a.stop <= b.stop

# ╔═╡ 579b3dc5-bbdf-4c00-8a01-7d7c5caed94f
Base.:+(a::Interval, b::Integer) = Interval(a.start + b, a.stop + b)

# ╔═╡ 102dbfff-97e4-4b17-8c5d-e43c4edd3dff
begin
	struct Piece{T<:Integer}
		interval::AbstractInterval{T}
		diff::T
	end
	Piece(dest::T, src::T, rge::T) where {T<:Integer} = 
		Piece{T}(Interval(src, src+rge-one(T)), dest-src)
end

# ╔═╡ d2661415-b0ef-4b0b-bd99-884bc74012ab
begin
	# Piecewise Affine Dictionary
	struct PADict{T<:Integer}
		segments::Vector{Piece{T}}
	end
	PADict{T}() where {T<:Integer} = PADict{T}(Piece{T}[])
end

# ╔═╡ 1c4d0f88-3df5-4a47-8d48-38922db6bd2c
Base.:∈(i::T, p::Piece{T}) where {T<: Integer} = i ∈ p.interval

# ╔═╡ 577f7552-eef3-4da0-bafb-47feecb67263
begin
	dict = Dict{String, PADict{Int}}()
	global mapkeys = String[]
	for line ∈ inp[3:end]
		isempty(line) && continue
	
		if occursin("map", line) 
			push!(mapkeys, line)
			dict[mapkeys[end]] = PADict{Int}()
		else
			vals = line |> split .|> x->Base.parse(Int, x)

			push!(dict[mapkeys[end]].segments, Piece(vals...))
		end
	end
end

# ╔═╡ 0b4eb17f-1864-4ae9-9038-c6826e9e4e73
function apply_maps(seed)
	for key in mapkeys
		seed = dict[key][seed]
	end
	seed
end

# ╔═╡ 777d07aa-a439-4afa-9940-b8837b731659
Base.getindex(a::Piece, b::Interval) = b ⊆ a.interval ? b + a.diff : error() 

# ╔═╡ 8702e836-30a3-40e3-9053-74ef335f518e
Base.:∩(a::Interval, b::Interval) = 
	Interval(max(a.start, b.start), min(a.stop, b.stop))

# ╔═╡ 800894e3-794c-48a3-92d8-acad733c85fc
Base.:∩(a::Interval, b::Piece) = a ∩ b.interval

# ╔═╡ 3c50deb2-4c84-43cd-9985-95ad8356f0db


# ╔═╡ 560901b7-3b29-4992-9775-0edcb2283da7
Base.minimum(a::Interval{<:Integer}) = a.start

# ╔═╡ a5d478ee-815c-402d-804a-d6f80ccc805f
apply_maps.(seeds) |> minimum

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

# ╔═╡ 285bc16b-5d0b-4340-84d8-8c783fbf61c3
function Base.getindex(d::PADict{T}, idx::T) where {T<:Integer}
	for seg in d.segments
		idx ∈ seg && return seg[idx]
	end
	idx
end

# ╔═╡ b148ad43-c4fb-427a-bf2a-61b3ecb393a8
Base.getindex(p::Piece, i::Integer) = i ∈ p ? i + p.diff : error()

# ╔═╡ a3f10ba2-c452-432c-99f9-174075ecbfe1
function Base.getindex(a::PADict{T}, b::Interval{T}) where {T<:Integer}
	b = Interval{T}[b]
	b2 = Interval{T}[]
	for seg ∈ a.segments
		for bᵢ ∈ b
			tmp = bᵢ ∩ seg
			if !isempty(tmp)
				push!(b2, seg[tmp])
				# remove bᵢ from b
				# append the setdiff bᵢ \ tmp to b 
			end
		end
	end
	push!(b2, b) 
end

# ╔═╡ 07da6639-6b5f-44f0-a699-f0a83e436fc8
md"Let's define some data structures"

# ╔═╡ 99a2d6b6-9ff4-477c-87d0-1eec670f9655
md"Now let's actually solve the problem…"

# ╔═╡ 97f4b9ac-2e77-4b59-a275-63c52aa74653
md"I parse the input into a dictionary with the map names as keys… not ideal, because I also need to keep track of the order of keys. Maybe just a vector?"

# ╔═╡ 288e0a8e-e3d7-43a5-a982-af2701f90ed9
md"""## Part II
Now the fun part begins, and we redefine our functionality from `Int` to `Intervals`
"""

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
# ╠═╡ disabled = true
#=╠═╡
inp = readlines("input");
  ╠═╡ =#

# ╔═╡ 1b8a8c2a-e1fb-4855-aa8e-8a2b4e155c4f


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
# ╠═59dd4339-6c9e-4214-9f9c-c837f1762692
# ╟─07da6639-6b5f-44f0-a699-f0a83e436fc8
# ╠═92042062-da17-4b3a-a93f-05f7b203205c
# ╠═fc6f75c5-80dd-469c-89e2-e59820ce13ad
# ╠═32d92df7-8df5-4558-9c55-a36efca323ea
# ╠═c7ba091c-93a2-11ee-1f81-0d504adbce54
# ╠═102dbfff-97e4-4b17-8c5d-e43c4edd3dff
# ╠═d2661415-b0ef-4b0b-bd99-884bc74012ab
# ╠═285bc16b-5d0b-4340-84d8-8c783fbf61c3
# ╠═b148ad43-c4fb-427a-bf2a-61b3ecb393a8
# ╠═1c4d0f88-3df5-4a47-8d48-38922db6bd2c
# ╠═88d37adb-6e18-4594-a9a6-febb08313b03
# ╟─99a2d6b6-9ff4-477c-87d0-1eec670f9655
# ╠═16493a49-20ec-4a77-bdf2-96edaf76437d
# ╠═40845d48-1f0a-4563-8cf0-45b440fcc474
# ╟─97f4b9ac-2e77-4b59-a275-63c52aa74653
# ╠═577f7552-eef3-4da0-bafb-47feecb67263
# ╠═0b4eb17f-1864-4ae9-9038-c6826e9e4e73
# ╠═a5d478ee-815c-402d-804a-d6f80ccc805f
# ╟─288e0a8e-e3d7-43a5-a982-af2701f90ed9
# ╠═0faf3b9a-47ab-4014-83b0-a089a6880e52
# ╠═777d07aa-a439-4afa-9940-b8837b731659
# ╠═579b3dc5-bbdf-4c00-8a01-7d7c5caed94f
# ╠═8702e836-30a3-40e3-9053-74ef335f518e
# ╠═800894e3-794c-48a3-92d8-acad733c85fc
# ╠═3c50deb2-4c84-43cd-9985-95ad8356f0db
# ╠═a3f10ba2-c452-432c-99f9-174075ecbfe1
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
