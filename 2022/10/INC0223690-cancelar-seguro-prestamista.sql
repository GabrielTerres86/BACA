begin

update cecred.tbseg_prestamista a
set a.tpregist = 0
where a.cdcooper = 11
and a.nrdconta = 380210
and a.nrproposta = '770349475669'
and a.nrctrseg = 25244;

update cecred.crapseg a
set a.cdsitseg = 2,
    a.dtcancel = trunc(sysdate),
    a.dtfimvig = trunc(sysdate)
where a.cdcooper = 11
and a.nrdconta = 380210
and a.nrctrseg = 25244;

commit;

end;