begin

begin

update	tbseg_prestamista
set	situacao	= 0,
	dtrecusa	= trunc(sysdate),
	tprecusa	= 8,
	cdmotrec	= 193,
	tpregist	= 0
where	cdcooper	= 2
and	nrdconta	= 530867
and	nrproposta	= '770359181582';

update	tbseg_prestamista
set	situacao	= 0,
	dtrecusa	= trunc(sysdate),
	tprecusa	= 8,
	cdmotrec	= 193,
	tpregist	= 0
where	cdcooper	= 2
and	nrdconta	= 560863
and	nrproposta	= '770357483174';

update	tbseg_prestamista
set	situacao	= 0,
	dtrecusa	= trunc(sysdate),
	tprecusa	= 8,
	cdmotrec	= 193,
	tpregist	= 0
where	cdcooper	= 2
and	nrdconta	= 590312
and	nrproposta	= '770359007663';

update	tbseg_prestamista
set	situacao	= 0,
	dtrecusa	= trunc(sysdate),
	tprecusa	= 8,
	cdmotrec	= 193,
	tpregist	= 0
where	cdcooper	= 2
and	nrdconta	= 665096
and	nrproposta	= '770357462096';

update	tbseg_prestamista
set	situacao	= 0,
	dtrecusa	= trunc(sysdate),
	tprecusa	= 8,
	cdmotrec	= 193,
	tpregist	= 0
where	cdcooper	= 2
and	nrdconta	= 751588
and	nrproposta	= '770352840491';

update	tbseg_prestamista
set	situacao	= 0,
	dtrecusa	= trunc(sysdate),
	tprecusa	= 8,
	cdmotrec	= 193,
	tpregist	= 0
where	cdcooper	= 2
and	nrdconta	= 763802
and	nrproposta	= '770358811248';

update	tbseg_prestamista
set	situacao	= 0,
	dtrecusa	= trunc(sysdate),
	tprecusa	= 8,
	cdmotrec	= 193,
	tpregist	= 0
where	cdcooper	= 2
and	nrdconta	= 854069
and	nrproposta	= '770359044852';

update	tbseg_prestamista
set	situacao	= 0,
	dtrecusa	= trunc(sysdate),
	tprecusa	= 8,
	cdmotrec	= 193,
	tpregist	= 0
where	cdcooper	= 2
and	nrdconta	= 872857
and	nrproposta	= '770351344776';

update	tbseg_prestamista
set	situacao	= 0,
	dtrecusa	= trunc(sysdate),
	tprecusa	= 8,
	cdmotrec	= 193,
	tpregist	= 0
where	cdcooper	= 1
and	nrdconta	= 4071417
and	nrproposta	= '770354833476';

update	tbseg_prestamista
set	situacao	= 0,
	dtrecusa	= trunc(sysdate),
	tprecusa	= 8,
	cdmotrec	= 193,
	tpregist	= 0
where	cdcooper	= 1
and	nrdconta	= 6945945
and	nrproposta	= '770357647088';

update	tbseg_prestamista
set	situacao	= 0,
	dtrecusa	= trunc(sysdate),
	tprecusa	= 8,
	cdmotrec	= 193,
	tpregist	= 0
where	cdcooper	= 1
and	nrdconta	= 8195110
and	nrproposta	= '770358617212';

update	tbseg_prestamista
set	situacao	= 0,
	dtrecusa	= trunc(sysdate),
	tprecusa	= 8,
	cdmotrec	= 193,
	tpregist	= 0
where	cdcooper	= 1
and	nrdconta	= 10399682
and	nrproposta	= '770358337392';

update	tbseg_prestamista
set	situacao	= 0,
	dtrecusa	= trunc(sysdate),
	tprecusa	= 8,
	cdmotrec	= 193,
	tpregist	= 0
where	cdcooper	= 1
and	nrdconta	= 10417133
and	nrproposta	= '770352127906';

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
where	cdcooper	= 2
and	nrdconta	= 763802
and	tpseguro	= 4
and	nrctrseg	= 171828;

update	crapseg
set	dtfimvig	= trunc(sysdate),
	dtcancel	= trunc(sysdate),
	cdsitseg	= 5,
	cdopeexc	= 1,
	cdageexc	= 1,
	dtinsexc	= trunc(sysdate),
	cdopecnl	= 1
where	cdcooper	= 2
and	nrdconta	= 665096
and	tpseguro	= 4
and	nrctrseg	= 169207;

update	crapseg
set	dtfimvig	= trunc(sysdate),
	dtcancel	= trunc(sysdate),
	cdsitseg	= 5,
	cdopeexc	= 1,
	cdageexc	= 1,
	dtinsexc	= trunc(sysdate),
	cdopecnl	= 1
where	cdcooper	= 2
and	nrdconta	= 560863
and	tpseguro	= 4
and	nrctrseg	= 181120;

update	crapseg
set	dtfimvig	= trunc(sysdate),
	dtcancel	= trunc(sysdate),
	cdsitseg	= 5,
	cdopeexc	= 1,
	cdageexc	= 1,
	dtinsexc	= trunc(sysdate),
	cdopecnl	= 1
where	cdcooper	= 2
and	nrdconta	= 854069
and	tpseguro	= 4
and	nrctrseg	= 156658;

update	crapseg
set	dtfimvig	= trunc(sysdate),
	dtcancel	= trunc(sysdate),
	cdsitseg	= 5,
	cdopeexc	= 1,
	cdageexc	= 1,
	dtinsexc	= trunc(sysdate),
	cdopecnl	= 1
where	cdcooper	= 2
and	nrdconta	= 590312
and	tpseguro	= 4
and	nrctrseg	= 164977;

update	crapseg
set	dtfimvig	= trunc(sysdate),
	dtcancel	= trunc(sysdate),
	cdsitseg	= 5,
	cdopeexc	= 1,
	cdageexc	= 1,
	dtinsexc	= trunc(sysdate),
	cdopecnl	= 1
where	cdcooper	= 2
and	nrdconta	= 530867
and	tpseguro	= 4
and	nrctrseg	= 158551;

update	crapseg
set	dtfimvig	= trunc(sysdate),
	dtcancel	= trunc(sysdate),
	cdsitseg	= 5,
	cdopeexc	= 1,
	cdageexc	= 1,
	dtinsexc	= trunc(sysdate),
	cdopecnl	= 1
where	cdcooper	= 2
and	nrdconta	= 751588
and	tpseguro	= 4
and	nrctrseg	= 138091;

update	crapseg
set	dtfimvig	= trunc(sysdate),
	dtcancel	= trunc(sysdate),
	cdsitseg	= 5,
	cdopeexc	= 1,
	cdageexc	= 1,
	dtinsexc	= trunc(sysdate),
	cdopecnl	= 1
where	cdcooper	= 2
and	nrdconta	= 872857
and	tpseguro	= 4
and	nrctrseg	= 115367;

update	crapseg
set	dtfimvig	= trunc(sysdate),
	dtcancel	= trunc(sysdate),
	cdsitseg	= 5,
	cdopeexc	= 1,
	cdageexc	= 1,
	dtinsexc	= trunc(sysdate),
	cdopecnl	= 1
where	cdcooper	= 1
and	nrdconta	= 6945945
and	tpseguro	= 4
and	nrctrseg	= 834544;

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

update	crapseg
set	dtfimvig	= trunc(sysdate),
	dtcancel	= trunc(sysdate),
	cdsitseg	= 5,
	cdopeexc	= 1,
	cdageexc	= 1,
	dtinsexc	= trunc(sysdate),
	cdopecnl	= 1
where	cdcooper	= 1
and	nrdconta	= 8195110
and	tpseguro	= 4
and	nrctrseg	= 824150;

update	crapseg
set	dtfimvig	= trunc(sysdate),
	dtcancel	= trunc(sysdate),
	cdsitseg	= 5,
	cdopeexc	= 1,
	cdageexc	= 1,
	dtinsexc	= trunc(sysdate),
	cdopecnl	= 1
where	cdcooper	= 1
and	nrdconta	= 10399682
and	tpseguro	= 4
and	nrctrseg	= 817463;

update	crapseg
set	dtfimvig	= trunc(sysdate),
	dtcancel	= trunc(sysdate),
	cdsitseg	= 5,
	cdopeexc	= 1,
	cdageexc	= 1,
	dtinsexc	= trunc(sysdate),
	cdopecnl	= 1
where	cdcooper	= 1
and	nrdconta	= 4071417
and	tpseguro	= 4
and	nrctrseg	= 652066;

update	crapseg
set	dtfimvig	= trunc(sysdate),
	dtcancel	= trunc(sysdate),
	cdsitseg	= 5,
	cdopeexc	= 1,
	cdageexc	= 1,
	dtinsexc	= trunc(sysdate),
	cdopecnl	= 1
where	cdcooper	= 1
and	nrdconta	= 10417133
and	tpseguro	= 4
and	nrctrseg	= 664936;

end;

commit;

end;