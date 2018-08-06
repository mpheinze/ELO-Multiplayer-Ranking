***** ------------------------------------------------------------------------------ *****
***** --------- Elo Ranking System - Demonstrating the Deminishing Returns --------- *****
***** ------------------------------------------------------------------------------ *****

clear all

* defining mata functions
mata : 
	real matrix scorevector(real matrix a,
									real matrix b,
									real matrix c) {
		
		return(a :* (b - c))
		
	}
	end


* ----- Setting parameters ----- *

local games = 1000
local players = 9
local min_part = 3
local start_rank = 100

* ------------------------------ *

local row_count = `games' + 1
set obs `row_count'

qui gen participants = .

	forvalues i = 1/`players' {
		qui gen player`i' = `start_rank' in 1
		* qui gen player`i' = runiformint(50, 150) in 1
		qui gen pos`i' = .
		qui gen gcount`i' = .
	}

***** --------------- main script --------------- *****

	forvalues g = 1/`games' {
		
		* choosing participants, game positions, and game counts
		local participants = runiformint(`min_part', `players')
		local part_list = ""
		
		replace participants = `participants' in `g'
		
			forvalues k = 1/`participants' {
				
				* collective - uniform distribution
				local j = runiformint(1, `players')
				
				/*
				* collective - poisson distribution
				local j = rpoisson(1.4) + 1
					if `j' > 10 {
						local j = 10
					} 
				*/
				
				* targeted - augmented uniform distribution
				* targeted - augmented normal distribution
				
				
				local boolean = 0
					while `boolean' == 0 {
						if strpos("`part_list'", " `j' ") {
							local j = runiformint(1, `players')
						}
						else {
							local boolean = 1
						}
					}
				local part_list = "`part_list'" + " `j' "
				qui replace pos`j' = `k' in `g'
				qui sum gcount`j'
				qui replace gcount`j' = r(N) + 1 in `g'
			}
		
		* calculating game ranking
		mat S = J(`players', 1, 0)
		mat K = J(`players', 1, 0)
		mat E = J(`players', `players', 0)
		local permutations = `participants' * (`participants' - 1) / 2
		local a = 800
		local b = 10
		local c = 400
		
			* matrix S - earned points
			foreach i in `part_list' {
				mat S[`i',1] = (`participants' - pos`i'[`g']) / `permutations'
			}
			
			* matrix E - estimated win probability
			foreach i in `part_list' {
				foreach j in `part_list' {
					if `i' != `j' {
						mat E[`i',`j'] = 1 / (1 + `b'^((player`j'[`g'] - player`i'[`g']) / `c'))
					}
				}
			}
			
			* matrix K - the K factor
			foreach i in `part_list' {
				mat K[`i',1] = `a' / (sqrt(gcount`i'[`g']) + (`players' - `participants')^2)
			}
		
		mata : st_matrix("ES", rowsum(st_matrix("E")))
		mat ES = ES / (`permutations')
		mata : st_matrix("P", scorevector(st_matrix("K"), st_matrix("S"), st_matrix("ES")))
		
		* updating new ranking
		local row = `g' + 1
		
			forvalues i = 1/`players' {
				qui replace player`i' = round(player`i'[`g'] + P[`i',1], 1) in `row'
			}
	}

sum pos*


***** --------------- ranking diagnostics --------------- *****

* Printing average score from final round
capture egen total_rank = rowtotal(player*)
local N = _N
qui sum total_rank in `N'
local end_mean = round(r(mean) / `players', .000)
gen game_id = _n
local label_tick = `games' / 2
local label_max = `games' - 1

twoway (bar participants game_id, yaxis(1) yscale(range(0(5)40) axis(1)) ylabel(, ///
nolabels noticks nogrid) fcolor(navy8) fintensity(30) lcolor(white) lwidth(none)) ///
(line player* game_id, yaxis(2) yscale(range(0) axis(2))), graphregion(color(white)) ///
xlabel(0(`label_tick')`label_max') legend(off) xtitle("Games played", margin(medsmall)) ///
ytitle("Rank", margin(medsmall)) title("`players' players, playing `games' games") ///
note("Game outcomes are uniformly random. Mean rank after final round: `end_mean'", span)

di "Average score on round `N': " `end_mean'


exit
* producing table of mean points by score and game size
reshape long player pos gcount, i(game_id) j(player_id)
tsset player_id game_id
gen fd_rank = fd.player

table pos participants, c(mean fd_rank) col f(%9.1g)

exit
















