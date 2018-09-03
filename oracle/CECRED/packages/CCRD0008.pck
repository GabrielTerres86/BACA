CREATE OR REPLACE PACKAGE CECRED.CCRD0008 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CCRD0008
  --  Sistema  : Impress�o de Termos de Ades�o
  --  Sigla    : CCRD
  --  Autor    : Paulo Roberto da Silva (Supero)
  --  Data     : mar�o/2018.                   Ultima atualizacao: 09/03/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas para impress�o de termos de ades�o
  --
  -- Alteracoes:
  --
  --------------------------------------------------------------------------------------------------------------
                                     
  -- Rotina para gera��o do Termo de Ades�o PF
  PROCEDURE pc_impres_termo_adesao_pf(pr_cdcooper IN crapcop.cdcooper%TYPE  --> C�digo da Cooperativa
                                     ,pr_cdagecxa IN crapage.cdagenci%TYPE  --> C�digo da agencia
                                     ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                     ,pr_cdopecxa IN crapope.cdoperad%TYPE  --> C�digo do Operador
                                     ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da Tela
                                     ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                     ,pr_cdprogra IN crapprg.cdprogra%TYPE  --> Codigo do programa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de Movimento
                                     ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                     ,pr_flgerlog IN INTEGER                --> Indicador se deve gerar log(0-nao, 1-sim)
                                     --------> OUT <--------
                                     ,pr_nmarqpdf  OUT VARCHAR2              --> Retornar quantidad de registros                           
                                     ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                     ,pr_dscritic OUT VARCHAR2);            --> Descri��o da cr�tica

  -- Rotina para gera��o do Termo de Ades�o PJ
  PROCEDURE pc_impres_termo_adesao_pj(pr_cdcooper IN crapcop.cdcooper%TYPE  --> C�digo da Cooperativa
                                     ,pr_cdagecxa IN crapage.cdagenci%TYPE  --> C�digo da agencia
                                     ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                     ,pr_cdopecxa IN crapope.cdoperad%TYPE  --> C�digo do Operador
                                     ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da Tela
                                     ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                     ,pr_cdprogra IN crapprg.cdprogra%TYPE  --> Codigo do programa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de Movimento
                                     ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                     ,pr_flgerlog IN INTEGER                --> Indicador se deve gerar log(0-nao, 1-sim)
                                     --------> OUT <--------
                                     ,pr_nmarqpdf  OUT VARCHAR2              --> Retornar quantidad de registros                           
                                     ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                     ,pr_dscritic OUT VARCHAR2);            --> Descri��o da cr�tica
                                     
  --> Rotina para gera��o do Termo de Ades�o  - Ayllos Web
  PROCEDURE pc_impres_termo_adesao_pf_web(pr_nrdconta   IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                         ,pr_nrctrcrd   IN crapcrd.nrctrcrd%TYPE  --> Contrato
                                         ,pr_xmllog     IN VARCHAR2               --> XML com informacoes de LOG
                                         ,pr_cdcritic  OUT PLS_INTEGER            --> Codigo da critica
                                         ,pr_dscritic  OUT VARCHAR2               --> Descricao da critica
                                         ,pr_retxml IN OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                         ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
                                         ,pr_des_erro  OUT VARCHAR2);             --> Erros do processo

  PROCEDURE pc_impres_termo_adesao_pj_web(pr_nrdconta   IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                         ,pr_nrctrcrd   IN crapcrd.nrctrcrd%TYPE  --> Contrato
                                         ,pr_xmllog     IN VARCHAR2               --> XML com informacoes de LOG
                                         ,pr_cdcritic  OUT PLS_INTEGER            --> Codigo da critica
                                         ,pr_dscritic  OUT VARCHAR2               --> Descricao da critica
                                         ,pr_retxml IN OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                         ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
                                         ,pr_des_erro  OUT VARCHAR2);           --> Erros do processo


END CCRD0008;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CCRD0008 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CCRD0008
  --  Sistema  : Impress�o de Termos de Ades�o
  --  Sigla    : CCRD
  --  Autor    : Paulo Roberto da Silva (Supero)
  --  Data     : mar�o/2018.                   Ultima atualizacao: 09/03/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas para impress�o de termos de ades�o
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------

  --> Armazenar dados do contrato
  TYPE typ_rec_dados_ctr 
       IS RECORD (nrctrcrd crapcrd.nrctrcrd%TYPE, --Nr Contrato
                  cdagenci crapage.cdagenci%TYPE, --C�digo PA
                  nmresage crapage.nmresage%TYPE, --Posto Atendimento
                  nrdconta crapass.nrdconta%TYPE, --Conta Corrente
                  nmresadm crapadc.nmresadm%TYPE,--Tipo Cart�o CECRED
                  nmprimtl crapass.nmprimtl%TYPE, --Nome Completo
                  nrcpfcgc VARCHAR2(100),         --CPF/CNPJ
                  razaosocial   VARCHAR2(200),    -- Raz�o Social
                  dtconstituicao  VARCHAR2(10), -- Data da Constitui��o
                  nmimpresso       VARCHAR2(200),   -- Nome Impresso
                  vlfaturamentoanual   crapjur.vlfatano%TYPE, -- Faturamento Anual
                  nmfantasia       VARCHAR2(200),    -- Nome Fantasia
                  nmtitcrd crawcrd.nmtitcrd%TYPE, --Nome Impresso Cart�o
                  dtnasctl crapass.dtnasctl%TYPE, --Data Nascimento
                  nrdocttl crapttl.nrdocttl%TYPE, --Nr Identidade
                  cdorgao_expedidor tbgen_orgao_expedidor.cdorgao_expedidor%TYPE, --�rg�o Expedidor
                  cdufdttl crapttl.cdufdttl%TYPE, --UF Identidade
                  dtemdttl crapttl.dtemdttl%TYPE, --Data Emiss�o Identidade
                  cdsexotl crapass.cdsexotl%TYPE, --Sexo
                  dssexotl VARCHAR2(1),           --Descri��o Sexo
                  dsnatura crapttl.dsnatura%TYPE, --Naturalidade
                  dsnacion crapnac.dsnacion%TYPE, --Nacionalidade
                  rsestcvl gnetcvl.rsestcvl%TYPE, --Estado Civil
                  vrnrtere VARCHAR2(40),          --Nr Telefone Residencial
                  vrnrteco VARCHAR2(40),          --Nr Telefone Comercial
                  vrnrtece VARCHAR2(40),          --Nr Telefone Celular
                  vlrenda  crapttl.vlsalari%TYPE,   -- Renda
                  vllimsug crawcrd.vllimcrd%TYPE,   -- Limite de credito
                  vllimcon crawcrd.vllimcrd%TYPE,   -- Limite de credito
                  vllimest crawcrd.vllimcrd%TYPE,   -- Limite de credito
                  dsdadosSolicitacao VARCHAR2(500), -- Responsavel solicita��o
                  dsdadosAprovacao VARCHAR2(500),  -- Responsavel aprova��o
                  tpforma_pagamento VARCHAR2(100), -- Forma de pagamento
                  nmlocaldata      VARCHAR2(200),   -- Local e Data Assinatura
                  indspc           VARCHAR2(1),     -- Indicador se est� no SPC
                  indserasa        VARCHAR2(1),     -- Indicador se est� no SERASA   
                  nrdia_pagamento VARCHAR2(2),
                  nrcpftit        VARCHAR2(100),
                  cdgraupr crawcrd.cdgraupr%TYPE);    -- Dia de pagamento
                  
  TYPE typ_tab_dados_ctr IS TABLE OF typ_rec_dados_ctr
       INDEX BY PLS_INTEGER;                
                  
  --> Armazenar dados das assinaturas
  TYPE typ_rec_assinaturas_ctr 
       IS RECORD (hraprovacao      tbcrd_aprovacao_cartao.hraprovacao%TYPE, -- Hora da assinatura
                  dtaprovacao      tbcrd_aprovacao_cartao.dtaprovacao%TYPE,    -- Data da assinatura
                  nmaprovador      tbcrd_aprovacao_cartao.nmaprovador%TYPE,  -- Nome da assinatura  
                  idaprovacao      tbcrd_aprovacao_cartao.idaprovacao%TYPE,
                  nrctrcrd         tbcrd_aprovacao_cartao.nrctrcrd%TYPE,
                  indtipo_senha    tbcrd_aprovacao_cartao.indtipo_senha%TYPE,
                  nrcpf            tbcrd_aprovacao_cartao.nrcpf%TYPE,
                  nmtextoassinatura VARCHAR2(4000));   
                                  
  TYPE typ_tab_assinaturas_ctr IS TABLE OF typ_rec_assinaturas_ctr
       INDEX BY PLS_INTEGER;
  
  --> Rotina para buscar dados para impressao do Termo de Ades�o PF
  PROCEDURE pc_obtem_dados_contrato (pr_cdcooper        IN crapcop.cdcooper%TYPE  --> C�digo da Cooperativa 
                                    ,pr_cdagenci        IN crapage.cdagenci%TYPE  --> C�digo da agencia
                                    ,pr_nrdcaixa        IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                    ,pr_cdoperad        IN crapope.cdoperad%TYPE  --> C�digo do Operador
                                    ,pr_idorigem        IN INTEGER                --> Identificador de Origem
                                    ,pr_nrdconta        IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                    ,pr_nrctrlim        IN craplim.nrctrlim%TYPE  --> Contrato
                                    ,pr_nmdatela        IN craptel.nmdatela%TYPE
                                    ,pr_tab_dados_ctr   OUT typ_tab_dados_ctr      --> Dados do contrato 
                                    ,pr_tab_crapavt     OUT cada0001.typ_tab_crapavt_58
                                    ,pr_tab_bens        OUT cada0001.typ_tab_bens    
                                    ,pr_tab_assinaturas_ctr OUT typ_tab_assinaturas_ctr                               
                                    ,pr_cdcritic        OUT PLS_INTEGER            --> C�digo da cr�tica
                                    ,pr_dscritic        OUT VARCHAR2) IS           --> Descri��o da cr�t
                                      
    /* .............................................................................

     Programa: pc_obtem_dados_contrato
     Sistema : Rotinas referentes ao Termo Ades�o Cart�o de Cr�dito
     Sigla   : CRED
     Autor   : Paulo Silva - Supero
     Data    : Mar�o/2018.                    Ultima atualizacao: 28/03/2018

     Dados referentes ao programa:

     Frequencia:
     Objetivo  : Rotina para buscar dados para impressao do Termo de Ades�o
     
     Alteracoes: 
    ..............................................................................*/

    ---------->> CURSORES <<--------
    --> Buscar dados associado PF
    CURSOR cr_crapttl (pr_nrcpfcgc crapttl.nrcpfcgc%TYPE)IS
      SELECT ttl.dsnatura,
             ttl.cdestcvl,
             ttl.vlsalari,
             ttl.dtnasttl,
             ttl.nrdocttl,
             ttl.tpdocttl,
             ttl.idorgexp,
             ttl.dtemdttl,
             ttl.cdufdttl,
             ttl.cdsexotl,
             decode(ttl.cdsexotl,1,'M',2,'F') dssexotl,
             ttl.cdnacion
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper
         AND ttl.nrdconta = pr_nrdconta
         AND ttl.nrcpfcgc = pr_nrcpfcgc;
    rw_crapttl cr_crapttl%ROWTYPE;
		
		-- cursor para encontrar dados do avalista de PJ
		CURSOR cr_crapavt (pr_cdcooper IN crapavt.cdcooper%TYPE,
											 pr_nrdconta IN crapavt.nrdconta%TYPE,
											 pr_nrcpfcgc IN crapavt.nrcpfcgc%TYPE) IS
		SELECT avt.nrdconta
					,NVL(ttl.tpdocttl,avt.tpdocava) tpdocava
					,NVL(ttl.nmextttl,avt.nmdavali) nmdavali
					,NVL(ttl.cdestcvl,avt.cdestcvl) cdestcvl
					,avt.nrcpfcgc
					,NVL(ttl.nrdocttl,avt.nrdocava) nrdocava
					,NVL(ttl.idorgexp,avt.idorgexp) idorgexp
					,NVL(ttl.cdufdttl,avt.cdufddoc) cdufddoc
					,NVL(ttl.dtnasttl,avt.dtnascto) dtnascto
					,DECODE(NVL(ttl.cdsexotl,avt.cdsexcto),1,'2',2,'1','0') sexbancoob
					,NVL(ttl.inpessoa,DECODE(avt.inpessoa,0,1,avt.inpessoa)) inpessoa
			FROM crapttl ttl
				 , crapavt avt
		 WHERE ttl.cdcooper(+) = avt.cdcooper
			 AND ttl.nrdconta(+) = avt.nrdctato
			 AND avt.tpctrato = 6 -- Contrato pessoa juridica
			 AND avt.cdcooper = pr_cdcooper
			 AND avt.nrdconta = pr_nrdconta
			 AND avt.nrcpfcgc = pr_nrcpfcgc ;
		rw_crapavt cr_crapavt%ROWTYPE;
    
    --> Buscar dados cooperado
    CURSOR cr_crapass (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE )IS
      SELECT ass.nrcpfcgc,
             ass.nmprimtl,
             ass.cdagenci,
             ass.inpessoa,
             ass.nrdconta,
             ass.nrdocptl,
             ass.tpdocptl,
             ass.dtemdptl,
             ass.inadimpl,
             ass.idorgexp,
             ass.cdufdptl,
             ass.dtnasctl,
             ass.cdsexotl,
             decode(ass.cdsexotl,1,'M',2,'F') dssexotl,
             ass.cdnacion
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    
    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop
            ,cop.nmextcop
            ,cop.nrdocnpj
            ,cop.dsendcop
            ,cop.nrendcop
            ,cop.nmbairro
            ,cop.nmcidade
            ,cop.cdufdcop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE; 
    
    --> Buscar enderecos do cooperado.
    CURSOR cr_crapenc IS
      SELECT enc.nrdconta,
             enc.dsendere,
             enc.nrcepend,
             enc.nmbairro,
             enc.nmcidade,
             enc.nrendere,
             enc.cdufende
        FROM crapenc enc
       WHERE enc.cdcooper = pr_cdcooper
         AND enc.nrdconta = pr_nrdconta
         AND enc.idseqttl = 1
         AND enc.cdseqinc = 1;
    rw_crapenc cr_crapenc%ROWTYPE;
    
    --> buscar operador
    CURSOR cr_crapope(pr_cdcooper crapage.cdcooper%TYPE,
                      pr_cdoperad crapope.cdoperad%TYPE) IS
      SELECT ope.cdoperad
            ,ope.nmoperad
        FROM crapope ope
       WHERE ope.cdcooper = pr_cdcooper
         AND ope.cdoperad = pr_cdoperad;
    rw_crapope_solicitante cr_crapope%ROWTYPE;
    rw_crapope_aprovador   cr_crapope%ROWTYPE;
    
    --> Buscar Dados agencia
    CURSOR cr_crapage(pr_cdcooper crapage.cdcooper%TYPE,
                      pr_cdagenci crapage.cdagenci%TYPE) IS
      SELECT age.nmcidade
            ,age.nmresage
        FROM crapage age
       WHERE age.cdcooper = pr_cdcooper
         AND age.cdagenci = pr_cdagenci;
    rw_crapage cr_crapage%ROWTYPE;
    
    --> Para pessoa juridica - faturamento unico cliente 
    CURSOR cr_crapjfn IS
      SELECT jfn.cdcooper,
             jfn.perfatcl,
             ((jfn.vlrftbru##1 + jfn.vlrftbru##2 + jfn.vlrftbru##3 +
               jfn.vlrftbru##4 + jfn.vlrftbru##5 + jfn.vlrftbru##6 +
               jfn.vlrftbru##7 + jfn.vlrftbru##8 + jfn.vlrftbru##9 +
               jfn.vlrftbru##10 + jfn.vlrftbru##11 + jfn.vlrftbru##12)/12) vlfatur
        FROM crapjfn jfn
       WHERE jfn.cdcooper = pr_cdcooper
         AND jfn.nrdconta = pr_nrdconta;
    rw_crapjfn cr_crapjfn%ROWTYPE;
         
    --> Buscar informa��es do contrato
    CURSOR cr_crawcrd IS
      SELECT crd.nrctrcrd
            ,crd.dtinsori
            ,crd.cdadmcrd
            ,crd.nmtitcrd
            ,crd.dddebito
            ,DECODE(crd.tpdpagto,
                    1,'D�bito Autom�tico (Total)',
                    2,'D�bito Autom�tico (M�nimo)',
                    3,'Fatura','') ds_forma_pagto
            ,DECODE(crd.tpdpagto,
                    1,'debitoTotal',
                    2,'debitoMinimo',
                    3,'fatura','') forma_pagto        
            ,crd.cdoperad
            ,crd.dtsolici
            ,crd.dtaprova
            ,crd.vllimcrd
            ,crd.dsjustif
            ,crd.cdgraupr
            ,crd.insitcrd
            ,crd.insitdec
            ,crd.nmextttl
            ,crd.dtnasccr
			      ,crd.nrcpftit
            ,crd.dtpropos
            ,crd.nrdoccrd
            ,crd.dsprotoc
        FROM crawcrd crd
       WHERE crd.cdcooper = pr_cdcooper
         and crd.nrdconta = pr_nrdconta
         and crd.nrctrcrd = pr_nrctrlim;
    rw_crawcrd cr_crawcrd%ROWTYPE;
    
    -- Busca historico de limite
    CURSOR cr_lim_contratado(prm_cdcooper    tbcrd_limite_atualiza.cdcooper%TYPE
                            ,prm_nrdconta    tbcrd_limite_atualiza.nrdconta%TYPE
                            ,prm_dsprotoc    tbcrd_limite_atualiza.dsprotocolo%TYPE) IS
      SELECT tbla.vllimite_anterior
      FROM tbcrd_limite_atualiza tbla
      WHERE cdcooper = pr_cdcooper
      AND   nrdconta = pr_nrdconta
      AND   dsprotocolo = prm_dsprotoc
      AND   rownum   = 1
      ORDER BY tbla.idatualizacao ASC;
      
    rw_lim_contratado    cr_lim_contratado%ROWTYPE;
    
    --> Busca Administradora
    CURSOR cr_crapadc (pr_cdadmcrd crapadc.cdadmcrd%TYPE) IS
      SELECT (adc.nmresadm) nmresadm
      FROM CRAPADC adc
           WHERE adc.cdcooper = pr_cdcooper
           AND adc.cdadmcrd = pr_cdadmcrd
           AND adc.insitadc = 0; --Normal  
    rw_crapadc cr_crapadc%ROWTYPE;
    
    --> Busca Nacionalidade
    CURSOR cr_crapnac (pr_cdnacion crapnac.cdnacion%TYPE) IS
      SELECT dsnacion
        FROM crapnac
       WHERE cdnacion = pr_cdnacion;
    rw_crapnac cr_crapnac%ROWTYPE;
    
    --> Busca Estado Civil
    CURSOR cr_gnetcvl (pr_cdestcvl gnetcvl.cdestcvl%TYPE) IS    
      SELECT rsestcvl
        FROM gnetcvl
       WHERE cdestcvl = pr_cdestcvl;
    rw_gnetcvl cr_gnetcvl%ROWTYPE;
    
    -- cursor para adquirir telefones do cooperado
    CURSOR cr_craptfc (pr_cdcooper IN craptfc.cdcooper%TYPE,
                       pr_nrdconta IN craptfc.nrdconta%TYPE,
                       pr_tptelefo IN craptfc.tptelefo%TYPE) IS
    SELECT tfc.nrtelefo
          ,tfc.nrdddtfc
      FROM craptfc tfc
     WHERE tfc.cdcooper = pr_cdcooper
       AND tfc.nrdconta = pr_nrdconta
       AND tfc.tptelefo = pr_tptelefo;
       
    rw_craptfc_resid   cr_craptfc%ROWTYPE;   
    rw_craptfc_celu    cr_craptfc%ROWTYPE; 
    rw_craptfc_comer   cr_craptfc%ROWTYPE;
    
    --> Buscar dados assinatura
    CURSOR cr_tbaprc (pr_cdcooper crapass.cdcooper%TYPE,
                      pr_nrdconta crapass.nrdconta%TYPE,
                      pr_nrctrcrd crawcrd.nrctrcrd%TYPE)IS
      SELECT idaprovacao,
             cdcooper,
             nrdconta,
             nrctrcrd,
             indtipo_senha,
             dtaprovacao,
             hraprovacao,
             nrcpf,
             nmaprovador
        FROM tbcrd_aprovacao_cartao
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctrcrd = pr_nrctrcrd;
    rw_tbaprc cr_tbaprc%ROWTYPE;
    
    --> Busca os dados da pessoa Juridica
    CURSOR cr_crapjur IS
      select jur.nmfansia
            ,jur.dtiniatv
            ,jur.vlfatano
        from crapjur jur
      where cdcooper = pr_cdcooper
      and   nrdconta = pr_nrdconta;
    rw_crapjur    cr_crapjur%ROWTYPE;   
    
    CURSOR cr_aciona_motor(pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE
                          ,pr_dsprotoc IN crawcrd.dsprotoc%TYPE) IS
      SELECT dsconteudo_requisicao
        FROM tbgen_webservice_aciona
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctrprp = pr_nrctrcrd
         AND tpacionamento = 2
         AND cdoperad = 'MOTOR'
         AND tpproduto = 4
         AND dsprotocolo = pr_dsprotoc
       ORDER BY idacionamento ASC;
    vr_dsconteudo CLOB;
    
    CURSOR cr_envio_esteira(pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE) IS
      SELECT dsconteudo_requisicao
        FROM tbgen_webservice_aciona
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctrprp = pr_nrctrcrd
         AND tpacionamento = 1
         AND dsoperacao = 'ENVIO DA PROPOSTA PARA ANALISE DE CREDITO'
         AND tpproduto = 4
       ORDER BY idacionamento ASC;
       
    CURSOR cr_retorno_esteira(pr_nrctrcrd IN crawcrd.nrctrcrd%TYPE) IS
      SELECT dsconteudo_requisicao
        FROM tbgen_webservice_aciona
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctrprp = pr_nrctrcrd
         AND tpacionamento = 2
         AND dsoperacao LIKE '%RETORNO PROPOSTA%'
         AND tpproduto = 4
       ORDER BY idacionamento DESC;
    
    ----------->>> VARIAVEIS <<<--------   
    -- Vari�vel de cr�ticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> C�d. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro    
    
    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;
    vr_idxctr          PLS_INTEGER;
    vr_idxassinaturas  PLS_INTEGER;
    vr_tab_dados_ctr   typ_tab_dados_ctr;    
    
    vr_cdoedrep        tbgen_orgao_expedidor.cdorgao_expedidor%TYPE;
    vr_nmorgexp        tbgen_orgao_expedidor.nmorgao_expedidor%TYPE;
    vr_nrdocttl        crapttl.nrdocttl%TYPE;
    vr_localedata      VARCHAR2(200);
    vr_dt_constituicao VARCHAR2(10); -- Data da constitui��o da empresa (PJ)
    vr_vllimsug        NUMBER := 0;
    vr_vllimest        NUMBER := 0;
    vr_codcateg        VARCHAR2(4000);
    vr_retorno         VARCHAR2(4000);
    
    vr_dsDadosSolicitante    VARCHAR2(500);
    vr_dsDadosAprovador      VARCHAR2(500);
    
    vr_obj      cecred.json := json();
    vr_obj_lst  json_list := json_list();
    vr_obj_crd  cecred.json := json();
    vr_obj_anl  cecred.json := json();
    
    vr_tab_crapavt       cada0001.typ_tab_crapavt_58;
    vr_tab_bens          cada0001.typ_tab_bens;
    vr_tab_erro          gene0001.typ_tab_erro;
    vr_tab_assinaturas_ctr  typ_tab_assinaturas_ctr;
    
    --variaveis de restri��es
    vr_nrconbir          crapcbd.nrconbir%TYPE;
    vr_nrseqdet          crapcbd.nrseqdet%TYPE;
    vr_cdbircon          crapbir.cdbircon%TYPE;
    vr_dsbircon          crapbir.dsbircon%TYPE;
    vr_cdmodbir          crapmbr.cdmodbir%TYPE;
    vr_dsmodbir          crapmbr.dsmodbir%TYPE;
    vr_flsituac          VARCHAR2(10);
    
    vr_existe_cartao    VARCHAR2(1);
                                                 
  BEGIN
  
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop;
    FETCH cr_crapcop INTO rw_crapcop;
    -- Se n�o encontrar
    IF cr_crapcop%NOTFOUND THEN   
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapcop;
    END IF;
    
    --> Buscar cooperado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    IF cr_crapass%NOTFOUND THEN 
      CLOSE cr_crapass;
      vr_cdcritic := 9; -- 009 - Associado nao cadastrado.
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapass;
    END IF;
    
    --> Buscar contrato
    OPEN cr_crawcrd;
    FETCH cr_crawcrd INTO rw_crawcrd;
    IF cr_crawcrd%NOTFOUND THEN
      CLOSE cr_crawcrd;
      vr_dscritic := 'Contrato nao encontrado.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crawcrd;
    END IF;
    
    --> Buscar ultimo historico de limite
    OPEN cr_lim_contratado(pr_cdcooper
                          ,pr_nrdconta
                          ,rw_crawcrd.dsprotoc);
    FETCH cr_lim_contratado INTO rw_lim_contratado;
    CLOSE cr_lim_contratado;
    
    IF rw_crapass.inpessoa = 1 THEN
      --> Buscar dados PF
      OPEN cr_crapttl(pr_nrcpfcgc => trunc(rw_crawcrd.nrcpftit));
      FETCH cr_crapttl INTO rw_crapttl;
      IF cr_crapttl%NOTFOUND THEN 
        CLOSE cr_crapttl;
        vr_cdcritic := 9; -- 009 - Associado nao cadastrado.
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapttl;
      END IF;
      
      -- Buscar estado civil  
      OPEN cr_gnetcvl(pr_cdestcvl => rw_crapttl.cdestcvl);
      FETCH cr_gnetcvl INTO rw_gnetcvl;
      IF cr_gnetcvl%NOTFOUND THEN 
        CLOSE cr_gnetcvl;
        vr_dscritic := 'Estado civil nao cadastrado';
        --RAISE vr_exc_erro;
      ELSE
        CLOSE cr_gnetcvl;

      END IF;
      
      --> Buscar dados de Nacionalidade                           
      OPEN cr_crapnac(rw_crapttl.cdnacion); 
      FETCH cr_crapnac INTO rw_crapnac;    
      IF cr_crapnac%NOTFOUND THEN
        CLOSE cr_crapnac;
        vr_dscritic := 'Nacionalidade nao encontrada.';
        --RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapnac;
      END IF;
      -- Buscar telefone residencial
      OPEN cr_craptfc(pr_cdcooper
                     ,pr_nrdconta
                     ,1);
      FETCH cr_craptfc INTO rw_craptfc_resid;
      IF cr_craptfc%NOTFOUND THEN
        CLOSE cr_craptfc;
        vr_dscritic := 'Telefone residencial n�o encontrado.';
        --RAISE vr_exc_erro;
      ELSE
        CLOSE cr_craptfc;
      END IF;
    END IF;
    
    --> Buscar endere�o do cooperado
    OPEN cr_crapenc;
    FETCH cr_crapenc INTO rw_crapenc;
    IF cr_crapenc%NOTFOUND THEN
      CLOSE cr_crapenc;
      vr_dscritic := 'Endereco nao cadastrado.';
      --RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapenc;
    END IF;
    
    --> buscar dados do operador solicitante                                         
    OPEN cr_crapope(pr_cdcooper
                   ,rw_crawcrd.cdoperad); 
    FETCH cr_crapope INTO rw_crapope_solicitante;
    IF cr_crapope%NOTFOUND THEN
      CLOSE cr_crapope;
      vr_dscritic := 'Operador solicitante nao cadastrado.';
      --RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapope;

    END IF;
    
    --> buscar dados do operador aprovador                                         
    OPEN cr_crapope(pr_cdcooper
                   ,rw_crawcrd.cdoperad); 
    FETCH cr_crapope INTO rw_crapope_aprovador;
    IF cr_crapope%NOTFOUND THEN
      CLOSE cr_crapope;
      vr_dscritic := 'Operador aprovador nao cadastrado.';
      --RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapope;

    END IF;
    
    --> Buscar Dados agencia
    OPEN cr_crapage(pr_cdcooper => pr_cdcooper ,
                    pr_cdagenci => rw_crapass.cdagenci);
    FETCH cr_crapage INTO rw_crapage;
    CLOSE cr_crapage;        
    
    --> Para pessoa juridica - faturamento unico cliente 
    OPEN cr_crapjfn ;   
    FETCH cr_crapjfn INTO rw_crapjfn;
    CLOSE cr_crapjfn;
    
    --> Buscar dados da Administradora                           
    OPEN cr_crapadc(rw_crawcrd.cdadmcrd); 
    FETCH cr_crapadc INTO rw_crapadc;    
    IF cr_crapadc%NOTFOUND THEN
      CLOSE cr_crapadc;
      vr_dscritic := 'Administradora nao encontrada.';
      --RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapadc;
    END IF;
    
    -- Buscar telefone celular
    OPEN cr_craptfc(pr_cdcooper
                   ,pr_nrdconta
                   ,2);
    FETCH cr_craptfc INTO rw_craptfc_celu;
    IF cr_craptfc%NOTFOUND THEN
      CLOSE cr_craptfc;
      vr_dscritic := 'Telefone celular n�o encontrado.';
      --RAISE vr_exc_erro;
    ELSE
      CLOSE cr_craptfc;
    END IF;
    -- Buscar telefone comercial
    OPEN cr_craptfc(pr_cdcooper
                   ,pr_nrdconta
                   ,3);
    FETCH cr_craptfc INTO rw_craptfc_comer;
    CLOSE cr_craptfc;  
    
    -- Buscar assinatura
    BEGIN
      select 'S'
      INTO  vr_existe_cartao
      from  crawcrd 
      where nrcrcard <> '0'
      and   insitcrd <> '0' 
      AND   nrdconta = pr_nrdconta
      AND   nrctrcrd = pr_nrctrlim
      and   cdcooper = pr_cdcooper;
    EXCEPTION
      WHEN no_data_found THEN
        NULL;
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao verificar se o cart�o j� existe';
        RAISE vr_exc_erro;  
    END;
    
    IF vr_existe_cartao IS NOT NULL THEN
      vr_tab_assinaturas_ctr(1).nmtextoassinatura := 'Proposta assinada manualmente, termo pr� impresso.';
    ELSE
      BEGIN
        vr_idxassinaturas := 0;
        FOR rw_tbaprc IN cr_tbaprc(pr_cdcooper
                                  ,pr_nrdconta
                                  ,rw_crawcrd.nrctrcrd) 
        LOOP
          vr_idxassinaturas := vr_tab_assinaturas_ctr.count() + 1;
          
          vr_tab_assinaturas_ctr(vr_idxassinaturas).hraprovacao := rw_tbaprc.hraprovacao;
          vr_tab_assinaturas_ctr(vr_idxassinaturas).dtaprovacao := rw_tbaprc.dtaprovacao;
          vr_tab_assinaturas_ctr(vr_idxassinaturas).nmaprovador := rw_tbaprc.nmaprovador;
          vr_tab_assinaturas_ctr(vr_idxassinaturas).idaprovacao := rw_tbaprc.idaprovacao;
          vr_tab_assinaturas_ctr(vr_idxassinaturas).nrctrcrd := rw_tbaprc.nrctrcrd;
          vr_tab_assinaturas_ctr(vr_idxassinaturas).indtipo_senha := rw_tbaprc.indtipo_senha;
          vr_tab_assinaturas_ctr(vr_idxassinaturas).nrcpf := rw_tbaprc.nrcpf;
          vr_tab_assinaturas_ctr(vr_idxassinaturas).nmtextoassinatura := 'Assinado eletronicamente, mediante aposi��o de senha do '
                                                              ||rw_tbaprc.nmaprovador||', no dia '||to_char(rw_tbaprc.dtaprovacao,'DD/MM/YYYY')
                                                              ||' e na hora '||rw_tbaprc.hraprovacao;
        END LOOP; 
      EXCEPTION
        WHEN no_data_found THEN
           vr_dscritic := 'Assinatura n�o encontrada.';
           vr_tab_assinaturas_ctr(1).nmtextoassinatura := 'Proposta assinada manualmente, termo pr� impresso.';
           --RAISE vr_exc_erro;
      END;
      
      IF vr_idxassinaturas = 0 THEN
         vr_dscritic := 'Assinatura n�o encontrada.';
         vr_tab_assinaturas_ctr(1).nmtextoassinatura := 'Proposta assinada manualmente, termo pr� impresso.';
      END IF;
      
    END IF;
    
    -- Se for pessoa Juridica
    IF rw_crapass.inpessoa > 1 THEN
      OPEN cr_crapjur;
      FETCH cr_crapjur INTO rw_crapjur;
      IF cr_crapjur%NOTFOUND THEN
        CLOSE cr_crapjur;
        vr_dscritic := 'Dados da pessoa Juridica n�o encontrado.';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapjur;
      END IF;
    END IF;  
    
    -- Busca restri��es 
    sspc0001.pc_busca_consulta_biro(pr_cdcooper => pr_cdcooper,
                                    pr_nrdconta => pr_nrdconta,
                                    pr_nrconbir => vr_nrconbir,
                                    pr_nrseqdet => vr_nrseqdet);
    
    --Verifica se esta no SPC/SERASA
    sspc0001.pc_verifica_situacao(pr_nrconbir => vr_nrconbir
                                 ,pr_nrseqdet => vr_nrseqdet
                                 ,pr_cdbircon => vr_cdbircon
                                 ,pr_dsbircon => vr_dsbircon
                                 ,pr_cdmodbir => vr_cdmodbir
                                 ,pr_dsmodbir => vr_dsmodbir
                                 ,pr_flsituac => vr_flsituac); 
    
    -- Monta o Local e Data
    vr_localedata := SUBSTR(rw_crapage.nmcidade,1,15) ||', ' || gene0005.fn_data_extenso(nvl(rw_crawcrd.dtinsori,rw_crawcrd.dtpropos));
    
    IF rw_crapass.inpessoa = 1 THEN
      
      IF rw_crapttl.tpdocttl = 'CI' THEN
        vr_nrdocttl := rw_crapttl.nrdocttl;
      END IF;
      
      --Busca �rg�o Expedidor
      cada0001.pc_busca_orgao_expedidor(pr_idorgao_expedidor => rw_crapttl.idorgexp, 
                                        pr_cdorgao_expedidor => vr_cdoedrep, 
                                        pr_nmorgao_expedidor => vr_nmorgexp, 
                                        pr_cdcritic          => vr_cdcritic, 
                                        pr_dscritic          => vr_dscritic);
                                        
      IF nvl(vr_cdcritic,0) > 0 OR 
         TRIM(vr_dscritic) IS NOT NULL THEN
        vr_cdoedrep := 'NAO CADAST';
      END IF;
		ELSE
			--
			-- Representante do tipo OUTROS
			IF rw_crawcrd.cdgraupr = 9 THEN
				--
				--vr_dtnascto   := rw_crawcrd.dtnasccr;
				--vr_nrdocttl   := ' ';
				vr_nrdocttl   := rw_crawcrd.nrdoccrd;
				--vr_idorgexp   := NULL;
				--vr_cdufdttl   := ' ';
				--vr_nmdavali   := rw_crawcrd.nmtitcrd;                
				--vr_sexbancoob := 0;
				--vr_cdestcvl   := 0;
				--vr_nrcpfcgc   := rw_crawcrd.nrcpftit;
				--vr_inpessoa   := 1;
        --        
			ELSE
				-- Busca registro de representante para pessoa jur�dica
				OPEN cr_crapavt(pr_cdcooper => pr_cdcooper,
												pr_nrdconta => pr_nrdconta,
												pr_nrcpfcgc => rw_crawcrd.nrcpftit);
				FETCH cr_crapavt INTO rw_crapavt;

				-- Se nao encontrar
				IF cr_crapavt%NOTFOUND THEN
					-- Fechar o cursor pois efetuaremos raise
					CLOSE cr_crapavt;
					-- Montar mensagem de critica
					vr_dscritic := 'Representante nao encontrado. Conta/DV: ' || pr_nrdconta ||
												 ' CPF: '                                   || rw_crawcrd.nrcpftit ||
												 ' Coop: '                                  || pr_cdcooper ;
					RAISE vr_exc_erro;
					--
				ELSE
					-- Data nascimento representante
					--vr_dtnascto := rw_crapavt.dtnascto;

					-- Apenas fechar o cursor
					CLOSE cr_crapavt;
					--
				END IF;

				-- Somente alimenta var�aveis com informa��es de Documento for Carteira de Identidade
				IF rw_crapavt.tpdocava = 'CI' THEN
					vr_nrdocttl := rw_crapavt.nrdocava;
					--vr_idorgexp := rw_crapavt.idorgexp;
					--vr_cdufdttl := rw_crapavt.cdufddoc;
					--vr_nmdavali := rw_crapavt.nmdavali;
				ELSE
					vr_nrdocttl := ' ';
					--vr_idorgexp := NULL;
					--vr_cdufdttl := ' ';
					--vr_nmdavali := rw_crapavt.nmdavali;
				END IF;

				-- Assume a data de nascimento
				--vr_dtnascto   := rw_crapavt.dtnascto;
				--vr_sexbancoob := rw_crapavt.sexbancoob;
				--vr_cdestcvl   := rw_crapavt.cdestcvl;
				--vr_nrcpfcgc   := rw_crapavt.nrcpfcgc;
				--vr_inpessoa   := rw_crapavt.inpessoa;
        --
			END IF;
			--
    END IF;  
    
    IF rw_crapjur.dtiniatv IS NOT NULL THEN
      vr_dt_constituicao := to_char(rw_crapjur.dtiniatv,'DD/MM/YYYY');
    END IF;
    
    --Valor Limite Sugerido
    OPEN cr_aciona_motor(pr_nrctrcrd => rw_crawcrd.nrctrcrd
                        ,pr_dsprotoc => rw_crawcrd.dsprotoc);
    FETCH cr_aciona_motor INTO vr_dsconteudo;
    IF cr_aciona_motor%FOUND THEN
        
      BEGIN
        vr_obj := json(vr_dsconteudo);

        vr_obj_anl := json(vr_obj.get('indicadoresGeradosRegra').to_char());
        
        vr_obj_lst := json_list(vr_obj_anl.get('sugestaoCartaoCecred').to_char());
          
        FOR vr_idx IN 1..vr_obj_lst.count() LOOP
          BEGIN
            vr_obj_crd := json( vr_obj_lst.get(vr_idx));
            vr_codcateg := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj_crd.get('codigoCategoria').to_char(),'"'),'"'),'\u','\')));
              
            IF vr_codcateg = rw_crawcrd.cdadmcrd THEN
              vr_vllimsug := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj_crd.get('vlLimite').to_char(),'"'),'"'),'\u','\')));
              vr_dsDadosAprovador := 'Motor de Cr�dito em '|| to_char(rw_crawcrd.dtinsori,'DD/MM/YYYY');
              EXIT;
            END IF;
          END;
        END LOOP;
      EXCEPTION
        WHEN OTHERS THEN
          vr_vllimsug := 0;
      END;
    END IF;
    CLOSE cr_aciona_motor;

    --Valor Limite Esteira
    IF rw_crawcrd.insitdec IN (1,3,8) THEN
      OPEN cr_envio_esteira(pr_nrctrcrd => rw_crawcrd.nrctrcrd);
      FETCH cr_envio_esteira INTO vr_dsconteudo;
      IF cr_envio_esteira%FOUND THEN
        vr_obj := json(vr_dsconteudo);
        
        IF vr_obj.exist('valor') THEN
          vr_vllimest := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj.get('valor').to_char(),'"'),'"'),'\u','\')));
          vr_dsDadosAprovador := 'Esteira de Cr�dito em '|| to_char(rw_crawcrd.dtaprova,'DD/MM/YYYY');
        END IF;
      
        OPEN cr_retorno_esteira(pr_nrctrcrd => rw_crawcrd.nrctrcrd);
        FETCH cr_retorno_esteira INTO vr_dsconteudo;
        IF cr_retorno_esteira%FOUND THEN
          vr_obj := json(vr_dsconteudo);
          
          IF vr_obj.exist('insitapr') THEN
            vr_retorno := gene0007.fn_convert_web_db(UNISTR(replace(RTRIM(LTRIM(vr_obj.get('insitapr').to_char(),'"'),'"'),'\u','\')));
          END IF;
          
          IF vr_retorno <> '1' THEN
            vr_vllimest := NULL;
            vr_dsDadosAprovador := null;
          END IF;
        ELSE
          vr_dsDadosAprovador := 'Em an�lise pela Esteira.';
        END IF;
        CLOSE cr_retorno_esteira;
      END IF;
      CLOSE cr_envio_esteira;
    END IF;
    
    -- Monta os dados do Aprovador
    IF rw_crawcrd.cdadmcrd IN (16,17) THEN --D�bito
      --O mesmo da solicita��o
      vr_dsDadosAprovador := rw_crawcrd.cdoperad ||' - '|| rw_crapope_aprovador.nmoperad ||' em '|| to_char(rw_crawcrd.dtpropos,'DD/MM/YYYY');
    END IF;
    
    -- Monta os dados do Solicitante
    vr_dsDadosSolicitante := rw_crawcrd.cdoperad ||' - '|| rw_crapope_solicitante.nmoperad ||' em '|| to_char(rw_crawcrd.dtpropos,'DD/MM/YYYY');
    
    --> Carregar temptable do contrato
    vr_idxctr := vr_tab_dados_ctr.count() + 1;
    --
    vr_tab_dados_ctr(vr_idxctr).nrctrcrd := rw_crawcrd.nrctrcrd;    --Nr Contrato
    vr_tab_dados_ctr(vr_idxctr).cdagenci := rw_crapass.cdagenci;    --Posto Atendimento
    vr_tab_dados_ctr(vr_idxctr).nmresage := rw_crapage.nmresage;    --Posto Atendimento
    vr_tab_dados_ctr(vr_idxctr).nrdconta := pr_nrdconta;            --Conta Corrente
    vr_tab_dados_ctr(vr_idxctr).nmresadm := rw_crawcrd.cdadmcrd;    --Tipo Cart�o CECRED
    vr_tab_dados_ctr(vr_idxctr).nmtitcrd := rw_crawcrd.nmtitcrd;  --Nome Impresso Cart�o
    vr_tab_dados_ctr(vr_idxctr).nrdocttl := vr_nrdocttl;          --Nr Identidade
    vr_tab_dados_ctr(vr_idxctr).cdorgao_expedidor := vr_cdoedrep; --�rg�o Expedidor
    vr_tab_dados_ctr(vr_idxctr).cdufdttl := rw_crapttl.cdufdttl;  --UF Identidade
    vr_tab_dados_ctr(vr_idxctr).dtemdttl := rw_crapttl.dtemdttl;  --Data Emiss�o Identidade
    vr_tab_dados_ctr(vr_idxctr).cdsexotl := rw_crapttl.cdsexotl;  --Sexo
    vr_tab_dados_ctr(vr_idxctr).dssexotl := rw_crapttl.dssexotl;  --Descri��o Sexo
    vr_tab_dados_ctr(vr_idxctr).dsnatura := rw_crapttl.dsnatura;  --Naturalidade
    vr_tab_dados_ctr(vr_idxctr).dsnacion := rw_crapnac.dsnacion;  --Nacionalidade
    vr_tab_dados_ctr(vr_idxctr).rsestcvl := rw_gnetcvl.rsestcvl;  --Estado Civil
    vr_tab_dados_ctr(vr_idxctr).nmprimtl := rw_crawcrd.nmextttl;  --Nome Completo
    
    IF rw_crapass.inpessoa = 1 THEN
      vr_tab_dados_ctr(vr_idxctr).nrcpfcgc := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crawcrd.nrcpftit,
                                                                        pr_inpessoa => rw_crapass.inpessoa);--CPF/CNPJ
      vr_tab_dados_ctr(vr_idxctr).vlrenda  := rw_crapttl.vlsalari;  --Rendimento, Sal�rio
      vr_tab_dados_ctr(vr_idxctr).dtnasctl := rw_crapttl.dtnasttl;  --Data Nascimento
    ELSE
      vr_tab_dados_ctr(vr_idxctr).razaosocial :=rw_crapass.nmprimtl;  -- Raz�o Social
      vr_tab_dados_ctr(vr_idxctr).nrcpfcgc := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapass.nrcpfcgc,
                                                                      pr_inpessoa => rw_crapass.inpessoa);--CPF/CNPJ
      vr_tab_dados_ctr(vr_idxctr).nmfantasia := rw_crapjur.nmfansia;  -- Nome fantasia
      vr_tab_dados_ctr(vr_idxctr).dtconstituicao := vr_dt_constituicao;    -- Data da Constitui��o
      vr_tab_dados_ctr(vr_idxctr).nmimpresso := rw_crawcrd.nmtitcrd;  -- Nome impresso do PJ
      vr_tab_dados_ctr(vr_idxctr).vlfaturamentoanual := rw_crapjur.vlfatano;      -- Faturamento atual
      vr_tab_dados_ctr(vr_idxctr).vlrenda  := rw_crapjfn.vlfatur;     -- Rendimento, Sal�rio
      vr_tab_dados_ctr(vr_idxctr).dtnasctl := rw_crawcrd.dtnasccr;  --Data Nascimento
    END IF;
    
    vr_tab_dados_ctr(vr_idxctr).vrnrtere := rw_craptfc_resid.nrdddtfc ||' '|| rw_craptfc_resid.nrtelefo;          --Nr Telefone Residencial
    vr_tab_dados_ctr(vr_idxctr).vrnrteco := rw_craptfc_comer.nrdddtfc ||' '|| rw_craptfc_comer.nrtelefo;          --Nr Telefone Comercial
    vr_tab_dados_ctr(vr_idxctr).vrnrtece := rw_craptfc_celu.nrdddtfc ||' '||  rw_craptfc_celu.nrtelefo;  
             --Nr Telefone Celular
    vr_tab_dados_ctr(vr_idxctr).vllimsug := vr_vllimsug;                        -- Limite de credito sugerido
    
    IF rw_lim_contratado.vllimite_anterior IS NULL THEN
       vr_tab_dados_ctr(vr_idxctr).vllimcon := rw_crawcrd.vllimcrd;                -- Limite de credito contratado
    ELSE
      vr_tab_dados_ctr(vr_idxctr).vllimcon := rw_lim_contratado.vllimite_anterior;                -- Limite de credito contratado
    END IF;
    
    vr_tab_dados_ctr(vr_idxctr).vllimest := vr_vllimest;                        -- Limite de credito esteira
    vr_tab_dados_ctr(vr_idxctr).nrcpftit := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crawcrd.nrcpftit,
                                                                      pr_inpessoa => 1);--CPF da proposta
    vr_tab_dados_ctr(vr_idxctr).dsdadosSolicitacao := vr_dsDadosSolicitante;    -- Operador Solicitante
    vr_tab_dados_ctr(vr_idxctr).dsdadosAprovacao := vr_dsDadosAprovador;        -- Operador Aprovador
    vr_tab_dados_ctr(vr_idxctr).tpforma_pagamento := rw_crawcrd.forma_pagto;    -- Forma de pagamento
    vr_tab_dados_ctr(vr_idxctr).nrdia_pagamento := rw_crawcrd.dddebito;         -- Dia de pagamento
    vr_tab_dados_ctr(vr_idxctr).nmlocaldata := vr_localedata;                   -- Local e Data da Assinatura    
    vr_tab_dados_ctr(vr_idxctr).cdgraupr := rw_crawcrd.cdgraupr;                --Representante Outros
    
    IF rw_crapass.inadimpl = 1 OR (nvl(vr_flsituac,'N') = 'S' AND UPPER(vr_dsbircon) = 'SPC') THEN
      vr_tab_dados_ctr(vr_idxctr).indspc := 'S';
    ELSE
      vr_tab_dados_ctr(vr_idxctr).indspc := 'N';
    END IF;
    
    IF nvl(vr_flsituac,'N') = 'S' THEN
      IF UPPER(vr_dsbircon) = 'SERASA' THEN
        vr_tab_dados_ctr(vr_idxctr).indserasa := 'S';
      ELSE
        vr_tab_dados_ctr(vr_idxctr).indserasa := 'N';
      END IF;
    ELSE
      vr_tab_dados_ctr(vr_idxctr).indserasa := 'N';
    END IF;  
       
    -- Se for pessoa Juridica
    IF rw_crapass.inpessoa > 1 THEN
    
      --Busca representantes/procuradores
      cada0001.pc_busca_dados_58(pr_cdcooper => pr_cdcooper
                                ,pr_cdagenci => pr_cdagenci
                                ,pr_nrdcaixa => pr_nrdcaixa
                                ,pr_cdoperad => pr_cdoperad
                                ,pr_nmdatela => pr_nmdatela
                                ,pr_idorigem => pr_idorigem
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_idseqttl => 0
                                ,pr_flgerlog => FALSE
                                ,pr_cddopcao => 'C'
                                ,pr_nrdctato => 0
                                ,pr_nrcpfcto => 0
                                ,pr_nrdrowid => NULL
                                ,pr_tab_crapavt => vr_tab_crapavt
                                ,pr_tab_bens => vr_tab_bens
                                ,pr_tab_erro => vr_tab_erro
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);
                               
    END IF;
    
    --> Retornar dados encontrados
    pr_tab_dados_ctr  := vr_tab_dados_ctr; -- Dados do cooperado
    pr_tab_crapavt    := vr_tab_crapavt;
    pr_tab_bens       := vr_tab_bens;
    pr_tab_assinaturas_ctr := vr_tab_assinaturas_ctr;
    
  EXCEPTION    
    WHEN vr_exc_erro THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
      END IF;
      
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := replace(replace('Erro ao buscar dados para impressao: ' || SQLERRM, chr(13)),chr(10));   
  END pc_obtem_dados_contrato;
  
  -- Rotina para gera��o do Termo de Ades�o PF
  PROCEDURE pc_impres_termo_adesao_pf(pr_cdcooper IN crapcop.cdcooper%TYPE  --> C�digo da Cooperativa
                                     ,pr_cdagecxa IN crapage.cdagenci%TYPE  --> C�digo da agencia
                                     ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                     ,pr_cdopecxa IN crapope.cdoperad%TYPE  --> C�digo do Operador
                                     ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da Tela
                                     ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                     ,pr_cdprogra IN crapprg.cdprogra%TYPE  --> Codigo do programa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de Movimento
                                     ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                     ,pr_flgerlog IN INTEGER                --> Indicador se deve gerar log(0-nao, 1-sim)
                                     --------> OUT <--------
                                     ,pr_nmarqpdf  OUT VARCHAR2              --> Retornar quantidad de registros                           
                                     ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                     ,pr_dscritic OUT VARCHAR2) IS          --> Descri��o da cr�tica
    /* .............................................................................

     Programa: pc_impres_termo_adesao_pf
     Sistema : Rotinas referentes ao cart�o de cr�dito
     Sigla   : CRED
     Autor   : Paulo Silva - Supero
     Data    : Mar�o/2018.                    Ultima atualizacao: 28/03/2018

     Dados referentes ao programa:

     Frequencia:
     Objetivo  : Rotina para gera��o do Termo de Ades�o PF
     Alteracoes: 
     
    ..............................................................................*/
    
    ----------->>> VARIAVEIS <<<--------   
    -- Vari�vel de cr�ticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> C�d. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro    
    vr_des_reto        VARCHAR2(100);
    vr_tab_erro        GENE0001.typ_tab_erro;
    
    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;
    
    vr_dsorigem        craplgm.dsorigem%TYPE;
    vr_dstransa        craplgm.dstransa%TYPE;
    vr_nrdrowid        ROWID;

    vr_idseqttl        crapttl.idseqttl%TYPE;
    
    vr_dsdireto        VARCHAR2(4000);
    vr_nmendter        VARCHAR2(4000);     
    vr_dscomand        VARCHAR2(4000);
    vr_typsaida        VARCHAR2(100);    
    
    vr_tab_dados_ctr   typ_tab_dados_ctr;
    vr_tab_crapavt     cada0001.typ_tab_crapavt_58;
    vr_tab_bens        cada0001.typ_tab_bens;
    vr_tab_assinaturas_ctr  typ_tab_assinaturas_ctr;
    
    vr_idxctr          PLS_INTEGER;
    vr_idxass          PLS_INTEGER;
    
    --vr_dsextmail       VARCHAR2(3);
    vr_dsmailcop       VARCHAR2(4000);
    vr_dsassmail       VARCHAR2(200);
    vr_dscormail       VARCHAR2(50);
    
    -- Vari�veis para armazenar as informa��es em XML
    vr_des_xml   CLOB;
    vr_txtcompl  VARCHAR2(32600);
    
    l_offset     NUMBER:=0;
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na vari�vel CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_txtcompl, pr_des_dados, pr_fecha_xml);
    END;
    
  BEGIN    
    --> Definir transa��o
    IF pr_flgerlog = 1 THEN
      vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
    END IF; 
    
    --Buscar diretorio da cooperativa
    vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C', --> cooper 
                                         pr_cdcooper => pr_cdcooper);
                                         
    vr_nmendter := vr_dsdireto ||'/rl/tapf001';
    
    vr_dscomand := 'rm '||vr_nmendter||'* 2>/dev/null';
    
    --Executar o comando no unix
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_dscomand
                         ,pr_typ_saida   => vr_typsaida
                         ,pr_des_saida   => vr_dscritic);
    --Se ocorreu erro dar RAISE
    IF vr_typsaida = 'ERR' THEN
      vr_dscritic:= 'Nao foi possivel remover arquivos: '||vr_dscomand||'. Erro: '||vr_dscritic;
      RAISE vr_exc_erro;
    END IF; 
    
    --> Montar nome do arquivo
    pr_nmarqpdf := 'tapf001'|| gene0002.fn_busca_time || '.pdf';
      
    --> Buscar dados para impressao do Termo de Ades�o PF
    pc_obtem_dados_contrato (  pr_cdcooper        => pr_cdcooper  --> C�digo da Cooperativa 
                              ,pr_cdagenci        => pr_cdagecxa  --> C�digo da agencia
                              ,pr_nrdcaixa        => pr_nrdcaixa  --> Numero do caixa do operador
                              ,pr_cdoperad        => pr_cdopecxa  --> C�digo do Operador
                              ,pr_idorigem        => pr_idorigem  --> Identificador de Origem
                              ,pr_nrdconta        => pr_nrdconta  --> N�mero da Conta
                              ,pr_nrctrlim        => pr_nrctrlim  --> Contrato
                              ,pr_nmdatela        => pr_nmdatela  --> Nome da Tela
                              ,pr_tab_dados_ctr   => vr_tab_dados_ctr    --> Dados do contrato 
                              ,pr_tab_crapavt     => vr_tab_crapavt     
                              ,pr_tab_bens        => vr_tab_bens  
                              ,pr_tab_assinaturas_ctr => vr_tab_assinaturas_ctr                                  
                              ,pr_cdcritic        => vr_cdcritic         --> C�digo da cr�tica
                              ,pr_dscritic        => vr_dscritic);         --> Descri��o da cr�t
                                      
    IF nvl(vr_cdcritic,0) > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;   
    
    
    vr_idxctr := vr_tab_dados_ctr.first;
    --> Verificar se retornou informacao
    IF vr_idxctr IS NULL THEN
      vr_dscritic := 'Nao foi possivel gerar a impressao.';
      RAISE vr_exc_erro;
    END IF;
    
    vr_idxass := vr_tab_assinaturas_ctr.first;
    --> Verificar se retornou informacao
    IF vr_idxass IS NULL THEN
      vr_dscritic := 'Termo n�o foi assinado.';
      RAISE vr_exc_erro;
    END IF;
    
    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    
    vr_txtcompl := NULL;
   
    --> INICIO
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz>
                    <nmprimtl>'|| vr_tab_dados_ctr(vr_idxctr).nmprimtl ||'</nmprimtl>'); 
    
    pc_escreve_xml('<nrctrd>'||vr_tab_dados_ctr(vr_idxctr).nrctrcrd||'</nrctrd>'||
                   '<nomeCompleto>'|| vr_tab_dados_ctr(vr_idxctr).nmprimtl     ||'</nomeCompleto>'||     
                   '<cpf>'|| vr_tab_dados_ctr(vr_idxctr).nrcpfcgc                 ||'</cpf>'||
                   '<nomeImpresso>'|| vr_tab_dados_ctr(vr_idxctr).nmtitcrd ||'</nomeImpresso>'||
                   '<dataNascimento>'|| to_char(vr_tab_dados_ctr(vr_idxctr).dtnasctl,'DD/MM/RRRR') ||'</dataNascimento>'||
                   '<identidade>'|| vr_tab_dados_ctr(vr_idxctr).nrdocttl ||'</identidade>'|| 
                   '<postoAtendimento>'|| vr_tab_dados_ctr(vr_idxctr).cdagenci ||' - '|| vr_tab_dados_ctr(vr_idxctr).nmresage ||'</postoAtendimento>'||
                   '<contaCorrente>'||  gene0002.fn_mask_conta(vr_tab_dados_ctr(vr_idxctr).nrdconta) ||'</contaCorrente>'||
                   '<tpcartao>'|| vr_tab_dados_ctr(vr_idxctr).nmresadm ||'</tpcartao>'||
                   '<emissor>'|| vr_tab_dados_ctr(vr_idxctr).cdorgao_expedidor ||'</emissor>'||
                   '<uf>'|| vr_tab_dados_ctr(vr_idxctr).cdufdttl ||'</uf>'||
                   '<sexo>'|| vr_tab_dados_ctr(vr_idxctr).dssexotl ||'</sexo>'||
                   '<naturalidade>'|| vr_tab_dados_ctr(vr_idxctr).dsnatura ||'</naturalidade>'||
                   '<nacionalidade>'|| vr_tab_dados_ctr(vr_idxctr).dsnacion ||'</nacionalidade>'||
                   '<estadocivil>'|| vr_tab_dados_ctr(vr_idxctr).rsestcvl ||'</estadocivil>'||
                   '<foneRes>'|| vr_tab_dados_ctr(vr_idxctr).vrnrtere ||'</foneRes>'||
                   '<foneCom>'|| vr_tab_dados_ctr(vr_idxctr).vrnrteco ||'</foneCom>'||
                   '<celular>'|| vr_tab_dados_ctr(vr_idxctr).vrnrtece ||'</celular>'||
                   '<renda>'|| 'R$ '|| to_char(vr_tab_dados_ctr(vr_idxctr).vlrenda,'FM99G999G990D00') ||'</renda>'||
                   '<limiteSugerido>'|| 'R$ '|| to_char(vr_tab_dados_ctr(vr_idxctr).vllimsug,'FM99G999G990D00') ||'</limiteSugerido>'||
                   '<limiteContratado>'|| 'R$ '|| to_char(vr_tab_dados_ctr(vr_idxctr).vllimcon,'FM99G999G990D00') ||'</limiteContratado>'||
                   '<limiteEsteira>'|| 'R$ '|| to_char(vr_tab_dados_ctr(vr_idxctr).vllimest,'FM99G999G990D00') ||'</limiteEsteira>'||
                   '<dadosSolicitacao>'|| vr_tab_dados_ctr(vr_idxctr).dsdadosSolicitacao ||'</dadosSolicitacao>'||
                   '<dadosAprovacao>'|| vr_tab_dados_ctr(vr_idxctr).dsdadosAprovacao ||'</dadosAprovacao>'||
                   '<localEData>'|| vr_tab_dados_ctr(vr_idxctr).nmlocaldata ||'</localEData>'||
                   '<formaPagamento>'|| vr_tab_dados_ctr(vr_idxctr).tpforma_pagamento ||'</formaPagamento>'||
                   '<assinatura>'||vr_tab_assinaturas_ctr(1).nmtextoassinatura||'</assinatura>'||
                   '<spc>'|| vr_tab_dados_ctr(vr_idxctr).indspc ||'</spc>'||
                   '<serasa>'|| vr_tab_dados_ctr(vr_idxctr).indserasa ||'</serasa>'||
                   '<diaPagamento>'|| vr_tab_dados_ctr(vr_idxctr).nrdia_pagamento ||'</diaPagamento>');    
    
    --> Descarregar buffer    
    pc_escreve_xml(' ',TRUE); 
    
    --> Descarregar buffer    
    pc_escreve_xml('</raiz>',TRUE); 
    
   loop exit when l_offset > dbms_lob.getlength(vr_des_xml);
   DBMS_OUTPUT.PUT_LINE (dbms_lob.substr( vr_des_xml, 254, l_offset) || '~');
   l_offset := l_offset + 255;
   end loop;
    
    --> Solicita geracao do PDF
    gene0002.pc_solicita_relato(pr_cdcooper   => pr_cdcooper
                               , pr_cdprogra  => pr_cdprogra
                               , pr_dtmvtolt  => pr_dtmvtolt
                               , pr_dsxml     => vr_des_xml
                               , pr_dsxmlnode => '/raiz'
                               , pr_dsjasper  => 'termo_adesao_pf.jasper'
                               , pr_dsparams  => null
                               , pr_dsarqsaid => vr_dsdireto ||'/rl/'||pr_nmarqpdf
                               , pr_flg_gerar => 'S'
                               , pr_qtcoluna  => 234
                               , pr_cdrelato  => 280
                               , pr_sqcabrel  => 1
                               , pr_flg_impri => 'N'
                               , pr_nmformul  => ' '
                               , pr_nrcopias  => 1
                               , pr_nrvergrl  => 1
                               , pr_dsextmail => NULL
                               , pr_dsmailcop => vr_dsmailcop
                               , pr_dsassmail => vr_dsassmail
                               , pr_dscormail => vr_dscormail
                               , pr_des_erro  => vr_dscritic);
    
    IF vr_dscritic IS NOT NULL THEN -- verifica retorno se houve erro
      RAISE vr_exc_erro; -- encerra programa
    END IF;        
    
    IF pr_idorigem = 5 THEN
      -- Copia contrato PDF do diretorio da cooperativa para servidor WEB
      GENE0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper
                                  ,pr_cdagenci => NULL
                                  ,pr_nrdcaixa => NULL
                                  ,pr_nmarqpdf => vr_dsdireto ||'/rl/'||pr_nmarqpdf
                                  ,pr_des_reto => vr_des_reto
                                  ,pr_tab_erro => vr_tab_erro);
      -- Se retornou erro
      IF NVL(vr_des_reto,'OK') <> 'OK' THEN
        IF vr_tab_erro.COUNT > 0 THEN -- verifica pl-table se existe erros
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic; -- busca primeira critica
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; -- busca primeira descricao da critica
          RAISE vr_exc_erro; -- encerra programa
        END IF;
      END IF;

      -- Remover relatorio do diretorio padrao da cooperativa
      gene0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => 'rm '||vr_dsdireto ||'/rl/'||pr_nmarqpdf
                           ,pr_typ_saida   => vr_typsaida
                           ,pr_des_saida   => vr_dscritic);
      -- Se retornou erro
      IF vr_typsaida = 'ERR' OR vr_dscritic IS NOT NULL THEN
        -- Concatena o erro que veio
        vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
        RAISE vr_exc_erro; -- encerra programa
      END IF;
    END IF;        
    
    --> Gerar log de sucesso
    IF pr_flgerlog = 1 THEN
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                           pr_cdoperad => pr_cdopecxa, 
                           pr_dscritic => NULL, 
                           pr_dsorigem => vr_dsorigem, 
                           pr_dstransa => vr_dstransa, 
                           pr_dttransa => trunc(SYSDATE),
                           pr_flgtrans =>  1, -- True
                           pr_hrtransa => gene0002.fn_busca_time, 
                           pr_idseqttl => vr_idseqttl, 
                           pr_nmdatela => pr_nmdatela, 
                           pr_nrdconta => pr_nrdconta, 
                           pr_nrdrowid => vr_nrdrowid);
                             
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                pr_nmdcampo => 'nrctrlim', 
                                pr_dsdadant => NULL, 
                                pr_dsdadatu => pr_nrctrlim);
    END IF;
    
    COMMIT;
    
  EXCEPTION    
    WHEN vr_exc_erro THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
      END IF;
      
      IF pr_flgerlog = 1 THEN
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                             pr_cdoperad => pr_cdopecxa, 
                             pr_dscritic => pr_dscritic, 
                             pr_dsorigem => vr_dsorigem, 
                             pr_dstransa => vr_dstransa, 
                             pr_dttransa => trunc(SYSDATE),
                             pr_flgtrans =>  0, --FALSE
                             pr_hrtransa => gene0002.fn_busca_time, 
                             pr_idseqttl => vr_idseqttl, 
                             pr_nmdatela => pr_nmdatela, 
                             pr_nrdconta => pr_nrdconta, 
                             pr_nrdrowid => vr_nrdrowid);
                             
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                  pr_nmdcampo => 'nrctrlim', 
                                  pr_dsdadant => NULL, 
                                  pr_dsdadatu => pr_nrctrlim);
      END IF;
      
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := replace(replace('Erro ao gerar impressao do contrato: ' || SQLERRM, chr(13)),chr(10));   
  
      IF pr_flgerlog = 1 THEN
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                             pr_cdoperad => pr_cdopecxa, 
                             pr_dscritic => pr_dscritic, 
                             pr_dsorigem => vr_dsorigem, 
                             pr_dstransa => vr_dstransa, 
                             pr_dttransa => trunc(SYSDATE),
                             pr_flgtrans =>  0, --FALSE
                             pr_hrtransa => gene0002.fn_busca_time, 
                             pr_idseqttl => vr_idseqttl, 
                             pr_nmdatela => pr_nmdatela, 
                             pr_nrdconta => pr_nrdconta, 
                             pr_nrdrowid => vr_nrdrowid);
                             
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                  pr_nmdcampo => 'nrctrlim', 
                                  pr_dsdadant => NULL, 
                                  pr_dsdadatu => pr_nrctrlim);
      END IF; 
      
  END pc_impres_termo_adesao_pf;
  
  -- Rotina para gera��o do Termo de Ades�o PJ
  PROCEDURE pc_impres_termo_adesao_pj(pr_cdcooper IN crapcop.cdcooper%TYPE  --> C�digo da Cooperativa
                                     ,pr_cdagecxa IN crapage.cdagenci%TYPE  --> C�digo da agencia
                                     ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                     ,pr_cdopecxa IN crapope.cdoperad%TYPE  --> C�digo do Operador
                                     ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da Tela
                                     ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                     ,pr_cdprogra IN crapprg.cdprogra%TYPE  --> Codigo do programa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de Movimento
                                     ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                     ,pr_flgerlog IN INTEGER                --> Indicador se deve gerar log(0-nao, 1-sim)
                                     --------> OUT <--------
                                     ,pr_nmarqpdf  OUT VARCHAR2              --> Retornar quantidad de registros                           
                                     ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                     ,pr_dscritic OUT VARCHAR2) IS          --> Descri��o da cr�tica
    /* .............................................................................

     Programa: pc_impres_termo_adesao_pj
     Sistema : Rotinas referentes ao cart�o de cr�dito
     Sigla   : CRED
     Autor   : Carlos Lima - Supero
     Data    : Abril/2018.                    Ultima atualizacao: 11/04/2018

     Dados referentes ao programa:

     Frequencia:
     Objetivo  : Rotina para gera��o do Termo de Ades�o PJ
     Alteracoes: 
     
    ..............................................................................*/
    
    ----------->>> VARIAVEIS <<<--------   
    -- Vari�vel de cr�ticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> C�d. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro    
    vr_des_reto        VARCHAR2(100);
    vr_tab_erro        GENE0001.typ_tab_erro;
    
    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;
    
    vr_dsorigem        craplgm.dsorigem%TYPE;
    vr_dstransa        craplgm.dstransa%TYPE;
    vr_nrdrowid        ROWID;

    vr_idseqttl        crapttl.idseqttl%TYPE;
    
    vr_dsdireto        VARCHAR2(4000);
    vr_nmendter        VARCHAR2(4000);     
    vr_dscomand        VARCHAR2(4000);
    vr_typsaida        VARCHAR2(100);    
    
    vr_tab_dados_ctr   typ_tab_dados_ctr;
    vr_tab_crapavt     cada0001.typ_tab_crapavt_58;
    vr_tab_bens        cada0001.typ_tab_bens;
    vr_tab_assinaturas_ctr  typ_tab_assinaturas_ctr;
    
    vr_idxctr          PLS_INTEGER;
    vr_idxass          PLS_INTEGER;
    
    --vr_dsextmail       VARCHAR2(3);
    vr_dsmailcop       VARCHAR2(4000);
    vr_dsassmail       VARCHAR2(200);
    vr_dscormail       VARCHAR2(50);
    
    -- Vari�veis para armazenar as informa��es em XML
    vr_des_xml   CLOB;
    vr_txtcompl  VARCHAR2(32600);
    
    l_offset     NUMBER:=0;
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na vari�vel CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_txtcompl, pr_des_dados, pr_fecha_xml);
    END;
    
  BEGIN    
    --> Definir transa��o
    IF pr_flgerlog = 1 THEN
      vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
    END IF; 
    
    --Buscar diretorio da cooperativa
    vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C', --> cooper 
                                         pr_cdcooper => pr_cdcooper);
                                         
    vr_nmendter := vr_dsdireto ||'/rl/tapj001';
    
    vr_dscomand := 'rm '||vr_nmendter||'* 2>/dev/null';
    
    --Executar o comando no unix
    GENE0001.pc_OScommand(pr_typ_comando => 'S'
                         ,pr_des_comando => vr_dscomand
                         ,pr_typ_saida   => vr_typsaida
                         ,pr_des_saida   => vr_dscritic);
    --Se ocorreu erro dar RAISE
    IF vr_typsaida = 'ERR' THEN
      vr_dscritic:= 'Nao foi possivel remover arquivos: '||vr_dscomand||'. Erro: '||vr_dscritic;
      RAISE vr_exc_erro;
    END IF; 
    
    --> Montar nome do arquivo
    pr_nmarqpdf := 'tapj001'|| gene0002.fn_busca_time || '.pdf';
      
    --> Buscar dados para impressao do Termo de Ades�o PF
    pc_obtem_dados_contrato (  pr_cdcooper        => pr_cdcooper  --> C�digo da Cooperativa 
                              ,pr_cdagenci        => pr_cdagecxa  --> C�digo da agencia
                              ,pr_nrdcaixa        => pr_nrdcaixa  --> Numero do caixa do operador
                              ,pr_cdoperad        => pr_cdopecxa  --> C�digo do Operador
                              ,pr_idorigem        => pr_idorigem  --> Identificador de Origem
                              ,pr_nrdconta        => pr_nrdconta  --> N�mero da Conta
                              ,pr_nrctrlim        => pr_nrctrlim  --> Contrato
                              ,pr_nmdatela        => pr_nmdatela  --> Nome da tela
                              ,pr_tab_dados_ctr   => vr_tab_dados_ctr    --> Dados do contrato 
                              ,pr_tab_crapavt     => vr_tab_crapavt     
                              ,pr_tab_bens        => vr_tab_bens  
                              ,pr_tab_assinaturas_ctr => vr_tab_assinaturas_ctr                                       
                              ,pr_cdcritic        => vr_cdcritic         --> C�digo da cr�tica
                              ,pr_dscritic        => vr_dscritic);         --> Descri��o da cr�t
                                      
    IF nvl(vr_cdcritic,0) > 0 OR
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;   
    
    
    vr_idxctr := vr_tab_dados_ctr.first;
    --> Verificar se retornou informacao
    IF vr_idxctr IS NULL THEN
      vr_dscritic := 'Nao foi possivel gerar a impressao.';
      RAISE vr_exc_erro;
    END IF;
    
    vr_idxass := vr_tab_assinaturas_ctr.first;
    --> Verificar se retornou informacao
    IF vr_idxass IS NULL THEN
      vr_dscritic := 'Termo n�o foi assinado.';
      RAISE vr_exc_erro;
    END IF;
   
    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    
    vr_txtcompl := NULL;
   
    --> INICIO
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz>
                    <nmprimtl>'|| vr_tab_dados_ctr(vr_idxctr).nmprimtl ||'</nmprimtl>'); 
    
    pc_escreve_xml('<nrctrd>'||vr_tab_dados_ctr(vr_idxctr).nrctrcrd||'</nrctrd>'||
                   '<postoAtendimento>'|| vr_tab_dados_ctr(vr_idxctr).cdagenci ||' - '|| vr_tab_dados_ctr(vr_idxctr).nmresage ||'</postoAtendimento>'||
                   '<contaCorrente>'|| gene0002.fn_mask_conta(vr_tab_dados_ctr(vr_idxctr).nrdconta) ||'</contaCorrente>'||
                   '<razaoSocial>'|| vr_tab_dados_ctr(vr_idxctr).razaosocial ||'</razaoSocial>'||
                   '<cnpj>'|| vr_tab_dados_ctr(vr_idxctr).nrcpfcgc ||'</cnpj>'||
                   '<nomeFantasia>'|| vr_tab_dados_ctr(vr_idxctr).nmfantasia ||'</nomeFantasia>'||
                   '<dataConstituicao>'|| vr_tab_dados_ctr(vr_idxctr).dtconstituicao ||'</dataConstituicao>'||
                   '<nomeImpresso>'|| vr_tab_dados_ctr(vr_idxctr).nmimpresso ||'</nomeImpresso>'||
                   '<faturamentoAnual>'|| 'R$ '|| to_char(vr_tab_dados_ctr(vr_idxctr).vlfaturamentoanual,'FM99G999G990D00') ||'</faturamentoAnual>'||
                   '<tipoCartao>'|| vr_tab_dados_ctr(vr_idxctr).nmresadm ||'</tipoCartao>'||
                   '<foneComercial>'|| vr_tab_dados_ctr(vr_idxctr).vrnrteco ||'</foneComercial>'||
                   '<foneCelular>'|| vr_tab_dados_ctr(vr_idxctr).vrnrtece ||'</foneCelular>'||
                   '<rendimentos>'|| 'R$ '|| to_char(vr_tab_dados_ctr(vr_idxctr).vlrenda,'FM99G999G990D00') ||'</rendimentos>'||
                   '<limiteSugerido>'|| 'R$ '|| to_char(vr_tab_dados_ctr(vr_idxctr).vllimsug,'FM99G999G990D00') ||'</limiteSugerido>'||
                   '<limiteContratado>'|| 'R$ '|| to_char(vr_tab_dados_ctr(vr_idxctr).vllimcon,'FM99G999G990D00') ||'</limiteContratado>'||
                   '<limiteEsteira>'|| 'R$ '|| to_char(vr_tab_dados_ctr(vr_idxctr).vllimest,'FM99G999G990D00') ||'</limiteEsteira>'||
                   '<formaPagamento>'|| vr_tab_dados_ctr(vr_idxctr).tpforma_pagamento ||'</formaPagamento>'||
                   '<dadosSolicitacao>'|| vr_tab_dados_ctr(vr_idxctr).dsdadosSolicitacao ||'</dadosSolicitacao>'||
                   '<dadosAprovacao>'|| vr_tab_dados_ctr(vr_idxctr).dsdadosAprovacao ||'</dadosAprovacao>'||
                   '<localEData>'|| vr_tab_dados_ctr(vr_idxctr).nmlocaldata ||'</localEData>'||
                   '<spc>'|| vr_tab_dados_ctr(vr_idxctr).indspc ||'</spc>'||
                   '<serasa>'|| vr_tab_dados_ctr(vr_idxctr).indserasa ||'</serasa>'||
                   '<diaPagamento>'|| vr_tab_dados_ctr(vr_idxctr).nrdia_pagamento ||'</diaPagamento>'||
                   '<cdgraupr>'|| vr_tab_dados_ctr(vr_idxctr).cdgraupr ||'</cdgraupr>');
                     
    pc_escreve_xml('<portadores>');
    
    IF vr_tab_dados_ctr(vr_idxctr).cdgraupr = 9 THEN
      pc_escreve_xml('<portador>');
      pc_escreve_xml('<nomeCompleto>'||vr_tab_dados_ctr(vr_idxctr).nmprimtl||'</nomeCompleto>'||
                     '<nomeImpresso>'||vr_tab_dados_ctr(vr_idxctr).nmtitcrd||'</nomeImpresso>'||
                     '<cpf>'||vr_tab_dados_ctr(vr_idxctr).nrcpftit||'</cpf>'||
                     '<dataNascimento>'||to_char(vr_tab_dados_ctr(vr_idxctr).dtnasctl,'DD/MM/RRRR')||'</dataNascimento>'||
                     '<identidade>'||vr_tab_dados_ctr(vr_idxctr).nrdocttl||'</identidade>'||
                     '<emissor>'||vr_tab_dados_ctr(vr_idxctr).cdorgao_expedidor||'</emissor>'||
                     '<ufEmissao>'||vr_tab_dados_ctr(vr_idxctr).cdufdttl||'</ufEmissao>');
      pc_escreve_xml('</portador>');
    ELSE
      FOR rindex IN 1..vr_tab_crapavt.count LOOP
        --
        IF gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => vr_tab_crapavt(rindex).nrcpfcgc,
                                     pr_inpessoa => 1) = vr_tab_dados_ctr(vr_idxctr).nrcpftit THEN
          pc_escreve_xml('<portador>');
          pc_escreve_xml('<nomeCompleto>'||vr_tab_crapavt(rindex).nmdavali||'</nomeCompleto>'||
                         '<nomeImpresso>'||vr_tab_crapavt(rindex).nmdavali||'</nomeImpresso>'||
                         '<cpf>'||vr_tab_crapavt(rindex).nrcpfcgc||'</cpf>'||
                         '<dataNascimento>'||to_char(vr_tab_crapavt(rindex).dtnascto,'DD/MM/RRRR')||'</dataNascimento>'||
                         '<identidade>'||vr_tab_crapavt(rindex).nrdocava||'</identidade>'||
                         '<emissor>'||vr_tab_crapavt(rindex).cdoeddoc||'</emissor>'||
                         '<ufEmissao>'||vr_tab_crapavt(rindex).cdufddoc||'</ufEmissao>');
          pc_escreve_xml('</portador>');
        END IF;
        --
      END LOOP;
    END IF;
    
    pc_escreve_xml('</portadores>');
    
    pc_escreve_xml('<assinaturas>');
    
    FOR rindex IN 1..vr_tab_assinaturas_ctr.count LOOP
      pc_escreve_xml('<assinatura>');
      pc_escreve_xml('<txtassinatura>'||vr_tab_assinaturas_ctr(rindex).nmtextoassinatura||'</txtassinatura>');
      pc_escreve_xml('</assinatura>');
    END LOOP;
    
    pc_escreve_xml('</assinaturas>');
        
    --> Descarregar buffer    
    pc_escreve_xml(' ',TRUE); 
    
    --> Descarregar buffer    
    pc_escreve_xml('</raiz>',TRUE); 
    
   loop exit when l_offset > dbms_lob.getlength(vr_des_xml);
   DBMS_OUTPUT.PUT_LINE (dbms_lob.substr( vr_des_xml, 254, l_offset) || '~');
   l_offset := l_offset + 255;
   end loop;
    
    --> Solicita geracao do PDF
    gene0002.pc_solicita_relato(pr_cdcooper   => pr_cdcooper
                               , pr_cdprogra  => pr_cdprogra
                               , pr_dtmvtolt  => pr_dtmvtolt
                               , pr_dsxml     => vr_des_xml
                               , pr_dsxmlnode => '/raiz'
                               , pr_dsjasper  => 'termo_adesao_pj.jasper'
                               , pr_dsparams  => null
                               , pr_dsarqsaid => vr_dsdireto ||'/rl/'||pr_nmarqpdf
                               , pr_flg_gerar => 'S'
                               , pr_qtcoluna  => 234
                               , pr_cdrelato  => 280
                               , pr_sqcabrel  => 1
                               , pr_flg_impri => 'N'
                               , pr_nmformul  => ' '
                               , pr_nrcopias  => 1
                               , pr_nrvergrl  => 1
                               , pr_dsextmail => NULL
                               , pr_dsmailcop => vr_dsmailcop
                               , pr_dsassmail => vr_dsassmail
                               , pr_dscormail => vr_dscormail
                               , pr_des_erro  => vr_dscritic);
    
    IF vr_dscritic IS NOT NULL THEN -- verifica retorno se houve erro
      RAISE vr_exc_erro; -- encerra programa
    END IF;        
    
    IF pr_idorigem = 5 THEN
      -- Copia contrato PDF do diretorio da cooperativa para servidor WEB
      GENE0002.pc_efetua_copia_pdf(pr_cdcooper => pr_cdcooper
                                  ,pr_cdagenci => NULL
                                  ,pr_nrdcaixa => NULL
                                  ,pr_nmarqpdf => vr_dsdireto ||'/rl/'||pr_nmarqpdf
                                  ,pr_des_reto => vr_des_reto
                                  ,pr_tab_erro => vr_tab_erro);
      -- Se retornou erro
      IF NVL(vr_des_reto,'OK') <> 'OK' THEN
        IF vr_tab_erro.COUNT > 0 THEN -- verifica pl-table se existe erros
          vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic; -- busca primeira critica
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic; -- busca primeira descricao da critica
          RAISE vr_exc_erro; -- encerra programa
        END IF;
      END IF;

      -- Remover relatorio do diretorio padrao da cooperativa
      gene0001.pc_OScommand(pr_typ_comando => 'S'
                           ,pr_des_comando => 'rm '||vr_dsdireto ||'/rl/'||pr_nmarqpdf||' 2>/dev/null'
                           ,pr_typ_saida   => vr_typsaida
                           ,pr_des_saida   => vr_dscritic);
      
      -- Se retornou erro
      IF vr_typsaida = 'ERR' OR vr_dscritic IS NOT NULL THEN
        -- Concatena o erro que veio
        vr_dscritic := 'Erro ao remover arquivo: '||vr_dscritic;
        RAISE vr_exc_erro; -- encerra programa
      END IF;
    END IF;        
    
    --> Gerar log de sucesso
    IF pr_flgerlog = 1 THEN
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                           pr_cdoperad => pr_cdopecxa, 
                           pr_dscritic => NULL, 
                           pr_dsorigem => vr_dsorigem, 
                           pr_dstransa => vr_dstransa, 
                           pr_dttransa => trunc(SYSDATE),
                           pr_flgtrans =>  1, -- True
                           pr_hrtransa => gene0002.fn_busca_time, 
                           pr_idseqttl => vr_idseqttl, 
                           pr_nmdatela => pr_nmdatela, 
                           pr_nrdconta => pr_nrdconta, 
                           pr_nrdrowid => vr_nrdrowid);
                             
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                pr_nmdcampo => 'nrctrlim', 
                                pr_dsdadant => NULL, 
                                pr_dsdadatu => pr_nrctrlim);
    END IF;
    
    COMMIT;
    
  EXCEPTION    
    WHEN vr_exc_erro THEN
      
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := replace(replace(vr_dscritic,chr(13)),chr(10));
      END IF;
      
      IF pr_flgerlog = 1 THEN
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                             pr_cdoperad => pr_cdopecxa, 
                             pr_dscritic => pr_dscritic, 
                             pr_dsorigem => vr_dsorigem, 
                             pr_dstransa => vr_dstransa, 
                             pr_dttransa => trunc(SYSDATE),
                             pr_flgtrans =>  0, --FALSE
                             pr_hrtransa => gene0002.fn_busca_time, 
                             pr_idseqttl => vr_idseqttl, 
                             pr_nmdatela => pr_nmdatela, 
                             pr_nrdconta => pr_nrdconta, 
                             pr_nrdrowid => vr_nrdrowid);
                             
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                  pr_nmdcampo => 'nrctrlim', 
                                  pr_dsdadant => NULL, 
                                  pr_dsdadatu => pr_nrctrlim);
      END IF;
      
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := replace(replace('Erro ao gerar impressao do contrato: ' || SQLERRM, chr(13)),chr(10));   
  
      IF pr_flgerlog = 1 THEN
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                             pr_cdoperad => pr_cdopecxa, 
                             pr_dscritic => pr_dscritic, 
                             pr_dsorigem => vr_dsorigem, 
                             pr_dstransa => vr_dstransa, 
                             pr_dttransa => trunc(SYSDATE),
                             pr_flgtrans =>  0, --FALSE
                             pr_hrtransa => gene0002.fn_busca_time, 
                             pr_idseqttl => vr_idseqttl, 
                             pr_nmdatela => pr_nmdatela, 
                             pr_nrdconta => pr_nrdconta, 
                             pr_nrdrowid => vr_nrdrowid);
                             
        gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid, 
                                  pr_nmdcampo => 'nrctrlim', 
                                  pr_dsdadant => NULL, 
                                  pr_dsdadatu => pr_nrctrlim);
      END IF; 
      
  END pc_impres_termo_adesao_pj;
  
  --> Rotina para gera��o do Termo de Ades�o PF  - Ayllos Web
  PROCEDURE pc_impres_termo_adesao_pf_web(pr_nrdconta   IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                         ,pr_nrctrcrd   IN crapcrd.nrctrcrd%TYPE  --> Contrato
                                         ,pr_xmllog     IN VARCHAR2               --> XML com informacoes de LOG
                                         ,pr_cdcritic  OUT PLS_INTEGER            --> Codigo da critica
                                         ,pr_dscritic  OUT VARCHAR2               --> Descricao da critica
                                         ,pr_retxml IN OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                         ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
                                         ,pr_des_erro  OUT VARCHAR2) IS           --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_impres_termo_adesao_pf_web
    Sistema : Ayllos Web
    Autor   : Paulo Silva - Supero
    Data    : Mar�o/2018                 Ultima atualizacao: 28/03/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para chamar as impressoes pelo Ayllos Web

    Alteracoes: -----
    ..............................................................................*/
    DECLARE
      -- Cursor da data
      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Variaveis gerais
      vr_nmarqpdf VARCHAR2(1000);

    BEGIN
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);
                              
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'pc_gera_impressao'
                                ,pr_action => vr_nmeacao);

      -- Busca a data do sistema
      OPEN  BTCH0001.cr_crapdat(vr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;

      pc_impres_termo_adesao_pf(pr_cdcooper => vr_cdcooper  --> C�digo da Cooperativa
                               ,pr_cdagecxa => vr_cdagenci  --> C�digo da agencia
                               ,pr_nrdcaixa => vr_nrdcaixa  --> Numero do caixa do operador
                               ,pr_cdopecxa => vr_cdoperad  --> C�digo do Operador
                               ,pr_nmdatela => vr_nmdatela  --> Nome da Tela
                               ,pr_idorigem => vr_idorigem  --> Identificador de Origem
                               ,pr_cdprogra => 'ATENDA'  --> Codigo do programa
                               ,pr_nrdconta => pr_nrdconta  --> N�mero da Conta
                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt  --> Data de Movimento
                               ,pr_nrctrlim => pr_nrctrcrd  --> Contrato
                               ,pr_flgerlog => 1            --> True 
                               --------> OUT <--------
                               ,pr_nmarqpdf => vr_nmarqpdf       --> Retornar quantidad de registros                           
                               ,pr_cdcritic => vr_cdcritic       --> C�digo da cr�tica
                               ,pr_dscritic => vr_dscritic);     --> Descri��o da cr�tica

      -- Se retornou erro
      IF NVL(vr_cdcritic,0) > 0 OR 
         TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'nmarqpdf'
                            ,pr_tag_cont => vr_nmarqpdf
                            ,pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela pc_impres_termo_adesao_pf_web: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_impres_termo_adesao_pf_web;
  
  --> Rotina para gera��o do Termo de Ades�o PJ  - Ayllos Web
  PROCEDURE pc_impres_termo_adesao_pj_web(pr_nrdconta   IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                         ,pr_nrctrcrd   IN crapcrd.nrctrcrd%TYPE  --> Contrato
                                         ,pr_xmllog     IN VARCHAR2               --> XML com informacoes de LOG
                                         ,pr_cdcritic  OUT PLS_INTEGER            --> Codigo da critica
                                         ,pr_dscritic  OUT VARCHAR2               --> Descricao da critica
                                         ,pr_retxml IN OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                         ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
                                         ,pr_des_erro  OUT VARCHAR2) IS           --> Erros do processo
  BEGIN

    /* .............................................................................

    Programa: pc_impres_termo_adesao_pj_web
    Sistema : Ayllos Web
    Autor   : Carlos Lima - Supero
    Data    : Abril/2018                 Ultima atualizacao: 11/04/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para chamar as impressoes pelo Ayllos Web

    Alteracoes: -----
    ..............................................................................*/
    DECLARE
      -- Cursor da data
      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

      -- Variavel de criticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_erro EXCEPTION;

      -- Variaveis de log
      vr_cdcooper INTEGER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Variaveis gerais
      vr_nmarqpdf VARCHAR2(1000);

    BEGIN
      -- Extrai os dados vindos do XML
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'pc_impres_termo_adesao_pj_web'
                                ,pr_action => vr_nmeacao);
      
      -- Busca a data do sistema
      OPEN  BTCH0001.cr_crapdat(vr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;

      pc_impres_termo_adesao_pj(pr_cdcooper => vr_cdcooper  --> C�digo da Cooperativa
                               ,pr_cdagecxa => vr_cdagenci  --> C�digo da agencia
                               ,pr_nrdcaixa => vr_nrdcaixa  --> Numero do caixa do operador
                               ,pr_cdopecxa => vr_cdoperad  --> C�digo do Operador
                               ,pr_nmdatela => vr_nmdatela  --> Nome da Tela
                               ,pr_idorigem => vr_idorigem  --> Identificador de Origem
                               ,pr_cdprogra => 'ATENDA'  --> Codigo do programa
                               ,pr_nrdconta => pr_nrdconta  --> N�mero da Conta
                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt  --> Data de Movimento
                               ,pr_nrctrlim => pr_nrctrcrd  --> Contrato
                               ,pr_flgerlog => 1            --> True 
                               --------> OUT <--------
                               ,pr_nmarqpdf => vr_nmarqpdf       --> Retornar quantidad de registros                           
                               ,pr_cdcritic => vr_cdcritic       --> C�digo da cr�tica
                               ,pr_dscritic => vr_dscritic);     --> Descri��o da cr�tica

      -- Se retornou erro
      IF NVL(vr_cdcritic,0) > 0 OR 
         TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Dados'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'nmarqpdf'
                            ,pr_tag_cont => vr_nmarqpdf
                            ,pr_des_erro => vr_dscritic);

    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic <> 0 THEN
          vr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela pc_impres_termo_adesao_pj_web: ' || SQLERRM;

        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_impres_termo_adesao_pj_web;
END CCRD0008;
/
