CREATE OR REPLACE PACKAGE CECRED.ESTE0004 is
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : ESTE0004
      Sistema  : Rotinas referentes a comunicaçao com a ESTEIRA de CREDITO da IBRATAN
      Sigla    : ESTE
      Autor    : Paulo Penteado (GFT) 
      Data     : Fevereio/2018.                   Ultima atualizacao: 16/02/2018

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas referentes a comunicaçao com a ESTEIRA de CREDITO da IBRATAN - Motor de Credito

      Alteracoes: 18/02/2018 Criaçao (Paulo Penteado (GFT))

                  23/03/2018 - Alterado a referencia que era para a tabela CRAPLIM para a tabela CRAWLIM nos procedimentos 
                  Referentes a proposta. (Lindon Carlos Pecile - GFT)

  ---------------------------------------------------------------------------------------------------------------*/
  --> Rotina responsavel por montar o objeto json para analise de limite de desconto de títulos
  PROCEDURE pc_gera_json_analise_lim(pr_cdcooper   in crapass.cdcooper%type
                                    ,pr_cdagenci   in crapass.cdagenci%type
                                    ,pr_nrdconta   in crapass.nrdconta%type
                                    ,pr_nrctrlim   in crawlim.nrctrlim%type
                                    ,pr_tpctrlim   in crawlim.tpctrlim%type
                                    ,pr_nrctaav1   in crawlim.nrctaav1%type
                                    ,pr_nrctaav2   in crawlim.nrctaav2%type
                                    ---- OUT ----
                                    ,pr_dsjsonan  out nocopy json             --> Retorno do clob em modelo json com os dados para analise
                                    ,pr_cdcritic  out number                  --> Codigo da critica
                                    ,pr_dscritic  out varchar2                --> Descricao da critica
                                    );
                                
  --> Rotina responsavel por gerar o objeto Json da proposta
  PROCEDURE pc_gera_json_proposta(pr_cdcooper in crawepr.cdcooper%type
                                 ,pr_cdagenci in crapage.cdagenci%type
                                 ,pr_cdoperad in crapope.cdoperad%type
                                 ,pr_nrdconta in crawepr.nrdconta%type
                                 ,pr_nrctrlim in crawlim.nrctrlim%type
                                 ,pr_tpctrlim in crawlim.tpctrlim%type
                                 ,pr_nmarquiv in varchar2               --> Diretorio e nome do arquivo pdf da proposta de emprestimo
                                 ---- OUT ----
                                 ,pr_proposta out json                   --> Retorno do clob em modelo json da proposta de emprestimo
                                 ,pr_cdcritic out number                 --> Codigo da critica
                                 ,pr_dscritic out varchar2               --> Descricao da critica
                                 );
         
END ESTE0004;
/
CREATE OR REPLACE PACKAGE BODY CECRED.ESTE0004 IS
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : ESTE0004
      Sistema  : Rotinas referentes a comunicaçao com a ESTEIRA de CREDITO da IBRATAN
      Sigla    : CADA
      Autor    : Paulo Penteado (Gft)
      Data     : Março/2018.                   Ultima atualizacao: 23/03/2018
      
      Dados referentes ao programa:
      Frequencia: Sempre que solicitado
      Objetivo  : Rotinas referentes a comunicaçao com a ESTEIRA de CREDITO da IBRATAN

      Alteracoes: 23/03/2018 - Alterado a referencia que era para a tabela CRAPLIM para a tabela CRAWLIM nos procedimentos 
                  Referentes a proposta. (Lindon Carlos Pecile - GFT)
  
  ---------------------------------------------------------------------------------------------------------------*/
    
PROCEDURE pc_gera_json_pessoa_ass(pr_cdcooper in crapass.cdcooper%type
                                 ,pr_nrdconta in crapass.nrdconta%type
                                 ,pr_vlsalari in number  default 0
                                 ,pr_persocio in number  default 0
                                 ,pr_dtadmsoc in date    default null
                                 ,pr_dtvigpro in date    default null
                                 ,pr_dsjsonan out json
                                 ,pr_cdcritic out number
                                 ,pr_dscritic out varchar2) is
BEGIN
   /*..........................................................................
     Objetivo  : Rotina responsavel por buscar todas as informaçoes cadastrais
     ..........................................................................*/
DECLARE
   -- Variáveis para exceçoes
   vr_cdcritic pls_integer;
   vr_dscritic varchar2(4000);
   vr_exc_saida exception;
   vr_des_reto varchar2(3);
   vr_tab_erro gene0001.typ_tab_erro;
    
   -- Declarar objetos Json necessários:
   vr_obj_generico  json := json();
   vr_obj_generic2  json := json();
   vr_obj_generic3  json := json(); 
   vr_lst_generic2  json_list := json_list();
   vr_lst_generic3  json_list := json_list();
   
   -- Variáveis auxiliares
   vr_tpcmpvrn varchar2(100);
   vr_dstextab craptab.dstextab%type;
   vr_nmseteco craptab.dstextab%type;
   vr_qtdopliq varchar2(10);
   vr_flliquid boolean;
   vr_flprjcop boolean;
   vr_fl800900 boolean;
   vr_vladtdep crapsda.vllimcre%type;
   vr_flggrupo integer;
   vr_nrdgrupo crapgrp.nrdgrupo%type;
   vr_gergrupo varchar2(100);
   vr_dsdrisgp crapgrp.dsdrisgp%type;
   vr_temcotas boolean;
   vr_temdebaut boolean;
   vr_vlsldtot number;
   vr_ind      pls_integer;
   vr_vlsldapl craprda.vlsdrdca%type := 0;
   vr_vlsldrgt number;
   vr_percenir number;
   vr_vlsldppr number;
   vr_flgativo integer;
   vr_nrctrhcj number;
   vr_flgliber integer;
   vr_vltotccr number;
   vr_vlutiliz number;
   vr_vlendivi number := 0;
   vr_ind_coresp varchar2(100);
   vr_qtprecal number(10) := 0;
   vr_tot_vlsdeved number(25, 10) := 0;
   vr_ava_vlsdeved number(25, 10) := 0;
   vr_tot_qtprecal number := 0;
   vr_nratrmai number(25,10);
   vr_vltotatr number(25,10);
   vr_qtpclven number;
   vr_qtpclatr number;
   vr_qtpclpag number;
   vr_tot_qtpclatr number;
   vr_tot_qtpclpag number;
   vr_idxempr  varchar2(100);
   vr_dias     number;
   vr_inusatab boolean;
   vr_dstextab_parempctl craptab.dstextab%type;
   vr_dstextab_digitaliza craptab.dstextab%type;
   vr_qtregist integer;
   vr_vltotpre number(25,2) := 0;
   vr_nrconbir crapcbc.nrconbir%type;
   vr_nrseqdet crapcbd.nrseqdet%type;
   vr_cdbircon crapbir.cdbircon%type;
   vr_dsbircon crapbir.dsbircon%type;
   vr_cdmodbir crapmbr.cdmodbir%type;
   vr_dsmodbir crapmbr.dsmodbir%type;
   vr_flsituac varchar2(100) := 'N';      
   vr_vlmedfat number;
   vr_qtmesest crapprm.dsvlrprm%type;
   vr_qtmeschq crapprm.dsvlrprm%type; 
   vr_qtmeschqal11 crapprm.dsvlrprm%type; 
   vr_qtmeschqal12 crapprm.dsvlrprm%type;       
   vr_qthisemp crapprm.dsvlrprm%type; 
   vr_qqdiacheq number;    
   vr_tab_estouros risc0001.typ_tab_estouros;
   vr_dtiniest date;
   vr_qtdiaat2 integer := 0;
   vr_idcarga  tbepr_carga_pre_aprv.idcarga%type;
   vr_vllimdis crapcpa.vllimdis%type := 0;
   vr_maior_nratrmai number(25,10);

   --PlTables auxiliares
   vr_tab_sald                extr0001.typ_tab_saldos;
   vr_tab_medias              extr0001.typ_tab_medias;
   vr_tab_comp_medias         extr0001.typ_tab_comp_medias;
   vr_tab_ocorren             cada0004.typ_tab_ocorren;
   vr_tab_saldo_rdca          apli0001.typ_tab_saldo_rdca;
   vr_tab_conta_bloq          apli0001.typ_tab_ctablq;
   vr_tab_craplpp             apli0001.typ_tab_craplpp;
   vr_tab_craplrg             apli0001.typ_tab_craplpp;
   vr_tab_resgate             apli0001.typ_tab_resgate;
   vr_tab_dados_rpp           apli0001.typ_tab_dados_rpp;
   vr_tab_cartoes             cada0004.typ_tab_cartoes;
   vr_tab_co_responsavel      empr0001.typ_tab_dados_epr;
   vr_tab_dados_epr           empr0001.typ_tab_dados_epr;
   
   --Tipo de registro do tipo data
   rw_crapdat btch0001.cr_crapdat%rowtype;
    
   --     Cursor para endereço
   cursor cr_crapenc(pr_tpendass crapenc.tpendass%type) is
   select enc.dsendere
         ,enc.nrendere
         ,enc.complend
         ,enc.nmbairro
         ,enc.nmcidade
         ,enc.cdufende
         ,enc.nrcepend
         ,enc.nrcxapst
         ,enc.incasprp
         ,enc.vlalugue
         ,enc.dtinires
   from   crapenc enc
   where  enc.cdcooper = pr_cdcooper
   and    enc.nrdconta = pr_nrdconta
   and    enc.tpendass = pr_tpendass
   and    enc.idseqttl = 1;
   rw_crapenc cr_crapenc%rowtype;
    
   --     Cursor para telefones:
   cursor cr_craptfc is
   select tfc.tptelefo
         ,tfc.nrdddtfc
         ,tfc.nrtelefo
   from   craptfc tfc
   where  tfc.cdcooper = pr_cdcooper
   and    tfc.nrdconta = pr_nrdconta
   and    tfc.idseqttl = 1
   and    tfc.tptelefo in (1, 2, 3); /* Residencial, Celular e Comercial */
      
   --     Busca Email
   cursor cr_crapcem is
   select cem.dsdemail
   from   crapcem cem
   where  cem.cdcooper = pr_cdcooper
   and    cem.nrdconta = pr_nrdconta
   and    cem.idseqttl = 1;
   vr_dsdemail crapcem.dsdemail%type;
      
   --     Busca no cadastro do associado:
   cursor cr_crapass is
   select ass.nrdconta
         ,ass.nrcpfcgc
         ,ass.cdagenci
         ,ass.dtnasctl
         ,ass.nrmatric
         ,ass.cdtipcta
         ,ass.cdsitdct
         ,ass.dtcnsscr
         ,ass.inlbacen
         ,decode(ass.incadpos,1,'Nao Autorizado',2,'Autorizado','Cancelado') incadpos
         ,ass.dtelimin
         ,ass.inccfcop
         ,ass.dtcnsspc
         ,ass.dtdsdspc
         ,ass.inadimpl
         ,ass.cdsitdtl
         ,ass.inpessoa
         ,ass.dtcnscpf
         ,ass.cdsitcpf
         ,ass.cdclcnae
         ,ass.vllimcre
         ,ass.nmprimtl
         ,ass.dtmvtolt
         ,ass.dtadmiss
   from   crapass ass
   where  ass.cdcooper = pr_cdcooper
   and    ass.nrdconta = pr_nrdconta;
   rw_crapass cr_crapass%rowtype;
       
   --     Buscar informaçoes do primeiro titular 
   cursor cr_crapttl is
   select ttl.nmextttl
         ,ttl.dtcnscpf
         ,ttl.cdsitcpf
         ,ttl.tpdocttl
         ,ttl.nrdocttl
         ,org.cdorgao_expedidor cdoedttl
         ,ttl.dtnasttl
         ,ttl.cdsexotl
         ,ttl.tpnacion
         ,nac.dsnacion dsnacion
         ,ttl.dsnatura || '-' || ttl.cdufnatu dsnatura
         ,ttl.dthabmen
         ,ttl.cdestcvl
         ,ttl.cdgraupr
         ,ttl.cdfrmttl
         ,ttl.nmmaettl
         ,ttl.nmpaittl
         ,ttl.cdnatopc
         ,ttl.cdocpttl
         ,ttl.tpcttrab
         ,ttl.cdempres
         ,ttl.nrcpfemp
         ,ttl.dsproftl
         ,ttl.cdnvlcgo
         ,ttl.nrcadast
         ,ttl.cdturnos
         ,ttl.inpolexp
         ,ttl.dtadmemp
         ,ttl.vlsalari vlrendim
         ,ttl.vldrendi##1 + ttl.vldrendi##2 + ttl.vldrendi##3 +
          ttl.vldrendi##4 + ttl.vldrendi##5 + ttl.vldrendi##6 vroutrorn
         ,ttl.inhabmen
         ,ttl.grescola
         ,ass.dtcnsscr
         ,ass.inlbacen
         ,ass.incadpos
         ,ass.dtelimin
         ,ass.dtcnsspc
         ,ass.dtdsdspc
         ,ass.inadimpl
         ,ass.cdsitdtl
   from   crapttl ttl
         ,crapass ass
         ,crapnac nac
         ,tbgen_orgao_expedidor org
   where  ttl.cdcooper = pr_cdcooper
   and    ttl.nrdconta = pr_nrdconta
   and    ttl.idseqttl = 1
   and    ass.cdcooper = ttl.cdcooper
   and    ass.nrdconta = ttl.nrdconta
   and    ttl.cdnacion = nac.cdnacion(+)
   and    ttl.idorgexp = org.idorgao_expedidor(+);
   rw_crapttl cr_crapttl%rowtype;
    
   -- Buscar dados do titular pessoa juridical
   cursor cr_crapjur is
     select jur.nmextttl
           ,jur.nmfansia
           ,jur.natjurid
           ,jur.qtfilial
           ,jur.qtfuncio
           ,jur.cdseteco
           ,jur.cdrmativ
           ,jur.vlfatano
           ,jur.vlcaprea
           ,jur.dtregemp
           ,jur.nrregemp
           ,jur.orregemp
           ,jur.dtinsnum
           ,jur.nrinsmun
           ,jur.nrinsest
           ,jur.flgrefis
           ,jur.nrcdnire
           ,jur.dtiniatv
       from crapjur jur
      where jur.cdcooper = pr_cdcooper
        and jur.nrdconta = pr_nrdconta;
   rw_crapjur cr_crapjur%rowtype;
    
   -- Verifica se esta na tabela do pre-aprovado
   cursor cr_crapcpa (pr_cdcooper in crapcpa.cdcooper%type,
                      pr_nrdconta in crapcpa.nrdconta%type,
                      pr_idcarga  in crapcpa.iddcarga%type) is
     select cpa.vllimdis
           ,cpa.vlcalpre
           ,cpa.vlctrpre
           ,cpa.cdlcremp
       from crapcpa cpa
      where cpa.cdcooper = pr_cdcooper
        and cpa.nrdconta = pr_nrdconta
        and cpa.iddcarga = pr_idcarga;
   rw_crapcpa cr_crapcpa%rowtype;    
    
   -- Pré Aprovado Nao Liberado
   cursor cr_preapv is
     select flglibera_pre_aprv
       from tbepr_param_conta
      where cdcooper = pr_cdcooper
        and nrdconta = pr_nrdconta;
   vr_flglibera_pre_aprv tbepr_param_conta.flglibera_pre_aprv%type := 0;
    
   -- Data Ultima Revisao Cadastral
   cursor cr_revisa is
     select max(crapalt.dtaltera)
       from crapalt
      where crapalt.cdcooper = pr_cdcooper
        and crapalt.nrdconta = pr_nrdconta
        and crapalt.tpaltera = 1;
   vr_dtaltera date;
    
   -- Conta tem Alerta
   cursor cr_alerta is
     select 1
       from crapcrt
      where nrcpfcgc = rw_crapass.nrcpfcgc
        and cdsitreg = 1 --> Inserido
        and dtexclus is null;
   vr_indexis number;
    
   -- Quantidade de Dependentes
   cursor cr_depend is
     select count(1)
       from crapdep
      where cdcooper = pr_cdcooper
        and nrdconta = pr_nrdconta;
   vr_qtdepend number;
       
   -- Buscar descriçao
   cursor cr_nature(pr_natjurid in crapjur.natjurid%type) is
     select gncdntj.dsnatjur
       from gncdntj
      where gncdntj.cdnatjur = pr_natjurid;
   vr_dsnatjur gncdntj.dsnatjur%type;
  
  -- Buscar descriçao
cursor cr_ramatv(pr_cdseteco in gnrativ.cdseteco%type
                ,pr_cdrmativ in gnrativ.cdrmativ%type) is
 select gnrativ.nmrmativ
  from gnrativ
  where gnrativ.cdseteco  = pr_cdseteco
   and gnrativ.cdrmativ = pr_cdrmativ;    
vr_dsramatv gnrativ.nmrmativ%type;
  
   -- Buscar descriçao
   cursor cr_cnae(pr_cdclcnae in crapass.cdclcnae%type) is
     select dscnae
       from tbgen_cnae
      where cdcnae = pr_cdclcnae;
   vr_dscnae tbgen_cnae.dscnae%type;
    
   -- Buscar informaçoes de faturamento 
   cursor cr_crapjfn is
     select jfn.perfatcl
           ,'01' || to_char(jfn.mesftbru##1, 'fm00') || to_char(jfn.anoftbru##1, 'fm0000') dtfatme1
           ,'01' || to_char(jfn.mesftbru##2, 'fm00') || to_char(jfn.anoftbru##2, 'fm0000') dtfatme2
           ,'01' || to_char(jfn.mesftbru##3, 'fm00') || to_char(jfn.anoftbru##3, 'fm0000') dtfatme3
           ,'01' || to_char(jfn.mesftbru##4, 'fm00') || to_char(jfn.anoftbru##4, 'fm0000') dtfatme4
           ,'01' || to_char(jfn.mesftbru##5, 'fm00') || to_char(jfn.anoftbru##5, 'fm0000') dtfatme5
           ,'01' || to_char(jfn.mesftbru##6, 'fm00') || to_char(jfn.anoftbru##6, 'fm0000') dtfatme6
           ,'01' || to_char(jfn.mesftbru##7, 'fm00') || to_char(jfn.anoftbru##7, 'fm0000') dtfatme7
           ,'01' || to_char(jfn.mesftbru##8, 'fm00') || to_char(jfn.anoftbru##8, 'fm0000') dtfatme8
           ,'01' || to_char(jfn.mesftbru##9, 'fm00') || to_char(jfn.anoftbru##9, 'fm0000') dtfatme9
           ,'01' || to_char(jfn.mesftbru##10, 'fm00') || to_char( jfn.anoftbru##10, 'fm0000') dtfatme10
           ,'01' || to_char(jfn.mesftbru##11, 'fm00') || to_char( jfn.anoftbru##11, 'fm0000') dtfatme11
           ,'01' || to_char(jfn.mesftbru##12, 'fm00') || to_char( jfn.anoftbru##12, 'fm0000') dtfatme12
           ,jfn.vlrftbru##1
           ,jfn.vlrftbru##2
           ,jfn.vlrftbru##3
           ,jfn.vlrftbru##4
           ,jfn.vlrftbru##5
           ,jfn.vlrftbru##6
           ,jfn.vlrftbru##7
           ,jfn.vlrftbru##8
           ,jfn.vlrftbru##9
           ,jfn.vlrftbru##10
           ,jfn.vlrftbru##11
           ,jfn.vlrftbru##12
       from crapjfn jfn
      where jfn.cdcooper = pr_cdcooper
        and jfn.nrdconta = pr_nrdconta;
   rw_crapjfn cr_crapjfn%rowtype;
    
   -- Buscar ultimas operaçoes de Crédito Liquidadas      
   cursor cr_crapepr is
     select epr.nrctremp
           ,epr.vlemprst
           ,epr.dtmvtolt
           ,epr.qtpreemp
           ,epr.vlpreemp
           ,epr.cdlcremp
           ,lcr.dslcremp
           ,epr.cdfinemp
           ,fin.dsfinemp
       from crapepr epr
           ,craplcr lcr
           ,crapfin fin
      where epr.cdcooper = pr_cdcooper
        and epr.nrdconta = pr_nrdconta
        and epr.inliquid = 1 -- Somente liquidadas
        and lcr.cdcooper = epr.cdcooper
        and lcr.cdlcremp = epr.cdlcremp
        and lcr.flglispr = 1 -- Somente as que listam na proposta
        and fin.cdcooper = epr.cdcooper
        and fin.cdfinemp = epr.cdfinemp
      order by epr.dtultpag desc;
    
   -- Busca data da Liquidaçao        
   cursor cr_dtliquid(pr_nrctremp in crapepr.nrctremp%type) is
     select max(lem.dtmvtolt)
       from craplem lem
           ,craphis his
      where lem.cdcooper = pr_cdcooper
        and lem.nrdconta = pr_nrdconta
        and lem.nrctremp = pr_nrctremp
        and his.cdcooper = lem.cdcooper
        and his.cdhistor = lem.cdhistor
        and his.indebcre = 'C'; -- Lcto de Crecito
   vr_dtliquid date;
    
   -- Buscar quantos dias de atraso houve no contrato
   cursor cr_crapris(pr_nrctremp in crapepr.nrctremp%type
                    ,pr_dtultdma in crapdat.dtultdma%type) is
     select max(ris.qtdiaatr) qtdiaatr
       from crapris ris
      where ris.cdcooper = pr_cdcooper
        and ris.nrdconta = pr_nrdconta
        and ris.nrctremp = nvl(pr_nrctremp,ris.nrctremp)
        and ris.dtrefere >= pr_dtultdma
        and ris.cdmodali in(299,499)
        and ris.inddocto = 1;
   vr_qtdiaatr number;
    
   -- Checar se esta proposta foi liquidada em novos contratos
   cursor cr_eprliquid(pr_nrctremp in crapepr.nrctremp%type) is
     select 1
       from crawepr wpr2
      where wpr2.cdcooper = pr_cdcooper
        and wpr2.nrdconta = pr_nrdconta
        and pr_nrctremp -- Contrato registro em loop
            in (wpr2.nrctrliq##1
               ,wpr2.nrctrliq##2
               ,wpr2.nrctrliq##3
               ,wpr2.nrctrliq##4
               ,wpr2.nrctrliq##5
               ,wpr2.nrctrliq##6
               ,wpr2.nrctrliq##7
               ,wpr2.nrctrliq##8
               ,wpr2.nrctrliq##9
               ,wpr2.nrctrliq##10);
   rw_eprliquid cr_eprliquid%rowtype;
    
   -- Verificar se houve prejuizo do Cooperado na Cooperativa          
   cursor cr_crapepr_preju is
     select 1
       from crapepr epr
      where epr.cdcooper = pr_cdcooper
        and epr.nrdconta = pr_nrdconta
        and epr.inprejuz = 1;
   rw_crapepr_preju cr_crapepr_preju%rowtype;
    
   -- Verificar se ha emprestimo nas linhas 800 e 900     
   cursor cr_crapepr_800_900 is
     select 1
       from crapepr epr
      where epr.cdcooper = pr_cdcooper
        and epr.nrdconta = pr_nrdconta
        and epr.inliquid = 0
        and epr.cdlcremp in (800, 900);
   rw_crapepr_800_900 cr_crapepr_800_900%rowtype;
    
   -- Buscar outras propostas em Andamento
   cursor cr_crawepr_outras is
     select sum(wpr.vlemprst) vlsdeved
           ,sum(wpr.vlpreemp) vlpreemp
       from crawepr wpr
      where wpr.cdcooper = pr_cdcooper
        and wpr.nrdconta = pr_nrdconta
        --AND wpr.nrctremp <> pr_nrctremp  -- Somente em aberto
        and wpr.insitapr = 1             -- Somente Aprovadas
        and not exists(select 1 
                        from crapepr epr
                       where epr.cdcooper = wpr.cdcooper
                         and epr.nrdconta = wpr.nrdconta
                         and epr.nrctremp = wpr.nrctremp);
   rw_crawepr_outras cr_crawepr_outras%rowtype;
      
   -- Buscar Contrato Limite Crédito
   /*
   cursor cr_craplim_chqesp is
     select lim.dtinivig
           ,lim.vllimite
       from craplim lim
      where lim.cdcooper = pr_cdcooper
        and lim.nrdconta = pr_nrdconta
        and lim.insitlim = 2; -- Ativo
   rw_craplim_chqesp cr_craplim_chqesp%rowtype;
   */ 
   -- Buscar Proposta Limite Crédito
   cursor cr_crawlim_chqesp is
     select lim.dtinivig
           ,lim.vllimite
       from crawlim lim
      where lim.cdcooper = pr_cdcooper
        and lim.nrdconta = pr_nrdconta
        and lim.insitlim = 2; -- Ativo
   rw_crawlim_chqesp cr_crawlim_chqesp%rowtype;
    
   -- Buscar ultimas ocorrencias de Cheques Devolvidos
   cursor cr_crapneg_cheq(pr_qtmeschq     in integer
                      ,pr_qtmeschqal11 in integer
           ,pr_qtmeschqal12 in integer) is
     select dtiniest
           ,vlestour
           ,cdobserv
    ,rownum
       from crapneg
      where crapneg.cdcooper = pr_cdcooper
        and crapneg.cdhisest = 1 /* Dev Cheques */
        and crapneg.nrdconta = pr_nrdconta
        and crapneg.dtiniest between add_months(trunc(rw_crapdat.dtmvtolt),
                                           -decode(crapneg.cdobserv
                              ,11,pr_qtmeschqal11
                              ,12,pr_qtmeschqal12
                          ,pr_qtmeschq))
                                                and trunc(rw_crapdat.dtmvtolt)      
      order by crapneg.dtiniest desc;
    
   -- Buscar Saldo de Cotas
   cursor cr_crapcot is
     select vldcotas
       from crapcot
      where cdcooper = pr_cdcooper
        and nrdconta = pr_nrdconta;
   vr_vldcotas crapcot.vldcotas%type;
   
   -- Busca se o cooperado tem plano de cotas ativo
   cursor cr_crappla is
     select 1
       from crappla
      where cdcooper = pr_cdcooper
        and nrdconta = pr_nrdconta
        and cdsitpla = 1;
   rw_crappla cr_crappla%rowtype;
    
   -- Verificar se cooperado tem Debito Automático
   cursor cr_crapatr is
     select 1
       from crapatr
      where cdcooper = pr_cdcooper
        and nrdconta = pr_nrdconta
        and dtfimatr is null;
   rw_crapatr cr_crapatr%rowtype;
    
   -- Buscar as informaçoes do Arquivo SCR
   cursor cr_crapopf is
     select qtopesfn
           ,qtifssfn
           ,dtrefere
       from crapopf
      where nrcpfcgc = rw_crapass.nrcpfcgc
      order by dtrefere desc;
   rw_crapopf cr_crapopf%rowtype;
      
   -- Na sequencia buscar os valores dos vencimentos
   cursor cr_crapvop(pr_nrcpfcgc in crapass.nrcpfcgc%type) is
     select sum(vlvencto) vlopesfn
           ,sum(case
                  when cdvencto between 205 and 290 then
                   vlvencto
                  else
                   0
                end) vlopevnc
           ,sum(case
                  when cdvencto between 310 and 330 then
                   vlvencto
                  else
                   0
                end) vlopeprj
           ,sum(case
                  when cdvencto = 130 then
                   vlvencto
                  else
                   0
                end) vlvcto130
       from crapvop
      where nrcpfcgc = pr_nrcpfcgc
        and dtrefere = rw_crapopf.dtrefere;
   rw_crapvop     cr_crapvop%rowtype;
    
   -- Buscar todos os seguros da Conta do Cooperado 
   cursor cr_crapseg is
     select decode(seg.tpseguro
                  ,1
                  ,'CASA'
                  ,11
                  ,'CASA'
                  ,2
                  ,'AUTO'
                  ,3
                  ,'VIDA'
                  ,4
                  ,'PRST'
                  ,'    ') dstipo
           ,wseg.vlseguro vlpremio
       from crapseg seg
           ,crapcsg csg
           ,crawseg wseg
      where seg.cdcooper = csg.cdcooper
        and seg.cdsegura = csg.cdsegura
        and seg.cdcooper = pr_cdcooper
        and seg.nrdconta = pr_nrdconta
        and seg.cdcooper = wseg.cdcooper(+)
        and seg.nrdconta = wseg.nrdconta(+)
        and seg.nrctrseg = wseg.nrctrseg(+)
        and seg.cdsitseg in (1, 3, 11)
     union all
     select decode(segnov.tpseguro
                  ,'C'
                  ,'CASA'
                  ,'A'
                  ,'AUTO'
                  ,'V'
                  ,'VIDA'
                  ,'G'
                  ,'VIDA'
                  ,'P'
                  ,'PRST'
                  ,'    ') dstipo
           ,segnov.vlpremio_total vlpremio
       from tbseg_contratos segnov
           ,crapcsg         csg
           ,tbseg_parceiro  par
      where segnov.cdparceiro = par.cdparceiro
        and segnov.cdcooper = csg.cdcooper
        and segnov.cdsegura = csg.cdsegura
        and segnov.cdcooper = pr_cdcooper
        and segnov.nrdconta = pr_nrdconta
        and segnov.indsituacao in('A','R','E')
        and segnov.nrapolice > 0;
    
   -- Verificar se há bloqueio de aplicaçoes na conta
   cursor cr_crapblj is
     select sum(vlbloque)
       from crapblj
      where cdcooper = pr_cdcooper
        and nrdconta = pr_nrdconta
        and cdmodali = 2
        and dtblqfim is null;
   vr_vlbloque crapblj.vlbloque%type;

  
  -- Verificar se há bloqueio de aplicaçoes na conta
   cursor cr_crapblj_pp is
     select sum(vlbloque)
       from crapblj
      where cdcooper = pr_cdcooper
        and nrdconta = pr_nrdconta
        and cdmodali > 2
        and dtblqfim is null;
   vr_vlbloque_pp crapblj.vlbloque%type;
    
   -- Buscar contrato de desconto cheques
   cursor cr_craplim_chq is
     select dtinivig
           ,vllimite
       from craplim
      where craplim.cdcooper = pr_cdcooper
        and craplim.nrdconta = pr_nrdconta
        and craplim.tpctrlim = 2
        and craplim.insitlim = 2; /* ATIVO */
   rw_craplim_chq cr_craplim_chq%rowtype;
    
   -- Buscar borderôs ativos
   cursor cr_crapcdb(pr_dtmvtolt in crapdat.dtmvtolt%type) is
     select sum(vlcheque) vlcheque
       from crapcdb
      where crapcdb.cdcooper = pr_cdcooper
        and crapcdb.nrdconta = pr_nrdconta
        and crapcdb.insitchq = 2
        and crapcdb.dtlibera > pr_dtmvtolt;
   rw_crapcdb cr_crapcdb%rowtype;
    
   -- Buscar contrato de desconto titulos
   cursor cr_craplim_tit is
     select dtinivig
           ,vllimite
       from craplim
      where craplim.cdcooper = pr_cdcooper
        and craplim.nrdconta = pr_nrdconta
        and craplim.tpctrlim = 3
        and craplim.insitlim = 2; /* ATIVO */
   rw_craplim_tit cr_craplim_tit%rowtype;
    
   -- Buscar borderôs ativos
   cursor cr_craptdb(pr_dtmvtolt in crapdat.dtmvtolt%type) is
     select sum(vltitulo) vltitulo
       from craptdb
      where craptdb.cdcooper = pr_cdcooper
        and craptdb.nrdconta = pr_nrdconta
        and ((craptdb.insittit = 4) or
            (craptdb.insittit = 2 and
            craptdb.dtdpagto = pr_dtmvtolt));
   rw_craptdb cr_craptdb%rowtype;
    
   -- Para PP, buscaremos no cadastro de parcelas a quantidade de parcelas pagas em atraso      
   cursor cr_crappep_atraso(pr_dtmvtolt in crapdat.dtmvtolt%type
                        ,pr_nrctremp in crappep.nrctremp%type
            ,pr_qthisemp in integer) is
     select count(1)
       from crappep
      where cdcooper = pr_cdcooper
        and nrdconta = pr_nrdconta
        and nrctremp = pr_nrctremp
        and dtultpag > dtvencto -- Paga depois do vencimento
        and dtultpag >= add_months(pr_dtmvtolt, -pr_qthisemp) -- Nos ultimos XX meses
        and inliquid = 1 -- Liquidadas
        and vlpagmta > 0; -- Com multa
    
   -- Para as parcelas pagas também buscaremos no cadastro de parcelas
   cursor cr_crappep_pagtos(pr_dtmvtolt in crapdat.dtmvtolt%type
                        ,pr_nrctremp in crappep.nrctremp%type
            ,pr_qthisemp in integer) is
     select count(1)
       from crappep
      where cdcooper = pr_cdcooper
        and nrdconta = pr_nrdconta
        and nrctremp = pr_nrctremp
        and dtultpag >= add_months(pr_dtmvtolt, -pr_qthisemp) -- Nos ultimos XX meses
        and inliquid = 1 -- Liquidadas
        and vlpagmta = 0; -- Sem multa
    
   -- Para TR, buscaremos nos lançamentos de pagtos a quantidade de lançamentos de Multa
   cursor cr_craplem_atraso(pr_dtmvtolt in crapdat.dtmvtolt%type
                        ,pr_nrctremp in craplem.nrctremp%type
            ,pr_qthisemp in integer) is
     select count(1)
       from craplem
      where cdcooper = pr_cdcooper
        and nrdconta = pr_nrdconta
        and nrctremp = pr_nrctremp
        and cdhistor = 443 -- Multa
        and dtmvtolt >= add_months(pr_dtmvtolt, -pr_qthisemp); -- Nos ultimos XX meses
    
   -- Somar o valor pago nos ultimos 6 meses
   cursor cr_craplem_pago(pr_dtmvtolt in crapdat.dtmvtolt%type
                      ,pr_nrctremp in craplem.nrctremp%type
           ,pr_qthisemp in integer) is
     select nvl(sum(vllanmto),0)
       from craplem
      where cdcooper = pr_cdcooper
        and nrdconta = pr_nrdconta
        and nrctremp = pr_nrctremp
        and cdhistor not in (99, 98, 443) -- Remover liberaçao, juros e Multa
        and dtmvtolt >= add_months(pr_dtmvtolt, -pr_qthisemp) -- Nos ultimos XX meses
        and vlpreemp > 0;
vr_vlpclpag number(25,10);
   
-- Busca dos bens do associado CURSOR cr_crapbem e vr_vlrtotbem
cursor cr_crapbem is
select sum(vlrdobem)
 from crapbem 
 where cdcooper = pr_cdcooper
   and nrdconta = pr_nrdconta
   and idseqttl = 1;
vr_vltotbem number;
      
      
   -- Buscar saldos diarios dos associados
   cursor cr_crapsda (pr_cdcooper crapsda.cdcooper%type,
                      pr_nrdconta crapsda.nrdconta%type,
                      pr_dtiniest crapsda.dtmvtolt%type) is
     select vlsddisp,
            vllimcre
       from crapsda
      where crapsda.cdcooper = pr_cdcooper
        and crapsda.nrdconta = pr_nrdconta
        and crapsda.dtmvtolt >= pr_dtiniest         
       order by crapsda.dtmvtolt desc;
      
   -- Cursor para verificar se o cooperado teve contrato de linha de credito no periodo
   cursor cr_craplim (pr_cdcooper craplim.cdcooper%type,
                      pr_nrdconta craplim.nrdconta%type,
                      pr_dtiniest craplim.dtinivig%type) is
     select 1 
       from craplim lim
      where lim.cdcooper = pr_cdcooper
        and lim.nrdconta = pr_nrdconta
        and lim.insitlim in (2,3)
        and nvl(lim.dtfimvig,pr_dtiniest) >= pr_dtiniest;
   rw_craplim cr_craplim%rowtype;
   
   -- Cursor para verificar se o cooperado teve proposta linha de credito no periodo
   
   cursor cr_crawlim (pr_cdcooper crawlim.cdcooper%type,
                      pr_nrdconta crawlim.nrdconta%type,
                      pr_dtiniest crawlim.dtinivig%type) is
     select 1 
       from crawlim lim
      where lim.cdcooper = pr_cdcooper
        and lim.nrdconta = pr_nrdconta
        and lim.insitlim in (2,3)
        and nvl(lim.dtfimvig,pr_dtiniest) >= pr_dtiniest;
   --rw_crawlim cr_crawlim%rowtype;

    BEGIN
      --Verificar se a data existe
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se nao encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        CLOSE BTCH0001.cr_crapdat;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF; 
  
      -- Buscar informaçoes cadastrais da conta
      OPEN cr_crapass;
      FETCH cr_crapass
        INTO rw_crapass;
    
      -- Se nao encontrar registro
      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        -- Sair acusando critica 9
        vr_cdcritic := 9;
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapass;
      END IF;

      --Verificar se usa tabela juros
      vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_tptabela => 'USUARI'
                                              ,pr_cdempres => 11
                                              ,pr_cdacesso => 'TAXATABELA'
                                              ,pr_tpregist => 0);
      -- Se a primeira posiçao do campo
      -- dstextab for diferente de zero
      vr_inusatab:= SUBSTR(vr_dstextab,1,1) != '0'; 
      
      -- Buscar saldo devedor
      EMPR0001.pc_saldo_devedor_epr (pr_cdcooper   => pr_cdcooper     --> Cooperativa conectada
                                    ,pr_cdagenci   => 1               --> Codigo da agencia
                                    ,pr_nrdcaixa   => 0               --> Numero do caixa
                                    ,pr_cdoperad   => '1'             --> Codigo do operador
                                    ,pr_nmdatela   => 'ATENDA'        --> Nome datela conectada
                                    ,pr_idorigem   => 1 --Ayllos      --> Indicador da origem da chamada
                                    ,pr_nrdconta   => pr_nrdconta     --> Conta do associado
                                    ,pr_idseqttl   => 1               --> Sequencia de titularidade da conta
                                    ,pr_rw_crapdat => rw_crapdat      --> Vetor com dados de parametro (CRAPDAT)
                                    ,pr_nrctremp   => 0               --> Numero contrato emprestimo
                                    ,pr_cdprogra   => 'B1WGEN0001'    --> Programa conectado
                                    ,pr_inusatab   => vr_inusatab     --> Indicador de utilizacao da tabela
                                    ,pr_flgerlog   => 'N'             --> Gerar log S/N
                                    ,pr_vlsdeved   => vr_vlendivi     --> Saldo devedor calculado
                                    ,pr_vltotpre   => vr_vltotpre     --> Valor total das prestacaes
                                    ,pr_qtprecal   => vr_qtprecal     --> Parcelas calculadas
                                    ,pr_des_reto   => vr_des_reto     --> Retorno OK / NOK
                                    ,pr_tab_erro   => vr_tab_erro);   --> Tabela com possives erros

      -- Se houve retorno de erro
      IF vr_des_reto = 'NOK' THEN
        -- Extrair o codigo e critica de erro da tabela de erro
        vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
        vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
        
        -- Limpar tabela de erros
        vr_tab_erro.DELETE;
        
        RAISE vr_exc_saida;
      END IF;
      
      -- Enviaremos os dados básicos encontrados na tabela 
      vr_obj_generico.put('documento', este0002.fn_mask_cpf_cnpj(rw_crapass.nrcpfcgc,rw_crapass.inpessoa));
    
      -- Para Pessoas Fisicas 
      IF rw_crapass.inpessoa = 1 THEN
        vr_obj_generico.put('tipoPessoa', 'FISICA');
        -- Buscar dados do titular 
        OPEN cr_crapttl;
        FETCH cr_crapttl
          INTO rw_crapttl;
        CLOSE cr_crapttl;
      
        vr_obj_generico.put('nome', rw_crapttl.nmextttl);
        
        IF rw_crapttl.cdsexotl = 1 THEN
          vr_obj_generico.put('sexo', 'MASCULINO'); 
        ELSE
          vr_obj_generico.put('sexo', 'FEMININO');      
        END IF;
        
        vr_obj_generico.put('dataNascimento'
                           ,este0002.fn_data_ibra_motor(rw_crapass.dtnasctl));              
        -- Se o Documento for RG
        IF rw_crapttl.tpdocttl = 'CI' THEN
          vr_obj_generico.put('rg', rw_crapttl.nrdocttl);
          vr_obj_generico.put('ufRg', rw_crapttl.cdoedttl);
        END IF;
        vr_obj_generico.put('nomeMae', rw_crapttl.nmmaettl);
     /*vr_obj_generico.put('tipoNacionalidade',rw_crapttl.tpnacion);*/
        vr_obj_generico.put('nacionalidade'  ,rw_crapttl.dsnacion);
      
        -- Montar objeto profissao       
        IF rw_crapttl.dsproftl <> ' ' THEN
          vr_obj_generic2 := json();
          vr_obj_generic2.put('titulo', rw_crapttl.dsproftl);
          vr_obj_generico.put('profissao', vr_obj_generic2);
        END IF;
      
        -- Buscar endereço residencial
        OPEN cr_crapenc(10);
        FETCH cr_crapenc
          INTO rw_crapenc;
        CLOSE cr_crapenc;
      
      ELSE
        vr_obj_generico.put('tipoPessoa', 'JURIDICA');
        -- Buscar dados da conta PJ
        OPEN cr_crapjur;
        FETCH cr_crapjur
          INTO rw_crapjur;
        CLOSE cr_crapjur;
      
        vr_obj_generico.put('razaoSocial', rw_crapjur.nmextttl);
        vr_obj_generico.put('dataFundacao'
                           ,este0002.fn_data_ibra_motor(rw_crapjur.dtiniatv));
      
        -- Buscar endereço comercial
        OPEN cr_crapenc(9);
        FETCH cr_crapenc
          INTO rw_crapenc;
        CLOSE cr_crapenc;
      
      END IF;
    
      -- Montar objeto Telefone para Telefones Celular/Residencial/Comercial      
      vr_lst_generic2 := json_list();
      -- Criar objeto só para este telefone
      vr_obj_generic2 := json();
      -- Buscar todos os registros
      FOR rw_craptfc IN cr_craptfc LOOP
        -- Para pessoa Juridica sempre enviamos comercial
        IF rw_crapass.inpessoa = 2 THEN
          vr_obj_generic2.put('especie', 'COMERCIAL');
        ELSE
          -- Para pessoa Fisica temos de testar 
          IF rw_craptfc.tptelefo = 3 THEN
            vr_obj_generic2.put('especie', 'COMERCIAL');
          ELSE
            vr_obj_generic2.put('especie', 'DOMICILIO');
          END IF;
        END IF;
      
        -- Celular
        IF rw_craptfc.tptelefo = 2 THEN
          vr_obj_generic2.put('tipo', 'MOVEL');
        ELSE
          vr_obj_generic2.put('tipo', 'FIXO');
        END IF;
      
        vr_obj_generic2.put('ddd', rw_craptfc.nrdddtfc);
        vr_obj_generic2.put('numero',este0002.fn_somente_numeros_telefone(rw_craptfc.nrtelefo));
        -- Adicionar telefone na lista
        vr_lst_generic2.append(vr_obj_generic2.to_json_value());
      END LOOP;
      -- Adicionar o array telefone no objeto
      vr_obj_generico.put('telefones', vr_lst_generic2);
    
      -- Montar objeto Endereco
      IF rw_crapenc.dsendere <> ' ' THEN
        vr_obj_generic2 := json();
      
        vr_obj_generic2.put('logradouro', rw_crapenc.dsendere);
        vr_obj_generic2.put('numero', rw_crapenc.nrendere);
        vr_obj_generic2.put('complemento', rw_crapenc.complend);
        vr_obj_generic2.put('bairro', rw_crapenc.nmbairro);
        vr_obj_generic2.put('cidade', rw_crapenc.nmcidade);
        vr_obj_generic2.put('uf', rw_crapenc.cdufende);
        vr_obj_generic2.put('cep', rw_crapenc.nrcepend);
        -- Adicionar o array endereco no objeto
        vr_obj_generico.put('endereco', vr_obj_generic2);
      END IF;
    
      -- Montar informaçoes Adicionais
      vr_obj_generic2 := json();
    
      -- Caixa Postal
      IF rw_crapenc.nrcxapst <> 0 THEN
        vr_obj_generic2.put('caixaPostal', rw_crapenc.nrcxapst);
      END IF;
    
      -- Conta
   vr_obj_generic2.put('conta', to_number(substr(pr_nrdconta,1,length(pr_nrdconta)-1)));
   vr_obj_generic2.put('contaDV', to_number(substr(pr_nrdconta,-1)));
    
      -- Agencia
      vr_obj_generic2.put('agenci', rw_crapass.cdagenci);
    
    -- Data Admissao Coop
   vr_obj_generic2.put('dataAdmissaoCoop', este0002.fn_data_ibra_motor(NVL(rw_crapass.dtmvtolt,rw_crapass.dtadmiss)));
   
      -- Matricula
      vr_obj_generic2.put('matric', rw_crapass.nrmatric);
    
      -- Tipo da Conta
      vr_obj_generic2.put('tipoConta'
                         ,rw_crapass.cdtipcta);
    
      -- Situaçao da Conta
      vr_obj_generic2.put('situacaoConta'
                         ,rw_crapass.cdsitdct);
    
      -- Email
      OPEN cr_crapcem;
      FETCH cr_crapcem INTO vr_dsdemail;
      CLOSE cr_crapcem;
      vr_obj_generic2.put('email',vr_dsdemail);
    
      -- Tipo do Imóvel
      IF rw_crapenc.incasprp <> 0 THEN
        vr_obj_generic2.put('tipoImovel'
                           ,rw_crapenc.incasprp);
      END IF;
      
      -- Valor do Imovel (Somente quando nao for alugado)
      IF rw_crapenc.vlalugue > 0 AND rw_crapenc.incasprp NOT IN (0, 3) THEN
        vr_obj_generic2.put('valorImovel',este0001.fn_decimal_ibra(rw_crapenc.vlalugue));
        vr_obj_generic2.put('valorAluguel',este0001.fn_decimal_ibra(0));
        /*vr_vlalugue := 0;*/
   ELSE
    -- Quando alugado enviaremos valor Aluguel
    vr_obj_generic2.put('valorImovel',este0001.fn_decimal_ibra(0));
        vr_obj_generic2.put('valorAluguel', este0001.fn_decimal_ibra(rw_crapenc.vlalugue));
        /*vr_vlalugue := rw_crapenc.vlalugue;*/
   END IF;    
   
   -- Busca dos bens do associado CURSOR cr_crapbem e vr_vlrtotbem
   OPEN cr_crapbem;
   FETCH cr_crapbem
    INTO vr_vltotbem;
   CLOSE cr_crapbem;

   -- Se o titular possui bens
   vr_obj_generic2.put('valorTotalBens', este0001.fn_decimal_ibra(vr_vltotbem));
   
      -- Data de Inicio de Residencia
      IF rw_crapenc.dtinires IS NOT NULL THEN
        vr_obj_generic2.put('inicioResidImovel'
                           ,este0002.fn_data_ibra_motor(rw_crapenc.dtinires));
      END IF;
    
      -- Data de demissao na Cooperativa
      IF rw_crapass.dtelimin IS NOT NULL THEN
        vr_obj_generic2.put('dataDemissao'
                           ,este0002.fn_data_ibra_motor(rw_crapass.dtelimin));
      END IF;
     
   -- Data da consulta no SPC 
   IF rw_crapass.dtcnsspc IS NOT NULL THEN
    vr_obj_generic2.put('dataConsultaSPC'
              ,este0002.fn_data_ibra_motor(rw_crapass.dtcnsspc));
   END IF;
      
   -- Data da inclusao no SPC pela cooperativa
   IF rw_crapass.dtdsdspc IS NOT NULL THEN
        vr_obj_generic2.put('dataInclusaoSPCpelaCoop'
                           ,este0002.fn_data_ibra_motor(rw_crapass.dtdsdspc));
      END IF;
    
      -- Está no SPC(cooperativa)
      vr_obj_generic2.put('SPCpelaCoop'
                         ,NVL(rw_crapass.inadimpl,0)=1);
    
      -- Está no SPC(outras IFs)
      sspc0001.pc_busca_consulta_biro(pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_nrconbir => vr_nrconbir
                                     ,pr_nrseqdet => vr_nrseqdet);
      -- Se encontrar 
      IF NVL(vr_nrconbir,0) > 0 AND NVL(vr_nrseqdet,0) > 0 THEN 
        -- Buscar o detalhamento da consulta
        sspc0001.pc_verifica_situacao(pr_nrconbir => vr_nrconbir
                                     ,pr_nrseqdet => vr_nrseqdet
                                     ,pr_cdbircon => vr_cdbircon
                                     ,pr_dsbircon => vr_dsbircon
                                     ,pr_cdmodbir => vr_cdmodbir
                                     ,pr_dsmodbir => vr_dsmodbir
                                     ,pr_flsituac => vr_flsituac);
      END IF;
      vr_obj_generic2.put('SPCoutrasIFs',vr_flsituac='S');
    
      -- CCF
      vr_obj_generic2.put('ccf', NVL(rw_crapass.inccfcop,0)=1);
    
      -- Cadastro Positivo
      vr_obj_generic2.put('cadastroPositivo'
                         ,rw_crapass.incadpos);
    
      -- Data Consulta SCR
      IF rw_crapass.dtcnsscr IS NOT NULL THEN
        vr_obj_generic2.put('dataConsultaSCR'
                           ,este0002.fn_data_ibra_motor(rw_crapass.dtcnsscr));
      END IF;
      
      -- PreAprovado
      vr_flglibera_pre_aprv := 0;
      
      -- Busca a carga ativa
      EMPR0002.pc_busca_carga_ativa(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_idcarga  => vr_idcarga);
      --  Caso nao possua carga ativa
      IF vr_idcarga > 0 THEN
        --> Verifica se esta na tabela do pre-aprovado
        OPEN cr_crapcpa(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_idcarga  => vr_idcarga);
        FETCH cr_crapcpa INTO rw_crapcpa;
        -- Somente casa Haja
        IF cr_crapcpa%FOUND THEN
          CLOSE cr_crapcpa;
          -- Verifica se existe Bloqueio em Conta
          OPEN cr_preapv;
          FETCH cr_preapv
            INTO vr_flglibera_pre_aprv;
          -- Se nao encontrou
          IF cr_preapv%NOTFOUND THEN
            -- Tratar como liberado
            vr_flglibera_pre_aprv := 1;
          END IF;
          CLOSE cr_preapv;
        ELSE
          vr_vllimdis := rw_crapcpa.vllimdis;
          CLOSE cr_crapcpa;
        END IF; 
      END IF;

      vr_obj_generic2.put('liberaPreAprovad', (nvl(vr_flglibera_pre_aprv,0)=1));
      vr_obj_generic2.put('limitePreAprovado', este0001.fn_decimal_ibra(nvl(vr_vllimdis,0)));

      -- Data Ultima Revisao Cadastral      
      OPEN cr_revisa;
      FETCH cr_revisa
        INTO vr_dtaltera;
      CLOSE cr_revisa;
    
      IF vr_dtaltera IS NOT NULL THEN
        vr_obj_generic2.put('dataUltimaRevCadast', este0002.fn_data_ibra_motor(vr_dtaltera));
      END IF;
    
      vr_indexis := 0;
      OPEN cr_alerta;
      FETCH cr_alerta
        INTO vr_indexis;
      CLOSE cr_alerta;
    
      vr_obj_generic2.put('estaALERTA', (vr_indexis=1));
    
      -- Conta tem Registro Contra Ordem
      vr_obj_generic2.put('estaDCTROR'
                         ,(NVL(rw_crapass.cdsitdtl,0) = 2));
          
      -- Buscar as informaçoes do Arquivo SCR   
      OPEN cr_crapopf;
      FETCH cr_crapopf
        INTO rw_crapopf;
      
      IF cr_crapopf%FOUND THEN
        CLOSE cr_crapopf;
          
        -- Na sequencia buscar os valores dos vencimentos
        OPEN cr_crapvop(rw_crapass.nrcpfcgc);
        FETCH cr_crapvop
          INTO rw_crapvop;
        CLOSE cr_crapvop;    
          
        -- Enfim, enviar as informaçoes ao JSON
        vr_obj_generic2.put('conscrOpSFN'
                           ,este0001.fn_decimal_ibra(rw_crapvop.vlopesfn));
        vr_obj_generic2.put('conscrOpVenc'
                           ,este0001.fn_decimal_ibra(rw_crapvop.vlopevnc));
        vr_obj_generic2.put('conscrOpPrej'
                           ,este0001.fn_decimal_ibra(rw_crapvop.vlopeprj));
        vr_obj_generic2.put('conscrQtOper', rw_crapopf.qtopesfn);
        vr_obj_generic2.put('conscrQtIFs', rw_crapopf.qtifssfn);
        vr_obj_generic2.put('conscr61a90'
                           ,este0001.fn_decimal_ibra(rw_crapvop.vlvcto130));        
      ELSE         
        CLOSE cr_crapopf;
        
        -- Enfim, enviar as informaçoes ao JSON
        vr_obj_generic2.put('conscrOpSFN'
                           ,este0001.fn_decimal_ibra(0));
        vr_obj_generic2.put('conscrOpVenc'
                           ,este0001.fn_decimal_ibra(0));
        vr_obj_generic2.put('conscrOpPrej'
                           ,este0001.fn_decimal_ibra(0));
        vr_obj_generic2.put('conscrQtOper', 0);
        vr_obj_generic2.put('conscrQtIFs', 0);
        vr_obj_generic2.put('conscr61a90'
                           ,este0001.fn_decimal_ibra(0));  
        
      END IF;   
      
      -- Buscar outras propostas em Andamento      
      OPEN cr_crawepr_outras;
      FETCH cr_crawepr_outras
        INTO rw_crawepr_outras;
      CLOSE cr_crawepr_outras;
    
      -- Propostas Em Andamento
      vr_obj_generic2.put('somaOperacoesAndamento',este0001.fn_decimal_ibra(nvl(rw_crawepr_outras.vlsdeved,0)));
      vr_obj_generic2.put('somaPrestacoesAndamento',este0001.fn_decimal_ibra(nvl(rw_crawepr_outras.vlpreemp,0)));
      
      -- Soma das Operaçoes em Andamento
      vr_obj_generic2.put('somaOperacoes',este0001.fn_decimal_ibra(nvl(vr_vlendivi,0)));
      vr_obj_generic2.put('somaPrestacoes',este0001.fn_decimal_ibra(nvl(vr_vltotpre,0)));
      
      -- Somente para Pessoa Fisica
      IF rw_crapass.inpessoa = 1 THEN
      
        -- Nome Pai
        IF rw_crapttl.nmpaittl <> ' ' THEN
          vr_obj_generic2.put('nomePai', rw_crapttl.nmpaittl);
        END IF;
      
        -- Estado Civil
        IF rw_crapttl.cdestcvl <> 0 THEN
          vr_obj_generic2.put('estadoCivil'
                             ,rw_crapttl.cdestcvl);
        END IF;
      
        -- Naturalidade
        IF rw_crapttl.dsnatura <> ' ' THEN
          vr_obj_generic2.put('naturalidadeDescricao', rw_crapttl.dsnatura);
        END IF;
      
        -- Habilitaçao Menor
        vr_obj_generic2.put('reponsabiLegal',rw_crapttl.inhabmen);
      
        -- Data Emancipaçao
        IF rw_crapttl.dthabmen IS NOT NULL THEN
          vr_obj_generic2.put('dataEmancipa'
                             ,este0002.fn_data_ibra_motor(rw_crapttl.dthabmen));
        END IF;
      
        -- Valor Rendimento
        IF pr_vlsalari > rw_crapttl.vlrendim THEN 
          vr_obj_generic2.put('valorSalario'
                             ,este0001.fn_decimal_ibra(pr_vlsalari));
        ELSE
          vr_obj_generic2.put('valorSalario'
                             ,este0001.fn_decimal_ibra(rw_crapttl.vlrendim));            
        END IF;
      
        -- Outros Rendimentos
        vr_obj_generic2.put('valorOutrosRendim'
                           ,este0001.fn_decimal_ibra(rw_crapttl.vroutrorn));
        
        -- Data Consulta CPF
        IF rw_crapttl.dtcnscpf IS NOT NULL THEN
          vr_obj_generic2.put('dataConsultaCPF'
                             ,este0002.fn_data_ibra_motor(rw_crapttl.dtcnscpf));
        END IF;
      
        -- Situaçao CPF
        vr_obj_generic2.put('situacaoCPF'
                           ,rw_crapttl.cdsitcpf);
      
        -- Escolaridade
        IF rw_crapttl.grescola <> 0 THEN
          vr_obj_generic2.put('escolaridade'
                             ,rw_crapttl.grescola);
        END IF;
      
        -- Curso Superior
        IF rw_crapttl.cdfrmttl <> 0 THEN
          vr_obj_generic2.put('cursoSuperiorCodigo'
                             ,rw_crapttl.cdfrmttl);
          vr_obj_generic2.put('cursoSuperiorDescricao'
                             ,este0002.fn_des_cdfrmttl(rw_crapttl.cdfrmttl));
               
        END IF;
      
        -- Natureza Ocupaçao
        IF rw_crapttl.cdnatopc <> 0 THEN
          vr_obj_generic2.put('naturezaOcupacao'
                             ,rw_crapttl.cdnatopc);
        END IF;
      
        -- Ocupaçao
        IF rw_crapttl.cdocpttl <> 0 THEN
          vr_obj_generic2.put('ocupacaoCodigo'
                             ,rw_crapttl.cdocpttl);
          vr_obj_generic2.put('ocupacaoDescricao'
                             ,este0002.fn_des_cdocupa(rw_crapttl.cdocpttl));               
        END IF;
      
        -- Tipo Contrato de Trabalho
        IF rw_crapttl.tpcttrab <> 0 THEN
          vr_obj_generic2.put('tipoContratoTrabalho'
                             ,rw_crapttl.tpcttrab);
        END IF;
      
        -- Nivel Cargo
        IF rw_crapttl.cdnvlcgo <> 0 THEN
          vr_obj_generic2.put('nivelCargo'
                             ,rw_crapttl.cdnvlcgo);
        END IF;
      
        -- Turno
        IF rw_crapttl.cdturnos <> 0 THEN
          vr_obj_generic2.put('turno'
                             ,rw_crapttl.cdturnos);
        END IF;
      
        -- Data Admissao
        IF rw_crapttl.dtadmemp IS NOT NULL THEN
          vr_obj_generic2.put('dataAdmissao'
                             ,este0002.fn_data_ibra_motor(rw_crapttl.dtadmemp));
        END IF;
      
        -- CNPJ Empresa
        IF rw_crapttl.nrcpfemp <> 0 THEN
          vr_obj_generic2.put('codCNPJEmpresa', rw_crapttl.nrcpfemp);
        END IF;
      
        -- Tipo Comprovante de Renda
        IF rw_crapttl.cdnatopc = 8 THEN
          vr_tpcmpvrn := 'C';
        ELSIF rw_crapttl.tpcttrab = 1 THEN
          vr_tpcmpvrn := 'F';
        ELSIF rw_crapttl.tpcttrab = 4 THEN
          vr_tpcmpvrn := 'R';
        ELSE
          vr_tpcmpvrn := 'S';
        END IF;
      
        vr_obj_generic2.put('tipoComprovanteRenda', vr_tpcmpvrn);
      
        -- Pessoa Politicamente Exposta
        vr_obj_generic2.put('pessoaPoliticamenteExposta'
                           ,(NVL(rw_crapttl.inpolexp,0)=1));
      
        OPEN cr_depend;
        FETCH cr_depend
          INTO vr_qtdepend;
        CLOSE cr_depend;
      
        vr_obj_generic2.put('quantDependentes', vr_qtdepend);
      
      ELSE
      
        -- Faturamento Annual 
        vr_obj_generic2.put('valorFaturamentoAnual'
                           ,este0001.fn_decimal_ibra(rw_crapjur.vlfatano));
        
        -- Data Consulta CNPJ
        IF rw_crapass.dtcnscpf IS NOT NULL THEN
          vr_obj_generic2.put('dataConsultaCNPJ'
                             ,este0002.fn_data_ibra_motor(rw_crapass.dtcnscpf));
        END IF;
      
        -- Situaçao CNPJ
        vr_obj_generic2.put('situacaoCNPJ'
                           ,rw_crapass.cdsitcpf);
      
        -- Nome Fantasia
        IF rw_crapjur.nmfansia <> ' ' THEN
          vr_obj_generic2.put('nomeFantasia', rw_crapjur.nmfansia);
        END IF;
      
        -- Natureza Juridica
        IF rw_crapjur.natjurid <> 0 THEN
          -- Buscar descriçao          
          OPEN cr_nature(rw_crapjur.natjurid);
          FETCH cr_nature
            INTO vr_dsnatjur;
          CLOSE cr_nature;
        
          vr_obj_generic2.put('naturezaJuridicaCodigo'
                             ,rw_crapjur.natjurid);
          vr_obj_generic2.put('naturezaJuridicaDescricao'
                             ,vr_dsnatjur);               
        END IF;
      
        -- Quantidade Filiais
        vr_obj_generic2.put('quantFiliais', rw_crapjur.qtfilial);
      
        -- Quantidade Funcionários
        vr_obj_generic2.put('quantFuncionarios', rw_crapjur.qtfuncio);
      
        -- Ramo Atividade
        IF rw_crapjur.cdseteco <> 0 AND rw_crapjur.cdrmativ <> 0 THEN
          -- Buscar descriçao          
          OPEN cr_ramatv(rw_crapjur.cdseteco
                   ,rw_crapjur.cdrmativ);
          FETCH cr_ramatv
            INTO vr_dsramatv;
          CLOSE cr_ramatv;
        
          vr_obj_generic2.put('ramoAtividadeCodigo'
                             ,rw_crapjur.cdrmativ);
          vr_obj_generic2.put('ramoAtividadeDescricao'
                             ,vr_dsramatv);
               
        END IF;
      
        -- Setor Economico
        IF rw_crapjur.cdseteco <> 0 THEN
        
          -- Buscar descriçao
          vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                   ,pr_nmsistem => 'CRED'
                                                   ,pr_tptabela => 'GENERI'
                                                   ,pr_cdempres => 0
                                                   ,pr_cdacesso => 'SETORECONO'
                                                   ,pr_tpregist => rw_crapjur.cdseteco);
          -- Se Encontrou
          IF TRIM(vr_dstextab) IS NOT NULL THEN
            vr_nmseteco := vr_dstextab;
          ELSE
            vr_nmseteco := 'Nao Cadastrado';
          END IF;
          vr_obj_generic2.put('setorEconomicoCodigo'
                             ,rw_crapjur.cdseteco);
     vr_obj_generic2.put('setorEconomicoDescricao'
                             ,vr_nmseteco);
        END IF;
    
       -- Buscar faturamento médio mensal
    cada0001.pc_calcula_faturamento(pr_cdcooper => pr_cdcooper
                    ,pr_cdagenci => 1
                    ,pr_nrdcaixa => 1
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_vlmedfat => vr_vlmedfat
                    ,pr_tab_erro => vr_tab_erro
                    ,pr_des_reto => vr_des_reto);

    -- Media Faturamento Anual
    vr_obj_generic2.put('mediaFaturamentoAnual', este0001.fn_decimal_ibra(round(vr_vlmedfat,0)));
      
        -- Valor Faturamento Anual
        vr_obj_generic2.put('valorFaturamentoAnual'
                           ,este0001.fn_decimal_ibra(rw_crapjur.vlfatano));
      
        -- Valor Faturamento Anual
        vr_obj_generic2.put('valorFaturamentoAnual'
                           ,este0001.fn_decimal_ibra(rw_crapjur.vlfatano));
      
        -- Capital Realizado
        vr_obj_generic2.put('capitalRealizado'
                           ,este0001.fn_decimal_ibra(rw_crapjur.vlcaprea));
      
        -- Data de registro da empresa
        IF rw_crapjur.dtregemp IS NOT NULL THEN
          vr_obj_generic2.put('dataRegistroEmpresa'
                             ,este0002.fn_data_ibra_motor(rw_crapjur.dtregemp));
        END IF;
      
        -- Orgao de Registro da Empresa
        IF rw_crapjur.orregemp IS NOT NULL THEN
          vr_obj_generic2.put('orgaoRegistroEmpresa', rw_crapjur.orregemp);
        END IF;
      
        -- Numero Registro Empresa
        IF rw_crapjur.nrregemp <> 0 THEN
          vr_obj_generic2.put('numeroRegistroEmpresa', rw_crapjur.nrregemp);
        END IF;
      
        -- Data Inscriçao Municipal
        IF rw_crapjur.dtinsnum IS NOT NULL THEN
          vr_obj_generic2.put('dataInscricMunicipal'
                             ,este0002.fn_data_ibra_motor(rw_crapjur.dtinsnum));
        END IF;
      
        -- Numero Inscriçao Municipal
        IF rw_crapjur.nrinsmun <> 0 THEN
          vr_obj_generic2.put('numeroInscricMunicipal'
                             ,rw_crapjur.nrinsmun);
        END IF;
      
        -- Numero Inscriçao Estadual
        IF rw_crapjur.nrinsest <> 0 THEN
          vr_obj_generic2.put('numeroInscricEstadual', rw_crapjur.nrinsest);
        END IF;
      
        -- Participante REFIS
        vr_obj_generic2.put('optanteRefis'
                           ,(nvl(rw_crapjur.flgrefis,0)=1));
      
        -- Numero Nire
        IF rw_crapjur.nrcdnire <> 0 THEN
          vr_obj_generic2.put('numeroNIRE', rw_crapjur.nrcdnire);
        END IF;
      
        -- CNAE
        IF rw_crapass.cdclcnae <> 0 THEN
          -- Buscar descriçao          
          OPEN cr_cnae(rw_crapass.cdclcnae);
          FETCH cr_cnae
            INTO vr_dscnae;
          CLOSE cr_cnae;
        
          vr_obj_generic2.put('cnaeCodigo'
                             ,rw_crapass.cdclcnae);
          vr_obj_generic2.put('cnaeDescricao'
                             ,vr_dscnae);               
        END IF;
      
        -- Buscar informaçoes do Faturamento
        OPEN cr_crapjfn;
        FETCH cr_crapjfn
          INTO rw_crapjfn;
        CLOSE cr_crapjfn;
      
        -- Percentual faturamento cliente único
        IF rw_crapjfn.perfatcl <> 0 THEN
          vr_obj_generic2.put('percentFaturamenMaiorCliente'
                             ,este0001.fn_decimal_ibra(rw_crapjfn.perfatcl));
        END IF; 
      END IF;
         
      -- Verificar se houve prejuizo do Cooperado na Cooperativa  
      OPEN cr_crapepr_preju;
      FETCH cr_crapepr_preju
        INTO rw_crapepr_preju;
    
      IF cr_crapepr_preju%FOUND OR rw_crapass.cdsitdtl IN (5, 6, 7, 8) THEN
        vr_flprjcop := TRUE;
      ELSE
        vr_flprjcop := FALSE;
      END IF;
      CLOSE cr_crapepr_preju;
    
      -- Enviar causouPrejuizoCoop
      vr_obj_generic2.put('causouPrejuizoCoop', vr_flprjcop);
    
      -- Verificar se ha emprestimo nas linhas 800 e 900
      OPEN cr_crapepr_800_900;
      FETCH cr_crapepr_800_900
        INTO rw_crapepr_800_900;
    
      IF cr_crapepr_800_900%FOUND THEN
        vr_fl800900 := TRUE;
      ELSE
        vr_fl800900 := FALSE;
      END IF;
    
      -- Enviar temLinha800e900
      vr_obj_generic2.put('temLinha800e900', vr_fl800900);
    
      -- Buscar o Saldo do Cooperado (Declarar vr_vladtdep)
      extr0001.pc_obtem_saldo_dia(pr_cdcooper   => pr_cdcooper
                                 ,pr_rw_crapdat => rw_crapdat
                                 ,pr_cdagenci   => 1
                                 ,pr_nrdcaixa   => 1
                                 ,pr_cdoperad   => '1'
                                 ,pr_nrdconta   => pr_nrdconta
                                 ,pr_vllimcre   => rw_crapass.vllimcre
                                 ,pr_dtrefere   => rw_crapdat.dtmvtolt
                                 ,pr_flgcrass   => FALSE
                                 ,pr_des_reto   => vr_des_reto
                                 ,pr_tab_sald   => vr_tab_sald
                                 ,pr_tab_erro   => vr_tab_erro);
    
      if  vr_tab_sald.count > 0 then
          if  vr_tab_sald(0).vlsddisp < 0 then
              if  abs(vr_tab_sald(0).vlsddisp) > vr_tab_sald(0).vllimcre then
                  vr_vladtdep := vr_tab_sald(0).vllimcre + vr_tab_sald(0).vlsddisp;
              else
                  vr_vladtdep := 0;
              end if;
          else
              vr_vladtdep := 0;
          end if;
      else
          vr_vladtdep := 0;
      end if;
    
      -- Enviar o valorAdiantDeposit
      vr_obj_generic2.put('valorAdiantDeposit'
                         ,este0001.fn_decimal_ibra(vr_vladtdep));
    
   -- Buscar parâmetro da quantidade de meses para busca dos Estouros/Adiantamentos
   vr_qtmesest := gene0001.fn_param_sistema('CRED',pr_cdcooper,'QTD_MES_HIST_EST_DESC');
              
      -- Montar objeto para Estrutura Estouros
      vr_lst_generic3 := json_list();
    
      /* Inicializar */  
      vr_qqdiacheq := 0;
    
      /* Obter as informaoes de estouro do cooperado */
      RISC0001.pc_lista_estouros( pr_cdcooper      => pr_cdcooper     --> Codigo Cooperativa
                                 ,pr_cdoperad      => '1'             --> Operador conectado
                                 ,pr_nrdconta      => pr_nrdconta     --> Numero da Conta
                                 ,pr_idorigem      => 5               --> Identificador Origem
                                 ,pr_idseqttl      => 1               --> Sequencial do Titular
                                 ,pr_nmdatela      => 'RATI0001'      --> Nome da tela
                                 ,pr_dtmvtolt      => rw_crapdat.dtmvtolt --> Data do movimento
                                 ,pr_tab_estouros  => vr_tab_estouros --> Informaçoes de estouro na conta
                                 ,pr_dscritic      => vr_dscritic);   --> Retorno de erro

      -- verificar se retornou critica
      IF vr_dscritic is not null THEN
        raise vr_exc_saida;
      END IF;

      /* Data do inicio do estouro a partir de um ano atras */
      vr_dtiniest := add_months(rw_crapdat.dtmvtolt, -vr_qtmesest);

      -- varrer temptable de estouro
      IF vr_tab_estouros.count > 0 THEN
        FOR I IN vr_tab_estouros.FIRST..vr_tab_estouros.LAST LOOP
          IF vr_tab_estouros(I).dtiniest >= vr_dtiniest AND vr_tab_estouros(I).cdhisest  = 'Estouro' THEN
            -- Para cada registro de Estouro, criar objeto para a operaçao e enviar suas informaçoes 
            vr_obj_generic3 := json();        
            
            vr_obj_generic3.put('quantDiaEstouro', vr_tab_estouros(I).qtdiaest);
            vr_obj_generic3.put('dataEstouro'
                               ,este0002.fn_data_ibra_motor(vr_tab_estouros(I).dtiniest));
            vr_obj_generic3.put('valorEstouro'
                               ,este0001.fn_decimal_ibra(vr_tab_estouros(I).vlestour));
                               
            -- Adicionar Operaçao na lista
            vr_lst_generic3.append(vr_obj_generic3.to_json_value());  
            

          END IF;
        END LOOP;
      END IF;
      
      -- Adicionar o array Estouros no objeto informaçoes adicionais
   vr_obj_generic2.put('estouro', vr_lst_generic3);  
      
      -- Verificar se cooperado possui contrato de
      -- limite de credito no periodo
      OPEN cr_craplim( pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta,
                       pr_dtiniest => vr_dtiniest);
      FETCH cr_craplim INTO rw_craplim;
      
      
      -- se nao possuir contrato de limite de credito, nao precisa
      -- verificar a sda
      IF cr_craplim%NOTFOUND THEN                 
        CLOSE cr_craplim;
      ELSE
        CLOSE cr_craplim;                  
        -- Varrer tabela de saldo do dia
        FOR rw_crapsda IN cr_crapsda ( pr_cdcooper => pr_cdcooper,
                                       pr_nrdconta => pr_nrdconta,
                                       pr_dtiniest => vr_dtiniest) LOOP

          -- se o saldo for negativo e o maior que o limite de credito
          IF rw_crapsda.vlsddisp < 0  AND
             rw_crapsda.vlsddisp >= (rw_crapsda.vllimcre*-1) THEN
            vr_qtdiaat2 := nvl(vr_qtdiaat2,0) + 1;
          ELSE
            -- armazenar maior data
            IF nvl(vr_qtdiaat2,0) > nvl(vr_qqdiacheq,0) THEN
              vr_qqdiacheq := nvl(vr_qtdiaat2,0);
            END IF;
            vr_qtdiaat2 := 0;
          END IF;

        END LOOP;
      END IF; -- FIM IF cr_craplim%NOTFOUND 



      -- se nao possuir proposta de limite de credito, nao precisa
      -- verificar a sda
      IF cr_crawlim%NOTFOUND THEN                 
        CLOSE cr_crawlim;
      ELSE
        CLOSE cr_crawlim;                  
        -- Varrer tabela de saldo do dia
        FOR rw_crapsda IN cr_crapsda ( pr_cdcooper => pr_cdcooper,
                                       pr_nrdconta => pr_nrdconta,
                                       pr_dtiniest => vr_dtiniest) LOOP

          -- se o saldo for negativo e o maior que o limite de credito
          IF rw_crapsda.vlsddisp < 0  AND
             rw_crapsda.vlsddisp >= (rw_crapsda.vllimcre*-1) THEN
            vr_qtdiaat2 := nvl(vr_qtdiaat2,0) + 1;
          ELSE
            -- armazenar maior data
            IF nvl(vr_qtdiaat2,0) > nvl(vr_qqdiacheq,0) THEN
              vr_qqdiacheq := nvl(vr_qtdiaat2,0);
            END IF;
            vr_qtdiaat2 := 0;
          END IF;

        END LOOP;
      END IF; -- FIM IF cr_crawlim%NOTFOUND 

      
      
      
      

      IF vr_qqdiacheq = 0  THEN
        vr_qqdiacheq := vr_qtdiaat2;
      END IF;

      IF vr_qtdiaat2 > vr_qqdiacheq THEN
        vr_qqdiacheq := vr_qtdiaat2;
      END IF;
    
      -- Enviar informaçoes de Cheque Especial 
      vr_obj_generic2.put('quantDiasChequeEspecial', NVL(vr_qqdiacheq,0));
      
      -- Buscar Contrato Limite Crédito    
      OPEN cr_crawlim_chqesp;
      FETCH cr_crawlim_chqesp
        INTO rw_crawlim_chqesp;
      CLOSE cr_crawlim_chqesp;
    
      -- Enviar as informaçoes do limite de crédito (somente se houver limite de crédito)
      IF rw_crawlim_chqesp.vllimite > 0 THEN
        vr_obj_generic2.put('dataContratoLimiteCred'
                           ,este0002.fn_data_ibra_motor(rw_crawlim_chqesp.dtinivig));
        vr_obj_generic2.put('limiteCredito'
                           ,este0001.fn_decimal_ibra(rw_crawlim_chqesp.vllimite));
      
        -- Enviar saldo utilizado do limite de crédito
        if  vr_tab_sald.count > 0 then
            if  vr_tab_sald(0).vlsddisp < 0 THEN
                -- Se temos adiantamento a depositante 
                IF  vr_vladtdep < 0 THEN
                    -- Estamos usando todo o limite
                    vr_obj_generic2.put('saldoUtilizLimiteCredito',este0001.fn_decimal_ibra(rw_crawlim_chqesp.vllimite));
                ELSE
                    -- O Saldo negativo é o valor utilizado 
                    vr_obj_generic2.put('saldoUtilizLimiteCredito',este0001.fn_decimal_ibra(vr_tab_sald(0).vlsddisp));
                END IF;
            ELSE
                vr_obj_generic2.put('saldoUtilizLimiteCredito',este0001.fn_decimal_ibra(0));
            END IF;
        else
            vr_obj_generic2.put('saldoUtilizLimiteCredito',este0001.fn_decimal_ibra(0));
        end if;
      END IF;
    
      -- Chamar rotina para busca das Médias da Conta Corrente
      extr0001.pc_carrega_medias(pr_cdcooper        => pr_cdcooper
                                ,pr_cdagenci        => 1
                                ,pr_nrdcaixa        => 1
                                ,pr_cdoperad        => '1'
                                ,pr_nrdconta        => pr_nrdconta
                                ,pr_dtmvtolt        => rw_crapdat.dtmvtolt
                                ,pr_idorigem        => 5
                                ,pr_idseqttl        => 1
                                ,pr_nmdatela        => 'ATENDA'
                                ,pr_flgerlog        => 0
                                ,pr_tab_medias      => vr_tab_medias
                                ,pr_tab_comp_medias => vr_tab_comp_medias
                                ,pr_cdcritic        => vr_cdcritic
                                ,pr_dscritic        => vr_dscritic);
    
      -- Testar erros e se nao houver, enviar os Saldos Médios
      IF vr_tab_comp_medias.count > 0 THEN 
        vr_obj_generic2.put('saldoMedioAtual'
                           ,este0001.fn_decimal_ibra(vr_tab_comp_medias(vr_tab_comp_medias.first).vltsddis));
        vr_obj_generic2.put('saldoMedioTrimes'
                           ,este0001.fn_decimal_ibra(vr_tab_comp_medias(vr_tab_comp_medias.first).vlsmdtri));
        vr_obj_generic2.put('saldoMedioSemes'
                           ,este0001.fn_decimal_ibra(vr_tab_comp_medias(vr_tab_comp_medias.first).vlsmdsem));
      ELSE
        vr_obj_generic2.put('saldoMedioAtual'
                           ,este0001.fn_decimal_ibra(0));
        vr_obj_generic2.put('saldoMedioTrimes'
                           ,este0001.fn_decimal_ibra(0));
        vr_obj_generic2.put('saldoMedioSemes'
                           ,este0001.fn_decimal_ibra(0));
      END IF;
      
      -- Acionar rotina de ocorrencias na conta 
      cada0004.pc_lista_ocorren(pr_cdcooper    => pr_cdcooper
                               ,pr_cdagenci    => 1
                               ,pr_nrdcaixa    => 1
                               ,pr_cdoperad    => '1'
                               ,pr_nrdconta    => pr_nrdconta
                               ,pr_rw_crapdat  => rw_crapdat
                               ,pr_idorigem    => 5
                               ,pr_idseqttl    => 1
                               ,pr_nmdatela    => 'ATENDA'
                               ,pr_flgerlog    => 0
                               ,pr_tab_ocorren => vr_tab_ocorren
                               ,pr_des_reto    => vr_des_reto
                               ,pr_tab_erro    => vr_tab_erro);
      IF vr_tab_ocorren.count > 0 THEN 
        vr_obj_generic2.put('ratingAtivoConta', vr_tab_ocorren(vr_tab_ocorren.first).inrisctl);
        vr_obj_generic2.put('ratingConta', vr_tab_ocorren(vr_tab_ocorren.first).indrisco);
        vr_obj_generic2.put('riscoCooperado', NVL(trim(vr_tab_ocorren(vr_tab_ocorren.first).nivrisco),'A'));
      ELSE
        vr_obj_generic2.put('ratingAtivoConta', 'A');
        vr_obj_generic2.put('ratingConta', 'A');
        vr_obj_generic2.put('riscoCooperado', 'A');        
      END IF;
      
      -- Buscar risco do grupo econômico (se existir)
      geco0001.pc_busca_grupo_associado(pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_flggrupo => vr_flggrupo
                                       ,pr_nrdgrupo => vr_nrdgrupo
                                       ,pr_gergrupo => vr_gergrupo
                                       ,pr_dsdrisgp => vr_dsdrisgp);
      -- Se houver grupo 
      IF vr_flggrupo = 1 THEN
        vr_obj_generic2.put('riscoGrupoEconomico', vr_dsdrisgp);
      END IF;
        
      -- Buscar Saldo de Cotas
      OPEN cr_crapcot;
      FETCH cr_crapcot
        INTO vr_vldcotas;
      CLOSE cr_crapcot;
      -- Enviar o saldo das cotas
      vr_obj_generic2.put('saldoCotas', este0001.fn_decimal_ibra(vr_vldcotas));
    
      -- Busca se o cooperado tem plano de cotas ativo      
      OPEN cr_crappla;
      FETCH cr_crappla
        INTO rw_crappla;
    
      IF cr_crappla%FOUND THEN
        vr_temcotas := TRUE;
      ELSE
        vr_temcotas := FALSE;
      END IF;
      CLOSE cr_crappla;
    
      -- Enviar flag se tem Cotas
      vr_obj_generic2.put('temPlanoCotas', vr_temcotas);
    
      -- Verificar se cooperado tem Debito Automático
      OPEN cr_crapatr;
      FETCH cr_crapatr
        INTO rw_crapatr;
    
      IF cr_crapatr%FOUND THEN
        vr_temdebaut := TRUE;
      ELSE
        vr_temdebaut := FALSE;
      END IF;
      CLOSE cr_crapatr;
    
      -- Enviar flag se tem DebAutomático
      vr_obj_generic2.put('temDebaut', vr_temdebaut);
    
      -- Buscar informaçoes e Saldos das Aplicaçoes 
      apli0002.pc_obtem_dados_aplicacoes(pr_cdcooper       => pr_cdcooper --Codigo Cooperativa
                                        ,pr_cdagenci       => 1 --Codigo Agencia
                                        ,pr_nrdcaixa       => 1 --Numero do Caixa
                                        ,pr_cdoperad       => '1' --Codigo Operador
                                        ,pr_nmdatela       => 'ATENDA' --Nome da Tela
                                        ,pr_idorigem       => 5 --Origem dos Dados
                                        ,pr_nrdconta       => pr_nrdconta --Numero da Conta do Associado
                                        ,pr_idseqttl       => 1 --Sequencial do Titular
                                        ,pr_nraplica       => 0 --Numero da Aplicacao
                                        ,pr_cdprogra       => 'ATENDA' --Nome da Tela
                                        ,pr_flgerlog       => 0 /*FALSE*/ --Imprimir log
                                        ,pr_dtiniper       => NULL --Data Inicio periodo   
                                        ,pr_dtfimper       => NULL --Data Final periodo
                                        ,pr_vlsldapl       => vr_vlsldtot --Saldo da Aplicacao
                                        ,pr_tab_saldo_rdca => vr_tab_saldo_rdca --Tipo de tabela com o saldo RDCA
                                        ,pr_des_reto       => vr_des_reto --Retorno OK ou NOK
                                        ,pr_tab_erro       => vr_tab_erro); --Tabela de Erros
      -- Se retornou erro
      IF vr_des_reto = 'NOK' THEN
        --Se possuir erro na PLTable
        IF vr_tab_erro.count > 0 THEN
          vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
        ELSE
          vr_dscritic := 'Nao foi possivel carregar o aplicacoes.';
        END IF;
      
        -- Limpar tabela de erros
        vr_tab_erro.delete;
      
        RAISE vr_exc_saida;
      END IF;
    
      -- loop sobre a tabela de saldo
      vr_ind := vr_tab_saldo_rdca.first;
      WHILE vr_ind IS NOT NULL LOOP
        -- Somar o valor de resgate
        vr_vlsldapl := vr_vlsldapl + vr_tab_saldo_rdca(vr_ind).sldresga;
        vr_ind := vr_tab_saldo_rdca.next(vr_ind);
      END LOOP;
    
      --> Buscar saldo das aplicacoes
      apli0005.pc_busca_saldo_aplicacoes(pr_cdcooper => pr_cdcooper --> Código da Cooperativa
                                        ,pr_cdoperad => 1 --> Código do Operador
                                        ,pr_nmdatela => 'ATENDA' --> Nome da Tela
                                        ,pr_idorigem => 5 --> AYLLOS WEB 
                                        ,pr_nrdconta => pr_nrdconta --> Número da Conta
                                        ,pr_idseqttl => 1 --> Titular da Conta
                                        ,pr_nraplica => 0 --> Número da Aplicaçao / Parâmetro Opcional
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Data de Movimento
                                        ,pr_cdprodut => 0 --> Código do Produto -–> Parâmetro Opcional
                                        ,pr_idblqrgt => 1 --> Identificador de Bloqueio de Resgate  
                                        ,pr_idgerlog => 0 --> Identificador de Log (0 – Nao / 1 – Sim)
                                        ,pr_vlsldtot => vr_vlsldtot --> Saldo Total da Aplicaçao
                                        ,pr_vlsldrgt => vr_vlsldrgt --> Saldo Total para Resgate
                                        ,pr_cdcritic => vr_cdcritic --> Código da crítica
                                        ,pr_dscritic => vr_dscritic); --> Descriçao da crítica
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
    
      vr_vlsldapl := vr_vlsldapl + vr_vlsldrgt;
    
      -- Verificar se há bloqueio de aplicaçoes na conta      
      OPEN cr_crapblj;
      FETCH cr_crapblj
        INTO vr_vlbloque;
      CLOSE cr_crapblj;
    
      -- Enviar informaçoes das aplicaçoes para o JSON
      vr_obj_generic2.put('temAplicacao'
                         ,(nvl(vr_vlsldapl,0) > 0));
      vr_obj_generic2.put('temAplicacaoBloqueada'
                         ,(nvl(vr_vlbloque,0) > 0));
      vr_obj_generic2.put('saldoDisponAplicacao'
                         ,este0001.fn_decimal_ibra(GREATEST(0
                                                  ,nvl(vr_vlsldapl,0) -
                                                   nvl(vr_vlbloque,0)
                         )));
      vr_obj_generic2.put('saldoTotalAplicacao'
                         ,este0001.fn_decimal_ibra(vr_vlsldapl));
    
      -- Selecionar informacoes % IR para o calculo da APLI0001.pc_calc_saldo_rpp
      vr_percenir:= GENE0002.fn_char_para_number
                          (TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                     ,pr_nmsistem => 'CRED'
                                                     ,pr_tptabela => 'CONFIG'
                                                     ,pr_cdempres => 0
                                                     ,pr_cdacesso => 'PERCIRAPLI'
                                                     ,pr_tpregist => 0));
                                                                                 
    
      -- Buscar informaçoes e Saldos das Poupanças Programadas
      apli0001.pc_consulta_poupanca(pr_cdcooper      => pr_cdcooper --> Cooperativa 
                                   ,pr_cdagenci      => 1 --> Codigo da Agencia
                                   ,pr_nrdcaixa      => 1 --> Numero do caixa 
                                   ,pr_cdoperad      => 1 --> Codigo do Operador
                                   ,pr_idorigem      => 5 --> Identificador da Origem
                                   ,pr_nrdconta      => pr_nrdconta --> Nro da conta associado
                                   ,pr_idseqttl      => 1 --> Identificador Sequencial
                                   ,pr_nrctrrpp      => 0 --> Contrato Poupanca Programada 
                                   ,pr_dtmvtolt      => rw_crapdat.dtmvtolt --> Data do movimento atual
                                   ,pr_dtmvtopr      => rw_crapdat.dtmvtopr --> Data do proximo movimento
                                   ,pr_inproces      => rw_crapdat.inproces --> Indicador de processo
                                   ,pr_cdprogra      => 'ATENDA' --> Nome do programa chamador
                                   ,pr_flgerlog      => FALSE --> Flag erro log
                                   ,pr_percenir      => vr_percenir --> % IR para Calculo Poupanca
                                   ,pr_tab_craptab   => vr_tab_conta_bloq --> Tipo de tabela de Conta Bloqueada
                                   ,pr_tab_craplpp   => vr_tab_craplpp --> Tipo de tabela com lancamento poupanca
                                   ,pr_tab_craplrg   => vr_tab_craplrg --> Tipo de tabela com resgates
                                   ,pr_tab_resgate   => vr_tab_resgate --> Tabela com valores dos resgates 
                                   ,pr_vlsldrpp      => vr_vlsldppr --> Valor saldo poupanca programada
                                   ,pr_retorno       => vr_des_reto --> Descricao de erro ou sucesso OK/NOK 
                                   ,pr_tab_dados_rpp => vr_tab_dados_rpp --> Poupancas Programadas
                                   ,pr_tab_erro      => vr_tab_erro); --> Saida com erros;
      --Se retornou erro
      IF vr_des_reto = 'NOK' THEN
        -- Extrair o codigo e critica de erro da tabela de erro
        vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
        vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
      
        -- Limpar tabela de erros
        vr_tab_erro.delete;
      
        RAISE vr_exc_saida;
      END IF;
    
      -- Verificar se há bloqueio de aplicaçoes na conta          
      OPEN cr_crapblj_pp;
      FETCH cr_crapblj_pp
        INTO vr_vlbloque_pp;
      CLOSE cr_crapblj_pp;
    
      -- Enviar informaçoes das aplicaçoes para o JSON
      vr_obj_generic2.put('temPoupProgram'
                         ,(nvl(vr_vlsldppr,0) > 0));
      vr_obj_generic2.put('temPoupProgamBloqueada'
                         ,(nvl(vr_vlbloque_pp,0) > 0));
      vr_obj_generic2.put('saldoDisponPoupProgram'
                         ,este0001.fn_decimal_ibra(GREATEST(0
                                                  ,nvl(vr_vlsldppr,0) -
                                                   nvl(vr_vlbloque_pp,0)
                         )));
      vr_obj_generic2.put('saldoTotalPoupProgram'
                         ,este0001.fn_decimal_ibra(nvl(vr_vlsldppr,0)));
    
      --> Procedure para listar cartoes do cooperado                    
      cada0004.pc_lista_cartoes(pr_cdcooper => pr_cdcooper --> Codigo da cooperativa
                               ,pr_cdagenci => 1 --> Codigo de agencia
                               ,pr_nrdcaixa => 1 --> Numero do caixa
                               ,pr_cdoperad => 1 --> Codigo do operador
                               ,pr_nrdconta => pr_nrdconta --> Numero da conta
                               ,pr_idorigem => 5 --> Identificado de oriem
                               ,pr_idseqttl => 1 --> sequencial do titular
                               ,pr_nmdatela => 'ATENDA' --> Nome da tela
                               ,pr_flgerlog => 'N' --> identificador se deve gerar log S-Sim e N-Nao
                               ,pr_flgzerar => 'N' --> Nao zerar limite
                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Data da cooperativa
                                ------ OUT ------
                               ,pr_flgativo    => vr_flgativo --> Retorna situaçao 1-ativo 2-inativo
                               ,pr_nrctrhcj    => vr_nrctrhcj --> Retorna numero do contrato
                               ,pr_flgliber    => vr_flgliber --> Retorna se esta liberado 1-sim 2-nao
                               ,pr_vltotccr    => vr_vltotccr --> retorna total de limite do cartao 
                               ,pr_tab_cartoes => vr_tab_cartoes --> retorna temptable com os dados dos convenios
                               ,pr_des_reto    => vr_des_reto --> OK ou NOK
                               ,pr_tab_erro    => vr_tab_erro);
    
      -- Se houve retorno nao Ok
      IF vr_des_reto = 'NOK' THEN
        -- Retornar a mensagem de erro
        vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
        vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
        -- Limpar tabela de erros
        vr_tab_erro.delete;
        RAISE vr_exc_saida;
      END IF;
    
      -- VArrer cartoes ate encontrar algum ativo
      IF vr_tab_cartoes.count > 0 THEN
        FOR vr_dx IN vr_tab_cartoes.first..vr_tab_cartoes.last LOOP
          IF vr_tab_cartoes(vr_dx).dssitcrd IN('Solic.','Liber.','Sol.2v','Prc.BB','Em uso','Sol.2v') THEN
            vr_flgativo := 1;
          END IF;
        END LOOP;
      END IF;
    
      -- Enviar flag de encontro e valor de Limite de Crédito
      vr_obj_generic2.put('temCartaoCredito'
                         ,(vr_flgativo > 0));
      vr_obj_generic2.put('limiteCartaoCredit'
                         ,este0001.fn_decimal_ibra(vr_vltotccr));
    
      -- Buscar proposta de desconto cheques     
      OPEN cr_crawlim_chqesp;
      FETCH cr_crawlim_chqesp
        INTO rw_crawlim_chqesp;
      CLOSE cr_crawlim_chqesp;
      -- Buscar borderôs ativos
    
      -- Buscar contrato de desconto cheques     
      OPEN cr_craplim_chq;
      FETCH cr_craplim_chq
        INTO rw_craplim_chq;
      CLOSE cr_craplim_chq;
      -- Buscar borderôs ativos
      OPEN cr_crapcdb(rw_crapdat.dtmvtolt);
      FETCH cr_crapcdb
        INTO rw_crapcdb;
      CLOSE cr_crapcdb;
    
      -- Enviar informaçoes do contrato de Cheque
      vr_obj_generic2.put('dataContrDescCheq'
                         ,este0002.fn_data_ibra_motor(rw_craplim_chq.dtinivig));
      vr_obj_generic2.put('limiteDescCheq'
                         ,este0001.fn_decimal_ibra(nvl(rw_craplim_chq.vllimite,0)));
      vr_obj_generic2.put('saldoUtilizDescCheq'
                         ,este0001.fn_decimal_ibra(nvl(rw_crapcdb.vlcheque,0)));
    
      -- Buscar contrato de desconto titulos     
      OPEN cr_craplim_tit;
      FETCH cr_craplim_tit
        INTO rw_craplim_tit;
      CLOSE cr_craplim_tit;
    
      -- Buscar borderôs ativos
      OPEN cr_craptdb(rw_crapdat.dtmvtolt);
      FETCH cr_craptdb
        INTO rw_craptdb;
      CLOSE cr_craptdb;
    
      -- Enviar informaçoes do contrato de Cheque
      vr_obj_generic2.put('dataContrDescTitul'
                         ,este0002.fn_data_ibra_motor(rw_craplim_tit.dtinivig));
      vr_obj_generic2.put('limiteDescTitul'
                         ,este0001.fn_decimal_ibra(nvl(rw_craplim_tit.vllimite,0)));
      vr_obj_generic2.put('saldoUtilizDescTitul'
                         ,este0001.fn_decimal_ibra(nvl(rw_craptdb.vltitulo,0)));
        
      -- Entao chamaremos a rotina para busca do endividamento total 
      gene0005.pc_saldo_utiliza(pr_cdcooper    => pr_cdcooper
                               ,pr_tpdecons    => 3
                               ,pr_cdagenci    => 1
                               ,pr_nrdcaixa    => 1
                               ,pr_cdoperad    => 1
                               ,pr_nrdconta    => pr_nrdconta
                               ,pr_nrcpfcgc    => 0
                               ,pr_idseqttl    => 1
                               ,pr_idorigem    => 5
                               ,pr_dsctrliq    => 0--rw_crawepr.dsliquid
                               ,pr_cdprogra    => 'ATENDA'
                               ,pr_tab_crapdat => rw_crapdat
                               ,pr_inusatab    => TRUE
                               ,pr_vlutiliz    => vr_vlutiliz
                               ,pr_cdcritic    => vr_cdcritic
                               ,pr_dscritic    => vr_dscritic);
    
      IF NVL(vr_cdcritic, 0) <> 0 OR vr_dscritic IS NOT NULL THEN
        -- Se for erro 9, entao o associado esta com data de eliminacao preenchida.
        -- Neste caso nao deve dar erro, e sim considerar como valor zerado
        IF NVL(vr_cdcritic, 0) = 9 THEN
          vr_vlutiliz := 0;
          vr_cdcritic := 0;
          vr_dscritic := NULL;
        ELSE
          RAISE vr_exc_saida;
        END IF;
      END IF;
    
      -- Enviar o saldo utilizado
      vr_obj_generic2.put('saldoDevedor', este0001.fn_decimal_ibra(vr_vlutiliz));
    
      -- Verificar co-responsabilidade
      empr0003.pc_gera_co_responsavel(pr_cdcooper           => pr_cdcooper
                                     ,pr_cdagenci           => 1
                                     ,pr_nrdcaixa           => 1
                                     ,pr_cdoperad           => '1'
                                     ,pr_nmdatela           => 'ATENDA'
                                     ,pr_idorigem           => 5
                                     ,pr_cdprogra           => 'ATENDA'
                                     ,pr_nrdconta           => pr_nrdconta
                                     ,pr_idseqttl           => 1
                                     ,pr_dtcalcul           => rw_crapdat.dtmvtolt
                                     ,pr_flgerlog           => 'N'
                                     ,pr_vldscchq           => rw_craplim_chq.vllimite -- Valor Limite Cheques
                                     ,pr_vlutlchq           => rw_crapcdb.vlcheque -- Valor utilizado Cheques
                                     ,pr_vldctitu           => rw_craplim_tit.vllimite -- Valor Limite Titulos
                                     ,pr_vlutitit           => rw_craptdb.vltitulo -- Valor utilizado Titulos
                                     ,pr_tab_co_responsavel => vr_tab_co_responsavel
                                     ,pr_dscritic           => vr_dscritic
                                     ,pr_cdcritic           => vr_cdcritic);
    
      -- Testar possíveis erros no retorno prevendo já o formato convertido… 
      IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
    
      -- Loop para buscar todos os contratos em que o avalista é co-resposável 
      vr_ind_coresp := vr_tab_co_responsavel.first;
      WHILE vr_ind_coresp IS NOT NULL LOOP
      
        -- Se Saldo Devedor Maior que Zero
        IF vr_tab_co_responsavel(vr_ind_coresp).vlsdeved > 0 THEN
      
          -- Se ha pagamento a pagar
          IF NVL(vr_tab_co_responsavel(vr_ind_coresp).vlpreapg,0)
           + NVL(vr_tab_co_responsavel(vr_ind_coresp).vlmrapar,0)
           + NVL(vr_tab_co_responsavel(vr_ind_coresp).vlmtapar,0) > 0 THEN
           -- Acumular atraso
            vr_tot_qtprecal := vr_tot_qtprecal + 1;
            vr_ava_vlsdeved := vr_ava_vlsdeved + NVL(vr_tab_co_responsavel(vr_ind_coresp).vlpreapg,0)
                                               + NVL(vr_tab_co_responsavel(vr_ind_coresp).vlmrapar,0)
                                               + NVL(vr_tab_co_responsavel(vr_ind_coresp).vlmtapar,0);
          END IF;
          -- Somar totais
          vr_tot_vlsdeved := vr_tot_vlsdeved + NVL(vr_tab_co_responsavel(vr_ind_coresp).vlsdeved,0);

        END IF;
        
        -- Buscar próximo registro
        vr_ind_coresp := vr_tab_co_responsavel.next(vr_ind_coresp);
      END LOOP;
    
      -- Enfim, enviar as informaçoes para o JSON (Neste ponto voltamos a trazer código PLSQL)
      vr_obj_generic2.put('coopAvalista',(vr_tot_vlsdeved > 0));
      vr_obj_generic2.put('valorCoopAvalista',este0001.fn_decimal_ibra(vr_tot_vlsdeved));
      vr_obj_generic2.put('coopAvalistaAtraso',(vr_tot_qtprecal > 0));
      vr_obj_generic2.put('valorAvalistaAtraso',este0001.fn_decimal_ibra(vr_ava_vlsdeved));
             
   
   --Verificar se usa tabela juros
   vr_dstextab:= TABE0001.fn_busca_dstextab (pr_cdcooper => pr_cdcooper
                        ,pr_nmsistem => 'CRED'
                        ,pr_tptabela => 'USUARI'
                        ,pr_cdempres => 11
                        ,pr_cdacesso => 'TAXATABELA'
                        ,pr_tpregist => 0);
   -- Se a primeira posiçao do campo
   -- dstextab for diferente de zero
   vr_inusatab:= SUBSTR(vr_dstextab,1,1) != '0';             
    
      -- Leitura do indicador de uso da tabela de taxa de juros
      vr_dstextab_parempctl := tabe0001.fn_busca_dstextab(pr_cdcooper => 3
                                                         ,pr_nmsistem => 'CRED'
                                                         ,pr_tptabela => 'USUARI'
                                                         ,pr_cdempres => 11
                                                         ,pr_cdacesso => 'PAREMPCTL'
                                                         ,pr_tpregist => 01);    
    
    -- busca o tipo de documento GED
    vr_dstextab_digitaliza := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                        ,pr_nmsistem => 'CRED'
                                                        ,pr_tptabela => 'GENERI'
                                                        ,pr_cdempres => 00
                                                        ,pr_cdacesso => 'DIGITALIZA'
                                                        ,pr_tpregist => 5);    
    
      -- Buscar todos os contratos do Cooperado
      empr0001.pc_obtem_dados_empresti(pr_cdcooper       => pr_cdcooper --> Cooperativa conectada
                                      ,pr_cdagenci       => 1 --> Código da agencia
                                      ,pr_nrdcaixa       => 1 --> Número do caixa
                                      ,pr_cdoperad       => '1' --> Código do operador
                                      ,pr_nmdatela       => 'EXTEMP' --> Nome datela conectada
                                      ,pr_idorigem       => 5 --> Indicador da origem da chamada
                                      ,pr_nrdconta       => pr_nrdconta --> Conta do associado
                                      ,pr_idseqttl       => 1 --> Sequencia de titularidade da conta
                                      ,pr_rw_crapdat     => rw_crapdat --> Vetor com dados de parâmetro (CRAPDAT)
                                      ,pr_dtcalcul       => NULL --> Data solicitada do calculo
                                      ,pr_nrctremp       => 0 --> Número contrato empréstimo
                                      ,pr_cdprogra       => 'ATENDA' --> Programa conectado
                                      ,pr_inusatab       => vr_inusatab --> Indicador de utilizaçao da tabela de juros
                                      ,pr_flgerlog       => 'N' --> Gerar log S/N
                                      ,pr_flgcondc       => FALSE --> Mostrar emprestimos liq. s/ prejuizo
                                      ,pr_nmprimtl       => rw_crapass.nmprimtl --> Nome Primeiro Titular
                                      ,pr_tab_parempctl  => vr_dstextab_parempctl --> Dados tabela parametro
                                      ,pr_tab_digitaliza => vr_dstextab_digitaliza --> Dados tabela parametro
                                      ,pr_nriniseq       => 0 --> Numero inicial da paginacao
                                      ,pr_nrregist       => 0 --> Numero de registros por pagina
                                      ,pr_qtregist       => vr_qtregist --> Qtde total de registros
                                      ,pr_tab_dados_epr  => vr_tab_dados_epr --> Saida com os dados do empréstimo
                                      ,pr_des_reto       => vr_des_reto --> Retorno OK / NOK
                                      ,pr_tab_erro       => vr_tab_erro); --> Tabela com possíves erros
    
      IF vr_des_reto = 'NOK' THEN
        IF vr_tab_erro.exists(vr_tab_erro.first) THEN
        
          vr_dscritic := 'Conta: ' || pr_nrdconta ||
                         ' nao possui emprestimo.: ' ||
                        -- concatenado a critica na versao oracle para tbm saber a causa de abortar o programa
                         vr_tab_erro(vr_tab_erro.first).dscritic;
        ELSE
          vr_dscritic := 'Conta: ' || pr_nrdconta ||
                         ' nao possui emprestimo.';
        END IF;
        RAISE vr_exc_saida;
      END IF;
   
      -- Buscar parâmetro da quantidade de meses para encontro do histórico de empréstimos
      vr_qthisemp := gene0001.fn_param_sistema('CRED',pr_cdcooper,'QTD_MES_HIST_EMPRES_DESC');
   
      -- Zerar variaveis auxiliares
      vr_nratrmai := 0;
      vr_vltotatr := 0;
      vr_qtpclven := 0;
      vr_qtpclatr := 0;
      vr_qtpclpag := 0;
      vr_tot_qtpclatr := 0;
      vr_tot_qtpclpag := 0;
      vr_maior_nratrmai := 0;
    
      -- varrer temptable de emprestimos
      vr_idxempr := vr_tab_dados_epr.first;

      vr_dias     := 0;
      WHILE vr_idxempr IS NOT NULL LOOP
        -- Para aqueles com saldo devedor
        IF vr_tab_dados_epr(vr_idxempr).vlsdeved > 0 THEN
          -- Chamar calculo de dias em atraso
         
          este0002.pc_calc_dias_atraso(pr_cdcooper => pr_cdcooper  
                                      ,pr_nrdconta   => pr_nrdconta
                                      ,pr_nrctremp => vr_tab_dados_epr(vr_idxempr).nrctremp  
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                      ,pr_dtmvtoan => rw_crapdat.dtmvtoan
                                      ,pr_dtmvtopr => rw_crapdat.dtmvtopr
                                      ,pr_tpemprst => vr_tab_dados_epr(vr_idxempr).tpemprst   
                                      ,pr_qtmesdec => vr_tab_dados_epr(vr_idxempr).qtmesdec   
                                      ,pr_dtdpagto => vr_tab_dados_epr(vr_idxempr).dtdpagto   
                                      ,pr_qtprecal => vr_tab_dados_epr(vr_idxempr).qtprecal   
                                      ,pr_flgpagto => vr_tab_dados_epr(vr_idxempr).flgpagto   
                                      ,pr_qtdiaatr   => vr_dias
                                      ,pr_cdcritic   => vr_cdcritic
                                      ,pr_des_erro   => vr_dscritic);
          --Se ocorreu erro
          IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
            --Levantar Exceçao
            RAISE vr_exc_saida;
          END IF;
        
          -- Se há atraso
          IF vr_dias > 0 THEN
            
            IF vr_dias > vr_maior_nratrmai THEN
              vr_maior_nratrmai := vr_dias;
            END IF;
            -- Acumular saldo em atraso
            vr_vltotatr := vr_vltotatr + vr_tab_dados_epr(vr_idxempr).vlpreapg
                                       + vr_tab_dados_epr(vr_idxempr).vlmrapar
                                       + vr_tab_dados_epr(vr_idxempr).vlmtapar;
            -- Meses em atraso
            vr_qtpclven := vr_qtpclven + CEIL(vr_dias/30);                          
          END IF;
          
        END IF;
      
        -- Calculo de Parcelas conforme tipo de empréstimo 
        IF vr_tab_dados_epr(vr_idxempr).tpemprst = 1 THEN
          -- Para PP, buscaremos no cadastro de parcelas a quantidade de parcelas pagas em atraso
          OPEN cr_crappep_atraso(rw_crapdat.dtmvtolt
                           ,vr_tab_dados_epr(vr_idxempr).nrctremp
                ,vr_qthisemp);
          FETCH cr_crappep_atraso
            INTO vr_qtpclatr;
          CLOSE cr_crappep_atraso;
        
          -- Para as parcelas pagas também buscaremos no cadastro de parcelas           
          OPEN cr_crappep_pagtos(rw_crapdat.dtmvtolt
                           ,vr_tab_dados_epr(vr_idxempr).nrctremp
                ,vr_qthisemp);
          FETCH cr_crappep_pagtos
            INTO vr_qtpclpag;
          CLOSE cr_crappep_pagtos;
        
        ELSE
          -- Para TR, buscaremos nos lançamentos de pagtos a quantidade de lançamentos de Multa         
          OPEN cr_craplem_atraso(rw_crapdat.dtmvtolt
                           ,vr_tab_dados_epr(vr_idxempr).nrctremp
                ,vr_qthisemp);
          FETCH cr_craplem_atraso
            INTO vr_qtpclatr;
          CLOSE cr_craplem_atraso;
        
          -- Somar o valor pago nos ultimos 6 meses
          OPEN cr_craplem_pago(rw_crapdat.dtmvtolt
                         ,vr_tab_dados_epr(vr_idxempr).nrctremp
               ,vr_qthisemp);
          FETCH cr_craplem_pago
            INTO vr_vlpclpag;
          CLOSE cr_craplem_pago;
          -- Quantidade Parcelas paga é Valor Paga nos ultimos 6 meses / Valor da Parcela
          vr_qtpclpag := ROUND(vr_vlpclpag / vr_tab_dados_epr(vr_idxempr)
                               .vlpreemp);
        
          -- Descontar da quantidade paga a quantidade em atraso, pq mesmo tendo pago 
          -- proporcionalmente o valor total da parcela, se teve multa no mes significa
          -- que foi pago após o vencimento
          vr_qtpclpag := vr_qtpclpag - vr_qtpclatr;
        
          -- Garantir que nao fique negativo, portanto se for negativo trará zero.
          vr_qtpclpag := greatest(0, vr_qtpclpag);
        
        END IF;
        
        -- TOtalizar
        vr_tot_qtpclatr :=  vr_tot_qtpclatr + vr_qtpclatr;
        vr_tot_qtpclpag :=  vr_tot_qtpclpag + vr_qtpclpag;
        
        -- Buscar o próximo
        vr_idxempr := vr_tab_dados_epr.next(vr_idxempr);
      END LOOP;
      
      -- Busca maior atraso dentre os emprestimos do cooperado 
      OPEN cr_crapris(null, add_months(rw_crapdat.dtmvtolt,-vr_qthisemp));
      FETCH cr_crapris
        INTO vr_nratrmai;
      CLOSE cr_crapris;      
      
      -- Enviar informaçoes do atraso e parcelas calculadas para o JSON
      vr_obj_generic2.put('valorAtrasoEmprest',este0001.fn_decimal_ibra(vr_vltotatr));
      vr_obj_generic2.put('quantDiasMaiorAtrasoEmprest', vr_nratrmai);
      
      vr_obj_generic2.put('quantParcelPagas', vr_tot_qtpclpag);
      vr_obj_generic2.put('quantParcelPagasAtraso', vr_tot_qtpclatr);
      vr_obj_generic2.put('quantParcelAtraso', vr_qtpclven);
      vr_obj_generic2.put('quantDiasAtrasoEmprest', vr_maior_nratrmai);
    
      -- Data de Vigencia Procuraçao
      IF pr_dtvigpro IS NOT NULL THEN 
        vr_obj_generic2.put('dataVigenciaProcuracao' ,este0002.fn_data_ibra_motor(pr_dtvigpro));
      END IF;  

      -- Data de Admissao Procuraçao
      IF pr_dtadmsoc IS NOT NULL THEN 
        vr_obj_generic2.put('dataAdmissaoProcuracao' ,este0002.fn_data_ibra_motor(pr_dtadmsoc));
      END IF;  
      
      -- Percentual Procuraçao
      IF pr_persocio IS NOT NULL THEN 
        vr_obj_generic2.put('valorPercentualProcuracao' ,Este0001.fn_Decimal_Ibra(pr_persocio));
      END IF;
      
      -- Montar objeto para seguro
      vr_lst_generic3 := json_list();
    
      -- Buscar todos os seguros da Conta do Cooperado 
      -- Efetuar laço para trazer todos os registros 
      FOR rw_crapseg IN cr_crapseg LOOP
            
        -- Criar objeto para a operaçao e enviar suas informaçoes 
        vr_obj_generic3 := json();
        vr_obj_generic3.put('tipoSeguro', rw_crapseg.dstipo);
        vr_obj_generic3.put('valorApoliceSeguro'
                           ,este0001.fn_decimal_ibra(rw_crapseg.vlpremio));
        vr_obj_generic3.put('tipoPagtoSeguro ', 'Debito Automático');
      
        -- Adicionar Operaçao na lista
        vr_lst_generic3.append(vr_obj_generic3.to_json_value());
      
      END LOOP; -- Final da leitura os seguros
    
      -- Adicionar o array seguro no objeto informaçoes adicionais
      vr_obj_generic2.put('seguro', vr_lst_generic3);
   
      -- Montar objeto para CheqDevol
      vr_lst_generic3 := json_list();
    
   -- Buscar parâmetro da quantidade de meses para busca dos Estouros/Adiantamentos
   vr_qtmeschq := gene0001.fn_param_sistema('CRED',pr_cdcooper,'QTD_MES_HIST_DEVCHQ_DESC');  
   vr_qtmeschqal11 := gene0001.fn_param_sistema('CRED',pr_cdcooper,'QTD_MES_HIST_DEV_CH_AL11');
   vr_qtmeschqal12 := gene0001.fn_param_sistema('CRED',pr_cdcooper,'QTD_MES_HIST_DEV_CH_AL11');   
  
      -- Efetuar laço para trazer todos os registros 
      FOR rw_negchq IN cr_crapneg_cheq(vr_qtmeschq
                                  ,vr_qtmeschqal11
                   ,vr_qtmeschqal12) LOOP
      
        -- Criar objeto para a operaçao e enviar suas informaçoes 
        vr_obj_generic3 := json();
        vr_obj_generic3.put('dataCheqDevol'
                           ,este0002.fn_data_ibra_motor(rw_negchq.dtiniest));
        vr_obj_generic3.put('valorCheqDevol'
                           ,este0001.fn_decimal_ibra(rw_negchq.vlestour));
        vr_obj_generic3.put('alineaCheqDevol', rw_negchq.cdobserv);
      
        -- Adicionar Operaçao na lista
        vr_lst_generic3.append(vr_obj_generic3.to_json_value());
      
      END LOOP; -- Final da leitura das operaçoes
    
      -- Adicionar o array CheqDevol no objeto informaçoes adicionais
      vr_obj_generic2.put('cheqDevol', vr_lst_generic3);
      
      -- Montar objeto para OpCred
      vr_lst_generic3 := json_list();
  
      -- Lógica para retorno das ultimas operaçoes de Crédito Liquidadas
      -- Primeiramente buscamos a quantidade de operaçoes a serem enviadas 
      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'PROPOSTEPR'
                                               ,pr_tpregist => 0);
      -- Conforme o tipo de pessoa
      IF rw_crapass.inpessoa = 1 THEN
        vr_qtdopliq := SUBSTR(vr_dstextab, 44, 3);
      ELSE
        vr_qtdopliq := SUBSTR(vr_dstextab, 52, 3);
      END IF;
        
      -- Efetuar laço para trazer todos os registros 
      FOR rw_crapepr IN cr_crapepr LOOP
      
        -- Verificar a quantidade de registros já lidos, pois nao poderá passer da quantidade parametrizada
        IF vr_qtdopliq < cr_crapepr%rowcount THEN
          EXIT;
        END IF;
      
        -- Busca data da Liquidaçao              
        OPEN cr_dtliquid(rw_crapepr.nrctremp);
        FETCH cr_dtliquid
          INTO vr_dtliquid;
        CLOSE cr_dtliquid;
      
        -- Busca atraso
        OPEN cr_crapris(rw_crapepr.nrctremp, rw_crapepr.dtmvtolt);
        FETCH cr_crapris
          INTO vr_qtdiaatr;
        CLOSE cr_crapris;
      
        OPEN cr_eprliquid(rw_crapepr.nrctremp);
        FETCH cr_eprliquid
          INTO rw_eprliquid;
      
        IF cr_eprliquid%FOUND THEN
          vr_flliquid := TRUE;
        ELSE
          vr_flliquid := FALSE;
        END IF;
        CLOSE cr_eprliquid;
        
        -- Criar objeto para a operaçao e enviar suas informaçoes 
        vr_obj_generic3 := json();
        vr_obj_generic3.put('contratOpCred'
                           ,gene0002.fn_mask_contrato(rw_crapepr.nrctremp));
        vr_obj_generic3.put('dataContratOpCred', este0002.fn_data_ibra_motor(rw_crapepr.dtmvtolt));              
        vr_obj_generic3.put('valorOpCred'
                           ,este0001.fn_decimal_ibra(rw_crapepr.vlemprst));
        vr_obj_generic3.put('valorPrestOpCred'
                           ,este0001.fn_decimal_ibra(rw_crapepr.vlpreemp));
        vr_obj_generic3.put('quantPrestOpCred'
                           ,este0001.fn_decimal_ibra(rw_crapepr.qtpreemp));
        vr_obj_generic3.put('finalidadeOpCredCodigo', rw_crapepr.cdfinemp);
        vr_obj_generic3.put('finalidadeOpCredDescricao', rw_crapepr.dsfinemp);    
        vr_obj_generic3.put('linhaOpCredCodigo', rw_crapepr.cdlcremp);
        vr_obj_generic3.put('linhaOpCredDescricao', rw_crapepr.dslcremp);    
        vr_obj_generic3.put('liquidacaoOpCred', este0002.fn_data_ibra_motor(vr_dtliquid));
        vr_obj_generic3.put('pontualidadeOpCred'
                           ,este0002.fn_des_pontualidade(vr_qtdiaatr));
        vr_obj_generic3.put('atrasoOpCred'
                           ,(nvl(vr_qtdiaatr,0) > 0));
        vr_obj_generic3.put('propostasLiquidOpCred', vr_flliquid);
      
        -- Adicionar Operaçao na lista
        vr_lst_generic3.append(vr_obj_generic3.to_json_value());
      
      END LOOP; -- Final da leitura das operaçoes
    
      -- Adicionar o array OpCred no objeto informaçoes adicionais
      vr_obj_generic2.put('opCred', vr_lst_generic3);
      
      -- Somente para Pessoa Fisica
      IF rw_crapass.inpessoa <> 1 THEN
   
        -- Montar objeto para faturamentos
        vr_lst_generic3 := json_list();
      
        -- Criar objeto para mes 01
        if rw_crapjfn.dtfatme1 <> '01000000' then
          vr_obj_generic3 := json();
          vr_obj_generic3.put('dataFaturamentoMes'
                             ,este0002.fn_data_ibra_motor(to_date(rw_crapjfn.dtfatme1,'ddmmrrrr')));
          vr_obj_generic3.put('valorFaturamentoMes'
                             ,este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##1));
          -- Adicionar Mes na lista
          vr_lst_generic3.append(vr_obj_generic3.to_json_value());
        end if;

        if rw_crapjfn.dtfatme2 <> '01000000' then
          -- Criar objeto para mes 02
          vr_obj_generic3 := json();
          vr_obj_generic3.put('dataFaturamentoMes'
                             ,este0002.fn_data_ibra_motor(to_date(rw_crapjfn.dtfatme2,'ddmmrrrr')));
          vr_obj_generic3.put('valorFaturamentoMes'
                             ,este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##2));
          -- Adicionar Mes na lista
          vr_lst_generic3.append(vr_obj_generic3.to_json_value());
        end if;
        
        if rw_crapjfn.dtfatme3 <> '01000000' then        
          -- Criar objeto para mes 03
          vr_obj_generic3 := json();
          vr_obj_generic3.put('dataFaturamentoMes'
                             ,este0002.fn_data_ibra_motor(to_date(rw_crapjfn.dtfatme3,'ddmmrrrr')));
          vr_obj_generic3.put('valorFaturamentoMes'
                             ,este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##3));
          -- Adicionar Mes na lista
          vr_lst_generic3.append(vr_obj_generic3.to_json_value());
        end if;
        
        if rw_crapjfn.dtfatme4 <> '01000000' then
          -- Criar objeto para mes 04
          vr_obj_generic3 := json();
          vr_obj_generic3.put('dataFaturamentoMes'
                             ,este0002.fn_data_ibra_motor(to_date(rw_crapjfn.dtfatme4,'ddmmrrrr')));
          vr_obj_generic3.put('valorFaturamentoMes'
                             ,este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##4));
          -- Adicionar Mes na lista
          vr_lst_generic3.append(vr_obj_generic3.to_json_value());
        end if;
        
        if rw_crapjfn.dtfatme5 <> '01000000' then
          -- Criar objeto para mes 05
          vr_obj_generic3 := json();
          vr_obj_generic3.put('dataFaturamentoMes'
                             ,este0002.fn_data_ibra_motor(to_date(rw_crapjfn.dtfatme5,'ddmmrrrr')));
          vr_obj_generic3.put('valorFaturamentoMes'
                             ,este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##5));
          -- Adicionar Mes na lista
          vr_lst_generic3.append(vr_obj_generic3.to_json_value());
        end if;
        
        if rw_crapjfn.dtfatme6 <> '01000000' then
          -- Criar objeto para mes 06
          vr_obj_generic3 := json();
          vr_obj_generic3.put('dataFaturamentoMes'
                             ,este0002.fn_data_ibra_motor(to_date(rw_crapjfn.dtfatme6,'ddmmrrrr')));
          vr_obj_generic3.put('valorFaturamentoMes'
                             ,este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##6));
          -- Adicionar Mes na lista
          vr_lst_generic3.append(vr_obj_generic3.to_json_value());
        end if;        
        
        if rw_crapjfn.dtfatme7 <> '01000000' then
          -- Criar objeto para mes 07
          vr_obj_generic3 := json();
          vr_obj_generic3.put('dataFaturamentoMes'
                             ,este0002.fn_data_ibra_motor(to_date(rw_crapjfn.dtfatme7,'ddmmrrrr')));
          vr_obj_generic3.put('valorFaturamentoMes'
                             ,este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##7));
          -- Adicionar Mes na lista
          vr_lst_generic3.append(vr_obj_generic3.to_json_value());
        end if;
        
        if rw_crapjfn.dtfatme8 <> '01000000' then
          -- Criar objeto para mes 08
          vr_obj_generic3 := json();
          vr_obj_generic3.put('dataFaturamentoMes'
                             ,este0002.fn_data_ibra_motor(to_date(rw_crapjfn.dtfatme8,'ddmmrrrr')));
          vr_obj_generic3.put('valorFaturamentoMes'
                             ,este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##8));
          -- Adicionar Mes na lista
          vr_lst_generic3.append(vr_obj_generic3.to_json_value());
        end if;
        
        if rw_crapjfn.dtfatme9 <> '01000000' then
          -- Criar objeto para mes 09
          vr_obj_generic3 := json();
          vr_obj_generic3.put('dataFaturamentoMes'
                             ,este0002.fn_data_ibra_motor(to_date(rw_crapjfn.dtfatme9,'ddmmrrrr')));
          vr_obj_generic3.put('valorFaturamentoMes'
                             ,este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##9));
          -- Adicionar Mes na lista
          vr_lst_generic3.append(vr_obj_generic3.to_json_value());
        end if;
        
        if rw_crapjfn.dtfatme10 <> '01000000' then        
          -- Criar objeto para mes 10
          vr_obj_generic3 := json();
          vr_obj_generic3.put('dataFaturamentoMes'
                             ,este0002.fn_data_ibra_motor(to_date(rw_crapjfn.dtfatme10,'ddmmrrrr')));
          vr_obj_generic3.put('valorFaturamentoMes'
                             ,este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##10));
          -- Adicionar Mes na lista
          vr_lst_generic3.append(vr_obj_generic3.to_json_value());
        end if;
        
        if rw_crapjfn.dtfatme11 <> '01000000' then
          -- Criar objeto para mes 11
          vr_obj_generic3 := json();
          vr_obj_generic3.put('dataFaturamentoMes'
                             ,este0002.fn_data_ibra_motor(to_date(rw_crapjfn.dtfatme11,'ddmmrrrr')));
          vr_obj_generic3.put('valorFaturamentoMes'
                             ,este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##11));
          -- Adicionar Mes na lista
          vr_lst_generic3.append(vr_obj_generic3.to_json_value());
        end if;
        
        if rw_crapjfn.dtfatme12 <> '01000000' then
          -- Criar objeto para mes 12
          vr_obj_generic3 := json();
          vr_obj_generic3.put('dataFaturamentoMes'
                             ,este0002.fn_data_ibra_motor(to_date(rw_crapjfn.dtfatme12,'ddmmrrrr')));
          vr_obj_generic3.put('valorFaturamentoMes'
                             ,este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##12));
          -- Adicionar Mes na lista
          vr_lst_generic3.append(vr_obj_generic3.to_json_value());
        end if;  
      
        -- Adicionar o array de faturamentos no objeto informaçoes adicionais
        vr_obj_generic2.put('faturamentoMes', vr_lst_generic3);
      
   END IF;
   
      -- Enviar informaçoes adicionais ao JSON 
      vr_obj_generico.put('informacoesAdicionais', vr_obj_generic2);

      -- Ao final copiamos o json montado ao retornado
      pr_dsjsonan := vr_obj_generico;
    
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      
      WHEN OTHERS THEN
        IF SQLCODE < 0 THEN
          -- Caso ocorra exception gerar o código do erro com a linha do erro
          vr_dscritic:= vr_dscritic ||
                        dbms_utility.format_error_backtrace;
                       
        END IF;  

        -- Montar a mensagem final do erro 
        vr_dscritic:= 'Erro na montagem dos dados para análise automática da proposta (1): ' ||
                       vr_dscritic || ' -- SQLERRM: ' || SQLERRM;
                       
        -- Remover as ASPAS que quebram o texto
        vr_dscritic:= replace(vr_dscritic,'"', '');
        vr_dscritic:= replace(vr_dscritic,'''','');
        -- Remover as quebras de linha
        vr_dscritic:= replace(vr_dscritic,chr(10),'');
        vr_dscritic:= replace(vr_dscritic,chr(13),'');
      
        pr_cdcritic := 0;
        pr_dscritic := vr_dscritic;
    END;
  END pc_gera_json_pessoa_ass;

    
  --> Rotina responsavel por montar o objeto json para analise de limite de desconto de títulos
  PROCEDURE pc_gera_json_analise_lim(pr_cdcooper   IN crapass.cdcooper%TYPE   --> Codigo da cooperativa
                                    ,pr_cdagenci   IN crapass.cdagenci%type
                                    ,pr_nrdconta   IN crapass.nrdconta%type
                                    ,pr_nrctrlim   IN crawlim.nrctrlim%type
                                    ,pr_tpctrlim   IN crawlim.tpctrlim%type
                                    ,pr_nrctaav1   IN crawlim.nrctaav1%type
                                    ,pr_nrctaav2   IN crawlim.nrctaav2%type
                                    ---- OUT ----
                                    ,pr_dsjsonan  OUT NOCOPY json             --> Retorno do clob em modelo json com os dados para analise
                                    ,pr_cdcritic  OUT NUMBER                  --> Codigo da critica
                                    ,pr_dscritic  OUT varchar2                --> Descricao da critica
                                    ) is
  /* ..........................................................................
    
      Programa : pc_gera_json_analise_lim
      Sistema  : 
      Sigla    : CRED
      Autor    : Paulo Penteado (GFT) 
      Data     : Fevereiro/2018.                   Ultima atualizacao: 18/02/2018
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por montar o objeto json para analise.
    
      Alteraçao : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
   -- Buscar quantidade de dias de reaproveitamento     
  CURSOR cr_craprbi IS
    select rbi.qtdiarpv
    from   craprbi rbi
          ,crapass ass
          ,crawlim lim
    where  rbi.cdcooper = pr_cdcooper
    and    rbi.inpessoa = ass.inpessoa
    and    rbi.inprodut = 5
    and    ass.cdcooper = pr_cdcooper
    and    ass.nrdconta = pr_nrdconta
    and    lim.cdcooper = pr_cdcooper
    and    lim.nrdconta = pr_nrdconta
    and    lim.nrctrlim = pr_nrctrlim
    and    lim.tpctrlim = pr_tpctrlim;
  rw_craprbi cr_craprbi%rowtype;
  
  -- Buscar PA do operador de envio da proposta
  CURSOR cr_crapope IS
    select ope.cdpactra
    from   crapope ope
          ,crawlim lim
    where  ope.cdcooper = pr_cdcooper
    and    upper(ope.cdoperad) = upper(lim.cdoperad)
    and    lim.cdcooper = pr_cdcooper
    and    lim.nrdconta = pr_nrdconta
    and    lim.nrctrlim = pr_nrctrlim
    and    lim.tpctrlim = pr_tpctrlim;
  vr_cdpactra crapope.cdpactra%type;
  
  -- Buscar última data de consulta ao bacen
  CURSOR cr_crapopf IS
     SELECT max(opf.dtrefere) dtrefere
        FROM crapopf opf;
  rw_crapopf cr_crapopf%ROWTYPE;
  
  --> Buscar dados do limite
  CURSOR cr_crawlim IS
    select 'LIMITE DESCONTO TITULO' dsoperac
          ,0 flgreneg -- renegociacao: Indicaçao de Operaçao de Renegociaçao 
          ,lim.vllimite
          ,0 vlpreemp
          ,0 qtpreemp
          ,lim.dtinivig
          ,lim.dtfimvig
          ,ldc.cddlinha cdlcremp
          ,ldc.dsdlinha dslcremp
          ,lim.tpctrlim
          ,'LM' tpproduto
          ,/*ldc.*/1 tpctrato
          ,0 cdfinemp -- finalidadeCodigo: Codigo Finalidade da Proposta de Empréstimo
          ,'' dsfinemp -- finalidadeDescricao: Descricao Finalidade da Proposta de Empréstimo
          ,lim.inconcje
          ,lim.idquapro
          ,'0,0,0,0,0,0,0,0,0,0' dsliquid
          ,ass.nrcpfcgc
          ,ass.inpessoa
          ,'C' despagto --Tipo do Debito do Emprestimo: C-CONTA F-FOLHA
          ,ldc.txmensal
          ,0 perceto
          ,lim.qtdiavig
          ,lim.cddlinha
    from   crapldc ldc
          ,crapass ass
          ,crawlim lim
    where  ldc.cdcooper = lim.cdcooper
    and    ldc.cddlinha = lim.cddlinha
    and    ldc.tpdescto = lim.tpctrlim
    and    ass.cdcooper = lim.cdcooper
    and    ass.nrdconta = lim.nrdconta
    and    lim.cdcooper = pr_cdcooper
    and    lim.nrdconta = pr_nrdconta
    and    lim.nrctrlim = pr_nrctrlim
    and    lim.tpctrlim = pr_tpctrlim;
    rw_crawlim cr_crawlim%rowtype;
    
    -- Buscar os dados do associado
    CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%type,
                      pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT ass.inpessoa
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    
    -- Buscar dados titular
    CURSOR cr_crapttl(pr_cdcooper crapass.cdcooper%type,
                      pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT ttl.dtnasttl
            ,ttl.inhabmen
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper
         AND ttl.nrdconta = pr_nrdconta
         AND ttl.idseqttl = 1;                      
    rw_crapttl cr_crapttl%rowtype;
    
    -- Buscar avalistas terceiros
    CURSOR cr_crapavt(pr_cdcooper crapass.cdcooper%TYPE,
                      pr_nrdconta crapass.nrdconta%TYPE,
                      pr_nrctrlim crapavt.nrctremp%TYPE,
                      pr_tpctrato crapavt.tpctrato%TYPE,
                      pr_dsproftl crapavt.dsproftl%TYPE) IS
      SELECT crapavt.* --> necessario ser todos os campos pois envia como parametro
        FROM crapavt
       WHERE crapavt.cdcooper = pr_cdcooper
         AND crapavt.nrdconta = pr_nrdconta
         AND crapavt.nrctremp = pr_nrctrlim
         AND crapavt.tpctrato = pr_tpctrato
         AND (   pr_dsproftl IS NULL 
               OR ( pr_dsproftl = 'SOCIO' AND dsproftl IN('SOCIO/PROPRIETARIO'
                                                         ,'SOCIO ADMINISTRADOR'
                                                         ,'DIRETOR/ADMINISTRADOR'
                                                         ,'SINDICO'
                                                         ,'ADMINISTRADOR'))
               OR ( pr_dsproftl = 'PROCURADOR' AND dsproftl LIKE UPPER('%PROCURADOR%'))
              );
    rw_crapavt cr_crapavt%ROWTYPE;
    
    --> Buscar cadastro do Conjuge:
    CURSOR cr_crapcje (pr_cdcooper crapass.cdcooper%type,
                       pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT crapcje.nrctacje
            ,crapcje.nmconjug
            ,crapcje.nrcpfcjg
            ,crapcje.dtnasccj
            ,crapcje.tpdoccje
            ,crapcje.nrdoccje
            ,crapcje.grescola
            ,crapcje.cdfrmttl
            ,crapcje.cdnatopc
            ,crapcje.cdocpcje
            ,crapcje.tpcttrab
            ,crapcje.dsproftl
            ,crapcje.cdnvlcgo
            ,crapcje.nrfonemp
            ,crapcje.nrramemp
            ,crapcje.cdturnos
            ,crapcje.dtadmemp
            ,crapcje.vlsalari
            ,crapcje.nrdocnpj
            ,crapcje.cdufdcje
       FROM crapcje
      WHERE crapcje.cdcooper = pr_cdcooper
        AND crapcje.nrdconta = pr_nrdconta
        AND crapcje.idseqttl = 1;
    rw_crapcje cr_crapcje%ROWTYPE;
    
    --> Buscar representante legal
    CURSOR cr_crapcrl (pr_cdcooper crapass.cdcooper%type,
                       pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT crapcrl.cdcooper
            ,crapcrl.nrctamen
            ,crapcrl.idseqmen
            ,crapcrl.nrdconta
            ,crapcrl.nrcpfcgc
            ,crapcrl.nmrespon
            ,org.cdorgao_expedidor dsorgemi
            ,crapcrl.cdufiden
            ,crapcrl.dtemiden
            ,crapcrl.dtnascin
            ,crapcrl.cddosexo
            ,crapcrl.cdestciv
            ,crapnac.dsnacion
            ,crapcrl.dsnatura
            ,crapcrl.cdcepres
            ,crapcrl.dsendres
            ,crapcrl.nrendres
            ,crapcrl.dscomres
            ,crapcrl.dsbaires
            ,crapcrl.nrcxpost
            ,crapcrl.dscidres
            ,crapcrl.dsdufres
            ,crapcrl.nmpairsp
            ,crapcrl.nmmaersp
            ,crapcrl.tpdeiden
            ,crapcrl.nridenti
            ,crapcrl.cdrlcrsp
        FROM crapcrl,
             crapnac,
             tbgen_orgao_expedidor org
       WHERE crapcrl.cdcooper = pr_cdcooper
         AND crapcrl.nrctamen = pr_nrdconta
         AND crapcrl.cdnacion = crapnac.cdnacion(+)
         AND crapcrl.idorgexp = org.idorgao_expedidor(+);
    
    -- Declarar cursor de participaçoes societárias
    CURSOR cr_crapepa (pr_cdcooper crapass.cdcooper%type,
                       pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT cdcooper, 
             nrdconta, 
             nrdocsoc, 
             nrctasoc, 
             nmfansia, 
             nrinsest, 
             natjurid, 
             dtiniatv, 
             qtfilial, 
             qtfuncio, 
             dsendweb, 
             cdseteco, 
             cdmodali, 
             cdrmativ, 
             vledvmto, 
             dtadmiss, 
             dtmvtolt, 
             persocio, 
             nmprimtl
        FROM crapepa 
       WHERE cdcooper = pr_cdcooper 
         AND nrdconta = pr_nrdconta;
    
    -- Buscar descriçao
    CURSOR cr_nature (pr_natjurid gncdntj.cdnatjur%TYPE) IS
      SELECT gncdntj.dsnatjur
        FROM gncdntj
       WHERE gncdntj.cdnatjur = pr_natjurid;
    rw_nature cr_nature%ROWTYPE; 
    
    -- Buscar descriçao
    CURSOR cr_gnrativ ( pr_cdseteco gnrativ.cdseteco%TYPE,
                        pr_cdrmativ gnrativ.cdrmativ%TYPE)IS
      SELECT gnrativ.nmrmativ
        FROM gnrativ
       WHERE gnrativ.cdseteco = pr_cdseteco
         AND gnrativ.cdrmativ = pr_cdrmativ;    
    rw_gnrativ cr_gnrativ%ROWTYPE;
    
    
    -- Buscar os bens em garanita na Proposta
    CURSOR cr_crapbpr IS       
      SELECT crapbpr.dscatbem
            ,crapbpr.vlmerbem
            ,greatest(crapbpr.nranobem,crapbpr.nrmodbem) nranobem
            ,crapbpr.nrcpfbem
        FROM crapbpr 
       WHERE crapbpr.cdcooper = pr_cdcooper
         AND crapbpr.nrdconta = pr_nrdconta
         AND crapbpr.nrctrpro = pr_nrctrlim
         AND crapbpr.tpctrpro = 3
         AND trim(crapbpr.dscatbem) is not NULL;
    
    -- Buscar Saldo de Cotas
    CURSOR cr_crapcot(pr_cdcooper crapass.cdcooper%type,
                      pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT vldcotas
        FROM crapcot
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta;
    vr_vldcotas crapcot.vldcotas%TYPE;
    
    --> Buscar se a conta é de Colaborador Cecred
    CURSOR cr_tbcolab(pr_cdcooper crapcop.cdcooper%TYPE
                     ,pr_nrcpfcgc crapass.nrcpfcgc%TYPE) IS 
                     
      SELECT substr(lpad(col.cddcargo_vetor,7,'0'),5,3) cddcargo
        FROM tbcadast_colaborador col       
       WHERE col.cdcooper = pr_cdcooper
         AND col.nrcpfcgc = pr_nrcpfcgc
         AND col.flgativo = 'A';         
     
    CURSOR cr_crapprp IS
    SELECT prp.flgdocje
     FROM crapprp prp
    WHERE prp.cdcooper = pr_cdcooper
      AND prp.nrdconta = pr_nrdconta
     AND prp.nrctrato = pr_nrctrlim
     AND prp.tpctrato = 3;
  rw_crapprp cr_crapprp%ROWTYPE;
   
    CURSOR cr_crapepr (pr_cdcooper IN crapepr.cdcooper%TYPE
                      ,pr_nrdconta IN crapepr.nrdconta%TYPE
                      ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
      SELECT nvl(vlpreemp,0)
        FROM crapepr
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctremp = pr_nrctremp;

  
    --Tipo de registro do tipo data
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
     
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(500);
    vr_exc_erro EXCEPTION;

    -- Objeto json    
    vr_obj_analise   json      := json();
    vr_obj_conjuge   json      := json();
    vr_obj_avalista  json      := json();
    vr_obj_responsav json      := json();
    vr_obj_socio     json      := json();
    vr_obj_particip  json      := json();
    vr_obj_procurad  json      := json();
    vr_obj_generico  json      := json();
    vr_obj_generic2  json      := json();
    vr_lst_generico  json_list := json_list();
    vr_lst_generic2  json_list := json_list();
    
    vr_flavalis      BOOLEAN := FALSE;
    vr_flrespvl      BOOLEAN := FALSE;
    vr_flsocios      BOOLEAN := FALSE;
    vr_flpartic      BOOLEAN := FALSE;
    vr_flprocura     BOOLEAN := FALSE;
    vr_flgbens       BOOLEAN := FALSE;
    vr_nrdeanos      INTEGER;
    vr_nrdmeses      INTEGER;
    vr_dsdidade      VARCHAR2(100);
    vr_dstextab      craptab.dstextab%TYPE;
    vr_nmseteco      craptab.dstextab%TYPE;
    vr_dstpgara      craptab.dstextab%TYPE;
    vr_dsquapro      VARCHAR2(100);
    vr_flgcolab      BOOLEAN;
    vr_cddcargo      tbcadast_colaborador.cdcooper%TYPE;
    vr_qtdiarpv      INTEGER;
    vr_valoriof      NUMBER;
    vr_tab_split     gene0002.typ_split;
    vr_dsliquid      VARCHAR2(1000);
    vr_sum_vlpreemp  crapepr.vlpreemp%TYPE := 0;
    vr_vlpreemp      crapepr.vlpreemp%TYPE;
    vr_txcetano      NUMBER;
    vr_txcetmes      NUMBER;
      
  BEGIN
  
    --Verificar se a data existe
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se nao encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      CLOSE BTCH0001.cr_crapdat;
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;  
  
    vr_obj_analise.put('proposta', gene0002.fn_mask_contrato(pr_nrctrlim));
                      
   -- Buscar quantidade de dias de reaproveitamento             
    OPEN cr_craprbi;
    FETCH cr_craprbi INTO rw_craprbi;
    
    -- Se encontrou
    IF cr_craprbi%FOUND THEN
     -- Buscar a coluna e multiplicar por 24 para chegarmos na quantidade de horas de reaproveitamento
     vr_qtdiarpv := rw_craprbi.qtdiarpv * 24;
    ELSE
     -- Se nao encontrar consideramos 168 horas (7 dias)
     vr_qtdiarpv := 168;
    END IF;
    CLOSE cr_craprbi;
  
  -- Buscar PA do operador
  OPEN cr_crapope;
  FETCH cr_crapope INTO vr_cdpactra;
    CLOSE cr_crapope;
  
  OPEN cr_crapopf;
  FETCH cr_crapopf INTO rw_crapopf;
    IF cr_crapopf%NOTFOUND THEN
      CLOSE cr_crapopf;
      vr_dscritic := 'Data Base Bacen-SCR nao encontrada!';
      RAISE vr_exc_erro;
    ELSE
    CLOSE cr_crapopf;
    END IF;
  
  -- Montar os atributos de 'configuracoes'
  vr_obj_generico := json();
  vr_obj_generico.put('centroCusto', vr_cdpactra);
    vr_obj_generico.put('dataBaseBacen', to_char(rw_crapopf.dtrefere,'RRRRMM'));
  vr_obj_generico.put('horasReaproveitamento', vr_qtdiarpv);
  
    -- Adicionar o array configuracoes
    vr_obj_analise.put('configuracoes', vr_obj_generico);                  
                  
    --> Buscar dados da proposta de emprestimo
    OPEN cr_crawlim;
    FETCH cr_crawlim INTO rw_crawlim;
    
    -- Caso nao encontrar abortar proceso
    IF cr_crawlim%NOTFOUND THEN
      CLOSE cr_crawlim;
      vr_cdcritic := 535; -- 535 - Proposta nao encontrada.
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crawlim;
    
    --> indicadoresCliente
    vr_obj_generico := json();
    
    vr_obj_generico.put('cooperativa', pr_cdcooper); 
    vr_obj_generico.put('agenci', pr_cdagenci);

    vr_obj_generico.put('segmentoCodigo' ,3); 
    vr_obj_generico.put('segmentoDescricao' ,'Limite Desct Titulo');     

    vr_obj_generico.put('linhaCreditoCodigo'    ,rw_crawlim.cdlcremp);
    vr_obj_generico.put('linhaCreditoDescricao' ,rw_crawlim.dslcremp);
    vr_obj_generico.put('finalidadeCodigo'      ,rw_crawlim.cdfinemp);       
    vr_obj_generico.put('finalidadeDescricao'   ,rw_crawlim.dsfinemp);                

    vr_obj_generico.put('tipoProduto'           ,rw_crawlim.tpproduto);
    
    /* Paulo Penteado (GFT): 02/03/2018 - Por hora iremos considerar as tags 
       tipoGarantiaCodigo e tipoGarantiaDescricao como sendo 1 e 'LIMITE DESC TITUL0' até a liberaçao 
       a alteraçao 404 ser liberada. Pois na 404 será criado o campo crapldc.tpctrato */
    vr_obj_generico.put('tipoGarantiaCodigo'    ,rw_crawlim.tpctrato );
    --> Buscar descriçao do tipo de garantia
    vr_dstpgara  := 'LIMITE DESC TITUL0';
                    /*tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper,
                                               pr_nmsistem => 'CRED',
                                               pr_tptabela => 'GENERI', 
                                               pr_cdempres => 0, 
                                               pr_cdacesso => 'CTRATOEMPR', 
                                               pr_tpregist => rw_crawlim.tpctrato);*/
    vr_obj_generico.put('tipoGarantiaDescricao'    ,TRIM(vr_dstpgara) );

    vr_obj_generico.put('debitoEm'    ,rw_crawlim.despagto );
    vr_obj_generico.put('liquidacao'  ,rw_crawlim.dsliquid!='0,0,0,0,0,0,0,0,0,0');

    vr_obj_generico.put('valorTaxaMensal', ESTE0001.fn_decimal_ibra(rw_crawlim.txmensal));

    vr_obj_generico.put('valorEmprest'  , ESTE0001.fn_decimal_ibra(rw_crawlim.vllimite));
    vr_obj_generico.put('quantParcela'  , rw_crawlim.qtpreemp);
    vr_obj_generico.put('primeiroVencto', este0002.fn_data_ibra_motor(rw_crawlim.dtfimvig));
    vr_obj_generico.put('valorParcela'  , ESTE0001.fn_decimal_ibra(rw_crawlim.vlpreemp));

    vr_obj_generico.put('renegociacao', nvl(rw_crawlim.flgreneg,0) = 1);

    vr_obj_generico.put('qualificaOperacaoCodigo',rw_crawlim.idquapro );

    CASE rw_crawlim.idquapro
      WHEN 1 THEN vr_dsquapro := 'Operacao normal';
      WHEN 2 THEN vr_dsquapro := 'Renovacao de credito';
      WHEN 3 THEN vr_dsquapro := 'Renegociacao de credito';
      WHEN 4 THEN vr_dsquapro := 'Composicao da divida';
      ELSE vr_dsquapro := ' ';
    END CASE;

    vr_obj_generico.put('qualificaOperacaoDescricao'    ,vr_dsquapro );
         
    IF rw_crawlim.inpessoa = 1 THEN 
      -- Verificar se a conta é de colaborador do sistema Cecred
      vr_cddcargo := NULL;
      OPEN cr_tbcolab(pr_cdcooper => pr_cdcooper
                     ,pr_nrcpfcgc => rw_crawlim.nrcpfcgc);
      FETCH cr_tbcolab INTO vr_cddcargo;
      IF cr_tbcolab%FOUND THEN 
        vr_flgcolab := TRUE;
      ELSE
        vr_flgcolab := FALSE;
      END IF;
      CLOSE cr_tbcolab; 
              
      vr_obj_generico.put('cooperadoColaborador',vr_flgcolab);
   
   OPEN cr_crapprp;
   FETCH cr_crapprp INTO rw_crapprp;
   CLOSE cr_crapprp;
      vr_obj_generico.put('conjugeCoResponv',nvl(rw_crapprp.flgdocje,0)=1);

    END IF;
    
    -- Efetuar laço para trazer todos os registros 
    FOR rw_crapbpr IN cr_crapbpr LOOP 

      -- Indicar que encontrou
      vr_flgbens := TRUE;
      -- Para cada registro de Bem, criar objeto para a operaçao e enviar suas informaçoes 
      vr_lst_generic2 := json_list();
      vr_obj_generic2 := json();
      vr_obj_generic2.put('categoriaBem',     rw_crapbpr.dscatbem);
      vr_obj_generic2.put('anoGarantia',      rw_crapbpr.nranobem);
      vr_obj_generic2.put('valorGarantia',    ESTE0001.fn_decimal_ibra(rw_crapbpr.vlmerbem));
      vr_obj_generic2.put('bemInterveniente', rw_crapbpr.nrcpfbem <> 0);

      -- Adicionar Bem na lista
      vr_lst_generic2.append(vr_obj_generic2.to_json_value());
  
    END LOOP; -- Final da leitura dos Bens

    -- Adicionar o array bemEmGarantia
    IF vr_flgbens THEN
      vr_obj_generico.put('bemEmGarantia', vr_lst_generic2);
    ELSE
      -- Verificar se o valor das Cotas é Superior ao da Proposta
      OPEN cr_crapcot(pr_cdcooper
                     ,pr_nrdconta);
      FETCH cr_crapcot
       INTO vr_vldcotas;
      CLOSE cr_crapcot;
      -- Se valor das cotas é superior ao da proposta
      IF NVL(vr_vldcotas,0) > rw_crawlim.vllimite THEN 
        -- Adicionar as cotas  
        vr_lst_generic2 := json_list();
        vr_obj_generic2 := json();
        vr_obj_generic2.put('categoriaBem','COTAS CAPITAL');
        vr_obj_generic2.put('anoGarantia',0);
        vr_obj_generic2.put('valorGarantia',ESTE0001.fn_decimal_ibra(vr_vldcotas));
        vr_obj_generic2.put('bemInterveniente',false);
        -- Adicionar Bem na lista
        vr_lst_generic2.append(vr_obj_generic2.to_json_value());
        -- Adicionar as cotas como garantia
        vr_obj_generico.put('bemEmGarantia', vr_lst_generic2);
      END IF;
    END IF;  
    
    vr_obj_generico.put('operacao', rw_crawlim.dsoperac); 
    
    -- Buscar IOF
    vr_valoriof := 0;
    vr_obj_generico.put('IOFValor', este0001.fn_decimal_ibra(nvl(vr_valoriof,0)));

    IF rw_crawlim.dsliquid <> '0,0,0,0,0,0,0,0,0,0' THEN
      vr_tab_split := gene0002.fn_quebra_string(rw_crawlim.dsliquid, ',');
      
      vr_dsliquid := vr_tab_split.FIRST;
          
      vr_sum_vlpreemp := 0;
      
      WHILE vr_dsliquid IS NOT NULL LOOP
        
        IF vr_tab_split(vr_dsliquid) <> '0' THEN
          
          OPEN cr_crapepr (pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrctremp => vr_tab_split(vr_dsliquid));
          FETCH cr_crapepr INTO vr_vlpreemp;
          CLOSE cr_crapepr;
          vr_sum_vlpreemp := vr_sum_vlpreemp + vr_vlpreemp;
          
        END IF;
        vr_dsliquid := vr_tab_split.NEXT(vr_dsliquid);    
      END LOOP;
    END IF;
    
    vr_obj_generico.put('valorPrestLiquidacao', ESTE0001.fn_decimal_ibra(vr_sum_vlpreemp));

    vr_obj_analise.put('indicadoresCliente', vr_obj_generico);         
    
    pc_gera_json_pessoa_ass(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_dsjsonan => vr_obj_generico
                           ,pr_cdcritic => vr_cdcritic 
                           ,pr_dscritic => vr_dscritic);
                           
     -- Testar possíveis erros na rotina:
     IF nvl(vr_cdcritic,0) <> 0 OR 
        trim(vr_dscritic) IS NOT NULL THEN 
       RAISE vr_exc_erro;
     END IF;    
       
    -- Adicionar o JSON montado do Proponente no objeto principal
    vr_obj_analise.put('proponente',vr_obj_generico);
    
    rw_crapass := NULL;
    --> Buscar dados do associado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    
    -- Caso nao encontrar abortar proceso
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_cdcritic := 9;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapass;
    
    --> Para Pessoa Fisica iremos buscar seu Conjuge
    IF rw_crapass.inpessoa = 1 THEN 
    
      --> Buscar cadastro do Conjuge
      rw_crapcje := NULL;
      OPEN cr_crapcje( pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta);
      FETCH cr_crapcje INTO rw_crapcje;
     
      -- Se nao encontrar 
      IF cr_crapcje%NOTFOUND THEN
        -- apenas fechamos o cursor
        CLOSE cr_crapcje;
      ELSE   
        -- Fechar o cursor e enviar 
        CLOSE cr_crapcje;
        --> Se Conjuge for associado:
        IF rw_crapcje.nrctacje <> 0 THEN 

          -- Passaremos a conta para montagem dos dados:
          pc_gera_json_pessoa_ass(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => rw_crapcje.nrctacje
                                 ,pr_vlsalari => rw_crapcje.vlsalari
                                 ,pr_dsjsonan => vr_obj_conjuge
                                 ,pr_cdcritic => vr_cdcritic 
                                 ,pr_dscritic => vr_dscritic);

          -- Testar possíveis erros na rotina:
          IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
            RAISE vr_exc_erro;
          END IF; 
            
          -- Adicionar o JSON montado do Proponente no objeto principal
          vr_obj_analise.put('conjuge',vr_obj_conjuge);

        ELSE
          -- Enviaremos os dados básicos encontrados na tabela de conjugue
          vr_obj_conjuge.put('documento'      ,este0002.fn_mask_cpf_cnpj(rw_crapcje.nrcpfcjg,1));
          vr_obj_conjuge.put('tipoPessoa'     ,'FISICA');
          vr_obj_conjuge.put('nome'           ,rw_crapcje.nmconjug);
          
          vr_obj_conjuge.put('dataNascimento' ,este0002.fn_data_ibra_motor(rw_crapcje.dtnasccj));
          
          -- Se o Documento for RG
          IF rw_crapcje.tpdoccje = 'CI' THEN
            vr_obj_conjuge.put('rg', rw_crapcje.nrdoccje);
            vr_obj_conjuge.put('ufRg', rw_crapcje.cdufdcje);
          END IF;
          
          -- Montar objeto Telefone para Telefone Comercial      
          IF rw_crapcje.nrfonemp <> ' ' THEN 
            vr_lst_generic2 := json_list();
            -- Criar objeto só para este telefone
            vr_obj_generico := json();
            vr_obj_generico.put('especie', 'COMERCIAL');
            /*
            IF SUBSTR(rw_crapcje.nrfonemp,1,1) < 8 THEN 
              vr_obj_generico.put('tipo', 'FIXO');
            ELSE
              vr_obj_generico.put('tipo', 'MOVEL');
            END IF;
   */
            
            vr_obj_generico.put('numero', este0002.fn_somente_numeros_telefone(rw_crapcje.nrfonemp));
            -- Adicionar telefone na lista
            vr_lst_generic2.append(vr_obj_generico.to_json_value());
            -- Adicionar o array telefone no objeto Conjuge
            vr_obj_conjuge.put('telefones', vr_lst_generic2);
              
          END IF;     

          -- Montar objeto profissao       
          IF rw_crapcje.dsproftl <> ' ' THEN 
            vr_obj_generico := json();
            vr_obj_generico.put('titulo'   , rw_crapcje.dsproftl);
            vr_obj_conjuge.put ('profissao', vr_obj_generico);
          END IF;     
          
          -- Montar informaçoes Adicionais
          vr_obj_generico := json();
          -- Escolaridade
          IF rw_crapcje.grescola <> 0 THEN 
            vr_obj_generico.put('escolaridade', rw_crapcje.grescola);
          END IF;
          -- Curso Superior
          IF rw_crapcje.cdfrmttl <> 0 THEN 
            vr_obj_generico.put('cursoSuperiorCodigo'
                               ,rw_crapcje.cdfrmttl);
            vr_obj_generico.put('cursoSuperiorDescricao'
                               ,este0002.fn_des_cdfrmttl(rw_crapcje.cdfrmttl));
          END IF;
          -- Natureza Ocupaçao
          IF rw_crapcje.cdnatopc <> 0 THEN 
            vr_obj_generico.put('naturezaOcupacao', rw_crapcje.cdnatopc);
          END IF;
          -- Ocupaçao
          IF rw_crapcje.cdocpcje <> 0 THEN 
            vr_obj_generico.put('ocupacaoCodigo'
                               ,rw_crapcje.cdocpcje);
            vr_obj_generico.put('ocupacaoDescricao'
                               ,este0002.fn_des_cdocupa(rw_crapcje.cdocpcje));
          END IF;
          -- Tipo Contrato de Trabalho
          IF rw_crapcje.tpcttrab <> 0 THEN 
            vr_obj_generico.put('tipoContratoTrabalho', rw_crapcje.tpcttrab);
          END IF;
          -- Nivel Cargo
          IF rw_crapcje.cdnvlcgo <> 0 THEN 
            vr_obj_generico.put('nivelCargo', rw_crapcje.cdnvlcgo);
          END IF;
          -- Turno
          IF rw_crapcje.cdturnos <> 0 THEN 
            vr_obj_generico.put('turno', rw_crapcje.cdturnos);
          END IF;
          -- Data Admissao
          IF rw_crapcje.dtadmemp IS NOT NULL THEN 
            vr_obj_generico.put('dataAdmissao', este0002.fn_data_ibra_motor(rw_crapcje.dtadmemp));
          END IF;
          -- Salario
          IF rw_crapcje.vlsalari <> 0 THEN 
            vr_obj_generico.put('valorSalario', ESTE0001.fn_decimal_ibra(rw_crapcje.vlsalari));
          END IF;
          -- CNPJ Empresa
          IF rw_crapcje.nrdocnpj <> 0 THEN 
            vr_obj_generico.put('codCNPJEmpresa', rw_crapcje.nrdocnpj);
          END IF;
          -- Enviar informaçoes adicionais ao JSON Conjuge
          vr_obj_conjuge.put('informacoesAdicionais' ,vr_obj_generico);        
              
          -- Ao final adicionamos o json montado ao principal
          vr_obj_analise.put('conjuge' ,vr_obj_conjuge);        
        END IF; 
        
      END IF;  
    END IF;

    --> Chamar rorina para calcular o contrato do cet
    CCET0001.pc_calculo_cet_limites( pr_cdcooper  => pr_cdcooper         -- Cooperativa
                                    ,pr_dtmvtolt  => rw_crapdat.dtmvtolt -- Data Movimento
                                    ,pr_cdprogra  => 'ATENDA'            -- Programa chamador
                                    ,pr_nrdconta  => pr_nrdconta         -- Conta/dv
                                    ,pr_inpessoa  => rw_crapass.inpessoa -- Indicativo de pessoa
                                    ,pr_cdusolcr  => 1                   -- Codigo de uso da linha de credito
                                    ,pr_cdlcremp  => rw_crawlim.cddlinha -- Linha de credio
                                    ,pr_tpctrlim  => pr_tpctrlim         --> Tipo da operacao (1-Chq Esp./ 2-Desc Chq./ 3-Desc Tit)
                                    ,pr_nrctrlim  => pr_nrctrlim         -- Contrato
                                    ,pr_dtinivig  => nvl(rw_crawlim.dtinivig,rw_crapdat.dtmvtolt) -- Data liberacao
                                    ,pr_qtdiavig  => rw_crawlim.qtdiavig -- Dias de vigencia
                                    ,pr_vlemprst  => rw_crawlim.vllimite -- Valor emprestado
                                    ,pr_txmensal  => rw_crawlim.txmensal -- Taxa mensal
                                    ,pr_txcetano  => vr_txcetano         -- Taxa cet ano
                                    ,pr_txcetmes  => vr_txcetmes         -- Taxa cet mes
                                    ,pr_cdcritic  => vr_cdcritic
                                    ,pr_dscritic  => vr_dscritic);

    vr_obj_generico.put('CETValor', este0001.fn_decimal_ibra(nvl(vr_txcetano,0)));
    
    --> BUSCAR AVALISTAS INTERNOS E EXTERNOS: 
    -- Inicializar lista de Avalistas
    vr_lst_generico := json_list();
 
    -- Enviar avalista 01 em novo json só para avalistas
    IF nvl(pr_nrctaav1,0) <> 0 THEN
      -- Setar flag para indicar que há avalista
      vr_flavalis := true;
      
      pc_gera_json_pessoa_ass(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => pr_nrctaav1
                             ,pr_dsjsonan => vr_obj_avalista
                             ,pr_cdcritic => vr_cdcritic 
                             ,pr_dscritic => vr_dscritic);

      -- Testar possíveis erros na rotina:
      IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
        RAISE vr_exc_erro;
      END IF;

      -- Adicionar o avalista montato na lista de avalistas
      vr_lst_generico.append(vr_obj_avalista.to_json_value());

    END IF;
    
    -- Enviar avalista 02 em novo json só para avalistas
    IF nvl(pr_nrctaav2,0) <> 0 THEN
      -- Setar flag para indicar que há avalista
      vr_flavalis := true;
      
      pc_gera_json_pessoa_ass(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => pr_nrctaav2
                             ,pr_dsjsonan => vr_obj_avalista
                             ,pr_cdcritic => vr_cdcritic 
                             ,pr_dscritic => vr_dscritic);

      -- Testar possíveis erros na rotina:
      IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
        RAISE vr_exc_erro;
      END IF;

      -- Adicionar o avalista montato na lista de avalistas
      vr_lst_generico.append(vr_obj_avalista.to_json_value());

    END IF;
    
    --> Efetuar laço para retornar todos os registros disponíveis:
    FOR rw_crapavt IN cr_crapavt(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta 
                                ,pr_nrctrlim => pr_nrctrlim
                                ,pr_tpctrato => 8
                                ,pr_dsproftl => null) LOOP
                                 
      -- Setar flag para indicar que há avalista
      vr_flavalis := true;
      -- Enviaremos os dados básicos encontrados na tabela de avalistas terceiros 
      este0002.pc_gera_json_pessoa_avt(pr_rw_crapavt => rw_crapavt
                                      ,pr_dsjsonavt  => vr_obj_avalista
                                      ,pr_cdcritic   => vr_cdcritic 
                                      ,pr_dscritic   => vr_dscritic);
      -- Testar possíveis erros na rotina:
      IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
        RAISE vr_exc_erro;
      END IF; 
      
      -- Adicionar o avalista montato na lista de avalistas
      vr_lst_generico.append(vr_obj_avalista.to_json_value());
      
      
    END LOOP; --> crapavt                             
    
    -- Enviar novo objeto de avalistas para dentro do objeto principal (Se houve encontro) 
    IF vr_flavalis = true THEN
      vr_obj_analise.put('avalistas' , vr_lst_generico);
    END IF; 
  
    --> Para pessoa física verificaremos necessidade de envio dos responsáveis legais:
    IF rw_crapass.inpessoa = 1 THEN 
      
       -- Buscar dados titular
       OPEN cr_crapttl(pr_cdcooper,pr_nrdconta);
       FETCH cr_crapttl
        INTO rw_crapttl;
       CLOSE cr_crapttl; 
         
       -- Inicializar idade
       vr_nrdeanos := 18;    
       -- Se menor de idade 
       IF rw_crapttl.inhabmen = 0  THEN 
         -- Verifica a idade
         cada0001.pc_busca_idade(pr_dtnasctl => rw_crapttl.dtnasttl
                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                ,pr_nrdeanos => vr_nrdeanos
                                ,pr_nrdmeses => vr_nrdmeses
                                ,pr_dsdidade => vr_dsdidade
                                ,pr_des_erro => vr_dscritic);

         -- Verficia se ocorreram erros
         IF vr_dscritic IS NOT NULL THEN
           vr_nrdeanos := 18;
         END IF;
       END IF;
    
      -- Se menor de idade ou incapaz
      IF vr_nrdeanos < 18 OR rw_crapttl.inhabmen = 2 THEN
      
        -- Inicializar lista de Representantes
        vr_lst_generico := json_list();
        
        --> Efetuar laço para retornar todos os registros disponíveis
        FOR rw_crapcrl IN cr_crapcrl ( pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta ) LOOP
          -- Setar flag para indicar que há responsaveis
          vr_flrespvl := true;
          
          --> Se Responsável for associado
          IF rw_crapcrl.nrdconta <> 0 THEN 
            -- Passaremos a conta para montagem dos dados:
            pc_gera_json_pessoa_ass(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => rw_crapcrl.nrdconta
                                   ,pr_dsjsonan => vr_obj_responsav
                                   ,pr_cdcritic => vr_cdcritic 
                                   ,pr_dscritic => vr_dscritic); 
            -- Testar possíveis erros na rotina:
            IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
              RAISE vr_exc_erro;
            END IF;
            
            -- Adicionar o avalista montato na lista de avalistas
            vr_lst_generico.append(vr_obj_responsav.to_json_value());

         ELSE
           -- Enviaremos os dados básicos encontrados na tabela de responsável legal
           vr_obj_responsav.put('documento'      , este0002.fn_mask_cpf_cnpj(rw_crapcrl.nrcpfcgc,1));
           vr_obj_responsav.put('tipoPessoa'     ,'FISICA');
           vr_obj_responsav.put('nome'           ,rw_crapcrl.nmrespon);
           IF rw_crapcrl.cddosexo = 1 THEN
             vr_obj_responsav.put('sexo','MASCULINO');
           ELSE
             vr_obj_responsav.put('sexo','FEMININO');
           END IF;
           
           IF rw_crapcrl.dtnascin IS NOT NULL THEN 
             vr_obj_responsav.put('dataNascimento' ,este0002.fn_data_ibra_motor(rw_crapcrl.dtnascin));
           END IF;
           
           IF rw_crapcrl.nmmaersp IS NOT NULL THEN 
             vr_obj_responsav.put('nomeMae' ,rw_crapcrl.nmmaersp);
           END IF;
           
           vr_obj_responsav.put('nacionalidade'  ,rw_crapcrl.dsnacion);

           -- Se o Documento for RG
           IF rw_crapcrl.tpdeiden = 'CI' THEN
             vr_obj_responsav.put('rg', rw_crapcrl.nridenti);
             vr_obj_responsav.put('ufRg', rw_crapcrl.cdufiden);
           END IF; 

           -- Montar objeto Endereco
           IF rw_crapcrl.dsendres <> ' ' THEN 
             vr_obj_generico := json();
     
             vr_obj_generico.put('logradouro'  , rw_crapcrl.dsendres);
             vr_obj_generico.put('numero'      , rw_crapcrl.nrendres);
             vr_obj_generico.put('complemento' , rw_crapcrl.dscomres);
             vr_obj_generico.put('bairro'      , rw_crapcrl.dsbaires);
             vr_obj_generico.put('cidade'      , rw_crapcrl.dscidres);
             vr_obj_generico.put('uf'          , rw_crapcrl.dsdufres);
             vr_obj_generico.put('cep'         , rw_crapcrl.cdcepres);

             vr_obj_responsav.put('endereco', vr_obj_generico);
           END IF;     
        
           -- Montar informaçoes Adicionais
           vr_obj_generico := json();
           
           -- Nome Pai
           IF rw_crapcrl.nmpairsp <> ' ' THEN 
             vr_obj_generico.put('nomePai', rw_crapcrl.nmpairsp);
           END IF;
           -- Estado Civil
           IF rw_crapcrl.cdestciv <> 0 THEN 
             vr_obj_generico.put('estadoCivil', rw_crapcrl.cdestciv);
           END IF;
           -- Naturalidade
           IF rw_crapcrl.dsnatura <> ' ' THEN 
             vr_obj_generico.put('naturalidade', rw_crapcrl.dsnatura);
           END IF;
           -- Caixa Postal
           IF rw_crapcrl. nrcxpost <> 0 THEN 
             vr_obj_generico.put('caixaPostal', rw_crapcrl.nrcxpost);
           END IF;
     
           -- Enviar informaçoes adicionais ao JSON Responsavel Leval
           vr_obj_responsav.put('informacoesAdicionais' ,vr_obj_generico);     

           -- Adicionar o responsavel montato na lista de responsaveis
           vr_lst_generico.append(vr_obj_responsav.to_json_value());
         END IF;
          
          
        END LOOP; --> crapcrl  
        
        -- Enviar novo objeto de responsaveis para dentro do objeto principal
        -- (Somente se encontramos)
        IF vr_flrespvl THEN 
          vr_obj_analise.put('representantesLegais' ,vr_lst_generico);    
        END IF;
                
      END IF;
    END IF; -- INPESSOA
    
    --> Para pessoa Jurídica buscaremos os sócios da Empresa:
    IF rw_crapass.inpessoa = 2 THEN
    
      -- Inicializar lista de Representantes
      vr_lst_generico := json_list();
    
      --> Efetuar laço para retornar todos os registros disponíveis:
      FOR rw_crapavt IN cr_crapavt(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta 
                                  ,pr_nrctrlim => pr_nrctrlim
                                  ,pr_tpctrato => 8
                                  ,pr_dsproftl => 'SOCIO') LOOP 
    
        -- Setar flag para indicar que há sócio
        vr_flsocios := true;
        -- Se socio for associado
        IF rw_crapavt.nrdctato > 0 THEN 
          -- Passaremos a conta para montagem dos dados:
          pc_gera_json_pessoa_ass(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => rw_crapavt.nrdctato
                                 ,pr_dsjsonan => vr_obj_socio
                                 ,pr_persocio => rw_crapavt.persocio
                                 ,pr_dtadmsoc => rw_crapavt.dtadmsoc
                                 ,pr_dtvigpro => rw_crapavt.dtvalida
                                 ,pr_cdcritic => vr_cdcritic 
                                 ,pr_dscritic => vr_dscritic);
          -- Testar possíveis erros na rotina:
          IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
            RAISE vr_exc_erro;
          END IF;  
          
          -- Adicionar o responsavel montato na lista de socios
          vr_lst_generico.append(vr_obj_socio.to_json_value());
          null;

        ELSE
          -- Enviaremos os dados básicos encontrados na tabela de socios
          este0002.pc_gera_json_pessoa_avt(pr_rw_crapavt => rw_crapavt
                                          ,pr_dsjsonavt  => vr_obj_socio
                                          ,pr_cdcritic   => vr_cdcritic 
                                          ,pr_dscritic   => vr_dscritic);
          -- Testar possíveis er ros na rotina:
          IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
            RAISE vr_exc_erro;
          END IF; 
          -- Adicionar o responsavel montato na lista de socios
          vr_lst_generico.append(vr_obj_socio.to_json_value());

        END IF;
      
      
      END LOOP; --Fim crapavt
      
      -- Enviar novo objeto de socios para dentro do objeto principal (Se houve encontro) 
      IF vr_flsocios = true THEN      
        vr_obj_analise.put('socios' ,vr_lst_generico); 
      END IF;
       
      --> Busca das participaçoes societárias
      
      -- Inicializar lista de Participaçoes Societárias
      vr_lst_generico := json_list();
      
      --> Efetuar laço para retornar todos os registros disponíveis de participaçoes:
      FOR rw_crapepa IN cr_crapepa( pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta)  LOOP
        -- Setar flag para indicar que há participaçoes
        vr_flpartic := true;
        -- Se socio for associado
        IF rw_crapepa.nrctasoc > 0 THEN 
          -- Passaremos a conta para montagem dos dados:
          pc_gera_json_pessoa_ass(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => rw_crapepa.nrctasoc
                                 ,pr_persocio => rw_crapepa.persocio
                                 ,pr_dtadmsoc => rw_crapepa.dtadmiss
                                 ,pr_dtvigpro => to_date('31/12/9999','dd/mm/rrrr')
                                 ,pr_dsjsonan => vr_obj_particip
                                 ,pr_cdcritic => vr_cdcritic 
                                 ,pr_dscritic => vr_dscritic); 
          -- Testar possíveis erros na rotina:
          IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
            RAISE vr_exc_erro;
          END IF;  
          -- Adicionar o responsavel montato na lista de socios
          vr_lst_generico.append(vr_obj_particip.to_json_value());

        ELSE
          -- Enviaremos os dados básicos encontrados na tabela de Participaçoes    
          vr_obj_particip.put('documento'      ,este0002.fn_mask_cpf_cnpj(rw_crapepa.nrdocsoc,2));
          vr_obj_particip.put('tipoPessoa'     ,'JURIDICA');
          vr_obj_particip.put('razaoSocial'    ,rw_crapepa.nmprimtl);
          
          IF rw_crapepa.dtiniatv IS NOT NULL THEN 
            vr_obj_particip.put('dataFundacao' ,este0002.fn_data_ibra_motor(rw_crapepa.dtiniatv));
          END IF;
          
          -- Montar informaçoes Adicionais
          vr_obj_generico := json();

          -- Conta
          vr_obj_generico.put('conta', to_number(substr(rw_crapepa.nrdconta,1,length(rw_crapepa.nrdconta)-1)));
          vr_obj_generico.put('contaDV', to_number(substr(rw_crapepa.nrdconta,-1)));
          
          IF INSTR(rw_crapepa.dsendweb,'@') > 0 THEN
            vr_obj_generico.put('email', rw_crapepa.dsendweb);
          END IF;
          
          -- Natureza Juridica
          IF rw_crapepa.natjurid <> 0 THEN 
            --> Buscar descriçao
            OPEN cr_nature(pr_natjurid => rw_crapepa.natjurid);
            FETCH cr_nature INTO rw_nature;
            CLOSE cr_nature;

            vr_obj_generico.put('naturezaJuridica', rw_crapepa.natjurid||'-'||rw_nature.dsnatjur);
          END IF;
          
          -- Quantidade Filiais
          vr_obj_generico.put('quantFiliais', rw_crapepa.qtfilial);

          -- Quantidade Funcionários
          vr_obj_generico.put('quantFuncionarios', rw_crapepa.qtfuncio);
        
          -- Ramo Atividade
          IF rw_crapepa.cdseteco <> 0 AND rw_crapepa.cdrmativ <> 0 THEN 
              
            OPEN cr_gnrativ (pr_cdseteco => rw_crapepa.cdseteco, 
                             pr_cdrmativ => rw_crapepa.cdrmativ );
            FETCH cr_gnrativ INTO rw_gnrativ;
            CLOSE cr_gnrativ;
            
            vr_obj_generico.put('ramoAtividade', rw_crapepa.cdrmativ ||'-'||rw_gnrativ.nmrmativ);
          END IF;
          
          -- Setor Economico
          IF rw_crapepa.cdseteco <> 0 THEN 
          
            -- Buscar descriçao
            vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                     ,pr_nmsistem => 'CRED'
                                                     ,pr_tptabela => 'GENERI'
                                                     ,pr_cdempres => 0
                                                     ,pr_cdacesso => 'SETORECONO'
                                                     ,pr_tpregist => rw_crapepa.cdseteco);
            -- Se Encontrou
            IF TRIM(vr_dstextab) IS NOT NULL THEN
              vr_nmseteco := vr_dstextab;
            ELSE
              vr_nmseteco := 'Nao Cadastrado';
            END IF;
            vr_obj_generico.put('setorEconomico', rw_crapepa.cdseteco ||'-'|| vr_nmseteco);
          END IF;

          -- Numero Inscriçao Estadual
          IF rw_crapepa.nrinsest <> 0 THEN   
            vr_obj_generico.put('numeroInscricEstadual', rw_crapepa.nrinsest);
          END IF;
          
          -- Data de Vigencia Procuraçao
          vr_obj_generico.put('dataVigenciaProcuracao' ,este0002.fn_data_ibra_motor(to_date('31/12/9999','dd/mm/rrrr')));
          
          -- Data de Admissao Procuraçao
          IF rw_crapepa.dtadmiss IS NOT NULL THEN 
            vr_obj_generico.put('dataAdmissaoProcuracao' ,este0002.fn_data_ibra_motor(rw_crapepa.dtadmiss));
          END IF;  
           
          -- Percentual Procuraçao
          IF rw_crapepa.persocio IS NOT NULL THEN 
            vr_obj_generico.put('valorPercentualProcuracao' ,Este0001.fn_Decimal_Ibra(rw_crapepa.persocio));
          END IF;
         
          -- Enviar informaçoes adicionais ao JSON Responsavel Leval
          vr_obj_particip.put('informacoesAdicionais' ,vr_obj_generico);    

          -- Adicionar o responsavel montado na lista de participaçoes
          vr_lst_generico.append(vr_obj_particip.to_json_value());          
          
        END IF;  
        
      END LOOP; --> fim crapepa
      
      -- Enviar novo objeto de participaçoes para dentro do objeto principal (Se houve encontro) 
      IF vr_flpartic = true THEN      
        vr_obj_analise.put('participacoesSocietarias' ,vr_lst_generico);
      END IF;
      
    END IF; --> INPESSOA 2   
    
    --> Busca dos procuradores:
    -- Inicializar lista de Representantes
    vr_lst_generico := json_list();

    -->Efetuar laço para retornar todos os registros disponíveis de Procuradores:
    FOR rw_crapavt IN cr_crapavt(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta 
                                ,pr_nrctrlim => pr_nrctrlim
                                ,pr_tpctrato => 8
                                ,pr_dsproftl => 'PROCURADOR') LOOP
      -- Setar flag para indicar que há sócio
      vr_flprocura := true;
      -- Se socio for associado
      IF rw_crapavt.nrdctato > 0 THEN 
        -- Passaremos a conta para montagem dos dados:
        pc_gera_json_pessoa_ass ( pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => rw_crapavt.nrdctato
                                 ,pr_dsjsonan => vr_obj_procurad
                                 ,pr_cdcritic => vr_cdcritic 
                                 ,pr_dscritic => vr_dscritic); 
        -- Testar possíveis erros na rotina:
        IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
          RAISE vr_exc_erro;
        END IF;  

        -- Adicionar o responsavel montato na lista de responsaveis
        vr_lst_generico.append(vr_obj_procurad.to_json_value());

      ELSE
        -- Enviaremos os dados básicos encontrados na tabela de procuradores
        este0002.pc_gera_json_pessoa_avt(pr_rw_crapavt => rw_crapavt
                                        ,pr_dsjsonavt  => vr_obj_procurad
                                        ,pr_cdcritic   => vr_cdcritic 
                                        ,pr_dscritic   => vr_dscritic);
        -- Testar possíveis erros na rotina:
        IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN 
          RAISE vr_exc_erro;
        END IF;        
        -- Adicionar o responsavel montato na lista de responsaveis
        vr_lst_generico.append(vr_obj_procurad.to_json_value());
      END IF;
    END LOOP;

    -- Enviar novo objeto de procuradores para dentro do objeto principal (Se houve encontro) 
    IF vr_flprocura = true THEN
      vr_obj_analise.put('procuradores' ,vr_lst_generico);    
    END IF;
    
    pr_dsjsonan := vr_obj_analise;
    
  EXCEPTION
    WHEN vr_exc_erro  THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN 
      IF SQLCODE < 0 THEN
        -- Caso ocorra exception gerar o código do erro com a linha do erro
        vr_dscritic:= vr_dscritic ||
                      dbms_utility.format_error_backtrace;
                       
      END IF;  

      -- Montar a mensagem final do erro 
      vr_dscritic:= 'Erro na montagem dos dados para análise automática da proposta (2): ' ||
                     vr_dscritic || ' -- SQLERRM: ' || SQLERRM;
                       
      -- Remover as ASPAS que quebram o texto
      vr_dscritic:= replace(vr_dscritic,'"', '');
      vr_dscritic:= replace(vr_dscritic,'''','');
      -- Remover as quebras de linha
      vr_dscritic:= replace(vr_dscritic,chr(10),'');
      vr_dscritic:= replace(vr_dscritic,chr(13),'');
      
      pr_cdcritic := 0;
      pr_dscritic := vr_dscritic;

  END pc_gera_json_analise_lim;

                                
  --> Rotina responsavel por gerar o objeto Json da proposta
  PROCEDURE pc_gera_json_proposta(pr_cdcooper in crawepr.cdcooper%type
                                 ,pr_cdagenci in crapage.cdagenci%type
                                 ,pr_cdoperad in crapope.cdoperad%type
                                 ,pr_nrdconta in crawepr.nrdconta%type
                                 ,pr_nrctrlim in crawlim.nrctrlim%type
                                 ,pr_tpctrlim in crawlim.tpctrlim%type
                                 ,pr_nmarquiv in varchar2               --> Diretorio e nome do arquivo pdf da proposta de emprestimo
                                 ---- OUT ----
                                 ,pr_proposta out json                   --> Retorno do clob em modelo json da proposta de emprestimo
                                 ,pr_cdcritic out number                 --> Codigo da critica
                                 ,pr_dscritic out varchar2               --> Descricao da critica
                                 ) is

  cursor cr_crapass is
  select ass.nrdconta
        ,ass.nmprimtl
        ,ass.cdagenci
        ,age.nmextage
        ,ass.inpessoa
        ,decode(ass.inpessoa,1,0,2,1) inpessoa_ibra
        ,ass.nrcpfcgc
        ,ass.dtmvtolt
  from   crapass ass
        ,crapage age
  where  ass.cdcooper = age.cdcooper
  and    ass.cdagenci = age.cdagenci
  and    ass.cdcooper = pr_cdcooper
  and    ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%rowtype;


  -->    Buscar dados da proposta de emprestimo
  cursor cr_crawlim is  
  select lim.nrctrlim
        ,lim.cdagenci
        ,lim.vllimite
        ,1 qtpreemp -- popd 
        ,lim.dtpropos dtvencto
        ,lim.vllimite vlpreemp
        ,lim.hrinclus
        ,ldc.cddlinha cdlcremp
        ,ldc.dsdlinha dslcremp
        ,/*ldc.*/1 tpctrato
        ,1 cdfinemp -- finalidadeCodigo: Codigo Finalidade da Proposta de Empréstimo
        ,'AQUISICAO DE TERRENO' dsfinemp -- finalidadeDescricao: Descricao Finalidade da Proposta de Empréstimo Paulo Penteado (GFT)teste pois parece que nao aceita nulo 
        ,lim.cdoperad
        ,ope.nmoperad
        ,0 instatus
        ,lim.dsnivris
        ,lim.insitapr
        ,upper(lim.cdopeapr) cdopeapr
        ,'0,0,0,0,0,0,0,0,0,0' dsliquid
        ,decode(lim.tpctrlim,1,'PP','TR') tpproduto
  from   crawlim lim
        ,crapldc ldc
        ,crapope ope
  where  ldc.cdcooper = lim.cdcooper
  and    ldc.cddlinha = lim.cddlinha
  and    ldc.tpdescto = lim.tpctrlim
  and    lim.cdcooper = ope.cdcooper
  and    upper(lim.cdoperad) = upper(ope.cdoperad)
  and    lim.cdcooper = pr_cdcooper
  and    lim.nrdconta = pr_nrdconta
  and    lim.nrctrlim = pr_nrctrlim
  and    lim.tpctrlim = pr_tpctrlim;
  rw_crawlim cr_crawlim%rowtype;

  -->    Selecionar os associados da cooperativa por CPF/CGC
  cursor cr_crapass_cpfcgc(pr_nrcpfcgc crapass.nrcpfcgc%type) is
  select cdcooper
        ,nrdconta
        ,flgcrdpa
  from   crapass
  where  cdcooper = pr_cdcooper
  and    nrcpfcgc = pr_nrcpfcgc -- CPF/CGC passado
  and    dtelimin is null;

  -->    Buscar valor de propostas pendentes
  cursor cr_crawepr_pend is
  select nvl(sum(w.vlemprst),0) vlemprst
  from   crawepr w
    join craplcr l on l.cdlcremp = w.cdlcremp and 
                      l.cdcooper = w.cdcooper
  where  w.cdcooper = pr_cdcooper
  and    w.nrdconta = pr_nrdconta
  and    w.insitapr in(1,3)        -- já estao aprovadas
  and    w.insitest <> 4           -- Expiradas
  --AND w.nrctremp <> pr_nrctremp -- desconsiderar a proposta que esta sendo enviada no momento
  and   not exists( select 1
                    from   crapepr p
                    where  w.cdcooper = p.cdcooper
                    and    w.nrdconta = p.nrdconta
                    and    w.nrctremp = p.nrctremp);
  rw_crawepr_pend cr_crawepr_pend%rowtype;

  -->    Selecionar o saldo disponivel do pre-aprovado da conta em questao  da carga ativa
  cursor cr_crapcpa is
  select cpa.vllimdis
        ,cpa.vlcalpre
        ,cpa.vlctrpre
  from   crapcpa              cpa
        ,tbepr_carga_pre_aprv carga
  where  carga.cdcooper = pr_cdcooper
  and    carga.indsituacao_carga = 1
  and    carga.flgcarga_bloqueada = 0
  and    cpa.cdcooper = carga.cdcooper
  and    cpa.iddcarga = carga.idcarga
  and    cpa.nrdconta = pr_nrdconta;
  rw_crapcpa cr_crapcpa%rowtype;

  -->    Buscar operador
  cursor cr_crapope is
  select ope.nmoperad
        ,ope.cdoperad
  from   crapope ope
  where  ope.cdcooper        = pr_cdcooper
  and    upper(ope.cdoperad) = upper(pr_cdoperad);
  rw_crapope cr_crapope%rowtype;

  -->    Buscar se a conta é de Colaborador Cecred
  cursor cr_tbcolab is
  select substr(lpad(col.cddcargo_vetor,7,'0'),5,3) cddcargo
  from   tbcadast_colaborador col
  where  col.cdcooper = pr_cdcooper
  and    col.nrcpfcgc = rw_crapass.nrcpfcgc
  and    col.flgativo = 'A';
  
  vr_flgcolab boolean;
  vr_cddcargo tbcadast_colaborador.cdcooper%type;

  -->    Calculo do faturamento PJ
  cursor cr_crapjfn is
  select vlrftbru##1+vlrftbru##2+vlrftbru##3+vlrftbru##4+vlrftbru##5+vlrftbru##6
        +vlrftbru##7+vlrftbru##8+vlrftbru##9+vlrftbru##10+vlrftbru##11+vlrftbru##12 vltotfat
  from   crapjfn
  where  cdcooper = pr_cdcooper
  and    nrdconta = pr_nrdconta;
  rw_crapjfn cr_crapjfn%rowtype;

  -----------> VARIAVEIS <-----------
  -- Tratamento de erros
  vr_cdcritic number;
  vr_dscritic varchar2(500);
  vr_exc_erro exception;

  --Tipo de registro do tipo data
  rw_crapdat btch0001.cr_crapdat%rowtype;

  -- Objeto json da proposta
  vr_obj_proposta json := json();
  vr_obj_agencia  json := json();
  vr_obj_imagem   json := json();
  vr_lst_doctos   json_list := json_list();
  vr_json_valor   json_value;

  -- Variaveis auxiliares
  vr_data_aux     date := null;
  vr_dstpgara     craptab.dstextab%type;
  vr_dstextab     craptab.dstextab%type;
  vr_inusatab     boolean;
  vr_vlutiliz     number;
  vr_vlprapne     number;
  vr_vllimdis     number;
  vr_nmarquiv     varchar2(1000);
  vr_dsiduser     varchar2(100);
  vr_dsprotoc  tbepr_acionamento.dsprotocolo%type;
  vr_dsdirarq  varchar2(1000);
  vr_dscomando varchar2(1000);

  BEGIN

     --    Verificar se a data existe
     open  btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
     fetch btch0001.cr_crapdat into rw_crapdat;
     if    btch0001.cr_crapdat%notfound then
           vr_cdcritic:= 1;
           close btch0001.cr_crapdat;
           raise vr_exc_erro;
     end   if;
     close btch0001.cr_crapdat;

     -->   Buscar dados do associado
     open  cr_crapass;
     fetch cr_crapass into rw_crapass;
     if    cr_crapass%notfound then
           close cr_crapass;
           vr_cdcritic := 9;
           raise vr_exc_erro;
     end   if;
     close cr_crapass;

     --> Buscar dados da proposta de emprestimo
     open  cr_crawlim;
     fetch cr_crawlim into rw_crawlim;
     if    cr_crawlim%notfound then
           close cr_crawlim;
           vr_cdcritic := 535; -- 535 - Proposta nao encontrada.
           raise vr_exc_erro;
     end   if;
     close cr_crawlim;

     --> Criar objeto json para agencia da proposta
     vr_obj_agencia.put('cooperativaCodigo', pr_cdcooper);
     vr_obj_agencia.put('PACodigo', pr_cdagenci);
     vr_obj_proposta.put('PA' ,vr_obj_agencia);
     vr_obj_agencia := json();

     --> Criar objeto json para agencia do cooperado
     vr_obj_agencia.put('cooperativaCodigo', pr_cdcooper);
     vr_obj_agencia.put('PACodigo', rw_crapass.cdagenci);
     vr_obj_proposta.put('cooperadoContaPA' ,vr_obj_agencia);

     -- Nr. conta sem o digito
     vr_obj_proposta.put('cooperadoContaNum',to_number(substr(rw_crapass.nrdconta,1,length(rw_crapass.nrdconta)-1)));
     -- Somente o digito
     vr_obj_proposta.put('cooperadoContaDv' ,to_number(substr(rw_crapass.nrdconta,-1)));

     vr_obj_proposta.put('cooperadoNome'    , rw_crapass.nmprimtl);

     vr_obj_proposta.put('cooperadoTipoPessoa', rw_crapass.inpessoa_ibra);
     if  rw_crapass.inpessoa = 1 then
         vr_obj_proposta.put('cooperadoDocumento' , lpad(rw_crapass.nrcpfcgc,11,'0'));
     else
         vr_obj_proposta.put('cooperadoDocumento' , lpad(rw_crapass.nrcpfcgc,14,'0'));
     end if;
    
     vr_obj_proposta.put('numero'             , rw_crawlim.nrctrlim);
     vr_obj_proposta.put('valor'              , rw_crawlim.vllimite);
     vr_obj_proposta.put('parcelaQuantidade'  , rw_crawlim.qtpreemp);
     vr_obj_proposta.put('parcelaPrimeiroVencimento', este0001.fn_data_ibra(rw_crawlim.dtvencto));
     vr_obj_proposta.put('parcelaValor'       , rw_crawlim.vlpreemp);

     --> Data e hora da inclusao da proposta
     vr_data_aux := to_date(to_char(rw_crapass.dtmvtolt,'DD/MM/RRRR') ||' '||
                            to_char(to_date(rw_crawlim.hrinclus,'SSSSS'),'HH24:MI:SS'),
                           'DD/MM/RRRR HH24:MI:SS');
     vr_obj_proposta.put('dataHora'           , este0001.fn_datatempo_ibra(vr_data_aux));

     vr_obj_proposta.put('produtoCreditoSegmentoCodigo' ,3); 
     vr_obj_proposta.put('produtoCreditoSegmentoDescricao' ,'Limite Desct Titulo');   

     vr_obj_proposta.put('linhaCreditoCodigo'    ,rw_crawlim.cdlcremp);
     vr_obj_proposta.put('linhaCreditoDescricao' ,rw_crawlim.dslcremp);
     vr_obj_proposta.put('finalidadeCodigo'      ,rw_crawlim.cdfinemp);       
     vr_obj_proposta.put('finalidadeDescricao'   ,rw_crawlim.dsfinemp);      

     vr_obj_proposta.put('tipoProduto'           ,rw_crawlim.tpproduto);
     vr_obj_proposta.put('tipoGarantiaCodigo'    ,rw_crawlim.tpctrato );

     --> Buscar desciçao do tipo de garantia
     vr_dstpgara  := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'CTRATOEMPR'
                                               ,pr_tpregist => rw_crawlim.tpctrato);
     vr_obj_proposta.put('tipoGarantiaDescricao'    ,trim(vr_dstpgara) );

     --    Buscar dados do operador
     open  cr_crapope;
     fetch cr_crapope into rw_crapope;
     if    cr_crapope%notfound then
           close cr_crapope;
           vr_cdcritic := 67; -- 067 - Operador nao cadastrado.
           raise vr_exc_erro;
     end   if;
     close cr_crapope;

     vr_obj_proposta.put('loginOperador'         ,lower(rw_crapope.cdoperad));
     vr_obj_proposta.put('nomeOperador'          ,rw_crapope.nmoperad );

     --  Vazio se for CDC
     --IF  rw_crawepr.inlcrcdc = 0 THEN
     --    /* Se estiver zerado é pq nao houve Parecer de Credito - ou seja - oriundo do Motor de Crédito */
     --    IF  NVL(rw_crawlim.instatus, 0) = 0 THEN
     --        /* Se reprovado no Motor */
     --        IF  rw_crawepr.cdopeapr = 'MOTOR' AND rw_crawepr.insitapr = 2 THEN
     --            /*Fixo 3-Nao Conceder*/
     --            rw_crawepr.instatus := 3;
     --        ELSE
     --            /*Fixo 2-Analise Manual*/
     --            rw_crawepr.instatus := 2;
     --        END IF;
     --    END IF;
     --    /*1-pre-aprovado, 2-analise manual, 3-nao conceder */
     --    vr_obj_proposta.put('parecerPreAnalise', rw_crawepr.instatus);
     --ELSE
     --    /* Zerado para CDC */
         vr_obj_proposta.put('parecerPreAnalise', 0);
     --END IF;


     --if  rw_crawlim.inlcrcdc = 0 then
         -- Verificar se usa tabela juros
         vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                  ,pr_nmsistem => 'CRED'
                                                  ,pr_tptabela => 'USUARI'
                                                  ,pr_cdempres => 11
                                                  ,pr_cdacesso => 'TAXATABELA'
                                                  ,pr_tpregist => 0);
         -- Se a primeira posiçao do campo dstextab for diferente de zero
         vr_inusatab := substr(vr_dstextab,1,1) != '0';

         -- Busca endividamento do cooperado
         rati0001.pc_calcula_endividamento(pr_cdcooper   => pr_cdcooper     --> Código da Cooperativa
                                          ,pr_cdagenci   => pr_cdagenci     --> Código da agencia
                                          ,pr_nrdcaixa   => 0               --> Número do caixa
                                          ,pr_cdoperad   => pr_cdoperad     --> Código do operador
                                          ,pr_rw_crapdat => rw_crapdat      --> Vetor com dados de parâmetro (CRAPDAT)
                                          ,pr_nrdconta   => pr_nrdconta     --> Conta do associado
                                          ,pr_dsliquid   => rw_crawlim.dsliquid --> Lista de contratos a liquidar
                                          ,pr_idseqttl   => 1               --> Sequencia de titularidade da conta
                                          ,pr_idorigem   => 1 /*AYLLOS*/    --> Indicador da origem da chamada
                                          ,pr_inusatab   => vr_inusatab     --> Indicador de utilizaçao da tabela de juros
                                          ,pr_tpdecons   => 3               --> Tipo da consulta 3 - Considerar a data atual
                                          ,pr_vlutiliz   => vr_vlutiliz     --> Valor da dívida
                                          ,pr_cdcritic   => vr_cdcritic     --> Critica encontrada no processo
                                          ,pr_dscritic   => vr_dscritic);   --> Saída de erro
         --  Se houve erro
         if  nvl(vr_cdcritic,0) > 0 or trim(vr_dscritic) is not null then
             raise vr_exc_erro;
         end if;

         vr_vllimdis := 0.0;
         vr_vlprapne := 0.0;
         for rw_crapass_cpfcgc in cr_crapass_cpfcgc(pr_nrcpfcgc => rw_crapass.nrcpfcgc) 
         loop
             rw_crawepr_pend := null;
             open  cr_crawepr_pend;
             fetch cr_crawepr_pend into rw_crawepr_pend;
             close cr_crawepr_pend;

             vr_vlprapne := nvl(rw_crawepr_pend.vlemprst, 0) + vr_vlprapne;

             --> Selecionar o saldo disponivel do pre-aprovado da conta em questao  da carga ativa
             if  rw_crapass_cpfcgc.flgcrdpa = 1 then
                 rw_crapcpa := null;
                 open  cr_crapcpa;
                 fetch cr_crapcpa into rw_crapcpa;
                 close cr_crapcpa;
                 vr_vllimdis := nvl(rw_crapcpa.vllimdis, 0) + vr_vllimdis;
             end if;
         end loop;

         vr_obj_proposta.put('endividamentoContaValor'     ,vr_vlutiliz);
         vr_obj_proposta.put('propostasPendentesValor'     ,vr_vlprapne );
         vr_obj_proposta.put('limiteCooperadoValor'        ,nvl(vr_vllimdis,0) );

         -- Busca PDF gerado pela análise automática do Motor
         vr_dsprotoc := este0001.fn_protocolo_analise_auto(pr_cdcooper => pr_cdcooper
                                                          ,pr_nrdconta => pr_nrdconta
                                                          ,pr_nrctremp => pr_nrctrlim);

         vr_obj_proposta.put('protocoloPolitica'          ,vr_dsprotoc);

         -- Copiar parâmetro
         vr_nmarquiv := pr_nmarquiv;

         --  Caso nao tenhamos recebido o PDF
         if  vr_nmarquiv is null then
             -- Gerar ID aleatório
             vr_dsiduser := dbms_random.string('A', 27);

             dsct0002.pc_gera_impressao_limite(pr_cdcooper => pr_cdcooper
                                              ,pr_cdagecxa => pr_cdagenci
                                              ,pr_nrdcaixa => 0
                                              ,pr_cdopecxa => pr_cdoperad
                                              ,pr_nmdatela => 'ATENDA'
                                              ,pr_idorigem => 1 --Ayllos
                                              ,pr_tpctrlim => pr_tpctrlim
                                              ,pr_nrdconta => rw_crapass.nrdconta
                                              ,pr_idseqttl => 1
                                              ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                              ,pr_dtmvtopr => rw_crapdat.dtmvtopr
                                              ,pr_inproces => rw_crapdat.inproces
                                              ,pr_idimpres => 2 --Gerar impressao do contrato do limite de desconto de titulo
                                              ,pr_nrctrlim => pr_nrctrlim
                                              ,pr_dsiduser => vr_dsiduser
                                              ,pr_flgemail => 0
                                              ,pr_flgerlog => 0
                                              ,pr_nmarqpdf => vr_nmarquiv
                                              ,pr_cdcritic => vr_cdcritic
                                              ,pr_dscritic => vr_dscritic );

             if  trim(vr_dscritic) is not null then
                 raise vr_exc_erro;
             end if;

             vr_dsdirarq := gene0001.fn_diretorio(pr_tpdireto => 'C' --> cooper
                                                 ,pr_cdcooper => pr_cdcooper
                                                 ,pr_nmsubdir => '/rl');
             
             --  Se o arquivo nao existir, Remover o conteudo do nome do arquivo para nao enviar
             if  not gene0001.fn_exis_arquivo(vr_dsdirarq || '/' || vr_nmarquiv) then
                 vr_nmarquiv := null;
             end if;
         end if;

         if  vr_nmarquiv is not null then
             -- Converter arquivo PDF para clob em base64 para enviar via json
             este0001.pc_arq_para_clob_base64(pr_nmarquiv       => vr_dsdirarq || '/' || vr_nmarquiv
                                             ,pr_json_value_arq => vr_json_valor
                                             ,pr_dscritic       => vr_dscritic);
             if  trim(vr_dscritic) is not null then
                 raise vr_exc_erro;
             end if;
     
             -- Gerar objeto json para a imagem
             vr_obj_imagem.put('codigo'      , 'PROPOSTA_PDF');
             vr_obj_imagem.put('conteudo'    ,vr_json_valor);
             vr_obj_imagem.put('emissaoData' , este0001.fn_data_ibra(sysdate));
             vr_obj_imagem.put('validadeData', '');
             -- incluir objeto imagem na proposta
             vr_lst_doctos.append(vr_obj_imagem.to_json_value());

             --  Caso o PDF tenha sido gerado nesta rotina, Temos de apagá-lo... Em outros casos o PDF é apagado na rotina chamadora
             if  vr_nmarquiv <> nvl(pr_nmarquiv,' ') then
                 gene0001.pc_oscommand_shell(pr_des_comando => 'rm '||vr_nmarquiv);
             end if;
         end if;

         --  Se encontrou PDF de análise Motor
         if  vr_dsprotoc is not null then
             -- Diretorio para salvar
             vr_dsdirarq := gene0001.fn_diretorio(pr_tpdireto => 'C' --> usr/coop
                                                 ,pr_cdcooper => 3
                                                 ,pr_nmsubdir => '/log/webservices');

             -- Utilizar o protocolo para nome do arquivo
             vr_nmarquiv := vr_dsprotoc || '.pdf';

             -- Comando para download
             vr_dscomando := gene0001.fn_param_sistema('CRED',3,'SCRIPT_DOWNLOAD_PDF_ANL');

             -- Substituir o caminho do arquivo a ser baixado
             vr_dscomando := replace(vr_dscomando, '[local-name]', vr_dsdirarq || '/' || vr_nmarquiv);

             -- Substiruir a URL para Download
             vr_dscomando := replace(vr_dscomando, '[remote-name]', gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                                                             ,pr_cdacesso => 'HOST_WEBSRV_MOTOR_IBRA')||
                                                                    gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                                                             ,pr_cdacesso => 'URI_WEBSRV_MOTOR_IBRA')||
                                                                    '_result/' || vr_dsprotoc || '/pdf');

             -- Executar comando para Download
             gene0001.pc_oscommand(pr_typ_comando => 'S'
                                  ,pr_des_comando => vr_dscomando);


             -- Se NAO encontrou o arquivo
             if  not gene0001.fn_exis_arquivo(pr_caminho => vr_dsdirarq || '/' || vr_nmarquiv) then
                 vr_dscritic := 'Problema na recepcao do Arquivo - Tente novamente mais tarde!';
                 raise vr_exc_erro;
             end if;

             -- Converter arquivo PDF para clob em base64 para enviar via json
             este0001.pc_arq_para_clob_base64(pr_nmarquiv       => vr_dsdirarq || '/' || vr_nmarquiv
                                             ,pr_json_value_arq => vr_json_valor
                                             ,pr_dscritic       => vr_dscritic);
             if  trim(vr_dscritic) is not null then
                 raise vr_exc_erro;
             end if;

             -- Gerar objeto json para a imagem
             vr_obj_imagem.put('codigo'      ,'RESULTADO_POLITICA');
             vr_obj_imagem.put('conteudo'    ,vr_json_valor);
             vr_obj_imagem.put('emissaoData' ,este0001.fn_data_ibra(sysdate));
             vr_obj_imagem.put('validadeData','');

             -- incluir objeto imagem na proposta
             vr_lst_doctos.append(vr_obj_imagem.to_json_value());

             -- Temos de apagá-lo... Em outros casos o PDF é apagado na rotina chamadora
             gene0001.pc_oscommand_shell(pr_des_comando => 'rm ' || vr_dsdirarq || '/' || vr_nmarquiv);
         end if;

         -- Incluiremos os documentos ao json principal
         vr_obj_proposta.put('documentos',vr_lst_doctos);

     --else -- caso for CDC, enviar vazio
     --    vr_obj_proposta.put('endividamentoContaValor'     ,'');
     --    vr_obj_proposta.put('propostasPendentesValor'     ,'');
     --    vr_obj_proposta.put('endividamentoContaValor'     ,'');
     --end if;

     vr_obj_proposta.put('contratoNumero'     ,rw_crawlim.nrctrlim);

     -- Verificar se a conta é de colaborador do sistema Cecred
     vr_cddcargo := null;
     open  cr_tbcolab;
     fetch cr_tbcolab into vr_cddcargo;
     if    cr_tbcolab%found then
           vr_flgcolab := true;
     else
           vr_flgcolab := false;
     end   if;
     close cr_tbcolab;

     -- Enviar tag indicando se é colaborador
     vr_obj_proposta.put('cooperadoColaborador',vr_flgcolab); 

     --  Enviar o cargo somente se colaborador
     if  vr_flgcolab then
         vr_obj_proposta.put('codigoCargo',vr_cddcargo);
     end if;

     -- Enviar nivel de risco no momento da criacao
     vr_obj_proposta.put('classificacaoRisco',rw_crawlim.dsnivris);

     -- Enviar flag se a proposta é de renogociaçao
     vr_obj_proposta.put('renegociacao',(rw_crawlim.dsliquid != '0,0,0,0,0,0,0,0,0,0'));

     --  BUscar faturamento se pessoa Juridica
     if  rw_crapass.inpessoa = 2 then
      -- Buscar faturamento
         open  cr_crapjfn;
         fetch cr_crapjfn into rw_crapjfn;
         close cr_crapjfn;
         vr_obj_proposta.put('faturamentoAnual',rw_crapjfn.vltotfat);
     end if;

     -- Devolver o objeto criado
     pr_proposta := vr_obj_proposta;

  EXCEPTION
     when vr_exc_erro then
          if  nvl(vr_cdcritic,0) > 0 and trim(vr_dscritic) is null then
              vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          end if;

          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;

     when others then
          pr_cdcritic := 0;
          pr_dscritic := 'Nao foi possivel montar objeto proposta: '||sqlerrm;

END pc_gera_json_proposta;
  
END ESTE0004;
/
