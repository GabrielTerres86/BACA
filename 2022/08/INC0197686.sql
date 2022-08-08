begin

declare

ds_exc_erro_v		exception;
ds_critica_v		cecred.crapcri.dscritic%type;
ds_critica_rollback_v	cecred.crapcri.dscritic%type;
ds_critica_arq_v	cecred.crapcri.dscritic%type;

ds_dados_rollback_v	clob			:= null;
ds_texto_rollback_v	varchar2(32600);
nm_arquivo_rollback_v	varchar2(100);

cd_cooperativa_v	cecred.crapcop.cdcooper%type	:= 3;
ds_nome_diretorio_v	cecred.crapprm.dsvlrprm%type;

qt_reg_commit		number(10)	:= 0;
nr_arquivo		number(10)	:= 1;
qt_reg_arquivo		number(10)	:= 10000;

vr_cdprogra		cecred.crapprg.cdprogra%type	:= 'BACA_PRST';
vr_index		varchar2(50);
vr_ultimoDia		date;

vr_vlenviad		number;
vr_dsadesao		varchar2(100);
vr_vltotdiv815		number(30,10)	:= 0;
vr_flgachou		boolean		:= false;
vr_dir_relatorio_815	varchar2(100);

type	typ_reg_record	is record
			(cdcooper	cecred.tbseg_prestamista.cdcooper%type,
			nrdconta	cecred.tbseg_prestamista.nrdconta%type,
			cdagenci	cecred.crapass.cdagenci%type,
			dtmvtolt	cecred.crapdat.dtmvtolt%type,
			dtinivig	cecred.crapdat.dtmvtolt%type,
			dtrefcob	cecred.crapdat.dtmvtolt%type,
			nmrescop	cecred.crapcop.nmrescop%type,
			vlenviad	number,
			dsregist	varchar2(20),
			tpregist	cecred.tbseg_prestamista.tpregist%type,
			nmprimtl	cecred.tbseg_prestamista.nmprimtl%type,
			nrcpfcgc	cecred.tbseg_prestamista.nrcpfcgc%type,
			nrctrseg	varchar2(15),
			nrctremp	cecred.tbseg_prestamista.nrctremp%type,
			vlprodut	cecred.tbseg_prestamista.vlprodut%type,
			vlsdeved	cecred.tbseg_prestamista.vlsdeved%type);

type	typ_tab		is table of typ_reg_record index by varchar2(30);
vr_crrl815		typ_tab;
vr_tab_crrl815		typ_tab;

vr_index_815		pls_integer	:= 0;
vr_vltotarq		number(30,10);

type	typ_reg_totais	is record
			(vlpremio	number(25,2),
			slddeved	number(25,2),
			qtdadesao	pls_integer,
			dsadesao	varchar2(20));

type	typ_tab_totais	is table of typ_reg_totais index by varchar2(100);
vr_totais		typ_tab_totais;

vr_des_xml		clob;

type	typ_reg_totdat	is record
			(vlpremio	number(25,2),
			slddeved	number(25,2));

type	typ_tab_sldevpa	is table of typ_reg_totdat index by pls_integer;
vr_tab_sldevpac		typ_tab_sldevpa;

type	typ_tab_lancarq	is table of number(30,10) index by pls_integer;
vr_tab_lancarq_815	typ_tab_lancarq;

vr_dtmvtolt_yymmdd	VARCHAR2(8);
vr_linhadet		VARCHAR(4000);
vr_arquivo_txt		utl_file.file_type;
vr_idx_lancarq		pls_integer;
vr_nmsegura            VARCHAR2(200);
vr_typ_said            VARCHAR2(4);

cursor	c05 is
select	a.cdcooper,
	a.nmrescop,
	nvl(b.dtmvtolt,trunc(sysdate)) dtmvtolt
from	cecred.crapdat b,
	cecred.crapcop a
where	a.cdcooper	= b.cdcooper
and	a.cdcooper	in (1,16);

procedure valida_diretorio_p(	ds_nome_diretorio_p	in	varchar2,
				ds_critica_p		out	cecred.crapcri.dscritic%type) is

ds_critica_v	crapcri.dscritic%type;
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

procedure	pc_escreve_xml_rel(	pr_des_dados	varchar2) is
begin

	dbms_lob.writeappend(vr_des_xml,length(pr_des_dados),pr_des_dados);

end	pc_escreve_xml_rel;

procedure	pc_finaliza_arquivo is

begin

	qt_reg_commit		:= qt_reg_commit + 1;
	qt_reg_arquivo		:= qt_reg_arquivo + 1;

	if	(qt_reg_commit	>= 1000) then

		commit;

		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'commit;' || chr(13) || chr(13), FALSE);

		qt_reg_commit	:= 0;

	end if;

	if	(qt_reg_arquivo	>= 10000) then

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

			ds_critica_v	:= ds_critica_v || '-' || ds_critica_rollback_v;

			raise	ds_exc_erro_v;

		end if;

		dbms_lob.close(ds_dados_rollback_v);
		dbms_lob.freetemporary(ds_dados_rollback_v);

	end if;

end pc_finaliza_arquivo;

procedure	pc_gera_arquivo_coop(	pr_cdcooper	in cecred.crapcop.cdcooper%type,
					pr_diretorio	in cecred.crapprm.dsvlrprm%type,
					pr_nmrescop	in cecred.crapcop.nmrescop%type,
					pr_dtmvtolt	in cecred.crapdat.dtmvtolt%type,
					pr_dscritic	out varchar2) is

vr_tab_nrdeanos		pls_integer;
vr_dscritic		varchar2(4000);
vr_cdcritic		PLS_INTEGER;
vr_destinatario_email	varchar2(500)		:= cecred.gene0001.fn_param_sistema('CRED', 0, 'ENVIA_SEG_PRST_EMAIL');
vr_exc_saida		exception;
vr_nrsequen		number(5);
vr_seqtran		integer			:= 1;
vr_vlminimo		number;
vr_tpregist		integer;
vr_nrdmeses		number;
vr_contrcpf		cecred.tbseg_prestamista.nrcpfcgc%type;
vr_vltotenv		number;
vr_vlmaximo		number;
vr_dscorpem		varchar2(2000);
vr_apolice		varchar2(20);
vr_nmarquiv		varchar2(100);
vr_linha_txt		varchar2(32600);
vr_pgtosegu		number;
vr_vlprodvl		number;
vr_dtfimvig		date;
vr_dtcalcidade		date;
vr_dstextab		varchar2(400);
vr_nrdeanos		pls_integer;
vr_dsdidade		varchar2(50);
vr_dsdemail		varchar2(100);
vr_nrproposta		varchar2(15);
vr_dtdevend		cecred.tbseg_prestamista.dtdevend%TYPE;
vr_dtinivig		cecred.tbseg_prestamista.dtinivig%TYPE;
vr_flgnvenv		BOOLEAN;

nr_proposta_v		cecred.tbseg_prestamista.nrproposta%type;
        
type	typ_reg_ctrl_prst is
	record(	nrcpfcgc	cecred.tbseg_prestamista.nrcpfcgc%type,
		nrctremp	cecred.tbseg_prestamista.nrctremp%type);  

type	typ_tab_ctrl_prst is
	table of	typ_reg_ctrl_prst
	index by	varchar2(40);

vr_tab_ctrl_prst	typ_tab_ctrl_prst;
        
vr_ind_arquivo		utl_file.file_type;
        
cursor	cr_craptsg(	pr_cdcooper	cecred.crapcop.cdcooper%type,
			pr_cdsegura	cecred.craptsg.cdsegura%type) is
select	a.nrtabela
from	craptsg a
where	a.cdcooper	= pr_cdcooper
and	a.tpseguro	= 4
and	a.tpplaseg	= 1
and	a.cdsegura	= pr_cdsegura;

CURSOR	cr_seg_parametro_prst(	pr_cdcooper	cecred.tbseg_prestamista.cdcooper%TYPE) IS
SELECT	pp.idseqpar,
	pp.tppessoa,
	pp.cdsegura,
	pp.tpcustei,
	pp.nrapolic,
	pp.pagsegu,
	pp.seqarqu,
	pp.enderftp,
	pp.loginftp,
	pp.senhaftp
FROM	cecred.tbseg_parametros_prst pp
WHERE	pp.cdcooper	= pr_cdcooper
AND	pp.tppessoa	= 1
AND	pp.cdsegura	= cecred.segu0001.busca_seguradora
AND	pp.tpcustei	= 1;

rw_seg_parametro_prst	cr_seg_parametro_prst%ROWTYPE;

cursor	cr_prestamista(	pr_cdcooper IN cecred.crapcop.cdcooper%type) is
select	p.rowid as nr_linha_tbseg,
	ap.rowid as nr_linha_crapseg,
	aw.rowid as nr_linha_crawseg,
	p.idseqtra,
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
	p.nrproposta,
	lpad(decode(p.cdcooper , 5,1, 7,2, 10,3, 11,4, 14,5, 9,6, 16,7, 2,8, 8,9, 6,10, 12,11, 13,12, 1,13),6,'0') cdcooperativa,
	sum(p.vldevatu) over(partition by  p.cdcooper, p.nrcpfcgc ) saldo_cpf,
	add_months(c.dtmvtolt, c.qtpreemp) dtfimctr,
	p.dtdenvio,
	p.dtrefcob,
	ap.cdsitseg,
	p.tpcustei
from	cecred.tbseg_prestamista p,
	cecred.crapepr c,
	cecred.crapass ass,
	cecred.crawseg aw,
	cecred.crapseg ap
where	c.cdcooper		= p.cdcooper
and	c.nrdconta		= p.nrdconta
and	c.nrctremp		= p.nrctremp
and	ass.cdcooper		= c.cdcooper
and	ass.nrdconta		= c.nrdconta
and	ap.tpseguro		= 4
and	aw.nrctrseg		= ap.nrctrseg
and	aw.nrdconta		= ap.nrdconta
and	aw.cdcooper		= ap.cdcooper
and	p.nrctrseg		= aw.nrctrseg
and	p.nrctremp		= aw.nrctrato
and	p.nrdconta		= aw.nrdconta
and	p.cdcooper		= aw.cdcooper
and	p.cdcooper		= pr_cdcooper
AND	TRUNC(p.dtinivig)	< trunc(SYSDATE,'month')
and	p.tpregist		<> 0
and	p.tpcustei		= 1
order by	p.nrcpfcgc asc,
	p.cdapolic;

rw_prestamista	cr_prestamista%rowtype;

CURSOR	cr_crawepr(	pr_cdcooper	cecred.crawepr.cdcooper%TYPE,
			pr_nrdconta	cecred.crawepr.nrdconta%TYPE,
			pr_nrctremp	cecred.crawepr.nrctremp%TYPE) IS

SELECT	e.dtmvtolt,
	(SELECT	MAX(pe.dtvencto)
	FROM	cecred.crappep pe
	WHERE	e.cdcooper	= pe.cdcooper
	AND	e.nrdconta	= pe.nrdconta
	AND	e.nrctremp	= pe.nrctremp) dtvencto
FROM	cecred.crawepr e
WHERE	e.cdcooper	= pr_cdcooper
AND	e.nrdconta	= pr_nrdconta
AND	e.nrctremp	= pr_nrctremp
AND	e.flgreneg	= 1;

rw_crawepr	cr_crawepr%ROWTYPE;

begin     

	OPEN	cr_seg_parametro_prst(	pr_cdcooper	=> pr_cdcooper);
	FETCH	cr_seg_parametro_prst
	INTO	rw_seg_parametro_prst;

		IF	cr_seg_parametro_prst%NOTFOUND THEN

			CLOSE	cr_seg_parametro_prst;
			vr_dscritic	:= 'Não foi possível localizar taxa de pagamento da seguradora. PC_PARAMETROS_PRST';
			RAISE		vr_exc_saida;

		END IF;

	CLOSE	cr_seg_parametro_prst;

	vr_vlminimo	:= cecred.segu0003.fn_capital_seguravel_min(	pr_cdcooper	=> pr_cdcooper,
									pr_tppessoa	=> rw_seg_parametro_prst.tppessoa,
									pr_cdsegura	=> rw_seg_parametro_prst.cdsegura,
									pr_tpcustei	=> rw_seg_parametro_prst.tpcustei,
									pr_dtnasc	=> TO_DATE('01/01/1990','DD/MM/RRRR'),
									pr_cdcritic	=> vr_cdcritic,
									pr_dscritic	=> vr_dscritic);

	vr_vlmaximo	:= cecred.segu0003.fn_capital_seguravel_max(	pr_cdcooper	=> pr_cdcooper,
									pr_tppessoa	=> rw_seg_parametro_prst.tppessoa,
									pr_cdsegura	=> rw_seg_parametro_prst.cdsegura,
									pr_tpcustei	=> rw_seg_parametro_prst.tpcustei,
									pr_dtnasc	=> TO_DATE('01/01/1990','DD/MM/RRRR'),
									pr_cdcritic	=> vr_cdcritic,
									pr_dscritic	=> vr_dscritic);

	IF	(vr_dscritic	IS NOT NULL) THEN

		RAISE	vr_exc_saida;

	END IF;

	vr_nrsequen	:= rw_seg_parametro_prst.seqarqu+ 1;
	vr_apolice	:= rw_seg_parametro_prst.nrapolic;
	vr_pgtosegu	:= rw_seg_parametro_prst.pagsegu;

	if	(qt_reg_arquivo	>= 10000) then

		qt_reg_arquivo	:= 0;

		dbms_lob.createtemporary(ds_dados_rollback_v, true, dbms_lob.CALL);
		dbms_lob.open(ds_dados_rollback_v, dbms_lob.lob_readwrite);
		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'LOGS E ROLLBACK ' || chr(13) || chr(13), false);
		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'begin ' || chr(13) || chr(13), false);  
		nm_arquivo_rollback_v	:= 'ROLLBACK_INC0197686_coop_' || pr_cdcooper || '_arq_' || nr_arquivo || '.sql';

		nr_arquivo	:= nr_arquivo + 1;

	end if;
          
	begin

		UPDATE	cecred.tbseg_parametros_prst p
		SET	p.seqarqu	= vr_nrsequen
		WHERE	p.idseqpar	= rw_seg_parametro_prst.idseqpar;

		gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v,
					' update	cecred.tbseg_parametros_prst a ' || chr(13) ||
					' set	a.seqarqu	= ' || rw_seg_parametro_prst.seqarqu || chr(13) ||
					' where	a.idseqpar	= ' || rw_seg_parametro_prst.idseqpar || ';' || chr(13) || chr(13), FALSE);

	exception
	when	others then

		vr_dscritic	:= 'Erro ao atualizar sequencia da cooperativa: ' || pr_cdcooper || ' - ' || sqlerrm;
		raise	vr_exc_saida;

	end;

	vr_dtcalcidade	:= to_date(add_months(vr_ultimoDia,-1),'dd/mm/rrrr');

        vr_nmarquiv	:= 'AILOS_' || replace(pr_nmrescop,' ','_') || '_' ||
			replace(to_char(vr_ultimoDia , 'MM/YYYY'), '/', '_') || '_' ||
			gene0002.fn_mask(vr_nrsequen, '99999') || '.txt';

	cecred.gene0001.pc_abre_arquivo(	pr_nmdireto	=> pr_diretorio || '/arq/',
					pr_nmarquiv	=> vr_nmarquiv,
					pr_tipabert	=> 'W',
					pr_utlfileh	=> vr_ind_arquivo,
					pr_des_erro	=> vr_dscritic);

	if	(vr_dscritic	is not null) then

		raise	vr_exc_saida;

	end if;
      
	open	cr_craptsg(	pr_cdcooper	=> pr_cdcooper,
				pr_cdsegura	=> cecred.segu0001.busca_seguradora);
	fetch	cr_craptsg
	into	vr_tab_nrdeanos;

		if	(cr_craptsg%notfound) then

			vr_tab_nrdeanos	:= 0;

		end if;

	close	cr_craptsg;

	for	rw_prestamista in
		cr_prestamista(	pr_cdcooper	=> pr_cdcooper) loop

		if	(qt_reg_arquivo	>= 10000) then

			qt_reg_arquivo	:= 0;

			dbms_lob.createtemporary(ds_dados_rollback_v, true, dbms_lob.CALL);
			dbms_lob.open(ds_dados_rollback_v, dbms_lob.lob_readwrite);
			cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'LOGS E ROLLBACK ' || chr(13) || chr(13), false);
			cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'begin ' || chr(13) || chr(13), false);  
			nm_arquivo_rollback_v	:= 'ROLLBACK_INC0197686_coop_' || pr_cdcooper || '_arq_' || nr_arquivo || '.sql';

			nr_arquivo	:= nr_arquivo + 1;

		end if;

		vr_NRPROPOSTA	:= nvl(rw_prestamista.NRPROPOSTA,0);
		vr_dtdevend	:= rw_prestamista.dtdevend;
		vr_dtinivig	:= rw_prestamista.dtinivig;
		vr_flgnvenv	:= FALSE; 
		vr_tpregist	:= rw_prestamista.tpregist;
		vr_dtfimvig	:= nvl(rw_prestamista.dtfimvig,rw_prestamista.dtfimctr);

		cecred.cada0001.pc_busca_idade(	pr_dtnasctl	=> rw_prestamista.dtnasctl,
						pr_dtmvtolt	=> vr_dtcalcidade,
						pr_flcomple	=> 1,
						pr_nrdeanos	=> vr_nrdeanos,
						pr_nrdmeses	=> vr_nrdmeses,
						pr_dsdidade	=> vr_dsdidade,
						pr_des_erro	=> vr_dscritic);

		if	(rw_prestamista.saldo_cpf	< vr_vlminimo) and
			(vr_tpregist			= 3) then

			vr_tpregist	:= 2;

		elsif	(rw_prestamista.saldo_cpf	>= vr_vlminimo) and
			(vr_tpregist			= 2) and
			(rw_prestamista.vldevatu	> 0) then

			if	(vr_nrdeanos > vr_tab_nrdeanos) or (vr_nrdeanos < 14) then

				if	(vr_nrdeanos	> vr_tab_nrdeanos) then

					vr_tpregist	:= 0;

					begin

						UPDATE	cecred.tbseg_prestamista a
						SET	a.tpregist	= vr_tpregist
						WHERE	a.rowid		= rw_prestamista.nr_linha_tbseg;

						cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v,
								' update	cecred.tbseg_prestamista a ' || chr(13) ||
								' set		a.tpregist	= ' || rw_prestamista.tpregist || chr(13) ||
								' where		a.rowid		= ' || chr(39) || rw_prestamista.nr_linha_tbseg || chr(39) || ';' || chr(13) || chr(13), FALSE);

					exception
					WHEN	OTHERS THEN

						vr_cdcritic	:= 0;
						vr_dscritic	:= 'Erro ao atualizar tipo de registro(idade): ' || pr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || SQLERRM;
						RAISE	vr_exc_saida;

					END;

				end if;

				pc_finaliza_arquivo;

				continue;

			end if;

			if	(rw_prestamista.cdsitseg	= 1) then

				BEGIN

					vr_nrproposta	:= cecred.SEGU0003.FN_NRPROPOSTA(1);

					UPDATE	cecred.tbseg_prestamista a
					SET	a.tpregist	= 1,
						a.dtinivig	= trunc(SYSDATE,'MONTH')-1,
						a.nrproposta	= vr_nrproposta
					WHERE	a.rowid		= rw_prestamista.nr_linha_tbseg;

					cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v,
									' update	cecred.tbseg_prestamista a ' || chr(13) ||
									' set		a.tpregist	= ' || rw_prestamista.tpregist || ', ' || chr(13) ||
									'		a.dtinivig	= to_date(' || chr(39) || trim(to_char(rw_prestamista.dtinivig,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' || chr(13) ||
									'		a.nrproposta	= ' || chr(39) || rw_prestamista.nrproposta || chr(39) || chr(13) ||
									' where		a.rowid		= ' || chr(39) || rw_prestamista.nr_linha_tbseg || chr(39) || ';' || chr(13) || chr(13), FALSE);

					UPDATE	cecred.crawseg w
					SET	w.nrproposta	= vr_nrproposta
					WHERE	w.rowid		= rw_prestamista.nr_linha_crawseg;

					cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v,
									' update	cecred.crawseg a ' || chr(13) ||
									' set		a.nrproposta	= ' || chr(39) || rw_prestamista.nrproposta || chr(39) || chr(13) ||
									' where		a.rowid		= ' || chr(39) || rw_prestamista.nr_linha_crawseg || chr(39) || ';' || chr(13) || chr(13), FALSE);

				EXCEPTION
				WHEN	OTHERS THEN

					vr_dscritic	:= 'Erro ao atualizar tbseg_prestamista (replica_cancelado)' ||
							' - Cooperativa: ' || pr_cdcooper ||
							' - Conta: ' || rw_prestamista.nrdconta ||
							' - Contrato Prestamista: ' || rw_prestamista.nrctrseg ||
							' - Contrato Emprestimo: ' || rw_prestamista.nrctremp || ' - ' || SQLERRM;

					RAISE		vr_exc_saida;

				END;

			end if;

			IF	(NVL(vr_nrproposta,0)	= 0) THEN

				vr_nrproposta	:= nvl(rw_prestamista.NRPROPOSTA,0);

			END IF;

			vr_dtdevend	:= rw_prestamista.data_emp;
			vr_dtinivig	:= vr_ultimoDia;
			vr_tpregist	:= 1;

			vr_flgnvenv	:= TRUE;

		elsif	(rw_prestamista.saldo_cpf	< vr_vlminimo) and
			(vr_tpregist			in (2,1)) then

			if	(vr_tpregist	= 1) then

				begin

					update	cecred.tbseg_prestamista a
					set	a.dtdenvio	= pr_dtmvtolt
					where	a.rowid		= rw_prestamista.nr_linha_tbseg;

					cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v,
								' update	cecred.tbseg_prestamista a ' || chr(13) ||
								' set		a.dtdenvio	= to_date(' || chr(39) || trim(to_char(rw_prestamista.dtdenvio,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ') ' || chr(13) ||
								' where		a.rowid		= ' || chr(39) || rw_prestamista.nr_linha_tbseg || chr(39) || ';' || chr(13) || chr(13), FALSE);

				exception
				when	others then

					vr_dscritic	:= 'Erro ao atualizar saldo do contrato: ' || pr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || sqlerrm;
					raise	vr_exc_saida;

				end;

			end if;

			pc_finaliza_arquivo;

			continue;

		end if;

		if	(vr_tab_ctrl_prst.EXISTS(rw_prestamista.nrcpfcgc || rw_prestamista.nrctremp)) then

			vr_tpregist	:= 0;

			begin

				update	cecred.tbseg_prestamista a
				set	a.tpregist	= vr_tpregist
				where	a.rowid		= rw_prestamista.nr_linha_tbseg;

				cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v,
							' update	cecred.tbseg_prestamista a ' || chr(13) ||
							' set	a.tpregist	= ' || rw_prestamista.tpregist || chr(13) ||
							' where	a.rowid		= ' || chr(39) || rw_prestamista.nr_linha_tbseg || chr(39) || ';' || chr(13) || chr(13), FALSE);

			exception
			when	others then

				vr_dscritic	:= 'Erro ao atualizar tipo de registro(idade): ' || pr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || sqlerrm;
				raise	vr_exc_saida;

			end;

			pc_finaliza_arquivo;

			continue;

		else

			vr_index	:= rw_prestamista.nrcpfcgc || rw_prestamista.nrctremp;
			vr_tab_ctrl_prst(vr_index).nrcpfcgc	:= rw_prestamista.nrcpfcgc;
			vr_tab_ctrl_prst(vr_index).nrctremp	:= rw_prestamista.nrctremp;

		end if;

		if	(vr_contrcpf	is null) or
			(vr_contrcpf	<> rw_prestamista.nrcpfcgc) then

			vr_contrcpf	:= rw_prestamista.nrcpfcgc;
			vr_vlenviad	:= rw_prestamista.vldevatu;
			vr_vltotenv	:= rw_prestamista.vldevatu;

		else

			vr_vlenviad	:= rw_prestamista.vldevatu;
			vr_vltotenv	:= vr_vltotenv + rw_prestamista.vldevatu;

		end if;

		if	(vr_vltotenv	> vr_vlmaximo) then

			if	(vr_contrcpf	is null) or
				(vr_contrcpf	<> rw_prestamista.nrcpfcgc) then

	              		vr_vlenviad := vr_vlmaximo;

			else

				vr_vlenviad := vr_vlmaximo - (vr_vltotenv - rw_prestamista.vldevatu);

			end if;

			vr_dscorpem	:= 'Ola, o contrato de emprestimo abaixo ultrapassou o valor limite maximo coberto pela seguradora, segue dados:<br /><br />
					Cooperativa: '			|| pr_nmrescop || '<br />
					Conta: '			|| rw_prestamista.nrdconta || '<br />
					Nome: '				|| rw_prestamista.nmprimtl || '<br />
					Contrato Empréstimo: '		|| rw_prestamista.nrctremp || '<br />
					Proposta seguro: '		|| rw_prestamista.nrctrseg || '<br />
					Valor Empréstimo: '		|| rw_prestamista.vldevatu || '<br />
					Valor saldo devedor total: '	|| rw_prestamista.saldo_cpf || '<br />
					Valor Limite Máximo: '		|| vr_vlmaximo;

			cecred.gene0003.pc_solicita_email(	pr_cdprogra	=> vr_cdprogra,
							pr_des_destino	=> vr_destinatario_email,
							pr_des_assunto	=> 'Valor limite maximo excedido ',
							pr_des_corpo	=> vr_dscorpem,
							pr_des_anexo	=> null,
							pr_flg_enviar	=> 'S',
							pr_des_erro	=> vr_dscritic);

			if	(vr_vlenviad	<= 0) then

				pc_finaliza_arquivo;

				continue;

			end if;

		end if;

		if	(vr_nrdeanos	> vr_tab_nrdeanos) then

			if	(vr_tpregist	= 1) then

				vr_tpregist	:= 0;
				pc_finaliza_arquivo;
				continue;

			elsif	(vr_tpregist	= 3) then

				vr_tpregist	:= 2;

			elsif	(vr_tpregist	= 2) then

				if	(vr_tpregist	<> rw_prestamista.tpregist) then

					vr_tpregist	:= 2;

				else

					pc_finaliza_arquivo;

					continue;

				end if;

			end if;

		elsif	(vr_nrdeanos	< 14) then

			vr_tpregist	:= 1;

			begin

				update	cecred.tbseg_prestamista a
				set	a.tpregist	= vr_tpregist
				where	a.rowid		= rw_prestamista.nr_linha_tbseg;

				cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v,
							' update	cecred.tbseg_prestamista a ' || chr(13) ||
							' set	a.tpregist	= ' || rw_prestamista.tpregist || chr(13) ||
							' where	a.rowid		= ' || chr(39) || rw_prestamista.nr_linha_tbseg || chr(39) || ';' || chr(13) || chr(13), FALSE);

			exception
			when	others then

				vr_dscritic	:= 'Erro ao atualizar tipo de registro(idade): ' || pr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || sqlerrm;
				raise		vr_exc_saida;

			end;

			pc_finaliza_arquivo;

			continue;

		end if;

		if	(vr_vlenviad	= 0) or
			(rw_prestamista.inliquid = 1) then

			if	(vr_tpregist	= 3) then

				vr_tpregist	:= 2;

			elsif	(rw_prestamista.tpregist	in (1,2)) then

				vr_tpregist	:= 0;

				begin

					update	cecred.tbseg_prestamista a
					set	a.tpregist	= vr_tpregist
					where	a.rowid		= rw_prestamista.nr_linha_tbseg;

					cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v,
								' update	cecred.tbseg_prestamista a ' || chr(13) ||
								' set	a.tpregist	= ' || rw_prestamista.tpregist || chr(13) ||
								' where	a.rowid		= ' || chr(39) || rw_prestamista.nr_linha_tbseg || chr(39) || ';' || chr(13) || chr(13), FALSE);

				exception
				when	others then

					vr_dscritic	:= 'Erro ao atualizar tipo de registro(idade): ' || pr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || sqlerrm;
					raise	vr_exc_saida;

				end;

				pc_finaliza_arquivo;

				continue;

			end if;

		end if;

		vr_vlprodvl	:= vr_vlenviad * (vr_pgtosegu/100);

		if	(vr_vlprodvl	< 0.01) then

			vr_vlprodvl	:= 0.01;

		end if;

		if	(vr_vlenviad	< 0.01) then

			vr_vlenviad	:= 0.01;

		end if;

		OPEN	cr_crawepr(	pr_cdcooper	=> rw_prestamista.cdcooper,
					pr_nrdconta	=> rw_prestamista.nrdconta,
					pr_nrctremp	=> rw_prestamista.nrctremp);
		FETCH	cr_crawepr INTO rw_crawepr;

			IF	(cr_crawepr%FOUND) and
				(rw_crawepr.dtvencto <> rw_prestamista.dtfimvig) THEN

				UPDATE	tbseg_prestamista p
				SET	p.dtinivig	= rw_crawepr.dtmvtolt,
					p.dtfimvig	= rw_crawepr.dtvencto
				WHERE	p.cdcooper	= rw_prestamista.cdcooper
				AND	p.nrdconta	= rw_prestamista.nrdconta
				AND	p.nrctrseg	= rw_prestamista.nrctrseg;

				UPDATE	crawseg w
				SET	w.dtinivig	= rw_crawepr.dtmvtolt,
					w.dtfimvig	= rw_crawepr.dtvencto
				WHERE	w.cdcooper	= rw_prestamista.cdcooper
				AND	w.nrdconta	= rw_prestamista.nrdconta
				AND	w.nrctrseg	= rw_prestamista.nrctrseg;

				UPDATE	crapseg p
				SET	p.dtinivig	= rw_crawepr.dtmvtolt,
					p.dtfimvig	= rw_crawepr.dtvencto
				WHERE	p.cdcooper	= rw_prestamista.cdcooper
				AND	p.nrdconta	= rw_prestamista.nrdconta
				AND	p.nrctrseg	= rw_prestamista.nrctrseg;

				vr_dtinivig	:= rw_crawepr.dtmvtolt;
				vr_dtfimvig	:= rw_crawepr.dtvencto;

			END IF;

		CLOSE cr_crawepr;

		vr_linha_txt	:= '';
		vr_linha_txt	:= vr_linha_txt || lpad(vr_seqtran, 5, 0);
		vr_linha_txt	:= vr_linha_txt || lpad(vr_tpregist, 2, 0);
		vr_linha_txt	:= vr_linha_txt || lpad(vr_apolice, 15, 0);
		vr_linha_txt	:= vr_linha_txt || rpad(to_char(rw_prestamista.nrcpfcgc,'fm00000000000'), 14, ' ');
		vr_linha_txt	:= vr_linha_txt || lpad(' ', 20, ' ');
		vr_linha_txt	:= vr_linha_txt || rpad(upper(cecred.gene0007.fn_caract_especial(rw_prestamista.nmprimtl)), 70, ' ');
		vr_linha_txt	:= vr_linha_txt || lpad(to_char(rw_prestamista.dtnasctl, 'YYYY-MM-DD'), 10, 0);
		vr_linha_txt	:= vr_linha_txt || lpad(rw_prestamista.cdsexotl, 2, 0);
		vr_linha_txt	:= vr_linha_txt || rpad(upper(cecred.gene0007.fn_caract_especial(nvl(rw_prestamista.dsendres,' '))), 60, ' ');
		vr_linha_txt	:= vr_linha_txt || rpad(upper(cecred.gene0007.fn_caract_especial(nvl(rw_prestamista.nmbairro,' '))), 30, ' ');
		vr_linha_txt	:= vr_linha_txt || rpad(upper(cecred.gene0007.fn_caract_especial(nvl(rw_prestamista.nmcidade,' '))), 30, ' ');
		vr_linha_txt	:= vr_linha_txt || rpad(nvl(to_char(rw_prestamista.cdufresd), ' '),2,' ');
		vr_linha_txt	:= vr_linha_txt || rpad(cecred.gene0002.fn_mask(rw_prestamista.nrcepend, 'zzzzz-zz9'), 10, ' ');

		if	(length(rw_prestamista.nrtelefo)	= 11) then

			vr_linha_txt	:= vr_linha_txt || rpad(cecred.gene0002.fn_mask(rw_prestamista.nrtelefo, '(99)99999-9999'), 15, ' ');

		elsif	(length(rw_prestamista.nrtelefo)	= 10) then

			vr_linha_txt	:= vr_linha_txt || rpad(cecred.gene0002.fn_mask(rw_prestamista.nrtelefo, '(99)9999-9999'), 15, ' ');

		else

			vr_linha_txt	:= vr_linha_txt || rpad(cecred.gene0002.fn_mask(rw_prestamista.nrtelefo, '99999-9999'), 15, ' ');

		end if;

		vr_linha_txt	:= vr_linha_txt || rpad(' ', 15, ' ');
		vr_linha_txt	:= vr_linha_txt || rpad(' ', 15, ' ');
		vr_dsdemail	:= rw_prestamista.dsdemail;

		cecred.segu0003.pc_limpa_email(vr_dsdemail);

		vr_linha_txt	:= vr_linha_txt || rpad(' ', 1, ' ');
		vr_linha_txt	:= vr_linha_txt || rpad(nvl(vr_dsdemail, ' '), 50, ' ');
		vr_linha_txt	:= vr_linha_txt || rpad(' ', 12, ' ');
		vr_linha_txt	:= vr_linha_txt || rpad(' ', 10, ' ');
		vr_linha_txt	:= vr_linha_txt || rpad( nvl(vr_nrproposta,0), 30, ' ');
		vr_linha_txt	:= vr_linha_txt || lpad(to_char(vr_dtdevend, 'YYYY-MM-DD'), 10, 0);
		vr_linha_txt	:= vr_linha_txt || lpad(to_char(vr_dtinivig, 'YYYY-MM-DD'), 10, 0);
		vr_linha_txt	:= vr_linha_txt || lpad(' ', 2, ' ');
		vr_linha_txt	:= vr_linha_txt || lpad(nvl(to_char(rw_prestamista.nrctremp), 0), 10, 0);
		vr_linha_txt	:= vr_linha_txt || lpad(' ', 10, ' ');
		vr_linha_txt	:= vr_linha_txt || lpad(' ', 10, ' ');
		vr_linha_txt	:= vr_linha_txt || lpad(' ', 10, ' ');
		vr_linha_txt	:= vr_linha_txt || lpad(' ', 10, ' ');
		vr_linha_txt	:= vr_linha_txt || rpad(lpad(rw_prestamista.cdcooper, 4, 0), 50, ' ');
		vr_linha_txt	:= vr_linha_txt || lpad(' ', 50, ' ');
		vr_linha_txt	:= vr_linha_txt || nvl(to_char(rw_prestamista.cdcobran), ' ');
		vr_linha_txt	:= vr_linha_txt || rpad(nvl(to_char(rw_prestamista.cdadmcob), ' '), 3, ' ');
		vr_linha_txt	:= vr_linha_txt || rpad(' ', 10, ' ');
		vr_linha_txt	:= vr_linha_txt || rpad(' ', 10, ' ');
		vr_linha_txt	:= vr_linha_txt || rpad(' ', 2, ' ');
		vr_linha_txt	:= vr_linha_txt || rpad(' ', 20, ' ');
		vr_linha_txt	:= vr_linha_txt || rpad(' ', 5, ' ');
		vr_linha_txt	:= vr_linha_txt || rpad(' ', 10, ' ');
		vr_linha_txt	:= vr_linha_txt || rpad(nvl(to_char(rw_prestamista.tpfrecob), ' '), 2, ' ');
		vr_linha_txt	:= vr_linha_txt || rpad(nvl(to_char(rw_prestamista.tpsegura), ' '), 2, ' ');
		vr_linha_txt	:= vr_linha_txt || nvl(to_char(rw_prestamista.cdcooperativa), ' ');
		vr_linha_txt	:= vr_linha_txt || nvl(to_char(rw_prestamista.cdplapro), ' ');
		vr_linha_txt	:= vr_linha_txt || lpad(replace(to_char(vr_vlprodvl,'fm99999990d00'), ',', '.'), 12, 0);
		vr_linha_txt	:= vr_linha_txt || lpad(nvl(to_char(rw_prestamista.tpcobran), ' '), 1, ' ');
		vr_linha_txt	:= vr_linha_txt || lpad(replace(to_char(vr_vlenviad,'fm999999999999990d00'), ',', '.'), 30, 0);
		vr_linha_txt	:= vr_linha_txt || lpad(to_char(vr_ultimoDia, 'YYYY-MM-DD'), 10, 0);
		vr_linha_txt	:= vr_linha_txt || lpad(to_char(vr_dtfimvig, 'YYYY-MM-DD'), 10, 0);
		vr_linha_txt	:= vr_linha_txt || rpad(' ', 20, ' ');
		vr_linha_txt	:= vr_linha_txt || lpad(' ', 50, ' ');
		vr_linha_txt	:= vr_linha_txt || lpad(' ', 50, ' ');
		vr_linha_txt	:= vr_linha_txt || lpad(' ', 50, ' ');
		vr_linha_txt	:= vr_linha_txt || lpad(' ', 50, ' ');
		vr_linha_txt	:= vr_linha_txt || lpad(' ', 50, ' ');
		vr_linha_txt	:= vr_linha_txt || lpad(' ', 50, ' ');
		vr_linha_txt	:= vr_linha_txt || lpad(' ', 50, ' ');
		vr_linha_txt	:= vr_linha_txt || lpad(' ', 50, ' ');
		vr_linha_txt	:= vr_linha_txt || lpad(' ', 50, ' ');
		vr_linha_txt	:= vr_linha_txt || lpad(' ', 89, ' ');
		vr_linha_txt	:= vr_linha_txt || lpad(' ', 15, ' ');
		vr_linha_txt	:= vr_linha_txt || rpad(' ', 30, ' ');
		vr_linha_txt	:= vr_linha_txt || rpad(' ', 15, ' ');
		vr_linha_txt	:= vr_linha_txt || lpad(' ', 3, ' ');
		vr_linha_txt	:= vr_linha_txt || rpad(' ', 30, ' ');
		vr_linha_txt	:= vr_linha_txt || rpad(' ', 15, ' ');
		vr_linha_txt	:= vr_linha_txt || lpad(' ', 3, ' ');
		vr_linha_txt	:= vr_linha_txt || rpad(' ', 30, ' ');
		vr_linha_txt	:= vr_linha_txt || rpad(' ', 15, ' ');
		vr_linha_txt	:= vr_linha_txt || lpad(' ', 3, ' ');
		vr_linha_txt	:= vr_linha_txt || rpad(' ', 30, ' ');
		vr_linha_txt	:= vr_linha_txt || rpad(' ', 15, ' ');
		vr_linha_txt	:= vr_linha_txt || lpad(' ', 3, ' ');
		vr_linha_txt	:= vr_linha_txt || chr(13);

		begin

			vr_index_815				:= vr_index_815 + 1;
			vr_tab_crrl815(vr_index_815).cdcooper	:= pr_cdcooper;
			vr_tab_crrl815(vr_index_815).dtmvtolt	:= pr_dtmvtolt;
			vr_tab_crrl815(vr_index_815).nmrescop	:= pr_nmrescop;
			vr_tab_crrl815(vr_index_815).nmprimtl	:= rw_prestamista.nmprimtl;
			vr_tab_crrl815(vr_index_815).nrdconta	:= rw_prestamista.nrdconta;
			vr_tab_crrl815(vr_index_815).cdagenci	:= rw_prestamista.cdagenci;          
			vr_tab_crrl815(vr_index_815).nrctrseg	:= vr_nrproposta;
			vr_tab_crrl815(vr_index_815).nrctremp	:= rw_prestamista.nrctremp;
			vr_tab_crrl815(vr_index_815).nrcpfcgc	:= rw_prestamista.nrcpfcgc;
			vr_tab_crrl815(vr_index_815).vlprodut	:= vr_vlprodvl;
			vr_tab_crrl815(vr_index_815).vlenviad	:= vr_vlenviad;
			vr_tab_crrl815(vr_index_815).vlsdeved	:= rw_prestamista.saldo_cpf;
			vr_tab_crrl815(vr_index_815).dtinivig	:= vr_dtinivig;
			vr_tab_crrl815(vr_index_815).dtrefcob	:= vr_ultimoDia;
			vr_tab_crrl815(vr_index_815).tpregist	:= vr_tpregist;

			if	(vr_tpregist	= 0) then

				vr_tab_crrl815(vr_index_815).dsregist	:= 'NOT FOUND';

			elsif	(vr_tpregist	= 1) then

				vr_tab_crrl815(vr_index_815).dsregist	:= 'ADESAO';

			elsif	(vr_tpregist	= 2) then

				vr_tab_crrl815(vr_index_815).dsregist	:= 'CANCELAMENTO';

			elsif	(vr_tpregist	= 3) then

				vr_tab_crrl815(vr_index_815).dsregist	:= 'ENDOSSO';

			end if;

		exception
		when	others then

			vr_dscritic	:= 'Erro na montagem do 815. Proposta: ' || vr_nrproposta || ' - Conta: ' || rw_prestamista.nrdconta || ' - Contrato: ' || rw_prestamista.nrctremp || ' - Apólice: ' || rw_prestamista.nrctrseg || ' - ' || sqlerrm;
			raise	vr_exc_saida;

		end;

		if	(vr_tpregist	= 1) then

			vr_tpregist	:= 3;

		end if;

		begin

			update	cecred.tbseg_prestamista a
			set	a.tpregist	= vr_tpregist,
				a.dtdenvio	= pr_dtmvtolt,
				a.vlprodut	= vr_vlprodvl,
				a.dtrefcob	= vr_ultimoDia,
				a.dtdevend	= rw_prestamista.dtdevend,
				a.dtfimvig	= vr_dtfimvig
			where	a.rowid		= rw_prestamista.nr_linha_tbseg;

			cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v,
						' update	cecred.tbseg_prestamista a ' || chr(13) ||
						' set	a.tpregist	= ' || rw_prestamista.tpregist || ', ' || chr(13) ||
						'	a.dtdenvio	= to_date(' || chr(39) || trim(to_char(rw_prestamista.dtdenvio,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' || chr(13) ||
						'	a.vlprodut	= ' || replace(trim(to_char(rw_prestamista.vlprodut)),',','.') || ', ' || chr(13) ||
						'	a.dtrefcob	= to_date(' || chr(39) || trim(to_char(rw_prestamista.dtrefcob,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' || chr(13) ||
						'	a.dtdevend	= to_date(' || chr(39) || trim(to_char(rw_prestamista.dtdevend,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || '), ' || chr(13) ||
						'	a.dtfimvig	= to_date(' || chr(39) || trim(to_char(rw_prestamista.dtfimvig,'dd/mm/yyyy')) || chr(39) || ',' || chr(39) || 'dd/mm/yyyy' || chr(39) || ') ' || chr(13) ||
						' where	a.rowid		= ' || chr(39) || rw_prestamista.nr_linha_tbseg || chr(39) || ';' || chr(13) || chr(13), FALSE);

		exception
		when	others then

			vr_dscritic	:= 'Erro ao atualizar saldo do contrato: ' || pr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || sqlerrm;
			raise	vr_exc_saida;

		end;

		if	(vr_tpregist	= 2) then

			begin

				update	cecred.crapseg c
				set	c.cdsitseg	= vr_tpregist
				where	c.rowid		= rw_prestamista.nr_linha_crapseg;

				cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v,
						' update	cecred.crapseg a ' || chr(13) ||
						' set	a.cdsitseg	= ' || rw_prestamista.cdsitseg || chr(13) ||
						' where	a.rowid		= ' || chr(39) || rw_prestamista.nr_linha_crapseg || chr(39) || ';' || chr(13) || chr(13), FALSE);

			exception
			when	others then

				vr_dscritic	:= 'Erro ao cancelar seguro prestamista: ' || pr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || sqlerrm;
				raise	vr_exc_saida;

			end;

		end if;

		cecred.gene0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_linha_txt);

		vr_seqtran	:= vr_seqtran + 1;

		pc_finaliza_arquivo;

	end loop;

	vr_crrl815	:= vr_tab_crrl815;
	vr_tab_ctrl_prst.delete;

	cecred.gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo);

	cecred.gene0003.pc_converte_arquivo(	pr_cdcooper	=> pr_cdcooper,
					pr_nmarquiv	=> pr_diretorio || '/arq/' || vr_nmarquiv,
					pr_nmarqenv	=> vr_nmarquiv,
					pr_des_erro	=> vr_dscritic);

	if	(vr_dscritic	is not null) then

		cecred.gene0002.pc_escreve_xml(ds_dados_rollback_v,
					ds_texto_rollback_v,
					'LOG: falha mapeada ao atualizar registro:' || chr(13) ||
					'Crítica: ' || vr_dscritic || chr(13) || chr(13), false);

		raise	vr_exc_saida;

	end if;

exception
when	vr_exc_saida then

	pr_dscritic	:= vr_dscritic || SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;

when	others then

	vr_dscritic	:= SQLERRM || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
	pr_dscritic	:= vr_dscritic;

end pc_gera_arquivo_coop;

begin

if	(upper(cecred.gene0001.fn_database_name) like '%AYLLOSP%' or upper(cecred.gene0001.fn_database_name) like '%AILOSTS%') then

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

	ds_nome_diretorio_v	:= ds_nome_diretorio_v || 'cpd/bacas/INC0197686';

else

	ds_nome_diretorio_v	:= cecred.gene0001.fn_diretorio(	pr_tpdireto => 'C',
								pr_cdcooper => 3);

	ds_nome_diretorio_v	:= ds_nome_diretorio_v || '/INC0197686';

end if;
 
valida_diretorio_p(	ds_nome_diretorio_p	=> ds_nome_diretorio_v,
			ds_critica_p		=> ds_critica_v);

if	(trim(ds_critica_v) is not null) then

	raise ds_exc_erro_v;

end if;

vr_ultimoDia	:= trunc(sysdate,'month') - 1;

for	r05 in c05 loop

	ds_critica_v	:= null;
	qt_reg_arquivo	:= 10000;

	vr_tab_crrl815.delete;
	vr_crrl815.delete;
	vr_totais.delete;
	vr_tab_lancarq_815.delete;

	pc_gera_arquivo_coop(	pr_cdcooper	=> r05.cdcooper,
				pr_diretorio	=> ds_nome_diretorio_v,
				pr_nmrescop	=> r05.nmrescop,
				pr_dtmvtolt	=> r05.dtmvtolt,
				pr_dscritic	=> ds_critica_v);

	if	(ds_critica_v	is null) then

		if	(qt_reg_arquivo	<> 10000) then

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
								pr_des_erro	=> ds_critica_rollback_v);

			if	(trim(ds_critica_rollback_v) is not null) then

				ds_critica_v	:= ds_critica_v || '-' || ds_critica_rollback_v;

				raise	ds_exc_erro_v;

			end if;

			dbms_lob.close(ds_dados_rollback_v);
			dbms_lob.freetemporary(ds_dados_rollback_v);

		end if;

		commit;

	else

		ds_critica_arq_v	:= substr(ds_critica_arq_v || ' - Coop: ' || r05.cdcooper || ' - ' || ds_critica_v || chr(13),1,1000);

	end if;

	vr_index_815	:= 0;

	dbms_lob.createtemporary(vr_des_xml, TRUE);
	dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
	vr_vltotarq	:= 0;
	vr_tab_sldevpac.delete;

	pc_escreve_xml_rel('<?xml version="1.0" encoding="utf-8"?><crrl815><dados>');
	vr_index_815	:= vr_crrl815.first;

	while	(vr_index_815	is not null) loop

		if	(vr_crrl815(vr_index_815).vlenviad	is null) then

			vr_vlenviad	:= 0;

		else

			vr_vlenviad	:= vr_crrl815(vr_index_815).vlenviad;

		end if;

		pc_escreve_xml_rel(	'<registro>' ||
						'<dtmvtolt>' || TO_CHAR(vr_crrl815(vr_index_815).dtmvtolt , 'DD/MM/RRRR') || '</dtmvtolt>' ||
						'<nmrescop>' || vr_crrl815(vr_index_815).nmrescop || '</nmrescop>' ||
						'<nmprimtl>' || vr_crrl815(vr_index_815).nmprimtl || '</nmprimtl>' ||
						'<nrdconta>' || TRIM(gene0002.fn_mask_conta(vr_crrl815(vr_index_815).nrdconta)) || '</nrdconta>' ||
						'<cdagenci>' || TO_CHAR(vr_crrl815(vr_index_815).cdagenci)  || '</cdagenci>' ||
						'<nrctrseg>' || TRIM(vr_crrl815(vr_index_815).nrctrseg) || '</nrctrseg>' ||
						'<nrctremp>' || TRIM(gene0002.fn_mask_contrato(vr_crrl815(vr_index_815).nrctremp)) || '</nrctremp>' ||
						'<nrcpfcgc>' || TRIM(gene0002.fn_mask_cpf_cnpj(vr_crrl815(vr_index_815).nrcpfcgc, 1)) || '</nrcpfcgc>' ||
						'<vlprodut>' || to_char(vr_crrl815(vr_index_815).vlprodut, 'FM99G999G999G999G999G999G999G990D00') || '</vlprodut>' ||
						'<vlenviad>' || to_char(vr_vlenviad, 'FM99G999G999G999G999G999G999G990D00') || '</vlenviad>' ||
						'<vlsdeved>' || to_char(vr_crrl815(vr_index_815).vlsdeved, 'FM99G999G999G999G999G999G999G990D00') || '</vlsdeved>' ||
						'<dtrefcob>' || NVL(TO_CHAR( vr_crrl815(vr_index_815).dtrefcob, 'DD/MM/RRRR') , '') || '</dtrefcob>' ||
						'<dsregist>' || vr_crrl815(vr_index_815).dsregist || '</dsregist>' ||
						'<dtinivig>' || NVL(TO_CHAR( vr_crrl815(vr_index_815).dtinivig , 'DD/MM/RRRR') , '') || '</dtinivig>' ||
					'</registro>');

		vr_dsadesao	:= vr_crrl815(vr_index_815).dsregist;

		if	(not vr_tab_sldevpac.EXISTS(vr_crrl815(vr_index_815).cdagenci)) then

			vr_tab_sldevpac(vr_crrl815(vr_index_815).cdagenci).slddeved	:= 0;
			vr_tab_sldevpac(vr_crrl815(vr_index_815).cdagenci).vlpremio	:= 0;

		end if;

		vr_tab_sldevpac(vr_crrl815(vr_index_815).cdagenci).slddeved	:= vr_tab_sldevpac(vr_crrl815(vr_index_815).cdagenci).slddeved + vr_vlenviad;
		vr_vltotarq	:= vr_vltotarq + vr_vlenviad;

		if	(not vr_totais.EXISTS(vr_dsadesao)) then

			vr_totais(vr_dsadesao).qtdadesao	:= 1;
			vr_totais(vr_dsadesao).slddeved		:= vr_vlenviad;
			vr_totais(vr_dsadesao).vlpremio		:= vr_crrl815(vr_index_815).vlprodut;
			vr_totais(vr_dsadesao).dsadesao		:= vr_dsadesao;

		else

			vr_totais(vr_dsadesao).slddeved		:= vr_totais(vr_dsadesao).slddeved + vr_vlenviad;
			vr_totais(vr_dsadesao).vlpremio		:= vr_totais(vr_dsadesao).vlpremio + vr_crrl815(vr_index_815).vlprodut;
			vr_totais(vr_dsadesao).qtdadesao	:= vr_totais(vr_dsadesao).qtdadesao + 1;

		end if;

		vr_vltotdiv815							:= vr_vltotdiv815 + vr_crrl815(vr_index_815).vlprodut;
		vr_tab_sldevpac(vr_crrl815(vr_index_815).cdagenci).vlpremio	:= vr_tab_sldevpac(vr_crrl815(vr_index_815).cdagenci).vlpremio + vr_crrl815(vr_index_815).vlprodut;
		vr_index_815							:= vr_crrl815.next(vr_index_815);
		vr_flgachou							:= TRUE;

	end loop;

	pc_escreve_xml_rel('</dados>');
	pc_escreve_xml_rel('<totais>');
	vr_index	:= vr_totais.first;
	vr_index_815	:= 0;

	while	(vr_index	is not null) loop

		if	(vr_totais.EXISTS(vr_index)) then

			pc_escreve_xml_rel(	'<registro>'||
							'<dsadesao>' || NVL(vr_totais(vr_index).dsadesao, ' ') || '</dsadesao>' ||
							'<vlpremio>' || to_char(NVL(vr_totais(vr_index).vlpremio, '0'), 'FM99G999G999G999G999G999G999G990D00') || '</vlpremio>' ||
							'<slddeved>' || to_char(NVL(vr_totais(vr_index).slddeved, '0'), 'FM99G999G999G999G999G999G999G990D00') || '</slddeved>' ||
							'<qtdadesao>' || NVL(vr_totais(vr_index).qtdadesao, 0) || '</qtdadesao>'||
						'</registro>');

		end if;

		vr_index	:= vr_totais.next(vr_index);

	end loop;

	vr_index	:= null;

	pc_escreve_xml_rel(  '</totais>');

	if	(vr_flgachou) then

		pc_escreve_xml_rel('<totpac vltotdiv="'||to_char(vr_vltotarq,'fm999g999g999g990d00')||   '">');

		if	(vr_tab_sldevpac.COUNT	> 0) then

			for	vr_cdagenci	in vr_tab_sldevpac.FIRST..vr_tab_sldevpac.LAST loop

				if	(vr_tab_sldevpac.EXISTS(vr_cdagenci)) then

					pc_escreve_xml_rel(	'<registro>' ||
									'<cdagenci>' || LPAD(vr_cdagenci,3,' ') || '</cdagenci>' ||
									'<sldevpac>' || to_char(vr_tab_sldevpac(vr_cdagenci).slddeved,'fm999g999g999g990d00') || '</sldevpac>' ||
								'</registro>');

					vr_tab_lancarq_815(vr_cdagenci) := vr_tab_sldevpac(vr_cdagenci).vlpremio;

				end if;

			end loop;

			pc_escreve_xml_rel(	'</totpac>');

		end if;

	end if;

	pc_escreve_xml_rel('</crrl815>');

	if	(vr_crrl815.EXISTS(1)) then

		cecred.gene0002.pc_solicita_relato(	pr_cdcooper	=> r05.cdcooper,
						pr_cdprogra	=> vr_cdprogra,
						pr_dtmvtolt	=> r05.dtmvtolt,
						pr_dsxml	=> vr_des_xml,
						pr_dsxmlnode	=> '/crrl815',
						pr_dsjasper	=> 'crrl815.jasper',
						pr_dsparams	=> NULL,
						pr_dsarqsaid	=> ds_nome_diretorio_v || '/crrl815.lst',
						pr_cdrelato	=> 815,
						pr_flg_gerar	=> 'S',
						pr_qtcoluna	=> 234,
						pr_sqcabrel	=> 1,
						pr_nmformul	=> '234col',
						pr_flg_impri	=> 'S',
						pr_nrcopias	=> 1,
						pr_nrvergrl	=> 1,
						pr_des_erro	=> ds_critica_v);

		if	(ds_critica_v	is not null) then

			raise	ds_exc_erro_v;

		end if;

	end if;

	dbms_lob.close(vr_des_xml);
	dbms_lob.freetemporary(vr_des_xml);

	vr_dtmvtolt_yymmdd	:= to_char(vr_ultimodia, 'yyyymmdd');
	vr_linhadet		:= '';

	cecred.gene0001.pc_abre_arquivo(	pr_nmdireto	=> ds_nome_diretorio_v || '/contab/',
					pr_nmarquiv	=> vr_dtmvtolt_yymmdd||'_'||lpad(r05.cdcooper,2,0)||'_PRESTAMISTA.txt',
					pr_tipabert	=> 'W',
					pr_utlfileh	=> vr_arquivo_txt,
					pr_des_erro	=> ds_critica_v);

	if	(ds_critica_v	is not null) then

		raise	ds_exc_erro_v;

	end if;

	if	(vr_tab_lancarq_815.count	> 0) then

		    SELECT nmsegura INTO vr_nmsegura FROM crapcsg WHERE cdcooper = r05.cdcooper AND cdsegura = 514; 

		vr_idx_lancarq	:= vr_tab_lancarq_815.first;
		vr_linhadet	:= TRIM(vr_dtmvtolt_yymmdd) || ',' ||
				TRIM(to_char(vr_ultimodia,'ddmmyy')) ||
				',8304,4963,' ||
                                 TRIM(to_char(vr_vltotdiv815,'FM99999999999999990D90', 'NLS_NUMERIC_CHARACTERS = ''.,'''))||
                                 ',5210,'||
                                 '"VLR. REF. PROVISAO P/ PAGAMENTO DE SEGURO PRESTAMISTA - '|| vr_nmsegura ||' - REF. ' 
                                 || to_CHAR(vr_ultimodia,'MM/YYYY') ||'"';

		cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);
             
             WHILE vr_idx_lancarq IS NOT NULL LOOP                      
                vr_linhadet := lpad(vr_idx_lancarq,3,0) || ',' || 
                    TRIM(to_char(round(vr_tab_lancarq_815(vr_idx_lancarq),2),'FM99999999999999990D90', 'NLS_NUMERIC_CHARACTERS = ''.,''')); 
                    
                cecred.gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);                        
                vr_idx_lancarq := vr_tab_lancarq_815.next(vr_idx_lancarq);             
             END LOOP;           
          END IF;

          cecred.gene0001.pc_fecha_arquivo(vr_arquivo_txt);      

end loop;

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