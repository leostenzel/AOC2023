### A Pluto.jl notebook ###
# v0.19.35

using Markdown
using InteractiveUtils

# ╔═╡ ce2561a4-9986-11ee-3d51-a753d974b2ce
input = push!("input" |> readlines, "")

# ╔═╡ dd689436-004a-4977-961c-7105ca365fb1
patterns = let patterns = Matrix{Char}[]
	tmp = String[]
	for line ∈ input		
		if isempty(line)
			push!(patterns, stack(tmp))
			tmp = String[]
		else
			push!(tmp, line)
		end
	end
	@assert count(isempty, input) == length(patterns)
	patterns
end

# ╔═╡ 0b63069e-4c7c-45b0-a426-70991d5a157c
function find_rows(pattern)
	l = size(pattern, 2)-1
	for i ∈ 1:l
		tmp = pattern[:,i:end]
		if iseven(size(tmp,2)) && reverse(tmp; dims=2) == tmp
			# @show pattern[:,i:end] |> size
			return i + (size(pattern, 2) - i) ÷ 2 
		end
		tmp = pattern[:,begin:i+1]
		if iseven(size(tmp, 2)) && reverse(tmp; dims=2) == tmp
			# @show i
			return (i+1) ÷ 2
		end
	end
	return 0
end

# ╔═╡ e64f9157-6aee-4eec-8c2b-6e2ca8ba93d3
find_cols(pattern) = pattern |> permutedims |> find_rows

# ╔═╡ dde6faeb-a7e9-4333-8358-303defa9587f
find_rows.(patterns) * 100 + find_cols.(patterns) |> sum

# ╔═╡ 53d1e728-7bdd-4003-af36-29a54fa1dde6
md"## Part II"

# ╔═╡ 53aee326-13e4-45d4-818f-3fa3f1f32df2
function find_rows2(pattern)
	l = size(pattern, 2)-1
	for i ∈ 1:l
		tmp = pattern[:,i:end]
		if iseven(size(tmp,2)) && (sum(reverse(tmp; dims=2) .!= tmp) == 2)
			# @show pattern[:,i:end] |> size
			return i + (size(pattern, 2) - i) ÷ 2 
		end
		tmp = pattern[:,begin:i+1]
		if iseven(size(tmp, 2)) && (sum(reverse(tmp; dims=2) .!= tmp) == 2)
			# @show i
			return (i+1) ÷ 2
		end
	end
	return 0
end

# ╔═╡ 92b7e56b-e040-44f7-9089-b3ad48050c13
find_cols2(pattern) = pattern |> permutedims |> find_rows2

# ╔═╡ e223f02b-a9fa-4f38-9151-239cb66b6396
find_rows2.(patterns) * 100 + find_cols2.(patterns) |> sum

# ╔═╡ Cell order:
# ╠═ce2561a4-9986-11ee-3d51-a753d974b2ce
# ╠═dd689436-004a-4977-961c-7105ca365fb1
# ╠═0b63069e-4c7c-45b0-a426-70991d5a157c
# ╠═e64f9157-6aee-4eec-8c2b-6e2ca8ba93d3
# ╠═dde6faeb-a7e9-4333-8358-303defa9587f
# ╟─53d1e728-7bdd-4003-af36-29a54fa1dde6
# ╠═53aee326-13e4-45d4-818f-3fa3f1f32df2
# ╠═92b7e56b-e040-44f7-9089-b3ad48050c13
# ╠═e223f02b-a9fa-4f38-9151-239cb66b6396
