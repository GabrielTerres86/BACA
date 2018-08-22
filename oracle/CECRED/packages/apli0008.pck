CREATE OR REPLACE PACKAGE CECRED.APLI0008 AS

  /* ------------------------------------------------------------------------------------
  Programa: APLI0008
  Sistema : Rotinas genericas referente a aplicacao programada
  Sigla   : APLI
  
  Autor   : CIS Corporate
  Data    : Julho/2018                       Ultima atualizacao: 
  
  Dados referentes ao programa:
  
  Frequencia: -----
  Objetivo  : Rotinas genéricas referente às aplicações programadas
              
  Alteracoes:    
  ----------------------------------------------------------------------------------- */

	-- PLTable que contém os dados de extrato das aplicações programadas
	TYPE typ_reg_extrato_apl_prog IS
	  RECORD(dtmvtolt craprac.dtmvtolt%TYPE
		      ,cdagenci craplac.cdagenci%TYPE
					,cdhistor craphis.cdhistor%TYPE
					,dshistor craphis.dshistor%TYPE
          ,aghistor PLS_INTEGER           -- Indica se deve-se agrupar o histórico
					,dsextrat craphis.dsextrat%TYPE
					,nrdocmto craplac.nrdocmto%TYPE
					,indebcre craphis.indebcre%TYPE
					,vllanmto craplac.vllanmto%TYPE
          ,cdbccxlt craplac.cdbccxlt%TYPE
          ,nrdolote craplac.nrdolote%TYPE
					,vlsldtot NUMBER
					,txlancto NUMBER
					,nraplica craplac.nraplica%TYPE);
					
  TYPE typ_tab_extrato_apl_prog IS
    TABLE OF typ_reg_extrato_apl_prog
		INDEX BY BINARY_INTEGER;

  /* Funcao para validar a cooperativa */
  FUNCTION fn_val_cooperativa(pr_cdcooper IN crapcop.cdcooper%TYPE) --> Código da Cooperativa
   RETURN NUMBER;
  /* Funcao para validar a cooperativa */
  FUNCTION fn_val_associado(pr_cdcooper IN crapcop.cdcooper%TYPE, --> Código da Cooperativa
                            pr_nrdconta IN crapass.nrdconta%TYPE) --> Número/Digito Conta) 
   RETURN NUMBER;

  /* Procedure para buscar a aplicacao programada padrão */
  PROCEDURE pc_buscar_apl_prog_padrao(pr_cdprodut OUT pls_integer); --> Código do Produto default (CRAPCPC)

  /* Procedure para buscar a aplicacao programada padrão - Mensageria */
  PROCEDURE pc_buscar_apl_prog_padrao_web(
                                          pr_xmllog   IN VARCHAR2            --> XML com informacoes de LOG
                                         ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                                         ,pr_retxml   IN OUT NOCOPY XMLType  --> Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2           --> Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2);         --> Erros do processo

  /* Procedure para incluir uma aplicação programada */
  PROCEDURE pc_incluir_apl_prog (pr_cdcooper IN crapcop.cdcooper%TYPE       --> Código da cooperativa
                                ,pr_cdagenci IN crapage.cdagenci%TYPE       --> Código da agência
                                ,pr_nrdcaixa IN INTEGER                     --> Número do caixa
                                ,pr_cdoperad IN crapope.cdoperad%TYPE       --> Código do operador
                                ,pr_nmdatela VARCHAR2                       --> Nome da tela
                                ,pr_idorigem IN INTEGER                     --> Código de origem
                                ,pr_nrdconta IN craprpp.nrdconta%TYPE       --> Número da conta
                                ,pr_idseqttl IN crapttl.idseqttl%TYPE       --> Sequêncial do titular   
                                ,pr_dtmvtolt IN craprpp.dtmvtolt%TYPE       --> Data do movimento atual
                                ,pr_cdprodut IN crapcpc.cdprodut%TYPE       --> Código do Produto de Captação
                                ,pr_dtinirpp IN craprpp.dtinirpp%TYPE       --> Data de Inicío da Aplicação Programada
                                ,pr_dtvctopp IN Date                        --> Data de vencimento do fundo (Tela)
                                ,pr_qtdiacar IN crapmpc.qtdiacar%TYPE       --> Carência em dias (Tela)
                                ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE       --> Prazo de vencimento em dias (Tela)
                                ,pr_vlprerpp IN craprpp.vlprerpp%TYPE       --> Valor da parcela
                                ,pr_tpemiext IN craprpp.tpemiext%TYPE       --> Tipo de impressao do extrato (1-individual,2-todas,3-nao emit).
                                ,pr_flgerlog IN INTEGER                     --> Gerar log (0 = Não / 1 = Sim)
                                ,pr_dsfinali IN craprpp.dsfinali%TYPE       --> Finalidade do fundo (proveniente da tela)
                                ,pr_flgteimo IN INTEGER                     --> Teimosinha (0 = Não / 1 = Sim)
                                ,pr_flgdbpar IN INTEGER                     --> Débito Parcial (0 = Não / 1 = Sim)
                                ,pr_nrctrrpp OUT craprpp.nrctrrpp%TYPE      --> Número do Contrato - CRAPRPP
                                ,pr_nraplica OUT craprac.nraplica%TYPE      --> Número da Aplicação - CRAPRAC
                                ,pr_rpprowid OUT ROWID                      --> RowID da tabela CRAPRPP
                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE      --> Codigo da critica de erro
                                ,pr_dscritic OUT crapcri.dscritic%TYPE);    --> Descricao da critica de erro
 
 /* Procedure para incluir uma aplicação programada  - Mensageria */
  PROCEDURE pc_incluir_apl_prog_web (pr_nrdconta IN craprpp.nrdconta%TYPE   --> Número da conta
                                    ,pr_idseqttl IN crapttl.idseqttl%TYPE   --> Sequêncial do titular   
                                    ,pr_cdprodut IN crapcpc.cdprodut%TYPE   --> Código do Produto de Captação
                                    ,pr_dtmvtolt IN VARCHAR2                --> Data do movimento atual - DD/MM/YYYY
                                    ,pr_qtdiacar IN crapmpc.qtdiacar%TYPE   --> Carência em dias (Tela)
                                    ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE   --> Prazo de vencimento em dias (Tela)
                                    ,pr_dtinirpp IN VARCHAR2                --> Data de Inicío da Aplicação Programada - DD/MM/YYYY
                                    ,pr_dtvctopp IN VARCHAR2                --> Data de vencimento - DD/MM/YYYY (Tela)
                                    ,pr_vlprerpp IN craprpp.vlprerpp%TYPE   --> Valor da parcela
                                    ,pr_tpemiext IN craprpp.tpemiext%TYPE   --> Tipo de impressao do extrato (1-individual,2-todas,3-nao emit).
                                    ,pr_flgerlog IN INTEGER                 --> Gerar log (0 = Não / 1 = Sim)
                                    ,pr_dsfinali IN craprpp.dsfinali%TYPE   --> Finalidade do fundo (proveniente da tela)
                                    ,pr_flgteimo IN INTEGER                 --> Teimosinha (0 = Não / 1 = Sim)
                                    ,pr_flgdbpar IN INTEGER                 --> Débito Parcial (0 = Não / 1 = Sim)
                                    ,pr_xmllog   IN VARCHAR2                --> XML com informacoes de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER            --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2               --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType      --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2               --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);             --> Erros do processo
                                                                 
  /* Procedure para calcular o saldo de uma aplicacao programada a partir da RPP */
  PROCEDURE pc_calc_saldo_apl_prog (pr_cdcooper IN crapcop.cdcooper%TYPE     --> Cooperativa
                                   ,pr_cdprogra IN crapres.cdprogra%TYPE     --> Programa que esta executando
                                   ,pr_cdoperad IN craplrg.cdoperad%TYPE     --> Codigo do Operador
                                   ,pr_nrdconta IN craprpp.nrdconta%TYPE     --> Numero da conta da aplicacao
                                   ,pr_idseqttl IN INTEGER                   --> Identificador Sequencial
                                   ,pr_idorigem IN INTEGER                   --> Identificador da Origem
                                   ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE     --> Numero do contrato poupanca
                                   ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE     --> Data do movimento atual
                                   ,pr_vlsdrdpp IN OUT craprpp.vlsdrdpp%TYPE --> Valor do saldo da poupanca programada
                                   ,pr_des_erro OUT VARCHAR2) ;              --> Saida com erros;

  /* Procedure para calcular o saldo de uma aplicacao programada a partir da RPP - Mensgeria*/
  PROCEDURE pc_calc_saldo_apl_prog_web (pr_nrdconta IN craprac.nrdconta%TYPE   -- Número da Conta
                                       ,pr_idseqttl IN crapttl.idseqttl%TYPE   -- Titular da Conta
                                       ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE   -- Número da Aplicação Programada.
                                       ,pr_dtmvtolt IN VARCHAR2                -- Data de Movimento Inicial
                                       ,pr_xmllog   IN VARCHAR2                -- XML com informacoes de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER            -- Código da crítica
                                       ,pr_dscritic OUT VARCHAR2               -- Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2               -- Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2);              -- Erros do processo

  /* Procedure referente a busca de extratos das aplicações programadas a partira da RPP */                           
  PROCEDURE pc_calc_saldo_ini_apl_prog(pr_cdcooper IN craprac.cdcooper%TYPE                  -- Código da Cooperativa
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE                  -- Código do Operador 
                                      ,pr_nmdatela IN craptel.nmdatela%TYPE                  -- Nome da Tela
                                      ,pr_idorigem IN NUMBER                                 -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA                  
                                      ,pr_nrdconta IN craprac.nrdconta%TYPE                  -- Número da Conta
                                      ,pr_idseqttl IN crapttl.idseqttl%TYPE                  -- Titular da Conta
                                      ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE                  -- Número da Aplicação Programada.
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE                  -- Data de Movimento
                                      ,pr_idgerlog IN NUMBER                                 -- Identificador de Log (Fixo na chamada, 0 – Não / 1 – Sim)
                                      ,pr_vlsdrdpp OUT NUMBER                                -- Saldo em pr_dtmvtolt-1
                                      ,pr_vlresgat OUT NUMBER                                -- Valor de resgate
                                      ,pr_vlrendim OUT NUMBER                                -- Valor de rendimento
                                      ,pr_vldoirrf OUT NUMBER                                -- Valor do IRRF
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE                 -- Código da crítica
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE);               -- Descrição da crítica

  /* Procedure referente a busca de extratos das aplicações programadas a partir da RPP */                           
  PROCEDURE pc_buscar_extrato_apl_prog(pr_cdcooper IN craprac.cdcooper%TYPE                  -- Código da Cooperativa
                                      ,pr_cdoperad IN crapope.cdoperad%TYPE                  -- Código do Operador 
                                      ,pr_nmdatela IN craptel.nmdatela%TYPE                  -- Nome da Tela
                                      ,pr_idorigem IN NUMBER                                 -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA                  
                                      ,pr_nrdconta IN craprac.nrdconta%TYPE                  -- Número da Conta
                                      ,pr_idseqttl IN crapttl.idseqttl%TYPE                  -- Titular da Conta
                                      ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE                  -- Número da Aplicação Programada.
                                      ,pr_dtmvtolt_ini IN crapdat.dtmvtolt%TYPE              -- Data de Movimento - Inicio
                                      ,pr_dtmvtolt_fim IN crapdat.dtmvtolt%TYPE              -- Data de Movimento - Fim
                                      ,pr_idlstdhs IN NUMBER                                 -- Identificador de Listagem de Todos Históricos (Fixo na chamada, 0 – Não / 1 – Sim)
                                      ,pr_idgerlog IN NUMBER                                 -- Identificador de Log (Fixo na chamada, 0 – Não / 1 – Sim)
                                      ,pr_tab_extrato OUT apli0008.typ_tab_extrato_apl_prog  -- PLTable com os dados de extrato
                                      ,pr_vlresgat OUT NUMBER                                -- Valor de resgate
                                      ,pr_vlrendim OUT NUMBER                                -- Valor de rendimento
                                      ,pr_vldoirrf OUT NUMBER                                -- Valor do IRRF
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE                 -- Código da crítica
                                      ,pr_dscritic OUT crapcri.dscritic%TYPE);               -- Descrição da crítica

  /* Procedure referente a busca de extratos das aplicações programadas a partir da RPP Mensageria */    
  PROCEDURE pc_buscar_extrato_apl_prog_web (pr_nrdconta IN craprac.nrdconta%TYPE   -- Número da Conta
                                           ,pr_idseqttl IN crapttl.idseqttl%TYPE   -- Titular da Conta
                                           ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE   -- Número da Aplicação Programada.
                                           ,pr_dtmvtolt_ini IN VARCHAR2            -- Data de Movimento Inicial
                                           ,pr_dtmvtolt_fim IN VARCHAR2            -- Data de Movimento Fim
                                           ,pr_idlstdhs IN NUMBER                  -- Identificador de Listagem de Todos Históricos (Fixo na chamada, 0 – Não / 1 – Sim)
                                           ,pr_idgerlog IN NUMBER                  -- Identificador de Log (Fixo na chamada, 0 – Não / 1 – Sim)
                                           ,pr_xmllog   IN VARCHAR2                -- XML com informacoes de LOG
                                           ,pr_cdcritic OUT PLS_INTEGER            -- Código da crítica
                                           ,pr_dscritic OUT VARCHAR2               -- Descrição da crítica
                                           ,pr_retxml   IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                                           ,pr_nmdcampo OUT VARCHAR2               -- Nome do campo com erro
                                           ,pr_des_erro OUT VARCHAR2);              -- Erros do processo

  /* Procedure referente geracao de extratos de um título de uma Aplicação Programada */                           
  PROCEDURE pc_gerar_ext_apl_prog_titulo(pr_cdcooper IN craprac.cdcooper%TYPE                  -- Código da Cooperativa
                                        ,pr_cdoperad IN crapope.cdoperad%TYPE                  -- Código do Operador 
                                        ,pr_nmdatela IN craptel.nmdatela%TYPE                  -- Nome da Tela
                                        ,pr_idorigem IN NUMBER                                 -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA                  
                                        ,pr_nrdconta IN craprac.nrdconta%TYPE                  -- Número da Conta
                                        ,pr_idseqttl IN crapttl.idseqttl%TYPE                  -- Titular da Conta
                                        ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE                  -- Número da Aplicação Programada.
                                        ,pr_nraplica IN craprac.nraplica%TYPE                  -- Número da Aplicacao
                                        ,pr_dtmvtolt_ini IN crapdat.dtmvtolt%TYPE              -- Data de Movimento - Inicio
                                        ,pr_dtmvtolt_fim IN crapdat.dtmvtolt%TYPE              -- Data de Movimento - Fim
                                        ,pr_idlstdhs IN NUMBER                                 -- Identificador de Listagem de Todos Históricos (Fixo na chamada, 0 – Não / 1 – Sim)
                                        ,pr_idgerlog IN NUMBER                                 -- Identificador de Log (Fixo na chamada, 0 – Não / 1 – Sim)
                                        ,pr_tab_extrato OUT apli0008.typ_tab_extrato_apl_prog  -- PLTable com os dados de extrato
                                        ,pr_vlresgat OUT NUMBER                                -- Valor de resgate
                                        ,pr_vlrendim OUT NUMBER                                -- Valor de rendimento
                                        ,pr_vldoirrf OUT NUMBER                                -- Valor do IRRF 
                                        ,pr_percirrf OUT NUMBER                                -- Valor de aliquota de IR
                                        ,pr_txacumul OUT NUMBER                                -- Taxa acumulada durante o período total da aplicação
                                        ,pr_txacumes OUT NUMBER                                -- Taxa acumulada durante o mês vigente
                                        ,pr_qtdiacar OUT craprac.qtdiacar%TYPE                 -- Qtd. dias carência
                                        ,pr_dtfimcar OUT DATE                                  -- Data fim da carência
                                        ,pr_dtvencto OUT DATE                                  -- Data de vencimento 
                                        ,pr_qtdiaprz OUT craprac.qtdiaprz%TYPE                 -- Quantidade de dias do prazo da modalidade
                                        ,pr_qtdiaapl OUT craprac.qtdiaapl%TYPE                 -- Quantidade de dias da aplicacao
                                        ,pr_txaplica OUT craprac.txaplica%TYPE                 -- Taxa contratada da aplicacao
                                        ,pr_nmdindex OUT crapind.nmdindex%TYPE                 -- Nome do Indice  
                                        ,pr_cdcritic OUT crapcri.cdcritic%TYPE                 -- Código da crítica
                                        ,pr_dscritic OUT crapcri.dscritic%TYPE);               -- Descrição da crítica
    
  /* Procedure referente a busca de detalhes da RPP a partir do numero de contrato */
  PROCEDURE pc_buscar_detalhe_apl_prog (pr_cdcooper IN craprac.cdcooper%TYPE                  -- Código da Cooperativa
                                       ,pr_cdoperad IN crapope.cdoperad%TYPE                  -- Código do Operador 
                                       ,pr_nmdatela IN craptel.nmdatela%TYPE                  -- Nome da Tela
                                       ,pr_idorigem IN NUMBER                                 -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA                  
                                       ,pr_nrdconta IN craprac.nrdconta%TYPE                  -- Número da Conta
                                       ,pr_idseqttl IN crapttl.idseqttl%TYPE                  -- Titular da Conta
                                       ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE                  -- Número da Aplicação Programada
                                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE                  -- Data de Movimento
                                       ,pr_tab_dados_rpp OUT apli0001.typ_tab_dados_rpp       -- PLTable com os detalhes;
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE                 -- Código da crítica
                                       ,pr_dscritic OUT crapcri.dscritic%TYPE);               -- Descrição da crítica

  /* Procedure referente a busca de detalhes da RPP a partir do numero de contrato - Mensgeria*/
  PROCEDURE pc_buscar_detalhe_apl_prog_web (pr_nrdconta IN craprac.nrdconta%TYPE   -- Número da Conta
                                           ,pr_idseqttl IN crapttl.idseqttl%TYPE   -- Titular da Conta
                                           ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE   -- Número da Aplicação Programada.
                                           ,pr_dtmvtolt IN VARCHAR2                -- Data de Movimento Inicial
                                           ,pr_xmllog   IN VARCHAR2                -- XML com informacoes de LOG
                                           ,pr_cdcritic OUT PLS_INTEGER            -- Código da crítica
                                           ,pr_dscritic OUT VARCHAR2               -- Descrição da crítica
                                           ,pr_retxml   IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                                           ,pr_nmdcampo OUT VARCHAR2               -- Nome do campo com erro
                                           ,pr_des_erro OUT VARCHAR2);              -- Erros do processo

END APLI0008;
/
CREATE OR REPLACE PACKAGE BODY CECRED.APLI0008 AS

  FUNCTION fn_val_cooperativa(pr_cdcooper IN crapcop.cdcooper%TYPE) --> Código da Cooperativa
   RETURN NUMBER IS
    /* .............................................................................
     Programa: fn_val_cooperativa
     Autor   : CIS Corporate
     Data    : 21/07/2018                     Ultima atualizacao:
    
     Dados referentes ao programa:
    
     Objetivo  : Verificar a existencia da cooperativa
     
     Alteracoes :
     
    .............................................................................*/
    vr_coop NUMBER;
  
  Begin
    Begin
      -- Utlizando cursor implicito pois irá retornar no máximo 1 linha
      Select 1 into vr_coop from crapcop Where cdcooper = pr_cdcooper;
    Exception
      When NO_DATA_FOUND Then
        vr_coop := 0;
    End;
    Return vr_coop;
  End fn_val_cooperativa;

  FUNCTION fn_val_associado(pr_cdcooper IN crapcop.cdcooper%TYPE, --> Código da Cooperativa
                            pr_nrdconta IN crapass.nrdconta%TYPE) --> Número/Digito Conta) 
   RETURN NUMBER IS
    /* .............................................................................
     Programa: fn_val_associado
     Autor   : CIS Corporate
     Data    : 21/07/2018                     Ultima atualizacao:
    
     Dados referentes ao programa:
    
     Objetivo  : Verificar a existencia da cooperativa
     
     Alteracoes :
     
    .............................................................................*/
    vr_assoc NUMBER;
  
  Begin
    Begin
      -- Utlizando cursor implicito pois irá retornar no máximo 1 linha
      Select 1
        into vr_assoc
        from crapass
       Where cdcooper = pr_cdcooper
         and nrdconta = pr_nrdconta;
    Exception
      When NO_DATA_FOUND Then
        vr_assoc := 0;
    End;
    Return vr_assoc;
  End fn_val_associado;

  PROCEDURE pc_buscar_apl_prog_padrao(pr_cdprodut OUT pls_integer) --> Código do Produto default (CRAPCPC)
   IS
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_buscar_apl_prog_padrao
    --  Sistema  : Captação (Aplicação Programada)
    --  Sigla    : CRED
    --  Autor    : CIS Corporate
    --  Data     : Março/2018.                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: ----
    -- Objetivo  : Recupera aplicacao programada padrão
    --
    -- Alteracoes:
    -- 
    ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      CURSOR cr_crapprm IS
        Select TO_NUMBER(DSVLRPRM) codprodut
          From crapprm
         Where NMSISTEM = 'CRED'
           AND CDACESSO = 'COD_MIGRACAO_APL_PROG';
      vr_crapprm cr_crapprm%ROWTYPE;
    BEGIN
      OPEN cr_crapprm;
      FETCH cr_crapprm
        INTO vr_crapprm;
      pr_cdprodut := vr_crapprm.codprodut;
      CLOSE cr_crapprm;
    END;
  END pc_buscar_apl_prog_padrao;

  PROCEDURE pc_buscar_apl_prog_padrao_web(
                                          pr_xmllog   IN VARCHAR2            --> XML com informacoes de LOG
                                         ,pr_cdcritic OUT PLS_INTEGER        --> Código da crítica
                                         ,pr_dscritic OUT VARCHAR2           --> Descrição da crítica
                                         ,pr_retxml   IN OUT NOCOPY XMLType  --> Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2           --> Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2)          --> Erros do processo
   IS
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_buscar_apl_prog_padrao_web
    --  Sistema  : Captação (Aplicação Programada)
    --  Sigla    : CRED
    --  Autor    : CIS Corporate
    --  Data     : Julho/2018.                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: ----
    -- Objetivo  : Recupera aplicacao programada padrão web
    --
    -- Alteracoes:
    -- 
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      vr_cdprodut pls_integer;
    
      -- Variaveis auxiliares
      vr_exc_erro EXCEPTION;
    
    BEGIN
      apli0008.pc_buscar_apl_prog_padrao(pr_cdprodut => vr_cdprodut);
      If vr_cdprodut is null Then
        Raise vr_exc_erro;
      End If;
    
      -- Criar XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><cdprodut>' || vr_cdprodut ||
                                     '</cdprodut></Root>');
    
    Exception
      When others then
        pr_cdcritic := null; -- não será utilizado
        pr_nmdcampo := null; -- não será utilizado
        pr_dscritic := 'Produto padrão para Aplicação Programada não cadastrado';
        pr_des_erro := 'NOK';
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
      
    END;
  END pc_buscar_apl_prog_padrao_web;

  PROCEDURE pc_incluir_apl_prog (pr_cdcooper IN crapcop.cdcooper%TYPE             --> Código da cooperativa
                                ,pr_cdagenci IN crapage.cdagenci%TYPE             --> Código da agência
                                ,pr_nrdcaixa IN INTEGER                           --> Número do caixa
                                ,pr_cdoperad IN crapope.cdoperad%TYPE             --> Código do operador
                                ,pr_nmdatela VARCHAR2                             --> Nome da tela
                                ,pr_idorigem IN INTEGER                           --> Código de origem
                                ,pr_nrdconta IN craprpp.nrdconta%TYPE             --> Número da conta
                                ,pr_idseqttl IN crapttl.idseqttl%TYPE             --> Sequêncial do titular   
                                ,pr_dtmvtolt IN craprpp.dtmvtolt%TYPE             --> Data do movimento atual
                                ,pr_cdprodut IN crapcpc.cdprodut%TYPE             --> Código do Produto de Captação
                                ,pr_dtinirpp IN craprpp.dtinirpp%TYPE             --> Data de Inicío da Aplicação Programada
                                ,pr_dtvctopp IN Date                              --> Data de vencimento (Tela)
                                ,pr_qtdiacar IN crapmpc.qtdiacar%TYPE             --> Carência em dias (Tela)
                                ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE             --> Prazo de vencimento em dias (Tela)
                                ,pr_vlprerpp IN craprpp.vlprerpp%TYPE             --> Valor da parcela
                                ,pr_tpemiext IN craprpp.tpemiext%TYPE             --> Tipo de impressao do extrato (1-individual,2-todas,3-nao emit).
                                ,pr_flgerlog IN INTEGER                           --> Gerar log (0 = Não / 1 = Sim)
                                ,pr_dsfinali IN craprpp.dsfinali%TYPE             --> Finalidade do fundo (proveniente da tela)
                                ,pr_flgteimo IN INTEGER                           --> Teimosinha (0 = Não / 1 = Sim)
                                ,pr_flgdbpar IN INTEGER                           --> Débito Parcial (0 = Não / 1 = Sim)
                                ,pr_nrctrrpp OUT craprpp.nrctrrpp%TYPE            --> Número do Contrato - CRAPRPP
                                ,pr_nraplica OUT craprac.nraplica%TYPE            --> Número da Aplicação - CRAPRAC
                                ,pr_rpprowid OUT ROWID                            --> RowID da tabela CRAPRPP
                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE            --> Codigo da critica de erro
                                ,pr_dscritic OUT crapcri.dscritic%TYPE)           --> Descricao da critica de erro

   IS
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_incluir_apli_progr
    --  Sistema  : Captação (Aplicação Programada)
    --  Sigla    : CRED
    --  Autor    : CIS Corporate
    --  Data     : Julho/2018.                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: ----
    -- Objetivo  : Insere novo plano aplicação programada
    --
    -- Alteracoes:
    -- 
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      -- Constantes
    
      cn_cdbccxlt pls_integer := 200;
      cn_nrdolote pls_integer := 1537; -- Num. Lote
      cn_tplotmov pls_integer := 14;
      cn_cdhistor pls_integer := 0;
    
      vr_consist pls_integer := 0;     -- Generica para consistencias
      vr_saldo NUMBER(25,8);      -- Saldo 

      vr_lock_timer date;

      vr_cdsecext    crapass.cdsecext%type; -- Código de Seção
      vr_tmp_craplot cobr0011.cr_craplot%ROWTYPE;
      vr_nrseqdig    craplot.nrseqdig%type; -- Sequencia de digitação
      vr_nrseqted    crapmat.nrseqted%type; -- Recuperar a sequence da conta de apl. programada
    
      -- Variaveis auxiliares
      vr_exc_erro_nrb EXCEPTION; -- Sem rollback
      vr_exc_erro_rb  EXCEPTION; -- Com rollback
    
      -- Cursores
      -- Lotes
      CURSOR cr_craplot(pr_cdcooper crapcop.cdcooper%TYPE,
                        pr_cdagenci craplot.cdagenci%TYPE,
                        pr_dtmvtolt craplot.dtmvtolt%TYPE) IS
        Select 1
          From craplot
         where cdcooper = pr_cdcooper
           and dtmvtolt = pr_dtmvtolt
           and cdagenci = pr_cdagenci
           and cdbccxlt = cn_cdbccxlt -- fixo
           and nrdolote = cn_nrdolote; -- fixo
      rw_craplot cr_craplot%ROWTYPE;

    Begin
      Begin
        -- Verifica se existe a cooperativa
        vr_consist := apli0008.fn_val_cooperativa(pr_cdcooper => pr_cdcooper); -- Cod. Cooperativa
        If vr_consist = 0 Then
          pr_cdcritic := null;
          pr_dscritic := 'Cooperativa não encontrada';
          Raise vr_exc_erro_nrb;
        End If;
        -- Verifica se existe o cooperado e recupera o codigo da secao para onde deve ser enviado o extrato.
        Begin
          -- Utlizando cursor implicito pois irá retornar no máximo 1 linha
          Select cdsecext
            into vr_cdsecext
            from crapass
           Where cdcooper = pr_cdcooper
             and nrdconta = pr_nrdconta;
        Exception
             When NO_DATA_FOUND Then
                  pr_cdcritic := 999;
                  pr_dscritic := 'Associado não encontrado';
                  Raise vr_exc_erro_nrb;
        End;
         
        -- A proc. pc_obtem_taxa_modalidade não é executada novamente, esta já foi invocada na tela

        SAVEPOINT RAC_savepoint;
      
        -- Tratamento do LOTE  
        -- Leitura do lote se o mesmo estiver em lock, tenta por 10 seg. */
        For i in 1 .. 100 Loop
          Begin
            Open cr_craplot(pr_cdcooper => pr_cdcooper,
                            pr_cdagenci => pr_cdagenci,
                            pr_dtmvtolt => pr_dtmvtolt);
            Fetch cr_craplot
              Into rw_craplot;
            pr_dscritic := NULL;
            Exit;
          Exception
            When Others Then
              If cr_craplot%ISOPEN Then
                Close cr_craplot;
              End If;
              -- setar critica caso for o ultimo
              If i = 100 THEN
                pr_dscritic := 'Registro de lote em uso';
              End If;
              -- aguardar +- 0,5 seg. antes de tentar novamente
              Select SYSDATE Into vr_lock_timer From Dual;
              Loop
                Exit When vr_lock_timer +(1 / 100000) = SYSDATE;
              End Loop;
          End;
        End Loop;
        If pr_dscritic = 'Registro de lote em uso' Then
          raise vr_exc_erro_nrb;
        End If;

        IF cr_craplot%NOTFOUND THEN
          CLOSE cr_craplot;
          -- Criar o lote
          cobr0011.pc_insere_lote(pr_cdcooper => pr_cdcooper,
                                  pr_dtmvtolt => pr_dtmvtolt,
                                  pr_cdagenci => pr_cdagenci,
                                  pr_cdbccxlt => cn_cdbccxlt,
                                  pr_nrdolote => cn_nrdolote,
                                  pr_cdoperad => pr_cdoperad,
                                  pr_nrdcaixa => pr_nrdcaixa,
                                  pr_tplotmov => cn_tplotmov,
                                  pr_cdhistor => cn_cdhistor,
                                  pr_craplot  => vr_tmp_craplot, -- OUT
                                  pr_dscritic => pr_dscritic     -- OUT
                                  );
          IF pr_dscritic is not null Then
            raise vr_exc_erro_rb;
          END IF;
        ELSE
          CLOSE cr_craplot;
        END IF; -- Not found (Lote encontrado)

        -- Recuperar a sequencia da digitação (chave unica craprpp3)  
        -- Cursor Implicito
        Select max(nrseqdig) + 1
          into vr_nrseqdig
          from craprpp
         where cdcooper = pr_cdcooper
           and dtmvtolt = pr_dtmvtolt
           and cdagenci = pr_cdagenci
           and cdbccxlt = cn_cdbccxlt -- fixo
           and nrdolote = cn_nrdolote; -- fixo
        If vr_nrseqdig is null Then
           vr_nrseqdig := 1;
        End If;

        -- Atualizar CRAPLOT
        Begin
          Update craplot
             Set qtcompln = qtcompln + 1,
                 qtinfoln = qtinfoln + 1,
                 vlcompcr = vlcompcr + pr_vlprerpp,
                 vlinfocr = vlinfocr + pr_vlprerpp
           Where cdcooper = pr_cdcooper
             and dtmvtolt = pr_dtmvtolt
             and cdagenci = pr_cdagenci
             and cdbccxlt = cn_cdbccxlt -- fixo
             and nrdolote = cn_nrdolote -- fixo
             and tplotmov = cn_tplotmov; -- fixo
        Exception
          When Others Then
            pr_dscritic := 'Erro atualizacao CRAPLOT';
            raise vr_exc_erro_rb;
        End;
        
        -- Recuperar próximo número RPP
        vr_nrseqted := cecred.fn_sequence(pr_nmtabela => 'CRAPMAT',
                                           pr_nmdcampo => 'NRRDCAPP',
                                           pr_dsdchave => pr_cdcooper,
                                           pr_flgdecre => 'N');

        -- Efetuar Inclusao na RPP
        Begin
          Insert into craprpp
            (nrctrrpp,         -- Numero da poupanca programada.
             cdsitrpp,         -- Situacao: 0-nao ativo, 1-ativo, 2-suspenso, 3-cancelado, 5-vencido.
             cdcooper,         -- cooperativa
             cdageass,         -- Codigo da agencia do associado.
             cdagenci,         -- Numero do PA.
             tpemiext,         -- Tipo de impressao do extrato (1-individual,2-todas,3-nao emit).
             dtimpcrt,         -- Data de impressao do contrato
             dtcalcul,         -- Proximo dia a ser calculado.      
             dtvctopp,         -- Data de vencimento da poupanca programada.
             cdopeori,         -- Codigo do operador original do registro
             cdageori,         -- Codigo da agencia original do registro
             dtinsori,         -- Data  de criação do registro
             dtiniper,         -- Data de início do periodo.
             dtfimper,         -- Data de fim do periodo.
             dtinirpp,         -- Data de inicio da poupanca programada.
             dtdebito,         -- Data do debito.
             dtiniext,         -- Data de referencia inicial para extrato.
             dtfimext,         -- Data de referencia final para extrato.
             dtsppant,         -- Data de referencia dos lancamentos do ano anterior.
             dtsppext,         -- Data de referencia dos lancamentos p/extrato.
             dtrnirpp,         -- Data de reinicio do debito do plano.
             dtsdppan,         -- Data do saldo anterior.
             flgctain,         -- Conta Investimento
             nrdolote,         -- Numero do lote.
             nrseqdig,         -- Sequencia de digitacao.
             cdbccxlt,         -- Codigo do banco/caixa.
             cdsecext,         -- Codigo da secao para onde deve ser enviado o extrato.
             nrdconta,         -- Numero da conta/dv do associado.
             vlprerpp,         -- Valor da prestacao da poupanca programada.
             indebito,         -- Indicador de debito.
             dtmvtolt,         -- Data do movimento atual.
             cdprodut,         -- Codigo do produto de captacao
             dsfinali,         -- Descricao da finalidade para a aplicacao programada
             flgteimo,         -- Teimosinha
             flgdbpar          -- Débito Parcial
             )         
          Values
            (vr_nrseqted,      -- Numero da poupanca programada.
             1,                -- 1
             pr_cdcooper,
             pr_cdagenci,
             pr_cdagenci,
             pr_tpemiext,      -- Tipo de impressao do extrato - prov. Tela
             null,             -- Data de impressao do contrato             
             null,             -- Proximo dia a ser calculado.     
             pr_dtvctopp,      -- Data de vencimento da poupanca programada. - prov. Tela
             pr_cdoperad,      
             pr_cdagenci,
             to_date(sysdate,'DD/MM/YYYY'), -- Data  de criação do registro
             pr_dtinirpp,      -- Data de início do periodo.
             add_months(pr_dtinirpp,1),      -- Data de fim do periodo.
             pr_dtinirpp,      -- Data de inicio da poupanca programada.
             pr_dtinirpp,      -- Data do debito.  
             pr_dtinirpp,      -- Data de referencia inicial para extrato.
             pr_dtinirpp,      -- Data de referencia final para extrato.
             pr_dtinirpp,      -- Data de referencia dos lancamentos do ano anterior.
             pr_dtinirpp,      -- Data de referencia dos lancamentos p/extrato.
             null,             -- Data de reinicio do debito do plano.
             pr_dtinirpp,      -- Data do saldo anterior.
             1,                -- Conta Investimento - Fixo
             cn_nrdolote,      -- Numero do lote.
             vr_nrseqdig,      -- Sequencia de digitacao.
             cn_cdbccxlt,      -- Codigo do banco/caixa. - Fixo
             vr_cdsecext,      -- Codigo da secao para onde deve ser enviado o extrato.
             pr_nrdconta,      -- Numero da conta/dv do associado.
             pr_vlprerpp,      -- Valor da prestacao da poupanca programada.
             0,                -- Indicador de debito.
             pr_dtmvtolt,      -- Data do movimento atual.
             pr_cdprodut,      -- Código do produto CRAPCPC
             pr_dsfinali,      -- Finalidade do fundo (proveniente da tela)
             pr_flgteimo,      -- Teimosinha (0 = Não / 1 = Sim)
             pr_flgdbpar       -- Débito Parcial (0 = Não / 1 = Sim)
             )
             Returning rowid into pr_rpprowid;
        Exception
          When Others Then
            pr_dscritic := 'Erro insercao craprpp';
            raise vr_exc_erro_rb;
        End;

        pr_nrctrrpp:=vr_nrseqted;
        vr_saldo := 0;
        -- Criar Saldo da Aplicação
        Begin
           Insert into crapspp   
             (cdcooper,          -- Codigo que identifica a Cooperativa.
              nrdconta,          -- Numero da conta/dv do associado.
              nrctrrpp,          -- Numero da poupanca programada.
              dtsldrpp,          -- Data do saldo da poupanca programada.
              vlsldrpp,          -- Saldo da poupanca programada.
              dtmvtolt)          -- Data do movimento.
            Values
             (pr_cdcooper,       -- Codigo que identifica a Cooperativa.
              pr_nrdconta,       -- Numero da conta/dv do associado.
              vr_nrseqted,       -- Numero da poupanca programada.
              pr_dtinirpp,       -- Data do saldo da poupanca programada.
              vr_saldo,          -- Saldo da poupanca programada.
              pr_dtmvtolt        -- Data do movimento.
              );
        Exception
            When Others Then
              pr_dscritic := 'Erro atualizacao CRAPSPP';
              raise vr_exc_erro_rb;
        End;
        -- Se for necessário gerar log
        If  pr_flgerlog = 1 Then
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => ''
                              ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
                              ,pr_dstransa => 'Inclusao de Aplicacao Programada'
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 1 --> TRUE
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => pr_rpprowid);

          gene0001.pc_gera_log_item(pr_nrdrowid => pr_rpprowid
                                     ,pr_nmdcampo => 'NRAPLICA'
                                     ,pr_dsdadant => ''
                                     ,pr_dsdadatu => pr_nraplica);

          gene0001.pc_gera_log_item(pr_nrdrowid => pr_rpprowid
                                   ,pr_nmdcampo => 'NRDOCMTO'
                                   ,pr_dsdadant => ''
                                   ,pr_dsdadatu => pr_nraplica);

          gene0001.pc_gera_log_item(pr_nrdrowid => pr_rpprowid
                                   ,pr_nmdcampo => 'DTRESGAT'
                                   ,pr_dsdadant => ''
                                   ,pr_dsdadatu => TO_CHAR(pr_dtvctopp,'dd/MM/RRRR'));

        End If;
       Commit;  
      Exception
        When vr_exc_erro_nrb Then
          pr_rpprowid:= null;
        When vr_exc_erro_rb Then
          pr_rpprowid:= null;
          Rollback to RAC_savepoint;
        When Others Then
          pr_rpprowid:= null;
      End;
    End;
  
  END pc_incluir_apl_prog;
 
  PROCEDURE pc_incluir_apl_prog_web (pr_nrdconta IN craprpp.nrdconta%TYPE  --> Número da conta
                                    ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequêncial do titular   
                                    ,pr_cdprodut IN crapcpc.cdprodut%TYPE  --> Código do Produto de Captação
                                    ,pr_dtmvtolt IN VARCHAR2               --> Data do movimento atual - DD/MM/YYYY
                                    ,pr_qtdiacar IN crapmpc.qtdiacar%TYPE  --> Carência em dias (Tela)
                                    ,pr_qtdiaprz IN crapmpc.qtdiaprz%TYPE  --> Prazo de vencimento em dias (Tela)
                                    ,pr_dtinirpp IN VARCHAR2               --> Data de Inicío da Aplicação Programada - DD/MM/YYYY
                                    ,pr_dtvctopp IN VARCHAR2               --> Data de vencimento - DD/MM/YYYY (Tela)
                                    ,pr_vlprerpp IN craprpp.vlprerpp%TYPE  --> Valor da parcela
                                    ,pr_tpemiext IN craprpp.tpemiext%TYPE  --> Tipo de impressao do extrato (1-individual,2-todas,3-nao emit).
                                    ,pr_flgerlog IN INTEGER                --> Gerar log (0 = Não / 1 = Sim)
                                    ,pr_dsfinali IN craprpp.dsfinali%TYPE  --> Finalidade do fundo (proveniente da tela)
                                    ,pr_flgteimo IN INTEGER                --> Teimosinha (0 = Não / 1 = Sim)
                                    ,pr_flgdbpar IN INTEGER                --> Débito Parcial (0 = Não / 1 = Sim)
                                    ,pr_xmllog   IN VARCHAR2               --> XML com informacoes de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2)             --> Erros do processo
   IS
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_incluir_apl_prog_web
    --  Sistema  : Captação (Aplicação Programada)
    --  Sigla    : CRED
    --  Autor    : CIS Corporate
    --  Data     : Julho/2018.                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: ----
    -- Objetivo  : Insere novo plano aplicação programada 
    --
    -- Alteracoes:
    -- 
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
    
      -- Variaveis auxiliares
      vr_exc_erro EXCEPTION;

      -- Variaveis de entrada
      vr_dtmvtolt Date := TO_DATE(pr_dtmvtolt,'DD/MM/YYYY');  
      vr_dtinirpp Date := TO_DATE (pr_dtinirpp,'DD/MM/YYYY'); 
      vr_dtvctopp Date := TO_DATE(pr_dtvctopp,'DD/MM/YYYY');  

      -- Variaveis de retorno
      vr_nrctrrpp craprpp.nrctrrpp%TYPE;
      vr_nraplica craprac.nraplica%TYPE;
      vr_rpprowid ROWID;

      -- Variaveis de log
      vr_cdcooper crapcop.cdcooper%TYPE;
      vr_cdoperad VARCHAR2(100);
      vr_nmdatela VARCHAR2(100);
      vr_nmeacao  VARCHAR2(100);
      vr_cdagenci VARCHAR2(100);
      vr_nrdcaixa VARCHAR2(100);
      vr_idorigem VARCHAR2(100);

      -- Variaveis de XML 
      vr_xml_temp VARCHAR2(32767);
      vr_clobxmlc CLOB;
    
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

      
      -- Efetua a inclusão da Aplicação Programada
      apli0008.pc_incluir_apl_prog(pr_cdcooper => vr_cdcooper,
                                   pr_cdagenci => vr_cdagenci,
                                   pr_nrdcaixa => vr_nrdcaixa,
                                   pr_cdoperad => vr_cdoperad,
                                   pr_nmdatela => vr_nmdatela,
                                   pr_idorigem => vr_idorigem,
                                   pr_nrdconta => pr_nrdconta,
                                   pr_idseqttl => pr_idseqttl,
                                   pr_dtmvtolt => vr_dtmvtolt,
                                   pr_cdprodut => pr_cdprodut,
                                   pr_dtinirpp => vr_dtinirpp,
                                   pr_dtvctopp => vr_dtvctopp,
                                   pr_qtdiacar => pr_qtdiacar,
                                   pr_qtdiaprz => pr_qtdiaprz,
                                   pr_vlprerpp => pr_vlprerpp,
                                   pr_tpemiext => pr_tpemiext,
                                   pr_flgerlog => pr_flgerlog,
                                   pr_dsfinali => pr_dsfinali,
                                   pr_flgteimo => pr_flgteimo,
                                   pr_flgdbpar => pr_flgdbpar,
                                   pr_nrctrrpp => vr_nrctrrpp,
                                   pr_nraplica => vr_nraplica,
                                   pr_rpprowid => vr_rpprowid,
                                   pr_cdcritic => vr_cdcritic,
                                   pr_dscritic => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;     
      -- Criar cabeçalho do XML
      dbms_lob.createtemporary(vr_clobxmlc, TRUE); 
      dbms_lob.open(vr_clobxmlc, dbms_lob.lob_readwrite);
      -- Insere o cabeçalho do XML 
      gene0002.pc_escreve_xml(pr_xml            => vr_clobxmlc 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1" ?><Dados>');

      gene0002.pc_escreve_xml(pr_xml            => vr_clobxmlc
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => 
          '<inf>
           <nrctrrpp>' || TO_CHAR(vr_nrctrrpp) || '</nrctrrpp>
           <nraplica>' || TO_CHAR(vr_nraplica) || '</nraplica>
           <rpprowid>' || vr_rpprowid || '</rpprowid>
           </inf>');

      -- Encerrar a tag raiz 
      gene0002.pc_escreve_xml(pr_xml            => vr_clobxmlc 
                             ,pr_texto_completo => vr_xml_temp 
                             ,pr_texto_novo     => '</Dados>' 
                             ,pr_fecha_xml      => TRUE);

      pr_retxml := XMLType.createXML(vr_clobxmlc);
    
    Exception
      When vr_exc_erro Then
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);
			  pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        
      When others Then
        pr_cdcritic := null; -- não será utilizado
        pr_dscritic := 'Erro geral em APLI0008.pc_incluir_apl_prog_web: '||SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
      
    END;
  END pc_incluir_apl_prog_web;
 
  PROCEDURE pc_calc_saldo_apl_prog (pr_cdcooper IN crapcop.cdcooper%TYPE     --> Cooperativa
                                   ,pr_cdprogra IN crapres.cdprogra%TYPE     --> Programa que esta executando
                                   ,pr_cdoperad IN craplrg.cdoperad%TYPE     --> Codigo do Operador
                                   ,pr_nrdconta IN craprpp.nrdconta%TYPE     --> Numero da conta da aplicacao
                                   ,pr_idseqttl IN INTEGER                   --> Identificador Sequencial
                                   ,pr_idorigem IN INTEGER                   --> Identificador da Origem
                                   ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE     --> Numero do contrato poupanca
                                   ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE     --> Data do movimento atual
                                   ,pr_vlsdrdpp IN OUT craprpp.vlsdrdpp%TYPE --> Valor do saldo da poupanca programada
                                   ,pr_des_erro OUT VARCHAR2) IS             --> Saida com erros;
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_calc_saldo_apl_prog
  --  Sistema  : Captação (Aplicação Programada)
  --  Sigla    : CRED
  --  Autor    : CIS Corporate
  --  Data     : Julho/2018.                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: ----
  -- Objetivo  : Procedure para calcular o saldo de uma aplicacao programada a partir da RPP
  --             Ela é invocada a partir de outras procs. então não revalida cooperativa, cooperado, etc.
  -- Alteracoes:
  -- 
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      --Selecionar os fundos a partir do numero de contrato de apl. programada
      CURSOR cr_craprac (pr_cdcooper IN crapspp.cdcooper%TYPE
                        ,pr_nrdconta IN crapspp.nrdconta%TYPE
                        ,pr_nrctrrpp IN crapspp.nrctrrpp%TYPE) IS
        SELECT nraplica, cdprodut
          FROM craprac
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctrrpp = pr_nrctrrpp;

      rw_craprac cr_craprac%ROWTYPE;
      
      -- Variaveis
      vr_vlsdappr NUMBER(25,8);
      vr_vlrgappr NUMBER(25,8);

      -- Variaveis de retorno de erro
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(4000);
      vr_exc_erro  EXCEPTION; -- Com rollback

    
    BEGIN
      vr_vlsdappr := 0;
      vr_vlrgappr := 0;
      OPEN cr_craprac (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrctrrpp => pr_nrctrrpp);
      LOOP
        FETCH cr_craprac
          INTO rw_craprac;
          EXIT WHEN cr_craprac%NOTFOUND;

          BEGIN 
            apli0005.pc_busca_saldo_aplic_prog (pr_cdcooper => pr_cdcooper
                                               ,pr_cdoperad => pr_cdoperad
                                               ,pr_nmdatela => pr_cdprogra
                                               ,pr_idorigem => pr_idorigem
                                               ,pr_nrdconta => pr_nrdconta
                                               ,pr_idseqttl => pr_idseqttl
                                               ,pr_dtmvtolt => pr_dtmvtolt
                                               ,pr_nraplica => rw_craprac.nraplica 
                                               ,pr_cdprodut => rw_craprac.cdprodut
                                               ,pr_idblqrgt => 1                   -- Todas
                                               ,pr_idgerlog => 0                   -- Nao gerar log
                                               ,pr_vlsldtot => vr_vlsdappr         -- Saldo total
                                               ,pr_vlsldrgt => vr_vlrgappr         -- Saldo total para resgate
                                               ,pr_cdcritic => vr_cdcritic
                                               ,pr_dscritic => pr_des_erro);

            pr_vlsdrdpp := pr_vlsdrdpp + vr_vlrgappr;
            IF pr_des_erro is not null THEN
               EXIT;
            END IF;
          END;
        END LOOP;
      CLOSE cr_craprac;
    END;
  END pc_calc_saldo_apl_prog;
  
  PROCEDURE pc_calc_saldo_apl_prog_web (pr_nrdconta IN craprac.nrdconta%TYPE   -- Número da Conta
                                       ,pr_idseqttl IN crapttl.idseqttl%TYPE   -- Titular da Conta
                                       ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE   -- Número da Aplicação Programada.
                                       ,pr_dtmvtolt IN VARCHAR2                -- Data de Movimento Inicial
                                       ,pr_xmllog   IN VARCHAR2                -- XML com informacoes de LOG
                                       ,pr_cdcritic OUT PLS_INTEGER            -- Código da crítica
                                       ,pr_dscritic OUT VARCHAR2               -- Descrição da crítica
                                       ,pr_retxml   IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                                       ,pr_nmdcampo OUT VARCHAR2               -- Nome do campo com erro
                                       ,pr_des_erro OUT VARCHAR2)              -- Erros do processo

  IS
  BEGIN
   /* .............................................................................

   Programa: pc_calc_saldo_apl_prog_web
   Sistema : Novos Produtos de Captação - Aplicação Programada
   Sigla   : APLI
   Autor   : CIS Corporate
   Data    : Julho/2018.                    Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Procedure para calcular o saldo de uma aplicacao programada a partir da RPP - Mensageria. 

   Observacao: -----

   Alteracoes: 
  ..............................................................................*/                

  DECLARE
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    
    -- Variaveis auxiliares
    vr_exc_erro EXCEPTION;

    -- Variaveis de entrada
    vr_dtmvtolt Date := TO_DATE(pr_dtmvtolt,'dd/mm/yyyy');  

    -- Variaveis de retorno
    
    vr_vlsdrdpp NUMBER (15,2) := 0;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Variaveis de XML 
    vr_xml_temp VARCHAR2(32767);
    vr_clobxmlc CLOB;
    
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

    -- Busca as informações da apl. programada
    pc_calc_saldo_apl_prog (pr_cdcooper => vr_cdcooper
                           ,pr_cdprogra => vr_nmdatela
                           ,pr_cdoperad => vr_cdoperad
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_idseqttl => pr_idseqttl
                           ,pr_idorigem => vr_idorigem
                           ,pr_nrctrrpp => pr_nrctrrpp
                           ,pr_dtmvtolt => vr_dtmvtolt
                           ,pr_vlsdrdpp => vr_vlsdrdpp
                           ,pr_des_erro => vr_dscritic);

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;     
    -- Criar cabeçalho do XML
    dbms_lob.createtemporary(vr_clobxmlc, TRUE); 
    dbms_lob.open(vr_clobxmlc, dbms_lob.lob_readwrite);
    -- Insere o cabeçalho do XML 
    gene0002.pc_escreve_xml (pr_xml            => vr_clobxmlc 
                            ,pr_texto_completo => vr_xml_temp 
                            ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>');
     gene0002.pc_escreve_xml(pr_xml            => vr_clobxmlc
                           ,pr_texto_completo => vr_xml_temp 
                           ,pr_texto_novo     => 
                           '<Registro>'||
                           '<vlsdrdpp>'||vr_vlsdrdpp||'</vlsdrdpp>'||
                           '</Registro>'
                           );
    -- Encerrar a tag raiz 
    gene0002.pc_escreve_xml(pr_xml            => vr_clobxmlc 
                            ,pr_texto_completo => vr_xml_temp 
                            ,pr_texto_novo     => '</Dados></Root>' 
                            ,pr_fecha_xml      => TRUE);
                                  
    pr_retxml := XMLType.createXML(vr_clobxmlc);

  Exception
    When vr_exc_erro Then
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        
    When others Then
      pr_cdcritic := null; -- não será utilizado
      pr_dscritic := 'Erro geral em APLI0008.pc_calc_saldo_apl_prog_web: '||SQLERRM;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
      
  END;

  END pc_calc_saldo_apl_prog_web;
  
  PROCEDURE pc_calc_saldo_ini_apl_prog (pr_cdcooper IN craprac.cdcooper%TYPE                  -- Código da Cooperativa
                                       ,pr_cdoperad IN crapope.cdoperad%TYPE                  -- Código do Operador 
                                       ,pr_nmdatela IN craptel.nmdatela%TYPE                  -- Nome da Tela
                                       ,pr_idorigem IN NUMBER                                 -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA                  
                                       ,pr_nrdconta IN craprac.nrdconta%TYPE                  -- Número da Conta
                                       ,pr_idseqttl IN crapttl.idseqttl%TYPE                  -- Titular da Conta
                                       ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE                  -- Número da Aplicação Programada.
                                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE                  -- Data de Movimento 
                                       ,pr_idgerlog IN NUMBER                                 -- Identificador de Log (Fixo na chamada, 0 – Não / 1 – Sim)
                                       ,pr_vlsdrdpp OUT NUMBER                                -- Saldo em pr_dtmvtolt-1
                                       ,pr_vlresgat OUT NUMBER                                -- Valor de resgate
                                       ,pr_vlrendim OUT NUMBER                                -- Valor de rendimento
                                       ,pr_vldoirrf OUT NUMBER                                -- Valor do IRRF 
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE                 -- Código da crítica
                                       ,pr_dscritic OUT crapcri.dscritic%TYPE                 -- Descrição da crítica
   ) IS
    BEGIN
     /* .............................................................................

     Programa: pc_calc_saldo_ini_apl_prog
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : CIS Corporate
     Data    : Julho/2018.                    Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Calcular o saldo inicial a partir da data da compra, passando por todos os lançamentos

     Observacao: -----

     Alteracoes: 
    ..............................................................................*/                
      
      DECLARE
        
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
            
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;      
            
      -- Variáveis retornadas da procedure IMUT0001.pc_verifica_periodo_imune
      vr_flgimune BOOLEAN;
      vr_dtinicio DATE;
      vr_dttermin DATE;
      vr_dsreturn VARCHAR2(3);
      vr_tab_erro GENE0001.typ_tab_erro;
            
      --Variáveis locais
      vr_dstransa VARCHAR2(100) := 'Busca saldo inicial da aplicacao programada contrato #: ' || pr_nrctrrpp;
      vr_dsorigem VARCHAR2(100) := gene0001.vr_vet_des_origens(pr_idorigem);
      vr_nrdrowid ROWID;
      vr_vlresgat NUMBER :=0;
      vr_vlrendim NUMBER :=0;
      vr_vldoirrf NUMBER :=0;
      vr_vlsldtot NUMBER :=0;
      vr_qtdiasir PLS_INTEGER := 0; -- Qtd de dias para calculo de faixa de IR
      vr_percirrf NUMBER;
      vr_txlancto NUMBER;
      vr_txacumul NUMBER;
      vr_txacumes NUMBER;
      
        
      -- Busca Aplicações de captação com seus lançamentos
      CURSOR cr_craplac IS
          SELECT 
                 lac.nraplica,
                 rac.dtmvtolt dtmvtolt_rac,
                 lac.dtmvtolt dtmvtolt_lac,
                 rac.txaplica,
                 rac.qtdiacar,
                 cpc.idtippro,            
                 cpc.idtxfixa,
                 cpc.cddindex,
                 cpc.cdhsraap, 
                 cpc.cdhsnrap,
                 cpc.cdhsprap,
                 cpc.cdhsrvap,
                 cpc.cdhsrdap, 
                 cpc.cdhsirap,
                 cpc.cdhsrgap,
                 cpc.cdhsvtap,
                 lac.vllanmto,
                 lac.cdhistor
            FROM craprac rac, craplac lac, crapcpc cpc
           WHERE rac.cdcooper = pr_cdcooper
             AND rac.nrdconta = pr_nrdconta
             AND rac.nrctrrpp = pr_nrctrrpp
             AND rac.cdprodut = cpc.cdprodut
             AND rac.cdcooper = lac.cdcooper
             AND rac.nrdconta = lac.nrdconta
             AND rac.nraplica = lac.nraplica
             AND lac.dtmvtolt <= (pr_dtmvtolt - 1)
           ORDER BY lac.dtmvtolt, lac.cdhistor;
      
      rw_craplac cr_craplac%ROWTYPE;
       
      -- Buscar histórico de lançamento das aplicações
      CURSOR cr_craphis(pr_cdcooper IN craphis.cdcooper%TYPE
                       ,pr_cdhistor IN craphis.cdhistor%TYPE) IS
          SELECT his.indebcre,
                 his.dshistor,
                 his.dsextrat,
                 his.cdhistor
            FROM craphis his
           WHERE his.cdcooper = pr_cdcooper
             AND his.cdhistor = pr_cdhistor;
            
       rw_craphis cr_craphis%ROWTYPE;

       BEGIN -- Principal
           -- Carregada as faixas de IR para uso posterior             
           apli0001.pc_busca_faixa_ir_rdc(pr_cdcooper => pr_cdcooper);

           -- Para cada registro de lançamento de aplicação de captação                                                                    
           FOR rw_craplac IN cr_craplac LOOP
                IF rw_craplac.idtippro = 1 THEN -- Pré-fixada
                    -- Buscar as taxas acumuladas da aplicação
                    apli0006.pc_taxa_acumul_aplic_pre(pr_cdcooper => pr_cdcooper,              --> Código da Cooperativa
                                                      pr_txaplica => rw_craplac.txaplica,      --> Taxa da Aplicação
                                                      pr_idtxfixa => rw_craplac.idtxfixa,      --> Taxa Fixa (1-SIM/2-NAO)
                                                      pr_cddindex => rw_craplac.cddindex,      --> Código do Indexador
                                                      pr_dtinical => rw_craplac.dtmvtolt_rac,  --> Data Inicial Cálculo
                                                      pr_dtfimcal => pr_dtmvtolt,              --> Data Final Cálculo 
                                                      pr_txacumul => vr_txacumul,              --> Taxa acumulada durante o período total da aplicação
                                                      pr_txacumes => vr_txacumes,              --> Taxa acumulada durante o mês vigente
                                                      pr_cdcritic => vr_cdcritic,              --> Código da crítica
                                                      pr_dscritic => vr_dscritic);             --> Descrição da crítica
                ELSIF rw_craplac.idtippro = 2 THEN -- Pós-fixada
                    -- Buscar as taxas acumuladas da aplicação
                    apli0006.pc_taxa_acumul_aplic_pos(pr_cdcooper => pr_cdcooper,              --> Código da Cooperativa
                                                      pr_txaplica => rw_craplac.txaplica,      --> Taxa da Aplicação
                                                      pr_idtxfixa => rw_craplac.idtxfixa,      --> Taxa Fixa (1-SIM/2-NAO)
                                                      pr_cddindex => rw_craplac.cddindex,      --> Código do Indexador
                                                      pr_dtinical => rw_craplac.dtmvtolt_rac,  --> Data Inicial Cálculo 
                                                      pr_dtfimcal => pr_dtmvtolt,              --> Data Final Cálculo 
                                                      pr_txacumul => vr_txacumul,              --> Taxa acumulada durante o período total da aplicação
                                                      pr_txacumes => vr_txacumes,              --> Taxa acumulada durante o mês vigente
                                                      pr_cdcritic => vr_cdcritic,              --> Código da crítica
                                                      pr_dscritic => vr_dscritic);             --> Descrição da crítica
                END IF;
                IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                   RAISE vr_exc_saida;
                END IF;                                   
                IMUT0001.pc_verifica_periodo_imune (pr_cdcooper  => pr_cdcooper   --> Codigo Cooperativa
                                                   ,pr_nrdconta  => pr_nrdconta   --> Numero da Conta
                                                   ,pr_flgimune  => vr_flgimune   --> Identificador se é imune
                                                   ,pr_dtinicio  => vr_dtinicio   --> Data de inicio da imunidade
                                                   ,pr_dttermin  => vr_dttermin   --> Data termino da imunidade
                                                   ,pr_dsreturn  => vr_dsreturn   --> Descricao retorno(NOK/OK)
                                                   ,pr_tab_erro  => vr_tab_erro); --> Tabela erros
                                                                                        
                IF vr_dsreturn = 'NOK' THEN
                    --Se tem erro na tabela 
                    IF vr_tab_erro.count > 0 THEN
                       vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                       vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                    ELSE
                       vr_cdcritic:= 0;
                       vr_dscritic:= 'Erro ao executar IMUT0001.pc_verifica_periodo_imune. Cooperativa: '||pr_cdcooper||' Conta: '||pr_nrdconta;  
                    END IF;  
                    --Levantar Excecao
                    RAISE vr_exc_saida;
                END IF;
                -- Verifica a quantidade de dias para saber o IR 
                vr_qtdiasir := pr_dtmvtolt - rw_craplac.dtmvtolt_rac;
                -- Consulta faixas de IR
                FOR i IN REVERSE apli0001.vr_faixa_ir_rdc.first .. apli0001.vr_faixa_ir_rdc.last LOOP
                    IF vr_qtdiasir > apli0001.vr_faixa_ir_rdc(i).qtdiatab THEN
                        vr_percirrf := apli0001.vr_faixa_ir_rdc(i).perirtab;
                    END IF;
                END LOOP;
                -- Se não possuir IRRF
                IF (vr_percirrf IS NULL OR vr_percirrf = 0) THEN
                    -- Atribuir primeira faixa de irrf
                    vr_percirrf := apli0001.vr_faixa_ir_rdc(1).perirtab;
                END IF;                                                                                

                -- Verificar se o histórico de lançamento está cadastrado na tabela craphis
                OPEN cr_craphis (pr_cdcooper => pr_cdcooper
                                ,pr_cdhistor => rw_craplac.cdhistor);
                FETCH cr_craphis INTO rw_craphis;

                IF cr_craphis%NOTFOUND THEN
                    vr_cdcritic := 526; -- Histórico não encontrado
                    CLOSE cr_craphis;
                    RAISE vr_exc_saida;
                END IF;
                CLOSE cr_craphis;
                        
                -- Verifica a quantidade de dias para saber o IR 
                vr_qtdiasir := rw_craplac.dtmvtolt_lac - rw_craplac.dtmvtolt_rac;
                  
                -- Consulta faixas de IR
                FOR i IN REVERSE apli0001.vr_faixa_ir_rdc.first .. apli0001.vr_faixa_ir_rdc.last LOOP
                  IF vr_qtdiasir > apli0001.vr_faixa_ir_rdc(i).qtdiatab THEN
                    vr_percirrf := apli0001.vr_faixa_ir_rdc(i).perirtab;
                  END IF;
                END LOOP;
                -- Se não possuir IRRF
                IF (vr_percirrf IS NULL OR vr_percirrf = 0) THEN
                  -- Atribuir primeira faixa de irrf
                  vr_percirrf := apli0001.vr_faixa_ir_rdc(1).perirtab;
                END IF;
                IF rw_craplac.cdhistor = rw_craplac.cdhsrgap THEN    /* Resgate */
                     vr_vlresgat := NVL(vr_vlresgat,0) + rw_craplac.vllanmto;
                ELSIF rw_craplac.cdhistor = rw_craplac.cdhsprap THEN /* Rendimento */
                     vr_vlrendim := NVL(vr_vlrendim,0) + rw_craplac.vllanmto;
                ELSIF rw_craplac.cdhistor = rw_craplac.cdhsirap THEN /* IRRF */
                     vr_vldoirrf := NVL(vr_vldoirrf,0) + rw_craplac.vllanmto;
                END IF;
                IF rw_craphis.indebcre = 'C' THEN     /* Crédito */
                     vr_vlsldtot := NVL(vr_vlsldtot,0) + rw_craplac.vllanmto;
                ELSIF rw_craphis.indebcre = 'D' THEN  /* Débito  */
                     vr_vlsldtot := NVL(vr_vlsldtot,0) - rw_craplac.vllanmto;
                ELSE
                     vr_cdcritic := 0;
                     vr_dscritic := 'Tipo de lancamento invalido';
                     RAISE vr_exc_saida;
                END IF;
                -- Atribui a descrição do histórico e extrato para as variáveis
                IF vr_flgimune = TRUE AND vr_dttermin IS NULL THEN --Se o cooperado ainda está imune, utiliza a data de movimento */
                   vr_dttermin := pr_dtmvtolt;
                END IF;                

                IF rw_craplac.cdhistor = rw_craplac.cdhsrdap THEN /* Rendimento */
                     vr_txlancto := rw_craplac.txaplica;
                ELSIF rw_craplac.cdhistor = rw_craplac.cdhsirap THEN /* IRRF */                     
                     vr_txlancto := vr_percirrf;
                ELSE /* Demais lançamentos */
                     vr_txlancto := 0; 
                END IF;
           END LOOP; -- CRAPLAC
           -- Alimenta parâmetros
           pr_vlsdrdpp := vr_vlsldtot;
           pr_vlresgat := vr_vlresgat;
           pr_vlrendim := vr_vlrendim;
           pr_vldoirrf := vr_vldoirrf;
        
            -- Gerar log
            IF pr_idgerlog = 1 THEN
               GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                   ,pr_cdoperad => pr_cdoperad
                                   ,pr_dscritic => ''
                                   ,pr_dsorigem => vr_dsorigem
                                   ,pr_dstransa => vr_dstransa
                                   ,pr_dttransa => TRUNC(SYSDATE)
                                   ,pr_flgtrans => 0 --> FALSE
                                   ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                                   ,pr_idseqttl => pr_idseqttl
                                   ,pr_nmdatela => pr_nmdatela
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrdrowid => vr_nrdrowid);
               COMMIT;
            END IF;
          
          EXCEPTION
            WHEN vr_exc_saida THEN
                 IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
                    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
                 END IF;
                 -- Alimenta parametros com a crítica ocorrida
                 pr_cdcritic := vr_cdcritic;
                 pr_dscritic := vr_dscritic;
                 ROLLBACK;

                 -- Verifica se deve gerar log
                 IF pr_idgerlog = 1 THEN
                    GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                        ,pr_cdoperad => pr_cdoperad
                                        ,pr_dscritic => vr_dscritic
                                        ,pr_dsorigem => vr_dsorigem
                                        ,pr_dstransa => vr_dstransa
                                        ,pr_dttransa => TRUNC(SYSDATE)
                                        ,pr_flgtrans => 0 --> FALSE
                                        ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                                        ,pr_idseqttl => pr_idseqttl
                                        ,pr_nmdatela => pr_nmdatela
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_nrdrowid => vr_nrdrowid);
                    COMMIT;
                 END IF;
            WHEN OTHERS THEN
                 pr_cdcritic := vr_cdcritic;
                 pr_dscritic := 'Erro nao tratado APLI0008.pc_cal_saldo_ini_apl_prog: ' || SQLERRM;
                 ROLLBACK; 
                 -- Verifica se deve gerar log
                 IF pr_idgerlog = 1 THEN
                    GENE0001.pc_gera_log (pr_cdcooper => pr_cdcooper
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_dscritic => vr_dscritic
                                         ,pr_dsorigem => vr_dsorigem
                                         ,pr_dstransa => vr_dstransa
                                         ,pr_dttransa => TRUNC(SYSDATE)
                                         ,pr_flgtrans => 0 --> FALSE
                                         ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                                         ,pr_idseqttl => pr_idseqttl
                                         ,pr_nmdatela => pr_nmdatela
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_nrdrowid => vr_nrdrowid);
                    COMMIT;
               END IF; 
       END; -- Principal
  END pc_calc_saldo_ini_apl_prog;
   
  PROCEDURE pc_buscar_extrato_apl_prog (pr_cdcooper IN craprac.cdcooper%TYPE                  -- Código da Cooperativa
                                       ,pr_cdoperad IN crapope.cdoperad%TYPE                  -- Código do Operador 
                                       ,pr_nmdatela IN craptel.nmdatela%TYPE                  -- Nome da Tela
                                       ,pr_idorigem IN NUMBER                                 -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA                  
                                       ,pr_nrdconta IN craprac.nrdconta%TYPE                  -- Número da Conta
                                       ,pr_idseqttl IN crapttl.idseqttl%TYPE                  -- Titular da Conta
                                       ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE                  -- Número da Aplicação Programada.
                                       ,pr_dtmvtolt_ini IN crapdat.dtmvtolt%TYPE              -- Data de Movimento - Inicio
                                       ,pr_dtmvtolt_fim IN crapdat.dtmvtolt%TYPE              -- Data de Movimento - Fim
                                       ,pr_idlstdhs IN NUMBER                                 -- Identificador de Listagem de Todos Históricos (Fixo na chamada, 0 – Não / 1 – Sim)
                                       ,pr_idgerlog IN NUMBER                                 -- Identificador de Log (Fixo na chamada, 0 – Não / 1 – Sim)
                                       ,pr_tab_extrato OUT apli0008.typ_tab_extrato_apl_prog  -- PLTable com os dados de extrato
                                       ,pr_vlresgat OUT NUMBER                                -- Valor de resgate
                                       ,pr_vlrendim OUT NUMBER                                -- Valor de rendimento
                                       ,pr_vldoirrf OUT NUMBER                                -- Valor do IRRF 
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE                 -- Código da crítica
                                       ,pr_dscritic OUT crapcri.dscritic%TYPE                 -- Descrição da crítica
   ) IS
    BEGIN
     /* .............................................................................

     Programa: pc_buscar_extrato_apl_prog
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : CIS Corporate
     Data    : Julho/2018.                    Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a busca de extratos das aplicações programadas de forma consolidada.
                 Utilizada na ATENDA
                 Derivada de apli0005.pc_busca_extrato_aplicacao

     Observacao: -----

     Alteracoes: 
    ..............................................................................*/                
      
      DECLARE
        
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
            
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;      
            
      -- Variáveis retornadas da procedure IMUT0001.pc_verifica_periodo_imune
      vr_flgimune BOOLEAN;
      vr_dtinicio DATE;
      vr_dttermin DATE;
      vr_dsreturn VARCHAR2(3);
      vr_tab_erro GENE0001.typ_tab_erro;
            
      --Variáveis locais
      vr_dstransa VARCHAR2(100) := 'Busca extrato da aplicacao programada contrato #: ' || pr_nrctrrpp;
      vr_dsorigem VARCHAR2(100) := gene0001.vr_vet_des_origens(pr_idorigem);
      vr_nrdrowid ROWID;
      vr_lshistor VARCHAR2(200);            
      vr_vlresgat NUMBER;
      vr_vlresgat_calc NUMBER;
      vr_vlrendim NUMBER;
      vr_vldoirrf NUMBER;
      vr_vlsldtot NUMBER := 0;
      vr_dshistor craphis.dshistor%TYPE;
      vr_dsextrat craphis.dsextrat%TYPE;
      vr_qtdiasir PLS_INTEGER := 0; -- Qtd de dias para calculo de faixa de IR
      vr_percirrf NUMBER;
      vr_txlancto NUMBER;
      vr_txacumul NUMBER;
      vr_txacumes NUMBER;
      
      vr_saldo_imp PLS_INTEGER := 0;   -- Saldo anterior impresso?
      vr_vlsdrdpp_ant NUMBER := 0;     -- Valor Saldo anterior
      
      -- PLTable que conterá os dados do extrato
      vr_tab_extrato_temp apli0008.typ_tab_extrato_apl_prog;
      vr_tab_extrato apli0008.typ_tab_extrato_apl_prog;
      vr_ind_extrato PLS_INTEGER := 0;
        
      -- Busca Aplicações de captação com seus lançamentos
      CURSOR cr_craplac (pr_cdcooper IN craprac.cdcooper%TYPE,
                         pr_nrdconta IN craprac.nrdconta%TYPE,
                         pr_nrctrrpp IN craprac.nrctrrpp%TYPE) IS
          SELECT 
                 lac.nraplica,
                 rac.dtmvtolt dtmvtolt_rac,
                 lac.dtmvtolt dtmvtolt_lac,
                 lac.nrdolote,
                 lac.cdbccxlt,
                 rac.txaplica,
                 rac.qtdiacar,
                 cpc.idtippro,            
                 cpc.idtxfixa,
                 cpc.cddindex,
                 cpc.cdhsraap, 
                 cpc.cdhsnrap,
                 cpc.cdhsprap,
                 cpc.cdhsrvap,
                 cpc.cdhsrdap, 
                 cpc.cdhsirap,
                 cpc.cdhsrgap,
                 cpc.cdhsvtap,
                 lac.vllanmto,
                 lac.cdhistor,
                 lac.cdagenci,
                 lac.nrdocmto
            FROM craprac rac, craplac lac, crapcpc cpc
           WHERE rac.cdcooper = pr_cdcooper
             AND rac.nrdconta = pr_nrdconta
             AND rac.nrctrrpp = pr_nrctrrpp
             AND rac.cdprodut = cpc.cdprodut
             AND rac.cdcooper = lac.cdcooper
             AND rac.nrdconta = lac.nrdconta
             AND rac.nraplica = lac.nraplica
             AND lac.dtmvtolt <= pr_dtmvtolt_fim
           ORDER BY lac.dtmvtolt, lac.cdhistor;
      
      rw_craplac cr_craplac%ROWTYPE;
       
      -- Buscar histórico de lançamento das aplicações
      CURSOR cr_craphis(pr_cdcooper IN craphis.cdcooper%TYPE
                       ,pr_cdhistor IN craphis.cdhistor%TYPE) IS
          SELECT his.indebcre,
                 his.dshistor,
                 his.dsextrat,
                 his.cdhistor
            FROM craphis his
           WHERE his.cdcooper = pr_cdcooper
             AND his.cdhistor = pr_cdhistor;
            
       rw_craphis cr_craphis%ROWTYPE;

       BEGIN -- Principal
           -- Carregada as faixas de IR para uso posterior             
           apli0001.pc_busca_faixa_ir_rdc(pr_cdcooper => pr_cdcooper);

           -- Para cada registro de lançamento de aplicação de captação                                                                    
           FOR rw_craplac IN cr_craplac (pr_cdcooper => pr_cdcooper        --> Cooperativa
                                         ,pr_nrdconta => pr_nrdconta       --> Nr. da conta
                                         ,pr_nrctrrpp => pr_nrctrrpp)      --> Nr. do contrato (RPP)
           LOOP
                IF rw_craplac.idtippro = 1 THEN -- Pré-fixada
                    -- Buscar as taxas acumuladas da aplicação
                    apli0006.pc_taxa_acumul_aplic_pre(pr_cdcooper => pr_cdcooper,              --> Código da Cooperativa
                                                      pr_txaplica => rw_craplac.txaplica,      --> Taxa da Aplicação
                                                      pr_idtxfixa => rw_craplac.idtxfixa,      --> Taxa Fixa (1-SIM/2-NAO)
                                                      pr_cddindex => rw_craplac.cddindex,      --> Código do Indexador
                                                      pr_dtinical => rw_craplac.dtmvtolt_rac,  --> Data Inicial Cálculo
                                                      pr_dtfimcal => pr_dtmvtolt_fim,          --> Data Final Cálculo 
                                                      pr_txacumul => vr_txacumul,              --> Taxa acumulada durante o período total da aplicação
                                                      pr_txacumes => vr_txacumes,              --> Taxa acumulada durante o mês vigente
                                                      pr_cdcritic => vr_cdcritic,              --> Código da crítica
                                                      pr_dscritic => vr_dscritic);             --> Descrição da crítica
                                                                                                    
                    IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                       RAISE vr_exc_saida;
                    END IF;
                ELSIF rw_craplac.idtippro = 2 THEN -- Pós-fixada
                    -- Buscar as taxas acumuladas da aplicação
                    apli0006.pc_taxa_acumul_aplic_pos(pr_cdcooper => pr_cdcooper,              --> Código da Cooperativa
                                                      pr_txaplica => rw_craplac.txaplica,      --> Taxa da Aplicação
                                                      pr_idtxfixa => rw_craplac.idtxfixa,      --> Taxa Fixa (1-SIM/2-NAO)
                                                      pr_cddindex => rw_craplac.cddindex,      --> Código do Indexador
                                                      pr_dtinical => rw_craplac.dtmvtolt_rac,  --> Data Inicial Cálculo 
                                                      pr_dtfimcal => pr_dtmvtolt_fim,          --> Data Final Cálculo 
                                                      pr_txacumul => vr_txacumul,              --> Taxa acumulada durante o período total da aplicação
                                                      pr_txacumes => vr_txacumes,              --> Taxa acumulada durante o mês vigente
                                                      pr_cdcritic => vr_cdcritic,              --> Código da crítica
                                                      pr_dscritic => vr_dscritic);             --> Descrição da crítica

                    IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                       RAISE vr_exc_saida;
                    END IF;                                   
                END IF;
                -- Se parâmetro pr_idlstdhs for igual 1, listar todos os históricos
                IF pr_idlstdhs = 1 THEN
                    vr_lshistor := to_char(rw_craplac.cdhsraap) || ',' || -- CR. Plano poup
                                   to_char(rw_craplac.cdhsnrap) || ',' || -- CR. Plano poup
                                   to_char(rw_craplac.cdhsprap) || ',' || -- Previsao Mes
                                   to_char(rw_craplac.cdhsrvap) || ',' || -- Reversão
                                   to_char(rw_craplac.cdhsrdap) || ',' || -- Rendimento
                                   to_char(rw_craplac.cdhsirap) || ',' || -- DB.IRRF
                                   to_char(rw_craplac.cdhsrgap) || ',' || -- Resgate
                                   to_char(rw_craplac.cdhsvtap);          -- Resg. RDCPOS
                -- Se parâmetro pr_idlstdhs for igual 0, não listar históricos de reversão e rendimento
                ELSIF pr_idlstdhs = 0 THEN
                    vr_lshistor := to_char(rw_craplac.cdhsraap) || ',' || 
                                   to_char(rw_craplac.cdhsnrap) || ',' || 
                                   to_char(rw_craplac.cdhsprap) || ',' || 
                                   to_char(rw_craplac.cdhsirap) || ',' || 
                                   to_char(rw_craplac.cdhsrgap) || ',' || 
                                   to_char(rw_craplac.cdhsvtap);
                END IF;

                IMUT0001.pc_verifica_periodo_imune (pr_cdcooper  => pr_cdcooper   --> Codigo Cooperativa
                                                   ,pr_nrdconta  => pr_nrdconta   --> Numero da Conta
                                                   ,pr_flgimune  => vr_flgimune   --> Identificador se é imune
                                                   ,pr_dtinicio  => vr_dtinicio   --> Data de inicio da imunidade
                                                   ,pr_dttermin  => vr_dttermin   --> Data termino da imunidade
                                                   ,pr_dsreturn  => vr_dsreturn   --> Descricao retorno(NOK/OK)
                                                   ,pr_tab_erro  => vr_tab_erro); --> Tabela erros
                                                                                        
                IF vr_dsreturn = 'NOK' THEN
                    --Se tem erro na tabela 
                    IF vr_tab_erro.count > 0 THEN
                       vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                       vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                    ELSE
                       vr_cdcritic:= 0;
                       vr_dscritic:= 'Erro ao executar IMUT0001.pc_verifica_periodo_imune. Cooperativa: '||pr_cdcooper||' Conta: '||pr_nrdconta;  
                    END IF;  
                    --Levantar Excecao
                    RAISE vr_exc_saida;
                END IF;
                                                                                  
                -- Verifica a quantidade de dias para saber o IR 
                vr_qtdiasir := pr_dtmvtolt_fim - rw_craplac.dtmvtolt_rac;
                  
                -- Consulta faixas de IR
                FOR i IN REVERSE apli0001.vr_faixa_ir_rdc.first .. apli0001.vr_faixa_ir_rdc.last LOOP
                    IF vr_qtdiasir > apli0001.vr_faixa_ir_rdc(i).qtdiatab THEN
                        vr_percirrf := apli0001.vr_faixa_ir_rdc(i).perirtab;
                    END IF;
                END LOOP;
                -- Se não possuir IRRF
                IF (vr_percirrf IS NULL OR vr_percirrf = 0) THEN
                    -- Atribuir primeira faixa de irrf
                    vr_percirrf := apli0001.vr_faixa_ir_rdc(1).perirtab;
                END IF;                                                                                

                -- Verificar se o histórico de lançamento está cadastrado na tabela craphis
                OPEN cr_craphis (pr_cdcooper => pr_cdcooper
                                ,pr_cdhistor => rw_craplac.cdhistor);
                FETCH cr_craphis INTO rw_craphis;

                IF cr_craphis%NOTFOUND THEN
                    vr_cdcritic := 526; -- Histórico não encontrado
                    CLOSE cr_craphis;
                    RAISE vr_exc_saida;
                END IF;
                CLOSE cr_craphis;
                        
                -- Verifica a quantidade de dias para saber o IR -
                vr_qtdiasir := rw_craplac.dtmvtolt_lac - rw_craplac.dtmvtolt_rac;
                  
                -- Consulta faixas de IR
                FOR i IN REVERSE apli0001.vr_faixa_ir_rdc.first .. apli0001.vr_faixa_ir_rdc.last LOOP
                  IF vr_qtdiasir > apli0001.vr_faixa_ir_rdc(i).qtdiatab THEN
                    vr_percirrf := apli0001.vr_faixa_ir_rdc(i).perirtab;
                  END IF;
                END LOOP;
                -- Se não possuir IRRF
                IF (vr_percirrf IS NULL OR vr_percirrf = 0) THEN
                  -- Atribuir primeira faixa de irrf
                  vr_percirrf := apli0001.vr_faixa_ir_rdc(1).perirtab;
                END IF;
                IF rw_craplac.cdhistor = rw_craplac.cdhsrgap THEN    /* Resgate */
                     vr_vlresgat := NVL(vr_vlresgat,0) + rw_craplac.vllanmto;
                ELSIF rw_craplac.cdhistor = rw_craplac.cdhsprap THEN /* Rendimento */
                     vr_vlrendim := NVL(vr_vlrendim,0) + rw_craplac.vllanmto;
                ELSIF rw_craplac.cdhistor = rw_craplac.cdhsirap THEN /* IRRF */
                     vr_vldoirrf := NVL(vr_vldoirrf,0) + rw_craplac.vllanmto;
                END IF;
                IF rw_craphis.indebcre = 'C' THEN     /* Crédito */
                     vr_vlsldtot := NVL(vr_vlsldtot,0) + rw_craplac.vllanmto;
                ELSIF rw_craphis.indebcre = 'D' AND  (rw_craplac.cdhistor = rw_craplac.cdhsrvap) THEN  /* Débito  */
                      vr_vlsldtot := NVL(vr_vlsldtot,0) - rw_craplac.vllanmto;  
                     /*
                      IF (rw_craplac.cdhistor = rw_craplac.cdhsrvap) -- Reversao
                      AND (rw_craplac.dtmvtolt_lac - rw_craplac.dtmvtolt_rac >=  rw_craplac.qtdiacar) THEN -- Fora do período de carência
                          vr_vlsldtot := NVL(vr_vlsldtot,0) -- Não faz nada
                      ELSE
                          vr_vlsldtot := NVL(vr_vlsldtot,0) - rw_craplac.vllanmto;
                      END IF; */
                ELSE
                     vr_cdcritic := 0;
                     vr_dscritic := 'Tipo de lancamento invalido';
                     RAISE vr_exc_saida;
                END IF;
                -- Atribui a descrição do histórico e extrato para as variáveis
                vr_dshistor := rw_craphis.dshistor;
                vr_dsextrat := rw_craphis.dsextrat;
                IF vr_flgimune = TRUE THEN
                     /* Se o cooperado ainda está imune, utiliza a data de movimento */
                    IF vr_dttermin IS NULL THEN 
                        vr_dttermin := pr_dtmvtolt_fim;
                    END IF;
                    -- Se o cooperado tinha imunidade tributária na data do lançamento do rendimento
                    IF rw_craplac.cdhistor  = rw_craplac.cdhsrdap AND
                         rw_craplac.dtmvtolt_lac >= vr_dtinicio AND
                         rw_craplac.dtmvtolt_lac <= vr_dttermin THEN
                        -- O carácter * é apresentado junto a descrição do histórico
                        vr_dshistor := vr_dshistor || '*';
                        vr_dsextrat := vr_dsextrat || '*';
                    END IF;
                END IF;                
                IF rw_craplac.cdhistor = rw_craplac.cdhsrdap THEN /* Rendimento */
                     vr_txlancto := rw_craplac.txaplica;
                ELSIF rw_craplac.cdhistor = rw_craplac.cdhsirap THEN /* IRRF */                     
                     vr_txlancto := vr_percirrf;
                ELSE /* Demais lançamentos */
                     vr_txlancto := 0; 
                END IF;
                
                IF gene0002.fn_existe_valor(vr_lshistor,rw_craplac.cdhistor,',') = 'S' THEN
                   IF (vr_saldo_imp=0 AND (rw_craplac.dtmvtolt_lac >= pr_dtmvtolt_ini)) THEN -- Saldo anterior ainda nao foi impresso mas ja pode
                      vr_ind_extrato :=  1;
                      vr_tab_extrato_temp(vr_ind_extrato).dtmvtolt := pr_dtmvtolt_ini;
                      vr_tab_extrato_temp(vr_ind_extrato).cdagenci := 0;
                      vr_tab_extrato_temp(vr_ind_extrato).cdhistor := 0;
                      vr_tab_extrato_temp(vr_ind_extrato).dshistor := 'SALDO ANTERIOR';
                      vr_tab_extrato_temp(vr_ind_extrato).aghistor := 0;
                      vr_tab_extrato_temp(vr_ind_extrato).dsextrat := 'SALDO ANTERIOR';
                      vr_tab_extrato_temp(vr_ind_extrato).nrdocmto := 0;
                      vr_tab_extrato_temp(vr_ind_extrato).indebcre := '';
                      vr_tab_extrato_temp(vr_ind_extrato).vllanmto := 0;
                      vr_tab_extrato_temp(vr_ind_extrato).vlsldtot := vr_vlsdrdpp_ant;
                      vr_tab_extrato_temp(vr_ind_extrato).txlancto := 0;
                      vr_tab_extrato_temp(vr_ind_extrato).nraplica := 0;
                      vr_tab_extrato_temp(vr_ind_extrato).cdbccxlt := 0;
                      vr_tab_extrato_temp(vr_ind_extrato).nrdolote := 0;
                      vr_saldo_imp:=1;
                   END IF;
                   IF vr_saldo_imp=1 THEN 
                      -- Incrementa indice da PLTable de extrato
                      vr_ind_extrato := vr_tab_extrato_temp.count() + 1;
                      vr_tab_extrato_temp(vr_ind_extrato).dtmvtolt := rw_craplac.dtmvtolt_lac;
                      vr_tab_extrato_temp(vr_ind_extrato).cdagenci := rw_craplac.cdagenci;
                      vr_tab_extrato_temp(vr_ind_extrato).cdhistor := rw_craphis.cdhistor;
                      IF rw_craphis.cdhistor IN (rw_craplac.cdhsprap,rw_craplac.cdhsrgap) THEN
                         vr_tab_extrato_temp(vr_ind_extrato).aghistor := 1; -- Acumula
                      ELSE
                         vr_tab_extrato_temp(vr_ind_extrato).aghistor := 0; -- Nao Acumula
                      END IF;
                      vr_tab_extrato_temp(vr_ind_extrato).dshistor := vr_dshistor;
                      vr_tab_extrato_temp(vr_ind_extrato).dsextrat := vr_dsextrat;
                      vr_tab_extrato_temp(vr_ind_extrato).nrdocmto := rw_craplac.nrdocmto;
                      vr_tab_extrato_temp(vr_ind_extrato).indebcre := rw_craphis.indebcre;
                      vr_tab_extrato_temp(vr_ind_extrato).vllanmto := rw_craplac.vllanmto;
                      vr_tab_extrato_temp(vr_ind_extrato).vlsldtot := vr_vlsldtot;
                      vr_tab_extrato_temp(vr_ind_extrato).txlancto := vr_txlancto;
                      vr_tab_extrato_temp(vr_ind_extrato).nraplica := rw_craplac.nraplica;
                      vr_tab_extrato_temp(vr_ind_extrato).cdbccxlt := rw_craplac.cdbccxlt;
                      vr_tab_extrato_temp(vr_ind_extrato).nrdolote := rw_craplac.nrdolote;
                   END IF;
                END IF;
                vr_vlsdrdpp_ant := vr_vlsldtot;
           END LOOP; -- CRAPLAC
           IF vr_tab_extrato_temp.count>0 THEN
               -- Junta as provisões e resgates
               vr_ind_extrato :=  0;
               FOR vr_ind_extrato_temp in vr_tab_extrato_temp.First .. vr_tab_extrato_temp.Last
                 LOOP
                   IF vr_tab_extrato_temp(vr_ind_extrato_temp).aghistor = 1  
                   AND (vr_tab_extrato_temp(vr_ind_extrato_temp).dtmvtolt = vr_tab_extrato(vr_ind_extrato).dtmvtolt)
                   AND (vr_tab_extrato_temp(vr_ind_extrato_temp).cdagenci = vr_tab_extrato(vr_ind_extrato).cdagenci)
                   AND (vr_tab_extrato_temp(vr_ind_extrato_temp).cdhistor = vr_tab_extrato(vr_ind_extrato).cdhistor) THEN -- Acumular
                        vr_tab_extrato(vr_ind_extrato).nrdocmto := null;
                        vr_tab_extrato(vr_ind_extrato).vllanmto := vr_tab_extrato(vr_ind_extrato).vllanmto + vr_tab_extrato_temp(vr_ind_extrato_temp).vllanmto;
                        vr_tab_extrato(vr_ind_extrato).vlsldtot := vr_tab_extrato(vr_ind_extrato).vlsldtot + vr_tab_extrato_temp(vr_ind_extrato_temp).vllanmto;
                   ELSE
                      vr_ind_extrato := vr_tab_extrato.count() + 1;
                      vr_tab_extrato(vr_ind_extrato).dtmvtolt := vr_tab_extrato_temp(vr_ind_extrato_temp).dtmvtolt;
                      vr_tab_extrato(vr_ind_extrato).cdagenci := vr_tab_extrato_temp(vr_ind_extrato_temp).cdagenci;
                      vr_tab_extrato(vr_ind_extrato).cdhistor := vr_tab_extrato_temp(vr_ind_extrato_temp).cdhistor;
                      vr_tab_extrato(vr_ind_extrato).dshistor := vr_tab_extrato_temp(vr_ind_extrato_temp).dshistor;
                      vr_tab_extrato(vr_ind_extrato).aghistor := vr_tab_extrato_temp(vr_ind_extrato_temp).aghistor;
                      vr_tab_extrato(vr_ind_extrato).dsextrat := vr_tab_extrato_temp(vr_ind_extrato_temp).dsextrat;
                      vr_tab_extrato(vr_ind_extrato).nrdocmto := vr_tab_extrato_temp(vr_ind_extrato_temp).nrdocmto;
                      vr_tab_extrato(vr_ind_extrato).indebcre := vr_tab_extrato_temp(vr_ind_extrato_temp).indebcre;
                      vr_tab_extrato(vr_ind_extrato).vllanmto := vr_tab_extrato_temp(vr_ind_extrato_temp).vllanmto;
                      vr_tab_extrato(vr_ind_extrato).vlsldtot := vr_tab_extrato_temp(vr_ind_extrato_temp).vlsldtot;
                      vr_tab_extrato(vr_ind_extrato).txlancto := vr_tab_extrato_temp(vr_ind_extrato_temp).txlancto;
                      vr_tab_extrato(vr_ind_extrato).nraplica := vr_tab_extrato_temp(vr_ind_extrato_temp).nraplica;
                      vr_tab_extrato(vr_ind_extrato).cdbccxlt := vr_tab_extrato_temp(vr_ind_extrato_temp).cdbccxlt;
                      vr_tab_extrato(vr_ind_extrato).nrdolote := vr_tab_extrato_temp(vr_ind_extrato_temp).nrdolote;
                   END IF;
               END LOOP;
           END IF;
           -- Alimenta parâmetros
           pr_vlresgat := vr_vlresgat;
           pr_vlrendim := vr_vlrendim;
           pr_vldoirrf := vr_vldoirrf;
           pr_tab_extrato := vr_tab_extrato;
        
            -- Gerar log
            IF pr_idgerlog = 1 THEN
               GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                   ,pr_cdoperad => pr_cdoperad
                                   ,pr_dscritic => ''
                                   ,pr_dsorigem => vr_dsorigem
                                   ,pr_dstransa => vr_dstransa
                                   ,pr_dttransa => TRUNC(SYSDATE)
                                   ,pr_flgtrans => 0 --> FALSE
                                   ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                                   ,pr_idseqttl => pr_idseqttl
                                   ,pr_nmdatela => pr_nmdatela
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrdrowid => vr_nrdrowid);
               COMMIT;
            END IF;
          
          EXCEPTION
            WHEN vr_exc_saida THEN
                 IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
                    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
                 END IF;
                 -- Alimenta parametros com a crítica ocorrida
                 pr_cdcritic := vr_cdcritic;
                 pr_dscritic := vr_dscritic;
                 ROLLBACK;

                 -- Verifica se deve gerar log
                 IF pr_idgerlog = 1 THEN
                    GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                        ,pr_cdoperad => pr_cdoperad
                                        ,pr_dscritic => vr_dscritic
                                        ,pr_dsorigem => vr_dsorigem
                                        ,pr_dstransa => vr_dstransa
                                        ,pr_dttransa => TRUNC(SYSDATE)
                                        ,pr_flgtrans => 0 --> FALSE
                                        ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                                        ,pr_idseqttl => pr_idseqttl
                                        ,pr_nmdatela => pr_nmdatela
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_nrdrowid => vr_nrdrowid);
                    COMMIT;
                 END IF;
            WHEN OTHERS THEN
                 pr_cdcritic := vr_cdcritic;
                 pr_dscritic := 'Erro nao tratado APLI0008.pc_buscar_extrato_apl_prog: ' || SQLERRM;
                 ROLLBACK; 
                 -- Verifica se deve gerar log
                 IF pr_idgerlog = 1 THEN
                    GENE0001.pc_gera_log (pr_cdcooper => pr_cdcooper
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_dscritic => vr_dscritic
                                         ,pr_dsorigem => vr_dsorigem
                                         ,pr_dstransa => vr_dstransa
                                         ,pr_dttransa => TRUNC(SYSDATE)
                                         ,pr_flgtrans => 0 --> FALSE
                                         ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                                         ,pr_idseqttl => pr_idseqttl
                                         ,pr_nmdatela => pr_nmdatela
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_nrdrowid => vr_nrdrowid);
                    COMMIT;
               END IF; 
       END; -- Principal
  END pc_buscar_extrato_apl_prog;
  
  PROCEDURE pc_buscar_extrato_apl_prog_web (pr_nrdconta IN craprac.nrdconta%TYPE   -- Número da Conta
                                           ,pr_idseqttl IN crapttl.idseqttl%TYPE   -- Titular da Conta
                                           ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE   -- Número da Aplicação Programada.
                                           ,pr_dtmvtolt_ini IN VARCHAR2            -- Data de Movimento Inicial
                                           ,pr_dtmvtolt_fim IN VARCHAR2            -- Data de Movimento Fim
                                           ,pr_idlstdhs IN NUMBER                  -- Identificador de Listagem de Todos Históricos (Fixo na chamada, 0 – Não / 1 – Sim)
                                           ,pr_idgerlog IN NUMBER                  -- Identificador de Log (Fixo na chamada, 0 – Não / 1 – Sim)
                                           ,pr_xmllog   IN VARCHAR2                -- XML com informacoes de LOG
                                           ,pr_cdcritic OUT PLS_INTEGER            -- Código da crítica
                                           ,pr_dscritic OUT VARCHAR2               -- Descrição da crítica
                                           ,pr_retxml   IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                                           ,pr_nmdcampo OUT VARCHAR2               -- Nome do campo com erro
                                           ,pr_des_erro OUT VARCHAR2)              -- Erros do processo


  IS
  BEGIN
   /* .............................................................................

   Programa: pc_buscar_extrato_apl_prog_web
   Sistema : Novos Produtos de Captação
   Sigla   : APLI
   Autor   : CIS Corporate
   Data    : Julho/2018.                    Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Rotina referente a busca de extratos das aplicações programadas. 

   Observacao: -----

   Alteracoes: 
  ..............................................................................*/                

  DECLARE
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    
    -- Variaveis auxiliares
    vr_exc_erro EXCEPTION;

    -- Variaveis de entrada
    vr_dtmvtolt_ini Date := TO_DATE(pr_dtmvtolt_ini,'DD/MM/YYYY');  
    vr_dtmvtolt_fim Date := TO_DATE(pr_dtmvtolt_fim,'DD/MM/YYYY');  

    -- Variaveis de retorno
    pr_tab_extrato apli0008.typ_tab_extrato_apl_prog;
    vr_vlresgat NUMBER (15,2);
    vr_vlrendim NUMBER (15,2);
    vr_vldoirrf NUMBER (15,2);
    vr_percirrf NUMBER (15,2);

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Variaveis de XML 
    vr_xml_temp VARCHAR2(32767);
    vr_clobxmlc CLOB;
    
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

    -- Busca o extrato da apl. programada
    pc_buscar_extrato_apl_prog (pr_cdcooper => vr_cdcooper
                               ,pr_cdoperad => vr_cdoperad
                               ,pr_nmdatela => vr_nmdatela
                               ,pr_idorigem => vr_idorigem
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_idseqttl => pr_idseqttl
                               ,pr_nrctrrpp => pr_nrctrrpp
                               ,pr_dtmvtolt_ini => vr_dtmvtolt_ini
                               ,pr_dtmvtolt_fim => vr_dtmvtolt_fim
                               ,pr_idlstdhs => pr_idlstdhs
                               ,pr_idgerlog => pr_idgerlog
                               ,pr_tab_extrato => pr_tab_extrato
                               ,pr_vlresgat => vr_vlresgat
                               ,pr_vlrendim => vr_vlrendim
                               ,pr_vldoirrf => vr_vldoirrf
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic);

    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;     
    -- Criar cabeçalho do XML
    dbms_lob.createtemporary(vr_clobxmlc, TRUE); 
    dbms_lob.open(vr_clobxmlc, dbms_lob.lob_readwrite);
    -- Insere o cabeçalho do XML 
    gene0002.pc_escreve_xml (pr_xml            => vr_clobxmlc 
                            ,pr_texto_completo => vr_xml_temp 
                            ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>');
      
    IF pr_tab_extrato.count >0 THEN
       FOR ctLinha in pr_tab_extrato.First .. pr_tab_extrato.Last LOOP
           gene0002.pc_escreve_xml(pr_xml            => vr_clobxmlc
                                  ,pr_texto_completo => vr_xml_temp 
                                  ,pr_texto_novo     => 
                                  '<Registro>'||
                                  '<dtmvtolt>'||to_char(pr_tab_extrato(ctLinha).dtmvtolt,'dd/mm/yyyy')||'</dtmvtolt>'||
                                  '<dshistor>'||pr_tab_extrato(ctLinha).dshistor||'</dshistor>'||
                                  '<nrdocmto>'||pr_tab_extrato(ctLinha).nrdocmto||'</nrdocmto>'||
                                  '<indebcre>'||pr_tab_extrato(ctLinha).indebcre||'</indebcre>'||
                                  '<vllanmto>'||pr_tab_extrato(ctLinha).vllanmto||'</vllanmto>'||
                                  '<vlsldppr>'||pr_tab_extrato(ctLinha).vlsldtot||'</vlsldppr>'||
                                  '<txaplica>0</txaplica>'||
                                  '<txaplmes>0</txaplmes>'||
                                  '<cdagenci>'||pr_tab_extrato(ctLinha).cdagenci||'</cdagenci>'||
                                  '<cdbccxlt>'||pr_tab_extrato(ctLinha).cdbccxlt||'</cdbccxlt>'||
                                  '<nrdolote>'||pr_tab_extrato(ctLinha).nrdolote||'</nrdolote>'||
                                  '<dsextrat>'||pr_tab_extrato(ctLinha).dsextrat||'</dsextrat>'||
                                  '</Registro>'
                                  );
       END LOOP;
    END IF;
       -- Encerrar a tag raiz 
       gene0002.pc_escreve_xml(pr_xml            => vr_clobxmlc 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => '</Dados></Root>' 
                               ,pr_fecha_xml      => TRUE);
                                 
       pr_retxml := XMLType.createXML(vr_clobxmlc);

  Exception
    When vr_exc_erro Then
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        
    When others Then
      pr_cdcritic := null; -- não será utilizado
      pr_dscritic := 'Erro geral em APLI0008.pc_buscar_extrato_apl_prog_web: '||SQLERRM;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
      
  END;

  END pc_buscar_extrato_apl_prog_web;

  PROCEDURE pc_gerar_ext_apl_prog_titulo (pr_cdcooper IN craprac.cdcooper%TYPE                  -- Código da Cooperativa
                                         ,pr_cdoperad IN crapope.cdoperad%TYPE                  -- Código do Operador 
                                         ,pr_nmdatela IN craptel.nmdatela%TYPE                  -- Nome da Tela
                                         ,pr_idorigem IN NUMBER                                 -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA                  
                                         ,pr_nrdconta IN craprac.nrdconta%TYPE                  -- Número da Conta
                                         ,pr_idseqttl IN crapttl.idseqttl%TYPE                  -- Titular da Conta
                                         ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE                  -- Número da Aplicação Programada.
                                         ,pr_nraplica IN craprac.nraplica%TYPE                  -- Número da Aplicacao
                                         ,pr_dtmvtolt_ini IN crapdat.dtmvtolt%TYPE              -- Data de Movimento - Inicio
                                         ,pr_dtmvtolt_fim IN crapdat.dtmvtolt%TYPE              -- Data de Movimento - Fim
                                         ,pr_idlstdhs IN NUMBER                                 -- Identificador de Listagem de Todos Históricos (Fixo na chamada, 0 – Não / 1 – Sim)
                                         ,pr_idgerlog IN NUMBER                                 -- Identificador de Log (Fixo na chamada, 0 – Não / 1 – Sim)
                                         ,pr_tab_extrato OUT apli0008.typ_tab_extrato_apl_prog  -- PLTable com os dados de extrato
                                         ,pr_vlresgat OUT NUMBER                                -- Valor de resgate
                                         ,pr_vlrendim OUT NUMBER                                -- Valor de rendimento
                                         ,pr_vldoirrf OUT NUMBER                                -- Valor do IRRF 
                                         ,pr_percirrf OUT NUMBER                                -- Valor de aliquota de IR
                                         ,pr_txacumul OUT NUMBER                                -- Taxa acumulada durante o período total da aplicação
                                         ,pr_txacumes OUT NUMBER                                -- Taxa acumulada durante o mês vigente
                                         ,pr_qtdiacar OUT craprac.qtdiacar%TYPE                 -- Qtd. dias carência
                                         ,pr_dtfimcar OUT DATE                                  -- Data fim da carência
                                         ,pr_dtvencto OUT DATE                                  -- Data de vencimento 
                                         ,pr_qtdiaprz OUT craprac.qtdiaprz%TYPE                 -- Quantidade de dias do prazo da modalidade
                                         ,pr_qtdiaapl OUT craprac.qtdiaapl%TYPE                 -- Quantidade de dias da aplicacao
                                         ,pr_txaplica OUT craprac.txaplica%TYPE                 -- Taxa contratada da aplicacao
                                         ,pr_nmdindex OUT crapind.nmdindex%TYPE                 -- Nome do Indice  
                                         ,pr_cdcritic OUT crapcri.cdcritic%TYPE                 -- Código da crítica
                                         ,pr_dscritic OUT crapcri.dscritic%TYPE                 -- Descrição da crítica
   
   ) IS
    BEGIN
     /* .............................................................................

     Programa: pc_extrato_apl_prog_titulo
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : CIS Corporate
     Data    : Agposto/2018.                    Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a busca de extratos das aplicações programadas 

     Observacao: -----

     Alteracoes: 
    ..............................................................................*/                
      
      DECLARE
        
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
            
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;      
            
      -- Variáveis retornadas da procedure IMUT0001.pc_verifica_periodo_imune
      vr_flgimune BOOLEAN;
      vr_dtinicio DATE;
      vr_dttermin DATE;
      vr_dsreturn VARCHAR2(3);
      vr_tab_erro GENE0001.typ_tab_erro;
            
      --Variáveis locais
      vr_dstransa VARCHAR2(100) := 'Busca extrato da aplicacao programada contrato #: ' || pr_nrctrrpp;
      vr_dsorigem VARCHAR2(100) := gene0001.vr_vet_des_origens(pr_idorigem);
      vr_nrdrowid ROWID;
      vr_lshistor VARCHAR2(200);            
      vr_vlresgat NUMBER := 0;
      vr_vlresgat_calc NUMBER := 0;
      vr_vlrendim NUMBER := 0;
      vr_vldoirrf NUMBER := 0;
      vr_vlsldtot NUMBER := 0;
      vr_dshistor craphis.dshistor%TYPE;
      vr_dsextrat craphis.dsextrat%TYPE;
      vr_qtdiasir PLS_INTEGER := 0; -- Qtd de dias para calculo de faixa de IR
      vr_percirrf NUMBER := 0;
      vr_txlancto NUMBER := 0;
      vr_txacumul NUMBER := 0;
      vr_txacumes NUMBER := 0;
      vr_saldo_imp PLS_INTEGER := 0;   -- Saldo anterior impresso?
      vr_vlsdrdpp_ant NUMBER := 0;     -- Valor Saldo anterior
      
      -- PLTable que conterá os dados do extrato
      vr_tab_extrato_temp apli0008.typ_tab_extrato_apl_prog;
      vr_tab_extrato apli0008.typ_tab_extrato_apl_prog;
      vr_ind_extrato PLS_INTEGER := 0;

      -- Busca Detalhes do fundo
      CURSOR cr_craprac IS
          SELECT
              rac.dtmvtolt,
              rac.dtvencto,
              rac.qtdiacar,
              (rac.dtmvtolt+rac.qtdiacar) dtfimcar,
              rac.qtdiaprz,
              rac.qtdiaapl,
              rac.txaplica,
              ind.nmdindex
          FROM
              craprac rac, crapcpc cpc, crapind ind
        WHERE rac.cdcooper=pr_cdcooper
          AND rac.nrdconta=pr_nrdconta 
          AND rac.nrctrrpp=pr_nrctrrpp
          AND rac.nraplica=pr_nraplica
          AND rac.cdprodut=cpc.cdprodut
          AND cpc.cddindex=ind.cddindex;
          
      rw_craprac cr_craprac%ROWTYPE;   

      -- Busca Aplicações de captação com seus lançamentos
      CURSOR cr_craplac IS
          SELECT 
                 lac.nraplica,
                 rac.dtmvtolt dtmvtolt_rac,
                 lac.dtmvtolt dtmvtolt_lac,
                 lac.nrdolote,
                 lac.cdbccxlt,
                 cpc.idtippro,            
                 cpc.idtxfixa,
                 cpc.cddindex,
                 cpc.cdhsraap, 
                 cpc.cdhsnrap,
                 cpc.cdhsprap,
                 cpc.cdhsrvap,
                 cpc.cdhsrdap, 
                 cpc.cdhsirap,
                 cpc.cdhsrgap,
                 cpc.cdhsvtap,
                 lac.vllanmto,
                 lac.cdhistor,
                 lac.cdagenci,
                 lac.nrdocmto
            FROM craprac rac, craplac lac, crapcpc cpc
           WHERE rac.cdcooper = pr_cdcooper
             AND rac.nrdconta = pr_nrdconta
             AND rac.nrctrrpp = pr_nrctrrpp
             AND rac.nraplica = pr_nraplica
             AND rac.cdprodut = cpc.cdprodut
             AND rac.cdcooper = lac.cdcooper
             AND rac.nrdconta = lac.nrdconta
             AND rac.nraplica = lac.nraplica
             AND lac.dtmvtolt <= pr_dtmvtolt_fim
           ORDER BY lac.dtmvtolt, lac.cdhistor;
      
      rw_craplac cr_craplac%ROWTYPE;
       
      -- Buscar histórico de lançamento das aplicações
      CURSOR cr_craphis(pr_cdcooper IN craphis.cdcooper%TYPE
                       ,pr_cdhistor IN craphis.cdhistor%TYPE) IS
          SELECT his.indebcre,
                 his.dshistor,
                 his.dsextrat,
                 his.cdhistor
            FROM craphis his
           WHERE his.cdcooper = pr_cdcooper
             AND his.cdhistor = pr_cdhistor;
            
       rw_craphis cr_craphis%ROWTYPE;

       BEGIN -- Principal
           -- Carrega informações sobre os títulos
           OPEN cr_craprac;
           FETCH cr_craprac INTO rw_craprac;
           IF cr_craprac%NOTFOUND THEN
              CLOSE cr_craprac;
              RAISE vr_exc_saida;
           END IF;
           CLOSE cr_craprac;

           -- Carregada as faixas de IR para uso posterior             
           apli0001.pc_busca_faixa_ir_rdc(pr_cdcooper => pr_cdcooper);

           -- Para cada registro de lançamento de aplicação de captação                                                                    
           FOR rw_craplac IN cr_craplac
           LOOP
                IF rw_craplac.idtippro = 1 THEN -- Pré-fixada
                    -- Buscar as taxas acumuladas da aplicação
                    apli0006.pc_taxa_acumul_aplic_pre(pr_cdcooper => pr_cdcooper,              --> Código da Cooperativa
                                                      pr_txaplica => rw_craprac.txaplica,      --> Taxa da Aplicação
                                                      pr_idtxfixa => rw_craplac.idtxfixa,      --> Taxa Fixa (1-SIM/2-NAO)
                                                      pr_cddindex => rw_craplac.cddindex,      --> Código do Indexador
                                                      pr_dtinical => rw_craplac.dtmvtolt_rac,  --> Data Inicial Cálculo
                                                      pr_dtfimcal => pr_dtmvtolt_fim,          --> Data Final Cálculo 
                                                      pr_txacumul => vr_txacumul,              --> Taxa acumulada durante o período total da aplicação
                                                      pr_txacumes => vr_txacumes,              --> Taxa acumulada durante o mês vigente
                                                      pr_cdcritic => vr_cdcritic,              --> Código da crítica
                                                      pr_dscritic => vr_dscritic);             --> Descrição da crítica
                                                                                                    
                    IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                       RAISE vr_exc_saida;
                    END IF;
                ELSIF rw_craplac.idtippro = 2 THEN -- Pós-fixada
                    -- Buscar as taxas acumuladas da aplicação
                    apli0006.pc_taxa_acumul_aplic_pos(pr_cdcooper => pr_cdcooper,              --> Código da Cooperativa
                                                      pr_txaplica => rw_craprac.txaplica,      --> Taxa da Aplicação
                                                      pr_idtxfixa => rw_craplac.idtxfixa,      --> Taxa Fixa (1-SIM/2-NAO)
                                                      pr_cddindex => rw_craplac.cddindex,      --> Código do Indexador
                                                      pr_dtinical => rw_craplac.dtmvtolt_rac,  --> Data Inicial Cálculo 
                                                      pr_dtfimcal => pr_dtmvtolt_fim,          --> Data Final Cálculo 
                                                      pr_txacumul => vr_txacumul,              --> Taxa acumulada durante o período total da aplicação
                                                      pr_txacumes => vr_txacumes,              --> Taxa acumulada durante o mês vigente
                                                      pr_cdcritic => vr_cdcritic,              --> Código da crítica
                                                      pr_dscritic => vr_dscritic);             --> Descrição da crítica

                    IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                       RAISE vr_exc_saida;
                    END IF;                                   
                END IF;
                -- Se parâmetro pr_idlstdhs for igual 1, listar todos os históricos
                IF pr_idlstdhs = 1 THEN
                    vr_lshistor := to_char(rw_craplac.cdhsraap) || ',' || -- CR. Plano poup
                                   to_char(rw_craplac.cdhsnrap) || ',' || -- CR. Plano poup
                                   to_char(rw_craplac.cdhsprap) || ',' || -- Previsao Mes
                                   to_char(rw_craplac.cdhsrvap) || ',' || -- Reversão
                                   to_char(rw_craplac.cdhsrdap) || ',' || -- Rendimento
                                   to_char(rw_craplac.cdhsirap) || ',' || -- DB.IRRF
                                   to_char(rw_craplac.cdhsrgap) || ',' || -- Resgate
                                   to_char(rw_craplac.cdhsvtap);          -- Resg. RDCPOS
                -- Se parâmetro pr_idlstdhs for igual 0, não listar históricos de reversão e rendimento
                ELSIF pr_idlstdhs = 0 THEN
                    vr_lshistor := to_char(rw_craplac.cdhsraap) || ',' || 
                                   to_char(rw_craplac.cdhsnrap) || ',' || 
                                   to_char(rw_craplac.cdhsprap) || ',' || 
                                   to_char(rw_craplac.cdhsirap) || ',' || 
                                   to_char(rw_craplac.cdhsrgap) || ',' || 
                                   to_char(rw_craplac.cdhsvtap);
                END IF;

                IMUT0001.pc_verifica_periodo_imune (pr_cdcooper  => pr_cdcooper   --> Codigo Cooperativa
                                                   ,pr_nrdconta  => pr_nrdconta   --> Numero da Conta
                                                   ,pr_flgimune  => vr_flgimune   --> Identificador se é imune
                                                   ,pr_dtinicio  => vr_dtinicio   --> Data de inicio da imunidade
                                                   ,pr_dttermin  => vr_dttermin   --> Data termino da imunidade
                                                   ,pr_dsreturn  => vr_dsreturn   --> Descricao retorno(NOK/OK)
                                                   ,pr_tab_erro  => vr_tab_erro); --> Tabela erros
                                                                                        
                IF vr_dsreturn = 'NOK' THEN
                    --Se tem erro na tabela 
                    IF vr_tab_erro.count > 0 THEN
                       vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                       vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                    ELSE
                       vr_cdcritic:= 0;
                       vr_dscritic:= 'Erro ao executar IMUT0001.pc_verifica_periodo_imune. Cooperativa: '||pr_cdcooper||' Conta: '||pr_nrdconta;  
                    END IF;  
                    --Levantar Excecao
                    RAISE vr_exc_saida;
                END IF;
                                                                                  
                -- Verifica a quantidade de dias para saber o IR 
                vr_qtdiasir := pr_dtmvtolt_fim - rw_craplac.dtmvtolt_rac;
                  
                -- Consulta faixas de IR
                FOR i IN REVERSE apli0001.vr_faixa_ir_rdc.first .. apli0001.vr_faixa_ir_rdc.last LOOP
                    IF vr_qtdiasir > apli0001.vr_faixa_ir_rdc(i).qtdiatab THEN
                        vr_percirrf := apli0001.vr_faixa_ir_rdc(i).perirtab;
                    END IF;
                END LOOP;
                -- Se não possuir IRRF
                IF (vr_percirrf IS NULL OR vr_percirrf = 0) THEN
                    -- Atribuir primeira faixa de irrf
                    vr_percirrf := apli0001.vr_faixa_ir_rdc(1).perirtab;
                END IF;                                                                                

                -- Verificar se o histórico de lançamento está cadastrado na tabela craphis
                OPEN cr_craphis (pr_cdcooper => pr_cdcooper
                                ,pr_cdhistor => rw_craplac.cdhistor);
                FETCH cr_craphis INTO rw_craphis;

                IF cr_craphis%NOTFOUND THEN
                    vr_cdcritic := 526; -- Histórico não encontrado
                    CLOSE cr_craphis;
                    RAISE vr_exc_saida;
                END IF;
                CLOSE cr_craphis;
                        
                -- Verifica a quantidade de dias para saber o IR -
                vr_qtdiasir := rw_craplac.dtmvtolt_lac - rw_craplac.dtmvtolt_rac;
                  
                -- Consulta faixas de IR
                FOR i IN REVERSE apli0001.vr_faixa_ir_rdc.first .. apli0001.vr_faixa_ir_rdc.last LOOP
                  IF vr_qtdiasir > apli0001.vr_faixa_ir_rdc(i).qtdiatab THEN
                    vr_percirrf := apli0001.vr_faixa_ir_rdc(i).perirtab;
                  END IF;
                END LOOP;
                -- Se não possuir IRRF
                IF (vr_percirrf IS NULL OR vr_percirrf = 0) THEN
                  -- Atribuir primeira faixa de irrf
                  vr_percirrf := apli0001.vr_faixa_ir_rdc(1).perirtab;
                END IF;
                IF rw_craplac.cdhistor = rw_craplac.cdhsrgap THEN    /* Resgate */
                     vr_vlresgat := NVL(vr_vlresgat,0) + rw_craplac.vllanmto;
                ELSIF rw_craplac.cdhistor = rw_craplac.cdhsprap THEN /* Rendimento */
                     vr_vlrendim := NVL(vr_vlrendim,0) + rw_craplac.vllanmto;
                ELSIF rw_craplac.cdhistor = rw_craplac.cdhsirap THEN /* IRRF */
                     vr_vldoirrf := NVL(vr_vldoirrf,0) + rw_craplac.vllanmto;
                END IF;
                IF rw_craphis.indebcre = 'C' THEN     /* Crédito */
                     vr_vlsldtot := NVL(vr_vlsldtot,0) + rw_craplac.vllanmto;
                ELSIF rw_craphis.indebcre = 'D' AND (rw_craplac.cdhistor = rw_craplac.cdhsrvap) THEN  /* Débito  */
                      -- Reversao
                          vr_vlsldtot := NVL(vr_vlsldtot,0) - rw_craplac.vllanmto;
                ELSE
                     vr_cdcritic := 0;
                     vr_dscritic := 'Tipo de lancamento invalido';
                     RAISE vr_exc_saida;
                END IF;
                -- Atribui a descrição do histórico e extrato para as variáveis
                vr_dshistor := rw_craphis.dshistor;
                vr_dsextrat := rw_craphis.dsextrat;
                IF vr_flgimune = TRUE THEN
                     /* Se o cooperado ainda está imune, utiliza a data de movimento */
                    IF vr_dttermin IS NULL THEN 
                        vr_dttermin := pr_dtmvtolt_fim;
                    END IF;
                    -- Se o cooperado tinha imunidade tributária na data do lançamento do rendimento
                    IF rw_craplac.cdhistor  = rw_craplac.cdhsrdap AND
                         rw_craplac.dtmvtolt_lac >= vr_dtinicio AND
                         rw_craplac.dtmvtolt_lac <= vr_dttermin THEN
                        -- O carácter * é apresentado junto a descrição do histórico
                        vr_dshistor := vr_dshistor || '*';
                        vr_dsextrat := vr_dsextrat || '*';
                    END IF;
                END IF;                
                IF rw_craplac.cdhistor = rw_craplac.cdhsrdap THEN /* Rendimento */
                     vr_txlancto := rw_craprac.txaplica;
                ELSIF rw_craplac.cdhistor = rw_craplac.cdhsirap THEN /* IRRF */                     
                     vr_txlancto := vr_percirrf;
                ELSE /* Demais lançamentos */
                     vr_txlancto := 0; 
                END IF;
                
                IF gene0002.fn_existe_valor(vr_lshistor,rw_craplac.cdhistor,',') = 'S' THEN
                   IF (vr_saldo_imp=0 AND (rw_craplac.dtmvtolt_lac >= pr_dtmvtolt_ini)) THEN -- Saldo anterior ainda nao foi impresso mas ja pode
                      vr_ind_extrato :=  1;
                      vr_tab_extrato_temp(vr_ind_extrato).dtmvtolt := pr_dtmvtolt_ini;
                      vr_tab_extrato_temp(vr_ind_extrato).cdagenci := 0;
                      vr_tab_extrato_temp(vr_ind_extrato).cdhistor := 0;
                      vr_tab_extrato_temp(vr_ind_extrato).dshistor := 'SALDO ANTERIOR';
                      vr_tab_extrato_temp(vr_ind_extrato).aghistor := 0;
                      vr_tab_extrato_temp(vr_ind_extrato).dsextrat := 'SALDO ANTERIOR';
                      vr_tab_extrato_temp(vr_ind_extrato).nrdocmto := 0;
                      vr_tab_extrato_temp(vr_ind_extrato).indebcre := '';
                      vr_tab_extrato_temp(vr_ind_extrato).vllanmto := 0;
                      vr_tab_extrato_temp(vr_ind_extrato).vlsldtot := vr_vlsdrdpp_ant;
                      vr_tab_extrato_temp(vr_ind_extrato).txlancto := 0;
                      vr_tab_extrato_temp(vr_ind_extrato).nraplica := 0;
                      vr_tab_extrato_temp(vr_ind_extrato).cdbccxlt := 0;
                      vr_tab_extrato_temp(vr_ind_extrato).nrdolote := 0;
                      vr_saldo_imp:=1;
                   END IF;
                   IF vr_saldo_imp=1 THEN 
                      -- Incrementa indice da PLTable de extrato
                      vr_ind_extrato := vr_tab_extrato_temp.count() + 1;
                      vr_tab_extrato_temp(vr_ind_extrato).dtmvtolt := rw_craplac.dtmvtolt_lac;
                      vr_tab_extrato_temp(vr_ind_extrato).cdagenci := rw_craplac.cdagenci;
                      vr_tab_extrato_temp(vr_ind_extrato).cdhistor := rw_craphis.cdhistor;
                      vr_tab_extrato_temp(vr_ind_extrato).aghistor := 0; -- Nao Acumula
                      vr_tab_extrato_temp(vr_ind_extrato).dshistor := vr_dshistor;
                      vr_tab_extrato_temp(vr_ind_extrato).dsextrat := vr_dsextrat;
                      vr_tab_extrato_temp(vr_ind_extrato).nrdocmto := rw_craplac.nrdocmto;
                      vr_tab_extrato_temp(vr_ind_extrato).indebcre := rw_craphis.indebcre;
                      vr_tab_extrato_temp(vr_ind_extrato).vllanmto := rw_craplac.vllanmto;
                      vr_tab_extrato_temp(vr_ind_extrato).vlsldtot := vr_vlsldtot;
                      vr_tab_extrato_temp(vr_ind_extrato).txlancto := vr_txlancto;
                      vr_tab_extrato_temp(vr_ind_extrato).nraplica := rw_craplac.nraplica;
                      vr_tab_extrato_temp(vr_ind_extrato).cdbccxlt := rw_craplac.cdbccxlt;
                      vr_tab_extrato_temp(vr_ind_extrato).nrdolote := rw_craplac.nrdolote;
                   END IF;
                END IF;
                vr_vlsdrdpp_ant := vr_vlsldtot;
           END LOOP; -- CRAPLAC
           IF vr_tab_extrato_temp.count>0 THEN
               -- Junta as provisões e resgates
               vr_ind_extrato :=  0;
               FOR vr_ind_extrato_temp in vr_tab_extrato_temp.First .. vr_tab_extrato_temp.Last
                 LOOP
                    vr_ind_extrato := vr_tab_extrato.count() + 1;
                    vr_tab_extrato(vr_ind_extrato).dtmvtolt := vr_tab_extrato_temp(vr_ind_extrato_temp).dtmvtolt;
                    vr_tab_extrato(vr_ind_extrato).cdagenci := vr_tab_extrato_temp(vr_ind_extrato_temp).cdagenci;
                    vr_tab_extrato(vr_ind_extrato).cdhistor := vr_tab_extrato_temp(vr_ind_extrato_temp).cdhistor;
                    vr_tab_extrato(vr_ind_extrato).dshistor := vr_tab_extrato_temp(vr_ind_extrato_temp).dshistor;
                    vr_tab_extrato(vr_ind_extrato).aghistor := vr_tab_extrato_temp(vr_ind_extrato_temp).aghistor;
                    vr_tab_extrato(vr_ind_extrato).dsextrat := vr_tab_extrato_temp(vr_ind_extrato_temp).dsextrat;
                    vr_tab_extrato(vr_ind_extrato).nrdocmto := vr_tab_extrato_temp(vr_ind_extrato_temp).nrdocmto;
                    vr_tab_extrato(vr_ind_extrato).indebcre := vr_tab_extrato_temp(vr_ind_extrato_temp).indebcre;
                    vr_tab_extrato(vr_ind_extrato).vllanmto := vr_tab_extrato_temp(vr_ind_extrato_temp).vllanmto;
                    vr_tab_extrato(vr_ind_extrato).vlsldtot := vr_tab_extrato_temp(vr_ind_extrato_temp).vlsldtot;
                    vr_tab_extrato(vr_ind_extrato).txlancto := vr_tab_extrato_temp(vr_ind_extrato_temp).txlancto;
                    vr_tab_extrato(vr_ind_extrato).nraplica := vr_tab_extrato_temp(vr_ind_extrato_temp).nraplica;
                    vr_tab_extrato(vr_ind_extrato).cdbccxlt := vr_tab_extrato_temp(vr_ind_extrato_temp).cdbccxlt;
                    vr_tab_extrato(vr_ind_extrato).nrdolote := vr_tab_extrato_temp(vr_ind_extrato_temp).nrdolote;
               END LOOP;
           END IF;
           -- Alimenta parâmetros
           pr_vlresgat := vr_vlresgat;
           pr_vlrendim := vr_vlrendim;
           pr_vldoirrf := vr_vldoirrf;
           pr_percirrf := vr_percirrf;
           pr_txacumul := vr_txacumul;
           pr_txacumes := vr_txacumes;  
           pr_qtdiacar := rw_craprac.qtdiacar;
           pr_dtfimcar := rw_craprac.dtfimcar;
           pr_dtvencto := rw_craprac.dtvencto;
           pr_qtdiaprz := rw_craprac.qtdiaprz;
           pr_qtdiaapl := rw_craprac.qtdiaapl;
           pr_txaplica := rw_craprac.txaplica;
           pr_nmdindex := rw_craprac.nmdindex;
           pr_tab_extrato := vr_tab_extrato;
        
            -- Gerar log
            IF pr_idgerlog = 1 THEN
               GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                   ,pr_cdoperad => pr_cdoperad
                                   ,pr_dscritic => ''
                                   ,pr_dsorigem => vr_dsorigem
                                   ,pr_dstransa => vr_dstransa
                                   ,pr_dttransa => TRUNC(SYSDATE)
                                   ,pr_flgtrans => 0 --> FALSE
                                   ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                                   ,pr_idseqttl => pr_idseqttl
                                   ,pr_nmdatela => pr_nmdatela
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrdrowid => vr_nrdrowid);
               COMMIT;
            END IF;
          
          EXCEPTION
            WHEN vr_exc_saida THEN
                 IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
                    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
                 END IF;
                 -- Alimenta parametros com a crítica ocorrida
                 pr_cdcritic := vr_cdcritic;
                 pr_dscritic := vr_dscritic;
                 ROLLBACK;

                 -- Verifica se deve gerar log
                 IF pr_idgerlog = 1 THEN
                    GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                        ,pr_cdoperad => pr_cdoperad
                                        ,pr_dscritic => vr_dscritic
                                        ,pr_dsorigem => vr_dsorigem
                                        ,pr_dstransa => vr_dstransa
                                        ,pr_dttransa => TRUNC(SYSDATE)
                                        ,pr_flgtrans => 0 --> FALSE
                                        ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                                        ,pr_idseqttl => pr_idseqttl
                                        ,pr_nmdatela => pr_nmdatela
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_nrdrowid => vr_nrdrowid);
                    COMMIT;
                 END IF;
            WHEN OTHERS THEN
                 pr_cdcritic := vr_cdcritic;
                 pr_dscritic := 'Erro nao tratado APLI0008.pc_buscar_extrato_apl_prog: ' || SQLERRM;
                 ROLLBACK; 
                 -- Verifica se deve gerar log
                 IF pr_idgerlog = 1 THEN
                    GENE0001.pc_gera_log (pr_cdcooper => pr_cdcooper
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_dscritic => vr_dscritic
                                         ,pr_dsorigem => vr_dsorigem
                                         ,pr_dstransa => vr_dstransa
                                         ,pr_dttransa => TRUNC(SYSDATE)
                                         ,pr_flgtrans => 0 --> FALSE
                                         ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                                         ,pr_idseqttl => pr_idseqttl
                                         ,pr_nmdatela => pr_nmdatela
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_nrdrowid => vr_nrdrowid);
                    COMMIT;
               END IF; 
       END; -- Principal
  END pc_gerar_ext_apl_prog_titulo;
          
  PROCEDURE pc_buscar_detalhe_apl_prog (pr_cdcooper IN craprac.cdcooper%TYPE                  -- Código da Cooperativa
                                       ,pr_cdoperad IN crapope.cdoperad%TYPE                  -- Código do Operador 
                                       ,pr_nmdatela IN craptel.nmdatela%TYPE                  -- Nome da Tela
                                       ,pr_idorigem IN NUMBER                                 -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA                  
                                       ,pr_nrdconta IN craprac.nrdconta%TYPE                  -- Número da Conta
                                       ,pr_idseqttl IN crapttl.idseqttl%TYPE                  -- Titular da Conta
                                       ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE                  -- Número da Aplicação Programada
                                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE                  -- Data de Movimento
                                       ,pr_tab_dados_rpp OUT apli0001.typ_tab_dados_rpp       -- PLTable com os detalhes;
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE                 -- Código da crítica
                                       ,pr_dscritic OUT crapcri.dscritic%TYPE                 -- Descrição da crítica
   ) IS
    BEGIN
     /* .............................................................................

     Programa: pc_buscar_detalhe_apl_prog
     Sistema : Novos Produtos de Captação - Aplicação Programada
     Sigla   : APLI
     Autor   : CIS Corporate
     Data    : Julho/2018.                    Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a busca de detalhes de uma aplicação programada

     Observacao: -----

     Alteracoes: 
    ..............................................................................*/                
      
      DECLARE
        
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
            
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;      
            
      --Variáveis locais
      vr_vlsdrdpp NUMBER(25,8):=0;
    
      -- PLTable de retorno
      
      vr_tab_dados_rpp APLI0001.typ_tab_dados_rpp;
        
      -- Busca Aplicações de captação com seus lançamentos
      CURSOR cr_craprpp IS
      SELECT 
              nrctrrpp,
              cdagenci,
              nrdolote,
              cdbccxlt,
              dtmvtolt,
              dtvctopp,
              dtdebito,
              Extract(day from dtdebito) indiadeb,
              vlprerpp,
              qtprepag,
              vlprepag,
              vlrgtacu,
              dtinirpp,
              dtrnirpp,
              dtaltrpp,
              dtcancel,
         CASE cdsitrpp 
             WHEN 1 THEN 'Ativa'
             WHEN 2 THEN 'Suspensa'
             WHEN 3 THEN 'Cancelada'
             WHEN 4 THEN 'Cancelada' -- Suspensa e depois cancelada
             WHEN 5 THEN 'Vencida'  
             ELSE null END dssitrpp,
         CASE flgctain
             WHEN 0 THEN 'Sim'
             ELSE 'Nao' END flgctain
        FROM craprpp 
       WHERE cdcooper=pr_cdcooper 
         AND nrdconta=pr_nrdconta
         AND nrctrrpp=pr_nrctrrpp;
      rw_craprpp cr_craprpp%ROWTYPE;
      BEGIN -- Principal
          -- Recupera as informações do último movimento da da Apl. Programada
          OPEN cr_craprpp;
          FETCH cr_craprpp INTO rw_craprpp;
          IF cr_craprpp%NOTFOUND THEN
              vr_dscritic:='Aplicacao Programada nao encontrada';
              CLOSE cr_craprpp;
              RAISE vr_exc_saida;
          END IF;
          CLOSE cr_craprpp;
          -- Calcula o saldo atual
          apli0008.pc_calc_saldo_apl_prog (pr_cdcooper => pr_cdcooper,
                                           pr_cdprogra => pr_nmdatela,
                                           pr_cdoperad => pr_cdoperad,
                                           pr_nrdconta => pr_nrdconta,
                                           pr_idseqttl => pr_idseqttl,
                                           pr_idorigem => pr_idorigem,
                                           pr_nrctrrpp => pr_nrctrrpp,
                                           pr_dtmvtolt => pr_dtmvtolt,
                                           pr_vlsdrdpp => vr_vlsdrdpp,
                                           pr_des_erro => vr_dscritic);


          IF vr_dscritic is not null THEN
              RAISE vr_exc_saida;
          END IF;
          vr_tab_dados_rpp(1).nrctrrpp:=rw_craprpp.nrctrrpp;
          vr_tab_dados_rpp(1).cdagenci:=rw_craprpp.cdagenci;
          vr_tab_dados_rpp(1).cdbccxlt:=rw_craprpp.cdbccxlt;
          vr_tab_dados_rpp(1).nrdolote:=rw_craprpp.nrdolote;
          vr_tab_dados_rpp(1).dtmvtolt:=rw_craprpp.dtmvtolt;
          vr_tab_dados_rpp(1).dtvctopp:=rw_craprpp.dtvctopp;
          vr_tab_dados_rpp(1).dtdebito:=rw_craprpp.dtdebito;
          vr_tab_dados_rpp(1).indiadeb:=rw_craprpp.indiadeb;
          vr_tab_dados_rpp(1).vlprerpp:=rw_craprpp.vlprerpp;
          vr_tab_dados_rpp(1).qtprepag:=rw_craprpp.qtprepag;
          vr_tab_dados_rpp(1).vlprepag:=rw_craprpp.vlprepag;
          vr_tab_dados_rpp(1).vlrgtacu:=rw_craprpp.vlrgtacu;
          vr_tab_dados_rpp(1).vlsdrdpp:=vr_vlsdrdpp;
          vr_tab_dados_rpp(1).vljuracu:=(vr_vlsdrdpp+rw_craprpp.vlrgtacu)-rw_craprpp.vlprepag;
          vr_tab_dados_rpp(1).dtinirpp:=rw_craprpp.dtinirpp;
          vr_tab_dados_rpp(1).dtrnirpp:=rw_craprpp.dtrnirpp;
          vr_tab_dados_rpp(1).dtaltrpp:=rw_craprpp.dtaltrpp;
          vr_tab_dados_rpp(1).dtcancel:=rw_craprpp.dtcancel;
          vr_tab_dados_rpp(1).dssitrpp:=rw_craprpp.dssitrpp;
          vr_tab_dados_rpp(1).dsctainv:=rw_craprpp.flgctain;

          pr_tab_dados_rpp := vr_tab_dados_rpp;
      EXCEPTION
          WHEN vr_exc_saida THEN
               IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
                  vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
               END IF;

               -- Alimenta parametros com a crítica ocorrida
               pr_cdcritic := vr_cdcritic;
               pr_dscritic := vr_dscritic;

          WHEN OTHERS THEN
               pr_cdcritic := vr_cdcritic;
               pr_dscritic := 'Erro nao tratado APLI0008.pc_buscar_detalhe_apl_prog: ' || SQLERRM;

      END; -- Principal
  END pc_buscar_detalhe_apl_prog;
  
  PROCEDURE pc_buscar_detalhe_apl_prog_web (pr_nrdconta IN craprac.nrdconta%TYPE   -- Número da Conta
                                           ,pr_idseqttl IN crapttl.idseqttl%TYPE   -- Titular da Conta
                                           ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE   -- Número da Aplicação Programada.
                                           ,pr_dtmvtolt IN VARCHAR2                -- Data de Movimento Inicial
                                           ,pr_xmllog   IN VARCHAR2                -- XML com informacoes de LOG
                                           ,pr_cdcritic OUT PLS_INTEGER            -- Código da crítica
                                           ,pr_dscritic OUT VARCHAR2               -- Descrição da crítica
                                           ,pr_retxml   IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                                           ,pr_nmdcampo OUT VARCHAR2               -- Nome do campo com erro
                                           ,pr_des_erro OUT VARCHAR2)              -- Erros do processo

  IS
  BEGIN
   /* .............................................................................

   Programa: pc_buscar_detalhe_apl_prog_web
   Sistema : Novos Produtos de Captação - Aplicação Programada
   Sigla   : APLI
   Autor   : CIS Corporate
   Data    : Julho/2018.                    Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Rotina referente a busca de detalhes de uma aplicação programada - Mensageria. 

   Observacao: -----

   Alteracoes: 
  ..............................................................................*/                

  DECLARE
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    
    -- Variaveis auxiliares
    vr_exc_erro EXCEPTION;

    -- Variaveis de entrada
    vr_dtmvtolt Date := TO_DATE(pr_dtmvtolt,'dd/mm/yyyy');  

    -- Variaveis de retorno
    vr_tab_dados_rpp APLI0001.typ_tab_dados_rpp;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Variaveis de XML 
    vr_xml_temp VARCHAR2(32767);
    vr_clobxmlc CLOB;
    
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

    -- Busca as informações da apl. programada
    pc_buscar_detalhe_apl_prog(pr_cdcooper => vr_cdcooper,
                               pr_cdoperad => vr_cdoperad,
                               pr_nmdatela => vr_nmdatela,
                               pr_idorigem => vr_idorigem,
                               pr_nrdconta => pr_nrdconta,
                               pr_idseqttl => pr_idseqttl,
                               pr_nrctrrpp => pr_nrctrrpp,
                               pr_dtmvtolt => vr_dtmvtolt,
                               pr_tab_dados_rpp => vr_tab_dados_rpp,
                               pr_cdcritic => vr_cdcritic,
                               pr_dscritic => vr_dscritic);


    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;     

    IF vr_tab_dados_rpp.count >0 THEN
       -- Criar cabeçalho do XML
       dbms_lob.createtemporary(vr_clobxmlc, TRUE); 
       dbms_lob.open(vr_clobxmlc, dbms_lob.lob_readwrite);
       -- Insere o cabeçalho do XML 
       gene0002.pc_escreve_xml (pr_xml            => vr_clobxmlc 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>');

       gene0002.pc_escreve_xml(pr_xml            => vr_clobxmlc
                              ,pr_texto_completo => vr_xml_temp 
                              ,pr_texto_novo     => 
                              '<Registro>'||
                              '<cdbccxlt>'||vr_tab_dados_rpp(1).cdbccxlt||'</cdbccxlt>'||
                              '<nrdolote>'||vr_tab_dados_rpp(1).nrdolote||'</nrdolote>'||
                              '<dtmvtolt>'||to_char(vr_tab_dados_rpp(1).dtmvtolt,'dd/mm/yyyy')||'</dtmvtolt>'||
                              '<dtvctopp>'||to_char(vr_tab_dados_rpp(1).dtvctopp,'dd/mm/yyyy')||'</dtvctopp>'||
                              '<dtdebito>'||to_char(vr_tab_dados_rpp(1).dtdebito,'dd/mm/yyyy')||'</dtdebito>'||
                              '<indiadeb>'||vr_tab_dados_rpp(1).indiadeb||'</indiadeb>'||
                              '<vlprerpp>'||vr_tab_dados_rpp(1).vlprerpp||'</vlprerpp>'||
                              '<qtprepag>'||vr_tab_dados_rpp(1).qtprepag||'</qtprepag>'||
                              '<vlprepag>'||vr_tab_dados_rpp(1).vlprepag||'</vlprepag>'||
                              '<vlrgtacu>'||vr_tab_dados_rpp(1).vlrgtacu||'</vlrgtacu>'||
                              '<vlsdrdpp>'||vr_tab_dados_rpp(1).vlsdrdpp||'</vlsdrdpp>'||
                              '<vljuracu>'||vr_tab_dados_rpp(1).vljuracu||'</vljuracu>'||
                              '<dtinirpp>'||to_char(vr_tab_dados_rpp(1).dtinirpp,'dd/mm/yyyy')||'</dtinirpp>'||
                              '<dtrnirpp>'||to_char(vr_tab_dados_rpp(1).dtrnirpp,'dd/mm/yyyy')||'</dtrnirpp>'||
                              '<dtaltrpp>'||to_char(vr_tab_dados_rpp(1).dtaltrpp,'dd/mm/yyyy')||'</dtaltrpp>'||
                              '<dtcancel>'||to_char(vr_tab_dados_rpp(1).dtcancel,'dd/mm/yyyy')||'</dtcancel>'||
                              '<dssitrpp>'||vr_tab_dados_rpp(1).dssitrpp||'</dssitrpp>'||
                              '<dsctainv>'||vr_tab_dados_rpp(1).dsctainv||'</dsctainv>'||
                              '</Registro>'
                              );
       -- Encerrar a tag raiz 
       gene0002.pc_escreve_xml(pr_xml            => vr_clobxmlc 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => '</Dados></Root>' 
                               ,pr_fecha_xml      => TRUE);
                                 
       pr_retxml := XMLType.createXML(vr_clobxmlc);
    END IF;

  Exception
    When vr_exc_erro Then
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        
    When others Then
      pr_cdcritic := null; -- não será utilizado
      pr_dscritic := 'Erro geral em APLI0008.pc_buscar_extrato_apl_prog_web: '||SQLERRM;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
      
  END;


  END pc_buscar_detalhe_apl_prog_web;





END APLI0008; 
/
