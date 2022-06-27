begin

update	cecred.crapseg a
set	a.cdsitseg	= 1,
	a.dtcancel	= null,
	a.cdopecnl	= null,
	a.cdopeexc	= null,
	a.cdageexc	= 0,
	a.dtinsexc	= null
where	a.nrctrseg	= 1009879
and	a.nrdconta	= 8345007
and	a.cdcooper	= 1;

update	cecred.crapseg a
set	a.cdsitseg	= 2,
	a.dtcancel	= trunc(sysdate),
	a.cdopecnl	= 1,
	a.cdopeexc	= 1,
	a.cdageexc	= 1,
	a.dtinsexc	= trunc(sysdate)
where	a.nrctrseg	= 1046961
and	a.nrdconta	= 8345007
and	a.cdcooper	= 1;

update	cecred.tbseg_prestamista a
set	a.tpregist	= 1
where	a.nrctremp	= 5123386
and	a.nrctrseg	= 1009879
and	a.nrdconta	= 8345007
and	a.cdcooper	= 1;



update	cecred.crapseg a
set	a.cdsitseg	= 1,
	a.dtcancel	= null,
	a.cdopecnl	= null,
	a.cdopeexc	= null,
	a.cdageexc	= 0,
	a.dtinsexc	= null
where	a.nrctrseg	= 1011907
and	a.nrdconta	= 12165662
and	a.cdcooper	= 1;

update	cecred.crapseg a
set	a.cdsitseg	= 2,
	a.dtcancel	= trunc(sysdate),
	a.cdopecnl	= 1,
	a.cdopeexc	= 1,
	a.cdageexc	= 1,
	a.dtinsexc	= trunc(sysdate)
where	a.nrctrseg	= 1057285
and	a.nrdconta	= 12165662
and	a.cdcooper	= 1;

update	cecred.tbseg_prestamista a
set	a.tpregist	= 1
where	a.nrctremp	= 5030332
and	a.nrctrseg	= 1011907
and	a.nrdconta	= 12165662
and	a.cdcooper	= 1;



update	cecred.crapseg a
set	a.cdsitseg	= 1,
	a.dtcancel	= null,
	a.cdopecnl	= null,
	a.cdopeexc	= null,
	a.cdageexc	= 0,
	a.dtinsexc	= null
where	a.nrctrseg	= 1008395
and	a.nrdconta	= 12257800
and	a.cdcooper	= 1;

update	cecred.crapseg a
set	a.cdsitseg	= 2,
	a.dtcancel	= trunc(sysdate),
	a.cdopecnl	= 1,
	a.cdopeexc	= 1,
	a.cdageexc	= 1,
	a.dtinsexc	= trunc(sysdate)
where	a.nrctrseg	= 1063796
and	a.nrdconta	= 12257800
and	a.cdcooper	= 1;

update	cecred.tbseg_prestamista a
set	a.tpregist	= 1
where	a.nrctremp	= 4496001
and	a.nrctrseg	= 1008395
and	a.nrdconta	= 12257800
and	a.cdcooper	= 1;



update	cecred.crapseg a
set	a.cdsitseg	= 1,
	a.dtcancel	= null,
	a.cdopecnl	= null,
	a.cdopeexc	= null,
	a.cdageexc	= 0,
	a.dtinsexc	= null
where	a.nrctrseg	= 1008733
and	a.nrdconta	= 10851135
and	a.cdcooper	= 1;

update	cecred.tbseg_prestamista a
set	a.tpregist	= 1
where	a.nrctremp	= 5041723
and	a.nrctrseg	= 1008733
and	a.nrdconta	= 10851135
and	a.cdcooper	= 1;

commit;

end;