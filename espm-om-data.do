*** Purpose: data preparation for espm OM analysis
*** Author: S Bauldry
*** Date: March 11, 2019


*** Reading extracted data from NLS
cd ~/dropbox/research/hlthineq/mgah/espm/espm-work
infile using espm-om-raw/espm-om-raw.dct, clear

* Recoding missing
recode _all (-5 = .a) (-4 = .s) (-3/-1 = .m)

* ID and 1976 sample flag
rename R0000100 id
gen s76 = ( !mi(R0285800) )

* age and age of death
rename R0002200 age66
lab var age66 "age in 1966"

rename R0787700 aged
replace aged = R0787800 if mi(aged) & !mi(R0787800)
replace aged = R0707500 if mi(aged) & !mi(R0707500)

* still alive indicator
gen dth = ( !mi(aged) )
lab var dth "R died"

* replace age in 2013 for still alive
replace aged = age66 + 45 if mi(aged)

* truncate age at 90 and fix age for N = 15 cases died before first survey
recode aged (91/max = 90)
replace aged = age66 + 1 if age66 >= aged
lab var aged "age of death or age in 2013"

* sociodemographic measures
rename R0002300 race
lab def rc 1 "white" 2 "black" 3 "other", replace
lab val race rc
lab var race "race"

gen pimm = ( R0029000 != 1 | R0029100 != 1 )
replace pimm = . if mi(R0029000)  & mi(R0029100)
lab var pimm "1 or 2 parents foreign-born"

local mar R0002400 R0063700 R0116400 R0164000 R0268850 R0285000 R0325210 ///
  R0374000 R0407700 R0474200 R0549800 R0703300
gen rmar = .
foreach y in 66 67 69 71 73 75 76 78 80 81 83 90 {
  gettoken v mar : mar
  replace rmar = 1 if (`v' == 1 | `v' == 2) & (rmar	== 4 | mi(rmar))
  replace rmar = 2 if (`v' == 3           ) & (rmar	== 1 | mi(rmar))
  replace rmar = 3 if (`v' == 4 | `v' == 5) & (rmar	== 1 | mi(rmar))
  replace rmar = 4 if (`v' == 6           ) & (            mi(rmar))
}

recode R0029700 (1 = 1) (2/max = 0), gen(pmar)
lab def pm 0 "other" 1 "2 bio parents", replace
lab val pmar pm
lab var pm "age 15 family structure"

recode R0056400 (0/11 = 1) (12 = 2) (13/18 = 3), gen(redu)
lab def re 1 "0-11 yrs" 2 "12 yrs" 3 "13-18 yrs", replace
lab val redu re
lab var redu "R education"

recode R0010700 (601/985 = 1) (301/555 = 2) (0/195 250/290 = 3) ///
  (200/222 = 4) (995 = .), gen(rocc)
lab def oc 1 "manual" 2 "skilled" 3 "white collar" 4 "farm", replace
lab val rocc oc
lab var rocc "R occupation"

recode R0029800 (601/985 = 1) (301/555 = 2) (0/195 250/290 = 3) ///
  (200/222 = 4) (995 = .), gen(pocc)
lab val pocc oc
lab var pocc "parent occupation"

recode R0029900 (0/6 = 1) (7/11 = 2) (12/18 = 3), gen(pedu)
replace pedu = 1 if pocc == 0 | pocc == 3 & mi(pedu)
lab var pedu "parent education"

* adjust wealth and income to 2017 dollars
local inf ///
  /// inf  yr ///
      7.55 66 ///
	  7.33 67 ///
	  6.67 69 ///
	  6.04 71 ///
	  5.51 73 ///
	  4.55 75 ///
	  4.30 76 ///
	  3.75 78 ///
      2.97 80 ///
      2.69 81 ///
      1.87 90

local ass R0057700 R0162200 R0254000 R0371400 R0547900 R0708200

foreach y in 66 69 71 76 81 90 {
  local inf2 "`inf'"
  while "`yr'" != "`y'" {
    gettoken in inf2 : inf2
	gettoken yr inf2 : inf2
  }
  
  gettoken a ass : ass
  
  gen ass`y' = `a'*`in'
  local ra = 65 - (`y' - 66)
  replace ass`y' = .o if age66 >= `ra'
}

egen rwth = rowmean(ass*)
lab var rwth "average net worth"

local inc R0057500 R0106300 R0162300 R0253900 R0267600 R0283700 R0371100 ///
  R0403820 R0434920 R0547710 R0708600

recode R0403820 (0 = .) if R0373900 != -4
recode R0434920 (0 = .) if R0407600 != -4 
recode `inc' (min/0 = 0)

foreach y in 66 67 69 71 73 75 76 78 80 81 90 {
  local inf2 "`inf'"
  while "`yr'" != "`y'" {
    gettoken in inf2 : inf2
	gettoken yr inf2 : inf2
  }
  
  gettoken i inc : inc
  
  gen inc`y' = `i'*`in'
  local ra = 65 - (`y' - 66)
  replace inc`y' = .o if age66 >= `ra'
}

egen rinc = rowmean(inc*)
lab var rinc "average income"

* adult children measures

* relationships in and out of household in 66, 67, 69, 76
local HH66 R0032900 R0033700 R0034500 R0035300 R0036100 R0036900 R0037700  ///
  R0038500 R0039300 R0040100 R0040900 R0041700 R0042500 R0043300 R0044100  ///
  R0044900 R0045700 R0046500 R0047300 R0048100

local OH66 R0030700 R0030900 R0031100 R0031300 R0031500 R0031700 R0031900 ///
  R0032100 R0032300 R0032500
  
local HH67 R0084600 R0085400 R0086200 R0087000 R0087800 R0088600 R0089400 ///
  R0090200 R0091000 R0091800 R0092600 R0093400 R0094200 R0095000 R0095800 ///
  R0096600 R0097400

local HH69 R0138600 R0139400 R0140200 R0141000 R0141800 R0142600 R0143400 ///
  R0144200 R0145000 R0145800 R0146600 R0147400 R0148200 R0149000 R0149800 ///
  R0151400

local HH76 R0352900 R0353700 R0354500 R0355300 R0356100 R0356900 R0357700 ///
  R0358500 R0359300 R0360900 R0361700

local OH76 R0342700 R0343500 R0344300 R0345100 R0345900 R0346700 R0347500 ///
  R0348300 R0349100 R0349900 R0350700 R0351500

* recode gender to match other variables
recode `OH76' (2 = 3) (3 = 4)

foreach yr in 66 67 69 76 {
  egen nc`yr' = anycount(`HH`yr'' `OH`yr''), v(2 3 4)
}
egen nch = rowmax(nc*)
lab var nch "number of children"

* education
rename R0051400 cedu66

* 76 combine info for household (i), outside (o), and son in laws (s)
local iRel R0352900 R0353700 R0354500 R0355300 R0356100 R0356900 R0357700 ///
  R0358500 R0359300 R0360900 R0361700

local iAge R0353000 R0353800 R0354600 R0355400 R0356200 R0357000 R0357800 ///
  R0358600 R0359400 R0361000 R0361800

local iEdu R0353200 R0354000 R0354800 R0355600 R0356400 R0357200 R0358000 ///
  R0358800 R0359600 R0361200 R0362000

local oRel R0342700 R0343500 R0344300 R0345100 R0345900 R0346700 R0347500 ///
  R0348300 R0349100 R0349900 R0350700 R0351500

local oAge R0342800 R0343600 R0344400 R0345200 R0346000 R0346800 R0347600 ///
  R0348400 R0349200 R0350000 R0350800 R0351600

local oEdu R0342900 R0343700 R0344500 R0345300 R0346100 R0346900 R0347700 ///
  R0348500 R0349300 R0350100 R0350900 R0351700

local sEdu R0343300 R0344100 R0344900 R0345700 R0346500 R0347300 R0348100 ///
  R0348900 R0349700 R0350500 R0351300 R0352100
  
* drop adult children under 25
foreach v in Edu {
  foreach h in o i s {
    local agehold "``h'Age'"
    local varhold "``h'`v''"
    local relhold "``h'Rel'"

    while "`varhold'"!="" {
      gettoken newv varhold : varhold
      gettoken cage agehold : agehold
      gettoken relv relhold : relhold

      qui gen `newv'25 = `newv'
      if "`h'" != "s" qui replace `newv'25 = . if `cage' < 25
      if "`h'" == "i" qui replace `newv'25 = . if `relv' < 2 | `relv' > 4

      local `h'`v'25 "``h'`v'25' `newv'25"
    }
  }
}

egen cedu76 = rowmax(`oEdu25' `iEdu25' `sEdu25')
egen cedumx = rowmax(cedu66 cedu76)
recode cedumx (0/12 = 1)(13/15 = 2) (16/18 = 3), gen(cedu)
lab def ce 1 "0-12 yrs" 2 "13-15 yrs" 3 "16-18 yrs", replace
lab val cedu ce
lab var cedu "max adult child education"




  
