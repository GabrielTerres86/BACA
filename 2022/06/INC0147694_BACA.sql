begin

update cecred.tbseg_prestamista a
set a.tpregist = 0
where a.cdcooper = 13
and a.NRDCONTA = 539112
and a.NRCTREMP = 206013
and a.NRCTRSEG = 346636;

update cecred.crapseg a
set a.cdsitseg = 2,
    a.dtcancel = trunc(sysdate),
    a.dtfimvig = trunc(sysdate)
where a.cdcooper = 13
and a.NRDCONTA = 539112
and a.NRCTRSEG = 346636;

update cecred.tbseg_prestamista a
set a.tpregist = 0
where a.cdcooper = 2
and a.NRDCONTA = 502049
and a.NRCTREMP = 228894
and a.NRCTRSEG = 14785;

update cecred.crapseg a
set a.cdsitseg = 2,
    a.dtcancel = trunc(sysdate),
    a.dtfimvig = trunc(sysdate)
where a.cdcooper = 2
and a.NRDCONTA = 502049
and a.NRCTRSEG = 14785;

commit;

end;