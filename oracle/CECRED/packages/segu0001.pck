CREATE OR REPLACE PACKAGE CECRED."SEGU0001" AS

/*..............................................................................

    Programa: CONV0001 (Antigo b1wgen0045.p)
    Autor   : Guilherme - Precise
    Data    : Outubro/2009                       Ultima Atualizacao: 20/06/2016

    Dados referentes ao programa:

    Objetivo  : BO para unificacao de funcoes com o CRPS524.
                Programas com funcoes em comum com CRPS524:
                    - CCARBB
                    - CRPS138 relat 115 - Qntde Cooperados
                    - RELINS relat 470 - Beneficios INSS
                    - CRPS483 relat 450 - Inf. de Convenios
                    - RELSEG Op "R" 4 - Inf. de Seguros

    Alteracoes: 18/03/2010 - Incluido novo campo para guardar o numero de
                             cooperados com debito automatico, que tiveram
                             debitos no mes (Elton).

                14/05/2010 - Incluido novo parametro na procedure
                             valor-convenios com a quantidade de cooperados que
                             tiveram pelo menos um debito automatico no mes,
                             independente do convenio. (Elton).

                04/06/2010 - Incluido tratamento para tarifa TAA (Elton).

                15/03/2011 - Inclusao dos parametros ret_vlcancel e ret_qtcancel
                             na procedure limite-cartao-credito (Vitor)

                20/03/2012 - Alterado o parametro aux_qtassdeb para a table
                             crawass na procedure valor-convenios (Adriano).

                25/04/2012 - Incluido novo parametro na procedure
                             limite-cartao-credito. (David Kruger).

                22/06/2012 - Substituido gncoper por crapcop (Tiago).

                05/09/2012 - Alteracao na leitura da situacao de cartoes de
                             Creditos (David Kruger).

                22/02/2013 - Incluido novas procedures para utilizacao da tela
                             RELSEG no AYLLOS e WEB (David Kruger).

                21/06/2013 - Contabilizando crawcrd.insitcrd = 7 como "em uso"
                             (Tiago).
                             
                12/08/2015 - Projeto Reformulacao cadastral
                             Eliminado o campo nmdsecao (Tiago Castro - RKAM).

                20/06/2016 - Correcao para o uso correto do indice da CRAPTAB em procedures 
                             desta package.(Carlos Rafael Tanholi).   
..............................................................................*/
    
  --  Tipo de registro para PlTable de seguros
  TYPE typ_reg_seguro IS
    RECORD( inpessoa PLS_INTEGER
            ,tpseguro crapseg.tpseguro%TYPE
            ,cdagenci craplcm.cdagenci%TYPE
            ,cdsitseg crapseg.cdsitseg%TYPE
            ,dtcancel crapseg.dtcancel%TYPE
            ,qtsegvid crapgpr.qtsegvid%TYPE
            ,vllanmto crapseg.vlpremio%TYPE );

  -- Tipo de tabela para PlTable de seguros
  TYPE typ_tab_seguro IS
    TABLE OF typ_reg_seguro
    INDEX BY varchar2(15); --(2) tpseguro || (3) cdagenci || (10) nrdconta                             
    
  -- Tipo de registro para PlTble de informacao de seguros
  TYPE typ_reg_info_seguros IS
    RECORD ( tpseguro crapseg.tpseguro%type
            ,cdagenci craplcm.cdagenci%type
            ,dtrefere DATE
            ,inpessoa PLS_INTEGER
            ,qtsegaut PLS_INTEGER
            ,qtincvid PLS_INTEGER
            ,qtexcvid PLS_INTEGER
            ,qtincres PLS_INTEGER
            ,qtexcres PLS_INTEGER
            ,qtsegvid PLS_INTEGER
            ,qtsegres PLS_INTEGER
            ,vlsegvid NUMBER(25,2)
            ,vlrecvid NUMBER(25,2)
            ,vlrepvid NUMBER(25,2)
            ,vlsegres NUMBER(25,2)
            ,vlrecres NUMBER(25,2)
            ,vlrepres NUMBER(25,2)
            ,vlsegaut NUMBER(25,2)
            ,vlrecaut NUMBER(25,2)
            ,vlrepaut NUMBER(25,2) );
            
  -- Tipo de tabela para PlTable de informacao de seguros
  TYPE typ_tab_info_seguros IS
    TABLE OF typ_reg_info_seguros
    INDEX BY varchar2(14); -- (2) tpseguro || (3) cdagenci || (1) inpessoa || (8) dtrefere                                                 
    
  -- Tipo de tabela para grau
  TYPE typ_tab_dsgraupr IS VARRAY(5) OF VARCHAR2(20);
    
  -- Tipo de tabela para beneficiario vida
  TYPE typ_tab_nmbenvid IS VARRAY(5) OF VARCHAR2(40);
    
  -- Tipo de tabela para taxa participacao
  TYPE typ_tab_txpartic IS VARRAY(5) OF NUMBER;

  -- Tabela de memoria para informacao de seguros
  vr_tab_info_seguros typ_tab_info_seguros;
  
  -- Tabela de memoria para seguros
  vr_tab_seguro typ_tab_seguro;
  
  -- Tipo de Registro Motivo Cancelamento
  TYPE typ_reg_mot_can IS RECORD /* b1wgen0033tt.i tt-mot-can */
    (cdmotcan INTEGER
    ,dsmotcan VARCHAR2(100));
    
  --Tipo de Tabela Motivo Cancelamento
  TYPE typ_tab_mot_can IS TABLE OF typ_reg_mot_can INDEX BY PLS_INTEGER;
    
  -- Tipo de Registro de Associado
  TYPE typ_reg_associado IS RECORD /* b1wgen0033tt.i tt-associado */
    (nrmatric	crapass.nrmatric%type
    ,indnivel	crapass.indnivel%type
    ,nrdconta	crapass.nrdconta%type
    ,cdagenci	crapass.cdagenci%type
    ,nrcadast	crapass.nrcadast%type
    ,nmprimtl	crapass.nmprimtl%type
    ,dtnasctl	crapass.dtnasctl%type
    ,dsnacion	crapass.dsnacion%type
    ,dsproftl	crapass.dsproftl%type
    ,dtadmiss	crapass.dtadmiss%type
    ,dtdemiss	crapass.dtdemiss%TYPE
    ,nrcpfcgc	crapass.nrcpfcgc%type
    ,dtultalt	crapass.dtultalt%type
    ,tpdocptl	crapass.tpdocptl%type
    ,nrdocptl	crapass.nrdocptl%type
    ,cdsexotl	crapass.cdsexotl%type
    ,dsfiliac	crapass.dsfiliac%type
    ,dtadmemp	crapass.dtadmemp%type
    ,cdturnos	crapass.cdturnos%type
    ,nrramemp	crapass.nrramemp%type
    ,nrctacto	crapass.nrctacto%type
    ,cdtipsfx	crapass.cdtipsfx%type
    ,cddsenha	crapass.cddsenha%type
    ,cdsecext	crapass.cdsecext%type
    ,cdsitdct	crapass.cdsitdct%type
    ,cdsitdtl	crapass.cdsitdtl%type
    ,cdsrcheq	crapass.cdsrcheq%type
    ,cdtipcta	crapass.cdtipcta%type
    ,dtabtcct	crapass.dtabtcct%type
    ,dtasitct	crapass.dtasitct%type
    ,dtatipct	crapass.dtatipct%type
    ,dtcnsspc	crapass.dtcnsspc%type
    ,dtdsdspc	crapass.dtdsdspc%type
    ,inadimpl	crapass.inadimpl%type
    ,inedvmto	crapass.inedvmto%type
    ,inlbacen	crapass.inlbacen%type
    ,nrflcheq	crapass.nrflcheq%type
    ,qtextmes	crapass.qtextmes%type
    ,vllimcre	crapass.vllimcre%type
    ,dsregcas	crapass.dsregcas%TYPE
    ,nmsegntl	crapass.nmsegntl%type
    ,tpdocstl	crapass.tpdocstl%type
    ,nrdocstl	crapass.nrdocstl%type
    ,cdgraupr	crapass.cdgraupr%type
    ,cddsecao	crapass.cddsecao%type
    ,dtultlcr	crapass.dtultlcr%type
    ,inpessoa	crapass.inpessoa%type
    ,inmatric	crapass.inmatric%type
    ,inisipmf	crapass.inisipmf%type
    ,tplimcre	crapass.tplimcre%type
    ,dtnasstl	crapass.dtnasstl%type
    ,dsfilstl	crapass.dsfilstl%type
    ,nrcpfstl	crapass.nrcpfstl%type
    ,dtelimin	crapass.dtelimin%type
    ,vledvmto	crapass.vledvmto%type
    ,dtedvmto	crapass.dtedvmto%type
    ,qtfolmes	crapass.qtfolmes%type
    ,tpextcta	crapass.tpextcta%type
    ,cdoedptl	crapass.cdoedptl%type
    ,cdoedstl	crapass.cdoedstl%type
    ,cdoedrsp	crapass.cdoedrsp%type
    ,cdufdptl	crapass.cdufdptl%type
    ,cdufdstl	crapass.cdufdstl%type
    ,cdufdrsp	crapass.cdufdrsp%type
    ,nmrespon	crapass.nmrespon%type
    ,inhabmen	crapass.inhabmen%type
    ,nrcpfrsp	crapass.nrcpfrsp%type
    ,nrdocrsp	crapass.nrdocrsp%type
    ,tpdocrsp	crapass.tpdocrsp%type
    ,dtemdstl	crapass.dtemdstl%type
    ,dtemdptl	crapass.dtemdptl%type
    ,dtemdrsp	crapass.dtemdrsp%type
    ,qtdepend	crapass.qtdepend%type
    ,dsendcol	crapass.dsendcol%TYPE
    ,tpavsdeb	crapass.tpavsdeb%type
    ,iniscpmf	crapass.iniscpmf%type
    ,nrctaprp	crapass.nrctaprp%type
    ,cdoedttl	crapass.cdoedttl%type
    ,cdufdttl	crapass.cdufdttl%type
    ,dsfilttl	crapass.dsfilttl%type
    ,dtnasttl	crapass.dtnasttl%type
    ,nmtertl	crapass.nmtertl%type
    ,nrcpfttl	crapass.nrcpfttl%type
    ,nrdocttl	crapass.nrdocttl%type
    ,tpdocttl	crapass.tpdocttl%type
    ,dtemdttl	crapass.dtemdttl%type
    ,tpvincul	crapass.tpvincul%type
    ,nrfonemp	crapass.nrfonemp%type
    ,dtcnscpf	crapass.dtcnscpf%type
    ,cdsitcpf	crapass.cdsitcpf%type
    ,nmpaittl	crapass.nmpaittl%type
    ,nmpaistl	crapass.nmpaistl%type
    ,nmpaiptl	crapass.nmpaiptl%type
    ,nmmaettl	crapass.nmmaettl%type
    ,nmmaestl	crapass.nmmaestl%type
    ,nmmaeptl	crapass.nmmaeptl%type
    ,inccfcop	crapass.inccfcop%type
    ,dtccfcop	crapass.dtccfcop%type
    ,indrisco	crapass.indrisco%TYPE
    ,inarqcbr	crapass.inarqcbr%TYPE
    ,dsdemail	crapass.dsdemail%type
    ,qtfoltal	crapass.qtfoltal%type
    ,nrdctitg	crapass.nrdctitg%type
    ,flchqitg	crapass.flchqitg%type
    ,flgctitg	crapass.flgctitg%type
    ,dtabcitg	crapass.dtabcitg%type
    ,nrctainv	crapass.nrctainv%TYPE
    ,cdoperat	crapass.cdoperat%type
    ,flgatrat	crapass.flgatrat%type
    ,dtaturat	crapass.dtaturat%type
    ,vlutlrat	crapass.vlutlrat%type
    ,flgiddep	crapass.flgiddep%type
    ,dtlimdeb	crapass.dtlimdeb%type
    ,cdcooper	crapass.cdcooper%type
    ,vllimdeb	crapass.vllimdeb%type
    ,cdmotdem	crapass.cdmotdem%type
    ,flgdbitg	crapass.flgdbitg%type
    ,dsnivris	crapass.dsnivris%type
    ,dtectitg	crapass.dtectitg%type
    ,cdopedem	crapass.cdopedem%type
    ,dtmvtolt	crapass.dtmvtolt%type
    ,cdbantrf	crapass.cdbantrf%type
    ,cdagetrf	crapass.cdagetrf%type
    ,nrctatrf	crapass.nrctatrf%type
    ,dtmvcitg	crapass.dtmvcitg%type
    ,dtcnsscr	crapass.dtcnsscr%type
    ,nrcpfppt	crapass.nrcpfppt%type
    ,dtdevqst	crapass.dtdevqst%type
    ,dtentqst	crapass.dtentqst%type
    ,cdbcochq	crapass.cdbcochq%type
    ,dtcadqst	crapass.dtcadqst%type
    ,nrnotatl	crapass.nrnotatl%type
    ,inrisctl	crapass.inrisctl%type
    ,dtrisctl	crapass.dtrisctl%type
    ,flgrestr	crapass.flgrestr%type
    ,nrctacns	crapass.nrctacns%type
    ,progress_recid	crapass.progress_recid%type
    ,nrempcrd	crapass.nrempcrd%type
    ,inserasa	crapass.inserasa%type
    ,flgcrdpa	crapass.flgcrdpa%type
    ,cdoplcpa	crapass.cdoplcpa%type
    ,incadpos	crapass.incadpos%type
    ,flgrenli	crapass.flgrenli%type
    ,nrfonres VARCHAR2(100));
  
  --Tipo de Tabela de Associado  
  TYPE typ_tab_associado IS TABLE OF typ_reg_associado INDEX BY PLS_INTEGER;
    
  -- Tipo de Registro Seguros
  TYPE typ_reg_seguros IS RECORD /* b1wgen0033tt.i tt-seguros */
    (nrdconta crapseg.nrdconta%type
    ,nrctrseg crapseg.nrctrseg%type
    ,dtinivig crapseg.dtinivig%type
    ,dtfimvig crapseg.dtfimvig%type
    ,dtmvtolt crapseg.dtmvtolt%type
    ,cdagenci crapseg.cdagenci%type
    ,cdbccxlt crapseg.cdbccxlt%type
    ,cdsitseg crapseg.cdsitseg%type
    ,dtaltseg crapseg.dtaltseg%type
    ,dtcancel crapseg.dtcancel%type
    ,dtdebito crapseg.dtdebito%type
    ,dtiniseg crapseg.dtiniseg%type
    ,indebito crapseg.indebito%type
    ,nrdolote crapseg.nrdolote%type
    ,nrseqdig crapseg.nrseqdig%type
    ,qtprepag crapseg.qtprepag%type
    ,vlprepag crapseg.vlprepag%type
    ,vlpreseg crapseg.vlpreseg%type
    ,dtultpag crapseg.dtultpag%type
    ,tpseguro crapseg.tpseguro%type
    ,tpplaseg crapseg.tpplaseg%type
    ,qtprevig crapseg.qtprevig%type
    ,cdsegura crapseg.cdsegura%type
    ,lsctrant crapseg.lsctrant%type
    ,nrctratu crapseg.nrctratu%type
    ,flgunica crapseg.flgunica%type
    ,dtprideb crapseg.dtprideb%type
    ,vldifseg crapseg.vldifseg%type
    ,nmbenvid##1 crapseg.nmbenvid##1%type
    ,nmbenvid##2 crapseg.nmbenvid##2%type
    ,nmbenvid##3 crapseg.nmbenvid##3%type
    ,nmbenvid##4 crapseg.nmbenvid##4%type
    ,nmbenvid##5 crapseg.nmbenvid##5%type
    ,dsgraupr##1 crapseg.dsgraupr##1%type
    ,dsgraupr##2 crapseg.dsgraupr##2%type
    ,dsgraupr##3 crapseg.dsgraupr##3%type
    ,dsgraupr##4 crapseg.dsgraupr##4%type
    ,dsgraupr##5 crapseg.dsgraupr##5%type
    ,txpartic##1 crapseg.txpartic##1%type
    ,txpartic##2 crapseg.txpartic##2%type
    ,txpartic##3 crapseg.txpartic##3%type
    ,txpartic##4 crapseg.txpartic##4%type
    ,txpartic##5 crapseg.txpartic##5%type
    ,dtultalt crapseg.dtultalt%type
    ,cdoperad crapseg.cdoperad%type
    ,vlpremio crapseg.vlpremio%type
    ,qtparcel crapseg.qtparcel%type
    ,tpdpagto crapseg.tpdpagto%type
    ,cdcooper crapseg.cdcooper%type
    ,flgconve crapseg.flgconve%type
    ,flgclabe crapseg.flgclabe%type
    ,cdmotcan crapseg.cdmotcan%type
    ,tpendcor crapseg.tpendcor%type
    ,cdopecnl crapseg.cdopecnl%type
    ,dsseguro VARCHAR2(100)
    ,dsstatus VARCHAR2(100)
    ,vlseguro crawseg.vlseguro%type
    ,nmdsegur crawseg.nmdsegur%type
    ,vlant    crapseg.vlpreseg%type
    ,registro ROWID
    ,dsmotcan VARCHAR2(100));

  -- Tipo de tabela de Seguros
  TYPE typ_tab_seguros IS TABLE OF typ_reg_seguros INDEX BY PLS_INTEGER;
  
  -- Tipo de Registro da Seguradora
  TYPE typ_reg_seguradora IS RECORD 
    (cdsegura crapcsg.cdsegura%type
    ,nmsegura crapcsg.nmsegura%type
    ,nrcgcseg crapcsg.nrcgcseg%type
    ,nmresseg crapcsg.nmresseg%type
    ,dsmsgseg crapcsg.dsmsgseg%type
    ,nrctrato crapcsg.nrctrato%type
    ,nrultpra crapcsg.nrultpra%type
    ,nrlimpra crapcsg.nrlimpra%type
    ,nrultprc crapcsg.nrultprc%type
    ,nrlimprc crapcsg.nrlimprc%type
    ,dsasauto crapcsg.dsasauto%type
    ,cdhstaut##1 crapcsg.cdhstaut##1%type
    ,cdhstaut##2 crapcsg.cdhstaut##2%type
    ,cdhstaut##3 crapcsg.cdhstaut##3%type
    ,cdhstaut##4 crapcsg.cdhstaut##4%type
    ,cdhstaut##5 crapcsg.cdhstaut##5%type
    ,cdhstaut##6 crapcsg.cdhstaut##6%type
    ,cdhstaut##7 crapcsg.cdhstaut##7%type
    ,cdhstaut##8 crapcsg.cdhstaut##8%type
    ,cdhstaut##9 crapcsg.cdhstaut##9%type
    ,cdhstaut##10 crapcsg.cdhstaut##10%type
    ,cdhstcas##1 crapcsg.cdhstcas##1%type
    ,cdhstcas##2 crapcsg.cdhstcas##2%type
    ,cdhstcas##3 crapcsg.cdhstcas##3%type
    ,cdhstcas##4 crapcsg.cdhstcas##4%type
    ,cdhstcas##5 crapcsg.cdhstcas##5%type
    ,cdhstcas##6 crapcsg.cdhstcas##6%type
    ,cdhstcas##7 crapcsg.cdhstcas##7%type
    ,cdhstcas##8 crapcsg.cdhstcas##8%type
    ,cdhstcas##9 crapcsg.cdhstcas##9%type
    ,cdhstcas##10 crapcsg.cdhstcas##10%type
    ,cdcooper crapcsg.cdcooper%type
    ,flgativo crapcsg.flgativo%type
    ,nmrescec VARCHAR2(100)
    ,nmrescop crapcop.nmrescop%type);
  
  -- Tipo de tabela da Seguradora
  TYPE typ_tab_seguradora IS TABLE OF typ_reg_seguradora INDEX BY PLS_INTEGER;
  
  -- Tipo de registro dos planos de seguros /* b1wgen0033tt.i - tt-plano-seg */
  TYPE typ_rec_plano_seg IS RECORD
    (tpseguro craptsg.tpseguro%type
    ,tpplaseg craptsg.tpplaseg%type
    ,vlplaseg craptsg.vlplaseg%type
    ,dsocupac craptsg.dsocupac%type
    ,dsgarant craptsg.dsgarant%type
    ,nrtabela craptsg.nrtabela%type
    ,dsmorada craptsg.dsmorada%type
    ,cdsitpsg craptsg.cdsitpsg%type
    ,inplaseg craptsg.inplaseg%type
    ,vlmorada craptsg.vlmorada%type
    ,cdsegura craptsg.cdsegura%type
    ,flgunica craptsg.flgunica%type
    ,cdcooper craptsg.cdcooper%type
    ,dddcorte craptsg.dddcorte%type
    ,mmpripag craptsg.mmpripag%type
    ,ddcancel craptsg.ddcancel%type
    ,qtdiacar craptsg.qtdiacar%type
    ,ddmaxpag craptsg.ddmaxpag%type
    ,qtmaxpar craptsg.qtmaxpar%type);
    
  -- Tipo de tabela dos planos de seguros
  TYPE typ_tab_plano_seg IS TABLE OF typ_rec_plano_seg INDEX BY PLS_INTEGER;
    
  /* Procedure que contabiliza seguros novos e cancelados no periodo */                              
  PROCEDURE pc_contabiliza (pr_cdcooper IN crapcop.cdcooper%type
                           ,pr_tpseguro IN crapseg.tpseguro%type
                           ,pr_dataini IN DATE
                           ,pr_datafim IN DATE
                           ,pr_inpessoa IN crapass.inpessoa%TYPE
                           ,pr_cdagenci IN crapass.cdagenci%TYPE
                           ,pr_qtdnovos OUT PLS_INTEGER
                           ,pr_qtdcance OUT PLS_INTEGER);   
                           
  /* Procedure para buscar dados dos seguros */
  PROCEDURE pc_busca_dados_seg (pr_cdcooper IN PLS_INTEGER,
                                pr_vlrdecom1 OUT NUMBER,
                                pr_vlrdecom2 OUT NUMBER,
                                pr_vlrdecom3 OUT NUMBER,
                                pr_vlrdeiof1 OUT NUMBER,
                                pr_vlrdeiof2 OUT NUMBER,
                                pr_vlrdeiof3 OUT NUMBER,
                                pr_recid1    OUT ROWID,
                                pr_recid2    OUT ROWID,
                                pr_recid3    OUT ROWID,
                                pr_vlrapoli  OUT NUMBER,
                                pr_cdcritic  OUT crapcri.cdcritic%type,
                                pr_dscritic  OUT VARCHAR2);                           
  
  -- Procedure para busca dos seguros de vida e residencia
  PROCEDURE pc_seguros_resid_vida (pr_cdcooper IN PLS_INTEGER
                                  ,pr_dataini  IN DATE
                                  ,pr_datafim  IN DATE
                                  ,pr_cdagenci IN PLS_INTEGER
                                  ,pr_listahis IN VARCHAR2
                                  ,pr_tab_seguro OUT SEGU0001.typ_tab_seguro
                                  ,pr_des_reto   OUT VARCHAR2);
  -- Procedure para busca dos seguros de automovel
  PROCEDURE pc_seguros_auto (pr_cdcooper IN PLS_INTEGER
                            ,pr_dataini  IN DATE
                            ,pr_datafim  IN DATE
                            ,pr_cdagenci IN PLS_INTEGER
                            ,pr_tpseguro IN PLS_INTEGER
                            ,pr_cdsitseg IN PLS_INTEGER
                            ,pr_vlrapoli IN NUMBER
                            ,pr_vlrdecom1 IN NUMBER
                            ,pr_vlrdeiof1 IN NUMBER
                            ,pr_vlrdecom2 IN NUMBER
                            ,pr_vlrdeiof2 IN NUMBER
                            ,pr_vlrdecom3 IN NUMBER
                            ,pr_vlrdeiof3 IN NUMBER
                            ,pr_tab_seguro       IN  SEGU0001.typ_tab_seguro
                            ,pr_tab_info_seguros OUT SEGU0001.typ_tab_info_seguros
                            ,pr_des_reto    OUT VARCHAR );                                  
  
  --Procedimento para Buscar Seguros
  PROCEDURE pc_buscar_seguros (pr_cdcooper  IN crapcop.cdcooper%type -- Cooperativa
                              ,pr_cdagenci  IN crapage.cdagenci%type -- Agencia
                              ,pr_nrdcaixa  IN INTEGER               -- Numero Caixa
                              ,pr_cdoperad  IN crapope.cdoperad%type -- Operador
                              ,pr_dtmvtolt  IN crapdat.dtmvtolt%type -- Data Movimento
                              ,pr_nrdconta  IN crapass.nrdconta%type -- Numero Conta
                              ,pr_idseqttl  IN crapttl.idseqttl%type -- Sequencial Titular
                              ,pr_idorigem  IN INTEGER               -- Origem Informacao
                              ,pr_nmdatela  IN VARCHAR2              -- Programa Chamador
                              ,pr_flgerlog  IN BOOLEAN               -- Escrever Erro Log
                              ,pr_cdempres  IN crapemp.cdempres%type -- Codigo Empresa
                              ,pr_tab_seguros OUT segu0001.typ_tab_seguros -- Tabela de Seguros
                              ,pr_qtsegass  OUT INTEGER              -- Qdade Seguros Associado
                              ,pr_vltotseg  OUT NUMBER               -- Valor Total Segurado
                              ,pr_des_erro  OUT VARCHAR2             -- Descricao Erro
                              ,pr_tab_erro  OUT GENE0001.typ_tab_erro); -- Tabela Erros
                                                                                           
  --Procedimento para Criar o Seguro
  PROCEDURE pc_cria_seguro (pr_cdcooper  IN crapcop.cdcooper%type -- Cooperativa
                           ,pr_cdagenci  IN crapage.cdagenci%type -- Agencia
                           ,pr_nrdcaixa  IN INTEGER               -- Numero Caixa
                           ,pr_cdoperad  IN crapope.cdoperad%type -- Operador
                           ,pr_dtmvtolt  IN crapdat.dtmvtolt%type -- Data Movimento
                           ,pr_nrdconta  IN crapass.nrdconta%type -- Numero Conta
                           ,pr_idseqttl  IN crapttl.idseqttl%type -- Sequencial Titular
                           ,pr_idorigem  IN INTEGER               -- Origem Informacao
                           ,pr_nmdatela  IN VARCHAR2              -- Programa Chamador
                           ,pr_flgerlog  IN BOOLEAN               -- Escrever Erro Log
                           ,pr_cdmotcan  IN crapseg.cdmotcan%type -- Motivo Cancelamento
                           ,pr_cdsegura  IN crapseg.cdsegura%type -- Codigo Seguradora
                           ,pr_cdsitseg  IN crapseg.cdsitseg%type -- Situacao Seguro
                           ,pr_tab_dsgraupr segu0001.typ_tab_dsgraupr -- Grau Parentesco 
                           ,pr_dtaltseg  IN crapseg.dtaltseg%type -- Data Alteracao Seguro
                           ,pr_dtcancel  IN crapseg.dtcancel%type -- Data Cancelamento
                           ,pr_dtdebito  IN crapseg.dtdebito%type -- Data Debito
                           ,pr_dtfimvig  IN crapseg.dtfimvig%type -- Data Fim Vigencia
                           ,pr_dtiniseg  IN crapseg.dtiniseg%type -- Data Inicio Seguro
                           ,pr_dtinivig  IN crapseg.dtinivig%type -- Data Inicio Vigencia
                           ,pr_dtprideb  IN crapseg.dtprideb%type -- Data Primeiro Debito
                           ,pr_dtultalt  IN crapseg.dtultalt%type -- Data Ultima Alteracao
                           ,pr_dtultpag  IN crapseg.dtultpag%type -- Data Ultimo Pagamento
                           ,pr_flgclabe  IN crapseg.flgclabe%type -- Flag Abertura
                           ,pr_flgconve  IN crapseg.flgconve%type -- Flag Convenio
                           ,pr_flgunica  IN crapseg.flgunica%type -- Flag Parcela Unica
                           ,pr_indebito  IN crapseg.indebito%type -- Indicador Debito
                           ,pr_lsctrant  IN crapseg.lsctrant%type -- Contrato Anterior
                           ,pr_tab_nmbenvid  IN segu0001.typ_tab_nmbenvid -- Nome Beneficiario Vida
                           ,pr_nrctratu  IN crapseg.nrctratu%type -- Numero Contrato Atual
                           ,pr_nrctrseg  IN crapseg.nrctrseg%type -- Numero Contrato Seguro
                           ,pr_nrdolote  IN craplot.nrdolote%type -- Numero do Lote
                           ,pr_qtparcel  IN crapseg.qtparcel%type -- Quantidade Parcelas
                           ,pr_qtprepag  IN crapseg.qtprepag%type -- Quantidade Parcelas Pagas
                           ,pr_qtprevig  IN crapseg.qtprevig%type -- Quantidade Prestacoes Vigentes
                           ,pr_tpdpagto  IN crapseg.tpdpagto%type -- Tipo de Pagamento
                           ,pr_tpendcor  IN crapseg.tpendcor%type -- Tipo Endereco Correspondencia
                           ,pr_tpplaseg  IN crapseg.tpplaseg%type -- Tipo Plano Seguro
                           ,pr_tpseguro  IN crapseg.tpseguro%type -- Tipo Seguro
                           ,pr_tab_txpartic IN segu0001.typ_tab_txpartic --Tabela taxa participacao
                           ,pr_vldifseg  IN crapseg.vldifseg%type -- Valor Diferenca Seguro
                           ,pr_vlpremio  IN crapseg.vlpremio%type -- Valor do Premio
                           ,pr_vlprepag  IN crapseg.vlprepag%type -- Valor Prestacoes Pagas
                           ,pr_vlpreseg  IN crapseg.vlpreseg%type -- Valor Prestacao Seguro
                           ,pr_vlcapseg  IN craptsg.vlmorada%type -- Valor Capital Segurado
                           ,pr_cdbccxlt  IN craplot.cdbccxlt%type -- Caixa
                           ,pr_nrcpfcgc  IN crawseg.nrcpfcgc%type -- Numero cpf/cnpj
                           ,pr_nmdsegur  IN crawseg.nmdsegur%type -- Nome Segurado
                           ,pr_vltotpre  IN crapseg.vlpremio%type -- Valor Total Prestacoes
                           ,pr_cdcalcul  IN crawseg.cdcalcul%type -- Codigo Calculo
                           ,pr_vlseguro  IN crawseg.vlseguro%type -- Valor Seguro
                           ,pr_dsendres  IN crawseg.dsendres%type -- Descricao Endereco
                           ,pr_nrendres  IN crawseg.nrendres%type -- Numero Endereco
                           ,pr_nmbairro  IN crawseg.nmbairro%type -- Nome Bairro
                           ,pr_nmcidade  IN crawseg.nmcidade%type -- Nome Cidade
                           ,pr_cdufresd  IN crawseg.cdufresd%type -- Estado Residencia
                           ,pr_nrcepend  IN crawseg.nrcepend%type -- CEP Endereco
                           ,pr_cdsexosg  IN INTEGER               -- Sexo
                           ,pr_cdempres  IN crapemp.cdempres%type -- Codigo Empresa
                           ,pr_dtnascsg  IN crapdat.dtmvtolt%type -- Data Nascimento
                           ,pr_complend  IN crawseg.complend%type -- Complemento Endereco
                           ,pr_flgsegur  OUT BOOLEAN              -- Seguro Criado
                           ,pr_crawseg   OUT ROWID                -- Registro Crawseg
                           ,pr_des_erro  OUT VARCHAR2             -- Retorno Erro OK/NOK 
                           ,pr_tab_erro  OUT gene0001.typ_tab_erro); --Tabela Erros                            
                           
  -- Rotina para verificar pacote de tarifas via web
  PROCEDURE pc_buscar_plaseg_web(pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da Conta                                 
                                ,pr_cdsegura IN crapseg.cdsegura%type -- Codigo Seguradora
                                ,pr_tpseguro IN craptsg.tpseguro%type -- Tipo Seguro
                                ,pr_tpplaseg IN craptsg.tpplaseg%type -- Tipo Plano Seguro
                                ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo da Critica
                                ,pr_dscritic OUT crapcri.dscritic%TYPE --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2);                           
                           
END SEGU0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED."SEGU0001" AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : SEGU0001
  --  Sistema  : Procedimentos para Seguros
  --  Sigla    : CRED
  --  Autor    : Douglas Pagel
  --  Data     : Novembro/2013.                   Ultima atualizacao: 22/08/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para busca de dados de seguros
  --
  -- Alteracao : 22/08/2016 - Criada procedure pc_buscar_plaseg_web que buscar o valor do plano
  --                          de acordo com os parametros (Tiago/Thiago #462910)
  ---------------------------------------------------------------------------------------------------------------
  -- Busca dos dados da cooperativa
  CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%type) IS
    SELECT cop.nmrescop
          ,cop.nmextcop
          ,cop.dsemlcof
    FROM crapcop cop
    WHERE cop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;
                        
  /* Procedure que contabiliza seguros novos e cancelados no periodo */
  PROCEDURE pc_contabiliza (pr_cdcooper IN crapcop.cdcooper%type
                           ,pr_tpseguro IN crapseg.tpseguro%type
                           ,pr_dataini  IN DATE
                           ,pr_datafim  IN DATE
                           ,pr_inpessoa IN crapass.inpessoa%TYPE
                           ,pr_cdagenci IN crapass.cdagenci%TYPE
                           ,pr_qtdnovos OUT PLS_INTEGER
                           ,pr_qtdcance OUT PLS_INTEGER) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_contabiliza           Antigo: b1wgen0045.p/proc_contabiliza
  --  Sistema  : Procedimentos para contabilizar seguros
  --  Sigla    : CRED
  --  Autor    : Douglas Pagel
  --  Data     : Novembro/2013.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Retorna quantidade de seguros novos e cancelados do tipo e periodo informado

  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      -- Cursor para seguros novos
      CURSOR cr_crapseg_novos (pr_cdcooper crapcop.cdcooper%type
                              ,pr_tpseguro crapseg.tpseguro%type
                              ,pr_dataini DATE
                              ,pr_datafim DATE) IS
        SELECT count(*) as qtdnovos
          FROM crapseg,
               crapass
         WHERE crapseg.cdcooper = pr_cdcooper
           AND crapseg.tpseguro = pr_tpseguro
           AND crapseg.dtmvtolt >= pr_dataini
           AND crapseg.dtmvtolt <= pr_datafim
           AND crapass.cdcooper = crapseg.cdcooper
           AND crapass.nrdconta = crapseg.nrdconta
           AND crapass.cdagenci = pr_cdagenci
           AND crapass.inpessoa = pr_inpessoa;
      rw_crapseg_novos cr_crapseg_novos%rowtype;   
      
      -- Cursor para seguros cancelados
      CURSOR cr_crapseg_cance (pr_cdcooper crapcop.cdcooper%type
                              ,pr_tpseguro crapseg.tpseguro%type
                              ,pr_dataini DATE
                              ,pr_datafim DATE) IS
        SELECT count(*) as qtdcance
          FROM crapseg,
               crapass
         WHERE crapseg.cdcooper = pr_cdcooper
           AND crapseg.tpseguro = pr_tpseguro
           AND crapseg.dtcancel >= pr_dataini
           AND crapseg.dtcancel <= pr_datafim
           AND crapass.cdcooper = crapseg.cdcooper
           AND crapass.nrdconta = crapseg.nrdconta
           AND crapass.cdagenci = pr_cdagenci
           AND crapass.inpessoa = pr_inpessoa;
      rw_crapseg_cance cr_crapseg_cance%rowtype;

    BEGIN
      -- BUSCA SEGUROS NOVOS
      OPEN cr_crapseg_novos (pr_cdcooper => pr_cdcooper
                            ,pr_tpseguro => pr_tpseguro
                            ,pr_dataini  => pr_dataini
                            ,pr_datafim  => pr_datafim);
      FETCH cr_crapseg_novos
        INTO rw_crapseg_novos;
      -- REOTRNA QUANTIDADE  
      pr_qtdnovos := rw_crapseg_novos.qtdnovos;
      CLOSE cr_crapseg_novos;
      
      -- BUSCA SEGUROS CANCELADOS
      OPEN cr_crapseg_cance(pr_cdcooper => pr_cdcooper
                            ,pr_tpseguro => pr_tpseguro
                            ,pr_dataini  => pr_dataini
                            ,pr_datafim  => pr_datafim);
      FETCH cr_crapseg_cance
        INTO rw_crapseg_cance;
      -- RETORNA QUANTIDADE  
      pr_qtdcance := rw_crapseg_cance.qtdcance;
      CLOSE cr_crapseg_cance;
    END;
  END; -- pc_contabiliza
  
  /* Procedure para buscar dados dos seguros */
  PROCEDURE pc_busca_dados_seg (pr_cdcooper IN PLS_INTEGER,
                                pr_vlrdecom1 OUT NUMBER,
                                pr_vlrdecom2 OUT NUMBER,
                                pr_vlrdecom3 OUT NUMBER,
                                pr_vlrdeiof1 OUT NUMBER,
                                pr_vlrdeiof2 OUT NUMBER,
                                pr_vlrdeiof3 OUT NUMBER,
                                pr_recid1    OUT ROWID,
                                pr_recid2    OUT ROWID,
                                pr_recid3    OUT ROWID,
                                pr_vlrapoli  OUT NUMBER,
                                pr_cdcritic  OUT crapcri.cdcritic%type,
                                pr_dscritic  OUT VARCHAR2) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_busca_dados_seg           Antigo: b1wgen0045.p/busca_dados_seg
  --  Sistema  : Procedimentos coletar dados dos seguros
  --  Sigla    : CRED
  --  Autor    : Douglas Pagel
  --  Data     : Novembro/2013.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para buscar taxas dos seguros

  ---------------------------------------------------------------------------------------------------------------
    
    --Variaveis de Erro
    vr_cdcritic crapcri.cdcritic%type;
    vr_dscritic VARCHAR2(4000);
    --Variaveis de Excecao
    vr_exc_erro EXCEPTION;

    -- CURSOR para craptab
    CURSOR cr_craptab IS
      SELECT craptab.tpregist,
             craptab.rowid,
             CRAPTAB.dstextab
        FROM craptab
       WHERE craptab.cdcooper = pr_cdcooper
         AND UPPER(craptab.nmsistem) = 'CRED'
         AND UPPER(craptab.tptabela) = 'GENERI'
         AND craptab.cdempres = 00
         AND UPPER(craptab.cdacesso) = 'TAXASEGURO'
         AND craptab.tpregist BETWEEN 1 AND 3;
    rw_craptab cr_craptab%rowtype;
  BEGIN
    --Inicializar varaivel retorno erro
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    OPEN cr_craptab;

    LOOP 
      FETCH cr_craptab INTO rw_craptab;
      EXIT WHEN cr_craptab%NOTFOUND;

      -- Busca taxa dos seguros na craptab
      IF rw_craptab.tpregist = 1 THEN -- Auto
        pr_vlrdeiof1 := TO_NUMBER(nvl(trim(SUBSTR(rw_craptab.dstextab,1,5)),0));
        pr_vlrdecom1 := TO_NUMBER(nvl(trim(SUBSTR(rw_craptab.dstextab,6,5)),0));
        pr_recid1    := rw_craptab.rowid;
        pr_vlrapoli  := TO_NUMBER(nvl(trim(SUBSTR(rw_craptab.dstextab,11,6)),0));
      ELSIF rw_craptab.tpregist = 2 THEN -- Vida
        pr_vlrdeiof2 := TO_NUMBER(nvl(trim(SUBSTR(rw_craptab.dstextab,1,5)),0));
        pr_vlrdecom2 := TO_NUMBER(nvl(trim(SUBSTR(rw_craptab.dstextab,6,5)),0));
        pr_recid2    := rw_craptab.rowid;
      ELSIF rw_craptab.tpregist = 3 THEN -- Residencial
        pr_vlrdeiof3 := TO_NUMBER(nvl(trim(SUBSTR(rw_craptab.dstextab,1,5)),0));
        pr_vlrdecom3 := TO_NUMBER(nvl(trim(SUBSTR(rw_craptab.dstextab,6,5)),0));
        pr_recid3    := rw_craptab.rowid;
      END IF;

    END LOOP;
      
    -- Fecha o cursor
    CLOSE cr_craptab;
 
  EXCEPTION
     WHEN vr_exc_erro THEN
       pr_cdcritic:= vr_cdcritic;
       pr_dscritic:= vr_dscritic;
     WHEN OTHERS THEN
       pr_cdcritic:= 0;
       pr_dscritic:= 'Erro na rotina SEGU0001.pc_busca_dados_seg. '||SQLERRM;
  END; -- pc_busca_dados_seg
  
  /* Procedure para buscar valores dos seguros */
  PROCEDURE pc_seguros_resid_vida (pr_cdcooper IN PLS_INTEGER
                                  ,pr_dataini  IN DATE
                                  ,pr_datafim  IN DATE
                                  ,pr_cdagenci IN PLS_INTEGER
                                  ,pr_listahis IN VARCHAR2
                                  ,pr_tab_seguro OUT SEGU0001.typ_tab_seguro
                                  ,pr_des_reto    OUT VARCHAR2) IS
     ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_seguros_resid_vida           Antigo: b1wgen0045.p/seguros_resid_vida
  --  Sistema  : Procedimentos coletar dados dos seguros
  --  Sigla    : CRED
  --  Autor    : Douglas Pagel
  --  Data     : Novembro/2013.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para buscar valores dos seguros

  ---------------------------------------------------------------------------------------------------------------
    vr_chave VARCHAR2(15);         -- auxiliar para chave da PlTable de seguros
    vr_nrcontad NUMBER(10) := 0;

    -- CURSOR para lancamentos de seguros
    -- Foi tentado agrupar os valores por lancamento e somar o qtsegvid, porém vai dar erro nos arredondamentos
    CURSOR cr_craplcm IS
      SELECT crapass.cdagenci,
             crapass.inpessoa,
             crapseg.tpseguro,
             crapseg.dtcancel,
             1 qtsegvid, 
             craplcm.vllanmto 
        FROM crapseg,
             craplcm,
             crapass
       WHERE craplcm.cdcooper = pr_cdcooper
         AND craplcm.dtmvtolt >= pr_dataini
         AND craplcm.dtmvtolt <= pr_datafim
         -- 175, 460 e 511 SEGURO CASA
         -- 341 SEGURO VIDA
         AND craplcm.cdhistor IN (341,175,460,511)  
         AND crapass.cdagenci = decode(pr_cdagenci,0,crapass.cdagenci,pr_cdagenci) -- Se foi passado agencia, ler somente a agencia passada
         AND crapass.nrdconta = craplcm.nrdconta
         AND crapass.cdcooper = pr_cdcooper
         AND crapseg.cdcooper = crapass.cdcooper
         AND crapseg.nrdconta = crapass.nrdconta
         AND crapseg.tpseguro = decode(craplcm.cdhistor,341,
                                                            3, -- Vida
                                                            11) -- Residencial
         AND crapseg.nrctrseg = craplcm.nrdocmto;
    rw_craplcm cr_craplcm%rowtype;

  BEGIN
    -- Leitura da craplcm
    OPEN cr_craplcm;
    LOOP
      FETCH cr_craplcm
       INTO rw_craplcm;
      EXIT WHEN cr_craplcm%NOTFOUND;

      -- Monta chave para inserir dados na PlTable de seguros
      vr_chave := LPAD(rw_craplcm.tpseguro, 2, '0') || LPAD(rw_craplcm.cdagenci, 3, '0') || LPAD(vr_nrcontad, 9, '0');
      -- Insere dados na PlTable de parametro
      pr_tab_seguro(vr_chave).cdagenci := rw_craplcm.cdagenci;
      pr_tab_seguro(vr_chave).inpessoa := rw_craplcm.inpessoa;
      pr_tab_seguro(vr_chave).tpseguro := rw_craplcm.tpseguro;
      pr_tab_seguro(vr_chave).vllanmto := rw_craplcm.vllanmto;
      pr_tab_seguro(vr_chave).qtsegvid := rw_craplcm.qtsegvid;
      pr_tab_seguro(vr_chave).dtcancel := rw_craplcm.dtcancel;

      -- Acrescenta o contador do indice
      vr_nrcontad := vr_nrcontad + 1;
    END LOOP; -- FIM leitura da craplcm
    CLOSE cr_craplcm;
  EXCEPTION
    WHEN others THEN
      -- Retorno nao OK
      pr_des_reto := 'Erro rotina pc_seguros_resid_vida: '||SQLERRM;
  END; -- pc_seguros_resid_vida
  
  /* Procedimentos coletar dados dos seguros */
  PROCEDURE pc_seguros_auto (pr_cdcooper IN PLS_INTEGER
                            ,pr_dataini  IN DATE
                            ,pr_datafim  IN DATE
                            ,pr_cdagenci IN PLS_INTEGER
                            ,pr_tpseguro IN PLS_INTEGER
                            ,pr_cdsitseg IN PLS_INTEGER
                            ,pr_vlrapoli IN NUMBER
                            ,pr_vlrdecom1 IN NUMBER
                            ,pr_vlrdeiof1 IN NUMBER
                            ,pr_vlrdecom2 IN NUMBER
                            ,pr_vlrdeiof2 IN NUMBER
                            ,pr_vlrdecom3 IN NUMBER
                            ,pr_vlrdeiof3 IN NUMBER
                            ,pr_tab_seguro       IN  SEGU0001.typ_tab_seguro
                            ,pr_tab_info_seguros OUT SEGU0001.typ_tab_info_seguros
                            ,pr_des_reto    OUT VARCHAR ) IS
  BEGIN
     ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_seguros_auto           Antigo: b1wgen0045.p/seguros_auto
  --  Sistema  : Procedimentos coletar dados dos seguros
  --  Sigla    : CRED
  --  Autor    : Douglas Pagel
  --  Data     : Novembro/2013.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para buscar seguros de automovel

  ---------------------------------------------------------------------------------------------------------------
    DECLARE
    -- CURSORES --

    -- Cursor para listagem dos seguros
    CURSOR cr_crapseg (pr_cdcooper crapcop.cdcooper%TYPE
                      ,pr_cdagenci crapass.cdagenci%TYPE
                      ,pr_tpseguro PLS_INTEGER
                      ,pr_cdsitseg PLS_INTEGER
                      ,pr_dataini  DATE
                      ,pr_datafim  DATE) IS
     SELECT crapseg.lsctrant,
            crapseg.nrdconta,
            crapseg.tpseguro,
            crapseg.vlpremio,
            crapass.inpessoa,
            crapass.cdagenci
       FROM crapseg,
            crapass
      WHERE crapseg.cdcooper = pr_cdcooper
        AND crapseg.tpseguro = pr_tpseguro
        AND crapseg.cdsitseg <> pr_cdsitseg
        AND crapseg.dtmvtolt >= pr_dataini
        AND crapseg.dtmvtolt <= pr_datafim
        AND crapass.cdcooper = crapseg.cdcooper
        AND crapass.nrdconta = crapseg.nrdconta
        AND crapseg.lsctrant = ' '
        AND crapseg.cdagenci = decode(pr_cdagenci,0,crapseg.cdagenci,pr_cdagenci);
    rw_crapseg cr_crapseg%rowtype;


    -- VARIAVEIS --
    vr_tot_qtseguro_aut     PLS_INTEGER := 0;
    vr_tot_qtseguro_res     PLS_INTEGER := 0;
    vr_tot_qtseguro_vid     PLS_INTEGER := 0;
    vr_tot_qtdnovos         PLS_INTEGER := 0;
    vr_tot_qtdcance         PLS_INTEGER := 0;
    vr_tot_vllanmto_vid     NUMBER(25,4) := 0;
    vr_tot_vlreceit_vid     NUMBER(25,4) := 0;
    vr_tot_vlrepass_vid     NUMBER(25,4) := 0;
    vr_tot_vllanmto_res     NUMBER(25,4) := 0;
    vr_tot_vlreceit_res     NUMBER(25,4) := 0;
    vr_tot_vlrepass_res     NUMBER(25,4) := 0;
    vr_tot_vllanmto_aut     NUMBER(25,4) := 0;
    vr_tot_vlreceit_aut     NUMBER(25,4) := 0;
    vr_tot_vlrepass_aut     NUMBER(25,4) := 0;
    vr_rel_vlreceit_aut     NUMBER(25,4) := 0;
    vr_rel_vlreceit_vid     NUMBER(25,4) := 0;
    vr_rel_vlreceit_res     NUMBER(25,4) := 0;
    -- Para PlTable de seguros
    vr_chave varchar2(15); --(2) tpseguro || (3) cdagenci || (10) nrdconta
    vr_cdagenci PLS_INTEGER := 0; -- Auxiliar para troca de agencia.
    vr_trocapa BOOLEAN := FALSE; -- Auxiliar para troca de agencia.
    vr_chave_info VARCHAR2(14) := 0; -- Auxiliar para chave da pl-table de info seguros
    vr_nrcontad NUMBER(09) := 0;
    vr_inpessoa NUMBER(03) := 0;
    BEGIN
      -- Limpa tabela de saida
      pr_tab_info_seguros.delete;

      -- Atualiza a tabela de seguros com o parametro
      segu0001.vr_tab_seguro := pr_tab_seguro;

      -- Listagem dos seguros auto
      OPEN cr_crapseg(pr_cdcooper => pr_cdcooper
                      ,pr_cdagenci => pr_cdagenci
                      ,pr_tpseguro => pr_tpseguro
                      ,pr_cdsitseg => pr_cdsitseg
                      ,pr_dataini  => pr_dataini
                      ,pr_datafim  => pr_datafim);
      LOOP
        FETCH cr_crapseg INTO rw_crapseg;
        EXIT WHEN cr_crapseg%NOTFOUND;

        -- Monta chave para inserir na pltable de seguros
        vr_chave := LPAD(rw_crapseg.tpseguro, 2, '0') || LPAD(rw_crapseg.cdagenci, 3, '0') || LPAD(vr_nrcontad, 9, '0');
        -- aumenta o contador
        vr_nrcontad := vr_nrcontad + 1; 
        -- Insere dados da pltable de seguros
        segu0001.vr_tab_seguro(vr_chave).cdagenci := rw_crapseg.cdagenci;
        segu0001.vr_tab_seguro(vr_chave).inpessoa := rw_crapseg.inpessoa;
        segu0001.vr_tab_seguro(vr_chave).tpseguro := rw_crapseg.tpseguro;
        segu0001.vr_tab_seguro(vr_chave).vllanmto := rw_crapseg.vlpremio;

      END LOOP; --FIM Listagem dos seguros auto
      CLOSE cr_crapseg;

      -- Loop para pltable de seguros
      vr_chave := segu0001.vr_tab_seguro.first;
      LOOP
        EXIT WHEN vr_chave IS NULL;
        -- Calcula valores dos seguros
        IF segu0001.vr_tab_seguro(vr_chave).tpseguro = 2 THEN -- AUTO
          vr_rel_vlreceit_aut := (segu0001.vr_tab_seguro(vr_chave).vllanmto -
                                 (segu0001.vr_tab_seguro(vr_chave).vllanmto *
                                 (pr_vlrdeiof1 / 100))) - pr_vlrapoli;
          vr_rel_vlreceit_aut := round(vr_rel_vlreceit_aut *
                                (pr_vlrdecom1 / 100),2);

        END IF;

        IF segu0001.vr_tab_seguro(vr_chave).tpseguro = 1 OR -- RESIDENCIA
          segu0001.vr_tab_seguro(vr_chave).tpseguro = 11 THEN
          vr_rel_vlreceit_res := segu0001.vr_tab_seguro(vr_chave).vllanmto  -
                                      (segu0001.vr_tab_seguro(vr_chave).vllanmto * (pr_vlrdeiof3 /
                                      100));
          vr_rel_vlreceit_res := round(vr_rel_vlreceit_res * (pr_vlrdecom3 /
                    100),2);
        END IF;

        IF segu0001.vr_tab_seguro(vr_chave).tpseguro = 3 THEN -- VIDA
          vr_rel_vlreceit_vid := segu0001.vr_tab_seguro(vr_chave).vllanmto -
                                          (segu0001.vr_tab_seguro(vr_chave).vllanmto *
                                           (pr_vlrdeiof2 / 100));
          vr_rel_vlreceit_vid := round(vr_rel_vlreceit_vid *
                                             (pr_vlrdecom2 / 100),2);
        END IF;

        -- Acumula quantidades dos seguros

        IF segu0001.vr_tab_seguro(vr_chave).tpseguro = 2 THEN -- AUTO
          IF vr_rel_vlreceit_aut < 0 OR
             segu0001.vr_tab_seguro(vr_chave).vllanmto <= pr_vlrapoli THEN
            vr_rel_vlreceit_aut := 0;
          END IF;
          vr_tot_qtseguro_aut := vr_tot_qtseguro_aut + 1;
          vr_tot_vllanmto_aut := vr_tot_vllanmto_aut + segu0001.vr_tab_seguro(vr_chave).vllanmto;
          vr_tot_vlreceit_aut := vr_tot_vlreceit_aut + vr_rel_vlreceit_aut;
          vr_tot_vlrepass_aut := vr_tot_vlrepass_aut + (segu0001.vr_tab_seguro(vr_chave).vllanmto - vr_rel_vlreceit_aut);
        END IF;

        IF segu0001.vr_tab_seguro(vr_chave).tpseguro = 3 THEN -- VIDA
          vr_tot_qtseguro_vid := vr_tot_qtseguro_vid + segu0001.vr_tab_seguro(vr_chave).qtsegvid;
          vr_tot_vllanmto_vid := vr_tot_vllanmto_vid + segu0001.vr_tab_seguro(vr_chave).vllanmto;
          vr_tot_vlreceit_vid := vr_tot_vlreceit_vid + vr_rel_vlreceit_vid;
          vr_tot_vlrepass_vid := vr_tot_vlrepass_vid + (segu0001.vr_tab_seguro(vr_chave).vllanmto - vr_rel_vlreceit_vid);
        END IF;

        IF segu0001.vr_tab_seguro(vr_chave).tpseguro = 1 OR -- RESIDENCIA
           segu0001.vr_tab_seguro(vr_chave).tpseguro = 11 THEN
          vr_tot_qtseguro_res := vr_tot_qtseguro_res + 1;
          vr_tot_vllanmto_res := vr_tot_vllanmto_res + segu0001.vr_tab_seguro(vr_chave).vllanmto;
          vr_tot_vlreceit_res := vr_tot_vlreceit_res + vr_rel_vlreceit_res;
          vr_tot_vlrepass_res := vr_tot_vlrepass_res + (segu0001.vr_tab_seguro(vr_chave).vllanmto - vr_rel_vlreceit_res);
        END IF;

        -- Pega o PA atual
        vr_cdagenci := segu0001.vr_tab_seguro(vr_chave).cdagenci;
        vr_inpessoa := segu0001.vr_tab_seguro(vr_chave).inpessoa;

        -- Verifica se deve inserir os dados na pltable de info seguros
        vr_trocapa := FALSE;
        -- Se proximo registro existe
        IF segu0001.vr_tab_seguro.next(vr_chave) IS NOT NULL THEN
          -- E SE TROCOU O PA
          IF vr_cdagenci <> segu0001.vr_tab_seguro(segu0001.vr_tab_seguro.next(vr_chave)).cdagenci OR
             vr_inpessoa <> segu0001.vr_tab_seguro(segu0001.vr_tab_seguro.next(vr_chave)).inpessoa THEN
            vr_trocapa := TRUE;
          END IF; -- FIM trocou PA
        ELSE
          vr_trocapa := TRUE;
        END IF; -- FIM Verificacao para info seguros

        -- Se teve troca de PA, insere na pltable de info seguros
        IF vr_trocapa THEN
          -- Monta chave para ver se registro já existe
          -- (2) tpseguro || (3) cdagenci || (1) inpessoa || (8) dtrefere

          vr_chave_info := LPAD(segu0001.vr_tab_seguro(vr_chave).tpseguro, 2, '0') || LPAD(segu0001.vr_tab_seguro(vr_chave).cdagenci, 3, '0') || LPAD(segu0001.vr_tab_seguro(vr_chave).inpessoa, 1, '0') || LPAD(to_char(pr_datafim,'yyyymmdd'), 2, '0');
          -- Verifica se registro existe
          IF pr_tab_info_seguros.EXISTS(vr_chave_info) THEN
            -- Acumula valores
            pr_tab_info_seguros(vr_chave_info).qtsegaut := nvl(pr_tab_info_seguros(vr_chave_info).qtsegaut,0) +
						               vr_tot_qtseguro_aut;
            pr_tab_info_seguros(vr_chave_info).vlsegaut := pr_tab_info_seguros(vr_chave_info).vlsegaut +
                           vr_tot_vllanmto_aut;
            pr_tab_info_seguros(vr_chave_info).vlrecaut := nvl(pr_tab_info_seguros(vr_chave_info).vlrecaut,0) +
                           vr_tot_vlreceit_aut;
            pr_tab_info_seguros(vr_chave_info).vlrepaut := pr_tab_info_seguros(vr_chave_info).vlrepaut +
                           vr_tot_vlrepass_aut;
            pr_tab_info_seguros(vr_chave_info).qtsegvid := nvl(pr_tab_info_seguros(vr_chave_info).qtsegvid,0) +
                           vr_tot_qtseguro_vid;
            pr_tab_info_seguros(vr_chave_info).vlsegvid := pr_tab_info_seguros(vr_chave_info).vlsegvid +
                           vr_tot_vllanmto_vid;
            pr_tab_info_seguros(vr_chave_info).vlrecvid := pr_tab_info_seguros(vr_chave_info).vlrecvid +
                           vr_tot_vlreceit_vid;
            pr_tab_info_seguros(vr_chave_info).vlrepvid := pr_tab_info_seguros(vr_chave_info).vlrepvid +
                           vr_tot_vlrepass_vid;
            pr_tab_info_seguros(vr_chave_info).qtsegres := pr_tab_info_seguros(vr_chave_info).qtsegres +
                           vr_tot_qtseguro_res;
            pr_tab_info_seguros(vr_chave_info).vlsegres := pr_tab_info_seguros(vr_chave_info).vlsegres +
                           vr_tot_vllanmto_res;
            pr_tab_info_seguros(vr_chave_info).vlrecres := pr_tab_info_seguros(vr_chave_info).vlrecres +
                           vr_tot_vlreceit_res;
            pr_tab_info_seguros(vr_chave_info).vlrepres := pr_tab_info_seguros(vr_chave_info).vlrepres +
                           vr_tot_vlrepass_res;
          ELSE -- Registro nao existe
            -- Inicializa valores
            pr_tab_info_seguros(vr_chave_info).tpseguro := segu0001.vr_tab_seguro(vr_chave).tpseguro;
            pr_tab_info_seguros(vr_chave_info).cdagenci := segu0001.vr_tab_seguro(vr_chave).cdagenci;            
            pr_tab_info_seguros(vr_chave_info).inpessoa := segu0001.vr_tab_seguro(vr_chave).inpessoa;            
            pr_tab_info_seguros(vr_chave_info).dtrefere := pr_datafim;           
            pr_tab_info_seguros(vr_chave_info).qtsegaut := vr_tot_qtseguro_aut;
            pr_tab_info_seguros(vr_chave_info).vlsegaut := vr_tot_vllanmto_aut;
            pr_tab_info_seguros(vr_chave_info).vlrecaut := vr_tot_vlreceit_aut;
            pr_tab_info_seguros(vr_chave_info).vlrepaut := vr_tot_vlrepass_aut;
            pr_tab_info_seguros(vr_chave_info).qtsegvid := vr_tot_qtseguro_vid;
            pr_tab_info_seguros(vr_chave_info).vlsegvid := vr_tot_vllanmto_vid;
            pr_tab_info_seguros(vr_chave_info).vlrecvid := vr_tot_vlreceit_vid;
            pr_tab_info_seguros(vr_chave_info).vlrepvid := vr_tot_vlrepass_vid;
            pr_tab_info_seguros(vr_chave_info).qtsegres := vr_tot_qtseguro_res;
            pr_tab_info_seguros(vr_chave_info).vlsegres := vr_tot_vllanmto_res;
            pr_tab_info_seguros(vr_chave_info).vlrecres := vr_tot_vlreceit_res;
            pr_tab_info_seguros(vr_chave_info).vlrepres := vr_tot_vlrepass_res;
          END IF; -- FIM da verificacao se registro existe
          
          -- Caso seja seguro de vida
          IF segu0001.vr_tab_seguro(vr_chave).tpseguro = 3 THEN
            -- Chama rotina que contabiliza seguros novos e cancelados
            pc_contabiliza(pr_cdcooper => pr_cdcooper
                          ,pr_tpseguro => 3
                          ,pr_dataini => pr_dataini
                          ,pr_datafim => pr_datafim
                          ,pr_inpessoa => segu0001.vr_tab_seguro(vr_chave).inpessoa
                          ,pr_cdagenci => segu0001.vr_tab_seguro(vr_chave).cdagenci
                          ,pr_qtdnovos => vr_tot_qtdnovos
                          ,pr_qtdcance => vr_tot_qtdcance);
            -- Alimenta a pltable de info seguros com os dados da procedure
            -- Seguros novos 
            pr_tab_info_seguros(vr_chave_info).qtincvid := NVL(pr_tab_info_seguros(vr_chave_info).qtincvid, 0) + 
                                                            vr_tot_qtdnovos;                                      
            -- Seguros cancelados
            pr_tab_info_seguros(vr_chave_info).qtexcvid := NVL(pr_tab_info_seguros(vr_chave_info).qtexcvid, 0) + 
                                                            vr_tot_qtdcance;                                      
          
          END IF;  
          
          -- Caso seja seguro residencial
          IF segu0001.vr_tab_seguro(vr_chave).tpseguro = 1 OR 
           segu0001.vr_tab_seguro(vr_chave).tpseguro = 11 THEN
            -- Chama rotina que contabiliza seguros novos e cancelados
            pc_contabiliza(pr_cdcooper => pr_cdcooper
                          ,pr_tpseguro => 11
                          ,pr_dataini => pr_dataini
                          ,pr_datafim => pr_datafim
                          ,pr_inpessoa => segu0001.vr_tab_seguro(vr_chave).inpessoa
                          ,pr_cdagenci => segu0001.vr_tab_seguro(vr_chave).cdagenci
                          ,pr_qtdnovos => vr_tot_qtdnovos
                          ,pr_qtdcance => vr_tot_qtdcance);
            -- Alimenta a pltable de info seguros com os dados da procedure
            -- Seguros novos 
            pr_tab_info_seguros(vr_chave_info).qtincres := NVL(pr_tab_info_seguros(vr_chave_info).qtincres, 0) + 
                                                            vr_tot_qtdnovos;                                      
                                                            
            -- Seguros cancelados
            pr_tab_info_seguros(vr_chave_info).qtexcres := NVL(pr_tab_info_seguros(vr_chave_info).qtexcres, 0) + 
                                                            vr_tot_qtdcance;                                      
          
          END IF;
          
          -- zera variaveis para proximo PA
          vr_tot_qtseguro_aut := 0;
          vr_tot_vllanmto_aut := 0;
          vr_tot_vlreceit_aut := 0;
          vr_tot_vlrepass_aut := 0;
          vr_tot_qtseguro_res := 0;
          vr_tot_vllanmto_res := 0;
          vr_tot_vlreceit_res := 0;
          vr_tot_vlrepass_res := 0;
          vr_tot_qtseguro_vid := 0;
          vr_tot_vllanmto_vid := 0;
          vr_tot_vlreceit_vid := 0;
          vr_tot_vlrepass_vid := 0;
          vr_tot_qtdnovos     := 0;
          vr_tot_qtdcance     := 0;



        END IF; -- FIM do tratamento para troca do PA na leitura da pltable de seguros

        -- Pega chave do proximo registro
        vr_chave := segu0001.vr_tab_seguro.next(vr_chave);
      END LOOP; -- FIM do Loop para pltable de seguros
      
      -- Retorna ok
      pr_des_reto := 'OK';
      
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_reto := 'NOK';
    END; -- pc_seguros_auto
  END;
  
  --Procedimento para Buscar Associado
  PROCEDURE pc_buscar_associados (pr_cdcooper  IN crapcop.cdcooper%type -- Cooperativa
                                 ,pr_cdagenci  IN crapage.cdagenci%type -- Agencia
                                 ,pr_nrdcaixa  IN INTEGER               -- Numero Caixa
                                 ,pr_cdoperad  IN crapope.cdoperad%type -- Operador
                                 ,pr_dtmvtolt  IN crapdat.dtmvtolt%type -- Data Movimento
                                 ,pr_nrdconta  IN crapass.nrdconta%type -- Numero Conta
                                 ,pr_idseqttl  IN crapttl.idseqttl%type -- Sequencial Titular
                                 ,pr_idorigem  IN INTEGER               -- Origem Informacao
                                 ,pr_nmdatela  IN VARCHAR2              -- Programa Chamador
                                 ,pr_flgerlog  IN BOOLEAN               -- Escrever Erro Log
                                 ,pr_tab_associado OUT typ_tab_associado -- Tabela de Associado
                                 ,pr_des_erro  OUT VARCHAR2             -- Descricao Erro
                                 ,pr_tab_erro  OUT GENE0001.typ_tab_erro) IS -- Tabela Erros
  BEGIN
     ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_buscar_associados                   Antigo: b1wgen0033.p/buscar_associados
  --  Sistema  : 
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido
  --  Data     : Abril/2015.                   Ultima atualizacao: 29/01/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para buscar informacoes do associado
  --
  -- Alteracoes: 29/01/2016 - Alteracao de flginspc para inserasa - Pre-Aprovado fase II.
  --                          (Jaison/Anderson)
  --
  ---------------------------------------------------------------------------------------------------------------
    DECLARE
    
      --Selecionar Associado
      CURSOR cr_crapass (pr_cdcooper IN crapcop.cdcooper%type
                        ,pr_nrdconta IN crapass.nrdconta%type) IS
        SELECT *
        FROM crapass 
        WHERE crapass.cdcooper = pr_cdcooper
        AND   crapass.nrdconta = pr_nrdconta;   
      rw_crapass cr_crapass%rowtype;  
                     
      --Variaveis Locais
      vr_dsorigem VARCHAR2(1000);
      vr_dstransa VARCHAR2(1000);
      vr_nrdrowid ROWID;
      vr_index    PLS_INTEGER;
      
      --Variaveis de Erro
      vr_cdcritic integer;
      vr_dscritic varchar2(4000);
      
      vr_exc_sair EXCEPTION;
      vr_exc_erro EXCEPTION;
      
    BEGIN
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;
      vr_dscritic:= NULL;
      
      --Limpar tabela erros
      pr_tab_erro.DELETE;
      pr_tab_associado.DELETE;
      
      --Descricao da Origem e da Transacao
      vr_dsorigem:= gene0001.vr_vet_des_origens(pr_idorigem);
      vr_dstransa:= 'Buscar Associado.';
      
      --Selecionar Associado
      OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      --Se nao Encontrou
      IF cr_crapass%NOTFOUND THEN
        vr_cdcritic:= 9;
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
      ELSE
        vr_index:= pr_tab_associado.COUNT + 1;
        pr_tab_associado(vr_index).nrmatric:= rw_crapass.nrmatric;
        pr_tab_associado(vr_index).indnivel:= rw_crapass.indnivel;
        pr_tab_associado(vr_index).nrdconta:= rw_crapass.nrdconta;
        pr_tab_associado(vr_index).cdagenci:= rw_crapass.cdagenci;
        pr_tab_associado(vr_index).nrcadast:= rw_crapass.nrcadast;
        pr_tab_associado(vr_index).nmprimtl:= rw_crapass.nmprimtl;
        pr_tab_associado(vr_index).dtnasctl:= rw_crapass.dtnasctl;
        pr_tab_associado(vr_index).dsnacion:= rw_crapass.dsnacion;
        pr_tab_associado(vr_index).dsproftl:= rw_crapass.dsproftl;
        pr_tab_associado(vr_index).dtadmiss:= rw_crapass.dtadmiss;
        pr_tab_associado(vr_index).dtdemiss:= rw_crapass.dtdemiss;
        pr_tab_associado(vr_index).nrcpfcgc:= rw_crapass.nrcpfcgc;
        pr_tab_associado(vr_index).dtultalt:= rw_crapass.dtultalt;
        pr_tab_associado(vr_index).tpdocptl:= rw_crapass.tpdocptl;
        pr_tab_associado(vr_index).nrdocptl:= rw_crapass.nrdocptl;
        pr_tab_associado(vr_index).cdsexotl:= rw_crapass.cdsexotl;
        pr_tab_associado(vr_index).dsfiliac:= rw_crapass.dsfiliac;
        pr_tab_associado(vr_index).dtadmemp:= rw_crapass.dtadmemp;
        pr_tab_associado(vr_index).cdturnos:= rw_crapass.cdturnos;
        pr_tab_associado(vr_index).nrramemp:= rw_crapass.nrramemp;
        pr_tab_associado(vr_index).nrctacto:= rw_crapass.nrctacto;
        pr_tab_associado(vr_index).cdtipsfx:= rw_crapass.cdtipsfx;
        pr_tab_associado(vr_index).cddsenha:= rw_crapass.cddsenha;
        pr_tab_associado(vr_index).cdsecext:= rw_crapass.cdsecext;
        pr_tab_associado(vr_index).cdsitdct:= rw_crapass.cdsitdct;
        pr_tab_associado(vr_index).cdsitdtl:= rw_crapass.cdsitdtl;
        pr_tab_associado(vr_index).cdsrcheq:= rw_crapass.cdsrcheq;
        pr_tab_associado(vr_index).cdtipcta:= rw_crapass.cdtipcta;
        pr_tab_associado(vr_index).dtabtcct:= rw_crapass.dtabtcct;
        pr_tab_associado(vr_index).dtasitct:= rw_crapass.dtasitct;
        pr_tab_associado(vr_index).dtatipct:= rw_crapass.dtatipct;
        pr_tab_associado(vr_index).dtcnsspc:= rw_crapass.dtcnsspc;
        pr_tab_associado(vr_index).dtdsdspc:= rw_crapass.dtdsdspc;
        pr_tab_associado(vr_index).inadimpl:= rw_crapass.inadimpl;
        pr_tab_associado(vr_index).inedvmto:= rw_crapass.inedvmto;
        pr_tab_associado(vr_index).inlbacen:= rw_crapass.inlbacen;
        pr_tab_associado(vr_index).nrflcheq:= rw_crapass.nrflcheq;
        pr_tab_associado(vr_index).qtextmes:= rw_crapass.qtextmes;
        pr_tab_associado(vr_index).vllimcre:= rw_crapass.vllimcre;
        pr_tab_associado(vr_index).dsregcas:= rw_crapass.dsregcas;
        pr_tab_associado(vr_index).nmsegntl:= rw_crapass.nmsegntl;
        pr_tab_associado(vr_index).tpdocstl:= rw_crapass.tpdocstl;
        pr_tab_associado(vr_index).nrdocstl:= rw_crapass.nrdocstl;
        pr_tab_associado(vr_index).cdgraupr:= rw_crapass.cdgraupr;
        pr_tab_associado(vr_index).cddsecao:= rw_crapass.cddsecao;
        pr_tab_associado(vr_index).dtultlcr:= rw_crapass.dtultlcr;
        pr_tab_associado(vr_index).inpessoa:= rw_crapass.inpessoa;
        pr_tab_associado(vr_index).inmatric:= rw_crapass.inmatric;
        pr_tab_associado(vr_index).inisipmf:= rw_crapass.inisipmf;
        pr_tab_associado(vr_index).tplimcre:= rw_crapass.tplimcre;
        pr_tab_associado(vr_index).dtnasstl:= rw_crapass.dtnasstl;
        pr_tab_associado(vr_index).dsfilstl:= rw_crapass.dsfilstl;
        pr_tab_associado(vr_index).nrcpfstl:= rw_crapass.nrcpfstl;
        pr_tab_associado(vr_index).dtelimin:= rw_crapass.dtelimin;
        pr_tab_associado(vr_index).vledvmto:= rw_crapass.vledvmto;
        pr_tab_associado(vr_index).dtedvmto:= rw_crapass.dtedvmto;
        pr_tab_associado(vr_index).qtfolmes:= rw_crapass.qtfolmes;
        pr_tab_associado(vr_index).tpextcta:= rw_crapass.tpextcta;
        pr_tab_associado(vr_index).cdoedptl:= rw_crapass.cdoedptl;
        pr_tab_associado(vr_index).cdoedstl:= rw_crapass.cdoedstl;
        pr_tab_associado(vr_index).cdoedrsp:= rw_crapass.cdoedrsp;
        pr_tab_associado(vr_index).cdufdptl:= rw_crapass.cdufdptl;
        pr_tab_associado(vr_index).cdufdstl:= rw_crapass.cdufdstl;
        pr_tab_associado(vr_index).cdufdrsp:= rw_crapass.cdufdrsp;
        pr_tab_associado(vr_index).nmrespon:= rw_crapass.nmrespon;
        pr_tab_associado(vr_index).inhabmen:= rw_crapass.inhabmen;
        pr_tab_associado(vr_index).nrcpfrsp:= rw_crapass.nrcpfrsp;
        pr_tab_associado(vr_index).nrdocrsp:= rw_crapass.nrdocrsp;
        pr_tab_associado(vr_index).tpdocrsp:= rw_crapass.tpdocrsp;
        pr_tab_associado(vr_index).dtemdstl:= rw_crapass.dtemdstl;
        pr_tab_associado(vr_index).dtemdptl:= rw_crapass.dtemdptl;
        pr_tab_associado(vr_index).dtemdrsp:= rw_crapass.dtemdrsp;
        pr_tab_associado(vr_index).qtdepend:= rw_crapass.qtdepend;
        pr_tab_associado(vr_index).dsendcol:= rw_crapass.dsendcol;
        pr_tab_associado(vr_index).tpavsdeb:= rw_crapass.tpavsdeb;
        pr_tab_associado(vr_index).iniscpmf:= rw_crapass.iniscpmf;
        pr_tab_associado(vr_index).nrctaprp:= rw_crapass.nrctaprp;
        pr_tab_associado(vr_index).cdoedttl:= rw_crapass.cdoedttl;
        pr_tab_associado(vr_index).cdufdttl:= rw_crapass.cdufdttl;
        pr_tab_associado(vr_index).dsfilttl:= rw_crapass.dsfilttl;
        pr_tab_associado(vr_index).dtnasttl:= rw_crapass.dtnasttl;
        pr_tab_associado(vr_index).nmtertl:= rw_crapass.nmtertl;
        pr_tab_associado(vr_index).nrcpfttl:= rw_crapass.nrcpfttl;
        pr_tab_associado(vr_index).nrdocttl:= rw_crapass.nrdocttl;
        pr_tab_associado(vr_index).tpdocttl:= rw_crapass.tpdocttl;
        pr_tab_associado(vr_index).dtemdttl:= rw_crapass.dtemdttl;
        pr_tab_associado(vr_index).tpvincul:= rw_crapass.tpvincul;
        pr_tab_associado(vr_index).nrfonemp:= rw_crapass.nrfonemp;
        pr_tab_associado(vr_index).dtcnscpf:= rw_crapass.dtcnscpf;
        pr_tab_associado(vr_index).cdsitcpf:= rw_crapass.cdsitcpf;
        pr_tab_associado(vr_index).nmpaittl:= rw_crapass.nmpaittl;
        pr_tab_associado(vr_index).nmpaistl:= rw_crapass.nmpaistl;
        pr_tab_associado(vr_index).nmpaiptl:= rw_crapass.nmpaiptl;
        pr_tab_associado(vr_index).nmmaettl:= rw_crapass.nmmaettl;
        pr_tab_associado(vr_index).nmmaestl:= rw_crapass.nmmaestl;
        pr_tab_associado(vr_index).nmmaeptl:= rw_crapass.nmmaeptl;
        pr_tab_associado(vr_index).inccfcop:= rw_crapass.inccfcop;
        pr_tab_associado(vr_index).dtccfcop:= rw_crapass.dtccfcop;
        pr_tab_associado(vr_index).indrisco:= rw_crapass.indrisco;
        pr_tab_associado(vr_index).inarqcbr:= rw_crapass.inarqcbr;
        pr_tab_associado(vr_index).dsdemail:= rw_crapass.dsdemail;
        pr_tab_associado(vr_index).qtfoltal:= rw_crapass.qtfoltal;
        pr_tab_associado(vr_index).nrdctitg:= rw_crapass.nrdctitg;
        pr_tab_associado(vr_index).flchqitg:= rw_crapass.flchqitg;
        pr_tab_associado(vr_index).flgctitg:= rw_crapass.flgctitg;
        pr_tab_associado(vr_index).dtabcitg:= rw_crapass.dtabcitg;
        pr_tab_associado(vr_index).nrctainv:= rw_crapass.nrctainv;
        pr_tab_associado(vr_index).cdoperat:= rw_crapass.cdoperat;
        pr_tab_associado(vr_index).flgatrat:= rw_crapass.flgatrat;
        pr_tab_associado(vr_index).dtaturat:= rw_crapass.dtaturat;
        pr_tab_associado(vr_index).vlutlrat:= rw_crapass.vlutlrat;
        pr_tab_associado(vr_index).flgiddep:= rw_crapass.flgiddep;
        pr_tab_associado(vr_index).dtlimdeb:= rw_crapass.dtlimdeb;
        pr_tab_associado(vr_index).cdcooper:= rw_crapass.cdcooper;
        pr_tab_associado(vr_index).vllimdeb:= rw_crapass.vllimdeb;
        pr_tab_associado(vr_index).cdmotdem:= rw_crapass.cdmotdem;
        pr_tab_associado(vr_index).flgdbitg:= rw_crapass.flgdbitg;
        pr_tab_associado(vr_index).dsnivris:= rw_crapass.dsnivris;
        pr_tab_associado(vr_index).dtectitg:= rw_crapass.dtectitg;
        pr_tab_associado(vr_index).cdopedem:= rw_crapass.cdopedem;
        pr_tab_associado(vr_index).dtmvtolt:= rw_crapass.dtmvtolt;
        pr_tab_associado(vr_index).cdbantrf:= rw_crapass.cdbantrf;
        pr_tab_associado(vr_index).cdagetrf:= rw_crapass.cdagetrf;
        pr_tab_associado(vr_index).nrctatrf:= rw_crapass.nrctatrf;
        pr_tab_associado(vr_index).dtmvcitg:= rw_crapass.dtmvcitg;
        pr_tab_associado(vr_index).dtcnsscr:= rw_crapass.dtcnsscr;
        pr_tab_associado(vr_index).nrcpfppt:= rw_crapass.nrcpfppt;
        pr_tab_associado(vr_index).dtdevqst:= rw_crapass.dtdevqst;
        pr_tab_associado(vr_index).dtentqst:= rw_crapass.dtentqst;
        pr_tab_associado(vr_index).cdbcochq:= rw_crapass.cdbcochq;
        pr_tab_associado(vr_index).dtcadqst:= rw_crapass.dtcadqst;
        pr_tab_associado(vr_index).nrnotatl:= rw_crapass.nrnotatl;
        pr_tab_associado(vr_index).inrisctl:= rw_crapass.inrisctl;
        pr_tab_associado(vr_index).dtrisctl:= rw_crapass.dtrisctl;
        pr_tab_associado(vr_index).flgrestr:= rw_crapass.flgrestr;
        pr_tab_associado(vr_index).nrctacns:= rw_crapass.nrctacns;
        pr_tab_associado(vr_index).progress_recid:= rw_crapass.progress_recid;
        pr_tab_associado(vr_index).nrempcrd:= rw_crapass.nrempcrd;
        pr_tab_associado(vr_index).inserasa:= rw_crapass.inserasa;
        pr_tab_associado(vr_index).flgcrdpa:= rw_crapass.flgcrdpa;
        pr_tab_associado(vr_index).cdoplcpa:= rw_crapass.cdoplcpa;
        pr_tab_associado(vr_index).incadpos:= rw_crapass.incadpos;
        pr_tab_associado(vr_index).flgrenli:= rw_crapass.flgrenli;
        --pr_tab_associado(vr_index).cdempres:= rw_crapass.cdempres;
        --pr_tab_associado(vr_index).qttalmes:= rw_crapass.qttalmes;
        --pr_tab_associado(vr_index).dtaltcrd:= rw_crapass.dtaltcrd;
        --pr_tab_associado(vr_index).tplimcrd:= rw_crapass.tplimcrd;
        --pr_tab_associado(vr_index).vllimcrd:= rw_crapass.vllimcrd;
        --pr_tab_associado(vr_index).dscpfcgc:= rw_crapass.dscpfcgc;
        --pr_tab_associado(vr_index).fllautom:= rw_crapass.fllautom;
        pr_tab_associado(vr_index).nrfonres:= NULL;
  
      END IF;            
      --Fechar Cursor
      CLOSE cr_crapass;
                    
      --Limpar tabela erros
      pr_tab_erro.DELETE;
      
      IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

        --Se for para gerar log
        IF pr_flgerlog THEN

          --Executar rotina geracao log
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => vr_dsorigem
                              ,pr_dstransa => vr_dstransa
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0 /*FALSE*/
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);        
        END IF;
        --Retorno NOK
         pr_des_erro:= 'NOK';   
         RETURN;
      END IF;
                             
      --Se for para gerar log
      IF pr_flgerlog THEN
        --Executar rotina geracao log
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1 /*TRUE*/
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);        
      END IF;
      
      --Retorno OK
      pr_des_erro:= 'OK';   
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro:= 'NOK';
        vr_dscritic:= 'Erro na rotina SEGU0001.pc_buscar_associados. '||sqlerrm;
        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);                
    END;      
  END pc_buscar_associados;                             
                                 
  --Procedimento para Buscar Associado
  PROCEDURE pc_buscar_pessoa_juridica (pr_cdcooper  IN crapcop.cdcooper%type -- Cooperativa
                                      ,pr_cdagenci  IN crapage.cdagenci%type -- Agencia
                                      ,pr_nrdcaixa  IN INTEGER               -- Numero Caixa
                                      ,pr_cdoperad  IN crapope.cdoperad%type -- Operador
                                      ,pr_dtmvtolt  IN crapdat.dtmvtolt%type -- Data Movimento
                                      ,pr_nrdconta  IN crapass.nrdconta%type -- Numero Conta
                                      ,pr_idseqttl  IN crapttl.idseqttl%type -- Sequencial Titular
                                      ,pr_idorigem  IN INTEGER               -- Origem Informacao
                                      ,pr_nmdatela  IN VARCHAR2              -- Programa Chamador
                                      ,pr_flgerlog  IN BOOLEAN               -- Escrever Erro Log
                                      ,pr_reg_crapjur OUT crapjur%rowtype    -- Registro da pessoa Juridica
                                      ,pr_des_erro  OUT VARCHAR2             -- Descricao Erro
                                      ,pr_tab_erro  OUT GENE0001.typ_tab_erro) IS -- Tabela Erros
  BEGIN
     ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_buscar_pessoa_juridica                   Antigo: b1wgen0033.p/buscar_pessoa_juridica
  --  Sistema  : 
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido
  --  Data     : Abril/2015.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para buscar informacoes da pessoa Juridica

  ---------------------------------------------------------------------------------------------------------------
    DECLARE
    
      --Selecionar Associado
      CURSOR cr_crapjur (pr_cdcooper IN crapcop.cdcooper%type
                        ,pr_nrdconta IN crapass.nrdconta%type) IS
        SELECT *
        FROM crapjur 
        WHERE crapjur.cdcooper = pr_cdcooper
        AND   crapjur.nrdconta = pr_nrdconta;                
      --Variaveis Locais
      vr_dsorigem VARCHAR2(1000);
      vr_dstransa VARCHAR2(1000);
      vr_nrdrowid ROWID;
      
      --Variaveis de Erro
      vr_cdcritic integer;
      vr_dscritic varchar2(4000);
      
      vr_exc_sair EXCEPTION;
      vr_exc_erro EXCEPTION;
      
    BEGIN
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;
      vr_dscritic:= NULL;
      
      --Limpar tabela erros
      pr_tab_erro.DELETE;
      
      --Descricao da Origem e da Transacao
      vr_dsorigem:= gene0001.vr_vet_des_origens(pr_idorigem);
      vr_dstransa:= 'Buscar Pessoa Juridica.';
      
      --Selecionar Info. Pessoa Juridica
      OPEN cr_crapjur (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapjur INTO pr_reg_crapjur;
      --Se nao Encontrou
      IF cr_crapjur%NOTFOUND THEN
        vr_cdcritic:= 0;
        vr_dscritic:= 'Cadastro pessoa juridica nao encontrado.';
      END IF;            
      --Fechar Cursor
      CLOSE cr_crapjur;
                    
      --Limpar tabela erros
      pr_tab_erro.DELETE;
      
      IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

        --Se for para gerar log
        IF pr_flgerlog THEN

          --Executar rotina geracao log
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => vr_dsorigem
                              ,pr_dstransa => vr_dstransa
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0 /*FALSE*/
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);        
        END IF;
        --Retorno NOK
         pr_des_erro:= 'NOK';   
         RETURN;
      END IF;
                             
      --Se for para gerar log
      IF pr_flgerlog THEN
        --Executar rotina geracao log
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1 /*TRUE*/
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);        
      END IF;
      
      --Retorno OK
      pr_des_erro:= 'OK';   
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro:= 'NOK';
        vr_dscritic:= 'Erro na rotina SEGU0001.pc_buscar_pessoa_juridica. '||sqlerrm;
        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);                
    END;      
  END pc_buscar_pessoa_juridica;                             

  --Procedimento para Buscar Titular
  PROCEDURE pc_buscar_titular (pr_cdcooper  IN crapcop.cdcooper%type -- Cooperativa
                              ,pr_cdagenci  IN crapage.cdagenci%type -- Agencia
                              ,pr_nrdcaixa  IN INTEGER               -- Numero Caixa
                              ,pr_cdoperad  IN crapope.cdoperad%type -- Operador
                              ,pr_dtmvtolt  IN crapdat.dtmvtolt%type -- Data Movimento
                              ,pr_nrdconta  IN crapass.nrdconta%type -- Numero Conta
                              ,pr_idseqttl  IN crapttl.idseqttl%type -- Sequencial Titular
                              ,pr_idorigem  IN INTEGER               -- Origem Informacao
                              ,pr_nmdatela  IN VARCHAR2              -- Programa Chamador
                              ,pr_flgerlog  IN BOOLEAN               -- Escrever Erro Log
                              ,pr_reg_crapttl OUT crapttl%rowtype    -- Registro do Titular
                              ,pr_des_erro  OUT VARCHAR2             -- Descricao Erro
                              ,pr_tab_erro  OUT GENE0001.typ_tab_erro) IS -- Tabela Erros
  BEGIN
     ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_buscar_titular                   Antigo: b1wgen0033.p/buscar_titular
  --  Sistema  : 
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido
  --  Data     : Abril/2015.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para buscar informacoes do titular

  ---------------------------------------------------------------------------------------------------------------
    DECLARE
    
      --Selecionar Titular
      CURSOR cr_crapttl (pr_cdcooper IN crapcop.cdcooper%type
                        ,pr_nrdconta IN crapass.nrdconta%type
                        ,pr_idseqttl IN crapttl.idseqttl%type) IS
        SELECT *
        FROM crapttl 
        WHERE crapttl.cdcooper = pr_cdcooper
        AND   crapttl.nrdconta = pr_nrdconta
        AND   crapttl.idseqttl = pr_idseqttl;  
                      
      --Variaveis Locais
      vr_dsorigem VARCHAR2(1000);
      vr_dstransa VARCHAR2(1000);
      vr_nrdrowid ROWID;
      
      --Variaveis de Erro
      vr_cdcritic integer;
      vr_dscritic varchar2(4000);
      
      vr_exc_sair EXCEPTION;
      vr_exc_erro EXCEPTION;
      
    BEGIN
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;
      vr_dscritic:= NULL;
      
      --Limpar tabela erros
      pr_tab_erro.DELETE;
      
      --Descricao da Origem e da Transacao
      vr_dsorigem:= gene0001.vr_vet_des_origens(pr_idorigem);
      vr_dstransa:= 'Buscar Titular.';
      
      --Selecionar Titular
      OPEN cr_crapttl (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_idseqttl => pr_idseqttl);
      FETCH cr_crapttl INTO pr_reg_crapttl;
      --Se nao Encontrou
      IF cr_crapttl%NOTFOUND THEN
        vr_cdcritic:= 0;
        vr_dscritic:= 'Titular nao encontrado.';
      END IF;            
      --Fechar Cursor
      CLOSE cr_crapttl;
                    
      --Limpar tabela erros
      pr_tab_erro.DELETE;
      
      IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

        --Se for para gerar log
        IF pr_flgerlog THEN

          --Executar rotina geracao log
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => vr_dsorigem
                              ,pr_dstransa => vr_dstransa
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0 /*FALSE*/
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);        
        END IF;
        --Retorno NOK
         pr_des_erro:= 'NOK';   
         RETURN;
      END IF;
                             
      --Se for para gerar log
      IF pr_flgerlog THEN
        --Executar rotina geracao log
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1 /*TRUE*/
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);        
      END IF;
      
      --Retorno OK
      pr_des_erro:= 'OK';   
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro:= 'NOK';
        vr_dscritic:= 'Erro na rotina SEGU0001.pc_buscar_titular. '||sqlerrm;
        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);                
    END;      
  END pc_buscar_titular;                             

  --Procedimento para Buscar Empresa
  PROCEDURE pc_buscar_empresa (pr_cdcooper  IN crapcop.cdcooper%type -- Cooperativa
                              ,pr_cdagenci  IN crapage.cdagenci%type -- Agencia
                              ,pr_nrdcaixa  IN INTEGER               -- Numero Caixa
                              ,pr_cdoperad  IN crapope.cdoperad%type -- Operador
                              ,pr_dtmvtolt  IN crapdat.dtmvtolt%type -- Data Movimento
                              ,pr_nrdconta  IN crapass.nrdconta%type -- Numero Conta
                              ,pr_idseqttl  IN crapttl.idseqttl%type -- Sequencial Titular
                              ,pr_idorigem  IN INTEGER               -- Origem Informacao
                              ,pr_nmdatela  IN VARCHAR2              -- Programa Chamador
                              ,pr_flgerlog  IN BOOLEAN               -- Escrever Erro Log
                              ,pr_cdempres  IN crapemp.cdempres%type -- Codigo Empresa
                              ,pr_reg_crapemp OUT crapemp%rowtype    -- Registro da Empresa
                              ,pr_des_erro  OUT VARCHAR2             -- Descricao Erro
                              ,pr_tab_erro  OUT GENE0001.typ_tab_erro) IS -- Tabela Erros
  BEGIN
     ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_buscar_empresa                   Antigo: b1wgen0033.p/buscar_empresa
  --  Sistema  : 
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido
  --  Data     : Abril/2015.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para buscar informacoes da empresa

  ---------------------------------------------------------------------------------------------------------------
    DECLARE
    
      --Selecionar Titular
      CURSOR cr_crapemp (pr_cdcooper IN crapcop.cdcooper%type
                        ,pr_cdempres IN crapemp.cdempres%type) IS
        SELECT *
        FROM crapemp 
        WHERE crapemp.cdcooper = pr_cdcooper
        AND   crapemp.cdempres = pr_cdempres;  
                      
      --Variaveis Locais
      vr_dsorigem VARCHAR2(1000);
      vr_dstransa VARCHAR2(1000);
      vr_nrdrowid ROWID;
      
      --Variaveis de Erro
      vr_cdcritic integer;
      vr_dscritic varchar2(4000);
      
      vr_exc_sair EXCEPTION;
      vr_exc_erro EXCEPTION;
      
    BEGIN
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;
      vr_dscritic:= NULL;
      
      --Limpar tabela erros
      pr_tab_erro.DELETE;
      
      --Descricao da Origem e da Transacao
      vr_dsorigem:= gene0001.vr_vet_des_origens(pr_idorigem);
      vr_dstransa:= 'Buscar Empresa.';
      
      --Selecionar Empresa
      OPEN cr_crapemp (pr_cdcooper => pr_cdcooper
                      ,pr_cdempres => pr_cdempres);
      FETCH cr_crapemp INTO pr_reg_crapemp;
      --Se nao Encontrou
      IF cr_crapemp%NOTFOUND THEN
        vr_cdcritic:= 40;
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
      END IF;            
      --Fechar Cursor
      CLOSE cr_crapemp;
                    
      --Limpar tabela erros
      pr_tab_erro.DELETE;
      
      IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

        --Se for para gerar log
        IF pr_flgerlog THEN

          --Executar rotina geracao log
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => vr_dsorigem
                              ,pr_dstransa => vr_dstransa
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0 /*FALSE*/
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);        
        END IF;
        --Retorno NOK
         pr_des_erro:= 'NOK';   
         RETURN;
      END IF;
                             
      --Se for para gerar log
      IF pr_flgerlog THEN
        --Executar rotina geracao log
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1 /*TRUE*/
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);        
      END IF;
      
      --Retorno OK
      pr_des_erro:= 'OK';   
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro:= 'NOK';
        vr_dscritic:= 'Erro na rotina SEGU0001.pc_buscar_empresa. '||sqlerrm;
        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);                
    END;      
  END pc_buscar_empresa;                             

  
  --Procedimento para Buscar Empresa
  PROCEDURE pc_buscar_plano_seguro (pr_cdcooper  IN crapcop.cdcooper%type -- Cooperativa
                                   ,pr_cdagenci  IN crapage.cdagenci%type -- Agencia
                                   ,pr_nrdcaixa  IN INTEGER               -- Numero Caixa
                                   ,pr_cdoperad  IN crapope.cdoperad%type -- Operador
                                   ,pr_dtmvtolt  IN crapdat.dtmvtolt%type -- Data Movimento
                                   ,pr_nrdconta  IN crapass.nrdconta%type -- Numero Conta
                                   ,pr_idseqttl  IN crapttl.idseqttl%type -- Sequencial Titular
                                   ,pr_idorigem  IN INTEGER               -- Origem Informacao
                                   ,pr_nmdatela  IN VARCHAR2              -- Programa Chamador
                                   ,pr_flgerlog  IN BOOLEAN               -- Escrever Erro Log
                                   ,pr_cdsegura  IN crapseg.cdsegura%type -- Codigo Seguradora
                                   ,pr_tpseguro  IN craptsg.tpseguro%type -- Tipo Seguro
                                   ,pr_tpplaseg  IN craptsg.tpplaseg%type -- Tipo Plano Seguro
                                   ,pr_tab_plano_seg OUT typ_tab_plano_seg  -- Tabela Planos Seguro
                                   ,pr_des_erro  OUT VARCHAR2               -- Descricao Erro
                                   ,pr_tab_erro  OUT GENE0001.typ_tab_erro) IS -- Tabela Erros
  BEGIN
     ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_buscar_plano_seguro                   Antigo: b1wgen0033.p/buscar_plano_seguro
  --  Sistema  : 
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido
  --  Data     : Abril/2015.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para buscar informacoes dos planos seguro

  ---------------------------------------------------------------------------------------------------------------
    DECLARE
    
      --Selecionar Titular
      CURSOR cr_craptsg (pr_cdcooper IN crapcop.cdcooper%type
                        ,pr_cdsegura IN crapseg.cdsegura%type
                        ,pr_tpseguro IN craptsg.tpseguro%type
                        ,pr_tpplaseg IN craptsg.tpplaseg%type) IS
        SELECT *
        FROM craptsg 
        WHERE craptsg.cdcooper = pr_cdcooper
        AND  (nvl(pr_cdsegura,0) = 0 OR craptsg.cdsegura = pr_cdsegura) 
        AND  (nvl(pr_tpseguro,0) = 0 OR craptsg.tpseguro = pr_tpseguro) 
        AND  (nvl(pr_tpplaseg,0) = 0 OR craptsg.tpplaseg = pr_tpplaseg);  
                      
      --Variaveis Locais
      vr_dsorigem VARCHAR2(1000);
      vr_dstransa VARCHAR2(1000);
      vr_nrdrowid ROWID;
      vr_index    PLS_INTEGER;
      
      --Variaveis de Erro
      vr_cdcritic integer;
      vr_dscritic varchar2(4000);
      
      vr_exc_sair EXCEPTION;
      vr_exc_erro EXCEPTION;
      
    BEGIN
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;
      vr_dscritic:= NULL;
      
      --Limpar tabela erros
      pr_tab_erro.DELETE;
      pr_tab_plano_seg.DELETE;
      
      --Descricao da Origem e da Transacao
      vr_dsorigem:= gene0001.vr_vet_des_origens(pr_idorigem);
      vr_dstransa:= 'Buscar Plano Seguro.';
      
      --Selecionar Plano Seguro
      FOR rw_craptsg IN cr_craptsg (pr_cdcooper => pr_cdcooper
                                   ,pr_cdsegura => pr_cdsegura
                                   ,pr_tpseguro => pr_tpseguro
                                   ,pr_tpplaseg => pr_tpplaseg) LOOP
        --Proximo Registro
        vr_index:= pr_tab_plano_seg.COUNT + 1;                           
        pr_tab_plano_seg(vr_index).tpseguro:= rw_craptsg.tpseguro;
        pr_tab_plano_seg(vr_index).tpplaseg:= rw_craptsg.tpplaseg;
        pr_tab_plano_seg(vr_index).vlplaseg:= rw_craptsg.vlplaseg;
        pr_tab_plano_seg(vr_index).dsocupac:= rw_craptsg.dsocupac;
        pr_tab_plano_seg(vr_index).dsgarant:= rw_craptsg.dsgarant;
        pr_tab_plano_seg(vr_index).nrtabela:= rw_craptsg.nrtabela;
        pr_tab_plano_seg(vr_index).dsmorada:= rw_craptsg.dsmorada;
        pr_tab_plano_seg(vr_index).cdsitpsg:= rw_craptsg.cdsitpsg;
        pr_tab_plano_seg(vr_index).inplaseg:= rw_craptsg.inplaseg;
        pr_tab_plano_seg(vr_index).vlmorada:= rw_craptsg.vlmorada;
        pr_tab_plano_seg(vr_index).cdsegura:= rw_craptsg.cdsegura;
        pr_tab_plano_seg(vr_index).flgunica:= rw_craptsg.flgunica;
        pr_tab_plano_seg(vr_index).cdcooper:= rw_craptsg.cdcooper;
        pr_tab_plano_seg(vr_index).dddcorte:= rw_craptsg.dddcorte;
        pr_tab_plano_seg(vr_index).mmpripag:= rw_craptsg.mmpripag;
        pr_tab_plano_seg(vr_index).ddcancel:= rw_craptsg.ddcancel;
        pr_tab_plano_seg(vr_index).qtdiacar:= rw_craptsg.qtdiacar;
        pr_tab_plano_seg(vr_index).ddmaxpag:= rw_craptsg.ddmaxpag;
        pr_tab_plano_seg(vr_index).qtmaxpar:= rw_craptsg.qtmaxpar;
      END LOOP;
      
      --Se nao Encontrou Plano                             
      IF pr_tab_plano_seg.COUNT = 0 THEN
        vr_cdcritic:= 200;
      END IF;            
                    
      --Limpar tabela erros
      pr_tab_erro.DELETE;
      
      IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

        --Se for para gerar log
        IF pr_flgerlog THEN

          --Executar rotina geracao log
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => vr_dsorigem
                              ,pr_dstransa => vr_dstransa
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0 /*FALSE*/
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);        
        END IF;
        --Retorno NOK
         pr_des_erro:= 'NOK';   
         RETURN;
      END IF;
                             
      --Se for para gerar log
      IF pr_flgerlog THEN
        --Executar rotina geracao log
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1 /*TRUE*/
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);        
      END IF;
      
      --Retorno OK
      pr_des_erro:= 'OK';   
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro:= 'NOK';
        vr_dscritic:= 'Erro na rotina SEGU0001.pc_buscar_plano_seguro. '||sqlerrm;
        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);                
    END;      
  END pc_buscar_plano_seguro;                             

  --Procedimento para Buscar Seguradora
  PROCEDURE pc_buscar_seguradora (pr_cdcooper  IN crapcop.cdcooper%type -- Cooperativa
                                 ,pr_cdagenci  IN crapage.cdagenci%type -- Agencia
                                 ,pr_nrdcaixa  IN INTEGER               -- Numero Caixa
                                 ,pr_cdoperad  IN crapope.cdoperad%type -- Operador
                                 ,pr_dtmvtolt  IN crapdat.dtmvtolt%type -- Data Movimento
                                 ,pr_nrdconta  IN crapass.nrdconta%type -- Numero Conta
                                 ,pr_idseqttl  IN crapttl.idseqttl%type -- Sequencial Titular
                                 ,pr_idorigem  IN INTEGER               -- Origem Informacao
                                 ,pr_nmdatela  IN VARCHAR2              -- Programa Chamador
                                 ,pr_flgerlog  IN BOOLEAN               -- Escrever Erro Log
                                 ,pr_tpseguro  IN craptsg.tpseguro%type -- Tipo Seguro
                                 ,pr_cdsitpsg  IN craptsg.cdsitpsg%type -- Situacao Seguro
                                 ,pr_cdsegura  IN craptsg.cdsegura%type -- Codigo Seguradora
                                 ,pr_nmsegura  IN crapcsg.nmsegura%type -- Nome Seguradora
                                 ,pr_qtregist  OUT PLS_INTEGER          -- Quantidade Registros
                                 ,pr_tab_seguradora OUT typ_tab_seguradora  -- Tabela da Seguradora
                                 ,pr_des_erro  OUT VARCHAR2             -- Descricao Erro
                                 ,pr_tab_erro  OUT GENE0001.typ_tab_erro) IS -- Tabela Erros
  BEGIN
     ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_buscar_seguradora                   Antigo: b1wgen0033.p/buscar_seguradora
  --  Sistema  : 
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido
  --  Data     : Abril/2015.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para buscar informacoes da seguradora

  ---------------------------------------------------------------------------------------------------------------
    DECLARE
    
      --Selecionar Seguradoras
      CURSOR cr_crapcsg (pr_cdcooper IN crapcsg.cdcooper%type
                        ,pr_cdsegura IN crapcsg.cdsegura%type
                        ,pr_nmsegura IN crapcsg.nmsegura%type) IS
        SELECT *
        FROM crapcsg 
        WHERE crapcsg.cdcooper = pr_cdcooper
        AND (nvl(pr_cdsegura,0) = 0 OR crapcsg.cdsegura = pr_cdsegura) 
        AND (pr_nmsegura IS NULL OR instr(upper(nmsegura),upper(pr_nmsegura)) > 0);  
               
      --Selecionar Planos de Seguros
      CURSOR cr_craptsg (pr_cdcooper IN craptsg.cdcooper%type
                        ,pr_cdsegura IN craptsg.cdsegura%type
                        ,pr_tpseguro IN craptsg.tpseguro%type
                        ,pr_cdsitpsg IN craptsg.cdsitpsg%type) IS
        SELECT craptsg.flgunica
              ,craptsg.vlplaseg
              ,craptsg.vlmorada                  
        FROM craptsg
        WHERE craptsg.cdcooper = pr_cdcooper 
        AND   craptsg.cdsegura = pr_cdsegura 
        AND  (nvl(pr_tpseguro,0) = 0 OR craptsg.tpseguro = nvl(pr_tpseguro,0)) 
        AND  (nvl(pr_cdsitpsg,0) = 0 OR craptsg.cdsitpsg = nvl(pr_cdsitpsg,0));       
      rw_craptsg cr_craptsg%rowtype;
        
      --Tabela de Registro da Cooperativa
      rw_crabcop cr_crapcop%ROWTYPE;
      
      --Variaveis Locais
      vr_dsorigem VARCHAR2(1000);
      vr_dstransa VARCHAR2(1000);
      vr_nrdrowid ROWID;
      vr_index    PLS_INTEGER;
      
      --Variaveis de Erro
      vr_cdcritic integer;
      vr_dscritic varchar2(4000);
      
      vr_exc_sair EXCEPTION;
      vr_exc_erro EXCEPTION;
      
    BEGIN
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;
      vr_dscritic:= NULL;
      
      --Limpar tabela erros
      pr_tab_erro.DELETE;
      pr_tab_seguradora.DELETE;
      
      --Descricao da Origem e da Transacao
      vr_dsorigem:= gene0001.vr_vet_des_origens(pr_idorigem);
      vr_dstransa:= 'Buscar Seguradora.';
      
      --Selecionar Cooperativa
      OPEN cr_crapcop (pr_cdcooper => 3);
      FETCH cr_crapcop INTO rw_crapcop;
      --Se nao Encontrou
      IF cr_crapcop%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcop;
        vr_cdcritic:= 1;
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;            
      --Fechar Cursor
      CLOSE cr_crapcop;
      
      --Selecionar Cooperativa
      OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crabcop;
      --Se nao Encontrou
      IF cr_crapcop%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcop;
        vr_cdcritic:= 1;
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;            
      --Fechar Cursor
      CLOSE cr_crapcop;
                    
      --Percorrer as Seguradoras
      FOR rw_crapcsg IN cr_crapcsg (pr_cdcooper => pr_cdcooper
                                   ,pr_cdsegura => pr_cdsegura
                                   ,pr_nmsegura => pr_nmsegura) LOOP
        IF rw_crapcsg.flgativo = 0 THEN
          CONTINUE;
        END IF; 
        
        --Tipo de Seguradora
        IF nvl(pr_tpseguro,0) <> 0 OR nvl(pr_cdsitpsg,0) <> 0 THEN
          --Selecionar Planos de Seguros
          OPEN cr_craptsg (pr_cdcooper => pr_cdcooper
                          ,pr_cdsegura => rw_crapcsg.cdsegura
                          ,pr_tpseguro => pr_tpseguro
                          ,pr_cdsitpsg => pr_cdsitpsg);
          FETCH cr_craptsg INTO rw_craptsg;
          --Se nao encontrou
          IF cr_craptsg%NOTFOUND THEN
            --Fechar Cursor
            CLOSE cr_craptsg;
            --Proximo registro
            CONTINUE;
          ELSE
            --Fechar Cursor
            CLOSE cr_craptsg;
          END IF;  
        END IF;
          
        --Incrementar qdade registros
        pr_qtregist:= nvl(pr_qtregist,0) + 1; 
        
        --Criar Registro Seguradora
        vr_index:= pr_tab_seguradora.COUNT + 1;
        pr_tab_seguradora(vr_index).cdsegura:= rw_crapcsg.cdsegura;
        pr_tab_seguradora(vr_index).nmsegura:= rw_crapcsg.nmsegura;
        pr_tab_seguradora(vr_index).nmresseg:= rw_crapcsg.nmresseg;
        pr_tab_seguradora(vr_index).cdcooper:= rw_crapcsg.cdcooper;
        pr_tab_seguradora(vr_index).nrlimprc:= rw_crapcsg.nrlimprc;
        pr_tab_seguradora(vr_index).nrultprc:= rw_crapcsg.nrultprc;
        pr_tab_seguradora(vr_index).nrcgcseg:= rw_crapcsg.nrcgcseg;
        pr_tab_seguradora(vr_index).nmrescec:= rw_crapcop.nmextcop;
        pr_tab_seguradora(vr_index).nmrescop:= rw_crabcop.nmrescop;
      END LOOP;
        
      --Se nao encontrou nenhuma seguradora
      IF pr_tab_seguradora.COUNT = 0 THEN
        --Erro
        vr_cdcritic:= 556;
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
        
      --Limpar tabela erros
      pr_tab_erro.DELETE;
      
      IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

        --Se for para gerar log
        IF pr_flgerlog THEN

          --Executar rotina geracao log
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => vr_dsorigem
                              ,pr_dstransa => vr_dstransa
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0 /*FALSE*/
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);        
        END IF;
        --Retorno NOK
         pr_des_erro:= 'NOK';   
         RETURN;
      END IF;
                             
      --Se for para gerar log
      IF pr_flgerlog THEN
        --Executar rotina geracao log
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1 /*TRUE*/
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);        
      END IF;
      
      --Retorno OK
      pr_des_erro:= 'OK';   
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_des_erro:= 'NOK';
        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);                
        
      WHEN OTHERS THEN
        pr_des_erro:= 'NOK';
        vr_dscritic:= 'Erro na rotina SEGU0001.pc_buscar_seguradora. '||sqlerrm;
        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);                
    END;      
  END pc_buscar_seguradora;                             

  --Procedimento para Buscar Motivo Cancelamento
  PROCEDURE pc_buscar_motivo_can (pr_cdcooper  IN crapcop.cdcooper%type -- Cooperativa
                                 ,pr_cdagenci  IN crapage.cdagenci%type -- Agencia
                                 ,pr_nrdcaixa  IN INTEGER               -- Numero Caixa
                                 ,pr_cdoperad  IN crapope.cdoperad%type -- Operador
                                 ,pr_dtmvtolt  IN crapdat.dtmvtolt%type -- Data Movimento
                                 ,pr_nrdconta  IN crapass.nrdconta%type -- Numero Conta
                                 ,pr_idseqttl  IN crapttl.idseqttl%type -- Sequencial Titular
                                 ,pr_idorigem  IN INTEGER               -- Origem Informacao
                                 ,pr_nmdatela  IN VARCHAR2              -- Programa Chamador
                                 ,pr_flgerlog  IN BOOLEAN               -- Escrever Erro Log
                                 ,pr_cdmotcan  IN INTEGER               -- Codigo Motivo
                                 ,pr_dsmotcan  IN VARCHAR2              -- Descricao Motivo
                                 ,pr_qtregist  OUT PLS_INTEGER          -- Quantidade Motivos
                                 ,pr_tab_mot_can OUT typ_tab_mot_can    -- Tabela Motivos Cancelamentos
                                 ,pr_des_erro  OUT VARCHAR2             -- Descricao Erro
                                 ,pr_tab_erro  OUT GENE0001.typ_tab_erro) IS -- Tabela Erros
  BEGIN
     ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_buscar_motivo_can                   Antigo: b1wgen0033.p/buscar_motivo_can
  --  Sistema  : 
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido
  --  Data     : Abril/2015.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para buscar motivos de cancelamento

  ---------------------------------------------------------------------------------------------------------------
    DECLARE
    
      -- Vetor Local
      TYPE typ_mot_can IS VARRAY(9) OF VARCHAR2(100);
      vr_mot_can typ_mot_can:= typ_mot_can('Nao Interesse pelo Seguro'
                                          ,'Desligamento da Empresa (Estipulante)'
                                          ,'Falecimento'
                                          ,'Outros'
                                          ,'Alteracao de endereco'
                                          ,'Alteracao de plano'
                                          ,'Venda do imovel'
                                          ,'Insuficiencia de saldo'
                                          ,'Encerramento de conta');
      --Variaveis Locais
      vr_dsorigem VARCHAR2(1000);
      vr_dstransa VARCHAR2(1000);
      vr_nrdrowid ROWID;
      
      --Variaveis de Erro
      vr_cdcritic integer;
      vr_dscritic varchar2(4000);
      
      vr_exc_sair EXCEPTION;
      vr_exc_erro EXCEPTION;
      
    BEGIN
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;
      vr_dscritic:= NULL;
      
      --Limpar tabela erros
      pr_tab_erro.DELETE;
      pr_tab_mot_can.DELETE;
      
      BEGIN
        
        IF nvl(pr_cdmotcan,0) > 9 THEN
          vr_dscritic:= 'Motivo nao cadastrado';
          --Sair  
          RAISE vr_exc_sair;
        END IF;
        --Retornar total motivos
        pr_qtregist:= 9;
        
        --Adicionar todos os motivos
        FOR idx IN 1..vr_mot_can.COUNT() LOOP
          pr_tab_mot_can(idx).cdmotcan:= idx;
          pr_tab_mot_can(idx).dsmotcan:= vr_mot_can(idx);
        END LOOP; 
         
        --Foi informado Codigo Motivo
        IF nvl(pr_cdmotcan,0) <> 0 THEN
          FOR idx IN 1..pr_tab_mot_can.COUNT() LOOP 
            IF pr_cdmotcan <> idx THEN
              --Retornar Quantidade Motivos
              pr_qtregist:= pr_qtregist - 1;
              pr_tab_mot_can.DELETE(idx);
            END IF;
          END LOOP;    
        END IF;
      EXCEPTION
        WHEN vr_exc_sair THEN
          NULL;
      END;
          
      --Descricao do motivo foi informada
      IF pr_dsmotcan IS NOT NULL AND nvl(pr_cdmotcan,0) = 0 THEN
        FOR idx IN 1..pr_tab_mot_can.COUNT() LOOP
          --Se possuir o texto
          IF instr(upper(pr_tab_mot_can(idx).dsmotcan),upper(pr_dsmotcan)) > 0 THEN
            --Retornar Quantidade Motivos
            pr_qtregist:= pr_qtregist - 1;
            pr_tab_mot_can.DELETE(idx);
          END IF;  
        END LOOP;  
      END IF;  

      --Descricao da Origem e da Transacao
      vr_dsorigem:= gene0001.vr_vet_des_origens(pr_idorigem);
      vr_dstransa:= 'Buscar Motivos Cancelamento.';
      
      --Limpar tabela erros
      pr_tab_erro.DELETE;
      
      IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

        --Se for para gerar log
        IF pr_flgerlog THEN

          --Executar rotina geracao log
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => vr_dsorigem
                              ,pr_dstransa => vr_dstransa
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0 /*FALSE*/
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);        
        END IF;
        --Retorno NOK
         pr_des_erro:= 'NOK';   
         RETURN;
      END IF;
                             
      --Se for para gerar log
      IF pr_flgerlog THEN
        --Executar rotina geracao log
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1 /*TRUE*/
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);        
      END IF;
      
      --Retorno OK
      pr_des_erro:= 'OK';   
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro:= 'NOK';
        vr_dscritic:= 'Erro na rotina SEGU0001.pc_buscar_motivo_can. '||sqlerrm;
        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);                
    END;      
  END pc_buscar_motivo_can;                             

  --Procedimento para Buscar Seguros
  PROCEDURE pc_buscar_seguros (pr_cdcooper  IN crapcop.cdcooper%type -- Cooperativa
                              ,pr_cdagenci  IN crapage.cdagenci%type -- Agencia
                              ,pr_nrdcaixa  IN INTEGER               -- Numero Caixa
                              ,pr_cdoperad  IN crapope.cdoperad%type -- Operador
                              ,pr_dtmvtolt  IN crapdat.dtmvtolt%type -- Data Movimento
                              ,pr_nrdconta  IN crapass.nrdconta%type -- Numero Conta
                              ,pr_idseqttl  IN crapttl.idseqttl%type -- Sequencial Titular
                              ,pr_idorigem  IN INTEGER               -- Origem Informacao
                              ,pr_nmdatela  IN VARCHAR2              -- Programa Chamador
                              ,pr_flgerlog  IN BOOLEAN               -- Escrever Erro Log
                              ,pr_cdempres  IN crapemp.cdempres%type -- Codigo Empresa
                              ,pr_tab_seguros OUT segu0001.typ_tab_seguros -- Tabela de Seguros
                              ,pr_qtsegass  OUT INTEGER              -- Qdade Seguros Associado
                              ,pr_vltotseg  OUT NUMBER               -- Valor Total Segurado
                              ,pr_des_erro  OUT VARCHAR2             -- Descricao Erro
                              ,pr_tab_erro  OUT GENE0001.typ_tab_erro) IS -- Tabela Erros
  BEGIN
     ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_buscar_seguros                   Antigo: b1wgen0033.p/buscar_seguros
  --  Sistema  : 
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido
  --  Data     : Abril/2015.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para buscar informacoes dos seguros

  ---------------------------------------------------------------------------------------------------------------
    DECLARE
    
      -- Tabela de Motivos
      vr_tab_mot_can segu0001.typ_tab_mot_can;
      
      
      --Selecionar Seguros
      CURSOR cr_crapseg (pr_cdcooper IN crapcop.cdcooper%type
                        ,pr_nrdconta IN crapseg.nrdconta%type) IS
        SELECT crapseg.*
              ,crapseg.rowid
        FROM crapseg
        WHERE crapseg.cdcooper = pr_cdcooper
        AND   crapseg.nrdconta = pr_nrdconta;  
                      
      --Selecionar Seguros
      CURSOR cr_crapseg_coop (pr_cdcooper IN crapcop.cdcooper%type) IS
        SELECT crapseg.*
              ,crapseg.rowid
        FROM crapseg
        WHERE crapseg.cdcooper = pr_cdcooper;  

      -- Selecionar Informacoes Contrato Vida
      CURSOR cr_crawseg (pr_cdcooper IN crapseg.cdcooper%type
                        ,pr_nrdconta IN crapseg.nrdconta%type
                        ,pr_nrctrseg IN crapseg.nrctrseg%type) IS
        SELECT crawseg.vlseguro
              ,crawseg.dtfimvig
              ,crawseg.tpplaseg
              ,crawseg.nmdsegur
        FROM crawseg 
        WHERE crawseg.cdcooper = pr_cdcooper  
        AND   crawseg.nrdconta = pr_nrdconta
        AND   crawseg.nrctrseg = pr_nrctrseg;
      rw_crawseg cr_crawseg%ROWTYPE;
          
      --Variaveis Locais
      vr_dsorigem  VARCHAR2(1000);
      vr_dstransa  VARCHAR2(1000);
      vr_nrdrowid  ROWID;
      vr_qtmotcan  NUMBER;
      vr_index     PLS_INTEGER;
      vr_index_mot PLS_INTEGER;
      
      --Variaveis de Erro
      vr_cdcritic  integer;
      vr_dscritic   varchar2(4000);
      vr_des_erro varchar2(3);
      
      vr_exc_sair  EXCEPTION;
      vr_exc_erro  EXCEPTION;
      
    BEGIN
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;
      vr_dscritic:= NULL;
      pr_qtsegass:= 0;
      pr_vltotseg:= 0;
      
      --Limpar tabelas 
      pr_tab_erro.DELETE;
      pr_tab_seguros.DELETE;
      
      --Descricao da Origem e da Transacao
      vr_dsorigem:= gene0001.vr_vet_des_origens(pr_idorigem);
      vr_dstransa:= 'Listar seguros.';
      
      --Conta foi informada
      IF nvl(pr_nrdconta,0) <> 0 THEN
        --Listar Seguros
        FOR rw_crapseg IN cr_crapseg (pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta) LOOP
          IF (rw_crapseg.cdsitseg = 2 AND rw_crapseg.dtcancel < (pr_dtmvtolt - 365)) OR
             (rw_crapseg.cdsitseg = 4 AND rw_crapseg.dtfimvig < (pr_dtmvtolt - 365)) THEN
            --Proximo Registro 
            CONTINUE;
          END IF; 
          --Inserir Linha tabela seguros
          vr_index:= pr_tab_seguros.COUNT + 1;
          pr_tab_seguros(vr_index).cdcooper:= rw_crapseg.cdcooper;
          pr_tab_seguros(vr_index).cdagenci:= rw_crapseg.cdagenci;
          pr_tab_seguros(vr_index).dtcancel:= rw_crapseg.dtcancel;
          pr_tab_seguros(vr_index).cdmotcan:= rw_crapseg.cdmotcan;
          pr_tab_seguros(vr_index).nrdconta:= rw_crapseg.nrdconta;
          pr_tab_seguros(vr_index).tpendcor:= rw_crapseg.tpendcor;
          pr_tab_seguros(vr_index).dtiniseg:= rw_crapseg.dtiniseg;
          pr_tab_seguros(vr_index).cdsegura:= rw_crapseg.cdsegura;
          pr_tab_seguros(vr_index).flgclabe:= rw_crapseg.flgclabe;
          pr_tab_seguros(vr_index).nrctrseg:= rw_crapseg.nrctrseg;
          pr_tab_seguros(vr_index).tpplaseg:= rw_crapseg.tpplaseg;
          pr_tab_seguros(vr_index).dtprideb:= rw_crapseg.dtprideb;
          pr_tab_seguros(vr_index).dtdebito:= rw_crapseg.dtdebito;
          pr_tab_seguros(vr_index).tpseguro:= rw_crapseg.tpseguro;
          pr_tab_seguros(vr_index).cdsitseg:= rw_crapseg.cdsitseg;
          pr_tab_seguros(vr_index).nrseqdig:= rw_crapseg.nrseqdig;
          pr_tab_seguros(vr_index).nrdolote:= rw_crapseg.nrdolote;
          pr_tab_seguros(vr_index).cdbccxlt:= rw_crapseg.cdbccxlt;
          pr_tab_seguros(vr_index).nrseqdig:= rw_crapseg.nrseqdig; 
          
          CASE rw_crapseg.tpseguro
            WHEN 1 THEN pr_tab_seguros(vr_index).dsseguro:= 'CASA';
            WHEN 11 THEN pr_tab_seguros(vr_index).dsseguro:= 'CASA';
            WHEN 2 THEN pr_tab_seguros(vr_index).dsseguro:= 'AUTO';
            WHEN 3 THEN pr_tab_seguros(vr_index).dsseguro:= 'VIDA';
            WHEN 4 THEN pr_tab_seguros(vr_index).dsseguro:= 'PRST';
            ELSE pr_tab_seguros(vr_index).dsseguro:= '    ';
          END CASE;  
             
          pr_tab_seguros(vr_index).vlpreseg:= rw_crapseg.vlpreseg;
          pr_tab_seguros(vr_index).dtinivig:= rw_crapseg.dtinivig;
          
          IF rw_crapseg.tpseguro = 11 THEN
            pr_tab_seguros(vr_index).qtprevig:= rw_crapseg.qtprepag;
          ELSE
            IF rw_crapseg.indebito > 0 THEN
              pr_tab_seguros(vr_index).qtprevig:= rw_crapseg.qtprepag - 1;
            ELSE
              pr_tab_seguros(vr_index).qtprevig:= rw_crapseg.qtprepag;
            END IF;
          END IF;      
          
          pr_tab_seguros(vr_index).registro:=    rw_crapseg.ROWID;
          pr_tab_seguros(vr_index).nmbenvid##1:= rw_crapseg.nmbenvid##1;
          pr_tab_seguros(vr_index).nmbenvid##2:= rw_crapseg.nmbenvid##2;
          pr_tab_seguros(vr_index).nmbenvid##3:= rw_crapseg.nmbenvid##3;
          pr_tab_seguros(vr_index).nmbenvid##4:= rw_crapseg.nmbenvid##4;
          pr_tab_seguros(vr_index).nmbenvid##5:= rw_crapseg.nmbenvid##5;
          pr_tab_seguros(vr_index).dsgraupr##1:= rw_crapseg.dsgraupr##1;
          pr_tab_seguros(vr_index).dsgraupr##2:= rw_crapseg.dsgraupr##2;
          pr_tab_seguros(vr_index).dsgraupr##3:= rw_crapseg.dsgraupr##3;
          pr_tab_seguros(vr_index).dsgraupr##4:= rw_crapseg.dsgraupr##4;
          pr_tab_seguros(vr_index).dsgraupr##5:= rw_crapseg.dsgraupr##5;
          pr_tab_seguros(vr_index).txpartic##1:= rw_crapseg.txpartic##1;
          pr_tab_seguros(vr_index).txpartic##2:= rw_crapseg.txpartic##2;
          pr_tab_seguros(vr_index).txpartic##3:= rw_crapseg.txpartic##3;
          pr_tab_seguros(vr_index).txpartic##4:= rw_crapseg.txpartic##4;
          pr_tab_seguros(vr_index).txpartic##5:= rw_crapseg.txpartic##5;
          pr_tab_seguros(vr_index).dtultalt:= rw_crapseg.dtultalt;
          pr_tab_seguros(vr_index).vlprepag:= rw_crapseg.vlprepag;
          pr_tab_seguros(vr_index).qtprepag:= rw_crapseg.qtprepag;
          pr_tab_seguros(vr_index).dtultalt:= rw_crapseg.dtultalt;
          pr_tab_seguros(vr_index).dtmvtolt:= rw_crapseg.dtmvtolt;
          
          /** TOTAIS **/
          pr_qtsegass:= nvl(pr_qtsegass,0) + 1;
          
          IF rw_crapseg.cdsitseg = 3 AND rw_crapseg.tpseguro = 11 THEN
            pr_tab_seguros(vr_index).dsstatus:= 'Ativo';
            --Valor total
            IF rw_crapseg.flgunica = 1 THEN 
              pr_vltotseg:= nvl(pr_vltotseg,0) + 0;
            ELSE 
              pr_vltotseg:= nvl(pr_vltotseg,0) + nvl(rw_crapseg.vlpreseg,0);
            END IF;
          ELSIF rw_crapseg.cdsitseg = 1 THEN
            pr_tab_seguros(vr_index).dsstatus:= 'Ativo';
            --Valor total
            IF rw_crapseg.flgunica = 1 THEN 
              pr_vltotseg:= nvl(pr_vltotseg,0) + 0;
            ELSE 
              pr_vltotseg:= nvl(pr_vltotseg,0) + nvl(rw_crapseg.vlpreseg,0);
            END IF;    
          ELSIF rw_crapseg.cdsitseg = 2 THEN
            pr_tab_seguros(vr_index).dsstatus:= 'Cancelado';
          ELSIF rw_crapseg.cdsitseg = 3 THEN
            pr_tab_seguros(vr_index).dsstatus:= 'S'||to_char(rw_crapseg.nrctratu,'99999g990');
          ELSIF rw_crapseg.cdsitseg = 4 THEN
            pr_tab_seguros(vr_index).dsstatus:= 'Vencido';
          ELSE
            pr_tab_seguros(vr_index).dsstatus:= '?????????';
          END IF;  
          
          --Selecionar outras informacoes seguros
          OPEN cr_crawseg (pr_cdcooper => rw_crapseg.cdcooper
                          ,pr_nrdconta => rw_crapseg.nrdconta
                          ,pr_nrctrseg => rw_crapseg.nrctrseg);
          FETCH cr_crawseg INTO rw_crawseg;
          --Se Encontrou
          IF cr_crawseg%FOUND THEN
            pr_tab_seguros(vr_index).vlseguro:= rw_crawseg.vlseguro;
            pr_tab_seguros(vr_index).dtfimvig:= rw_crawseg.dtfimvig;
            pr_tab_seguros(vr_index).tpplaseg:= rw_crawseg.tpplaseg;
            pr_tab_seguros(vr_index).nmdsegur:= rw_crawseg.nmdsegur;
          END IF;  
          --Fechar Cursor
          CLOSE cr_crawseg; 
          
          --Buscar Motivos Cancelamento
          pc_buscar_motivo_can (pr_cdcooper  => pr_cdcooper        -- Cooperativa
                               ,pr_cdagenci  => pr_cdagenci        -- Agencia
                               ,pr_nrdcaixa  => pr_nrdcaixa        -- Numero Caixa
                               ,pr_cdoperad  => pr_cdoperad        -- Operador
                               ,pr_dtmvtolt  => pr_dtmvtolt        -- Data Movimento
                               ,pr_nrdconta  => pr_nrdconta        -- Numero Conta
                               ,pr_idseqttl  => pr_idseqttl        -- Sequencial Titular
                               ,pr_idorigem  => pr_idorigem        -- Origem Informacao
                               ,pr_nmdatela  => pr_nmdatela        -- Programa Chamador
                               ,pr_flgerlog  => pr_flgerlog        -- Escrever Erro Log
                               ,pr_cdmotcan  => rw_crapseg.cdmotcan -- Codigo Motivo Cancelamento
                               ,pr_dsmotcan  => NULL                -- Descricao Motivo
                               ,pr_qtregist  => vr_qtmotcan        -- Qdade Motivos Cancelamento
                               ,pr_tab_mot_can => vr_tab_mot_can   -- Tabela Motivo Cancelamento
                               ,pr_des_erro => vr_des_erro         -- Descricao Erro
                               ,pr_tab_erro => pr_tab_erro);       -- Tabela Erros
          --Se ocorreu erro
          IF vr_des_erro = 'NOK' THEN
            IF pr_tab_erro.COUNT > 0 THEN
              vr_cdcritic:= pr_tab_erro(pr_tab_erro.FIRST).cdcritic;
              vr_dscritic:= pr_tab_erro(pr_tab_erro.FIRST).dscritic;
            ELSE
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao buscar motivo cancelamento.';
            END IF;
            --Levantar Excecao
            RAISE vr_exc_sair;    
          END IF;
          
          --Se Existir registro de Motivo
          IF vr_tab_mot_can.COUNT > 0 THEN
            --Primeiro Registro
            vr_index_mot:= vr_tab_mot_can.FIRST;
            WHILE vr_index_mot IS NOT NULL LOOP
              IF pr_tab_seguros(vr_index).cdmotcan = vr_tab_mot_can(vr_index_mot).cdmotcan THEN
                pr_tab_seguros(vr_index).dsmotcan:= vr_tab_mot_can(vr_index_mot).dsmotcan;
                --Sair 
                EXIT;
              END IF;  
              --Proximo Registro
              vr_index_mot:= vr_tab_mot_can.NEXT(vr_index_mot);
            END LOOP;  
          END IF;
        END LOOP; --rw_crapseg 
      ELSE
         FOR rw_crapseg IN cr_crapseg_coop (pr_cdcooper => pr_cdcooper) LOOP
           IF (rw_crapseg.nrdconta <> nvl(pr_nrdconta,0) AND nvl(pr_nrdconta,0) <> 0) THEN 
             -- Proximo Registro
             CONTINUE;
           END IF;  
          IF (rw_crapseg.cdsitseg = 2 AND rw_crapseg.dtcancel < (pr_dtmvtolt - 365)) OR
             (rw_crapseg.cdsitseg = 4 AND rw_crapseg.dtfimvig < (pr_dtmvtolt - 365)) THEN
            --Proximo Registro 
            CONTINUE;
          END IF; 
          --Inserir Linha tabela seguros
          vr_index:= pr_tab_seguros.COUNT + 1;
          pr_tab_seguros(vr_index).cdcooper:= rw_crapseg.cdcooper;
          pr_tab_seguros(vr_index).cdagenci:= rw_crapseg.cdagenci;
          pr_tab_seguros(vr_index).dtcancel:= rw_crapseg.dtcancel;
          pr_tab_seguros(vr_index).cdmotcan:= rw_crapseg.cdmotcan;
          pr_tab_seguros(vr_index).nrdconta:= rw_crapseg.nrdconta;
          pr_tab_seguros(vr_index).tpendcor:= rw_crapseg.tpendcor;
          pr_tab_seguros(vr_index).dtiniseg:= rw_crapseg.dtiniseg;
          pr_tab_seguros(vr_index).cdsegura:= rw_crapseg.cdsegura;
          pr_tab_seguros(vr_index).flgclabe:= rw_crapseg.flgclabe;
          pr_tab_seguros(vr_index).nrctrseg:= rw_crapseg.nrctrseg;
          pr_tab_seguros(vr_index).tpplaseg:= rw_crapseg.tpplaseg;
          pr_tab_seguros(vr_index).dtprideb:= rw_crapseg.dtprideb;
          pr_tab_seguros(vr_index).dtdebito:= rw_crapseg.dtdebito;
          pr_tab_seguros(vr_index).tpseguro:= rw_crapseg.tpseguro;
          pr_tab_seguros(vr_index).cdsitseg:= rw_crapseg.cdsitseg;
          pr_tab_seguros(vr_index).nrseqdig:= rw_crapseg.nrseqdig;
          pr_tab_seguros(vr_index).nrdolote:= rw_crapseg.nrdolote;
          pr_tab_seguros(vr_index).cdbccxlt:= rw_crapseg.cdbccxlt;
          pr_tab_seguros(vr_index).nrseqdig:= rw_crapseg.nrseqdig; 
          
          CASE rw_crapseg.tpseguro
            WHEN 1 THEN  pr_tab_seguros(vr_index).dsseguro:= 'CASA';
            WHEN 11 THEN pr_tab_seguros(vr_index).dsseguro:= 'CASA';
            WHEN 2 THEN  pr_tab_seguros(vr_index).dsseguro:= 'AUTO';
            WHEN 3 THEN  pr_tab_seguros(vr_index).dsseguro:= 'VIDA';
            WHEN 4 THEN  pr_tab_seguros(vr_index).dsseguro:= 'PRST';
            ELSE pr_tab_seguros(vr_index).dsseguro:= '    ';
          END CASE;  
             
          pr_tab_seguros(vr_index).vlpreseg:= rw_crapseg.vlpreseg;
          pr_tab_seguros(vr_index).dtinivig:= rw_crapseg.dtinivig;
          
          IF rw_crapseg.tpseguro = 11 THEN
            pr_tab_seguros(vr_index).qtprevig:= rw_crapseg.qtprepag;
          ELSE
            IF rw_crapseg.indebito > 0 THEN
              pr_tab_seguros(vr_index).qtprevig:= rw_crapseg.qtprepag - 1;
            ELSE
              pr_tab_seguros(vr_index).qtprevig:= rw_crapseg.qtprepag;
            END IF;
          END IF;      
          
          pr_tab_seguros(vr_index).registro:=    rw_crapseg.ROWID;
          pr_tab_seguros(vr_index).nmbenvid##1:= rw_crapseg.nmbenvid##1;
          pr_tab_seguros(vr_index).nmbenvid##2:= rw_crapseg.nmbenvid##2;
          pr_tab_seguros(vr_index).nmbenvid##3:= rw_crapseg.nmbenvid##3;
          pr_tab_seguros(vr_index).nmbenvid##4:= rw_crapseg.nmbenvid##4;
          pr_tab_seguros(vr_index).nmbenvid##5:= rw_crapseg.nmbenvid##5;
          pr_tab_seguros(vr_index).dsgraupr##1:= rw_crapseg.dsgraupr##1;
          pr_tab_seguros(vr_index).dsgraupr##2:= rw_crapseg.dsgraupr##2;
          pr_tab_seguros(vr_index).dsgraupr##3:= rw_crapseg.dsgraupr##3;
          pr_tab_seguros(vr_index).dsgraupr##4:= rw_crapseg.dsgraupr##4;
          pr_tab_seguros(vr_index).dsgraupr##5:= rw_crapseg.dsgraupr##5;
          pr_tab_seguros(vr_index).txpartic##1:= rw_crapseg.txpartic##1;
          pr_tab_seguros(vr_index).txpartic##2:= rw_crapseg.txpartic##2;
          pr_tab_seguros(vr_index).txpartic##3:= rw_crapseg.txpartic##3;
          pr_tab_seguros(vr_index).txpartic##4:= rw_crapseg.txpartic##4;
          pr_tab_seguros(vr_index).txpartic##5:= rw_crapseg.txpartic##5;
          pr_tab_seguros(vr_index).dtultalt:= rw_crapseg.dtultalt;
          pr_tab_seguros(vr_index).vlprepag:= rw_crapseg.vlprepag;
          pr_tab_seguros(vr_index).qtprepag:= rw_crapseg.qtprepag;
          pr_tab_seguros(vr_index).dtmvtolt:= rw_crapseg.dtmvtolt;
          
          /** TOTAIS **/
          pr_qtsegass:= nvl(pr_qtsegass,0) + 1;
          
          IF rw_crapseg.cdsitseg = 3 AND rw_crapseg.tpseguro = 11 THEN
            pr_tab_seguros(vr_index).dsstatus:= 'Ativo';
            --Valor total
            IF rw_crapseg.flgunica = 1 THEN 
              pr_vltotseg:= nvl(pr_vltotseg,0) + 0;
            ELSE 
              pr_vltotseg:= nvl(pr_vltotseg,0) + nvl(rw_crapseg.vlpreseg,0);
            END IF;
          ELSIF rw_crapseg.cdsitseg = 1 THEN
            pr_tab_seguros(vr_index).dsstatus:= 'Ativo';
            --Valor total
            IF rw_crapseg.flgunica = 1 THEN 
              pr_vltotseg:= nvl(pr_vltotseg,0) + 0;
            ELSE 
              pr_vltotseg:= nvl(pr_vltotseg,0) + nvl(rw_crapseg.vlpreseg,0);
            END IF;    
          ELSIF rw_crapseg.cdsitseg = 2 THEN
            pr_tab_seguros(vr_index).dsstatus:= 'Cancelado';
          ELSIF rw_crapseg.cdsitseg = 3 THEN
            pr_tab_seguros(vr_index).dsstatus:= 'S'||to_char(rw_crapseg.nrctratu,'99999g990');
          ELSIF rw_crapseg.cdsitseg = 4 THEN
            pr_tab_seguros(vr_index).dsstatus:= 'Vencido';
          ELSE
            pr_tab_seguros(vr_index).dsstatus:= '?????????';
          END IF;  
          
          --Selecionar outras informacoes seguros
          OPEN cr_crawseg (pr_cdcooper => rw_crapseg.cdcooper
                          ,pr_nrdconta => rw_crapseg.nrdconta
                          ,pr_nrctrseg => rw_crapseg.nrctrseg);
          FETCH cr_crawseg INTO rw_crawseg;
          --Se Encontrou
          IF cr_crawseg%FOUND THEN
            pr_tab_seguros(vr_index).vlseguro:= rw_crawseg.vlseguro;
            pr_tab_seguros(vr_index).dtfimvig:= rw_crawseg.dtfimvig;
            pr_tab_seguros(vr_index).tpplaseg:= rw_crawseg.tpplaseg;
            pr_tab_seguros(vr_index).nmdsegur:= rw_crawseg.nmdsegur;
          END IF;  
          --Fechar Cursor
          CLOSE cr_crawseg; 
          
          --Buscar Motivos Cancelamento
          pc_buscar_motivo_can (pr_cdcooper  => pr_cdcooper        -- Cooperativa
                               ,pr_cdagenci  => pr_cdagenci        -- Agencia
                               ,pr_nrdcaixa  => pr_nrdcaixa        -- Numero Caixa
                               ,pr_cdoperad  => pr_cdoperad        -- Operador
                               ,pr_dtmvtolt  => pr_dtmvtolt        -- Data Movimento
                               ,pr_nrdconta  => pr_nrdconta        -- Numero Conta
                               ,pr_idseqttl  => pr_idseqttl        -- Sequencial Titular
                               ,pr_idorigem  => pr_idorigem        -- Origem Informacao
                               ,pr_nmdatela  => pr_nmdatela        -- Programa Chamador
                               ,pr_flgerlog  => pr_flgerlog        -- Escrever Erro Log
                               ,pr_cdmotcan  => rw_crapseg.cdmotcan -- Codigo Motivo Cancelamento
                               ,pr_dsmotcan  => NULL                -- Descricao Motivo
                               ,pr_qtregist  => vr_qtmotcan        -- Qdade Motivos Cancelamento
                               ,pr_tab_mot_can => vr_tab_mot_can   -- Tabela Motivo Cancelamento
                               ,pr_des_erro => vr_des_erro         -- Descricao Erro
                               ,pr_tab_erro => pr_tab_erro);       -- Tabela Erros
          --Se ocorreu erro
          IF vr_des_erro = 'NOK' THEN
            IF pr_tab_erro.COUNT > 0 THEN
              vr_cdcritic:= pr_tab_erro(pr_tab_erro.FIRST).cdcritic;
              vr_dscritic:= pr_tab_erro(pr_tab_erro.FIRST).dscritic;
            ELSE
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao buscar motivo cancelamento.';
            END IF;
            --Levantar Excecao
            RAISE vr_exc_sair;    
          END IF;
          
          --Se Existir registro de Motivo
          IF vr_tab_mot_can.COUNT > 0 THEN
            --Primeiro Registro
            vr_index_mot:= vr_tab_mot_can.FIRST;
            WHILE vr_index_mot IS NOT NULL LOOP
              IF pr_tab_seguros(vr_index).cdmotcan = vr_tab_mot_can(vr_index_mot).cdmotcan THEN
                 pr_tab_seguros(vr_index).dsmotcan:= vr_tab_mot_can(vr_index_mot).dsmotcan;
                 --Sair 
                 EXIT;
              END IF;  
              --Proximo Registro
              vr_index_mot:= vr_tab_mot_can.NEXT(vr_index_mot);
            END LOOP;  
          END IF;

        END LOOP;                            
      END IF;
        
      --Limpar tabela erros
      pr_tab_erro.DELETE;
      
      IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

        --Se for para gerar log
        IF pr_flgerlog THEN

          --Executar rotina geracao log
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => vr_dsorigem
                              ,pr_dstransa => vr_dstransa
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0 /*FALSE*/
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);        
        END IF;
        --Retorno NOK
         pr_des_erro:= 'NOK';   
         RETURN;
      END IF;
                             
      --Se for para gerar log
      IF pr_flgerlog THEN
        --Executar rotina geracao log
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1 /*TRUE*/
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);        
      END IF;
      
      --Retorno OK
      pr_des_erro:= 'OK';   
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro:= 'NOK';
        vr_dscritic:= 'Erro na rotina SEGU0001.pc_buscar_seguros. '||sqlerrm;
        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);                
    END;      
  END pc_buscar_seguros;                             

  --Procedimento para calcular a data de debito
  PROCEDURE pc_calcular_data_debito (pr_cdcooper  IN crapcop.cdcooper%type -- Cooperativa
                                    ,pr_cdagenci  IN crapage.cdagenci%type -- Agencia
                                    ,pr_nrdcaixa  IN INTEGER               -- Numero Caixa
                                    ,pr_cdoperad  IN crapope.cdoperad%type -- Operador
                                    ,pr_dtmvtolt  IN crapdat.dtmvtolt%type -- Data Movimento
                                    ,pr_nrdconta  IN crapass.nrdconta%type -- Numero Conta
                                    ,pr_idseqttl  IN crapttl.idseqttl%type -- Sequencial Titular
                                    ,pr_idorigem  IN INTEGER               -- Origem Informacao
                                    ,pr_nmdatela  IN VARCHAR2              -- Programa Chamador
                                    ,pr_flgerlog  IN BOOLEAN               -- Escrever Erro Log
                                    ,pr_flgunica  IN crapseg.flgunica%type -- Pagto Unico
                                    ,pr_qtmaxpar  IN INTEGER               -- Quantidade maxima parcelas
                                    ,pr_mmpripag  IN INTEGER               -- Mes Primeiro Pagamento
                                    ,pr_dtdebini  IN DATE                  -- Data Debito Inicial
                                    ,pr_dtpriini  IN DATE                  -- Data Primeiro Pagto
                                    ,pr_dtdebito  OUT DATE                 -- Data Debito
                                    ,pr_dtpripag  OUT DATE                 -- Data Primeiro Pagamento
                                    ,pr_des_erro  OUT VARCHAR2             -- Descricao Erro
                                    ,pr_tab_erro  OUT GENE0001.typ_tab_erro) IS -- Tabela Erros
  BEGIN
     ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_calcular_data_debito                   Antigo: b1wgen0033.p/calcular_data_debito
  --  Sistema  : 
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido
  --  Data     : Abril/2015.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para calcular a data de debito

  ---------------------------------------------------------------------------------------------------------------
    DECLARE
    
      --Variaveis Locais
      vr_dtdebito DATE;
      vr_dtprideb DATE;
      
      --Variaveis de Log
      vr_dsorigem VARCHAR2(1000);
      vr_dstransa VARCHAR2(1000);
      vr_nrdrowid ROWID;
      
      --Variaveis de Erro
      vr_cdcritic integer;
      vr_dscritic varchar2(4000);
      
      --Variaveis Excecao
      vr_exc_sair EXCEPTION;
      vr_exc_erro EXCEPTION;
      
    BEGIN
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;
      vr_dscritic:= NULL;
      
      --Limpar tabela erros
      pr_tab_erro.DELETE;

      --Descricao da Origem e da Transacao
      vr_dsorigem:= gene0001.vr_vet_des_origens(pr_idorigem);
      vr_dstransa:= 'Calcular Data Debito.';
            
      IF pr_flgunica = 0 AND pr_qtmaxpar <> 1 THEN
        --Montar Data
        vr_dtdebito:= TO_DATE(to_char(pr_dtdebini,'DD')||to_char(pr_dtmvtolt,'MMYYYY'),'DDMMYYYY');
        --Calcular Data
        vr_dtdebito:= GENE0005.fn_calc_data (pr_dtmvtolt => vr_dtdebito
                                            ,pr_qtmesano => 1
                                            ,pr_tpmesano => 'M'
                                            ,pr_des_erro => vr_dscritic);
        --Se ocorreu erro
        IF vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;                                      
      ELSE
        --Data Debito
        vr_dtdebito:= TO_DATE(to_char(pr_dtpriini,'DD')||to_char(pr_dtmvtolt,'MMYYYY'),'DDMMYYYY');
      END IF;
       
      --Data Primeiro Debito
      IF nvl(pr_mmpripag,0) > 0 THEN
        vr_dtprideb:= vr_dtdebito;
      ELSE
        vr_dtprideb:= TO_DATE(to_char(pr_dtpriini,'DD')||to_char(pr_dtmvtolt,'MMYYYY'),'DDMMYYYY');
      END IF;
          
      --Retornar Valores
      pr_dtdebito:= vr_dtdebito;
      pr_dtpripag:= vr_dtprideb;
      
      --Limpar tabela erros
      pr_tab_erro.DELETE;
      
      IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

        --Se for para gerar log
        IF pr_flgerlog THEN

          --Executar rotina geracao log
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => vr_dsorigem
                              ,pr_dstransa => vr_dstransa
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0 /*FALSE*/
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);        
        END IF;
        --Retorno NOK
         pr_des_erro:= 'NOK';   
         RETURN;
      END IF;
                             
      --Se for para gerar log
      IF pr_flgerlog THEN
        --Executar rotina geracao log
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1 /*TRUE*/
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);        
      END IF;
      
      --Retorno OK
      pr_des_erro:= 'OK';   
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_des_erro:= 'NOK';
        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);                
      WHEN OTHERS THEN
        pr_des_erro:= 'NOK';
        vr_dscritic:= 'Erro na rotina SEGU0001.pc_calcular_data_debito. '||sqlerrm;
        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);                
    END;      
  END pc_calcular_data_debito;                             

  --Procedimento para Atualizar Matricula
  PROCEDURE pc_atualizar_matricula (pr_cdcooper  IN crapcop.cdcooper%type -- Cooperativa
                                   ,pr_cdagenci  IN crapage.cdagenci%type -- Agencia
                                   ,pr_nrdcaixa  IN INTEGER               -- Numero Caixa
                                   ,pr_cdoperad  IN crapope.cdoperad%type -- Operador
                                   ,pr_dtmvtolt  IN crapdat.dtmvtolt%type -- Data Movimento
                                   ,pr_nrdconta  IN crapass.nrdconta%type -- Numero Conta
                                   ,pr_idseqttl  IN crapttl.idseqttl%type -- Sequencial Titular
                                   ,pr_idorigem  IN INTEGER               -- Origem Informacao
                                   ,pr_nmdatela  IN VARCHAR2              -- Programa Chamador
                                   ,pr_flgerlog  IN BOOLEAN               -- Escrever Erro Log
                                   ,pr_reg_crapmat OUT crapmat%rowtype    -- Registro da Empresa
                                   ,pr_des_erro  OUT VARCHAR2             -- Descricao Erro
                                   ,pr_tab_erro  OUT GENE0001.typ_tab_erro) IS -- Tabela Erros
  BEGIN
     ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_atualizar_matricula                   Antigo: b1wgen0033.p/atualizar_matricula
  --  Sistema  : 
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido
  --  Data     : Abril/2015.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para atualizar matricula

  ---------------------------------------------------------------------------------------------------------------
    DECLARE
    
      --Selecionar Matricula
      CURSOR cr_crapmat (pr_cdcooper IN crapcop.cdcooper%type) IS
        SELECT /*+ INDEX_ASC (crapmat crapmat##crapmat1) */ crapmat.*
        FROM crapmat 
        WHERE crapmat.cdcooper = pr_cdcooper;  
                      
      --Variaveis Locais
      vr_dsorigem VARCHAR2(1000);
      vr_dstransa VARCHAR2(1000);
      vr_nrdrowid ROWID;
      vr_nrctrseg INTEGER;
      
      --Variaveis de Erro
      vr_cdcritic integer;
      vr_dscritic varchar2(4000);
      
      vr_exc_sair EXCEPTION;
      vr_exc_erro EXCEPTION;
      
    BEGIN
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;
      vr_dscritic:= NULL;
      
      --Limpar tabela erros
      pr_tab_erro.DELETE;
      
      --Descricao da Origem e da Transacao
      vr_dsorigem:= gene0001.vr_vet_des_origens(pr_idorigem);
      vr_dstransa:= 'Atualizar matricula.';
      
      --Selecionar Matricula
      OPEN cr_crapmat (pr_cdcooper => pr_cdcooper);
      FETCH cr_crapmat INTO pr_reg_crapmat;
      --Se nao Encontrou
      IF cr_crapmat%NOTFOUND THEN
        vr_cdcritic:= 71;
        vr_dscritic:= 'Matricula nao encontrada.';
      ELSE
        /* Buscar a proxima sequencia crapmat.nrctrseg */ 
        pc_sequence_progress(pr_nmtabela => 'CRAPMAT'
                            ,pr_nmdcampo => 'NRCTRSEG'
                            ,pr_dsdchave => pr_cdcooper
                            ,pr_flgdecre => 'N'
                            ,pr_sequence => vr_nrctrseg);
        --Retornar Matricula
        pr_reg_crapmat.nrctrseg:= vr_nrctrseg;                            
      END IF;            
      --Fechar Cursor
      CLOSE cr_crapmat;
                    
      --Limpar tabela erros
      pr_tab_erro.DELETE;
      
      IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN
        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

        --Se for para gerar log
        IF pr_flgerlog THEN

          --Executar rotina geracao log
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => vr_dsorigem
                              ,pr_dstransa => vr_dstransa
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0 /*FALSE*/
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);        
        END IF;
        --Retorno NOK
         pr_des_erro:= 'NOK';   
         RETURN;
      END IF;
                             
      --Se for para gerar log
      IF pr_flgerlog THEN
        --Executar rotina geracao log
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1 /*TRUE*/
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);        
      END IF;
      
      --Retorno OK
      pr_des_erro:= 'OK';   
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro:= 'NOK';
        vr_dscritic:= 'Erro na rotina SEGU0001.pc_atualizar_matricula. '||sqlerrm;
        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);                
    END;      
  END pc_atualizar_matricula;                             

  --Procedimento para Criar o Seguro
  PROCEDURE pc_cria_seguro (pr_cdcooper  IN crapcop.cdcooper%type -- Cooperativa
                           ,pr_cdagenci  IN crapage.cdagenci%type -- Agencia
                           ,pr_nrdcaixa  IN INTEGER               -- Numero Caixa
                           ,pr_cdoperad  IN crapope.cdoperad%type -- Operador
                           ,pr_dtmvtolt  IN crapdat.dtmvtolt%type -- Data Movimento
                           ,pr_nrdconta  IN crapass.nrdconta%type -- Numero Conta
                           ,pr_idseqttl  IN crapttl.idseqttl%type -- Sequencial Titular
                           ,pr_idorigem  IN INTEGER               -- Origem Informacao
                           ,pr_nmdatela  IN VARCHAR2              -- Programa Chamador
                           ,pr_flgerlog  IN BOOLEAN               -- Escrever Erro Log
                           ,pr_cdmotcan  IN crapseg.cdmotcan%type -- Motivo Cancelamento
                           ,pr_cdsegura  IN crapseg.cdsegura%type -- Codigo Seguradora
                           ,pr_cdsitseg  IN crapseg.cdsitseg%type -- Situacao Seguro
                           ,pr_tab_dsgraupr segu0001.typ_tab_dsgraupr -- Grau Parentesco 
                           ,pr_dtaltseg  IN crapseg.dtaltseg%type -- Data Alteracao Seguro
                           ,pr_dtcancel  IN crapseg.dtcancel%type -- Data Cancelamento
                           ,pr_dtdebito  IN crapseg.dtdebito%type -- Data Debito
                           ,pr_dtfimvig  IN crapseg.dtfimvig%type -- Data Fim Vigencia
                           ,pr_dtiniseg  IN crapseg.dtiniseg%type -- Data Inicio Seguro
                           ,pr_dtinivig  IN crapseg.dtinivig%type -- Data Inicio Vigencia
                           ,pr_dtprideb  IN crapseg.dtprideb%type -- Data Primeiro Debito
                           ,pr_dtultalt  IN crapseg.dtultalt%type -- Data Ultima Alteracao
                           ,pr_dtultpag  IN crapseg.dtultpag%type -- Data Ultimo Pagamento
                           ,pr_flgclabe  IN crapseg.flgclabe%type -- Flag Abertura
                           ,pr_flgconve  IN crapseg.flgconve%type -- Flag Convenio
                           ,pr_flgunica  IN crapseg.flgunica%type -- Flag Parcela Unica
                           ,pr_indebito  IN crapseg.indebito%type -- Indicador Debito
                           ,pr_lsctrant  IN crapseg.lsctrant%type -- Contrato Anterior
                           ,pr_tab_nmbenvid  IN segu0001.typ_tab_nmbenvid -- Nome Beneficiario Vida
                           ,pr_nrctratu  IN crapseg.nrctratu%type -- Numero Contrato Atual
                           ,pr_nrctrseg  IN crapseg.nrctrseg%type -- Numero Contrato Seguro
                           ,pr_nrdolote  IN craplot.nrdolote%type -- Numero do Lote
                           ,pr_qtparcel  IN crapseg.qtparcel%type -- Quantidade Parcelas
                           ,pr_qtprepag  IN crapseg.qtprepag%type -- Quantidade Parcelas Pagas
                           ,pr_qtprevig  IN crapseg.qtprevig%type -- Quantidade Prestacoes Vigentes
                           ,pr_tpdpagto  IN crapseg.tpdpagto%type -- Tipo de Pagamento
                           ,pr_tpendcor  IN crapseg.tpendcor%type -- Tipo Endereco Correspondencia
                           ,pr_tpplaseg  IN crapseg.tpplaseg%type -- Tipo Plano Seguro
                           ,pr_tpseguro  IN crapseg.tpseguro%type -- Tipo Seguro
                           ,pr_tab_txpartic IN segu0001.typ_tab_txpartic --Tabela taxa participacao
                           ,pr_vldifseg  IN crapseg.vldifseg%type -- Valor Diferenca Seguro
                           ,pr_vlpremio  IN crapseg.vlpremio%type -- Valor do Premio
                           ,pr_vlprepag  IN crapseg.vlprepag%type -- Valor Prestacoes Pagas
                           ,pr_vlpreseg  IN crapseg.vlpreseg%type -- Valor Prestacao Seguro
                           ,pr_vlcapseg  IN craptsg.vlmorada%type -- Valor Capital Segurado
                           ,pr_cdbccxlt  IN craplot.cdbccxlt%type -- Caixa
                           ,pr_nrcpfcgc  IN crawseg.nrcpfcgc%type -- Numero cpf/cnpj
                           ,pr_nmdsegur  IN crawseg.nmdsegur%type -- Nome Segurado
                           ,pr_vltotpre  IN crapseg.vlpremio%type -- Valor Total Prestacoes
                           ,pr_cdcalcul  IN crawseg.cdcalcul%type -- Codigo Calculo
                           ,pr_vlseguro  IN crawseg.vlseguro%type -- Valor Seguro
                           ,pr_dsendres  IN crawseg.dsendres%type -- Descricao Endereco
                           ,pr_nrendres  IN crawseg.nrendres%type -- Numero Endereco
                           ,pr_nmbairro  IN crawseg.nmbairro%type -- Nome Bairro
                           ,pr_nmcidade  IN crawseg.nmcidade%type -- Nome Cidade
                           ,pr_cdufresd  IN crawseg.cdufresd%type -- Estado Residencia
                           ,pr_nrcepend  IN crawseg.nrcepend%type -- CEP Endereco
                           ,pr_cdsexosg  IN INTEGER               -- Sexo
                           ,pr_cdempres  IN crapemp.cdempres%type -- Codigo Empresa
                           ,pr_dtnascsg  IN crapdat.dtmvtolt%type -- Data Nascimento
                           ,pr_complend  IN crawseg.complend%type -- Complemento Endereco
                           ,pr_flgsegur  OUT BOOLEAN              -- Seguro Criado
                           ,pr_crawseg   OUT ROWID                -- Registro Crawseg
                           ,pr_des_erro  OUT VARCHAR2             -- Retorno Erro OK/NOK 
                           ,pr_tab_erro  OUT gene0001.typ_tab_erro) IS --Tabela Erros
  BEGIN
     ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_cria_seguro                   Antigo: b1wgen0033.p/cria_seguro
  --  Sistema  : 
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido
  --  Data     : Abril/2015.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para criar os seguros

  ---------------------------------------------------------------------------------------------------------------
    DECLARE
    
      -- Cursor para verificar se lote existe
      CURSOR cr_craplot (pr_cdcooper IN crapcop.cdcooper%TYPE,
			                   pr_dtmvtolt IN crapdat.dtmvtolt%TYPE,
                         pr_cdagenci IN craplot.cdagenci%TYPE,
                         pr_cdbccxlt IN craplot.cdbccxlt%TYPE,
                         pr_nrdolote IN craplot.nrdolote%TYPE) IS
			SELECT lot.nrseqdig
			      ,lot.qtcompln
						,lot.qtinfoln
						,lot.vlcompdb
            ,lot.nrdolote
            ,lot.cdbccxlt
            ,lot.cdagenci
            ,lot.dtmvtolt
						,lot.ROWID
			  FROM craplot lot
       WHERE lot.cdcooper = pr_cdcooper AND
             lot.dtmvtolt = pr_dtmvtolt AND
             lot.cdagenci = pr_cdagenci AND
             lot.cdbccxlt = pr_cdbccxlt AND
             lot.nrdolote = pr_nrdolote;
			rw_craplot cr_craplot%ROWTYPE;
      
      --Selecionar Seguros
      CURSOR cr_crapseg (pr_cdcooper IN crapseg.cdcooper%type
                        ,pr_dtmvtolt IN crapseg.dtmvtolt%type
                        ,pr_cdagenci IN crapseg.cdagenci%type
                        ,pr_cdbccxlt IN crapseg.cdbccxlt%type
                        ,pr_nrdolote IN crapseg.nrdolote%type) IS
        SELECT nvl(max(nvl(crapseg.nrseqdig,0)),0) nrseqdig 
        FROM crapseg
        WHERE crapseg.cdcooper = pr_cdcooper          
        AND   crapseg.dtmvtolt = pr_dtmvtolt          
        AND   crapseg.cdagenci = pr_cdagenci 
        AND   crapseg.cdbccxlt = pr_cdbccxlt          
        AND   crapseg.nrdolote = pr_nrdolote;
      rw_crapseg cr_crapseg%rowtype;
                        
      --Tabelas de Dados
      vr_tab_associado  segu0001.typ_tab_associado;
      vr_tab_seguros    segu0001.typ_tab_seguros;
      vr_tab_seguradora segu0001.typ_tab_seguradora;
      vr_tab_plano_seg  segu0001.typ_tab_plano_seg;
      
      --Registros de Dados
      vr_reg_crapjur crapjur%rowtype;
      vr_reg_crapttl crapttl%rowtype;
      vr_reg_crapemp crapemp%rowtype;
      vr_reg_crapmat crapmat%rowtype;
      rw_crawseg     crawseg%rowtype;
      
      --Variaveis Locais
      vr_nrcpfcgc crawseg.nrcpfcgc%type;
      vr_cdempres crapttl.cdempres%type;
      vr_cdsegura crapcsg.cdsegura%type;
      vr_nrctrseg crapmat.nrctrseg%type; 
      vr_nmempres crapemp.nmextemp%type; 
      vr_tpsegvid crawseg.tpsegvid%type; 
      vr_nmbenefi crawseg.nmbenefi%type; 
      vr_cdsexosg crawseg.cdsexosg%type;
      vr_nrseqdig craplot.nrseqdig%type;  
      vr_dsorigem VARCHAR2(1000);
      vr_dstransa VARCHAR2(1000);
      vr_nmdsegur VARCHAR2(1000);
      vr_nrdrowid ROWID;
      vr_qtsegass INTEGER;
      vr_qtparcel INTEGER;
      vr_vltotseg NUMBER;
      vr_flgseger BOOLEAN;
      vr_qtregist INTEGER;
      vr_dtfimvig DATE;
      vr_dtprideb DATE;
      vr_dtdebito DATE;
      vr_dtmvtolt DATE;
      vr_vlpremio NUMBER;
      vr_rowid_crawseg ROWID;
      vr_rowid_crapseg ROWID;
          
      --Variaveis Indice
      vr_index_seguros    PLS_INTEGER;
      vr_index_seguradora PLS_INTEGER;
      vr_index_plano      PLS_INTEGER;
      
      --Variaveis de Erro
      vr_cdcritic integer;
      vr_dscritic varchar2(4000);
      vr_des_erro varchar2(3); 
      
      vr_exc_sair EXCEPTION;
      vr_exc_erro EXCEPTION;
      
    BEGIN
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;
      vr_dscritic:= NULL;
      
      --Limpar tabela erros
      pr_tab_erro.DELETE;
      
      BEGIN
        
        /* Copiar valores dos parametros para variaveis pois alguns 
           parametros que são de entrada sofrem alteracao!! */
        vr_nrcpfcgc:= pr_nrcpfcgc;
        vr_nrctrseg:= pr_nrctrseg;
        vr_dtmvtolt:= pr_dtmvtolt;
        vr_cdsegura:= pr_cdsegura;
        vr_nmdsegur:= pr_nmdsegur;
        vr_dtdebito:= pr_dtdebito;
        vr_dtprideb:= pr_dtprideb;
        
        --Buscar Associados
        pc_buscar_associados (pr_cdcooper  => pr_cdcooper        -- Cooperativa
                             ,pr_cdagenci  => pr_cdagenci        -- Agencia
                             ,pr_nrdcaixa  => pr_nrdcaixa        -- Numero Caixa
                             ,pr_cdoperad  => pr_cdoperad        -- Operador
                             ,pr_dtmvtolt  => pr_dtmvtolt        -- Data Movimento
                             ,pr_nrdconta  => pr_nrdconta        -- Numero Conta
                             ,pr_idseqttl  => pr_idseqttl        -- Sequencial Titular
                             ,pr_idorigem  => pr_idorigem        -- Origem Informacao
                             ,pr_nmdatela  => pr_nmdatela        -- Programa Chamador
                             ,pr_flgerlog  => pr_flgerlog        -- Escrever Erro Log
                             ,pr_tab_associado => vr_tab_associado -- Registro do Associado
                             ,pr_des_erro => vr_des_erro         -- Descricao Erro
                             ,pr_tab_erro => pr_tab_erro);       -- Tabela Erros
        --Se ocorreu erro
        IF vr_des_erro = 'NOK' THEN
          IF pr_tab_erro.COUNT > 0 THEN
            vr_cdcritic:= pr_tab_erro(pr_tab_erro.FIRST).cdcritic;
            vr_dscritic:= pr_tab_erro(pr_tab_erro.FIRST).dscritic;
          ELSE
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao buscar associado.';
          END IF;
          --Levantar Excecao
          RAISE vr_exc_sair;    
        END IF;
        
        --CPF/CNPJ zerado
        IF pr_nrcpfcgc = '0' THEN
          vr_nrcpfcgc:= vr_tab_associado(1).nrcpfcgc;
        ELSE
          vr_nrcpfcgc:= pr_nrcpfcgc;  
        END IF;  
        --Codigo da Empresa
        vr_cdempres:= pr_cdempres;
        
        /*Ayllos Web*/
        IF pr_idorigem = 5 THEN
          /* juridica */
          IF vr_tab_associado(1).inpessoa <> 1 THEN 
            --Buscar Pessoa Juridica
            pc_buscar_pessoa_juridica (pr_cdcooper  => pr_cdcooper        -- Cooperativa
                                      ,pr_cdagenci  => pr_cdagenci        -- Agencia
                                      ,pr_nrdcaixa  => pr_nrdcaixa        -- Numero Caixa
                                      ,pr_cdoperad  => pr_cdoperad        -- Operador
                                      ,pr_dtmvtolt  => pr_dtmvtolt        -- Data Movimento
                                      ,pr_nrdconta  => pr_nrdconta        -- Numero Conta
                                      ,pr_idseqttl  => pr_idseqttl        -- Sequencial Titular
                                      ,pr_idorigem  => pr_idorigem        -- Origem Informacao
                                      ,pr_nmdatela  => pr_nmdatela        -- Programa Chamador
                                      ,pr_flgerlog  => pr_flgerlog        -- Escrever Erro Log
                                      ,pr_reg_crapjur => vr_reg_crapjur   -- Registro da Pessoa Juridica
                                      ,pr_des_erro => vr_des_erro         -- Descricao Erro
                                      ,pr_tab_erro => pr_tab_erro);       -- Tabela Erros
            --Se ocorreu erro
            IF vr_des_erro = 'NOK' THEN
              IF pr_tab_erro.COUNT > 0 THEN
                vr_cdcritic:= pr_tab_erro(pr_tab_erro.FIRST).cdcritic;
                vr_dscritic:= pr_tab_erro(pr_tab_erro.FIRST).dscritic;
              ELSE
                vr_cdcritic:= 0;
                vr_dscritic:= 'Erro ao buscar pessoa juridica.';
              END IF;
              --Levantar Excecao
              RAISE vr_exc_sair;    
            END IF;
            --Codigo da Empresa
            vr_cdempres:= vr_reg_crapjur.cdempres;
          END IF;  
        END IF;  --pr_idorigem = 5
        
        --Buscar Titular
        pc_buscar_titular (pr_cdcooper  => pr_cdcooper        -- Cooperativa
                          ,pr_cdagenci  => pr_cdagenci        -- Agencia
                          ,pr_nrdcaixa  => pr_nrdcaixa        -- Numero Caixa
                          ,pr_cdoperad  => pr_cdoperad        -- Operador
                          ,pr_dtmvtolt  => pr_dtmvtolt        -- Data Movimento
                          ,pr_nrdconta  => pr_nrdconta        -- Numero Conta
                          ,pr_idseqttl  => pr_idseqttl        -- Sequencial Titular
                          ,pr_idorigem  => pr_idorigem        -- Origem Informacao
                          ,pr_nmdatela  => pr_nmdatela        -- Programa Chamador
                          ,pr_flgerlog  => pr_flgerlog        -- Escrever Erro Log
                          ,pr_reg_crapttl => vr_reg_crapttl   -- Registro do Titular
                          ,pr_des_erro => vr_des_erro         -- Descricao Erro
                          ,pr_tab_erro => pr_tab_erro);       -- Tabela Erros
        --Se ocorreu erro
        IF vr_des_erro = 'NOK' THEN
          IF pr_tab_erro.COUNT > 0 THEN
            vr_cdcritic:= pr_tab_erro(pr_tab_erro.FIRST).cdcritic;
            vr_dscritic:= pr_tab_erro(pr_tab_erro.FIRST).dscritic;
          ELSE
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao buscar titular.';
          END IF;
          --Levantar Excecao
          RAISE vr_exc_sair;    
        END IF;
        
        /* Pessoa Fisica e Sem Empresa */
        IF vr_tab_associado(1).inpessoa = 1 AND nvl(pr_cdempres,0) = 0 THEN 
          vr_cdempres:= vr_reg_crapttl.cdempres;
        END IF;
        
        --Buscar Empresa
        pc_buscar_empresa (pr_cdcooper  => pr_cdcooper        -- Cooperativa
                          ,pr_cdagenci  => pr_cdagenci        -- Agencia
                          ,pr_nrdcaixa  => pr_nrdcaixa        -- Numero Caixa
                          ,pr_cdoperad  => pr_cdoperad        -- Operador
                          ,pr_dtmvtolt  => pr_dtmvtolt        -- Data Movimento
                          ,pr_nrdconta  => pr_nrdconta        -- Numero Conta
                          ,pr_idseqttl  => pr_idseqttl        -- Sequencial Titular
                          ,pr_idorigem  => pr_idorigem        -- Origem Informacao
                          ,pr_nmdatela  => pr_nmdatela        -- Programa Chamador
                          ,pr_flgerlog  => pr_flgerlog        -- Escrever Erro Log
                          ,pr_cdempres  => vr_cdempres        -- Codigo Empresa
                          ,pr_reg_crapemp => vr_reg_crapemp   -- Registro da Empresa
                          ,pr_des_erro => vr_des_erro         -- Descricao Erro
                          ,pr_tab_erro => pr_tab_erro);       -- Tabela Erros
        --Se ocorreu erro
        IF vr_des_erro = 'NOK' THEN
          IF pr_tab_erro.COUNT > 0 THEN
            vr_cdcritic:= pr_tab_erro(pr_tab_erro.FIRST).cdcritic;
            vr_dscritic:= pr_tab_erro(pr_tab_erro.FIRST).dscritic;
          ELSE
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao buscar empresa.';
          END IF;
          --Levantar Excecao
          RAISE vr_exc_sair;    
        END IF;  
        
        --Seguro Vida ou Prestamista
        IF pr_tpseguro IN (3,4) THEN
          --Plano Seguro
          IF pr_tpplaseg IN (14,18,24,34,44,54,64) THEN
            --Limpar tabela Seguros
            vr_tab_seguros.DELETE;
            
            --Buscar Dados do Seguro
            pc_buscar_seguros (pr_cdcooper  => pr_cdcooper        -- Cooperativa
                              ,pr_cdagenci  => pr_cdagenci        -- Agencia
                              ,pr_nrdcaixa  => pr_nrdcaixa        -- Numero Caixa
                              ,pr_cdoperad  => pr_cdoperad        -- Operador
                              ,pr_dtmvtolt  => pr_dtmvtolt        -- Data Movimento
                              ,pr_nrdconta  => pr_nrdconta        -- Numero Conta
                              ,pr_idseqttl  => pr_idseqttl        -- Sequencial Titular
                              ,pr_idorigem  => pr_idorigem        -- Origem Informacao
                              ,pr_nmdatela  => pr_nmdatela        -- Programa Chamador
                              ,pr_flgerlog  => pr_flgerlog        -- Escrever Erro Log
                              ,pr_cdempres  => vr_cdempres        -- Codigo Empresa
                              ,pr_tab_seguros => vr_tab_seguros   -- Tabela de Seguros
                              ,pr_qtsegass => vr_qtsegass         -- Qdade Seguros Associado
                              ,pr_vltotseg => vr_vltotseg         -- Valor Total Segurado
                              ,pr_des_erro => vr_des_erro         -- Descricao Erro
                              ,pr_tab_erro => pr_tab_erro);       -- Tabela Erros
            --Se ocorreu erro
            IF vr_des_erro = 'NOK' THEN
              IF pr_tab_erro.COUNT > 0 THEN
                vr_cdcritic:= pr_tab_erro(pr_tab_erro.FIRST).cdcritic;
                vr_dscritic:= pr_tab_erro(pr_tab_erro.FIRST).dscritic;
              ELSE
                vr_cdcritic:= 0;
                vr_dscritic:= 'Erro ao buscar seguros.';
              END IF;
              --Levantar Excecao
              RAISE vr_exc_sair;    
            END IF;
            
            --Nao encontrou erro
            vr_flgseger:= FALSE;
            --Percorrer seguros
            vr_index_seguros:= vr_tab_seguros.FIRST;
            WHILE vr_index_seguros IS NOT NULL LOOP
              IF vr_tab_seguros(vr_index_seguros).cdcooper = pr_cdcooper AND
                 vr_tab_seguros(vr_index_seguros).nrdconta = pr_nrdconta AND
                 vr_tab_seguros(vr_index_seguros).tpseguro = 3 AND 
                 vr_tab_seguros(vr_index_seguros).dtcancel IS NULL AND
                 vr_tab_seguros(vr_index_seguros).cdsitseg = 1 AND
                 vr_tab_seguros(vr_index_seguros).tpplaseg IN (14,18,24,34,44,54,64) THEN
                vr_flgseger:= TRUE;
                EXIT; 
              END IF;   
              --Proximo Registro
              vr_index_seguros:= vr_tab_seguros.NEXT(vr_index_seguros);
            END LOOP;
              
            --Se Encontrou problema
            IF vr_flgseger THEN
              --Codigo erro
              vr_cdcritic:= 648;
              --Limpar tabela Seguros
              vr_tab_seguros.DELETE;
              --Retornar 
              RAISE vr_exc_erro;                
            END IF;    
          END IF;
          
          /*seguros do tipo prest/vida nao passam o código da seguradora
            realizada busca das informaçoes da mesma conforme o tipo do plano 
            e o plano informado*/

          --Buscar Dados Seguradora
          pc_buscar_seguradora (pr_cdcooper  => pr_cdcooper        -- Cooperativa
                               ,pr_cdagenci  => pr_cdagenci        -- Agencia
                               ,pr_nrdcaixa  => pr_nrdcaixa        -- Numero Caixa
                               ,pr_cdoperad  => pr_cdoperad        -- Operador
                               ,pr_dtmvtolt  => pr_dtmvtolt        -- Data Movimento
                               ,pr_nrdconta  => pr_nrdconta        -- Numero Conta
                               ,pr_idseqttl  => pr_idseqttl        -- Sequencial Titular
                               ,pr_idorigem  => pr_idorigem        -- Origem Informacao
                               ,pr_nmdatela  => pr_nmdatela        -- Programa Chamador
                               ,pr_flgerlog  => pr_flgerlog        -- Escrever Erro Log
                               ,pr_tpseguro  => pr_tpseguro        -- Tipo Seguro
                               ,pr_cdsitpsg  => 1                  -- Situacao Seguro
                               ,pr_cdsegura  => pr_cdsegura        -- Codigo Seguradora
                               ,pr_nmsegura  => NULL               -- Nome Seguradora
                               ,pr_qtregist  => vr_qtregist        -- Quantidade Registros
                               ,pr_tab_seguradora => vr_tab_seguradora  -- Tabela da Seguradora
                               ,pr_des_erro => vr_des_erro         -- Descricao Erro
                               ,pr_tab_erro => pr_tab_erro);       -- Tabela Erros
          --Se ocorreu erro
          IF vr_des_erro = 'NOK' THEN
            IF pr_tab_erro.COUNT > 0 THEN
              vr_cdcritic:= pr_tab_erro(pr_tab_erro.FIRST).cdcritic;
              vr_dscritic:= pr_tab_erro(pr_tab_erro.FIRST).dscritic;
            ELSE
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao buscar seguros.';
            END IF;
            --Levantar Excecao
            RAISE vr_exc_sair;    
          END IF; 
          
          --Buscar Primeira Seguradora
          vr_index_seguradora:= vr_tab_seguradora.FIRST;
          WHILE vr_index_seguradora IS NOT NULL LOOP
            IF vr_tab_seguradora(vr_index_seguradora).cdcooper = pr_cdcooper AND
              (nvl(pr_cdsegura,0) = 0 OR vr_tab_seguradora(vr_index_seguradora).cdsegura = pr_cdsegura) THEN
              EXIT;
            END IF;  
            --Proximo Registro
            vr_index_seguradora:= vr_tab_seguradora.NEXT(vr_index_seguradora);
          END LOOP;
              
          --Codigo Seguradora Informado
          IF nvl(vr_cdsegura,0) = 0 AND vr_index_seguradora IS NOT NULL THEN
            vr_cdsegura:= vr_tab_seguradora(vr_index_seguradora).cdsegura; 
          END IF;   
          
          --Atualizar Matricula
          pc_atualizar_matricula (pr_cdcooper  => pr_cdcooper        -- Cooperativa
                                 ,pr_cdagenci  => pr_cdagenci        -- Agencia
                                 ,pr_nrdcaixa  => pr_nrdcaixa        -- Numero Caixa
                                 ,pr_cdoperad  => pr_cdoperad        -- Operador
                                 ,pr_dtmvtolt  => pr_dtmvtolt        -- Data Movimento
                                 ,pr_nrdconta  => pr_nrdconta        -- Numero Conta
                                 ,pr_idseqttl  => pr_idseqttl        -- Sequencial Titular
                                 ,pr_idorigem  => pr_idorigem        -- Origem Informacao
                                 ,pr_nmdatela  => pr_nmdatela        -- Programa Chamador
                                 ,pr_flgerlog  => pr_flgerlog        -- Escrever Erro Log
                                 ,pr_reg_crapmat => vr_reg_crapmat   -- Registro de Matriculas
                                 ,pr_des_erro => vr_des_erro         -- Descricao Erro
                                 ,pr_tab_erro => pr_tab_erro);       -- Tabela Erros
          --Se ocorreu erro
          IF vr_des_erro = 'NOK' THEN
            IF pr_tab_erro.COUNT > 0 THEN
              vr_cdcritic:= pr_tab_erro(pr_tab_erro.FIRST).cdcritic;
              vr_dscritic:= pr_tab_erro(pr_tab_erro.FIRST).dscritic;
            ELSE
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao atualizar matricula.';
            END IF;
            --Levantar Excecao
            RAISE vr_exc_sair;
          ELSE
            --Numero Contrato
            vr_nrctrseg:= vr_reg_crapmat.nrctrseg;      
          END IF; 
        END IF;
        
        --Buscar Plano Seguro
        pc_buscar_plano_seguro (pr_cdcooper => pr_cdcooper        -- Cooperativa
                               ,pr_cdagenci => pr_cdagenci        -- Agencia
                               ,pr_nrdcaixa => pr_nrdcaixa        -- Numero Caixa
                               ,pr_cdoperad => pr_cdoperad        -- Operador
                               ,pr_dtmvtolt => pr_dtmvtolt        -- Data Movimento
                               ,pr_nrdconta => pr_nrdconta        -- Numero Conta
                               ,pr_idseqttl => pr_idseqttl        -- Sequencial Titular
                               ,pr_idorigem => pr_idorigem        -- Origem Informacao
                               ,pr_nmdatela => pr_nmdatela        -- Programa Chamador
                               ,pr_flgerlog => pr_flgerlog        -- Escrever Erro Log
                               ,pr_cdsegura => pr_cdsegura        -- Codigo Seguradora
                               ,pr_tpseguro => pr_tpseguro        -- Tipo Seguro
                               ,pr_tpplaseg => pr_tpplaseg        -- Tipo Plano Seguro
                               ,pr_tab_plano_seg => vr_tab_plano_seg   -- Tabela Plano Seguros
                               ,pr_des_erro => vr_des_erro        -- Descricao Erro
                               ,pr_tab_erro => pr_tab_erro);      -- Tabela Erros
        --Se ocorreu erro
        IF vr_des_erro = 'NOK' THEN
          IF pr_tab_erro.COUNT > 0 THEN
            vr_cdcritic:= pr_tab_erro(pr_tab_erro.FIRST).cdcritic;
            vr_dscritic:= pr_tab_erro(pr_tab_erro.FIRST).dscritic;
          ELSE
            vr_cdcritic:= 0;
            vr_dscritic:= 'Erro ao buscar plano seguro.';
          END IF;
          --Levantar Excecao
          RAISE vr_exc_sair;
        END IF; 
         
        --Encontrar o Primeiro Plano
        vr_index_plano:= vr_tab_plano_seg.FIRST;
        WHILE vr_index_plano IS NOT NULL LOOP
          IF vr_tab_plano_seg(vr_index_plano).cdcooper = pr_cdcooper AND
             vr_tab_plano_seg(vr_index_plano).cdsegura = pr_cdsegura AND
             vr_tab_plano_seg(vr_index_plano).tpseguro = pr_tpseguro AND
             vr_tab_plano_seg(vr_index_plano).tpplaseg = pr_tpplaseg THEN
            EXIT; 
          END IF;   
          --Proximo Registro
          vr_index_plano:= vr_tab_plano_seg.NEXT(vr_index_plano);
        END LOOP;
         
        /* realiza calculo da data de debito para origem web e tipo 11 - Casa 3 - Vida  */
        IF pr_idorigem = 5 AND pr_tpseguro IN (3,11) AND vr_index_plano IS NOT NULL THEN
          
          --Calcular Data Debito Parcela Seguro
          pc_calcular_data_debito (pr_cdcooper => pr_cdcooper        -- Cooperativa
                                  ,pr_cdagenci => pr_cdagenci        -- Agencia
                                  ,pr_nrdcaixa => pr_nrdcaixa        -- Numero Caixa
                                  ,pr_cdoperad => pr_cdoperad        -- Operador
                                  ,pr_dtmvtolt => pr_dtmvtolt        -- Data Movimento
                                  ,pr_nrdconta => pr_nrdconta        -- Numero Conta
                                  ,pr_idseqttl => pr_idseqttl        -- Sequencial Titular
                                  ,pr_idorigem => pr_idorigem        -- Origem Informacao
                                  ,pr_nmdatela => pr_nmdatela        -- Programa Chamador
                                  ,pr_flgerlog => pr_flgerlog        -- Escrever Erro Log
                                  ,pr_flgunica => pr_flgunica        -- Parcela Unica
                                  ,pr_qtmaxpar => vr_tab_plano_seg(vr_index_plano).qtmaxpar -- Qdade Máxima Parcelas
                                  ,pr_mmpripag => vr_tab_plano_seg(vr_index_plano).mmpripag -- Mes Primeiro Pagamento
                                  ,pr_dtdebini => vr_dtdebito        -- Data Debito Inicial
                                  ,pr_dtpriini => vr_dtprideb        -- Data Primeiro Inicial
                                  ,pr_dtdebito => vr_dtdebito        -- Data Debito
                                  ,pr_dtpripag => vr_dtprideb        -- Data Primeiro Pagamento
                                  ,pr_des_erro => vr_des_erro        -- Descricao Erro
                                  ,pr_tab_erro => pr_tab_erro);      -- Tabela Erros
          --Se ocorreu erro 
          IF vr_des_erro = 'NOK' THEN
            IF pr_tab_erro.COUNT > 0 THEN
              vr_cdcritic:= pr_tab_erro(pr_tab_erro.FIRST).cdcritic;
              vr_dscritic:= pr_tab_erro(pr_tab_erro.FIRST).dscritic;
            ELSE
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao calcular data debito.';
            END IF;
            --Levantar Excecao
            RAISE vr_exc_sair;
          END IF;  
        END IF;
        
        IF pr_tpseguro = 11 THEN
          /* Este tratamento foi feito devido aos seguros que vencem 
             em feriado/final de semana, onde o mes de vencimento eh
             diferente do dia da renovacao. Nestes casos deve-se
             criar o registro com data do proximo dia util para
             contabilizar junto aos seguros do proximo mes  */ 
          IF pr_cdsitseg = 3  THEN  /* Renovacao */ 
            vr_dtmvtolt:= vr_dtprideb; 
          END IF;
          
          --Selecionar Lote  
          OPEN cr_craplot(pr_cdcooper => pr_cdcooper,
                          pr_dtmvtolt => vr_dtmvtolt,
                          pr_cdagenci => vr_tab_associado(1).cdagenci,
                          pr_cdbccxlt => pr_cdbccxlt,
                          pr_nrdolote => pr_nrdolote);
          FETCH cr_craplot INTO rw_craplot;
          
          -- Verificar se lote existe
          IF cr_craplot%NOTFOUND THEN
            -- Fechar cursor de lote
            CLOSE cr_craplot; 

            BEGIN
              -- criar registros de lote na tabela
              INSERT INTO craplot
                  (cdcooper
                  ,dtmvtolt
                  ,cdagenci
                  ,cdbccxlt
                  ,nrdolote
                  ,tplotmov
                  ,cdhistor
                  ,nrseqdig
                  ,flgltsis
                  ,tpdmoeda
                  ,qtcompln
                  ,qtinfoln
                  ,vlcompcr
                  ,vlinfocr)
              VALUES
                  (pr_cdcooper     -- cdcooper
                  ,vr_dtmvtolt     -- dtmvtolt
                  ,vr_tab_associado(1).cdagenci
                  ,pr_cdbccxlt     -- cdbccxlt
                  ,pr_nrdolote     -- nrdolote
                  ,15	             -- tplotmov							 									 
                  ,0               -- cdhistor
                  ,1               -- nrseqdig
                  ,1 /*YES*/       -- flgltsis
                  ,1               -- tpdmoeda
                  ,1               -- qtcompln
                  ,1               -- qtinfoln
                  ,pr_vlpreseg     -- vlcompcr
                  ,pr_vlpreseg)    -- vlinfocr
              RETURNING craplot.rowid 
              INTO rw_craplot.rowid;    
            EXCEPTION
              WHEN OTHERS THEN
                -- se ocorreu algum erro durante a criação 
                vr_dscritic := 'Erro ao inserir craplot: '||SQLERRM;
                RAISE vr_exc_erro;
            END;
          ELSE  
            -- Fechar cursor de lote
            CLOSE cr_craplot; 
            
            --Atualizar Lote
            BEGIN
              UPDATE craplot SET craplot.qtcompln = nvl(craplot.qtcompln,0) + 1
                                ,craplot.qtinfoln = nvl(craplot.qtinfoln,0) + 1
                                ,craplot.vlcompcr = nvl(craplot.vlcompcr,0) + nvl(pr_vlpreseg,0)
                                ,craplot.vlinfocr = nvl(craplot.vlinfocr,0) + nvl(pr_vlpreseg,0)
              WHERE craplot.rowid = rw_craplot.rowid;                  
            EXCEPTION
              WHEN OTHERS THEN
                -- se ocorreu algum erro durante a criação 
                vr_dscritic := 'Erro ao atualizar craplot: '||SQLERRM;
                RAISE vr_exc_erro;
            END;  
          END IF;
          
          --Atribuir Numero Contrato ao Sequencial
          vr_nrseqdig:= vr_nrctrseg;
          
          /* Pra nao dar erro na chave crapseg3 */
          OPEN cr_crapseg (pr_cdcooper => pr_cdcooper
                          ,pr_dtmvtolt => vr_dtmvtolt
                          ,pr_cdagenci => vr_tab_associado(1).cdagenci
                          ,pr_cdbccxlt => pr_cdbccxlt
                          ,pr_nrdolote => pr_nrdolote);
          FETCH cr_crapseg INTO rw_crapseg;
          --Se Encontrou e Retornou algum nrseqdig
          IF cr_crapseg%FOUND AND rw_crapseg.nrseqdig > 0 THEN
            vr_nrseqdig:= nvl(rw_crapseg.nrseqdig,0) + 1;
          END IF;  
          --Fechar Cursor
          CLOSE cr_crapseg;                
        END IF;
            
        --Nome Segurado
        IF vr_nmdsegur IS NULL THEN
          IF vr_tab_associado.EXISTS(1) THEN
            vr_nmdsegur:= vr_tab_associado(1).nmprimtl; 
          END IF;  
        END IF;
        
        --Fim Vigencia
        IF pr_tpseguro IN (3,4) THEN
          vr_dtfimvig:= NULL;
        ELSE
          vr_dtfimvig:= pr_dtfimvig;
        END IF;
            
        --Valor Premio
        IF pr_tpseguro = 11 AND vr_index_plano IS NOT NULL THEN
          vr_vlpremio:= vr_tab_plano_seg(vr_index_plano).vlplaseg;
        ELSE
          vr_vlpremio:= 0;
        END IF;    
                                  
        BEGIN
          INSERT INTO crawseg 
            (crawseg.dtmvtolt
            ,crawseg.dtdebito
            ,crawseg.nrdconta
            ,crawseg.nrctrseg
            ,crawseg.tpseguro
            ,crawseg.cdsegura
            ,crawseg.nrcpfcgc
            ,crawseg.nmdsegur
            ,crawseg.dtinivig
            ,crawseg.dtiniseg
            ,crawseg.dtfimvig
            ,crawseg.vlpremio
            ,crawseg.vlpreseg
            ,crawseg.cdcalcul
            ,crawseg.tpplaseg
            ,crawseg.vlseguro
            ,crawseg.dtprideb
            ,crawseg.flgunica
            ,crawseg.dsendres
            ,crawseg.nrendres
            ,crawseg.nmbairro
            ,crawseg.nmcidade
            ,crawseg.cdufresd
            ,crawseg.nrcepend
            ,crawseg.cdcooper
            ,crawseg.complend)
          VALUES 
            (vr_dtmvtolt --dtmvtolt
            ,vr_dtdebito --dtdebito
            ,pr_nrdconta --nrdconta
            ,vr_nrctrseg --nrctrseg
            ,pr_tpseguro --tpseguro
            ,vr_cdsegura --cdsegura
            ,vr_nrcpfcgc --nrcpfcgc
            ,UPPER(vr_nmdsegur) --nmdsegur
            ,pr_dtinivig --dtinivig
            ,pr_dtinivig --dtiniseg
            ,vr_dtfimvig --dtfimvig
            ,vr_vlpremio --vlpremio
            ,pr_vlpreseg --vlpreseg
            ,pr_cdcalcul --cdcalcul
            ,pr_tpplaseg --tpplaseg
            ,pr_vlseguro --vlseguro
            ,vr_dtprideb --dtprideb
            ,pr_flgunica --flgunica
            ,UPPER(pr_dsendres) --dsendres
            ,pr_nrendres --nrendres
            ,UPPER(pr_nmbairro) --nmbairro
            ,UPPER(pr_nmcidade) --nmcidade
            ,pr_cdufresd --cdufresd
            ,pr_nrcepend --nrcepend
            ,pr_cdcooper --cdcooper
            ,UPPER(pr_complend)) --complend
          RETURNING rowid 
                   ,crawseg.dtinivig
                   ,crawseg.dtfimvig
                   ,crawseg.vlpremio     
          INTO vr_rowid_crawseg
              ,rw_crawseg.dtinivig
              ,rw_crawseg.dtfimvig
              ,rw_crawseg.vlpremio;     
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic:= 'Erro ao inserir registro na crawseg. '||sqlerrm;
            --Levantar Excecao
            RAISE vr_exc_erro;
        END; 
        
        /*campos do seguro_i.p*/
        IF pr_tpseguro IN (3,4) THEN
          --Preparar valores para update 
          IF vr_reg_crapemp.nmextemp IS NOT NULL THEN
            vr_nmempres:= vr_reg_crapemp.nmextemp;
          ELSE
            vr_nmempres:= NULL;
          END IF;
          IF upper(vr_nmdsegur) = upper(vr_tab_associado(1).nmprimtl) THEN
            vr_tpsegvid:= 1;
          ELSE
            vr_tpsegvid:= 2;
          END IF;    
          IF pr_tpseguro IN (3,4) THEN   
            vr_nmbenefi:= NULL;
          ELSE
            vr_nmbenefi:= upper(vr_nmdsegur);
          END IF;    
          IF nvl(pr_cdsexosg,0) <> 0 THEN
            vr_cdsexosg:= pr_cdsexosg;
          ELSE
            vr_cdsexosg:= vr_tab_associado(1).cdsexotl;
          END IF;    
  
          BEGIN
            UPDATE crawseg SET crawseg.dtnascsg = pr_dtnascsg 
                              ,crawseg.vlbenefi = 0
                              ,crawseg.nrcadast = vr_tab_associado(1).nrcadast
                              ,crawseg.nrfonemp = vr_tab_associado(1).nrfonemp
                              ,crawseg.nrfonres = vr_tab_associado(1).nrfonres
                              ,crawseg.dsmarvei = NULL
                              ,crawseg.dstipvei = NULL
                              ,crawseg.nranovei = 0
                              ,crawseg.nrmodvei = 0
                              ,crawseg.nrdplaca = NULL
                              ,crawseg.qtpasvei = 0
                              ,crawseg.dschassi = NULL
                              ,crawseg.ppdbonus = 0
                              ,crawseg.flgdnovo = 0 /*FALSE*/
                              ,crawseg.flgrenov = 0 /*FALSE*/
                              ,crawseg.cdapoant = NULL
                              ,crawseg.nmsegant = NULL
                              ,crawseg.flgdutil = 1 /*TRUE*/
                              ,crawseg.flgnotaf = 0 /*FALSE*/
                              ,crawseg.flgapant = 0 /*FALSE*/
                              ,crawseg.vldfranq = 0
                              ,crawseg.vldcasco = 0
                              ,crawseg.vlverbae = 0
                              ,crawseg.flgassis = 0 /*FALSE*/
                              ,crawseg.vldanmat = 0
                              ,crawseg.vldanpes = 0
                              ,crawseg.vldanmor = 0
                              ,crawseg.vlappmor = 0
                              ,crawseg.vlappinv = 0
                              ,crawseg.flgcurso = 0 /*FALSE*/
                              ,crawseg.flgrepgr = 0 /*FALSE*/
                              ,crawseg.nrctrato = 0
                              ,crawseg.flgvisto = 0 /*FALSE*/
                              ,crawseg.vlfrqobr = 0
                              ,crawseg.qtparcel = 0
                              ,crawseg.nmempres = upper(vr_nmempres)
                              ,crawseg.tpsegvid = vr_tpsegvid
                              ,crawseg.nmbenefi = upper(vr_nmbenefi)
                              ,crawseg.cdsexosg = vr_cdsexosg 
                              ,crawseg.nrctrseg = vr_nrctrseg
            WHERE rowid = vr_rowid_crawseg
            RETURNING crawseg.qtparcel
            INTO rw_crawseg.qtparcel;                  
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic:= 'Erro ao atualizar crawseg(1). '||sqlerrm;
              --Levantar Excecao
              RAISE vr_exc_erro;
          END; 
        ELSE
          --Determinar Qdade Maxima Parcelas
          IF vr_tab_plano_seg(vr_index_plano).flgunica = 1 THEN
            vr_qtparcel:= 1;
          ELSIF vr_index_plano IS NOT NULL THEN
            vr_qtparcel:= vr_tab_plano_seg(vr_index_plano).qtmaxpar;
          END IF;
              
          BEGIN
            UPDATE crawseg SET crawseg.qtparcel = vr_qtparcel
            WHERE crawseg.rowid = vr_rowid_crawseg
            RETURNING crawseg.qtparcel 
            INTO rw_crawseg.qtparcel;   
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic:= 'Erro ao atualizar crawseg(2). '||sqlerrm;
              --Levantar Excecao
              RAISE vr_exc_erro;
          END;    
        END IF;
         
        --Retornar ROWID da crawseg
        pr_crawseg:= vr_rowid_crawseg;
        
        --Criar Seguro
        BEGIN
          INSERT INTO crapseg 
            (crapseg.cdcooper
            ,crapseg.cdoperad
            ,crapseg.dtmvtolt
            ,crapseg.nrseqdig
            ,crapseg.nrctrseg
            ,crapseg.cdagenci
            ,crapseg.cdbccxlt
            ,crapseg.nrdolote
            ,crapseg.cdsitseg
            ,crapseg.dtaltseg
            ,crapseg.dtcancel
            ,crapseg.dtdebito
            ,crapseg.dtinivig
            ,crapseg.dtfimvig
            ,crapseg.cdsegura
            ,crapseg.indebito
            ,crapseg.nrdconta
            ,crapseg.dtultpag
            ,crapseg.dtiniseg
            ,crapseg.qtparcel
            ,crapseg.dtprideb
            ,crapseg.flgunica
            ,crapseg.tpseguro
            ,crapseg.tpplaseg
            ,crapseg.vlpreseg
            ,crapseg.lsctrant
            ,crapseg.nmbenvid##1
            ,crapseg.nmbenvid##2
            ,crapseg.nmbenvid##3
            ,crapseg.nmbenvid##4
            ,crapseg.nmbenvid##5
            ,crapseg.txpartic##1
            ,crapseg.txpartic##2
            ,crapseg.txpartic##3
            ,crapseg.txpartic##4
            ,crapseg.txpartic##5
            ,crapseg.dsgraupr##1
            ,crapseg.dsgraupr##2
            ,crapseg.dsgraupr##3
            ,crapseg.dsgraupr##4
            ,crapseg.dsgraupr##5
            ,crapseg.cdmotcan
            ,crapseg.flgconve
            ,crapseg.nrctratu
            ,crapseg.qtprepag
            ,crapseg.qtprevig
            ,crapseg.tpdpagto
            ,crapseg.tpendcor
            ,crapseg.vldifseg
            ,crapseg.vlpremio
            ,crapseg.vlprepag)
          VALUES
            (pr_cdcooper        --cdcooper
            ,pr_cdoperad        --cdoperad
            ,vr_dtmvtolt        --dtmvtolt
            ,CASE pr_tpseguro WHEN 11 THEN vr_nrseqdig ELSE vr_nrctrseg END --nrseqdig
            ,vr_nrctrseg        --nrctrseg
            ,vr_tab_associado(1).cdagenci --cdagenci
            ,pr_cdbccxlt         --cdbccxlt
            ,pr_nrdolote         --nrdolote
            ,pr_cdsitseg         --cdsitseg
            ,pr_dtaltseg         --dtaltseg
            ,pr_dtcancel         --dtcancel
            ,vr_dtdebito         --dtdebito
            ,rw_crawseg.dtinivig --dtinivig
            ,rw_crawseg.dtfimvig --dtfimvig
            ,pr_cdsegura         --cdsegura
            ,pr_indebito         --indebito
            ,pr_nrdconta         --nrdconta
            ,CASE pr_tpseguro WHEN 11 THEN NULL ELSE vr_dtmvtolt END --dtultpag
            ,pr_dtiniseg         --dtiniseg
            ,rw_crawseg.qtparcel --qtparcel
            ,vr_dtprideb         --dtprideb
            ,pr_flgunica         --flgunica
            ,pr_tpseguro         --tpseguro
            ,pr_tpplaseg         --tpplaseg
            ,pr_vlpreseg         --vlpreseg
            ,pr_lsctrant         --lsctrant
            ,upper(pr_tab_nmbenvid(1)) --nmbenvid
            ,upper(pr_tab_nmbenvid(2))
            ,upper(pr_tab_nmbenvid(3))
            ,upper(pr_tab_nmbenvid(4))
            ,upper(pr_tab_nmbenvid(5))
            ,pr_tab_txpartic(1) --txpartic
            ,pr_tab_txpartic(2)
            ,pr_tab_txpartic(3)
            ,pr_tab_txpartic(4)
            ,pr_tab_txpartic(5)
            ,upper(pr_tab_dsgraupr(1)) --dsgraupr
            ,upper(pr_tab_dsgraupr(2))
            ,upper(pr_tab_dsgraupr(3))
            ,upper(pr_tab_dsgraupr(4))
            ,upper(pr_tab_dsgraupr(5))
            ,pr_cdmotcan          --cdmotcan
            ,pr_flgconve          --flgconve
            ,pr_nrctratu          --nrctratu
            ,pr_qtprepag          --qtprepag
            ,pr_qtprevig          --qtprevig
            ,pr_tpdpagto          --tpdpagto
            ,pr_tpendcor          --tpendcor
            ,pr_vldifseg          --vldifseg
            ,rw_crawseg.vlpremio  --vlpremio
            ,pr_vlprepag)         --vlprepag
          RETURNING crapseg.rowid 
          INTO vr_rowid_crapseg;  
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic:= 'Erro ao inserir crapseg. '||sqlerrm;
            --Levantar Excecao
            RAISE vr_exc_erro;
        END; 
        
        --Seguro Residencial
        IF pr_tpseguro IN (1,11) THEN
          BEGIN
            UPDATE crapseg SET crapseg.flgclabe = pr_flgclabe
            WHERE crapseg.rowid = vr_rowid_crapseg;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic:= 'Erro ao atualizar crapseg(1). '||sqlerrm;
              --Levantar Excecao
              RAISE vr_exc_erro;
          END; 
        END IF;
          
        --Seguro Vida ou Prestamista
        IF pr_tpseguro IN (3,4) THEN
          BEGIN
            UPDATE crapseg SET crapseg.nrseqdig = crapseg.nrctrseg
                              ,crapseg.dtprideb = CASE pr_tpseguro WHEN 3 THEN crapseg.dtprideb ELSE NULL END
                              ,crapseg.vldifseg = 0
                              ,crapseg.flgunica = 0 /* FALSE.*/
            WHERE crapseg.rowid = vr_rowid_crapseg;
          EXCEPTION
            WHEN OTHERS THEN
              vr_dscritic:= 'Erro ao atualizar crapseg(2). '||sqlerrm;
              --Levantar Excecao
              RAISE vr_exc_erro;
          END; 
        END IF;  
      EXCEPTION
        WHEN vr_exc_sair THEN
          NULL;
      END;    
      
      --Limpar tabela erros
      pr_tab_erro.DELETE;
      
      /* Caso seja efetuada alguma alteracao na descricao deste log,
         devera ser tratado o relatorio de "demonstrativo produtos por
         colaborador" da tela CONGPR. (Fabricio - 04/05/2012) */
         
      --Descricao da Origem
      vr_dsorigem:= gene0001.vr_vet_des_origens(pr_idorigem);
      --Descricao da Transacao
      vr_dstransa:= 'Efetivado o seguro do tipo: ';
      
      IF pr_tpseguro IN (1,11) THEN 
        vr_dstransa:= vr_dstransa ||'SEGURO RESIDENCIAL.';
      ELSIF pr_tpseguro = 3 THEN
        vr_dstransa:= vr_dstransa ||'SEGURO DE VIDA.';
      ELSE
        vr_dstransa:= vr_dstransa ||'SEGURO PRESTAMISTA.';
      END IF;       

      IF nvl(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN   
        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

        --Se for para gerar log
        IF pr_flgerlog THEN
          --Executar rotina geracao log
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => vr_dsorigem
                              ,pr_dstransa => vr_dstransa
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0 /*FALSE*/
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);  
          --Retorna Erro
          pr_des_erro:= 'NOK';
          RETURN;                          
        END IF;
      END IF;                       
                             
      --Se for para gerar log
      IF pr_flgerlog THEN
        --Executar rotina geracao log
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1 /*TRUE*/
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);        
      END IF;
      
      /* Abaixo e verificado se e seguro de VIDA e para os planos abaixo, 
        retorna par_flgsegur = true para mensagen alerta */ 
      IF pr_tpseguro = 3 AND pr_tpplaseg IN (11,15,21,31,41,51,61) THEN 
        pr_flgsegur:= TRUE;
      ELSE
        pr_flgsegur:= FALSE;
      END IF;
      
      --Retorno OK
      pr_des_erro:= 'OK';   
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_des_erro:= 'NOK';
        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);                
        
      WHEN OTHERS THEN
        pr_des_erro:= 'NOK';
        --Mensagem Erro
        vr_cdcritic:= 0;
        vr_dscritic:= 'Erro na rotina segu0001.pc_cria_seguro. '||sqlerrm;
        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);                
    END;      
  END pc_cria_seguro;                             

  -- Rotina para verificar pacote de tarifas via web
  PROCEDURE pc_buscar_plaseg_web(pr_nrdconta IN crapass.nrdconta%TYPE  --> Numero da Conta                                 
                                ,pr_cdsegura IN crapseg.cdsegura%type -- Codigo Seguradora
                                ,pr_tpseguro IN craptsg.tpseguro%type -- Tipo Seguro
                                ,pr_tpplaseg IN craptsg.tpplaseg%type -- Tipo Plano Seguro
                                ,pr_xmllog   IN VARCHAR2               --> XML com informações de LOG
                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo da Critica
                                ,pr_dscritic OUT crapcri.dscritic%TYPE --> Descrição da crítica
                                ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
  BEGIN                              
    DECLARE 
    
      --Tabelas de Dados
      vr_tab_plano_seg  segu0001.typ_tab_plano_seg;
    
      --Variaveis Indice
      vr_index_plano      PLS_INTEGER;
      vr_achou_plano      BOOLEAN;
      
     -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);
      
      --Variaveis de Erro
      vr_cdcritic integer;
      vr_dscritic varchar2(4000);
      vr_des_erro varchar2(3); 
      vr_tab_erro GENE0001.typ_tab_erro;
      
      vr_exc_sair EXCEPTION;
      vr_exc_erro EXCEPTION;
    
    BEGIN   
  
       -- Recupera dados de log para consulta posterior
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Verifica se houve erro recuperando informacoes de log                              
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;       
  
        --Buscar Plano Seguro
      pc_buscar_plano_seguro (pr_cdcooper => vr_cdcooper        -- Cooperativa
                             ,pr_cdagenci => vr_cdagenci        -- Agencia
                             ,pr_nrdcaixa => vr_nrdcaixa        -- Numero Caixa
                             ,pr_cdoperad => Vr_cdoperad        -- Operador
                             ,pr_dtmvtolt => SYSDATE --pr_dtmvtolt        -- Data Movimento
                             ,pr_nrdconta => pr_nrdconta        -- Numero Conta
                             ,pr_idseqttl => 1                  -- Sequencial Titular
                             ,pr_idorigem => vr_idorigem        -- Origem Informacao
                             ,pr_nmdatela => vr_nmdatela        -- Programa Chamador
                             ,pr_flgerlog => TRUE               -- Escrever Erro Log
                             ,pr_cdsegura => pr_cdsegura        -- Codigo Seguradora
                             ,pr_tpseguro => pr_tpseguro        -- Tipo Seguro
                             ,pr_tpplaseg => pr_tpplaseg        -- Tipo Plano Seguro
                             ,pr_tab_plano_seg => vr_tab_plano_seg   -- Tabela Plano Seguros
                             ,pr_des_erro => vr_des_erro        -- Descricao Erro
                             ,pr_tab_erro => vr_tab_erro);      -- Tabela Erros
      --Se ocorreu erro
      IF vr_des_erro = 'NOK' THEN
        IF vr_tab_erro.COUNT > 0 THEN
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro ao buscar plano seguro.';
        END IF;
        --Levantar Excecao
        RAISE vr_exc_sair;
      END IF; 
         
      --Encontrar o Primeiro Plano
      vr_achou_plano := FALSE;
      vr_index_plano := vr_tab_plano_seg.FIRST;
      
      WHILE vr_index_plano IS NOT NULL LOOP
        
        IF vr_tab_plano_seg(vr_index_plano).cdcooper = vr_cdcooper AND
           vr_tab_plano_seg(vr_index_plano).cdsegura = pr_cdsegura AND
           vr_tab_plano_seg(vr_index_plano).tpseguro = pr_tpseguro AND
           vr_tab_plano_seg(vr_index_plano).tpplaseg = pr_tpplaseg THEN
           
           vr_achou_plano := TRUE;
           EXIT; 
           
        END IF;   
        
        --Proximo Registro
        vr_index_plano:= vr_tab_plano_seg.NEXT(vr_index_plano);
      END LOOP;
      
      --Se encontrou o plano devolve os dados      
      IF vr_achou_plano THEN
         pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="UTF-8"?>' ||
                                        '<dados/>');
        
         gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dados', pr_posicao => 0, pr_tag_nova => 'vlplaseg', pr_tag_cont => To_Char(NVL(vr_tab_plano_seg(vr_index_plano).vlplaseg,0),'fm999g999g999g990d00'), pr_des_erro => vr_dscritic);  --valor do plano 
      ELSE
          vr_cdcritic:= 0;
          vr_dscritic:= 'Erro ao buscar plano seguro.';
          --Levantar Excecao
          RAISE vr_exc_sair;           
      END IF;
                            
      --Retorno OK
      pr_des_erro:= 'OK';   
    EXCEPTION
      WHEN vr_exc_sair THEN
        -- Retorno não OK          
        pr_des_erro:= 'NOK';
        
        -- Erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
        
        -- Existe para satisfazer exigência da interface. 
      	pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
        
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        -- Erro
        pr_cdcritic:= 0;
        pr_dscritic:= 'Erro na rotina SEGU0001.pc_buscar_seguros. '||SQLERRM;
        
        -- Existe para satisfazer exigência da interface. 
      	pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');        
    END;      
  END pc_buscar_plaseg_web;


END SEGU0001;
/
