begin

begin

update	crapseg
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

update	crapseg
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

update	crapseg
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

update	crapseg
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

update	tbseg_prestamista
set	tpregist	= 0
where	cdcooper	= 13
and	nrdconta	= 8320
and	nrctrseg	= 368532;

end;

commit;

end;