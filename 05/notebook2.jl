### A Pluto.jl notebook ###
# v0.19.32

using Markdown
using InteractiveUtils

# ╔═╡ 59dd4339-6c9e-4214-9f9c-c837f1762692
using JuliaSyntax

# ╔═╡ a2d2dd08-1e50-4433-acc2-0598d8369f23
abstract type AbstractInterval end

# ╔═╡ f3e900cc-ede1-43f2-b1ad-8ba23f39fc1d
struct EmptyInterval <: AbstractInterval end

# ╔═╡ c7ba091c-93a2-11ee-1f81-0d504adbce54
struct Interval{T<:Integer} <: AbstractInterval
	start::T
	stop::T
	Interval(start::T, stop::T) where {T<:Integer} = 
		start <= stop ? new{T}(start, stop) : EmptyInterval()
end

# ╔═╡ 555ee35b-0c3a-40eb-9e46-7a4558b92daf
Base.isempty(::AbstractInterval) = false 

# ╔═╡ 69122591-1b6e-46f1-9ff7-a5b007d5fb8b
Base.isempty(::EmptyInterval) = true

# ╔═╡ 88d37adb-6e18-4594-a9a6-febb08313b03
Base.:∈(i::Integer, inter::Interval) = inter.start <= i <= inter.stop

# ╔═╡ 16493a49-20ec-4a77-bdf2-96edaf76437d
input = readlines("input");

# ╔═╡ 40845d48-1f0a-4563-8cf0-45b440fcc474
seeds = split(input[1], ':')[end] |> split .|> x->Base.parse(Int, x);

# ╔═╡ 579b3dc5-bbdf-4c00-8a01-7d7c5caed94f
Base.:+(a::Interval, b::Integer) = Interval(a.start + b, a.stop + b)

# ╔═╡ 8ee3b66c-3b19-430b-abf6-4ac4c5785347
Base.:+(::EmptyInterval, ::Integer) = EmptyInterval()

# ╔═╡ 102dbfff-97e4-4b17-8c5d-e43c4edd3dff
begin
	struct Piece
		interval::AbstractInterval
		diff
	end
	Piece(dest::T, src::T, rge::T) where {T<:Integer} = 
		Piece(Interval(src, src+rge-one(T)), dest-src)
end

# ╔═╡ d2661415-b0ef-4b0b-bd99-884bc74012ab
begin
	# Piecewise Affine Dictionary
	struct PADict
		segments::Vector{Piece}
	end
	PADict() = PADict(Piece[])
end

# ╔═╡ d9e5a11a-e01e-4b02-b2f1-bbdd511407c4
Base.push!(a::PADict, b) = push!(a.segments, b)

# ╔═╡ 1c4d0f88-3df5-4a47-8d48-38922db6bd2c
Base.:∈(i::Integer, p::Piece) = i ∈ p.interval

# ╔═╡ 285bc16b-5d0b-4340-84d8-8c783fbf61c3
function Base.getindex(d::PADict, idx::Integer) 
	for seg in d.segments
		idx ∈ seg && return seg[idx]
	end
	idx
end

# ╔═╡ 577f7552-eef3-4da0-bafb-47feecb67263
begin
	dicts = PADict[]
	for line ∈ input[3:end]
		isempty(line) && continue

		if occursin("map", line) 
			push!(dicts, PADict())
		else
			vals = line |> split .|> x->Base.parse(Int, x)
			push!(dicts[end], Piece(vals...))
		end
	end
end

# ╔═╡ 0b4eb17f-1864-4ae9-9038-c6826e9e4e73
function apply_maps(seed)
	for d in dicts
		seed = d[seed]
	end
	seed
end

# ╔═╡ b148ad43-c4fb-427a-bf2a-61b3ecb393a8
Base.getindex(p::Piece, i::Integer) = i ∈ p ? i + p.diff : error()

# ╔═╡ 8702e836-30a3-40e3-9053-74ef335f518e
Base.:∩(a::AbstractInterval, b::AbstractInterval) = 
	Interval(max(a.start, b.start), min(a.stop, b.stop))

# ╔═╡ 2cadd759-4022-4eff-a0cf-387bad223c42
Base.:∩(::AbstractInterval, ::EmptyInterval) = EmptyInterva()

# ╔═╡ ff9f8c61-866a-4675-9001-cd0c87f04593
Base.:∩(::EmptyInterval, ::AbstractInterval) = EmptyInterval()

# ╔═╡ 800894e3-794c-48a3-92d8-acad733c85fc
Base.:∩(a::AbstractInterval, b::Piece) = a ∩ b.interval

# ╔═╡ db89423c-1819-4a97-8597-f0ca49809012
Base.:∩(b::Piece, a::AbstractInterval) = a ∩ b.interval

# ╔═╡ 777d07aa-a439-4afa-9940-b8837b731659
Base.getindex(a::Piece, b::AbstractInterval) = (a ∩ b) + a.diff 

# ╔═╡ 3c50deb2-4c84-43cd-9985-95ad8356f0db
Base.getindex(a::Piece, b::Set{<:AbstractInterval})= 
	Set(((a ∩ bᵢ) + a.diff for bᵢ ∈ b))

# ╔═╡ d4559c7f-ec63-48ac-8165-939949b36693
Base.getindex(::Piece, ::EmptyInterval) = Set([EmptyInterval{T}()]) 

# ╔═╡ 84cffe5e-f145-4948-9cbd-11541450ef7a
Base.setdiff(a::Interval, b::Interval) = 
	Set([Interval(a.start, min(b.start-1, a.stop)), Interval(max(a.start, b.stop+1), a.stop)])

# ╔═╡ af4e4fa6-096a-44ac-a775-1a3de4a86af8
Base.setdiff(a::AbstractInterval, ::EmptyInterval) = Set([a])

# ╔═╡ 7d3fbac7-a1d5-45e9-a74c-3bb269ef25e1
Base.setdiff(::EmptyInterval, ::AbstractInterval) = 
	Set([EmptyInterval()])

# ╔═╡ 6001a158-8958-4f00-8d8c-0f15e5cdf40b
Base.setdiff(a::Set{<:AbstractInterval}, b::Set{<:AbstractInterval}) =
	foldl(setdiff, b; init=a)

# ╔═╡ f3312322-ccf1-489a-a06a-0f96001f2e5d
Base.setdiff(a::Set{<:AbstractInterval}, b::AbstractInterval) = 
	reduce(∪, setdiff(aᵢ, b) for aᵢ ∈ a)

# ╔═╡ 94f32613-6bf4-4b76-8b29-08a0e3e2f441
preimage(p::Piece) = p.interval

# ╔═╡ a3f10ba2-c452-432c-99f9-174075ecbfe1
Base.getindex(a::PADict, b::AbstractInterval) = a[Set([b])]

# ╔═╡ ec9542a9-9877-4b1e-a0bf-d604f8f735c6
function Base.getindex(a::PADict, b::Set{<:AbstractInterval})
	res = Set{AbstractInterval}()
	for seg in a.segments
		push!(res, seg[b]...)
	end
	res ∪ setdiff(b, Set(preimage.(a.segments)))
end

# ╔═╡ 07da6639-6b5f-44f0-a699-f0a83e436fc8
md"Let's define some data structures"

# ╔═╡ 99a2d6b6-9ff4-477c-87d0-1eec670f9655
md"Now let's actually solve the problem…"

# ╔═╡ 288e0a8e-e3d7-43a5-a982-af2701f90ed9
md"""## Part II
Now the fun part begins, and we redefine our functionality from `Int` to `Intervals`
"""

# ╔═╡ 564fa9c0-28be-45cf-ba2e-5882fb7ccf38
begin
	seeds2 = split(input[1], ':')[end] |> split .|> x->Base.parse(Int, x)
	seeds2 = Set(reshape(seeds2, 2, :) |> eachcol .|> x->Interval(x[1], sum(x)))
end

# ╔═╡ 7053ab26-03d4-499d-8b27-778535ae1773
Base.minimum(a::AbstractInterval) = a.start

# ╔═╡ e613c8b3-358d-440e-b8ab-16258fbc9934
Base.minimum(::EmptyInterval) = typemax(Int)

# ╔═╡ a5d478ee-815c-402d-804a-d6f80ccc805f
apply_maps.(seeds) |> minimum

# ╔═╡ b44addd6-a782-4d53-82ac-dba7c7c53ef3
apply_maps(seeds2) .|> minimum |> minimum

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
# ╠═a2d2dd08-1e50-4433-acc2-0598d8369f23
# ╠═f3e900cc-ede1-43f2-b1ad-8ba23f39fc1d
# ╠═c7ba091c-93a2-11ee-1f81-0d504adbce54
# ╠═555ee35b-0c3a-40eb-9e46-7a4558b92daf
# ╠═69122591-1b6e-46f1-9ff7-a5b007d5fb8b
# ╠═102dbfff-97e4-4b17-8c5d-e43c4edd3dff
# ╠═d2661415-b0ef-4b0b-bd99-884bc74012ab
# ╠═d9e5a11a-e01e-4b02-b2f1-bbdd511407c4
# ╠═285bc16b-5d0b-4340-84d8-8c783fbf61c3
# ╠═b148ad43-c4fb-427a-bf2a-61b3ecb393a8
# ╠═1c4d0f88-3df5-4a47-8d48-38922db6bd2c
# ╠═88d37adb-6e18-4594-a9a6-febb08313b03
# ╟─99a2d6b6-9ff4-477c-87d0-1eec670f9655
# ╠═16493a49-20ec-4a77-bdf2-96edaf76437d
# ╠═40845d48-1f0a-4563-8cf0-45b440fcc474
# ╠═577f7552-eef3-4da0-bafb-47feecb67263
# ╠═0b4eb17f-1864-4ae9-9038-c6826e9e4e73
# ╠═a5d478ee-815c-402d-804a-d6f80ccc805f
# ╟─288e0a8e-e3d7-43a5-a982-af2701f90ed9
# ╠═777d07aa-a439-4afa-9940-b8837b731659
# ╠═579b3dc5-bbdf-4c00-8a01-7d7c5caed94f
# ╠═8ee3b66c-3b19-430b-abf6-4ac4c5785347
# ╠═8702e836-30a3-40e3-9053-74ef335f518e
# ╠═2cadd759-4022-4eff-a0cf-387bad223c42
# ╠═ff9f8c61-866a-4675-9001-cd0c87f04593
# ╠═800894e3-794c-48a3-92d8-acad733c85fc
# ╠═db89423c-1819-4a97-8597-f0ca49809012
# ╠═3c50deb2-4c84-43cd-9985-95ad8356f0db
# ╠═d4559c7f-ec63-48ac-8165-939949b36693
# ╠═84cffe5e-f145-4948-9cbd-11541450ef7a
# ╠═af4e4fa6-096a-44ac-a775-1a3de4a86af8
# ╠═7d3fbac7-a1d5-45e9-a74c-3bb269ef25e1
# ╠═6001a158-8958-4f00-8d8c-0f15e5cdf40b
# ╠═f3312322-ccf1-489a-a06a-0f96001f2e5d
# ╠═94f32613-6bf4-4b76-8b29-08a0e3e2f441
# ╠═a3f10ba2-c452-432c-99f9-174075ecbfe1
# ╠═ec9542a9-9877-4b1e-a0bf-d604f8f735c6
# ╠═564fa9c0-28be-45cf-ba2e-5882fb7ccf38
# ╠═7053ab26-03d4-499d-8b27-778535ae1773
# ╠═e613c8b3-358d-440e-b8ab-16258fbc9934
# ╠═b44addd6-a782-4d53-82ac-dba7c7c53ef3
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
