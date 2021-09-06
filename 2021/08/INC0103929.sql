declare

cursor	c01 is
SELECT	distinct
	a.idarquivo
FROM	tbdomic_liqtrans_arquivo a,
	tbdomic_liqtrans_lancto l,
	tbdomic_liqtrans_centraliza c,
	tbdomic_liqtrans_pdv p
WHERE	a.dhrecebimento		>= to_date('25/08/2021','dd/mm/yyyy')
AND	a.idarquivo		= l.idarquivo
AND	l.idlancto		= c.idlancto
AND	c.idcentraliza		= p.idcentraliza
and	a.nmarquivo_retorno	is not null
and	p.dsocorrencia_retorno	= 'ESLC0129'
and	p.dtpagamento		= '2021-08-30'
and	l.insituacao		= 1;

cursor	c02 is
SELECT	p.idpdv
FROM	tbdomic_liqtrans_arquivo a,
	tbdomic_liqtrans_lancto l,
	tbdomic_liqtrans_centraliza c,
	tbdomic_liqtrans_pdv p
WHERE	a.dhrecebimento		>= to_date('25/08/2021','dd/mm/yyyy')
AND	a.idarquivo		= l.idarquivo
AND	l.idlancto		= c.idlancto
AND	c.idcentraliza		= p.idcentraliza
and	a.nmarquivo_retorno	is not null
and	p.dsocorrencia_retorno	= 'ESLC0129'
and	p.dtpagamento		= '2021-08-30'
and	l.insituacao		= 1;

begin

for r01 in c01 loop

	update	tbdomic_liqtrans_arquivo a
	set	a.nmarquivo_gerado	= null,
		a.dharquivo_gerado	= null,
		a.nmarquivo_retorno	= null,
		a.dharquivo_retorno	= null
	where	a.idarquivo		= r01.idarquivo;

end loop;

for r02 in c02 loop

	update	tbdomic_liqtrans_pdv a
	set	a.dhretorno		= null,
		a.cdocorrencia_retorno	= null,
		a.dserro		= null,
		a.dsocorrencia_retorno	= null
	where	a.idpdv			= r02.idpdv;

end loop;

commit;

end;