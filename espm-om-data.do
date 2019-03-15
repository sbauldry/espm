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

gen imm = (R0028400 == 7) if !mi(R0028400)
lab var imm "immigrant"

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
lab def rm1 1 "married" 2 "widow" 3 "separated" 4 "never", replace

* recoding due to small N
recode rmar (1 = 1) (2 3 4 = 0)
lab var rmar "marital history"

recode R0029700 (1 = 1) (2/max = 0), gen(pmar)
lab def pm 0 "other" 1 "2 bio parents", replace
lab val pmar pm
lab var pmar "age 15 family structure"

recode R0029600 (1 2 = 3) (2 4 = 2) (5 6 = 1), gen(pres)
lab def pr 1 "rural" 2 "town" 3 "city", replace
lab val pres pr
lab var pres "city size age 15"

recode R0002500 (1 2 3 = 3) (4/7 = 2) (8 = 1), gen(res)
lab val res pr
lab var res "city size"

rename R0287052 sth
lab var sth "living in South"

recode R0056400 (0/11 = 1) (12 = 2) (13/18 = 3), gen(redu)
lab def re 1 "0-11 yrs" 2 "12 yrs" 3 "13-18 yrs", replace
lab val redu re
lab var redu "education"

recode R0010700 (601/985 = 1) (301/555 = 2) (0/195 250/290 = 3) ///
  (200/222 = 4) (995 = .), gen(rocc)
lab def oc 1 "manual" 2 "skilled" 3 "white collar" 4 "farm", replace
lab val rocc oc
lab var rocc "occupation"

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

foreach yr in 66 67 69 76 {
  egen nc`yr' = anycount(`HH`yr'' `OH`yr''), v(2 3 4)
}
egen nch = rowmax(nc*)
lab var nch "number of children"

* education
rename R0051400 cedu66

* 76 
local oAge R0342800 R0343600 R0344400 R0345200 R0346000 R0346800 R0347600 ///
  R0348400 R0349200 R0350000 R0350800 R0351600

local oEdu R0342900 R0343700 R0344500 R0345300 R0346100 R0346900 R0347700 ///
  R0348500 R0349300 R0350100 R0350900 R0351700

local sEdu R0343300 R0344100 R0344900 R0345700 R0346500 R0347300 R0348100 ///
  R0348900 R0349700 R0350500 R0351300 R0352100
  
* filter adult children over 25
forval i = 1/12 {
  gettoken age oAge : oAge
  gettoken oed oEdu : oEdu  
  gettoken sed sEdu : sEdu

  qui gen r`oed' = `oed' if `age' >= 25
  qui gen s`sed' = `sed' if `age' >= 25
  qui gen r`age' = `age' if `age' >= 25
  
  local roEdu "`roEdu' r`oed'"
  local rsEdu "`rsEdu' s`sed'"
  local roAge "`roAge' r`age'"
}

* determine max education and age
egen cedumax = rowmax(`roEdu' `rsEdu')

gen ceduage = .
forval i = 1/12 {
  gettoken oed roEdu : roEdu
  gettoken sed rsEdu : rsEdu
  gettoken age roAge : roAge
  
  replace ceduage = `age' if `oed' == cedumax & !mi(`oed') & ceduage > `age'
  replace ceduage = `age' if `sed' == cedumax & !mi(`sed') & ceduage > `age'
}

recode cedumax (0/12 = 1)(13/15 = 2) (16/18 = 3), gen(cedu)
lab def ce 1 "0-12 yrs" 2 "13-15 yrs" 3 "16-18 yrs", replace
lab val cedu ce
lab var cedu "max adult child education"
lab var ceduage "age of adult child with max education"

* mediators

* financial assistance from 80 & 90
gen fna = ( (R0540100 == 1 | R0540100 == 2) & R0540200 == 1 ) ///
  if !mi(R0540100) & !mi(R0540200)
replace fna = 1 if R0661100 == 1 | R0661100 == 2
lab var fna "adult child for financial assistance 80/90"

* personal assistance from 80 & 90
gen pra = ( (R0540800 == 1 | R0540800 == 2) & R0540900 == 1 ) ///
  if !mi(R0540800) & !mi(R0540900)
replace pra = 1 if R0661500 == 1 & ( R0661600 == 2 | R0661600 == 3 )
lab var pra "adult child for personal assistance 80/90"

* drinking from 90
recode R0628900 (0 = 6)
gen drkf = 6 - R0720700 if !mi(R0720700)
replace drkf = 6 - R0628900 if mi(drkf) & !mi(R0628900)
replace drkf = 0 if R0628600 == 0 | R0720400 == 0 
lab def df 0 "0" 1 "< 1/m" 2 "1-3/m" 3 "1-2/w" 4 "3-6/w" 5 "every day", replace
lab val drkf df
lab var drkf "drinking frequency 90"

gen drka = 7 - R0720800 if !mi(R0720800)
replace drka = 7 - R0628800 if mi(drka) & !mi(R0628800)
replace drka = 0 if R0628600 == 0 | R0720400 == 0 
replace drka = 0 if drkf == 0 & mi(drka)
lab def da 0 "0" 1 "1" 2 "2" 3 "3 or 4" 4 "5 or 6" 5 "7-11" 6 "12+", replace
lab val drka da
lab var drka "drinking amount 90"

* smoking
gen ceduyr = 1976 - (ceduage - 25)
gen ssmkyr = (1966 - age66) + R0628400
replace ssmkyr = (1966 - age66) + R0719700 if mi(ssmkyr)

rename R0627700 csmk
replace csmk = 0 if R0719600 == 0 & mi(csmk)

rename R0628100 esmk
replace esmk = R0719600 if mi(esmk)
replace esmk = 1 if csmk == 1

* remove N = 454 past smokers who quit before adult child completed education
replace esmk = 0 if ssmkyr < ceduyr & !mi(ssmkyr) & !mi(ceduyr)

* filling in current smoking
replace csmk = 0 if esmk == 0
replace csmk = 0 if esmk == 1 & mi(csmk)

lab var csmk "current smoker 90"
lab var esmk "ever smoked after child's edu 90"

* keeping analysis variables
order id s76 age66 aged dth race imm pimm rmar pmar pres res sth redu rocc ///
  pedu pocc rwth rinc nch cedu fna pra drkf drka csmk esmk 
keep id-esmk

* sample selection: in 1976, have children, non-missing children's education
keep if s76
keep if nch > 0
keep if !mi(cedu)
keep if race != 3

* sample selection: non-missing on covariates (except parent education)
* dropping N = 289, 12%
keep if !mi(imm, pimm, pmar, pres, redu, rocc, pocc, rwth, rinc)

* saving data for analysis
save espm-om-data, replace
