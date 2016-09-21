CREATE OR REPLACE PACKAGE CECRED.LIMI0001 AS
  
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : LIMI0001
  --  Sistema  : Rotinas referentes ao limite de credito
  --  Sigla    : LIMI
  --  Autor    : James Prust Junior
  --  Data     : Dezembro - 2014.                   Ultima atualizacao: 17/08/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas genericas refente ao limite de credito

  -- Alteracoes:     11/08/2016 - Inclus�o de par�metros para limite de desconto de cheque.
  --                 (Linhares - Projeto 300)
  --
  --                 17/08/2016 - Inclus�o de rotina para renova��o de limite de cheque.
  --                 (Linhares - Projeto 300)
  ---------------------------------------------------------------------------------------------------------------
  -- Rotina referente a consulta da tela CADLIM
  PROCEDURE pc_tela_cadlim_consultar(pr_inpessoa IN craprli.inpessoa%TYPE --> Codigo do tipo de pessoa
                                    ,pr_flgdepop IN INTEGER               --> Flag para verificar o departamento do operador
                                    ,pr_idgerlog IN INTEGER               --> Identificador de Log (Fixo no c�digo, 0 � N�o / 1 - Sim)
                                    ,pr_tplimite IN INTEGER               --> Tipo de limite (1 - Limite de credito / 2 - Limite de desconto de cheques / 3 - Lim. Desc. Titulo )
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informa��es de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                    ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
                                    
  -- Rotina referente a alteracao da tela CADLIM
  PROCEDURE pc_tela_cadlim_alterar(pr_inpessoa IN craprli.inpessoa%TYPE --> Codigo do tipo de pessoa                                  
                                  ,pr_vlmaxren IN craprli.vlmaxren%TYPE --> Valor Maximo para renovacao do limite
                                  ,pr_nrrevcad IN craprli.nrrevcad%TYPE --> Numero de meses da revisao cadastral
                                  ,pr_qtmincta IN craprli.qtmincta%TYPE --> Tempo Minimo de conta
                                  ,pr_qtdiaren IN craprli.qtdiaren%TYPE --> Periodo Maximo de dias para renovacao
                                  ,pr_qtmaxren IN craprli.qtmaxren%TYPE --> Quantidade maxima de renovacao
                                  ,pr_qtdiaatr IN craprli.qtdiaatr%TYPE --> Quantidade de dias de atraso de emprestimo
                                  ,pr_qtatracc IN craprli.qtatracc%TYPE --> Quantidade de dias de atraso em conta corrente
                                  ,pr_dssitdop IN craprli.dssitdop%TYPE --> Situacoes que englobam a operacao
                                  ,pr_dsrisdop IN craprli.dsrisdop%TYPE --> Riscos que englobam a operacao
                                  ,pr_tplimite IN craprli.tplimite%TYPE --> Tipo de limite de cr�dito
                                  ,pr_pcliqdez IN craprli.pcliqdez%TYPE --> Percentual m�nimo de liquidez
                                  ,pr_qtdialiq IN craprli.qtdialiq%TYPE --> Quantidade de dias para calculo do percentual liquidez                                  
                                  ,pr_idgerlog IN INTEGER               --> Identificador de Log (Fixo no c�digo, 0 � N�o / 1 - Sim)         
                                  ,pr_xmllog   IN VARCHAR2              --> XML com informa��es de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                  ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2);           --> Erros do processo
    
  -- Rotina referente a renovacao manual do limite de credito
  PROCEDURE pc_renovar_limite_cred_manual(pr_cdcooper IN crapcop.cdcooper%TYPE  --> C�digo da Cooperativa
                                         ,pr_cdoperad IN crapope.cdoperad%TYPE  --> C�digo do Operador
                                         ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da Tela
                                         ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                         ,pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                         ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Titular da Conta
                                         ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de Movimento
                                         ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato                            
                                         ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                         ,pr_dscritic OUT VARCHAR2);            --> Descri��o da cr�tica

  -- Rotina referente a renovacao manual do limite de desconto de cheque
  PROCEDURE pc_renovar_lim_desc_cheque(pr_cdcooper IN crapcop.cdcooper%TYPE --> C�digo da Cooperativa
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE --> N�mero da Conta
                                      ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Titular da Conta
                                      ,pr_vllimite IN craplim.vllimite%TYPE --> Valor Limite de Desconto
                                      ,pr_nrctrlim IN craplim.nrctrlim%TYPE --> Contrato
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data de Movimento
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE --> C�digo do Operador
                                      ,pr_nmdatela IN craptel.nmdatela%TYPE --> Nome da Tela
                                      ,pr_idorigem IN INTEGER               --> Identificador de Origem
                                      ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                      ,pr_dscritic OUT VARCHAR2);           --> Descri��o da cr�tica
                                      
  -- Rotina referente ao desbloqueio do limite de descondo de cheque
  PROCEDURE pc_desbloq_lim_desc_cheque(pr_cdcooper IN crapcop.cdcooper%TYPE --> C�digo da cooperativa
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE --> N�mero da Conta
                                      ,pr_nrctrlim IN craplim.nrctrlim%TYPE --> Contrato                            
                                      ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> N�mero do Caixa
                                      ,pr_cdoperad IN craplgm.cdoperad%TYPE --> C�digo do operador
                                      ,pr_nmdatela IN craptel.nmdatela%TYPE --> Nome da Tela
                                      ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                      ,pr_dscritic OUT VARCHAR2);           --> Descri��o da cr�tica
  
END LIMI0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.LIMI0001 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : LIMI0001
  --  Sistema  : Rotinas referentes ao limite de credito
  --  Sigla    : LIMI
  --  Autor    : James Prust Junior
  --  Data     : Dezembro - 2014.                   Ultima atualizacao: 17/08/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas genericas refente ao limite de credito

  -- Alteracoes: 13/11/2015 - Incluido o comando upper para os cursores que fazem
  --                          comparacao com o campo cdoperad da tabela crapope
  --                          (Tiago SD339476)
  --
  --             11/08/2016 - Inclus�o de par�metros para limite de desconto de cheque.
  --                          (Linhares - Projeto 300)
  --  
  --             17/08/2016 - Inclus�o de rotina para renova��o de limite de cheque.
  --                          (Linhares - Projeto 300)
  --
  ---------------------------------------------------------------------------------------------------------------
  PROCEDURE pc_tela_cadlim_consultar(pr_inpessoa IN craprli.inpessoa%TYPE --> Codigo do tipo de pessoa
                                    ,pr_flgdepop IN INTEGER               --> Flag para verificar o departamento do operador
                                    ,pr_idgerlog IN INTEGER               --> Identificador de Log (Fixo no c�digo, 0 � N�o / 1 - Sim)
                                    ,pr_tplimite IN INTEGER               --> Tipo de limite (1 - Limite de credito / 2 - Limite de desconto de cheques / 3 - Lim. Desc. Titulo )
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informa��es de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                    ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
    /* .............................................................................

     Programa: pc_tela_cadlim_consultar
     Sistema : Rotinas referentes ao limite de credito
     Sigla   : LIMI
     Autor   : James Prust Junior
     Data    : Dezembro/14.                    Ultima atualizacao: 11/08/2016

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Consultar as regras do limite de credito.

     Observacao: -----
     Alteracoes:  11/08/2016 - Inclus�o do par�metro pr_tplmite para filtro por tipo de limite
                             - Inclus�o dos campos pcliqdez e qtdialiq na consulta
                  (Linhares - Projeto 300)
     ..............................................................................*/ 
    DECLARE

      -- Selecionar os dados
      CURSOR cr_craprli(pr_cdcooper IN craprli.cdcooper%TYPE
                       ,pr_inpessoa IN craprli.inpessoa%TYPE
                       ,pr_tplimite IN craprli.tplimite%TYPE) IS
        SELECT vlmaxren,
               nrrevcad,
               qtmincta,
               qtdiaren,
               qtmaxren,
               qtdiaatr,
               qtatracc,
               dssitdop,
               dsrisdop,
               pcliqdez,
               qtdialiq
          FROM craprli
         WHERE cdcooper = pr_cdcooper
           AND inpessoa = pr_inpessoa
           AND tplimite = pr_tplimite;

      rw_craprli cr_craprli%ROWTYPE;
      
      CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE
                       ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
        SELECT dsdepart
          FROM crapope
         WHERE crapope.cdcooper = pr_cdcooper
           AND upper(crapope.cdoperad) = upper(pr_cdoperad);
      rw_crapope cr_crapope%ROWTYPE;
      
      -- Vari�vel de cr�ticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

      -- Variaveis padrao
      vr_cdcooper      NUMBER;
      vr_cdoperad      VARCHAR2(100);
      vr_nmdatela      VARCHAR2(100);
      vr_nmeacao       VARCHAR2(100);
      vr_cdagenci      VARCHAR2(100);
      vr_nrdcaixa      VARCHAR2(100);
      vr_idorigem      VARCHAR2(100);      
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
      
      -- Condicao para verificar se olha o departamento do operador                
      IF pr_flgdepop = 1 THEN
                
        -- Buscar Dados do Operador
        OPEN cr_crapope (pr_cdcooper => vr_cdcooper
                        ,pr_cdoperad => vr_cdoperad);
        FETCH cr_crapope INTO rw_crapope;
        -- Verifica se a retornou registro
        IF cr_crapope%NOTFOUND THEN
          CLOSE cr_crapope;
          vr_cdcritic := 67;
          vr_dscritic := NULL;
          RAISE vr_exc_saida;
        ELSE
          -- Apenas Fecha o Cursor
          CLOSE cr_crapope;
        END IF;
          
        -- Somente o departamento credito ir� ter acesso para alterar as informacoes
        IF rw_crapope.dsdepart <> 'PRODUTOS' AND rw_crapope.dsdepart <> 'TI'  THEN
          vr_cdcritic := 36;
          vr_dscritic := NULL;
          RAISE vr_exc_saida;          
        END IF;
               
      END IF; /* END IF pr_flgdepop */
      
      -- Cursor com os dados da Regra
      OPEN cr_craprli(pr_cdcooper => vr_cdcooper
                     ,pr_inpessoa => pr_inpessoa
                     ,pr_tplimite => pr_tplimite);
      FETCH cr_craprli 
       INTO rw_craprli;
      -- Se nao encontrar
      IF cr_craprli%NOTFOUND THEN
        -- Fecha o cursor
        CLOSE cr_craprli;
        vr_dscritic := 'Regra nao encontrada.';
        RAISE vr_exc_saida;
      ELSE
        -- Fecha o cursor
        CLOSE cr_craprli;          
      END IF;      
      
      -- Criar cabe�alho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'vlmaxren', pr_tag_cont => rw_craprli.vlmaxren, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'nrrevcad', pr_tag_cont => rw_craprli.nrrevcad, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtmincta', pr_tag_cont => rw_craprli.qtmincta, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtdiaren', pr_tag_cont => rw_craprli.qtdiaren, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtmaxren', pr_tag_cont => rw_craprli.qtmaxren, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtdiaatr', pr_tag_cont => rw_craprli.qtdiaatr, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtatracc', pr_tag_cont => rw_craprli.qtatracc, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'dssitdop', pr_tag_cont => rw_craprli.dssitdop, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'dsrisdop', pr_tag_cont => rw_craprli.dsrisdop, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'pcliqdez', pr_tag_cont => rw_craprli.pcliqdez, pr_des_erro => vr_dscritic);
      gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => 0, pr_tag_nova => 'qtdialiq', pr_tag_cont => rw_craprli.qtdialiq, pr_des_erro => vr_dscritic);
      
    EXCEPTION      
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas c�digo
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descri��o
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em LIMI0001.pc_tela_cadlim_alterar: ' || SQLERRM;
        
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;

  END pc_tela_cadlim_consultar;
  
  PROCEDURE pc_tela_cadlim_alterar(pr_inpessoa IN craprli.inpessoa%TYPE --> Codigo do tipo de pessoa                                  
                                  ,pr_vlmaxren IN craprli.vlmaxren%TYPE --> Valor Maximo para renovacao do limite
                                  ,pr_nrrevcad IN craprli.nrrevcad%TYPE --> Numero de meses da revisao cadastral
                                  ,pr_qtmincta IN craprli.qtmincta%TYPE --> Tempo Minimo de conta
                                  ,pr_qtdiaren IN craprli.qtdiaren%TYPE --> Periodo Maximo de dias para renovacao
                                  ,pr_qtmaxren IN craprli.qtmaxren%TYPE --> Quantidade maxima de renovacao
                                  ,pr_qtdiaatr IN craprli.qtdiaatr%TYPE --> Quantidade de dias de atraso de emprestimo
                                  ,pr_qtatracc IN craprli.qtatracc%TYPE --> Quantidade de dias de atraso em conta corrente
                                  ,pr_dssitdop IN craprli.dssitdop%TYPE --> Situacoes que englobam a operacao
                                  ,pr_dsrisdop IN craprli.dsrisdop%TYPE --> Riscos que englobam a operacao
                                  ,pr_tplimite IN craprli.tplimite%TYPE --> Tipo de limite de cr�dito
                                  ,pr_pcliqdez IN craprli.pcliqdez%TYPE --> Percentual m�nimo de liquidez
                                  ,pr_qtdialiq IN craprli.qtdialiq%TYPE --> Quantidade de dias para calculo do percentual liquidez                                  
                                  ,pr_idgerlog IN INTEGER               --> Identificador de Log (Fixo no c�digo, 0 � N�o / 1 - Sim)         
                                  ,pr_xmllog   IN VARCHAR2              --> XML com informa��es de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                  ,pr_dscritic OUT VARCHAR2             --> Descri��o da cr�tica
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
    /* .............................................................................

     Programa: pc_tela_cadlim_alterar
     Sistema : Rotinas referentes ao limite de credito
     Sigla   : LIMI
     Autor   : James Prust Junior
     Data    : Dezembro/14.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Alterar as regras do limite de credito.

     Observacao: -----
     Alteracoes: 11/08/2016 - Inclus�o do par�metro pr_tplmite para filtro por tipo de limite
                            - Inclus�o dos par�metros pr_pcliqdez e pr_qtdialiq para busca e atualiza��o
                 (Linhares - Projeto 300)
     
     ..............................................................................*/ 
    DECLARE

      -- Selecionar os dados
      CURSOR cr_craprli(pr_cdcooper IN craprli.cdcooper%TYPE
                       ,pr_inpessoa IN craprli.inpessoa%TYPE) IS
        SELECT vlmaxren,
               nrrevcad,
               qtmincta,
               qtdiaren,
               qtmaxren,
               qtdiaatr,
               qtatracc,
               dssitdop,
               dsrisdop,
               pcliqdez,
               qtdialiq               
          FROM craprli
         WHERE cdcooper = pr_cdcooper
           AND inpessoa = pr_inpessoa
           AND tplimite = pr_tplimite;

      rw_craprli cr_craprli%ROWTYPE;

      CURSOR cr_crapope(pr_cdcooper IN crapope.cdcooper%TYPE
                       ,pr_cdoperad IN crapope.cdoperad%TYPE) IS
        SELECT dsdepart
          FROM crapope
         WHERE crapope.cdcooper = pr_cdcooper
           AND upper(crapope.cdoperad) = upper(pr_cdoperad);
      rw_crapope cr_crapope%ROWTYPE; 
      
      -- Vari�vel de cr�ticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

      -- Variaveis padrao
      vr_cdcooper      NUMBER;
      vr_cdoperad      VARCHAR2(100);
      vr_nmdatela      VARCHAR2(100);
      vr_nmeacao       VARCHAR2(100);
      vr_cdagenci      VARCHAR2(100);
      vr_nrdcaixa      VARCHAR2(100);
      vr_idorigem      VARCHAR2(100);
      
      -- Variaveis de log
      vr_dtaltcad      VARCHAR2(20);          --> Data de alteracao do cadastro
      vr_dsclinha      VARCHAR2(4000);        --> Linha a ser inserida no LOG
      vr_dsdireto      VARCHAR2(400);         --> Diret�rio do arquivo de LOG
      vr_utlfileh      utl_file.file_type;    --> Handle para arquivo de LOG

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

      -- Buscar Dados do Operador
      OPEN cr_crapope (pr_cdcooper => vr_cdcooper
                      ,pr_cdoperad => vr_cdoperad);
      FETCH cr_crapope INTO rw_crapope;
      -- Verifica se a retornou registro
      IF cr_crapope%NOTFOUND THEN
        CLOSE cr_crapope;
        vr_cdcritic := 67;
        vr_dscritic := NULL;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas Fecha o Cursor
        CLOSE cr_crapope;
      END IF;
        
      -- Somente o departamento credito ir� ter acesso para alterar as informacoes
      IF rw_crapope.dsdepart <> 'PRODUTOS' AND rw_crapope.dsdepart <> 'TI'  THEN
        vr_cdcritic := 36;
        vr_dscritic := NULL;
        RAISE vr_exc_saida;          
      END IF;

      -- Cursor com os dados da Regra
      OPEN cr_craprli(pr_cdcooper => vr_cdcooper
                     ,pr_inpessoa => pr_inpessoa);
      FETCH cr_craprli 
       INTO rw_craprli;
      -- Se nao encontrar
      IF cr_craprli%NOTFOUND THEN
        -- Fecha o cursor
        CLOSE cr_craprli;
        vr_dscritic := 'Regra nao encontrada.';
        RAISE vr_exc_saida;
      ELSE
        -- Fecha o cursor
        CLOSE cr_craprli;          
      END IF;

      vr_dtaltcad := to_char(SYSDATE,'dd/mm/yyyy hh24:mi:ss');
      vr_dsdireto := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                          ,pr_cdcooper => vr_cdcooper
                                          ,pr_nmsubdir => '/log');

      -- Abrir arquivo em modo de adi��o
      gene0001.pc_abre_arquivo(pr_nmdireto => vr_dsdireto
                              ,pr_nmarquiv => 'cadlim.log'
                              ,pr_tipabert => 'A'
                              ,pr_utlfileh => vr_utlfileh
                              ,pr_des_erro => vr_dscritic);

      -- Verifica se ocorreram erros
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;

      IF rw_craprli.vlmaxren <> pr_vlmaxren THEN
        vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                   || ' alterou o campo Valor Maximo do Limite de ' 
                                   || rw_craprli.vlmaxren || ' para ' || pr_vlmaxren;
        -- Gravar linha no arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                      ,pr_des_text => vr_dsclinha);
      END IF;
        
      IF rw_craprli.nrrevcad <> pr_nrrevcad THEN
        vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                   || ' alterou o campo Revisao Cadastral de ' 
                                   || rw_craprli.nrrevcad || ' para ' || pr_nrrevcad;
        -- Gravar linha no arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                      ,pr_des_text => vr_dsclinha);
      END IF;
        
      IF rw_craprli.qtmincta <> pr_qtmincta THEN
        vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                   || ' alterou o campo Tempo de Conta de '
                                   || rw_craprli.qtmincta || ' para ' || pr_qtmincta;
        -- Gravar linha no arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                      ,pr_des_text => vr_dsclinha);
      END IF;
       
      IF rw_craprli.qtdiaren <> pr_qtdiaren THEN
        vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                   || ' alterou o campo Tentativas Diarias de Renovacao de '
                                   || rw_craprli.qtdiaren || ' para ' || pr_qtdiaren;
        -- Gravar linha no arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                      ,pr_des_text => vr_dsclinha);
      END IF;
        
      IF rw_craprli.dssitdop <> pr_dssitdop THEN
        vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                   || ' alterou o campo Situacao da Conta de ' 
                                   || rw_craprli.dssitdop || ' para ' || pr_dssitdop;                                 
                                     
        -- Gravar linha no arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                      ,pr_des_text => vr_dsclinha);
      END IF;
        
      IF rw_craprli.qtmaxren <> pr_qtmaxren THEN
        vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                   || ' alterou o campo Qtde. Maxima de Renovacoes de ' 
                                   || rw_craprli.qtmaxren || ' para ' || pr_qtmaxren;                                 
                                     
        -- Gravar linha no arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                      ,pr_des_text => vr_dsclinha);
      END IF;
        
      IF rw_craprli.qtdiaatr <> pr_qtdiaatr THEN
        vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                   || ' alterou o campo Emprestimo em Atraso de ' 
                                   || rw_craprli.qtdiaatr || ' para ' || pr_qtdiaatr;                                 
                                     
        -- Gravar linha no arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                      ,pr_des_text => vr_dsclinha);
      END IF;
        
      IF rw_craprli.qtatracc <> pr_qtatracc THEN
        vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                   || ' alterou o campo Conta Corrente em Atraso de ' 
                                   || rw_craprli.qtatracc || ' para ' || pr_qtatracc;                                 
                                    
        -- Gravar linha no arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                      ,pr_des_text => vr_dsclinha);
      END IF;
        
      IF rw_craprli.dsrisdop <> pr_dsrisdop THEN
        vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                   || ' alterou o campo Risco da Conta de ' 
                                   || rw_craprli.dsrisdop || ' para ' || pr_dsrisdop;                                 
                                     
        -- Gravar linha no arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                      ,pr_des_text => vr_dsclinha);
      END IF;
        
      
      IF rw_craprli.pcliqdez <> pr_pcliqdez THEN

        vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                   || ' alterou o campo Percentual Minimo de Liquidez de ' 
                                   || rw_craprli.pcliqdez || ' para ' || pr_pcliqdez;                                 
                                     
        -- Gravar linha no arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                      ,pr_des_text => vr_dsclinha);
        
      END IF;
      
     
      IF rw_craprli.qtdialiq <> pr_qtdialiq THEN

        vr_dsclinha := vr_dtaltcad || ' -->  Operador ' || vr_cdoperad 
                                   || ' alterou o campo Quantidade de Dias para Calculo Percentual Liquidez de ' 
                                   || rw_craprli.qtdialiq || ' para ' || pr_qtdialiq;                                 
                                     
        -- Gravar linha no arquivo
        gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_utlfileh
                                      ,pr_des_text => vr_dsclinha);
        
      END IF;
        
      -- Fechar arquivo
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_utlfileh);
        
      BEGIN
        UPDATE craprli SET   
               vlmaxren = pr_vlmaxren,
               nrrevcad = pr_nrrevcad,
               qtmincta = pr_qtmincta,
               qtdiaren = pr_qtdiaren,
               qtmaxren = pr_qtmaxren,
               qtdiaatr = pr_qtdiaatr,
               qtatracc = pr_qtatracc,
               dssitdop = pr_dssitdop,
               dsrisdop = pr_dsrisdop,
               pcliqdez = pr_pcliqdez,
               qtdialiq = pr_qtdialiq               
         WHERE cdcooper = vr_cdcooper
           AND inpessoa = pr_inpessoa
           AND tplimite = pr_tplimite;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao alterar a regra: ' || SQLERRM;
          RAISE vr_exc_saida;
      END;

      COMMIT;   

    EXCEPTION      
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas c�digo
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descri��o
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
      WHEN OTHERS THEN
        
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em LIMI0001.pc_tela_cadlim_alterar: ' || SQLERRM;
        
        -- Carregar XML padr�o para vari�vel de retorno n�o utilizada.
        -- Existe para satisfazer exig�ncia da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        ROLLBACK;
    END;

  END pc_tela_cadlim_alterar;
  
  -- Rotina referente a renovacao manual do limite de credito
  PROCEDURE pc_renovar_limite_cred_manual(pr_cdcooper IN crapcop.cdcooper%TYPE  --> C�digo da Cooperativa
                                         ,pr_cdoperad IN crapope.cdoperad%TYPE  --> C�digo do Operador
                                         ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da Tela
                                         ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                         ,pr_nrdconta IN crapass.nrdconta%TYPE  --> N�mero da Conta
                                         ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Titular da Conta
                                         ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de Movimento
                                         ,pr_nrctrlim IN craplim.nrctrlim%TYPE  --> Contrato                            
                                         ,pr_cdcritic OUT PLS_INTEGER           --> C�digo da cr�tica
                                         ,pr_dscritic OUT VARCHAR2) IS         --> Descri��o da cr�tica
  BEGIN
    /* .............................................................................

     Programa: pc_renovar_manual
     Sistema : Rotinas referentes ao limite de credito
     Sigla   : LIMI
     Autor   : James Prust Junior
     Data    : Dezembro/14.                    Ultima atualizacao: 11/08/2016

     Dados referentes ao programa:

     Frequencia: 
     Objetivo  : Rotina referente a renovacao manual do limite de credito
     Alteracoes:  11/08/2016 - Inclu�do filtro tplimite para Limite de Cr�dito
             (Linhares Projeto 300)
    ..............................................................................*/
    
  DECLARE
    -- Vari�vel de cr�ticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    
    -- Variaveis de Log de Alteracao    
    vr_flgctitg crapalt.flgctitg%TYPE;
    vr_dsaltera LONG;
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
    -- Cursor Limite de cheque especial
    CURSOR cr_craplim(pr_cdcooper IN craplim.cdcooper%TYPE     --> C�digo da Cooperativa
                     ,pr_nrdconta IN craplim.nrdconta%TYPE     --> N�mero da Conta
                     ,pr_nrctrlim IN craplim.nrctrlim%TYPE) IS --> N�mero do Contrato                    
                     
      SELECT craplim.cddlinha,
             craplim.insitlim,
             craplim.qtrenova,
             craplim.dtrenova,
             nvl(craplim.dtfimvig, craplim.dtinivig + craplim.qtdiavig) as dtfimvig
        FROM craplim
       WHERE craplim.cdcooper = pr_cdcooper
         AND craplim.nrdconta = pr_nrdconta
         AND craplim.nrctrlim = pr_nrctrlim
         AND craplim.tpctrlim = 1;
    rw_craplim cr_craplim%ROWTYPE;
    
    -- Cursor Linhas de Credito Rotativo
    CURSOR cr_craplrt (pr_cdcooper IN craplrt.cdcooper%TYPE,
                       pr_cddlinha IN craplrt.cddlinha%TYPE) IS
      SELECT craplrt.flgstlcr
        FROM craplrt
       WHERE craplrt.cdcooper = pr_cdcooper AND
             craplrt.cddlinha = pr_cddlinha;
    rw_craplrt cr_craplrt%ROWTYPE;
    
    -- Cursor Regras do limite de cheque especial
    CURSOR cr_craprli (pr_cdcooper IN craprli.cdcooper%TYPE,
                       pr_inpessoa IN craprli.inpessoa%TYPE) IS
      SELECT qtmaxren
        FROM craprli
       WHERE craprli.cdcooper = pr_cdcooper AND
             craprli.inpessoa = DECODE(pr_inpessoa,3,2,pr_inpessoa)
             AND craprli.tplimite = 1; -- Limite Credito
    rw_craprli cr_craprli%ROWTYPE;
    
    -- Cursor Associado
    CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE,
                       pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT inpessoa,
             nrdctitg,
             flgctitg
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper AND
             crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    
    -- Cursor alteracao de cadastro
    CURSOR cr_crapalt (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE
                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
      SELECT crapalt.dsaltera,
             crapalt.rowid
        FROM crapalt
       WHERE crapalt.cdcooper = pr_cdcooper
         AND crapalt.nrdconta = pr_nrdconta
         AND crapalt.dtaltera = pr_dtmvtolt;
    rw_crapalt cr_crapalt%ROWTYPE;
    
  BEGIN
    
    -- Consultar o limite de credito
    OPEN cr_craplim(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta,
                    pr_nrctrlim => pr_nrctrlim);
    FETCH cr_craplim INTO rw_craplim;
    -- Verifica se o limite de credito existe
    IF cr_craplim%NOTFOUND THEN
      CLOSE cr_craplim;
      vr_dscritic := 'Associado nao possui proposta de limite de credito. Conta: ' || pr_nrdconta || '.Contrato: ' || pr_nrctrlim;
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_craplim;
    END IF;
    
    -- Verifica a situacao do limite do cheque especial
    IF nvl(rw_craplim.insitlim,0) <> 2 THEN
      vr_dscritic := 'O contrato de limite de credito deve estar ativo.';
      RAISE vr_exc_saida;
    END IF;
    
    -- Verificacao para saber se jah passou o vencimento do limite para a renovacao
    IF rw_craplim.dtfimvig > pr_dtmvtolt THEN
      vr_dscritic := 'Nao e possivel realizar a renovacao do limite. Contrato nao esta vencido.';     
      RAISE vr_exc_saida;      
    END IF;
    
    -- Consulta o limite de credito
    OPEN cr_craplrt(pr_cdcooper => pr_cdcooper,
                    pr_cddlinha => rw_craplim.cddlinha);
    FETCH cr_craplrt INTO rw_craplrt;
    -- Verifica se o limite de credito existe
    IF cr_craplrt%NOTFOUND THEN
      CLOSE cr_craplrt;
      vr_dscritic := 'Linha de Credito nao cadastrada. Linha: ' || rw_craplim.cddlinha;
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_craplrt;
    END IF;
    
    -- Verifica a situacao do limite do credito
    IF nvl(rw_craplrt.flgstlcr,0) = 0 THEN
      vr_dscritic := 'Linha de credito bloqueada. Nao e possivel efetuar a renovacao. E necessario incluir um novo limite.';
      RAISE vr_exc_saida;
    END IF;  
    
    -- Consulta o Associado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    -- Verifica se o limite de credito existe
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_dscritic := 'Associado nao cadastrado. Conta: ' || pr_nrdconta;
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_crapass;
    END IF;
    
    -- Consulta a regra do limite de cheque especial
    OPEN cr_craprli(pr_cdcooper => pr_cdcooper,
                    pr_inpessoa => rw_crapass.inpessoa);
    FETCH cr_craprli INTO rw_craprli;
    -- Verifica se o limite de credito existe
    IF cr_craprli%NOTFOUND THEN
      CLOSE cr_craprli;
      vr_dscritic := 'Regras do Linha de Credito nao cadastrada.';
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_craprli;
    END IF;
    
    -- Verificar a quantidade maxima que pode renovar
    IF ((nvl(rw_craprli.qtmaxren,0) > 0) AND (nvl(rw_craplim.qtrenova,0) >= nvl(rw_craprli.qtmaxren,0))) THEN
      vr_dscritic := 'Nao e possivel realizar a renovacao do limite. Incluir novo contrato';
      RAISE vr_exc_saida;
    END IF;    
    
    -- Atualiza os dados do limite de cheque especial
    BEGIN
      UPDATE craplim SET 
             dtrenova = pr_dtmvtolt,
             tprenova = 'M',
             dsnrenov = '',
             dtfimvig = pr_dtmvtolt + nvl(qtdiavig,0),
             qtrenova = nvl(qtrenova,0) + 1,
             cdoperad = pr_cdoperad,
             cdopelib = pr_cdoperad
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctrlim = pr_nrctrlim
         AND tpctrlim = 1; -- Limite Credito
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao renovar o limite de credito: ' || SQLERRM;
        RAISE vr_exc_saida;
    END;
    
    /* Por default fica como 3 */
    vr_flgctitg  := 3;    
    vr_dsaltera  := 'Renov. Manual Limite Cred. Ctr: ' || pr_nrctrlim || ',';
    
    /* Se for conta integracao ativa, seta a flag para enviar ao BB */
    IF trim(rw_crapass.nrdctitg) IS NOT NULL AND rw_crapass.flgctitg = 2 THEN  /* Ativa */
      --Conta Integracao
      vr_flgctitg := 0;
    END IF;
    
    /* Verifica se jah possui alteracao */
    OPEN cr_crapalt (pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_dtmvtolt => pr_dtmvtolt);
    FETCH cr_crapalt INTO rw_crapalt;
    --Verificar se encontrou
    IF cr_crapalt%FOUND THEN
      --Fechar Cursor
      CLOSE cr_crapalt;
      -- Altera o registro
      BEGIN
        UPDATE crapalt SET 
               crapalt.dsaltera = rw_crapalt.dsaltera || vr_dsaltera,
 							 crapalt.cdoperad = pr_cdoperad,
 		           crapalt.flgctitg = vr_flgctitg
         WHERE crapalt.rowid = rw_crapalt.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic:= 'Erro ao atualizar crapalt. '||SQLERRM;
          --Sair
          RAISE vr_exc_saida;
      END;       
    ELSE
      --Fechar Cursor
      CLOSE cr_crapalt;
       
      --Inserir Alteracao
      BEGIN
        INSERT INTO crapalt
          (crapalt.nrdconta
          ,crapalt.dtaltera
          ,crapalt.tpaltera
          ,crapalt.dsaltera
          ,crapalt.cdcooper
          ,crapalt.flgctitg
          ,crapalt.cdoperad)
        VALUES
          (pr_nrdconta
          ,pr_dtmvtolt
          ,2
          ,vr_dsaltera
          ,pr_cdcooper
          ,vr_flgctitg
          ,pr_cdoperad);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir crapalt. '||SQLERRM;
          RAISE vr_exc_saida;
      END;
      
    END IF;   
    
  EXCEPTION
    WHEN vr_exc_saida THEN     
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      ROLLBACK;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral LIMI0001.pc_renovar_limite_cred_manual: ' || SQLERRM;
      ROLLBACK;
    END;
    
  END pc_renovar_limite_cred_manual;
  
 -- Rotina referente a renovacao manual do limite de desconto de cheque
  PROCEDURE pc_renovar_lim_desc_cheque(pr_cdcooper IN crapcop.cdcooper%TYPE --> C�digo da Cooperativa
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE --> N�mero da Conta
                                      ,pr_idseqttl IN crapttl.idseqttl%TYPE --> Titular da Conta
                                      ,pr_vllimite IN craplim.vllimite%TYPE --> Valor Limite de Desconto
                                      ,pr_nrctrlim IN craplim.nrctrlim%TYPE --> Contrato
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data de Movimento
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE --> C�digo do Operador
                                      ,pr_nmdatela IN craptel.nmdatela%TYPE --> Nome da Tela
                                      ,pr_idorigem IN INTEGER               --> Identificador de Origem
                                      ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                      ,pr_dscritic OUT VARCHAR2) IS         --> Descri��o da cr�tica                                       
                                      
  BEGIN

    /* .............................................................................

     Programa: pc_renovar_lim_desc_cheque
     Sistema : Rotinas referentes ao limite de credito
     Sigla   : LIMI
     Autor   : Ricardo Linhares/
     Data    : Agosto/16.                    Ultima atualizacao: 08/09/2016

     Dados referentes ao programa:

     Frequencia: Sempre que chamada. 
     Objetivo  : Rotina referente a renovacao manual do limite de desconto de cheque
     
     Alteracoes: 08/09/2016 - Alterada procedure para ser chamada sem mensageria.
                              Mensageria ser� tratada na package criada exclusivamente
                              para a tela. Projeto 300 (Lombardi)
     
    ..............................................................................*/
    
  DECLARE
  
    -- Vari�vel para consulta de limite
    vr_tab_lim_desconto TELA_TAB019.typ_tab_lim_desconto;      
    
    --Variaveis auxiliares
    vr_vllimite craplim.vllimite%TYPE;
    vr_nrdrowid ROWID;
    
    -- Vari�vel de cr�ticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    
    -- Variaveis de Log de Alteracao    
    vr_flgctitg crapalt.flgctitg%TYPE;
    vr_dsaltera LONG;
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
    
    -- Cursor Limite de cheque especial
    CURSOR cr_craplim(pr_cdcooper IN craplim.cdcooper%TYPE     --> C�digo da Cooperativa
                     ,pr_nrdconta IN craplim.nrdconta%TYPE     --> N�mero da Conta
                     ,pr_nrctrlim IN craplim.nrctrlim%TYPE) IS --> N�mero do Contrato                    
                     
      SELECT craplim.cddlinha,
             craplim.insitlim,
             craplim.qtrenova,
             craplim.dtrenova,
             craplim.vllimite,
             nvl(craplim.dtfimvig, craplim.dtinivig + craplim.qtdiavig) as dtfimvig
        FROM craplim
       WHERE craplim.cdcooper = pr_cdcooper
         AND craplim.nrdconta = pr_nrdconta
         AND craplim.nrctrlim = pr_nrctrlim
         AND craplim.tpctrlim = 2; -- Limite de cr�dito de desconto de cheque
    rw_craplim cr_craplim%ROWTYPE;
    
    -- Cursor Linhas de Credito de Desconto de Cheque
    CURSOR cr_crapldc (pr_cdcooper IN craplrt.cdcooper%TYPE,
                       pr_cddlinha IN craplrt.cddlinha%TYPE) IS
      SELECT crapldc.flgstlcr
        FROM crapldc
       WHERE crapldc.cdcooper = pr_cdcooper 
         AND crapldc.cddlinha = pr_cddlinha
         AND crapldc.tpdescto = 2; -- Cheque
      
    rw_crapldc cr_crapldc%ROWTYPE;
    
    -- Cursor Regras do limite de cheque especial
    CURSOR cr_craprli (pr_cdcooper IN craprli.cdcooper%TYPE,
                       pr_inpessoa IN craprli.inpessoa%TYPE) IS
      SELECT qtmaxren
        FROM craprli
       WHERE craprli.cdcooper = pr_cdcooper 
         AND craprli.inpessoa = DECODE(pr_inpessoa,3,2,pr_inpessoa)
         AND craprli.tplimite = 2; -- Limite Credito Desconto Cheque
    
    rw_craprli cr_craprli%ROWTYPE;
    
    -- Cursor Associado
    CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE,
                       pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT inpessoa,
             nrdctitg,
             flgctitg
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper 
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    
    -- Cursor alteracao de cadastro
    CURSOR cr_crapalt (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE
                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
    SELECT crapalt.dsaltera,
           crapalt.rowid
      FROM crapalt
     WHERE crapalt.cdcooper = pr_cdcooper
       AND crapalt.nrdconta = pr_nrdconta
       AND crapalt.dtaltera = pr_dtmvtolt;
    
     rw_crapalt cr_crapalt%ROWTYPE;
     
  BEGIN
    
    IF(pr_vllimite < 0) THEN
      vr_dscritic := 'Valor do limite inv�lido.';
      RAISE vr_exc_saida;
    END IF;
     
    -- Consultar o limite de credito
    OPEN cr_craplim(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta,
                    pr_nrctrlim => pr_nrctrlim);
    FETCH cr_craplim INTO rw_craplim;

    -- Verifica se o limite de credito existe
    IF cr_craplim%NOTFOUND THEN
      CLOSE cr_craplim;
      vr_dscritic := 'Associado n�o possui proposta de limite de desconto cheque.';
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_craplim;
    END IF;
    
    -- Verifica a situacao do limite do cheque especial
    IF nvl(rw_craplim.insitlim,0) <> 2 THEN
      vr_dscritic := 'O contrato de limite de desconto de cheque deve estar ativo.';
      RAISE vr_exc_saida;
    END IF;
    
    -- Verificacao para saber se jah passou o vencimento do limite para a renovacao
    IF rw_craplim.dtfimvig > pr_dtmvtolt THEN
      vr_dscritic := 'Nao e possivel realizar a renovacao do limite de desconto de cheque. Limite nao esta vencido.';     
      RAISE vr_exc_saida;      
    END IF;
    
    --Guarda valor anterior do limite
    vr_vllimite := rw_craplim.vllimite;
    
    -- Consulta o limite de credito de desconto de cheque
    OPEN cr_crapldc(pr_cdcooper => pr_cdcooper,
                    pr_cddlinha => rw_craplim.cddlinha);
    FETCH cr_crapldc INTO rw_crapldc;

    -- Verifica se o limite de credito existe
    IF cr_crapldc%NOTFOUND THEN
      CLOSE cr_crapldc;
      vr_dscritic := 'Linha de desconto de cheque nao cadastrada.';
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_crapldc;
    END IF;
    
    -- Verifica se a linha de credito esta liberada
    IF nvl(rw_crapldc.flgstlcr,0) = 0 THEN
      vr_dscritic := 'Nao e possivel realizar a renovacao de limite, linha de desconto bloqueada. Incluir novo limite.';
      RAISE vr_exc_saida;
    END IF;

    -- Consulta o Associado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    
    -- Verifica se o limite de credito existe
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_dscritic := 'Associado nao cadastrado.';
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_crapass;
    END IF;
    
    -- Consulta a regra do limite de cheque especial
    OPEN cr_craprli(pr_cdcooper => pr_cdcooper,
                    pr_inpessoa => rw_crapass.inpessoa);
    FETCH cr_craprli INTO rw_craprli;
    -- Verifica se o limite de credito existe
    IF cr_craprli%NOTFOUND THEN
      CLOSE cr_craprli;
      vr_dscritic := 'Regras da linha de credito de desconto de cheque nao cadastrada.';
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_craprli;
    END IF;
    
    -- Verificar a quantidade maxima que pode renovar
    IF ((nvl(rw_craprli.qtmaxren,0) > 0) AND (nvl(rw_craplim.qtrenova,0) >= nvl(rw_craprli.qtmaxren,0))) THEN
      vr_dscritic := 'Nao e possivel realizar a renovacao do limite. Incluir novo contrato';
      RAISE vr_exc_saida;
    END IF;    
    
    -- Consulta o limite de desconto por tipo de pessoa
    TELA_TAB019.pc_busca_limite_desconto( pr_cdcooper => pr_cdcooper                  --> Codigo da cooperativa 
                                         ,pr_inpessoa => rw_crapass.inpessoa          --> Tipo de pessoa ( 0 - todos 1-Fisica e 2-Juridica)
                                         ,pr_tab_lim_desconto => vr_tab_lim_desconto  --> Temptable com os dados do limite de desconto                                     
                                         ,pr_cdcritic => vr_cdcritic                  --> C�digo da cr�tica
                                         ,pr_dscritic => vr_dscritic);                --> Descri��o da cr�tica                
    
    -- Se retornou alguma cr�tica
    IF TRIM(vr_dscritic) IS NOT NULL OR nvl(vr_cdcritic,0) > 0 THEN
      RAISE vr_exc_saida;
    END IF;              

    -- Verifica se o novo limite estipula o limite m�ximo pelo tipo de pessoa
    IF(pr_vllimite > vr_tab_lim_desconto(rw_crapass.inpessoa).vllimite) THEN
      vr_dscritic := 'Nao e possivel realizar a renovacao de limite, valor excede o limite estipulado.';
      RAISE vr_exc_saida;
    END IF;

    -- Atualiza os dados do limite de cheque especial
    BEGIN
      UPDATE craplim
         SET dtinivig = pr_dtmvtolt,
             dtfimvig = pr_dtmvtolt + NVL(qtdiavig,0),
             vllimite = pr_vllimite,
             qtrenova = NVL(qtrenova,0) + 1,
             dtrenova = pr_dtmvtolt,
             tprenova = 'M' -- Manual
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctrlim = pr_nrctrlim
         AND tpctrlim = 2; -- Limite Desconto Cheque

    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao renovar o limite de credito de desconto de cheque: ' || SQLERRM;
        RAISE vr_exc_saida;
    END;
    
    -- Por default fica como 3
    vr_flgctitg  := 3;    
    vr_dsaltera  := 'Renov. Manual Limite Desc Cheque. Ctr: ' || pr_nrctrlim || ',';
    
    -- Se for conta integracao ativa, seta a flag para enviar ao BB 
    IF trim(rw_crapass.nrdctitg) IS NOT NULL AND rw_crapass.flgctitg = 2 THEN  -- Ativa
      --Conta Integracao
      vr_flgctitg := 0;
    END IF;
    
    -- Verifica se jah possui alteracao
    OPEN cr_crapalt (pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_dtmvtolt => pr_dtmvtolt);
    FETCH cr_crapalt INTO rw_crapalt;

    IF cr_crapalt%FOUND THEN
      CLOSE cr_crapalt;
      -- Altera o registro
      BEGIN
        UPDATE crapalt SET 
               dsaltera = rw_crapalt.dsaltera || vr_dsaltera,
               cdoperad = pr_cdoperad,
               flgctitg = vr_flgctitg
         WHERE rowid = rw_crapalt.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic:= 'Erro ao atualizar crapalt. '||SQLERRM;
          RAISE vr_exc_saida;
      END;       
    ELSE
      CLOSE cr_crapalt;
      --Inserir Alteracao
      BEGIN
        INSERT INTO crapalt
          (nrdconta
          ,dtaltera
          ,tpaltera
          ,dsaltera
          ,cdcooper
          ,flgctitg
          ,cdoperad)
        VALUES
          (pr_nrdconta
          ,pr_dtmvtolt
          ,2 -- altera��es diversas
          ,vr_dsaltera
          ,pr_cdcooper
          ,vr_flgctitg
          ,pr_cdoperad);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir crapalt. '||SQLERRM;
          RAISE vr_exc_saida;
      END;
      
    END IF;
       
    IF vr_vllimite <> pr_vllimite THEN
      -- Inclus�o de log com retorno do ROWID
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => ''
                          ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem) --> Origem enviada
                          ,pr_dstransa => 'Altera��o do valor limite de desconto de cheque.'
                          ,pr_dttransa => trunc(SYSDATE)
                          ,pr_flgtrans => 1 --> TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 0
                          ,pr_nmdatela => 'ATENDA'
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
            
      gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                               ,pr_nmdcampo => 'Valor Limite'
                               ,pr_dsdadant => to_char(vr_vllimite,'FM999G999G999G999G999D00')
                               ,pr_dsdadatu => to_char(pr_vllimite,'FM999G999G999G999G999D00'));
    END IF;
    
  EXCEPTION
    WHEN vr_exc_saida THEN     
      IF vr_cdcritic <> 0 THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      END IF;
      ROLLBACK;
    WHEN OTHERS THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := 'Erro geral na rotina da tela ' || pr_nmdatela || ': ' || SQLERRM;
      ROLLBACK;
    END;
    
  END pc_renovar_lim_desc_cheque;
  
  -- Rotina referente ao desbloqueio do limite de descondo de cheque
  PROCEDURE pc_desbloq_lim_desc_cheque(pr_cdcooper IN crapcop.cdcooper%TYPE --> C�digo da cooperativa
                                      ,pr_nrdconta IN crapass.nrdconta%TYPE --> N�mero da Conta
                                      ,pr_nrctrlim IN craplim.nrctrlim%TYPE --> Contrato                            
                                      ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE --> N�mero do Caixa
                                      ,pr_cdoperad IN craplgm.cdoperad%TYPE --> C�digo do operador
                                      ,pr_nmdatela IN craptel.nmdatela%TYPE --> Nome da Tela
                                      ,pr_cdcritic OUT PLS_INTEGER          --> C�digo da cr�tica
                                      ,pr_dscritic OUT VARCHAR2) IS         --> Descri��o da cr�tica
                                      
    BEGIN 
      
    /* .............................................................................

     Programa: pc_desbloq_lim_desc_cheque
     Sistema : Rotinas referentes ao limite de credito
     Sigla   : LIMI
     Autor   : Ricardo Linhares
     Data    : Agosto/16.                    Ultima atualizacao: 

     Dados referentes ao programa:

     Frequencia: Sempre que chamada. 
     Objetivo  : Rotina referente ao desbloqueio do limite de desconto de cheque
     Alteracoes:  
    ..............................................................................*/    
                                      

    DECLARE                                      
                                      
      -- Vari�vel de cr�ticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;
      vr_tab_erro      gene0001.typ_tab_erro;      
    
    -- Cursor Associado
    CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE,
                       pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT dtelimin,
             dtdemiss,
             cdagenci,
             vllimcre
        FROM crapass
       WHERE crapass.cdcooper = pr_cdcooper 
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;      

    -- Cursor gen�rico de calend�rio
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    --Tipo da tabela de saldos
    vr_tab_saldo EXTR0001.typ_tab_saldos;    

    -- Cursor alteracao de cadastro
    CURSOR cr_crapalt (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE
                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
    SELECT crapalt.dsaltera,
           crapalt.rowid
      FROM crapalt
     WHERE crapalt.cdcooper = pr_cdcooper
       AND crapalt.nrdconta = pr_nrdconta
       AND crapalt.dtaltera = pr_dtmvtolt;    

    rw_crapalt cr_crapalt%ROWTYPE;

    -- Variaveis de Log de Alteracao    
    vr_flgctitg crapalt.flgctitg%TYPE;
    vr_dsaltera LONG;       
    
    -- saldo dispon�vel
    vr_vlsddisp NUMBER;
      
   BEGIN
      
    -- Consulta o Associado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    
    -- Verifica a conta do associado
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_dscritic := 'Associado nao cadastrado.';
      RAISE vr_exc_saida;
    ELSE
      CLOSE cr_crapass;
    END IF;

    -- Verifica se o cooperado est� demitido
    IF rw_crapass.dtdemiss IS NOT NULL THEN
      vr_dscritic := 'Operacao nao efetuada. Cooperado Demitido';
      RAISE vr_exc_saida;
    END IF;    

    -- Verifica se a conta n�o est� eliminada
    IF rw_crapass.dtelimin IS NOT NULL THEN
      vr_dscritic := 'Operacao nao efetuada. Conta Eliminada.';
      RAISE vr_exc_saida;
    END IF;       

   -- Leitura do calendario da cooperativa
     OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;    

    -- Verifica se o saldo est� positivo
    extr0001.pc_obtem_saldo_dia(pr_cdcooper => pr_cdcooper, 
                                pr_rw_crapdat => rw_crapdat, 
                                pr_cdagenci => rw_crapass.cdagenci, 
                                pr_nrdcaixa => pr_nrdcaixa,
                                pr_cdoperad => pr_cdoperad, 
                                pr_nrdconta => pr_nrdconta, 
                                pr_vllimcre => rw_crapass.vllimcre, 
                                pr_dtrefere => rw_crapdat.dtmvtolt, 
                                pr_flgcrass => FALSE, 
                                pr_tipo_busca => 'A', -- A = Usa dtrefere-1
                                pr_des_reto => vr_dscritic, 
                                pr_tab_sald => vr_tab_saldo, 
                                pr_tab_erro => vr_tab_erro);

    --Se ocorreu erro
    IF vr_dscritic = 'NOK' THEN
      IF vr_tab_erro.COUNT > 0 THEN
        vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
        vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
      ELSE
        vr_cdcritic:= 0;
        vr_dscritic:= 'Operacao nao Efetuada. Nao foi possivel consultar o saldo para a operacao.';
      END IF;
      RAISE vr_exc_saida;
    ELSE
      vr_dscritic:= NULL;
    END IF;
    --Verificar o saldo retornado
    IF vr_tab_saldo.Count = 0 THEN
      vr_cdcritic:= 0;
      vr_dscritic:= 'Operacao nao Efetuada. Nao foi possivel consultar o saldo para a operacao.';
      RAISE vr_exc_saida;
    ELSE
      vr_vlsddisp := nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vlsddisp,0) +
                     nvl(vr_tab_saldo(vr_tab_saldo.FIRST).vllimcre,0);
    END IF; 
    
    -- Verifica se o saldo � positivo
    IF vr_vlsddisp < 0 THEN
      vr_cdcritic:= 0;
      vr_dscritic:= 'Operacao nao Efetuada. Conta com Saldo Negativo.';   
      RAISE vr_exc_saida;
    END IF;

    -- Efetuar desbloqueio
    UPDATE craplim
       SET insitblq = 0
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND nrctrlim = pr_nrctrlim
       AND tpctrlim = 2; -- Limite Desconto Cheque

    vr_flgctitg  := 3;    
    vr_dsaltera  := 'Desbloq. Inclusao Bordero. Ctr: ' || pr_nrctrlim || ',';
    
    -- Atualizar CRAPLAT
    OPEN cr_crapalt (pr_cdcooper => pr_cdcooper
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
    FETCH cr_crapalt INTO rw_crapalt;

    IF cr_crapalt%FOUND THEN
      CLOSE cr_crapalt;
      BEGIN
        UPDATE crapalt SET 
               dsaltera = rw_crapalt.dsaltera || vr_dsaltera,
               cdoperad = pr_cdoperad,
               flgctitg = vr_flgctitg
         WHERE rowid = rw_crapalt.rowid;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic:= 'Erro ao atualizar crapalt. '|| SQLERRM;
          RAISE vr_exc_saida;
      END;       
    ELSE
      CLOSE cr_crapalt;
      BEGIN
        INSERT INTO crapalt
          (nrdconta
          ,dtaltera
          ,tpaltera
          ,dsaltera
          ,cdcooper
          ,flgctitg
          ,cdoperad)
        VALUES
          (pr_nrdconta
          ,rw_crapdat.dtmvtolt
          ,2 --altera��es diversas
          ,vr_dsaltera
          ,pr_cdcooper
          ,vr_flgctitg
          ,pr_cdoperad);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro ao inserir crapalt. '||SQLERRM;
          RAISE vr_exc_saida;
      END;
      
    END IF;      

    EXCEPTION
      WHEN vr_exc_saida THEN     

        IF vr_cdcritic <> 0 THEN
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;
        ROLLBACK;
      WHEN OTHERS THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral na rotina da tela ' || pr_nmdatela || ': ' || SQLERRM;
        ROLLBACK;
      END;
  
    END pc_desbloq_lim_desc_cheque;
    
END LIMI0001;
/
