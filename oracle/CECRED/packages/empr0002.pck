CREATE OR REPLACE PACKAGE CECRED.EMPR0002 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : EMPR0002
  --  Sistema  : Rotinas referentes a tela PARPRE
  --  Sigla    : EMPR
  --  Autor    : Jaison Fernando - CECRED
  --  Data     : Junho - 2014.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas genericas refente a tela PARPRE

  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------
   
  --temptable para retornar dados da cpa, antigo b1wgen188tt.i/tt-dados-cpa
  TYPE typ_rec_dados_cpa IS RECORD
      (cdcooper crapepr.cdcooper%TYPE,
       nrdconta crapepr.nrdconta%TYPE,
       inpessoa crapass.inpessoa%TYPE,
       vldiscrd NUMBER(11,2),
       txmensal NUMBER(11,2));
  TYPE typ_tab_dados_cpa IS TABLE OF typ_rec_dados_cpa 
      INDEX BY PLS_INTEGER;
       
       
  
  /* Rotina referente as acoes da tela PARPRE */
  PROCEDURE pc_tela_cadpre(pr_cddopcao IN VARCHAR2              --> Tipo de acao que sera executada (C - Consulta / A - Alteracao)
                          ,pr_inpessoa IN crappre.inpessoa%TYPE --> Codigo do tipo de pessoa
                          ,pr_nrmcotas IN crappre.nrmcotas%TYPE --> Numero de vezes que as cotas serao multiplicadas
                          ,pr_vllimcra IN crappre.vllimcra%TYPE --> Limite contas risco A
                          ,pr_vllimcrb IN crappre.vllimcrb%TYPE --> Limite contas risco B
                          ,pr_vllimcrc IN crappre.vllimcrc%TYPE --> Limite contas risco C
                          ,pr_vllimcrd IN crappre.vllimcrd%TYPE --> Limite contas risco D
                          ,pr_vllimcre IN crappre.vllimcre%TYPE --> Limite contas risco E
                          ,pr_vllimcrf IN crappre.vllimcrf%TYPE --> Limite contas risco F
                          ,pr_vllimcrg IN crappre.vllimcrg%TYPE --> Limite contas risco G
                          ,pr_vllimcrh IN crappre.vllimcrh%TYPE --> Limite contas risco H
                          ,pr_dssitdop IN crappre.dssitdop%TYPE --> Situação das Contas separados por (;)
                          ,pr_nrrevcad IN crappre.nrrevcad%TYPE --> Numero de meses da revisao cadastral
                          ,pr_vllimmin IN crappre.vllimmin%TYPE --> Limite minimo
                          ,pr_vlpercom IN crappre.vlpercom%TYPE --> Porcentagem de comprometimento da Renda
                          ,pr_vlmaxleg IN crappre.vlmaxleg%TYPE --> Porcentagem de Valor Maximo Legal
                          ,pr_vllimctr IN crappre.vllimctr%TYPE --> Limite minimo para contratacao
                          ,pr_vlmulpli IN crappre.vlmulpli%TYPE --> Valor multiplo
                          ,pr_cdfinemp IN crappre.cdfinemp%TYPE --> Codigo da Finalidade
                          ,pr_cdlcremp IN crappre.cdlcremp%TYPE --> Codigo da Linha de Credito
                          ,pr_qtmescta IN crappre.qtmescta%TYPE --> Tempo de abertura da conta
                          ,pr_qtmesadm IN crappre.qtmesadm%TYPE --> Tempo de admissao no emprego atual
                          ,pr_qtmesemp IN crappre.qtmesemp%TYPE --> Tempo do fundacao da empresa
                          ,pr_dslstali IN crappre.dslstali%TYPE --> Lista com codigos de alineas de devolucao de cheque
                          ,pr_qtdevolu IN crappre.qtdevolu%TYPE --> Quantidade de devolucoes de cheque
                          ,pr_qtdiadev IN crappre.qtdiadev%TYPE --> Quantidade de dias para calc. devolucao de cheque
                          ,pr_qtctaatr IN crappre.qtctaatr%TYPE --> Quantidade de dias de conta corrente em atraso
                          ,pr_qtepratr IN crappre.qtepratr%TYPE --> Quantidade de dias de emprestimo em atraso
                          ,pr_qtestour IN crappre.qtestour%TYPE --> Quantidade de estouros de conta
                          ,pr_qtdiaest IN crappre.qtdiaest%TYPE --> Quantidade de dias para calc. estouro de conta
                          ,pr_flgconsu IN NUMBER                --> Flag para consulta
                          ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                          ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                          ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                          ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                          ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  PROCEDURE pc_consultar_carga (pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2);
  
  PROCEDURE pc_busca_carga_ativa (pr_cdcooper  IN tbepr_carga_pre_aprv.cdcooper%TYPE    --> Codigo da cooperativa
                                 ,pr_idcarga  OUT tbepr_carga_pre_aprv.idcarga%TYPE);   --> Codigo da carga
  
  PROCEDURE pc_exclui_carga_bloqueada (pr_cdcooper IN  tbepr_carga_pre_aprv.cdcooper%TYPE --> Codigo Cooperativa
                                      ,pr_dscritic OUT VARCHAR2);                         --> Retorno de critica

  PROCEDURE pc_gerar_carga (pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);

  
   --> Procedimento para buscar dados do credito pré-aprovado (crapcpa)
  PROCEDURE pc_busca_dados_cpa (pr_cdcooper  IN crapcop.cdcooper%TYPE    --> Codigo da cooperativa
                               ,pr_cdagenci  IN crapage.cdagenci%TYPE    --> Código da agencia
                               ,pr_nrdcaixa  IN crapbcx.nrdcaixa%TYPE    --> Numero do caixa
                               ,pr_cdoperad  IN crapope.cdoperad%TYPE    --> Codigo do operador
                               ,pr_nmdatela  IN craptel.nmdatela%TYPE    --> Nome da tela
                               ,pr_idorigem  IN INTEGER                  --> Id origem
                               ,pr_nrdconta  IN crapass.nrdconta%TYPE    --> Numero da conta do cooperado
                               ,pr_idseqttl  IN crapttl.idseqttl%TYPE    --> Sequencial do titular
                               ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE    --> CPF do operador juridico
                               ,pr_tab_dados_cpa OUT typ_tab_dados_cpa   --> Retorna dados do credito pre aprovado
                               ,pr_des_reto      OUT VARCHAR2            --> Retorno OK/NOK
                               ,pr_tab_erro      OUT gene0001.typ_tab_erro); --> Retorna os erros

  PROCEDURE pc_busca_dados_cpa_prog (pr_cdcooper  IN crapcop.cdcooper%TYPE    --> Codigo da cooperativa
                                    ,pr_cdagenci  IN crapage.cdagenci%TYPE    --> Código da agencia
                                    ,pr_nrdcaixa  IN crapbcx.nrdcaixa%TYPE    --> Numero do caixa
                                    ,pr_cdoperad  IN crapope.cdoperad%TYPE    --> Codigo do operador
                                    ,pr_nmdatela  IN craptel.nmdatela%TYPE    --> Nome da tela
                                    ,pr_idorigem  IN INTEGER                  --> Id origem
                                    ,pr_nrdconta  IN crapass.nrdconta%TYPE    --> Numero da conta do cooperado
                                    ,pr_idseqttl  IN crapttl.idseqttl%TYPE    --> Sequencial do titular
                                    ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE    --> CPF do operador juridico
                                    ,pr_clob_cpa  OUT CLOB                --> Retorna dados do credito pre aprovado
                                    ,pr_des_reto  OUT VARCHAR2            --> Retorno OK/NOK
                                    ,pr_clob_erro OUT CLOB);              --> Retorna os erros
  
  PROCEDURE pc_busca_alinea(pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);
  
  PROCEDURE pc_altera_carga(pr_idcarga  IN tbepr_carga_pre_aprv.idcarga%TYPE --> Codigo da Carga
                           ,pr_acao     IN VARCHAR2                          --> Acao: B-Bloquear / L-Liberar
                           ,pr_xmllog   IN VARCHAR2                          --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER                      --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2                         --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType                --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2                         --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);
  
  PROCEDURE pc_inclui_carga (pr_cdcooper IN  tbepr_carga_pre_aprv.cdcooper%TYPE --> Codigo Cooperativa
                            ,pr_idcarga  OUT tbepr_carga_pre_aprv.idcarga%TYPE  --> Codigo da Carga
                            ,pr_dscritic OUT VARCHAR2);                         --> Retorno de critica

  PROCEDURE pc_limpeza_diretorio(pr_nmdireto IN VARCHAR2      --> Diretorio para limpeza
                                ,pr_dscritic OUT VARCHAR2);   --> Retorno de critica
                               
  END EMPR0002;
/
CREATE OR REPLACE PACKAGE BODY CECRED.EMPR0002 AS
  
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : EMPR0002
  --  Sistema  : Rotinas referentes a tela CADPRE
  --  Sigla    : EMPR
  --  Autor    : Jaison Fernando - CECRED
  --  Data     : Junho - 2014.                   Ultima atualizacao: 13/11/2015
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas genericas refente a tela CADPRE
  --
  -- Alteracoes: 13/11/2015 - Ajustado leitura na CRAPOPE incluindo upper (Odirlei-AMcom)
  --
  ---------------------------------------------------------------------------------------------------------------
  
  -- Selecionar os dados da Cooperativa
  CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
  SELECT cdcooper
        ,nmrescop
        ,vlmaxleg
    FROM crapcop 
   WHERE cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;
  
  PROCEDURE pc_valida_operador(pr_cdcooper  IN crapope.cdcooper%TYPE --> Codigo da Carga
                              ,pr_cdoperad  IN crapope.cdoperad%TYPE --> Descrição da crítica
                              ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da crítica
  BEGIN

    /* .............................................................................

     Programa: pc_valida_operador
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Jaison Fernando
     Data    : Janeiro/2015.                    Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Valida o operador.

     Alteracoes: 

     ..............................................................................*/ 
    DECLARE
      -- Busca o operador
      CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE
                       ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
        SELECT dsdepart
          FROM crapope
         WHERE crapope.cdcooper = pr_cdcooper
           AND UPPER(crapope.cdoperad) = UPPER(pr_cdoperad);
      rw_crapope cr_crapope%ROWTYPE;

      -- Variaveis
      vr_blnfound BOOLEAN;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_cdcritic  crapcri.cdcritic%TYPE;
      vr_dscritic  crapcri.dscritic%TYPE;
     
    BEGIN
      -- Buscar Dados do Operador
      OPEN cr_crapope (pr_cdcooper => pr_cdcooper
                      ,pr_cdoperad => pr_cdoperad);
      FETCH cr_crapope INTO rw_crapope;
      -- Alimenta a booleana se achou ou nao
      vr_blnfound := cr_crapope%FOUND;
      -- Fecha cursor
      CLOSE cr_crapope;

      -- Se nao achou
      IF NOT vr_blnfound THEN
        vr_cdcritic := 67;
        vr_dscritic := NULL;
        RAISE vr_exc_saida;
      END IF;

      -- Somente o departamento credito irá ter acesso para alterar as informacoes
      IF rw_crapope.dsdepart <> 'PRODUTOS' AND rw_crapope.dsdepart <> 'TI'  THEN
        vr_cdcritic := 36;
        vr_dscritic := NULL;
        RAISE vr_exc_saida;
      END IF;
        
    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          vr_dscritic := GENE0001.fn_busca_critica(vr_cdcritic);
        END IF;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral em CRAPPRE: ' || SQLERRM;
    END;
    
  END pc_valida_operador;

  /* Rotina referente as acoes da tela CADPRE */
  PROCEDURE pc_tela_cadpre(pr_cddopcao IN VARCHAR2              --> Tipo de acao que sera executada (C - Consulta / A - Alteracao)
                          ,pr_inpessoa IN crappre.inpessoa%TYPE --> Codigo do tipo de pessoa
                          ,pr_nrmcotas IN crappre.nrmcotas%TYPE --> Numero de vezes que as cotas serao multiplicadas
                          ,pr_vllimcra IN crappre.vllimcra%TYPE --> Limite contas risco A
                          ,pr_vllimcrb IN crappre.vllimcrb%TYPE --> Limite contas risco B
                          ,pr_vllimcrc IN crappre.vllimcrc%TYPE --> Limite contas risco C
                          ,pr_vllimcrd IN crappre.vllimcrd%TYPE --> Limite contas risco D
                          ,pr_vllimcre IN crappre.vllimcre%TYPE --> Limite contas risco E
                          ,pr_vllimcrf IN crappre.vllimcrf%TYPE --> Limite contas risco F
                          ,pr_vllimcrg IN crappre.vllimcrg%TYPE --> Limite contas risco G
                          ,pr_vllimcrh IN crappre.vllimcrh%TYPE --> Limite contas risco H
                          ,pr_dssitdop IN crappre.dssitdop%TYPE --> Situação das Contas separados por (;)
                          ,pr_nrrevcad IN crappre.nrrevcad%TYPE --> Numero de meses da revisao cadastral
                          ,pr_vllimmin IN crappre.vllimmin%TYPE --> Limite minimo
                          ,pr_vlpercom IN crappre.vlpercom%TYPE --> Porcentagem de comprometimento da Renda
                          ,pr_vlmaxleg IN crappre.vlmaxleg%TYPE --> Porcentagem de Valor Maximo Legal
                          ,pr_vllimctr IN crappre.vllimctr%TYPE --> Limite minimo para contratacao
                          ,pr_vlmulpli IN crappre.vlmulpli%TYPE --> Valor multiplo
                          ,pr_cdfinemp IN crappre.cdfinemp%TYPE --> Codigo da Finalidade
                          ,pr_cdlcremp IN crappre.cdlcremp%TYPE --> Codigo da Linha de Credito
                          ,pr_qtmescta IN crappre.qtmescta%TYPE --> Tempo de abertura da conta
                          ,pr_qtmesadm IN crappre.qtmesadm%TYPE --> Tempo de admissao no emprego atual
                          ,pr_qtmesemp IN crappre.qtmesemp%TYPE --> Tempo do fundacao da empresa
                          ,pr_dslstali IN crappre.dslstali%TYPE --> Lista com codigos de alineas de devolucao de cheque
                          ,pr_qtdevolu IN crappre.qtdevolu%TYPE --> Quantidade de devolucoes de cheque
                          ,pr_qtdiadev IN crappre.qtdiadev%TYPE --> Quantidade de dias para calc. devolucao de cheque
                          ,pr_qtctaatr IN crappre.qtctaatr%TYPE --> Quantidade de dias de conta corrente em atraso
                          ,pr_qtepratr IN crappre.qtepratr%TYPE --> Quantidade de dias de emprestimo em atraso
                          ,pr_qtestour IN crappre.qtestour%TYPE --> Quantidade de estouros de conta
                          ,pr_qtdiaest IN crappre.qtdiaest%TYPE --> Quantidade de dias para calc. estouro de conta
                          ,pr_flgconsu IN NUMBER                --> Flag para consulta
                          ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                          ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                          ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                          ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                          ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                          ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN

    /* .............................................................................

     Programa: pc_tela_cadpre
     Sistema : Cartoes de Credito - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Jaison Fernando
     Data    : Junho/14.                    Ultima atualizacao: 08/01/2016

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina geral de CRUD da tela CADPRE.

     Observacao: -----

     Alteracoes: 01/10/2014 - Somente permitir alterar os parametros caso o departamento
                              do operador for "PRODUTOS". (James)

                 08/01/2016 - Inclusao/Exclusao de campos PRJ261 - Pre-Aprovado fase II.
                              (Jaison/Anderson)

     ..............................................................................*/ 
    DECLARE

      -- Selecionar os dados
      CURSOR cr_crappre(pr_cdcooper IN crappre.cdcooper%TYPE
                       ,pr_inpessoa IN crappre.inpessoa%TYPE) IS
        SELECT inpessoa, nrmcotas, dsrisdop, dssitdop, nrrevcad,
               vllimmin, vlpercom, vllimcra, vllimcrb, vllimcrc,
               vllimcrd, vllimcre, vllimcrf, vllimcrg, vllimcrh,
               vlmaxleg, vllimctr, vlmulpli, cdfinemp, cdlcremp,
               qtmescta, qtmesadm, qtmesemp, dslstali, qtdevolu,
               qtdiadev, qtctaatr, qtepratr, qtestour, qtdiaest
          FROM crappre 
         WHERE cdcooper = pr_cdcooper
           AND inpessoa = pr_inpessoa;
      rw_crappre cr_crappre%ROWTYPE;

      -- Selecionar os dados da Finalidade
      CURSOR cr_crapfin (pr_cdcooper IN crapfin.cdcooper%TYPE
                        ,pr_cdfinemp IN crapfin.cdfinemp%TYPE) IS
      SELECT cdfinemp
            ,dsfinemp
            ,flgstfin
        FROM crapfin 
       WHERE cdcooper = pr_cdcooper
         AND cdfinemp = pr_cdfinemp;
      rw_crapfin cr_crapfin%ROWTYPE;

      -- Selecionar os dados da Linha de Credito
      CURSOR cr_craplcr (pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
      SELECT cdlcremp
            ,dslcremp
            ,flgstlcr
        FROM craplcr 
       WHERE cdlcremp = pr_cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;

      -- Verifica se a Linha de Credito pertence a Finalidade
      CURSOR cr_craplch (pr_cdcooper IN craplch.cdcooper%TYPE
                        ,pr_cdfinemp IN craplch.cdfinemp%TYPE
                        ,pr_cdlcrhab IN craplch.cdlcrhab%TYPE) IS
      SELECT cdfinemp
        FROM craplch 
       WHERE cdcooper = pr_cdcooper
         AND cdfinemp = pr_cdfinemp
         AND cdlcrhab = pr_cdlcrhab;
      rw_craplch cr_craplch%ROWTYPE;

      -- Verifica a ultima carga gerada bloqueada
      CURSOR cr_carga (pr_cdcooper IN tbepr_carga_pre_aprv.cdcooper%TYPE
                      ,pr_inpessoa IN NUMBER) IS
        SELECT NVL(carga.vltotal_pre_aprv_pf,0) +
               NVL(carga.vltotal_pre_aprv_pj,0) vlsomado
          FROM tbepr_carga_pre_aprv carga 
         WHERE carga.cdcooper = pr_cdcooper
           AND carga.indsituacao_carga = 1 -- Gerada
           AND carga.flgcarga_bloqueada = 1 -- Bloqueada
           AND ROWNUM = 1
        ORDER BY carga.idcarga DESC;
      
      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
      vr_null          EXCEPTION;

      -- Variaveis de log
      vr_cdcooper      NUMBER;
      vr_cdoperad      VARCHAR2(100);
      vr_nmdatela      VARCHAR2(100);
      vr_nmeacao       VARCHAR2(100);
      vr_cdagenci      VARCHAR2(100);
      vr_nrdcaixa      VARCHAR2(100);
      vr_idorigem      VARCHAR2(100);

      vr_vlmaximo      crapcop.vlmaxleg%TYPE; --> Valor Maximo Legal
      vr_dsrisdop      crappre.dsrisdop%TYPE; --> Riscos da Operacao
      vr_dtaltcad      VARCHAR2(20);          --> Data de alteracao do cadastro
      vr_dsclinha      VARCHAR2(4000);        --> Linha a ser inserida no LOG
      vr_dsdireto      VARCHAR2(400);         --> Diretório do arquivo de LOG
      vr_utlfileh      utl_file.file_type;    --> Handle para arquivo de LOG
      vr_vlsomado      NUMBER;                --> Valor total calculado

      BEGIN
        GENE0004.pc_extrai_dados(pr_xml      => pr_retxml 
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao 
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => vr_dscritic);

        IF pr_cddopcao = 'A' THEN
          
          -- Valida o operador
          EMPR0002.pc_valida_operador(pr_cdcooper => vr_cdcooper
                                     ,pr_cdoperad => vr_cdoperad
                                     ,pr_dscritic => vr_dscritic);
          -- Se possui critica
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_exc_saida;
          END IF;
           
        END IF;

        -- Cursor com os dados da Regra
        OPEN cr_crappre(pr_cdcooper => vr_cdcooper
                       ,pr_inpessoa => pr_inpessoa);
        FETCH cr_crappre 
         INTO rw_crappre;

        -- Se nao encontrar
        IF cr_crappre%NOTFOUND THEN
          -- Fecha o cursor
          CLOSE cr_crappre;
          vr_dscritic := 'Regra nao encontrada.';
          RAISE vr_exc_saida;
        END IF;

        -- Fecha o cursor
        CLOSE cr_crappre;

        -- Busca cooperativa
        OPEN cr_crapcop(vr_cdcooper);
        FETCH cr_crapcop 
         INTO rw_crapcop;

        -- Fecha o cursor
        CLOSE cr_crapcop;

        vr_vlmaximo := (rw_crapcop.vlmaxleg * (rw_crappre.vlmaxleg / 100));

        -- Criar cabeçalho do XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados'   , pr_posicao => 0          , pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'inpessoa', pr_tag_cont => rw_crappre.inpessoa, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'nrmcotas', pr_tag_cont => rw_crappre.nrmcotas, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vllimcra', pr_tag_cont => rw_crappre.vllimcra, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vllimcrb', pr_tag_cont => rw_crappre.vllimcrb, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vllimcrc', pr_tag_cont => rw_crappre.vllimcrc, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vllimcrd', pr_tag_cont => rw_crappre.vllimcrd, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vllimcre', pr_tag_cont => rw_crappre.vllimcre, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vllimcrf', pr_tag_cont => rw_crappre.vllimcrf, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vllimcrg', pr_tag_cont => rw_crappre.vllimcrg, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vllimcrh', pr_tag_cont => rw_crappre.vllimcrh, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'dssitdop', pr_tag_cont => rw_crappre.dssitdop, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'nrrevcad', pr_tag_cont => rw_crappre.nrrevcad, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vllimmin', pr_tag_cont => rw_crappre.vllimmin, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vlpercom', pr_tag_cont => rw_crappre.vlpercom, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vlmaxleg', pr_tag_cont => rw_crappre.vlmaxleg, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vlmaximo', pr_tag_cont => vr_vlmaximo, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vllimctr', pr_tag_cont => rw_crappre.vllimctr, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vlmulpli', pr_tag_cont => rw_crappre.vlmulpli, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cdfinemp', pr_tag_cont => rw_crappre.cdfinemp, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'cdlcremp', pr_tag_cont => rw_crappre.cdlcremp, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtmescta', pr_tag_cont => rw_crappre.qtmescta, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtmesadm', pr_tag_cont => rw_crappre.qtmesadm, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtmesemp', pr_tag_cont => rw_crappre.qtmesemp, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'dslstali', pr_tag_cont => rw_crappre.dslstali, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtdevolu', pr_tag_cont => rw_crappre.qtdevolu, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtdiadev', pr_tag_cont => rw_crappre.qtdiadev, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtctaatr', pr_tag_cont => rw_crappre.qtctaatr, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtepratr', pr_tag_cont => rw_crappre.qtepratr, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtestour', pr_tag_cont => rw_crappre.qtestour, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtdiaest', pr_tag_cont => rw_crappre.qtdiaest, pr_des_erro => vr_dscritic);

        -- Cursor com o valor total gerado
        OPEN cr_carga(pr_cdcooper => vr_cdcooper
                     ,pr_inpessoa => pr_inpessoa);
        FETCH cr_carga INTO vr_vlsomado;
        CLOSE cr_carga;

        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vlsomado', pr_tag_cont => vr_vlsomado, pr_des_erro => vr_dscritic);

        -- Cursor com os dados da Finalidade
        OPEN cr_crapfin(pr_cdcooper => vr_cdcooper
                       ,pr_cdfinemp => rw_crappre.cdfinemp);
        FETCH cr_crapfin INTO rw_crapfin;
        CLOSE cr_crapfin;

        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'dsfinemp', pr_tag_cont => rw_crapfin.dsfinemp, pr_des_erro => vr_dscritic);

        -- Cursor com os dados da Linha de Credito
        OPEN cr_craplcr(pr_cdlcremp => rw_crappre.cdlcremp);
        FETCH cr_craplcr INTO rw_craplcr;
        CLOSE cr_craplcr;

        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'dslcremp', pr_tag_cont => rw_craplcr.dslcremp, pr_des_erro => vr_dscritic);

        -- Efetua a manipulação do registro
        IF pr_flgconsu = 0 THEN

          -- Cursor com os dados da Finalidade
          OPEN cr_crapfin(pr_cdcooper => vr_cdcooper
                         ,pr_cdfinemp => pr_cdfinemp);
          FETCH cr_crapfin 
           INTO rw_crapfin;

          -- Se nao encontrar
          IF cr_crapfin%NOTFOUND THEN
            -- Fecha o cursor
            CLOSE cr_crapfin;
            vr_cdcritic := 362;
            RAISE vr_exc_saida;
          ELSE
            -- Fecha o cursor
            CLOSE cr_crapfin;
            -- Se a Finalidade estiver bloqueada
            IF rw_crapfin.flgstfin = 0 THEN
              vr_cdcritic := 469;
              RAISE vr_exc_saida;
            END IF;
          END IF;

          -- Cursor com os dados da Linha de Credito
          OPEN cr_craplcr(pr_cdlcremp => pr_cdlcremp);
          FETCH cr_craplcr 
           INTO rw_craplcr;

          -- Se nao encontrar
          IF cr_craplcr%NOTFOUND THEN
            -- Fecha o cursor
            CLOSE cr_craplcr;
            vr_dscritic := 'Linha de Credito nao cadastrada.';
            RAISE vr_exc_saida;
          ELSE
            -- Fecha o cursor
            CLOSE cr_craplcr;
            -- Se a Linha de Credito estiver bloqueada
            IF rw_craplcr.flgstlcr = 0 THEN
              vr_dscritic := 'Linha de Credito esta bloqueada.';
              RAISE vr_exc_saida;
            ELSE
              -- Verifica se a Linha de Credito pertence a Finalidade
              OPEN cr_craplch(pr_cdcooper => vr_cdcooper
                             ,pr_cdfinemp => pr_cdfinemp
                             ,pr_cdlcrhab => pr_cdlcremp);
              FETCH cr_craplch 
               INTO rw_craplch;

              -- Se nao encontrar
              IF cr_craplch%NOTFOUND THEN
                -- Fecha o cursor
                CLOSE cr_craplch;
                vr_dscritic := 'Linha de Credito nao pertence a Finalidade escolhida.';
                RAISE vr_exc_saida;
              END IF;
              -- Fecha o cursor
              CLOSE cr_craplch;
            END IF;
          END IF;

          vr_dsrisdop := '';

          IF pr_vllimcra > 0 THEN
            vr_dsrisdop := vr_dsrisdop || 'A;';
          END IF;

          IF pr_vllimcrb > 0 THEN
            vr_dsrisdop := vr_dsrisdop || 'B;';
          END IF;

          IF pr_vllimcrc > 0 THEN
            vr_dsrisdop := vr_dsrisdop || 'C;';
          END IF;

          IF pr_vllimcrd > 0 THEN
            vr_dsrisdop := vr_dsrisdop || 'D;';
          END IF;

          IF pr_vllimcre > 0 THEN
            vr_dsrisdop := vr_dsrisdop || 'E;';
          END IF;

          IF pr_vllimcrf > 0 THEN
            vr_dsrisdop := vr_dsrisdop || 'F;';
          END IF;

          IF pr_vllimcrg > 0 THEN
            vr_dsrisdop := vr_dsrisdop || 'G;';
          END IF;

          IF pr_vllimcrh > 0 THEN
            vr_dsrisdop := vr_dsrisdop || 'H;';
          END IF;

          -- Seta os tipos de risco sem o ultimo ';'
          vr_dsrisdop := SUBSTR(vr_dsrisdop,1,(LENGTH(vr_dsrisdop) - 1));

          -- Alteracao
          IF pr_cddopcao = 'A' THEN

              BEGIN
                vr_dtaltcad := to_char(SYSDATE,'dd/mm/yyyy hh24:mi:ss');
                vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                                    ,pr_cdcooper => vr_cdcooper
                                                    ,pr_nmsubdir => '/log');

                -- Abrir arquivo em modo de adição
                gene0001.pc_abre_arquivo(pr_nmdireto => vr_dsdireto
                                        ,pr_nmarquiv => 'cadpre.log'
                                        ,pr_tipabert => 'A'
                                        ,pr_utlfileh => vr_utlfileh
                                        ,pr_des_erro => vr_dscritic);

                -- Verifica se ocorreram erros
                IF vr_dscritic IS NOT NULL THEN
                  RAISE vr_exc_saida;
                END IF;

                IF rw_crappre.cdfinemp <> pr_cdfinemp THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Codigo da Finalidade de ' 
                                 || rw_crappre.cdfinemp || ' para ' || pr_cdfinemp;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.cdlcremp <> pr_cdlcremp THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Codigo da Linha Credito de ' 
                                 || rw_crappre.cdlcremp || ' para ' || pr_cdlcremp;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.nrmcotas <> pr_nrmcotas THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Multiplicar Cotas Capital de ' 
                                 || rw_crappre.nrmcotas || ' para ' || pr_nrmcotas;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.dssitdop <> pr_dssitdop THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Situacao das Contas de ' 
                                 || rw_crappre.dssitdop || ' para ' || pr_dssitdop;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.qtmescta <> pr_qtmescta THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Tempo de Conta de ' 
                                 || rw_crappre.qtmescta || ' para ' || pr_qtmescta;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.qtmesadm <> pr_qtmesadm THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Tempo Admissao Emprego Atual de ' 
                                 || rw_crappre.qtmesadm || ' para ' || pr_qtmesadm;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.qtmesemp <> pr_qtmesemp THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Tempo Fundacao Empresa de ' 
                                 || rw_crappre.qtmesemp || ' para ' || pr_qtmesemp;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.nrrevcad <> pr_nrrevcad THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Revisao Cadastral de ' 
                                 || rw_crappre.nrrevcad || ' para ' || pr_nrrevcad;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.vllimmin <> pr_vllimmin THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Limite Minimo Ofertado de ' 
                                 || rw_crappre.vllimmin || ' para ' || pr_vllimmin;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.vllimctr <> pr_vllimctr THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Limite Minimo Contratacao de ' 
                                 || rw_crappre.vllimctr || ' para ' || pr_vllimctr;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.vlmulpli <> pr_vlmulpli THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Valores Multiplos de ' 
                                 || rw_crappre.vlmulpli || ' para ' || pr_vlmulpli;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.vlpercom <> pr_vlpercom THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Comprometimento de Renda de ' 
                                 || rw_crappre.vlpercom || ' para ' || pr_vlpercom;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.vlmaxleg <> pr_vlmaxleg THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Multiplicar Valor Max. Legal de ' 
                                 || rw_crappre.vlmaxleg || ' para ' || pr_vlmaxleg;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.vllimcra <> pr_vllimcra THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Limite Operacao Risco A de ' 
                                 || rw_crappre.vllimcra || ' para ' || pr_vllimcra;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.vllimcrb <> pr_vllimcrb THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Limite Operacao Risco B de ' 
                                 || rw_crappre.vllimcrb || ' para ' || pr_vllimcrb;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.vllimcrc <> pr_vllimcrc THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Limite Operacao Risco C de ' 
                                 || rw_crappre.vllimcrc || ' para ' || pr_vllimcrc;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.vllimcrd <> pr_vllimcrd THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Limite Operacao Risco D de ' 
                                 || rw_crappre.vllimcrd || ' para ' || pr_vllimcrd;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.vllimcre <> pr_vllimcre THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Limite Operacao Risco E de ' 
                                 || rw_crappre.vllimcre || ' para ' || pr_vllimcre;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.vllimcrf <> pr_vllimcrf THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Limite Operacao Risco F de ' 
                                 || rw_crappre.vllimcrf || ' para ' || pr_vllimcrf;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.vllimcrg <> pr_vllimcrg THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Limite Operacao Risco G de ' 
                                 || rw_crappre.vllimcrg || ' para ' || pr_vllimcrg;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.vllimcrh <> pr_vllimcrh THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Limite Operacao Risco H de ' 
                                 || rw_crappre.vllimcrh || ' para ' || pr_vllimcrh;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.dslstali <> pr_dslstali THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Alineas de Devolucoes de ' 
                                 || rw_crappre.dslstali || ' para ' || pr_dslstali;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.qtdevolu <> pr_qtdevolu THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Quantidade de devolucoes de ' 
                                 || rw_crappre.qtdevolu || ' para ' || pr_qtdevolu;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.qtdiadev <> pr_qtdiadev THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Periodo de devolucoes de ' 
                                 || rw_crappre.qtdiadev || ' para ' || pr_qtdiadev;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.qtctaatr <> pr_qtctaatr THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Conta Corrente em Atraso de ' 
                                 || rw_crappre.qtctaatr || ' para ' || pr_qtctaatr;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.qtepratr <> pr_qtepratr THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Emprestimo em Atraso de ' 
                                 || rw_crappre.qtepratr || ' para ' || pr_qtepratr;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.qtestour <> pr_qtestour THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Quantidade de Estouro de ' 
                                 || rw_crappre.qtestour || ' para ' || pr_qtestour;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                IF rw_crappre.qtdiaest <> pr_qtdiaest THEN
                  vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                 || ' alterou o campo Periodo de Estouro de ' 
                                 || rw_crappre.qtdiaest || ' para ' || pr_qtdiaest;
                  -- Gravar linha no arquivo
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                                ,pr_des_text => vr_dsclinha);
                END IF;

                -- Fechar arquivo
                gene0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfileh);

                UPDATE crappre SET 
                  cdfinemp = pr_cdfinemp, cdlcremp = pr_cdlcremp, nrmcotas = pr_nrmcotas, 
                  dssitdop = pr_dssitdop, qtmescta = pr_qtmescta, qtmesadm = pr_qtmesadm, 
                  qtmesemp = pr_qtmesemp, nrrevcad = pr_nrrevcad, vllimmin = pr_vllimmin, 
                  vllimctr = pr_vllimctr, vlmulpli = pr_vlmulpli, vlpercom = pr_vlpercom, 
                  vlmaxleg = pr_vlmaxleg, dsrisdop = vr_dsrisdop, vllimcra = pr_vllimcra, 
                  vllimcrb = pr_vllimcrb, vllimcrc = pr_vllimcrc, vllimcrd = pr_vllimcrd, 
                  vllimcre = pr_vllimcre, vllimcrf = pr_vllimcrf, vllimcrg = pr_vllimcrg, 
                  vllimcrh = pr_vllimcrh, dslstali = pr_dslstali, qtdevolu = pr_qtdevolu, 
                  qtdiadev = pr_qtdiadev, qtctaatr = pr_qtctaatr, qtepratr = pr_qtepratr,
                  qtestour = pr_qtestour, qtdiaest = pr_qtdiaest
                WHERE cdcooper = vr_cdcooper
                  AND inpessoa = pr_inpessoa;

                COMMIT;

              EXCEPTION
                WHEN OTHERS THEN
                vr_dscritic := 'Problema ao atualizar Regra: ' || sqlerrm;
                RAISE vr_exc_saida;
              END;

          END IF;

        END IF;

    EXCEPTION
      WHEN vr_null THEN
        NULL;
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em CRAPPRE: ' || SQLERRM;
        
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_tela_cadpre;
  
  PROCEDURE pc_consultar_carga (pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                               ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                               ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                               ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                               ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                               ,pr_des_erro OUT VARCHAR2) IS

  BEGIN

    /* .............................................................................

     Programa: pc_consultar_carga
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : James Prust Junior
     Data    : Junho/14.                    Ultima atualizacao: 11/01/2016

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina geral de CRUD da tela CADPRE.

     Observacao: -----

     Alteracoes: 11/01/2016 - Reformulacao para buscar as cargas da tabela 
                              TBEPR_CARGA_PRE_APRV - Pre-Aprovado fase II.
                              (Jaison/Anderson)
                 24/03/2016 - Alteração para trazer apenas as últimas 3 cargas,
                              sendo que entre elas, obrigatoriamente deve estar
                              a carga liberada.

     ..............................................................................*/ 
    DECLARE
      -- Selecionar os dados
      CURSOR cr_carga (pr_cdcooper IN tbepr_carga_pre_aprv.cdcooper%TYPE) IS
        SELECT carga.idcarga,
               TO_CHAR(carga.dtcalculo,'DD/MM/RRRR') dtcalculo,
               TO_CHAR(carga.dtcalculo,'HH24:MI:SS') hora,
               DECODE(carga.flgcarga_bloqueada,0,'Liberada','Bloqueada') situacao,
               CASE carga.indsituacao_carga
                 WHEN 1 THEN 'Gerada'
                 WHEN 2 THEN 'Solicitada'
                 WHEN 3 THEN 'Executando'
               END status,
               TO_CHAR(NVL(carga.vltotal_pre_aprv_pf,0) + 
                       NVL(carga.vltotal_pre_aprv_pj,0),'FM999G999G999G990D00') vltotal
          FROM tbepr_carga_pre_aprv carga
         WHERE carga.cdcooper = pr_cdcooper
           /* Trazer as últimas três cargas e entre elas tem que estar a carga liberada */
           AND carga.idcarga in (select idcarga
                                   from(
                                        SELECT epr.idcarga
                                          FROM tbepr_carga_pre_aprv epr
                                         WHERE epr.cdcooper = pr_cdcooper
                                      ORDER BY epr.flgcarga_bloqueada, epr.dtcalculo DESC
                                       ) origem
                                   where rownum <= 3);
    
      -- Variaveis de log
      vr_cdcooper  NUMBER;
      vr_cdoperad  VARCHAR2(100);
      vr_nmdatela  VARCHAR2(100);
      vr_nmeacao   VARCHAR2(100);
      vr_cdagenci  VARCHAR2(100);
      vr_nrdcaixa  VARCHAR2(100);
      vr_idorigem  VARCHAR2(100);

      -- Variaveis
      vr_auxconta INTEGER := 0;
      vr_dscritic VARCHAR2(10000);
      
      BEGIN
        GENE0004.pc_extrai_dados(pr_xml      => pr_retxml 
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao 
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => pr_dscritic);
        -- Incluir nome
        GENE0001.pc_informa_acesso(pr_module => vr_nmdatela
                                  ,pr_action => NULL);

        -- Criar cabecalho do XML
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Root'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'Dados'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);

        -- Busca as cargas
        FOR rw_carga IN cr_carga (pr_cdcooper => vr_cdcooper) LOOP
          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'Dados'
                                ,pr_posicao  => 0
                                ,pr_tag_nova => 'carga'
                                ,pr_tag_cont => NULL
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'carga'
                                ,pr_posicao  => vr_auxconta
                                ,pr_tag_nova => 'idcarga'
                                ,pr_tag_cont => rw_carga.idcarga
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'carga'
                                ,pr_posicao  => vr_auxconta
                                ,pr_tag_nova => 'dtcalculo'
                                ,pr_tag_cont => rw_carga.dtcalculo
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'carga'
                                ,pr_posicao  => vr_auxconta
                                ,pr_tag_nova => 'hora'
                                ,pr_tag_cont => rw_carga.hora
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'carga'
                                ,pr_posicao  => vr_auxconta
                                ,pr_tag_nova => 'situacao'
                                ,pr_tag_cont => rw_carga.situacao
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'carga'
                                ,pr_posicao  => vr_auxconta
                                ,pr_tag_nova => 'status'
                                ,pr_tag_cont => rw_carga.status
                                ,pr_des_erro => vr_dscritic);

          GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                                ,pr_tag_pai  => 'carga'
                                ,pr_posicao  => vr_auxconta
                                ,pr_tag_nova => 'vltotal'
                                ,pr_tag_cont => rw_carga.vltotal
                                ,pr_des_erro => vr_dscritic);

          vr_auxconta := vr_auxconta + 1;
        END LOOP;

      EXCEPTION        
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro geral em CRAPPRE: ' || SQLERRM;
          
          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
          ROLLBACK;
      END;
    
  END pc_consultar_carga;
  
  PROCEDURE pc_busca_carga_ativa (pr_cdcooper  IN tbepr_carga_pre_aprv.cdcooper%TYPE    --> Codigo da cooperativa
                                 ,pr_idcarga  OUT tbepr_carga_pre_aprv.idcarga%TYPE) IS --> Codigo da carga
  BEGIN

    /* .............................................................................

     Programa: pc_busca_carga_ativa
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Jaison
     Data    : Janeiro/2016                    Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Busca a carga ativa.

     Observacao: -----

     Alteracoes: 

     ..............................................................................*/

    DECLARE
      -- Selecionar os dados
      CURSOR cr_carga (pr_cdcooper IN tbepr_carga_pre_aprv.cdcooper%TYPE) IS
        SELECT carga.idcarga
          FROM tbepr_carga_pre_aprv carga
         WHERE carga.cdcooper = pr_cdcooper
           AND carga.indsituacao_carga = 1 -- Gerada
           AND carga.flgcarga_bloqueada = 0; -- Liberada
      rw_carga cr_carga%ROWTYPE;

      -- Variaveis
      vr_blnfound BOOLEAN;

    BEGIN
      -- Efetua a busca do registro
      OPEN cr_carga(pr_cdcooper => pr_cdcooper);
      FETCH cr_carga INTO rw_carga;
      -- Alimenta a booleana se achou ou nao
      vr_blnfound := cr_carga%FOUND;
      -- Fecha cursor
      CLOSE cr_carga;

      -- Se achou
      IF vr_blnfound THEN
        pr_idcarga := rw_carga.idcarga;
      ELSE
        pr_idcarga := 0;
      END IF;
    END;
    
  END pc_busca_carga_ativa;
  
  PROCEDURE pc_exclui_carga_bloqueada (pr_cdcooper IN  tbepr_carga_pre_aprv.cdcooper%TYPE --> Codigo Cooperativa
                                      ,pr_dscritic OUT VARCHAR2) IS                       --> Retorno de critica

  BEGIN

    /* .............................................................................

     Programa: pc_exclui_carga_bloqueada
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Jaison Fernando
     Data    : Janeiro/2015.                    Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Excluir as cargas bloqueadas.

     Alteracoes: 24/03/2016 - Alteração para excluir apenas as cargas que possuem
                              mais do que 20 dias, para evitar que cargas sejam
                              excluídas sem que tenham sido importadas no BI.
                              Obs.: Na interface será apresentada apenas as últimas
                              3 cargas. (Anderson Fossa).

     ..............................................................................*/ 
    DECLARE
      -- Selecionar os dados
      CURSOR cr_carga(pr_cdcooper IN tbepr_carga_pre_aprv.cdcooper%TYPE) IS
        SELECT carga.idcarga
          FROM tbepr_carga_pre_aprv carga
         WHERE carga.cdcooper = pr_cdcooper
           /* Vamos apagar apenas os registros que tenham mais do que 20 dias 
              para evitar apagar dados que ainda não foram importados para o BI */
           AND carga.dtcalculo <= trunc(sysdate - 20)
           AND carga.flgcarga_bloqueada = 1; -- Bloqueada

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_dscritic  VARCHAR2(10000);
     
    BEGIN
      -- Percorre todas as cargas bloqueadas
      FOR rw_carga IN cr_carga(pr_cdcooper => pr_cdcooper) LOOP
        BEGIN
          -- Exclui os motivos
          DELETE 
            FROM tbepr_motivo_nao_aprv motivo
           WHERE motivo.cdcooper = pr_cdcooper
             AND motivo.idcarga = rw_carga.idcarga;
          -- Exclui os creditos
          DELETE 
            FROM crapcpa 
           WHERE crapcpa.cdcooper = pr_cdcooper
             AND crapcpa.iddcarga = rw_carga.idcarga;
          -- Exclui a carga
          DELETE 
            FROM tbepr_carga_pre_aprv carga 
           WHERE carga.cdcooper = pr_cdcooper
             AND carga.idcarga = rw_carga.idcarga;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao excluir a Carga. ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
      END LOOP;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral em tbepr_carga_pre_aprv: ' || SQLERRM;
    END;
    
  END pc_exclui_carga_bloqueada;
  
  PROCEDURE pc_gerar_carga (pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) IS

  BEGIN

    /* .............................................................................

     Programa: pc_gerar_carga
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : James Prust Junior
     Data    : Junho/14.                    Ultima atualizacao: 12/01/2016

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina geral de CRUD da tela CADPRE.

     Alteracoes: 26/11/2014 - Ajustado para somente permitir gerar a carga quando o departamento 
                              do usuario for Produtos ou TI. (James)

                 12/01/2016 - Reformulacao para gerar as cargas - Pre-Aprovado fase II.
                              (Jaison/Anderson)

     ..............................................................................*/ 
    DECLARE
      -- Selecionar os dados
      CURSOR cr_carga(pr_cdcooper IN tbepr_carga_pre_aprv.cdcooper%TYPE) IS
        SELECT carga.idcarga,
               carga.indsituacao_carga
          FROM tbepr_carga_pre_aprv carga
         WHERE carga.cdcooper = pr_cdcooper
           AND carga.indsituacao_carga IN (2,3); -- 2-Solicitada / 3–Executando
      rw_carga cr_carga%ROWTYPE;
    
      -- Variável de críticas
      vr_exc_saida EXCEPTION;

      -- Variaveis de log
      vr_cdcooper  NUMBER;
      vr_cdoperad  VARCHAR2(100);
      vr_nmdatela  VARCHAR2(100);
      vr_nmeacao   VARCHAR2(100);
      vr_cdagenci  VARCHAR2(100);
      vr_nrdcaixa  VARCHAR2(100);
      vr_idorigem  VARCHAR2(100);
      
      -- Variaveis de geracao
      vr_blnfound  BOOLEAN;
      vr_dsplsql   VARCHAR2(4000); -- Bloco PLSQL para chamar a execução paralela do pc_crps682
      vr_jobname   VARCHAR2(30);   -- Job name dos processos criados
      vr_idcarga   tbepr_carga_pre_aprv.idcarga%TYPE;
     
      BEGIN
        GENE0004.pc_extrai_dados(pr_xml      => pr_retxml 
                                ,pr_cdcooper => vr_cdcooper
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_nmeacao  => vr_nmeacao 
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_idorigem => vr_idorigem
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_dscritic => pr_dscritic);

        -- Valida o operador
        EMPR0002.pc_valida_operador(pr_cdcooper => vr_cdcooper
                                   ,pr_cdoperad => vr_cdoperad
                                   ,pr_dscritic => pr_dscritic);
        -- Se possui critica
        IF pr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        -- Efetua a busca do registro
        OPEN cr_carga(pr_cdcooper => vr_cdcooper);
        FETCH cr_carga INTO rw_carga;
        -- Alimenta a booleana se achou ou nao
        vr_blnfound := cr_carga%FOUND;
        -- Fecha cursor
        CLOSE cr_carga;

        -- Se achou
        IF vr_blnfound THEN
          pr_dscritic := 'Geracao nao permitida, pois existe carga Solicitada ou Executando.';
          RAISE vr_exc_saida;
        END IF;

        -- Exclui as cargas bloqueadas
        EMPR0002.pc_exclui_carga_bloqueada (pr_cdcooper => vr_cdcooper
                                           ,pr_dscritic => pr_dscritic);
        -- Se possui critica
        IF pr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        -- Cria a carga
        EMPR0002.pc_inclui_carga (pr_cdcooper => vr_cdcooper
                                 ,pr_idcarga  => vr_idcarga
                                 ,pr_dscritic => pr_dscritic);
        -- Se possui critica
        IF pr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;
        
        COMMIT;
        
        -- Chamar o JOB
        -- Montar o bloco PLSQL que será executado
        -- Ou seja, executaremos a geração dos dados
        -- para a agência atual atraves de Job no banco
        vr_dsplsql := 'DECLARE'||chr(13)
                   || '  vr_stprogra NUMBER;'||chr(13)
                   || '  vr_infimsol NUMBER;'||chr(13)
                   || '  vr_cdcritic NUMBER;'||chr(13)
                   || '  vr_dscritic VARCHAR2(4000);'||chr(13)                   
                   || 'BEGIN'||chr(13)
                   || '  pc_crps682('||vr_cdcooper||',0,0,vr_stprogra,vr_infimsol,vr_cdcritic,vr_dscritic);'||chr(13)
                   || 'END;';
                   
        -- Montar o prefixo do código do programa para o jobname
        vr_jobname := 'crps682_'||vr_cdcooper||'$';
        -- Faz a chamada ao programa paralelo atraves de JOB
        GENE0001.pc_submit_job(pr_cdcooper  => vr_cdcooper  --> Código da cooperativa
                              ,pr_cdprogra  => 'CRPS682'    --> Código do programa
                              ,pr_dsplsql   => vr_dsplsql   --> Bloco PLSQL a executar
                              ,pr_dthrexe   => SYSTIMESTAMP --> Executar nesta hora
                              ,pr_interva   => NULL         --> Sem intervalo de execução da fila, ou seja, apenas 1 vez
                              ,pr_jobname   => vr_jobname   --> Nome randomico criado
                              ,pr_des_erro  => pr_dscritic);
        -- Testar saida com erro
        IF pr_dscritic IS NOT NULL THEN
          -- Levantar exceçao
          RAISE vr_exc_saida;
        END IF;
        
      EXCEPTION        
        WHEN vr_exc_saida THEN
          -- Se foi retornado apenas código
          IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
            -- Buscar a descrição
            pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
          END IF;
        
          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
          ROLLBACK;
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro geral em CRAPPRE: ' || SQLERRM;
          
          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
          ROLLBACK;
      END;
    
  END pc_gerar_carga;

  --> Procedimento para buscar dados do credito pré-aprovado (crapcpa)
  PROCEDURE pc_busca_dados_cpa (pr_cdcooper  IN crapcop.cdcooper%TYPE    --> Codigo da cooperativa
                               ,pr_cdagenci  IN crapage.cdagenci%TYPE    --> Código da agencia
                               ,pr_nrdcaixa  IN crapbcx.nrdcaixa%TYPE    --> Numero do caixa
                               ,pr_cdoperad  IN crapope.cdoperad%TYPE    --> Codigo do operador
                               ,pr_nmdatela  IN craptel.nmdatela%TYPE    --> Nome da tela
                               ,pr_idorigem  IN INTEGER                  --> Id origem
                               ,pr_nrdconta  IN crapass.nrdconta%TYPE    --> Numero da conta do cooperado
                               ,pr_idseqttl  IN crapttl.idseqttl%TYPE    --> Sequencial do titular
                               ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE    --> CPF do operador juridico
                               ,pr_tab_dados_cpa OUT typ_tab_dados_cpa   --> Retorna dados do credito pre aprovado
                               ,pr_des_reto      OUT VARCHAR2            --> Retorno OK/NOK
                               ,pr_tab_erro      OUT gene0001.typ_tab_erro) IS --> Retorna os erros

    /* .............................................................................

     Programa: pc_busca_dados_cpa        antigo: b1wgen0188.p/busca_dados
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Odirlei Busana(AMcom)
     Data    : Outubro/2015.                    Ultima atualizacao: 13/01/2016

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Procedimento para buscar dados do credito pré-aprovado (crapcpa)

     Alteracoes: 19/10/2015 - Conversão Progress -> Oracle (Odirlei/AMcom)

                 13/01/2016 - Verificacao de carga ativa - Pre-Aprovado fase II.
                              (Jaison/Anderson)

    ..............................................................................*/ 

    ---------------> CURSORES <-----------------

    -- Verifica se esta na tabela do pre-aprovado
    CURSOR cr_crapcpa (pr_cdcooper IN crapcpa.cdcooper%TYPE,
                       pr_nrdconta IN crapcpa.nrdconta%TYPE,
                       pr_idcarga  IN crapcpa.iddcarga%TYPE) IS
      SELECT cpa.vllimdis
            ,cpa.vlcalpre
            ,cpa.vlctrpre
        FROM crapcpa cpa
       WHERE cpa.cdcooper = pr_cdcooper
         AND cpa.nrdconta = pr_nrdconta
         AND cpa.iddcarga = pr_idcarga;
    rw_crapcpa cr_crapcpa%rowtype;

    --> Verifica se o associado pode obter o credido pre-aprovado
    CURSOR cr_crapass IS
      SELECT ass.cdcooper
            ,ass.nrdconta
            ,ass.flgcrdpa
            ,ass.inpessoa
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    --> Verifica se esta bloqueado o pre-aprovado 
    CURSOR cr_crappre (pr_cdcooper IN crappre.cdcooper%TYPE,
                       pr_inpessoa IN crappre.inpessoa%TYPE)IS
      SELECT pre.cdcooper
            ,pre.cdlcremp
        FROM crappre pre
       WHERE pre.cdcooper = pr_cdcooper
         AND pre.inpessoa = pr_inpessoa;
    rw_crappre cr_crappre%ROWTYPE;     

    --> Buscar linha de credito
    CURSOR cr_craplcr (pr_cdcooper craplcr.cdcooper%TYPE,
                       pr_cdlcremp craplcr.cdlcremp%TYPE)IS
      SELECT lcr.txmensal
        FROM craplcr lcr
       WHERE lcr.cdcooper = pr_cdcooper
         AND lcr.cdlcremp = pr_cdlcremp;
    rw_craplcr cr_craplcr%ROWTYPE;

    ---------------> VARIAVEIS <----------------       

    --> Tratamento de erros
    vr_exc_erro EXCEPTION;
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);

    vr_idx      PLS_INTEGER;
    vr_idcarga  tbepr_carga_pre_aprv.idcarga%TYPE;

  BEGIN

    pr_tab_erro.delete;
    pr_tab_dados_cpa.delete;

    --> Somente o primeiro titular pode contratrar o pre-aprovado e nao 
    --  pode ser operador de conta juridica 
    IF pr_idseqttl > 1 OR pr_nrcpfope > 0 THEN
      pr_des_reto := 'OK';
      RETURN;
    END IF;

    -- Busca a carga ativa
    EMPR0002.pc_busca_carga_ativa(pr_cdcooper => pr_cdcooper
                                 ,pr_idcarga  => vr_idcarga);
    --  Caso nao possua carga ativa
    IF vr_idcarga = 0 THEN
      pr_des_reto := 'OK';
      RETURN;
    END IF;

    --> Verifica se esta na tabela do pre-aprovado
    OPEN cr_crapcpa(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta
                   ,pr_idcarga  => vr_idcarga);
    FETCH cr_crapcpa INTO rw_crapcpa;

    -- caso nao esteja, aborta com ok
    IF cr_crapcpa%NOTFOUND THEN
      CLOSE cr_crapcpa;
      pr_des_reto := 'OK';
      RETURN;  
    ELSE
      CLOSE cr_crapcpa;
    END IF; 

    --> Verifica se o associado pode obter o credido pre-aprovado
    OPEN cr_crapass;
    FETCH cr_crapass INTO rw_crapass;

    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_cdcritic := 9; --> Associado nao cadastrado
      vr_dscritic := NULL;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapass;
    END IF;

    --> Na tela de contas nao podemos verificar a flag 
    IF pr_nmdatela <> 'CONTAS'AND
       rw_crapass.flgcrdpa = 0 /* FALSE */ THEN
      pr_des_reto := 'OK';
      RETURN; 
    END IF;

    --> Verifica se esta bloqueado o pre-aprovado 
    OPEN cr_crappre(pr_cdcooper => rw_crapass.cdcooper,
                    pr_inpessoa => rw_crapass.inpessoa);
    FETCH cr_crappre INTO rw_crappre;

    IF cr_crappre%NOTFOUND THEN
      CLOSE cr_crappre;
      vr_cdcritic := 0;
      vr_dscritic := 'Parametros pre-aprovado nao cadastrado';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crappre;
    END IF;

    --> Buscar linha de credito
    OPEN cr_craplcr (pr_cdcooper => rw_crappre.cdcooper,
                     pr_cdlcremp => rw_crappre.cdlcremp);
    FETCH cr_craplcr INTO rw_craplcr;

    IF cr_craplcr%NOTFOUND THEN
       CLOSE cr_craplcr;
      vr_cdcritic := 363; --> Linha nao cadastrada.
      vr_dscritic := NULL;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_craplcr;
    END IF;

    --> Carregar temptable
    vr_idx := pr_tab_dados_cpa.count + 1;
    pr_tab_dados_cpa(vr_idx).cdcooper := rw_crapass.cdcooper;
    pr_tab_dados_cpa(vr_idx).nrdconta := rw_crapass.nrdconta;
    pr_tab_dados_cpa(vr_idx).inpessoa := rw_crapass.inpessoa;
    pr_tab_dados_cpa(vr_idx).vldiscrd := rw_crapcpa.vllimdis;
    pr_tab_dados_cpa(vr_idx).txmensal := rw_craplcr.txmensal;

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno não OK
      pr_des_reto := 'NOK';

      -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro); 
    WHEN OTHERS THEN
      -- Retorno não OK
      pr_des_reto := 'NOK';
      -- Montar descrição de erro não tratado
      vr_dscritic := 'Erro na rotina EMPR0002.pc_busca_dados_cpa: ' ||sqlerrm;
      -- Gerar rotina de gravação de erro avisando sobre o erro não tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => 0
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
  END pc_busca_dados_cpa;

  PROCEDURE pc_busca_dados_cpa_prog (pr_cdcooper  IN crapcop.cdcooper%TYPE    --> Codigo da cooperativa
                                    ,pr_cdagenci  IN crapage.cdagenci%TYPE    --> Código da agencia
                                    ,pr_nrdcaixa  IN crapbcx.nrdcaixa%TYPE    --> Numero do caixa
                                    ,pr_cdoperad  IN crapope.cdoperad%TYPE    --> Codigo do operador
                                    ,pr_nmdatela  IN craptel.nmdatela%TYPE    --> Nome da tela
                                    ,pr_idorigem  IN INTEGER                  --> Id origem
                                    ,pr_nrdconta  IN crapass.nrdconta%TYPE    --> Numero da conta do cooperado
                                    ,pr_idseqttl  IN crapttl.idseqttl%TYPE    --> Sequencial do titular
                                    ,pr_nrcpfope  IN crapopi.nrcpfope%TYPE    --> CPF do operador juridico
                                    ,pr_clob_cpa  OUT CLOB                --> Retorna dados do credito pre aprovado
                                    ,pr_des_reto  OUT VARCHAR2            --> Retorno OK/NOK
                                    ,pr_clob_erro OUT CLOB) IS            --> Retorna os erros
  BEGIN

    /* .............................................................................

     Programa: pc_busca_dados_cpa_prog        antigo: b1wgen0188.p/busca_dados
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Jaison
     Data    : Janeiro/2016                    Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Busca dados do credito pré-aprovado (crapcpa) pelo Progress.

     Alteracoes: 

    ..............................................................................*/ 

    DECLARE
      -- Variaveis
      vr_tab_erro      GENE0001.typ_tab_erro;
      vr_tab_dados_cpa EMPR0002.typ_tab_dados_cpa;
      vr_dscritic      VARCHAR2(4000);
      vr_idx           PLS_INTEGER;
      vr_xml_temp      VARCHAR2(32767);

    BEGIN
      -- Procedimento para buscar dados do credito pré-aprovado (crapcpa)
      EMPR0002.pc_busca_dados_cpa (pr_cdcooper  => pr_cdcooper   --> Codigo da cooperativa
                                  ,pr_cdagenci  => pr_cdagenci   --> Código da agencia
                                  ,pr_nrdcaixa  => pr_nrdcaixa   --> Numero do caixa
                                  ,pr_cdoperad  => pr_cdoperad   --> Codigo do operador
                                  ,pr_nmdatela  => pr_nmdatela   --> Nome da tela
                                  ,pr_idorigem  => pr_idorigem   --> Id origem
                                  ,pr_nrdconta  => pr_nrdconta   --> Numero da conta do cooperado
                                  ,pr_idseqttl  => pr_idseqttl   --> Sequencial do titular
                                  ,pr_nrcpfope  => pr_nrcpfope   --> CPF do operador juridico
                                  ------ OUT --------
                                  ,pr_tab_dados_cpa => vr_tab_dados_cpa  --> Retorna dados do credito pre aprovado
                                  ,pr_des_reto      => pr_des_reto       --> Retorno OK/NOK
                                  ,pr_tab_erro      => vr_tab_erro);     --> Retorna os erros

      -- Gerar xml a partir da temptable
      IF vr_tab_erro.count > 0 THEN
        GENE0001.pc_xml_tab_erro(pr_tab_erro => vr_tab_erro, --> TempTable de erro
                                 pr_xml_erro => pr_clob_erro, --> XML dos registros da temptable de erro
                                 pr_tipooper => 1,           --> Tipo de operação, 1 - Gerar XML, 2 --Gerar pltable
                                 pr_dscritic => vr_dscritic);
      END IF;
      
      -- Chave inicial
      vr_idx := vr_tab_dados_cpa.FIRST;
      -- Se existir e possuir valor
      IF vr_tab_dados_cpa.EXISTS(vr_idx) AND 
         vr_tab_dados_cpa(vr_idx).vldiscrd > 0 THEN

        -- Criar documento XML
        dbms_lob.createtemporary(pr_clob_cpa, TRUE);
        dbms_lob.open(pr_clob_cpa, dbms_lob.lob_readwrite);

        -- Insere o cabeçalho do XML 
        GENE0002.pc_escreve_xml(pr_xml            => pr_clob_cpa 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><raiz>');
                               
        -- Escreve o registro
        GENE0002.pc_escreve_xml(pr_xml            => pr_clob_cpa
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo => '<registro>'||
                                                   '<cdcooper>'||vr_tab_dados_cpa(vr_idx).cdcooper||'</cdcooper>'||
                                                   '<nrdconta>'||vr_tab_dados_cpa(vr_idx).nrdconta||'</nrdconta>'||
                                                   '<inpessoa>'||vr_tab_dados_cpa(vr_idx).inpessoa||'</inpessoa>'||
                                                   '<vldiscrd>'||vr_tab_dados_cpa(vr_idx).vldiscrd||'</vldiscrd>'||
                                                   '<txmensal>'||vr_tab_dados_cpa(vr_idx).txmensal||'</txmensal>'||
                                                 '</registro>');

        -- Encerrar a tag raiz 
        GENE0002.pc_escreve_xml(pr_xml            => pr_clob_cpa 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => '</raiz>' 
                               ,pr_fecha_xml      => TRUE);

      END IF;

    END;

  END pc_busca_dados_cpa_prog;
  
  PROCEDURE pc_busca_alinea(pr_xmllog   IN VARCHAR2           --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER       --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2          --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2          --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) IS

  BEGIN

    /* .............................................................................

     Programa: pc_busca_alinea
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Jaison Fernando
     Data    : Janeiro/2015.                    Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Buscar os dados da Alineas.

     Alteracoes: 

     ..............................................................................*/ 
    DECLARE
      -- Selecionar os dados
      CURSOR cr_crapali IS
        SELECT cdalinea
              ,dsalinea
              ,COUNT(1) OVER() qtregist
          FROM crapali
      ORDER BY cdalinea;

      -- Variaveis
      vr_auxconta INTEGER := 0;
      vr_dscritic VARCHAR2(10000);
     
    BEGIN
      -- Criar cabecalho do XML
      pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

      GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'Dados'
                            ,pr_tag_cont => NULL
                            ,pr_des_erro => vr_dscritic);

      -- Busca as Alineas
      FOR rw_crapali IN cr_crapali LOOP
        -- Cria atributo
        IF vr_auxconta = 0 THEN
          GENE0007.pc_gera_atributo(pr_xml      => pr_retxml
                                   ,pr_tag      => 'Dados'
                                   ,pr_atrib    => 'qtregist'
                                   ,pr_atval    => rw_crapali.qtregist
                                   ,pr_numva    => 0
                                   ,pr_des_erro => vr_dscritic);
        END IF;

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'Dados'
                              ,pr_posicao  => 0
                              ,pr_tag_nova => 'alinea'
                              ,pr_tag_cont => NULL
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'alinea'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'cdalinea'
                              ,pr_tag_cont => rw_crapali.cdalinea
                              ,pr_des_erro => vr_dscritic);

        GENE0007.pc_insere_tag(pr_xml      => pr_retxml
                              ,pr_tag_pai  => 'alinea'
                              ,pr_posicao  => vr_auxconta
                              ,pr_tag_nova => 'dsalinea'
                              ,pr_tag_cont => rw_crapali.dsalinea
                              ,pr_des_erro => vr_dscritic);

        vr_auxconta := vr_auxconta + 1;
      END LOOP;
        
    EXCEPTION        
        WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro geral em CRAPPRE: ' || SQLERRM;
          
          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
          ROLLBACK;
    END;
    
  END pc_busca_alinea;
  
  PROCEDURE pc_atualiza_flag_credito(pr_cdcooper IN crapcop.cdcooper%TYPE             --> Codigo da cooperativa
                                    ,pr_idcarga  IN tbepr_carga_pre_aprv.idcarga%TYPE --> Codigo da Carga
                                    ,pr_dscritic OUT VARCHAR2) IS                     --> Descricao da critica
  BEGIN

    /* .............................................................................

     Programa: pc_atualiza_flag_credito
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Jaison Fernando
     Data    : Janeiro/2015.                    Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Atualiza a flag de credito flgcrdpa na tabela crapass.

     Alteracoes: 

     ..............................................................................*/ 
    DECLARE
      -- Registros atualizaveis
      CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_idcarga  IN tbepr_carga_pre_aprv.idcarga%TYPE) IS
        SELECT crapass.cdcooper
              ,crapass.nrdconta
              ,crapass.cdoplcpa
              ,NVL(crapass.flgcrdpa,0) flgcrdpa
              ,CASE WHEN EXISTS (SELECT 1
                                   FROM crapcpa
                                  WHERE crapcpa.cdcooper = crapass.cdcooper                               
                                    AND crapcpa.nrdconta = crapass.nrdconta
                                    AND crapcpa.iddcarga = pr_idcarga)
                 THEN 1
                 ELSE 0
              END flgcrdpa_novo
          FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND( (crapass.flgcrdpa = 1) -- Tem pre-aprovado
            OR  (crapass.flgcrdpa = 0 AND 
                TRIM(crapass.cdoplcpa) IS NULL) ); -- Nao tem pre-aprovado e nao foi setado manualmente
      rw_crapass cr_crapass%ROWTYPE;

      -- Variaveis
      vr_idx       PLS_INTEGER;
      vr_idcarga   tbepr_carga_pre_aprv.idcarga%TYPE;

      -- PL Table
      TYPE typ_reg_crapass IS
           RECORD (cdcooper crapass.cdcooper%TYPE
                  ,nrdconta crapass.nrdconta%TYPE
                  ,cdoplcpa crapass.cdoplcpa%TYPE
                  ,flgcrdpa crapass.flgcrdpa%TYPE
                  ,cd_rowid ROWID);
      TYPE typ_tab_crapass IS 
           TABLE OF typ_reg_crapass INDEX BY PLS_INTEGER;
      vr_tab_crapass typ_tab_crapass;

    BEGIN
      -- Busca a carga ativa
      EMPR0002.pc_busca_carga_ativa(pr_cdcooper => pr_cdcooper
                                   ,pr_idcarga  => vr_idcarga);

      -- Carrega os registros
      FOR rw_crapass IN cr_crapass(pr_cdcooper => pr_cdcooper
                                  ,pr_idcarga  => vr_idcarga) LOOP
        -- Se nova flag for diferente ou operador setou manualmente, adicionar para update
        IF rw_crapass.flgcrdpa <> rw_crapass.flgcrdpa_novo 
        OR TRIM(rw_crapass.cdoplcpa) IS NOT NULL THEN
          vr_idx := vr_tab_crapass.COUNT + 1;
          vr_tab_crapass(vr_idx).cdcooper := rw_crapass.cdcooper;
          vr_tab_crapass(vr_idx).nrdconta := rw_crapass.nrdconta;
          vr_tab_crapass(vr_idx).flgcrdpa := rw_crapass.flgcrdpa_novo;
          -- Vamos zerar o operador, pois se a nova flag de pre-aprovado for FALSE e
          -- tiver preenchido o operador, o usuario conseguira alterar manualmente
          vr_tab_crapass(vr_idx).cdoplcpa := ' ';
        END IF;
      END LOOP;
        
      BEGIN
        FORALL idx IN 1..vr_tab_crapass.COUNT SAVE EXCEPTIONS
          UPDATE crapass
             SET crapass.cdoplcpa = vr_tab_crapass(idx).cdoplcpa,
                 crapass.flgcrdpa = vr_tab_crapass(idx).flgcrdpa
           WHERE crapass.cdcooper = vr_tab_crapass(idx).cdcooper
             AND crapass.nrdconta = vr_tab_crapass(idx).nrdconta;
      EXCEPTION
        WHEN OTHERS THEN
          pr_dscritic := 'Erro ao atualizar CRAPASS com Merge. ' || SQLERRM(-SQL%BULK_EXCEPTIONS(1).ERROR_CODE);
      END;

    END;
    
  END pc_atualiza_flag_credito;
  
  PROCEDURE pc_altera_carga(pr_idcarga  IN tbepr_carga_pre_aprv.idcarga%TYPE --> Codigo da Carga
                           ,pr_acao     IN VARCHAR2                          --> Acao: B-Bloquear / L-Liberar
                           ,pr_xmllog   IN VARCHAR2                          --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER                      --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2                         --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType                --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2                         --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) IS

  BEGIN

    /* .............................................................................

     Programa: pc_altera_carga
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Jaison Fernando
     Data    : Janeiro/2015.                    Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Bloquear/Liberar a Carga.

     Alteracoes: 

     ..............................................................................*/ 
    DECLARE
      -- Selecionar os dados
      CURSOR cr_carga(pr_idcarga IN tbepr_carga_pre_aprv.idcarga%TYPE) IS
        SELECT carga.idcarga
              ,carga.indsituacao_carga
              ,carga.flgcarga_bloqueada
          FROM tbepr_carga_pre_aprv carga
         WHERE carga.idcarga = pr_idcarga;
      rw_carga cr_carga%ROWTYPE;

      -- Variaveis de log
      vr_cdcooper NUMBER;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Variaveis
      vr_blnfound BOOLEAN;
      vr_flbloque INTEGER;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_dscritic  VARCHAR2(10000);
     
    BEGIN
      GENE0004.pc_extrai_dados(pr_xml      => pr_retxml 
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao 
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Valida o operador
      EMPR0002.pc_valida_operador(pr_cdcooper => vr_cdcooper
                                 ,pr_cdoperad => vr_cdoperad
                                 ,pr_dscritic => vr_dscritic);
      -- Se possui critica
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      -- Efetua a busca do registro
      OPEN cr_carga(pr_idcarga => pr_idcarga);
      FETCH cr_carga INTO rw_carga;
      -- Alimenta a booleana se achou ou nao
      vr_blnfound := cr_carga%FOUND;
      -- Fecha cursor
      CLOSE cr_carga;

      -- Se nao achou
      IF NOT vr_blnfound THEN
        vr_dscritic := 'Carga nao encontrada.';
        RAISE vr_exc_saida;
      END IF;
      
      IF pr_acao = 'B' THEN
        vr_flbloque := 1; -- Bloquear
      ELSE
        vr_flbloque := 0; -- Liberar
      END IF;

      -- Se ja estiver bloqueada(1) / liberada(0)
      IF rw_carga.flgcarga_bloqueada = vr_flbloque THEN
        IF pr_acao = 'B' THEN
          vr_dscritic := 'Carga selecionada ja esta Bloqueada.';
        ELSE
          vr_dscritic := 'Carga selecionada ja esta Liberada.';
        END IF;
        RAISE vr_exc_saida;
      END IF;

      -- Se nao estiver gerada(1)
      IF rw_carga.indsituacao_carga > 1 THEN
        vr_dscritic := 'A carga selecionada nao foi Gerada.';
        RAISE vr_exc_saida;
      END IF;
      
      BEGIN
        -- Se for uma liberacao
        IF pr_acao = 'L' THEN
          -- Bloquear a carga antiga da cooperativa
          UPDATE tbepr_carga_pre_aprv
             SET tbepr_carga_pre_aprv.flgcarga_bloqueada = 1 -- Bloquear
           WHERE tbepr_carga_pre_aprv.cdcooper = vr_cdcooper;
        END IF;
        -- Bloquear/Liberar a carga passada
        UPDATE tbepr_carga_pre_aprv
           SET tbepr_carga_pre_aprv.flgcarga_bloqueada = vr_flbloque
         WHERE tbepr_carga_pre_aprv.idcarga = rw_carga.idcarga;
      EXCEPTION
        WHEN OTHERS THEN
        vr_dscritic := 'Problema ao atualizar carga: ' || SQLERRM;
        RAISE vr_exc_saida;
      END;

      -- Atualiza a flag de credito flgcrdpa na tabela crapass
      EMPR0002.pc_atualiza_flag_credito(pr_cdcooper => vr_cdcooper
                                       ,pr_idcarga  => rw_carga.idcarga
                                       ,pr_dscritic => vr_dscritic);
      -- Se possui critica
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      COMMIT;
        
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || vr_dscritic || '</Erro></Root>');
        ROLLBACK;

      WHEN OTHERS THEN
          pr_cdcritic := 0;
          pr_dscritic := 'Erro geral em CRAPPRE: ' || SQLERRM;
          
          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
          ROLLBACK;
    END;
    
  END pc_altera_carga;
  
  PROCEDURE pc_inclui_carga (pr_cdcooper IN  tbepr_carga_pre_aprv.cdcooper%TYPE --> Codigo Cooperativa
                            ,pr_idcarga  OUT tbepr_carga_pre_aprv.idcarga%TYPE  --> Codigo da Carga
                            ,pr_dscritic OUT VARCHAR2) IS                       --> Retorno de critica

  BEGIN

    /* .............................................................................

     Programa: pc_inclui_carga
     Sistema : Emprestimo Pre-Aprovado - Cooperativa de Credito
     Sigla   : EMPR
     Autor   : Jaison Fernando
     Data    : Janeiro/2015.                    Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Incluir a Carga.

     Alteracoes: 

     ..............................................................................*/ 
    DECLARE
      -- Selecionar os dados
      CURSOR cr_carga (pr_cdcooper IN tbepr_carga_pre_aprv.cdcooper%TYPE) IS
        SELECT carga.idcarga
          FROM tbepr_carga_pre_aprv carga
         WHERE carga.cdcooper = pr_cdcooper
           AND carga.indsituacao_carga = 2 -- Solicitada
           AND carga.flgcarga_bloqueada = 1; -- Bloqueada

      -- Variaveis
      vr_blnfound BOOLEAN;
      vr_idcarga  tbepr_carga_pre_aprv.idcarga%TYPE;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
      vr_dscritic  VARCHAR2(10000);
     
    BEGIN
      -- Efetua a busca do registro
      OPEN cr_carga (pr_cdcooper => pr_cdcooper);
      FETCH cr_carga INTO vr_idcarga;
      -- Alimenta a booleana se achou ou nao
      vr_blnfound := cr_carga%FOUND;
      -- Fecha cursor
      CLOSE cr_carga;

      -- Se nao achou
      IF NOT vr_blnfound THEN
        -- Inclui uma nova carga
        BEGIN
          INSERT INTO tbepr_carga_pre_aprv
                     (cdcooper
                     ,dtcalculo
                     ,indsituacao_carga
                     ,flgcarga_bloqueada)
              VALUES (pr_cdcooper
                     ,SYSDATE
                     ,2 -- Solicitada
                     ,1) -- Bloqueada
           RETURNING idcarga 
                INTO vr_idcarga;
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Problema ao incluir a carga de Credito Pre Aprovado: ' || SQLERRM;
            RAISE vr_exc_saida;
        END;
      END IF;

      pr_idcarga := vr_idcarga;

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN
        pr_dscritic := 'Erro geral em CRAPPRE: ' || SQLERRM;
    END;
    
  END pc_inclui_carga;

  PROCEDURE pc_limpeza_diretorio(pr_nmdireto IN VARCHAR2      --> Diretorio para limpeza
                                ,pr_dscritic OUT VARCHAR2) IS --> Retorno de critica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_limpeza_diretorio
    --  Sistema  : Emprestimo Pre-Aprovado - Cooperativa de Credito
    --  Sigla    : EMPR
    --  Autor    : Jaison
    --  Data     : Janeiro/2016                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Fazer limpeza de diretorio quando a data eh anterior ao periodo de 4 meses da data atual.
    -- Alteracoes:
    --
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      vr_typ_said VARCHAR2(3);        -- Saida da rotina de chamada ao OS
      vr_dslista  VARCHAR2(4000);     -- Lista de arquivos do diretorio
      vr_lstarqre GENE0002.typ_split; -- Lista de arquivos
      vr_lstnome  GENE0002.typ_split; -- Lista de nomes
      vr_dtlimite DATE;
      vr_dtarquiv DATE;

      -- Cursor generico de calendario
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    BEGIN
      -- Leitura do calendario da CECRED
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => 3);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      CLOSE BTCH0001.cr_crapdat;

      -- Subtrai 4 meses
      vr_dtlimite := ADD_MONTHS(TRUNC(rw_crapdat.dtmvtolt), - 4);

      -- Primeiro testamos se o diretório já não está vazio
      GENE0001.pc_lista_arquivos(pr_path => pr_nmdireto         --> Dir a limpar
                                ,pr_pesq => NULL                --> Qualquer arquivo
                                ,pr_listarq => vr_dslista       --> Lista encontrada
                                ,pr_des_erro => pr_dscritic);   --> Erro encontrado
      -- Se houve erro ja na listagem
      IF pr_dscritic IS NOT NULL THEN
        -- Incrementar a mensagem
        pr_dscritic := 'Erro Ao verificar arquivos do dir para limpeza '||pr_nmdireto||' --> '||pr_dscritic;
        RETURN;
      END IF;
      -- Se houverem arquivos
      IF vr_dslista IS NOT NULL THEN
        -- Separar a lista de arquivos encontradas com funcao existente
        vr_lstarqre := GENE0002.fn_quebra_string(pr_string => vr_dslista, pr_delimit => ',');
        -- Se nao encontrou nenhum arquivo sair
        IF vr_lstarqre.COUNT() = 0 THEN
          RETURN;
        END IF;
        -- Para cada arquivo encontrado no DIR
        FOR vr_idx IN 1..vr_lstarqre.COUNT LOOP
          -- Separa o nome da data
          vr_lstnome := GENE0002.fn_quebra_string(pr_string => vr_lstarqre(vr_idx), pr_delimit => '_');
          IF vr_lstnome.COUNT() < 2 THEN
            CONTINUE;
          ELSE
            vr_dtarquiv := TO_DATE(SUBSTR(vr_lstnome(2),1,8),'DDMMRRRR');
          END IF;
          -- Se a data de limite for maior que a do arquivo
          IF vr_dtlimite > vr_dtarquiv THEN
            -- Remover o arquivo
            GENE0001.pc_OScommand_Shell(pr_des_comando => 'rm "'||pr_nmdireto||'/'||vr_lstarqre(vr_idx)||'"'
                                       ,pr_typ_saida   => vr_typ_said
                                       ,pr_des_saida   => pr_dscritic);
            -- Testar retorno de erro
            IF vr_typ_said = 'ERR' THEN
              pr_dscritic := 'Erro ao limpar dir '||pr_nmdireto||' --> Ao remover arquivo "'||vr_lstarqre(vr_idx)||'"--> '||pr_dscritic;
              RETURN;
            END IF;
          END IF;
        END LOOP;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- Retorna o erro para a procedure chamadora
        pr_dscritic := 'Erro --> na rotina CYBE0002.pc_limpeza_diretorio -->  '||SQLERRM;
    END;
  END pc_limpeza_diretorio;
  

END EMPR0002;
/
