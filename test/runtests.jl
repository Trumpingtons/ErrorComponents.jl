# Made by Pollis (Compose > New Methods > Package and Publish) from method.toml: change the method, not this file.
using Test, CSV, Downloads, Tables, ErrorComponents

const DATA = joinpath(@__DIR__, "data")

"An input table: a file of the tests, or downloaded from its link into memory."
function input(source; delim = ',', columns = nothing, header = true, skipto = nothing, limit = nothing)
	bytes = startswith(source, r"https?://") ? take!(Downloads.download(source, IOBuffer())) : read(joinpath(DATA, source))
	named = columns === nothing && header
	header = columns !== nothing ? Symbol.(columns) : named ? 1 : false
	rows = (; skipto = something(skipto, named ? 2 : 1), limit)
	file = delim == "whitespace" ? CSV.File(bytes; header, rows..., delim = ' ', ignorerepeated = true, stripwhitespace = true) : CSV.File(bytes; header, rows..., delim = delim == "tab" ? '\t' : only(delim))
	return Tables.columntable(file)
end

"The published table: its row labels and its values as printed, `nothing` where a cell is empty."
function target(file)
	table = CSV.File(joinpath(DATA, "targets", file * ".csv"); types = String, delim = ',')
	columns = Tables.columnnames(table)
	rows = [string(coalesce(row[columns[1]], "")) for row in table]
	values = [let cell = row[column]; cell === missing ? nothing : strip(cell) end for row in table, column in columns[2:end]]
	return rows, string.(columns[2:end]), values
end

"Tests each printed value against the result rounded to the digits printed."
function check(result, file, tolerance)
	rows, columns, values = target(file)
	result = result isa AbstractVecOrMat ? result : Tables.matrix(result)
	result = reshape(result, size(result, 1), :)
	@test size(result) == size(values)
	for i in axes(values, 1), j in axes(values, 2)
		printed = values[i, j]
		(printed === nothing || isempty(printed)) && continue
		mantissa, exponent = occursin(r"[eE]", printed) ? split(printed, r"[eE]") : (printed, "0")
		digits = (occursin('.', mantissa) ? length(split(mantissa, '.')[2]) : 0) - parse(Int, exponent)
		published = parse(Float64, printed)
		computed = round(result[i, j]; digits)
		@testset "$(rows[i]), $(columns[j])" begin
			@test isapprox(computed, published; atol = (tolerance + 1e-6) * 10.0^-digits)
		end
	end
end

@testset "ErrorComponents" begin
	@testset "Baltagi (2005), Table 2.1, p. 21" begin
		grunfeld = input("https://raw.githubusercontent.com/Trumpingtons/PollisDatasets.jl/main/data/grunfeld.csv")
		check(ErrorComponents.table21(grunfeld), "table21", 0)
	end
	@testset "Baltagi (2005), Table 2.5, p. 24" begin
		gasoline = input("https://raw.githubusercontent.com/Trumpingtons/PollisDatasets.jl/main/data/gasoline.csv")
		check(ErrorComponents.table25(gasoline), "table25", 0)
	end
	@testset "Baltagi (2005), Table 2.6, p. 25" begin
		produc = input("https://raw.githubusercontent.com/Trumpingtons/PollisDatasets.jl/main/data/produc.csv")
		check(ErrorComponents.table26(produc), "table26", 0)
	end
	@testset "Baltagi (2005), Table 3.1, p. 43" begin
		grunfeld = input("https://raw.githubusercontent.com/Trumpingtons/PollisDatasets.jl/main/data/grunfeld.csv")
		check(ErrorComponents.table31(grunfeld), "table31", 0)
	end
	@testset "Baltagi (2005), Table 3.6, p. 46" begin
		gasoline = input("https://raw.githubusercontent.com/Trumpingtons/PollisDatasets.jl/main/data/gasoline.csv")
		check(ErrorComponents.table36(gasoline), "table36", 0)
	end
	@testset "Baltagi (2005), Table 3.7, p. 47" begin
		produc = input("https://raw.githubusercontent.com/Trumpingtons/PollisDatasets.jl/main/data/produc.csv")
		check(ErrorComponents.table37(produc), "table37", 0)
	end
	@testset "Baltagi (2005), Table 9.4, p. 182 (MV3 not tested: its prior is not given)" begin
		produc = input("https://raw.githubusercontent.com/Trumpingtons/PollisDatasets.jl/main/data/produc.csv")
		check(ErrorComponents.table94(produc), "table94", 0)
	end
end
