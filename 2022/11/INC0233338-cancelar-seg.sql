begin

update cecred.crapseg
   set dtfimvig	= trunc(sysdate),
	dtcancel	= trunc(sysdate),
	cdsitseg	= 2,
	cdopeexc	= 1,
	cdageexc	= 1,
	dtinsexc	= trunc(sysdate),
	cdopecnl	= 1
where cdcooper	= 6
and	nrdconta	= 104833
and	nrctrseg	= 8989;


update cecred.tbseg_prestamista
   set tpregist = 0
 where cdcooper	= 6
   and nrdconta	= 104833
   and nrctrseg	= 8989
   and nrproposta = '770349555085';

commit;

end;