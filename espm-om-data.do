*** Purpose: data preparation for espm OM analysis
*** Author: S Bauldry
*** Date: March 11, 2019


*** Reading extracted data from NLS
cd ~/dropbox/research/hlthineq/mgah/espm/espm-work
infile using espm-om-raw-1/espm-om-raw-1.dct, clear

* Recoding missing
recode _all (-5 = .a) (-4 = .s) (-3/-1 = .m)

* Prepare variables for analysis
rename R0000100 id
gen s76 = ( !mi(R0285800) )

rename R0002300 race
lab def rc 1 "white" 2 "black" 3 "other"
lab val race rc

gen age66 = floor( (mdy(R0002101, R0002102, 1966) - ///
                    mdy(R0002201, 15, 1900 + R0002203))/364.25)
replace age66 = R0002200 if !mi(R0002200) & (age66 < 45 | age66 > 59)


