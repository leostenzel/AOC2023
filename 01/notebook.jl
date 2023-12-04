### A Pluto.jl notebook ###
# v0.19.32

using Markdown
using InteractiveUtils

# ╔═╡ f5a45a52-8b57-474a-869f-9067eb34ef7d
input = readlines("input");

# ╔═╡ 17a2d1d2-089b-4ba4-9df4-39a01ce2e5a8
keepdigits(x) = filter(isdigit, x)

# ╔═╡ 9189bd0f-5e38-45d5-a56c-535dfe0cab49
firstlast(x) = first(x) * last(x)

# ╔═╡ 8d69e088-ae4a-4f3b-ac56-fc8989df249a
parseint(x) = parse(Int, x)

# ╔═╡ 6dbc7601-802f-4e82-9041-c26bb9945d97
input .|> keepdigits .|> firstlast .|> parseint |> sum

# ╔═╡ 732eabbf-fad7-4e78-a1ee-ffc249af55d1
md"## Part two"

# ╔═╡ ed58f513-bbd0-4a2c-898c-a671cd38b8f3
replacements = [
	"one" => "1"
	"two" => "2" 
	"three" => "3" 
	"four" => "4" 
	"five" => "5" 
	"six" => "6" 
	"seven" => "7" 
	"eight" => "8" 
	"nine" => "9"
]

# ╔═╡ 16a9e20b-64c1-44bc-9c7e-8b24ba6a5bc4
replacewords(x) = replace(x, replacements...)

# ╔═╡ d15bef4d-40b4-4ac2-b751-c5543732446a
md"""Why doesn't this work right? In my input I can correct it by replacing overlapping numbers manually.
Your input could also have more numbers stuck together, then this will still fail…"""

# ╔═╡ 18ab5271-95b6-42b6-831a-2fdc800354bc
overlaps = [
	"oneight" => "18"
	"twone" => "21"
 	"threeight" => "38"
 	"fiveight" => "58"
 	"sevenine" => "79"
 	"eightwo" => "82"
 	"eighthree" => "83"
 	"nineight" => "98"
]

# ╔═╡ f4ba496a-3f54-4c88-87bf-0b2b63184622
overlappingwords(x) = replace(x, overlaps...)

# ╔═╡ 209fd08a-b30f-4c7e-b5ef-8ede12be0d1d
input .|> overlappingwords .|> replacewords .|> keepdigits .|> firstlast .|> parseint |> sum

# ╔═╡ 5a277429-2121-4cc3-848a-41aef3139511
md"""
### Without defining overlaps manually
still not a very pretty solution…
"""

# ╔═╡ a9c00503-7d5d-4f07-ba61-cb3478b1951d
function replace_firstlast(x)
	# replace the first occurence of any spelled-out number.
	# we append the original string, because we may have to replace some of the previously matched characters again
	x = replace(x, replacements..., count=1) * x

	# reverse the replacement rule
	rev_repl = @. reverse(first(replacements)) => last(replacements)
	
	# apply the rule from the end
	reverse(replace(reverse(x), rev_repl..., count=1))
end

# ╔═╡ f195dfde-1294-4a2b-8bab-215c24bcc5fc
input .|> replace_firstlast .|> keepdigits .|> firstlast .|> parseint |> sum

# ╔═╡ 08ee7e3b-dd5d-4e95-9cb5-97c061471f09
md"""
### without replacements

Clearly, replace doesn't really work well with these strings.
Regex would probably be the best solution here, but we could write similar functionality ourselves…
"""

# ╔═╡ 736257fe-864a-43c0-bf96-f6c7588b3895
function first_substring(patterns, x) 
	function f(p)
		r = findfirst(p, x)
		isnothing(r) ? length(x)+1 : r[begin]
	end
	argmin(f, patterns)
end

# ╔═╡ faf433b7-11fa-46df-8c3a-865ce4630383
function last_substring(patterns, x) 
	function f(p)
		r = findlast(p, x)
		isnothing(r) ? 0 : r[end]
	end
	argmax(f, patterns)
end

# ╔═╡ c53a9685-2960-494c-b829-a127690c6d0d
begin
	patterns = first.(replacements)
	append!(patterns, string.(1:9))

	r_dict = Dict(replacements..., (string.(1:9) .=> string.(1:9))...)
	
	result = 0
	open("input") do f
		for l ∈ eachline(f)
			tmp = r_dict[first_substring(patterns, l)]
			tmp = tmp * r_dict[last_substring(patterns, l)]
			result += parse(Int, tmp)
		end
	end
	result
end

# ╔═╡ Cell order:
# ╠═f5a45a52-8b57-474a-869f-9067eb34ef7d
# ╠═17a2d1d2-089b-4ba4-9df4-39a01ce2e5a8
# ╠═9189bd0f-5e38-45d5-a56c-535dfe0cab49
# ╠═8d69e088-ae4a-4f3b-ac56-fc8989df249a
# ╠═6dbc7601-802f-4e82-9041-c26bb9945d97
# ╟─732eabbf-fad7-4e78-a1ee-ffc249af55d1
# ╠═ed58f513-bbd0-4a2c-898c-a671cd38b8f3
# ╠═16a9e20b-64c1-44bc-9c7e-8b24ba6a5bc4
# ╟─d15bef4d-40b4-4ac2-b751-c5543732446a
# ╠═18ab5271-95b6-42b6-831a-2fdc800354bc
# ╠═f4ba496a-3f54-4c88-87bf-0b2b63184622
# ╠═209fd08a-b30f-4c7e-b5ef-8ede12be0d1d
# ╟─5a277429-2121-4cc3-848a-41aef3139511
# ╠═a9c00503-7d5d-4f07-ba61-cb3478b1951d
# ╠═f195dfde-1294-4a2b-8bab-215c24bcc5fc
# ╟─08ee7e3b-dd5d-4e95-9cb5-97c061471f09
# ╠═c53a9685-2960-494c-b829-a127690c6d0d
# ╠═736257fe-864a-43c0-bf96-f6c7588b3895
# ╠═faf433b7-11fa-46df-8c3a-865ce4630383
