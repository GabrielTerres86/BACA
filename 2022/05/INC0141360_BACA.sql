begin

declare

ds_exc_erro_v		exception;
ds_erro_registro_v	exception;
ds_critica_v		crapcri.dscritic%type;
ds_critica_rollback_v	crapcri.dscritic%type;
ds_critica_arq_v	crapcri.dscritic%type;
ie_idprglog_v		cecred.tbgen_prglog.idprglog%type	:= 0;

ds_dados_rollback_v	clob			:= null;
ds_texto_rollback_v	varchar2(32600);
nm_arquivo_rollback_v	varchar2(100);

cd_cooperativa_v	cecred.crapcop.cdcooper%type	:= 3;
ds_nome_diretorio_v	cecred.crapprm.dsvlrprm%type;

qt_reg_commit		number(10)	:= 0;
nr_arquivo		number(10)	:= 1;
qt_reg_arquivo		number(10)	:= 50000;

type	typ_reg_ctrl_coop is
	record(	cdcooper	cecred.crapcop.cdcooper%type);  

type	typ_tab_ctrl_coop is
	table of	typ_reg_ctrl_coop
	index by	varchar2(10);

vr_tab_ctrl_coop	typ_tab_ctrl_coop;

cursor	c01 is
select	a.cdcooper,
	a.nrproposta,
	a.rowid as nr_linha_tbseg,
	a.tpregist,
	c.rowid as nr_linha_crap,
	decode(	a.nrproposta,
		'770629444181',202.97,
		'770629445099',11.21,
		'770629445838',42.14,
		'770629445528',181.72,
		'770629445455',292.42,
		'770629444548',62.21,
		'770629445676',206.21,
		'770629443843',91.1,
		'770629443746',43.19,
		'770629444467',64.44,
		'770629446052',734.44,
		'770629445480',37.54,
		'770629443738',747.03,
		'770629445170',52.87,
		'770629444963',187.48,
		'770629445056',15.84,
		'770629444904',88.78,
		'770629674187',156.28) vl_corrigido,
	a.vlprodut as vlprodut_tbseg,
	c.vlpremio as vlpremio_crap,
	b.rowid as nr_linha_craw,
	b.vlpremio as vlpremio_craw
from	cecred.crapseg c,
	cecred.crawseg b,
	cecred.tbseg_prestamista a
where	c.cdsitseg		= 1
and	c.tpseguro		= 4
and	b.nrctrseg		= c.nrctrseg
and	b.nrdconta		= c.nrdconta
and	b.cdcooper		= c.cdcooper
and	a.nrproposta		= b.nrproposta
and	a.nrctrseg		= b.nrctrseg
and	a.nrdconta		= b.nrdconta
and	a.cdcooper		= b.cdcooper
and	trim(a.tprecusa)	is null
and	nvl(a.cdmotrec,0)	= 0
and	a.dtrecusa		is null
and	a.nrproposta		in
	('770629444181',
'770629445099',
'770629445838',
'770629445528',
'770629445455',
'770629444548',
'770629445676',
'770629443843',
'770629443746',
'770629444467',
'770629446052',
'770629445480',
'770629443738',
'770629445170',
'770629444963',
'770629445056',
'770629444904',
'770629674187');

cursor	c05 is
select	a.cdcooper,
	a.nmrescop
from	cecred.crapcop a
where	a.cdcooper	in (9,13);

procedure valida_diretorio_p(	ds_nome_diretorio_p	in	varchar2,
				ds_critica_p		out	cecred.crapcri.dscritic%TYPE) is

ds_critica_v	cecred.crapcri.dscritic%type;
ie_tipo_saida_v	varchar2(3);
ds_saida_v	varchar2(1000);
   
begin

	if	(cecred.gene0001.fn_exis_diretorio(ds_nome_diretorio_p)) then

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

procedure pc_gera_arquivo_coop_contributario(	pr_cdcooper	in cecred.crapcop.cdcooper%type,
						pr_diretorio	in cecred.crapprm.dsvlrprm%type,
						pr_nmrescop	in cecred.crapcop.nmrescop%type,
						pr_dscritic	out varchar2) is

vr_nrsequen		number(5);
vr_pielimit		cecred.tbseg_prestamista.vlpielimit%type;
vr_ifttlimi		cecred.tbseg_prestamista.vlpielimit%type;
vr_apolice		varchar2(20);
vr_nmarquiv		varchar2(100);
vr_nmarquivFinal	varchar2(100);
vr_linha_txt		varchar2(32600);
vr_ultimoDia		date;
vr_vlprodvl		number;
vr_dtfimvig		date;
vr_nr_meses		number;
vr_vlenviad		number;
vr_vlcaptpie		numeric(15,2);
vr_vlcaptiftt		numeric(15,2);
vr_modulo		varchar2(50);
vr_ind_arquivo		utl_file.file_type;

vr_dscritic		cecred.crapcri.dscritic%type;
vr_exc_saida_v		exception;

cursor	cr_prestamista(pr_cdcooper	cecred.crapcop.cdcooper%type) is
select	p.idseqtra,
	p.cdcooper,
	p.nrdconta,
	ass.cdagenci,
	p.nrctrseg,
	p.tpregist,
	p.cdapolic,
	p.nrcpfcgc,
	p.nmprimtl,
	p.dtnasctl,
	p.cdsexotl,
	p.dsendres,
	p.dsdemail,
	p.nmbairro,
	p.nmcidade,
	p.cdufresd,
	p.nrcepend,
	p.nrtelefo,
	p.dtdevend,
	p.dtinivig,
	p.nrctremp,
	p.cdcobran,
	p.cdadmcob,
	p.tpfrecob,
	p.tpsegura,
	p.cdplapro,
	p.vlprodut,
	p.tpcobran,
	p.vlsdeved,
	p.vldevatu,
	p.dtfimvig,
	c.inliquid,
	c.dtmvtolt data_emp,
	c.qtpreemp,
	c.vlpreemp,
	p.nrproposta,
	lpad(decode(p.cdcooper , 5,1, 7,2, 10,3,  11,4, 14,5, 9,6, 16,7, 2,8, 8,9, 6,10, 12,11, 13,12, 1,13  )   ,6,'0') cdcooperativa,
	SUM(p.vldevatu) over(partition by  p.cdcooper, p.nrcpfcgc ) saldo_cpf,
	ADD_MONTHS(c.dtmvtolt, c.qtpreemp)  dtfimctr,
	p.nrapolice,
	p.vlpielimit,
	p.vlifttlimi,
	p.qtifttdias,
	p.rowid as nr_linha_tbseg
FROM	cecred.tbseg_prestamista p,
	cecred.crapepr c,
	cecred.crapass ass
WHERE	p.cdcooper	= pr_cdcooper
AND	c.cdcooper	= p.cdcooper
AND	c.nrdconta	= p.nrdconta
AND	c.nrctremp	= p.nrctremp
AND	ass.cdcooper	= c.cdcooper
AND	ass.nrdconta	= c.nrdconta
and	p.nrproposta	in
	('770629444181',
'770629445099',
'770629445838',
'770629445528',
'770629445455',
'770629444548',
'770629445676',
'770629443843',
'770629443746',
'770629444467',
'770629446052',
'770629445480',
'770629443738',
'770629445170',
'770629444963',
'770629445056',
'770629444904',
'770629674187')
order by	p.nrcpfcgc asc,
	p.cdapolic;

rw_prestamista	cr_prestamista%rowtype;
        
cursor	cr_seg_parametro_prst(	pr_cdcooper	cecred.tbseg_prestamista.cdcooper%type,
				pr_tpcustei	cecred.tbseg_parametros_prst.tpcustei%type,
				pr_cdsegura	cecred.craptsg.cdsegura%type) is

select	pp.idseqpar,
	pp.seqarqu,
	pp.enderftp,
	pp.loginftp,
	pp.senhaftp,
	pp.nrapolic,
	pp.pielimit,
	pp.ifttlimi
FROM	cecred.tbseg_parametros_prst pp
WHERE	pp.cdcooper	= pr_cdcooper
AND	pp.tppessoa	= 1
AND	pp.cdsegura	= pr_cdsegura
AND	pp.tpcustei	= pr_tpcustei;

rw_seg_parametro_prst	cr_seg_parametro_prst%rowtype;

cursor	cr_crawseg(	pr_cdcooper	cecred.crawseg.cdcooper%type,
			pr_nrdconta	cecred.crawseg.nrdconta%type,
			pr_nrctrseg	cecred.crawseg.nrctrseg%type,
			pr_nrctrato	cecred.crawseg.nrctrato%type) is
select	c.flggarad,
	c.nrendres
from	cecred.crawseg c
where	c.cdcooper	= pr_cdcooper
and	c.nrdconta	= pr_nrdconta
and	c.nrctrseg	= pr_nrctrseg
and	c.nrctrato	= pr_nrctrato;

rw_crawseg	cr_crawseg%rowtype;

begin
       
	open	cr_seg_parametro_prst(	pr_cdcooper	=> pr_cdcooper,
					pr_tpcustei	=> 0,
					pr_cdsegura	=> cecred.segu0001.busca_seguradora);
	fetch	cr_seg_parametro_prst
	into	rw_seg_parametro_prst;

		if	(cr_seg_parametro_prst%notfound) then

			close	cr_seg_parametro_prst;
			vr_dscritic	:= 'Nao foi possivel localizar taxa de pagamento da seguradora. PC_PARAMETROS_PRST';
			raise	vr_exc_saida_v;

		end if;

	close	cr_seg_parametro_prst;
          
	vr_nrsequen	:= rw_seg_parametro_prst.seqarqu + 1;

	update	cecred.tbseg_parametros_prst p
	set	p.seqarqu	= vr_nrsequen
	where	p.idseqpar	= rw_seg_parametro_prst.idseqpar;

	vr_ultimoDia	:= trunc(SYSDATE,'MONTH')-1;

	IF	(gene0001.fn_database_name	= cecred.gene0001.fn_param_sistema('CRED',0,'DB_NAME_PRODUC')) then

		vr_apolice	:= nvl(rw_prestamista.nrapolice,rw_seg_parametro_prst.nrapolic);

	else

		vr_apolice	:= NVL(cecred.gene0001.fn_param_sistema('CRED', 0, 'APOLICE_ICATU_SEGPRE'),'77000799');

	end if;

	vr_nmarquiv		:= 'TMP_AILOS_' || vr_apolice || '_' || replace(pr_nmrescop,' ','_') || '_' ||
				REPLACE(to_char(vr_ultimoDia , 'MM/YYYY'), '/', '') || '_' || cecred.gene0002.fn_mask(vr_nrsequen, '99999') || '.csv';
                       
        vr_nmarquivFinal	:= 'AILOS_' || vr_apolice || '_' || replace(pr_nmrescop,' ','_') || '_' ||
				REPLACE(to_char(vr_ultimoDia , 'MM/YYYY'), '/', '') || '_' || cecred.gene0002.fn_mask(vr_nrsequen, '99999') || '.csv';

	cecred.GENE0001.pc_abre_arquivo(	pr_nmdireto	=> pr_diretorio,
					pr_nmarquiv	=> vr_nmarquiv,
					pr_tipabert	=> 'W',
					pr_utlfileh	=> vr_ind_arquivo,
					pr_des_erro	=> vr_dscritic);

	if	(vr_dscritic	is not null) then

		RAISE	vr_exc_saida_v;

	END IF;

	vr_linha_txt	:= 'CPF,Nome,Sexo,Data de Nascimento,Modulo,Subestipulante,Capital VG Basica,Matricula Funcional,Valor Premio VG,Data de Inicio de Vigencia do Contrato/Certificado,Data de Fim de Vigencia do Contrato/Certificado,' ||
			'Tipo de movimento,Endereco,Complemento,Bairro,Cidade,UF,CEP,' ||
			'Numero Endereco,Numero Proposta,Data da solicitacao do cancelamento,Numero da apolice coletiva,Data do Protocolo,CAPITAL PIE,CAPITAL IFTT,Meses de Financiamento,Data da Assinatura da Proposta,Valor da Parcela do financiamento,' ||
			'Competencia do movimento,Motivo do cancelamento do risco,Cooperativa,Banco,Agencia,Numero Conta Corrente';

	cecred.GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_linha_txt);

	vr_linha_txt := '';

	for	rw_prestamista in cr_prestamista(	pr_cdcooper	=> pr_cdcooper) loop

		vr_dtfimvig   := nvl(rw_prestamista.dtfimvig,rw_prestamista.dtfimctr);
		vr_modulo := '0';

		OPEN	cr_crawseg(	pr_cdcooper	=> rw_prestamista.cdcooper,
					pr_nrdconta	=> rw_prestamista.nrdconta,
					pr_nrctrseg	=> rw_prestamista.nrctrseg,
					pr_nrctrato	=> rw_prestamista.nrctremp);
		FETCH	cr_crawseg 
		INTO	rw_crawseg;

			IF	(cr_crawseg%NOTFOUND) THEN

				vr_dscritic	:= 'Proposta de seguro prestamista não localizado! Conta: ' || rw_prestamista.nrdconta ||
						' Apólice: ' || rw_prestamista.nrctrseg || ' Contrato Empréstimo: ' ||rw_prestamista.nrctremp ;

				RAISE	vr_exc_saida_v;

			END IF;

		CLOSE cr_crawseg;

		IF	(rw_crawseg.flggarad	= 1) THEN

			vr_vlcaptiftt	:= rw_prestamista.vlpreemp;
			vr_modulo	:= 2;
			vr_vlcaptpie	:= rw_prestamista.vlpreemp;
			vr_pielimit	:= nvl(rw_prestamista.vlpielimit, rw_seg_parametro_prst.pielimit);

			IF	(vr_vlcaptpie	> vr_pielimit) THEN

				vr_vlcaptpie	:= vr_pielimit;

			END IF;

			vr_vlcaptpie	:= vr_vlcaptpie * rw_prestamista.qtifttdias;
			vr_ifttlimi	:= nvl(rw_prestamista.vlifttlimi, rw_seg_parametro_prst.ifttlimi);

			IF	(vr_vlcaptiftt	> vr_ifttlimi) THEN

				vr_vlcaptiftt	:= vr_ifttlimi;

			END IF;

			vr_vlcaptiftt	:= vr_vlcaptiftt * rw_prestamista.qtifttdias;

		ELSE

			vr_vlcaptiftt	:= 0;
			vr_vlcaptpie	:= 0;
			vr_modulo	:= 1;

		END IF;

		vr_vlenviad	:= rw_prestamista.vlsdeved;
		vr_vlprodvl	:= rw_prestamista.vlprodut;

		IF	(vr_vlprodvl	< 0.01) THEN

			vr_vlprodvl	:= 0.01;

		END IF;

		IF	(vr_vlenviad < 0.01) THEN

			vr_vlenviad	:= 0.01;

		END IF;

		vr_linha_txt	:= '';
		vr_linha_txt	:= vr_linha_txt || TRIM(to_char(rw_prestamista.nrcpfcgc,'fm00000000000'))||',';
		vr_linha_txt	:= vr_linha_txt || TRIM(UPPER(cecred.gene0007.fn_caract_especial(rw_prestamista.nmprimtl)))||',';

		IF	(rw_prestamista.cdsexotl	= 1) THEN

			vr_linha_txt	:= vr_linha_txt || 'M,';

		ELSE

			vr_linha_txt	:= vr_linha_txt || 'F,';

		END IF;

		vr_linha_txt	:= vr_linha_txt || to_char(rw_prestamista.dtnasctl, 'DD/MM/YYYY')||',';
		vr_linha_txt	:= vr_linha_txt || vr_modulo||',';
		vr_linha_txt	:= vr_linha_txt || 0||',';
		vr_linha_txt	:= vr_linha_txt || REPLACE(to_char(rw_prestamista.vlsdeved,'fm999999999990d00'),',','.') ||',';
		vr_linha_txt	:= vr_linha_txt || TRIM(to_char(rw_prestamista.nrcpfcgc,'fm00000000000')) || rw_prestamista.nrctremp ||',' ;
		vr_linha_txt	:= vr_linha_txt || REPLACE(to_char(vr_vlprodvl,'fm999999999990d00'),',','.') ||',';
		vr_linha_txt	:= vr_linha_txt || TO_CHAR(rw_prestamista.dtinivig, 'DD/MM/YYYY')||',';
		vr_linha_txt	:= vr_linha_txt || TO_CHAR(vr_dtfimvig, 'DD/MM/YYYY')||',';
		vr_linha_txt	:= vr_linha_txt || 'I,';
		vr_linha_txt	:= vr_linha_txt || TRIM(REPLACE(UPPER(gene0007.fn_caract_especial(nvl(rw_prestamista.dsendres,' '))),',',' '))||',';
		vr_linha_txt	:= vr_linha_txt ||',';
		vr_linha_txt	:= vr_linha_txt ||TRIM(UPPER(gene0007.fn_caract_especial(nvl(rw_prestamista.nmbairro,' '))))||',';
		vr_linha_txt	:= vr_linha_txt ||TRIM(UPPER(gene0007.fn_caract_especial(nvl(rw_prestamista.nmcidade,' '))))||',';
		vr_linha_txt	:= vr_linha_txt || TRIM(nvl(to_char(rw_prestamista.cdufresd), ' '))||',';
		vr_linha_txt	:= vr_linha_txt || TRIM(rw_prestamista.nrcepend)||',';
		vr_linha_txt	:= vr_linha_txt || rw_crawseg.nrendres || ',';
		vr_linha_txt	:= vr_linha_txt || nvl(rw_prestamista.nrproposta,0)||',';
		vr_linha_txt	:= vr_linha_txt || ',';
		vr_linha_txt	:= vr_linha_txt || vr_apolice||',' ;
		vr_linha_txt	:= vr_linha_txt || TO_CHAR(rw_prestamista.data_emp, 'DD/MM/YYYY')||',';
		vr_linha_txt	:= vr_linha_txt || REPLACE(to_char(vr_vlcaptpie,'fm999999999990d00'),',','.') ||',';
		vr_linha_txt	:= vr_linha_txt || REPLACE(to_char(vr_vlcaptiftt,'fm999999999990d00'),',','.') ||',';

		vr_nr_meses	:= TRUNC((vr_dtfimvig - rw_prestamista.dtinivig)/30);

		vr_linha_txt	:= vr_linha_txt || vr_nr_meses ||',';
		vr_linha_txt	:= vr_linha_txt || TO_CHAR(rw_prestamista.dtdevend, 'DD/MM/YYYY')||' ,';
		vr_linha_txt	:= vr_linha_txt || REPLACE(to_char(rw_prestamista.vlpreemp,'fm999999999990d00'),',','.')||',' ;
		vr_linha_txt	:= vr_linha_txt || TO_CHAR(vr_ultimoDia, 'MMYYYY')||',' ;
		vr_linha_txt	:= vr_linha_txt || ' ,';
		vr_linha_txt	:= vr_linha_txt || TRIM(rw_prestamista.cdcooper)|| ',';
		vr_linha_txt	:= vr_linha_txt || '85,';
		vr_linha_txt	:= vr_linha_txt || TRIM(rw_prestamista.cdagenci)|| ',';
		vr_linha_txt	:= vr_linha_txt || TRIM(rw_prestamista.nrdconta);

		cecred.GENE0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_linha_txt);

		UPDATE	cecred.tbseg_prestamista a
		SET	a.tpregist	= 3
		WHERE	a.rowid		= rw_prestamista.nr_linha_tbseg;

	END LOOP;

	cecred.GENE0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo);

	cecred.GENE0003.pc_converte_arquivo(	pr_cdcooper	=> pr_cdcooper,
					pr_nmarquiv	=> pr_diretorio || vr_nmarquiv,
					pr_nmarqenv	=> vr_nmarquiv,
					pr_des_erro	=> vr_dscritic);

	IF	(vr_dscritic	IS NOT NULL) THEN

		RAISE	vr_exc_saida_v;

	END IF;

	cecred.gene0001.pc_OScommand_Shell(	pr_des_comando	=> 'iconv -f ISO8859-1 -t utf-8 '||pr_diretorio || '/converte/' || vr_nmarquiv ||
							' > '||pr_diretorio||vr_nmarquivFinal);

exception
when	vr_exc_saida_v then

	pr_dscritic	:= vr_dscritic || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;

WHEN	OTHERS THEN

	pr_dscritic	:= vr_dscritic || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;

END pc_gera_arquivo_coop_contributario;

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

	ds_nome_diretorio_v	:= ds_nome_diretorio_v || 'cpd/bacas/INC0141360';

else

	ds_nome_diretorio_v	:= cecred.gene0001.fn_diretorio(	pr_tpdireto => 'C',
								pr_cdcooper => 3);

	ds_nome_diretorio_v	:= ds_nome_diretorio_v || '/INC0141360';

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
		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, '-- LOGS E ROLLBACK ' || chr(13) || chr(13), false);
		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'begin ' || chr(13) || chr(13), false);  
		nm_arquivo_rollback_v	:= 'ROLLBACK_INC0141360_' || nr_arquivo || '.sql';

		nr_arquivo	:= nr_arquivo + 1;

	end if;

	if	(not vr_tab_ctrl_coop.exists(trim(to_char(r01.cdcooper)))) then

		vr_tab_ctrl_coop(trim(to_char(r01.cdcooper))).cdcooper	:= r01.cdcooper;

	end if;

	qt_reg_commit		:= qt_reg_commit + 1;
	qt_reg_arquivo		:= qt_reg_arquivo + 1;

	update	cecred.tbseg_prestamista a
	set	a.tpregist	= 1,
		a.vlprodut	= r01.vl_corrigido
	where	a.rowid		= r01.nr_linha_tbseg;

	gene0002.pc_escreve_xml(ds_dados_rollback_v,
				ds_texto_rollback_v,
				'update	cecred.tbseg_prestamista a ' || chr(13) ||
				'set	a.tpregist = ' || r01.tpregist || ', ' || chr(13) ||
				'	a.vlprodut = ' || replace(nvl(trim(to_char(r01.vlprodut_tbseg)),'null'),',','.') || chr(13) ||
				'where	a.rowid	= ' || chr(39) || r01.nr_linha_tbseg || chr(39) || ';' || chr(13) || chr(13), false);

	update	cecred.crawseg a
	set	a.vlpremio	= r01.vl_corrigido
	where	a.rowid		= r01.nr_linha_craw;

	cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v,
				ds_texto_rollback_v,
				'update	crawseg a ' || chr(13) ||
				'set	a.vlpremio = ' || replace(nvl(trim(to_char(r01.vlpremio_craw)),'null'),',','.') || chr(13) ||
				'where	a.rowid	= ' || chr(39) || r01.nr_linha_craw || chr(39) || ';' || chr(13) || chr(13), false);

	update	cecred.crapseg a
	set	a.vlpremio	= r01.vl_corrigido
	where	a.rowid		= r01.nr_linha_crap;

	cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v,
				ds_texto_rollback_v,
				'update	crapseg a ' || chr(13) ||
				'set	a.vlpremio = ' || replace(nvl(trim(to_char(r01.vlpremio_crap)),'null'),',','.') || chr(13) ||
				'where	a.rowid	= ' || chr(39) || r01.nr_linha_crap || chr(39) || ';' || chr(13) || chr(13), false);

	if	(qt_reg_commit	>= 10000) then

		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'commit;' || chr(13) || chr(13), FALSE);

		commit;

		qt_reg_commit	:= 0;

	end if;

	if	(qt_reg_arquivo	>= 50000) then

		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'end;'||chr(13), FALSE);
		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, chr(13), TRUE);

		cecred.gene0002.pc_solicita_relato_arquivo(	pr_cdcooper	=> cd_cooperativa_v,
							pr_cdprogra	=> 'ATENDA',
							pr_dtmvtolt	=> trunc(sysdate),
							pr_dsxml	=> ds_dados_rollback_v,
							pr_dsarqsaid	=> ds_nome_diretorio_v || '/' || nm_arquivo_rollback_v,
							pr_flg_impri	=> 'N',
							pr_flg_gerar	=> 'S',
							pr_flgremarq	=> 'N',
							pr_nrcopias	=> 1,
							pr_des_erro	=> ds_critica_rollback_v);

		if	(trim(ds_critica_rollback_v) is not null) then

			raise	ds_erro_registro_v;

		end if;

		dbms_lob.close(ds_dados_rollback_v);
		dbms_lob.freetemporary(ds_dados_rollback_v);

	end if;

	exception
	when	ds_erro_registro_v then

		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v,
					ds_texto_rollback_v,
					'LOG: falha mapeada ao atualizar registro:' || chr(13) ||
					'Proposta: ' || r01.nrproposta || chr(13) ||
					'Crítica: ' || ds_critica_rollback_v || chr(13) || chr(13), false);

	when	others then

		rollback;

		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v,
					ds_texto_rollback_v,
					'LOG: erro de sistema ao atualizar registro:' || chr(13) ||
					'Proposta: ' || r01.nrproposta || chr(13) ||
					'Erro: ' || sqlerrm || chr(13) || chr(13), false);

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
						pr_dsarqsaid	=> ds_nome_diretorio_v || '/' || nm_arquivo_rollback_v,
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

	commit;

end if;

for	r05 in c05 loop

	ds_critica_v	:= null;

	if	(vr_tab_ctrl_coop.exists(trim(to_char(r05.cdcooper)))) then

		pc_gera_arquivo_coop_contributario(	pr_cdcooper	=> r05.cdcooper,
							pr_diretorio	=> ds_nome_diretorio_v,
							pr_nmrescop	=> r05.nmrescop,
							pr_dscritic	=> ds_critica_v);

		if	(ds_critica_v	is null) then

			commit;

		else

			rollback;
			ds_critica_arq_v	:= substr(ds_critica_arq_v || ' - Coop: ' || r05.cdcooper || ' - ' || ds_critica_v || chr(13),1,1000);

			cecred.pc_log_programa(	pr_dstiplog		=> 'E',
						pr_cdprograma		=> 'ATENDA',
						pr_cdcooper		=> r05.cdcooper,
						pr_tpexecucao		=> 2,
						pr_tpocorrencia		=> 0,
						pr_cdcriticidade	=> 2,
						pr_dsmensagem		=> 'INC0141360 - ' || ds_critica_v,
						pr_flgsucesso		=> 0,
						pr_nmarqlog		=> NULL,
						pr_idprglog		=> ie_idprglog_v);

		end if;

	end if;

end loop;

vr_tab_ctrl_coop.delete;

if	(ds_critica_arq_v	is not null) then

	ds_critica_v	:= ds_critica_arq_v;
	raise	ds_exc_erro_v;

end if;

exception
when	ds_exc_erro_v then

	rollback;
	raise_application_error(-20111, ds_critica_v);

end;

end;