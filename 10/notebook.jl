### A Pluto.jl notebook ###
# v0.19.32

using Markdown
using InteractiveUtils

# ╔═╡ fe2cd977-5c8b-41d4-8e98-e02201a52627
input = ("input" |> readlines .|> x->Vector{Char}(x)) |> x->hcat(x...);

# ╔═╡ 100ccd65-f873-41d4-8a9c-fc25c6cc7eca
inout_dict = Dict(:north => :south, :south=>:north, :east => :west, :west => :east)

# ╔═╡ 27946889-9d50-4e63-af08-bb9ba4a7a1e1
begin
	struct CharPipe{char, indir}
		loc::CartesianIndex{2}
	end
	CharPipe(loc::CartesianIndex{2}, indir) = CharPipe{input[loc], indir}(loc)
end

# ╔═╡ 5df688e7-f402-42fd-a551-5b2c4ee3dbde
char(::CharPipe{c, indir}) where {c, indir} = c

# ╔═╡ 6b0a1cb2-01eb-4f67-893a-607843bb2d33
in_dir(::CharPipe{char, indir}) where {char, indir} = indir

# ╔═╡ 1b83c9f6-8959-4b1b-8c5e-83e6fe42050c
begin
	# generic fallback
	out_dir(::CharPipe) = nothing
	
	out_dir(::CharPipe{'7', :south}) = :west
	out_dir(::CharPipe{'7', :west}) = :south

	out_dir(::CharPipe{'F', :south}) = :east
	out_dir(::CharPipe{'F', :east}) = :south

	out_dir(::CharPipe{'L', :east}) = :north
	out_dir(::CharPipe{'L', :north}) = :east

	out_dir(::CharPipe{'J', :north}) = :west
	out_dir(::CharPipe{'J', :west}) = :north

	out_dir(::CharPipe{'|', indir}) where {indir} = inout_dict[indir]
	out_dir(::CharPipe{'-', indir}) where {indir} = inout_dict[indir]
end

# ╔═╡ f5d8ded9-ff10-4a86-b65e-221bd8a77e00
location(c::CharPipe) = c.loc

# ╔═╡ e126451e-ae64-4eb9-9f89-86057dd14b5d
begin 
	move(s, c::CartesianIndex) = move(Val(s), c)
	move(s, c::CharPipe) = move(s, location(c))
	move(::Val{:north}, c::CI) where {CI<:CartesianIndex} = CI(c[1], c[2]-1)
	move(::Val{:south}, c::CI) where {CI<:CartesianIndex} = CI(c[1], c[2]+1)
	move(::Val{:west}, c::CI) where {CI<:CartesianIndex} = CI(c[1]-1, c[2])
	move(::Val{:east}, c::CI) where {CI<:CartesianIndex} = CI(c[1]+1, c[2])
end

# ╔═╡ 1a236e6d-f4fb-4576-b93e-0b30907e14bc
next_loc(c::CharPipe) = move(out_dir(c), location(c))

# ╔═╡ a92bde01-053a-4773-b75e-4ca11e420c31
function Base.iterate(c::CharPipe{char, indir}) where {char, indir}
	char == 'S' && return nothing	
	nc = next_loc(c)
	CharPipe{input[nc], inout_dict[out_dir(c)]}(nc)
end

# ╔═╡ 4776733a-cb1a-41d4-a403-5e60289bfe20
directions = inout_dict |> keys

# ╔═╡ 89cf7822-0956-4049-a6e8-35e8c6195564
begin
	s_loc = findfirst(==('S'), input)
	next = nothing
	
	for dir ∈ directions
		next = CharPipe(move(dir, s_loc), inout_dict[dir])
		!isnothing(out_dir(next)) && break
	end

	loop = CharPipe[]
	while !isnothing(next)
		push!(loop, next)
		next = iterate(next)
	end
	length(loop) ÷ 2
end

# ╔═╡ 2161308f-c50d-49ea-9f6e-02ffbd7d30fa
md"""## Part II
I thought about simple solutions, assuming all tiles on the outside are connected to the boundary…
But I'm not sure this is actually correct.

So let's be more explicit, and consider the parts which are connected to the left and the right of the loop. 
"""

# ╔═╡ cf152f92-fc0b-4900-a32c-9ed56b5cbfbb
begin
	# generic fallback
	left(dir) = nothing
	
	# implementations
	# We always consider _incoming_ directions
	left(::Val{:east}) = :south
	left(::Val{:west}) = :north
	left(::Val{:north}) = :east
	left(::Val{:south}) = :west

	# wrapper
	left(dir::Symbol) = left(Val(dir))

	function left(c::CharPipe{char, indir}) where {char, indir}
		outdir = out_dir(c)
		isnothing(outdir) && return [left(indir)]
		setdiff(left.([indir, inout_dict[outdir]]), [indir, outdir])
	end
end

# ╔═╡ e16b2bad-146c-4f1b-b4ce-d190ce0f6b83
begin
	left_locs = CartesianIndex{2}[]
	for c ∈ loop
		push!.((left_locs,), move.(left(c), (c,)))
	end

	# Adding the output direction of the 'S' node explicitly
	push!(left_locs, move(left(in_dir(loop[begin])), loop[end]))
	
	left_locs = setdiff(left_locs, location.(loop))
end

# ╔═╡ eac8281e-01cd-405e-bf68-11262ea8d08a
function grow_set(seed, boundary)
	candidates = copy(seed)
	result = Set{eltype(candidates)}()
	
	while !isempty(candidates)
		c = pop!(candidates)
		(c ∈ boundary || c ∈ result) && continue
		
		push!(result, c)
		push!.((candidates,), move.(directions, (c,)))
	end
	result
end

# ╔═╡ 5597adcf-f22f-47a5-a121-af0b6cfa30d9
grow_set(left_locs, Set(location.(loop))) |> length

# ╔═╡ 3ef08350-be20-4f9f-8627-33a71a530fd2
md"Did we count the inside or the outside…?"

# ╔═╡ 25217bc8-a17d-48a6-8197-9f918fd05c0a
dir_lookup = Dict(:north=>1, :east=>0, :south=>-1, :west=>0)

# ╔═╡ 242bd32b-253f-49bb-85f9-5721d0fe06ee
begin
	curvature(i::Symbol, o::Symbol) = curvature(Val(i), Val(o))

	curvature(i, o) = 0

	curvature(::Val{:north}, ::Val{:west}) = -1
	curvature(::Val{:west}, ::Val{:south}) = -1
	curvature(::Val{:south}, ::Val{:east}) = -1
	curvature(::Val{:east}, ::Val{:north}) = -1
	
	curvature(::Val{:north}, ::Val{:east}) = 1
	curvature(::Val{:east}, ::Val{:south}) = 1
	curvature(::Val{:south}, ::Val{:west}) = 1
	curvature(::Val{:west}, ::Val{:north}) = 1

	curvature(c::CharPipe) = curvature(in_dir(c), out_dir(c))
end

# ╔═╡ e7910a83-5964-44b2-9d2e-06a0f15afdd8
md"""In my case the total curvature is positive, meaning we take more left turns than right turns, thus the left is actually the inside.

Of course, we'd need 4 additional left turns to make a loop, while I only find 3…
But that's okay, the last one is hidden in the `S` node.
"""

# ╔═╡ e1ecdc09-21eb-42a5-a61e-eeecc5a08a5b
curvature.(loop) |> sum

# ╔═╡ Cell order:
# ╠═fe2cd977-5c8b-41d4-8e98-e02201a52627
# ╠═100ccd65-f873-41d4-8a9c-fc25c6cc7eca
# ╠═27946889-9d50-4e63-af08-bb9ba4a7a1e1
# ╠═5df688e7-f402-42fd-a551-5b2c4ee3dbde
# ╠═6b0a1cb2-01eb-4f67-893a-607843bb2d33
# ╠═1b83c9f6-8959-4b1b-8c5e-83e6fe42050c
# ╠═1a236e6d-f4fb-4576-b93e-0b30907e14bc
# ╠═e126451e-ae64-4eb9-9f89-86057dd14b5d
# ╠═f5d8ded9-ff10-4a86-b65e-221bd8a77e00
# ╠═a92bde01-053a-4773-b75e-4ca11e420c31
# ╠═4776733a-cb1a-41d4-a403-5e60289bfe20
# ╠═89cf7822-0956-4049-a6e8-35e8c6195564
# ╟─2161308f-c50d-49ea-9f6e-02ffbd7d30fa
# ╠═cf152f92-fc0b-4900-a32c-9ed56b5cbfbb
# ╠═e16b2bad-146c-4f1b-b4ce-d190ce0f6b83
# ╠═eac8281e-01cd-405e-bf68-11262ea8d08a
# ╠═5597adcf-f22f-47a5-a121-af0b6cfa30d9
# ╟─3ef08350-be20-4f9f-8627-33a71a530fd2
# ╠═25217bc8-a17d-48a6-8197-9f918fd05c0a
# ╠═242bd32b-253f-49bb-85f9-5721d0fe06ee
# ╟─e7910a83-5964-44b2-9d2e-06a0f15afdd8
# ╠═e1ecdc09-21eb-42a5-a61e-eeecc5a08a5b
