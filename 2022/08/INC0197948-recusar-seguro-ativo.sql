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
and	nrdconta	= 12621749
and	tpseguro	= 4
and	nrctrseg	= 1017467;

end;

commit;

end;