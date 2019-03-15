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

* plot survivor curve
sts graph

* prepare age of death for gsem command
gen raged = aged - age76

* fit overall model
gsem (raged <- i.race i.imm i.pimm i.rmar i.pmar i.pres i.res i.sth ///
  i.redu i.rocc i.pocc rinc nch i.cedu, family(weibull, fail(dth) aft))



gsem (raged <- i.race i.imm i.pimm i.rmar i.pmar i.pres i.res i.sth ///
  i.redu i.rocc i.pocc rinc nch i.cedu drkf, family(weibull, fail(dth) aft)) ///
  (drkf <- i.race i.imm i.pimm i.rmar i.pmar i.pres i.res i.sth ///
  i.redu i.rocc i.pocc rinc nch i.cedu)
  
nlcom _b[drkf:2.cedu]*_b[raged:2.cedu]
nlcom _b[drkf:3.cedu]*_b[raged:3.cedu]
  
gsem (raged <- i.race i.imm i.pimm i.rmar i.pmar i.pres i.res i.sth ///
  i.redu i.rocc i.pocc rinc nch i.cedu drka, family(weibull, fail(dth) aft)) ///
  (drka <- i.race i.imm i.pimm i.rmar i.pmar i.pres i.res i.sth ///
  i.redu i.rocc i.pocc rinc nch i.cedu)
  
nlcom _b[drka:2.cedu]*_b[raged:2.cedu]
nlcom _b[drka:3.cedu]*_b[raged:3.cedu]
  
gsem (raged <- i.race i.imm i.pimm i.rmar i.pmar i.pres i.res i.sth ///
  i.redu i.rocc i.pocc rinc nch i.cedu fna, family(weibull, fail(dth) aft)) ///
  (fna <- i.race i.imm i.pimm i.rmar i.pmar i.pres i.res i.sth ///
  i.redu i.rocc i.pocc rinc nch i.cedu)
  
nlcom _b[fna:2.cedu]*_b[raged:2.cedu]
nlcom _b[fna:3.cedu]*_b[raged:3.cedu]
  
gsem (raged <- i.race i.imm i.pimm i.rmar i.pmar i.pres i.res i.sth ///
  i.redu i.rocc i.pocc rinc nch i.cedu pra, family(weibull, fail(dth) aft)) ///
  (pra <- i.race i.imm i.pimm i.rmar i.pmar i.pres i.res i.sth ///
  i.redu i.rocc i.pocc rinc nch i.cedu)
  
nlcom _b[pra:2.cedu]*_b[raged:2.cedu]
nlcom _b[pra:3.cedu]*_b[raged:3.cedu]
  
gsem (raged <- i.race i.imm i.pimm i.rmar i.pmar i.pres i.res i.sth ///
  i.redu i.rocc i.pocc rinc nch i.cedu csmk, family(weibull, fail(dth) aft)) ///
  (csmk <- i.race i.imm i.pimm i.rmar i.pmar i.pres i.res i.sth ///
  i.redu i.rocc i.pocc rinc nch i.cedu) if esmk == 1 

nlcom _b[csmk:2.cedu]*_b[raged:2.cedu]
nlcom _b[csmk:3.cedu]*_b[raged:3.cedu]
