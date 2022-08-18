begin

begin

update	cecred.crapseg
set	dtfimvig	= trunc(sysdate),
	dtcancel	= trunc(sysdate),
	cdsitseg	= 5,
	cdopeexc	= 1,
	cdageexc	= 1,
	dtinsexc	= trunc(sysdate),
	cdopecnl	= 1
where cdcooper	= 1
and	nrdconta	= 80343988
and	tpseguro	= 4
and	nrctrseg	= 1084821;

update	cecred.crapseg
set	dtfimvig	= trunc(sysdate),
	dtcancel	= trunc(sysdate),
	cdsitseg	= 5,
	cdopeexc	= 1,
	cdageexc	= 1,
	dtinsexc	= trunc(sysdate),
	cdopecnl	= 1
where cdcooper	= 1
and	nrdconta	= 6177220
and	tpseguro	= 4
and	nrctrseg	= 1083187;

update	cecred.crapseg
set	dtfimvig	= trunc(sysdate),
	dtcancel	= trunc(sysdate),
	cdsitseg	= 2,
	cdopeexc	= 1,
	cdageexc	= 1,
	dtinsexc	= trunc(sysdate),
	cdopecnl	= 1
where cdcooper	= 1
and	nrdconta	= 8526370
and	tpseguro	= 4
and	nrctrseg	= 1018728;

update	cecred.crapseg
set	dtfimvig	= trunc(sysdate),
	dtcancel	= trunc(sysdate),
	cdsitseg	= 2,
	cdopeexc	= 1,
	cdageexc	= 1,
	dtinsexc	= trunc(sysdate),
	cdopecnl	= 1
where cdcooper	= 13
and	nrdconta	= 8320
and	tpseguro	= 4
and	nrctrseg	= 368532;

end;

begin

update	cecred.tbseg_prestamista
set	tpregist	= 0
where	cdcooper	= 13
and	nrdconta	= 8320
and	nrctrseg	= 368532;

end;

BEGIN
  UPDATE cecred.tbseg_prestamista p
     SET p.tpregist = 3
   WHERE p.cdcooper = 13
     AND p.nrproposta = '770629332928';

  UPDATE cecred.crapseg p
     SET p.cdmotcan = 20
   WHERE p.cdcooper = 13
     AND p.nrdconta = 654116
     AND p.nrctrseg = 347849
     AND p.tpseguro = 4;
  
END;

commit;

end;