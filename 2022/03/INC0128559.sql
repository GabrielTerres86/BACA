begin

begin

update	tbseg_prestamista
set	situacao	= 0,
	dtrecusa	= trunc(sysdate),
	tprecusa	= 8,
	cdmotrec	= 193,
	tpregist	= 0
where	cdcooper	= 1
and	nrdconta	= 2954591
and	nrproposta	= '770358015344';

update	tbseg_prestamista
set	situacao	= 0,
	dtrecusa	= trunc(sysdate),
	tprecusa	= 8,
	cdmotrec	= 193,
	tpregist	= 0
where	cdcooper	= 1
and	nrdconta	= 3973786
and	nrproposta	= '770358424694';

update	tbseg_prestamista
set	situacao	= 0,
	dtrecusa	= trunc(sysdate),
	tprecusa	= 8,
	cdmotrec	= 193,
	tpregist	= 0
where	cdcooper	= 1
and	nrdconta	= 7139489
and	nrproposta	= '770353758705';

update	tbseg_prestamista
set	situacao	= 0,
	dtrecusa	= trunc(sysdate),
	tprecusa	= 8,
	cdmotrec	= 193,
	tpregist	= 0
where	cdcooper	= 1
and	nrdconta	= 7367627
and	nrproposta	= '770358689515';

update	tbseg_prestamista
set	situacao	= 0,
	dtrecusa	= trunc(sysdate),
	tprecusa	= 8,
	cdmotrec	= 193,
	tpregist	= 0
where	cdcooper	= 1
and	nrdconta	= 8071284
and	nrproposta	= '770355879313';

end;

begin

update	crapseg
set	dtfimvig	= trunc(sysdate),
	dtcancel	= trunc(sysdate),
	cdsitseg	= 5,
	cdopeexc	= 1,
	cdageexc	= 1,
	dtinsexc	= trunc(sysdate),
	cdopecnl	= 1
where	cdcooper	= 1
and	nrdconta	= 8071284
and	tpseguro	= 4
and	nrctrseg	= 937561;

update	crapseg
set	dtfimvig	= trunc(sysdate),
	dtcancel	= trunc(sysdate),
	cdsitseg	= 5,
	cdopeexc	= 1,
	cdageexc	= 1,
	dtinsexc	= trunc(sysdate),
	cdopecnl	= 1
where	cdcooper	= 1
and	nrdconta	= 2954591
and	tpseguro	= 4
and	nrctrseg	= 822511;

update	crapseg
set	dtfimvig	= trunc(sysdate),
	dtcancel	= trunc(sysdate),
	cdsitseg	= 5,
	cdopeexc	= 1,
	cdageexc	= 1,
	dtinsexc	= trunc(sysdate),
	cdopecnl	= 1
where	cdcooper	= 1
and	nrdconta	= 3973786
and	tpseguro	= 4
and	nrctrseg	= 849122;

update	crapseg
set	dtfimvig	= trunc(sysdate),
	dtcancel	= trunc(sysdate),
	cdsitseg	= 5,
	cdopeexc	= 1,
	cdageexc	= 1,
	dtinsexc	= trunc(sysdate),
	cdopecnl	= 1
where	cdcooper	= 1
and	nrdconta	= 7139489
and	tpseguro	= 4
and	nrctrseg	= 733475;

update	crapseg
set	dtfimvig	= trunc(sysdate),
	dtcancel	= trunc(sysdate),
	cdsitseg	= 5,
	cdopeexc	= 1,
	cdageexc	= 1,
	dtinsexc	= trunc(sysdate),
	cdopecnl	= 1
where	cdcooper	= 1
and	nrdconta	= 7367627
and	tpseguro	= 4
and	nrctrseg	= 806475;

end;

commit;

end;