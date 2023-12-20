### A Pluto.jl notebook ###
# v0.19.36

using Markdown
using InteractiveUtils

# ╔═╡ 06a73fb5-50d6-4b38-b3da-9cd61d961887
using JuliaSyntax

# ╔═╡ 9df8cfb0-c07f-4944-a420-a92a4e69587a
using MacroTools: @capture, postwalk, prewalk, @q

# ╔═╡ d801a602-9e35-11ee-109c-5db76110cf85
input = "input" |> readlines

# ╔═╡ 685479ba-dcee-4c62-96dc-bb5170aadf51
begin
	@kwdef struct XMAS{T}
		x::T; m::T; a::T; s::T
	end

	function XMAS(y::XMAS; args...) 
		names = fieldnames(XMAS)
		XMAS(; (names .=> getfield.((y,), names))..., args...)
	end

	for field ∈ fieldnames(XMAS)
		@eval $(field)(y::XMAS) = getfield(y, Symbol($field))
	end
end;

# ╔═╡ 835d77a3-8ac7-42c5-90bf-31358c507169
function parse_condition(a::AbstractString)
	# make my life simpler by juliafying the if-else expressions
	# also, I rename `in` to `f_in` to avoid issues
	a = replace(a, ':'=>" ? ", ','=>" : ", "in" => "f_in") |> Meta.parse
	
	# turn `name{…}` expressions into function calls
	a = postwalk(x -> @capture(x, name_{args__}) ? :($name(y) = $(args...)) : x, a)
	
	# turn variable names into function calls
	prewalk(x -> @capture(x, a_(b_, c_) ? d_ : e_) ? 
		begin
			e isa Symbol ? 
			:($a($b(y), $c) ? $d(y) : $e(y)) :
			:($a($b(y), $c) ? $d(y) : $e)
		end : x, a)
end

# ╔═╡ fe00a865-910a-401c-b895-59938f329af6
function parse_xmas(ex::AbstractString)
	ex = Meta.parse(ex)
	postwalk(x -> @capture(x, {args__}) ? :(XMAS(;$(args...))) : x, ex)
end

# ╔═╡ d68eee68-3b16-4e9c-b30b-03e0d455cf0c
begin
	local acc = XMAS{Int}[]
	
	A(x::XMAS) = push!(acc, x)
	R(x::XMAS) = nothing

	for line ∈ input
		isempty(line) && continue
		if line[1] != '{' 
			eval(parse_condition(line))
		else
			f_in(eval(parse_xmas(line)))
		end
	end
	
	getfield.(permutedims(acc), fieldnames(XMAS)) |> sum
end

# ╔═╡ edb76e9f-797c-4973-8c4f-d91b4e1ab173
md"Part II"

# ╔═╡ 1b081728-a899-468a-9663-a355eb8725c0
function ifelse2split(ex::Expr)
	ex = postwalk(x -> @capture(x, b_(a_(y_), c_) ? d_ : e_) ?
		@q begin 
			r1, r2 = split($a($y), $b, $c)
			$y = XMAS($y; Symbol($a) => r1)
			$d
			$y = XMAS($y; Symbol($a) => r2)
			$e
		end 
	: x, ex)
end

# ╔═╡ 989e3c2f-bbb9-4c41-87f2-1c06fb84aec1
Base.length(a::XMAS{<:AbstractVector}) = 
	prod(length.(getfield.((a,), fieldnames(XMAS))))

# ╔═╡ 7b6a2ffd-ddd1-41dc-9dd1-99a26e9b7802
function argwhere(a::AbstractRange, b::Function, c::Number, offset=0)
	length(a) == 0 && return 1:0
	(b(minimum(a), c) ? minimum(a) : c+offset):(b(maximum(a), c) ? maximum(a) : c-offset)
end

# ╔═╡ 01187369-864f-49e9-b68a-2e5b21456ade
split(a::AbstractRange, b::Function, c::Number) = 
	(argwhere(a, b, c, 1), argwhere(a, !b, c))

# ╔═╡ c5a59e0f-e0ec-4d53-80b2-213c21f07ce0
begin
	acc = XMAS{<:AbstractRange}[]

	# ugly hack st. Pluto won't complain
	eval(:(A(x::XMAS) = push!(acc, x)))

	for line ∈ input
		isempty(line) && break

		line |> parse_condition |> ifelse2split |> eval
	end

	f_in(XMAS(fill(1:4000, 4)...))
	
	acc .|> length |> sum
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
JuliaSyntax = "70703baa-626e-46a2-a12c-08ffd08c73b4"
MacroTools = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"

[compat]
JuliaSyntax = "~0.4.8"
MacroTools = "~0.5.11"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.9.4"
manifest_format = "2.0"
project_hash = "5abc64e7ef7add756cfeb0622e5195cfdc2d8440"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.JuliaSyntax]]
git-tree-sha1 = "e00e2b013f3bd98d3789f889b9305c1546ecd1ab"
uuid = "70703baa-626e-46a2-a12c-08ffd08c73b4"
version = "0.4.8"

[[deps.MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "9ee1618cbf5240e6d4e0371d6f24065083f60c48"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.11"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
"""

# ╔═╡ Cell order:
# ╠═06a73fb5-50d6-4b38-b3da-9cd61d961887
# ╠═9df8cfb0-c07f-4944-a420-a92a4e69587a
# ╠═d801a602-9e35-11ee-109c-5db76110cf85
# ╠═685479ba-dcee-4c62-96dc-bb5170aadf51
# ╠═835d77a3-8ac7-42c5-90bf-31358c507169
# ╠═fe00a865-910a-401c-b895-59938f329af6
# ╠═d68eee68-3b16-4e9c-b30b-03e0d455cf0c
# ╟─edb76e9f-797c-4973-8c4f-d91b4e1ab173
# ╠═7b6a2ffd-ddd1-41dc-9dd1-99a26e9b7802
# ╠═01187369-864f-49e9-b68a-2e5b21456ade
# ╠═1b081728-a899-468a-9663-a355eb8725c0
# ╠═989e3c2f-bbb9-4c41-87f2-1c06fb84aec1
# ╠═c5a59e0f-e0ec-4d53-80b2-213c21f07ce0
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
