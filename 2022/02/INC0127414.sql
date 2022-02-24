begin

begin

update	tbseg_prestamista
set	situacao	= 0,
	dtrecusa	= trunc(sysdate),
	tprecusa	= 8,
	cdmotrec	= 193,
	tpregist	= 0
where	cdcooper	= 1
and	nrdconta	= 1907875
and	nrproposta	= '770358472842';

update	tbseg_prestamista
set	situacao	= 0,
	dtrecusa	= trunc(sysdate),
	tprecusa	= 8,
	cdmotrec	= 193,
	tpregist	= 0
where	cdcooper	= 1
and	nrdconta	= 12213497
and	nrproposta	= '770354413337';

update	tbseg_prestamista
set	situacao	= 0,
	dtrecusa	= trunc(sysdate),
	tprecusa	= 8,
	cdmotrec	= 193,
	tpregist	= 0
where	cdcooper	= 1
and	nrdconta	= 1876260
and	nrproposta	= '770358765220';

update	tbseg_prestamista
set	situacao	= 0,
	dtrecusa	= trunc(sysdate),
	tprecusa	= 8,
	cdmotrec	= 193,
	tpregist	= 0
where	cdcooper	= 1
and	nrdconta	= 2205351
and	nrproposta	= '770354833468';

update	tbseg_prestamista
set	situacao	= 0,
	dtrecusa	= trunc(sysdate),
	tprecusa	= 8,
	cdmotrec	= 193,
	tpregist	= 0
where	cdcooper	= 1
and	nrdconta	= 2205459
and	nrproposta	= '770359771746';

update	tbseg_prestamista
set	situacao	= 0,
	dtrecusa	= trunc(sysdate),
	tprecusa	= 8,
	cdmotrec	= 193,
	tpregist	= 0
where	cdcooper	= 1
and	nrdconta	= 2423871
and	nrproposta	= '770354534371';

update	tbseg_prestamista
set	situacao	= 0,
	dtrecusa	= trunc(sysdate),
	tprecusa	= 8,
	cdmotrec	= 193,
	tpregist	= 0
where	cdcooper	= 1
and	nrdconta	= 3953750
and	nrproposta	= '770357628288';

update	tbseg_prestamista
set	situacao	= 0,
	dtrecusa	= trunc(sysdate),
	tprecusa	= 8,
	cdmotrec	= 193,
	tpregist	= 0
where	cdcooper	= 1
and	nrdconta	= 7789130
and	nrproposta	= '770358129501';

update	tbseg_prestamista
set	situacao	= 0,
	dtrecusa	= trunc(sysdate),
	tprecusa	= 8,
	cdmotrec	= 193,
	tpregist	= 0
where	cdcooper	= 1
and	nrdconta	= 7846312
and	nrproposta	= '770358189202';

update	tbseg_prestamista
set	situacao	= 0,
	dtrecusa	= trunc(sysdate),
	tprecusa	= 8,
	cdmotrec	= 193,
	tpregist	= 0
where	cdcooper	= 1
and	nrdconta	= 9759530
and	nrproposta	= '770358547940';

update	tbseg_prestamista
set	situacao	= 0,
	dtrecusa	= trunc(sysdate),
	tprecusa	= 8,
	cdmotrec	= 193,
	tpregist	= 0
where	cdcooper	= 1
and	nrdconta	= 11283009
and	nrproposta	= '770358173489';

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
and	nrdconta	= 1907875
and	tpseguro	= 4
and	nrctrseg	= 802197;

update	crapseg
set	dtfimvig	= trunc(sysdate),
	dtcancel	= trunc(sysdate),
	cdsitseg	= 5,
	cdopeexc	= 1,
	cdageexc	= 1,
	dtinsexc	= trunc(sysdate),
	cdopecnl	= 1
where	cdcooper	= 1
and	nrdconta	= 12213497
and	tpseguro	= 4
and	nrctrseg	= 758530;

update	crapseg
set	dtfimvig	= trunc(sysdate),
	dtcancel	= trunc(sysdate),
	cdsitseg	= 5,
	cdopeexc	= 1,
	cdageexc	= 1,
	dtinsexc	= trunc(sysdate),
	cdopecnl	= 1
where	cdcooper	= 1
and	nrdconta	= 9759530
and	tpseguro	= 4
and	nrctrseg	= 804462;

update	crapseg
set	dtfimvig	= trunc(sysdate),
	dtcancel	= trunc(sysdate),
	cdsitseg	= 5,
	cdopeexc	= 1,
	cdageexc	= 1,
	dtinsexc	= trunc(sysdate),
	cdopecnl	= 1
where	cdcooper	= 1
and	nrdconta	= 11283009
and	tpseguro	= 4
and	nrctrseg	= 837100;

update	crapseg
set	dtfimvig	= trunc(sysdate),
	dtcancel	= trunc(sysdate),
	cdsitseg	= 5,
	cdopeexc	= 1,
	cdageexc	= 1,
	dtinsexc	= trunc(sysdate),
	cdopecnl	= 1
where	cdcooper	= 1
and	nrdconta	= 7846312
and	tpseguro	= 4
and	nrctrseg	= 815212;

update	crapseg
set	dtfimvig	= trunc(sysdate),
	dtcancel	= trunc(sysdate),
	cdsitseg	= 5,
	cdopeexc	= 1,
	cdageexc	= 1,
	dtinsexc	= trunc(sysdate),
	cdopecnl	= 1
where	cdcooper	= 1
and	nrdconta	= 3953750
and	tpseguro	= 4
and	nrctrseg	= 843382;

update	crapseg
set	dtfimvig	= trunc(sysdate),
	dtcancel	= trunc(sysdate),
	cdsitseg	= 5,
	cdopeexc	= 1,
	cdageexc	= 1,
	dtinsexc	= trunc(sysdate),
	cdopecnl	= 1
where	cdcooper	= 1
and	nrdconta	= 7789130
and	tpseguro	= 4
and	nrctrseg	= 823271;

update	crapseg
set	dtfimvig	= trunc(sysdate),
	dtcancel	= trunc(sysdate),
	cdsitseg	= 5,
	cdopeexc	= 1,
	cdageexc	= 1,
	dtinsexc	= trunc(sysdate),
	cdopecnl	= 1
where	cdcooper	= 1
and	nrdconta	= 1876260
and	tpseguro	= 4
and	nrctrseg	= 813116;

update	crapseg
set	dtfimvig	= trunc(sysdate),
	dtcancel	= trunc(sysdate),
	cdsitseg	= 5,
	cdopeexc	= 1,
	cdageexc	= 1,
	dtinsexc	= trunc(sysdate),
	cdopecnl	= 1
where	cdcooper	= 1
and	nrdconta	= 2205351
and	tpseguro	= 4
and	nrctrseg	= 739281;

update	crapseg
set	dtfimvig	= trunc(sysdate),
	dtcancel	= trunc(sysdate),
	cdsitseg	= 5,
	cdopeexc	= 1,
	cdageexc	= 1,
	dtinsexc	= trunc(sysdate),
	cdopecnl	= 1
where	cdcooper	= 1
and	nrdconta	= 2205459
and	tpseguro	= 4
and	nrctrseg	= 793784;

update	crapseg
set	dtfimvig	= trunc(sysdate),
	dtcancel	= trunc(sysdate),
	cdsitseg	= 5,
	cdopeexc	= 1,
	cdageexc	= 1,
	dtinsexc	= trunc(sysdate),
	cdopecnl	= 1
where	cdcooper	= 1
and	nrdconta	= 2423871
and	tpseguro	= 4
and	nrctrseg	= 780243;

end;

commit;

end;