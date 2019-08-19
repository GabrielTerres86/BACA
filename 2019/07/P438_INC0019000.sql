/* INC0019000 */
update crawlim x
   set x.insitlim = 2,
       x.dtanulac = null
where x.cdcooper = 1
and x.nrdconta = 4035216
and x.tpctrlim = 3
and x.nrctrlim = 7482;

update crawlim x
  set x.insitapr = 2
where x.cdcooper = 1
and x.nrdconta = 4035216
and x.tpctrlim = 3
and x.nrctrlim = 9782

delete tbmotivo_anulacao x
where x.cdcooper = 1
and x.nrdconta = 4035216
and x.tpctrlim = 3
and x.nrctrato = 7482;

commit;
