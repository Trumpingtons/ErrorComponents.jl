# ErrorComponents.jl

WALHUS, AMEMIYA, Swamy-Arora and nested error components.

Random-effects panel regressions with the variance components estimated by Wallace-Hussain, Amemiya, Swamy-Arora, Henderson's method III or MIVQUE, one-way, two-way and nested, tested on Baltagi's tables for the Grunfeld, gasoline and public capital data.

Article: Baltagi, B. H., Song, S. H. and Jung, B. C. (2001). The unbalanced nested error component regression model. Journal of Econometrics 101(2), 357-381. [doi:10.1016/S0304-4076(00)00089-0](https://doi.org/10.1016/S0304-4076(00)00089-0)

## Usage

```julia
using ErrorComponents, CSV, Tables
g = Tables.columntable(CSV.File(download("https://raw.githubusercontent.com/Trumpingtons/PollisDatasets.jl/main/data/grunfeld.csv")))
X = [g.value g.capital]
fit = errorcomponents(g.invest, X, [g.firm, g.year]; structure=:twoway, method=:amemiya)
fit.coef, fit.se, sqrt.(fit.variances)  # sigma_mu, sigma_lambda, sigma_nu
```

## Vignette

[WALHUS, AMEMIYA, Swamy-Arora and nested error components](vignette/ErrorComponents.pdf)

## License

MIT (see [LICENSE](LICENSE)).

## Tests

The tests compute the published tables below from their data and check every printed value, rounded to the digits printed:

- Baltagi (2005), Table 2.1, p. 21 (`test/data/targets/table21.csv`)
- Baltagi (2005), Table 2.5, p. 24 (`test/data/targets/table25.csv`)
- Baltagi (2005), Table 2.6, p. 25 (`test/data/targets/table26.csv`)
- Baltagi (2005), Table 3.1, p. 43 (`test/data/targets/table31.csv`)
- Baltagi (2005), Table 3.6, p. 46 (`test/data/targets/table36.csv`)
- Baltagi (2005), Table 3.7, p. 47 (`test/data/targets/table37.csv`)
- Baltagi (2005), Table 9.4, p. 182 (MV3 not tested: its prior is not given) (`test/data/targets/table94.csv`)

The data, downloaded from its links when the tests run or kept in `test/data/inputs`:

- `gasoline`: <https://raw.githubusercontent.com/Trumpingtons/PollisDatasets.jl/main/data/gasoline.csv>, PollisDatasets: Baltagi and Griffin's 18 OECD countries, 1960-78
- `grunfeld`: <https://raw.githubusercontent.com/Trumpingtons/PollisDatasets.jl/main/data/grunfeld.csv>, PollisDatasets: Grunfeld's 11 firms, 1935-54 (Baltagi uses 10, without American Steel)
- `produc`: <https://raw.githubusercontent.com/Trumpingtons/PollisDatasets.jl/main/data/produc.csv>, PollisDatasets: Munnell's 48 states, 1970-86, in 9 regions

Run them with `using Pkg; Pkg.test("ErrorComponents")`.

Made with [Pollis](https://pollis.org).
