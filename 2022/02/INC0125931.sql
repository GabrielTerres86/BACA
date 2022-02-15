begin

begin

update	tbseg_prestamista
set	situacao	= 0,
	dtrecusa	= trunc(sysdate),
	tprecusa	= 8,		/* Recusa técnica */
	cdmotrec	= 193,		/* DPS não enviada */
	tpregist	= 0
where	cdcooper	= 1
and	nrdconta	= 8057672
and	nrproposta	= '770358283454';

update	tbseg_prestamista
set	situacao	= 0,
	dtrecusa	= trunc(sysdate),
	tprecusa	= 8,		/* Recusa técnica */
	cdmotrec	= 193,		/* DPS não enviada */
	tpregist	= 0
where	cdcooper	= 1
and	nrdconta	= 1936697
and	nrproposta	= '770354534290';

update	tbseg_prestamista
set	situacao	= 0,
	dtrecusa	= trunc(sysdate),
	tprecusa	= 8,		/* Recusa técnica */
	cdmotrec	= 193,		/* DPS não enviada */
	tpregist	= 0
where	cdcooper	= 1
and	nrdconta	= 3663124
and	nrproposta	= '770355498280';

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
and	nrdconta	= 8057672
and	tpseguro	= 4
and	nrctrseg	= 809665;

update	crapseg
set	dtfimvig	= trunc(sysdate),
	dtcancel	= trunc(sysdate),
	cdsitseg	= 5,
	cdopeexc	= 1,
	cdageexc	= 1,
	dtinsexc	= trunc(sysdate),
	cdopecnl	= 1
where	cdcooper	= 1
and	nrdconta	= 3663124
and	tpseguro	= 4
and	nrctrseg	= 950043;

update	crapseg
set	dtfimvig	= trunc(sysdate),
	dtcancel	= trunc(sysdate),
	cdsitseg	= 5,
	cdopeexc	= 1,
	cdageexc	= 1,
	dtinsexc	= trunc(sysdate),
	cdopecnl	= 1
where	cdcooper	= 1
and	nrdconta	= 1936697
and	tpseguro	= 4
and	nrctrseg	= 742988;

end;

commit;

end;