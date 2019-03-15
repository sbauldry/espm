*** Purpose: descriptives for espm OM analysis
*** Author: S Bauldry
*** Date: March 15, 2019


*** Loading prepared data
cd ~/dropbox/research/hlthineq/mgah/espm/espm-work
use espm-om-data, replace

* stset data for associations
gen age76 = age66 + 10
stset aged, failure(dth) origin(time age76)

*** drinking
preserve
drop if mi(drkf, drka)

* univariate
tab drkf
tab drka
tab cedu

* associations
eststo clear
qui reg drkf i.redu i.cedu
eststo m1

qui reg drka i.redu i.cedu
eststo m2

qui streg i.redu i.cedu, d(gompertz)
eststo m3

qui streg i.redu i.cedu drkf, d(gompertz)
eststo m4

qui streg i.redu i.cedu drka, d(gompertz)
eststo m5

esttab m1 m2 m3 m4 m5, b(%5.2f) not star nomti compress
restore


*** financial assistance and support
preserve
drop if mi(fna, pra)

* univariate
sum fna pra
tab cedu

* associations
eststo clear
qui logit fna i.redu i.cedu
eststo m1

qui logit pra i.redu i.cedu
eststo m2

qui streg i.redu i.cedu, d(gompertz)
eststo m3

qui streg i.redu i.cedu pra, d(gompertz)
eststo m4

qui streg i.redu i.cedu fna, d(gompertz)
eststo m5

esttab m1 m2 m3 m4 m5, b(%5.2f) not star nomti compress
restore


*** smoking
preserve
keep if esmk == 1

* univariate
tab csmk
tab cedu

* associations
eststo clear
qui logit csmk i.redu i.cedu
eststo m1

qui streg i.redu i.cedu, d(gompertz)
eststo m2

qui streg i.redu i.cedu csmk, d(gompertz)
eststo m3

esttab m1 m2 m3, b(%5.2f) not star nomti compress
restore

