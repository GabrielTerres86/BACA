CREATE OR REPLACE PACKAGE CECRED.AVAL0001 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : AVAL0001
  --  Sistema  : Rotinas genericas referente a AVALISTAS/PROCURADORES E REPRESENTANTES
  --  Sigla    : AVAL
  --  Autor    : Jean Michel - CECRED
  --  Data     : Abril - 2014.                   Ultima atualizacao: 23/07/2015
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas genericas refente a AVALISTAS/PROCURADORES E REPRESENTANTES

  -- Alteracoes: 23/07/2015 - Rotinas convertidas referentes a tela AVALIS (Jéssica - DB1)
  --
  ---------------------------------------------------------------------------------------------------------------

  --Tipo de Registros de contratos
  TYPE typ_reg_contras IS RECORD --(b1wgen0145tt.i/tt-contras) 
    (nrctremp INTEGER
    ,cdpesqui VARCHAR2(500)
    ,nrdconta INTEGER
    ,nmprimtl VARCHAR2(500)
    ,vldivida VARCHAR2(500)
    ,tpdcontr VARCHAR2(500));
    
  --Tipo de Tabela de Contratos Avalizados
  TYPE typ_tab_contras IS TABLE OF typ_reg_contras INDEX BY PLS_INTEGER;

    --Tipo de Registros de avalistas
  TYPE typ_reg_avalistas IS RECORD --(b1wgen0145tt.i/tt-avalistas) 
    (nrdconta crapavt.nrdconta%TYPE
    ,nmdavali crapavt.nmdavali%TYPE
    ,nrcpfcgc crapavt.nrcpfcgc%TYPE);
    
  --Tipo de Tabela de Avalistas
  TYPE typ_tab_avalistas IS TABLE OF typ_reg_avalistas INDEX BY PLS_INTEGER;

  -- PL Table de mensagem, caso encontre mais que uma conta para o mesmo CPF
  TYPE typ_reg_msgconta IS
    RECORD(msgconta VARCHAR2(500));

  TYPE typ_tab_msgconta IS TABLE OF typ_reg_msgconta INDEX BY VARCHAR2(500);

  -- Rotina referente a consulta de procuradores
  PROCEDURE pc_consulta_proc(pr_tpctrato IN crapavt.tpctrato%TYPE  --> Tipo de Contrato
                            ,pr_nrdconta IN crapavt.nrdconta%TYPE  --> Numero da conta
                            ,pr_nrcpfcgc IN crapavt.nrcpfcgc%TYPE  --> Numero de CPF do procurador
                            ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2);         --> Erros do processo

  PROCEDURE pc_busca_dados_contratos_car(pr_cdcooper IN crapcop.cdcooper%type -->Codigo Cooperativa
                                        ,pr_cdagenci IN crapage.cdagenci%TYPE DEFAULT NULL -->Codigo Agencia
                                        ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE DEFAULT NULL -->Numero Caixa
                                        ,pr_idorigem IN INTEGER DEFAULT NULL  -->Origem Processamento
                                        ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE DEFAULT NULL -->Data Movimento
                                        ,pr_nmdatela IN VARCHAR2 DEFAULT NULL -->Nome da tela
                                        ,pr_cdoperad IN crapnrc.cdoperad%TYPE DEFAULT NULL -->Operador
                                        ,pr_nrdconta IN INTEGER DEFAULT NULL  -->Numero da conta
                                        ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE DEFAULT NULL -->Numero de CPF
                                        ,pr_inproces IN INTEGER DEFAULT NULL  --> Indicador de utilização da tabela de juros
                                        ,pr_nmprimtl OUT VARCHAR2             --> Nome do associado
                                        ,pr_axnrcont OUT INTEGER              -->Numero da conta auxiliar, para apresentar caso só coloque o CPF
                                        ,pr_axnrcpfc OUT NUMBER               -->Numero do CPF auxiliar, para apresentar caso só coloque o numero da conta
                                        ,pr_nmdcampo OUT VARCHAR2    --Nome do Campo
                                        ,pr_des_erro OUT VARCHAR2    --Saida OK/NOK
                                        ,pr_clob_ret OUT CLOB        --Tabela Contratos
                                        ,pr_clob_msg OUT CLOB                 --Tabela Mensagem que retorna a mensagem caso exista mais de uma conta para o CPF
                                        ,pr_cdcritic OUT PLS_INTEGER --Codigo Erro
                                        ,pr_dscritic OUT VARCHAR2);  --Descricao Erro

  /* Rotina referente a consulta de contratos avalizados Modo Web */
  PROCEDURE pc_busca_dados_contratos_web(pr_dtmvtolt IN VARCHAR2 DEFAULT NULL              --Data Movimento
                                        ,pr_nrdconta IN INTEGER DEFAULT NULL               --Numero da conta
                                        ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE DEFAULT NULL --Numero de CPF
                                        ,pr_xmllog   IN VARCHAR2 DEFAULT NULL              --XML com informações de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER                       --Código da crítica
                                        ,pr_dscritic OUT VARCHAR2                          --Descrição da crítica
                                        ,pr_retxml   IN OUT NOCOPY XMLType                 --Arquivo de retorno do XML                                       
                                        ,pr_nmdcampo OUT VARCHAR2                          --Nome do Campo
                                        ,pr_des_erro OUT VARCHAR2);                        --Saida OK/NOK


  /* Rotina referente a consulta de avalistas Modo Caracter */
  PROCEDURE pc_busca_dados_avalista_car (pr_cdcooper IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                        ,pr_cdagenci IN INTEGER DEFAULT NULL  --Codigo Agencia
                                        ,pr_nrdcaixa IN INTEGER DEFAULT NULL  --Numero Caixa
                                        ,pr_cdoperad IN VARCHAR2 DEFAULT NULL --Operador
                                        ,pr_nmdatela IN VARCHAR2 DEFAULT NULL --Nome da tela
                                        ,pr_idorigem IN INTEGER DEFAULT NULL  --Origem Processamento
                                        ,pr_nmdavali IN VARCHAR2 DEFAULT NULL --Nome do Avalista
                                        ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                        ,pr_des_erro OUT VARCHAR2             --Saida OK/NOK
                                        ,pr_clob_ret OUT CLOB                 --Tabela Beneficiarios
                                        ,pr_cdcritic OUT PLS_INTEGER          --Codigo Erro
                                        ,pr_dscritic OUT VARCHAR2);           --Descricao Erro

  /* Rotina referente a consulta de avalistas Modo Web */
  PROCEDURE pc_busca_dados_avalista_web(pr_dtmvtolt IN VARCHAR2 DEFAULT NULL --Data Movimento
                                       ,pr_nmdavali IN VARCHAR2 DEFAULT NULL --Nome do Avalista                                       
                                       ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                       ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2);           --Saida OK/NOK


END AVAL0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.AVAL0001 AS

/* --------------------------------------------------------------------------------------------------------

    Programa : AVAL0001
    Sistema  : Rotinas para a tela AVALIS
    Sigla    : 
    Autor    : Jéssica DB1.
    Data     : xx/2015.                   Ultima atualizacao: 14/07/2016

   Dados referentes ao programa:

   Objetivo  : BO de rotinas para a tela AVALIS

   Alteracoes: 14/07/2016 - #485023 Correção da rotina pc_busca_dados_contratos, que não estava
                            pegando o cpf na busca do ass. MERGE da prod para agosto. (Carlos).
---------------------------------------------------------------------------------------------------------*/

  -- Selecionar os dados da Cooperativa
  CURSOR cr_crapcop (pr_cdcooper IN craptab.cdcooper%TYPE) IS
  SELECT cop.cdcooper
        ,cop.nmrescop
        ,cop.nrtelura
        ,cop.cdbcoctl
        ,cop.cdagectl
        ,cop.dsdircop
    FROM crapcop cop
   WHERE cop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  -- Cursor generico de calendario
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  vr_cdprogra     tbgen_prglog.cdprograma%type := 'AVAL0001';

  /* Rotina referente a consulta de avalistas, procuradores e representantes */
  PROCEDURE pc_consulta_proc(pr_tpctrato IN crapavt.tpctrato%TYPE  --> Tipo de Contrato
                            ,pr_nrdconta IN crapavt.nrdconta%TYPE  --> Numero da conta
                            ,pr_nrcpfcgc IN crapavt.nrcpfcgc%TYPE  --> Numero de CPF do procurador
                            ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN

    /* ................................................................................

     Programa: pc_consulta_proc
     Sistema : Cartoes de Credito - Cooperativa de Credito
     Sigla   : AVAL
     Autor   : Jean Michel
     Data    : Abril/14.                    Ultima atualizacao: 22/04/2014

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina de consulta de avalista, representantes e procuradores.

     Observacao: -----

     Alteracoes: 22/04/2014 - Inclusão de ordenação no cursor cr_crapavt (Jean Michel).

                 25/09/2014 - Incluir alter join no cursor cr_crapavt ( Renato - Supero )
     ..................................................................................*/
    DECLARE

      -- Selecionar os procuradores
      CURSOR cr_crapavt (pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_nrdconta IN crapass.nrdconta%TYPE
                        ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE
                        ,pr_tpctrato IN crapavt.tpctrato%TYPE)IS

      SELECT
        NVL(TRIM(avt.nmdavali), TRIM(ttl.nmextttl)) AS nmdavali
       ,avt.nrcpfcgc AS nrcpfcgc
       ,NVL(TRIM(avt.tpdocava), TRIM(ttl.tpdocttl)) AS tpdocttl
       ,NVL(TRIM(avt.nrdocava), TRIM(ttl.nrdocttl)) AS nrdocttl
       ,NVL(to_char(avt.dtnascto,'dd/mm/yyyy'),to_char(ttl.dtnasttl,'dd/mm/yyyy')) AS dtnasttl
      FROM
        crapavt avt,
        crapttl ttl
      WHERE
            avt.cdcooper = pr_cdcooper
        AND avt.tpctrato = pr_tpctrato
        AND avt.nrdconta = pr_nrdconta
        AND (avt.nrcpfcgc = pr_nrcpfcgc OR pr_nrcpfcgc = 0)
        AND ttl.cdcooper(+) = avt.cdcooper
        AND ttl.nrcpfcgc(+) = avt.nrcpfcgc
        AND ttl.nrdconta(+) = avt.nrdctato
      ORDER BY
        nmdavali;
      rw_crapavt cr_crapavt%ROWTYPE;

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

      -- Variaveis de log
      vr_cdcooper      NUMBER;
      vr_cdoperad      VARCHAR2(100);
      vr_nmdatela      VARCHAR2(100);
      vr_nmeacao       VARCHAR2(100);
      vr_cdagenci      VARCHAR2(100);
      vr_nrdcaixa      VARCHAR2(100);
      vr_idorigem      VARCHAR2(100);

      vr_contador INTEGER := 0;

      BEGIN

        gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);

        OPEN cr_crapavt(vr_cdcooper, pr_nrdconta, pr_nrcpfcgc, pr_tpctrato);

        LOOP
          FETCH cr_crapavt INTO rw_crapavt;

          -- SAI DO LOOP QUANDO CHEGAR AO FIM DOS REGISTROS
          EXIT WHEN cr_crapavt%NOTFOUND;

          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nmdavali', pr_tag_cont => rw_crapavt.nmdavali, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrcpfcgc', pr_tag_cont => rw_crapavt.nrcpfcgc, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'tpdocttl', pr_tag_cont => rw_crapavt.tpdocttl, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrdocttl', pr_tag_cont => rw_crapavt.nrdocttl, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtnasttl', pr_tag_cont => rw_crapavt.dtnasttl, pr_des_erro => vr_dscritic);

          vr_contador := vr_contador + 1;

        END LOOP;

        CLOSE cr_crapavt;

    EXCEPTION
      WHEN vr_exc_saida THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.

        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

        ROLLBACK;
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em consulta de procuradores: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.

        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

        ROLLBACK;
    END;


  END pc_consulta_proc;

  /* Rotina referente a consulta de contratos avalizados */
  PROCEDURE pc_busca_dados_contratos(pr_cdcooper IN crapcop.cdcooper%type -->Codigo Cooperativa
                                    ,pr_cdagenci IN crapage.cdagenci%TYPE DEFAULT NULL -->Codigo Agencia
                                    ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE DEFAULT NULL -->Numero Caixa
                                    ,pr_idorigem IN INTEGER DEFAULT NULL  -->Origem Processamento
                                    ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE DEFAULT NULL -->Data Movimento
                                    ,pr_nmdatela IN VARCHAR2 DEFAULT NULL -->Nome da tela
                                    ,pr_cdoperad IN crapnrc.cdoperad%TYPE DEFAULT NULL -->Operador
                                    ,pr_nrdconta IN INTEGER DEFAULT NULL  -->Numero da conta
                                    ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE DEFAULT NULL -->Numero de CPF
                                    ,pr_inproces IN INTEGER DEFAULT NULL  --> Indicador de utilização da tabela de juros
                                    ,pr_nmprimtl OUT VARCHAR2    --> Nome do associado
                                    ,pr_axnrcont OUT INTEGER     -->Numero da conta auxiliar, para apresentar caso só coloque o CPF
                                    ,pr_axnrcpfc OUT NUMBER      -->Numero do CPF auxiliar, para apresentar caso só coloque o numero da conta
                                    ,pr_tab_msgconta OUT aval0001.typ_tab_msgconta --> Tabela que retorna a mensagem caso exista mais de uma conta para o CPF                                    
                                    ,pr_nmdcampo OUT VARCHAR2    -->Nome do campo com erro
                                    ,pr_tab_contras OUT aval0001.typ_tab_contras --Tabela Contratos
                                    ,pr_tab_erro OUT gene0001.typ_tab_erro -->Tabela Erros
                                    ,pr_des_erro OUT VARCHAR2) IS -->Erros do processo
     /*---------------------------------------------------------------------------------------------------------------
     Programa: pc_busca_dados_contratos       Antiga: b1wgen0145.p/Busca_Dados
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED

     Autor   : Jéssica Laverde Gracino(DB1)
     Data    : 12/06/2015                        Ultima atualizacao: 14/02/2019

     Dados referentes ao programa:

     Frequencia: Diario (on-line)
     Objetivo  : Rotina referente a consulta de contratos avalizados

     Alteracoes: 12/06/2015 - Conversao Progress >> Oracle (PLSQL) - Jéssica (DB1)
                 14/02/2019 - Ajuste retorno para busca de contratos com tpcrtato <> 1
                              Ana - Envolti - INC0032752
    ---------------------------------------------------------------------------------------------------------------*/

    ------------------------------- CURSORES ---------------------------------
    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.nmrescop
          ,cop.nmextcop
          ,cop.cdcooper
          ,cop.dsdircop
          ,cop.cdagesic
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;  

    --Selecionar informacoes dos associados
    CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE,
                       pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT crapass.nrdconta
            ,crapass.nrcpfcgc
            ,crapass.dtdemiss
            ,crapass.nmprimtl
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    --Selecionar informacoes dos associados
    CURSOR cr_crapass2 (pr_cdcooper IN crapass.cdcooper%TYPE,
                        pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE) IS
      SELECT crapass.nrdconta
            ,crapass.nrcpfcgc
            ,crapass.dtdemiss
            ,crapass.nmprimtl
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrcpfcgc = pr_nrcpfcgc
         AND crapass.dtdemiss IS NULL;
    rw_crapass2 cr_crapass2%ROWTYPE;

    --Selecionar informacoes dos associados 
    CURSOR cr_crapass3 (pr_cdcooper IN crapass.cdcooper%TYPE,
                        pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE) IS
      SELECT crapass.nrdconta
            ,crapass.nrcpfcgc
            ,crapass.dtdemiss
            ,crapass.nmprimtl
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrcpfcgc = pr_nrcpfcgc;
    rw_crapass3 cr_crapass3%ROWTYPE;
        
    --Seleciona informacoes do cadastro de avalistas
    CURSOR cr_crapavl (pr_cdcooper IN crapavl.cdcooper%TYPE,
                       pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT crapavl.nrdconta
            ,crapavl.nrctaavd
            ,crapavl.tpctrato
            ,crapavl.nrctravd
        FROM crapavl
       WHERE crapavl.cdcooper = pr_cdcooper
         AND crapavl.nrdconta = pr_nrdconta
         AND crapavl.tpctrato = 1; -- desconto de títulos
    rw_crapavl cr_crapavl%ROWTYPE;

    --Seleciona informacoes do cadastro de avalistas
    CURSOR cr_crapavl1 (pr_cdcooper IN crapavl.cdcooper%TYPE,
                        pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT crapavl.nrdconta
            ,crapavl.nrctaavd
            ,crapavl.tpctrato
            ,crapavl.nrctravd
        FROM crapavl
       WHERE crapavl.cdcooper = pr_cdcooper
         AND crapavl.nrdconta = pr_nrdconta
         AND (crapavl.tpctrato = 2   -- desconto de cheques
          OR crapavl.tpctrato = 3   -- cheque especial
          OR crapavl.tpctrato = 8); -- desconto de títulos
    rw_crapavl1 cr_crapavl1%ROWTYPE;

    --Seleciona informações do cadastro de emprestimos
    CURSOR cr_crapepr (pr_cdcooper IN crapepr.cdcooper%TYPE,
                       pr_nrdconta IN crapavl.nrctaavd%TYPE,
                       pr_nrctremp IN crapavl.nrctravd%TYPE) IS
      SELECT crapepr.nrdconta
            ,crapepr.nrctremp
            ,crapepr.dtmvtolt
            ,crapepr.inliquid
            ,crapepr.cdagenci
            ,crapepr.cdbccxlt
            ,crapepr.nrdolote
            ,crapepr.inprejuz
        FROM crapepr
       WHERE crapepr.cdcooper = pr_cdcooper    
         AND crapepr.nrdconta = pr_nrdconta
         AND crapepr.nrctremp = pr_nrctremp;
    rw_crapepr cr_crapepr%ROWTYPE;

    -- Cursor genérico de calendário
    rw_crapdat BTCH0001.CR_CRAPDAT%ROWTYPE;

    -- Cursor sobre a tabela de limite de credito
    CURSOR cr_craplim (pr_cdcooper IN craplim.cdcooper%TYPE,
                       pr_nrdconta IN crapavl.nrctaavd%TYPE,
                       pr_tpctrlim IN INTEGER,
                       pr_nrctrlim IN crapavl.nrctravd%TYPE) IS
      SELECT craplim.insitlim
            ,craplim.nrdconta
            ,craplim.nrctrlim
            ,craplim.tpctrlim
            ,craplim.dtinivig
            ,craplim.vllimite
        FROM craplim
       WHERE craplim.cdcooper = pr_cdcooper
         AND craplim.nrdconta = pr_nrdconta
         AND craplim.tpctrlim = pr_tpctrlim
         AND craplim.nrctrlim = pr_nrctrlim;
    rw_craplim cr_craplim%ROWTYPE;

    -- Cursor sobre a tabela de limite de credito
    CURSOR cr_craplim1 (pr_cdcooper IN craplim.cdcooper%TYPE,
                        pr_nrdconta IN rw_craplim.nrdconta%TYPE,
                        pr_nrctrlim IN rw_craplim.nrctrlim%TYPE) IS
      SELECT craplim.insitlim
            ,craplim.nrdconta
            ,craplim.nrctrlim
            ,craplim.tpctrlim
            ,craplim.dtinivig
            ,craplim.vllimite
        FROM craplim
       WHERE craplim.cdcooper = pr_cdcooper
         AND craplim.nrdconta = pr_nrdconta
         AND craplim.tpctrlim = 2
         AND craplim.nrctrlim = pr_nrctrlim;
    rw_craplim1 cr_craplim1%ROWTYPE;


    CURSOR cr_crapcdc (pr_cdcooper IN crapcdc.cdcooper%TYPE,
                       pr_nrdconta IN craplim.nrdconta%TYPE,
                       pr_nrctrlim IN craplim.nrctrlim%TYPE,
                       pr_tpctrlim IN craplim.tpctrlim%TYPE) IS
      SELECT crapcdc.cdcooper
            ,crapcdc.nrdconta
            ,crapcdc.nrctrlim
            ,crapcdc.tpctrlim
            ,crapcdc.dtmvtolt
            ,crapcdc.cdagenci
            ,crapcdc.cdbccxlt
            ,crapcdc.nrdolote
        FROM crapcdc
       WHERE crapcdc.cdcooper = pr_cdcooper
         AND crapcdc.nrdconta = pr_nrdconta
         AND crapcdc.nrctrlim = pr_nrctrlim
         AND crapcdc.tpctrlim = pr_tpctrlim;
    rw_crapcdc cr_crapcdc%ROWTYPE;

    -- Borderôs de desconto de cheques
    CURSOR cr_crapbdc (pr_cdcooper IN crapbdc.cdcooper%TYPE,
                       pr_nrdconta IN craplim.nrdconta%TYPE,
                       pr_nrctrlim IN craplim.nrctrlim%TYPE) IS
      SELECT crapbdc.nrborder
            ,crapbdc.nrdconta
            ,crapbdc.nrctrlim
        FROM crapbdc
       WHERE crapbdc.cdcooper = pr_cdcooper
         AND crapbdc.nrdconta = pr_nrdconta
         AND crapbdc.nrctrlim = pr_nrctrlim;
    rw_crapbdc cr_crapbdc%ROWTYPE; 

    -- Desconto de cheques
    CURSOR cr_crapcdb (pr_cdcooper IN crapcdb.cdcooper%TYPE,
                       pr_nrdconta IN crapbdc.nrdconta%TYPE,
                       pr_nrborder IN crapbdc.nrborder%TYPE,
                       pr_nrctrlim IN crapbdc.nrctrlim%TYPE) IS
      SELECT /*+ index (crapcdb crapcdb##crapcdb7)*/
             crapcdb.vlcheque
            ,crapcdb.nrdconta
            ,crapcdb.nrborder
            ,crapcdb.nrctrlim
            ,crapcdb.insitchq
            ,crapcdb.dtlibera
        FROM crapcdb
       WHERE crapcdb.cdcooper = pr_cdcooper
         AND crapcdb.nrdconta = pr_nrdconta
         AND crapcdb.nrborder = pr_nrborder
         AND crapcdb.nrctrlim = pr_nrctrlim
         AND crapcdb.insitchq = 2                  
         AND crapcdb.dtlibera > rw_crapdat.dtmvtolt;
    rw_crapcdb cr_crapcdb%ROWTYPE;
    
    -- Borderos de Desconto de Titulos
    CURSOR cr_crapbdt IS
      SELECT craptdb.nrctrlim,
             craptdb.nrborder,
             craptdb.nrdconta,
             craptdb.vltitulo,
             crapbdt.dtmvtolt,
             crapbdt.cdagenci,
             crapbdt.cdbccxlt,
             crapbdt.nrdolote,
             craptdb.dtlibbdt,
             craptdb.cdoperad
        FROM crapbdt,
             craptdb
       WHERE craptdb.cdcooper = crapbdt.cdcooper
         AND craptdb.nrdconta = crapbdt.nrdconta
         AND crapbdt.nrctrlim = crapbdt.nrctrlim
         AND (craptdb.cdcooper  = crapbdt.cdcooper
         AND  craptdb.nrdconta  = crapbdt.nrdconta 
         AND  craptdb.nrborder  = crapbdt.nrborder 
         AND  craptdb.insittit =  4)
          OR (craptdb.cdcooper  = crapbdt.cdcooper 
         AND  craptdb.nrdconta  = crapbdt.nrdconta
         AND  craptdb.nrborder  = crapbdt.nrborder 
         AND  craptdb.insittit = 2                 
         AND  craptdb.dtdpagto = rw_crapdat.dtmvtolt);
    rw_crapbdt cr_crapbdt%ROWTYPE;    

    -- Cursor para busca de avalistas terceiros
    CURSOR cr_crapavt (pr_cdcooper IN crapavt.cdcooper%TYPE,
                       pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE) IS 
      SELECT crapavt.nrcpfcgc
            ,crapavt.nrctremp
            ,crapavt.tpctrato
            ,crapavt.nrdconta
            ,crapavt.nmdavali
        FROM crapavt
       WHERE crapavt.cdcooper = pr_cdcooper AND
             crapavt.nrcpfcgc = pr_nrcpfcgc AND
             crapavt.tpctrato IN( 1   -- emprestimo
                                 ,2   -- desconto de cheques
                                 ,3   -- cheque especial
                                 ,4
                                 ,8); -- desconto de títulos
    rw_crapavt cr_crapavt%ROWTYPE; 

    -- Buscar informações da proposta do cartão de credito
    CURSOR cr_crawcrd (pr_cdcooper IN crawcrd.cdcooper%TYPE
                      ,pr_nrdconta IN crapavt.nrdconta%TYPE
                      ,pr_nrctrcrd IN crapavt.nrctremp%TYPE) IS
      SELECT crawcrd.nrdconta
            ,crawcrd.nrctrcrd
            ,crawcrd.dtmvtolt
            ,crawcrd.cdcooper
            ,crawcrd.cdadmcrd
            ,crawcrd.nrcrcard
            ,crawcrd.tpcartao
            ,crawcrd.cdlimcrd  
            ,crawcrd.insitcrd
            ,crawcrd.cdagenci
            ,crawcrd.cdbccxlt
            ,crawcrd.nrdolote        
        FROM crawcrd
       WHERE crawcrd.cdcooper = pr_cdcooper
         AND crawcrd.nrdconta = pr_nrdconta
         AND crawcrd.nrctrcrd = pr_nrctrcrd;
    rw_crawcrd cr_crawcrd%ROWTYPE; 

    -- Tabela de limites de cartao de credito e dias de debito
    CURSOR cr_craptlc (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_cdadmcrd IN crawcrd.cdadmcrd%TYPE
                      ,pr_tpcartao IN crawcrd.tpcartao%TYPE
                      ,pr_cdlimcrd IN crawcrd.cdlimcrd%TYPE) IS
      SELECT craptlc.vllimcrd
            ,craptlc.cdadmcrd
            ,craptlc.tpcartao
            ,craptlc.cdlimcrd
            ,craptlc.dddebito
        FROM craptlc
       WHERE craptlc.cdcooper = pr_cdcooper
         AND craptlc.cdadmcrd = pr_cdadmcrd -- Codigo da administradora (1-Credicard, 2-Bradesco Visa)
         AND craptlc.tpcartao = pr_tpcartao -- Tipo de cartao (0, 1-nacional, 2-internacional, 3-gold)
         AND craptlc.cdlimcrd = pr_cdlimcrd -- Codigo do limite de credito.
         AND craptlc.dddebito = 0; -- Dia do debito em conta-corrente.
    rw_craptlc cr_craptlc%ROWTYPE;

    ------------------------------- VARIAVEIS ---------------------------------   
        
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000); 
    vr_des_reto VARCHAR2(3);
        
    --Variaveis Locais    
    vr_inpessoa  INTEGER;
    vr_nrdconta  INTEGER;
    vr_nrcpfcgc  VARCHAR2(100);
    vr_nmprimtl  VARCHAR2(100);
    vr_regexist  BOOLEAN;
    vr_tpctrlim  INTEGER;  

    --tabelas de memoria
    vr_tab_tot_descontos dsct0001.typ_tab_tot_descontos;
    vr_tab_erro gene0001.typ_tab_erro;
    
    --Variaveis referente ao cadastro de emprestimo
    vr_epr_cdpesqui VARCHAR2(4000);
    vr_epr_nmprimtl VARCHAR2(4000);
    vr_epr_nrctremp INTEGER;
    vr_epr_nrdconta INTEGER;
    vr_epr_tpdcontr VARCHAR2(4000);
    vr_epr_vldivida VARCHAR2(4000);    

    vr_vlsdeved NUMBER; --> Valor de saldo devedor
    vr_qtprecal NUMBER; --> Quantidade calculada das parcelas
    vr_vldscchq NUMBER;
    vr_vldsctit NUMBER;
    vr_vltotpre NUMBER;

    vr_retornvl  VARCHAR2(3):= 'NOK';
    
    --Variaveis de Indice
    vr_index PLS_INTEGER;
    vr_index_conta VARCHAR2(200);
    vr_index_msgconta VARCHAR2(200);
    vr_index_tot_desc PLS_INTEGER;
   
    vr_stsnrcal  BOOLEAN;
        
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;                                       
    vr_exc_saida EXCEPTION; 

    --INC0032752
    vr_idprglog     tbgen_prglog.idprglog%TYPE := 0;
    vr_dsparame     VARCHAR2(4000);

    ------------------------------TEMP TABLES-------------------------------   
    -- PL Table de associados - antiga: b1wgen0145tt.i/w_contas
    TYPE typ_reg_conta IS
      RECORD(nrdconta crapass.nrdconta%TYPE);

    TYPE typ_tab_conta IS TABLE OF typ_reg_conta INDEX BY PLS_INTEGER;

    vr_tab_conta  typ_tab_conta;
    ------------------------------------------------------------------------

    BEGIN
      -- Inclui nome do modulo logado - 14/02/2019 - INC0032752
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'AVAL0001.pc_busca_dados_contratos'); 

      vr_dsparame := ' - pr_cdcooper:'||pr_cdcooper
                    ||', pr_cdagenci:'||pr_cdagenci
                    ||', pr_nrdcaixa:'||pr_nrdcaixa
                    ||', pr_idorigem:'||pr_idorigem
                    ||', pr_dtmvtolt:'||pr_dtmvtolt
                    ||', pr_nmdatela:'||pr_nmdatela
                    ||', pr_cdoperad:'||pr_cdoperad
                    ||', pr_nrdconta:'||pr_nrdconta
                    ||', pr_nrcpfcgc:'||pr_nrcpfcgc
                    ||', pr_inproces:'||pr_inproces;
      
      --Inicializar Variaveis
      vr_cdcritic := 0;                         
      vr_dscritic := NULL;
      vr_regexist := FALSE;
      vr_vlsdeved := 0;
      vr_vltotpre := 0;
      vr_qtprecal := 0;
      vr_vldscchq := 0;
      vr_vldsctit := 0;
      vr_index_conta := 0;
      vr_index := 0;
      vr_index_msgconta := 0;
      vr_index_tot_desc := 0;
      vr_nrdconta := pr_nrdconta;
      
      --Limpar tabela dados
      vr_tab_conta.DELETE;
              
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
      
      FETCH cr_crapcop INTO rw_crapcop;
      
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        -- Busca critica
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        
       RAISE vr_exc_erro;
       
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
  
      --Verificar parametros
      IF vr_nrdconta = 0  AND
         pr_nrcpfcgc = 0 THEN
        
        vr_dscritic:= 'Informe Conta ou CPF';
        pr_nmdcampo:= 'nrdconta';
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      END IF;

      IF  vr_nrdconta > 0 THEN

        -- Validar o digito da conta
        IF NOT gene0005.fn_valida_digito_verificador(pr_nrdconta => vr_nrdconta) THEN
          -- 008 - Digito errado.
          vr_cdcritic := 8;
          -- Busca critica
          vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
          pr_nmdcampo:= 'nrdconta';
          -- Sair do programa
          RAISE vr_exc_erro;
        END IF;
        -- Inclui nome do modulo logado - 14/02/2019 - INC0032752
        GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'AVAL0001.pc_busca_dados_contratos'); 
       
      END IF; -- IF  par_nrdconta > 0

      IF pr_nrdconta > 0 THEN
        
        OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                         pr_nrdconta => pr_nrdconta);
        
        FETCH cr_crapass INTO rw_crapass;
        
        -- Se não encontrar registro
        IF cr_crapass%NOTFOUND THEN                     
                            
          -- Fechar o cursor pois haverá raise
          CLOSE cr_crapass;
          
          -- Montar mensagem de critica
          vr_cdcritic := 9;
          -- Busca critica
          vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
          pr_nmdcampo:= 'nrdconta';
               
          RAISE vr_exc_erro; 
        ELSE
          -- Apenas fechar o cursor
          CLOSE cr_crapass;
        END IF;

        vr_nrdconta := rw_crapass.nrdconta; 
        vr_nrcpfcgc := rw_crapass.nrcpfcgc;
        
      ELSE
        
        OPEN cr_crapass2 (pr_cdcooper => pr_cdcooper,
                          pr_nrcpfcgc => pr_nrcpfcgc);
        
        FETCH cr_crapass2 INTO rw_crapass2;
        
        -- Se encontrar registro
        IF cr_crapass2%FOUND THEN            
          vr_nrdconta := rw_crapass2.nrdconta; 
          vr_nrcpfcgc := rw_crapass2.nrcpfcgc;
        ELSE
          vr_nrdconta := 0;
          vr_nrcpfcgc := 0;
        END IF;

        CLOSE cr_crapass2;
        
      END IF;
      
      IF vr_nrdconta > 0 THEN

        --Acessar primeiro registro da tabela de memoria da conta
                
        FOR rw_crapass3 IN cr_crapass3(pr_cdcooper, vr_nrcpfcgc) LOOP
        
          vr_index_conta:= vr_index_conta + 1;
          
          vr_tab_conta(vr_index_conta).nrdconta:= rw_crapass3.nrdconta; 

        END LOOP;         

        --Buscar Primeiro contrato
        vr_index_conta:= vr_tab_conta.FIRST;    
         
        WHILE vr_index_conta IS NOT NULL LOOP
        
          IF vr_tab_conta(vr_index_conta).nrdconta <> vr_nrdconta THEN
              
            vr_index_msgconta := vr_index_msgconta + 1;                

            pr_tab_msgconta(vr_index_msgconta).msgconta := 'CPF tambem na conta = ' || vr_tab_conta(vr_index_conta).nrdconta;
                
          END IF;

          --Proximo Registro
          vr_index_conta:= vr_tab_conta.NEXT(vr_index_conta);

        END LOOP;
        
        vr_nmprimtl := rw_crapass.nmprimtl;
        
        --Buscar Primeiro contrato
        vr_index_conta:= vr_tab_conta.FIRST;    
         
        WHILE vr_index_conta IS NOT NULL LOOP                  
                      
          --Leitura no cadastro de avalistas
          FOR rw_crapavl IN cr_crapavl(pr_cdcooper, vr_tab_conta(vr_index_conta).nrdconta) LOOP
        
            OPEN cr_crapepr (pr_cdcooper => pr_cdcooper,
                             pr_nrdconta => rw_crapavl.nrctaavd,
                             pr_nrctremp => rw_crapavl.nrctravd);
              
            FETCH cr_crapepr INTO rw_crapepr;
                
            -- Se encontrar registro
            IF cr_crapepr%FOUND THEN                     
              IF rw_crapepr.inliquid <> 0 THEN
                CLOSE cr_crapepr;
                CONTINUE;
              END IF;

              vr_epr_cdpesqui := to_char(rw_crapepr.dtmvtolt,'DD/MM/YYYY')
                                 || '-' ||
                                 LPad(rw_crapepr.cdagenci, 3, '0')      || '-' ||    
                                 LPad(rw_crapepr.cdbccxlt, 3, '0')      || '-' ||
                                 LPad(rw_crapepr.nrdolote, 6, '0');
                                     
            ELSE
              CLOSE cr_crapepr;
              CONTINUE;
            END IF;

            CLOSE cr_crapepr; 

            vr_regexist := TRUE;   

            --Os contratos que caem aqui mostram certo na tela

            OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                             pr_nrdconta => rw_crapavl.nrctaavd);
              
            FETCH cr_crapass INTO rw_crapass;
                
            -- Se encontrar registro
            IF cr_crapass%FOUND THEN                     
              vr_epr_nmprimtl := rw_crapass.nmprimtl; 
            ELSE
              vr_epr_nmprimtl := 'ASSOC.NAO CADAST';
            END IF;

            CLOSE cr_crapass;

            vr_epr_nrctremp := rw_crapavl.nrctravd;
            vr_epr_nrdconta := rw_crapavl.nrctaavd;
            vr_epr_tpdcontr := 'EP';

            -- Leitura do calendário da cooperativa
            OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
            FETCH btch0001.cr_crapdat
             INTO rw_crapdat;
            -- Se não encontrar
            IF btch0001.cr_crapdat%NOTFOUND THEN
              -- Fechar o cursor pois efetuaremos raise
              CLOSE btch0001.cr_crapdat;
              -- Montar mensagem de critica
              vr_cdcritic := 1;
              vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
              RAISE vr_exc_erro;
            ELSE
              -- Apenas fechar o cursor
              CLOSE btch0001.cr_crapdat;
            END IF;
                
            vr_vlsdeved := 0;

            -- Trazer o valor de todas as prestacoes de emprestimo
            EMPR0001.pc_saldo_devedor_epr(pr_cdcooper => pr_cdcooper
                                         ,pr_cdagenci => pr_cdagenci
                                         ,pr_nrdcaixa => pr_nrdcaixa
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nmdatela => pr_nmdatela
                                         ,pr_idorigem => pr_idorigem
                                         ,pr_nrdconta => rw_crapepr.nrdconta
                                         ,pr_idseqttl => 1
                                         ,pr_rw_crapdat => rw_crapdat
                                         ,pr_nrctremp => rw_crapepr.nrctremp
                                         ,pr_cdprogra => 'AVAL0001'
                                         ,pr_inusatab => FALSE
                                         ,pr_flgerlog => 'N'
                                         ,pr_vlsdeved => vr_vlsdeved
                                         ,pr_vltotpre => vr_vltotpre
                                         ,pr_qtprecal => vr_qtprecal
                                         ,pr_des_reto => vr_des_reto
                                         ,pr_tab_erro => vr_tab_erro);
            -- Se retornou erro
            IF vr_des_reto <> 'OK' THEN
              -- Buscar da tabela de erro
              IF vr_tab_erro.count > 0 THEN
                vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
              ELSE
                vr_cdcritic := 1051;
                vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)
                               ||' EMPR0001.pc_saldo_devedor_epr.'; --Erro na pck empr0001
              END IF;
              -- Gerar exceção
              RAISE vr_exc_erro;
            END IF;
            -- Inclui nome do modulo logado - 14/02/2019 - INC0032752
            GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'AVAL0001.pc_busca_dados_contratos'); 

            IF rw_crapepr.inprejuz = 1 THEN
              vr_epr_vldivida := 'Prejuizo';
            ELSE
              vr_epr_vldivida := Lpad(to_char(vr_vlsdeved,'FM999G999G999D90'),12,' ');
            END IF;
                
            vr_index := vr_index + 1;             

            pr_tab_contras(vr_index).nrctremp := vr_epr_nrctremp;
            pr_tab_contras(vr_index).cdpesqui := vr_epr_cdpesqui;
            pr_tab_contras(vr_index).nrdconta := vr_epr_nrdconta;
            pr_tab_contras(vr_index).nmprimtl := vr_epr_nmprimtl;
            pr_tab_contras(vr_index).tpdcontr := vr_epr_tpdcontr;
            pr_tab_contras(vr_index).vldivida := vr_epr_vldivida;

          END LOOP; --rw_crapavl tpcontrato = 1

          --INC0032752
          --Verifica se encontrou algum contrato - tpctrato = 1
          IF vr_epr_nrctremp IS NULL THEN
             vr_regexist := FALSE;
          END IF;              

          --Proximo Registro
          vr_index_conta:= vr_tab_conta.NEXT(vr_index_conta);

        END LOOP;  --vr_index_conta is not null

        --Buscar Primeiro contrato
        vr_index_conta:= vr_tab_conta.FIRST;    
         
--         
        WHILE vr_index_conta IS NOT NULL LOOP

          FOR rw_crapavl1 IN cr_crapavl1(pr_cdcooper, vr_tab_conta(vr_index_conta).nrdconta) LOOP

            IF rw_crapavl1.tpctrato  = 2 THEN   /* Descto Cheques */
              vr_tpctrlim := 2;
              vr_epr_tpdcontr := 'DC';
            ELSIF rw_crapavl1.tpctrato  = 3 THEN
              vr_tpctrlim := 1;       /* Cheque Especial */ 
              vr_epr_tpdcontr := 'LM';
            ELSE
              vr_tpctrlim := 3;       /* Descto Titulos  */ 
              vr_epr_tpdcontr := 'DT';
            END IF;

            OPEN cr_craplim (pr_cdcooper => pr_cdcooper,
                             pr_nrdconta => rw_crapavl1.nrctaavd,
                             pr_tpctrlim => vr_tpctrlim,
                             pr_nrctrlim => rw_crapavl1.nrctravd);
          
            FETCH cr_craplim INTO rw_craplim;
                
            -- Se encontrar registro
            IF cr_craplim%FOUND THEN
                                  
              /* Somente p/ Cheque Espec */
              IF rw_craplim.insitlim <> 2 AND rw_craplim.tpctrlim = 1 THEN
                CLOSE cr_craplim;
                CONTINUE; 
              END IF;
              CLOSE cr_craplim;
                  
              OPEN cr_crapcdc (pr_cdcooper => pr_cdcooper,
                               pr_nrdconta => rw_craplim.nrdconta,
                               pr_nrctrlim => rw_craplim.nrctrlim,
                               pr_tpctrlim => rw_craplim.tpctrlim);
          
              FETCH cr_crapcdc INTO rw_crapcdc;
                  
              -- Se encontrar registro
              IF cr_crapcdc%FOUND THEN                     
                vr_epr_cdpesqui := to_char(rw_crapcdc.dtmvtolt,'DD/MM/YYYY')
                                   || '-' ||
                                   LPad(rw_crapcdc.cdagenci,3, '0')      || '-' ||
                                   LPad(rw_crapcdc.cdbccxlt,3, '0')      || '-' ||
                                   LPad(rw_crapcdc.nrdolote,6, '0'); 
              ELSE
                vr_epr_cdpesqui := to_char(rw_craplim.dtinivig,'DD/MM/YYYY') || ' - ' ||
                                   to_char(rw_craplim.nrctrlim);
              END IF;

              CLOSE cr_crapcdc;
    
            ELSE
              CLOSE cr_craplim;
              CONTINUE;
            END IF;

           --INC0032752 - comentado e tratado em outros pontos - vr_regexist := TRUE;              

            OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                             pr_nrdconta => rw_crapavl1.nrctaavd);
              
            FETCH cr_crapass INTO rw_crapass;
                
            -- Se encontrar registro
            IF cr_crapass%FOUND THEN                     
              vr_epr_nmprimtl := rw_crapass.nmprimtl; 
            ELSE
              vr_epr_nmprimtl := 'ASSOC.NAO CADAST';
            END IF;

            CLOSE cr_crapass;

            vr_epr_nrctremp := rw_crapavl1.nrctravd;
            vr_epr_nrdconta := rw_crapavl1.nrctaavd;

            IF rw_crapavl1.tpctrato = 2 THEN
              
              vr_vldscchq := 0;
              vr_tpctrlim := 2;

              OPEN cr_craplim1(pr_cdcooper => pr_cdcooper,
                               pr_nrdconta => rw_craplim.nrdconta,
                               pr_nrctrlim => rw_craplim.nrctrlim);
            
              FETCH cr_craplim1 INTO rw_craplim1;
                  
              -- Se encontrar registro
              IF cr_craplim1%FOUND THEN

                FOR rw_crapbdc IN cr_crapbdc(pr_cdcooper,
                                             rw_craplim.nrdconta,
                                             rw_craplim.nrctrlim) LOOP 
                    
                  FOR rw_crapcdb IN cr_crapcdb(pr_cdcooper,
                                               rw_crapbdc.nrdconta,
                                               rw_crapbdc.nrborder,
                                               rw_crapbdc.nrctrlim) LOOP

                    vr_vldscchq := vr_vldscchq + rw_crapcdb.vlcheque;

                  END LOOP; -- rw_crapcdb    
                    
                END LOOP; --for rw_crapbdc

              ELSE
                CLOSE cr_craplim1;
              END IF; -- IF cr_craplim1

              CLOSE cr_craplim1;
                  
              vr_vlsdeved := vr_vldscchq;
                                  
              IF vr_vldscchq = 0 THEN 
                CONTINUE;
              END IF;
    
              vr_epr_vldivida := Lpad(to_char(vr_vldscchq,'FM999G999G999D90'),12,' ');

            ELSIF rw_crapavl1.tpctrato = 8 THEN
                    
              vr_vldsctit := 0;

              -- Leitura do calendário da cooperativa
              OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
              FETCH btch0001.cr_crapdat
               INTO rw_crapdat;
              -- Se não encontrar
              IF btch0001.cr_crapdat%NOTFOUND THEN
                -- Fechar o cursor pois efetuaremos raise
                CLOSE btch0001.cr_crapdat;
                -- Montar mensagem de critica
                vr_cdcritic := 1;
                vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
                RAISE vr_exc_erro;
              ELSE
                -- Apenas fechar o cursor
                CLOSE btch0001.cr_crapdat;
              END IF;
                  
              -- Trazer o valor de todas as prestacoes de emprestimo
              DSCT0001.pc_busca_total_descto_lim(pr_cdcooper => pr_cdcooper
                                                ,pr_cdagenci => 0
                                                ,pr_nrdcaixa => 0
                                                ,pr_cdoperad => pr_cdoperad 
                                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                ,pr_nrdconta => rw_craplim.nrdconta
                                                ,pr_idseqttl => 1
                                                ,pr_idorigem => 1
                                                ,pr_nmdatela => 'AVALIS'
                                                ,pr_nrctrlim => rw_craplim.nrctrlim
                                                ,pr_tab_tot_descontos => vr_tab_tot_descontos --Tabela que retorna total desconto dos titulos
                                                ,pr_cdcritic => vr_cdcritic
                                                ,pr_dscritic => vr_dscritic
                                                ,pr_tab_erro => vr_tab_erro);

              -- Se retornou erro
              IF vr_des_reto <> 'OK' THEN
                -- Buscar da tabela de erro
                IF vr_tab_erro.count > 0 THEN
                  vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
                ELSE
                  vr_cdcritic := 1051;
                  vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)
                                 ||' DSCT0001.pc_busca_total_descto_lim.'; --Erro na pck DSCT0001
                END IF;
                -- Gerar exceção
                RAISE vr_exc_erro;
              ELSE
                -- Inclui nome do modulo logado - 14/02/2019 - INC0032752
                GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'AVAL0001.pc_busca_dados_contratos'); 

                --Buscar Primeiro valor
                vr_index_tot_desc := vr_tab_tot_descontos.FIRST;
                WHILE vr_index_tot_desc IS NOT NULL LOOP

                  vr_vldsctit := vr_tab_tot_descontos(vr_index_tot_desc).vltotdsc;

                  --Proximo Registro
                  vr_index_tot_desc:= vr_tab_tot_descontos.NEXT(vr_index_tot_desc);

                END LOOP;
              END IF;                             

              IF vr_vldsctit = 0 THEN 
                CONTINUE;
              END IF;

              vr_epr_vldivida := Lpad(to_char(vr_vldsctit,'FM999G999G999D90'),12,' ');                                                           

            ELSE
              vr_epr_vldivida := Lpad(to_char(rw_craplim.vllimite,'FM999G999G999D90'),12,' ');
            END IF; 

            vr_index := vr_index + 1; 

            pr_tab_contras(vr_index).nrctremp := vr_epr_nrctremp;  
            pr_tab_contras(vr_index).cdpesqui := vr_epr_cdpesqui;
            pr_tab_contras(vr_index).nrdconta := vr_epr_nrdconta;
            pr_tab_contras(vr_index).nmprimtl := vr_epr_nmprimtl;
            pr_tab_contras(vr_index).tpdcontr := vr_epr_tpdcontr;
            pr_tab_contras(vr_index).vldivida := vr_epr_vldivida;

          END LOOP; --rw_crapavl1                
            
          --INC0032752
          --Verifica se encontrou algum contrato tpctrato = 2,3,8
          IF vr_epr_nrctremp IS NULL THEN
             vr_regexist := FALSE;
          END IF;              
          
          --Proximo Registro
          vr_index_conta:= vr_tab_conta.NEXT(vr_index_conta);

        END LOOP;
        
        IF vr_regexist = FALSE THEN

          -- Montar mensagem de critica
          vr_cdcritic := 11;
          -- Busca critica
          vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
          pr_nmdcampo:= 'nrdconta'; 

          RAISE vr_exc_erro;

        END IF;

    END IF; -- IF pr_nrdconta > 0

    IF pr_nrcpfcgc > 0 THEN    
      
      --Validar o cpf/cnpj
      gene0005.pc_valida_cpf_cnpj (pr_nrcalcul => pr_nrcpfcgc
                                  ,pr_stsnrcal => vr_stsnrcal
                                  ,pr_inpessoa => vr_inpessoa);

      IF vr_stsnrcal = FALSE THEN

        -- Montar mensagem de critica
        vr_cdcritic := 27;
        -- Busca critica
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        pr_nmdcampo:= 'nrcpfcgc';

        RAISE vr_exc_erro;
     
      END IF;
      -- Inclui nome do modulo logado - 14/02/2019 - INC0032752
      GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'AVAL0001.pc_busca_dados_contratos'); 

      -- seleciona os avalistas do associado
      OPEN cr_crapavt(pr_cdcooper => pr_cdcooper
                     ,pr_nrcpfcgc => pr_nrcpfcgc);
      FETCH cr_crapavt INTO rw_crapavt;

      IF cr_crapavt%FOUND THEN

        IF vr_nmprimtl = ' ' OR vr_nmprimtl IS NULL THEN
          vr_nmprimtl := rw_crapavt.nmdavali;
        END IF;
        
      END IF;

      -- verifica se existe lançamentos no cadastro de avalistas para o associado
      IF cr_crapavt%FOUND THEN
        
        --Fecha o cursor
        CLOSE cr_crapavt;
          
        -- Verifica se o contrato é de emprestimo (1-Emprestimo)
        IF rw_crapavt.tpctrato = 1 THEN

          --Leitura no cadastro de avalistas
          FOR rw_crapavt IN cr_crapavt(pr_cdcooper, pr_nrcpfcgc) LOOP
        
            OPEN cr_crapepr (pr_cdcooper => pr_cdcooper,
                             pr_nrdconta => rw_crapavt.nrdconta,
                             pr_nrctremp => rw_crapavt.nrctremp);
              
            FETCH cr_crapepr INTO rw_crapepr;
                
            -- Se encontrar registro
            IF cr_crapepr%FOUND THEN                     
              IF rw_crapepr.inliquid <> 0 THEN
                CLOSE cr_crapepr;
                CONTINUE;
              END IF;

              vr_epr_cdpesqui := to_char(rw_crapepr.dtmvtolt,'DD/MM/YYYY')
                                 || '-' ||
                                 LPad(rw_crapepr.cdagenci, 3, '0')      || '-' ||    
                                 LPad(rw_crapepr.cdbccxlt, 3, '0')      || '-' ||
                                 LPad(rw_crapepr.nrdolote, 6, '0');
                                       
            ELSE
              CLOSE cr_crapepr;
              CONTINUE;
            END IF;

            CLOSE cr_crapepr; 

            vr_regexist := TRUE;   

            OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                             pr_nrdconta => rw_crapavt.nrdconta);
                
            FETCH cr_crapass INTO rw_crapass;
                  
            -- Se encontrar registro
            IF cr_crapass%FOUND THEN                     
              vr_epr_nmprimtl := rw_crapass.nmprimtl; 
            ELSE
              vr_epr_nmprimtl := 'ASSOC.NAO CADAST';
            END IF;

            CLOSE cr_crapass;

            vr_epr_tpdcontr := 'EP';
            vr_epr_nrctremp := rw_crapavt.nrctremp;
            vr_epr_nrdconta := rw_crapavt.nrdconta;

            -- Leitura do calendário da cooperativa
            OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
            
            FETCH btch0001.cr_crapdat INTO rw_crapdat;
            
            -- Se não encontrar
            IF btch0001.cr_crapdat%NOTFOUND THEN
              -- Fechar o cursor pois efetuaremos raise
              CLOSE btch0001.cr_crapdat;
              -- Montar mensagem de critica
              vr_cdcritic := 1;
              vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
              RAISE vr_exc_erro;
            ELSE
              -- Apenas fechar o cursor
              CLOSE btch0001.cr_crapdat;
            END IF;

            -- Trazer o valor de todas as prestacoes de emprestimo
            EMPR0001.pc_saldo_devedor_epr(pr_cdcooper => pr_cdcooper
                                         ,pr_cdagenci => pr_cdagenci
                                         ,pr_nrdcaixa => pr_nrdcaixa
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_nmdatela => pr_nmdatela
                                         ,pr_idorigem => pr_idorigem
                                         ,pr_nrdconta => rw_crapepr.nrdconta
                                         ,pr_idseqttl => 1
                                         ,pr_rw_crapdat => rw_crapdat
                                         ,pr_nrctremp => rw_crapepr.nrctremp
                                         ,pr_cdprogra => 'AVAL0001'
                                         ,pr_inusatab => FALSE
                                         ,pr_flgerlog => 'N'
                                         ,pr_vlsdeved => vr_vlsdeved
                                         ,pr_vltotpre => vr_vltotpre
                                         ,pr_qtprecal => vr_qtprecal
                                         ,pr_des_reto => vr_des_reto
                                         ,pr_tab_erro => vr_tab_erro);
            -- Se retornou erro
            IF vr_des_reto <> 'OK' THEN
              -- Buscar da tabela de erro
              IF vr_tab_erro.count > 0 THEN
                vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
              ELSE
                vr_cdcritic := 1051;
                vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)
                               ||' EMPR0001.pc_saldo_devedor_epr.'; --Erro na pck empr0001
              END IF;
              -- Gerar exceção
              RAISE vr_exc_erro;
            END IF;
            -- Inclui nome do modulo logado - 14/02/2019 - INC0032752
            GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'AVAL0001.pc_busca_dados_contratos'); 

            IF rw_crapepr.inprejuz = 1 THEN
              vr_epr_vldivida := 'Prejuizo';
            ELSE
              vr_epr_vldivida := Lpad(to_char(vr_vlsdeved,'FM999G999G999D90'),12,' ');
            END IF;

            vr_index := vr_index + 1;

            pr_tab_contras(vr_index).nrctremp := vr_epr_nrctremp;  
            pr_tab_contras(vr_index).cdpesqui := vr_epr_cdpesqui;
            pr_tab_contras(vr_index).nrdconta := vr_epr_nrdconta;
            pr_tab_contras(vr_index).nmprimtl := vr_epr_nmprimtl;
            pr_tab_contras(vr_index).tpdcontr := vr_epr_tpdcontr;
            pr_tab_contras(vr_index).vldivida := vr_epr_vldivida;

          END LOOP; --rw_crapavt

          --INC0032752
          --Verifica se encontrou algum contrato tpctrato = 1
          IF vr_epr_nrctremp IS NULL THEN
             vr_regexist := FALSE;
          END IF;              

        -- verifica as demais situações
        ELSIF rw_crapavt.tpctrato = 2 OR   -- desconto de cheques
              rw_crapavt.tpctrato = 3 OR   -- cheque especial
              rw_crapavt.tpctrato = 8 THEN -- desconto de titulos

          FOR rw_crapavt IN cr_crapavt(pr_cdcooper, pr_nrcpfcgc) LOOP

            IF rw_crapavt.tpctrato  = 2 THEN   /* Descto Cheques */
              vr_tpctrlim := 2;
              vr_epr_tpdcontr := 'DC';
            ELSIF rw_crapavt.tpctrato  = 8 THEN
              vr_tpctrlim := 3;       /* Descto Titulos */
              vr_epr_tpdcontr := 'DT';
            ELSE
              vr_tpctrlim := 1;       /* Cheque Especial */ 
              vr_epr_tpdcontr := 'LM';
            END IF;

            OPEN cr_craplim (pr_cdcooper => pr_cdcooper,
                             pr_nrdconta => rw_crapavt.nrdconta,
                             pr_tpctrlim => vr_tpctrlim,
                             pr_nrctrlim => rw_crapavt.nrctremp);
          
            FETCH cr_craplim INTO rw_craplim;
                
            -- Se encontrar registro
            IF cr_craplim%FOUND THEN       
                
              /* Somente p/ Cheque Espec */
              IF rw_craplim.insitlim <> 2 AND rw_craplim.tpctrlim = 1 THEN
                CONTINUE; 
              END IF;  
                  
              OPEN cr_crapcdc (pr_cdcooper => pr_cdcooper,
                               pr_nrdconta => rw_craplim.nrdconta,
                               pr_nrctrlim => rw_craplim.nrctrlim,
                               pr_tpctrlim => rw_craplim.tpctrlim);
          
              FETCH cr_crapcdc INTO rw_crapcdc;
                  
              -- Se encontrar registro
              IF cr_crapcdc%FOUND THEN                     
                vr_epr_cdpesqui := to_char(rw_crapcdc.dtmvtolt,'DD/MM/YYYY')
                                   || '-' ||
                                   LPad(rw_crapcdc.cdagenci,3, '0')      || '-' ||
                                   LPad(rw_crapcdc.cdbccxlt,3, '0')      || '-' ||
                                   LPad(rw_crapcdc.nrdolote,6, '0'); 
              ELSE
                vr_epr_cdpesqui := to_char(rw_craplim.dtinivig,'DD/MM/YYYY') || ' - ' ||
                                   to_char(rw_craplim.nrctrlim);
              END IF; /* IF  %found craplim */

              CLOSE cr_crapcdc;
    
            ELSE
              CLOSE cr_craplim;
              CONTINUE;
            END IF;           

            OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                             pr_nrdconta => rw_crapavt.nrdconta);
              
            FETCH cr_crapass INTO rw_crapass;
                
            -- Se encontrar registro
            IF cr_crapass%FOUND THEN                     
              vr_epr_nmprimtl := rw_crapass.nmprimtl; 
            ELSE
              vr_epr_nmprimtl := 'ASSOC.NAO CADAST';
            END IF;

            CLOSE cr_crapass;

            vr_epr_nrctremp := rw_crapavt.nrctremp;
            vr_epr_nrdconta := rw_crapavt.nrdconta;

            IF rw_crapavt.tpctrato = 2 THEN
              
              vr_vldscchq := 0;

              OPEN cr_craplim (pr_cdcooper => pr_cdcooper,
                               pr_nrdconta => vr_nrdconta,
                               pr_tpctrlim => 2,
                               pr_nrctrlim => rw_crapavt.nrctremp);
            
              FETCH cr_craplim INTO rw_craplim;
                  
              -- Se encontrar registro
              IF cr_craplim%FOUND THEN

                FOR rw_crapbdc IN cr_crapbdc(pr_cdcooper,
                                             vr_nrdconta,
                                             rw_craplim.nrctrlim) LOOP 
                    
                  FOR rw_crapcdb IN cr_crapcdb(pr_cdcooper,
                                               vr_nrdconta,
                                               rw_crapbdc.nrborder,
                                               rw_crapbdc.nrctrlim) LOOP

                    vr_vldscchq := vr_vldscchq + rw_crapcdb.vlcheque;

                  END LOOP; -- rw_crapcdb    
                    
                END LOOP; --for rw_crapbdc

              ELSE
                CLOSE cr_craplim;
              END IF; -- IF cr_craplim
                                                
              IF vr_vldscchq = 0 THEN 
                CONTINUE;
              END IF;
    
              vr_epr_vldivida := Lpad(to_char(vr_vldscchq,'FM999G999G999D90'),12,' ');

            ELSIF rw_crapavt.tpctrato = 8 THEN
                    
              vr_vldsctit := 0;
              
              -- Trazer o valor de todas as prestacoes de emprestimo
              DSCT0001.pc_busca_total_descto_lim(pr_cdcooper => pr_cdcooper
                                                ,pr_cdagenci => 0
                                                ,pr_nrdcaixa => 0
                                                ,pr_cdoperad => pr_cdoperad 
                                                ,pr_dtmvtolt => pr_dtmvtolt
                                                ,pr_nrdconta => vr_nrdconta
                                                ,pr_idseqttl => 1
                                                ,pr_idorigem => 1
                                                ,pr_nmdatela => 'AVALIS'
                                                ,pr_nrctrlim => rw_craplim.nrctrlim
                                                ,pr_tab_tot_descontos => vr_tab_tot_descontos --Tabela que retorna total desconto dos titulos
                                                ,pr_cdcritic => vr_cdcritic
                                                ,pr_dscritic => vr_dscritic
                                                ,pr_tab_erro => vr_tab_erro);
              -- Se retornou erro
              IF vr_des_reto <> 'OK' THEN
                -- Buscar da tabela de erro
                IF vr_tab_erro.count > 0 THEN
                  vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
                ELSE
                  vr_cdcritic := 1051;
                  vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic)
                                 ||' DSCT0001.pc_busca_total_descto_lim.'; --Erro na pck DSCT0001
                END IF;
                -- Gerar exceção
                RAISE vr_exc_erro;
              END IF;                           
              -- Inclui nome do modulo logado - 14/02/2019 - INC0032752
              GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => 'AVAL0001.pc_busca_dados_contratos'); 

              IF vr_vldsctit = 0 THEN 
                CONTINUE;
              END IF;

              vr_epr_vldivida := Lpad(to_char(vr_vldsctit,'FM999G999G999D90'),12,' ');

            ELSE
              vr_epr_vldivida := Lpad(to_char(rw_craplim.vllimite,'FM999G999G999D90'),12,' ');
            END IF;  

            vr_index := vr_index + 1;

            pr_tab_contras(vr_index).nrctremp := vr_epr_nrctremp;  
            pr_tab_contras(vr_index).cdpesqui := vr_epr_cdpesqui;
            pr_tab_contras(vr_index).nrdconta := vr_epr_nrdconta;
            pr_tab_contras(vr_index).nmprimtl := vr_epr_nmprimtl;
            pr_tab_contras(vr_index).tpdcontr := vr_epr_tpdcontr;
            pr_tab_contras(vr_index).vldivida := vr_epr_vldivida;

          END LOOP; --rw_crapavt

          --INC0032752
          --Verifica se encontrou algum contrato tpctrato = 2,3,8
          IF vr_epr_nrctremp IS NULL THEN
             vr_regexist := FALSE;
          END IF;              

        ELSE

          FOR rw_crapavt IN cr_crapavt(pr_cdcooper, pr_nrcpfcgc) LOOP
            
            OPEN cr_crawcrd (pr_cdcooper => pr_cdcooper,
                             pr_nrdconta => rw_crapavt.nrdconta,
                             pr_nrctrcrd => rw_crapavt.nrctremp);
            
            FETCH cr_crawcrd INTO rw_crawcrd;
                  
            -- Se encontrar registro
            IF cr_crawcrd%FOUND THEN
              IF rw_crawcrd.insitcrd <> 4 THEN
                CONTINUE;
              END IF;

              vr_epr_cdpesqui := to_char(rw_crawcrd.dtmvtolt,'DD/MM/YYYY')
                                 || '-' ||
                                 LPad(rw_crawcrd.cdagenci, 3, '0')      || '-' ||    
                                 LPad(rw_crawcrd.cdbccxlt, 3, '0')      || '-' ||
                                 LPad(rw_crawcrd.nrdolote, 6, '0');

            ELSE
              CONTINUE;
            END IF; -- IF cr_crawcrd
              
            CLOSE cr_crawcrd;

            vr_regexist := TRUE;

            OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                             pr_nrdconta => rw_crapavt.nrdconta);
                  
            FETCH cr_crapass INTO rw_crapass;
                    
            -- Se encontrar registro
            IF cr_crapass%FOUND THEN                     
              vr_epr_nmprimtl := rw_crapass.nmprimtl; 
            ELSE
              vr_epr_nmprimtl := 'ASSOC.NAO CADAST';
            END IF;

            CLOSE cr_crapass;

            vr_epr_nrctremp := rw_crapavt.nrctremp;
            vr_epr_nrdconta := rw_crapavt.nrdconta;
            vr_epr_tpdcontr := ' ';

            OPEN cr_craptlc (pr_cdcooper => pr_cdcooper,
                             pr_cdadmcrd => rw_crawcrd.cdadmcrd,
                             pr_tpcartao => rw_crawcrd.tpcartao,
                             pr_cdlimcrd => rw_crawcrd.cdlimcrd);
                  
            FETCH cr_craptlc INTO rw_craptlc;
                    
            -- Se encontrar registro
            IF cr_craptlc%FOUND THEN

              vr_epr_vldivida := Lpad(to_char(rw_craptlc.vllimcrd,'FM999G999G999D90'),12,' ');
              
            ELSE
              CLOSE cr_craptlc;
            END IF;

            CLOSE cr_craptlc;

            vr_epr_tpdcontr := 'CR';

            vr_index := vr_index + 1;

            pr_tab_contras(vr_index).nrctremp := vr_epr_nrctremp;  
            pr_tab_contras(vr_index).cdpesqui := vr_epr_cdpesqui;
            pr_tab_contras(vr_index).nrdconta := vr_epr_nrdconta;
            pr_tab_contras(vr_index).nmprimtl := vr_epr_nmprimtl;
            pr_tab_contras(vr_index).tpdcontr := vr_epr_tpdcontr;
            pr_tab_contras(vr_index).vldivida := vr_epr_vldivida;
  
          END LOOP; --for rw_crapavt

          --INC0032752
          --Verifica se encontrou algum contrato tpctrato <> 1,2,3,8
          IF vr_epr_nrctremp IS NULL THEN
             vr_regexist := FALSE;
          END IF;              

        END IF; --IF rw_crapavt.tpctrato = 1 THEN
        
      ELSE
        -- Fecha o cursor
        CLOSE cr_crapavt;
        
      END IF; --IF cr_crapavt%FOUND THEN 
      
      IF  vr_regexist = FALSE THEN

        -- Montar mensagem de critica
        vr_cdcritic := 11;
        -- Busca critica
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        pr_nmdcampo:= 'nrcpfcgc';
            
        -- Gerar exceção
        RAISE vr_exc_erro;            

      END IF;           
 
    END IF; --IF pr_nrcpfcgc > 0

    pr_nmprimtl := vr_nmprimtl;
    pr_axnrcont := vr_nrdconta;
    pr_axnrcpfc := vr_nrcpfcgc;

    -- Retira nome do modulo logado - 14/02/2019 - INC0032752
    GENE0001.pc_set_modulo(pr_module => NULL ,pr_action => NULL); 

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro:= vr_retornvl;
        
        -- Nao gravar se rotina for chamada pela analise de credito
        IF pr_nmdatela <> tela_analise_credito.pr_nmdatela THEN

          --> Registra o erro - INC0032752
          CECRED.pc_log_programa(pr_dstiplog      => 'E', 
                                 pr_cdcooper      => pr_cdcooper, 
                                 pr_tpocorrencia  => 1, 
                                 pr_cdprograma    => vr_cdprogra, 
                                 pr_tpexecucao    => 3, --Online
                                 pr_cdcriticidade => 1,
                                 pr_cdmensagem    => vr_cdcritic,    
                                 pr_dsmensagem    => vr_dscritic||vr_dsparame,
                                 pr_idprglog      => vr_idprglog,
                                 pr_nmarqlog      => NULL);

        END IF;                             
        
        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
                             
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        -- Chamar rotina de gravação de erro
        vr_cdcritic := 9999;
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic)||'COBR0007.pc_busca_dados_contratos. '||SQLERRM;

        --> Registra o erro - INC0032752
        CECRED.pc_log_programa(pr_dstiplog      => 'E', 
                               pr_cdcooper      => pr_cdcooper, 
                               pr_tpocorrencia  => 2, 
                               pr_cdprograma    => vr_cdprogra, 
                               pr_tpexecucao    => 3, --Online
                               pr_cdcriticidade => 2,
                               pr_cdmensagem    => vr_cdcritic,    
                               pr_dsmensagem    => vr_dscritic||vr_dsparame,
                               pr_idprglog      => vr_idprglog,
                               pr_nmarqlog      => NULL);

        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);


  END pc_busca_dados_contratos;

  /* Rotina referente a consulta de contratos avalizados Modo Caracter */
  PROCEDURE pc_busca_dados_contratos_car (pr_cdcooper IN crapcop.cdcooper%type -->Codigo Cooperativa
                                         ,pr_cdagenci IN crapage.cdagenci%TYPE DEFAULT NULL -->Codigo Agencia
                                         ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE DEFAULT NULL -->Numero Caixa
                                         ,pr_idorigem IN INTEGER DEFAULT NULL  -->Origem Processamento
                                         ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE DEFAULT NULL -->Data Movimento
                                         ,pr_nmdatela IN VARCHAR2 DEFAULT NULL -->Nome da tela
                                         ,pr_cdoperad IN crapnrc.cdoperad%TYPE DEFAULT NULL -->Operador
                                         ,pr_nrdconta IN INTEGER DEFAULT NULL  -->Numero da conta
                                         ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE DEFAULT NULL -->Numero de CPF
                                         ,pr_inproces IN INTEGER DEFAULT NULL  --> Indicador de utilização da tabela de juros
                                         ,pr_nmprimtl OUT VARCHAR2             --> Nome do associado
                                         ,pr_axnrcont OUT INTEGER              -->Numero da conta auxiliar, para apresentar caso só coloque o CPF
                                         ,pr_axnrcpfc OUT NUMBER               -->Numero do CPF auxiliar, para apresentar caso só coloque o numero da conta
                                         ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                         ,pr_des_erro OUT VARCHAR2             --Saida OK/NOK
                                         ,pr_clob_ret OUT CLOB                 --Tabela Contratos
                                         ,pr_clob_msg OUT CLOB                 --Tabela Mensagem que retorna a mensagem caso exista mais de uma conta para o CPF
                                         ,pr_cdcritic OUT PLS_INTEGER          --Codigo Erro
                                         ,pr_dscritic OUT VARCHAR2) IS         --Descricao Erro
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa: pc_busca_dados_contratos_car       Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : Jéssica Laverde Gracino(DB1)
    Data    : 22/06/2015                        Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Rotina referente a consulta de contratos avalizados modo Caracter

    Alteracoes: 22/06/2015 - Desenvolvimento - Jéssica (DB1)

	            10/06/2019 - Evitar registro de "sujeira" na tabela de logs.
                             Este log nao e relevante para a analise de credito (tela unica).
                             Bug 22300 - PRJ438 - Gabriel Marcos (Mouts).
                 
  ---------------------------------------------------------------------------------------------------------------*/

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 

    --Tabelas de Memoria
    vr_tab_erro gene0001.typ_tab_erro;
    vr_tab_contras aval0001.typ_tab_contras;
    vr_tab_msgconta aval0001.typ_tab_msgconta;

    --Variaveis Arquivo Dados
    vr_dstexto VARCHAR2(32767);
    vr_dstexto_msg VARCHAR2(32767);
    vr_string  VARCHAR2(32767);
    vr_string_msgconta VARCHAR2(32767);
        
    --Variaveis de Indice
    vr_index PLS_INTEGER;
    vr_index_msgconta PLS_INTEGER;
    
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;                                       
        
    BEGIN
      
      --limpar tabela erros
      vr_tab_erro.DELETE;
      
      --Limpar tabela dados
      vr_tab_contras.DELETE;
      vr_tab_msgconta.DELETE;
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= null;
      
      --Consultar Contratos Avalizados
      aval0001.pc_busca_dados_contratos (pr_cdcooper => pr_cdcooper  --Codigo Cooperativa
                                        ,pr_cdagenci => pr_cdagenci  --Codigo Agencia
                                        ,pr_nrdcaixa => pr_nrdcaixa  --Numero Caixa
                                        ,pr_idorigem => pr_idorigem  --Origem Processamento
                                        ,pr_dtmvtolt => pr_dtmvtolt  --Data Movimento
                                        ,pr_nmdatela => pr_nmdatela  --Nome da tela
                                        ,pr_cdoperad => pr_cdoperad  --Operador
                                        ,pr_nrdconta => pr_nrdconta  --Numero da conta do associado
                                        ,pr_nrcpfcgc => pr_nrcpfcgc  --Numero CPF/CNPJ
                                        ,pr_inproces => pr_inproces  --Indicador de utilização da tabela de juros
                                        ,pr_nmprimtl => pr_nmprimtl  --Nome do associado
                                        ,pr_axnrcont => pr_axnrcont  --Numero da conta auxiliar, para apresentar caso só coloque o CPF
                                        ,pr_axnrcpfc => pr_axnrcpfc  --Numero do CPF auxiliar, para apresentar caso só coloque o numero da conta
                                        ,pr_tab_msgconta => vr_tab_msgconta --Tabela que retorna a mensagem caso exista mais de uma conta para o CPF                                        
                                        ,pr_nmdcampo => pr_nmdcampo  --Nome do Campo
                                        ,pr_tab_contras => vr_tab_contras --Tabela Contratos
                                        ,pr_tab_erro => vr_tab_erro  --Tabela Erros
                                        ,pr_des_erro => vr_des_reto); --Saida OK/NOK

      --Se Ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        
        --Se possuir dados na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          --Mensagem erro
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          --Mensagem erro
          vr_dscritic:= 'Erro ao executar a aval0001.pc_busca_dados_contratos.';
        END IF;    
        
        --Levantar Excecao
        RAISE vr_exc_erro;

      ELSE

        --Montar CLOB
        IF vr_tab_msgconta.COUNT > 0 THEN
          
          -- Criar documento XML
          dbms_lob.createtemporary(pr_clob_msg, TRUE); 
          dbms_lob.open(pr_clob_msg, dbms_lob.lob_readwrite);
          
          -- Insere o cabeçalho do XML 
          gene0002.pc_escreve_xml(pr_xml            => pr_clob_msg 
                                 ,pr_texto_completo => vr_dstexto_msg 
                                 ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root>');
           
          --Buscar Primeira mensagem
          vr_index_msgconta:= vr_tab_msgconta.FIRST;
          
          --Percorrer todos as mensagens
          WHILE vr_index_msgconta IS NOT NULL LOOP
            vr_string_msgconta := '<msg>'||
                                  '<msgconta>'||NVL(TO_CHAR(vr_tab_msgconta(vr_index_msgconta).msgconta),' ')|| '</msgconta>'|| 
                                  '</msg>';
                        
            -- Escrever no XML
            gene0002.pc_escreve_xml(pr_xml            => pr_clob_msg 
                                   ,pr_texto_completo => vr_dstexto_msg 
                                   ,pr_texto_novo     => vr_string_msgconta
                                   ,pr_fecha_xml      => FALSE);   
                                                      
            --Proximo Registro
            vr_index_msgconta:= vr_tab_msgconta.NEXT(vr_index_msgconta);
            
          END LOOP;  
          
          -- Encerrar a tag raiz 
          gene0002.pc_escreve_xml(pr_xml            => pr_clob_msg 
                                 ,pr_texto_completo => vr_dstexto_msg 
                                 ,pr_texto_novo     => '</root>' 
                                 ,pr_fecha_xml      => TRUE);
                                 
        END IF;
                      
      END IF;
                                          
      --Montar CLOB
      IF vr_tab_contras.COUNT > 0 THEN
        
        -- Criar documento XML
        dbms_lob.createtemporary(pr_clob_ret, TRUE); 
        dbms_lob.open(pr_clob_ret, dbms_lob.lob_readwrite);
        
        -- Insere o cabeçalho do XML 
        gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret 
                               ,pr_texto_completo => vr_dstexto 
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root>');
         
        --Buscar Primeiro contrato
        vr_index:= vr_tab_contras.FIRST;
        
        --Percorrer todos os contratos
        WHILE vr_index IS NOT NULL LOOP
          vr_string:= '<aval>'||
                      '<nrctremp>'||NVL(TO_CHAR(vr_tab_contras(vr_index).nrctremp),'0')|| '</nrctremp>'|| 
                      '<cdpesqui>'||NVL(TO_CHAR(vr_tab_contras(vr_index).cdpesqui),' ')|| '</cdpesqui>'|| 
                      '<nrdconta>'||NVL(TO_CHAR(vr_tab_contras(vr_index).nrdconta),'0')|| '</nrdconta>'|| 
                      '<nmprimtl>'||NVL(TO_CHAR(vr_tab_contras(vr_index).nmprimtl),' ')|| '</nmprimtl>'|| 
                      '<vldivida>'||NVL(TO_CHAR(vr_tab_contras(vr_index).vldivida),' ')|| '</vldivida>'|| 
                      '<tpdcontr>'||NVL(TO_CHAR(vr_tab_contras(vr_index).tpdcontr),' ')|| '</tpdcontr>'||
                      '</aval>';
                      
          -- Escrever no XML
          gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret 
                                 ,pr_texto_completo => vr_dstexto 
                                 ,pr_texto_novo     => vr_string
                                 ,pr_fecha_xml      => FALSE);   
                                                    
          --Proximo Registro
          vr_index:= vr_tab_contras.NEXT(vr_index);
          
        END LOOP;  
        
        -- Encerrar a tag raiz 
        gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret 
                               ,pr_texto_completo => vr_dstexto 
                               ,pr_texto_novo     => '</root>' 
                               ,pr_fecha_xml      => TRUE);
                               
      END IF;
                                                     
      --Retorno
      pr_des_erro:= 'OK';       
    
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro:= 'NOK';
        
        --Erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;        
          
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        pr_cdcritic:= 0;
        -- Chamar rotina de gravação de erro
        pr_dscritic:= 'Erro na aval0001.pc_busca_dados_contratos_car --> '|| SQLERRM;

  END pc_busca_dados_contratos_car;  

  /* Rotina referente a consulta de contratos avalizados Modo Web */
  PROCEDURE pc_busca_dados_contratos_web(pr_dtmvtolt IN VARCHAR2 DEFAULT NULL              --Data Movimento
                                        ,pr_nrdconta IN INTEGER DEFAULT NULL               --Numero da conta
                                        ,pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE DEFAULT NULL --Numero de CPF
                                        ,pr_xmllog   IN VARCHAR2 DEFAULT NULL              --XML com informações de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER                       --Código da crítica
                                        ,pr_dscritic OUT VARCHAR2                          --Descrição da crítica
                                        ,pr_retxml   IN OUT NOCOPY XMLType                --Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2                          --Nome do Campo
                                        ,pr_des_erro OUT VARCHAR2) IS                      --Saida OK/NOK
                                       
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa: pc_busca_dados_contratos_web      Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : Jéssica Laverde Gracino(DB1)
    Data    : 22/06/2015                        Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Rotina referente a consulta de contratos avalizados modo Web

    Alteracoes: 22/06/2015 - Desenvolvimento - Jéssica (DB1)
                 
  ---------------------------------------------------------------------------------------------------------------*/

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 
    
    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    --Tabela de contratos
    vr_tab_contras aval0001.typ_tab_contras;
    --Tabela de Mensagem
    vr_tab_msgconta aval0001.typ_tab_msgconta;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_inproces INTEGER;
    
    vr_nmprimtl VARCHAR2(500);                          
    vr_axnrcont INTEGER;                           
    vr_axnrcpfc NUMBER;
    
    --Variaveis Arquivo Dados
    vr_dtmvtolt DATE;
    vr_auxconta PLS_INTEGER:= 0;
    vr_auxconta_msg PLS_INTEGER:= 0;
    vr_auxconta_saida PLS_INTEGER:= 0;    
    
    --Variaveis de Indice
    vr_index PLS_INTEGER;
    vr_index_msgconta PLS_INTEGER;
    
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;                                       
    
    BEGIN
      
      --limpar tabela erros
      vr_tab_erro.DELETE;
      
      --Limpar tabela dados
      vr_tab_contras.DELETE;
      vr_tab_msgconta.DELETE;
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= null;
      
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
      
      BEGIN                                                  
        --Pega a data de movimento e converte para "DATE"
        vr_dtmvtolt:= to_date(pr_dtmvtolt,'DD/MM/YYYY'); 
                      
      EXCEPTION
        WHEN OTHERS THEN
          
          --Monta mensagem de critica
          vr_dscritic := 'Data de movimento invalida.';
          
          --Gera exceção
          RAISE vr_exc_erro;
      END;
      
      --Consultar Contratos Avalizados
      aval0001.pc_busca_dados_contratos (pr_cdcooper => vr_cdcooper  --Codigo Cooperativa
                                        ,pr_cdagenci => vr_cdagenci  --Codigo Agencia
                                        ,pr_nrdcaixa => vr_nrdcaixa  --Numero Caixa
                                        ,pr_idorigem => vr_idorigem  --Origem Processamento
                                        ,pr_dtmvtolt => vr_dtmvtolt  --Data Movimento
                                        ,pr_nmdatela => vr_nmdatela  --Nome da tela
                                        ,pr_cdoperad => vr_cdoperad  --Operador
                                        ,pr_nrdconta => pr_nrdconta  --Numero da conta do associado
                                        ,pr_nrcpfcgc => pr_nrcpfcgc  --Numero CPF/CNPJ
                                        ,pr_inproces => vr_inproces  --Indicador de utilização da tabela de juros
                                        ,pr_nmprimtl => vr_nmprimtl  --Nome do associado
                                        ,pr_axnrcont => vr_axnrcont  --Numero da conta auxiliar, para apresentar caso só coloque o CPF
                                        ,pr_axnrcpfc => vr_axnrcpfc  --Numero do CPF auxiliar, para apresentar caso só coloque o numero da conta
                                        ,pr_tab_msgconta => vr_tab_msgconta --Tabela que retorna a mensagem caso exista mais de uma conta para o CPF                                        
                                        ,pr_nmdcampo => pr_nmdcampo  --Nome do Campo
                                        ,pr_tab_contras => vr_tab_contras --Tabela Contratos
                                        ,pr_tab_erro => vr_tab_erro  --Tabela Erros
                                        ,pr_des_erro => vr_des_reto); --Saida OK/NOK      

      --Se Ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        
        --Se possuir erro na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          --Mensagem Erro
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE  
          --Mensagem Erro
          vr_dscritic:= 'Erro na aval0001.pc_busca_dados_contratos.';
        END IF;  
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      END IF;
                                          
      --Montar CLOB
      IF vr_tab_contras.COUNT > 0 THEN
                  
        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');       
                
        --Buscar Primeiro contrato
        vr_index:= vr_tab_contras.FIRST;
        
        --Percorrer todos os contratos
        WHILE vr_index IS NOT NULL LOOP

          -- Insere as tags dos campos da PLTABLE de contratos
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'dados2', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'dados2', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrctremp', pr_tag_cont => TO_CHAR(vr_tab_contras(vr_index).nrctremp), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'cdpesqui', pr_tag_cont => TO_CHAR(vr_tab_contras(vr_index).cdpesqui), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrdconta', pr_tag_cont => TO_CHAR(vr_tab_contras(vr_index).nrdconta), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmprimtl', pr_tag_cont => TO_CHAR(vr_tab_contras(vr_index).nmprimtl), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'vldivida', pr_tag_cont => TO_CHAR(vr_tab_contras(vr_index).vldivida), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'tpdcontr', pr_tag_cont => TO_CHAR(vr_tab_contras(vr_index).tpdcontr), pr_des_erro => vr_dscritic);
          
          --Montar CLOB
          IF vr_tab_msgconta.COUNT > 0 THEN        

            --Buscar Primeiro registro de mensagem
            vr_index_msgconta:= vr_tab_msgconta.FIRST;

            vr_auxconta_msg := 0;

            --Percorrer todas as mensagens
            WHILE vr_index_msgconta IS NOT NULL LOOP

              --vr_auxconta := 0;

              -- Insere as tags dos campos da PLTABLE de contratos
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);       
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta_msg, pr_tag_nova => 'msgconta', pr_tag_cont => TO_CHAR(vr_tab_msgconta(vr_index_msgconta).msgconta), pr_des_erro => vr_dscritic);
                   
              -- Incrementa contador p/ posicao no XML
              vr_auxconta_msg := vr_auxconta_msg + 1;

              --Proximo Registro
              vr_index_msgconta:= vr_tab_msgconta.NEXT(vr_index_msgconta);

              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta_msg, pr_tag_nova => 'nmprimtl', pr_tag_cont => TO_CHAR(vr_nmprimtl), pr_des_erro => vr_dscritic);        
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta_msg, pr_tag_nova => 'axnrcont', pr_tag_cont => TO_CHAR(vr_axnrcont), pr_des_erro => vr_dscritic);
              gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta_msg, pr_tag_nova => 'axnrcpfc', pr_tag_cont => TO_CHAR(vr_axnrcpfc), pr_des_erro => vr_dscritic);
            
              vr_auxconta_saida := vr_auxconta_saida + 1;
              
            END LOOP;

          ELSE
          
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'associado', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'associado', pr_posicao => vr_auxconta_saida, pr_tag_nova => 'nmprimtl', pr_tag_cont => TO_CHAR(vr_nmprimtl), pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'associado', pr_posicao => vr_auxconta_saida, pr_tag_nova => 'axnrcont', pr_tag_cont => TO_CHAR(vr_axnrcont), pr_des_erro => vr_dscritic);
            gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'associado', pr_posicao => vr_auxconta_saida, pr_tag_nova => 'axnrcpfc', pr_tag_cont => TO_CHAR(vr_axnrcpfc), pr_des_erro => vr_dscritic);        
          
            vr_auxconta_saida := vr_auxconta_saida + 1;

          END IF;        
          
          -- Incrementa contador p/ posicao no XML
          vr_auxconta := vr_auxconta + 1;

          --Proximo Registro
          vr_index:= vr_tab_contras.NEXT(vr_index);
        
          
        END LOOP;        
        
      ELSE
        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'associado', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'associado', pr_posicao => 0, pr_tag_nova => 'nmprimtl', pr_tag_cont => TO_CHAR(vr_nmprimtl), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'associado', pr_posicao => 0, pr_tag_nova => 'axnrcont', pr_tag_cont => TO_CHAR(vr_axnrcont), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'associado', pr_posicao => 0, pr_tag_nova => 'axnrcpfc', pr_tag_cont => TO_CHAR(vr_axnrcpfc), pr_des_erro => vr_dscritic);    
      END IF;      
                                        
      --Retorno
      pr_des_erro:= 'OK';    

    EXCEPTION
      WHEN vr_exc_erro THEN
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
        pr_dscritic:= 'Erro na inss0001.pc_busca_dados_contratos_web --> '|| SQLERRM;
        
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
                                         
  END pc_busca_dados_contratos_web;
  
  /* Rotina referente a consulta dos avalistas */
  PROCEDURE pc_busca_dados_avalista(pr_cdcooper IN crapcop.cdcooper%type  -->Codigo Cooperativa
                                   ,pr_cdagenci IN INTEGER DEFAULT NULL-->Codigo Agencia
                                   ,pr_nrdcaixa IN INTEGER DEFAULT NULL   -->Numero Caixa
                                   ,pr_cdoperad IN VARCHAR2 DEFAULT NULL  -->Operador
                                   ,pr_nmdatela IN VARCHAR2 DEFAULT NULL  -->Nome da tela
                                   ,pr_idorigem IN INTEGER DEFAULT NULL   -->Origem Processamento
                                   ,pr_nmdavali IN VARCHAR2 --DEFAULT NULL  -->Nome do Avalista                                   
                                   ,pr_tab_avalistas OUT aval0001.typ_tab_avalistas --Tabela Avalistas
                                   ,pr_tab_erro OUT gene0001.typ_tab_erro -->Tabela Erros
                                   ,pr_des_erro OUT VARCHAR2) IS          -->Erros do processo
     /*---------------------------------------------------------------------------------------------------------------
     Programa: pc_busca_dados_avalista       Antiga: b1wgen0145.p/Busca_Avalista
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED

     Autor   : Jéssica Laverde Gracino(DB1)
     Data    : 19/06/2015                        Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Diario (on-line)
     Objetivo  : Rotina referente a consulta de avalistas

     Alteracoes: 19/06/2015 - Conversao Progress >> Oracle (PLSQL) - Jéssica (DB1)
    ---------------------------------------------------------------------------------------------------------------*/


    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.nmrescop
          ,cop.nmextcop
          ,cop.cdcooper
          ,cop.dsdircop
          ,cop.cdagesic
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    --Selecionar informacoes da pessoa juridica
    CURSOR cr_crapjur (pr_cdcooper IN crapjur.cdcooper%TYPE) IS
      SELECT crapjur.nmextttl
            ,crapjur.nrdconta
        FROM crapjur crapjur
       WHERE crapjur.cdcooper = pr_cdcooper
         AND crapjur.nmextttl LIKE '%'||UPPER(pr_nmdavali)||'%';
    rw_crapjur cr_crapjur%ROWTYPE;
    
    --Seleciona informacoes do cadastro de avalistas
    CURSOR cr_crapavl (pr_cdcooper IN crapttl.cdcooper%TYPE,
                       pr_nrdconta IN crapttl.nrdconta%TYPE) IS
      SELECT crapavl.nrdconta
            ,crapavl.nrctaavd
            ,crapavl.tpctrato
            ,crapavl.nrctravd
        FROM crapavl
       WHERE crapavl.cdcooper = pr_cdcooper
         AND crapavl.nrdconta = pr_nrdconta;
    rw_crapavl cr_crapavl%ROWTYPE;

    -- Cursor para busca de avalistas terceiros
    CURSOR cr_crapavt (pr_cdcooper IN crapavt.cdcooper%TYPE) IS 
      SELECT crapavt.nrcpfcgc
            ,crapavt.nrctremp
            ,crapavt.tpctrato
            ,crapavt.nrdconta
            ,crapavt.nmdavali
        FROM crapavt
       WHERE crapavt.cdcooper = pr_cdcooper         
         AND crapavt.nmdavali LIKE '%'||UPPER(pr_nmdavali)||'%';
    rw_crapavt cr_crapavt%ROWTYPE; 

    -- Buscar Titular
    CURSOR cr_crapttl (pr_cdcooper IN crapttl.cdcooper%TYPE) IS
    SELECT crapttl.cdcooper
          ,crapttl.nrdconta
          ,crapttl.idseqttl 
          ,crapttl.nmextttl
          ,crapttl.nrcpfcgc
     FROM crapttl
    WHERE crapttl.cdcooper = pr_cdcooper
      AND crapttl.nmextttl LIKE '%'||UPPER(pr_nmdavali)||'%';
    rw_crapttl cr_crapttl%ROWTYPE; 

    --Selecionar informacoes dos associados
    CURSOR cr_crapass (pr_cdcooper IN crapjur.cdcooper%TYPE,
                       pr_nrdconta IN crapjur.nrdconta%TYPE) IS
      SELECT crapass.nrdconta
            ,crapass.nrcpfcgc
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta
         AND crapass.dtdemiss IS NULL;
    rw_crapass cr_crapass%ROWTYPE;    
        
    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000); 
    
    --Variaveis de Tabela de memória
    vr_tab_erro gene0001.typ_tab_erro;

    --Variaveis de Indice
    vr_index VARCHAR(200);
  
    vr_retornvl  VARCHAR2(3):= 'NOK';
        
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;                                       
    vr_exc_saida EXCEPTION; 

    BEGIN

      --Inicializando a variável index
      vr_index := 0;
             
      -- Verifica se a cooperativa esta cadastrada
      OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
      
      FETCH cr_crapcop INTO rw_crapcop;
      
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        
        -- Fechar o cursor pois haverá raise
        CLOSE cr_crapcop;
        
        -- Montar mensagem de critica
        vr_cdcritic := 651;
        -- Busca critica
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        
       RAISE vr_exc_erro;
       
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;
  
      --Verificar parametros
      IF pr_nmdavali = '' OR pr_nmdavali IS NULL THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Informe o Avalista';

        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      IF LENGTH(pr_nmdavali) < 2  THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Informe 2 ou mais caracteres';

        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      

      -- Leitura para busca de avalistas terceiros
      FOR rw_crapavt IN cr_crapavt(pr_cdcooper) LOOP

        vr_index:= vr_index + 1;

        IF pr_tab_avalistas.EXISTS(vr_index) OR rw_crapavt.nrcpfcgc = 0 THEN
          CONTINUE;
        END IF;  

        pr_tab_avalistas(vr_index).nrdconta := rw_crapavt.nrdconta;
        pr_tab_avalistas(vr_index).nmdavali := rw_crapavt.nmdavali;
        pr_tab_avalistas(vr_index).nrcpfcgc := rw_crapavt.nrcpfcgc;    

      END LOOP;
      

      -- Leitura para busca de titulares
      FOR rw_crapttl IN cr_crapttl(pr_cdcooper) LOOP

        vr_index:= vr_index + 1;

        -- Leitura para busca de cadastro de avalistas
        FOR rw_crapavl IN cr_crapavl(rw_crapttl.cdcooper, rw_crapttl.nrdconta) LOOP

          IF pr_tab_avalistas.EXISTS(vr_index) THEN
            CONTINUE;
          END IF;  

          pr_tab_avalistas(vr_index).nrdconta := rw_crapavl.nrdconta;
          pr_tab_avalistas(vr_index).nmdavali := rw_crapttl.nmextttl;
          pr_tab_avalistas(vr_index).nrcpfcgc := rw_crapttl.nrcpfcgc;

        END LOOP;

      END LOOP;

      -- Leitura para busca de cadastro de pessoas juridicas
      FOR rw_crapjur IN cr_crapjur(pr_cdcooper) LOOP

        vr_index:= vr_index + 1;
      
        -- Leitura para busca de cadastro de avalistas
        FOR rw_crapavl IN cr_crapavl(pr_cdcooper, rw_crapttl.nrdconta) LOOP

          IF pr_tab_avalistas.EXISTS(vr_index) THEN
            CONTINUE;
          END IF;  

          -- Leitura para busca de cadastro de associados
          OPEN cr_crapass (pr_cdcooper => pr_cdcooper,
                           pr_nrdconta => rw_crapjur.nrdconta);
        
          FETCH cr_crapass INTO rw_crapass;
          
          CLOSE cr_crapass;

          pr_tab_avalistas(vr_index).nrdconta := rw_crapavl.nrdconta;
          pr_tab_avalistas(vr_index).nmdavali := rw_crapjur.nmextttl;
          pr_tab_avalistas(vr_index).nrcpfcgc := rw_crapass.nrcpfcgc;

        END LOOP;

      END LOOP;
                  
    EXCEPTION 
      WHEN vr_exc_erro THEN
        
        -- Retorno não OK          
        pr_des_erro:= vr_retornvl;
        
        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
                             
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        -- Chamar rotina de gravação de erro
        vr_dscritic := 'Erro na aval0001.pc_busca_dados_avalista --> '|| SQLERRM;

        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);


  END pc_busca_dados_avalista;

  /* Rotina referente a consulta de avalistas Modo Caracter */
  PROCEDURE pc_busca_dados_avalista_car (pr_cdcooper IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                        ,pr_cdagenci IN INTEGER DEFAULT NULL  --Codigo Agencia
                                        ,pr_nrdcaixa IN INTEGER DEFAULT NULL  --Numero Caixa
                                        ,pr_cdoperad IN VARCHAR2 DEFAULT NULL --Operador
                                        ,pr_nmdatela IN VARCHAR2 DEFAULT NULL --Nome da tela
                                        ,pr_idorigem IN INTEGER DEFAULT NULL  --Origem Processamento
                                        ,pr_nmdavali IN VARCHAR2 DEFAULT NULL --Nome do Avalista
                                        ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                        ,pr_des_erro OUT VARCHAR2             --Saida OK/NOK
                                        ,pr_clob_ret OUT CLOB                 --Tabela Beneficiarios
                                        ,pr_cdcritic OUT PLS_INTEGER          --Codigo Erro
                                        ,pr_dscritic OUT VARCHAR2) IS         --Descricao Erro
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa: pc_busca_dados_avalista_car       Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : Jéssica Laverde Gracino(DB1)
    Data    : 23/06/2015                        Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Rotina referente a consulta de avalistas modo Caracter

    Alteracoes: 23/06/2015 - Desenvolvimento - Jéssica (DB1)
                 
  ---------------------------------------------------------------------------------------------------------------*/

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 

    --Tabelas de Memoria
    vr_tab_erro gene0001.typ_tab_erro;
    vr_tab_avalistas aval0001.typ_tab_avalistas;

    --Variaveis Arquivo Dados
    vr_dstexto VARCHAR2(32767);
    vr_string  VARCHAR2(32767);
        
    --Variaveis de Indice
    vr_index PLS_INTEGER;
    
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;                                       
        
    BEGIN
      
      --limpar tabela erros
      vr_tab_erro.DELETE;
      
      --Limpar tabela dados
      vr_tab_avalistas.DELETE;
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= null;
      
      --Consultar Avalistas
      aval0001.pc_busca_dados_avalista(pr_cdcooper => pr_cdcooper  --Codigo Cooperativa
                                      ,pr_cdagenci => pr_cdagenci  --Codigo Agencia
                                      ,pr_nrdcaixa => pr_nrdcaixa  --Numero Caixa
                                      ,pr_cdoperad => pr_cdoperad  --Operador
                                      ,pr_nmdatela => pr_nmdatela  --Nome da tela
                                      ,pr_idorigem => pr_idorigem  --Origem Processamento
                                      ,pr_nmdavali => pr_nmdavali  --Nome do Avalista                                      
                                      ,pr_tab_avalistas => vr_tab_avalistas --Tabela Avalistas
                                      ,pr_tab_erro => vr_tab_erro  --Tabela Erros
                                      ,pr_des_erro => vr_des_reto); --Saida OK/NOK


      --Se Ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        
        --Se possuir dados na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          --Mensagem erro
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          --Mensagem erro
          vr_dscritic:= 'Erro ao executar a aval0001.pc_busca_dados_avalista.';
        END IF;    
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      END IF;
                                          
      --Montar CLOB
      IF vr_tab_avalistas.COUNT > 0 THEN
        
        -- Criar documento XML
        dbms_lob.createtemporary(pr_clob_ret, TRUE); 
        dbms_lob.open(pr_clob_ret, dbms_lob.lob_readwrite);
        
        -- Insere o cabeçalho do XML 
        gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret 
                               ,pr_texto_completo => vr_dstexto 
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root>');
         
        --Buscar Primeiro avalista
        vr_index:= vr_tab_avalistas.FIRST;
        
        --Percorrer todos os avalistas
        WHILE vr_index IS NOT NULL LOOP
          vr_string:= '<aval>'||
                      '<nrdconta>'||NVL(TO_CHAR(vr_tab_avalistas(vr_index).nrdconta),'0')|| '</nrdconta>'|| 
                      '<nmdavali>'||NVL(TO_CHAR(vr_tab_avalistas(vr_index).nmdavali),' ')|| '</nmdavali>'|| 
                      '<nrcpfcgc>'||NVL(TO_CHAR(vr_tab_avalistas(vr_index).nrcpfcgc),' ')|| '</nrcpfcgc>'||
                      '</aval>';
                      
          -- Escrever no XML
          gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret 
                                 ,pr_texto_completo => vr_dstexto 
                                 ,pr_texto_novo     => vr_string
                                 ,pr_fecha_xml      => FALSE);   
                                                    
          --Proximo Registro
          vr_index:= vr_tab_avalistas.NEXT(vr_index);
          
        END LOOP;  
        
        -- Encerrar a tag raiz 
        gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret 
                               ,pr_texto_completo => vr_dstexto 
                               ,pr_texto_novo     => '</root>' 
                               ,pr_fecha_xml      => TRUE);
                               
      END IF;
                                         
      --Retorno
      pr_des_erro:= 'OK';   

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK          
        pr_des_erro:= 'NOK';
        
        --Erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;        
          
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_erro:= 'NOK';
        
        pr_cdcritic:= 0;
        -- Chamar rotina de gravação de erro
        pr_dscritic:= 'Erro na aval0001.pc_busca_dados_avalista_car --> '|| SQLERRM;

  END pc_busca_dados_avalista_car;  

  /* Rotina referente a consulta de avalistas Modo Web */
  PROCEDURE pc_busca_dados_avalista_web(pr_dtmvtolt IN VARCHAR2 DEFAULT NULL --Data Movimento
                                       ,pr_nmdavali IN VARCHAR2 DEFAULT NULL --Nome do Avalista                                       
                                       ,pr_xmllog   IN VARCHAR2              --XML com informações de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER          --Código da crítica
                                       ,pr_dscritic OUT VARCHAR2             --Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType    --Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2             --Nome do Campo
                                       ,pr_des_erro OUT VARCHAR2) IS         --Saida OK/NOK
                                       
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa: pc_busca_dados_avalista_web      Antiga: 
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED

    Autor   : Jéssica Laverde Gracino(DB1)
    Data    : 23/06/2015                        Ultima atualizacao: 

    Dados referentes ao programa:

    Frequencia: Diario (on-line)
    Objetivo  : Rotina referente a consulta de avalistas modo Web

    Alteracoes: 23/06/2015 - Desenvolvimento - Jéssica (DB1)
                 
  ---------------------------------------------------------------------------------------------------------------*/

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 

    --Tabela de Erros
    vr_tab_erro gene0001.typ_tab_erro;
    --Tabela de beneficiarios
    vr_tab_avalistas aval0001.typ_tab_avalistas;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    
    --Variaveis Arquivo Dados
    vr_dtmvtolt DATE;
    vr_auxconta PLS_INTEGER:= 0;
        
    --Variaveis de Indice
    vr_index PLS_INTEGER;
    
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;                                       
    
    BEGIN
      
      --limpar tabela erros
      vr_tab_erro.DELETE;
      
      --Limpar tabela dados
      vr_tab_avalistas.DELETE;
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= null;
      
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
      
      BEGIN                                                  
        --Pega a data de movimento e converte para "DATE"
        vr_dtmvtolt:= to_date(pr_dtmvtolt,'DD/MM/YYYY'); 
                      
      EXCEPTION
        WHEN OTHERS THEN
          
          --Monta mensagem de critica
          vr_dscritic := 'Data de movimento invalida.';
          
          --Gera exceção
          RAISE vr_exc_erro;
      END;
      
      --Consultar Avalistas
      aval0001.pc_busca_dados_avalista(pr_cdcooper => vr_cdcooper  --Codigo Cooperativa
                                      ,pr_cdagenci => vr_cdagenci  --Codigo Agencia
                                      ,pr_nrdcaixa => vr_nrdcaixa  --Numero Caixa
                                      ,pr_cdoperad => vr_cdoperad  --Operador
                                      ,pr_nmdatela => vr_nmdatela  --Nome da tela
                                      ,pr_idorigem => vr_idorigem  --Origem Processamento
                                      ,pr_nmdavali => pr_nmdavali  --Nome do Avalista                                      
                                      ,pr_tab_avalistas => vr_tab_avalistas --Tabela Avalistas
                                      ,pr_tab_erro => vr_tab_erro  --Tabela Erros
                                      ,pr_des_erro => vr_des_reto); --Saida OK/NOK      

      --Se Ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        
        --Se possuir erro na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          --Mensagem Erro
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE  
          --Mensagem Erro
          vr_dscritic:= 'Erro na aval0001.pc_busca_dados_avalista.';
        END IF;  
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      END IF;
                                          
      --Montar CLOB
      IF vr_tab_avalistas.COUNT > 0 THEN

        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
                
        --Buscar Primeiro avalista
        vr_index:= vr_tab_avalistas.FIRST;
        
        --Percorrer todos os avalistas
        WHILE vr_index IS NOT NULL LOOP

          -- Insere as tags dos campos da PLTABLE de avalistas
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0     , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrdconta', pr_tag_cont => TO_CHAR(vr_tab_avalistas(vr_index).nrdconta), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nmdavali', pr_tag_cont => TO_CHAR(vr_tab_avalistas(vr_index).nmdavali), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_auxconta, pr_tag_nova => 'nrcpfcgc', pr_tag_cont => TO_CHAR(vr_tab_avalistas(vr_index).nrcpfcgc), pr_des_erro => vr_dscritic);

          -- Incrementa contador p/ posicao no XML
          vr_auxconta := vr_auxconta + 1;

          --Proximo Registro
          vr_index:= vr_tab_avalistas.NEXT(vr_index);
          
        END LOOP;
      ELSE
        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');    
      END IF;
                                         
      --Retorno
      pr_des_erro:= 'OK';    
    
    EXCEPTION
      WHEN vr_exc_erro THEN
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
        pr_dscritic:= 'Erro na aval0001.pc_busca_dados_avalista_web --> '|| SQLERRM;
        
        -- Existe para satisfazer exigência da interface. 
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_cdcritic||'-'||pr_dscritic || '</Erro></Root>');                     
                                         
  END pc_busca_dados_avalista_web;


END AVAL0001;
/
