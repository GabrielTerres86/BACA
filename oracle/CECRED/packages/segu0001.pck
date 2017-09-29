CREATE OR REPLACE PACKAGE CECRED.SEGU0001 AS

/*..............................................................................

    Programa: SEGU0001 (Antigo b1wgen0045.p)
    Autor   : Guilherme/SUPERO
    Data    : Outubro/2009                       Ultima Atualizacao: 03/07/2017

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

                25/05/2016 - PRJ 187.2 - Seguros Sicredi (Guilherme/SUPERO)

                20/06/2016 - Correcao para o uso correto do indice da CRAPTAB em procedures
                             desta package.(Carlos Rafael Tanholi).

                03/08/2016 - Retirados os campos 'flgcrdpa'	e cdoplcpa da tabela
                             temporaria de associados. Projeto 299/3 - Pre Aprovado (Lombardi).

                26/10/2016 - PRJ 187.2 - Ajuste nas datas na importação (Guilherme/SUPERO)

				26/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                 crapass, crapttl, crapjur 
							 (Adriano - P339).
  
                03/07/2017 - Incluido rotina de setar modulo Oracle 
                           - Implementado Log no padrão
                             ( Belli - Envolti - #667957)
  
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
    (nrmatric  crapass.nrmatric%type
    ,indnivel  crapass.indnivel%type
    ,nrdconta  crapass.nrdconta%type
    ,cdagenci  crapass.cdagenci%type
    ,nrcadast  crapass.nrcadast%type
    ,nmprimtl  crapass.nmprimtl%type
    ,dtnasctl  crapass.dtnasctl%type
    ,dsnacion  crapnac.dsnacion%type
    ,dsproftl  crapass.dsproftl%type
    ,dtadmiss  crapass.dtadmiss%type
    ,dtdemiss  crapass.dtdemiss%TYPE
    ,nrcpfcgc  crapass.nrcpfcgc%type
    ,dtultalt  crapass.dtultalt%type
    ,tpdocptl  crapass.tpdocptl%type
    ,nrdocptl  crapass.nrdocptl%type
    ,cdsexotl  crapass.cdsexotl%type
    ,dsfiliac  crapass.dsfiliac%type
    ,dtadmemp  crapass.dtadmemp%type
    ,cdturnos  crapass.cdturnos%type
    ,nrramemp  crapass.nrramemp%type
    ,nrctacto  crapass.nrctacto%type
    ,cdtipsfx  crapass.cdtipsfx%type
    ,cddsenha  crapass.cddsenha%type
    ,cdsecext  crapass.cdsecext%type
    ,cdsitdct  crapass.cdsitdct%type
    ,cdsitdtl  crapass.cdsitdtl%type
    ,cdsrcheq  crapass.cdsrcheq%type
    ,cdtipcta  crapass.cdtipcta%type
    ,dtabtcct  crapass.dtabtcct%type
    ,dtasitct  crapass.dtasitct%type
    ,dtatipct  crapass.dtatipct%type
    ,dtcnsspc  crapass.dtcnsspc%type
    ,dtdsdspc  crapass.dtdsdspc%type
    ,inadimpl  crapass.inadimpl%type
    ,inedvmto  crapass.inedvmto%type
    ,inlbacen  crapass.inlbacen%type
    ,nrflcheq  crapass.nrflcheq%type
    ,qtextmes  crapass.qtextmes%type
    ,vllimcre  crapass.vllimcre%type
    ,dsregcas  gnetcvl.dsestcvl%TYPE
    ,nmsegntl  crapttl.nmextttl%type
    ,tpdocstl  crapttl.tpdocttl%type
    ,nrdocstl  crapttl.nrdocttl%type
    ,cdgraupr  crapttl.cdgraupr%type
    ,dtultlcr  crapass.dtultlcr%type
    ,inpessoa  crapass.inpessoa%type
    ,inmatric  crapass.inmatric%type
    ,inisipmf  crapass.inisipmf%type
    ,tplimcre  crapass.tplimcre%type
    ,dtnasstl  crapttl.dtnasttl%type
    ,dsfilstl  VARCHAR2(140)
    ,nrcpfstl  crapttl.nrcpfcgc%type
    ,dtelimin  crapass.dtelimin%type
    ,vledvmto  crapass.vledvmto%type
    ,dtedvmto  crapass.dtedvmto%type
    ,qtfolmes  crapass.qtfolmes%type
    ,tpextcta  crapass.tpextcta%type
    ,cdoedptl  tbgen_orgao_expedidor.cdorgao_expedidor%TYPE
    ,cdoedstl  tbgen_orgao_expedidor.cdorgao_expedidor%TYPE
    ,cdoedrsp  tbgen_orgao_expedidor.cdorgao_expedidor%TYPE
    ,cdufdptl  crapass.cdufdptl%type
    ,cdufdstl  crapttl.cdufdttl%type
    ,cdufdrsp  crapcrl.cdufiden%type
    ,nmrespon  crapcrl.nmrespon%type
    ,inhabmen  crapttl.inhabmen%type
    ,nrcpfrsp  crapcrl.nrcpfcgc%type
    ,nrdocrsp  crapcrl.nridenti%type
    ,tpdocrsp  crapcrl.tpdeiden%type
    ,dtemdstl  crapttl.dtemdttl%type 
    ,dtemdptl  crapass.dtemdptl%type
    ,dtemdrsp  crapcrl.dtemiden%type
    ,tpavsdeb  crapass.tpavsdeb%type
    ,iniscpmf  crapass.iniscpmf%type
    ,nrctaprp  crapass.nrctaprp%type
    ,cdoedttl  tbgen_orgao_expedidor.cdorgao_expedidor%TYPE
    ,cdufdttl  crapttl.cdufdttl%type
    ,dsfilttl  VARCHAR2(134)
    ,dtnasttl  crapttl.dtnasttl%type
    ,nmtertl   crapttl.nmextttl%type
    ,nrcpfttl  crapttl.nrcpfcgc%type
    ,nrdocttl  crapttl.nrdocttl%type
    ,tpdocttl  crapttl.tpdocttl%type
    ,dtemdttl  crapttl.dtemdttl%type
    ,tpvincul  crapass.tpvincul%type
    ,nrfonemp  craptfc.nrtelefo%type
    ,dtcnscpf  crapass.dtcnscpf%type
    ,cdsitcpf  crapass.cdsitcpf%type
    ,nmpaittl  crapttl.nmpaittl%type
    ,nmpaistl  crapttl.nmpaittl%type
    ,nmpaiptl  crapass.nmpaiptl%type
    ,nmmaettl  crapttl.nmmaettl%type
    ,nmmaestl  crapttl.nmmaettl%type
    ,nmmaeptl  crapass.nmmaeptl%type
    ,inccfcop  crapass.inccfcop%type
    ,dtccfcop  crapass.dtccfcop%type
    ,indrisco  crapass.indrisco%TYPE
    ,inarqcbr  crapass.inarqcbr%TYPE
    ,dsdemail  crapcem.dsdemail%type
    ,qtfoltal  crapass.qtfoltal%type
    ,nrdctitg  crapass.nrdctitg%type
    ,flchqitg  crapass.flchqitg%type
    ,flgctitg  crapass.flgctitg%type
    ,dtabcitg  crapass.dtabcitg%type
    ,nrctainv  crapass.nrctainv%TYPE
    ,cdoperat  crapass.cdoperat%type
    ,flgatrat  crapass.flgatrat%type
    ,dtaturat  crapass.dtaturat%type
    ,vlutlrat  crapass.vlutlrat%type
    ,flgiddep  crapass.flgiddep%type
    ,dtlimdeb  crapass.dtlimdeb%type
    ,cdcooper  crapass.cdcooper%type
    ,vllimdeb  crapass.vllimdeb%type
    ,cdmotdem  crapass.cdmotdem%type
    ,flgdbitg  crapass.flgdbitg%type
    ,dsnivris  crapass.dsnivris%type
    ,dtectitg  crapass.dtectitg%type
    ,cdopedem  crapass.cdopedem%type
    ,dtmvtolt  crapass.dtmvtolt%type
    ,cdbantrf  crapass.cdbantrf%type
    ,cdagetrf  crapass.cdagetrf%type
    ,nrctatrf  crapass.nrctatrf%type
    ,dtmvcitg  crapass.dtmvcitg%type
    ,dtcnsscr  crapass.dtcnsscr%type
    ,nrcpfppt  crapass.nrcpfppt%type
    ,dtdevqst  crapass.dtdevqst%type
    ,dtentqst  crapass.dtentqst%type
    ,cdbcochq  crapass.cdbcochq%type
    ,dtcadqst  crapass.dtcadqst%type
    ,nrnotatl  crapass.nrnotatl%type
    ,inrisctl  crapass.inrisctl%type
    ,dtrisctl  crapass.dtrisctl%type
    ,flgrestr  crapass.flgrestr%type
    ,nrctacns  crapass.nrctacns%type
    ,progress_recid  crapass.progress_recid%type
    ,nrempcrd  crapass.nrempcrd%type
    ,inserasa  crapass.inserasa%type
    ,incadpos  crapass.incadpos%type
    ,flgrenli  crapass.flgrenli%type
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

  -- Tabela DE/PARA de plano de seguros inativos
  TYPE typ_rec_pldepara IS RECORD
    (cdsegura craptsg.cdsegura%type
    ,tpseguro crapseg.tpseguro%type
    ,tpplasde crapseg.tpplaseg%type
    ,tpplaspa crapseg.tpplaseg%TYPE);
  TYPE typ_tab_pldepara
    IS TABLE OF typ_rec_pldepara
     INDEX BY PLS_INTEGER;

  -- Destinados para passagem de parametros para criação do seguro
  TYPE tp_tab_seguros IS TABLE OF tbseg_contratos%ROWTYPE INDEX BY PLS_INTEGER;

  TYPE tp_tab_auto IS TABLE OF tbseg_auto_veiculos%ROWTYPE INDEX BY PLS_INTEGER;

  TYPE tp_tab_vida IS TABLE OF tbseg_vida_benefici%ROWTYPE INDEX BY PLS_INTEGER;

  TYPE tp_tab_casa IS TABLE OF tbseg_vida_benefici%ROWTYPE INDEX BY PLS_INTEGER;

  TYPE tp_tab_prst IS TABLE OF tbseg_vida_benefici%ROWTYPE INDEX BY PLS_INTEGER;

  -- Flags de Atualização para typ_reg_flg_atuos Seguros
  TYPE typ_reg_flg_atu IS RECORD
    (tp_seguro VARCHAR(1)
    ,tp_auto   VARCHAR2(1)
    ,tp_vida   VARCHAR2(1)
    ,tp_casa   VARCHAR2(1)
    ,tp_prst   VARCHAR2(1));

  -- Cursor genérico de calendário
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;

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
                              ,pr_tab_seguros OUT SEGU0001.typ_tab_seguros -- Tabela de Seguros
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

  -- Efetuar a importação dos dados Seguro Auto Sicredi recebido separado por ";" (SEGURO_CECRED_AAAAMMDD)
  PROCEDURE pc_importa_seg_auto_sicr(pr_cdcooper IN PLS_INTEGER);

  --Procedimento para Criar o Seguro
  PROCEDURE pc_insere_seguro (pr_seguros  IN tp_tab_seguros     -- Tabela de Seguros
                             ,pr_auto     IN tp_tab_auto        -- Tabela de Veiculos Segurados
                             ,pr_vida     IN tp_tab_vida        -- Tabela de Beneficiarios Seg.Vida
                             ,pr_casa     IN tp_tab_casa        -- Tabela de Casa do seguro (Não existe, apenas inserido para definir parametros)
                             ,pr_prst     IN tp_tab_prst        -- Tabela de Prestamistas (Não existe, apenas inserido para definir parametros)
                             ,pr_tipatu   IN SEGU0001.typ_reg_flg_atu    -- Contem os 4 indicadores de atualização dos seguros: Auto, Vida, Casa, Prestamista
                             ,pr_flgsegur OUT BOOLEAN           -- Seguro Criado TRUE ou FALSE
                             ,pr_indierro OUT NUMBER            -- Indica se o erro retornado é para o log ou arquivo especifico
                             ,pr_des_erro OUT VARCHAR2          -- Retorno Erro OK/NOK
                             ,pr_tab_erro OUT gene0001.typ_tab_erro);  --Tabela Erros
END SEGU0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.SEGU0001 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : SEGU0001
  --  Sistema  : Procedimentos para Seguros
  --  Sigla    : CRED
  --  Autor    : Douglas Pagel
  --  Data     : Novembro/2013.                   Ultima atualizacao: 03/07/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para busca de dados de seguros
  --
  -- Alteracao : 22/08/2016 - Criada procedure pc_buscar_plaseg_web que buscar o valor do plano
  --                          de acordo com os parametros (Tiago/Thiago #462910)
  --
  --             19/06/2017 - #642644 Alterado o nome do arquivo gerado em pc_importa_seg_auto_sicr e
  --                          enviado como anexo no e-mail, de ERRO_ARQ_SEG% para RESUMO_ARQ_SEG% (Carlos)
  --
  --             26/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
  --		                  crapass, crapttl, crapjur 
  --				  		  (Adriano - P339).
  --             03/07/2017 - Incluido rotina de setar modulo Oracle 
  --                        - Implementado Log no padrão
  --                          ( Belli - Envolti - #667957)
  --
  ---------------------------------------------------------------------------------------------------------------
  -- Busca dos dados da cooperativa
  CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%type) IS
    SELECT cop.nmrescop
          ,cop.nmextcop
          ,cop.dsemlcof
    FROM crapcop cop
    WHERE cop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;


  rw_tab_seguros  tp_tab_seguros;
  rw_tab_auto     tp_tab_auto;
  rw_tab_vida     tp_tab_vida;
  rw_tab_casa     tp_tab_casa;
  rw_tab_prst     tp_tab_prst;

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
  --  Data     : Novembro/2013.                   Ultima atualizacao: 03/07/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Retorna quantidade de seguros novos e cancelados do tipo e periodo informado
  --
  -- Alterações:
  --             03/07/2017 - Incluido rotina de setar modulo Oracle 
  --                          ( Belli - Envolti - #667957)
  -- 
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
    
      -- Inclusão da rotina de setar módulo - Chamado 667957 - 03/07/2017
      GENE0001.pc_set_modulo(pr_module => null, pr_action => 'SEGU0001.pc_contabiliza');      

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
  --  Data     : Novembro/2013.                   Ultima atualizacao: 03/07/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para buscar taxas dos seguros
  --
  -- Alterações:
  --             03/07/2017 - Incluido rotina de setar modulo Oracle 
  --                          ( Belli - Envolti - #667957)
  -- 
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
    
    -- Inclusão da rotina de setar módulo - Chamado 667957 - 03/07/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'SEGU0001.pc_busca_dados_seg');      

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
       -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
       CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
       
       -- Descrição do erro            
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
  --  Data     : Novembro/2013.                   Ultima atualizacao: 03/07/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para buscar valores dos seguros
  --
  -- Alterações:
  --             03/07/2017 - Incluido rotina de setar modulo Oracle 
  --                          ( Belli - Envolti - #667957)
  -- 

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
    
    -- Inclusão da rotina de setar módulo - Chamado 667957 - 03/07/2017
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'SEGU0001.pc_seguros_resid_vida');      

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
      -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
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
  --  Data     : Novembro/2013.                   Ultima atualizacao: 03/07/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para buscar seguros de automovel
  --
  -- Alterações:
  --             03/07/2017 - Incluido rotina de setar modulo Oracle 
  --                          ( Belli - Envolti - #667957)
  -- 

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
    
      -- Inclusão da rotina de setar módulo - Chamado 667957 - 03/07/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'SEGU0001.pc_seguros_auto');      

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
        -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
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
  --  Data     : Abril/2015.                   Ultima atualizacao: 03/07/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para buscar informacoes do associado
  --
  -- Alteracoes: 29/01/2016 - Alteracao de flginspc para inserasa - Pre-Aprovado fase II.
  --                          (Jaison/Anderson)
  --
  --             03/07/2017 - Incluido rotina de setar modulo Oracle 
  --                          ( Belli - Envolti - #667957)
  --
  --             17/04/2017 - Buscar a nacionalidade com CDNACION. (Jaison/Andrino)
  --
  --             24/07/2017 - Alterar cdoedptl para idorgexp.
  --                          PRJ339-CRM  (Odirlei-AMcom)
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

   CURSOR cr_crapttl(pr_cdcooper crapttl.cdcooper%TYPE
                       ,pr_nrdconta crapttl.nrdconta%TYPE
                       ,pr_idseqttl crapttl.idseqttl%TYPE)IS
      SELECT crapttl.nmextttl
            ,crapttl.nrdocttl
            ,crapttl.inhabmen
            ,crapttl.tpdocttl
            ,crapttl.cdestcvl
            ,crapttl.dtnasttl
            ,crapttl.nmpaittl
            ,crapttl.nrcpfcgc
            ,crapttl.idorgexp
            ,crapttl.cdufdttl
            ,crapttl.nmmaettl
            ,crapttl.dtemdttl
            ,crapttl.cdgraupr
        FROM crapttl
       WHERE crapttl.cdcooper = pr_cdcooper
         AND crapttl.nrdconta = pr_nrdconta
       AND crapttl.idseqttl = pr_idseqttl;
      rw_crapttl1 cr_crapttl%ROWTYPE;
      rw_crapttl2 cr_crapttl%ROWTYPE;
      rw_crapttl3 cr_crapttl%ROWTYPE;

      CURSOR cr_crapcem(pr_cdcooper crapcem.cdcooper%TYPE
                       ,pr_nrdconta crapcem.nrdconta%TYPE)IS
      SELECT crapcem.dsdemail
        FROM crapcem
       WHERE crapcem.cdcooper = pr_cdcooper
         AND crapcem.nrdconta = pr_nrdconta
         AND crapcem.idseqttl = 1
         AND crapcem.cddemail = 1;

      CURSOR cr_crapcrl(pr_cdcooper IN rw_crapass.cdcooper%TYPE
                       ,pr_nrctamen IN rw_crapass.nrdconta%TYPE)IS
      SELECT crapcrl.idorgexp
            ,crapcrl.cdufiden
            ,crapcrl.nmrespon
            ,crapcrl.nrcpfmen
            ,crapcrl.nridenti
            ,crapcrl.tpdeiden
            ,crapcrl.dtemiden
        FROM crapcrl                       
       WHERE crapcrl.cdcooper = pr_cdcooper
         AND crapcrl.nrctamen = pr_nrctamen
         AND crapcrl.idseqmen = 1;
      rw_crapcrl cr_crapcrl%ROWTYPE;
         
      CURSOR cr_gnetcvl(pr_cdestcvl IN gnetcvl.cdestcvl%TYPE)IS
      SELECT gnetcvl.dsestcvl
        FROM gnetcvl
       WHERE gnetcvl.cdestcvl = pr_cdestcvl;
      rw_gnetcvl cr_gnetcvl%ROWTYPE;

      CURSOR cr_craptfc (pr_cdcooper IN craptrf.cdcooper%TYPE
                        ,pr_nrdconta IN craptrf.nrdconta%TYPE
                        ,pr_tptelefo IN craptfc.tptelefo%TYPE) IS
      SELECT f.nrdddtfc,
             f.nrtelefo,
             f.tptelefo
        FROM craptfc f
       WHERE f.progress_recid = (SELECT min(f1.progress_recid)
                                   FROM craptfc f1
                                  WHERE f1.cdcooper = pr_cdcooper
                                    AND f1.nrdconta = pr_nrdconta
                                    AND f1.tptelefo = pr_tptelefo);
      rw_craptfc cr_craptfc%rowtype;

	  -- Busca a Nacionalidade
      CURSOR cr_crapnac(pr_cdnacion IN crapnac.cdnacion%TYPE) IS
        SELECT crapnac.dsnacion
          FROM crapnac
         WHERE crapnac.cdnacion = pr_cdnacion;

      --Variaveis Locais
      vr_dsorigem VARCHAR2(1000);
      vr_dstransa VARCHAR2(1000);
      vr_nrdrowid ROWID;
      vr_index    PLS_INTEGER;
      vr_dsnacion crapnac.dsnacion%TYPE;
      vr_cdorgexp tbgen_orgao_expedidor.cdorgao_expedidor%TYPE;
      vr_nmorgexp tbgen_orgao_expedidor.nmorgao_expedidor%TYPE;


      --Variaveis de Erro
      vr_cdcritic integer;
      vr_dscritic varchar2(4000);

      vr_exc_sair EXCEPTION;
      vr_exc_erro EXCEPTION;
      vr_dsestcvl gnetcvl.dsestcvl%TYPE;
      vr_inhabmen crapttl.inhabmen%TYPE;
      vr_dsdemail crapcem.dsdemail%TYPE;
      vr_nrfonres VARCHAR2(20);

    BEGIN

      -- Inclusão da rotina de setar módulo - Chamado 667957 - 03/07/2017
      GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'SEGU0001.pc_buscar_associados');      

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

	      IF rw_crapass.inpessoa = 1 THEN

          --Busca informações do titular da conta
          OPEN cr_crapttl(pr_cdcooper => rw_crapass.cdcooper
                         ,pr_nrdconta => rw_crapass.nrdconta
                         ,pr_idseqttl => 1);

          FETCH cr_crapttl INTO rw_crapttl1;

          CLOSE cr_crapttl;

          vr_inhabmen := rw_crapttl1.inhabmen;

          --Busca informações do responsável legal do titular
          OPEN cr_crapcrl(pr_cdcooper => rw_crapass.cdcooper
                         ,pr_nrctamen => rw_crapass.nrdconta);

          FETCH cr_crapcrl INTO rw_crapcrl;

          CLOSE cr_crapcrl;
          
          -- Buscar telefone do associado Residencial
          OPEN cr_craptfc(pr_cdcooper => rw_crapass.cdcooper
                         ,pr_nrdconta => rw_crapass.nrdconta
                         ,pr_tptelefo => 1); -- Residencial
                         
          FETCH cr_craptfc INTO rw_craptfc;
          
          IF cr_craptfc%NOTFOUND THEN
             CLOSE cr_craptfc;
          ELSE
             vr_nrfonres := rw_craptfc.nrdddtfc || rw_craptfc.nrtelefo;
             CLOSE cr_craptfc;
          END IF;

          OPEN cr_gnetcvl(pr_cdestcvl => rw_crapttl1.cdestcvl);

          FETCH cr_gnetcvl INTO vr_dsestcvl;

          CLOSE cr_gnetcvl;

          --Busca informações do segundo titular 
          OPEN cr_crapttl(pr_cdcooper => rw_crapass.cdcooper
                          ,pr_nrdconta => rw_crapass.nrdconta
                  ,pr_idseqttl => 2);

          FETCH cr_crapttl INTO rw_crapttl2;

          CLOSE cr_crapttl;

          --Busca informações do terceiro titular
          OPEN cr_crapttl(pr_cdcooper => rw_crapass.cdcooper
                          ,pr_nrdconta => rw_crapass.nrdconta
                  ,pr_idseqttl => 2);

          FETCH cr_crapttl INTO rw_crapttl3;

          CLOSE cr_crapttl;

        END IF;

        /* Emails */
        OPEN cr_crapcem (pr_cdcooper => rw_crapass.cdcooper
                        ,pr_nrdconta => rw_crapass.nrdconta);

        FETCH cr_crapcem INTO vr_dsdemail;
    		
        --Fechar Cursor
        CLOSE cr_crapcem;

        vr_index:= pr_tab_associado.COUNT + 1;

        -- Busca a Nacionalidade
        vr_dsnacion := '';
        OPEN  cr_crapnac(pr_cdnacion => rw_crapass.cdnacion);
        FETCH cr_crapnac INTO vr_dsnacion;
        CLOSE cr_crapnac;

        vr_cdorgexp := NULL;
        vr_nmorgexp := NULL;
        IF nvl(rw_crapass.idorgexp,0) <> 0 THEN 
          --> Buscar orgão expedidor
          cada0001.pc_busca_orgao_expedidor(pr_idorgao_expedidor => rw_crapass.idorgexp, 
                                            pr_cdorgao_expedidor => vr_cdorgexp, 
                                            pr_nmorgao_expedidor => vr_nmorgexp, 
                                            pr_cdcritic          => vr_cdcritic, 
                                            pr_dscritic          => vr_dscritic);
          IF nvl(vr_cdcritic,0) > 0 OR 
             TRIM(vr_dscritic) IS NOT NULL THEN
            vr_cdorgexp := NULL;
            vr_nmorgexp := NULL; 
            vr_cdcritic := NULL;
            vr_dscritic := NULL;
          END IF;                                     
        END IF;                                   

        pr_tab_associado(vr_index).nrmatric:= rw_crapass.nrmatric;
        pr_tab_associado(vr_index).indnivel:= rw_crapass.indnivel;
        pr_tab_associado(vr_index).nrdconta:= rw_crapass.nrdconta;
        pr_tab_associado(vr_index).cdagenci:= rw_crapass.cdagenci;
        pr_tab_associado(vr_index).nrcadast:= rw_crapass.nrcadast;
        pr_tab_associado(vr_index).nmprimtl:= rw_crapass.nmprimtl;
        pr_tab_associado(vr_index).dtnasctl:= rw_crapass.dtnasctl;
        pr_tab_associado(vr_index).dsnacion:= vr_dsnacion;
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
        pr_tab_associado(vr_index).dsregcas:= vr_dsestcvl;
        pr_tab_associado(vr_index).nmsegntl:= rw_crapttl2.nmextttl;
        pr_tab_associado(vr_index).tpdocstl:= rw_crapttl2.tpdocttl;
        pr_tab_associado(vr_index).nrdocstl:= rw_crapttl2.nrdocttl;
        pr_tab_associado(vr_index).cdgraupr:= rw_crapttl1.cdgraupr;
        pr_tab_associado(vr_index).dtultlcr:= rw_crapass.dtultlcr;
        pr_tab_associado(vr_index).inpessoa:= rw_crapass.inpessoa;
        pr_tab_associado(vr_index).inmatric:= rw_crapass.inmatric;
        pr_tab_associado(vr_index).inisipmf:= rw_crapass.inisipmf;
        pr_tab_associado(vr_index).tplimcre:= rw_crapass.tplimcre;
        pr_tab_associado(vr_index).dtnasstl:= rw_crapttl2.dtnasttl;
        pr_tab_associado(vr_index).dsfilstl:= rw_crapttl2.nmpaittl || ' - ' || rw_crapttl2.nmmaettl;
        pr_tab_associado(vr_index).nrcpfstl:= rw_crapttl2.nrcpfcgc;
        pr_tab_associado(vr_index).dtelimin:= rw_crapass.dtelimin;
        pr_tab_associado(vr_index).vledvmto:= rw_crapass.vledvmto;
        pr_tab_associado(vr_index).dtedvmto:= rw_crapass.dtedvmto;
        pr_tab_associado(vr_index).qtfolmes:= rw_crapass.qtfolmes;
        pr_tab_associado(vr_index).tpextcta:= rw_crapass.tpextcta;
        pr_tab_associado(vr_index).cdoedptl:= vr_cdorgexp;
        
        vr_cdorgexp := NULL;
        vr_nmorgexp := NULL;
        IF nvl(rw_crapttl2.idorgexp,0) <> 0 THEN
          --> Buscar orgão expedidor
          cada0001.pc_busca_orgao_expedidor(pr_idorgao_expedidor => rw_crapttl2.idorgexp, 
                                            pr_cdorgao_expedidor => vr_cdorgexp, 
                                            pr_nmorgao_expedidor => vr_nmorgexp, 
                                            pr_cdcritic          => vr_cdcritic, 
                                            pr_dscritic          => vr_dscritic);
          IF nvl(vr_cdcritic,0) > 0 OR 
             TRIM(vr_dscritic) IS NOT NULL THEN
            vr_cdorgexp := NULL;
            vr_nmorgexp := NULL; 
            vr_cdcritic := NULL;
            vr_dscritic := NULL;
          END IF; 
        END IF; 
        pr_tab_associado(vr_index).cdoedstl:= vr_cdorgexp;
        
        vr_cdorgexp := NULL;
        vr_nmorgexp := NULL;
        --> Buscar orgão expedidor
        IF nvl(rw_crapcrl.idorgexp,0) <> 0 THEN
          cada0001.pc_busca_orgao_expedidor(pr_idorgao_expedidor => rw_crapcrl.idorgexp, 
                                            pr_cdorgao_expedidor => vr_cdorgexp, 
                                            pr_nmorgao_expedidor => vr_nmorgexp, 
                                            pr_cdcritic          => vr_cdcritic, 
                                            pr_dscritic          => vr_dscritic);
          IF nvl(vr_cdcritic,0) > 0 OR 
             TRIM(vr_dscritic) IS NOT NULL THEN
            vr_cdorgexp := NULL;
            vr_nmorgexp := NULL; 
            vr_cdcritic := NULL;
            vr_dscritic := NULL;          
          END IF; 
        END IF; 
        
        pr_tab_associado(vr_index).cdoedrsp:= vr_cdorgexp;
        
        pr_tab_associado(vr_index).cdufdptl:= rw_crapass.cdufdptl;
        pr_tab_associado(vr_index).cdufdstl:= rw_crapttl2.cdufdttl;
        pr_tab_associado(vr_index).cdufdrsp:= rw_crapcrl.cdufiden;
        pr_tab_associado(vr_index).nmrespon:= rw_crapcrl.nmrespon;
        pr_tab_associado(vr_index).inhabmen:= vr_inhabmen;
        pr_tab_associado(vr_index).nrcpfrsp:= rw_crapcrl.nrcpfmen;
        pr_tab_associado(vr_index).nrdocrsp:= rw_crapcrl.nridenti;
        pr_tab_associado(vr_index).tpdocrsp:= rw_crapcrl.tpdeiden;
        pr_tab_associado(vr_index).dtemdstl:= rw_crapttl2.dtemdttl;
        pr_tab_associado(vr_index).dtemdptl:= rw_crapass.dtemdptl;
        pr_tab_associado(vr_index).dtemdrsp:= rw_crapcrl.dtemiden;
        pr_tab_associado(vr_index).tpavsdeb:= rw_crapass.tpavsdeb;
        pr_tab_associado(vr_index).iniscpmf:= rw_crapass.iniscpmf;
        pr_tab_associado(vr_index).nrctaprp:= rw_crapass.nrctaprp;
        
        vr_cdorgexp := NULL;
        vr_nmorgexp := NULL;
        --> Buscar orgão expedidor
        IF nvl(rw_crapttl3.idorgexp,0) <> 0 THEN
          cada0001.pc_busca_orgao_expedidor(pr_idorgao_expedidor => rw_crapttl3.idorgexp, 
                                            pr_cdorgao_expedidor => vr_cdorgexp, 
                                            pr_nmorgao_expedidor => vr_nmorgexp, 
                                            pr_cdcritic          => vr_cdcritic, 
                                            pr_dscritic          => vr_dscritic);
          IF nvl(vr_cdcritic,0) > 0 OR 
             TRIM(vr_dscritic) IS NOT NULL THEN
            vr_cdorgexp := NULL;
            vr_nmorgexp := NULL; 
            vr_cdcritic := NULL;
            vr_dscritic := NULL;
          END IF; 
        END IF; 
        
        pr_tab_associado(vr_index).cdoedttl:= vr_cdorgexp;
        
        pr_tab_associado(vr_index).cdufdttl:= rw_crapttl3.cdufdttl;
        pr_tab_associado(vr_index).dsfilttl:= rw_crapttl3.nmpaittl || ' - ' || rw_crapttl3.nmmaettl;
        pr_tab_associado(vr_index).dtnasttl:= rw_crapttl3.dtnasttl;
        pr_tab_associado(vr_index).nmtertl:=  rw_crapttl3.nmextttl;
        pr_tab_associado(vr_index).nrcpfttl:= rw_crapttl3.nrcpfcgc;
        pr_tab_associado(vr_index).nrdocttl:= rw_crapttl3.nrdocttl;
        pr_tab_associado(vr_index).tpdocttl:= rw_crapttl3.tpdocttl;
        pr_tab_associado(vr_index).dtemdttl:= rw_crapttl3.dtemdttl;
        pr_tab_associado(vr_index).tpvincul:= rw_crapass.tpvincul;
        pr_tab_associado(vr_index).nrfonemp:= vr_nrfonres;
        pr_tab_associado(vr_index).dtcnscpf:= rw_crapass.dtcnscpf;
        pr_tab_associado(vr_index).cdsitcpf:= rw_crapass.cdsitcpf;
        pr_tab_associado(vr_index).nmpaittl:= rw_crapttl3.nmpaittl;
        pr_tab_associado(vr_index).nmpaistl:= rw_crapttl2.nmpaittl;
        pr_tab_associado(vr_index).nmpaiptl:= rw_crapass.nmpaiptl;
        pr_tab_associado(vr_index).nmmaettl:= rw_crapttl3.nmmaettl;
        pr_tab_associado(vr_index).nmmaestl:= rw_crapttl2.nmmaettl;
        pr_tab_associado(vr_index).nmmaeptl:= rw_crapass.nmmaeptl;
        pr_tab_associado(vr_index).inccfcop:= rw_crapass.inccfcop;
        pr_tab_associado(vr_index).dtccfcop:= rw_crapass.dtccfcop;
        pr_tab_associado(vr_index).indrisco:= rw_crapass.indrisco;
        pr_tab_associado(vr_index).inarqcbr:= rw_crapass.inarqcbr;
        pr_tab_associado(vr_index).dsdemail:= vr_dsdemail;
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
        -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
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
  --  Data     : Abril/2015.                   Ultima atualizacao: 03/07/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para buscar informacoes da pessoa Juridica
  --
  -- Alterações:
  --             03/07/2017 - Incluido rotina de setar modulo Oracle 
  --                          ( Belli - Envolti - #667957)
  -- 

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

      -- Inclusão da rotina de setar módulo - Chamado 667957 - 03/07/2017
      GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'SEGU0001.pc_buscar_pessoa_juridica');      

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
        -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
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
  --  Data     : Abril/2015.                   Ultima atualizacao: 03/07/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para buscar informacoes do titular
  --
  -- Alterações:
  --             03/07/2017 - Incluido rotina de setar modulo Oracle 
  --                          ( Belli - Envolti - #667957)
  -- 

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

      -- Inclusão da rotina de setar módulo - Chamado 667957 - 03/07/2017
      GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'SEGU0001.pc_buscar_titular');

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
        -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
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
  --  Data     : Abril/2015.                   Ultima atualizacao: 03/07/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para buscar informacoes da empresa
  --
  -- Alterações:
  --             03/07/2017 - Incluido rotina de setar modulo Oracle 
  --                          ( Belli - Envolti - #667957)
  -- 

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

      -- Inclusão da rotina de setar módulo - Chamado 667957 - 03/07/2017
      GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'SEGU0001.pc_buscar_empresa');

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
        -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
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
  --  Data     : Abril/2015.                   Ultima atualizacao: 03/07/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para buscar informacoes dos planos seguro
  --
  -- Alterações:
  --             03/07/2017 - Incluido rotina de setar modulo Oracle 
  --                          ( Belli - Envolti - #667957)
  -- 

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

      -- Inclusão da rotina de setar módulo - Chamado 667957 - 03/07/2017
      GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'SEGU0001.pc_buscar_plano_seguro');

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
        -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
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
  --  Data     : Abril/2015.                   Ultima atualizacao: 03/07/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para buscar informacoes da seguradora
  --
  -- Alterações:
  --             03/07/2017 - Incluido rotina de setar modulo Oracle 
  --                          ( Belli - Envolti - #667957)
  -- 

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

      -- Inclusão da rotina de setar módulo - Chamado 667957 - 03/07/2017
      GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'SEGU0001.pc_buscar_seguradora');

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
        -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
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
  --  Data     : Abril/2015.                   Ultima atualizacao: 03/07/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para buscar motivos de cancelamento
  --
  -- Alterações:
  --             03/07/2017 - Incluido rotina de setar modulo Oracle 
  --                          ( Belli - Envolti - #667957)
  -- 

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

      -- Inclusão da rotina de setar módulo - Chamado 667957 - 03/07/2017
      GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'SEGU0001.pc_buscar_motivo_can');

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
        -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
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
                              ,pr_tab_seguros OUT SEGU0001.typ_tab_seguros -- Tabela de Seguros
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
  --  Data     : Abril/2015.                   Ultima atualizacao: 03/07/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para buscar informacoes dos seguros
  --
  -- Alterações:
  --             03/07/2017 - Incluido rotina de setar modulo Oracle 
  --                          ( Belli - Envolti - #667957)
  -- 

  ---------------------------------------------------------------------------------------------------------------
    DECLARE

      -- Tabela de Motivos
      vr_tab_mot_can SEGU0001.typ_tab_mot_can;


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

      -- Inclusão da rotina de setar módulo - Chamado 667957 - 03/07/2017
      GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'SEGU0001.pc_buscar_seguros');

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
        -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
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
  --  Data     : Abril/2015.                   Ultima atualizacao: 03/07/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para calcular a data de debito
  --
  -- Alterações:
  --             03/07/2017 - Incluido rotina de setar modulo Oracle 
  --                          ( Belli - Envolti - #667957)
  -- 

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

      -- Inclusão da rotina de setar módulo - Chamado 667957 - 03/07/2017
      GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'SEGU0001.pc_calcular_data_debito');

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
        -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
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
  --  Data     : Abril/2015.                   Ultima atualizacao: 03/07/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para atualizar matricula
  --
  -- Alterações:
  --             03/07/2017 - Incluido rotina de setar modulo Oracle 
  --                          ( Belli - Envolti - #667957)
  -- 

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

      -- Inclusão da rotina de setar módulo - Chamado 667957 - 03/07/2017
      GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'SEGU0001.pc_atualizar_matricula');

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
        -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
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

  /* Criacao dos registros da tabela DE/PARA de plano de seguros inativos */
  PROCEDURE pc_cria_tabela_depara (pr_tab_pldepara OUT typ_tab_pldepara) IS --
  BEGIN
     ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_cria_tabela_depara                   Antigo: b1wgen0033.p/cria-tabela-depara
  --  Sistema  :
  --  Sigla    : CRED
  --  Autor    : Jonata - Rkam
  --  Data     : Julho/2016.                   Ultima atualizacao: --/--/----
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Criar registros de plano de seguro inativos

  ---------------------------------------------------------------------------------------------------------------
    DECLARE
      vr_idx PLS_INTEGER;
    BEGIN
      vr_idx := 1;
      pr_tab_pldepara(vr_idx).cdsegura := 5011;
      pr_tab_pldepara(vr_idx).tpseguro := 11;
      pr_tab_pldepara(vr_idx).tpplasde := 11;
      pr_tab_pldepara(vr_idx).tpplaspa := 41;

      vr_idx := 2;
      pr_tab_pldepara(vr_idx).cdsegura := 5011;
      pr_tab_pldepara(vr_idx).tpseguro := 11;
      pr_tab_pldepara(vr_idx).tpplasde := 12;
      pr_tab_pldepara(vr_idx).tpplaspa := 42;

      vr_idx := 3;
      pr_tab_pldepara(vr_idx).cdsegura := 5011;
      pr_tab_pldepara(vr_idx).tpseguro := 11;
      pr_tab_pldepara(vr_idx).tpplasde := 13;
      pr_tab_pldepara(vr_idx).tpplaspa := 43;

      vr_idx := 4;
      pr_tab_pldepara(vr_idx).cdsegura := 5011;
      pr_tab_pldepara(vr_idx).tpseguro := 11;
      pr_tab_pldepara(vr_idx).tpplasde := 21;
      pr_tab_pldepara(vr_idx).tpplaspa := 41;

      vr_idx := 5;
      pr_tab_pldepara(vr_idx).cdsegura := 5011;
      pr_tab_pldepara(vr_idx).tpseguro := 11;
      pr_tab_pldepara(vr_idx).tpplasde := 22;
      pr_tab_pldepara(vr_idx).tpplaspa := 42;

      vr_idx := 6;
      pr_tab_pldepara(vr_idx).cdsegura := 5011;
      pr_tab_pldepara(vr_idx).tpseguro := 11;
      pr_tab_pldepara(vr_idx).tpplasde := 23;
      pr_tab_pldepara(vr_idx).tpplaspa := 43;

      vr_idx := 7;
      pr_tab_pldepara(vr_idx).cdsegura := 5011;
      pr_tab_pldepara(vr_idx).tpseguro := 11;
      pr_tab_pldepara(vr_idx).tpplasde := 31;
      pr_tab_pldepara(vr_idx).tpplaspa := 41;

      vr_idx := 8;
      pr_tab_pldepara(vr_idx).cdsegura := 5011;
      pr_tab_pldepara(vr_idx).tpseguro := 11;
      pr_tab_pldepara(vr_idx).tpplasde := 32;
      pr_tab_pldepara(vr_idx).tpplaspa := 42;

      vr_idx := 9;
      pr_tab_pldepara(vr_idx).cdsegura := 5011;
      pr_tab_pldepara(vr_idx).tpseguro := 11;
      pr_tab_pldepara(vr_idx).tpplasde := 33;
      pr_tab_pldepara(vr_idx).tpplaspa := 43;

      vr_idx := 10;
      pr_tab_pldepara(vr_idx).cdsegura := 5011;
      pr_tab_pldepara(vr_idx).tpseguro := 11;
      pr_tab_pldepara(vr_idx).tpplasde := 171;
      pr_tab_pldepara(vr_idx).tpplaspa := 201;

      vr_idx := 11;
      pr_tab_pldepara(vr_idx).cdsegura := 5011;
      pr_tab_pldepara(vr_idx).tpseguro := 11;
      pr_tab_pldepara(vr_idx).tpplasde := 171;
      pr_tab_pldepara(vr_idx).tpplaspa := 201;

      vr_idx := 12;
      pr_tab_pldepara(vr_idx).cdsegura := 5011;
      pr_tab_pldepara(vr_idx).tpseguro := 11;
      pr_tab_pldepara(vr_idx).tpplasde := 172;
      pr_tab_pldepara(vr_idx).tpplaspa := 202;

      vr_idx := 13;
      pr_tab_pldepara(vr_idx).cdsegura := 5011;
      pr_tab_pldepara(vr_idx).tpseguro := 11;
      pr_tab_pldepara(vr_idx).tpplasde := 173;
      pr_tab_pldepara(vr_idx).tpplaspa := 203;

      vr_idx := 14;
      pr_tab_pldepara(vr_idx).cdsegura := 5011;
      pr_tab_pldepara(vr_idx).tpseguro := 11;
      pr_tab_pldepara(vr_idx).tpplasde := 181;
      pr_tab_pldepara(vr_idx).tpplaspa := 201;

      vr_idx := 15;
      pr_tab_pldepara(vr_idx).cdsegura := 5011;
      pr_tab_pldepara(vr_idx).tpseguro := 11;
      pr_tab_pldepara(vr_idx).tpplasde := 182;
      pr_tab_pldepara(vr_idx).tpplaspa := 202;

      vr_idx := 16;
      pr_tab_pldepara(vr_idx).cdsegura := 5011;
      pr_tab_pldepara(vr_idx).tpseguro := 11;
      pr_tab_pldepara(vr_idx).tpplasde := 183;
      pr_tab_pldepara(vr_idx).tpplaspa := 203;

      vr_idx := 17;
      pr_tab_pldepara(vr_idx).cdsegura := 5011;
      pr_tab_pldepara(vr_idx).tpseguro := 11;
      pr_tab_pldepara(vr_idx).tpplasde := 191;
      pr_tab_pldepara(vr_idx).tpplaspa := 201;

      vr_idx := 18;
      pr_tab_pldepara(vr_idx).cdsegura := 5011;
      pr_tab_pldepara(vr_idx).tpseguro := 11;
      pr_tab_pldepara(vr_idx).tpplasde := 192;
      pr_tab_pldepara(vr_idx).tpplaspa := 202;

      vr_idx := 19;
      pr_tab_pldepara(vr_idx).cdsegura := 5011;
      pr_tab_pldepara(vr_idx).tpseguro := 11;
      pr_tab_pldepara(vr_idx).tpplasde := 193;
      pr_tab_pldepara(vr_idx).tpplaspa := 203;

      vr_idx := 20;
      pr_tab_pldepara(vr_idx).cdsegura := 5011;
      pr_tab_pldepara(vr_idx).tpseguro := 11;
      pr_tab_pldepara(vr_idx).tpplasde := 331;
      pr_tab_pldepara(vr_idx).tpplaspa := 361;

      vr_idx := 21;
      pr_tab_pldepara(vr_idx).cdsegura := 5011;
      pr_tab_pldepara(vr_idx).tpseguro := 11;
      pr_tab_pldepara(vr_idx).tpplasde := 332;
      pr_tab_pldepara(vr_idx).tpplaspa := 362;

      vr_idx := 22;
      pr_tab_pldepara(vr_idx).cdsegura := 5011;
      pr_tab_pldepara(vr_idx).tpseguro := 11;
      pr_tab_pldepara(vr_idx).tpplasde := 333;
      pr_tab_pldepara(vr_idx).tpplaspa := 363;

      vr_idx := 23;
      pr_tab_pldepara(vr_idx).cdsegura := 5011;
      pr_tab_pldepara(vr_idx).tpseguro := 11;
      pr_tab_pldepara(vr_idx).tpplasde := 341;
      pr_tab_pldepara(vr_idx).tpplaspa := 361;

      vr_idx := 24;
      pr_tab_pldepara(vr_idx).cdsegura := 5011;
      pr_tab_pldepara(vr_idx).tpseguro := 11;
      pr_tab_pldepara(vr_idx).tpplasde := 342;
      pr_tab_pldepara(vr_idx).tpplaspa := 362;

      vr_idx := 25;
      pr_tab_pldepara(vr_idx).cdsegura := 5011;
      pr_tab_pldepara(vr_idx).tpseguro := 11;
      pr_tab_pldepara(vr_idx).tpplasde := 343;
      pr_tab_pldepara(vr_idx).tpplaspa := 363;

      vr_idx := 26;
      pr_tab_pldepara(vr_idx).cdsegura := 5011;
      pr_tab_pldepara(vr_idx).tpseguro := 11;
      pr_tab_pldepara(vr_idx).tpplasde := 351;
      pr_tab_pldepara(vr_idx).tpplaspa := 361;

      vr_idx := 27;
      pr_tab_pldepara(vr_idx).cdsegura := 5011;
      pr_tab_pldepara(vr_idx).tpseguro := 11;
      pr_tab_pldepara(vr_idx).tpplasde := 352;
      pr_tab_pldepara(vr_idx).tpplaspa := 362;

      vr_idx := 28;
      pr_tab_pldepara(vr_idx).cdsegura := 5011;
      pr_tab_pldepara(vr_idx).tpseguro := 11;
      pr_tab_pldepara(vr_idx).tpplasde := 353;
      pr_tab_pldepara(vr_idx).tpplaspa := 363;

    END;
  END pc_cria_tabela_depara;

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
  --  Data     : Abril/2015.                   Ultima atualizacao: 03/07/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para criar os seguros
  --
  -- Alterações:
  --             03/07/2017 - Incluido rotina de setar modulo Oracle 
  --                          ( Belli - Envolti - #667957)
  -- 

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
      vr_tab_associado  SEGU0001.typ_tab_associado;
      vr_tab_seguros    SEGU0001.typ_tab_seguros;
      vr_tab_seguradora SEGU0001.typ_tab_seguradora;
      vr_tab_plano_seg  SEGU0001.typ_tab_plano_seg;

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
      vr_tab_pldepara typ_tab_pldepara;

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

      -- Inclusão da rotina de setar módulo - Chamado 667957 - 03/07/2017
      GENE0001.pc_set_modulo(pr_module => pr_nmdatela, pr_action => 'SEGU0001.pc_cria_seguro');

      --Inicializar Variaveis
      vr_cdcritic:= 0;
      vr_dscritic:= NULL;

      --Limpar tabela erros
      pr_tab_erro.DELETE;

      -- enquanto o crps604 puder renovar os tipos de seguros caregados na temp-table ira
      -- carregar ela apenas qdoa solicitacao vier de alguma tela
      IF TRIM(pr_nmdatela) IS NOT NULL THEN
        pc_cria_tabela_depara(vr_tab_pldepara);
      END IF;


      BEGIN

        -- Procuro se esta na tabela de|para e preencho as variaveis de acordo
        -- caso encontre na tabela*/
        FOR vr_idx IN 1..vr_tab_pldepara.count LOOP
          IF vr_tab_pldepara(vr_idx).cdsegura = pr_cdsegura
          AND vr_tab_pldepara(vr_idx).tpseguro = pr_tpseguro
          AND vr_tab_pldepara(vr_idx).tpplasde = pr_tpplaseg THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Este plano de seguro esta bloqueado para contratacao.';
            -- Levantar Excecao
            RAISE vr_exc_sair;
          END IF;
        END LOOP;

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
                  ,15               -- tplotmov
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
                -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
                CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
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
                -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
                CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
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
            -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
            CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
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
              -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
              CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
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
              -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
              CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
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
            /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
            ,crapseg.cdopeori
            ,crapseg.cdageori
            ,crapseg.dtinsori
            /* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
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
            /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
            ,pr_cdoperad          --cdopeori
            ,pr_cdagenci          --cdageori
            ,SYSDATE              --dtinsori
            /* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
            ,pr_vlprepag)         --vlprepag
          RETURNING crapseg.rowid
          INTO vr_rowid_crapseg;
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
            CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
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
              -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
              CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
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
              -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
              CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
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
        -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
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
  --
  -- Alterações:
  --             03/07/2017 - Incluido rotina de setar modulo Oracle 
  --                          ( Belli - Envolti - #667957)
  -- 
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

      -- Inclusão da rotina de setar módulo - Chamado 667957 - 03/07/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'SEGU0001.pc_buscar_plaseg_web');

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

      -- Inclusão da rotina de setar módulo - Chamado 667957 - 03/07/2017
      GENE0001.pc_set_modulo(pr_module => vr_nmdatela, pr_action => 'SEGU0001.pc_buscar_plaseg_web');

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
        -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
        CECRED.pc_internal_exception (pr_cdcooper => vr_cdcooper);   
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

  PROCEDURE pc_importa_seg_auto_sicr(pr_cdcooper IN PLS_INTEGER) IS
    /* ............................................................................

    Programa: pc_importa_seg_auto_sicr
    Sistema : Ayllos/JOB
    Autor   : Guilherme/SUPERO
    Data    : Maio/2016                 Ultima atualizacao: 09/08/2017

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Efetuar a importação dos dados Seguro Auto Sicredi recebido
                separado por ";" (SEGURO_CECRED_AAAAMMDD)

    Alteracoes: 16/08/2016 - Implementar ordenação para os registros lidos a partir
                             do arquivo para a tabela de memória ( Renato Darosci - Supero )

                19/08/2016 - Implementar o processamento de registros de retorno de
                             cancelamento ( Renato Darosci - Supero )
  
                03/07/2017 - Incluido rotina de setar modulo Oracle 
                           - Implementado Log no padrão
                             ( Belli - Envolti - #667957)
                
                09/08/2017 - Ajuste realizado para que seja possivel identificar
                             pelo titulo do email caso o arquivo for processado
                             com erro, conforme solicitado no chamado 679319. 
                             (Kelvin)
  
    ..............................................................................*/

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'SEGU0001';
      vr_nomdojob CONSTANT VARCHAR2(100) := 'JBSEG_AUTO_SICR_IMP';

      -- Tratamento de erros
      vr_exc_saida  EXCEPTION;
      vr_exc_valid  EXCEPTION;
      vr_exc_email  EXCEPTION;
      vr_cdcritic   PLS_INTEGER;
      vr_dscritic   VARCHAR2(4000);
      vr_dscriti2   crapcri.dscritic%TYPE;
      vr_flgerlog   BOOLEAN := FALSE;
      vr_temarquiv  BOOLEAN;
      vr_nmarqlog   VARCHAR2(100);
      vr_nmarqerr   VARCHAR2(80) := '';
      vr_raizcoop   VARCHAR2(50);
      vr_nmdirlog   VARCHAR2(100);
      vr_indierro   NUMBER;

      -- Variaveis
      vr_dsdirrec   VARCHAR2(200);   -- Diretorio de RECEBE
      vr_dsdirenv   VARCHAR2(200);   -- Diretorio de ENVIO
      vr_dsdirmov   VARCHAR2(200);   -- Diretorio de DESTINO APÓS PROCESSAMENTO
      vr_comando    VARCHAR2(2000);                                    --> Comando UNIX para Mover arquivo lido
      vr_tab_linhas gene0009.typ_tab_linhas;

      TYPE typ_tab_ordena IS TABLE OF gene0009.typ_tab_campos INDEX BY VARCHAR2(105);
      -- Caracteres:  [8] - Data
      --             [25] - Número da proposta
      --             [25] - Número da apolice
      vr_tab_ordena typ_tab_ordena;
      vr_dsdchave   VARCHAR2(105);

      vr_listaarqs  VARCHAR2(2000); -- dir da coop atual

      -- PL/Table que vai armazenar os nomes de arquivos a serem processados
      vr_tab_arqtmp      gene0002.typ_split;

      -- Novo Vetor para posicionar a linha - Chamado 667957 - 07/07/2017      
      TYPE type_linha IS TABLE OF NUMBER INDEX BY VARCHAR2(105);
      v_linha                type_linha;  
      vr_cdchave             varchar2(105);
      vr_nrlinha             number(20);      

      --vr_contareg   PLS_INTEGER;
      vr_dsdanexo   VARCHAR2(200);
      vr_nmarquiv   VARCHAR2(20);
      vr_maildest   VARCHAR2(100);
      vr_mailtitu   VARCHAR2(100);
      vr_mailbody   VARCHAR2(400);
      vr_flultexc   BOOLEAN:=FALSE;  -- Identifica se é a Ultima Execução do dia.

      --Variaveis pertencentes ao layout d(DETAIL) do arquivo
      lt_d_dtpropos   DATE;            -- Data Proposta
      lt_d_nragecta   VARCHAR2(40);    -- Agencia e Conta Debito (VARCHAR para tratar com posicionamento)
      lt_d_nr_do_ci   VARCHAR2(20);    -- Numero do CI

      vr_cdagectl     crapcop.cdagectl%TYPE;
      vr_flgsegok     BOOLEAN; -- RETORNO DA pc_insere_seguro se TRUE ou FALSE
      vr_tab_erro     gene0001.typ_tab_erro;

      vr_tpdseguro    PLS_INTEGER := 0;
      vr_found_seg    BOOLEAN:=FALSE;
      vr_found_ant    BOOLEAN:=FALSE; -- Identifica se o Predecessor existe (Para Apolice, Proposta / Para Endosso, Apolice)
      vr_nrapolice    tbseg_contratos.nrapolice%TYPE;
      vr_nrendosso    tbseg_contratos.nrendosso%TYPE;

      vr_typ_saida    VARCHAR2(4000);

      vr_reg_arquivo tbseg_contratos%ROWTYPE;
      vr_reg_auto    tbseg_auto_veiculos%ROWTYPE;
      vr_reg_vida    tbseg_vida_benefici%ROWTYPE;
      vr_reg_casa    tbseg_vida_benefici%ROWTYPE; -- A tabela para esse Seguro ainda nao existe
      vr_reg_prst    tbseg_vida_benefici%ROWTYPE; -- A tabela para esse Seguro ainda nao existe
      vr_reg_tpatu   typ_reg_flg_atu;

      -- Variaveis de posicionamento de modulo - 05/07/2017 - Chamado 667957
      vr_acao             VARCHAR2   (100) := 'SEGU0001.pc_importa_seg_auto_sicr'; 

      -- Variaveis de inclusão de log  - 05/07/2017 - Chamado 667957
      vr_idprglog            tbgen_prglog.idprglog%TYPE := 0; 


      ------------------------------- CURSORES ---------------------------------

      CURSOR cr_crapcop (p_cdagectl IN crapcop.cdagectl%type) IS
        SELECT cop.nmrescop
              ,cop.cdcooper
          FROM crapcop cop
         WHERE cop.cdagectl = p_cdagectl;
      rw_crapcop cr_crapcop%ROWTYPE;

      CURSOR cr_crapass (p_cdcooper IN crapcop.cdcooper%TYPE
                        ,p_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT ass.nmprimtl
              ,ass.nrdconta
          FROM crapass ass
         WHERE ass.cdcooper = p_cdcooper
           AND ass.nrdconta = p_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

      -- Busca Associado pelo CPF/CNPJ
      CURSOR cr_ass_cpfcnpj(p_nrcpfcgc IN crapass.nrcpfcgc%TYPE) IS
        SELECT ass.cdcooper
              ,ass.nrdconta
              ,ass.nrcpfcgc
              ,ass.rowid
              ,COUNT(cdcooper) OVER (PARTITION BY cdcooper) qtd_reg
          FROM crapass ass
         WHERE ass.nrcpfcgc = p_nrcpfcgc
         ORDER BY ass.cdcooper, ass.nrdconta;
      rw_ass_cpfcnpj cr_ass_cpfcnpj%ROWTYPE;

      -- VERIFICAR SE PROPOSTA/APOLICE EXISTE NA BASE
      CURSOR cr_seg_proposta(p_cdcooper IN tbseg_contratos.cdcooper%TYPE
                            ,p_nrdconta IN tbseg_contratos.nrdconta%TYPE
                            ,p_nrpropos IN tbseg_contratos.nrproposta%TYPE) IS
        SELECT seg.rowid, seg.*
          FROM tbseg_contratos seg
         WHERE seg.cdcooper      = p_cdcooper
           AND seg.nrdconta      = p_nrdconta
           AND seg.nrproposta    = p_nrpropos
           AND seg.nrapolice     = 0
           AND seg.tpseguro      = 'A' -- AUTO
           ;
      CURSOR cr_seg_apolice (p_cdcooper IN tbseg_contratos.cdcooper%TYPE
                            ,p_nrdconta IN tbseg_contratos.nrdconta%TYPE
                            ,p_nrapolic IN tbseg_contratos.nrapolice%TYPE) IS
        SELECT seg.rowid, seg.*
          FROM tbseg_contratos seg
         WHERE seg.cdcooper      = p_cdcooper
           AND seg.nrdconta      = p_nrdconta
           AND seg.nrapolice     = p_nrapolic
           AND seg.tpseguro      = 'A' -- AUTO
           AND seg.flgvigente    = 1   -- Buscar contrato vigente
           ;
      CURSOR cr_seg_endosso (p_cdcooper IN tbseg_contratos.cdcooper%TYPE
                            ,p_nrdconta IN tbseg_contratos.nrdconta%TYPE
                            ,p_nrapolic IN tbseg_contratos.nrapolice%TYPE
                            ,p_nrendoss IN tbseg_contratos.nrendosso%TYPE) IS
        SELECT seg.rowid, seg.*
          FROM tbseg_contratos seg
         WHERE seg.cdcooper      = p_cdcooper
           AND seg.nrdconta      = p_nrdconta
           AND seg.nrapolice     = p_nrapolic
           AND seg.nrendosso     = p_nrendoss
           AND seg.tpseguro      = 'A' -- AUTO
           AND seg.flgvigente    = 1   -- Buscar contrato vigente
           ;
      rw_seg_base cr_seg_apolice%ROWTYPE;

      -- BUSCAR O ENDOSSO A SER CANCELADO
      CURSOR cr_endosso_cancel (p_nrapolic  IN tbseg_contratos.nrapolice%TYPE
                               ,p_nrendoss  IN tbseg_contratos.nrendosso%TYPE) IS
        SELECT seg.rowid
              ,seg.nrapolice
          FROM tbseg_contratos seg
         WHERE seg.nrapolice   = p_nrapolic
           AND seg.nrendosso   = p_nrendoss
           AND seg.tpseguro    = 'A' -- AUTO
           AND seg.flgvigente  = 1;  -- Buscar contrato vigente
      rw_endosso_cancel   cr_endosso_cancel%ROWTYPE;

      -- BUSCAR A APOLICE OU O ENDOSSO A SER REATIVADO
      CURSOR cr_endosso_ativa (p_nrapolic  IN tbseg_contratos.nrapolice%TYPE) IS
        SELECT seg.rowid
          FROM tbseg_contratos seg
         WHERE seg.nrapolice   = p_nrapolic
           AND seg.indsituacao = 'E' -- Endossado
           AND seg.tpseguro    = 'A' -- AUTO
         ORDER BY seg.idcontrato DESC; -- Buscar o último contrato endossado
      rw_endosso_ativa   cr_endosso_ativa%ROWTYPE;

      -- BUSCAR O ENDOSSO RECEBIDO PARA A APOLICE
      CURSOR cr_endosso_recebido(p_nrapolic  IN tbseg_contratos.nrapolice%TYPE
                                ,p_nrendoss  IN tbseg_contratos.nrendosso%TYPE) IS
        SELECT 1
          FROM tbseg_contratos seg
         WHERE seg.nrapolice   = p_nrapolic
           AND seg.nrendosso   = p_nrendoss
           AND seg.tpseguro    = 'A'; -- AUTO
      rw_endosso_recebido  cr_endosso_recebido%ROWTYPE;


      CURSOR cr_auto_base (p_idcontrato IN tbseg_contratos.idcontrato%TYPE) IS
                        -- ,p_dschassi   IN tbseg_auto_veiculos.dschassi%TYPE) IS
        SELECT auto.*
          FROM tbseg_auto_veiculos auto
         WHERE auto.idcontrato = p_idcontrato;
      rw_auto_base cr_auto_base%ROWTYPE;

      CURSOR cr_tpendosso (p_tpendosso     IN tbseg_contratos.tpendosso%TYPE
                          ,p_tpsub_endosso IN tbseg_contratos.tpsub_endosso%TYPE) IS
        SELECT 1
          FROM TBSEG_TIPOS_ENDOSSO tipo
         WHERE tipo.tpendosso     = p_tpendosso
           AND tipo.tpsub_endosso = p_tpsub_endosso;
      rw_tpendosso cr_tpendosso%ROWTYPE;

      --------------------------- SUBROTINAS INTERNAS --------------------------
      FUNCTION fn_conv (p_valor boolean) RETURN VARCHAR2 IS

        BEGIN
         IF p_valor THEN
           RETURN 'SIM';
         ELSE
           RETURN 'NAO';
         END IF;

      END fn_conv;


      --> Controla log proc_batch, para apensa exibir qnd realmente processar informação
      PROCEDURE pc_controla_log_batch(pr_dstiplog_in     IN VARCHAR2,
                                      pr_dscritic_in     IN VARCHAR2 DEFAULT NULL,
                                      pr_dsfixa_in       IN VARCHAR2 DEFAULT 'ERRO: ',
                                      pr_tpocorrencia_in IN VARCHAR2 DEFAULT 2
                                      ) IS
                                      
      BEGIN

        vr_nmarqlog := 'proc_batch.log';           
        vr_dscriti2 := to_char(sysdate,'hh24:mi:ss')||' - ' || vr_cdprogra 
                               || ' --> ' 
                               || pr_dsfixa_in    || pr_dscritic_in                 
                               || ' - Module: ' || vr_cdprogra 
                               || ' - Action: ' || vr_acao;
        
        --> Controlar geração de log de execução dos jobs
        cecred.pc_log_programa(pr_dstiplog      => pr_dstiplog_in    , -- tbgen_prglog  DEFAULT 'O' --> Tipo do log: I - início; F - fim; O || E - ocorrência
                               pr_cdprograma    => vr_nomdojob       , -- tbgen_prglog
                               pr_cdcooper      => nvl(pr_cdcooper,3), -- tbgen_prglog
                               pr_tpexecucao    => 1,                  -- tbgen_prglog  DEFAULT 1 -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                               pr_tpocorrencia  => pr_tpocorrencia_in, -- tbgen_prglog_ocorrencia -- 4 Mensagem
                               pr_cdcriticidade => 0,           -- tbgen_prglog_ocorrencia DEFAULT 0 -- Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                               pr_dsmensagem    => vr_dscriti2, -- tbgen_prglog_ocorrencia
                               pr_flgsucesso    => 1,           -- tbgen_prglog  DEFAULT 1 -- Indicador de sucesso da execução
                               pr_nmarqlog      => vr_nmarqlog,
                               pr_idprglog      => vr_idprglog
                               );                                 

      END pc_controla_log_batch;

      PROCEDURE gera_log(pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_cdprogra IN crapprg.cdprogra%TYPE
                        ,pr_indierro IN PLS_INTEGER
                        ,pr_cdcritic IN crapcri.cdcritic%TYPE
                        ,pr_dscritic IN crapcri.dscritic%TYPE) IS

        vr_nmarqlog  VARCHAR2(50);
        vr_flfinmsg  VARCHAR2(1);
        vr_vet_arqv  gene0002.typ_split;
        vr_nmarqdat  gene0002.typ_split;

      BEGIN

        -- Se foi retornado apenas código
        IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscriti2 := gene0001.fn_busca_critica(pr_cdcritic);
        END IF;

        IF TRIM(pr_dscritic) IS NOT NULL THEN
           vr_dscriti2 := pr_dscritic;
        END IF;


        IF pr_indierro = 1 THEN
          vr_nmarqlog := 'proc_batch.log';
          vr_flfinmsg := 'S';
          pc_controla_log_batch(pr_dstiplog_in => 'E',
                                pr_dscritic_in => 'Falta Tratar - ' || vr_dscriti2);                          
        ELSE
          -- BLOCO PRA EXTRAIR A DATA DO NOME DO ARQUIVO
          vr_vet_arqv := gene0002.fn_quebra_string(pr_string =>pr_cdprogra, pr_delimit => '_' );
          FOR idx IN 1..vr_vet_arqv.count LOOP
            -- QUEBRA POR "." PRA REMOVER A EXTENSAO DO ARQUIVO
            vr_nmarqdat := gene0002.fn_quebra_string(pr_string =>vr_vet_arqv(idx), pr_delimit => '.' );
          END LOOP;

          vr_nmarqlog := 'RESUMO_ARQ_SEG_' || vr_nmarqdat(1) || '_' ||to_char(SYSDATE,'hh24');
          vr_flfinmsg := 'N';
          vr_nmarqerr := vr_nmarqlog || '.log';

          vr_dscriti2 := to_char(sysdate,'hh24:mi:ss')||' - ' || pr_cdprogra 
                                 || ' --> ' 
                                 || 'ALERTA: '       || vr_dscriti2;

        -- Envio centralizado de log de erro
          btch0001.pc_gera_log_batch( pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 1
                                  ,pr_des_log      => vr_dscriti2
                                  ,pr_nmarqlog     => vr_nmarqlog
                                     ,pr_flfinmsg     => vr_flfinmsg
                                     ,pr_cdprograma   => pr_cdprogra);
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);                                                           
          -- Acerto geração de erro via vr_exc_saida - Chamado 667957 - 05/07/2018
            vr_cdcritic := 0;
          vr_dscritic := 'Problemas com geracao de Log - ' || SQLERRM;                                    
            RAISE vr_exc_saida;
      END gera_log;


      -- Validações da execução do JOB
      -- Se ultima execução(12h), e nao processou arquivos, notificar
      PROCEDURE pc_controla_execucao(pr_temarquivo IN BOOLEAN) IS

        vr_flgexec  PLS_INTEGER;
        vr_vlprmjob PLS_INTEGER;

        -- Busca as horas inicio/fim do Job - Inicialmente proramado para das 7 as 12 (1 em 1h)
        vr_hriniexe NUMBER(3):= to_number(nvl(gene0001.fn_param_sistema('CRED', 0, 'HR_INI_JOB_SEGURO'),7));
        vr_hrfimexe NUMBER(3):= to_number(nvl(gene0001.fn_param_sistema('CRED', 0, 'HR_FIM_JOB_SEGURO'),12));

      BEGIN

        -- Se for a primeira execução do dia, zera o FLAG_ARQ_SEGURO
        IF to_number(to_char(SYSDATE,'hh24')) = vr_hriniexe THEN
          BEGIN
            UPDATE crapprm prm
               SET prm.dsvlrprm = 0
             WHERE prm.cdacesso ='FLAG_ARQ_SEGURO';

            COMMIT;
          EXCEPTION
            WHEN OTHERS THEN
              -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
              CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
              vr_dscritic := 'SEGU0001.pc_controla_execucao: Erro ao atualizar PRM[0] => ' ||
                             SQLERRM ;
              -- Acerto do log - Chamado 667957 - 05/07/2017              
              --> Final da execução com ERRO
              pc_controla_log_batch(pr_dstiplog_in => 'E',
                                    pr_dscritic_in => vr_dscritic);
          END;
        END IF;

        -- Verifica o param do sistema até o momento.
        vr_flgexec :=  to_number(nvl(gene0001.fn_param_sistema('CRED', 0, 'FLAG_ARQ_SEGURO'),0));

        IF pr_temarquivo THEN -- TEM ARQUIVO na pasta
          vr_vlprmjob := 1;
        ELSE -- NAO TEM arquivo na pasta
          IF vr_flgexec = 1 THEN -- Nao tem arquivo, mas ja encontrou em execucoes anterioes, nao atualiza
            vr_vlprmjob := vr_flgexec;
          ELSE
            vr_vlprmjob := 0;
          END IF;
        END IF;

        -- Atualiza indicador conforme a existencia de arquivo na pasta
        BEGIN
          UPDATE crapprm prm
             SET prm.dsvlrprm = vr_vlprmjob
           WHERE prm.cdacesso ='FLAG_ARQ_SEGURO';
          COMMIT;
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
            CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
            vr_dscritic := 'SEGU0001.pc_controla_execucao: Erro ao atualizar PRM[1] => ' ||
                           SQLERRM ;
            -- Acerto do log - Chamado 667957 - 05/07/2017     
            --> Final da execução com ERRO
            pc_controla_log_batch(pr_dstiplog_in => 'E',
                                  pr_dscritic_in => vr_dscritic);
        END;

        -- Validar a hora atual de execução
        IF to_number(to_char(SYSDATE,'hh24')) >= vr_hrfimexe THEN -- Ultima Execução - as 12h
            -- Busca novamente o parametro
            vr_flgexec  :=  to_number(nvl(gene0001.fn_param_sistema('CRED', 0, 'FLAG_ARQ_SEGURO'),0));
            vr_flultexc := TRUE;

            -- Parametro de Sistema FALSO (nao encontrou arquivo) e Hora execução > 12h
            -- deve enviar email
            IF  vr_flgexec = 0 THEN

              vr_maildest := gene0001.fn_param_sistema('CRED', 0, 'AUTO_DEST_SEM_ARQ');
              vr_mailtitu := gene0001.fn_param_sistema('CRED', 0, 'AUTO_TITL_SEM_ARQ');
              vr_mailbody := REPLACE(gene0001.fn_param_sistema('CRED', 0, 'AUTO_BODY_SEM_ARQ')
                                     ,'##DATA##'
                                     ,to_char(rw_crapdat.dtmvtocd,'DD/MM/RRRR'));
              -- Acerto do log - Chamado 667957 - 05/07/2017     
              --> Final da execução com ERRO
              pc_controla_log_batch(pr_dstiplog_in => 'E',
                                    pr_dscritic_in => 'Envio de Email: ' || vr_mailtitu);                      

              -- Envio de email
              gene0003.pc_solicita_email(pr_cdcooper        => 3 --pr_cdcooper
                                        ,pr_cdprogra        => 'SEGU0001'
                                        ,pr_des_destino     => vr_maildest
                                        ,pr_des_assunto     => vr_mailtitu
                                        ,pr_des_corpo       => vr_mailbody
                                        ,pr_des_anexo       => ''
                                        ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                        ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                        ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                        ,pr_des_erro        => vr_dscritic);
              -- Se houver erros
              IF vr_dscritic IS NOT NULL THEN
                -- Acerto geração de erro via vr_exc_saida - Chamado 667957 - 05/07/2018
                -- Gera critica
                vr_cdcritic := 0;
                vr_dscritic := 'Envio do Email!' || '. Critica: '||vr_dscritic;
                RAISE vr_exc_saida;
              END IF;

            END IF;

        END IF; -- Ultima Execução - as 12h

     END pc_controla_execucao;


     -- FUNÇÃO TEM POR OBJETITVO VALIDAR O TEXTO IMPORTADO
     -- POIS HOUVERAM CASOS DE ARQUIVOS RECEBIDOS COM FORMATAÇÃO
     -- UTF-8, E O PADRÃO DEVE SER ANSI. APENAS PARA EVITAR
     -- INCONSISTÊNCIAS NA IMPORTAÇÃO
     FUNCTION fn_valida_seguradora (pr_texto   VARCHAR2  -- Texto a ser validado
                                   ,pr_compara VARCHAR2) -- Texto contra o qual será validado
                                 RETURN BOOLEAN IS
       BEGIN

          -- PADRÃO ANSI
         IF  pr_texto = pr_compara THEN
           RETURN TRUE;
         END IF;

         -- SE O TEXTO VEIO EM UTF-8
         IF gene0007.fn_convert_web_db(pr_texto) = pr_compara THEN
           RETURN TRUE;
         END IF;

         RETURN FALSE;

     END fn_valida_seguradora;

  BEGIN

    -- Inclusão da rotina de setar módulo - Chamado 667957 - 03/07/2017
    GENE0001.pc_set_modulo(pr_module => vr_cdprogra, pr_action => vr_acao);      

    --------------- VALIDACOES INICIAIS -----------------
    vr_dsdirrec  := gene0001.fn_param_sistema('CRED', 0, 'DIR_SEG_AUTO_REC');
    vr_dsdirenv  := gene0001.fn_param_sistema('CRED', 0, 'DIR_SEG_AUTO_ENV');
    vr_dsdirmov  := gene0001.fn_param_sistema('CRED', 0, 'DIR_SEG_AUTO_OK');
    vr_nmarquiv  := 'SEGURO_CECRED_%'; -- Todos os arquivos com esse nome existentes na pasta


    -- Leitura do calendário da cooperativa
    OPEN btch0001.cr_crapdat(pr_cdcooper => 3);
     FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;

    -- Acerto do log - Chamado 667957 - 05/07/2017     
    pc_controla_log_batch(pr_dstiplog_in     => 'I',
                          pr_dsfixa_in       => 'ALERTA: ',
                          pr_tpocorrencia_in => 4);

    gene0001.pc_lista_arquivos(pr_path     => vr_dsdirrec
                              ,pr_pesq     => vr_nmarquiv
                              ,pr_listarq  => vr_listaarqs
                              ,pr_des_erro => vr_dscritic);


    --Carregar a lista de arquivos txt na pl/table
    vr_tab_arqtmp := gene0002.fn_quebra_string(pr_string => vr_listaarqs);

    -- Acerto do log - Chamado 667957 - 05/07/2017  
    --> Final da execução com ERRO
    pc_controla_log_batch(pr_dstiplog_in => 'E',
                          pr_dscritic_in => 'TOTAL ARQUIVOS ENCONTRADOS: ' ||
                                            vr_tab_arqtmp.count,                          
                          pr_dsfixa_in   => 'ALERTA: ',
                          pr_tpocorrencia_in => 4 );  

    -- Controle de execução - Se tem ou não arquivo
    IF vr_tab_arqtmp.count = 0 THEN
      vr_temarquiv := FALSE; -- Nao tem arquivo
      -- Acerto do log - Chamado 667957 - 05/07/2017  
      pc_controla_log_batch(pr_dstiplog_in => 'E',
                            pr_dscritic_in => 'Arquivo não encontrado - Hora: ' || to_char(SYSDATE,'hh24'),                          
                            pr_dsfixa_in   => 'ALERTA: ',
                            pr_tpocorrencia_in => 4 );  
    ELSE
      vr_temarquiv := TRUE;  -- Tem arquivo na pasta
    END IF;

    pc_controla_execucao(vr_temarquiv);



    -- Leitura da PL/Table e processamento dos arquivos
    FOR idx in 1..vr_tab_arqtmp.count LOOP -- LOOP de Arquivos da PASTA

      -- Acerto do log - Chamado 667957 - 05/07/2017     
      pc_controla_log_batch(pr_dstiplog_in => 'E',
                            pr_dscritic_in => 'Processamento do arquivo: ' || vr_tab_arqtmp(idx),
                            pr_dsfixa_in   => 'ALERTA: ',
                            pr_tpocorrencia_in => 4);

      vr_tab_linhas.delete;
      vr_nmarqerr  := NULL;  -- A cada arquivo, limpa o nome do arquivo de ERROS

      -- Importar o arquivo utilizando o Layout, separado por Virgula
      gene0009.pc_importa_arq_layout(pr_nmlayout   => 'SEGAUTO'
                                    ,pr_dsdireto   => vr_dsdirrec
                                    ,pr_nmarquiv   => vr_tab_arqtmp(idx)
                                    ,pr_dscritic   => vr_dscritic
                                    ,pr_tab_linhas => vr_tab_linhas);

      IF TRIM(vr_dscritic) IS NOT NULL THEN
        vr_dscritic := vr_dscritic || ' , Arquivo: ' || vr_tab_arqtmp(idx);
      
        -- Acerto do log - Chamado 667957 - 05/07/2017     
        pc_controla_log_batch(pr_dstiplog_in => 'E',
                              pr_dscritic_in => vr_dscritic);
                
        CONTINUE; -- Passa para o proximo arquivo da lista
      END IF;

      -- Se não possuir linhas - Gera log erros
      IF vr_tab_linhas.count = 0 THEN
        vr_dscritic := 'Arquivo ' || vr_tab_arqtmp(idx) || ' não possui conteúdo!';
      
        -- Acerto do log - Chamado 667957 - 05/07/2017     
        pc_controla_log_batch(pr_dstiplog_in => 'E',
                              pr_dscritic_in => vr_dscritic);
                
        -- Gera LOG de Erro do Arquivo
        gera_log(pr_cdcooper => 3 --pr_cdcooper
                ,pr_cdprogra => vr_tab_arqtmp(idx)
                ,pr_indierro => 2 -- 1-Log Geral 2-Log Especifico Arquivo
                ,pr_cdcritic => 0
                ,pr_dscritic => 'Arquivo ' || vr_tab_arqtmp(idx)
                                || ' não possui conteúdo!'
                 );
        CONTINUE; -- Passa para o proximo arquivo da lista
          END IF;


      /*** Renato Darosci - 16/08/2016 - PRocessar o registro de memória e reordena-lo ***/
      -- Garantir que a tabela não possua registros
      vr_tab_ordena.DELETE();

      -- Limpa Novo Vetor - Chamado 667957 - 07/07/2017   
      v_linha.DELETE();

      -- Percorrer todas a tabela de memória com os dados do arquivo
      FOR vr_indice IN vr_tab_linhas.FIRST..vr_tab_linhas.LAST LOOP --LINHAS ARQUIVO

        IF vr_tab_linhas(vr_indice).exists('$ERRO$') THEN
          -- Se a linha tem erro, criar outra chave pra ela
          vr_dsdchave := to_char(SYSDATE, 'YYYY') || '1231' ||
                         to_char(SYSDATE, 'YYYY') || '1231' ||
                         LPAD(vr_indice,14,'0')   ||
                         LPAD(vr_indice,25,'0')   ||
                         LPAD(vr_indice,25,'0')   ||
                         LPAD(vr_indice,25,'0');
        ELSE
          -- Para cada linha do arquivo lida, deve montar a chave de ordenação
          vr_dsdchave := to_char(vr_tab_linhas(vr_indice)('DTINIVIGENCIA').data, 'YYYYMMDD') ||
                         to_char(vr_tab_linhas(vr_indice)('DTINIPROPOSTA').data, 'YYYYMMDD') ||
                         LPAD(vr_tab_linhas(vr_indice)('SEGURADOCPFCNPJ').numero,14,'0')     ||
                         LPAD(vr_tab_linhas(vr_indice)('NRPROPOSTA').numero,25,'0')          ||
                         LPAD(vr_tab_linhas(vr_indice)('NRAPOLICE').numero,25,'0')           ||
                         LPAD(vr_tab_linhas(vr_indice)('NRENDOSSO').numero,25,'0');
        END IF;

        -- Inclui o registro de linha na tabela de ordenação
        vr_tab_ordena(vr_dsdchave) := vr_tab_linhas(vr_indice);

      -- Carrega Novo Vetor - Chamado 667957 - 07/07/2017         
        vr_cdchave          := vr_dsdchave;
        vr_nrlinha          := vr_indice;
        v_linha(vr_cdchave) := vr_nrlinha;

      END LOOP;

      -- Excluir todos os registros da collection de linhas do arquivo
      vr_tab_linhas.DELETE();

      -- Percorrer todos os registros da collection de ordenação e transferir para a collection
      -- das linhas do arquivo de forma ordenada, conforme a chave
      vr_dsdchave := vr_tab_ordena.FIRST();


      LOOP
        -- Transferir o registro
        vr_tab_linhas(vr_tab_linhas.COUNT() + 1) := vr_tab_ordena(vr_dsdchave);

      EXIT WHEN vr_dsdchave = vr_tab_ordena.LAST();
        -- Carregar a proxima chave da sequencia
        vr_dsdchave := vr_tab_ordena.NEXT(vr_dsdchave);
      END LOOP;


      -- Limpar a tab de ordenação
      vr_tab_ordena.DELETE();
      /***********************************************************************************/


      -- Navegar em cada linha do arquivo aberto para leitura
      FOR vr_indice2 IN vr_tab_linhas.FIRST..vr_tab_linhas.LAST LOOP --LINHAS ARQUIVO

        -- Pociona chave Novo Vetor - Chamado 667957 - 07/07/2017   
        
        IF vr_tab_linhas(vr_indice2).exists('$ERRO$') THEN
          vr_cdchave :=
               to_char(SYSDATE, 'YYYY') || '1231' ||
               to_char(SYSDATE, 'YYYY') || '1231' ||
               LPAD(vr_indice2,14,'0')   ||
               LPAD(vr_indice2,25,'0')   ||
               LPAD(vr_indice2,25,'0')   ||
               LPAD(vr_indice2,25,'0');
        ELSE                  
          vr_cdchave :=
               to_char(vr_tab_linhas(vr_indice2)('DTINIVIGENCIA').data, 'YYYYMMDD') ||
               to_char(vr_tab_linhas(vr_indice2)('DTINIPROPOSTA').data, 'YYYYMMDD') ||
               LPAD(vr_tab_linhas(vr_indice2)('SEGURADOCPFCNPJ').numero,14,'0')     ||
               LPAD(vr_tab_linhas(vr_indice2)('NRPROPOSTA').numero,25,'0')          ||
               LPAD(vr_tab_linhas(vr_indice2)('NRAPOLICE').numero,25,'0')           ||
               LPAD(vr_tab_linhas(vr_indice2)('NRENDOSSO').numero,25,'0');
        END IF;
    
        vr_nrlinha := v_linha(vr_cdchave);     
         
        -- Inicializa variaveis para cada linha do arquivo
        vr_dscritic   := NULL;
        vr_tpdseguro  := 0;
        vr_reg_arquivo:= NULL;
        vr_reg_auto   := NULL;
        vr_reg_arquivo.idcontrato    := vr_indice2;  -- Relacionamento interno entre Seguros e Veiculos
        vr_reg_auto.idcontrato       := vr_indice2;  -- Esse não será gravado na tabela. Tab tem SEQUENCE
        vr_reg_arquivo.cdparceiro    := 1;           -- SICREDI
        vr_reg_arquivo.tpseguro      := 'A';         -- [P]restamista,[V]ida,[A]uto,[C]asa
        vr_reg_arquivo.inerro_import := 0;           -- Registro SEM ERRO de Agencia ou Conta
        vr_reg_arquivo.dtmvtolt      := rw_crapdat.dtmvtocd; -- Data da Importação/Cadastro do Seguro
        -- Tipo atualização dos Dados (I-Inclusão / A-Alteração / M-Manter)
        vr_reg_tpatu.tp_seguro       := 'I';
        vr_reg_tpatu.tp_auto         := 'I';
        vr_reg_tpatu.tp_vida         := 'I';
        vr_reg_tpatu.tp_casa         := 'I';
        vr_reg_tpatu.tp_prst         := 'I';


        IF vr_tab_linhas(vr_indice2).exists('$ERRO$') THEN
          
          --Problemas com importacao do layout
          vr_dscritic := vr_tab_linhas(vr_indice2)('$ERRO$').texto;
      
          -- Acerto do log - Chamado 667957 - 05/07/2017     
          pc_controla_log_batch(pr_dstiplog_in => 'E',
                                pr_dscritic_in => vr_dscritic);
                  
          -- Carrega linha original do Novo Vetor - Chamado 667957 - 07/07/2017 
          -- Gera LOG de Erro do Arquivo
          gera_log(pr_cdcooper => 3 --pr_cdcooper
                  ,pr_cdprogra => vr_tab_arqtmp(idx)
                  ,pr_indierro => 2 -- 1-Log Geral 2-Log Especifico Arquivo
                  ,pr_cdcritic => 0
                  ,pr_dscritic => 'Linha '|| vr_nrlinha || ': ' || vr_dscritic
                   );
          CONTINUE; -- Passa para o proximo arquivo da lista
        END IF;

        -- Verificar se está recebendo um cancelamento de endoso
        IF NVL(vr_tab_linhas(vr_indice2)('NRENDOSSO_CANCELA').numero,0) <> 0 THEN

          vr_nrapolice := vr_tab_linhas(vr_indice2)('NRAPOLICE').numero;
          vr_nrendosso := vr_tab_linhas(vr_indice2)('NRENDOSSO_CANCELA').numero;

          -- Buscar o endosso a ser cancelado
          OPEN  cr_endosso_cancel(vr_nrapolice
                                 ,vr_nrendosso);
          FETCH cr_endosso_cancel INTO rw_endosso_cancel;

          -- Se não encontrar o registro do endosso
          IF cr_endosso_cancel%NOTFOUND THEN
            -- Fechar cursor
            CLOSE cr_endosso_cancel;
            -- Monta
            vr_dscritic := 'Cancelamento do Endosso não pode ser efetuado! Apólice/Endosso => '
                        || vr_nrapolice ||'/'|| vr_nrendosso;
            -- Gera LOG de Erro do Arquivo
            -- Carrega linha original do Novo Vetor - Chamado 667957 - 07/07/2017 
            gera_log(pr_cdcooper => 3 --pr_cdcooper
                    ,pr_cdprogra => vr_tab_arqtmp(idx)
                    ,pr_indierro => 2 -- 1-Log Geral 2-Log Especifico Arquivo
                    ,pr_cdcritic => 0
                    ,pr_dscritic => 'Linha '|| vr_nrlinha || ': ' || vr_dscritic
                     );
            CONTINUE; -- Passa para proxima linha
          END IF;

            -- Fechar cursor
          CLOSE cr_endosso_cancel;

          -- Efetuar o cancelamento do endosso retornado
          BEGIN
            UPDATE tbseg_contratos t
               SET t.indsituacao = 'C' -- Cancelado
                 , t.flgvigente  = 0   -- não mostrar nas telas
                 , t.dtcancela   = vr_tab_linhas(vr_indice2)('DTCANCELAMENTO').data
             WHERE ROWID = rw_endosso_cancel.rowid;
          EXCEPTION
            WHEN OTHERS THEN
                                           
              ROLLBACK;
              -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
              CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);         
              -- Acerto do log - Chamado 667957 - 05/07/2017 
              -- Carrega linha original do Novo Vetor - Chamado 667957 - 07/07/2017 
              -- Gera LOG de Erro do Arquivo
              pc_controla_log_batch(pr_dstiplog_in => 'E',
                                    pr_dscritic_in => 'Linha '|| vr_nrlinha || 
                                                      ' => Erro ao atualizar Endosso: ' || SQLERRM);
                                           
              CONTINUE;
          END;

          -- Buscar o ultimo contrato antes do endosso cancelado
          OPEN  cr_endosso_ativa(rw_endosso_cancel.nrapolice);
          FETCH cr_endosso_ativa INTO rw_endosso_ativa;

          -- Se não encontrar o registro do endosso
          IF cr_endosso_ativa%NOTFOUND THEN
            -- Fechar cursor
            CLOSE cr_endosso_ativa;

            ROLLBACK; -- desfaz a transação

            -- Monta
            vr_dscritic := 'Endosso a ser ativado não encontrado! Apolice => '
                            || rw_endosso_cancel.nrapolice;

            -- Acerto do log - Chamado 667957 - 05/07/2017 
            -- Carrega linha original do Novo Vetor - Chamado 667957 - 07/07/2017 
            -- Gera LOG de Erro do Arquivo
            pc_controla_log_batch(pr_dstiplog_in => 'E',
                                  pr_dscritic_in => 'Linha '|| vr_nrlinha || ': ' || vr_dscritic);
                                  
            CONTINUE; -- Passa para proxima linha
          END IF;

          -- Fechar o cursor
          CLOSE cr_endosso_ativa;

          -- Efetuar a ativação do endosso retornado
          BEGIN
            UPDATE tbseg_contratos t
               SET t.indsituacao = 'A'
                 , t.flgvigente  = 1
                 , t.dtcancela   = NULL
             WHERE ROWID = rw_endosso_ativa.rowid;
          EXCEPTION
            WHEN OTHERS THEN
                                           
              ROLLBACK;
              -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
              CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
      
              -- Acerto do log - Chamado 667957 - 05/07/2017 
              -- Carrega linha original do Novo Vetor - Chamado 667957 - 07/07/2017 
              -- Gera LOG de Erro do Arquivo
              pc_controla_log_batch(pr_dstiplog_in => 'E',
                                    pr_dscritic_in => 'Linha '|| vr_nrlinha || 
                                                      ' => Erro ao Ativar Endosso: ' || SQLERRM);
                                           
              CONTINUE;
          END;


        ELSE

            -- TRATAMENTO DOS CONTEUDOS DAS COLUNAS

            BEGIN -- Bloco para tratamento das atribuições

              --Variaveis com os valores do que foi importado do layout
              lt_d_dtpropos                      := vr_tab_linhas(vr_indice2)('DTINIPROPOSTA'  ).data;
              vr_reg_arquivo.dtinicio_vigencia   := vr_tab_linhas(vr_indice2)('DTINIVIGENCIA'  ).data;
              vr_reg_arquivo.dttermino_vigencia  := vr_tab_linhas(vr_indice2)('DTFIMVIGENCIA'  ).data;
              vr_reg_arquivo.dtcancela           := vr_tab_linhas(vr_indice2)('DTCANCELAMENTO' ).data;

              vr_reg_arquivo.nrproposta          := NVL(vr_tab_linhas(vr_indice2)('NRPROPOSTA'     ).numero,0);
              vr_reg_arquivo.nrapolice           := NVL(vr_tab_linhas(vr_indice2)('NRAPOLICE'      ).numero,0);
              vr_reg_arquivo.nrendosso           := NVL(vr_tab_linhas(vr_indice2)('NRENDOSSO'      ).numero,0);

              vr_reg_arquivo.nrdiadebito         := NVL(vr_tab_linhas(vr_indice2)('DIADEBITO'      ).numero,0);
              vr_reg_arquivo.qtparcelas          := NVL(vr_tab_linhas(vr_indice2)('QTDPARCELAS'    ).numero,0);
              vr_reg_arquivo.nrcpf_cnpj_segurado := NVL(vr_tab_linhas(vr_indice2)('SEGURADOCPFCNPJ').numero,0);
              vr_reg_auto.nrano_fabrica          := NVL(vr_tab_linhas(vr_indice2)('VEICULOANO'     ).numero,0);
              vr_reg_auto.nrano_modelo           := NVL(vr_tab_linhas(vr_indice2)('VEICULOMODELO'  ).numero,0);
              vr_reg_arquivo.percomissao         := NVL(vr_tab_linhas(vr_indice2)('VLRPERCOMISSAO' ).numero,0) / 100;
              vr_reg_arquivo.tpendosso           := NVL(vr_tab_linhas(vr_indice2)('ENDOSSOTIPO'    ).numero,0);
              vr_reg_arquivo.tpsub_endosso       := NVL(vr_tab_linhas(vr_indice2)('ENDOSSOSUBTIPO' ).numero,0);

              vr_reg_arquivo.nmsegurado          := UPPER(TRIM(REPLACE(vr_tab_linhas(vr_indice2)('SEGURADONOME'  ).texto,'"','')));
              vr_reg_auto.nmmarca                := UPPER(TRIM(REPLACE(vr_tab_linhas(vr_indice2)('VEICULOMARCA'  ).texto,'"','')));
              vr_reg_auto.dsmodelo               := UPPER(TRIM(REPLACE(vr_tab_linhas(vr_indice2)('VEICULOTIPO'   ).texto,'"','')));
              vr_reg_auto.dsplaca                := UPPER(TRIM(REPLACE(vr_tab_linhas(vr_indice2)('VEICULOPLACA'  ).texto,'"','')));
              vr_reg_auto.dschassi               := UPPER(NVL(TRIM(REPLACE(vr_tab_linhas(vr_indice2)('VEICULOCHASSI' ).texto,'"','')),'0'));
              vr_reg_auto.cdfipe                 := TRIM(REPLACE(vr_tab_linhas(vr_indice2)('VEICULOFIPE'   ).texto,'"',''));

              -- SITUACAO => [A]tivo,[V]encido,[R]enovado,[C]ancelado
              CASE TRIM(REPLACE(vr_tab_linhas(vr_indice2)('SITUACAO').texto,'"',''))
                WHEN 'Ativa'     THEN vr_reg_arquivo.indsituacao := 'A';
                WHEN 'Cancelada' THEN vr_reg_arquivo.indsituacao := 'C';
                WHEN 'Suspensa'  THEN vr_reg_arquivo.indsituacao := 'C';
                WHEN 'Renovada'  THEN vr_reg_arquivo.indsituacao := 'V'; -- Conforme email Zago(Sicredi), tratar Renovadas como Vencidas
                WHEN 'Vencida'   THEN vr_reg_arquivo.indsituacao := 'V';
                ELSE vr_dscritic := 'Situação inválida! => ' || TRIM(REPLACE(vr_tab_linhas(vr_indice2)('SITUACAO').texto,'"','')) ;
                  -- Carrega linha original do Novo Vetor - Chamado 667957 - 07/07/2017 
                  -- Gera LOG de Erro do Arquivo
                  gera_log(pr_cdcooper => 3 --pr_cdcooper
                          ,pr_cdprogra => vr_tab_arqtmp(idx)
                          ,pr_indierro => 2 -- 1-Log Geral 2-Log Especifico Arquivo
                          ,pr_cdcritic => 0
                          ,pr_dscritic => 'Linha '|| vr_nrlinha || ': ' || vr_dscritic
                           );
                  CONTINUE; -- Passa para proxima linha
              END CASE;

              -- Verifica Data Fim Vigencia e muda situação
              IF  vr_reg_arquivo.indsituacao = 'A'  -- ATIVA
              AND vr_reg_arquivo.dttermino_vigencia <= rw_crapdat.dtmvtocd THEN
                vr_reg_arquivo.indsituacao := 'V'; -- VENCIDA
              END IF;


              -- SEGURADORA - ATENÇÃO: SICREDI MANDA SEGURADORA PELO NOME E NAO POR CODIGO OU CNPJ
              -- SICREDI AUTO POSSUÍA APENAS 3 SEGURADORAS ATE O MOMENTO DA LIBERAÇÃO DO PROJETO (JUL/2016)

              IF fn_valida_seguradora(UPPER(TRIM(REPLACE(vr_tab_linhas(vr_indice2)('SEGURADORANOME').texto,'"','')))
                                     ,'HDI SEGUROS S/A') THEN
                  -- Verificar se o seguro é do tipo "Carta Verde"
                  IF (SUBSTR(LPAD(vr_reg_arquivo.nrapolice, 14,'0'),6,3) = '133') THEN
                    -- Ignora as informações de apólices do tipo "Carta Verde", pois
                    -- a carta é um produto exclusivo da seguradora HDI
                    CONTINUE;
                  END IF;
                  vr_reg_arquivo.cdsegura := 6572;

              ELSIF fn_valida_seguradora(UPPER(TRIM(REPLACE(vr_tab_linhas(vr_indice2)('SEGURADORANOME').texto,'"','')))
                                       ,'MAPFRE SEGURADORA S/A') THEN
                 vr_reg_arquivo.cdsegura := 12;

              ELSIF fn_valida_seguradora(UPPER(TRIM(REPLACE(vr_tab_linhas(vr_indice2)('SEGURADORANOME').texto,'"','')))
                                        ,'SUL AMÉRICA CIA NAC DE SEGUROS') THEN
                vr_reg_arquivo.cdsegura := 39284;

              ELSE
                vr_dscritic := 'Seguradora inválida! => ' || UPPER(TRIM(REPLACE(vr_tab_linhas(vr_indice2)('SEGURADORANOME').texto,'"','')));
                -- Carrega linha original do Novo Vetor - Chamado 667957 - 07/07/2017 
                -- Gera LOG de Erro do Arquivo
                gera_log(pr_cdcooper => 3 --pr_cdcooper
                        ,pr_cdprogra => vr_tab_arqtmp(idx)
                        ,pr_indierro => 2 -- 1-Log Geral 2-Log Especifico Arquivo
                        ,pr_cdcritic => 0
                        ,pr_dscritic => 'Linha '|| vr_nrlinha || ': ' || vr_dscritic
                        );
                CONTINUE; -- Passa para proxima linha

              END IF;

              lt_d_nr_do_ci := TRIM(REPLACE(vr_tab_linhas(vr_indice2)('NUMEROCI'      ).texto,'"',''));

            EXCEPTION
              WHEN OTHERS THEN   
                -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
                CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
                -- Erro de Atribuição / Tipo inválido
                vr_dscritic := 'Tipo de dado inválido recebido! (Caracteres não numéricos)';
                -- Carrega linha original do Novo Vetor - Chamado 667957 - 07/07/2017 
                -- Gera LOG de Erro do Arquivo
                gera_log(pr_cdcooper => 3 --pr_cdcooper
                        ,pr_cdprogra => vr_tab_arqtmp(idx)
                        ,pr_indierro => 2 -- 1-Log Geral 2-Log Especifico Arquivo
                        ,pr_cdcritic => 0
                        ,pr_dscritic => 'Linha '|| vr_nrlinha || ': ' || vr_dscritic
                        );
                CONTINUE; -- Passa para proxima linha
            END;

            -- Validar SEGURADOCONTA
            IF regexp_like (vr_tab_linhas(vr_indice2)('SEGURADOCONTA').texto,'[^0-9]') THEN
              -- Encontrou caracteres diferentes de 0 a 9
              vr_dscritic := 'Conteúdo inválido no campo CONTA/DV: ' ||
                             vr_tab_linhas(vr_indice2)('SEGURADOCONTA').texto;
              -- Carrega linha original do Novo Vetor - Chamado 667957 - 07/07/2017 
              -- Gera LOG de Erro do Arquivo
              gera_log(pr_cdcooper => 3 --pr_cdcooper
                      ,pr_cdprogra => vr_tab_arqtmp(idx)
                      ,pr_indierro => 2 -- 1-Log Geral 2-Log Especifico Arquivo
                      ,pr_cdcritic => 0
                      ,pr_dscritic => 'Linha '|| vr_nrlinha || ': ' || vr_dscritic
                       );
              CONTINUE; -- Passa para proxima linha
            ELSE -- AGENCIA CONTA contem apenas numeros
              lt_d_nragecta           := vr_tab_linhas(vr_indice2)('SEGURADOCONTA').texto;
              vr_cdagectl             := to_number(substr(lt_d_nragecta,0,3));

              vr_reg_arquivo.nrdconta := to_number(substr(lt_d_nragecta,4));
              vr_reg_arquivo.cdcooper := vr_cdagectl;

              -- VALIDAR AGENCIA/COOPERATIVA
              OPEN cr_crapcop (p_cdagectl => vr_cdagectl);
              FETCH cr_crapcop INTO rw_crapcop;
              --Se nao Encontrou
              IF cr_crapcop%NOTFOUND THEN
                CLOSE cr_crapcop;
                vr_dscritic := '=> Agência inválida: ' || vr_cdagectl || ' => "' || lt_d_nragecta || '"';
      
                -- Acerto do log - Chamado 667957 - 05/07/2017 
                -- Carrega linha original do Novo Vetor - Chamado 667957 - 07/07/2017 
                -- Gera LOG de Erro do Arquivo
                pc_controla_log_batch(pr_dstiplog_in => 'E',
                                      pr_dscritic_in => 'Linha '|| vr_nrlinha || ': ' || vr_dscritic);
                         
                -- Houve erro na Agencia/Conta
                vr_reg_arquivo.inerro_import := 1; -- Registro COM ERRO de Agencia ou Conta


              ELSE  -- Encontrou Cooperativa
        
                CLOSE cr_crapcop;

                vr_reg_arquivo.cdcooper := rw_crapcop.cdcooper;

                -- VALIDAR CONTA ASSOCIADO
                OPEN cr_crapass (p_cdcooper => vr_reg_arquivo.cdcooper
                                ,p_nrdconta => vr_reg_arquivo.nrdconta);
                FETCH cr_crapass INTO rw_crapass;
                --Se nao Encontrou
                IF cr_crapass%NOTFOUND THEN
                  CLOSE cr_crapass;
                           
                  vr_dscritic := '=> Conta não encontrada na Agencia informada: ' 
                                  || vr_reg_arquivo.nrdconta
                                  || ' => "' || lt_d_nragecta || '"';
      
                  -- Acerto do log - Chamado 667957 - 05/07/2017 
                  -- Carrega linha original do Novo Vetor - Chamado 667957 - 07/07/2017   
                  -- Gera LOG de Erro do Arquivo
                  pc_controla_log_batch(pr_dstiplog_in => 'E',
                                        pr_dscritic_in => 'Linha '|| vr_nrlinha || ': ' || vr_dscritic);
                           
                  -- Houve erro na Agencia/Conta
                  vr_reg_arquivo.inerro_import := 1; -- Registro COM ERRO de Agencia ou Conta
                ELSE
                  CLOSE cr_crapass;
                END IF; -- FIM cr_crapass
              END IF; -- FIM cr_CRAPCOP

              -- TENTAR LOCALIZAR COOP/CONTA PELO CPF/CNPJ
              IF vr_reg_arquivo.inerro_import = 1 THEN
                OPEN cr_ass_cpfcnpj (p_nrcpfcgc => vr_reg_arquivo.nrcpf_cnpj_segurado);
                FETCH cr_ass_cpfcnpj INTO rw_ass_cpfcnpj;

                IF  cr_ass_cpfcnpj%FOUND
                AND rw_ass_cpfcnpj.qtd_reg = 1 THEN
                  vr_reg_arquivo.cdcooper      := rw_ass_cpfcnpj.cdcooper;
                  vr_reg_arquivo.nrdconta      := rw_ass_cpfcnpj.nrdconta;
                  vr_reg_arquivo.inerro_import := 0; -- Limpa erro se achou COOP/CONTA
                END IF;
                CLOSE cr_ass_cpfcnpj;
              END IF;

            END IF;

            -- Validar PRESTACAO
            IF regexp_like (vr_tab_linhas(vr_indice2)('VLRPRESTACAO').texto,'[^0-9-]') THEN
              -- Encontrou caracteres diferentes de 0 a 9 e "-"
              vr_dscritic := 'Conteúdo inválido no campo VLR PRESTACAO';
              -- Carrega linha original do Novo Vetor - Chamado 667957 - 07/07/2017 
              -- Gera LOG de Erro do Arquivo
              gera_log(pr_cdcooper => 3 --pr_cdcooper
                      ,pr_cdprogra => vr_tab_arqtmp(idx)
                      ,pr_indierro => 2 -- 1-Log Geral 2-Log Especifico Arquivo
                      ,pr_cdcritic => 0
                      ,pr_dscritic => 'Linha '|| vr_nrlinha || ': ' || vr_dscritic
                       );
              CONTINUE; -- Passa para proxima linha
            ELSE
              vr_reg_arquivo.vlparcela := to_number( SUBSTR(vr_tab_linhas(vr_indice2)('VLRPRESTACAO').texto,
                                          INSTR(vr_tab_linhas(vr_indice2)('VLRPRESTACAO').texto,'-') ) ) / 100;
            END IF;

            -- Validar TOTPREMIOBRUTO
            IF regexp_like (vr_tab_linhas(vr_indice2)('TOTPREMIOBRUTO').texto,'[^0-9-]') THEN
              -- Encontrou caracteres diferentes de 0 a 9 e "-"
              vr_dscritic := 'Conteúdo inválido no campo TOT.PREMIO BRUTO';
              -- Carrega linha original do Novo Vetor - Chamado 667957 - 07/07/2017 
              -- Gera LOG de Erro do Arquivo
              gera_log(pr_cdcooper => 3 --pr_cdcooper
                      ,pr_cdprogra => vr_tab_arqtmp(idx)
                      ,pr_indierro => 2 -- 1-Log Geral 2-Log Especifico Arquivo
                      ,pr_cdcritic => 0
                      ,pr_dscritic => 'Linha '|| vr_nrlinha || ': ' || vr_dscritic
                       );
              CONTINUE; -- Passa para proxima linha
            ELSE
              vr_reg_arquivo.vlpremio_total := to_number( SUBSTR(vr_tab_linhas(vr_indice2)('TOTPREMIOBRUTO').texto,
                                               INSTR(vr_tab_linhas(vr_indice2)('TOTPREMIOBRUTO').texto,'-') ) ) / 100;
            END IF;

            -- Validar TOTPREMIOLIQUIDO
            IF regexp_like (vr_tab_linhas(vr_indice2)('TOTPREMIOLIQUIDO').texto,'[^0-9-]') THEN
              -- Encontrou caracteres diferentes de 0 a 9 e "-"
              vr_dscritic := 'Conteúdo inválido no campo TOT. PREMIO LIQUIDO';
              -- Carrega linha original do Novo Vetor - Chamado 667957 - 07/07/2017 
              -- Gera LOG de Erro do Arquivo
              gera_log(pr_cdcooper => 3 --pr_cdcooper
                      ,pr_cdprogra => vr_tab_arqtmp(idx)
                      ,pr_indierro => 2 -- 1-Log Geral 2-Log Especifico Arquivo
                      ,pr_cdcritic => 0
                      ,pr_dscritic => 'Linha '|| vr_nrlinha || ': ' || vr_dscritic
                       );
              CONTINUE; -- Passa para proxima linha
            ELSE
              vr_reg_arquivo.vlpremio_liquido := to_number( SUBSTR(vr_tab_linhas(vr_indice2)('TOTPREMIOLIQUIDO').texto,
                                                 INSTR(vr_tab_linhas(vr_indice2)('TOTPREMIOLIQUIDO').texto,'-') ) ) / 100;
            END IF;

            -- Validar VLRFRANQUIA
            IF regexp_like (vr_tab_linhas(vr_indice2)('VLRFRANQUIA').texto,'[^0-9-]') THEN
              -- Encontrou caracteres diferentes de 0 a 9 e "-"
              vr_dscritic := 'Conteúdo inválido no campo VLR. FRANQUIA';
              -- Carrega linha original do Novo Vetor - Chamado 667957 - 07/07/2017 
              -- Gera LOG de Erro do Arquivo
              gera_log(pr_cdcooper => 3 --pr_cdcooper
                      ,pr_cdprogra => vr_tab_arqtmp(idx)
                      ,pr_indierro => 2 -- 1-Log Geral 2-Log Especifico Arquivo
                      ,pr_cdcritic => 0
                      ,pr_dscritic => 'Linha '|| vr_nrlinha || ': ' || vr_dscritic
                       );
              CONTINUE; -- Passa para proxima linha
            ELSE
              vr_reg_auto.vlfranquia := to_number( SUBSTR(vr_tab_linhas(vr_indice2)('VLRFRANQUIA').texto,
                                        INSTR(vr_tab_linhas(vr_indice2)('VLRFRANQUIA').texto,'-') ) ) / 100;
            END IF;

            --    TERMINOU DE LER O CONTEUDO DO ARQUIVO
            --    INICIO DAS VALIDAÇÕES

            IF  vr_reg_arquivo.nrproposta <> 0
            AND vr_reg_arquivo.nrapolice   = 0
            AND vr_reg_arquivo.nrendosso   = 0 THEN
              -- É PROPOSTA
              vr_tpdseguro                 := 1;
              vr_reg_arquivo.tpendosso     := NULL;
              vr_reg_arquivo.tpsub_endosso := NULL;
            ELSIF vr_reg_arquivo.nrproposta <> 0
              AND vr_reg_arquivo.nrapolice  <> 0
              AND vr_reg_arquivo.nrendosso   = 0 THEN
              -- É APOLICE
              vr_tpdseguro := 2;
              vr_reg_arquivo.tpendosso     := NULL;
              vr_reg_arquivo.tpsub_endosso := NULL;
            ELSIF vr_reg_arquivo.nrapolice  <> 0
              --AND vr_reg_arquivo.nrproposta <> 0  -- COMENTADO PARA PASSAR PELO ERRO DO SICREDI AO MANDAR PROPOSTA = 0 QUANDO ENDOSSO
              AND vr_reg_arquivo.nrendosso  <> 0 THEN
              -- É ENDOSSO
              vr_tpdseguro := 3;

              -- Verificar se o Endosso já foi recebido anteriormente
              OPEN  cr_endosso_recebido(vr_reg_arquivo.nrapolice
                                       ,vr_reg_arquivo.nrendosso);
              FETCH cr_endosso_recebido INTO rw_endosso_recebido;

              -- Se encontrar o endosso recebido
              IF cr_endosso_recebido%FOUND THEN
                -- fechar o cursor
                CLOSE cr_endosso_recebido;

                -- Gerar erro no log enviado para o Sicredi
                vr_dscritic := '=> Endosso já processado anteriormente: ' || vr_reg_arquivo.nrapolice || '/' ||
                                vr_reg_arquivo.nrendosso;
                -- Carrega linha original do Novo Vetor - Chamado 667957 - 07/07/2017 
                -- Gera LOG de Erro do Arquivo
                gera_log(pr_cdcooper => 3 --pr_cdcooper
                        ,pr_cdprogra => vr_tab_arqtmp(idx)
                        ,pr_indierro => 2 -- 1-Log Geral 2-Log Especifico Arquivo
                        ,pr_cdcritic => 0
                        ,pr_dscritic => 'Linha '|| vr_nrlinha || ': ' || vr_dscritic
                         );
                CONTINUE; -- Passa para proxima linha
              END IF;

              -- Fechar o cursor caso ainda esteja aberto
              IF cr_endosso_recebido%ISOPEN THEN
                 CLOSE cr_endosso_recebido;
              END IF;

              -- VALIDAR TIPO E SUBTIPO ENDOSSO SE É VALIDO
              OPEN  cr_tpendosso (p_tpendosso     => vr_reg_arquivo.tpendosso
                                 ,p_tpsub_endosso => vr_reg_arquivo.tpsub_endosso);
              FETCH cr_tpendosso INTO rw_tpendosso;
              --Se nao Encontrou
              IF cr_tpendosso%NOTFOUND THEN
                CLOSE cr_tpendosso;
                vr_dscritic := '=> Tipo/Subtipo do Endosso inválido: ' || vr_reg_arquivo.tpendosso || '/' ||
                                vr_reg_arquivo.tpsub_endosso;
      
                -- Acerto do log - Chamado 667957 - 05/07/2017 
                -- Carrega linha original do Novo Vetor - Chamado 667957 - 07/07/2017 
                -- Gera LOG de Erro do Arquivo
                pc_controla_log_batch(pr_dstiplog_in => 'E',
                                      pr_dscritic_in => 'Linha '|| vr_nrlinha || ': ' || vr_dscritic);
                         
                CONTINUE; -- Passa para proxima linha
              END IF;
              CLOSE cr_tpendosso;
            ELSE
              IF  vr_reg_arquivo.nrproposta = 0
              AND vr_reg_arquivo.nrapolice  = 0
              AND vr_reg_arquivo.nrendosso  = 0 THEN
                -- REGISTRO INVALIDO!
                vr_dscritic := 'Número Proposta, Apólice e Endosso estão Zero!';
              ELSE
                vr_dscritic := 'Problemas com os dados do Seguro! ' ||
                               'Proposta('     || vr_reg_arquivo.nrproposta ||
                               '), Apólice ('  || vr_reg_arquivo.nrapolice  ||
                               ') e Endosso (' || vr_reg_arquivo.nrendosso  || ')!';
              END IF;
              -- Carrega linha original do Novo Vetor - Chamado 667957 - 07/07/2017 
              -- Gera LOG de Erro do Arquivo
              gera_log(pr_cdcooper => 3 --pr_cdcooper
                      ,pr_cdprogra => vr_tab_arqtmp(idx)
                      ,pr_indierro => 2 -- 1-Log Geral 2-Log Especifico Arquivo
                      ,pr_cdcritic => 0
                      ,pr_dscritic => 'Linha '|| vr_nrlinha || ': ' || vr_dscritic
                       );
              CONTINUE; -- Passa para proxima linha
            END  IF;


            CASE vr_tpdseguro
              WHEN 1 THEN  -- PROPOSTA
                -- VALIDAR SE PROPOSTA JA EXISTE NESSA COOPER/CONTA
                OPEN cr_seg_proposta(p_cdcooper => vr_reg_arquivo.cdcooper
                                    ,p_nrdconta => vr_reg_arquivo.nrdconta
                                    ,p_nrpropos => vr_reg_arquivo.nrproposta);
                FETCH cr_seg_proposta INTO rw_seg_base;
                vr_found_seg := cr_seg_proposta%FOUND;
                CLOSE cr_seg_proposta;
              WHEN 2 THEN  -- APOLICE
                -- VALIDAR SE APOLICE JA EXISTE NESSA COOPER/CONTA
                OPEN cr_seg_apolice (p_cdcooper => vr_reg_arquivo.cdcooper
                                    ,p_nrdconta => vr_reg_arquivo.nrdconta
                                    ,p_nrapolic => vr_reg_arquivo.nrapolice);
                FETCH cr_seg_apolice INTO rw_seg_base;
                vr_found_seg := cr_seg_apolice%FOUND;
                CLOSE cr_seg_apolice;
              WHEN 3 THEN  -- ENDOSSO
                -- VALIDAR SE ENDOSSO JA EXISTE NESSA COOPER/CONTA
                OPEN cr_seg_endosso (p_cdcooper => vr_reg_arquivo.cdcooper
                                    ,p_nrdconta => vr_reg_arquivo.nrdconta
                                    ,p_nrapolic => vr_reg_arquivo.nrapolice
                                    ,p_nrendoss => vr_reg_arquivo.nrendosso);
                FETCH cr_seg_endosso INTO rw_seg_base;
                vr_found_seg := cr_seg_endosso%FOUND;
                CLOSE cr_seg_endosso;
            END CASE;



            --Se nao Encontrou na base
            IF NOT vr_found_seg THEN

              -- ATENCAO: PARA OS CASOS DE ENDOSSO, APENAS A APOLICE VEM A MESMA
              -- POREM, A PROPOSTA SERÁ OUTRA.

              vr_reg_tpatu.tp_seguro    := 'I'; -- INSERE DADOS
              vr_reg_tpatu.tp_auto      := 'I'; -- INSERE DADOS
              vr_reg_arquivo.flgvigente  := 1;


              IF vr_tpdseguro = 2 THEN -- APOLICE
                -- VALIDAR SE PROPOSTA JA EXISTE NESSA COOPER/CONTA
                OPEN cr_seg_proposta(p_cdcooper => vr_reg_arquivo.cdcooper
                                    ,p_nrdconta => vr_reg_arquivo.nrdconta
                                    ,p_nrpropos => vr_reg_arquivo.nrproposta);
                FETCH cr_seg_proposta INTO rw_seg_base;
                vr_found_ant := cr_seg_proposta%FOUND;
                CLOSE cr_seg_proposta;

                --SE ENCONTROU PROPOSTA NA BASE
                IF  vr_found_ant THEN
                  OPEN  cr_auto_base(p_idcontrato => rw_seg_base.idcontrato);
                  FETCH cr_auto_base INTO rw_auto_base;
                  CLOSE cr_auto_base;

                  -- ATUALIZA PROPOSTA EXISTENTE COM OS DADOS IMPORTADOS DE APOLICE
                  vr_reg_tpatu.tp_seguro    := 'A'; -- ATUALIZA DADOS
                  vr_reg_tpatu.tp_auto      := 'A'; -- ATUALIZA DADOS
                  -- AQUI
                  vr_reg_arquivo.idcontrato := rw_seg_base.idcontrato;
                  vr_reg_auto.idcontrato    := rw_auto_base.idcontrato;


                  -- QUANDO PROPOSTA JA FOI ENVIADA E É RECEBIDA UMA APOLICE
                  -- O VALOR DA FRANQUIA ESTA VINDO ZERO NA COLUNA DA APOLICE.
                  IF vr_reg_auto.vlfranquia IS NULL
                  OR vr_reg_auto.vlfranquia = 0 THEN
                    vr_reg_auto.vlfranquia := rw_auto_base.vlfranquia;
                  END IF;
                END IF;

              ELSIF  vr_tpdseguro = 3 THEN
                -- Se é um Endosso e nao existir na base ainda, já cria como CANCELADO

                -- VALIDAR SE APOLICE JA EXISTE NESSA COOPER/CONTA
                OPEN cr_seg_apolice (p_cdcooper => vr_reg_arquivo.cdcooper
                                    ,p_nrdconta => vr_reg_arquivo.nrdconta
                                    ,p_nrapolic => vr_reg_arquivo.nrapolice);
                FETCH cr_seg_apolice INTO rw_seg_base;
                vr_found_ant := cr_seg_apolice%FOUND;
                CLOSE cr_seg_apolice;
                IF  NOT vr_found_ant THEN
                  -- ERRO - Apólice não existe e recebeu um endosso
                  -- Carrega linha original do Novo Vetor - Chamado 667957 - 07/07/2017 
                  -- Gera LOG de Erro do Arquivo
                  gera_log(pr_cdcooper => 3 --pr_cdcooper
                          ,pr_cdprogra => vr_tab_arqtmp(idx)
                          ,pr_indierro => 2 -- 1-Log Geral 2-Log Especifico Arquivo
                          ,pr_cdcritic => 0
                          ,pr_dscritic => 'Linha '|| vr_nrlinha || ': Recebimento de ENDOSSO para APÓLICE inexistente!' ||
                                          ' Apólice ('   || vr_reg_arquivo.nrapolice  ||
                                          ') e Endosso ('  || vr_reg_arquivo.nrendosso  || ')'
                           );

                  CONTINUE;

                ELSE
                  vr_reg_tpatu.tp_seguro   := 'Y';  -- Inserir dados do seguro, inativando o registro anterior

                  -- Se tá ZERO, erro do SICREDI
                  IF vr_reg_arquivo.nrproposta = 0 THEN
                    vr_reg_arquivo.nrproposta := rw_seg_base.nrproposta;
                  END IF;

                  IF vr_reg_arquivo.tpendosso IN (4,5) THEN
                    vr_reg_arquivo.indsituacao := 'C'; -- Altera a situado Seguro para CANCELADO
                    vr_reg_arquivo.dtcancela   := rw_crapdat.dtmvtocd;

                    -- QUANDO CANCELAMENTO, MANTEM OS DADOS DO
                    -- ULTIMO VEICULO DA APOLICE ATIVA
                    -- CONSULTAR VEICULO DA APOLICE
                    OPEN  cr_auto_base(p_idcontrato => rw_seg_base.idcontrato);
                    FETCH cr_auto_base INTO rw_auto_base;
                    CLOSE cr_auto_base;

                    -- Manter o automovel atual copiando os dados do veículo
                    vr_reg_auto.idveiculo            := NVL(vr_reg_auto.idveiculo     ,rw_auto_base.idveiculo);
                    vr_reg_auto.nmmarca              := NVL(TRIM(vr_reg_auto.nmmarca) ,rw_auto_base.nmmarca);
                    vr_reg_auto.dsmodelo             := NVL(TRIM(vr_reg_auto.dsmodelo),rw_auto_base.dsmodelo);
                    vr_reg_auto.nrano_fabrica        := NVL(vr_reg_auto.nrano_fabrica ,rw_auto_base.nrano_fabrica);
                    vr_reg_auto.nrano_modelo         := NVL(vr_reg_auto.nrano_modelo  ,rw_auto_base.nrano_modelo);
                    vr_reg_auto.dsplaca              := NVL(TRIM(vr_reg_auto.dsplaca) ,rw_auto_base.dsplaca);
                    vr_reg_auto.dschassi             := NVL(TRIM(vr_reg_auto.dschassi),rw_auto_base.dschassi);
                    vr_reg_auto.cdfipe               := NVL(vr_reg_auto.cdfipe        ,rw_auto_base.cdfipe);
                    vr_reg_auto.vlfranquia           := NVL(vr_reg_auto.vlfranquia    ,rw_auto_base.vlfranquia);

                  END IF;
                END IF;
              END IF;

            ELSE  -- ENCONTROU O REGISTRO NA BASE

              IF  vr_tpdseguro = 1 THEN                                      -- SE FOR PROPOSTA
                IF  vr_reg_arquivo.nrproposta          = rw_seg_base.nrproposta  -- PROPOSTA ARQUIVO = PROPOSTA BASE
                AND vr_reg_arquivo.nrcpf_cnpj_segurado = rw_seg_base.nrcpf_cnpj_segurado
                AND vr_reg_arquivo.dtinicio_vigencia   = rw_seg_base.dtinicio_vigencia THEN
                  vr_reg_tpatu.tp_seguro    := 'A';  --  ALTERA os dados do Seguro cadastrado
                  -- AQUI
                  vr_reg_arquivo.idcontrato := rw_seg_base.idcontrato;
                  vr_reg_auto.idcontrato    := rw_auto_base.idcontrato;
                ELSE
                  vr_reg_tpatu.tp_seguro   := 'I';  --  INCLUI os dados do Seguro cadastrado
                END IF;
              ELSE
                  vr_reg_tpatu.tp_seguro   := 'Y';  -- Inserir dados do seguro, inativando o registro anterior
              END IF;

              -- Tratar repetição - Possivel erro do envio por parte Sicredi
              -- Se um registro de apõlice for enviado novamente, irá apenas informar no
              -- log enviado a Sicredi e passará a próxima linha
              IF  vr_tpdseguro = 2  -- Apolice
              AND vr_reg_arquivo.nrapolice = rw_seg_base.nrapolice THEN
                  -- Apolice da Linha = Apolice da Base. Não pode importar

                -- Carrega linha original do Novo Vetor - Chamado 667957 - 07/07/2017 
                -- Gera LOG de Erro do Arquivo
                gera_log(pr_cdcooper => 3 --pr_cdcooper
                        ,pr_cdprogra => vr_tab_arqtmp(idx)
                        ,pr_indierro => 2 -- 1-Log Geral 2-Log Especifico Arquivo
                        ,pr_cdcritic => 0
                        ,pr_dscritic => 'Linha '|| vr_nrlinha || ': Identificado envio de registro duplicado.' ||
                                        ' Proposta('     || vr_reg_arquivo.nrproposta ||
                                        '), Apólice ('   || vr_reg_arquivo.nrapolice  ||
                                        ') e Endosso ('  || vr_reg_arquivo.nrendosso  || ')'
                         );

                CONTINUE;

              -- ENDOSSO de CANCELAMENTO -> Mantem dados do VEICULO e inclui o endosso de cancelamento
              ELSIF  vr_reg_arquivo.tpendosso IN (4,5) THEN -- Seguro da Linha
                vr_reg_tpatu.tp_auto      := 'I'; -- Passa como I para que sejam replicados os dados para o novo idContrato

                -- Se o endosso ativo da Apolice já for de cancelamento
                IF  rw_seg_base.nrendosso   <> 0
                AND rw_seg_base.tpendosso    IN (4,5) THEN
                  -- Carrega linha original do Novo Vetor - Chamado 667957 - 07/07/2017 
                  -- Gera LOG de Erro do Arquivo
                  gera_log(pr_cdcooper => 3 --pr_cdcooper
                          ,pr_cdprogra => vr_tab_arqtmp(idx)
                          ,pr_indierro => 2 -- 1-Log Geral 2-Log Especifico Arquivo
                          ,pr_cdcritic => 0
                          ,pr_dscritic => 'Linha '|| vr_nrlinha || ': Apólice ' || vr_reg_arquivo.nrapolice || ' já recebeu endosso de cancelamento. '
                           );
                  CONTINUE;
                END IF;

                -- CONSULTAR VEICULO DA APOLICE
                OPEN  cr_auto_base(p_idcontrato => rw_seg_base.idcontrato);
                FETCH cr_auto_base INTO rw_auto_base;
                CLOSE cr_auto_base;

                -- Manter o automovel atual copiando os dados do veículo
                vr_reg_auto.idveiculo            := rw_auto_base.idveiculo;
                vr_reg_auto.nmmarca              := rw_auto_base.nmmarca;
                vr_reg_auto.dsmodelo             := rw_auto_base.dsmodelo;
                vr_reg_auto.nrano_fabrica        := rw_auto_base.nrano_fabrica;
                vr_reg_auto.nrano_modelo         := rw_auto_base.nrano_modelo;
                vr_reg_auto.dsplaca              := rw_auto_base.dsplaca;
                vr_reg_auto.dschassi             := rw_auto_base.dschassi;
                vr_reg_auto.cdfipe               := rw_auto_base.cdfipe;
                vr_reg_auto.vlfranquia           := rw_auto_base.vlfranquia;

                --vr_reg_arquivo.dtcancela   := vr_reg_arquivo.dtinicio_vigencia;

                -- Deve resetar os valores do registro de memória com os dados do seguro e atualizar
                -- apenas os valores especificos, despresando assim as informações do arquivo
                vr_reg_arquivo.idcontrato         := rw_seg_base.idcontrato;
                vr_reg_arquivo.cdparceiro         := rw_seg_base.cdparceiro;
                vr_reg_arquivo.tpseguro           := rw_seg_base.tpseguro;
                vr_reg_arquivo.nrproposta         := rw_seg_base.nrproposta;
                vr_reg_arquivo.nrapolice          := rw_seg_base.nrapolice;
                vr_reg_arquivo.cdcooper           := rw_seg_base.cdcooper;
                vr_reg_arquivo.nrdconta           := rw_seg_base.nrdconta;
                vr_reg_arquivo.nrcpf_cnpj_segurado:= rw_seg_base.nrcpf_cnpj_segurado;
                vr_reg_arquivo.nmsegurado         := rw_seg_base.nmsegurado;
                -- INFORMAÇÕES QUE SERÃO ATUALIZADAS - Desta forma não receberão o valor da base
                --vr_reg_arquivo.nrendosso          := rw_seg_base.nrendosso;
                --vr_reg_arquivo.tpendosso          := rw_seg_base.tpendosso;
                --vr_reg_arquivo.tpsub_endosso      := rw_seg_base.tpsub_endosso;
                vr_reg_arquivo.nrapolice_renovacao:= rw_seg_base.nrapolice_renovacao;
                --vr_reg_arquivo.dtinicio_vigencia  := rw_seg_base.dtinicio_vigencia;
                --vr_reg_arquivo.dttermino_vigencia := rw_seg_base.dttermino_vigencia;
                vr_reg_arquivo.cdsegura           := rw_seg_base.cdsegura;

                -- Tipo de endosso igual a 4 ou 5 indicam o cancelamento do seguro, dessa
                -- forma já serão inseridos na base como cancelado
                vr_reg_arquivo.indsituacao        := 'C'; -- rw_seg_base.indsituacao;
                vr_reg_arquivo.flgvigente         := 1;

                --vr_reg_arquivo.dtcancela          := rw_seg_base.dtcancela;
                vr_reg_arquivo.vlpremio_liquido   := rw_seg_base.vlpremio_liquido;
                vr_reg_arquivo.vlpremio_total     := rw_seg_base.vlpremio_total;
                vr_reg_arquivo.nrdiadebito        := rw_seg_base.nrdiadebito;
                vr_reg_arquivo.qtparcelas         := rw_seg_base.qtparcelas;
                vr_reg_arquivo.vlparcela          := rw_seg_base.vlparcela;
                vr_reg_arquivo.percomissao        := rw_seg_base.percomissao;
                vr_reg_arquivo.dsobservacao       := rw_seg_base.dsobservacao;
                vr_reg_arquivo.vlcapital          := rw_seg_base.vlcapital;
                vr_reg_arquivo.inerro_import      := rw_seg_base.inerro_import;
                vr_reg_arquivo.dtmvtolt           := rw_seg_base.dtmvtolt;
                vr_reg_arquivo.dsplano            := rw_seg_base.dsplano;

              ELSE
                IF vr_reg_tpatu.tp_seguro <> 'I' THEN
                  -- CONSULTAR VEICULO DA APOLICE
                  OPEN cr_auto_base(p_idcontrato => rw_seg_base.idcontrato);
                  FETCH cr_auto_base INTO rw_auto_base;
                  --Se nao Encontrou
                  IF cr_auto_base%FOUND AND NVL(vr_reg_auto.vlfranquia,0) = 0 THEN
                    vr_reg_auto.vlfranquia := rw_auto_base.vlfranquia;
                  END IF;
                  -- Fechar
                  CLOSE cr_auto_base;

                  vr_reg_tpatu.tp_auto  := 'I';  -- INSERE DADOS

                  -- Deve resetar os valores do registro de memória com os dados do seguro
                  -- e atualizar apenas os valores especificos
                  vr_reg_arquivo.idcontrato         := rw_seg_base.idcontrato;
                  vr_reg_arquivo.cdparceiro         := rw_seg_base.cdparceiro;
                  vr_reg_arquivo.tpseguro           := rw_seg_base.tpseguro;
                  vr_reg_arquivo.nrproposta         := rw_seg_base.nrproposta;
                  vr_reg_arquivo.nrapolice          := rw_seg_base.nrapolice;
                  vr_reg_arquivo.cdcooper           := rw_seg_base.cdcooper;
                  vr_reg_arquivo.nrdconta           := rw_seg_base.nrdconta;
                  vr_reg_arquivo.nrcpf_cnpj_segurado:= rw_seg_base.nrcpf_cnpj_segurado;
                  vr_reg_arquivo.nmsegurado         := rw_seg_base.nmsegurado;
                  --vr_reg_arquivo.nrendosso          := rw_seg_base.nrendosso;
                  --vr_reg_arquivo.tpendosso          := rw_seg_base.tpendosso;
                  --vr_reg_arquivo.tpsub_endosso      := rw_seg_base.tpsub_endosso;
                  vr_reg_arquivo.nrapolice_renovacao:= rw_seg_base.nrapolice_renovacao;
                  vr_reg_arquivo.dtinicio_vigencia  := rw_seg_base.dtinicio_vigencia;
                  vr_reg_arquivo.dttermino_vigencia := rw_seg_base.dttermino_vigencia;
                  vr_reg_arquivo.cdsegura           := rw_seg_base.cdsegura;
                  vr_reg_arquivo.indsituacao        := rw_seg_base.indsituacao;
                  vr_reg_arquivo.dtcancela          := rw_seg_base.dtcancela;
                  vr_reg_arquivo.flgvigente         := 1;

                  -- INFORMAÇÕES QUE SERÃO ATUALIZADAS - Desta forma não receberão o valor da base
                  --vr_reg_arquivo.vlpremio_liquido   := rw_seg_base.vlpremio_liquido;
                  --vr_reg_arquivo.vlpremio_total     := rw_seg_base.vlpremio_total;
                  --vr_reg_arquivo.nrdiadebito        := rw_seg_base.nrdiadebito;
                  --vr_reg_arquivo.qtparcelas         := rw_seg_base.qtparcelas;
                  --vr_reg_arquivo.vlparcela          := rw_seg_base.vlparcela;
                  --vr_reg_arquivo.percomissao        := rw_seg_base.percomissao;
                  vr_reg_arquivo.dsobservacao       := rw_seg_base.dsobservacao;
                  vr_reg_arquivo.vlcapital          := rw_seg_base.vlcapital;
                  vr_reg_arquivo.inerro_import      := rw_seg_base.inerro_import;
                  vr_reg_arquivo.dtmvtolt           := rw_seg_base.dtmvtolt;
                  vr_reg_arquivo.dsplano            := rw_seg_base.dsplano;

                  --vr_reg_auto.idcontrato           := rw_auto_base.idcontrato;
                  --vr_reg_auto.idveiculo            := rw_auto_base.idveiculo;
                  -- INFORMAÇÕES QUE SERÃO ATUALIZADAS - Desta forma não receberão o valor da base
                  --vr_reg_auto.nmmarca              := rw_auto_base.nmmarca;
                  --vr_reg_auto.dsmodelo             := rw_auto_base.dsmodelo;
                  --vr_reg_auto.nrano_fabrica        := rw_auto_base.nrano_fabrica;
                  --vr_reg_auto.nrano_modelo         := rw_auto_base.nrano_modelo;
                  --vr_reg_auto.dsplaca              := rw_auto_base.dsplaca;
                  --vr_reg_auto.dschassi             := rw_auto_base.dschassi;
                  --vr_reg_auto.cdfipe               := rw_auto_base.cdfipe;
                  --vr_reg_auto.vlfranquia           := rw_auto_base.vlfranquia;

                END IF; -- FIM vr_reg_tpatu.tp_seguro <> 'I'

              END IF;

            END IF;
            IF cr_seg_apolice%ISOPEN THEN
              CLOSE cr_seg_apolice;
            END IF;

            IF vr_reg_tpatu.tp_seguro IN ('I','Y') THEN
              vr_reg_arquivo.dsobservacao  := 'Incluido em ' || to_char(rw_crapdat.dtmvtocd,'DD/MM/RRRR') ||
                                             ' as ' || to_char(SYSDATE,'hh24:mi:ss');
            ELSE
              vr_reg_arquivo.dsobservacao  := 'Atualizado em '
                                             || to_char(rw_crapdat.dtmvtocd,'DD/MM/RRRR')
                                             || ' as ' || to_char(SYSDATE,'hh24:mi:ss');
            END IF;

            -- Limpar a variável
            vr_dscritic := NULL;

            ------------------ PROCESSAMENTO PARA GRAVACAO DOS DADOS --------------------

            rw_tab_seguros(1) := vr_reg_arquivo;
            rw_tab_auto(1)    := vr_reg_auto; -- Caso venha existir Auto Frotista futuramente e receber
                                              -- mais de um veiculo por seguro, tratar o "(1)" como um
                                              -- contador/sequencial
            pc_insere_seguro(pr_seguros  => rw_tab_seguros
                            ,pr_auto     => rw_tab_auto
                            ,pr_vida     => rw_tab_vida
                            ,pr_casa     => rw_tab_casa
                            ,pr_prst     => rw_tab_prst
                            ,pr_tipatu   => vr_reg_tpatu
                            ,pr_flgsegur => vr_flgsegok
                            ,pr_indierro => vr_indierro
                            ,pr_des_erro => vr_dscritic
                            ,pr_tab_erro => vr_tab_erro);
                            
            IF NOT vr_flgsegok OR vr_dscritic IS NOT NULL THEN
              IF vr_indierro = 1 THEN          
                -- Ajuste geracao de LOG de Erro em DB - Chamado 667957 - 05/07/2017
                -- Gera LOG de Erro
                pc_controla_log_batch(pr_dstiplog_in => 'E',
                                      pr_dscritic_in => vr_dscritic);                
              ELSE
                -- Carrega linha original do Novo Vetor - Chamado 667957 - 07/07/2017 
              -- Gera LOG de Erro do Arquivo
              gera_log(pr_cdcooper => 3 --pr_cdcooper
                      ,pr_cdprogra => vr_tab_arqtmp(idx)
                      ,pr_indierro => vr_indierro -- 1 -- 1-Log Geral 2-Log Especifico Arquivo
                      ,pr_cdcritic => 0
                        ,pr_dscritic => 'Linha '|| vr_nrlinha || ' => ATENÇÃO: ' || vr_dscritic
                       );
              ROLLBACK;
              CONTINUE; -- Passa para proxima linha
              END IF;            
            END IF;
          ------------------ FIM - PROCESSAMENTO PARA GRAVACAO DOS DADOS --------------------
        END IF; -- IF TRIM(vr_tab_linhas(vr_indice2)('NRENDOSSO_CANCELA').numero) IS NOT NULL
        ----------
        COMMIT; -- Ao termino de cada linha, COMMIT
        ----------

      END LOOP;  -- LOOP de Linhas do Arquivo

      vr_mailtitu := gene0001.fn_param_sistema('CRED', 0, 'AUTO_TITL_FIM_PROC');

      -- FINALIZOU O ARQUIVO, VERIFICAR SE FOI GERADO ARQUIVO DE ERRO
      IF TRIM(vr_nmarqerr) IS NOT NULL THEN -- Arquivo que contem os logs de erros.
        vr_raizcoop := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => NULL);
        vr_dsdanexo := vr_raizcoop || '/log/' || vr_nmarqerr;

        vr_mailbody := REPLACE(REPLACE(gene0001.fn_param_sistema('CRED', 0, 'AUTO_BODY_FIM_PROC_E')
                                       ,'##DATA##'
                                       ,to_char(rw_crapdat.dtmvtocd,'DD/MM/RRRR'))
                               ,'##NMARQ##'
                               ,vr_tab_arqtmp(idx));
        
        vr_mailtitu := vr_mailtitu || ' - ' || 'Arquivo COM inconsistências';
                               
        -- Ajuste geracao de LOG de Erro em DB - Chamado 667957 - 05/07/2017
        -- Gera LOG
        pc_controla_log_batch(pr_dstiplog_in => 'E',
                              pr_dscritic_in => 'Envio de Email de Termino com Erro!'); 
                              
      ELSE -- EMAIL de SUCESSO
        vr_dsdanexo := NULL;
        vr_mailbody := REPLACE(REPLACE(gene0001.fn_param_sistema('CRED', 0, 'AUTO_BODY_FIM_PROC_S')
                                       ,'##DATA##'
                                       ,to_char(rw_crapdat.dtmvtocd,'DD/MM/RRRR'))
                               ,'##NMARQ##'
                               ,vr_tab_arqtmp(idx));
        
        vr_mailtitu := vr_mailtitu || ' - ' || 'Arquivo SEM inconsistências';
                               
        -- Ajuste geracao de LOG de Erro em DB - Chamado 667957 - 05/07/2017
        -- Gera LOG
        pc_controla_log_batch(pr_dstiplog_in => 'E',
                              pr_dscritic_in => 'Envio de Email de Termino com Sucesso!',
                              pr_dsfixa_in   => 'ALERTA: ',
                              pr_tpocorrencia_in => 4); 

      END IF;


      -- ENVIO DE EMAIL DE FIM DE PROCESSO / CONFORME DADOS ACIMA
      vr_maildest := gene0001.fn_param_sistema('CRED', 0, 'AUTO_DEST_FIM_PROC');

      gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                ,pr_cdprogra        => 'SEGU0001'
                                ,pr_des_destino     => vr_maildest
                                ,pr_des_assunto     => vr_mailtitu
                                ,pr_des_corpo       => vr_mailbody
                                ,pr_des_anexo       => vr_dsdanexo
                                ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic);
      -- Se houver erros
      IF vr_dscritic IS NOT NULL THEN
        -- Gera critica
        vr_cdcritic := 0;
        vr_dscritic := 'Erro no envio do Email!' || '. Erro: '||vr_dscritic;
        
        -- Ajuste geracao de LOG de Erro em DB - Chamado 667957 - 05/07/2017
        -- Gera LOG de Erro
        pc_controla_log_batch(pr_dstiplog_in => 'E',
                              pr_dscritic_in => vr_dscritic);
      END IF;

      -- SE TEM LOG DE ERROS, ENVIAR PARA O CONNECT PARA SICREDI
      IF vr_dsdanexo IS NOT NULL THEN

        -- Quando arquivo finalizado com erro, gravar o
        -- arquivo de log na pasta /micros/cecred/segauto/
        vr_nmdirlog := gene0001.fn_diretorio(pr_tpdireto => 'M'
                                           , pr_cdcooper => 3
                                           , pr_nmsubdir => '/segauto/');
        -- Comando para copiar arquivo
        vr_comando:= 'cp '||vr_dsdanexo||' '||vr_nmdirlog ||' 2> /dev/null';

        --Executar o comando no unix
        GENE0001.pc_OScommand (pr_typ_comando => 'S'
                              ,pr_des_comando => vr_comando
                              ,pr_typ_saida   => vr_typ_saida
                              ,pr_des_saida   => vr_dscritic);
                              
        -- Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic:= 'Nao foi possivel executar comando unix.1. '||vr_comando;
          -- Acerto do log - Chamado 667957 - 05/07/2017  
          --> Final da execução com ERRO
          pc_controla_log_batch(pr_dstiplog_in => 'E',
                                pr_dscritic_in => vr_dscritic);
        END IF;

        -- Montar Comando para mover o arquivo LOG para o diretório connect/sicredi/ENVIA
        vr_comando:= 'mv '|| vr_dsdanexo || ' ' || vr_dsdirenv || '/'|| vr_nmarqerr;

        -- Executar o comando no unix
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_comando
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic);
                              
        -- Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
          vr_dscritic:= 'Nao foi possivel executar comando unix.2. '||vr_comando;
          -- Acerto do log - Chamado 667957 - 05/07/2017  
          --> Final da execução com ERRO
          pc_controla_log_batch(pr_dstiplog_in => 'E',
                                pr_dscritic_in => vr_dscritic);
        END IF;
      END IF;

      -- Acerto do log - Chamado 667957 - 05/07/2017     
      pc_controla_log_batch(pr_dstiplog_in => 'E',
                            pr_dscritic_in => 'Termino processamento do arquivo: ' || vr_tab_arqtmp(idx),
                            pr_dsfixa_in   => 'ALERTA: ',
                            pr_tpocorrencia_in => 4);

      --  Mover o arquivo após o processamento
      gene0001.pc_oscommand_shell(pr_des_comando => 'mv ' ||vr_dsdirrec||'/'||vr_tab_arqtmp(idx)||' '||vr_dsdirmov||'/'||vr_tab_arqtmp(idx));


    END LOOP; -- Fim da Lista de Arquivos da Pasta


    
    ----------------- ENCERRAMENTO DO PROGRAMA -------------------
	
    -- se for a ultima execução do dia,
    -- move arquivo de log de execução pra pasta /micros/cecred/segauto
    IF  vr_flultexc THEN

      vr_raizcoop := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                          ,pr_cdcooper => pr_cdcooper
                                          ,pr_nmsubdir => 'log');
      vr_nmdirlog := gene0001.fn_diretorio(pr_tpdireto => 'M'
                                         , pr_cdcooper => 3
                                         , pr_nmsubdir => '/segauto/');
      -- Comando para copiar arquivo
      vr_comando:= 'mv ' || vr_raizcoop || '/log_SEGUROS_* '||vr_nmdirlog ||' 2> /dev/null';

      -- Executar o comando no unix
      GENE0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => vr_comando
                           ,pr_typ_saida   => vr_typ_saida
                           ,pr_des_saida   => vr_dscritic);
                              

        
      -- Se ocorreu erro dar RAISE
      IF vr_typ_saida = 'ERR' THEN
        vr_dscritic:= 'Nao foi possivel executar comando unix.3. '||vr_comando;
        --> Final da execução com ERRO
        pc_controla_log_batch(pr_dstiplog_in => 'E',
                              pr_dscritic_in => vr_dscritic);
      END IF;
    END IF;

    --> Log de final de execução
    pc_controla_log_batch(pr_dstiplog_in => 'F',
                          pr_dsfixa_in => 'ALERTA: ',
                          pr_tpocorrencia_in => 4);

    -- Finalizar a sessão com a efetivação dos dados
    COMMIT;

  EXCEPTION
    WHEN vr_exc_saida THEN -- SAIDA SEM ENVIO DE EMAIL

      -- Efetuar rollback
      ROLLBACK;
      
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;

      -- gera log do erro
      pc_controla_log_batch(pr_dstiplog_in => 'E',
                            pr_dscritic_in => vr_dscritic);
                            
      --> Log de final de execução
      pc_controla_log_batch( pr_dstiplog_in => 'F',
                             pr_tpocorrencia_in => 4);


    WHEN OTHERS THEN

      -- Efetuar rollback
      ROLLBACK;

      -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);         
      -- Efetuar retorno do erro não tratado
      vr_dscritic := SQLERRM;
      --> Final da execução com ERRO
      pc_controla_log_batch(pr_dstiplog_in => 'E',
                            pr_dscritic_in => vr_dscritic);

      pc_controla_log_batch(pr_dstiplog_in => 'F',
                            pr_tpocorrencia_in => 4);

  END pc_importa_seg_auto_sicr;

  --Procedimento para Criar o Seguro
  PROCEDURE pc_insere_seguro (pr_seguros  IN tp_tab_seguros     -- Tabela de Seguros
                             ,pr_auto     IN tp_tab_auto        -- Tabela de Veiculos Segurados
                             ,pr_vida     IN tp_tab_vida        -- Tabela de Beneficiarios Seg.Vida
                             ,pr_casa     IN tp_tab_casa        -- Tabela de Casa do seguro (Não existe, apenas inserido para definir parametros)
                             ,pr_prst     IN tp_tab_prst        -- Tabela de Prestamistas (Não existe, apenas inserido para definir parametros)
                             ,pr_tipatu   IN SEGU0001.typ_reg_flg_atu    -- Contem os 4 indicadores de atualização dos seguros: Auto, Vida, Casa, Prestamista
                             ,pr_flgsegur OUT BOOLEAN           -- Seguro Criado TRUE ou FALSE
                             ,pr_indierro OUT NUMBER            -- Indica se o erro retornado é para o log ou arquivo especifico
                             ,pr_des_erro OUT VARCHAR2          -- Retorno Erro OK/NOK
                             ,pr_tab_erro OUT gene0001.typ_tab_erro) IS  --Tabela Erros
  BEGIN
     ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_insere_seguro                   Antigo: Não há
  --  Sistema  :
  --  Sigla    : CRED
  --  Autor    : Guilherme/SUPERO
  --  Data     : Maio/2016.                   Ultima atualizacao: 03/07/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Procedure para inserir dados de seguros, e seus filhos, Veiculos, Vida, etc.
  --
  -- Alterações:
  --             03/07/2017 - Incluido rotina de setar modulo Oracle 
  --                          ( Belli - Envolti - #667957)
  -- 

  ---------------------------------------------------------------------------------------------------------------
    DECLARE

    TYPE typ_idcontrato IS TABLE OF tbseg_contratos.idcontrato%TYPE INDEX BY PLS_INTEGER;

    vr_idcontrato typ_idcontrato;
    vr_idveiculo  tbseg_auto_veiculos.idveiculo%TYPE;

    vr_exc_erro     EXCEPTION;
    vr_dscritic VARCHAR2(4000);

    -- Buscar o contrato atual da apolice a ser endossado
    CURSOR cr_contrato_endosso (p_nrapolice  IN tbseg_contratos.nrapolice%TYPE) IS
      SELECT seg.rowid
        FROM tbseg_contratos seg
       WHERE seg.nrapolice     = p_nrapolice
         AND seg.flgvigente    = 1
       --AND seg.inerro_import = 0
         AND seg.tpseguro      = 'A'; -- AUTO
    rw_contrato_endosso   cr_contrato_endosso%ROWTYPE;

    CURSOR cr_max_veiculo (p_idcontrato IN tbseg_auto_veiculos.idcontrato%TYPE) IS
     SELECT NVL(MAX(idveiculo),0) + 1
       FROM tbseg_auto_veiculos auto
      WHERE auto.idcontrato = p_idcontrato;

    BEGIN

      -- Inclusão da rotina de setar módulo - Chamado 667957 - 03/07/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'SEGU0001.pc_insere_seguro');

      -- Verificar se veio dados de SEGUROS
      IF pr_seguros.count() > 0 THEN

        -- Leitura do calendário da cooperativa
        OPEN btch0001.cr_crapdat(pr_cdcooper => 3);
         FETCH btch0001.cr_crapdat INTO rw_crapdat;
        CLOSE btch0001.cr_crapdat;

        -- Para cada seguro que vier no parametro...
        FOR vr_indice IN pr_seguros.first..pr_seguros.last LOOP

          -- Verificar qual o tipo de Atualização do Seguro I-Incluir / A-Atualizar / Y-Incluir e alterar apolice/endosso anterior
          IF pr_tipatu.tp_seguro IN ('I','Y') THEN    -- Incluir o Seguro

            -- Se for para alterar o endosso anterior
            IF pr_tipatu.tp_seguro = 'Y' THEN

              OPEN  cr_contrato_endosso(pr_seguros(vr_indice).nrapolice);
              FETCH cr_contrato_endosso INTO rw_contrato_endosso;

              -- Se não encontrar o endosso para atualizar
              IF cr_contrato_endosso%NOTFOUND THEN
                -- Fechar o cursor
                CLOSE cr_contrato_endosso;

                -- Mensagem de erro de retorno
                vr_dscritic := 'Não encontrada Apólice a ser endossada.' ||
                               ' [Apólice: ' || pr_seguros(vr_indice).nrapolice || 
                               ' - ' || pr_tipatu.tp_seguro || ']' ;

                -- Indicar erro do arquivo especifico
                pr_indierro := 2;

                -- Exception
                RAISE vr_exc_erro;
              END IF;

              CLOSE cr_contrato_endosso;

              -- Altera o contrato atual para endossado, pois irá inserir o endosso com as alterações
              BEGIN
                UPDATE tbseg_contratos t
                   SET t.indsituacao = 'E' -- Endossado
                     , t.flgvigente  = 0
                     , t.dtcancela   = pr_seguros(vr_indice).dtinicio_vigencia
                 WHERE ROWID = rw_contrato_endosso.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                  -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
                  CECRED.pc_internal_exception (pr_cdcooper => 3);   
                  vr_dscritic := 'Erro ao atualizar Endosso: ' || SQLERRM;
                  -- Indicar erro do arquivo especifico
                  pr_indierro := 1;
                  -- Exception
                  RAISE vr_exc_erro;
              END;
            END IF;

            BEGIN
              INSERT INTO tbseg_contratos(cdparceiro
                                         ,tpseguro
                                         ,nrproposta
                                         ,nrapolice
                                         ,cdcooper
                                         ,nrdconta
                                         ,nrcpf_cnpj_segurado
                                         ,nmsegurado
                                         ,nrendosso
                                         ,tpendosso
                                         ,tpsub_endosso
                                         ,nrapolice_renovacao
                                         ,dtinicio_vigencia
                                         ,dttermino_vigencia
                                         ,cdsegura
                                         ,indsituacao
                                         ,dtcancela
                                         ,vlpremio_liquido
                                         ,vlpremio_total
                                         ,nrdiadebito
                                         ,qtparcelas
                                         ,vlparcela
                                         ,percomissao
                                         ,dsobservacao
                                         ,vlcapital
                                         ,inerro_import
                                         ,dtmvtolt
                                         ,dsplano
                                         ,flgvigente)
                               VALUES( pr_seguros(vr_indice).cdparceiro
                                      ,pr_seguros(vr_indice).tpseguro
                                      ,pr_seguros(vr_indice).nrproposta
                                      ,pr_seguros(vr_indice).nrapolice
                                      ,pr_seguros(vr_indice).cdcooper
                                      ,pr_seguros(vr_indice).nrdconta
                                      ,pr_seguros(vr_indice).nrcpf_cnpj_segurado
                                      ,pr_seguros(vr_indice).nmsegurado
                                      ,pr_seguros(vr_indice).nrendosso
                                      ,pr_seguros(vr_indice).tpendosso
                                      ,pr_seguros(vr_indice).tpsub_endosso
                                      ,pr_seguros(vr_indice).nrapolice_renovacao
                                      ,pr_seguros(vr_indice).dtinicio_vigencia
                                      ,pr_seguros(vr_indice).dttermino_vigencia
                                      ,pr_seguros(vr_indice).cdsegura
                                      ,pr_seguros(vr_indice).indsituacao
                                      ,pr_seguros(vr_indice).dtcancela
                                      ,pr_seguros(vr_indice).vlpremio_liquido
                                      ,pr_seguros(vr_indice).vlpremio_total
                                      ,pr_seguros(vr_indice).nrdiadebito
                                      ,pr_seguros(vr_indice).qtparcelas
                                      ,pr_seguros(vr_indice).vlparcela
                                      ,pr_seguros(vr_indice).percomissao
                                      ,pr_seguros(vr_indice).dsobservacao
                                      ,pr_seguros(vr_indice).vlcapital
                                      ,pr_seguros(vr_indice).inerro_import
                                      ,pr_seguros(vr_indice).dtmvtolt
                                      ,pr_seguros(vr_indice).dsplano
                                      ,pr_seguros(vr_indice).flgvigente)
                            RETURNING tbseg_contratos.idcontrato
                                 INTO vr_idcontrato(vr_indice);
            EXCEPTION
              WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
                CECRED.pc_internal_exception (pr_cdcooper => 3);   
                -- se ocorreu algum erro durante a criação
                vr_dscritic := 'Erro ao inserir Seguro: '||SQLERRM;
                RAISE vr_exc_erro;
            END;

          ELSIF pr_tipatu.tp_seguro IN ('A','W') THEN -- Atualizar o Seguro existente
            -- Se for para alterar o endosso anterior
            IF pr_tipatu.tp_seguro = 'W' THEN

              OPEN  cr_contrato_endosso(pr_seguros(vr_indice).nrapolice);
              FETCH cr_contrato_endosso INTO rw_contrato_endosso;

              -- Se não encontrar o endosso para atualizar
              IF cr_contrato_endosso%NOTFOUND THEN
                -- Fechar o cursor
                CLOSE cr_contrato_endosso;

                -- Mensagem de erro de retorno
                vr_dscritic := 'Não encontrada Apólice a ser endossada.' ||
                               ' [Apólice: ' || pr_seguros(vr_indice).nrapolice || ' - ' || pr_tipatu.tp_seguro || ']' ;

                -- Indicar erro do arquivo especifico
                pr_indierro := 2;

                -- Exception
                RAISE vr_exc_erro;
              END IF;

              CLOSE cr_contrato_endosso;

              -- Altera o contrato atual para endossado, pois irá inserir o endosso com as alterações
              BEGIN
                UPDATE tbseg_contratos t
                   SET t.indsituacao = 'E' -- Endossado
                     , t.flgvigente  = 0
                     , t.dtcancela   = pr_seguros(vr_indice).dtinicio_vigencia
                 WHERE ROWID = rw_contrato_endosso.rowid;
              EXCEPTION
                WHEN OTHERS THEN
                  -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
                  CECRED.pc_internal_exception (pr_cdcooper => 3);   
                  vr_dscritic := 'Erro ao atualizar Endosso: ' || SQLERRM;
                  -- Indicar erro do arquivo especifico
                  pr_indierro := 1;
                  -- Exception
                  RAISE vr_exc_erro;
              END;

            END IF;

            BEGIN
              vr_idcontrato(vr_indice) := pr_seguros(vr_indice).idcontrato;
              UPDATE tbseg_contratos seg
                 SET seg.cdparceiro          = pr_seguros(vr_indice).cdparceiro
                    ,seg.tpseguro            = pr_seguros(vr_indice).tpseguro
                    ,seg.nrproposta          = pr_seguros(vr_indice).nrproposta
                    ,seg.nrapolice           = pr_seguros(vr_indice).nrapolice
                    ,seg.cdcooper            = pr_seguros(vr_indice).cdcooper
                    ,seg.nrdconta            = pr_seguros(vr_indice).nrdconta
                    ,seg.nrcpf_cnpj_segurado = pr_seguros(vr_indice).nrcpf_cnpj_segurado
                    ,seg.nmsegurado          = pr_seguros(vr_indice).nmsegurado
                    ,seg.nrendosso           = pr_seguros(vr_indice).nrendosso
                    ,seg.tpendosso           = pr_seguros(vr_indice).tpendosso
                    ,seg.tpsub_endosso       = pr_seguros(vr_indice).tpsub_endosso
                    ,seg.nrapolice_renovacao = pr_seguros(vr_indice).nrapolice_renovacao
                    ,seg.dtinicio_vigencia   = pr_seguros(vr_indice).dtinicio_vigencia
                    ,seg.dttermino_vigencia  = pr_seguros(vr_indice).dttermino_vigencia
                    ,seg.cdsegura            = pr_seguros(vr_indice).cdsegura
                    ,seg.indsituacao         = pr_seguros(vr_indice).indsituacao
                    ,seg.dtcancela           = pr_seguros(vr_indice).dtcancela
                    ,seg.vlpremio_liquido    = pr_seguros(vr_indice).vlpremio_liquido
                    ,seg.vlpremio_total      = pr_seguros(vr_indice).vlpremio_total
                    ,seg.nrdiadebito         = pr_seguros(vr_indice).nrdiadebito
                    ,seg.qtparcelas          = pr_seguros(vr_indice).qtparcelas
                    ,seg.vlparcela           = pr_seguros(vr_indice).vlparcela
                    ,seg.percomissao         = pr_seguros(vr_indice).percomissao
                    ,seg.dsobservacao        = pr_seguros(vr_indice).dsobservacao
                    ,seg.vlcapital           = pr_seguros(vr_indice).vlcapital
                    ,seg.dsplano             = pr_seguros(vr_indice).dsplano
                    ,seg.dtmvtolt            = rw_crapdat.dtmvtocd
                    ,seg.inerro_import       = pr_seguros(vr_indice).inerro_import
                    ,seg.flgvigente          = pr_seguros(vr_indice).flgvigente
               WHERE seg.idcontrato = vr_idcontrato(vr_indice);
            EXCEPTION
              WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
                CECRED.pc_internal_exception (pr_cdcooper => 3);   
                -- se ocorreu algum erro durante a criação
                vr_dscritic := 'Erro ao atualizar Seguro: '||SQLERRM;
                RAISE vr_exc_erro;
            END;
          ELSE
            vr_dscritic := 'Erro ao inserir Seguro: '||
                           'Tipo inválido de atualizacao => ' || pr_tipatu.tp_seguro;
            RAISE vr_exc_erro;
          END IF;


          ------ ATUALIZAÇÃO DAS TABELAS FILHAS DO SEGURO ----

          -- Para cada VEICULO recebido
          IF pr_auto.count() > 0 THEN

            FOR vr_idx_auto IN pr_auto.FIRST..pr_auto.LAST LOOP
              IF pr_tipatu.tp_auto = 'I' THEN -- Incluir o Veiculo no Seguro

                OPEN cr_max_veiculo(p_idcontrato => vr_idcontrato(vr_indice));
                FETCH cr_max_veiculo INTO vr_idveiculo;

                BEGIN
                  INSERT INTO tbseg_auto_veiculos(idcontrato
                                                 ,idveiculo
                                                 ,nmmarca
                                                 ,dsmodelo
                                                 ,nrano_fabrica
                                                 ,nrano_modelo
                                                 ,dsplaca
                                                 ,dschassi
                                                 ,cdfipe
                                                 ,vlfranquia)
                       VALUES(vr_idcontrato(vr_indice)
                             ,vr_idveiculo
                             ,pr_auto(vr_idx_auto).nmmarca
                             ,pr_auto(vr_idx_auto).dsmodelo
                             ,pr_auto(vr_idx_auto).nrano_fabrica
                             ,pr_auto(vr_idx_auto).nrano_modelo
                             ,pr_auto(vr_idx_auto).dsplaca
                             ,pr_auto(vr_idx_auto).dschassi
                             ,pr_auto(vr_idx_auto).cdfipe
                             ,pr_auto(vr_idx_auto).vlfranquia);
                EXCEPTION
                  WHEN OTHERS THEN
                    -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
                    CECRED.pc_internal_exception (pr_cdcooper => 3);   
                    -- se ocorreu algum erro durante a criação
                    vr_dscritic := 'Erro ao inserir Veículo do Seguro: '||SQLERRM;
                    RAISE vr_exc_erro;
                END;
              ELSIF pr_tipatu.tp_auto = 'A' THEN -- Atualizar o Veiculo existente
                BEGIN
                  UPDATE tbseg_auto_veiculos auto
                     SET auto.nmmarca       = pr_auto(vr_idx_auto).nmmarca
                        ,auto.dsmodelo      = pr_auto(vr_idx_auto).dsmodelo
                        ,auto.nrano_fabrica = pr_auto(vr_idx_auto).nrano_fabrica
                        ,auto.nrano_modelo  = pr_auto(vr_idx_auto).nrano_modelo
                        ,auto.dsplaca       = pr_auto(vr_idx_auto).dsplaca
                        ,auto.dschassi      = pr_auto(vr_idx_auto).dschassi
                        ,auto.cdfipe        = pr_auto(vr_idx_auto).cdfipe
                        ,auto.vlfranquia    = pr_auto(vr_idx_auto).vlfranquia
                   WHERE auto.idcontrato = vr_idcontrato(vr_indice)
                     AND auto.idveiculo  = pr_auto(vr_idx_auto).idveiculo;
                EXCEPTION
                  WHEN OTHERS THEN
                    -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
                    CECRED.pc_internal_exception (pr_cdcooper => 3);   
                    -- se ocorreu algum erro durante a criação
                    vr_dscritic := 'Erro ao atualizar Veículo do Seguro: '||SQLERRM;
                    RAISE vr_exc_erro;
                END;
              ELSIF pr_tipatu.tp_auto = 'E' THEN -- Excluir o Veiculo existente
                BEGIN
                  DELETE tbseg_auto_veiculos auto
                   WHERE auto.idcontrato = vr_idcontrato(vr_indice)
                     AND auto.idveiculo  = pr_auto(vr_idx_auto).idveiculo;
                EXCEPTION
                  WHEN OTHERS THEN
                    -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
                    CECRED.pc_internal_exception (pr_cdcooper => 3);   
                    -- se ocorreu algum erro durante a criação
                    vr_dscritic := 'Erro ao atualizar Veículo do Seguro: '||SQLERRM;
                    RAISE vr_exc_erro;
                END;
              END IF;

            END LOOP;

          END IF;

          -- Para cada BENEFICIARIOS VIDA recebido
          IF pr_vida.count() > 0 THEN

            FOR vr_idx_vida IN pr_vida.FIRST..pr_vida.LAST LOOP
              IF pr_tipatu.tp_vida = 'I' THEN -- Incluir o Beneficiario no Seguro
                BEGIN

                  /** INSIRA SEU CÓDIGO AQUI **/
                  NULL;

                EXCEPTION
                  WHEN OTHERS THEN
                    -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
                    CECRED.pc_internal_exception (pr_cdcooper => 3);   
                    -- se ocorreu algum erro durante a criação
                    vr_dscritic := 'Erro ao inserir Beneficiário do Seguro: '||SQLERRM;
                    RAISE vr_exc_erro;
                END;
              ELSIF pr_tipatu.tp_vida = 'A' THEN -- Atualizar o Beneficiário existente
                BEGIN

                  NULL;
                  /** INSIRA SEU CÓDIGO AQUI **/

                EXCEPTION
                  WHEN OTHERS THEN
                    -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
                    CECRED.pc_internal_exception (pr_cdcooper => 3);   
                    -- se ocorreu algum erro durante a criação
                    vr_dscritic := 'Erro ao atualizar Beneficiário do Seguro: '||SQLERRM;
                    RAISE vr_exc_erro;
                END;
              END IF;
            END LOOP;

          END IF;

          -- Para cada CASA recebido
          IF pr_casa.count() > 0 THEN

            FOR vr_idx_casa IN pr_casa.FIRST..pr_casa.LAST LOOP
              IF pr_tipatu.tp_casa = 'I' THEN -- Incluir o Bem no Seguro
                BEGIN

                  /** INSIRA SEU CÓDIGO AQUI **/
                  NULL;

                EXCEPTION
                  WHEN OTHERS THEN
                    -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
                    CECRED.pc_internal_exception (pr_cdcooper => 3);   
                    -- se ocorreu algum erro durante a criação
                    vr_dscritic := 'Erro ao inserir Bem ao Seguro: '||SQLERRM;
                    RAISE vr_exc_erro;
                END;
              ELSIF pr_tipatu.tp_casa = 'A' THEN -- Atualizar o Bem existente
                BEGIN

                  NULL;
                  /** INSIRA SEU CÓDIGO AQUI **/

                EXCEPTION
                  WHEN OTHERS THEN
                    -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
                    CECRED.pc_internal_exception (pr_cdcooper => 3);   
                    -- se ocorreu algum erro durante a criação
                    vr_dscritic := 'Erro ao atualizar Bem do Seguro: '||SQLERRM;
                    RAISE vr_exc_erro;
                END;
              END IF;
            END LOOP;
          END IF;

          -- Para cada PRESTAMISTA recebido
          IF pr_prst.count() > 0 THEN

            FOR vr_idx_prst IN pr_prst.FIRST..pr_prst.LAST LOOP
              IF pr_tipatu.tp_prst = 'I' THEN -- Incluir o Prestamista no Seguro
                BEGIN

                  /** INSIRA SEU CÓDIGO AQUI **/
                  NULL;

                EXCEPTION
                  WHEN OTHERS THEN
                    -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
                    CECRED.pc_internal_exception (pr_cdcooper => 3);   
                    -- se ocorreu algum erro durante a criação
                    vr_dscritic := 'Erro ao inserir Prestamista no Seguro: '||SQLERRM;
                    RAISE vr_exc_erro;
                END;
              ELSIF pr_tipatu.tp_vida = 'A' THEN -- Atualizar o Prestamista existente
                BEGIN

                  NULL;
                  /** INSIRA SEU CÓDIGO AQUI **/

                EXCEPTION
                  WHEN OTHERS THEN
                    -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
                    CECRED.pc_internal_exception (pr_cdcooper => 3);   
                    -- se ocorreu algum erro durante a criação
                    vr_dscritic := 'Erro ao atualizar Prestamista do Seguro: '||SQLERRM;
                    RAISE vr_exc_erro;
                END;
              END IF;
            END LOOP;
          END IF;

        END LOOP;  -- FIM do LOOP de SEGUROS
      ELSE
        -- Não foram enviados seguros para inclusão/atualização
        -- Nada a fazer
        pr_flgsegur := TRUE;
      END IF;


      -- Se chegou até aqui, deu sucesso
      pr_flgsegur := TRUE;
      pr_des_erro := '';

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_flgsegur := FALSE;
        pr_des_erro := vr_dscritic;

      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 17/07/2017 - Chamado 667957        
        CECRED.pc_internal_exception (pr_cdcooper => 3);   
        pr_flgsegur := FALSE;
        pr_des_erro := 'Erro na rotina pc_insere_seguro: '||SQLERRM;
    END;


  END pc_insere_seguro;


END SEGU0001;
/
