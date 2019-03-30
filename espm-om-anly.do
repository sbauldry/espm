*** Purpose: espm OM analysis
*** Author: S Bauldry
*** Date: March 15, 2019


*** Loading prepared data
cd ~/dropbox/research/hlthineq/mgah/espm/espm-work
use espm-om-data, replace

* stset data
gen age76 = age66 + 10
replace aged = 62 if age76 > aged
stset aged, failure(dth) origin(time age76)

* prepare age of death for gsem command
gen raged = aged - age76

* fit overall model
gsem (raged <- i.race i.imm i.pimm i.rmar i.pmar i.pres i.res i.sth ///
  i.redu i.rocc i.pocc rinc nch i.cedu, family(weibull, fail(dth) aft))


* financial assistance and personal assistance
gsem (raged <- i.race i.imm i.pimm i.rmar i.pmar i.pres i.res i.sth ///
  i.redu i.rocc i.pocc rinc nch i.cedu fna, family(weibull, fail(dth) aft)) ///
  (fna <- i.race i.imm i.pimm i.rmar i.pmar i.pres i.res i.sth i.redu i.rocc ///
  i.pocc rinc nch i.cedu, logit)
 
nlcom _b[fna:2.cedu]*_b[raged:2.cedu]
nlcom _b[fna:3.cedu]*_b[raged:3.cedu]

gsem (raged <- i.race i.imm i.pimm i.rmar i.pmar i.pres i.res i.sth ///
  i.redu i.rocc i.pocc rinc nch i.cedu pra, family(weibull, fail(dth) aft)) ///
  (pra <- i.race i.imm i.pimm i.rmar i.pmar i.pres i.res i.sth i.redu i.rocc ///
  i.pocc rinc nch i.cedu, logit)
  
nlcom _b[pra:2.cedu]*_b[raged:2.cedu]
nlcom _b[pra:3.cedu]*_b[raged:3.cedu]

* Figure illustrating results
preserve
clear
input id est lb ub
1 0.108 0.042 0.175
2 0.065 0.010 0.120
3 0.025 -0.021 0.072
4 0.037 -0.002 0.075
5 0.108 0.046 0.171
6 0.052 0.001 0.103
7 -0.012 -0.049 0.024
8 -0.004 -0.019 0.010
end

replace est = exp(est)
replace lb  = exp(lb)
replace ub  = exp(ub)

tempfile g1 g2
graph twoway (scatter id est, msize(small)) (rspike lb ub id, horizontal) ///
  if id < 5, ylab(1 "NDE: ACE 13-15 yrs" 2 "NDE: ACE 16-18 yrs" ///
  3 "NIE: ACE 13-15 yrs" 4 "NIE: ACE 16-18 yrs", angle(h) grid gstyle(dot)) ///
  xlab(0.9(.1)1.2, grid gstyle(dot)) xtit("exponentiated estimate") ytit("") ///
  xline(1, lc(black) lp(dash)) legend(off) tit("Financial Assistance") ///
  saving(`g1')

graph twoway (scatter id est, msize(small)) (rspike lb ub id, horizontal) ///
  if id > 4, ylab(5 "NDE: ACE 13-15 yrs" 6 "NDE: ACE 16-18 yrs" ///
  7 "NIE: ACE 13-15 yrs" 8 "NIE: ACE 16-18 yrs", angle(h) grid gstyle(dot)) ///
  xlab(0.9(.1)1.2, grid gstyle(dot)) xtit("exponentiated estimate") ytit("") ///
  xline(1, lc(black) lp(dash)) legend(off) tit("Direct Care") ///
  saving(`g2')

graph combine "`g1'" "`g2'"
graph export ~/desktop/espm-paa-19-ms-fig2.pdf, replace
restore


* smoking and drinking
gen qsmk = 1 - csmk
gsem (raged <- i.race i.imm i.pimm i.rmar i.pmar i.pres i.res i.sth ///
  i.redu i.rocc i.pocc rinc nch i.cedu qsmk, family(weibull, fail(dth) aft)) ///
  (qsmk <- i.race i.imm i.pimm i.rmar i.pmar i.pres i.res i.sth i.redu ///
  i.rocc i.pocc rinc nch i.cedu, logit) if esmk == 1 

nlcom _b[qsmk:2.cedu]*_b[raged:2.cedu]
nlcom _b[qsmk:3.cedu]*_b[raged:3.cedu]

gsem (raged <- i.race i.imm i.pimm i.rmar i.pmar i.pres i.res i.sth ///
  i.redu i.rocc i.pocc rinc nch i.cedu drka, family(weibull, fail(dth) aft)) ///
  (drka <- i.race i.imm i.pimm i.rmar i.pmar i.pres i.res i.sth ///
  i.redu i.rocc i.pocc rinc nch i.cedu, ologit)
  
nlcom _b[drka:2.cedu]*_b[raged:2.cedu]
nlcom _b[drka:3.cedu]*_b[raged:3.cedu]

* Figure illustrating results
preserve
clear
input id est lb ub
1 0.071 -0.026 0.168
2 0.047 -0.033 0.128
3 0.003 -0.034 0.039
4 0.017 -0.019 0.053
5 0.125  0.058 0.193
6 0.064  0.010 0.119
7 -0.020 -0.053 0.013
8 -0.013 -0.030 0.004
end

replace est = exp(est)
replace lb  = exp(lb)
replace ub  = exp(ub)

tempfile g1 g2
graph twoway (scatter id est, msize(small)) (rspike lb ub id, horizontal) ///
  if id < 5, ylab(1 "NDE: ACE 13-15 yrs" 2 "NDE: ACE 16-18 yrs" ///
  3 "NIE: ACE 13-15 yrs" 4 "NIE: ACE 16-18 yrs", angle(h) grid gstyle(dot)) ///
  xlab(0.9(.1)1.2, grid gstyle(dot)) xtit("exponentiated estimate") ytit("") ///
  xline(1, lc(black) lp(dash)) legend(off) tit("Smoking") ///
  saving(`g1')

graph twoway (scatter id est, msize(small)) (rspike lb ub id, horizontal) ///
  if id > 4, ylab(5 "NDE: ACE 13-15 yrs" 6 "NDE: ACE 16-18 yrs" ///
  7 "NIE: ACE 13-15 yrs" 8 "NIE: ACE 16-18 yrs", angle(h) grid gstyle(dot)) ///
  xlab(0.9(.1)1.2, grid gstyle(dot)) xtit("exponentiated estimate") ytit("") ///
  xline(1, lc(black) lp(dash)) legend(off) tit("Drinking") ///
  saving(`g2')

graph combine "`g1'" "`g2'"
graph export ~/desktop/espm-paa-19-ms-fig3.pdf, replace
restore
