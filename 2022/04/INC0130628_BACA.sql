begin

declare

ds_exc_erro_v		exception;
ds_erro_registro_v	exception;
cd_critica_v		crapcri.cdcritic%type;
ds_critica_v		crapcri.dscritic%type;
ds_critica_rollback_v	crapcri.dscritic%type;
ds_critica_arq_v	crapcri.dscritic%type;

ds_dados_rollback_v	clob			:= null;
ds_texto_rollback_v	varchar2(32600);
nm_arquivo_rollback_v	varchar2(100);

cd_cooperativa_v	crapcop.cdcooper%type	:= 3;
ds_nome_diretorio_v	crapprm.dsvlrprm%type;

qt_reg_commit		number(10)	:= 0;
nr_arquivo		number(10)	:= 1;
qt_reg_arquivo		number(10)	:= 50000;

vr_nrctrseg		crapseg.nrctrseg%type;
vr_flgdps		varchar2(1)		:= 'N';
vr_vlproposta		crawseg.vlseguro%type;
vr_flgprestamista	varchar2(1)		:= 'N';
vr_dsmotcan		varchar2(60);

type	typ_reg_ctrl_coop is
	record(	cdcooper	crapcop.cdcooper%type);  

type	typ_tab_ctrl_coop is
	table of	typ_reg_ctrl_coop
	index by	varchar2(10);

vr_tab_ctrl_coop	typ_tab_ctrl_coop;

cursor	c01 is
select	a.cdcooper,
	a.nrdconta,
	a.nrctremp,
	c.cdagenci,
	c.cdoperad,
	a.nrproposta
from	crapseg c,
	crawseg b,
	tbseg_prestamista a
where	not exists
	(select	1
	from	crapseg	y,
		crawseg x
	where	y.cdsitseg	= 1
	and	x.nrctrseg	= y.nrctrseg
	and	x.nrdconta	= y.nrdconta
	and	x.cdcooper	= y.cdcooper
	and	x.nrctrato	= a.nrctremp
	and	x.nrdconta	= a.nrdconta
	and	x.cdcooper	= a.cdcooper)
and	c.cdsitseg		= 5
and	c.tpseguro		= 4
and	b.nrctrseg		= c.nrctrseg
and	b.nrdconta		= c.nrdconta
and	b.cdcooper		= c.cdcooper
and	a.nrproposta		= b.nrproposta
and	a.nrctrseg		= b.nrctrseg
and	a.nrdconta		= b.nrdconta
and	a.cdcooper		= b.cdcooper
and	trim(a.tprecusa)	is not null
and	nvl(a.cdmotrec,0)	<> 0
and	a.dtrecusa		is not null
and	a.nrproposta		in
	('770358812341',
'770359647573',
'770359140193',
'770354048906',
'770357910013',
'770357371082',
'770354360420',
'770358733239',
'770358689515',
'770354109379',
'770352007668',
'770355212963',
'770357878900',
'770354537028',
'770351690070',
'770358754490',
'770351350903',
'770353480790',
'770358823831',
'770355943755',
'770354929937',
'770354929929',
'770351031751',
'770359007540',
'770355151697',
'770351043601',
'770351323787',
'770359292058',
'770351321393',
'770358735495',
'770353648225',
'770349693631',
'770351156368',
'770359812981',
'770358230890',
'770359701616',
'770358424694',
'770351350962',
'770350780947',
'770359968965',
'770354498090',
'770359814178',
'770358765190',
'770358504400',
'770357325366',
'770357002940',
'770353548921',
'770354428342',
'770359257180',
'770359331053',
'770354317508',
'770356438671',
'770352833924',
'770351320087',
'770352260053',
'770351322446',
'770359975589',
'770359970218',
'770349759519',
'770355587150',
'770350899456',
'770359641095',
'770358816410',
'770355658872',
'770351656255',
'770358713777',
'770358241077',
'770358750869',
'770352474592',
'770359588895',
'770351912405');

cursor	c02(	pr_nrctrseg	crapseg.nrctrseg%type,
		pr_nrctremp	tbseg_prestamista.nrctremp%type,
		pr_cdcooper	tbseg_prestamista.cdcooper%type,
		pr_nrdconta	tbseg_prestamista.nrdconta%type) is
select	a.rowid as nr_linha_crawseg
from	crawseg a
where	(
		a.nrctrseg = pr_nrctrseg or
		(
			pr_nrctrseg is null and 
			a.dtmvtolt =
			(select	max(x.dtmvtolt)
			from	crapdat x
			where	x.cdcooper	= a.cdcooper) and
			not exists
			(select	1
			from	crapseg x
			where	x.tpseguro	= 4
			and	x.nrctrseg	= a.nrctrseg
			and	x.nrdconta	= a.nrdconta
			and	x.cdcooper	= a.cdcooper)
		)
	)
and	a.nrdconta	= pr_nrdconta
and	a.cdcooper	= pr_cdcooper
and	a.nrctrato	= pr_nrctremp;

cursor	c03(	pr_nrctrseg	crapseg.nrctrseg%type,
		pr_cdcooper	tbseg_prestamista.cdcooper%type,
		pr_nrdconta	tbseg_prestamista.nrdconta%type) is
select	a.rowid nr_linha_crapseg
from	crapseg a
where	a.tpseguro	= 4
and	a.nrdconta	= pr_nrdconta
and	a.cdcooper	= pr_cdcooper
and	a.nrctrseg	= pr_nrctrseg;

cursor	c04(	pr_nrctrseg	crapseg.nrctrseg%type,
		pr_nrctremp	tbseg_prestamista.nrctremp%type,
		pr_cdcooper	tbseg_prestamista.cdcooper%type,
		pr_nrdconta	tbseg_prestamista.nrdconta%type) is
select	a.rowid nr_linha_tbseg
from	tbseg_prestamista a
where	a.nrctrseg	= pr_nrctrseg
and	a.nrdconta	= pr_nrdconta
and	a.cdcooper	= pr_cdcooper
and	a.nrctremp	= pr_nrctremp;

cursor	c05 is
select	a.cdcooper,
	a.nmrescop
from	crapcop a;

procedure valida_diretorio_p(	ds_nome_diretorio_p	in	varchar2,
				ds_critica_p		out	crapcri.dscritic%TYPE) is

ds_critica_v	crapcri.dscritic%type;
ie_tipo_saida_v	varchar2(3);
ds_saida_v	varchar2(1000);
   
begin

	if	(gene0001.fn_exis_diretorio(ds_nome_diretorio_p)) then

		ds_critica_p	:= null;

	else

		gene0001.pc_OSCommand_Shell(	pr_des_comando	=> 'mkdir ' || ds_nome_diretorio_p || ' 1> /dev/null',
						pr_typ_saida	=> ie_tipo_saida_v,
						pr_des_saida	=> ds_saida_v);

		if	(ie_tipo_saida_v	= 'ERR') then

			ds_critica_v	:= 'CRIAR DIRETORIO ARQUIVO -> Nao foi possivel criar o diretorio para gerar os arquivos. ' || ds_saida_v;
			raise		ds_exc_erro_v;

		end if;

		gene0001.pc_OSCommand_Shell(	pr_des_comando	=> 'chmod 777 ' || ds_nome_diretorio_p || ' 1> /dev/null',
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

procedure	pc_gera_arquivo_coop(	pr_cdcooper	in crapcop.cdcooper%type,
					pr_diretorio	in crapprm.dsvlrprm%type,
					pr_nmrescop	in crapcop.nmrescop%type,
					pr_dscritic	out varchar2) is

vr_cdprogra		crapprg.cdprogra%type	:= 'BACA_PRST';
vr_tab_nrdeanos		pls_integer;
vr_dscritic		varchar2(4000);
dtmvtolt_v		crapdat.dtmvtolt%type;
vr_index		varchar2(50);
vr_vlenviad		number;
vr_destinatario_email	varchar2(500)		:= gene0001.fn_param_sistema('CRED', 0, 'ENVIA_SEG_PRST_EMAIL');
vr_exc_saida		exception;
vr_nrsequen		number(5);
vr_seqtran		integer			:= 1;
vr_vlminimo		number;
vr_tpregist		integer;
vr_nrdmeses		number;
vr_contrcpf		tbseg_prestamista.nrcpfcgc%type;
vr_vltotenv		number;
vr_vlmaximo		number;
vr_dscorpem		varchar2(2000);
vr_apolice		varchar2(20);
vr_nmarquiv		varchar2(100);
vr_linha_txt		varchar2(32600);
vr_ultimoDia		date;
vr_pgtosegu		number;
vr_vlprodvl		number;
vr_dtfimvig		date;
vr_dtcalcidade		date;
vr_dstextab		varchar2(400);
vr_nrdeanos		pls_integer;
vr_dsdidade		varchar2(50);
vr_dsdemail		varchar2(100);
        
type	typ_reg_ctrl_prst is
	record(	nrcpfcgc	tbseg_prestamista.nrcpfcgc%type,
		nrctremp	tbseg_prestamista.nrctremp%type);  

type	typ_tab_ctrl_prst is
	table of	typ_reg_ctrl_prst
	index by	varchar2(40);

vr_tab_ctrl_prst	typ_tab_ctrl_prst;
        
vr_ind_arquivo		utl_file.file_type;
        
cursor	cr_craptsg(	pr_cdcooper	crapcop.cdcooper%type,
			pr_cdsegura	craptsg.cdsegura%type) is
select	a.nrtabela
from	craptsg a
where	a.cdcooper	= pr_cdcooper
and	a.tpseguro	= 4
and	a.tpplaseg	= 1
and	a.cdsegura	= pr_cdsegura;

cursor	cr_prestamista(	pr_cdcooper IN crapcop.cdcooper%type,
			pr_dtmvtolt IN crapdat.dtmvtolt%type) is
select	p.rowid as nr_linha_tbseg,
	ap.rowid as nr_linha_crapseg,
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
	add_months(c.dtmvtolt, c.qtpreemp) dtfimctr
from	tbseg_prestamista p,
	crapepr c,
	crapass ass,
	crawseg aw,
	crapseg ap,
	tbseg_prestamista po
where	p.cdcooper		= pr_cdcooper
and	c.cdcooper		= p.cdcooper
and	c.nrdconta		= p.nrdconta
and	c.nrctremp		= p.nrctremp
and	ass.cdcooper		= c.cdcooper
and	ass.nrdconta		= c.nrdconta
and	trunc(ap.dtmvtolt)	= pr_dtmvtolt
and	ap.cdsitseg		= 1
and	aw.nrctrseg		= ap.nrctrseg
and	aw.nrdconta		= ap.nrdconta
and	aw.cdcooper		= ap.cdcooper
and	p.nrproposta		= aw.nrproposta
and	p.nrctrseg		= aw.nrctrseg
and	p.nrctremp		= aw.nrctrato
and	p.nrdconta		= aw.nrdconta
and	p.cdcooper		= aw.cdcooper
and	p.tpregist		= 1
and	trim(p.tprecusa)	is null
and	nvl(p.cdmotrec,0)	= 0
and	p.dtrecusa		is null
and	po.nrctremp		= p.nrctremp
and	po.nrdconta		= p.nrdconta
and	po.cdcooper		= p.cdcooper
and	po.nrproposta in
	('770358812341',
'770359647573',
'770359140193',
'770354048906',
'770357910013',
'770357371082',
'770354360420',
'770358733239',
'770358689515',
'770354109379',
'770352007668',
'770355212963',
'770357878900',
'770354537028',
'770351690070',
'770358754490',
'770351350903',
'770353480790',
'770358823831',
'770355943755',
'770354929937',
'770354929929',
'770351031751',
'770359007540',
'770355151697',
'770351043601',
'770351323787',
'770359292058',
'770351321393',
'770358735495',
'770353648225',
'770349693631',
'770351156368',
'770359812981',
'770358230890',
'770359701616',
'770358424694',
'770351350962',
'770350780947',
'770359968965',
'770354498090',
'770359814178',
'770358765190',
'770358504400',
'770357325366',
'770357002940',
'770353548921',
'770354428342',
'770359257180',
'770359331053',
'770354317508',
'770356438671',
'770352833924',
'770351320087',
'770352260053',
'770351322446',
'770359975589',
'770359970218',
'770349759519',
'770355587150',
'770350899456',
'770359641095',
'770358816410',
'770355658872',
'770351656255',
'770358713777',
'770358241077',
'770358750869',
'770352474592',
'770359588895',
'770351912405')
order by	p.nrcpfcgc asc,
	p.cdapolic;

rw_prestamista	cr_prestamista%rowtype;

begin     

	vr_dstextab	:= tabe0001.fn_busca_dstextab(	pr_cdcooper	=> pr_cdcooper,
							pr_nmsistem	=> 'CRED',
							pr_tptabela	=> 'USUARI',
							pr_cdempres	=> 11,
							pr_cdacesso	=> 'SEGPRESTAM',
							pr_tpregist	=> 0);

	if	(vr_dstextab	is null) then

		vr_vlminimo	:= 0;

	else

		vr_vlminimo	:= gene0002.fn_char_para_number(SUBSTR(vr_dstextab, 27, 12));
		vr_vlmaximo	:= gene0002.fn_char_para_number(SUBSTR(vr_dstextab,14,12));

	end if;
          
	vr_nrsequen	:= to_number(substr(vr_dstextab, 139, 5)) + 1;
	vr_apolice	:= substr(vr_dstextab,146,16);
	vr_pgtosegu	:= gene0002.fn_char_para_number(SUBSTR(vr_dstextab,51,7));
          
	begin

		update	craptab a
		set	a.dstextab	= substr(a.dstextab, 1, 138) ||
					gene0002.fn_mask(vr_nrsequen, '99999') ||
					substr(a.dstextab, 144)
		where	a.cdcooper	= pr_cdcooper
		and	a.nmsistem	= 'CRED'
		and	a.tptabela	= 'USUARI'
		and	a.cdempres	= 11
		and	a.cdacesso	= 'SEGPRESTAM'
		and	a.tpregist	= 0;

	exception
	when	others then

		vr_dscritic	:= 'Erro ao atualizar sequencia da cooperativa: ' || pr_cdcooper || ' - ' || sqlerrm;
		raise	vr_exc_saida;

	end;

	vr_ultimoDia	:= trunc(sysdate,'month') - 1;
	vr_dtcalcidade	:= to_date(add_months(vr_ultimoDia,-1),'dd/mm/rrrr');

        vr_nmarquiv	:= 'AILOS_' || replace(pr_nmrescop,' ','_') || '_' ||
			replace(to_char(vr_ultimoDia , 'MM/YYYY'), '/', '_') || '_' ||
			gene0002.fn_mask(vr_nrsequen, '99999') || '.txt';

	gene0001.pc_abre_arquivo(	pr_nmdireto	=> pr_diretorio || '/arq/',
					pr_nmarquiv	=> vr_nmarquiv,
					pr_tipabert	=> 'W',
					pr_utlfileh	=> vr_ind_arquivo,
					pr_des_erro	=> vr_dscritic);

	if	(vr_dscritic	is not null) then

		raise	vr_exc_saida;

	end if;
      
	open	cr_craptsg(	pr_cdcooper	=> pr_cdcooper,
				pr_cdsegura	=> segu0001.busca_seguradora);
	fetch	cr_craptsg
	into	vr_tab_nrdeanos;

	if	(cr_craptsg%notfound) then

		vr_tab_nrdeanos	:= 0;

	end if;

	close	cr_craptsg;

	select	trunc(max(a.dtmvtolt))
	into	dtmvtolt_v
	from	crapdat a
	where	a.cdcooper	= pr_cdcooper;

	for	rw_prestamista in
		cr_prestamista(	pr_cdcooper	=> pr_cdcooper,
				pr_dtmvtolt	=> dtmvtolt_v) loop

		vr_tpregist	:= rw_prestamista.tpregist;
		vr_dtfimvig	:= nvl(rw_prestamista.dtfimvig,rw_prestamista.dtfimctr);

		cada0001.pc_busca_idade(	pr_dtnasctl	=> rw_prestamista.dtnasctl,
						pr_dtmvtolt	=> vr_dtcalcidade,
						pr_flcomple	=> 1,
						pr_nrdeanos	=> vr_nrdeanos,
						pr_nrdmeses	=> vr_nrdmeses,
						pr_dsdidade	=> vr_dsdidade,
						pr_des_erro	=> vr_dscritic);

		if	(rw_prestamista.saldo_cpf	< vr_vlminimo) then

			begin

				update	tbseg_prestamista a
				set	a.dtdenvio	= dtmvtolt_v
				where	a.rowid		= rw_prestamista.nr_linha_tbseg;

			exception
			when	others then

				vr_dscritic	:= 'Erro ao atualizar saldo do contrato: ' || pr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || sqlerrm;
				raise	vr_exc_saida;

			end;

			continue;

		end if;

		if	(vr_tab_ctrl_prst.EXISTS(rw_prestamista.nrcpfcgc || rw_prestamista.nrctremp)) then

			vr_tpregist	:= 0;

			begin

				update	tbseg_prestamista a
				set	a.tpregist	= vr_tpregist
				where	a.rowid		= rw_prestamista.nr_linha_tbseg;

			exception
			when	others then

				vr_dscritic	:= 'Erro ao atualizar tipo de registro(idade): ' || pr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || sqlerrm;
				raise	vr_exc_saida;

			end;

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

			gene0003.pc_solicita_email(	pr_cdprogra	=> vr_cdprogra,
							pr_des_destino	=> vr_destinatario_email,
							pr_des_assunto	=> 'Valor limite maximo excedido ',
							pr_des_corpo	=> vr_dscorpem,
							pr_des_anexo	=> null,
							pr_flg_enviar	=> 'S',
							pr_des_erro	=> vr_dscritic);

			if	(vr_vlenviad	<= 0) then

				continue;

			end if;

		end if;

		if	(vr_nrdeanos	> vr_tab_nrdeanos) then

			if	(vr_tpregist	= 1) then

				vr_tpregist	:= 0;
				continue;

			elsif	(vr_tpregist	= 3) then

				vr_tpregist	:= 2;

			elsif	(vr_tpregist	= 2) then

				if	(vr_tpregist	<> rw_prestamista.tpregist) then

					vr_tpregist	:= 2;

				else

					continue;

				end if;

			end if;

		elsif	(vr_nrdeanos	< 14) then

			vr_tpregist	:= 1;

			begin

				update	tbseg_prestamista a
				set	a.tpregist	= vr_tpregist
				where	a.rowid		= rw_prestamista.nr_linha_tbseg;

			exception
			when	others then

				vr_dscritic	:= 'Erro ao atualizar tipo de registro(idade): ' || pr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || sqlerrm;
				raise		vr_exc_saida;

			end;

			continue;

		end if;

		if	(vr_vlenviad	= 0) or
			(rw_prestamista.inliquid = 1) then

			if	(vr_tpregist	= 3) then

				vr_tpregist	:= 2;

			elsif	(rw_prestamista.tpregist	in (1,2)) then

				vr_tpregist	:= 0;

				begin

					update	tbseg_prestamista a
					set	a.tpregist	= vr_tpregist
					where	a.rowid		= rw_prestamista.nr_linha_tbseg;

				exception
				when	others then

					vr_dscritic	:= 'Erro ao atualizar tipo de registro(idade): ' || pr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || sqlerrm;
					raise	vr_exc_saida;

				end;

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

		vr_linha_txt	:= '';
		vr_linha_txt	:= vr_linha_txt || lpad(vr_seqtran, 5, 0);
		vr_linha_txt	:= vr_linha_txt || lpad(vr_tpregist, 2, 0);
		vr_linha_txt	:= vr_linha_txt || lpad(vr_apolice, 15, 0);
		vr_linha_txt	:= vr_linha_txt || rpad(to_char(rw_prestamista.nrcpfcgc,'fm00000000000'), 14, ' ');
		vr_linha_txt	:= vr_linha_txt || lpad(' ', 20, ' ');
		vr_linha_txt	:= vr_linha_txt || rpad(upper(gene0007.fn_caract_especial(rw_prestamista.nmprimtl)), 70, ' ');
		vr_linha_txt	:= vr_linha_txt || lpad(to_char(rw_prestamista.dtnasctl, 'YYYY-MM-DD'), 10, 0);
		vr_linha_txt	:= vr_linha_txt || lpad(rw_prestamista.cdsexotl, 2, 0);
		vr_linha_txt	:= vr_linha_txt || rpad(upper(gene0007.fn_caract_especial(nvl(rw_prestamista.dsendres,' '))), 60, ' ');
		vr_linha_txt	:= vr_linha_txt || rpad(upper(gene0007.fn_caract_especial(nvl(rw_prestamista.nmbairro,' '))), 30, ' ');
		vr_linha_txt	:= vr_linha_txt || rpad(upper(gene0007.fn_caract_especial(nvl(rw_prestamista.nmcidade,' '))), 30, ' ');
		vr_linha_txt	:= vr_linha_txt || rpad(nvl(to_char(rw_prestamista.cdufresd), ' '),2,' ');
		vr_linha_txt	:= vr_linha_txt || rpad(gene0002.fn_mask(rw_prestamista.nrcepend, 'zzzzz-zz9'), 10, ' ');

		if	(length(rw_prestamista.nrtelefo)	= 11) then

			vr_linha_txt	:= vr_linha_txt || rpad(gene0002.fn_mask(rw_prestamista.nrtelefo, '(99)99999-9999'), 15, ' ');

		elsif	(length(rw_prestamista.nrtelefo)	= 10) then

			vr_linha_txt	:= vr_linha_txt || rpad(gene0002.fn_mask(rw_prestamista.nrtelefo, '(99)9999-9999'), 15, ' ');

		else

			vr_linha_txt	:= vr_linha_txt || rpad(gene0002.fn_mask(rw_prestamista.nrtelefo, '99999-9999'), 15, ' ');

		end if;

		vr_linha_txt	:= vr_linha_txt || rpad(' ', 15, ' ');
		vr_linha_txt	:= vr_linha_txt || rpad(' ', 15, ' ');
		vr_dsdemail	:= rw_prestamista.dsdemail;

		segu0003.pc_limpa_email(vr_dsdemail);

		vr_linha_txt	:= vr_linha_txt || rpad(' ', 1, ' ');
		vr_linha_txt	:= vr_linha_txt || rpad(nvl(vr_dsdemail, ' '), 50, ' ');
		vr_linha_txt	:= vr_linha_txt || rpad(' ', 12, ' ');
		vr_linha_txt	:= vr_linha_txt || rpad(' ', 10, ' ');
		vr_linha_txt	:= vr_linha_txt || rpad( nvl(rw_prestamista.NRPROPOSTA,0), 30, ' ');
		vr_linha_txt	:= vr_linha_txt || lpad(to_char(rw_prestamista.dtdevend, 'YYYY-MM-DD'), 10, 0);
		vr_linha_txt	:= vr_linha_txt || lpad(to_char(rw_prestamista.dtinivig, 'YYYY-MM-DD'), 10, 0);
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

		if	(vr_tpregist	= 1) then

			vr_tpregist	:= 3;

		end if;

		begin

			update	tbseg_prestamista a
			set	a.tpregist	= vr_tpregist,
				a.dtdenvio	= dtmvtolt_v,
				a.vlprodut	= vr_vlprodvl,
				a.dtrefcob	= vr_ultimoDia,
				a.dtdevend	= rw_prestamista.dtdevend,
				a.dtfimvig	= vr_dtfimvig
			where	a.rowid		= rw_prestamista.nr_linha_tbseg;

		exception
		when	others then

			vr_dscritic	:= 'Erro ao atualizar saldo do contrato: ' || pr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || sqlerrm;
			raise	vr_exc_saida;

		end;

		if	(vr_tpregist	= 2) then

			begin

				update	crapseg c
				set	c.cdsitseg	= vr_tpregist
				where	c.rowid		= rw_prestamista.nr_linha_crapseg;

			exception
			when	others then

				vr_dscritic	:= 'Erro ao cancelar seguro prestamista: ' || pr_cdcooper || ' - nrdconta' || rw_prestamista.nrdconta || ' - ' || sqlerrm;
				raise	vr_exc_saida;

			end;

		end if;

		gene0001.pc_escr_linha_arquivo(vr_ind_arquivo,vr_linha_txt);

		vr_seqtran	:= vr_seqtran + 1;

	end loop;

	vr_tab_ctrl_prst.delete;

	gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquivo);

	gene0003.pc_converte_arquivo(	pr_cdcooper	=> pr_cdcooper,
					pr_nmarquiv	=> pr_diretorio || '/arq/' || vr_nmarquiv,
					pr_nmarqenv	=> vr_nmarquiv,
					pr_des_erro	=> vr_dscritic);

	if	(vr_dscritic	is not null) then

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

if	(upper(gene0001.fn_database_name) like '%AYLLOSP%') then

	select	max(a.dsvlrprm)
	into	ds_nome_diretorio_v
	from	crapprm a
	where	a.nmsistem	= 'CRED'
	and	a.cdcooper	= cd_cooperativa_v
	and	a.cdacesso	= 'ROOT_MICROS';

	if	(ds_nome_diretorio_v	is null) then

		select	max(a.dsvlrprm)
		into	ds_nome_diretorio_v
		from	crapprm a
		where	a.nmsistem	= 'CRED'
		and	a.cdcooper	= 0
		and	a.cdacesso	= 'ROOT_MICROS';

	end if;

	ds_nome_diretorio_v	:= ds_nome_diretorio_v || 'cpd/bacas/INC0130628';

else

	ds_nome_diretorio_v	:= gene0001.fn_diretorio(	pr_tpdireto => 'C',
								pr_cdcooper => 3);

	ds_nome_diretorio_v	:= ds_nome_diretorio_v || '/INC0130628';

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
		gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, '-> LOGS E ROLLBACK ' || chr(13) || chr(13), false);
		gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'begin ' || chr(13) || chr(13), false);  
		nm_arquivo_rollback_v	:= 'ROLLBACK_INC0130628_' || nr_arquivo || '.sql';

		nr_arquivo	:= nr_arquivo + 1;

	end if;

	if	(not vr_tab_ctrl_coop.exists(trim(to_char(r01.cdcooper)))) then

		vr_tab_ctrl_coop(trim(to_char(r01.cdcooper))).cdcooper	:= r01.cdcooper;

	end if;

	qt_reg_commit		:= qt_reg_commit + 1;
	qt_reg_arquivo		:= qt_reg_arquivo + 1;

	cd_critica_v		:= null;
	ds_critica_v		:= null;

	vr_nrctrseg		:= null;
	vr_flgdps		:= 'N';
	vr_vlproposta		:= null;
	vr_flgprestamista	:= 'N';
	vr_dsmotcan		:= null;

	SEGU0003.pc_validar_prestamista(	pr_cdcooper		=> r01.cdcooper,
						pr_nrdconta		=> r01.nrdconta,
						pr_nrctremp		=> r01.nrctremp,
						pr_cdagenci		=> r01.cdagenci,
						pr_nrdcaixa		=> 0,
						pr_cdoperad		=> r01.cdoperad,
						pr_nmdatela		=> 'SEGURO',
						pr_idorigem		=> 1,
						pr_valida_proposta	=> 'N',
						pr_sld_devedor		=> vr_vlproposta,
						pr_flgprestamista	=> vr_flgprestamista,
						pr_flgdps		=> vr_flgdps,
						pr_dsmotcan		=> vr_dsmotcan,
						pr_cdcritic		=> cd_critica_v,
						pr_dscritic		=> ds_critica_v);

	if	(trim(ds_critica_v)	is null) then

		segu0003.pc_cria_proposta_sp(		pr_cdcooper		=> r01.cdcooper,
							pr_nrdconta		=> r01.nrdconta,
							pr_nrctremp		=> r01.nrctremp,
							pr_cdagenci		=> r01.cdagenci,
							pr_nrdcaixa		=> 0,
							pr_cdoperad		=> r01.cdoperad,
							pr_nmdatela		=> 'SEGURO',
							pr_idorigem		=> 1,
							pr_cdcritic		=> cd_critica_v,
							pr_dscritic		=> ds_critica_v);

		if	(trim(ds_critica_v)	is null) then

			update	crapseg a
			set	a.cdsitseg	= 2
			where	exists
				(select	1
				from	tbseg_prestamista x
				where	trim(x.tprecusa)	is not null
				and	nvl(x.cdmotrec,0)	<> 0
				and	x.dtrecusa		is not null
				and	x.nrctremp		= r01.nrctremp
				and	x.nrctrseg		= a.nrctrseg
				and	x.nrdconta		= a.nrdconta
				and	x.cdcooper		= a.cdcooper)
			and	a.cdcooper	= r01.cdcooper
			and	a.nrdconta	= r01.nrdconta
			and	a.tpseguro	= 4
			and	a.cdsitseg	= 5;

			segu0001.pc_efetiva_proposta_seguro_p(	pr_cdcooper		=> r01.cdcooper,
								pr_nrdconta		=> r01.nrdconta,
								pr_nrctrato		=> r01.nrctremp,
								pr_cdoperad		=> r01.cdoperad,
								pr_cdagenci		=> r01.cdagenci,
								pr_vlslddev		=> vr_vlproposta,
								pr_idimpdps		=> vr_flgdps,
								pr_nrctrseg		=> vr_nrctrseg,
								pr_cdcritic		=> cd_critica_v,
								pr_dscritic		=> ds_critica_v);

			if	(trim(ds_critica_v)	is null) then

				segu0003.pc_vincula_emp_prest(	pr_cdcooper		=> r01.cdcooper,
								pr_nrdconta		=> r01.nrdconta,
								pr_nrctrseg		=> vr_nrctrseg,
								pr_nrctremp		=> r01.nrctremp,
								pr_cdagenci		=> r01.cdagenci,
								pr_nrdcaixa		=> 0,
								pr_cdoperad		=> r01.cdoperad,
								pr_nmdatela		=> 'SEGURO',
								pr_idorigem		=> 1,
								pr_cdcritic		=> cd_critica_v,
								pr_dscritic		=> ds_critica_v);

				if	(trim(ds_critica_v)	is null) then

					commit;

				end if;

			end if;

			update	crapseg a
			set	a.cdsitseg	= 5
			where	exists
				(select	1
				from	tbseg_prestamista x
				where	trim(x.tprecusa)	is not null
				and	nvl(x.cdmotrec,0)	<> 0
				and	x.dtrecusa		is not null
				and	x.nrctremp		= r01.nrctremp
				and	x.nrctrseg		= a.nrctrseg
				and	x.nrdconta		= a.nrdconta
				and	x.cdcooper		= a.cdcooper)
			and	a.cdcooper	= r01.cdcooper
			and	a.nrdconta	= r01.nrdconta
			and	a.tpseguro	= 4
			and	a.cdsitseg	= 2;

		end if;

		for	r02 in c02(	pr_nrctrseg	=> vr_nrctrseg,
					pr_nrctremp	=> r01.nrctremp,
					pr_cdcooper	=> r01.cdcooper,
					pr_nrdconta	=> r01.nrdconta) loop

			if	(trim(ds_critica_v)	is not null) then

				delete	from crawseg a
				where	a.rowid	= r02.nr_linha_crawseg;

			else

				gene0002.pc_escreve_xml(ds_dados_rollback_v,
							ds_texto_rollback_v,
							'delete	from crawseg a ' || chr(13) ||
							'where	a.rowid	= ' || chr(39) || r02.nr_linha_crawseg || chr(39) || ';' || chr(13) || chr(13), false);

			end if;

		end loop;

		for	r03 in c03(	pr_nrctrseg	=> vr_nrctrseg,
					pr_cdcooper	=> r01.cdcooper,
					pr_nrdconta	=> r01.nrdconta) loop

			if	(trim(ds_critica_v)	is not null) then

				delete	from crapseg a
				where	a.rowid	= r03.nr_linha_crapseg;

			else

				gene0002.pc_escreve_xml(ds_dados_rollback_v,
							ds_texto_rollback_v,
							'delete	from crapseg a ' || chr(13) ||
							'where	a.rowid	= ' || chr(39) || r03.nr_linha_crapseg || chr(39) || ';' || chr(13) || chr(13), false);

			end if;

		end loop;

		for	r04 in c04(	pr_nrctrseg	=> vr_nrctrseg,
					pr_nrctremp	=> r01.nrctremp,
					pr_cdcooper	=> r01.cdcooper,
					pr_nrdconta	=> r01.nrdconta) loop

			if	(trim(ds_critica_v)	is not null) then

				delete	from tbseg_prestamista a
				where	a.rowid	= r04.nr_linha_tbseg;

			else

				gene0002.pc_escreve_xml(ds_dados_rollback_v,
							ds_texto_rollback_v,
							'delete	from tbseg_prestamista a ' || chr(13) ||
							'where	a.rowid	= ' || chr(39) || r04.nr_linha_tbseg || chr(39) || ';' || chr(13) || chr(13), false);

			end if;

		end loop;

		if	(qt_reg_commit	>= 10000) then

			gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'commit;' || chr(13) || chr(13), FALSE);

			qt_reg_commit	:= 0;

		end if;

		if	(qt_reg_arquivo	>= 50000) then

			gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'end;'||chr(13), FALSE);
			gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, chr(13), TRUE);

			gene0002.pc_solicita_relato_arquivo(	pr_cdcooper	=> cd_cooperativa_v,
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

	end if;

	if	(trim(ds_critica_v)	is not null) then

		raise	ds_erro_registro_v;

	end if;

	exception
	when	ds_erro_registro_v then

		gene0002.pc_escreve_xml(ds_dados_rollback_v,
					ds_texto_rollback_v,
					'-> LOG: falha mapeada ao atualizar registro:' || chr(13) ||
					'-> Proposta: ' || r01.nrproposta || chr(13) ||
					'-> Crítica: ' || ds_critica_v || chr(13) || chr(13), false);

	when	others then

		rollback;

		gene0002.pc_escreve_xml(ds_dados_rollback_v,
					ds_texto_rollback_v,
					'-> LOG: erro de sistema ao atualizar registro:' || chr(13) ||
					'-> Proposta: ' || r01.nrproposta || chr(13) ||
					'-> Erro: ' || sqlerrm || chr(13) || chr(13), false);

		exit;

	end;

end loop;

if	(qt_reg_arquivo	<> 50000) then

	gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'commit;' || chr(13) || chr(13), FALSE);
	gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, 'end;' || chr(13), FALSE);
	gene0002.pc_escreve_xml(ds_dados_rollback_v, ds_texto_rollback_v, chr(13), TRUE);

	gene0002.pc_solicita_relato_arquivo(	pr_cdcooper	=> cd_cooperativa_v,
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

	if	(vr_tab_ctrl_coop.exists(trim(to_char(r05.cdcooper)))) then

		pc_gera_arquivo_coop(	pr_cdcooper	=> r05.cdcooper,
					pr_diretorio	=> ds_nome_diretorio_v,
					pr_nmrescop	=> r05.nmrescop,
					pr_dscritic	=> ds_critica_v);

		if	(ds_critica_v	is null) then

			commit;

		else

			ds_critica_arq_v	:= substr(ds_critica_arq_v || ' - Coop: ' || r05.cdcooper || ' - ' || ds_critica_v || chr(13),1,1000);

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