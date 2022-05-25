begin

update cecred.tbseg_prestamista a
set a.tpregist = 0
where a.cdcooper = 13
and a.NRDCONTA = 174777
and a.NRCTREMP = 199362
and a.NRCTRSEG = 336124;

update cecred.crapseg a
set a.cdsitseg = 2,
    a.dtcancel = trunc(sysdate),
    a.dtfimvig = trunc(sysdate)
where a.cdcooper = 13
and a.NRDCONTA = 174777
and a.NRCTRSEG = 336124;

commit;

end;