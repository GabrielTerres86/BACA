begin

update	crapseg
set	dtfimvig	= null,
	dtcancel	= null,
	cdsitseg	= 1,
	cdopeexc	= ' ',
	cdageexc	= 0,
	dtinsexc	= null,
	cdopecnl	= ' '
where	cdcooper	= 1
and	nrdconta	= 822841
and	tpseguro	= 4
and	nrctrseg	= 668533;

update	crapseg
set	dtfimvig	= trunc(sysdate),
	dtcancel	= trunc(sysdate),
	cdsitseg	= 2,
	cdopeexc	= 1,
	cdageexc	= 1,
	dtinsexc	= trunc(sysdate),
	cdopecnl	= 1
where	cdcooper	= 1
and	nrdconta	= 822841
and	tpseguro	= 4
and	nrctrseg	= 965162;

update	tbseg_prestamista
set	nrproposta	= '770352254134',
	nrctrseg	= 668533
where	cdcooper	= 1
and	nrdconta	= 822841
and	nrproposta	= '770354514443';

commit;

end;