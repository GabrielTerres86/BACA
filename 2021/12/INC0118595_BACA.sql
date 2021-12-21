begin

/* Atualizar situação para 0, para o job conferir as inconsistências e reprocessar */
	update	TBDOMIC_LIQTRANS_LANCTO a
	set	a.insituacao	= 0
	where	a.idarquivo	in
		(499974,
499990,
499962,
499963,
499968,
499972,
499965,
499967,
499983,
499985,
499986,
499989,
499981,
499964,
499973,
499976,
499970,
499979,
499969,
499971,
499977,
499984,
499987,
499975,
499988,
499980,
499966);

/* Limpar erros, para o job reprocessar */
	update	TBDOMIC_LIQTRANS_PDV a
	set	a.dserro		= null,
		a.dsocorrencia_retorno	= null,
		a.cdocorrencia_retorno	= '00',
		a.cdocorrencia		= '00'
	where	(nvl(trim(a.cdocorrencia),'00') in ('00','01'))
	and	a.dserro	like '%ESLC0029%'
	and	a.idcentraliza	in
		(select	z.idcentraliza
		from	TBDOMIC_LIQTRANS_CENTRALIZA z,
			TBDOMIC_LIQTRANS_LANCTO y,
			TBDOMIC_LIQTRANS_ARQUIVO x
		where	y.idlancto	= z.idlancto
		and	x.idarquivo	= y.idarquivo
		and	x.idarquivo	in 
			(499974,
499990,
499962,
499963,
499968,
499972,
499965,
499967,
499983,
499985,
499986,
499989,
499981,
499964,
499973,
499976,
499970,
499979,
499969,
499971,
499977,
499984,
499987,
499975,
499988,
499980,
499966)
		);

update TBDOMIC_LIQTRANS_ARQUIVO set nmarquivo_gerado = 'ASLC025_05463212_20211220_00031' WHERE idarquivo = 499974;
update TBDOMIC_LIQTRANS_ARQUIVO set nmarquivo_gerado = 'ASLC025_05463212_20211220_00032' WHERE idarquivo = 499990;
update TBDOMIC_LIQTRANS_ARQUIVO set nmarquivo_gerado = 'ASLC025_05463212_20211220_00033' WHERE idarquivo = 499962;
update TBDOMIC_LIQTRANS_ARQUIVO set nmarquivo_gerado = 'ASLC025_05463212_20211220_00034' WHERE idarquivo = 499963;
update TBDOMIC_LIQTRANS_ARQUIVO set nmarquivo_gerado = 'ASLC025_05463212_20211220_00035' WHERE idarquivo = 499968;
update TBDOMIC_LIQTRANS_ARQUIVO set nmarquivo_gerado = 'ASLC025_05463212_20211220_00036' WHERE idarquivo = 499972;
update TBDOMIC_LIQTRANS_ARQUIVO set nmarquivo_gerado = 'ASLC025_05463212_20211220_00037' WHERE idarquivo = 499965;
update TBDOMIC_LIQTRANS_ARQUIVO set nmarquivo_gerado = 'ASLC025_05463212_20211220_00038' WHERE idarquivo = 499967;
update TBDOMIC_LIQTRANS_ARQUIVO set nmarquivo_gerado = 'ASLC025_05463212_20211220_00039' WHERE idarquivo = 499983;
update TBDOMIC_LIQTRANS_ARQUIVO set nmarquivo_gerado = 'ASLC025_05463212_20211220_00040' WHERE idarquivo = 499985;
update TBDOMIC_LIQTRANS_ARQUIVO set nmarquivo_gerado = 'ASLC025_05463212_20211220_00041' WHERE idarquivo = 499986;
update TBDOMIC_LIQTRANS_ARQUIVO set nmarquivo_gerado = 'ASLC025_05463212_20211220_00042' WHERE idarquivo = 499989;
update TBDOMIC_LIQTRANS_ARQUIVO set nmarquivo_gerado = 'ASLC025_05463212_20211220_00043' WHERE idarquivo = 499981;
update TBDOMIC_LIQTRANS_ARQUIVO set nmarquivo_gerado = 'ASLC025_05463212_20211220_00044' WHERE idarquivo = 499964;
update TBDOMIC_LIQTRANS_ARQUIVO set nmarquivo_gerado = 'ASLC025_05463212_20211220_00045' WHERE idarquivo = 499973;
update TBDOMIC_LIQTRANS_ARQUIVO set nmarquivo_gerado = 'ASLC025_05463212_20211220_00046' WHERE idarquivo = 499976;
update TBDOMIC_LIQTRANS_ARQUIVO set nmarquivo_gerado = 'ASLC025_05463212_20211220_00047' WHERE idarquivo = 499970;
update TBDOMIC_LIQTRANS_ARQUIVO set nmarquivo_gerado = 'ASLC025_05463212_20211220_00048' WHERE idarquivo = 499979;
update TBDOMIC_LIQTRANS_ARQUIVO set nmarquivo_gerado = 'ASLC025_05463212_20211220_00049' WHERE idarquivo = 499969;
update TBDOMIC_LIQTRANS_ARQUIVO set nmarquivo_gerado = 'ASLC025_05463212_20211220_00050' WHERE idarquivo = 499971;
update TBDOMIC_LIQTRANS_ARQUIVO set nmarquivo_gerado = 'ASLC025_05463212_20211220_00051' WHERE idarquivo = 499977;
update TBDOMIC_LIQTRANS_ARQUIVO set nmarquivo_gerado = 'ASLC025_05463212_20211220_00052' WHERE idarquivo = 499984;
update TBDOMIC_LIQTRANS_ARQUIVO set nmarquivo_gerado = 'ASLC025_05463212_20211220_00053' WHERE idarquivo = 499987;
update TBDOMIC_LIQTRANS_ARQUIVO set nmarquivo_gerado = 'ASLC025_05463212_20211220_00054' WHERE idarquivo = 499975;
update TBDOMIC_LIQTRANS_ARQUIVO set nmarquivo_gerado = 'ASLC025_05463212_20211220_00055' WHERE idarquivo = 499988;
update TBDOMIC_LIQTRANS_ARQUIVO set nmarquivo_gerado = 'ASLC025_05463212_20211220_00056' WHERE idarquivo = 499980;
update TBDOMIC_LIQTRANS_ARQUIVO set nmarquivo_gerado = 'ASLC025_05463212_20211220_00057' WHERE idarquivo = 499966;

/* Atualizar sequencial na tabela de parâmetros */
update	CRAPSQU a
set	a.nrseqatu	= 57
where	a.nmtabela	= 'TBDOMIC_LIQTRANS_ARQUIVO'
and	a.nmdcampo	= 'TPARQUIVO'
and	a.dsdchave	= '2;20/12/2021';

commit;

end;