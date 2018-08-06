***** ------------------------------------------------------------------------------ *****
***** ---------------- Monte Carlo Study of Elo Multiplayer Ranking ---------------- *****
***** ------------------------------------------------------------------------------ *****

* Data structure setup
clear all


global obs = 500			// <----- Set number of games
global n = 4			// <----- Set number of players


set obs $obs

	forvalues i = 1/$n {
		gen rank`i' = 1000 in 1
		* gen rank`i' = 100 + round(runiform() * 10, 1) in 1
		gen position`i' = .
	}

* Simulating g games
global obs2 = $obs - 1
local players = 3 + round(runiform() * ($n - 3), 1)
di `players'

forvalues g = 1/$obs2 {

	local row = `g' + 1
	
	* Defining variables
	local i = round(1 + ($n - 1) * runiform(), 1)
	local list = "-`i'-"
	replace position1 = `i' in `g'

		* Generating random positions per game iteration
			forvalues k = 2/$n {
				local j = round(1 + ($n - 1) * runiform(), 1)
				local boolean = 0
					while `boolean' == 0 {
						if strpos("`list'", "-`j'-") {
							local j = round(1 + ($n - 1) * runiform(), 1)
						}
						else {
							local boolean = 1
						}
					}
				qui replace position`k' = `j' in  `g'
				local i = `j'
				local list = "`list'" + "-`i'-"
			}

	* Updating ranking
	local permutations = $n * ($n - 1) / 2
	mat S = J($n, 1, 0)
	
		forvalues i = 1/$n {
			mat S[`i',1] = ($n - position`i'[`g']) / `permutations'
		}
	
	mat E = J($n, $n, 0)
	local a = 800 / $n
	local b = 10
	local c = 400

		forvalues i = 1/$n {
			forvalues j = 1/$n {
				if `i' != `j' {
					mat E[`i',`j'] = 1 / (1 + `b'^((rank`j'[`g'] - rank`i'[`g']) / `c'))
				}
			}
		}
	
	mata : st_matrix("ES", rowsum(st_matrix("E")))
	mat ES = ES / (`permutations')
	mat P = `a' * (S - ES)

		forvalues i = 1/$n {
			qui replace rank`i' = round(rank`i'[`g'] + P[`i',1], 1) in `row'
		}

}

* Printing average score from final round
egen total_rank = rowtotal(rank*)
local N = _N
qui sum total_rank in `N'
local end_mean = r(mean) / $n
gen counter = _n

twoway (line rank* counter), graphregion(color(white)) xlabel(minmax) legend(off) ///
xtitle("Rounds played", margin(medsmall)) ytitle("Rank", margin(medsmall)) ///
title("$n players, playing $obs rounds") ///
note("Game outcomes are uniformly random. Mean rank after final round: `end_mean'", span)

di "Average score on round `N': " `end_mean'

