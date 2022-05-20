begin
  
delete from tbseg_prestamista a
where a.cdcooper = 13
and a.nrdconta = 628700
and a.nrctremp = 196823
and a.nrctrseg = 332459;

delete from crapseg a
where a.cdcooper = 13
and a.nrdconta = 628700
and a.nrctrseg = 332459;

delete from crawseg a
where a.cdcooper = 13
and a.nrdconta = 628700
and a.nrctrato = 196823
and a.nrctrseg = 332459;

update	cecred.crapprm p
set	p.DSVLRPRM	= '0'
where	p.cdacesso	like '%TPCUSTEI_PADRAO%'
and	p.NMSISTEM	= 'CRED'
and	p.CDCOOPER	in (9,13);

commit;

end;