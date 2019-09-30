/* EmpiricalPSet */
cd "C:\Users\hallcott\Documents\GitHub\BehavioralPublicProblemSet\analysis\" // put your own file path here

/* REPLICATE TABLE 1 */
global statfontsize = "footnotesize"
global DemographicVars = "Income Education Age Male Liberal Party Environmentalist ConserveEnergy OwnHome"



outreg,clear
use input/PreppedTESSData.dta, clear

/* Average Treatment Effects */
reg WTP2 T [pweight=Weight], robust, if WTP1!=. // Eliminate WTP1==. for sample consistency
	outreg, se merge replace varlabels tex fragment starlevels(10 5 1) sdec(2) statfont($statfontsize) summstat(r2 \ N) ///
		keep(T)

reg WTP2 T WTP1_C* [pweight=Weight], robust
	outreg, se merge replace varlabels tex fragment starlevels(10 5 1) sdec(2) statfont($statfontsize) summstat(r2 \ N) ///
		keep(T)

reg WTP2 T WTP1_C* $DemographicVars [pweight=Weight], robust
	outreg, se merge replace varlabels tex fragment starlevels(10 5 1) sdec(2) statfont($statfontsize) summstat(r2 \ N) ///
		keep(T)

	local baseline = _b[T]
		
* Eliminate top-coded and bottom-coded WTPs, because the largest WTP1 consumers have no way to reveal their increase in WTP.
reg WTP2 T WTP1_C* $DemographicVars [pweight=Weight], robust, if WTP1<=9&WTP1>=-9
	outreg, se merge replace varlabels tex fragment starlevels(10 5 1) sdec(2)  statfont($statfontsize) summstat(r2 \ N) ///
		keep(T)
		
* Consistency bias robustness check
reg WTP2 T EndlineOnly $DemographicVars [pweight=Weight], robust
		*reg WTP2 T [pweight=Weight], robust, if EndlineOnly==1|T==0
	outreg, se merge replace varlabels tex fragment starlevels(10 5 1) sdec(2)  statfont($statfontsize) summstat(r2 \ N) ///
		keep(T EndlineOnly)		
		
* T and TP
reg WTP2 T TP WTP1_C* $DemographicVars [pweight=Weight], robust
	outreg, se merge replace varlabels tex fragment starlevels(10 5 1) sdec(2)  statfont($statfontsize) summstat(r2 \ N) ///
		keep(T TP)

		
	local ratio3 = _b[T]/`baseline' // This is the scaling ratio for welfare calculations.
	display `ratio3'
		
outreg using "output/TESSATEs", replay replace tex fragment statfont($statfontsize) keep(T TP WTP1)  ///
				ctitles("","(1)","(2)","(3)","(4)","(5)","(6)") ///
				addrows("Baseline WTP Dummies $\mu$","No","Yes","Yes","Yes","No","Yes" \ ///
				"Individual Characteristics","No","No","Yes","Yes","Yes","Yes" \ ///
						"Exclude Max./Min. Baseline WTP","No","No","No","Yes","No","No" \ ///
						"Include Endline-Only Group","No","No","No","No","Yes","No")
