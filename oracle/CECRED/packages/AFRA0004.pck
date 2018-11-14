CREATE OR REPLACE PACKAGE CECRED.AFRA0004 is 
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : AFRA0004
      Sistema  : Rotinas referentes a monitoracao de Analise de Fraude
      Sigla    : AFRA
      Autor    : Teobaldo Jamunda - AMcom
      Data     : Abril/2018.                                           Ultima atualizacao: __/__/2018

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas referentes a monitoracao de Analise de Fraude e mensagens.
                  (PRJ381 - Analise Antifraude, Teobaldo J. - AMcom) 

      Alteracoes:  
      
  ---------------------------------------------------------------------------------------------------------------*/

  --> Procedimento para realizar monitoração de fraudes nas TEDs 
  --  transposta da AFRA0001 em 10/04/2018 
  PROCEDURE pc_monitora_ted ( pr_idanalis IN INTEGER );
  
  --> Procedimento para direcionar monitoração de fraudes conforme operacao
  PROCEDURE pc_monitora_operacao (pr_cdcooper   IN  crapcop.cdcooper%TYPE  -- Codigo da cooperativa
                                 ,pr_nrdconta   IN  crapttl.nrdconta%TYPE  -- Numero da conta
                                 ,pr_idseqttl   IN  crapttl.idseqttl%TYPE  -- Sequencial titular
                                 ,pr_vlrtotal   IN  NUMBER                 -- Valor total do lancamento (fatura,tributo,convenio,GPS)
                                 ,pr_flgagend   IN  INTEGER                -- Flag agendado /* 1-True, 0-False */ 
                                 ,pr_idorigem   IN  INTEGER                -- Indicador de origem
                                 ,pr_cdoperacao IN  tbgen_analise_fraude.cdoperacao%TYPE 
                                 ,pr_idanalis   IN  tbgen_analise_fraude.idanalise_fraude%TYPE DEFAULT NULL
                                 ,pr_lgprowid   IN  ROWID DEFAULT NULL     -- Rowid da craplgp 
                                 ,pr_cdcritic   OUT INTEGER                -- Codigo da critica
                                 ,pr_dscritic   OUT VARCHAR2);             -- Descricao critica  
                                 
  ---> Procedure destinada a monitorar operacao de Convenio
  PROCEDURE pc_monitora_convenios (pr_cdcooper IN  crapcop.cdcooper%TYPE  -- Codigo da cooperativa
                                  ,pr_nrdconta IN  crapttl.nrdconta%TYPE  -- Numero da conta
                                  ,pr_idseqttl IN  crapttl.idseqttl%TYPE  -- Sequencial titular
                                  ,pr_vlfatura IN  NUMBER                 -- Valor fatura
                                  ,pr_flgagend IN  INTEGER                -- Flag agendado /* 1-True, 0-False */ 
                                  ,pr_cdagenci IN  INTEGER                -- Codigo da agencia
                                  ,pr_dtmvtocd IN  DATE                   -- Data do movimento
                                  ,pr_cdcritic OUT INTEGER                -- Codigo da critica
                                  ,pr_dscritic OUT VARCHAR2);             -- Descricao critica

  ---> Procedure destinada a monitorar operacao de Convenio
  PROCEDURE pc_monitora_titulos (pr_cdcooper IN  crapcop.cdcooper%TYPE  -- Codigo da cooperativa
                                ,pr_nrdconta IN  crapttl.nrdconta%TYPE  -- Numero da conta
                                ,pr_idseqttl IN  crapttl.idseqttl%TYPE  -- Sequencial titular
                                ,pr_vllanmto IN  NUMBER                 -- Valor Lancamento
                                ,pr_flgagend IN  INTEGER                -- Flag agendado /* 1-True, 0-False */ 
                                ,pr_cdagenci IN  INTEGER                -- Codigo da agencia
                                ,pr_dtmvtocd IN  DATE                   -- Data do movimento
                                ,pr_dtmvtolt IN  DATE                   -- Data de pagamento 
                                ,pr_flgpgdda IN  craptit.flgpgdda%TYPE  -- DDA 
                                ,pr_cdcritic OUT INTEGER                -- Codigo da critica
                                ,pr_dscritic OUT VARCHAR2 );            -- Descricao critica
                                 
  ---> Procedure destinada a monitorar operacao de Tributos
 PROCEDURE pc_monitora_tributos (pr_cdcooper  IN  crapcop.cdcooper%TYPE   -- Codigo da cooperativa
                                 ,pr_nrdconta IN  crapass.nrdconta%TYPE   -- Numero da conta
                                 ,pr_idseqttl IN  crapttl.idseqttl%TYPE   -- Sequencial titular
                                 ,pr_vlfatura IN  NUMBER                  -- Valor fatura
                                 ,pr_flgagend IN  INTEGER                 -- Flag agendado /* 1-True, 0-False */
                                 ,pr_cdagenci IN  crapage.cdagenci%TYPE   -- Codigo da agencia
                                 ,pr_dtmvtocd IN  crapdat.dtmvtocd%TYPE   -- rw_crapdat.dtmvtocd
                                 ,pr_cdcritic OUT INTEGER                 -- Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2);              -- Descriçao da critica

  ---> Procedure destinada a monitorar operacao GPS
   PROCEDURE pc_monitora_gps (pr_cdcooper IN  crapcop.cdcooper%TYPE   -- Codigo da cooperativa
                             ,pr_nrdconta IN  crapttl.nrdconta%TYPE   -- Numero da conta
                             ,pr_idseqttl IN  crapttl.idseqttl%TYPE   -- Sequencial titular
                             ,pr_vlrtotal IN  NUMBER                  -- Valor total lancamento
                             ,pr_flgagend IN  INTEGER                 -- Flag agendado /* 1-True, 0-False */ 
                             ,pr_cdagenci IN  INTEGER                 -- Codigo da agencia
                             ,pr_dtmvtocd IN  DATE                    -- Data do movimento 
                             ,pr_lgprowid IN  ROWID                   -- ROWID da craplgp
                             ,pr_cdcritic OUT INTEGER                 -- Codigo da critica
                             ,pr_dscritic OUT VARCHAR2);              -- Descricao critica             
  
  --> Rotina para geração de mensagem de estorno para o cooperado                               
  PROCEDURE pc_mensagem_estorno (pr_cdcooper    IN  crapcop.cdcooper%TYPE                 -- Codigo da cooperativa
                                ,pr_nrdconta    IN  crapass.nrdconta%TYPE                 -- Numero da conta
                                ,pr_inpessoa    IN  crapass.inpessoa%TYPE                 -- Tipo de pessoa (1-Fis, 2-Jur)
                                ,pr_idseqttl    IN  crapttl.idseqttl%TYPE                 -- Sequencial titular
                                ,pr_cdproduto   IN  tbgen_analise_fraude.cdproduto%TYPE   -- Codigo do produto
                                ,pr_tptransacao IN  tbgen_analise_fraude.tptransacao%TYPE -- Tipo de transação (1-online/ 2-agendada)                                  
                                ,pr_vldinami    IN  VARCHAR2                              -- Permite Passar valores dinamicos para a mensagem ex. #VALOR#=58,99;#DTDEBITO#=18/01/2017; 
                                ,pr_programa    IN  VARCHAR2                              -- Nome do programa/package de origem da mensagem
                                ,pr_cdcritic    OUT INTEGER                               -- Codigo da critica 
                                ,pr_dscritic    OUT VARCHAR2);                            -- Descricao critica
end AFRA0004;
/
create or replace package body CECRED.AFRA0004 is

  /* ---------------------------------------------------------------------------

      Programa : AFRA0004
      Sistema  : Rotinas referentes a monitoracao de Analise de Fraude
      Sigla    : AFRA
      Autor    : Teobaldo Jamunda - AMcom
      Data     : Abril/2018.                    Ultima atualizacao: __/__/2018

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Centralizar rotinas referentes a monitoracao de 
                  Analise de Fraude e mensagens
                  (PRJ381 - Analise Antifraude, Teobaldo J. - AMcom)

      Alteracoes:  
      
  ----------------------------------------------------------------------------*/

  --> Cursores
    -- Busca as informações da cooperativa conectada
    CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT crapcop.cdcooper
            ,crapcop.dsdircop
            ,crapcop.cdbcoctl
            ,crapcop.cdagectl
            ,crapcop.nmrescop
            ,crapcop.vlinimon
            ,crapcop.vllmonip
            ,crapcop.nmextcop
            ,crapcop.flgofatr
      FROM crapcop crapcop
      WHERE crapcop.cdcooper = pr_cdcooper;

    -- Selecionar todos protocolos das transacoes
    CURSOR cr_crappro (pr_cdcooper IN crappro.cdcooper%type
                      ,pr_nrdconta IN crappro.nrdconta%type
                      ,pr_dtmvtolt IN crappro.dtmvtolt%type
                      ,pr_cdtippro IN crappro.cdtippro%type) IS
      SELECT crappro.cdcooper
            ,crappro.dtmvtolt
            ,crappro.dsinform##2
            ,crappro.dsprotoc
            ,crappro.nrseqaut
            ,crappro.dscedent
            ,crappro.flgagend
            ,crappro.vldocmto
       FROM crappro
      WHERE crappro.cdcooper = pr_cdcooper
      AND   crappro.nrdconta = pr_nrdconta
      AND   crappro.dtmvtolt = pr_dtmvtolt
      AND   crappro.cdtippro = pr_cdtippro;

    --Selecionar informacoes da autenticacao
    CURSOR cr_crapaut_sequen (pr_cdcooper IN crapaut.cdcooper%type
                             ,pr_cdagenci IN crapaut.cdagenci%type
                             ,pr_nrdcaixa IN crapaut.nrdcaixa%type
                             ,pr_dtmvtolt IN crapaut.dtmvtolt%type
                             ,pr_nrsequen IN crapaut.nrsequen%type) IS
      SELECT crapaut.cdcooper
            ,crapaut.dtmvtolt
            ,crapaut.cdagenci
            ,crapaut.nrdcaixa
            ,crapaut.vldocmto
            ,crapaut.hrautent
            ,crapaut.nrsequen
            ,crapaut.cdopecxa
            ,crapaut.cdhistor
            ,crapaut.dsprotoc
            ,crapaut.nrdocmto
            ,crapaut.ROWID
       FROM crapaut crapaut
      WHERE crapaut.cdcooper = pr_cdcooper
      AND   crapaut.cdagenci = pr_cdagenci
      AND   crapaut.nrdcaixa = pr_nrdcaixa
      AND   crapaut.dtmvtolt = pr_dtmvtolt
      AND   crapaut.nrsequen = pr_nrsequen;

    -- Selecionar faturas
    CURSOR cr_craplft (pr_cdcooper IN craplft.cdcooper%type
                      ,pr_dtmvtolt IN craplft.dtmvtolt%type
                      ,pr_cdagenci IN craplft.cdagenci%type
                      ,pr_cdbccxlt IN craplft.cdbccxlt%type
                      ,pr_nrdolote IN craplft.nrdolote%type
                      ,pr_nrseqdig IN craplft.nrseqdig%type) IS
      SELECT craplft.cdbarras
            ,craplft.vllanmto
            ,craplft.cdempcon
            ,craplft.cdhistor
      FROM craplft
      WHERE craplft.cdcooper = pr_cdcooper
      AND   craplft.dtmvtolt = pr_dtmvtolt
      AND   craplft.cdagenci = pr_cdagenci
      AND   craplft.cdbccxlt = pr_cdbccxlt
      AND   craplft.nrdolote = pr_nrdolote
      AND   craplft.nrseqdig = pr_nrseqdig;

    -- Selecionar lancamento
    CURSOR cr_craplgp_1 (pr_cdcooper IN craplft.cdcooper%type
                        ,pr_dtmvtolt IN craplft.dtmvtolt%type
                        ,pr_cdagenci IN craplft.cdagenci%type
                        ,pr_cdbccxlt IN craplft.cdbccxlt%type
                        ,pr_nrdolote IN craplft.nrdolote%type
                        ,pr_nrseqdig IN craplft.nrseqdig%type) IS
      SELECT craplgp.cdbarras
            ,craplgp.vlrtotal
      FROM craplgp
      WHERE craplgp.cdcooper = pr_cdcooper
      AND   craplgp.dtmvtolt = pr_dtmvtolt
      AND   craplgp.cdagenci = pr_cdagenci
      AND   craplgp.cdbccxlt = pr_cdbccxlt
      AND   craplgp.nrdolote = pr_nrdolote
      AND   craplgp.nrseqdig = pr_nrseqdig;

    -- Selecionar a data de abertura da conta
    CURSOR cr_crapass_data(pr_cdcooper IN craplgm.cdcooper%type,
                           pr_nrdconta IN craplgm.nrdconta%type) IS
      SELECT crapass.dtabtcct
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper
         AND crapass.nrdconta = pr_nrdconta;

    --Selecionar informacoes log transacoes no sistema
    CURSOR cr_craplgm(pr_cdcooper IN craplgm.cdcooper%type,
                      pr_nrdconta IN craplgm.nrdconta%type,
                      pr_idseqttl IN craplgm.idseqttl%type,
                      pr_dttransa IN craplgm.dttransa%type,
                      pr_dsorigem IN craplgm.dsorigem%type,
                      pr_cdoperad IN craplgm.cdoperad%type,
                      pr_flgtrans IN craplgm.flgtrans%type,
                      pr_dstransa IN craplgm.dstransa%TYPE) IS
      SELECT craplgm.cdcooper,
             craplgm.nrdconta,
             craplgm.idseqttl,
             craplgm.dttransa,
             craplgm.hrtransa,
             craplgm.nrsequen
        FROM craplgm
       WHERE craplgm.cdcooper = pr_cdcooper
         AND craplgm.nrdconta = pr_nrdconta
         AND craplgm.idseqttl = pr_idseqttl
         AND craplgm.dttransa = pr_dttransa
         AND craplgm.dsorigem = pr_dsorigem
         AND craplgm.cdoperad = pr_cdoperad
         AND craplgm.flgtrans = pr_flgtrans
         AND craplgm.dstransa = pr_dstransa
       ORDER BY craplgm.progress_recid DESC;

    --Selecionar tabela complementar de log
    CURSOR cr_craplgi(pr_cdcooper IN craplgm.cdcooper%type,
                      pr_nrdconta IN craplgm.nrdconta%type,
                      pr_idseqttl IN craplgm.idseqttl%type,
                      pr_dttransa IN craplgm.dttransa%type,
                      pr_hrtransa IN craplgm.hrtransa%type,
                      pr_nrsequen IN craplgm.nrsequen%type,
                      pr_nmdcampo IN craplgi.nmdcampo%type) IS
      SELECT craplgi.dsdadatu, craplgi.nmdcampo
        FROM craplgi
       WHERE craplgi.cdcooper = pr_cdcooper
         AND craplgi.nrdconta = pr_nrdconta
         AND craplgi.idseqttl = pr_idseqttl
         AND craplgi.dttransa = pr_dttransa
         AND craplgi.hrtransa = pr_hrtransa
         AND craplgi.nrsequen = pr_nrsequen
         AND craplgi.nmdcampo = pr_nmdcampo;

    --Selecionar Informacoes Agencia
    CURSOR cr_crapage (pr_cdcooper IN crapage.cdcooper%type
                      ,pr_cdagenci IN crapage.cdagenci%type) IS
      SELECT crapage.nmresage
        FROM crapage
       WHERE crapage.cdcooper = pr_cdcooper
       AND   crapage.cdagenci = pr_cdagenci;


    --Selecionar dados Pessoa Juridica
    CURSOR cr_crapjur (pr_cdcooper IN crapjur.cdcooper%type
                      ,pr_nrdconta IN crapjur.nrdconta%type) IS
      SELECT crapjur.nmextttl
        FROM crapjur
       WHERE crapjur.cdcooper = pr_cdcooper
       AND   crapjur.nrdconta = pr_nrdconta;

    -- Selecionar dados Avalistas
    CURSOR cr_crapavt2 (pr_cdcooper IN crapavt.cdcooper%type
                       ,pr_nrdconta IN crapavt.nrdconta%type
                       ,pr_tpctrato IN crapavt.tpctrato%type) IS
      SELECT crapavt.nrdctato
            ,crapavt.nmdavali
            ,crapavt.cdcooper
        FROM crapavt
       WHERE crapavt.cdcooper = pr_cdcooper
       AND   crapavt.nrdconta = pr_nrdconta
       AND   crapavt.tpctrato = pr_tpctrato;

    --Selecionar os telefones do titular
    CURSOR cr_craptfc (pr_cdcooper IN craptfc.cdcooper%type
                      ,pr_nrdconta IN craptfc.nrdconta%type) IS
      SELECT craptfc.nrdddtfc
            ,craptfc.nrtelefo
       FROM craptfc
      WHERE craptfc.cdcooper = pr_cdcooper
      AND   craptfc.nrdconta = pr_nrdconta;
    
    --Selecionar dados do asssociado
    CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT crapass.nrdconta
            ,crapass.nmprimtl
            ,crapass.vllimcre
            ,crapass.nrcpfcgc
            ,crapass.inpessoa
            ,crapass.cdcooper
            ,crapass.cdagenci
            ,crapass.nrctacns
            ,crapass.dtdemiss
            ,crapass.idastcjt
       FROM crapass
      WHERE crapass.cdcooper = pr_cdcooper
      AND   crapass.nrdconta = pr_nrdconta;

  --> Buscar representantes da empresa 
  CURSOR cr_repres (pr_nrcpfcgc IN tbcadast_pessoa.nrcpfcgc%TYPE) IS   
    SELECT pes.nmpessoa
      FROM tbcadast_pessoa_juridica_rep rep,
           tbcadast_pessoa pes
     WHERE rep.idpessoa_representante = pes.idpessoa
       AND pes.nrcpfcgc = pr_nrcpfcgc
     ORDER BY rep.persocio, pes.nmpessoa;   

  --Tipo de Dados para cursor data
  rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;


  -- Rotina para buscar conteúdo das mensagens do iBank/SMS
  FUNCTION fn_buscar_valor(pr_campo             IN VARCHAR2
                          ,pr_valores_dinamicos IN VARCHAR2 DEFAULT NULL) -- Máscara #Cooperativa#=1;#Convenio#=123
   RETURN VARCHAR2 IS
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : fn_buscar_valor
    --  Autor    : Everton
    --  Data     : Abril/2018.                   Ultima atualizacao: 13/04/2018
    --
    -- Objetivo  : Buscar campo de variavéis dinâmicas
    --
    -- Alteracao : 13/04/2018 - Movida da AFRA0001 para esta package, a fim de centralizar 
    --                          rotinas que geram mensagens. 
    --                         (PRJ381 - Analise de Fraude - Teobaldo J. - AMcom)
    ---------------------------------------------------------------------------------------------------------------
  
    /*Quebra os valores da string recebida por parâmetro*/
    CURSOR cr_parametro IS
      SELECT regexp_substr(parametro, '[^=]+', 1, 1) parametro
            ,regexp_substr(parametro, '[^=]+', 1, 2) valor
        FROM (SELECT regexp_substr(pr_valores_dinamicos, '[^;]+', 1, ROWNUM) parametro
                FROM dual
              CONNECT BY LEVEL <= LENGTH(regexp_replace(pr_valores_dinamicos ,'[^;]+','')) + 1);
  
  BEGIN
  
    -- Sobrescreve os parâmetros
    FOR rw_parametro IN cr_parametro LOOP
      --
      IF UPPER(rw_parametro.parametro) = (pr_campo) THEN
         RETURN rw_parametro.valor;
      END IF;                              
      --                       
    END LOOP;
  
  END fn_buscar_valor;


  --> Procedimento para direcionar monitoracao de fraudes conforme operacao
  PROCEDURE pc_monitora_operacao (pr_cdcooper   IN  crapcop.cdcooper%TYPE  -- Codigo da cooperativa
                                 ,pr_nrdconta   IN  crapttl.nrdconta%TYPE  -- Numero da conta
                                 ,pr_idseqttl   IN  crapttl.idseqttl%TYPE  -- Sequencial titular
                                 ,pr_vlrtotal   IN  NUMBER                 -- Valor total do lancamento (fatura,tributo,convenio,GPS)
                                 ,pr_flgagend   IN  INTEGER                -- Flag agendado /* 1-True, 0-False */ 
                                 ,pr_idorigem   IN  INTEGER                -- Indicador de origem
                                 ,pr_cdoperacao IN  tbgen_analise_fraude.cdoperacao%TYPE 
                                 ,pr_idanalis   IN  tbgen_analise_fraude.idanalise_fraude%TYPE DEFAULT NULL
                                 ,pr_lgprowid   IN  ROWID DEFAULT NULL     -- Rowid da craplgp 
                                 ,pr_cdcritic   OUT INTEGER                -- Codigo da critica
                                 ,pr_dscritic   OUT VARCHAR2) IS           -- Descricao critica                       
    /* ---------------------------------------------------------------------------

        Programa : pc_monitora_operacao
        Sistema  : Rotinas referentes a monitoracao de Analise de Fraude
        Sigla    : CRED
        Autor    : Teobaldo Jamunda - AMcom
        Data     : Abril/2018.                    Ultima atualizacao: 28/08/2018

        Dados referentes ao programa:

        Frequencia: sempre que chamada
        Objetivo  : Redirecionar para rotina de monitoracao de Analise de Fraude
                    devida conforme o codigo de operacao
                    (PRJ381 - Analise Antifraude, Teobaldo J. - AMcom)

        Alteracoes: 28/08/2018 - Quando cdoperacao for 7 DDA monitorar como se fosse
                                 titulo passando a descricao DDA (Tiago RITM0025395)        
    ----------------------------------------------------------------------------*/

    -- Variaveis de Erro
    vr_dscritic    VARCHAR2(4000);
    vr_exc_erro    EXCEPTION;

    -- Variaveis Locais
    vr_cdagenci    INTEGER;

    CURSOR cr_craplgp (pr_idanalis craplgp.idanafrd%TYPE)IS
      SELECT lgp.vlrtotal,
             lgp.rowid
        FROM craplgp lgp
       WHERE lgp.idanafrd = pr_idanalis; 
    rw_craplgp cr_craplgp%ROWTYPE;
    
    CURSOR cr_craplft (pr_idanalis craplgp.idanafrd%TYPE)IS
      SELECT lft.vllanmto,
             lft.rowid
        FROM craplft lft
       WHERE lft.idanafrd = pr_idanalis; 
    rw_craplft cr_craplft%ROWTYPE;
    
    CURSOR cr_craptit (pr_idanalis craplgp.idanafrd%TYPE)IS
      SELECT tit.vldpagto,
             tit.rowid
        FROM craptit tit
       WHERE tit.idanafrd = pr_idanalis; 
    rw_craptit cr_craptit%ROWTYPE;

  BEGIN
    
    /* tratamento para TAA */
    IF pr_idorigem = 4 THEN
      --Agencia
      vr_cdagenci:= 91;
    ELSE
      --Agencia
      vr_cdagenci:= 90;
    END IF;
    
    /* Data do sistema */
    -- Verifica se a data esta cadastrada
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois haverá raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1) || ' (AFRA0004)';
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;
      
    --> chama rotina conforme codigo Operacao (tbcc_dominio_campo, dominio: CDOPERAC_ANALISE_FRAUDE)
    CASE 
      WHEN pr_cdoperacao IN (1, 8)  THEN  /* TITULOS, DDA */
        IF pr_idanalis > 0 THEN
          OPEN cr_craptit (pr_idanalis => pr_idanalis);
          FETCH cr_craptit INTO rw_craptit;
          CLOSE cr_craptit;                   
        END IF;
      
           pc_monitora_titulos (pr_cdcooper => pr_cdcooper           -- Codigo da cooperativ 
                               ,pr_nrdconta => pr_nrdconta           -- Numero da conta
                               ,pr_idseqttl => pr_idseqttl           -- Sequencial titular
                               ,pr_vllanmto => nvl(pr_vlrtotal,rw_craptit.vldpagto)           -- Valor fatura
                               ,pr_flgagend => pr_flgagend           -- Flag agendado /* 1-T
                               ,pr_cdagenci => vr_cdagenci           -- Codigo da agencia
                               ,pr_dtmvtocd => rw_crapdat.dtmvtocd   -- Data do movimento
                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt   -- Data de pagamento 
                               ,pr_flgpgdda => CASE pr_cdoperacao WHEN 8 THEN 1 ELSE 0 END --Tipo titulo
                               ,pr_cdcritic => pr_cdcritic           -- retorno codigo critica 
                               ,pr_dscritic => pr_dscritic);         -- retorno descricao critica
                                      
      WHEN pr_cdoperacao in (2, 6)  THEN  /* CONVENIOS */
        IF pr_idanalis > 0 THEN
          OPEN cr_craplft (pr_idanalis => pr_idanalis);
          FETCH cr_craplft INTO rw_craplft;
          CLOSE cr_craplft;                   
        END IF;
      
           pc_monitora_convenios (pr_cdcooper => pr_cdcooper          -- Codigo da cooperativa
                                 ,pr_nrdconta => pr_nrdconta          -- Numero da conta
                                 ,pr_idseqttl => pr_idseqttl          -- Sequencial titular
                             ,pr_vlfatura => nvl(pr_vlrtotal,rw_craplft.vllanmto)          -- Valor fatura
                                 ,pr_flgagend => pr_flgagend          -- Flag agendado /* 1-True, 0-False */ 
                                 ,pr_cdagenci => vr_cdagenci          -- Codigo da agencia
                                 ,pr_dtmvtocd => rw_crapdat.dtmvtocd  -- Data do movimento                   
                                 ,pr_cdcritic => pr_cdcritic          -- retorno codigo critica 
                                 ,pr_dscritic => pr_dscritic);        -- retorno descricao critica

      WHEN pr_cdoperacao in (3, 4) THEN /* TRIBUTOS: 3-DARF/DAS, 4-FGTS/DAE */
        IF pr_idanalis > 0 THEN
          OPEN cr_craplft (pr_idanalis => pr_idanalis);
          FETCH cr_craplft INTO rw_craplft;
          CLOSE cr_craplft;                   
        END IF;
      
           pc_monitora_tributos (pr_cdcooper => pr_cdcooper          -- Codigo da cooperativa
                                ,pr_nrdconta => pr_nrdconta          -- Numero da conta
                                ,pr_idseqttl => pr_idseqttl          -- Sequencial titular     
                            ,pr_vlfatura => nvl(pr_vlrtotal,rw_craplft.vllanmto)          -- Valor fatura      
                                ,pr_flgagend => pr_flgagend          -- Flag agendado /* 1-True, 0-False */   
                                ,pr_cdagenci => vr_cdagenci          -- Codigo da agencia    
                                ,pr_dtmvtocd => rw_crapdat.dtmvtocd  -- rw_crapdat.dtmvtocd    
                                ,pr_cdcritic => pr_cdcritic          -- retorno Codigo da critica    
                                ,pr_dscritic => pr_dscritic);        -- retorno Descriçao da critica      
      
      WHEN pr_cdoperacao = 5  THEN  /* GPS */
        IF pr_idanalis > 0 THEN
          OPEN cr_craplgp (pr_idanalis => pr_idanalis);
          FETCH cr_craplgp INTO rw_craplgp;
          CLOSE cr_craplgp;           
        
        END IF;
           
           pc_monitora_gps (pr_cdcooper => pr_cdcooper           -- Codigo da cooperativa
                           ,pr_nrdconta => pr_nrdconta           -- Numero da conta
                           ,pr_idseqttl => pr_idseqttl           -- Sequencial titular
                           ,pr_vlrtotal => nvl(pr_vlrtotal,rw_craplgp.vlrtotal)           -- Valor total lancamento
                           ,pr_flgagend => pr_flgagend           -- Flag agendado /* 1-True, 0-False */ 
                           ,pr_cdagenci => vr_cdagenci           -- Codigo da agencia
                           ,pr_dtmvtocd => rw_crapdat.dtmvtocd   -- Data do movimento 
                           ,pr_lgprowid => nvl(pr_lgprowid,rw_craplgp.rowid)           -- ROWID da craplgp
                           ,pr_cdcritic => pr_cdcritic           -- retorno Codigo da critica
                           ,pr_dscritic => pr_cdcritic);         -- retorno Descricao critica

      WHEN pr_cdoperacao = 12 THEN  /* TED */
           pc_monitora_ted (pr_idanalis => pr_idanalis);    
      ELSE NULL;
    END CASE;      

  EXCEPTION      
    WHEN vr_exc_erro THEN 
      pr_dscritic := vr_dscritic; 
    WHEN OTHERS THEN
      -- Erro
      pr_dscritic:= 'Erro na rotina AFRA0004.pc_monitora_operacao. '||sqlerrm;
    
  END pc_monitora_operacao;
  
  
  /* Procedimento para realizar monitoração de fraudes nas TEDs */
  PROCEDURE pc_monitora_ted ( pr_idanalis IN INTEGER ) IS
     
    /* ..........................................................................
    --
    --  Programa : pc_monitora_ted       
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Março/2016.                   Ultima atualizacao: 02/05/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Procedure utilizada para realizar monitoração de fraudes nas TEDs
    --
    --  Alteração  : 07/04/2016 - Criacao dos parametros PR_INPESSOA e PR_INTIPCTA. 
    --                            Buscar informacoes que vinham da CRAPPRM e agora
    --                            vem da CRAPCOP. (Jaison/Marcos - SUPERO)
    --
    --               02/05/2016 - Se valor da TED ou do Limite ficarem abaixo dos
    --                            monitoraveis, buscar PRM e se existir, mandar email
    --                            para o email encontrado, senao nao havera envio.
    --                            (Jaison/Marcos - SUPERO)
    --
    -- ..........................................................................*/
    
    ---------------> CURSORES <----------------- 
    
    --> Buscar analise de fraude
    CURSOR cr_fraude IS
      SELECT fra.idanalise_fraude,
             fra.cdcanal_operacao,
             fra.dhinicio_analise,
             fra.dhlimite_analise,
             fra.cdcooper,
             fra.nrdconta,
             fra.iptransacao,
             fra.cdoperacao, 
             fra.tptransacao
        FROM tbgen_analise_fraude fra
       WHERE fra.idanalise_fraude = pr_idanalis; 
    rw_fraude cr_fraude%ROWTYPE;
    
    --> Buscar informações da TED
    CURSOR cr_craptvl (pr_idanalis  craplau.idanafrd%TYPE,
                       pr_cdcooper  craplau.cdcooper%TYPE,
                       pr_nrdconta  craplau.nrdconta%TYPE) IS
      SELECT tvl.cdcooper,
             tvl.nrdconta,
             cop.nmrescop,
             tvl.idseqttl,
             tvl.cdbccrcb,
             tvl.cdagercb,
             tvl.nrcctrcb,
             tvl.nmpesrcb,
             tvl.cpfcgrcb,
             tvl.vldocrcb,
             decode(substr(tvl.idopetrf, length(tvl.idopetrf), 1), 'M',1,0) flmobile,
             tvl.flgpescr,
             tvl.tpdctacr
        FROM craptvl tvl,
             crapcop cop,
             crapass ass,
             crapban ban
       WHERE tvl.cdcooper = cop.cdcooper
         AND tvl.cdcooper = ass.cdcooper
         AND tvl.nrdconta = ass.nrdconta 
         AND tvl.cdbccrcb = ban.cdbccxlt
         AND tvl.idanafrd = pr_idanalis
         AND tvl.cdcooper = pr_cdcooper
         AND tvl.nrdconta = pr_nrdconta;         
    rw_craptvl cr_craptvl%ROWTYPE;
    
    --> Buscar informações do agendamento de TED
    CURSOR cr_craplau (pr_idanalis  craplau.idanafrd%TYPE,
                       pr_cdcooper  craplau.cdcooper%TYPE,
                       pr_nrdconta  craplau.nrdconta%TYPE) IS                      
      SELECT lau.cdcooper,
             lau.nrdconta,
             cop.nmrescop,
             lau.idseqttl,
             lau.cddbanco,
             lau.cdageban,
             lau.nrctadst,
             cti.nmtitula,
             cti.nrcpfcgc,
             lau.vllanaut,
             lau.flmobile,
             cti.inpessoa,
             cti.intipcta
        FROM craplau lau,
             crapcop cop,
             crapass ass,
             crapban ban,
             crapcti cti
       WHERE lau.cdcooper = cop.cdcooper
         AND lau.cdcooper = ass.cdcooper
         AND lau.nrdconta = ass.nrdconta 
         AND lau.cddbanco = ban.cdbccxlt         
         AND lau.cdcooper = cti.cdcooper
         AND lau.nrdconta = cti.nrdconta
         AND lau.cddbanco = cti.cddbanco
         AND lau.cdageban = cti.cdageban
         AND lau.nrctadst = cti.nrctatrf 
         AND lau.cdtiptra = 4    
         AND lau.idanafrd = pr_idanalis
         AND lau.cdcooper = pr_cdcooper
         AND lau.nrdconta = pr_nrdconta;         
    rw_craplau cr_craplau%ROWTYPE;
    
    --> Selecionar informacoes de senhas
    CURSOR cr_crapsnh (pr_cdcooper IN crapsnh.cdcooper%type
                      ,pr_nrdconta IN crapsnh.nrdconta%type
                      ,pr_idseqttl IN crapsnh.idseqttl%TYPE) IS
      SELECT crapsnh.nrcpfcgc
            ,crapsnh.cdcooper
            ,crapsnh.nrdconta
            ,crapsnh.vllimted
      FROM crapsnh
      WHERE crapsnh.cdcooper = pr_cdcooper
      AND   crapsnh.nrdconta = pr_nrdconta
      AND   crapsnh.idseqttl = pr_idseqttl
      AND   crapsnh.tpdsenha = 1;
    rw_crapsnh cr_crapsnh%ROWTYPE;
    
    --> Buscar dados a agencia destino
    CURSOR cr_crapagb(pr_cddbanco crapagb.cddbanco%TYPE,
                      pr_cdageban crapagb.cdageban%TYPE) IS
      SELECT ban.nmresbcc
            ,agb.nmageban
            ,caf.cdufresd
        FROM crapban ban,
             crapagb agb,
             crapcaf caf
       WHERE agb.cddbanco = pr_cddbanco
         AND agb.cdageban = pr_cdageban
         AND agb.cddbanco = ban.cdbccxlt
         AND agb.cdcidade = caf.cdcidade;         
    rw_crapagb cr_crapagb%ROWTYPE;
    
    CURSOR cr_crapban(pr_cdbccxlt crapban.cdbccxlt%TYPE) IS
      SELECT crapban.nmextbcc
        FROM crapban
       WHERE crapban.cdbccxlt = pr_cdbccxlt;
    rw_crapban cr_crapban%ROWTYPE;
    
    --> Buscar dados do associado
    CURSOR cr_crapass (pr_cdcooper  crapass.cdcooper%TYPE,
                       pr_nrdconta  crapass.nrdconta%TYPE) IS
      SELECT ass.inpessoa,
             ass.nmprimtl,
             ass.nrcpfcgc,
             ass.cdagenci,
             age.nmresage
        FROM crapass ass
            ,crapage age
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta
         AND ass.cdcooper = age.cdcooper
         AND ass.cdagenci = age.cdagenci;
    rw_crapass cr_crapass%ROWTYPE;
    rw_crabass cr_crapass%ROWTYPE;
    
    vr_crabass BOOLEAN;
    
    --Selecionar informacoes dos titulares da conta
    CURSOR cr_crapttl (pr_cdcooper IN crapttl.cdcooper%TYPE
                      ,pr_nrdconta IN crapttl.nrdconta%TYPE
                      ,pr_idseqttl IN crapttl.idseqttl%type) IS
      SELECT crapttl.cdcooper
            ,crapttl.nrdconta
            ,crapttl.cdempres
            ,crapttl.cdturnos
            ,crapttl.nmextttl
            ,crapttl.idseqttl
       FROM crapttl crapttl
      WHERE crapttl.cdcooper = pr_cdcooper
      AND   crapttl.nrdconta = pr_nrdconta
      AND   (
            (trim(pr_idseqttl) IS NOT NULL AND crapttl.idseqttl = pr_idseqttl) OR
            (trim(pr_idseqttl) IS NULL)
            );
    rw_crapttl cr_crapttl%ROWTYPE;
    
    --Selecionar dados Pessoa Juridica
    CURSOR cr_crapjur (pr_cdcooper IN crapjur.cdcooper%type
                      ,pr_nrdconta IN crapjur.nrdconta%type) IS
      SELECT crapjur.nmextttl
      FROM crapjur
      WHERE crapjur.cdcooper = pr_cdcooper
      AND   crapjur.nrdconta = pr_nrdconta;
    rw_crapjur cr_crapjur%ROWTYPE;
    
    --Selecionar Avalistas
    CURSOR cr_crapavt (pr_cdcooper IN crapavt.cdcooper%type
                      ,pr_nrdconta IN crapavt.nrdconta%type
                      ,pr_tpctrato IN crapavt.tpctrato%type) IS
      SELECT crapavt.nrdctato
            ,crapavt.nmdavali
            ,crapavt.cdcooper
       FROM crapavt
      WHERE crapavt.cdcooper = pr_cdcooper
      AND   crapavt.nrdconta = pr_nrdconta
      AND   crapavt.tpctrato = pr_tpctrato;
    
    --Selecionar os telefones do titular
    CURSOR cr_craptfc (pr_cdcooper IN craptfc.cdcooper%type
                      ,pr_nrdconta IN craptfc.nrdconta%type) IS
      SELECT craptfc.nrdddtfc
            ,craptfc.nrtelefo
            ,craptfc.nmpescto
       FROM craptfc
      WHERE craptfc.cdcooper = pr_cdcooper
      AND   craptfc.nrdconta = pr_nrdconta;
    rw_craptfc cr_craptfc%ROWTYPE;
    
    --Selecionar os dados da cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT crapcop.dsestted
            ,crapcop.vlinited
            ,crapcop.vlmnlmtd
            ,crapcop.flmobted
            ,crapcop.flmstted
            ,crapcop.flnvfted
            ,crapcop.flmntage
        FROM crapcop
       WHERE crapcop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    --Buscar se o favorecido esta cadastrado na CRAPCTI ha mais de um dia
    CURSOR cr_crapcti (pr_cdcooper IN crapcti.cdcooper%TYPE
                      ,pr_nrdconta IN crapcti.nrdconta%TYPE
                      ,pr_cddbanco IN crapcti.cddbanco%TYPE
                      ,pr_nrctatrf IN crapcti.nrctatrf%TYPE
                      ,pr_cdageban IN crapcti.cdageban%TYPE
                      ,pr_inpessoa IN crapcti.inpessoa%TYPE
                      ,pr_intipcta IN crapcti.intipcta%TYPE
                      ,pr_nrcpfcgc IN crapcti.nrcpfcgc%TYPE) IS
      SELECT COUNT(1)
        FROM crapcti cti
       WHERE cti.cdcooper = pr_cdcooper
         AND cti.nrdconta = pr_nrdconta
         AND cti.cddbanco = pr_cddbanco
         AND cti.nrctatrf = pr_nrctatrf
         AND cti.cdageban = pr_cdageban
         AND cti.inpessoa = pr_inpessoa
         AND cti.intipcta = pr_intipcta
         AND cti.nrcpfcgc = pr_nrcpfcgc
         AND TRUNC(cti.dttransa) < TRUNC(SYSDATE); -- Cadastrados ha mais de um dia
    
    ---------------> VARIAVEIS <-----------------
    vr_exc_naomonit EXCEPTION;
    vr_exc_erro     EXCEPTION;
    vr_dscritic     VARCHAR2(2000);
    
    vr_vlr_minmonted    NUMBER := 0;
    vr_vlr_minported    NUMBER := 0;
    vr_flmonmob         NUMBER := 0;
    vr_dsufsmon         VARCHAR2(4000)  := NULL;
    vr_dsassunt         VARCHAR2(500)   := NULL;
    vr_conteudo         VARCHAR2(32000) := NULL;
    vr_email_dest       VARCHAR2(500)   := NULL;
    vr_qtregistro       NUMBER;
    
    vr_cdcooper crapcop.cdcooper%TYPE;   --> Codigo da cooperativa                            
    vr_nmrescop crapcop.nmrescop%TYPE;   --> Nome da cooperativa 
    vr_nrdconta crapttl.nrdconta%TYPE;   --> Numero da conta
    vr_idseqttl crapttl.idseqttl%TYPE;   --> Sequencial titular                             
    vr_cddbanco crapcti.cddbanco%TYPE;   --> Codigo do banco                             
    vr_cdageban crapcti.cdageban%TYPE;   --> codigo da agencia bancaria. 
    vr_nrctatrf crapcti.nrctatrf%TYPE;   --> conta que recebe a transferencia. 
    vr_nmtitula crapcti.nmtitula%TYPE;   --> nome do titular da conta. 
    vr_nrcpfcgc crapcti.nrcpfcgc%TYPE;   --> cpf/cnpj do titular da conta.  
    vr_vllanmto craplcm.vllanmto%TYPE;   --> Valor do lançamento
    vr_flmobile INTEGER;                 --> Indicador se origem é do Mobile
    vr_iptransa VARCHAR2(100);           --> IP da transacao no IBank/mobile
    vr_inpessoa crapcti.inpessoa%TYPE;   --> Tipo de pessoa da conta
    vr_intipcta crapcti.intipcta%TYPE;   --> Tipo da conta
    vr_idagenda INTEGER;                 --> Tipo de agendamento
    vr_fcrapagb BOOLEAN := FALSE;
    
  --  PRAGMA AUTONOMOUS_TRANSACTION;
      
  BEGIN
  
    --> Buscar analise de fraude
    OPEN cr_fraude;
    FETCH cr_fraude INTO rw_fraude;
    
    IF cr_fraude%NOTFOUND THEN
      vr_dscritic := 'Registro de analise de fraude não encontrado.';
      CLOSE cr_fraude;
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_fraude;
    END IF;
    
    -- Se for TED Online
    IF rw_fraude.tptransacao = 1 THEN
  
      OPEN cr_craptvl( pr_idanalis => pr_idanalis,
                       pr_cdcooper => rw_fraude.cdcooper,
                       pr_nrdconta => rw_fraude.nrdconta);
      FETCH cr_craptvl INTO rw_craptvl;
      
      IF cr_craptvl%NOTFOUND THEN
        CLOSE cr_craptvl;
        vr_dscritic := 'Não foi possivel localizar craptvl';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_craptvl;
      END IF;
      
      vr_cdcooper := rw_fraude.cdcooper;   --> Codigo da cooperativa                            
      vr_nmrescop := rw_craptvl.nmrescop;  --> Nome da cooperativa 
      vr_nrdconta := rw_craptvl.nrdconta;  --> Numero da conta
      vr_idseqttl := rw_craptvl.idseqttl;  --> Sequencial titular                             
      vr_cddbanco := rw_craptvl.cdbccrcb;  --> Codigo do banco                             
      vr_cdageban := rw_craptvl.cdagercb;  --> codigo da agencia bancaria. 
      vr_nrctatrf := rw_craptvl.nrcctrcb;  --> conta que recebe a transferencia. 
      vr_nmtitula := rw_craptvl.nmpesrcb;  --> nome do titular da conta. 
      vr_nrcpfcgc := rw_craptvl.cpfcgrcb;  --> cpf/cnpj do titular da conta.  
      vr_vllanmto := rw_craptvl.vldocrcb;  --> Valor do lançamento
      vr_flmobile := rw_craptvl.flmobile;  --> Indicador se origem é do Mobile
      vr_iptransa := rw_fraude.iptransacao;   --> IP da transacao no IBank/mobile
      vr_inpessoa := rw_craptvl.flgpescr;  --> Tipo de pessoa da conta
      vr_intipcta := rw_craptvl.tpdctacr;  --> Tipo da conta
      vr_idagenda := 1;                    --> Tipo de agendamento      
      
    ELSE
      
      OPEN cr_craplau( pr_idanalis => pr_idanalis,
                       pr_cdcooper => rw_fraude.cdcooper,
                       pr_nrdconta => rw_fraude.nrdconta);
      FETCH cr_craplau INTO rw_craplau;
      
      IF cr_craplau%NOTFOUND THEN
        CLOSE cr_craplau;
        vr_dscritic := 'Não foi possivel localizar craplau';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_craplau;
      END IF;
      
      vr_cdcooper := rw_fraude.cdcooper;   --> Codigo da cooperativa                            
      vr_nmrescop := rw_craplau.nmrescop;  --> Nome da cooperativa 
      vr_nrdconta := rw_craplau.nrdconta;  --> Numero da conta
      vr_idseqttl := rw_craplau.idseqttl;  --> Sequencial titular                             
      vr_cddbanco := rw_craplau.cddbanco;  --> Codigo do banco                             
      vr_cdageban := rw_craplau.cdageban;  --> codigo da agencia bancaria. 
      vr_nrctatrf := rw_craplau.nrctadst;  --> conta que recebe a transferencia. 
      vr_nmtitula := rw_craplau.nmtitula;  --> nome do titular da conta. 
      vr_nrcpfcgc := rw_craplau.nrcpfcgc;  --> cpf/cnpj do titular da conta.  
      vr_vllanmto := rw_craplau.vllanaut;  --> Valor do lançamento
      vr_flmobile := rw_craplau.flmobile;  --> Indicador se origem é do Mobile
      vr_iptransa := rw_fraude.iptransacao;   --> IP da transacao no IBank/mobile
      vr_inpessoa := rw_craplau.inpessoa;  --> Tipo de pessoa da conta
      vr_intipcta := rw_craplau.intipcta;  --> Tipo da conta
      vr_idagenda := 1;                   --> Tipo de agendamento
    
    END IF;
  
  
    vr_dsassunt := (CASE 
                      WHEN vr_idagenda = 1 THEN 'TED/'
                      ELSE                      'Agendamento de TED/'
                    END) ||
                    vr_nmrescop||'/'|| 
                   ltrim(gene0002.fn_mask_conta(vr_nrdconta))||
                   '/R$ '||TRIM(to_char(vr_vllanmto,'fm999g999g990d00'));
  
    --> Busca dados da cooperativa
    OPEN  cr_crapcop(pr_cdcooper => vr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    CLOSE cr_crapcop;
  
    --> Buscar valor de limite minimo de monitoramento da TED
    vr_vlr_minmonted := rw_crapcop.vlmnlmtd;
  
    --> Buscar valor minimo de monitoramento por TED
    vr_vlr_minported := rw_crapcop.vlinited;
    
    --> Verificar se deve monitorar TEDs mobile
    vr_flmonmob := rw_crapcop.flmobted;
    
    --> Buscar lista de UFs a serem monitoradas
    vr_dsufsmon := rw_crapcop.dsestted;        
                                              
    ------------> INICIAR VALIDAÇÔES DO TED <------------
    
    --> Verificar se precisa monitorar TEDs oriundas do mobile
    IF vr_flmobile = 1 AND vr_flmonmob = 0 THEN
      --> sair sem monitorar
      RAISE vr_exc_naomonit;
    END IF;
    
    --> Buscar informacoes da agencia destino
    OPEN cr_crapagb (pr_cddbanco => vr_cddbanco,
                     pr_cdageban => vr_cdageban);
    FETCH cr_crapagb INTO rw_crapagb;    
    
    IF cr_crapagb%NOTFOUND THEN
      CLOSE cr_crapagb;
      vr_fcrapagb := FALSE;
      
      -- Se não encontrar a agencia buscar apenas o nome do banco
      OPEN cr_crapban(pr_cdbccxlt => vr_cddbanco);
      FETCH cr_crapban INTO rw_crapban;
      
      IF cr_crapban%NOTFOUND THEN
         CLOSE cr_crapban;
         RAISE vr_exc_naomonit;           
    END IF;
      
      CLOSE cr_crapban;
    ELSE
    CLOSE cr_crapagb;
      vr_fcrapagb := TRUE;
    
    --> caso esteja nulo deve considerar todos os UFs
    IF TRIM(vr_dsufsmon) IS NOT NULL THEN
      -- Verificar se estado da agencia destino consta a lista de monitoracao
      IF gene0002.fn_existe_valor(pr_base     => upper(vr_dsufsmon), 
                                  pr_busca    => upper(rw_crapagb.cdufresd),
                                  pr_delimite => ';') = 'N' THEN
        --> sair sem monitorar
        RAISE vr_exc_naomonit;
      END IF;
    END IF;
    END IF;    
    
    --> Se eh para trazer somente novos favorecidos
    IF rw_crapcop.flnvfted = 1 THEN
      -- Buscar se o favorecido esta cadastrado na CRAPCTI ha mais de um dia
      OPEN cr_crapcti(pr_cdcooper => vr_cdcooper
                     ,pr_nrdconta => vr_nrdconta
                     ,pr_cddbanco => vr_cddbanco
                     ,pr_nrctatrf => vr_nrctatrf
                     ,pr_cdageban => vr_cdageban
                     ,pr_inpessoa => vr_inpessoa
                     ,pr_intipcta => vr_intipcta
                     ,pr_nrcpfcgc => vr_nrcpfcgc);
      FETCH cr_crapcti INTO vr_qtregistro;
      -- Fecha cursor
      CLOSE cr_crapcti;
      -- Esta cadastrado na CRAPCTI ha mais de um dia
      IF vr_qtregistro > 0 THEN
        --> sair sem monitorar
        RAISE vr_exc_naomonit;
      END IF;
    END IF;
                   
    -- buscar dados do cooperado
    OPEN cr_crapass (pr_cdcooper => vr_cdcooper,
                     pr_nrdconta => vr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    IF cr_crapass%NOTFOUND THEN
      vr_dscritic:= 'Associado nao cadastrado.';
      CLOSE cr_crapass;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapass;
     
    --> Se nao houver monitoracao para TEDs da mesma titularidade
    IF rw_crapcop.flmstted = 0 AND rw_crapass.nrcpfcgc = vr_nrcpfcgc THEN
      --> sair sem monitorar
      RAISE vr_exc_naomonit;
    END IF;
    
    --> Se nao é para monitorar agendamento de TED
    IF vr_idagenda > 1 AND rw_crapcop.flmntage = 0 THEN
      --> sair sem monitorar
      RAISE vr_exc_naomonit;
    END IF;    
    
    --> Buscar limite de TED do cooperado
    OPEN cr_crapsnh (pr_cdcooper => vr_cdcooper
                    ,pr_nrdconta => vr_nrdconta
                    ,pr_idseqttl => vr_idseqttl);
    FETCH cr_crapsnh INTO rw_crapsnh;
    --> caso nao encontrar o limite de TED
    IF cr_crapsnh%NOTFOUND THEN
      CLOSE cr_crapsnh;
      vr_dscritic := 'Nao foi possivel localizar limite de TED do cooperado.';
      RAISE vr_exc_erro;      
    END IF;
    CLOSE cr_crapsnh;
 
    --> Se o valor da TED é menor que o valor minimo para monitoracao
    IF vr_vllanmto < vr_vlr_minported
      OR
      --> Se o valor de limite de ted é menor que o valor de limite minimo para monitoracao
      rw_crapsnh.vllimted < vr_vlr_minmonted
    THEN
      --Buscar destinatario email
      vr_email_dest:= gene0001.fn_param_sistema('CRED',vr_cdcooper,'MONITORA_TED_ABAIXO');
           
      --Se nao encontrou destinatario
      IF vr_email_dest IS NULL THEN
        --> sair sem monitorar
        RAISE vr_exc_naomonit;
      END IF;
    ELSE
      --Buscar destinatario email
      vr_email_dest:= gene0001.fn_param_sistema('CRED',vr_cdcooper,'MONITORAMENTO_TED');

      --Se nao encontrou destinatario
      IF vr_email_dest IS NULL THEN
        --Montar mensagem de erro
        vr_dscritic:= 'Nao foi encontrado destinatario para os e-mails de monitoramento.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
    END IF;
    ------------> MONTAR CORPO E-MAIL <------------
    IF vr_fcrapagb THEN
    vr_conteudo := 'Dados do Favorecido: '|| vr_nmtitula ||'<br>'||
                   'Banco: '       || vr_cddbanco ||'-'|| rw_crapagb.nmresbcc ||'<br>'||
                   'Agencia: '     || vr_cdageban||'-'|| rw_crapagb.nmageban ||'<br>'||
                   'Estado: '      || rw_crapagb.cdufresd ||'<br>'||
                   'Conta: '       || gene0002.fn_mask_conta(vr_nrctatrf)||'<br>'||
                   'IP Transacao: '|| vr_iptransa ||'<br>'||
                   'Limite diário TED: R$'|| to_char(rw_crapsnh.vllimted,'fm999g999g999g990d00')||'<br>'||
                   'Dados cooperado: '|| gene0002.fn_mask_conta(vr_nrdconta)||'<br>'||
                   'PA: '|| rw_crapass.cdagenci ||' - '||rw_crapass.nmresage|| '<br>';
    ELSE
      vr_conteudo := 'Dados do Favorecido: '|| vr_nmtitula ||'<br>'||
                     'Banco: '       || vr_cddbanco ||' - '||rw_crapban.nmextbcc||' <br>'||
                     'Agencia: '     || vr_cdageban||'- Nao encontrado <br>'||
                     'Estado: Nao encontrado <br>'||
                     'Conta: '       || gene0002.fn_mask_conta(vr_nrctatrf)||'<br>'||
                     'IP Transacao: '|| vr_iptransa ||'<br>'||
                     'Limite diário TED: R$'|| to_char(rw_crapsnh.vllimted,'fm999g999g999g990d00')||'<br>'||
                     'Dados cooperado: '|| gene0002.fn_mask_conta(vr_nrdconta)||'<br>'||
                     'PA: '|| rw_crapass.cdagenci ||' - '||rw_crapass.nmresage|| '<br>';      
    END IF;
     
    -- Se for pessoa fisica
    IF rw_crapass.inpessoa = 1 THEN
      --> Lista todos os titulares
      FOR rw_crapttl IN cr_crapttl (pr_cdcooper => vr_cdcooper
                                   ,pr_nrdconta => vr_nrdconta
                                   ,pr_idseqttl => NULL) LOOP
        --Concatenar Conteudo
        vr_conteudo:= vr_conteudo||'Titular '|| rw_crapttl.idseqttl ||
                                   ': '||rw_crapttl.nmextttl|| '<BR>';
      END LOOP;
    
    -- Se for pessoa juridica
    ELSIF rw_crapass.inpessoa = 2 THEN
      --> Lista o nome da empresa 
      OPEN cr_crapjur (pr_cdcooper => vr_cdcooper
                      ,pr_nrdconta => vr_nrdconta);
      FETCH cr_crapjur INTO rw_crapjur;
      --Se Encontrou
      IF cr_crapjur%FOUND THEN
        --Concatenar o nome da empresa
        vr_conteudo:= vr_conteudo||'Empresa: '|| rw_crapjur.nmextttl;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapjur;
      --Concatenar Procuradores/Representantes
      vr_conteudo:= vr_conteudo||'<BR><BR>'||
                    'Procuradores/Representantes: <BR>';
    
      --> Lista os procuradores/representantes 
      FOR rw_crapavt IN cr_crapavt (pr_cdcooper => vr_cdcooper
                                   ,pr_nrdconta => vr_nrdconta
                                   ,pr_tpctrato => 6) LOOP
        vr_crabass:= FALSE;
        --Se tem Contato
        IF rw_crapavt.nrdctato <> 0 THEN
          OPEN cr_crapass (pr_cdcooper => rw_crapavt.cdcooper
                          ,pr_nrdconta => rw_crapavt.nrdctato);
          --Posicionar Proximo Registro
          FETCH cr_crapass INTO rw_crabass;
          --Se Encontrou
          vr_crabass:= cr_crapass%FOUND;
          --Fechar Cursor
          CLOSE cr_crapass;
        END IF;
        IF rw_crapavt.nrdctato <> 0 AND vr_crabass THEN
          --Concatenar nome avalista
          vr_conteudo:= vr_conteudo||rw_crabass.nmprimtl|| '<BR>';
        ELSE
          --Concatenar nome avalista
          vr_conteudo:= vr_conteudo||rw_crapavt.nmdavali|| '<BR>';
        END IF;
      END LOOP;    
    END IF; --> Fim IF inpessoa
    
    --> Fones 
    vr_conteudo:= vr_conteudo|| '<BR>Fones:<BR>';
    --Encontrar numeros de telefone
    FOR rw_craptfc IN cr_craptfc (pr_cdcooper => vr_cdcooper
                                 ,pr_nrdconta => vr_nrdconta) LOOP
      --Montar Conteudo
      vr_conteudo:= vr_conteudo||'(' ||rw_craptfc.nrdddtfc|| ') '
                                     ||rw_craptfc.nrtelefo|| ' - '
                                     ||rw_craptfc.nmpescto|| '<BR>';
    END LOOP;
    
    vr_conteudo := vr_conteudo ||'<BR>'||'Valor TED: R$ '|| to_char(vr_vllanmto,'fm999g999g999g990d00')||'<br>';
    
    --Enviar Email
    GENE0003.pc_solicita_email(pr_cdcooper        => vr_cdcooper    --> Cooperativa conectada
                              ,pr_cdprogra        => 'PAGA0002'     --> Programa conectado
                              ,pr_des_destino     => vr_email_dest  --> Um ou mais detinatários separados por ';' ou ','
                              ,pr_des_assunto     => vr_dsassunt    --> Assunto do e-mail
                              ,pr_des_corpo       => vr_conteudo    --> Corpo (conteudo) do e-mail
                              ,pr_des_anexo       => NULL           --> Um ou mais anexos separados por ';' ou ','
                              ,pr_flg_remove_anex => 'N'            --> Remover os anexos passados
                              ,pr_flg_remete_coop => 'N'            --> Se o envio será do e-mail da Cooperativa
                              ,pr_des_nome_reply  => NULL           --> Nome para resposta ao e-mail
                              ,pr_des_email_reply => NULL           --> Endereço para resposta ao e-mail
                              ,pr_flg_enviar      => 'S'            --> Enviar o e-mail na hora
                              ,pr_flg_log_batch   => 'N'            --> Incluir inf. no log
                              ,pr_des_erro        => vr_dscritic);  --> Descricao Erro
    --Se ocorreu erro
    IF vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    
    COMMIT;
    
  EXCEPTION
    -- sair sem gerar monitoracao
    WHEN vr_exc_naomonit THEN
      NULL;
     -- COMMIT;
    WHEN vr_exc_erro THEN
     -- ROLLBACK;
      -- Gerar log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper,
                                 pr_ind_tipo_log => 2, 
                                 pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||
                                                    ' - AFRA0004.pc_monitora_ted --> '|| vr_dsassunt ||': '||vr_dscritic,
                                 pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));  
      
    --  COMMIT;
    WHEN OTHERS THEN
    --  ROLLBACK;
      vr_dscritic := SQLerrm;  
    
      -- Gerar log
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper,
                                 pr_ind_tipo_log => 2, 
                                 pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||
                                                    ' - AFRA0004.pc_monitora_ted --> '|| vr_dsassunt ||': '||vr_dscritic,
                                 pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));  
     -- COMMIT;
  END pc_monitora_ted;
  
  
  ---> Procedure destinada a monitorar operacao de Convenio
  PROCEDURE pc_monitora_convenios (pr_cdcooper IN  crapcop.cdcooper%TYPE  -- Codigo da cooperativa
                                  ,pr_nrdconta IN  crapttl.nrdconta%TYPE  -- Numero da conta
                                  ,pr_idseqttl IN  crapttl.idseqttl%TYPE  -- Sequencial titular
                                  ,pr_vlfatura IN  NUMBER                 -- Valor fatura
                                  ,pr_flgagend IN  INTEGER                -- Flag agendado /* 1-True, 0-False */ 
                                  ,pr_cdagenci IN  INTEGER                -- Codigo da agencia
                                  ,pr_dtmvtocd IN  DATE                   -- Data do movimento
                                  ,pr_cdcritic OUT INTEGER                -- Codigo da critica
                                  ,pr_dscritic OUT VARCHAR2) IS           -- Descricao critica
    /* ---------------------------------------------------------------------------

        Programa : pc_monitora_convenio
        Sistema  : Rotinas referentes a monitoracao de Analise de Fraude
        Sigla    : CRED
        Autor    : Teobaldo Jamunda - AMcom
        Data     : Abril/2018.                    Ultima atualizacao: __/__/2018

        Dados referentes ao programa:

        Frequencia: sempre que for chamado
        Objetivo  : Realizar a monitoracao de pagamento de convenio (PAGA0001)
                    (PRJ381 - Analise Antifraude, Teobaldo J. - AMcom)

        Alteracoes:  
        
    ----------------------------------------------------------------------------*/
    
    --Selecionar informacoes do titular
    CURSOR cr_crapttl (pr_cdcooper IN crapttl.cdcooper%type
                      ,pr_nrdconta IN crapttl.nrdconta%type
                      ,pr_idseqttl IN crapttl.idseqttl%type) IS
      SELECT crapttl.nmextttl
            ,crapttl.nrcpfcgc
            ,crapttl.idseqttl
       FROM crapttl
      WHERE crapttl.cdcooper = pr_cdcooper
      AND   crapttl.nrdconta = pr_nrdconta
      AND   crapttl.idseqttl = pr_idseqttl;
    rw_crapttl cr_crapttl%ROWTYPE;

    -- Busca as informações da cooperativa conectada
    rw_crapcop cr_crapcop%ROWTYPE;  

    -- Busca informacoes da autenticacao
    rw_crapaut cr_crapaut_sequen%ROWTYPE;
  
    -- Busca faturas
    rw_craplft cr_craplft%ROWTYPE;

    -- Selecionar a data de abertura da conta
    rw_crapass_data cr_crapass_data%ROWTYPE;

    -- Busca Informacoes Agencia
    rw_crapage cr_crapage%ROWTYPE;

    -- Busca dados Pessoa Juridica
    rw_crapjur cr_crapjur%ROWTYPE;
    
    -- Busca dados Avalistas
    rw_crapavt cr_crapavt2%ROWTYPE;
    
    -- Busca os telefones do titular
    rw_craptfc cr_craptfc%ROWTYPE;

    -- Busca dados do asssociado
    rw_cra2ass      cr_crapass%ROWTYPE;
    rw_crapass_prot cr_crapass%ROWTYPE;

    -- Variaveis de Erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic    VARCHAR2(4000);
    vr_exc_erro    EXCEPTION;

    -- Variaveis Locais
    vr_cdagenci    INTEGER;
    vr_datdodia    DATE;
    vr_flgemail    BOOLEAN;
    vr_vlpagtos    NUMBER;
    vr_qtpagtos    NUMBER := 0;
    vr_dspagtos    VARCHAR2(4000);
    vr_dtabtcct    DATE;
    vr_qtidenti    INTEGER;
    vr_dtlimite    DATE;
    vr_nrdipatu    VARCHAR2(1000);
    vr_nrdipant    VARCHAR2(1000);
    vr_exec_lgm    EXCEPTION;
    vr_conteudo    VARCHAR2(4000);
    vr_cra2ass     BOOLEAN;
    vr_des_assunto VARCHAR2(100);
    vr_email_dest  VARCHAR2(100);
    vr_agendame    VARCHAR2(100);

  BEGIN
      --Inicializar variaveis
      pr_cdcritic:= NULL;
      pr_dscritic:= NULL;
      vr_cdagenci:= pr_cdagenci;
      
      -- Verificar cooperativa
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      -- Se nao encontrou
      IF cr_crapcop%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapcop;
        vr_cdcritic:= 0;
        vr_dscritic:= 'Cooperativa nao cadastrada.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      -- Fechar Cursor
      CLOSE cr_crapcop;

      -- Selecionar informacoes do associado
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      --Posicionar no primeiro registro
      FETCH cr_crapass INTO rw_crapass_prot;
      --Se nao encontrou
      IF cr_crapass%NOTFOUND THEN
        --Mensagem Erro
        vr_cdcritic:= 0;
        vr_dscritic:= 'Associado nao cadastrado.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapass;

      /** ------------------------------------------------------------- **
       ** Monitoracao Pagamentos - Antes de alterar verificar com David **
       ** ------------------------------------------------------------- **
       ** Envio de monitoracao sera enviado se for pagto via Internet,  **
       ** se nao for pagto via DDA, se nao for pagto proveniente de     **
       ** agendamento, se nao for boleto de cobranca registrada da      **
       ** cooperativa, se o valor individual ou total pago no dia pelo  **
       ** cooperado for maior que o limite estipulado para cooperativa  **
       ** atraves da tela PARMON no ayllos web.                         **
       ** exemplo: valor inicial monitoracao =   700,00                 **
       **          valor monitoracao IP      = 3.000,00                 **
       ** Será enviado email de monitoracao apenas quando:              **
       ** - Valor pago for maior ou igual a 3.000,00 independente do ip **
       ** - Valor pago for maior ou igual a 700,00 até 2.999,99 será    **
       ** verificado o IP anterior, caso seja diferente, envia email.   **
       ** ------------------------------------------------------------- **/

      IF vr_cdagenci = 90 AND pr_flgagend = 0 THEN /*0-false*/
        
        --Flag email recebe true
        vr_flgemail:= TRUE;

        /** Soma o total de pagtos efetuados pelo cooperado no dia e armazena
            esses pagtos para enviar no email **/

        IF vr_flgemail THEN
          --Zerar valor pagamentos
          vr_vlpagtos:= 0;
          vr_dspagtos:= NULL;
          --Selecionar todos protocolos das transacoes
          FOR rw_crappro IN cr_crappro (pr_cdcooper => rw_crapcop.cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_dtmvtolt => pr_dtmvtocd /* era: rw_crapdat.dtmvtocd */
                                       ,pr_cdtippro => 2) LOOP     /* 2 - pagamento */
                                       
            --Verificar se precisa ignorar registro.
            --#Banco indica que é título e Estornado não é necessário
            IF InStr(rw_crappro.dsinform##2,'#Banco:') > 0 OR
               InStr(Upper(rw_crappro.dsprotoc),'ESTORNADO') > 0 THEN
              CONTINUE;
            END IF;

            --Verificar as autenticacoes
            OPEN cr_crapaut_sequen (pr_cdcooper => rw_crappro.cdcooper
                                   ,pr_cdagenci => vr_cdagenci
                                   ,pr_nrdcaixa => 900
                                   ,pr_dtmvtolt => rw_crappro.dtmvtolt
                                   ,pr_nrsequen => rw_crappro.nrseqaut);
            --Posicionar no proximo registro
            FETCH cr_crapaut_sequen INTO rw_crapaut;
            --Se nao encontrar
            IF cr_crapaut_sequen%NOTFOUND OR rw_crapaut.dsprotoc <> rw_crappro.dsprotoc THEN
              --Fechar Cursor
              CLOSE cr_crapaut_sequen;
              --Proximo Registro
              CONTINUE;
            END IF;

            --Fechar Cursor
            CLOSE cr_crapaut_sequen;

            --Selecionar Faturas
            OPEN cr_craplft (pr_cdcooper => rw_crapaut.cdcooper
                            ,pr_dtmvtolt => rw_crapaut.dtmvtolt
                            ,pr_cdagenci => rw_crapaut.cdagenci
                            ,pr_cdbccxlt => 11
                            ,pr_nrdolote => 15900
                            ,pr_nrseqdig => To_Number(rw_crapaut.nrdocmto));
            --Posicionar no proximo registro
            FETCH cr_craplft INTO rw_craplft;
            --Se encontrar
            IF cr_craplft%FOUND THEN

              --Acumular pagamentos
              vr_vlpagtos:= NVL(vr_vlpagtos,0) + rw_craplft.vllanmto;
              vr_qtpagtos:= NVL(vr_qtpagtos,0) + 1;

              IF rw_crappro.flgagend = 1 THEN
                 vr_agendame := ' Agendamento';
              ELSE
                 vr_agendame := '';
              END IF;

              --Concatenar Descricao Pagamentos
              IF nvl(length(vr_dspagtos),0) < 2400 THEN
                vr_dspagtos:= vr_dspagtos||'Convenio: '||rw_crappro.dscedent||
                              '<BR>Valor do Pagamento: R$ '||
                              to_char(rw_craplft.vllanmto,'fm999G999G999G999D00')||
                              ' - Cod.Barras: '|| rw_craplft.cdbarras ||
                              vr_agendame ||'<BR><BR>';
              END IF;

            END IF;

            CLOSE cr_craplft; --Fechar Cursor
          END LOOP; --rw_crappro

          /** Verifica se o valor do pagto eh menor que o parametrizado
          e total pago no dia eh menor que o parametrizado**/
          IF pr_vlfatura < rw_crapcop.vlinimon AND
             vr_vlpagtos < rw_crapcop.vlinimon THEN
            --Flag email
            vr_flgemail:= FALSE;
          END IF;

        END IF; --vr_flgemail


        IF vr_flgemail AND (pr_vlfatura < rw_crapcop.vllmonip) THEN
          -- Selecionar ultimo log transacao sistema
          OPEN cr_crapass_data(pr_cdcooper => rw_crapcop.cdcooper
                              ,pr_nrdconta => pr_nrdconta);
          FETCH cr_crapass_data INTO rw_crapass_data;
          IF cr_crapass_data%FOUND THEN
            vr_dtabtcct := rw_crapass_data.dtabtcct;
          END IF;

          CLOSE cr_crapass_data;

          vr_qtidenti:= 0;
          vr_dtlimite:= vr_datdodia;
          BEGIN
            WHILE vr_dtlimite >= vr_dtabtcct LOOP

              FOR rw_craplgm IN cr_craplgm(pr_cdcooper => rw_crapcop.cdcooper
                                          ,pr_nrdconta => pr_nrdconta
                                          ,pr_idseqttl => pr_idseqttl
                                          ,pr_dttransa => vr_dtlimite
                                          ,pr_dsorigem => 'INTERNET'
                                          ,pr_cdoperad => '996'
                                          ,pr_flgtrans => 1
                                          ,pr_dstransa => 'Efetuado login de acesso a conta on-line.') LOOP

                --Selecionar tabela complementar de log
                FOR rw_craplgi IN cr_craplgi(pr_cdcooper => rw_craplgm.cdcooper,
                                             pr_nrdconta => rw_craplgm.nrdconta,
                                             pr_idseqttl => rw_craplgm.idseqttl,
                                             pr_dttransa => rw_craplgm.dttransa,
                                             pr_hrtransa => rw_craplgm.hrtransa,
                                             pr_nrsequen => rw_craplgm.nrsequen,
                                             pr_nmdcampo => 'IP') LOOP
                  IF TRIM(vr_nrdipatu) IS NULL THEN
                    vr_nrdipatu := rw_craplgi.dsdadatu;
                  ELSE
                    IF TRIM(vr_nrdipant) IS NOT NULL THEN
                      vr_nrdipant := vr_nrdipant || ';';
                    END IF;

                    vr_nrdipant := vr_nrdipant || rw_craplgi.dsdadatu;
                    vr_qtidenti := vr_qtidenti + 1;

                  END IF;

                  -- Verificar se foram identificados três IP
                  IF vr_qtidenti >= 3 THEN
                    RAISE vr_exec_lgm;
                  END IF;


                END LOOP;-- Loop craplgi
              END LOOP;-- Loop craplgm

              vr_dtlimite := vr_dtlimite - 1;

            END LOOP; -- Loop da data
          EXCEPTION
            -- Exception para quando encontrar os três registros de IP
            WHEN vr_exec_lgm THEN
              NULL;

            WHEN OTHERS THEN
              NULL;

          END;

          --Verificar se os ultimos IPs sao iguais
          IF GENE0002.fn_existe_valor(pr_base     => vr_nrdipant
                                     ,pr_busca    => vr_nrdipatu
                                     ,pr_delimite => ';') = 'S' THEN
            vr_flgemail:= FALSE;
          END IF;

        END IF; --vr_flgemail

        /** Enviar email para monitoracao se passou pelos filtros **/
        IF vr_flgemail THEN
          vr_conteudo:= 'PA: '||rw_crapass_prot.cdagenci;
          --Selecionar Agencia
          OPEN cr_crapage (pr_cdcooper => pr_cdcooper
                          ,pr_cdagenci => rw_crapass_prot.cdagenci);
          --Posicionar Proximo Registro
          FETCH cr_crapage INTO rw_crapage;
          --Se encontrou a agencia
          IF cr_crapage%FOUND THEN
            vr_conteudo:= vr_conteudo|| ' - '||rw_crapage.nmresage;
          END IF;

          --Fechar Cursor
          CLOSE cr_crapage;
          --Adicionar numero da conta na mensagem
          vr_conteudo:= vr_conteudo|| '<BR><BR>'||'Conta: '|| pr_nrdconta|| '<BR>';
          --Se for pessoa fisica
          IF rw_crapass_prot.inpessoa = 1 THEN
            /** Lista todos os titulares **/
            FOR rw_crapttl IN cr_crapttl (pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_idseqttl => pr_idseqttl) LOOP
              --Concatenar Conteudo
              vr_conteudo:= vr_conteudo||'Titular '|| rw_crapttl.idseqttl ||
                                         ': '||rw_crapttl.nmextttl|| '<BR>';
            END LOOP;

          ELSE
            /** Lista o nome da empresa **/

            OPEN cr_crapjur (pr_cdcooper => pr_cdcooper
                            ,pr_nrdconta => pr_nrdconta);
            FETCH cr_crapjur INTO rw_crapjur;
            --Se Encontrou
            IF cr_crapjur%FOUND THEN
              --Concatenar o nome da empresa
              vr_conteudo:= vr_conteudo||'Empresa: '|| rw_crapjur.nmextttl;
            END IF;

            --Fechar Cursor
            CLOSE cr_crapjur;
            --Concatenar Procuradores/Representantes
            vr_conteudo:= vr_conteudo||'<BR><BR>'||
                          'Procuradores/Representantes: <BR>';
            /** Lista os procuradores/representantes **/

            FOR rw_crapavt IN cr_crapavt2 (pr_cdcooper => pr_cdcooper
                                          ,pr_nrdconta => pr_nrdconta
                                          ,pr_tpctrato => 6) LOOP
              vr_cra2ass:= FALSE;
              --Se tem Contato
              IF rw_crapavt.nrdctato <> 0 THEN
                OPEN cr_crapass (pr_cdcooper => rw_crapavt.cdcooper
                                ,pr_nrdconta => rw_crapavt.nrdctato);
                --Posicionar Proximo Registro
                FETCH cr_crapass INTO rw_cra2ass;
                --Se Encontrou
                vr_cra2ass:= cr_crapass%FOUND;
                --Fechar Cursor
                CLOSE cr_crapass;
              END IF;

              IF rw_crapavt.nrdctato <> 0 AND vr_cra2ass THEN
                --Concatenar nome avalista
                vr_conteudo:= vr_conteudo||rw_cra2ass.nmprimtl|| '<BR>';
              ELSE
                --Concatenar nome avalista
                vr_conteudo:= vr_conteudo||rw_crapavt.nmdavali|| '<BR>';

              END IF;

            END LOOP;

          END IF;

          /* Fones */

          vr_conteudo:= vr_conteudo|| '<BR>Fones:<BR>';
          --Encontrar numeros de telefone
          FOR rw_craptfc IN cr_craptfc (pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta) LOOP
            --Montar Conteudo
            vr_conteudo:= vr_conteudo||'(' ||rw_craptfc.nrdddtfc|| ') '||
                                       rw_craptfc.nrtelefo|| '<BR>';
          END LOOP;

          --Concatenar Pagamentos
          vr_conteudo:= vr_conteudo|| '<BR>'|| vr_dspagtos;
          vr_conteudo:= vr_conteudo||'Quantidade pagto: '||to_char(vr_qtpagtos,'fm999G990')
                                   ||' Valor total: '||to_char(vr_vlpagtos,'fm999G999G999G999D00');


          --Determinar Assunto
          vr_des_assunto:= 'PAGTO CONVENIOS '||rw_crapcop.nmrescop ||' '||
                           GENE0002.fn_mask_conta(pr_nrdconta)|| ' R$ '||
                           TRIM(to_char(pr_vlfatura,'fm999g999g999g999d99'));

          --Buscar destinatario email
          vr_email_dest:= gene0001.fn_param_sistema('CRED',pr_cdcooper,'INTERNETBANK_PAGTO');
          --Se nao encontrou destinatario
          IF vr_email_dest IS NULL THEN
            --Montar mensagem de erro
            vr_dscritic:= 'Nao foi encontrado destinatario para os pagamentos via InternetBank.';
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;


          --Enviar Email
          GENE0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper    --> Cooperativa conectada
                                    ,pr_cdprogra        => 'INTERNETBANK' --> Programa conectado
                                    ,pr_des_destino     => vr_email_dest  --> Um ou mais detinatários separados por ';' ou ','
                                    ,pr_des_assunto     => vr_des_assunto --> Assunto do e-mail
                                    ,pr_des_corpo       => vr_conteudo    --> Corpo (conteudo) do e-mail
                                    ,pr_des_anexo       => NULL           --> Um ou mais anexos separados por ';' ou ','
                                    ,pr_flg_remove_anex => 'N'            --> Remover os anexos passados
                                    ,pr_flg_remete_coop => 'N'            --> Se o envio será do e-mail da Cooperativa
                                    ,pr_des_nome_reply  => NULL           --> Nome para resposta ao e-mail
                                    ,pr_des_email_reply => NULL           --> Endereço para resposta ao e-mail
                                    ,pr_flg_enviar      => 'S'            --> Enviar o e-mail na hora
                                    ,pr_flg_log_batch   => 'N'            --> Incluir inf. no log
                                    ,pr_des_erro        => vr_dscritic);  --> Descricao Erro
          --Se ocorreu erro
          IF vr_dscritic IS NOT NULL THEN
            vr_cdcritic:= 0;
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;

        END IF;

      END IF;  /* vr_cdagenci = 90 */

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        -- Erro
        pr_dscritic:= 'Erro na rotina AFRA0004.pc_monitora_convenio. '||sqlerrm;

    END pc_monitora_convenios;


  ---> Procedure destinada a monitorar operacao de Convenio
  PROCEDURE pc_monitora_titulos (pr_cdcooper IN  crapcop.cdcooper%TYPE  -- Codigo da cooperativa
                                ,pr_nrdconta IN  crapttl.nrdconta%TYPE  -- Numero da conta
                                ,pr_idseqttl IN  crapttl.idseqttl%TYPE  -- Sequencial titular
                                ,pr_vllanmto IN  NUMBER                 -- Valor Lancamento
                                ,pr_flgagend IN  INTEGER                -- Flag agendado /* 1-True, 0-False */ 
                                ,pr_cdagenci IN  INTEGER                -- Codigo da agencia
                                ,pr_dtmvtocd IN  DATE                   -- Data do movimento
                                ,pr_dtmvtolt IN  DATE                   -- Data de pagamento 
                                ,pr_flgpgdda IN  craptit.flgpgdda%TYPE  -- DDA 
                                ,pr_cdcritic OUT INTEGER                -- Codigo da critica
                                ,pr_dscritic OUT VARCHAR2 ) IS          -- Descricao critica
                                
    /* ---------------------------------------------------------------------------

        Programa : pc_monitora_titulos
        Sistema  : Rotinas referentes a monitoracao de Analise de Fraude
        Sigla    : CRED
        Autor    : Teobaldo Jamunda - AMcom
        Data     : Abril/2018.                    Ultima atualizacao: 17/09/2018

        Dados referentes ao programa:

        Frequencia: sempre que for chamado
        Objetivo  : Realizar a monitoracao de pagamento de titulos (PAGA0001)
                    (PRJ381 - Analise Antifraude, Teobaldo J. - AMcom)

        Alteracoes: 28/08/2018 - Inserido parametro com descricao do tipo de titulo (Tiago - RITM0025395) 
        
                    17/09/2018 - Correções referentes a monitoração de DDA (Tiago - RITM0025395)        
    ----------------------------------------------------------------------------*/

    --Selecionar informacoes dos titulares da conta
    CURSOR cr_crapttl (pr_cdcooper IN crapttl.cdcooper%TYPE
                      ,pr_nrdconta IN crapttl.nrdconta%TYPE
                      ,pr_idseqttl IN crapttl.idseqttl%type) IS
      SELECT crapttl.cdcooper
            ,crapttl.nrdconta
            ,crapttl.cdempres
            ,crapttl.cdturnos
            ,crapttl.nmextttl
            ,crapttl.idseqttl
      FROM crapttl crapttl
      WHERE crapttl.cdcooper = pr_cdcooper
      AND   crapttl.nrdconta = pr_nrdconta
      AND   (
            (trim(pr_idseqttl) IS NOT NULL AND crapttl.idseqttl = pr_idseqttl) OR
            (trim(pr_idseqttl) IS NULL)
            );
    rw_crapttl cr_crapttl%ROWTYPE;

    --Selecionar parametros Cobranca
    CURSOR cr_crapcco (pr_cdcooper IN crapcco.cdcooper%type
                      ,pr_nrconven IN crapcco.nrconven%type
                      ,pr_cddbanco IN crapcco.cddbanco%type) IS
      SELECT crapcco.flgregis
        FROM crapcco
       WHERE crapcco.cdcooper = pr_cdcooper
       AND   crapcco.nrconven = pr_nrconven
       AND   crapcco.cddbanco = pr_cddbanco;
    rw_crapcco cr_crapcco%ROWTYPE;

    --Selecionar Titulos
    CURSOR cr_craptit (pr_cdcooper IN craptit.cdcooper%type
                      ,pr_dtmvtolt IN craptit.dtmvtolt%type
                      ,pr_cdagenci IN craptit.cdagenci%type
                      ,pr_cdbccxlt IN craptit.cdbccxlt%type
                      ,pr_nrdolote IN craptit.nrdolote%type
                      ,pr_nrseqdig IN craptit.nrseqdig%type) IS
      SELECT craptit.dscodbar
            ,craptit.flgpgdda
            ,craptit.vldpagto
      FROM craptit
      WHERE craptit.cdcooper = pr_cdcooper
      AND   craptit.dtmvtolt = pr_dtmvtolt
      AND   craptit.cdagenci = pr_cdagenci
      AND   craptit.cdbccxlt = pr_cdbccxlt
      AND   craptit.nrdolote = pr_nrdolote
      AND   craptit.nrseqdig = pr_nrseqdig;
    rw_craptit cr_craptit%ROWTYPE;
    
    --Selecionar transacoes de operações conjuntas      
    CURSOR cr_tbpagto_trans_pend (pr_cdcooper IN craptit.cdcooper%TYPE
                                 ,pr_nrdconta IN craptit.nrdconta%TYPE
                                 ,pr_dtmvtolt IN craptit.dtmvtolt%TYPE
                                 ,pr_dscodbar IN craptit.dscodbar%TYPE) IS
      SELECT tbgen_trans_pend.nrcpf_operador
        FROM tbpagto_trans_pend,
             tbgen_trans_pend
       WHERE tbpagto_trans_pend.cdcooper = pr_cdcooper
         AND tbpagto_trans_pend.nrdconta = pr_nrdconta
         AND tbpagto_trans_pend.tppagamento = 2 /* Título */ 
         AND tbpagto_trans_pend.dtdebito = pr_dtmvtolt
         AND tbpagto_trans_pend.dscodigo_barras = pr_dscodbar
         AND tbgen_trans_pend.cdtransacao_pendente =
             tbpagto_trans_pend.cdtransacao_pendente;
    rw_tbpagto_trans_pend cr_tbpagto_trans_pend%ROWTYPE;

    -- buscar operador da conta.
    CURSOR cr_crapopi (pr_cdcooper IN crapopi.cdcooper%type
                      ,pr_nrdconta IN crapopi.nrdconta%TYPE
                      ,pr_nrcpfope IN crapopi.nrcpfope%TYPE) IS
      SELECT crapopi.nmoperad
        FROM crapopi
       WHERE crapopi.cdcooper = pr_cdcooper
       AND   crapopi.nrdconta = pr_nrdconta
       AND   crapopi.nrcpfope = pr_nrcpfope;
    rw_crapopi cr_crapopi%ROWTYPE;
      
    --Dados cooperativa
    rw_crapcop cr_crapcop%ROWTYPE;
    
    --Registro informacoes da autenticacao
    rw_crapaut cr_crapaut_sequen%ROWTYPE;
  
    --Registro a data de abertura da conta
    rw_crapass_data cr_crapass_data%ROWTYPE;

    --Registro Informacoes Agencia
    rw_crapage cr_crapage%ROWTYPE;
    
    --Registro Avalistas
    rw_crapavt cr_crapavt2%ROWTYPE;

    --Registro dados Pessoa Juridica
    rw_crapjur cr_crapjur%ROWTYPE;
    
    --Registro os telefones do titular
    rw_craptfc cr_craptfc%ROWTYPE;
    
    --Registro de dados de associado
    rw_cra2ass cr_crapass%ROWTYPE;
    rw_crapass_prot cr_crapass%ROWTYPE;
    
    --Variaveis de Erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;

    --Variaveis Locais
    vr_cdagenci    INTEGER;
    vr_datdodia    DATE;
    vr_flgemail    BOOLEAN;
    vr_vlpagtos    NUMBER;
    vr_qtpagtos    NUMBER := 0;
    vr_dspagtos    VARCHAR2(4000);
    vr_dtabtcct    DATE;
    vr_qtidenti    INTEGER;
    vr_dtlimite    DATE;
    vr_nrdipatu    VARCHAR2(1000);
    vr_nrdipant    VARCHAR2(1000);
    vr_exec_lgm    EXCEPTION;
    vr_conteudo    VARCHAR2(4000);
    vr_cra2ass     BOOLEAN;
    vr_des_assunto VARCHAR2(100);
    vr_email_dest  VARCHAR2(100);
    vr_agendame    VARCHAR2(100);
    vr_cdbccxlt    INTEGER;
    vr_indpagto    INTEGER;
    vr_flgpagto    BOOLEAN;
    vr_nrcnvco1    INTEGER;
    vr_nrcnvco2    INTEGER;
    vr_flgpagto    BOOLEAN;
    vr_rowidcob    ROWID;
    
  BEGIN
    -- Inicializar variaveis
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    vr_cdagenci:= pr_cdagenci;
    
    --> Busca dados da cooperativa
    OPEN  cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    CLOSE cr_crapcop;
    
    IF vr_cdagenci = 90 AND pr_flgagend = 0 THEN /*false*/
    
      -- Selecionar informacoes do associado
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);
      --Posicionar no primeiro registro
      FETCH cr_crapass INTO rw_crapass_prot;
      --Se nao encontrou
      IF cr_crapass%NOTFOUND THEN
        --Mensagem Erro
        vr_cdcritic:= 0;
        vr_dscritic:= 'Associado nao cadastrado.';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapass;
    
    
      --Flag email recebe true
      vr_flgemail:= TRUE;

      /** Soma o total de pagtos efetuados pelo cooperado no dia e armazena
          esses pagtos para enviar no email **/
      IF vr_flgemail THEN
        --Zerar valor pagamentos
        vr_vlpagtos:= 0;
        vr_dspagtos:= NULL;
        --Selecionar todos protocolos das transacoes
        FOR rw_crappro IN cr_crappro (pr_cdcooper => rw_crapcop.cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_dtmvtolt => pr_dtmvtocd /* era: rw_crapdat.dtmvtocd */
                                     ,pr_cdtippro => 2) LOOP     /* 2 - Pagamento */
          --Verificar se precisa ignorar registro
          IF pr_flgpgdda = 0 AND  
            (InStr(rw_crappro.dsinform##2,'#Banco:') = 0 OR
             InStr(Upper(rw_crappro.dsprotoc),'ESTORNADO') > 0) THEN
            --Ignorar registro
            CONTINUE;
          ELSE
            IF InStr(Upper(rw_crappro.dsprotoc),'ESTORNADO') > 0 THEN
              CONTINUE;
          END IF;
          END IF;

          --Verificar as autenticacoes
          OPEN cr_crapaut_sequen (pr_cdcooper => rw_crappro.cdcooper
                                 ,pr_cdagenci => vr_cdagenci
                                 ,pr_nrdcaixa => 900
                                 ,pr_dtmvtolt => rw_crappro.dtmvtolt
                                 ,pr_nrsequen => rw_crappro.nrseqaut);
          --Posicionar no proximo registro
          FETCH cr_crapaut_sequen INTO rw_crapaut;
          --Se nao encontrar
          IF cr_crapaut_sequen%NOTFOUND OR rw_crapaut.dsprotoc <> rw_crappro.dsprotoc THEN
            --Fechar Cursor
            CLOSE cr_crapaut_sequen;
            --Proximo Registro
            CONTINUE;
          END IF;
          --Fechar Cursor
          CLOSE cr_crapaut_sequen;

          --Selecionar Titulos
          OPEN cr_craptit (pr_cdcooper => rw_crapaut.cdcooper
                          ,pr_dtmvtolt => rw_crapaut.dtmvtolt
                          ,pr_cdagenci => rw_crapaut.cdagenci
                          ,pr_cdbccxlt => 11
                          ,pr_nrdolote => 16900
                          ,pr_nrseqdig => To_Number(rw_crapaut.nrdocmto));
          --Posicionar no proximo registro
          FETCH cr_craptit INTO rw_craptit;
          --Se nao encontrar
          IF cr_craptit%FOUND THEN
            
             -- Se estiver monitorando DDAs, pegar no email apenas titulos DDA
             IF    pr_flgpgdda = 1  
              AND  rw_craptit.flgpgdda = 0 THEN
                CONTINUE;
             END IF;
          
            --Codigo banco Caixa
            vr_cdbccxlt:= to_number(SUBSTR(rw_craptit.dscodbar,1,3));
            IF  vr_cdbccxlt IN (1,85)  THEN
              --Coluna 1 Convenio
              vr_nrcnvco1:= to_number(SUBSTR(RPad(rw_craptit.dscodbar,44,'9'),20,6));
              --Coluna 2 Convenio
              vr_nrcnvco2:= to_number(SUBSTR(RPad(rw_craptit.dscodbar,44,'9'),26,7));

              --Selecionar parametros Cobranca
              OPEN cr_crapcco (pr_cdcooper => rw_crapcop.cdcooper
                              ,pr_nrconven => vr_nrcnvco1
                              ,pr_cddbanco => vr_cdbccxlt);
              --Posicionar no proximo registro
              FETCH cr_crapcco INTO rw_crapcco;
              --Se nao encontrar
              IF cr_crapcco%NOTFOUND THEN
                --Fechar Cursor
                CLOSE cr_crapcco;
                --Selecionar parametros 2 convenio
                OPEN cr_crapcco (pr_cdcooper => rw_crapcop.cdcooper
                                ,pr_nrconven => vr_nrcnvco2
                                ,pr_cddbanco => vr_cdbccxlt);
                --Posicionar no proximo registro
                FETCH cr_crapcco INTO rw_crapcco;
                --Se nao encontrar
                IF cr_crapcco%NOTFOUND OR rw_crapcco.flgregis = 0 THEN
                  -- Verificar se foi agendado por operador da conta
                  OPEN cr_tbpagto_trans_pend (pr_cdcooper => rw_crapcop.cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_dtmvtolt => rw_crapaut.dtmvtolt
                                  ,pr_dscodbar => rw_craptit.dscodbar);
                  FETCH cr_tbpagto_trans_pend INTO rw_tbpagto_trans_pend;
                  IF cr_tbpagto_trans_pend%FOUND THEN
                     --Caso foi agendado por operador, pegar o nome
                     OPEN cr_crapopi (pr_cdcooper => rw_crapcop.cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_nrcpfope => rw_tbpagto_trans_pend.nrcpf_operador);
                     FETCH cr_crapopi INTO rw_crapopi;
                     IF cr_crapopi%FOUND THEN
                       -- se for maior não irá comportar toda a mensagem
                       IF nvl(length(vr_dspagtos),0) < 2330 THEN
                         vr_dspagtos := vr_dspagtos ||' Agendado pelo operador: ' ||
                                       rw_crapopi.nmoperad || '<BR>';
                       END IF;
                     END IF;
                     -- Fechar Cursor
                     CLOSE cr_crapopi;

                  END IF;
                  -- Fechar Cursor
                  CLOSE cr_tbpagto_trans_pend;

                  --Acumular pagamentos
                  vr_vlpagtos:= NVL(vr_vlpagtos,0) + rw_craptit.vldpagto;
                  vr_qtpagtos:= NVL(vr_qtpagtos,0) + 1;

                  --Concatenar Descricao Pagamentos
                  IF nvl(length(vr_dspagtos),0) < 2400 THEN

                    IF rw_crappro.flgagend = 1 THEN
                       vr_agendame := ' Agendamento';
                    ELSE
                       vr_agendame := '';
                    END IF;

                    vr_dspagtos:= vr_dspagtos||'Cedente: '||rw_crappro.dscedent||
                                  '<BR>Valor do Pagamento: R$ '||
                                  to_char(rw_craptit.vldpagto,'fm999G999G999G999D00')||
                                  ' - Cod.Barras: '|| rw_craptit.dscodbar ||
                                  vr_agendame||'<BR><BR>';
                  END IF;
                END IF;
                --Fechar Cursor
                CLOSE cr_crapcco;
              END IF;
              --Fechar Cursor
              IF cr_crapcco%ISOPEN THEN
                CLOSE cr_crapcco;
              END IF;
            ELSE
              -- Verificar se foi agendado por operador da conta
              OPEN cr_tbpagto_trans_pend (pr_cdcooper => rw_crapcop.cdcooper
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_dtmvtolt => rw_crapaut.dtmvtolt
                              ,pr_dscodbar => rw_craptit.dscodbar);
              FETCH cr_tbpagto_trans_pend INTO rw_tbpagto_trans_pend;
              IF cr_tbpagto_trans_pend%FOUND THEN
                 --Caso foi agendado por operador, pegar o nome
                 OPEN cr_crapopi (pr_cdcooper => rw_crapcop.cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrcpfope => rw_tbpagto_trans_pend.nrcpf_operador);
                 FETCH cr_crapopi INTO rw_crapopi;
                 IF cr_crapopi%FOUND THEN
                   -- se for maior não irá comportar toda a mensagem
                   IF nvl(length(vr_dspagtos),0) < 2330 THEN
                     vr_dspagtos := vr_dspagtos ||' Agendado pelo operador: ' ||
                                   rw_crapopi.nmoperad || '<BR>';
                   END IF;
                 END IF;
                 -- Fechar Cursor
                 CLOSE cr_crapopi;

              END IF;
              -- Fechar Cursor
              CLOSE cr_tbpagto_trans_pend;

              --Acumular pagamentos
              vr_vlpagtos:= nvl(vr_vlpagtos,0) + rw_craptit.vldpagto;
              vr_qtpagtos:= NVL(vr_qtpagtos,0) + 1;

              IF rw_crappro.flgagend = 1 THEN
                 vr_agendame := ' Agendamento';
              ELSE
                 vr_agendame := '';
              END IF;

              --Concatenar Descricao Pagamentos
              IF nvl(length(vr_dspagtos),0) < 2400 THEN
                vr_dspagtos:= vr_dspagtos||'Cedente: '||rw_crappro.dscedent||
                              '<BR>Valor do Pagamento: R$ '||
                              to_char(rw_craptit.vldpagto,'fm999G999G999G999D00')||
                              ' - Cod.Barras: '|| rw_craptit.dscodbar ||
                              vr_agendame||'<BR><BR>';
              END IF;
            END IF; --vr_cdbccxlt IN (1,85)
          END IF;
          --Fechar Cursor
          CLOSE cr_craptit;
        END LOOP; --rw_crappro

        /** Verifica se o valor do pagto eh menor que o parametrizado **/
        IF pr_vllanmto < rw_crapcop.vlinimon  THEN
          /** Verifica se total pago no dia eh menor que o parametrizado **/
          IF vr_vlpagtos < rw_crapcop.vlinimon THEN
            --Flag email
            vr_flgemail:= FALSE;
          END IF;
        END IF;
      END IF; --vr_flgemail

      IF vr_flgemail AND (pr_vllanmto < rw_crapcop.vllmonip) THEN
        --Selecionar ultimo log transacao sistema
        OPEN cr_crapass_data(pr_cdcooper => rw_crapcop.cdcooper
                            ,pr_nrdconta => pr_nrdconta);
        FETCH cr_crapass_data INTO rw_crapass_data;
        IF cr_crapass_data%FOUND THEN
          vr_dtabtcct := rw_crapass_data.dtabtcct;
        END IF;
        CLOSE cr_crapass_data;

        vr_qtidenti:= 0;
        vr_dtlimite:= vr_datdodia;
        BEGIN
          WHILE vr_dtlimite >= vr_dtabtcct LOOP

            FOR rw_craplgm IN cr_craplgm(pr_cdcooper => rw_crapcop.cdcooper
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_idseqttl => pr_idseqttl
                                        ,pr_dttransa => vr_dtlimite
                                        ,pr_dsorigem => 'INTERNET'
                                        ,pr_cdoperad => '996'
                                        ,pr_flgtrans => 1
                                        ,pr_dstransa => 'Efetuado login de acesso a conta on-line.') LOOP

              --Selecionar tabela complementar de log
              FOR rw_craplgi IN cr_craplgi(pr_cdcooper => rw_craplgm.cdcooper,
                                           pr_nrdconta => rw_craplgm.nrdconta,
                                           pr_idseqttl => rw_craplgm.idseqttl,
                                           pr_dttransa => rw_craplgm.dttransa,
                                           pr_hrtransa => rw_craplgm.hrtransa,
                                           pr_nrsequen => rw_craplgm.nrsequen,
                                           pr_nmdcampo => 'IP') LOOP
                IF TRIM(vr_nrdipatu) IS NULL THEN
                  vr_nrdipatu := rw_craplgi.dsdadatu;
                ELSE
                  IF TRIM(vr_nrdipant) IS NOT NULL THEN
                    vr_nrdipant := vr_nrdipant || ';';
                  END IF;
                  vr_nrdipant := vr_nrdipant || rw_craplgi.dsdadatu;
                  vr_qtidenti := vr_qtidenti + 1;
                END IF;
                -- Verificar se foram identificados três IP
                IF vr_qtidenti >= 3 THEN
                  RAISE vr_exec_lgm;
                END IF;

              END LOOP;-- Loop craplgi
            END LOOP;-- Loop craplgm

            vr_dtlimite := vr_dtlimite - 1;

          END LOOP; -- Loop da data
        EXCEPTION
          -- Exceptiond para quando encontrar os três registros de IP
          WHEN vr_exec_lgm THEN
            NULL;
          WHEN OTHERS THEN
            NULL;
        END;

        --Verificar se os ultimos IPs sao iguais
        IF GENE0002.fn_existe_valor(pr_base     => vr_nrdipant
                                   ,pr_busca    => vr_nrdipatu
                                   ,pr_delimite => ';') = 'S' THEN
          vr_flgemail:= FALSE;
        END IF;
      END IF; --vr_flgemail

      /** Enviar email para monitoracao se passou pelos filtros **/
      IF vr_flgemail THEN
        vr_conteudo:= 'PA: '||rw_crapass_prot.cdagenci;
        --Selecionar Agencia
        OPEN cr_crapage (pr_cdcooper => pr_cdcooper
                        ,pr_cdagenci => rw_crapass_prot.cdagenci);
        --Posicionar Proximo Registro
        FETCH cr_crapage INTO rw_crapage;
        --Se encontrou a agencia
        IF cr_crapage%FOUND THEN
          vr_conteudo:= vr_conteudo|| ' - '||rw_crapage.nmresage;
        END IF;
        --Fechar Cursor
        CLOSE cr_crapage;
        --Adicionar numero da conta na mensagem
        vr_conteudo:= vr_conteudo|| '<BR><BR>'||'Conta: '|| pr_nrdconta|| '<BR>';
        --Se for pessoa fisica
        IF rw_crapass_prot.inpessoa = 1 THEN
          /** Lista todos os titulares **/
          FOR rw_crapttl IN cr_crapttl (pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_idseqttl => NULL) LOOP
            --Concatenar Conteudo
            vr_conteudo:= vr_conteudo||'Titular '|| rw_crapttl.idseqttl ||
                                       ': '||rw_crapttl.nmextttl|| '<BR>';
          END LOOP;
        ELSE
          /** Lista o nome da empresa **/
          OPEN cr_crapjur (pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta);
          FETCH cr_crapjur INTO rw_crapjur;
          --Se Encontrou
          IF cr_crapjur%FOUND THEN
            --Concatenar o nome da empresa
            vr_conteudo:= vr_conteudo||'Empresa: '|| rw_crapjur.nmextttl;
          END IF;
          --Fechar Cursor
          CLOSE cr_crapjur;
          --Concatenar Procuradores/Representantes
          vr_conteudo:= vr_conteudo||'<BR><BR>'||
                        'Procuradores/Representantes: <BR>';
          /** Lista os procuradores/representantes **/
          FOR rw_crapavt IN cr_crapavt2 (pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_tpctrato => 6) LOOP
            vr_cra2ass:= FALSE;
            --Se tem Contato
            IF rw_crapavt.nrdctato <> 0 THEN
              OPEN cr_crapass (pr_cdcooper => rw_crapavt.cdcooper
                              ,pr_nrdconta => rw_crapavt.nrdctato);
              --Posicionar Proximo Registro
              FETCH cr_crapass INTO rw_cra2ass;
              --Se Encontrou
              vr_cra2ass:= cr_crapass%FOUND;
              --Fechar Cursor
              CLOSE cr_crapass;
            END IF;
            IF rw_crapavt.nrdctato <> 0 AND vr_cra2ass THEN
              --Concatenar nome avalista
              vr_conteudo:= vr_conteudo||rw_cra2ass.nmprimtl|| '<BR>';
            ELSE
              --Concatenar nome avalista
              vr_conteudo:= vr_conteudo||rw_crapavt.nmdavali|| '<BR>';
            END IF;
          END LOOP;
        END IF;
        /* Fones */
        vr_conteudo:= vr_conteudo|| '<BR>Fones:<BR>';
        --Encontrar numeros de telefone
        FOR rw_craptfc IN cr_craptfc (pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta) LOOP
          --Montar Conteudo
          vr_conteudo:= vr_conteudo||'(' ||rw_craptfc.nrdddtfc|| ') '||
                                     rw_craptfc.nrtelefo|| '<BR>';
        END LOOP;
        --Concatenar Pagamentos
        vr_conteudo:= vr_conteudo|| '<BR>'|| vr_dspagtos;
        vr_conteudo:= vr_conteudo||'Quantidade pagto: '||to_char(vr_qtpagtos,'fm999G990')
                                 ||' Valor total: '||to_char(vr_vlpagtos,'fm999G999G999G999D00');


        --Determinar Assunto
        vr_des_assunto:= 'PAGTO '||CASE pr_flgpgdda WHEN 0 THEN 'TITULOS ' ELSE 'DDA ' END||rw_crapcop.nmrescop ||' '||
                         GENE0002.fn_mask_conta(pr_nrdconta)|| ' R$ '||
                         TRIM(to_char(pr_vllanmto,'fm999g999g999g999d99'));

        --Buscar destinatario email
        vr_email_dest:= gene0001.fn_param_sistema('CRED',pr_cdcooper,'INTERNETBANK_PAGTO');
        --Se nao encontrou destinatario
        IF vr_email_dest IS NULL THEN
          --Montar mensagem de erro
          vr_dscritic:= 'Nao foi encontrado destinatario para os pagamentos via InternetBank.';
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;

        --Enviar Email
        GENE0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper    --> Cooperativa conectada
                                  ,pr_cdprogra        => 'INTERNETBANK' --> Programa conectado
                                  ,pr_des_destino     => vr_email_dest --> Um ou mais detinatários separados por ';' ou ','
                                  ,pr_des_assunto     => vr_des_assunto --> Assunto do e-mail
                                  ,pr_des_corpo       => vr_conteudo    --> Corpo (conteudo) do e-mail
                                  ,pr_des_anexo       => NULL           --> Um ou mais anexos separados por ';' ou ','
                                  ,pr_flg_remove_anex => 'N'            --> Remover os anexos passados
                                  ,pr_flg_remete_coop => 'N'            --> Se o envio será do e-mail da Cooperativa
                                  ,pr_des_nome_reply  => NULL           --> Nome para resposta ao e-mail
                                  ,pr_des_email_reply => NULL           --> Endereço para resposta ao e-mail
                                  ,pr_flg_enviar      => 'S'            --> Enviar o e-mail na hora
                                  ,pr_flg_log_batch    => 'N'           --> Incluir inf. no log
                                  ,pr_des_erro        => vr_dscritic);  --> Descricao Erro
        --Se ocorreu erro
        IF vr_dscritic IS NOT NULL THEN
          vr_cdcritic:= 0;
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
      END IF;
    END IF;
    
    IF vr_indpagto <> 0 THEN

      /* Procedure para gravar solicitação de envio da jdda */
      PAGA0001.pc_solicita_crapdda (pr_cdcooper  => pr_cdcooper    -- Codigo Cooperativa
                                   ,pr_dtmvtolt  => pr_dtmvtolt    /* era: rw_crapdat.dtmvtolt -- Data pagamento */
                                   ,pr_cobrowid  => vr_rowidcob    -- rowid de cobranca
                                   ,pr_dscritic  => vr_dscritic);  -- Descricao da critica

      IF TRIM(vr_dscritic) IS NOT NULL THEN
        --Nao mostrar erro para usuario., somente gerar log
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                   ,pr_ind_tipo_log => 2 -- Erro tratato
                                   ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                    || 'PAGA0001.pc_paga_titulo --> '
                                                    || 'erro ao gravar crapdda(crapcob.rowid = '||vr_rowidcob||'): '
                                                    || vr_dscritic );

        vr_dscritic := null;
      END IF;

      /* Processo de liquidação intrabancaria será executado ao final de todos os lançamentos
         na pc_efetua_debitos
      --Executar Liquidacao Intrabancaria DDA
      ddda0001.pc_liquid_intrabancaria_dda (pr_rowid_cob => vr_rowidcob    --ROWID da Cobranca
                                           ,pr_cdcritic  => vr_cdcritic    --Codigo de Erro
                                           ,pr_dscritic  => vr_dscritic);  --Descricao de Erro
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Nao mostrar erro para usuario.
        NULL;
      END IF;*/
    END IF;
    
    
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;
      WHEN OTHERS THEN
        -- Erro
        pr_dscritic:= 'Erro na rotina AFRA0004.pc_monitora_titulos. '||sqlerrm;

  END pc_monitora_titulos;
  
  
  ---> Procedure destinada a monitorar operacao de Tributos
  PROCEDURE pc_monitora_tributos (pr_cdcooper IN  crapcop.cdcooper%TYPE   -- Codigo da cooperativa
                                 ,pr_nrdconta IN  crapass.nrdconta%TYPE   -- Numero da conta
                                 ,pr_idseqttl IN  crapttl.idseqttl%TYPE   -- Sequencial titular
                                 ,pr_vlfatura IN  NUMBER                  -- Valor fatura
                                 ,pr_flgagend IN  INTEGER                 -- Flag agendado /* 1-True, 0-False */
                                 ,pr_cdagenci IN  crapage.cdagenci%TYPE   -- Codigo da agencia
                                 ,pr_dtmvtocd IN  crapdat.dtmvtocd%TYPE   -- rw_crapdat.dtmvtocd
                                 ,pr_cdcritic OUT INTEGER                 -- Codigo da critica
                                 ,pr_dscritic OUT VARCHAR2) IS            -- Descriçao da critica

    /* .............................................................................

     Programa: pc_monitora_tributos (era PAGA0003.pc_monitoracao_pagamento)
     Autor   : Dionathan
     Data    : Julho/2016.                    Ultima atualizacao: 12/04/2018

     Objetivo  : Procedure de monitoração de pagamentos para evitar fraudes.

     Alteracoes: 12/04/2018 - Movida da PAGA0003.pc_monitoracao_pagamento para
                              centralizar a monitoracao de operacoes. 
                              Realizados ajustes para adaptar rotina.
                             (PRJ381 - Analise Antifraude, Teobaldo J. - AMcom)
                              
    ..............................................................................*/
  /** ------------------------------------------------------------- **
   ** Monitoracao Pagamentos - Antes de alterar verificar regras    **
   ** ------------------------------------------------------------- **
   ** Envio de monitoracao sera enviado se for pagto via Internet,  **
   ** se nao for pagto via DDA, se nao for pagto proveniente de     **
   ** agendamento, se nao for boleto de cobranca registrada da      **
   ** cooperativa, se o valor individual ou total pago no dia pelo  **
   ** cooperado for maior que o limite estipulado para cooperativa  **
   ** atraves da tela PARMON no ayllos web.                         **
   ** exemplo: valor inicial monitoracao =   700,00                 **
   **          valor monitoracao IP      = 3.000,00                 **
   ** Será enviado email de monitoracao apenas quando:              **
   ** - Valor pago for maior ou igual a 3.000,00 independente do ip **
   ** - Valor pago for maior ou igual a 700,00 até 2.999,99 será    **
   ** verificado o IP anterior, caso seja diferente, envia email.   **
   ** ------------------------------------------------------------- **/
    
  rw_crapcop cr_crapcop%ROWTYPE;
  
  -- Selecionar a data de abertura da conta
  CURSOR cr_crapass_t(pr_cdcooper IN craplgm.cdcooper%TYPE
                     ,pr_nrdconta IN craplgm.nrdconta%type) IS
    SELECT ass.inpessoa
          ,ass.cdagenci
          ,age.nmresage
          ,ass.dtabtcct
          ,pes.idpessoa
          ,ass.nrcpfcgc
      FROM crapass ass
          ,crapage age
          ,tbcadast_pessoa pes
     WHERE ass.nrcpfcgc = pes.nrcpfcgc
       AND ass.cdcooper = age.cdcooper
       AND ass.cdagenci = age.cdagenci
       AND ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
  rw_crapass_t cr_crapass_t%ROWTYPE;
  
  -- Selecionar informacoes do titular
  CURSOR cr_crapttl (pr_cdcooper IN crapttl.cdcooper%type
                    ,pr_nrdconta IN crapttl.nrdconta%type
                    ,pr_idseqttl IN crapttl.idseqttl%type) IS
  SELECT ttl.nmextttl
        ,ttl.nrcpfcgc
        ,ttl.idseqttl
    FROM crapttl ttl
   WHERE ttl.cdcooper = pr_cdcooper
     AND ttl.nrdconta = pr_nrdconta
     AND ttl.idseqttl = pr_idseqttl;
  rw_crapttl cr_crapttl%ROWTYPE;
  
  -- Selecionar dados Pessoa Juridica
  rw_crapjur cr_crapjur%ROWTYPE;
  
  -- Cursor para protocolos e lançamentos de DARF/DAS
  CURSOR cr_craplft(pr_cdcooper IN crappro.cdcooper%type
                   ,pr_cdagenci IN crapaut.cdagenci%type
                   ,pr_nrdconta IN crappro.nrdconta%type
                   ,pr_dtmvtolt IN crappro.dtmvtolt%TYPE) IS
    SELECT pro.cdcooper
          ,pro.dtmvtolt
          ,pro.dscedent
          ,pro.dsprotoc
          ,pro.dsinform##1
          ,pro.dsinform##2
          ,pro.dsinform##3          
          ,pro.flgagend
          ,lft.vllanmto
          ,lft.cdbarras
          ,TO_CHAR(lft.cdseqfat) cdseqfat
          ,lft.dsnomfon
          ,pro.cdtippro
     FROM crappro pro
         ,crapaut aut
         ,craplft lft
    WHERE pro.cdcooper = pr_cdcooper
      AND pro.nrdconta = pr_nrdconta
      AND pro.dtmvtolt = pr_dtmvtolt
      AND pro.cdtippro IN (16, 17, 18, 19, 23, 24)
      AND aut.cdcooper = pro.cdcooper
      AND aut.dtmvtolt = pro.dtmvtolt
      AND aut.nrsequen = pro.nrseqaut
      AND UPPER(aut.dsprotoc) = UPPER(pro.dsprotoc)
      AND aut.cdagenci = pr_cdagenci
      AND aut.nrdcaixa = 900
      AND lft.cdcooper = aut.cdcooper
      AND lft.dtmvtolt = aut.dtmvtolt
      AND lft.cdagenci = aut.cdagenci
      AND lft.cdbccxlt = 11
      AND lft.nrdolote = 15900
      AND lft.nrseqdig = TO_NUMBER(aut.nrdocmto);
   
  --Selecionar informacoes log transacoes no sistema
  CURSOR cr_craplgm_lgi(pr_cdcooper IN craplgm.cdcooper%TYPE
                       ,pr_nrdconta IN craplgm.nrdconta%TYPE
                       ,pr_idseqttl IN craplgm.idseqttl%TYPE
                       ,pr_dttransa IN craplgm.dttransa%TYPE
                       ,pr_dsorigem IN craplgm.dsorigem%TYPE
                       ,pr_cdoperad IN craplgm.cdoperad%TYPE
                       ,pr_flgtrans IN craplgm.flgtrans%TYPE
                       ,pr_dstransa IN craplgm.dstransa%TYPE
                       ,pr_nmdcampo IN craplgi.nmdcampo%TYPE) IS
  SELECT lgm.cdcooper
        ,lgm.nrdconta
        ,lgm.idseqttl
        ,lgm.dttransa
        ,lgm.hrtransa
        ,lgm.nrsequen
        ,lgi.dsdadatu
        ,lgi.nmdcampo
    FROM craplgm lgm
        ,craplgi lgi
   WHERE lgi.cdcooper = lgm.cdcooper
     AND lgi.nrdconta = lgm.nrdconta
     AND lgi.idseqttl = lgm.idseqttl
     AND lgi.nrsequen = lgm.nrsequen
     AND lgi.dttransa = lgm.dttransa
     AND lgi.hrtransa = lgm.hrtransa
     AND lgm.cdcooper = pr_cdcooper
     AND lgm.nrdconta = pr_nrdconta
     AND lgm.idseqttl = pr_idseqttl
     AND lgm.dttransa = pr_dttransa
     AND lgm.dsorigem = pr_dsorigem
     AND lgm.cdoperad = pr_cdoperad
     AND lgm.flgtrans = pr_flgtrans
     AND lgm.dstransa = pr_dstransa
     AND lgi.nmdcampo = pr_nmdcampo
   ORDER BY lgm.progress_recid DESC;
    
    vr_datdodia DATE;
    vr_flgemail BOOLEAN;
    vr_vlpagtos NUMBER;
    vr_qtpagtos NUMBER := 0;
    vr_dspagtos VARCHAR2(4000);
    vr_qtidenti INTEGER;
    vr_dtlimite DATE;
    vr_nrdipatu VARCHAR2(1000);
    vr_nrdipant VARCHAR2(1000);
    vr_exec_lgm EXCEPTION;
    vr_conteudo VARCHAR2(4000);
    vr_des_assunto VARCHAR2(100);
    vr_email_dest  VARCHAR2(100);
    vr_tpcaptur INTEGER;
    
    vr_exc_erro EXCEPTION;
  
  BEGIN

    -- Apenas para pagamentos via Internet e nesta data
    IF pr_cdagenci = 90 AND pr_flgagend = 0 THEN  /* 0 - False (nao agendado) */
        
      --Verificar cooperativa
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      CLOSE cr_crapcop;
      
      --Buscar data do dia
      vr_datdodia:= trunc(sysdate); 
      
      --Flag email recebe true
      vr_flgemail:= TRUE;

      /** Soma o total de pagtos efetuados pelo cooperado no dia e armazena
          esses pagtos para enviar no email **/
      IF vr_flgemail THEN
        --Zerar valor pagamentos
        vr_vlpagtos:= 0;
        vr_dspagtos:= NULL;

        -- Cursor para protocolos e lançamentos de DARF/DAS/FGTS/DAE
        FOR rw_craplft IN cr_craplft (pr_cdcooper => pr_cdcooper
                                     ,pr_cdagenci => pr_cdagenci
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_dtmvtolt => pr_dtmvtocd) LOOP
          --Acumular pagamentos
          vr_vlpagtos:= NVL(vr_vlpagtos,0) + rw_craplft.vllanmto;
          vr_qtpagtos:= NVL(vr_qtpagtos,0) + 1;
          
          IF rw_craplft.cdtippro IN (23,24) THEN
            --Concatenar Descricao Pagamentos
            IF nvl(length(vr_dspagtos),0) < 2400 THEN
              vr_dspagtos:= vr_dspagtos ||
              rw_craplft.dsinform##1 ||' - '|| TRIM(rw_craplft.dsinform##2) || '<BR>' ||
              'Identificacao: ' || rw_craplft.dscedent || '<BR>' ||
              'Valor do Pagamento: R$ '|| to_char(rw_craplft.vllanmto,'fm999G999G999G999D00')||
              ' - Cod.Barras: '|| rw_craplft.cdbarras ||
              '<BR><BR>';
            END IF;
          
          ELSE
                    
      vr_tpcaptur := TO_NUMBER(TRIM(gene0002.fn_busca_entrada(2,(gene0002.fn_busca_entrada(1, rw_craplft.dsinform##3, '#')), ':')));
      
      IF vr_tpcaptur = 1 THEN  -- CDBARRA/LINDG
        --Concatenar Descricao Pagamentos
      IF nvl(length(vr_dspagtos),0) < 2400 THEN
        vr_dspagtos:= vr_dspagtos ||
        rw_craplft.dsinform##1 ||' - '|| TRIM(gene0002.fn_busca_entrada(2,(gene0002.fn_busca_entrada(5, rw_craplft.dsinform##3, '#')), ':')) || '<BR>' ||
        'Identificacao: ' || TO_CHAR(nvl(rw_craplft.dsnomfon,' ')) || ' ' || rw_craplft.dscedent || '<BR>' ||
        'Valor do Pagamento: R$ '|| to_char(rw_craplft.vllanmto,'fm999G999G999G999D00')||
        ' - Cod.Barras: '|| rw_craplft.cdbarras ||
        '<BR><BR>';
      END IF;
      ELSE -- DARF Manual
      --Concatenar Descricao Pagamentos
      IF nvl(length(vr_dspagtos),0) < 2400 THEN
        vr_dspagtos:= vr_dspagtos ||
        rw_craplft.dsinform##1 ||' - '|| TRIM(gene0002.fn_busca_entrada(2,(gene0002.fn_busca_entrada(5, rw_craplft.dsinform##3, '#')), ':')) || '<BR>' ||
        'Identificacao: ' || TO_CHAR(nvl(rw_craplft.dsnomfon,' ')) || ' ' || rw_craplft.dscedent || '<BR>' ||
        'Valor do Pagamento: R$ '|| to_char(rw_craplft.vllanmto,'fm999G999G999G999D00')  ||                             
        ' - Cod.Seq: '|| rw_craplft.cdseqfat ||
        '<BR><BR>';
      END IF;
      END IF;
          END IF;
        END LOOP; --rw_craplft

        /** Verifica se o valor do pagto eh menor que o parametrizado
        e total pago no dia eh menor que o parametrizado**/
        IF pr_vlfatura < rw_crapcop.vlinimon AND
           vr_vlpagtos < rw_crapcop.vlinimon THEN
          --Flag email
          vr_flgemail:= FALSE;
        END IF;

      END IF; --vr_flgemail

      --Selecionar ultimo log transacao sistema
      OPEN cr_crapass_t(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass_t INTO rw_crapass_t;
      CLOSE cr_crapass_t;

      IF vr_flgemail AND (pr_vlfatura < rw_crapcop.vllmonip) THEN
        

        vr_qtidenti:= 0;
        vr_dtlimite:= vr_datdodia;
        BEGIN
          WHILE vr_dtlimite >= rw_crapass_t.dtabtcct LOOP

            FOR rw_craplgm IN cr_craplgm_lgi(pr_cdcooper => pr_cdcooper
                                            ,pr_nrdconta => pr_nrdconta
                                            ,pr_idseqttl => pr_idseqttl
                                            ,pr_dttransa => vr_dtlimite
                                            ,pr_dsorigem => 'INTERNET'
                                            ,pr_cdoperad => '996'
                                            ,pr_flgtrans => 1
                                            ,pr_dstransa => 'Efetuado login de acesso a conta on-line.'
                                            ,pr_nmdcampo => 'IP') LOOP
                                        
              IF TRIM(vr_nrdipatu) IS NULL THEN
                vr_nrdipatu := rw_craplgm.dsdadatu;
              ELSE
                IF TRIM(vr_nrdipant) IS NOT NULL THEN
                  vr_nrdipant := vr_nrdipant || ';';
                END IF;

                vr_nrdipant := vr_nrdipant || rw_craplgm.dsdadatu;
                vr_qtidenti := vr_qtidenti + 1;

              END IF;

              -- Verificar se foram identificados três IP
              IF vr_qtidenti >= 3 THEN
                RAISE vr_exec_lgm;
              END IF;
                
            END LOOP;-- Loop craplgm

            vr_dtlimite := vr_dtlimite - 1;

          END LOOP; -- Loop da data
        EXCEPTION
          -- Exception para quando encontrar os três registros de IP
          WHEN vr_exec_lgm THEN
            NULL;

          WHEN OTHERS THEN
            NULL;

        END;

        --Verificar se os ultimos IPs sao iguais
        IF GENE0002.fn_existe_valor(pr_base     => vr_nrdipant
                                   ,pr_busca    => vr_nrdipatu
                                   ,pr_delimite => ';') = 'S' THEN
          vr_flgemail:= FALSE;
        END IF;

      END IF; --vr_flgemail

      /** Enviar email para monitoracao se passou pelos filtros **/
      IF vr_flgemail THEN
        
        vr_conteudo:= 'PA: '||rw_crapass_t.cdagenci||' - '||rw_crapass_t.nmresage;
        --Adicionar numero da conta na mensagem
        vr_conteudo:= vr_conteudo|| '<BR><BR>'||'Conta: '|| pr_nrdconta|| '<BR>';
        
        --Se for pessoa fisica
        IF rw_crapass_t.inpessoa = 1 THEN
          /** Lista todos os titulares **/

          FOR rw_crapttl IN cr_crapttl (pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_idseqttl => pr_idseqttl) LOOP
            --Concatenar Conteudo
            vr_conteudo:= vr_conteudo||'Titular '|| rw_crapttl.idseqttl ||
                                       ': '||rw_crapttl.nmextttl|| '<BR>';
          END LOOP;

        ELSE
          /** Lista o nome da empresa **/

          OPEN cr_crapjur (pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta);
          FETCH cr_crapjur INTO rw_crapjur;
          --Se Encontrou
          IF cr_crapjur%FOUND THEN
            --Concatenar o nome da empresa
            vr_conteudo:= vr_conteudo||'Empresa: '|| rw_crapjur.nmextttl;
          END IF;

          --Fechar Cursor
          CLOSE cr_crapjur;
          --Concatenar Procuradores/Representantes
          vr_conteudo:= vr_conteudo||'<BR><BR>'||
                        'Procuradores/Representantes: <BR>';
                        
          /** Lista os procuradores/representantes **/
          FOR rw_repres IN cr_repres(pr_nrcpfcgc => rw_crapass_t.nrcpfcgc) LOOP
            -- Concatenar nome avalista
            vr_conteudo:= vr_conteudo||rw_repres.nmpessoa|| '<BR>';
          END LOOP;

        END IF;

        -- Fones
        vr_conteudo:= vr_conteudo|| '<BR>Fones:<BR>';
        --Encontrar numeros de telefone
        FOR rw_craptfc IN cr_craptfc (pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta) LOOP
          --Montar Conteudo
          vr_conteudo:= vr_conteudo||'(' ||rw_craptfc.nrdddtfc|| ') '||
                                     rw_craptfc.nrtelefo|| '<BR>';
        END LOOP;

        --Concatenar Pagamentos
        vr_conteudo:= vr_conteudo|| '<BR>'|| vr_dspagtos;
        vr_conteudo:= vr_conteudo||'Quantidade pagto: '||to_char(vr_qtpagtos,'fm999G990')
                                 ||' Valor total: '||to_char(vr_vlpagtos,'fm999G999G999G999D00');

        --Determinar Assunto
        vr_des_assunto:= 'PAGTO DARF/DAS/FGTS/DAE '||rw_crapcop.nmrescop ||' '||
                         GENE0002.fn_mask_conta(pr_nrdconta)|| ' R$ '||
                         TRIM(to_char(pr_vlfatura,'fm999G999G999G999D00'));

        --Buscar destinatario email
        vr_email_dest:= gene0001.fn_param_sistema('CRED',pr_cdcooper,'INTERNETBANK_PAGTO');
        --Se nao encontrou destinatario
        IF vr_email_dest IS NULL THEN
          --Montar mensagem de erro
          pr_dscritic:= 'Nao foi encontrado destinatario para os pagamentos via InternetBank.';
          pr_cdcritic:= 0;
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;
        
        --Enviar Email
        GENE0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper    --> Cooperativa conectada
                                  ,pr_cdprogra        => 'INTERNETBANK' --> Programa conectado
                                  ,pr_des_destino     => vr_email_dest  --> Um ou mais detinatários separados por ';' ou ','
                                  ,pr_des_assunto     => vr_des_assunto --> Assunto do e-mail
                                  ,pr_des_corpo       => vr_conteudo    --> Corpo (conteudo) do e-mail
                                  ,pr_des_anexo       => NULL           --> Um ou mais anexos separados por ';' ou ','
                                  ,pr_flg_remove_anex => 'N'            --> Remover os anexos passados
                                  ,pr_flg_remete_coop => 'N'            --> Se o envio será do e-mail da Cooperativa
                                  ,pr_des_nome_reply  => NULL           --> Nome para resposta ao e-mail
                                  ,pr_des_email_reply => NULL           --> Endereço para resposta ao e-mail
                                  ,pr_flg_enviar      => 'S'            --> Enviar o e-mail na hora
                                  ,pr_flg_log_batch   => 'N'            --> Incluir inf. no log
                                  ,pr_des_erro        => pr_dscritic);  --> Descricao Erro
        --Se ocorreu erro
        IF pr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          pr_cdcritic:= 0;
          RAISE vr_exc_erro;
        END IF;
      END IF;
    END IF;  
  
  EXCEPTION
    WHEN OTHERS THEN
      IF pr_dscritic IS NULL THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro ao gerar monitoracao de pagamento DARF/DAS.';
      END IF;
  END pc_monitora_tributos;
  
     
  ---> Procedure destinada a monitorar operacao de |GPS
  PROCEDURE pc_monitora_gps (pr_cdcooper IN  crapcop.cdcooper%TYPE  -- Codigo da cooperativa
                            ,pr_nrdconta IN  crapttl.nrdconta%TYPE  -- Numero da conta
                            ,pr_idseqttl IN  crapttl.idseqttl%TYPE  -- Sequencial titular
                            ,pr_vlrtotal IN  NUMBER                 -- Valor total lancamento
                            ,pr_flgagend IN  INTEGER                -- Flag agendado /* 1-True, 0-False */ 
                            ,pr_cdagenci IN  INTEGER                -- Codigo da agencia
                            ,pr_dtmvtocd IN  DATE                   -- Data do movimento 
                            ,pr_lgprowid IN  ROWID                  -- ROWID da craplgp
                            ,pr_cdcritic OUT INTEGER                -- Codigo da critica
                            ,pr_dscritic OUT VARCHAR2) IS           -- Descricao critica
    /* ---------------------------------------------------------------------------

        Programa : pc_monitora_gps
        Sistema  : Rotinas referentes a monitoracao de Analise de Fraude
        Sigla    : CRED
        Autor    : Teobaldo Jamunda - AMcom
        Data     : Abril/2018.                    Ultima atualizacao: __/__/2018

        Dados referentes ao programa:

        Frequencia: sempre que for chamado
        Objetivo  : Realizar a monitoracao de pagamento de GPS (INSS0002)
                    (PRJ381 - Analise Antifraude, Teobaldo J. - AMcom)

        Alteracoes:  
        
    ----------------------------------------------------------------------------*/

    -- Selecionar informacoes do titular
    CURSOR cr_crapttl (pr_cdcooper IN crapttl.cdcooper%type
                      ,pr_nrdconta IN crapttl.nrdconta%type
                      ,pr_idseqttl IN crapttl.idseqttl%type) IS
      SELECT crapttl.nmextttl
            ,crapttl.nrcpfcgc
            ,crapttl.idseqttl
       FROM crapttl
      WHERE crapttl.cdcooper = pr_cdcooper
      AND   crapttl.nrdconta = pr_nrdconta
      AND   crapttl.idseqttl = pr_idseqttl;
    rw_crapttl cr_crapttl%ROWTYPE;
    
    -- Selecionar dados GPS
    CURSOR cr_craplgp (pr_rowid IN ROWID) IS
      SELECT craplgp.cdbarras
            ,craplgp.vlrtotal
        FROM craplgp
       WHERE craplgp.rowid = pr_rowid
         AND craplgp.flgativo = 1; 
    rw_craplgp cr_craplgp%ROWTYPE;

    -- Busca as informações da cooperativa conectada
    rw_crapcop cr_crapcop%ROWTYPE;  

    -- Busca informacoes da autenticacao
    rw_crapaut cr_crapaut_sequen%ROWTYPE;
  
    -- Selecionar a data de abertura da conta
    rw_crapass_data cr_crapass_data%ROWTYPE;

    -- Busca Informacoes Agencia
    rw_crapage cr_crapage%ROWTYPE;

    -- Busca dados Pessoa Juridica
    rw_crapjur cr_crapjur%ROWTYPE;
    
    -- Busca dados Avalistas
    rw_crapavt cr_crapavt2%ROWTYPE;
    
    -- Busca os telefones do titular
    rw_craptfc cr_craptfc%ROWTYPE;

    -- Busca dados do asssociado
    rw_cra2ass      cr_crapass%ROWTYPE;
    rw_crapass_prot cr_crapass%ROWTYPE;

    -- Variaveis de Erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic    VARCHAR2(4000);
    vr_exc_erro    EXCEPTION;

    -- Variaveis Locais
    vr_cdagenci    INTEGER;
    vr_datdodia    DATE;
    vr_flgemail    BOOLEAN;
    vr_vlpagtos    NUMBER;
    vr_qtpagtos    NUMBER := 0;
    vr_dspagtos    VARCHAR2(4000);
    vr_dtabtcct    DATE;
    vr_qtidenti    INTEGER;
    vr_dtlimite    DATE;
    vr_nrdipatu    VARCHAR2(1000);
    vr_nrdipant    VARCHAR2(1000);
    vr_exec_lgm    EXCEPTION;
    vr_conteudo    VARCHAR2(4000);
    vr_cra2ass     BOOLEAN;
    vr_des_assunto VARCHAR2(100);
    vr_email_dest  VARCHAR2(100);
    vr_agendame    VARCHAR2(100);

  BEGIN
    --Inicializar variaveis
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    vr_cdagenci:= pr_cdagenci;

    -- Verificar cooperativa
    OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
    -- Se nao encontrou
    IF cr_crapcop%NOTFOUND THEN
      --Fechar Cursor
      CLOSE cr_crapcop;
      vr_cdcritic:= 0;
      vr_dscritic:= 'Cooperativa nao cadastrada.';
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    -- Fechar Cursor
    CLOSE cr_crapcop;

    -- Selecionar informacoes do associado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta);
    --Posicionar no primeiro registro
    FETCH cr_crapass INTO rw_crapass_prot;
    --Se nao encontrou
    IF cr_crapass%NOTFOUND THEN
      --Mensagem Erro
      vr_cdcritic:= 0;
      vr_dscritic:= 'Associado nao cadastrado.';
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    --Fechar Cursor
    CLOSE cr_crapass;

    /** ------------------------------------------------------------- **
     ** Monitoracao Pagamentos - Antes de alterar verificar com David **
     ** ------------------------------------------------------------- **
     ** Envio de monitoracao sera enviado se for pagto via Internet,  **
     ** se nao for pagto via DDA, se nao for pagto proveniente de     **
     ** agendamento, se nao for boleto de cobranca registrada da      **
     ** cooperativa, se o valor individual ou total pago no dia pelo  **
     ** cooperado for maior que o limite estipulado para cooperativa  **
     ** atraves da tela PARMON no ayllos web.                         **
     ** exemplo: valor inicial monitoracao =   700,00                 **
     **          valor monitoracao IP      = 3.000,00                 **
     ** Será enviado email de monitoracao apenas quando:              **
     ** - Valor pago for maior ou igual a 3.000,00 independente do ip **
     ** - Valor pago for maior ou igual a 700,00 até 2.999,99 será    **
     ** verificado o IP anterior, caso seja diferente, envia email.   **
     ** ------------------------------------------------------------- **/

    IF vr_cdagenci = 90 AND pr_flgagend = 0 THEN /*0-false*/
        
      --Flag email recebe true
      vr_flgemail:= TRUE;

      /** Soma o total de pagtos efetuados pelo cooperado no dia e armazena
          esses pagtos para enviar no email **/
      IF vr_flgemail THEN
        --Zerar valor pagamentos
        vr_vlpagtos:= 0;
        vr_dspagtos:= NULL;
        --Selecionar todos protocolos das transacoes
        FOR rw_crappro IN cr_crappro (pr_cdcooper => rw_crapcop.cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_dtmvtolt => pr_dtmvtocd /* rw_crapdat.dtmvtocd */
                                     ,pr_cdtippro => 13) LOOP    /* 13 - Pagamento/Agendamento GPS */
                                       
          --Verificar se precisa ignorar registro.
          --#Banco indica que é título e Estornado não é necessário
          -- ### TJ condicao #Banco ??
          IF InStr(rw_crappro.dsinform##2,'#Banco:') > 0 OR
             InStr(Upper(rw_crappro.dsprotoc),'ESTORNADO') > 0 THEN
            CONTINUE;
          END IF;

          --Verificar as autenticacoes
          OPEN cr_crapaut_sequen (pr_cdcooper => rw_crappro.cdcooper
                                 ,pr_cdagenci => vr_cdagenci
                                 ,pr_nrdcaixa => 900
                                 ,pr_dtmvtolt => rw_crappro.dtmvtolt
                                 ,pr_nrsequen => rw_crappro.nrseqaut);
          --Posicionar no proximo registro
          FETCH cr_crapaut_sequen INTO rw_crapaut;
          --Se nao encontrar
          IF cr_crapaut_sequen%NOTFOUND OR rw_crapaut.vldocmto <> rw_crappro.vldocmto THEN
            --Fechar Cursor
            CLOSE cr_crapaut_sequen;
            --Proximo Registro
            CONTINUE;
          END IF;

          --Fechar Cursor
          CLOSE cr_crapaut_sequen;

          --Selecionar lancamento
          OPEN cr_craplgp_1 (pr_cdcooper => rw_crapaut.cdcooper
                          ,pr_dtmvtolt => rw_crapaut.dtmvtolt
                          ,pr_cdagenci => rw_crapaut.cdagenci
                          ,pr_cdbccxlt => 100
                          ,pr_nrdolote => 31900
                          ,pr_nrseqdig => To_Number(rw_crapaut.nrdocmto));
          --Posicionar no proximo registro
          FETCH cr_craplgp_1 INTO rw_craplgp;
          --Se encontrar
          IF cr_craplgp_1%FOUND THEN          

            --Acumular pagamentos
            vr_vlpagtos:= NVL(vr_vlpagtos,0) + rw_craplgp.vlrtotal;
            vr_qtpagtos:= NVL(vr_qtpagtos,0) + 1;

            IF rw_crappro.flgagend = 1 THEN
               vr_agendame := ' Agendamento';
            ELSE
               vr_agendame := '';
            END IF;

            --Concatenar Descricao Pagamentos
            IF nvl(length(vr_dspagtos),0) < 2400 THEN
              vr_dspagtos:= vr_dspagtos||'Convenio: '||rw_crappro.dscedent||
                            '<BR>Valor do Pagamento: R$ '||
                            to_char(rw_craplgp.vlrtotal,'fm999G999G999G999D00')||
                            ' - Cod.Barras: '|| rw_craplgp.cdbarras ||
                            vr_agendame ||'<BR><BR>';
            END IF;

          END IF;

          CLOSE cr_craplgp_1; --Fechar Cursor
        END LOOP; --rw_crappro

        /** Verifica se o valor do pagto eh menor que o parametrizado
        e total pago no dia eh menor que o parametrizado**/
        IF pr_vlrtotal < rw_crapcop.vlinimon AND
           vr_vlpagtos < rw_crapcop.vlinimon THEN
          --Flag email
          vr_flgemail:= FALSE;
        END IF;

      END IF; --vr_flgemail


      IF vr_flgemail AND (pr_vlrtotal < rw_crapcop.vllmonip) THEN
        -- Selecionar ultimo log transacao sistema
        OPEN cr_crapass_data(pr_cdcooper => rw_crapcop.cdcooper
                            ,pr_nrdconta => pr_nrdconta);
        FETCH cr_crapass_data INTO rw_crapass_data;
        IF cr_crapass_data%FOUND THEN
          vr_dtabtcct := rw_crapass_data.dtabtcct;
        END IF;

        CLOSE cr_crapass_data;

        vr_qtidenti:= 0;
        vr_dtlimite:= vr_datdodia;
        BEGIN
          WHILE vr_dtlimite >= vr_dtabtcct LOOP

            FOR rw_craplgm IN cr_craplgm(pr_cdcooper => rw_crapcop.cdcooper
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_idseqttl => pr_idseqttl
                                        ,pr_dttransa => vr_dtlimite
                                        ,pr_dsorigem => 'INTERNET'
                                        ,pr_cdoperad => '996'
                                        ,pr_flgtrans => 1
                                        ,pr_dstransa => 'Efetuado login de acesso a conta on-line.') LOOP

              --Selecionar tabela complementar de log
              FOR rw_craplgi IN cr_craplgi(pr_cdcooper => rw_craplgm.cdcooper,
                                           pr_nrdconta => rw_craplgm.nrdconta,
                                           pr_idseqttl => rw_craplgm.idseqttl,
                                           pr_dttransa => rw_craplgm.dttransa,
                                           pr_hrtransa => rw_craplgm.hrtransa,
                                           pr_nrsequen => rw_craplgm.nrsequen,
                                           pr_nmdcampo => 'IP') LOOP
                IF TRIM(vr_nrdipatu) IS NULL THEN
                  vr_nrdipatu := rw_craplgi.dsdadatu;
                ELSE
                  IF TRIM(vr_nrdipant) IS NOT NULL THEN
                    vr_nrdipant := vr_nrdipant || ';';
                  END IF;

                  vr_nrdipant := vr_nrdipant || rw_craplgi.dsdadatu;
                  vr_qtidenti := vr_qtidenti + 1;

                END IF;

                -- Verificar se foram identificados três IP
                IF vr_qtidenti >= 3 THEN
                  RAISE vr_exec_lgm;
                END IF;

              END LOOP;-- Loop craplgi
            END LOOP;-- Loop craplgm

            vr_dtlimite := vr_dtlimite - 1;

          END LOOP; -- Loop da data
        EXCEPTION
          -- Exception para quando encontrar os três registros de IP
          WHEN vr_exec_lgm THEN
            NULL;

          WHEN OTHERS THEN
            NULL;

        END;

        --Verificar se os ultimos IPs sao iguais
        IF GENE0002.fn_existe_valor(pr_base     => vr_nrdipant
                                   ,pr_busca    => vr_nrdipatu
                                   ,pr_delimite => ';') = 'S' THEN
          vr_flgemail:= FALSE;
        END IF;

      END IF; --vr_flgemail

      /** Enviar email para monitoracao se passou pelos filtros **/
      IF vr_flgemail THEN
        vr_conteudo:= 'PA: '||rw_crapass_prot.cdagenci;
        --Selecionar Agencia
        OPEN cr_crapage (pr_cdcooper => pr_cdcooper
                        ,pr_cdagenci => rw_crapass_prot.cdagenci);
        --Posicionar Proximo Registro
        FETCH cr_crapage INTO rw_crapage;
        --Se encontrou a agencia
        IF cr_crapage%FOUND THEN
          vr_conteudo:= vr_conteudo|| ' - '||rw_crapage.nmresage;
        END IF;

        --Fechar Cursor
        CLOSE cr_crapage;
        --Adicionar numero da conta na mensagem
        vr_conteudo:= vr_conteudo|| '<BR><BR>'||'Conta: '|| pr_nrdconta|| '<BR>';
        --Se for pessoa fisica
        IF rw_crapass_prot.inpessoa = 1 THEN
          /** Lista todos os titulares **/
          FOR rw_crapttl IN cr_crapttl (pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_idseqttl => pr_idseqttl) LOOP
            --Concatenar Conteudo
            vr_conteudo:= vr_conteudo||'Titular '|| rw_crapttl.idseqttl ||
                                       ': '||rw_crapttl.nmextttl|| '<BR>';
          END LOOP;

        ELSE
          /** Lista o nome da empresa **/

          OPEN cr_crapjur (pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta);
          FETCH cr_crapjur INTO rw_crapjur;
          --Se Encontrou
          IF cr_crapjur%FOUND THEN
            --Concatenar o nome da empresa
            vr_conteudo:= vr_conteudo||'Empresa: '|| rw_crapjur.nmextttl;
          END IF;

          --Fechar Cursor
          CLOSE cr_crapjur;
          --Concatenar Procuradores/Representantes
          vr_conteudo:= vr_conteudo||'<BR><BR>'||
                        'Procuradores/Representantes: <BR>';
          /** Lista os procuradores/representantes **/

          FOR rw_crapavt IN cr_crapavt2 (pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_tpctrato => 6) LOOP
            vr_cra2ass:= FALSE;
            --Se tem Contato
            IF rw_crapavt.nrdctato <> 0 THEN
              OPEN cr_crapass (pr_cdcooper => rw_crapavt.cdcooper
                              ,pr_nrdconta => rw_crapavt.nrdctato);
              --Posicionar Proximo Registro
              FETCH cr_crapass INTO rw_cra2ass;
              --Se Encontrou
              vr_cra2ass:= cr_crapass%FOUND;
              --Fechar Cursor
              CLOSE cr_crapass;
            END IF;

            IF rw_crapavt.nrdctato <> 0 AND vr_cra2ass THEN
              --Concatenar nome avalista
              vr_conteudo:= vr_conteudo||rw_cra2ass.nmprimtl|| '<BR>';
            ELSE
              --Concatenar nome avalista
              vr_conteudo:= vr_conteudo||rw_crapavt.nmdavali|| '<BR>';

            END IF;

          END LOOP;

        END IF;

        /* Fones */
        vr_conteudo:= vr_conteudo|| '<BR>Fones:<BR>';
        --Encontrar numeros de telefone
        FOR rw_craptfc IN cr_craptfc (pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta) LOOP
          --Montar Conteudo
          vr_conteudo:= vr_conteudo||'(' ||rw_craptfc.nrdddtfc|| ') '||
                                     rw_craptfc.nrtelefo|| '<BR>';
        END LOOP;

        --Concatenar Pagamentos
        vr_conteudo:= vr_conteudo|| '<BR>'|| vr_dspagtos;
        vr_conteudo:= vr_conteudo||'Quantidade pagto: '||to_char(vr_qtpagtos,'fm999G990')
                                 ||' Valor total: '||to_char(vr_vlpagtos,'fm999G999G999G999D00');


        --Determinar Assunto
        vr_des_assunto:= 'PAGTO GPS '||rw_crapcop.nmrescop ||' '||
                         GENE0002.fn_mask_conta(pr_nrdconta)|| ' R$ '||
                         TRIM(to_char(pr_vlrtotal,'fm999g999g999g999d99'));

        --Buscar destinatario email
        vr_email_dest:= gene0001.fn_param_sistema('CRED',pr_cdcooper,'INTERNETBANK_PAGTO');
        --Se nao encontrou destinatario
        IF vr_email_dest IS NULL THEN
          --Montar mensagem de erro
          vr_dscritic:= 'Nao foi encontrado destinatario para os pagamentos via InternetBank.';
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;

        --Enviar Email
        GENE0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper    --> Cooperativa conectada
                                  ,pr_cdprogra        => 'INTERNETBANK' --> Programa conectado
                                  ,pr_des_destino     => vr_email_dest  --> Um ou mais detinatários separados por ';' ou ','
                                  ,pr_des_assunto     => vr_des_assunto --> Assunto do e-mail
                                  ,pr_des_corpo       => vr_conteudo    --> Corpo (conteudo) do e-mail
                                  ,pr_des_anexo       => NULL           --> Um ou mais anexos separados por ';' ou ','
                                  ,pr_flg_remove_anex => 'N'            --> Remover os anexos passados
                                  ,pr_flg_remete_coop => 'N'            --> Se o envio será do e-mail da Cooperativa
                                  ,pr_des_nome_reply  => NULL           --> Nome para resposta ao e-mail
                                  ,pr_des_email_reply => NULL           --> Endereço para resposta ao e-mail
                                  ,pr_flg_enviar      => 'S'            --> Enviar o e-mail na hora
                                  ,pr_flg_log_batch   => 'N'            --> Incluir inf. no log
                                  ,pr_des_erro        => vr_dscritic);  --> Descricao Erro
        --Se ocorreu erro
        IF vr_dscritic IS NOT NULL THEN
          vr_cdcritic:= 0;
          --Levantar Excecao
          RAISE vr_exc_erro;
        END IF;

      END IF;  /* enviar email */

    END IF;  /* vr_cdagenci = 90 */

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic:= vr_cdcritic;
      pr_dscritic:= vr_dscritic;
    WHEN OTHERS THEN
      -- Erro
      pr_dscritic:= 'Erro na rotina AFRA0004.pc_monitora_convenio. '||sqlerrm;

  END pc_monitora_gps;    
    
  
  --> Rotina para geração de mensagem de estorno para o cooperado
  PROCEDURE pc_mensagem_estorno (pr_cdcooper    IN  crapcop.cdcooper%TYPE,
                                 pr_nrdconta    IN  crapass.nrdconta%TYPE,
                                 pr_inpessoa    IN  crapass.inpessoa%TYPE,
                                 pr_idseqttl    IN  crapttl.idseqttl%TYPE,
                                 pr_cdproduto   IN  tbgen_analise_fraude.cdproduto%TYPE,
                                 pr_tptransacao IN  tbgen_analise_fraude.tptransacao%TYPE, --> Tipo de transação (1-online/ 2-agendada)                                  
                                 pr_vldinami    IN  VARCHAR2,     --> Permite Passar valores dinamicos para a mensagem ex. #VALOR#=58,99;#DTDEBITO#=18/01/2017; 
                                 pr_programa    IN  VARCHAR2,     --> Nome do programa/package de origem da mensagem
                                 pr_cdcritic    OUT INTEGER,
                                 pr_dscritic    OUT VARCHAR2 ) IS
  /* ..........................................................................
    
      Programa : pc_mensagem_estorno        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(AMcom)
      Data     : Janeiro/2017.                   Ultima atualizacao: 13/04/2018
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel pela geração de mensagem de estorno para o cooperado
      Alteração : 13/04/2018 - Movido da AFRA0001 para esta package e realizados ajustes
                               a fim de tratar mensagens por tipo de produto. Acrescido  
                               o parametro pr_programa para indicar origem da mensagem.
                               (PRJ381 - Analise de Fraude - Teobaldo Jamunda - AMcom)
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    --> buscar dados da cooper
    CURSOR cr_crapcop IS
      SELECT cop.nmrescop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper; 
    rw_crapcop cr_crapcop%ROWTYPE;
    
    --> Buscar nome do associado
    CURSOR cr_crapass IS 
      SELECT ass.nmprimtl
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
         
    --> Buscar nome do titular
    CURSOR cr_crapttl( pr_cdcooper crapttl.cdcooper%TYPE,
                       pr_nrdconta crapttl.nrdconta%TYPE,
                       pr_idseqttl crapttl.idseqttl%TYPE) IS
      SELECT ttl.nmextttl
        FROM crapttl ttl 
       WHERE ttl.cdcooper = pr_cdcooper
         AND ttl.nrdconta = pr_nrdconta
         AND ttl.idseqttl = pr_idseqttl;    
    
    --Selecionar titulares com senhas ativas
    CURSOR cr_crapsnh (pr_cdcooper IN crapsnh.cdcooper%type
                      ,pr_nrdconta IN crapsnh.nrdconta%TYPE) IS
      SELECT crapsnh.nrcpfcgc
            ,crapsnh.cdcooper
            ,crapsnh.nrdconta
            ,crapsnh.idseqttl
        FROM crapsnh
       WHERE crapsnh.cdcooper = pr_cdcooper
         AND crapsnh.nrdconta = pr_nrdconta
         AND crapsnh.cdsitsnh = 1
         AND crapsnh.tpdsenha = 1;
    rw_crapsnh cr_crapsnh%ROWTYPE;
    
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;    
    
    vr_dsdassun crapmsg.dsdassun%TYPE;
    vr_dsdplchv crapmsg.dsdplchv%TYPE;
    vr_dsdmensg crapmsg.dsdmensg%TYPE;
    vr_cdtipmsg tbgen_tipo_mensagem.cdtipo_mensagem%TYPE;
    vr_vldinami VARCHAR2(1000);
    vr_nmprimtl crapass.nmprimtl%TYPE;
    
    -- Objetos para armazenar as variáveis da notificação
    vr_variaveis_notif NOTI0001.typ_variaveis_notif;
    vr_notif_origem    tbgen_notif_automatica_prm.cdorigem_mensagem%TYPE;
    vr_notif_motivo    tbgen_notif_automatica_prm.cdmotivo_mensagem%TYPE;    
    
    
  BEGIN
  
    OPEN cr_crapcop;
    FETCH cr_crapcop INTO rw_crapcop;
    CLOSE cr_crapcop;
    
    IF pr_cdproduto = 30 THEN
      --> Online
      IF pr_tptransacao = 1 THEN
        vr_dsdassun := 'TED Estornada';
      ELSE
        vr_dsdassun := 'Agendamento de TED Estornado';
      END IF;
      vr_dsdplchv := 'TED';
    END IF;
    
    
    --> Online
    IF pr_tptransacao = 1 THEN
      IF pr_inpessoa = 1 THEN
        vr_cdtipmsg := 21;
      ELSE
        vr_cdtipmsg := 18;
      END IF;
    --> Agendada
    ELSIF pr_tptransacao = 2 THEN
      IF pr_inpessoa = 1 THEN
        vr_cdtipmsg := 19;
      ELSE
        vr_cdtipmsg := 20;
      END IF;
    END IF; 
    
    
    IF pr_tptransacao = 1 THEN
      vr_notif_origem   := 5;
      vr_variaveis_notif('#valor') := fn_buscar_valor('#VALOR#',pr_vldinami);   
           
      CASE
        WHEN pr_inpessoa = 1 AND pr_cdproduto = 30 THEN
             vr_notif_motivo := 1;
        WHEN pr_inpessoa = 2 AND pr_cdproduto = 30 THEN
             vr_notif_motivo := 2;   
        WHEN pr_inpessoa = 1 AND
             pr_cdproduto IN (43, 44 ,45, 46 ,47)  THEN
             vr_notif_motivo := 6;  -->  Pagamento Estornado - PF
        WHEN pr_inpessoa = 2 AND
             pr_cdproduto IN (43, 44 ,45, 46 ,47)  THEN
             vr_notif_motivo := 7;  -->  Pagamento Estornado - PJ
        ELSE
             vr_notif_motivo := 6;  -->  Para nao abortar rotina Pagamento Estornado - PF
      END CASE;  

    --> Agendada
    ELSIF pr_tptransacao = 2 THEN

      vr_notif_origem   := 3;
      vr_variaveis_notif('#valor')    := fn_buscar_valor('#VALOR#',pr_vldinami);
      vr_variaveis_notif('#dtdebito') := fn_buscar_valor('#DTDEBITO#',pr_vldinami);                   
      
      CASE
         WHEN pr_inpessoa = 1 AND pr_cdproduto = 30 THEN
              vr_notif_motivo := 10;
         WHEN pr_inpessoa = 2 AND pr_cdproduto = 30 THEN
              vr_notif_motivo := 11;   
         WHEN pr_inpessoa = 1 AND
              pr_cdproduto IN (43, 44 ,45, 46 ,47)  THEN
              vr_notif_motivo := 12;  -->  Pagamento - Agendamento não efetivado  - PF
         WHEN pr_inpessoa = 2 AND
              pr_cdproduto IN (43, 44 ,45, 46 ,47)  THEN
              vr_notif_motivo := 13;  -->  Pagamento - Agendamento não efetivado  - PJ
         ELSE
              vr_notif_motivo := 12;  -->  Para nao abortar rotina Pagamento Estornado - PF
       END CASE;
     
    END IF;      
    
    
    --> Buscar pessoas que possuem acesso a conta
    FOR rw_crapsnh IN cr_crapsnh (pr_cdcooper  => pr_cdcooper
                                 ,pr_nrdconta  => pr_nrdconta) LOOP
                                   
      IF pr_inpessoa = 1 AND rw_crapsnh.idseqttl > 0 THEN
        OPEN cr_crapttl(pr_cdcooper => pr_cdcooper,
                        pr_nrdconta => pr_nrdconta,
                        pr_idseqttl => rw_crapsnh.idseqttl);
        FETCH cr_crapttl INTO vr_nmprimtl;
        CLOSE cr_crapttl;
      ELSE
        OPEN cr_crapass;
        FETCH cr_crapass INTO vr_nmprimtl;
        CLOSE cr_crapass;    
      END IF;
    
      vr_vldinami := '#NOME#='||vr_nmprimtl||';'||
                     pr_vldinami;
    
      IF pr_cdproduto = 30 THEN
        --> buscar mensagem 
        vr_dsdmensg := gene0003.fn_buscar_mensagem(pr_cdcooper          => pr_cdcooper
                                                  ,pr_cdproduto         => pr_cdproduto
                                                  ,pr_cdtipo_mensagem   => vr_cdtipmsg
                                                  ,pr_sms               => 0             -- Indicador se mensagem é SMS (pois deve cortar em 160 caracteres)
                                                  ,pr_valores_dinamicos => vr_vldinami); -- Máscara #Cooperativa#=1;#Convenio#=123    
    
        --> Criar mensagem
        GENE0003.pc_gerar_mensagem ( pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_idseqttl => rw_crapsnh.idseqttl
                                    ,pr_cdprogra => pr_programa        -- era fixo: 'AFRA0001'
                                    ,pr_inpriori => 1
                                    ,pr_dsdmensg => vr_dsdmensg
                                    ,pr_dsdassun => vr_dsdassun
                                    ,pr_dsdremet => rw_crapcop.nmrescop
                                    ,pr_dsdplchv => vr_dsdplchv
                                    ,pr_cdoperad => ''
                                    ,pr_cdcadmsg => 0
                                    ,pr_dscritic => vr_dscritic);
     
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;
      END IF;
      --
      -- Cria uma notificação
      IF vr_cdtipmsg = 20 THEN
        vr_variaveis_notif('#nomeresumido') := vr_nmprimtl;
      ELSE
        vr_variaveis_notif('#nomecompleto') := vr_nmprimtl;
      END IF;
      --
      noti0001.pc_cria_notificacao(pr_cdorigem_mensagem => vr_notif_origem
                                  ,pr_cdmotivo_mensagem => vr_notif_motivo
                                  ,pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_idseqttl => rw_crapsnh.idseqttl
                                  ,pr_variaveis => vr_variaveis_notif);      
      --
    END LOOP;
  
  EXCEPTION
    WHEN vr_exc_erro THEN
      
      --> Buscar critica
      IF nvl(vr_cdcritic,0) > 0 AND 
        TRIM(vr_dscritic) IS NULL THEN
        -- Busca descricao        
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);        
      END IF;  
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Não foi gerada mensagem de estorno ao cooperado: '||SQLERRM;
  END pc_mensagem_estorno;  
  
end AFRA0004;
/
