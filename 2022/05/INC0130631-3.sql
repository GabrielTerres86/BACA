begin

declare

ds_exc_erro_v		exception;
ds_dados_rollback_v	clob			:= null;
ds_texto_rollback_v	varchar2(32600);

cd_cooperativa_v	cecred.crapcop.cdcooper%type	:= 3;
ds_nome_arquivo_bkp_v	varchar2(100);
ds_nome_diretorio_v	cecred.crapprm.dsvlrprm%type;
ds_critica_v		cecred.crapcri.dscritic%type;

qt_registro	number(10)	:= 0;
nr_arquivo	number(10)	:= 1;
qt_reg_arquivo	number(10)	:= 50000;

vr_dscritic	VARCHAR2(1000);

cursor	c01 is
select	d.rowid as nr_linha_crap,
	d.cdsitseg,
	d.dtcancel,
	d.dtfimvig,
	a.nrctrato,
	a.cdcooper,
	a.nrdconta,
	a.nrctrseg,
	a.rowid as nr_linha_craw,
	a.tpcustei
from	cecred.crapseg h,
	cecred.crawseg g,
	cecred.crawepr f,
	cecred.crapseg d,
	cecred.craplcr c,
	cecred.crapepr b,
	cecred.crawseg a
where	h.rowid		in
	('AAAS9lADSAAL7nDAAF',
'AAAS9lADSAAL7YQAAA',
'AAAS9lADSAAL7mPAAG',
'AAAS9lADSAAL7a2AAB',
'AAAS9lADSAAL7n5AAO',
'AAAS9lADSAAL7lxAAI',
'AAAS9lADSAAL7ivAAg',
'AAAS9lADSAAL7Y8AAA',
'AAAS9lADSAAL7ldAAI',
'AAAS9lADSAAL7a9AAB',
'AAAS9lADSAAL7nNAAW',
'AAAS9lADSAAL7aiAAG',
'AAAS9lADSAAL7ivAAl',
'AAAS9lADSAAL7mIAAD',
'AAAS9lADSAAL7lZAAA',
'AAAS9lADSAAL7nxAAB',
'AAAS9lADSAAL7mQAAD',
'AAAS9lADSAAL7bMAAF',
'AAAS9lADSAAL7dPAAW',
'AAAS9lADSAAL7ldAAG',
'AAAS9lADSAAL7kbAAB',
'AAAS9lADSAAL7epAAQ',
'AAAS9lADSAAL7nNAAS',
'AAAS9lADSAAL7kNAAH',
'AAAS9lADSAAL7ldAAJ',
'AAAS9lADSAAL7bYAAB',
'AAAS9lADSAAL7bWAAA',
'AAAS9lADSAAL7hBAAI',
'AAAS9lADSAAL7ivAAi',
'AAAS9lADSAAL7jXAAV',
'AAAS9lADSAAL7mhAAO',
'AAAS9lADSAAL7ivABE',
'AAAS9lADSAAL7ivAA8',
'AAAS9lADSAAL7b8AAH',
'AAAS9lADSAAL7dDAAA',
'AAAS9lADSAAL7ivABF',
'AAAS9lADSAAL7aiAAB',
'AAAS9lADSAAL7mxAAA',
'AAAS9lADSAAL7d3AAU',
'AAAS9lADSAAL7lMAAA',
'AAAS9lADSAAL7mBAAF',
'AAAS9lADSAAL7jIAAV',
'AAAS9lADSAAL7aKAAJ',
'AAAS9lADSAAL7YQAAC',
'AAAS9lADSAAL7ivABD',
'AAAS9lADSAAL7baAAD',
'AAAS9lADSAAL7lBAAM',
'AAAS9lADSAAL7bsAAH',
'AAAS9lADSAAL7mfAAD',
'AAAS9lADSAAL7YSAAH',
'AAAS9lADSAAL7bwAAN')
and	g.tpseguro	= h.tpseguro
and	g.nrctrseg	= h.nrctrseg
and	g.nrdconta	= h.nrdconta
and	g.cdcooper	= h.cdcooper
and	g.tpseguro	= a.tpseguro
and	g.cdcooper	= a.cdcooper
and	g.nrdconta	= a.nrdconta
and	g.nrctrato	= a.nrctrato
and	f.CDORIGEM	in (1,5)
and	a.CDCOOPER	= f.CDCOOPER
and	a.NRDCONTA	= f.NRDCONTA
and	a.NRCTRATO	= f.NRCTREMP
and	d.CDSITSEG	in (1,2)
and	d.tpseguro	= 4
and	a.CDCOOPER	= d.CDCOOPER
and	a.NRDCONTA	= d.NRDCONTA
and	a.NRCTRSEG	= d.NRCTRSEG
and	c.TPCUSPR	= 0
and	b.CDCOOPER	= c.CDCOOPER
and	b.CDLCREMP	= c.CDLCREMP
and	b.INLIQUID	<> 1
and	a.NRCTRATO	= b.NRCTREMP
and	a.CDCOOPER	= b.CDCOOPER
and	a.NRDCONTA	= b.NRDCONTA
and	a.tpcustei	= 1
and	a.DTMVTOLT	between to_date('10/05/2022','dd/mm/yyyy') and to_date('17/05/2022 23:59:59','dd/mm/yyyy hh24:mi:ss')
and	a.cdcooper	in (9,13);

cursor	c02(	cdcooper_p	cecred.tbseg_prestamista.cdcooper%type,
		nrdconta_p	cecred.tbseg_prestamista.nrdconta%type,
		nrctremp_p	cecred.tbseg_prestamista.nrctremp%type,
		nrctrseg_p	cecred.tbseg_prestamista.nrctrseg%type) is
select	a.rowid as nr_linha_tbseg,
	a.tpregist
from	cecred.tbseg_prestamista a
where	a.tpregist	<> 0
and	a.nrctrseg	= nrctrseg_p
and	a.nrctremp	= nrctremp_p
and	a.nrdconta	= nrdconta_p
and	a.cdcooper	= cdcooper_p;

cursor	c03 is
select	b.dtfimvig,
	a.dtfimvig as dtfim_prestamista,
	b.rowid as nr_linha_craw,
	a.nrdconta
from	cecred.crapseg c,
	cecred.crawseg b,
	cecred.tbseg_prestamista a
where	c.cdsitseg	not in (2,5)
and	b.tpseguro	= c.tpseguro
and	b.nrctrseg	= c.nrctrseg
and	b.nrdconta	= c.nrdconta
and	b.cdcooper	= c.cdcooper
and	b.tpseguro	= 4
and	b.dtfimvig	is null
and	a.cdcooper	= b.cdcooper
and	a.nrdconta	= b.nrdconta
and	a.nrctrseg	= b.nrctrseg
and	a.nrctremp	= b.nrctrato
and	a.dtfimvig	is not null
and	a.tpregist	in (1,3);

cursor	c04 is
select	c.dtfimvig,
	a.dtfimvig as dtfim_prestamista,
	c.rowid as nr_linha_crap,
	a.nrdconta
from	cecred.crapseg c,
	cecred.crawseg b,
	cecred.tbseg_prestamista a
where	b.tpseguro	= 4
and	a.nrctrseg	= b.nrctrseg
and	a.nrctremp	= b.nrctrato
and	a.nrdconta	= b.nrdconta
and	a.cdcooper	= b.cdcooper
and	c.cdsitseg	not in (2,5)
and	c.tpseguro	= b.tpseguro
and	c.dtfimvig	is null
and	a.cdcooper	= c.cdcooper
and	a.nrdconta	= c.nrdconta
and	a.nrctrseg	= c.nrctrseg
and	a.dtfimvig	is not null
and	a.tpregist	in (1,3);

cursor	c05 is
select	a.rowid as nr_linha_craw,
	a.dtmvtolt as dtmvtolt_craw,
	a.dtinivig as dtinivig_craw,
	a.dtdebito as dtdebito_craw,
	a.dtiniseg as dtiniseg_craw,
	a.dtprideb as dtprideb_craw,
	b.rowid nr_linha_crap,
	b.dtmvtolt as dtmvtolt_crap,
	b.dtinivig as dtinivig_crap,
	b.dtdebito as dtdebito_crap,
	b.dtiniseg as dtiniseg_crap,
	b.dtprideb as dtprideb_crap,
	b.dtultpag as dtultpag_crap,
	b.dtinsori as dtinsori_crap,
	to_date('17/05/2022','dd/mm/yyyy') as dt_atualizada,
	a.cdcooper,
	a.nrdconta,
	a.nrctrato,
	a.nrctrseg
from	cecred.crapseg b,
	cecred.crawseg a
where	a.TPSEGURO	= b.TPSEGURO
and	a.NRDCONTA	= b.NRDCONTA
and	a.NRCTRSEG	= b.NRCTRSEG
and	a.CDCOOPER	= b.CDCOOPER
and	a.tpseguro	= 4
and	a.rowid	in
	('AAATCKADSAAKco3AAU',
'AAATCKADSAAKco3AAh',
'AAATCKADSAAKco3AAk',
'AAATCKADSAAKcpHAAF',
'AAATCKADSAAKcpXAAS',
'AAATCKADSAAKcpnAAG',
'AAATCKADSAAKcpnAAI',
'AAATCKADSAAKcpnAAK',
'AAATCKADSAAKcpnAAM',
'AAATCKADSAAKcpnAAN',
'AAATCKADSAAKcpnAAO',
'AAATCKADSAAKcpnAAQ',
'AAATCKADSAAKcp3AAC',
'AAATCKADSAAKcp3AAP',
'AAATCKADSAAKcp3AAV',
'AAATCKADSAAKcp3AAW',
'AAATCKADSAAKcp3AAX',
'AAATCKADSAAKcqXAAa',
'AAATCKADSAAKcq3AAV',
'AAATCKADSAAKcq3AAX',
'AAATCKADSAAKcq3AAZ',
'AAATCKADSAAKcq3AAb',
'AAATCKADSAAKcrHAAK',
'AAATCKADSAAKcrHAAd',
'AAATCKADSAAKcrXAAH',
'AAATCKADSAAKcrXAAK',
'AAATCKADSAAKcrXAAL',
'AAATCKADSAAKcrXAAM',
'AAATCKADSAAKcrXAAN',
'AAATCKADSAAKcrXAAO',
'AAATCKADSAAKcrXAAP',
'AAATCKADSAAKcrXAAQ',
'AAATCKADSAAKcrXAAR',
'AAATCKADSAAKcrXAAS',
'AAATCKADSAAKcrnAAM',
'AAATCKADSAAKcrnAAT',
'AAATCKADSAAKcrnAAU',
'AAATCKADSAAKcrnAAV',
'AAATCKADSAAKcrnAAW',
'AAATCKADSAAKcrnAAX',
'AAATCKADSAAKcrnAAb',
'AAATCKADSAAKcr3AAX',
'AAATCKADSAAKcr3AAZ',
'AAATCKADSAAKcr3AAb',
'AAATCKADSAAKcoIAAb',
'AAATCKADSAAKcoIAAf',
'AAATCKADSAAKcoIAAh',
'AAATCKADSAAKcoIAAi',
'AAATCKADSAAKcoYAAK',
'AAATCKADSAAKcoYAAN',
'AAATCKADSAAKcoYAAX',
'AAATCKADSAAKcoYAAZ',
'AAATCKADSAAKcooAAD',
'AAATCKADSAAKcooAAE',
'AAATCKADSAAKcooAAL',
'AAATCKADSAAKcooAAN',
'AAATCKADSAAKcooAAO',
'AAATCKADSAAKcooAAR',
'AAATCKADSAAKcooAAS',
'AAATCKADSAAKco4AAH',
'AAATCKADSAAKco4AAM',
'AAATCKADSAAKco4AAT',
'AAATCKADSAAKcpIAAS',
'AAATCKADSAAKcpIAAT',
'AAATCKADSAAKcpIAAX',
'AAATCKADSAAKcpIAAb',
'AAATCKADSAAKcpIAAd',
'AAATCKADSAAKcpYAAR',
'AAATCKADSAAKcpYAAV',
'AAATCKADSAAKcpYAAW',
'AAATCKADSAAKcpYAAX',
'AAATCKADSAAKcpYAAa',
'AAATCKADSAAKcpoAAO',
'AAATCKADSAAKcpoAAZ',
'AAATCKADSAAKcp4AAO',
'AAATCKADSAAKcp4AAQ',
'AAATCKADSAAKcp4AAR',
'AAATCKADSAAKcqIAAd',
'AAATCKADSAAKcq4AAP',
'AAATCKADSAAKcq4AAA',
'AAATCKADSAAKcq4AAQ',
'AAATCKADSAAKcq4AAS',
'AAATCKADSAAKcq4AAT',
'AAATCKADSAAKcrIAAM',
'AAATCKADSAAKcrIAAI',
'AAATCKADSAAKcrIAAK',
'AAATCKADSAAKcrIAAN',
'AAATCKADSAAKcrIAAO',
'AAATCKADSAAKcrIAAP',
'AAATCKADSAAKcrIAAQ',
'AAATCKADSAAKcrIAAR',
'AAATCKADSAAKcrIAAS',
'AAATCKADSAAKcrIAAT',
'AAATCKADSAAKcrYAAd',
'AAATCKADSAAKcrYAAe',
'AAATCKADSAAKcrYAAf',
'AAATCKADSAAKcrYAAg',
'AAATCKADSAAKcroAAa',
'AAATCKADSAAKcroAAV',
'AAATCKADSAAKcroAAb',
'AAATCKADSAAKcroAAc',
'AAATCKADSAAKcroAAd',
'AAATCKADSAAKcr4AAN',
'AAATCKADSAAKcr4AAM',
'AAATCKADSAAKcr4AAO',
'AAATCKADSAAKcr4AAQ',
'AAATCKADSAAKcr4AAR',
'AAATCKADSAAKcr4AAS',
'AAATCKADSAAKcr4AAT',
'AAATCKADSAAKcoJAAQ',
'AAATCKADSAAKcoJAAS',
'AAATCKADSAAKcoJAAT',
'AAATCKADSAAKcoZAAE',
'AAATCKADSAAKcoZAAB',
'AAATCKADSAAKcoZAAF',
'AAATCKADSAAKcoZAAG',
'AAATCKADSAAKcoZAAH',
'AAATCKADSAAKcoZAAI',
'AAATCKADSAAKcoZAAJ',
'AAATCKADSAAKcoZAAK',
'AAATCKADSAAKcoZAAL',
'AAATCKADSAAKcoZAAM',
'AAATCKADSAAKcoZAAN',
'AAATCKADSAAKcoZAAO',
'AAATCKADSAAKcoZAAP',
'AAATCKADSAAKcoZAAQ',
'AAATCKADSAAKcoZAAR',
'AAATCKADSAAKcoZAAS',
'AAATCKADSAAKcopAAS',
'AAATCKADSAAKcopAAC',
'AAATCKADSAAKcopAAY',
'AAATCKADSAAKcopAAZ',
'AAATCKADSAAKcopAAa',
'AAATCKADSAAKcopAAb',
'AAATCKADSAAKco5AAF',
'AAATCKADSAAKco5AAG',
'AAATCKADSAAKco5AAH',
'AAATCKADSAAKco5AAI',
'AAATCKADSAAKco5AAJ',
'AAATCKADSAAKco5AAK',
'AAATCKADSAAKco5AAL',
'AAATCKADSAAKco5AAM',
'AAATCKADSAAKco5AAN',
'AAATCKADSAAKco5AAO',
'AAATCKADSAAKco5AAP',
'AAATCKADSAAKco5AAQ',
'AAATCKADSAAKco5AAR',
'AAATCKADSAAKco5AAS',
'AAATCKADSAAKco5AAT',
'AAATCKADSAAKcpJAAP',
'AAATCKADSAAKcpJAAD',
'AAATCKADSAAKcpJAAQ',
'AAATCKADSAAKcpJAAR',
'AAATCKADSAAKcpJAAS',
'AAATCKADSAAKcpJAAT',
'AAATCKADSAAKcppAAi',
'AAATCKADSAAKcppAAj',
'AAATCKADSAAKcppAAk',
'AAATCKADSAAKcppAAl',
'AAATCKADSAAKcppAAm',
'AAATCKADSAAKcppAAn',
'AAATCKADSAAKcp5AAK',
'AAATCKADSAAKcp5AAO',
'AAATCKADSAAKcp5AAP',
'AAATCKADSAAKcp5AAQ',
'AAATCKADSAAKcp5AAR',
'AAATCKADSAAKcp5AAS',
'AAATCKADSAAKcp5AAT',
'AAATCKADSAAKcqJAAh',
'AAATCKADSAAKcqJAAa',
'AAATCKADSAAKcqJAAi',
'AAATCKADSAAKcqZAAA',
'AAATCKADSAAKcqZAAI',
'AAATCKADSAAKcqZAAK',
'AAATCKADSAAKcqpAAf',
'AAATCKADSAAKcqpAAa',
'AAATCKADSAAKcq5AAO',
'AAATCKADSAAKcq5AAP',
'AAATCKADSAAKcq5AAQ',
'AAATCKADSAAKcrZAAa',
'AAATCKADSAAKcrpAAJ',
'AAATCKADSAAKcrpAAB',
'AAATCKADSAAKcrpAAK',
'AAATCKADSAAKcrpAAQ',
'AAATCKADSAAKcr5AAS',
'AAATCKADSAAKcr5AAT',
'AAATCKADSAAKcoKAAP');

cursor	c06(	cdcooper_p	cecred.tbseg_prestamista.cdcooper%type,
		nrdconta_p	cecred.tbseg_prestamista.nrdconta%type,
		nrctremp_p	cecred.tbseg_prestamista.nrctremp%type,
		nrctrseg_p	cecred.tbseg_prestamista.nrctrseg%type) is
select	a.rowid as nr_linha_tbseg,
	a.dtdevend,
	a.dtinivig,
	a.dtrefcob,
	a.dtdenvio
from	cecred.tbseg_prestamista a
where	a.nrctrseg	= nrctrseg_p
and	a.nrctremp	= nrctremp_p
and	a.nrdconta	= nrdconta_p
and	a.cdcooper	= cdcooper_p;

procedure valida_diretorio_p(	ds_nome_diretorio_p	in	varchar2,
				ds_critica_p		out	crapcri.dscritic%TYPE) is

ds_critica_v	cecred.crapcri.dscritic%type;
ie_tipo_saida_v	varchar2(3);
ds_saida_v	varchar2(1000);
   
begin

	if	(gene0001.fn_exis_diretorio(ds_nome_diretorio_p)) then

		ds_critica_p	:= null;

	else

		cecred.gene0001.pc_OSCommand_Shell(	pr_des_comando	=> 'mkdir ' || ds_nome_diretorio_p || ' 1> /dev/null',
						pr_typ_saida	=> ie_tipo_saida_v,
						pr_des_saida	=> ds_saida_v);

		if	(ie_tipo_saida_v	= 'ERR') then

			ds_critica_v	:= 'CRIAR DIRETORIO ARQUIVO -> Nao foi possivel criar o diretorio para gerar os arquivos. ' || ds_saida_v;
			raise		ds_exc_erro_v;

		end if;

		cecred.gene0001.pc_OSCommand_Shell(	pr_des_comando	=> 'chmod 777 ' || ds_nome_diretorio_p || ' 1> /dev/null',
						pr_typ_saida	=> ie_tipo_saida_v,
						pr_des_saida	=> ds_saida_v);

		if	(ie_tipo_saida_v	= 'ERR') then

			ds_critica_v	:= 'PERMISSAO NO DIRETORIO -> Nao foi possivel adicionar permissao no diretorio dos arquivos. ' || ds_saida_v;
			raise		ds_exc_erro_v;

		end if;

	end if;

exception
when	ds_exc_erro_v then

        ds_critica_p	:= ds_critica_v;

end valida_diretorio_p;

begin

if	(upper(cecred.gene0001.fn_database_name) like '%AYLLOSP%') then

	select	max(a.dsvlrprm)
	into	ds_nome_diretorio_v
	from	cecred.crapprm a
	where	a.nmsistem	= 'CRED'
	and	a.cdcooper	= cd_cooperativa_v
	and	a.cdacesso	= 'ROOT_MICROS';

	if	(ds_nome_diretorio_v	is null) then

		select	max(a.dsvlrprm)
		into	ds_nome_diretorio_v
		from	cecred.crapprm a
		where	a.nmsistem	= 'CRED'
		and	a.cdcooper	= 0
		and	a.cdacesso	= 'ROOT_MICROS';

	end if;

	ds_nome_diretorio_v	:= ds_nome_diretorio_v || 'cpd/bacas/INC0130631';

else

	ds_nome_diretorio_v	:= gene0001.fn_diretorio(	pr_tpdireto => 'C',
								pr_cdcooper => 3);

	ds_nome_diretorio_v	:= ds_nome_diretorio_v || '/INC0130631';

end if;
 
valida_diretorio_p(	ds_nome_diretorio_p	=> ds_nome_diretorio_v,
			ds_critica_p		=> ds_critica_v);

if	(trim(ds_critica_v) is not null) then

	raise ds_exc_erro_v;

end if;

for	r01 in c01 loop

	begin

	if	(qt_reg_arquivo	>= 50000) then

		qt_reg_arquivo	:= 0;

		dbms_lob.createtemporary(ds_dados_rollback_v, true, dbms_lob.CALL);
		dbms_lob.open(ds_dados_rollback_v, dbms_lob.lob_readwrite);
		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'begin '||chr(13), false);  
		ds_nome_arquivo_bkp_v	:= 'ROLLBACK2_INC0130631-3_'||nr_arquivo||'.sql';

		nr_arquivo	:= nr_arquivo + 1;

	end if;

	qt_registro	:= qt_registro + 1;
	qt_reg_arquivo	:= qt_reg_arquivo + 1;

	update	cecred.crawseg a
	set	a.tpcustei	= 0
	where	a.rowid		= r01.nr_linha_craw;

	cecred.gene0002.pc_escreve_xml(	ds_dados_rollback_v,
					ds_texto_rollback_v,
					'update	cecred.crawseg a ' || chr(13) ||
					'set	a.tpcustei	= ' || replace(nvl(trim(to_char(r01.tpcustei)),'null'),',','.') || chr(13) ||
					'where	a.rowid		= ' || chr(39) || r01.nr_linha_craw || chr(39) || ';' || chr(13) || chr(13), false);

	if	(r01.cdsitseg	not in (2,5)) then

		update	cecred.crapseg a
		set	a.cdsitseg	= 2,
			a.dtcancel	= trunc(sysdate),
			a.dtfimvig	= trunc(sysdate)
		where	a.rowid		= r01.nr_linha_crap;

		cecred.gene0002.pc_escreve_xml(	ds_dados_rollback_v,
						ds_texto_rollback_v,
						'update	cecred.crapseg a ' || chr(13) ||
						'set	a.cdsitseg	= ' || replace(nvl(trim(to_char(r01.cdsitseg)),'null'),',','.') || ', ' || chr(13) ||
						'	a.dtcancel	= ' || 'to_date(' || chr(39) || trim(to_char(r01.dtcancel,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' || chr(13) ||
						'	a.dtfimvig	= ' || 'to_date(' || chr(39) || trim(to_char(r01.dtfimvig,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ') ' || chr(13) ||
						'where	a.rowid		= ' || chr(39) || r01.nr_linha_crap || chr(39) || ';' || chr(13) || chr(13), false);

	end if;

	for	r02 in c02(	cdcooper_p	=> r01.cdcooper,
				nrdconta_p	=> r01.nrdconta,
				nrctremp_p	=> r01.nrctrato,
				nrctrseg_p	=> r01.nrctrseg) loop

		begin

		update	cecred.tbseg_prestamista a
		set	a.tpregist	= 0
		where	a.rowid		= r02.nr_linha_tbseg;

		cecred.gene0002.pc_escreve_xml(	ds_dados_rollback_v,
						ds_texto_rollback_v,
						'update	cecred.tbseg_prestamista a ' || chr(13) ||
						'set	a.tpregist	= ' || replace(nvl(trim(to_char(r02.tpregist)),'null'),',','.') || chr(13) ||
						'where	a.rowid		= ' || chr(39) || r02.nr_linha_tbseg || chr(39) || ';' || chr(13) || chr(13), false);

		exception
		when others then
			vr_dscritic	:= 'Falha ao atualizar tbseg_prestamista';
			rollback;
			exit;
		end;

	end loop;

	if	(qt_registro	>= 10000) then

		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'commit;' || chr(13) || chr(13), FALSE);

		commit;

		qt_registro	:= 0;

	end if;

	if	(qt_reg_arquivo	>= 50000) then

		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'commit;' || chr(13) || chr(13), FALSE);
		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'end;'||chr(13), FALSE);
		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, chr(13), TRUE);

		cecred.gene0002.pc_solicita_relato_arquivo(	pr_cdcooper	=> cd_cooperativa_v,
							pr_cdprogra	=> 'ATENDA',
							pr_dtmvtolt	=> trunc(sysdate),
							pr_dsxml	=> ds_dados_rollback_v,
							pr_dsarqsaid	=> ds_nome_diretorio_v || '/' || ds_nome_arquivo_bkp_v,
							pr_flg_impri	=> 'N',
							pr_flg_gerar	=> 'S',
							pr_flgremarq	=> 'N',
							pr_nrcopias	=> 1,
							pr_des_erro	=> ds_critica_v);

		if	(trim(ds_critica_v) is not null) then

			rollback;
			raise	ds_exc_erro_v;

		end if;

		dbms_lob.close(ds_dados_rollback_v);
		dbms_lob.freetemporary(ds_dados_rollback_v);

	end if;

	exception
	when others then
		vr_dscritic	:= 'Falha ao atualizar tpcustei. Conta: ' || r01.nrdconta || '. ' || sqlerrm;
		rollback;
		exit;
	end;

end loop;

if	(qt_reg_arquivo	<> 50000) then

	cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'commit;' || chr(13) || chr(13), FALSE);
	cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'end;' || chr(13), FALSE);
	cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, chr(13), TRUE);

	cecred.gene0002.pc_solicita_relato_arquivo(	pr_cdcooper	=> cd_cooperativa_v,
						pr_cdprogra	=> 'ATENDA',
						pr_dtmvtolt	=> trunc(sysdate),
						pr_dsxml	=> ds_dados_rollback_v,
						pr_dsarqsaid	=> ds_nome_diretorio_v || '/' || ds_nome_arquivo_bkp_v,
						pr_flg_impri	=> 'N',
						pr_flg_gerar	=> 'S',
						pr_flgremarq	=> 'N',
						pr_nrcopias	=> 1,
						pr_des_erro	=> ds_critica_v);

	if	(trim(ds_critica_v) is not null) then

		raise	ds_exc_erro_v;

	end if;

	dbms_lob.close(ds_dados_rollback_v);
	dbms_lob.freetemporary(ds_dados_rollback_v);

end if;

commit;

qt_reg_arquivo	:= 50000;
qt_registro	:= 0;

for	r03 in c03 loop

	begin

	if	(qt_reg_arquivo	>= 50000) then

		qt_reg_arquivo	:= 0;

		dbms_lob.createtemporary(ds_dados_rollback_v, true, dbms_lob.CALL);
		dbms_lob.open(ds_dados_rollback_v, dbms_lob.lob_readwrite);
		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'begin '||chr(13), false);  
		ds_nome_arquivo_bkp_v	:= 'ROLLBACK2_INC0130631-3_'||nr_arquivo||'.sql';

		nr_arquivo	:= nr_arquivo + 1;

	end if;

	qt_registro	:= qt_registro + 1;
	qt_reg_arquivo	:= qt_reg_arquivo + 1;

	update	cecred.crawseg a
	set	a.dtfimvig	= r03.dtfim_prestamista
	where	a.rowid		= r03.nr_linha_craw;

	cecred.gene0002.pc_escreve_xml(	ds_dados_rollback_v,
					ds_texto_rollback_v,
					'update	cecred.crawseg a ' || chr(13) ||
					'set	a.dtfimvig	= to_date(' || chr(39) || trim(to_char(r03.dtfimvig,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ') ' ||
					'where	a.rowid		= ' || chr(39) || r03.nr_linha_craw || chr(39) || ';' || chr(13) || chr(13), false);

	if	(qt_registro	>= 10000) then

		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'commit;' || chr(13) || chr(13), FALSE);

		commit;

		qt_registro	:= 0;

	end if;

	if	(qt_reg_arquivo	>= 50000) then

		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'commit;' || chr(13) || chr(13), FALSE);
		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'end;'||chr(13), FALSE);
		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, chr(13), TRUE);

		cecred.gene0002.pc_solicita_relato_arquivo(	pr_cdcooper	=> cd_cooperativa_v,
							pr_cdprogra	=> 'ATENDA',
							pr_dtmvtolt	=> trunc(sysdate),
							pr_dsxml	=> ds_dados_rollback_v,
							pr_dsarqsaid	=> ds_nome_diretorio_v || '/' || ds_nome_arquivo_bkp_v,
							pr_flg_impri	=> 'N',
							pr_flg_gerar	=> 'S',
							pr_flgremarq	=> 'N',
							pr_nrcopias	=> 1,
							pr_des_erro	=> ds_critica_v);

		if	(trim(ds_critica_v) is not null) then

			rollback;
			raise	ds_exc_erro_v;

		end if;

		dbms_lob.close(ds_dados_rollback_v);
		dbms_lob.freetemporary(ds_dados_rollback_v);

	end if;

	exception
	when others then
		vr_dscritic	:= 'Falha ao atualizar dtfimvig crawseg. Conta: ' || r03.nrdconta || '. ' || sqlerrm;
		rollback;
		exit;
	end;

end loop;

if	(qt_reg_arquivo	<> 50000) then

	cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'commit;' || chr(13) || chr(13), FALSE);
	cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'end;' || chr(13), FALSE);
	cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, chr(13), TRUE);

	cecred.gene0002.pc_solicita_relato_arquivo(	pr_cdcooper	=> cd_cooperativa_v,
						pr_cdprogra	=> 'ATENDA',
						pr_dtmvtolt	=> trunc(sysdate),
						pr_dsxml	=> ds_dados_rollback_v,
						pr_dsarqsaid	=> ds_nome_diretorio_v || '/' || ds_nome_arquivo_bkp_v,
						pr_flg_impri	=> 'N',
						pr_flg_gerar	=> 'S',
						pr_flgremarq	=> 'N',
						pr_nrcopias	=> 1,
						pr_des_erro	=> ds_critica_v);

	if	(trim(ds_critica_v) is not null) then

		raise	ds_exc_erro_v;

	end if;

	dbms_lob.close(ds_dados_rollback_v);
	dbms_lob.freetemporary(ds_dados_rollback_v);

end if;

qt_reg_arquivo	:= 50000;
qt_registro	:= 0;

for	r04 in c04 loop

	begin

	if	(qt_reg_arquivo	>= 50000) then

		qt_reg_arquivo	:= 0;

		dbms_lob.createtemporary(ds_dados_rollback_v, true, dbms_lob.CALL);
		dbms_lob.open(ds_dados_rollback_v, dbms_lob.lob_readwrite);
		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'begin '||chr(13), false);  
		ds_nome_arquivo_bkp_v	:= 'ROLLBACK2_INC0130631-3_'||nr_arquivo||'.sql';

		nr_arquivo	:= nr_arquivo + 1;

	end if;

	qt_registro	:= qt_registro + 1;
	qt_reg_arquivo	:= qt_reg_arquivo + 1;

	update	cecred.crapseg a
	set	a.dtfimvig	= r04.dtfim_prestamista
	where	a.rowid		= r04.nr_linha_crap;

	cecred.gene0002.pc_escreve_xml(	ds_dados_rollback_v,
					ds_texto_rollback_v,
					'update	cecred.crapseg a ' || chr(13) ||
					'set	a.dtfimvig	= to_date(' || chr(39) || trim(to_char(r04.dtfimvig,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ') ' ||
					'where	a.rowid		= ' || chr(39) || r04.nr_linha_crap || chr(39) || ';' || chr(13) || chr(13), false);

	if	(qt_registro	>= 10000) then

		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'commit;' || chr(13) || chr(13), FALSE);

		commit;

		qt_registro	:= 0;

	end if;

	if	(qt_reg_arquivo	>= 50000) then

		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'commit;' || chr(13) || chr(13), FALSE);
		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'end;'||chr(13), FALSE);
		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, chr(13), TRUE);

		cecred.gene0002.pc_solicita_relato_arquivo(	pr_cdcooper	=> cd_cooperativa_v,
							pr_cdprogra	=> 'ATENDA',
							pr_dtmvtolt	=> trunc(sysdate),
							pr_dsxml	=> ds_dados_rollback_v,
							pr_dsarqsaid	=> ds_nome_diretorio_v || '/' || ds_nome_arquivo_bkp_v,
							pr_flg_impri	=> 'N',
							pr_flg_gerar	=> 'S',
							pr_flgremarq	=> 'N',
							pr_nrcopias	=> 1,
							pr_des_erro	=> ds_critica_v);

		if	(trim(ds_critica_v) is not null) then

			rollback;
			raise	ds_exc_erro_v;

		end if;

		dbms_lob.close(ds_dados_rollback_v);
		dbms_lob.freetemporary(ds_dados_rollback_v);

	end if;

	exception
	when others then
		vr_dscritic	:= 'Falha ao atualizar dtfimvig crapseg. Conta: ' || r04.nrdconta || '. ' || sqlerrm;
		rollback;
		exit;
	end;

end loop;

if	(qt_reg_arquivo	<> 50000) then

	cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'commit;' || chr(13) || chr(13), FALSE);
	cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'end;' || chr(13), FALSE);
	cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, chr(13), TRUE);

	cecred.gene0002.pc_solicita_relato_arquivo(	pr_cdcooper	=> cd_cooperativa_v,
						pr_cdprogra	=> 'ATENDA',
						pr_dtmvtolt	=> trunc(sysdate),
						pr_dsxml	=> ds_dados_rollback_v,
						pr_dsarqsaid	=> ds_nome_diretorio_v || '/' || ds_nome_arquivo_bkp_v,
						pr_flg_impri	=> 'N',
						pr_flg_gerar	=> 'S',
						pr_flgremarq	=> 'N',
						pr_nrcopias	=> 1,
						pr_des_erro	=> ds_critica_v);

	if	(trim(ds_critica_v) is not null) then

		raise	ds_exc_erro_v;

	end if;

	dbms_lob.close(ds_dados_rollback_v);
	dbms_lob.freetemporary(ds_dados_rollback_v);

end if;

commit;

qt_reg_arquivo	:= 50000;
qt_registro	:= 0;

for	r05 in c05 loop

	begin

	if	(qt_reg_arquivo	>= 50000) then

		qt_reg_arquivo	:= 0;

		dbms_lob.createtemporary(ds_dados_rollback_v, true, dbms_lob.CALL);
		dbms_lob.open(ds_dados_rollback_v, dbms_lob.lob_readwrite);
		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'begin '||chr(13), false);  
		ds_nome_arquivo_bkp_v	:= 'ROLLBACK2_INC0130631-3_'||nr_arquivo||'.sql';

		nr_arquivo	:= nr_arquivo + 1;

	end if;

	qt_registro	:= qt_registro + 1;
	qt_reg_arquivo	:= qt_reg_arquivo + 1;

	update	cecred.crawseg a
	set	a.dtmvtolt	= r05.dt_atualizada,
		a.dtinivig	= r05.dt_atualizada,
		a.dtdebito	= r05.dt_atualizada,
		a.dtiniseg	= r05.dt_atualizada,
		a.dtprideb	= r05.dt_atualizada
	where	a.rowid		= r05.nr_linha_craw;

	cecred.gene0002.pc_escreve_xml(	ds_dados_rollback_v,
					ds_texto_rollback_v,
					'update	cecred.crawseg a ' || chr(13) ||
					'set	a.dtmvtolt	= to_date(' || chr(39) || trim(to_char(r05.dtmvtolt_craw,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
					'	a.dtinivig	= to_date(' || chr(39) || trim(to_char(r05.dtinivig_craw,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
					'	a.dtdebito	= to_date(' || chr(39) || trim(to_char(r05.dtdebito_craw,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
					'	a.dtiniseg	= to_date(' || chr(39) || trim(to_char(r05.dtiniseg_craw,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
					'	a.dtprideb	= to_date(' || chr(39) || trim(to_char(r05.dtprideb_craw,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ') ' ||
					'where	a.rowid		= ' || chr(39) || r05.nr_linha_craw || chr(39) || ';' || chr(13) || chr(13), false);

	update	cecred.crapseg a
	set	a.dtmvtolt	= r05.dt_atualizada,
		a.dtinivig	= r05.dt_atualizada,
		a.dtdebito	= r05.dt_atualizada,
		a.dtiniseg	= r05.dt_atualizada,
		a.dtprideb	= r05.dt_atualizada,
		a.dtultpag	= r05.dt_atualizada,
		a.dtinsori	= r05.dt_atualizada
	where	a.rowid		= r05.nr_linha_crap;

	cecred.gene0002.pc_escreve_xml(	ds_dados_rollback_v,
					ds_texto_rollback_v,
					'update	cecred.crapseg a ' || chr(13) ||
					'set	a.dtmvtolt	= to_date(' || chr(39) || trim(to_char(r05.dtmvtolt_crap,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
					'	a.dtinivig	= to_date(' || chr(39) || trim(to_char(r05.dtinivig_crap,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
					'	a.dtdebito	= to_date(' || chr(39) || trim(to_char(r05.dtdebito_crap,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
					'	a.dtiniseg	= to_date(' || chr(39) || trim(to_char(r05.dtiniseg_crap,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
					'	a.dtprideb	= to_date(' || chr(39) || trim(to_char(r05.dtprideb_crap,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
					'	a.dtultpag	= to_date(' || chr(39) || trim(to_char(r05.dtultpag_crap,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
					'	a.dtinsori	= to_date(' || chr(39) || trim(to_char(r05.dtinsori_crap,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ') ' ||
					'where	a.rowid		= ' || chr(39) || r05.nr_linha_crap || chr(39) || ';' || chr(13) || chr(13), false);

	for	r06 in c06(	cdcooper_p	=> r05.cdcooper,
				nrdconta_p	=> r05.nrdconta,
				nrctremp_p	=> r05.nrctrato,
				nrctrseg_p	=> r05.nrctrseg) loop

		begin

		update	cecred.tbseg_prestamista a
		set	a.dtdevend	= r05.dt_atualizada,
			a.dtinivig	= r05.dt_atualizada,
			a.dtrefcob	= r05.dt_atualizada,
			a.dtdenvio	= r05.dt_atualizada
		where	a.rowid		= r06.nr_linha_tbseg;

		cecred.gene0002.pc_escreve_xml(	ds_dados_rollback_v,
						ds_texto_rollback_v,
						'update	cecred.tbseg_prestamista a ' || chr(13) ||
						'set	a.dtdevend	= to_date(' || chr(39) || trim(to_char(r06.dtdevend,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
						'	a.dtinivig	= to_date(' || chr(39) || trim(to_char(r06.dtinivig,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
						'	a.dtrefcob	= to_date(' || chr(39) || trim(to_char(r06.dtrefcob,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' ||
						'	a.dtdenvio	= to_date(' || chr(39) || trim(to_char(r06.dtdenvio,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ') ' ||
						'where	a.rowid		= ' || chr(39) || r06.nr_linha_tbseg || chr(39) || ';' || chr(13) || chr(13), false);

		exception
		when others then
			vr_dscritic	:= 'Falha ao atualizar datas tbseg_prestamista. Conta: ' || r05.nrdconta || '. ' || sqlerrm;
			rollback;
			exit;
		end;

	end loop;

	if	(qt_registro	>= 10000) then

		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'commit;' || chr(13) || chr(13), FALSE);

		commit;

		qt_registro	:= 0;

	end if;

	if	(qt_reg_arquivo	>= 50000) then

		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'commit;' || chr(13) || chr(13), FALSE);
		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'end;'||chr(13), FALSE);
		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, chr(13), TRUE);

		cecred.gene0002.pc_solicita_relato_arquivo(	pr_cdcooper	=> cd_cooperativa_v,
							pr_cdprogra	=> 'ATENDA',
							pr_dtmvtolt	=> trunc(sysdate),
							pr_dsxml	=> ds_dados_rollback_v,
							pr_dsarqsaid	=> ds_nome_diretorio_v || '/' || ds_nome_arquivo_bkp_v,
							pr_flg_impri	=> 'N',
							pr_flg_gerar	=> 'S',
							pr_flgremarq	=> 'N',
							pr_nrcopias	=> 1,
							pr_des_erro	=> ds_critica_v);

		if	(trim(ds_critica_v) is not null) then

			rollback;
			raise	ds_exc_erro_v;

		end if;

		dbms_lob.close(ds_dados_rollback_v);
		dbms_lob.freetemporary(ds_dados_rollback_v);

	end if;

	exception
	when others then
		vr_dscritic	:= 'Falha ao atualizar datas. Conta: ' || r05.nrdconta || '. ' || sqlerrm;
		rollback;
		exit;
	end;

end loop;

if	(qt_reg_arquivo	<> 50000) then

	cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'commit;' || chr(13) || chr(13), FALSE);
	cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'end;' || chr(13), FALSE);
	cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, chr(13), TRUE);

	cecred.gene0002.pc_solicita_relato_arquivo(	pr_cdcooper	=> cd_cooperativa_v,
						pr_cdprogra	=> 'ATENDA',
						pr_dtmvtolt	=> trunc(sysdate),
						pr_dsxml	=> ds_dados_rollback_v,
						pr_dsarqsaid	=> ds_nome_diretorio_v || '/' || ds_nome_arquivo_bkp_v,
						pr_flg_impri	=> 'N',
						pr_flg_gerar	=> 'S',
						pr_flgremarq	=> 'N',
						pr_nrcopias	=> 1,
						pr_des_erro	=> ds_critica_v);

	if	(trim(ds_critica_v) is not null) then

		raise	ds_exc_erro_v;

	end if;

	dbms_lob.close(ds_dados_rollback_v);
	dbms_lob.freetemporary(ds_dados_rollback_v);

end if;

if	(trim(vr_dscritic) is not null) then

	ds_critica_v	:= vr_dscritic;
	raise	ds_exc_erro_v;

end if;

commit;

exception
when	ds_exc_erro_v then

	raise_application_error(-20111, ds_critica_v);

end;

end;