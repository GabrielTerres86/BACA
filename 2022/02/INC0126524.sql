begin

begin

update	tbseg_prestamista
set	situacao	= 0,
	dtrecusa	= trunc(sysdate),
	tprecusa	= 8,		/* Recusa técnica */
	cdmotrec	= 193,		/* DPS não enviada */
	tpregist	= 0
where	cdcooper	= 1
and	nrdconta	= 10194550
and	nrproposta	= '770357253470';


update	tbseg_prestamista
set	situacao	= 0,
	dtrecusa	= trunc(sysdate),
	tprecusa	= 8,
	cdmotrec	= 193,
	tpregist	= 0
where	cdcooper	= 1
and	nrdconta	= 11526580
and	nrproposta	= '770358350836';

update	tbseg_prestamista
set	situacao	= 0,
	dtrecusa	= trunc(sysdate),
	tprecusa	= 8,
	cdmotrec	= 193,
	tpregist	= 0
where	cdcooper	= 1
and	nrdconta	= 7976550
and	nrproposta	= '770353694707';

update	tbseg_prestamista
set	situacao	= 0,
	dtrecusa	= trunc(sysdate),
	tprecusa	= 8,
	cdmotrec	= 193,
	tpregist	= 0
where	cdcooper	= 1
and	nrdconta	= 10232303
and	nrproposta	= '770358456782';

update	tbseg_prestamista
set	situacao	= 0,
	dtrecusa	= trunc(sysdate),
	tprecusa	= 8,
	cdmotrec	= 193,
	tpregist	= 0
where	cdcooper	= 1
and	nrdconta	= 8230838
and	nrproposta	= '770352520098';

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
and	nrdconta	= 7976550
and	tpseguro	= 4
and	nrctrseg	= 731134;

update	crapseg
set	dtfimvig	= trunc(sysdate),
	dtcancel	= trunc(sysdate),
	cdsitseg	= 5,
	cdopeexc	= 1,
	cdageexc	= 1,
	dtinsexc	= trunc(sysdate),
	cdopecnl	= 1
where	cdcooper	= 1
and	nrdconta	= 8230838
and	tpseguro	= 4
and	nrctrseg	= 677031;

update	crapseg
set	dtfimvig	= trunc(sysdate),
	dtcancel	= trunc(sysdate),
	cdsitseg	= 5,
	cdopeexc	= 1,
	cdageexc	= 1,
	dtinsexc	= trunc(sysdate),
	cdopecnl	= 1
where	cdcooper	= 1
and	nrdconta	= 10194550
and	tpseguro	= 4
and	nrctrseg	= 846399;

update	crapseg
set	dtfimvig	= trunc(sysdate),
	dtcancel	= trunc(sysdate),
	cdsitseg	= 5,
	cdopeexc	= 1,
	cdageexc	= 1,
	dtinsexc	= trunc(sysdate),
	cdopecnl	= 1
where	cdcooper	= 1
and	nrdconta	= 10232303
and	tpseguro	= 4
and	nrctrseg	= 822230;

update	crapseg
set	dtfimvig	= trunc(sysdate),
	dtcancel	= trunc(sysdate),
	cdsitseg	= 5,
	cdopeexc	= 1,
	cdageexc	= 1,
	dtinsexc	= trunc(sysdate),
	cdopecnl	= 1
where	cdcooper	= 1
and	nrdconta	= 11526580
and	tpseguro	= 4
and	nrctrseg	= 811389;

end;

commit;

end;