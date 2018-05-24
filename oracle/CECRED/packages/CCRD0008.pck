CREATE OR REPLACE PACKAGE CECRED.CCRD0008 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : CCRD0008
  --  Sistema  : Impressão de Termos de Adesão
  --  Sigla    : CCRD
  --  Autor    : Paulo Roberto da Silva (Supero)
  --  Data     : março/2018.                   Ultima atualizacao: 09/03/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas para impressão de termos de adesão
  --
  -- Alteracoes:
  --
  --------------------------------------------------------------------------------------------------------------
                                     
  --> Rotina para geração do Termo de Adesão  - Ayllos Web
  PROCEDURE pc_impres_termo_adesao_pf_web(pr_nrdconta   IN crapass.nrdconta%TYPE  --> Número da Conta
                                         ,pr_nrctrcrd   IN crapcrd.nrctrcrd%TYPE  --> Contrato                                  
                                         ,pr_xmllog     IN VARCHAR2               --> XML com informacoes de LOG
                                         ,pr_cdcritic  OUT PLS_INTEGER            --> Codigo da critica
                                         ,pr_dscritic  OUT VARCHAR2               --> Descricao da critica
                                         ,pr_retxml IN OUT NOCOPY xmltype         --> Arquivo de retorno do XML
                                         ,pr_nmdcampo  OUT VARCHAR2               --> Nome do campo com erro
                                         ,pr_des_erro  OUT VARCHAR2);             --> Erros do processo
                                         
  PROCEDURE pc_impres_termo_adesao_pj_web(pr_nrdconta   IN crapass.nrdconta%TYPE  --> Número da Conta
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
  --  Sistema  : Impressão de Termos de Adesão
  --  Sigla    : CCRD
  --  Autor    : Paulo Roberto da Silva (Supero)
  --  Data     : março/2018.                   Ultima atualizacao: 09/03/2018
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas para impressão de termos de adesão
  --
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------

  --> Armazenar dados do contrato
  TYPE typ_rec_dados_ctr 
       IS RECORD (nrctrcrd crapcrd.nrctrcrd%TYPE, --Nr Contrato
                  nmresage crapage.nmresage%TYPE, --Posto Atendimento
                  nrdconta crapass.nrdconta%TYPE, --Conta Corrente
                  nmresadm crapadc.nmresadm%TYPE,--Tipo Cartão CECRED
                  nmprimtl crapass.nmprimtl%TYPE, --Nome Completo
                  nrcpfcgc VARCHAR2(100),         --CPF/CNPJ
                  razaosocial   VARCHAR2(200),    -- Razão Social
                  dtconstituicao  VARCHAR2(10), -- Data da Constituição
                  nmimpresso       VARCHAR2(200),   -- Nome Impresso
                  vlfaturamentoanual   crapjur.vlfatano%TYPE, -- Faturamento Anual
                  nmfantasia       VARCHAR2(200),    -- Nome Fantasia
                  nmtitcrd crawcrd.nmtitcrd%TYPE, --Nome Impresso Cartão
                  dtnasctl crapass.dtnasctl%TYPE, --Data Nascimento
                  nrdocttl crapttl.nrdocttl%TYPE, --Nr Identidade
                  cdorgao_expedidor tbgen_orgao_expedidor.cdorgao_expedidor%TYPE, --Órgão Expedidor
                  cdufdttl crapttl.cdufdttl%TYPE, --UF Identidade
                  dtemdttl crapttl.dtemdttl%TYPE, --Data Emissão Identidade
                  cdsexotl crapass.cdsexotl%TYPE, --Sexo
                  dssexotl VARCHAR2(1),           --Descrição Sexo
                  dsnatura crapttl.dsnatura%TYPE, --Naturalidade
                  dsnacion crapnac.dsnacion%TYPE, --Nacionalidade
                  rsestcvl gnetcvl.rsestcvl%TYPE, --Estado Civil
                  vrnrtere VARCHAR2(40),          --Nr Telefone Residencial
                  vrnrteco VARCHAR2(40),          --Nr Telefone Comercial
                  vrnrtece VARCHAR2(40),          --Nr Telefone Celular
                  vlrenda  crapttl.vlsalari%TYPE,   -- Renda
                  vllimite crawcrd.vllimcrd%TYPE,   -- Limite de credito
                  dsdadosSolicitacao VARCHAR2(500), -- Responsavel solicitação
                  dsdadosAprovacao VARCHAR2(500),  -- Responsavel aprovação
                  tpforma_pagamento VARCHAR2(100), -- Forma de pagamento
                  nmlocaldata      VARCHAR2(200),   -- Local e Data Assinatura
                  indspc           VARCHAR2(1),     -- Indicador se está no SPC
                  indserasa        VARCHAR2(1),     -- Indicador se está no SERASA   
                  nrdia_pagamento VARCHAR2(2),
                  cdgraupr crawcrd.cdgraupr%TYPE);    -- Dia de pagamento
                  
  TYPE typ_tab_dados_ctr IS TABLE OF typ_rec_dados_ctr
       INDEX BY PLS_INTEGER;                
                  
  --> Armazenar dados das assinaturas
  TYPE typ_rec_assinaturas_ctr 
       IS RECORD (hraprovacao      tbcrd_aprovacao_cartao.hraprovacao%TYPE, -- Hora da assinatura
                  dtaprovacao      tbcrd_aprovacao_cartao.dtaprovacao%TYPE,    -- Data da assinatura
                  nmaprovador      tbcrd_aprovacao_cartao.nmaprovador%TYPE,
                  idaprovacao      tbcrd_aprovacao_cartao.idaprovacao%TYPE,
                  nrctrcrd         tbcrd_aprovacao_cartao.nrctrcrd%TYPE,
                  indtipo_senha    tbcrd_aprovacao_cartao.indtipo_senha%TYPE,
                  nrcpf            tbcrd_aprovacao_cartao.nrcpf%TYPE);   -- Nome da assinatura  
                                  
  TYPE typ_tab_assinaturas_ctr IS TABLE OF typ_rec_assinaturas_ctr
       INDEX BY PLS_INTEGER;
  
  --> Rotina para buscar dados para impressao do Termo de Adesão PF
  PROCEDURE pc_obtem_dados_contrato (  pr_cdcooper        IN crapcop.cdcooper%TYPE  --> Código da Cooperativa 
                                      ,pr_cdagenci        IN crapage.cdagenci%TYPE  --> Código da agencia
                                      ,pr_nrdcaixa        IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                      ,pr_cdoperad        IN crapope.cdoperad%TYPE  --> Código do Operador
                                      ,pr_idorigem        IN INTEGER                --> Identificador de Origem
                                      ,pr_nrdconta        IN crapass.nrdconta%TYPE  --> Número da Conta
                                      ,pr_dtmvtolt        IN crapdat.dtmvtolt%TYPE  --> Data de Movimento
                                      ,pr_nrctrlim        IN craplim.nrctrlim%TYPE  --> Contrato
                                      ,pr_nmdatela        IN craptel.nmdatela%TYPE
                                      ,pr_tab_dados_ctr   OUT typ_tab_dados_ctr      --> Dados do contrato 
                                      ,pr_tab_crapavt     OUT cada0001.typ_tab_crapavt_58
                                      ,pr_tab_bens        OUT cada0001.typ_tab_bens    
                                      ,pr_tab_assinaturas_ctr OUT typ_tab_assinaturas_ctr                               
                                      ,pr_cdcritic        OUT PLS_INTEGER            --> Código da crítica
                                      ,pr_dscritic        OUT VARCHAR2) IS           --> Descrição da crít
                                      
    /* .............................................................................

     Programa: pc_obtem_dados_contrato
     Sistema : Rotinas referentes ao Termo Adesão Cartão de Crédito
     Sigla   : CRED
     Autor   : Paulo Silva - Supero
     Data    : Março/2018.                    Ultima atualizacao: 28/03/2018

     Dados referentes ao programa:

     Frequencia:
     Objetivo  : Rotina para buscar dados para impressao do Termo de Adesão
     
     Alteracoes: 
    ..............................................................................*/
    
    ---------->> CURSORES <<--------
    --> Buscar dados associado PF
    CURSOR cr_crappf (pr_cdcooper crapass.cdcooper%TYPE,
                       pr_nrdconta crapass.nrdconta%TYPE )IS
      SELECT ass.nrcpfcgc,
             ass.nmprimtl,
             ass.cdagenci,
             ass.inpessoa,
             ass.nrdconta,
             ass.nrdocptl,
             ass.idorgexp,
             ass.tpdocptl,
             ass.cdufdptl,
             ass.dtemdptl,
             ass.dtnasctl,
             ass.cdsexotl,
             decode(ass.cdsexotl,1,'M',2,'F') dssexotl,
             ass.cdnacion,
             ttl.dsnatura,
             ttl.cdestcvl,
             ttl.vlsalari
        FROM crapttl ttl
            ,crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta
         AND ttl.cdcooper = ass.cdcooper
         AND ttl.nrdconta = ass.nrdconta
         AND ttl.idseqttl = 1;
    rw_crappf cr_crappf%ROWTYPE;
    
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
             ass.dtemdptl
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
    rw_crapope cr_crapope%ROWTYPE;
    
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
         
    --> Buscar informações do contrato
    CURSOR cr_crawcrd IS
      SELECT crd.nrctrcrd
            ,crd.dtinsori
            ,crd.cdadmcrd
            ,crd.nmtitcrd
            ,crd.dddebito
            ,DECODE(crd.tpdpagto,
                    1,'Débito Automático (Total)',
                    2,'Débito Automático (Mínimo)',
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
        FROM crawcrd crd
       WHERE crd.cdcooper = pr_cdcooper
         and crd.nrdconta = pr_nrdconta
         and crd.nrctrcrd = pr_nrctrlim;
    rw_crawcrd cr_crawcrd%ROWTYPE;
    
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
    
    -- Cursor para identificar restrições
    CURSOR cr_crapcbd(pr_cdcooper crapass.cdcooper%TYPE
                     ,pr_nrdconta crapass.nrdconta%TYPE
                     ,pr_nrcpfcgc crapass.nrcpfcgc%TYPE) IS
      SELECT crapcbd.nrconbir,
             crapcbd.nrseqdet
        FROM crapcbd
      WHERE crapcbd.cdcooper  = pr_cdcooper
         AND crapcbd.nrdconta = pr_nrdconta 
         AND crapcbd.nrcpfcgc = pr_nrcpfcgc
         AND crapcbd.inreterr = 0  -- Nao houve erros
      ORDER BY crapcbd.dtconbir DESC; -- Buscar a consuilta mais recente  
    rw_crapcbd    cr_crapcbd%ROWTYPE;
    
    ----------->>> VARIAVEIS <<<--------   
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic        VARCHAR2(1000);        --> Desc. Erro    
    
    -- Tratamento de erros
    vr_exc_erro        EXCEPTION;
    vr_idxctr          PLS_INTEGER;
    vr_idxassinaturas  PLS_INTEGER;
    vr_tab_dados_ctr   typ_tab_dados_ctr;    
    
    vr_cdoedrep        tbgen_orgao_expedidor.cdorgao_expedidor%TYPE;
    vr_nmorgexp        tbgen_orgao_expedidor.nmorgao_expedidor%TYPE;
    vr_nrdocttl        crapass.nrdocptl%TYPE;
    
    vr_dsDadosSolicitante    VARCHAR2(500);
    vr_dsDadosAprovador      VARCHAR2(500);
    
    vr_localedata        VARCHAR2(200);
    
    vr_tab_crapavt       cada0001.typ_tab_crapavt_58;
    vr_tab_bens          cada0001.typ_tab_bens;
    vr_tab_erro          gene0001.typ_tab_erro;
    vr_tab_assinaturas_ctr  typ_tab_assinaturas_ctr;
    
    vr_dt_constituicao   VARCHAR2(10); -- Data da constituição da empresa (PJ)
    --variaveis de restrições
    vr_cdbircon          crapbir.cdbircon%TYPE;
    vr_dsbircon          crapbir.dsbircon%TYPE;
    vr_cdmodbir          crapmbr.cdmodbir%TYPE;
    vr_dsmodbir          crapmbr.dsmodbir%TYPE;
    vr_flsituac          VARCHAR2(10);
                                                 
  BEGIN
  
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop;
    FETCH cr_crapcop INTO rw_crapcop;
    -- Se não encontrar
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
    
    IF rw_crapass.inpessoa = 1 THEN
      --> Buscar dados PF
      OPEN cr_crappf(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta);
      FETCH cr_crappf INTO rw_crappf;
      IF cr_crappf%NOTFOUND THEN 
        CLOSE cr_crappf;
        vr_cdcritic := 9; -- 009 - Associado nao cadastrado.
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crappf;
      END IF;
      
      -- Buscar estado civil  
      OPEN cr_gnetcvl(pr_cdestcvl => rw_crappf.cdestcvl);
      FETCH cr_gnetcvl INTO rw_gnetcvl;
      IF cr_gnetcvl%NOTFOUND THEN 
        CLOSE cr_gnetcvl;
        vr_dscritic := 'Estado civil nao cadastrado';
        --RAISE vr_exc_erro;
      ELSE
        CLOSE cr_gnetcvl;

      END IF;
      
      --> Buscar dados de Nacionalidade                           
      OPEN cr_crapnac(rw_crappf.cdnacion); 
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
        vr_dscritic := 'Telefone residencial não encontrado.';
        --RAISE vr_exc_erro;
      ELSE
        CLOSE cr_craptfc;
      END IF;
    END IF;
    
    --> Buscar endereço do cooperado
    OPEN cr_crapenc;
    FETCH cr_crapenc INTO rw_crapenc;
    IF cr_crapenc%NOTFOUND THEN
      CLOSE cr_crapenc;
      vr_dscritic := 'Endereco nao cadastrado.';
      --RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapenc;
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
      vr_dscritic := 'Telefone celular não encontrado.';
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
      END LOOP; 
    EXCEPTION
      WHEN no_data_found THEN
         vr_dscritic := 'Assinatura não encontrada.';
         RAISE vr_exc_erro;
    END;
    
	IF vr_idxassinaturas = 0 THEN
       vr_dscritic := 'Assinatura não encontrada.';
       vr_tab_assinaturas_ctr(1).nmaprovador := 'Assinatura realizada sobre o termo pré impresso na ocasião.';
    END IF;
    
    -- Se for pessoa Juridica
    IF rw_crapass.inpessoa > 1 THEN
      OPEN cr_crapjur;
      FETCH cr_crapjur INTO rw_crapjur;
      IF cr_crapjur%NOTFOUND THEN
        CLOSE cr_crapjur;
        vr_dscritic := 'Dados da pessoa Juridica não encontrado.';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapjur;
      END IF;
    END IF;  
    -- Busca restrições 
    OPEN cr_crapcbd(pr_cdcooper
                   ,pr_nrdconta
                   ,rw_crapass.nrcpfcgc);
    FETCH cr_crapcbd INTO rw_crapcbd;
    CLOSE cr_crapcbd; 
    --Verifica se esta no SPC/SERASA
    SSPC0001.pc_verifica_situacao(pr_nrconbir => rw_crapcbd.nrconbir
                                 ,pr_nrseqdet => rw_crapcbd.nrseqdet
                                 ,pr_cdbircon => vr_cdbircon
                                 ,pr_dsbircon => vr_dsbircon
                                 ,pr_cdmodbir => vr_cdmodbir
                                 ,pr_dsmodbir => vr_dsmodbir
                                 ,pr_flsituac => vr_flsituac); 
    
    -- Monta o Local e Data
    vr_localedata := SUBSTR(rw_crapage.nmcidade,1,15) ||', ' || gene0005.fn_data_extenso(rw_crawcrd.dtinsori);
    
    IF rw_crapass.inpessoa = 1 THEN
      
      IF rw_crappf.tpdocptl = 'CI' THEN
        vr_nrdocttl := rw_crappf.nrdocptl;
      END IF;
      
      --Busca Órgão Expedidor
      cada0001.pc_busca_orgao_expedidor(pr_idorgao_expedidor => rw_crappf.idorgexp, 
                                        pr_cdorgao_expedidor => vr_cdoedrep, 
                                        pr_nmorgao_expedidor => vr_nmorgexp, 
                                        pr_cdcritic          => vr_cdcritic, 
                                        pr_dscritic          => vr_dscritic);
                                        
      IF nvl(vr_cdcritic,0) > 0 OR 
         TRIM(vr_dscritic) IS NOT NULL THEN
        vr_cdoedrep := 'NAO CADAST';
        vr_nmorgexp := NULL; 
      END IF;
    END IF;  
    
    -- Monta os dados do Aprovador
    IF rw_crawcrd.cdadmcrd IN (16,17) THEN --Débito
      --O mesmo da solicitação
      vr_dsDadosAprovador := rw_crawcrd.cdoperad ||' - '|| rw_crapope_aprovador.nmoperad ||' em '|| to_char(rw_crawcrd.dtinsori,'DD/MM/YYYY');
    ELSE
      IF rw_crawcrd.dsjustif IS NULL THEN
        vr_dsDadosAprovador := 'Motor de Crédito em '|| to_char(rw_crawcrd.dtinsori,'DD/MM/YYYY');
      ELSE
        vr_dsDadosAprovador := 'Esteira de Crédito em '|| to_char(rw_crawcrd.dtaprova,'DD/MM/YYYY');
      END IF;
    END IF;
    
    IF rw_crapjur.dtiniatv IS NOT NULL THEN
      vr_dt_constituicao := to_char(rw_crapjur.dtiniatv,'DD/MM/YYYY');
    END IF;
    
    -- Monta os dados do Solicitante
    vr_dsDadosSolicitante := rw_crawcrd.cdoperad ||' - '|| rw_crapope_solicitante.nmoperad ||' em '|| to_char(rw_crawcrd.dtinsori,'DD/MM/YYYY');
    
    --> Carregar temptable do contrato
    vr_idxctr := vr_tab_dados_ctr.count() + 1;
    --
    vr_tab_dados_ctr(vr_idxctr).nrctrcrd := rw_crawcrd.nrctrcrd; --Nr Contrato
    vr_tab_dados_ctr(vr_idxctr).nmresage := rw_crapage.nmresage; --Posto Atendimento
    vr_tab_dados_ctr(vr_idxctr).nrdconta := pr_nrdconta;         --Conta Corrente
    vr_tab_dados_ctr(vr_idxctr).nmresadm := rw_crawcrd.cdadmcrd; --Tipo Cartão CECRED
    vr_tab_dados_ctr(vr_idxctr).nmprimtl := rw_crappf.nmprimtl; --Nome Completo
    vr_tab_dados_ctr(vr_idxctr).nrcpfcgc := rw_crapass.nrcpfcgc; --CPF/CNPJ
    vr_tab_dados_ctr(vr_idxctr).nmtitcrd := rw_crawcrd.nmtitcrd; --Nome Impresso Cartão
    vr_tab_dados_ctr(vr_idxctr).dtnasctl := rw_crappf.dtnasctl; --Data Nascimento
    vr_tab_dados_ctr(vr_idxctr).nrdocttl := vr_nrdocttl;         --Nr Identidade
    vr_tab_dados_ctr(vr_idxctr).cdorgao_expedidor := vr_cdoedrep; --Órgão Expedidor
    vr_tab_dados_ctr(vr_idxctr).cdufdttl := rw_crappf.cdufdptl; --UF Identidade
    vr_tab_dados_ctr(vr_idxctr).dtemdttl := rw_crappf.dtemdptl; --Data Emissão Identidade
    vr_tab_dados_ctr(vr_idxctr).cdsexotl := rw_crappf.cdsexotl; --Sexo
    vr_tab_dados_ctr(vr_idxctr).dssexotl := rw_crappf.dssexotl; --Descrição Sexo
    vr_tab_dados_ctr(vr_idxctr).dsnatura := rw_crappf.dsnatura; --Naturalidade
    vr_tab_dados_ctr(vr_idxctr).dsnacion := rw_crapnac.dsnacion; --Nacionalidade
    vr_tab_dados_ctr(vr_idxctr).rsestcvl := rw_gnetcvl.rsestcvl; --Estado Civil
    vr_tab_dados_ctr(vr_idxctr).vrnrtere := rw_craptfc_resid.nrdddtfc ||' '|| rw_craptfc_resid.nrtelefo;          --Nr Telefone Residencial
    vr_tab_dados_ctr(vr_idxctr).vrnrteco := rw_craptfc_comer.nrdddtfc ||' '|| rw_craptfc_comer.nrtelefo;          --Nr Telefone Comercial
    vr_tab_dados_ctr(vr_idxctr).vrnrtece := rw_craptfc_celu.nrdddtfc ||' '||  rw_craptfc_celu.nrtelefo;           --Nr Telefone Celular
    vr_tab_dados_ctr(vr_idxctr).vllimite := rw_crawcrd.vllimcrd;                -- Limite de credito
    IF rw_crapass.inpessoa = 1 THEN
      vr_tab_dados_ctr(vr_idxctr).vlrenda  := rw_crappf.vlsalari;                -- Rendimento, Salário
    ELSE
      vr_tab_dados_ctr(vr_idxctr).vlrenda  := rw_crapjfn.vlfatur;               -- Rendimento, Salário
    END IF;  
    vr_tab_dados_ctr(vr_idxctr).dsdadosSolicitacao := vr_dsDadosSolicitante;    -- Operador Solicitante
    vr_tab_dados_ctr(vr_idxctr).dsdadosAprovacao := vr_dsDadosAprovador;        -- Operador Aprovador
    vr_tab_dados_ctr(vr_idxctr).tpforma_pagamento := rw_crawcrd.forma_pagto;    -- Forma de pagamento
    vr_tab_dados_ctr(vr_idxctr).nrdia_pagamento := rw_crawcrd.dddebito;         -- Dia de pagamento
    vr_tab_dados_ctr(vr_idxctr).nmlocaldata := vr_localedata;         -- Local e Data da Assinatura    
    vr_tab_dados_ctr(vr_idxctr).razaosocial :=rw_crapass.nmprimtl;              -- Razão Social
    vr_tab_dados_ctr(vr_idxctr).dtconstituicao := vr_dt_constituicao;    -- Data da Constituição
    vr_tab_dados_ctr(vr_idxctr).nmimpresso := rw_crawcrd.nmtitcrd;              -- Nome impresso do PJ
    vr_tab_dados_ctr(vr_idxctr).vlfaturamentoanual := rw_crapjur.vlfatano;      -- Faturamento atual
    vr_tab_dados_ctr(vr_idxctr).nmfantasia := rw_crapjur.nmfansia;              -- Nome fantasia
    vr_tab_dados_ctr(vr_idxctr).cdgraupr := rw_crawcrd.cdgraupr;                --Representante Outros
    
    IF nvl(vr_flsituac,'N') = 'S' THEN
      
      IF UPPER(vr_dsbircon) = 'SPC' THEN
         vr_tab_dados_ctr(vr_idxctr).indspc := 'S';
      ELSIF UPPER(vr_dsbircon) = 'SERASA' THEN
         vr_tab_dados_ctr(vr_idxctr).indserasa := 'S';
      END IF;   
      
    END IF;  
       
    vr_tab_dados_ctr(vr_idxctr).nrcpfcgc := gene0002.fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapass.nrcpfcgc,
                                                                      pr_inpessoa => rw_crapass.inpessoa);
    
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
  
  -- Rotina para geração do Termo de Adesão PF
  PROCEDURE pc_impres_termo_adesao_pf(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                     ,pr_cdagecxa IN crapage.cdagenci%TYPE  --> Código da agencia
                                     ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                     ,pr_cdopecxa IN crapope.cdoperad%TYPE  --> Código do Operador
                                     ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da Tela
                                     ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                     ,pr_cdprogra IN crapprg.cdprogra%TYPE  --> Codigo do programa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de Movimento
                                     ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                     ,pr_flgerlog IN INTEGER                --> Indicador se deve gerar log(0-nao, 1-sim)
                                     --------> OUT <--------
                                     ,pr_nmarqpdf  OUT VARCHAR2              --> Retornar quantidad de registros                           
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da crítica
    /* .............................................................................

     Programa: pc_impres_termo_adesao_pf
     Sistema : Rotinas referentes ao cartão de crédito
     Sigla   : CRED
     Autor   : Paulo Silva - Supero
     Data    : Março/2018.                    Ultima atualizacao: 28/03/2018

     Dados referentes ao programa:

     Frequencia:
     Objetivo  : Rotina para geração do Termo de Adesão PF
     Alteracoes: 
     
    ..............................................................................*/
    
    ----------->>> VARIAVEIS <<<--------   
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
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
    
    -- Variáveis para armazenar as informações em XML
    vr_des_xml   CLOB;
    vr_txtcompl  VARCHAR2(32600);
    
    l_offset     NUMBER:=0;
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_txtcompl, pr_des_dados, pr_fecha_xml);
    END;
    
  BEGIN    
    --> Definir transação
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
      
    --> Buscar dados para impressao do Termo de Adesão PF
    pc_obtem_dados_contrato (  pr_cdcooper        => pr_cdcooper  --> Código da Cooperativa 
                              ,pr_cdagenci        => pr_cdagecxa  --> Código da agencia
                              ,pr_nrdcaixa        => pr_nrdcaixa  --> Numero do caixa do operador
                              ,pr_cdoperad        => pr_cdopecxa  --> Código do Operador
                              ,pr_idorigem        => pr_idorigem  --> Identificador de Origem
                              ,pr_nrdconta        => pr_nrdconta  --> Número da Conta
                              ,pr_dtmvtolt        => pr_dtmvtolt  --> Data de Movimento
                              ,pr_nrctrlim        => pr_nrctrlim  --> Contrato
                              ,pr_nmdatela        => pr_nmdatela  --> Nome da Tela
                              ,pr_tab_dados_ctr   => vr_tab_dados_ctr    --> Dados do contrato 
                              ,pr_tab_crapavt     => vr_tab_crapavt     
                              ,pr_tab_bens        => vr_tab_bens  
                              ,pr_tab_assinaturas_ctr => vr_tab_assinaturas_ctr                                  
                              ,pr_cdcritic        => vr_cdcritic         --> Código da crítica
                              ,pr_dscritic        => vr_dscritic);         --> Descrição da crít
                                      
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
      vr_dscritic := 'Termo não foi assinado.';
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
                     '<postoAtendimento>'|| vr_tab_dados_ctr(vr_idxctr).nmresage ||'</postoAtendimento>'||
                     '<contaCorrente>'|| vr_tab_dados_ctr(vr_idxctr).nrdconta ||'</contaCorrente>'||
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
                     '<limite>'|| 'R$ '|| to_char(vr_tab_dados_ctr(vr_idxctr).vllimite,'FM99G999G990D00') ||'</limite>'||
                     '<dadosSolicitacao>'|| vr_tab_dados_ctr(vr_idxctr).dsdadosSolicitacao ||'</dadosSolicitacao>'||
                     '<dadosAprovacao>'|| vr_tab_dados_ctr(vr_idxctr).dsdadosAprovacao ||'</dadosAprovacao>'||
                     '<localEData>'|| vr_tab_dados_ctr(vr_idxctr).nmlocaldata ||'</localEData>'||
                     '<horaAssinatura>'|| vr_tab_assinaturas_ctr(1).hraprovacao ||'</horaAssinatura>'||
                     '<formaPagamento>'|| vr_tab_dados_ctr(vr_idxctr).tpforma_pagamento ||'</formaPagamento>'||
                     '<dataAprovacao>'|| to_char(vr_tab_assinaturas_ctr(1).dtaprovacao,'DD/MM/RRRR') ||'</dataAprovacao>'||
                     '<nomeAprovacao>'|| vr_tab_assinaturas_ctr(1).nmaprovador ||'</nomeAprovacao>'||
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
  
  -- Rotina para geração do Termo de Adesão PJ
  PROCEDURE pc_impres_termo_adesao_pj(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                     ,pr_cdagecxa IN crapage.cdagenci%TYPE  --> Código da agencia
                                     ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                     ,pr_cdopecxa IN crapope.cdoperad%TYPE  --> Código do Operador
                                     ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da Tela
                                     ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                     ,pr_cdprogra IN crapprg.cdprogra%TYPE  --> Codigo do programa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de Movimento
                                     ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato
                                     ,pr_flgerlog IN INTEGER                --> Indicador se deve gerar log(0-nao, 1-sim)
                                     --------> OUT <--------
                                     ,pr_nmarqpdf  OUT VARCHAR2              --> Retornar quantidad de registros                           
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da crítica
    /* .............................................................................

     Programa: pc_impres_termo_adesao_pj
     Sistema : Rotinas referentes ao cartão de crédito
     Sigla   : CRED
     Autor   : Carlos Lima - Supero
     Data    : Abril/2018.                    Ultima atualizacao: 11/04/2018

     Dados referentes ao programa:

     Frequencia:
     Objetivo  : Rotina para geração do Termo de Adesão PJ
     Alteracoes: 
     
    ..............................................................................*/
    
    ----------->>> VARIAVEIS <<<--------   
    -- Variável de críticas
    vr_cdcritic        crapcri.cdcritic%TYPE; --> Cód. Erro
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
    
    -- Variáveis para armazenar as informações em XML
    vr_des_xml   CLOB;
    vr_txtcompl  VARCHAR2(32600);
    
    l_offset     NUMBER:=0;
    
    --------------------------- SUBROTINAS INTERNAS --------------------------
    -- Subrotina para escrever texto na variável CLOB do XML
    PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                             pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
    BEGIN
      gene0002.pc_escreve_xml(vr_des_xml, vr_txtcompl, pr_des_dados, pr_fecha_xml);
    END;
    
  BEGIN    
    --> Definir transação
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
      
    --> Buscar dados para impressao do Termo de Adesão PF
    pc_obtem_dados_contrato (  pr_cdcooper        => pr_cdcooper  --> Código da Cooperativa 
                              ,pr_cdagenci        => pr_cdagecxa  --> Código da agencia
                              ,pr_nrdcaixa        => pr_nrdcaixa  --> Numero do caixa do operador
                              ,pr_cdoperad        => pr_cdopecxa  --> Código do Operador
                              ,pr_idorigem        => pr_idorigem  --> Identificador de Origem
                              ,pr_nrdconta        => pr_nrdconta  --> Número da Conta
                              ,pr_dtmvtolt        => pr_dtmvtolt  --> Data de Movimento
                              ,pr_nrctrlim        => pr_nrctrlim  --> Contrato
                              ,pr_nmdatela        => pr_nmdatela  --> Nome da tela
                              ,pr_tab_dados_ctr   => vr_tab_dados_ctr    --> Dados do contrato 
                              ,pr_tab_crapavt     => vr_tab_crapavt     
                              ,pr_tab_bens        => vr_tab_bens  
                              ,pr_tab_assinaturas_ctr => vr_tab_assinaturas_ctr                                       
                              ,pr_cdcritic        => vr_cdcritic         --> Código da crítica
                              ,pr_dscritic        => vr_dscritic);         --> Descrição da crít
                                      
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
      vr_dscritic := 'Termo não foi assinado.';
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
                   '<postoAtendimento>'|| vr_tab_dados_ctr(vr_idxctr).nmresage ||'</postoAtendimento>'||
                   '<contaCorrente>'|| vr_tab_dados_ctr(vr_idxctr).nrdconta ||'</contaCorrente>'||
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
                   '<limite>'|| 'R$ '|| to_char(vr_tab_dados_ctr(vr_idxctr).vllimite,'FM99G999G990D00') ||'</limite>'||
                   '<formaPagamento>'|| vr_tab_dados_ctr(vr_idxctr).tpforma_pagamento ||'</formaPagamento>'||
                   '<dadosSolicitacao>'|| vr_tab_dados_ctr(vr_idxctr).dsdadosSolicitacao ||'</dadosSolicitacao>'||
                   '<dadosAprovacao>'|| vr_tab_dados_ctr(vr_idxctr).dsdadosAprovacao ||'</dadosAprovacao>'||
                   '<localEData>'|| vr_tab_dados_ctr(vr_idxctr).nmlocaldata ||'</localEData>'||
                   '<spc>'|| vr_tab_dados_ctr(vr_idxctr).indspc ||'</spc>'||
                   '<serasa>'|| vr_tab_dados_ctr(vr_idxctr).indserasa ||'</serasa>'||
                   '<diaPagamento>'|| vr_tab_dados_ctr(vr_idxctr).nrdia_pagamento ||'</diaPagamento>'||
                   '<cdgraupr>'|| vr_tab_dados_ctr(vr_idxctr).cdgraupr ||'</cdgraupr>');
                     
    pc_escreve_xml('<portadores>');
    
    FOR rindex IN 1..vr_tab_crapavt.count LOOP
      pc_escreve_xml('<portador>');
      pc_escreve_xml('<nomeCompleto>'||vr_tab_crapavt(rindex).nmdavali||'</nomeCompleto>'||
                     '<nomeImpresso>'||vr_tab_crapavt(rindex).nmdavali||'</nomeImpresso>'||
                     '<cpf>'||vr_tab_crapavt(rindex).nrcpfcgc||'</cpf>'||
                     '<dataNascimento>'||to_char(vr_tab_crapavt(rindex).dtnascto,'DD/MM/RRRR')||'</dataNascimento>'||
                     '<identidade>'||vr_tab_crapavt(rindex).nrdocava||'</identidade>'||
                     '<emissor>'||vr_tab_crapavt(rindex).cdoeddoc||'</emissor>'||
                     '<ufEmissao>'||vr_tab_crapavt(rindex).cdufddoc||'</ufEmissao>');
      pc_escreve_xml('</portador>');
    END LOOP;
    pc_escreve_xml('</portadores>');
    
    pc_escreve_xml('<assinaturas>');
    
    FOR rindex IN 1..vr_tab_assinaturas_ctr.count LOOP
      pc_escreve_xml('<assinatura>');
      pc_escreve_xml('<nomeAprovacao>'||vr_tab_assinaturas_ctr(rindex).nmaprovador||'</nomeAprovacao>'||
                     '<dataAprovacao>'||to_char(vr_tab_assinaturas_ctr(rindex).dtaprovacao,'DD/MM/RRRR')||'</dataAprovacao>'||
                     '<horaAssinatura>'||vr_tab_assinaturas_ctr(rindex).hraprovacao||'</horaAssinatura>');
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
      
  END pc_impres_termo_adesao_pj;
  
  --> Rotina para geração do Termo de Adesão PF  - Ayllos Web
  PROCEDURE pc_impres_termo_adesao_pf_web(pr_nrdconta   IN crapass.nrdconta%TYPE  --> Número da Conta
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
    Data    : Março/2018                 Ultima atualizacao: 28/03/2018

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
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'pc_gera_impressao'
                                ,pr_action => NULL);

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

      -- Busca a data do sistema
      OPEN  BTCH0001.cr_crapdat(vr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;

      pc_impres_termo_adesao_pf(pr_cdcooper => vr_cdcooper  --> Código da Cooperativa
                               ,pr_cdagecxa => vr_cdagenci  --> Código da agencia
                               ,pr_nrdcaixa => vr_nrdcaixa  --> Numero do caixa do operador
                               ,pr_cdopecxa => vr_cdoperad  --> Código do Operador
                               ,pr_nmdatela => vr_nmdatela  --> Nome da Tela
                               ,pr_idorigem => vr_idorigem  --> Identificador de Origem
                               ,pr_cdprogra => vr_nmdatela  --> Codigo do programa
                               ,pr_nrdconta => pr_nrdconta  --> Número da Conta
                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt  --> Data de Movimento
                               ,pr_nrctrlim => pr_nrctrcrd  --> Contrato
                               ,pr_flgerlog => 1            --> True 
                               --------> OUT <--------
                               ,pr_nmarqpdf => vr_nmarqpdf       --> Retornar quantidad de registros                           
                               ,pr_cdcritic => vr_cdcritic       --> Código da crítica
                               ,pr_dscritic => vr_dscritic);     --> Descrição da crítica

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
  
  --> Rotina para geração do Termo de Adesão PJ  - Ayllos Web
  PROCEDURE pc_impres_termo_adesao_pj_web(pr_nrdconta   IN crapass.nrdconta%TYPE  --> Número da Conta
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
      -- Incluir nome do modulo logado
      GENE0001.pc_informa_acesso(pr_module => 'pc_impres_termo_adesao_pj_web'
                                ,pr_action => NULL);

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

      -- Busca a data do sistema
      OPEN  BTCH0001.cr_crapdat(vr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;

      pc_impres_termo_adesao_pj(pr_cdcooper => vr_cdcooper  --> Código da Cooperativa
                               ,pr_cdagecxa => vr_cdagenci  --> Código da agencia
                               ,pr_nrdcaixa => vr_nrdcaixa  --> Numero do caixa do operador
                               ,pr_cdopecxa => vr_cdoperad  --> Código do Operador
                               ,pr_nmdatela => vr_nmdatela  --> Nome da Tela
                               ,pr_idorigem => vr_idorigem  --> Identificador de Origem
                               ,pr_cdprogra => vr_nmdatela  --> Codigo do programa
                               ,pr_nrdconta => pr_nrdconta  --> Número da Conta
                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt  --> Data de Movimento
                               ,pr_nrctrlim => pr_nrctrcrd  --> Contrato
                               ,pr_flgerlog => 1            --> True 
                               --------> OUT <--------
                               ,pr_nmarqpdf => vr_nmarqpdf       --> Retornar quantidad de registros                           
                               ,pr_cdcritic => vr_cdcritic       --> Código da crítica
                               ,pr_dscritic => vr_dscritic);     --> Descrição da crítica

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
