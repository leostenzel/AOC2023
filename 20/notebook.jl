### A Pluto.jl notebook ###
# v0.19.36

using Markdown
using InteractiveUtils

# ╔═╡ 971eb029-6426-42d1-9809-b509430c92df
using JuliaSyntax

# ╔═╡ e0337825-c5d1-4f3c-8803-78ed2cabdec3
abstract type AbstractModule end

# ╔═╡ 1a79a82c-36ba-4a7c-919d-a58723497c91
begin
	struct Pulse{S} 
		from::AbstractString
		to::AbstractString
	end
	islow(::Pulse{:low}) = true
	islow(::Pulse{:high}) = false
	ishigh(::Pulse{:low}) = false
	ishigh(::Pulse{:high}) = true
	Base.:!(p::Pulse{:low}) = Pulse{:high}(p.from, p.to)
	Base.:!(p::Pulse{:high}) = Pulse{:low}(p.from, p.to)
	Pulse(S, from, to) = Pulse{S}(from, to)
	from(p::Pulse) = p.from
	to(p::Pulse) = p.to
end

# ╔═╡ 12a6a37f-8bba-4d6d-8d9f-c6275d73b8a0
begin
	mutable struct FlipFlop <: AbstractModule
		name::AbstractString
		next::AbstractVector
		state::Bool
	end
	function (a::FlipFlop)(pulse::Pulse)
		ishigh(pulse) && return nothing
		
		a.state = !a.state
		a.state && return Pulse.((:high,), (a.name,), a.next)

		Pulse.((:low,), (a.name,), a.next)
	end
	name(a::FlipFlop) = a.name
	FlipFlop(name::AbstractString, next::AbstractVector) = FlipFlop(name, next, false)
end

# ╔═╡ f341aa0f-5ae8-4d5c-9110-2825e76d8171
begin
	struct Conjunction <: AbstractModule
		name::AbstractString
		next::AbstractVector
		memory::AbstractDict
	end
	# Conjunction(next) = Conjunction(next, Dict(next .=> Pulse.(:low, next),))
	function (a::Conjunction)(p::Pulse)
		a.memory[from(p)] = p
		if (a.memory |> values .|> ishigh) |> all
			return Pulse.(:low, a.name, a.next)
		end
		Pulse.(:high, a.name, a.next) 
	end
	name(a::Conjunction) = a.name
	Conjunction(name::AbstractString, next::AbstractVector) = 
		Conjunction(name, next, Dict{AbstractString, Pulse}())
end

# ╔═╡ a78d96f9-eda0-462e-8e26-9833470f4056
begin 
	struct Broadcaster <: AbstractModule
		next::AbstractVector
	end
	(a::Broadcaster)(p::Pulse{P}) where {P} = Pulse{P}.("broadcaster", a.next)
	name(::Broadcaster) = "broadcaster"
end

# ╔═╡ 9f524271-3df0-4c8d-83e5-26e6a1bcd671
function parse_line(line)
	name, to = split(line, "->")
	next = split(to, [',', ' ']; keepempty=false)
	name = split(name, ' ', keepempty=false)[]

	name == "broadcaster" && return Broadcaster(next)

	name[1] == '%' && return FlipFlop(name[2:end], next)

	name[1] == '&' && return Conjunction(name[2:end], next)

	error(line)
end

# ╔═╡ ce2cf110-0418-48cb-b52b-5afa4ad07427
function read_modules()
	input = "input" |> readlines
	
	modules = parse_line.(input)
	modules = Dict(name.(modules) .=> modules)

	# initialize the conjunctions
	for m ∈ modules |> values
		for target ∈ m.next
			target ∉ keys(modules) && continue
			if modules[target] isa Conjunction
				modules[target].memory[name(m)] = Pulse(:low, name(m), target)
			end
		end
	end
	modules
end

# ╔═╡ c9390017-16aa-4033-9a04-e5f2689c1a98
pulses = let

	modules = read_modules()
	
	pulses = Pulse[]

	for i ∈ 1:1000
		stack = Pulse[Pulse(:low, "button", "broadcaster")]
		
		while !isempty(stack)
			
			pulse = popfirst!(stack)
			
			push!(pulses, pulse)
	
			pulse.to ∉ keys(modules) && continue
			
			next_p = modules[pulse.to](pulse)
			
			isnothing(next_p) && continue
			
			push!(stack, next_p...)
			
		end
	end
	pulses
end

# ╔═╡ 4837fbc9-0990-4d44-8b0e-19cbfdf68e24
(pulses .|> ishigh |> sum) * (pulses .|> islow |> sum )

# ╔═╡ 63a5ab32-c354-49c5-a0a9-88de5ae05a47
md""" ## Part II
Let's assume there's a simple solution… i.e. the inputs are periodic…
It's not clear to me that this is actually a solution. But AOC says it is 😅
"""

# ╔═╡ 1a97646d-2b23-44a2-ab39-57b2ac66a7e1
rx_from = name.(values(filter(x->"rx" ∈ last(x).next , read_modules())))[]

# ╔═╡ 62944324-3e9e-4d36-a698-257c24288fb2
periods = let
	modules = read_modules()
	periods = Dict{AbstractString, Int}()
	
	for i ∈ 1:10_000
		stack = Pulse[Pulse(:low, "button", "broadcaster")]
		
		while !isempty(stack)
			
			pulse = popfirst!(stack)
			
			pulse.to ∉ keys(modules) && continue

			if pulse isa Pulse{:low} && pulse.to ∈ keys(modules[rx_from].memory)
				periods[pulse.to] = i
			end
			
			next_p = modules[pulse.to](pulse)
			
			isnothing(next_p) && continue
			
			push!(stack, next_p...)
			
		end

		length(periods) == length(modules[rx_from].memory) && break

	end
	periods
end

# ╔═╡ 042fd98d-f28f-462e-b904-6ab3ea2fccd6
periods |> values |> prod

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
# ╠═971eb029-6426-42d1-9809-b509430c92df
# ╠═e0337825-c5d1-4f3c-8803-78ed2cabdec3
# ╠═1a79a82c-36ba-4a7c-919d-a58723497c91
# ╠═12a6a37f-8bba-4d6d-8d9f-c6275d73b8a0
# ╠═f341aa0f-5ae8-4d5c-9110-2825e76d8171
# ╠═a78d96f9-eda0-462e-8e26-9833470f4056
# ╠═9f524271-3df0-4c8d-83e5-26e6a1bcd671
# ╠═ce2cf110-0418-48cb-b52b-5afa4ad07427
# ╠═c9390017-16aa-4033-9a04-e5f2689c1a98
# ╠═4837fbc9-0990-4d44-8b0e-19cbfdf68e24
# ╟─63a5ab32-c354-49c5-a0a9-88de5ae05a47
# ╠═1a97646d-2b23-44a2-ab39-57b2ac66a7e1
# ╠═62944324-3e9e-4d36-a698-257c24288fb2
# ╠═042fd98d-f28f-462e-b904-6ab3ea2fccd6
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
