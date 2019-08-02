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
              
  Alteracoes: 28/07/2019 - Correcao na busca do sequencial da tabela CRAPLOT. 
                           Deve ser gerado pela FN_SEQUENCE.
                           Heitor (Mouts) - Projeto Revitalizacao Sustentacao.
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

  --Definicao do tipo de registro para poupanca-programada/aplicacao-programada
  TYPE typ_reg_dados_rpp IS
    RECORD (nrctrrpp craprpp.nrctrrpp%TYPE
           ,cdagenci crapage.cdagenci%TYPE
           ,cdbccxlt craplot.cdbccxlt%TYPE
           ,nrdolote craplot.nrdolote%TYPE
           ,dtmvtolt crapdat.dtmvtolt%TYPE
           ,dtvctopp crapdat.dtmvtolt%TYPE
           ,dtdebito crapdat.dtmvtolt%TYPE
           ,indiadeb INTEGER               -- Dia de debito
           ,vlprerpp craprpp.vlprerpp%TYPE -- Valor da parcela
           ,qtprepag craprpp.qtprepag%TYPE -- Quantidade de parcelas pagas 
           ,vlprepag craprpp.vlprepag%TYPE -- Total depositado
           ,vlsdrdpp craprpp.vlsdrdpp%TYPE -- Saldo disponivel para resgate
           ,vlsdtoap craprpp.vlsdrdpp%TYPE -- Saldo total
           ,vlrgtrpp NUMBER                
           ,vljuracu craprpp.vljuracu%TYPE -- Valor dos juros acumulados do plano.
           ,vlrgtacu craprpp.vlrgtacu%TYPE -- Valor dos resgates acumulados.
           ,dtinirpp craprpp.dtinirpp%TYPE -- Data de inicio da poupanca programada. (não contratação)
           ,dtrnirpp craprpp.dtrnirpp%TYPE
           ,dtaltrpp craprpp.dtaltrpp%TYPE
           ,dtcancel craprpp.dtcancel%TYPE
           ,cdsitrpp craprpp.cdsitrpp%TYPE
           ,dssitrpp VARCHAR2(10)
           ,dsblqrpp VARCHAR2(3)
           ,dsresgat VARCHAR2(3)
           ,dsctainv VARCHAR2(3)
           ,dsmsgsaq VARCHAR2(40)
           ,cdtiparq INTEGER
           ,dtsldrpp crapdat.dtmvtolt%TYPE
           ,cdprodut crapcpc.cdprodut%TYPE
           ,dsfinali craprpp.dsfinali%TYPE
           ,flgteimo craprpp.flgteimo%TYPE
           ,flgdbpar craprpp.flgdbpar%TYPE
           ,nrdrowid ROWID);

  --Definicao do tipo de tabela para poupanca-programada/aplicacao-programada
  TYPE typ_tab_dados_rpp IS
    TABLE OF typ_reg_dados_rpp
    INDEX BY BINARY_INTEGER;   

  --Definicao do tipo de registro para poupanca-programada/aplicacao-programada
  TYPE typ_reg_saldo_rpp IS
    RECORD (nraplica craprac.nraplica%TYPE
     ,vlaplica craprac.vlaplica%TYPE
     ,tpresgat INTEGER
     ,qtdiacar craprac.qtdiacar%TYPE
     ,dtvencto DATE
     ,dtcarenc DATE
     ,vlsldtot NUMBER(20,8) --> Valor de saldo total
     ,vlsldrgt NUMBER(20,8) --> Valor de saldo de resgate
     ,vlultren NUMBER(20,8) --> Valor de ultimo rendimento
     ,vlrentot NUMBER(20,8) --> Valor de rendimento total
     ,vlrevers NUMBER(20,8) --> Valor de reversao
     ,vlrdirrf NUMBER(20,8) --> Valor de IRRF
     ,percirrf NUMBER(20,8)); --> Valor percentual de IRRF

  --Definicao do tipo de tabela para poupanca-programada/aplicacao-programada
  TYPE typ_tab_saldo_rpp IS
    TABLE OF typ_reg_saldo_rpp
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
                                                                 
  /* Procedure para alterar uma aplicação programada */
  PROCEDURE pc_alterar_apl_prog (pr_cdcooper IN crapcop.cdcooper%TYPE             --> Código da cooperativa
                                ,pr_cdagenci IN crapage.cdagenci%TYPE             --> Código da agência
                                ,pr_cdoperad IN crapope.cdoperad%TYPE             --> Código do operador
                                ,pr_nmdatela VARCHAR2                             --> Nome da tela
                                ,pr_idorigem IN INTEGER                           --> Código de origem
                                ,pr_nrdconta IN craprpp.nrdconta%TYPE             --> Número da conta
                                ,pr_idseqttl IN crapttl.idseqttl%TYPE             --> Sequêncial do titular   
                                ,pr_dtmvtolt IN craprpp.dtmvtolt%TYPE             --> Data do movimento atual
                                ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE             --> Número do Contrato - CRAPRPP
                                ,pr_vlprerpp IN craprpp.vlprerpp%TYPE             --> Valor da parcela
                                ,pr_indebito IN INTEGER                           --> Dia de debito
                                ,pr_dtdebito IN craprpp.dtdebito%TYPE             --> Data do proximo débito
                                ,pr_dsfinali IN craprpp.dsfinali%TYPE             --> Finalidade do fundo (proveniente da tela)
                                ,pr_flgerlog IN INTEGER                           --> Gerar log (0 = Não / 1 = Sim)
                                ,pr_nrdrowid OUT rowid                            --> Oracle ROWID
                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE            --> Codigo da critica de erro
                                ,pr_dscritic OUT crapcri.dscritic%TYPE);          --> Descricao da critica de erro

  /* Procedure para alterar uma aplicação programada  - Mensageria */
  PROCEDURE pc_alterar_apl_prog_web (pr_nrdconta IN craprpp.nrdconta%TYPE  --> Número da conta
                                    ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequêncial do titular   
                                    ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE  --> Número do Contrato - CRAPRPP
                                    ,pr_dtmvtolt IN VARCHAR2               --> Data do movimento atual - DD/MM/YYYY
                                    ,pr_vlprerpp IN craprpp.vlprerpp%TYPE  --> Valor da parcela
                                    ,pr_indebito IN INTEGER                --> Dia de debito
                                    ,pr_dtdebito IN VARCHAR2               --> Data do proximo débito
                                    ,pr_dsfinali IN craprpp.dsfinali%TYPE  --> Finalidade do fundo (proveniente da tela)
                                    ,pr_flgerlog IN INTEGER                --> Gerar log (0 = Não / 1 = Sim)
                                    ,pr_xmllog   IN VARCHAR2               --> XML com informacoes de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);            --> Erros do processo   
                                                                                                  
  /* Procedure para cancelar uma aplicação programada */
  PROCEDURE pc_cancelar_apl_prog (pr_cdcooper IN crapcop.cdcooper%TYPE             --> Código da cooperativa
                                ,pr_cdagenci IN crapage.cdagenci%TYPE             --> Código da agência
                                ,pr_cdoperad IN crapope.cdoperad%TYPE             --> Código do operador
                                ,pr_nmdatela VARCHAR2                             --> Nome da tela
                                ,pr_idorigem IN INTEGER                           --> Código de origem
                                ,pr_nrdconta IN craprpp.nrdconta%TYPE             --> Número da conta
                                ,pr_idseqttl IN crapttl.idseqttl%TYPE             --> Sequêncial do titular   
                                ,pr_dtmvtolt IN craprpp.dtmvtolt%TYPE             --> Data do movimento atual
                                ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE             --> Número do Contrato - CRAPRPP
                                ,pr_flgerlog IN INTEGER                           --> Gerar log (0 = Não / 1 = Sim)
                                ,pr_nrdrowid OUT rowid                            --> Oracle ROWID
                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE            --> Codigo da critica de erro
                                ,pr_dscritic OUT crapcri.dscritic%TYPE);          --> Descricao da critica de erro

  /* Procedure para cancelar uma aplicação programada  - Mensageria */
  PROCEDURE pc_cancelar_apl_prog_web (pr_nrdconta IN craprpp.nrdconta%TYPE  --> Número da conta
                                    ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequêncial do titular   
                                    ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE  --> Número do Contrato - CRAPRPP
                                    ,pr_dtmvtolt IN VARCHAR2               --> Data do movimento atual - DD/MM/YYYY
                                    ,pr_flgerlog IN INTEGER                --> Gerar log (0 = Não / 1 = Sim)
                                    ,pr_xmllog   IN VARCHAR2               --> XML com informacoes de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);            --> Erros do processo   

  /* Procedure para suspender uma aplicação programada */
  PROCEDURE pc_suspender_apl_prog (pr_cdcooper IN crapcop.cdcooper%TYPE             --> Código da cooperativa
                                ,pr_cdagenci IN crapage.cdagenci%TYPE             --> Código da agência
                                ,pr_cdoperad IN crapope.cdoperad%TYPE             --> Código do operador
                                ,pr_nmdatela VARCHAR2                             --> Nome da tela
                                ,pr_idorigem IN INTEGER                           --> Código de origem
                                ,pr_nrdconta IN craprpp.nrdconta%TYPE             --> Número da conta
                                ,pr_idseqttl IN crapttl.idseqttl%TYPE             --> Sequêncial do titular   
                                ,pr_dtmvtolt IN craprpp.dtmvtolt%TYPE             --> Data do movimento atual
                                ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE             --> Número do Contrato - CRAPRPP
                                ,pr_nrmesusp IN INTEGER                          --> Periodo de Suspensão em meses
                                ,pr_flgerlog IN INTEGER                           --> Gerar log (0 = Não / 1 = Sim)
                                ,pr_nrdrowid OUT rowid                            --> Oracle ROWID
                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE            --> Codigo da critica de erro
                                ,pr_dscritic OUT crapcri.dscritic%TYPE);          --> Descricao da critica de erro

  /* Procedure para suspender uma aplicação programada  - Mensageria */
  PROCEDURE pc_suspender_apl_prog_web (pr_nrdconta IN craprpp.nrdconta%TYPE  --> Número da conta
                                    ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequêncial do titular   
                                    ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE  --> Número do Contrato - CRAPRPP
                                    ,pr_nrmesusp IN INTEGER                --> Periodo de Suspensão em meses
                                    ,pr_dtmvtolt IN VARCHAR2               --> Data do movimento atual - DD/MM/YYYY
                                    ,pr_flgerlog IN INTEGER                --> Gerar log (0 = Não / 1 = Sim)
                                    ,pr_xmllog   IN VARCHAR2               --> XML com informacoes de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);            --> Erros do processo   

  /* Procedure para reativar uma aplicação programada */
  PROCEDURE pc_reativar_apl_prog (pr_cdcooper IN crapcop.cdcooper%TYPE             --> Código da cooperativa
                                ,pr_cdagenci IN crapage.cdagenci%TYPE             --> Código da agência
                                ,pr_cdoperad IN crapope.cdoperad%TYPE             --> Código do operador
                                ,pr_nmdatela VARCHAR2                             --> Nome da tela
                                ,pr_idorigem IN INTEGER                           --> Código de origem
                                ,pr_nrdconta IN craprpp.nrdconta%TYPE             --> Número da conta
                                ,pr_idseqttl IN crapttl.idseqttl%TYPE             --> Sequêncial do titular   
                                ,pr_dtmvtolt IN craprpp.dtmvtolt%TYPE             --> Data do movimento atual
                                ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE             --> Número do Contrato - CRAPRPP
                                ,pr_flgerlog IN INTEGER                           --> Gerar log (0 = Não / 1 = Sim)
                                ,pr_nrdrowid OUT rowid                            --> Oracle ROWID
                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE            --> Codigo da critica de erro
                                ,pr_dscritic OUT crapcri.dscritic%TYPE);          --> Descricao da critica de erro

  /* Procedure para reativar uma aplicação programada  - Mensageria */
  PROCEDURE pc_reativar_apl_prog_web (pr_nrdconta IN craprpp.nrdconta%TYPE  --> Número da conta
                                    ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequêncial do titular   
                                    ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE  --> Número do Contrato - CRAPRPP
                                    ,pr_dtmvtolt IN VARCHAR2               --> Data do movimento atual - DD/MM/YYYY
                                    ,pr_flgerlog IN INTEGER                --> Gerar log (0 = Não / 1 = Sim)
                                    ,pr_xmllog   IN VARCHAR2               --> XML com informacoes de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType     --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2              --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);            --> Erros do processo   

  /* Procedure para calcular diversos valores de uma aplicacao programada a partir da RPP */
   PROCEDURE pc_posicao_saldo_apl_prog (pr_cdcooper IN crapcop.cdcooper%TYPE     --> Cooperativa
                                       ,pr_cdprogra IN crapres.cdprogra%TYPE     --> Programa que esta executando
                                       ,pr_cdoperad IN craplrg.cdoperad%TYPE     --> Codigo do Operador
                                       ,pr_nrdconta IN craprpp.nrdconta%TYPE     --> Numero da conta da aplicacao
                                       ,pr_idseqttl IN INTEGER                   --> Identificador Sequencial
                                       ,pr_idorigem IN INTEGER                   --> Identificador da Origem
                                       ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE     --> Numero do contrato 
                                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE     --> Data do movimento atual
                                       ,pr_inrendim IN PLS_INTEGER default 1     --> Carrega o rendimento (pr_vlrebtap) [1 - Sim, 0 - Nao]
                                       ,pr_vlbascal OUT NUMBER                   --> Valor Base Total
                                       ,pr_vlsdtoap OUT NUMBER                   --> Valor de Saldo Total
                                       ,pr_vlsdrgap OUT NUMBER                   --> Valor do saldo disponível para resgate
                                       ,pr_vlrebtap OUT NUMBER                   --> Valor de rendimento bruto total
                                       ,pr_vlrdirrf OUT NUMBER                   --> Valor de IRRF
                                       ,pr_des_erro OUT VARCHAR2);   
                                                                 
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

  /* Procedure referente a busca de extratos das aplicações programadas a partir da RPP Canais */    
  PROCEDURE pc_buscar_extrato_apl_prog_car (pr_cdcooper IN craprac.cdcooper%TYPE                  -- Código da Cooperativa
                                           ,pr_cdoperad IN crapope.cdoperad%TYPE                  -- Código do Operador 
                                           ,pr_nmdatela IN craptel.nmdatela%TYPE                  -- Nome da Tela
                                           ,pr_idorigem IN NUMBER   -- Código de Origem
                                           ,pr_nrdconta IN craprac.nrdconta%TYPE   -- Número da Conta
                                           ,pr_idseqttl IN crapttl.idseqttl%TYPE                  -- Titular da Conta
                                           ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE   -- Número da Aplicação Programada.
                                           ,pr_dtmvtolt_ini IN DATE            -- Data de Movimento Inicial
                                           ,pr_dtmvtolt_fim IN DATE            -- Data de Movimento Fim
                                           ,pr_idlstdhs IN NUMBER                  -- Identificador de Listagem de Todos Históricos (Fixo na chamada, 0 – Não / 1 – Sim)
                                           ,pr_idgerlog IN NUMBER                  -- Identificador de Log (Fixo na chamada, 0 – Não / 1 – Sim)
                                           ,pr_xmllog   IN VARCHAR2                -- XML com informacoes de LOG
                                           ,pr_cdcritic OUT PLS_INTEGER            -- Código da crítica
                                           ,pr_dscritic OUT VARCHAR2               -- Descrição da crítica
                                           ,pr_clobxmlc   OUT CLOB                   -- Arquivo de retorno do XML
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
                                       ,pr_tab_dados_rpp OUT typ_tab_dados_rpp                -- PLTable com os detalhes;
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

  /* Recuperar lista das poupancas programadas e aplicações programadas */
  PROCEDURE pc_lista_poupanca (pr_cdcooper IN crapcop.cdcooper%TYPE            --> Cooperativa
                              ,pr_cdagenci IN crapage.cdagenci%TYPE            --> Codigo da Agencia
                              ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE            --> Numero do caixa
                              ,pr_cdoperad IN craplrg.cdoperad%TYPE            --> Codigo do Operador
                              ,pr_idorigem IN INTEGER                          --> Identificador da Origem
                              ,pr_nrdconta IN craprda.nrdconta%TYPE            --> Nro da conta da aplicacao RDCA
                              ,pr_idseqttl IN INTEGER                          --> Identificador Sequencial
                              ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE            --> Contrato Poupanca Programada
                              ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE            --> Data do movimento atual
                              ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE            --> Data do proximo movimento
                              ,pr_inproces IN crapdat.inproces%TYPE            --> Indicador de processo
                              ,pr_cdprogra IN crapprg.cdprogra%TYPE            --> Nome do programa chamador
                              ,pr_flgerlog IN BOOLEAN                          --> Flag erro log
                              ,pr_percenir IN NUMBER                           --> % IR para Calculo Poupanca
                              ,pr_tpapprog IN INTEGER default 0                --> Tipo de aplicacao poupanca (1 = Poupanca Antiga, 2 = Aplicações Programadas, 0 = Ambas)
                              ,pr_tpinvest IN INTEGER default 3                --> Tipo de aplicacao poupanca (1 = Poupanca Antiga, 2 = Aplicações Programadas, 0 = Ambas)
                              ,pr_situacao IN INTEGER default 4                --> Tipo de aplicacao poupanca (1 = Poupanca Antiga, 2 = Aplicações Programadas, 0 = Ambas)
                              ,pr_vlsldrpp OUT NUMBER                          --> Valor saldo total poupanca programada
                              ,pr_retorno  OUT VARCHAR2                        --> Descricao de erro ou sucesso OK/NOK
                              ,pr_tab_dados_rpp OUT typ_tab_dados_rpp          --> Poupancas Programadas
                              ,pr_tab_erro      IN OUT NOCOPY GENE0001.typ_tab_erro);  --> Saida com erros;

  /* Recuperar lista das poupancas programadas e aplicações programadas - Mensageria*/
  PROCEDURE pc_lista_poupanca_web (pr_nrdconta IN craprda.nrdconta%TYPE  -- Nro da conta da aplicacao RDCA
                                  ,pr_idseqttl IN INTEGER                -- Identificador Sequencial
                                  ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE  -- Contrato Poupanca Programada
                                  ,pr_dtmvtolt IN VARCHAR2               --> Data do movimento atual
                                  ,pr_dtmvtopr IN VARCHAR2               --> Data do proximo movimento
                                  ,pr_inproces IN crapdat.inproces%TYPE  -- Indicador de processo
                                  ,pr_flgerlog IN INTEGER                -- Flag erro log
                                  ,pr_percenir IN NUMBER                 -- % IR para Calculo Poupanca
                                  ,pr_tpapprog IN INTEGER default 0      -- Tipo de aplicacao poupanca (1 = Poupanca Antiga, 2 = Aplicações Programadas, 0 = Ambas)
                                  ,pr_xmllog   IN VARCHAR2               -- XML com informacoes de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER           -- Código da crítica
                                  ,pr_dscritic OUT VARCHAR2              -- Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType     -- Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2              -- Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2);            -- Erros do processo

  /* Obter dados para alterar ou suspender poupanca/aplicacao programada */
  PROCEDURE pc_obtem_dados_alte_susp (pr_cdcooper IN craprpp.cdcooper%TYPE              -- Código da Cooperativa
                                     ,pr_cdagenci IN craprpp.cdagenci%TYPE              -- Código da Agencia
                                     ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE              -- Numero do caixa
                                     ,pr_cdoperad IN crapope.cdoperad%TYPE              -- Código do Operador 
                                     ,pr_nmdatela IN craptel.nmdatela%TYPE              -- Nome da Tela
                                     ,pr_idorigem IN NUMBER                             -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA                  
                                     ,pr_nrdconta IN craprpp.nrdconta%TYPE              -- Número da Conta
                                     ,pr_idseqttl IN crapttl.idseqttl%TYPE              -- Titular da Conta
                                     ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE              -- Número da Aplicação Programada
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE              -- Data de Movimento
                                     ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE              -- Data da Operação
                                     ,pr_tpoperac IN PLS_INTEGER                        -- Tipo de Operacao - 1 = Alterar, 2 = Suspender
                                     ,pr_inproces IN PLS_INTEGER                        --
                                     ,pr_flgerlog IN BOOLEAN                            -- Flag erro log
                                     ,pr_retorno  OUT VARCHAR2                          -- Descricao de erro ou sucesso OK/NOK
                                     ,pr_tab_dados_rpp OUT typ_tab_dados_rpp            -- PLTable com os detalhes
                                     ,pr_tab_erro IN OUT NOCOPY GENE0001.typ_tab_erro); -- Saida com erros

  /* Obter dados para alterar poupanca/aplicacao programada - Mensageria */
  PROCEDURE pc_obtem_dados_alteracao_web (pr_nrdconta IN crapass.nrdconta%TYPE  -- Nro da conta da aplicacao 
                                         ,pr_idseqttl IN INTEGER                -- Identificador Sequencial
                                         ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE  -- Contrato Poupanca Programada
                                         ,pr_dtmvtolt IN VARCHAR2               -- Data do movimento atual
                                         ,pr_dtmvtopr IN VARCHAR2               -- Data do proximo movimento
                                         ,pr_inproces IN crapdat.inproces%TYPE  -- Indicador de processo
                                         ,pr_flgerlog IN INTEGER                -- Flag erro log
                                         ,pr_xmllog   IN VARCHAR2               -- XML com informacoes de LOG
                                         ,pr_cdcritic OUT PLS_INTEGER           -- Código da crítica
                                         ,pr_dscritic OUT VARCHAR2              -- Descrição da crítica
                                         ,pr_retxml   IN OUT NOCOPY XMLType     -- Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2              -- Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2);             -- Erros do processo

	/* Obter dados para suspender poupanca/aplicacao programada - Mensageria */
  PROCEDURE pc_obtem_dados_suspensao_web (pr_nrdconta IN crapass.nrdconta%TYPE  -- Nro da conta da aplicacao 
                                         ,pr_idseqttl IN INTEGER                -- Identificador Sequencial
                                         ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE  -- Contrato Poupanca Programada
                                         ,pr_dtmvtolt IN VARCHAR2               -- Data do movimento atual
                                         ,pr_dtmvtopr IN VARCHAR2               -- Data do proximo movimento
                                         ,pr_inproces IN crapdat.inproces%TYPE  -- Indicador de processo
                                         ,pr_flgerlog IN INTEGER                -- Flag erro log
                                         ,pr_xmllog   IN VARCHAR2               -- XML com informacoes de LOG
                                         ,pr_cdcritic OUT PLS_INTEGER           -- Código da crítica
                                         ,pr_dscritic OUT VARCHAR2              -- Descrição da crítica
                                         ,pr_retxml   IN OUT NOCOPY XMLType     -- Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2              -- Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2);             -- Erros do processo

  /* Recuperar lista das aplicações programadas para o processo na B3 */
  PROCEDURE pc_lista_aplicacoes_progr(pr_cdcooper    IN craprac.cdcooper%TYPE           --> Código da Cooperativa
															 ,pr_cdoperad    IN crapope.cdoperad%TYPE           --> Código do Operador
															 ,pr_nmdatela    IN craptel.nmdatela%TYPE           --> Nome da Tela
															 ,pr_idorigem    IN INTEGER                         --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA                  
                                                             ,pr_nrdcaixa    IN craplot.nrdcaixa%TYPE           --> Numero do Caixa                  
                                                             ,pr_nrdconta    IN craprac.nrdconta%TYPE           --> Número da Conta
															 ,pr_idseqttl    IN crapttl.idseqttl%TYPE           --> Titular da Conta
                                                             ,pr_cdagenci    IN crapage.cdagenci%TYPE           --> Codigo da Agencia
                                                             ,pr_cdprogra    IN craplog.cdprogra%TYPE           --> Codigo do Programa
															 ,pr_nraplica    IN craprac.nraplica%TYPE DEFAULT 0 --> Número da Aplicação - Parâmetro Opcional
															 ,pr_cdprodut    IN craprac.cdprodut%TYPE DEFAULT 0 --> Código do Produto – Parâmetro Opcional 
															 ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE           --> Data de Movimento
															 ,pr_idconsul    IN INTEGER                         --> Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas)
															 ,pr_idgerlog    IN INTEGER                         --> Identificador de Log (0 – Não / 1 – Sim) 																 
															 ,pr_tpaplica    IN PLS_INTEGER DEFAULT 0           --> Tipo Aplicacao (0 - Todas / 1 - Não PCAPTA (RDC PÓS, PRE e RDCA) / 2 - Apenas PCAPTA)
															 ,pr_cdcritic   OUT INTEGER                         --> Código da crítica
															 ,pr_dscritic   OUT VARCHAR2                        --> Descrição da crítica
															 ,pr_saldo_rdca OUT apli0001.typ_tab_saldo_rdca);   --> Tabela com os dados da aplicação

  /* Recuperar o detalhe das aplicações programadas para o processo na B3 */
	PROCEDURE pc_busca_aplicacoes_prog(pr_cdcooper IN craprac.cdcooper%TYPE             --> Código da Cooperativa
				 ,pr_cdoperad IN crapope.cdoperad%TYPE             --> Código do Operador
				 ,pr_nmdatela IN craptel.nmdatela%TYPE             --> Nome da Tela
				 ,pr_idorigem IN INTEGER                           --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA                  
				 ,pr_nrdconta IN craprac.nrdconta%TYPE             --> Número da Conta
				 ,pr_idseqttl IN crapttl.idseqttl%TYPE             --> Titular da Conta
				 ,pr_nraplica IN craprac.nraplica%TYPE DEFAULT 0   --> Número da Aplicação - Parâmetro Opcional
				 ,pr_cdprodut IN craprac.cdprodut%TYPE DEFAULT 0   --> Código do Produto – Parâmetro Opcional 
				 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE             --> Data de Movimento
				 ,pr_idconsul IN INTEGER                           --> Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas)
				 ,pr_idgerlog IN INTEGER                           --> Identificador de Log (0 – Não / 1 – Sim) 																 
				 ,pr_cdcritic OUT INTEGER                          --> Código da crítica
				 ,pr_dscritic OUT VARCHAR2                         --> Descrição da crítica
				 ,pr_tab_aplica OUT apli0005.typ_tab_aplicacao);   --> Tabela com os dados da aplicação

  /* Processar o detalhe das aplicações programadas no resgate e provisap */
procedure pc_calc_app_programada (pr_cdcooper  in crapcop.cdcooper%type,          --> Cooperativa
                              pr_dstextab  in craptab.dstextab%type,          --> Percentual de IR da aplicação
                              pr_cdprogra  in crapprg.cdprogra%type,          --> Programa chamador
                              pr_inproces  in crapdat.inproces%type,          --> Indicador do processo
                              pr_dtmvtolt  in crapdat.dtmvtolt%type,          --> Data do processo
                              pr_dtmvtopr  in crapdat.dtmvtopr%type,          --> Próximo dia útil
                              pr_rpp_rowid in varchar2,                       --> Identificador do registro da tabela CRAPRPP em processamento
                              pr_vlsdrdpp  in out craprpp.vlsdrdpp%type,      --> Saldo da poupança programada
                              pr_cdcritic out crapcri.cdcritic%type,          --> Codigo da crítica de erro
                              pr_des_erro out varchar2);                    --> Descrição do erro encontrado

  -- Rotina para geração do Termo de Adesão de uma aplicação programada  
  PROCEDURE pc_impres_termo_adesao_ap(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                     ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Código da agencia
                                     ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                     ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Código do Operador
                                     ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da Tela
                                     ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                     ,pr_cdprogra IN crapprg.cdprogra%TYPE  --> Codigo do programa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de Movimento
                                     ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE  --> Contrato
                                     ,pr_flgerlog IN INTEGER                --> Indicador se deve gerar log(0-nao, 1-sim)
                                     ,pr_nmarqpdf OUT VARCHAR2              --> Nome do PDF                           
                                     ,pr_dssrvarq OUT VARCHAR2              --> Diretorio do servidor do PDF                           
                                     ,pr_dsdirarq OUT VARCHAR2              --> Diretorio do PDF                           
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2);            --> Descrição da crítica

  -- Rotina para geração do Termo de Adesão de uma aplicação programada  - Mensageria
  PROCEDURE pc_impres_termo_adesao_ap_web (pr_nrdconta IN craprac.nrdconta%TYPE   -- Número da Conta
                                          ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE   -- Número da Aplicação Programada.
                                          ,pr_dtmvtolt IN VARCHAR2                -- Data de Movimento Inicial
                                          ,pr_flgerlog IN INTEGER                --> Indicador se deve gerar log(0-nao, 1-sim)
                                          ,pr_xmllog   IN VARCHAR2                -- XML com informacoes de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER            -- Código da crítica
                                          ,pr_dscritic OUT VARCHAR2               -- Descrição da crítica
                                          ,pr_retxml   IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2               -- Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2);             -- Erros do processo

  PROCEDURE pc_val_resgate_apl_prog (pr_cdcooper IN crapcop.cdcooper%TYPE             --> Código da cooperativa
                                    ,pr_cdagenci IN crapage.cdagenci%TYPE             --> Código da agência
                                    ,pr_nrdcaixa IN INTEGER                           --> Número do caixa
                                    ,pr_cdoperad IN crapope.cdoperad%TYPE             --> Código do operador
                                    ,pr_nmdatela VARCHAR2                             --> Nome da tela
                                    ,pr_idorigem IN INTEGER                           --> Código de origem
                                    ,pr_nrdconta IN craprpp.nrdconta%TYPE             --> Número da conta
                                    ,pr_idseqttl IN crapttl.idseqttl%TYPE             --> Sequêncial do titular   
                                    ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE             --> Código do contrato da poupança
                                    ,pr_dtmvtolt IN craprpp.dtmvtolt%TYPE             --> Data do movimento atual
                                    ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE             --> Data do proximo movimento
                                    ,pr_inproces IN crapdat.inproces%TYPE             --> Indicador de processo
                                    ,pr_cdprogra IN crapprg.cdprogra%TYPE             --> Nome do programa chamador
                                    ,pr_tpresgat IN VARCHAR2                          --> Tipo de Resgate (T = Total / P = Parcial)
                                    ,pr_vlresgat IN craplrg.vllanmto%TYPE             --> Valor do resgate
                                   	,pr_dtresgat IN craplrg.dtresgat%TYPE             --> Data para resgate
                                    ,pr_flgoprgt IN INTEGER DEFAULT 0                 --> Flag Op. Resgate ( 0 = Validar dados do resgate / 1 = Validar acesso a opcao resgate)
                                    ,pr_cdopeaut IN crapope.cdoperad%TYPE             --> Código do operador autorizacao
                                    ,pr_cddsenha IN crapope.cddsenha%TYPE             --> Senha do operador
                                    ,pr_flgsenha IN INTEGER                           --> Senha (0 = Não / 1 = Sim)
                                    ,pr_flgerlog IN INTEGER                           --> Gerar log (0 = Não / 1 = Sim)
                                    ,pr_vlsldrpp OUT NUMBER                           --> Valor do saldo
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE            --> Codigo da critica de erro
                                    ,pr_dscritic OUT crapcri.dscritic%TYPE);          --> Descricao da critica de erro
                                        
  PROCEDURE pc_val_resgate_apl_prog_web (pr_nrdconta IN craprac.nrdconta%TYPE -- Número da Conta
                                        ,pr_idseqttl IN crapttl.idseqttl%TYPE -- Sequêncial do titular   
                                        ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE -- Número da Aplicação Programada.
                                        ,pr_dtmvtolt IN VARCHAR2              -- Data de Movimento 
                                        ,pr_dtmvtopr IN VARCHAR2              -- Data do proximo movimento
                                        ,pr_inproces IN crapdat.inproces%TYPE -- Indicador de processo
                                        ,pr_tpresgat IN VARCHAR2              -- Tipo de Resgate (T = Total / P = Parcial)
                                        ,pr_vlresgat IN craplrg.vllanmto%TYPE -- Valor do resgate
                                        ,pr_dtresgat IN VARCHAR2              -- Data para resgate
                                        ,pr_flgoprgt IN INTEGER               -- Flag Op. Resgate ( 0 = Validar dados do resgate / 1 = Validar acesso a opcao resgate)
                                        ,pr_cdopeaut IN crapope.cdoperad%TYPE -- Código do operador autorizacao
                                        ,pr_cddsenha IN crapope.cddsenha%TYPE -- Senha do operador
                                        ,pr_flgsenha IN INTEGER               -- Senha (0 = Não / 1 = Sim)
                                        ,pr_flgerlog IN INTEGER               -- Indicador se deve gerar log(0-nao, 1-sim)
                                        ,pr_xmllog   IN VARCHAR2              -- XML com informacoes de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER          -- Código da crítica
                                        ,pr_dscritic OUT VARCHAR2             -- Descrição da crítica
                                        ,pr_retxml   IN OUT NOCOPY XMLType    -- Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2             -- Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2);           -- Erros do processo                                        
 
  PROCEDURE pc_efet_resgate_apl_prog (pr_cdcooper IN crapcop.cdcooper%TYPE    -- Código da cooperativa
                                     ,pr_cdagenci IN crapage.cdagenci%TYPE    -- Código da agência
                                     ,pr_nrdcaixa IN INTEGER                  -- Número do caixa
                                     ,pr_cdoperad IN crapope.cdoperad%TYPE    -- Código do operador
                                     ,pr_nmdatela VARCHAR2                    -- Nome da tela
                                     ,pr_idorigem IN INTEGER                  -- Código de origem
                                     ,pr_nrdconta IN craprpp.nrdconta%TYPE    -- Número da conta
                                     ,pr_idseqttl IN crapttl.idseqttl%TYPE    -- Sequêncial do titular   
                                     ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE    -- Código do contrato da poupança
                                     ,pr_dtmvtolt IN craprpp.dtmvtolt%TYPE    -- Data do movimento atual
                                     ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE    -- Data do proximo movimento
                                     ,pr_tpresgat IN VARCHAR2                 -- Tipo de Resgate (T = Total / P = Parcial)
                                     ,pr_vlresgat IN craplrg.vllanmto%TYPE    -- Valor do resgate
                                     ,pr_dtresgat IN craplrg.dtresgat%TYPE    -- Data para resgate
                                     ,pr_flgctain IN INTEGER                  -- Flag Conta Investimento ( 0 = Não / 1 = Sim)
                                     ,pr_flgerlog IN INTEGER                  -- Gerar log (0 = Não / 1 = Sim)
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE   -- Codigo da critica de erro
                                     ,pr_dscritic OUT crapcri.dscritic%TYPE); -- Descricao da critica de erro

  PROCEDURE pc_efet_resgate_apl_prog_web (pr_nrdconta IN craprac.nrdconta%TYPE -- Número da Conta
                                         ,pr_idseqttl IN crapttl.idseqttl%TYPE -- Sequêncial do titular   
                                         ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE -- Número da Aplicação Programada.
                                         ,pr_dtmvtolt IN VARCHAR2              -- Data de Movimento 
                                         ,pr_dtmvtopr IN VARCHAR2              -- Data do proximo movimento
                                         ,pr_inproces IN crapdat.inproces%TYPE -- Indicador de processo
                                         ,pr_tpresgat IN VARCHAR2              -- Tipo de Resgate (T = Total / P = Parcial)
                                         ,pr_vlresgat IN craplrg.vllanmto%TYPE -- Valor do resgate
                                         ,pr_dtresgat IN VARCHAR2              -- Data para resgate
                                         ,pr_flgctain IN VARCHAR2              -- Flag Conta Investimento ( yes / no )
                                         ,pr_flgerlog IN INTEGER               -- Indicador se deve gerar log(0-nao, 1-sim)
                                         ,pr_xmllog   IN VARCHAR2              -- XML com informacoes de LOG
                                         ,pr_cdcritic OUT PLS_INTEGER          -- Código da crítica
                                         ,pr_dscritic OUT VARCHAR2             -- Descrição da crítica
                                         ,pr_retxml   IN OUT NOCOPY XMLType    -- Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2             -- Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2);           -- Erros do processo

  /* Recupera a configuração da apl. programada de uma cooperativa + Produto */
  PROCEDURE pc_buscar_conf_apl_prog (pr_cdcooper IN crapcop.cdcooper%TYPE                                 --> Código da cooperativa a ser alterada 
                                    ,pr_cdprodut IN crapcpc.cdprodut%TYPE                                 --> Código do produto
                                    ,pr_idconfig OUT tbcapt_config_planos_apl_prog.idconfiguracao%TYPE 
                                                                                                          --> ID da configuração  
                                    ,pr_flgteimo OUT tbcapt_config_planos_apl_prog.flgteimosinha%TYPE     --> Teimosinha? (0 = Nao, 1 = Sim)
                                    ,pr_fldbparc OUT tbcapt_config_planos_apl_prog.flgdebito_parcial%TYPE --> Debito Parcial (0 = Nao, 1 = Sim)
                                    ,pr_vlminimo OUT tbcapt_config_planos_apl_prog.vlminimo%TYPE          --> Valor mínimo do débito parcial
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE                                --> Codigo da critica de erro
                                    ,pr_dscritic OUT crapcri.dscritic%TYPE);                              --> Descricao da critica de erro
 
  /* Recupera a configuração da apl. programada de uma cooperativa + Produto  - Mensageria */
  PROCEDURE pc_buscar_conf_apl_prog_web (pr_cdcooper_b IN craprac.nrdconta%TYPE -- Código da cooperativa a ser procurada
                                        ,pr_cdprodut   IN crapcpc.cdprodut%TYPE -- Código do produto
                                        ,pr_xmllog     IN VARCHAR2              -- XML com informacoes de LOG
                                        ,pr_cdcritic   OUT PLS_INTEGER          -- Código da crítica
                                        ,pr_dscritic   OUT VARCHAR2             -- Descrição da crítica
                                        ,pr_retxml     IN OUT NOCOPY XMLType    -- Arquivo de retorno do XML
                                        ,pr_nmdcampo   OUT VARCHAR2             -- Nome do campo com erro
                                        ,pr_des_erro   OUT VARCHAR2);           -- Erros do processo

  /* Mantém a configuração da apl. programada de uma cooperativa */
  PROCEDURE pc_manter_conf_apl_prog (pr_cdcooper IN crapcop.cdcooper%TYPE                        --> Código da cooperativa a ser alterada 
                                    ,pr_cdprodut IN crapcpc.cdprodut%TYPE                        --> Código do produto
                                    ,pr_flgteimo IN pls_integer DEFAULT 0                        --> Teimosinha? (0 = Nao, 1 = Sim)
                                    ,pr_fldbparc IN pls_integer DEFAULT 0                        --> Debito Parcial (0 = Nao, 1 = Sim)
                                    ,pr_vlminimo IN tbcapt_config_planos_apl_prog.vlminimo%TYPE  --> Valor mínimo do débito parcial
                                    ,pr_idconfig OUT tbcapt_config_planos_apl_prog.idconfiguracao%TYPE 
                                                                                                 --> ID da configuração (0 para inclusão) 
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE                       --> Codigo da critica de erro
                                    ,pr_dscritic OUT crapcri.dscritic%TYPE);                     --> Descricao da critica de erro

  /* Mantém a configuração da apl. programada de uma cooperativa  - Mensageria */
  PROCEDURE pc_manter_conf_apl_prog_web (pr_cdcooper_a IN craprac.nrdconta%TYPE                     -- Código da cooperativa a ter a config alterada
                                        ,pr_cdprodut   IN crapcpc.cdprodut%TYPE                     -- Código do produto
                                        ,pr_flgteimo IN pls_integer                                 -- Teimosinha? (0 = Nao, 1 = Sim)
                                        ,pr_fldbparc IN pls_integer                                 -- Debito Parcial (0 = Nao, 1 = Sim)
                                        ,pr_vlminimo IN tbcapt_config_planos_apl_prog.vlminimo%TYPE -- Valor mínimo do débito parcial
                                        ,pr_xmllog     IN VARCHAR2                                  -- XML com informacoes de LOG
                                        ,pr_cdcritic   OUT PLS_INTEGER                              -- Código da crítica
                                        ,pr_dscritic   OUT VARCHAR2                                 -- Descrição da crítica
                                        ,pr_retxml     IN OUT NOCOPY XMLType                        -- Arquivo de retorno do XML
                                        ,pr_nmdcampo   OUT VARCHAR2                                 -- Nome do campo com erro
                                        ,pr_des_erro   OUT VARCHAR2);                               -- Erros do processo

  /* Obtem a lista de Aplicações e Poupanças Programadas para uma conta e cooperativa  - Mensageria */
  PROCEDURE pc_ObterListaPlanoAplProg (pr_cdcooper IN crapcop.cdcooper%TYPE            --> Cooperativa
                                      ,pr_idorigem IN INTEGER                          --> Identificador da Origem
                                      ,pr_nrdconta IN craprda.nrdconta%TYPE            --> Nro da conta da aplicacao RDCA
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE            --> Data do movimento atual
                                      ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE            --> Data do proximo movimento
                                      ,pr_idseqttl IN INTEGER                          --> Identificador Sequencial
                                      ,pr_situacao IN INTEGER                          --> (0 = Todos, 1 = Ativos, 2 = Suspensos, 3 = Desativado: Não ativos, cancelados e vencidos)
                                      ,pr_tpinvest IN INTEGER                          --> (0 = Todos, 1/2 = Poupança Programada de planos antigos, 3 = Indexador Pre, 4 = Indexador POS)
                                      ,pr_cdagenci IN crapage.cdagenci%TYPE            --> Codigo da Agencia
                                      ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE            --> Numero do caixa
                                      ,pr_cdoperad IN craplrg.cdoperad%TYPE            --> Codigo do Operador
                                      ,pr_cdprogra IN crapprg.cdprogra%TYPE            --> Nome do programa chamador
                                      ,pr_flgerlog IN INTEGER                          --> Flag erro log
                                      ,pr_cdcritic OUT PLS_INTEGER                     --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2                        --> Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType);             --> Arquivo de retorno do XML

  /* Obtem os itens que formam parte do termo de adesão de uma Aplicação  - Mensageria */
  PROCEDURE pc_retorna_texto_termo_adesao(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                     ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Código da agencia
                                     ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                     ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Código do Operador
                                     ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da Tela
                                     ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                     ,pr_cdprogra IN crapprg.cdprogra%TYPE  --> Codigo do programa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de Movimento
                                     ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE  --> Contrato
                                     ,pr_flgerlog IN INTEGER                --> Indicador se deve gerar log(0-nao, 1-sim)
                                     ,pr_retxml   IN OUT NOCOPY XMLType        --> Arquivo de retorno do XML
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2);            --> Descrição da crítica

  /* Calcula o Saldo das Aplicações para resgate */
  PROCEDURE pc_calc_saldo_resgate(pr_cdcooper  IN craprga.cdcooper%TYPE     --> Código da cooperativa
                             ,pr_nrdconta  IN craprga.nrdconta%TYPE     --> Número da conta
                             ,pr_nraplica  IN craprga.nraplica%TYPE     --> Número da aplicação
                             ,pr_vlresgat  IN craprga.vlresgat%TYPE     --> Valor do resgate
                             ,pr_idtiprgt  IN craprga.idtiprgt%TYPE     --> Tipo do resgate 1 - Parcial / 2 - Total
                             ,pr_dtresgat  IN crapdat.dtmvtolt%TYPE     --> Data do resgate
                             ,pr_nrseqrgt  IN craprga.nrseqrgt%TYPE     --> Numero de sequencia do resgate
                             ,pr_idrgtcti  IN craprga.idrgtcti%TYPE     --> Indicador de resgate na conta investimento (0-Nao / 1-Sim)
                 ,pr_vlsldtot OUT NUMBER --> Valor de saldo total
                 ,pr_vlsldrgt OUT NUMBER --> Valor de saldo de resgate
                 ,pr_vlultren OUT NUMBER --> Valor de ultimo rendimento
                 ,pr_vlrentot OUT NUMBER --> Valor de rendimento total
                 ,pr_vlrevers OUT NUMBER --> Valor de reversao
                 ,pr_vlrdirrf OUT NUMBER --> Valor de IRRF
                 ,pr_percirrf OUT NUMBER --> Valor percentual de IRRF
                 ,pr_vlsldttr OUT NUMBER --> Valor de saldo total de resgate
                             ,pr_tpcritic OUT crapcri.cdcritic%TYPE     --> Tipo da crítica (0- Nao aborta Processo/ 1 - Aborta Processo)
                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Código da crítica
                             ,pr_dscritic OUT crapcri.dscritic%TYPE);

  /* Consulta o saldo para resgate da aplicação programada + resgate no momento */
  PROCEDURE pc_buscar_sld_rgt_apl_prog (pr_cdcooper IN craprac.cdcooper%TYPE                  -- Código da Cooperativa
                                       ,pr_cdoperad IN crapope.cdoperad%TYPE                  -- Código do Operador 
                                       ,pr_nmdatela IN craptel.nmdatela%TYPE                  -- Nome da Tela
                                       ,pr_idorigem IN NUMBER                                 -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA                  
                                       ,pr_nrdconta IN craprac.nrdconta%TYPE                  -- Número da Conta
                                       ,pr_idseqttl IN crapttl.idseqttl%TYPE                  -- Titular da Conta
                                       ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE                  -- Número da Aplicação Programada
                                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE                  -- Data de Movimento
                               ,pr_vlresgat  IN craprga.vlresgat%TYPE     --> Valor do resgate
                               ,pr_idtiprgt  IN craprga.idtiprgt%TYPE     --> Tipo do resgate 1 - Parcial / 2 - Total
                               ,pr_dtresgat  IN crapdat.dtmvtolt%TYPE     --> Data do resgate
                                       ,pr_tab_saldo_rpp OUT typ_tab_saldo_rpp                -- PLTable com os detalhes;
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE                 -- Código da crítica
                                       ,pr_dscritic OUT crapcri.dscritic%TYPE);                 -- Descrição da crítica

  /* Consulta o saldo para resgate da aplicação programada + resgate no momento - Mensageria*/
  PROCEDURE pc_buscar_sld_rgt_apl_prog_web (pr_nrdconta IN craprda.nrdconta%TYPE  -- Nro da conta da aplicacao
                                  ,pr_idseqttl IN INTEGER                -- Identificador Sequencial
                                  ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE  -- Contrato Poupanca Programada
                                  ,pr_dtmvtolt IN VARCHAR2               -- Data do movimento atual
                                  ,pr_dtmvtopr IN VARCHAR2               -- Data do proximo movimento
                          ,pr_vlresgat  IN craprga.vlresgat%TYPE     --> Valor do resgate
                          ,pr_idtiprgt  IN craprga.idtiprgt%TYPE     --> Tipo do resgate 1 - Parcial / 2 - Total
                          ,pr_dtresgat  IN VARCHAR2     --> Data do resgate
                                  ,pr_inproces IN crapdat.inproces%TYPE  -- Indicador de processo
                                  ,pr_flgerlog IN INTEGER                -- Flag erro log
                                  ,pr_xmllog   IN VARCHAR2               -- XML com informacoes de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER           -- Código da crítica
                                  ,pr_dscritic OUT VARCHAR2              -- Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType     -- Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2              -- Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2);             -- Erros do processo

END APLI0008;
/
CREATE OR REPLACE PACKAGE BODY CECRED.APLI0008 AS
  /* ------------------------------------------------------------------------------------
  Programa: APLI0008
  Sistema : Rotinas genericas referente a aplicacao programada
  Sigla   : APLI

  Autor   : CIS Corporate
  Data    : Julho/2018                       Ultima atualizacao: 15/04/2019
  
  Dados referentes ao programa:
  
  Frequencia: -----
  Objetivo  : Rotinas genéricas referente às aplicações programadas
              
  Alteracoes: 05/10/2018 - Inclusão rotinas para manutenção da configuração das APs - Proj. 411.2 - Fase 2 - (CIS Corporate)    
  
              18/03/2019 - PRB0040683 na rotina pc_calc_saldo_apl_prog, feitos os tratamentos de erros para que sejam identificados 
                           os possíveis pontos de correção (Carlos)      

              15/04/2019 - P450 - Ajuste na "pc_efet_resgate_apl_prog" para inclusão da centralizadora de lançamentos da CRAPLCM
                           (Reginaldo/AMcom)
  ----------------------------------------------------------------------------------- */
    
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
        pr_dscritic := 'Produto padrao de Poupanca Programada nao cadastrado';
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
      vr_solcoord INTEGER;
    
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
         
        /* Na conta online e mobile devemos validar os valores minimos cfme CADSOA 
           no aimaro web o sistema chama na etapa de validacao, pois tem permissao de coordenador */
        IF pr_idorigem = 3 /* INTERNET */ THEN
          CADA0006.pc_valida_valor_de_adesao(pr_cdcooper => pr_cdcooper
                                            ,pr_nrdconta => pr_nrdconta
                                            ,pr_cdprodut => 16          -- Poup./Apl. Programada
                                            ,pr_vlcontra => pr_vlprerpp
                                            ,pr_idorigem => pr_idorigem
                                            ,pr_cddchave => 0
                                            ,pr_solcoord => vr_solcoord
                                            ,pr_cdcritic => pr_cdcritic
                                            ,pr_dscritic => pr_dscritic);
          IF pr_cdcritic > 0 OR pr_dscritic IS NOT NULL THEN
            RAISE vr_exc_erro_nrb;
          END IF;
        END IF;

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
             trunc(sysdate),   -- Data  de criação do registro
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
            pr_dscritic := 'Erro insercao craprpp: ' || SQLERRM;
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
              pr_dscritic := 'Erro atualizacao CRAPSPP: ' || SQLERRM;
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
          CECRED.Pc_Internal_Exception(pr_cdcooper => pr_cdcooper);
          pr_dscritic := 'Erro nao especificado ' || sqlerrm;
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
      vr_dtvctopp Date;
      vr_pzmaxpro pls_integer := 0;      -- Prazo 

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
    
      CURSOR cr_craptab (pr_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT * 
        FROM   craptab tab
        WHERE  tab.cdcooper = pr_cdcooper
        AND    tab.nmsistem = 'CRED'
        AND    tab.tptabela = 'GENERI'     
        AND    tab.cdempres = 0           
        AND    tab.cdacesso = 'PZMAXPPROG' 
        AND    tab.tpregist = 2;                
      rw_craptab cr_craptab%ROWTYPE;

    BEGIN
      gene0001.pc_informa_acesso(pr_module => null, pr_action => 'APLI0008.pc_incluir_apl_prog_web');      
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

      IF pr_dtvctopp IS NULL THEN
            Open cr_craptab (vr_cdcooper);
            Fetch cr_craptab Into rw_craptab;
            CLOSE cr_craptab;
            IF (rw_craptab.dstextab IS NULL) THEN
                vr_pzmaxpro := 0;
            ELSE
                    vr_pzmaxpro := rw_craptab.dstextab;
                END IF;
                vr_dtvctopp := add_months(vr_dtinirpp,vr_pzmaxpro);
       ELSE
         vr_dtvctopp := TO_DATE(pr_dtvctopp,'DD/MM/YYYY');  
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
 
  PROCEDURE pc_alterar_apl_prog (pr_cdcooper IN crapcop.cdcooper%TYPE             --> Código da cooperativa
                                ,pr_cdagenci IN crapage.cdagenci%TYPE             --> Código da agência
                                ,pr_cdoperad IN crapope.cdoperad%TYPE             --> Código do operador
                                ,pr_nmdatela VARCHAR2                             --> Nome da tela
                                ,pr_idorigem IN INTEGER                           --> Código de origem
                                ,pr_nrdconta IN craprpp.nrdconta%TYPE             --> Número da conta
                                ,pr_idseqttl IN crapttl.idseqttl%TYPE             --> Sequêncial do titular   
                                ,pr_dtmvtolt IN craprpp.dtmvtolt%TYPE             --> Data do movimento atual
                                ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE             --> Número do Contrato - CRAPRPP
                                ,pr_vlprerpp IN craprpp.vlprerpp%TYPE             --> Valor da parcela
                                ,pr_indebito IN INTEGER                           --> Dia de debito
                                ,pr_dtdebito IN craprpp.dtdebito%TYPE             --> Data do proximo débito
                                ,pr_dsfinali IN craprpp.dsfinali%TYPE             --> Finalidade do fundo (proveniente da tela)
                                ,pr_flgerlog IN INTEGER                           --> Gerar log (0 = Não / 1 = Sim)
                                ,pr_nrdrowid OUT rowid                            --> Oracle ROWID
                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE            --> Codigo da critica de erro
                                ,pr_dscritic OUT crapcri.dscritic%TYPE)           --> Descricao da critica de erro

  IS
    BEGIN
      ---------------------------------------------------------------------------------------------------------------
      --
      --  Programa : pc_alterar_apl_prog
      --  Sistema  : Captação (Aplicação Programada)
      --  Sigla    : CRED
      --  Autor    : CIS Corporate
      --  Data     : Setembro/2018.                   Ultima atualizacao: 
      --
      -- Dados referentes ao programa:
      --
      -- Frequencia: ----
      -- Objetivo  : Altera novo plano aplicação programada
      --
      -- Alteracoes:
      -- 
      ---------------------------------------------------------------------------------------------------------------
      DECLARE
      
        vr_cdcritic crapcri.cdcritic%TYPE;       -- Cód. Erro
        vr_dscritic VARCHAR2(1000);              -- Desc. Erro
        vr_vlprerpp_ant craprpp.vlprerpp%TYPE;   -- Valor anterior para log    
        vr_dsfinali_ant craprpp.dsfinali%TYPE;   -- Finalidade anterior para log  
        vr_diadebit_ant craprpp.diadebit%TYPE;   -- Dia de debito anterior para log
        vr_dtdebito_ant craprpp.dtdebito%TYPE;   -- Dia de debito anterior para log
      
        vr_exc_saida EXCEPTION; 
        vr_nrdrowid rowid;
        vr_dstransa VARCHAR2(80) := 'Alteracao de aplicacao programada';
        vr_solcoord INTEGER;
      
        -- Cursores
        -- Apl. Programada
        CURSOR cr_craprpp(pr_cdcooper craprpp.cdcooper%TYPE,
                          pr_nrdconta craprpp.nrdconta%TYPE,
                          pr_nrctrrpp craprpp.nrctrrpp%TYPE) IS
          Select  rpp.vlprerpp 
                 ,rpp.dtaltrpp
                 ,rpp.dtdebito
                 ,rpp.diadebit
                 ,rpp.dsfinali
                 ,rpp.cdbccxlt
                 ,rpp.nrdolote
                 ,rpp.rowid
            From craprpp rpp
           where rpp.cdcooper = pr_cdcooper
             and rpp.nrdconta = pr_nrdconta
             and rpp.nrctrrpp = pr_nrctrrpp
             for update;
        rw_craprpp cr_craprpp%ROWTYPE;
        
        -- Lotes
        CURSOR cr_craplot(pr_cdcooper crapcop.cdcooper%TYPE,
                          pr_cdagenci craplot.cdagenci%TYPE,
                          pr_dtmvtolt craplot.dtmvtolt%TYPE,
                          pr_cdbccxlt craplot.cdbccxlt%TYPE,
                          pr_nrdolote craplot.nrdolote%TYPE) IS
          Select  lot.vlcompcr
                 ,lot.vlinfocr
            From craplot lot
           where lot.cdcooper = pr_cdcooper
             and lot.dtmvtolt = pr_dtmvtolt
             and lot.cdagenci = pr_cdagenci
             and lot.cdbccxlt = pr_cdbccxlt
             and lot.nrdolote = pr_nrdolote
             for update; 

        rw_craplot cr_craplot%ROWTYPE;
        
      BEGIN
          -- Verifica se existe a conta poupança
          OPEN cr_craprpp (pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrctrrpp => pr_nrctrrpp);
          FETCH cr_craprpp INTO rw_craprpp;
          -- Se não encontrar
          IF cr_craprpp%NOTFOUND THEN
             vr_cdcritic := 495;
             RAISE vr_exc_saida;
          END IF;

          -- Se o lote for de hoje , entao alterar o valor dele tambem 
          OPEN cr_craplot (pr_cdcooper => pr_cdcooper
                          ,pr_cdagenci => pr_cdagenci
                          ,pr_dtmvtolt => pr_dtmvtolt
                          ,pr_cdbccxlt => rw_craprpp.cdbccxlt
                          ,pr_nrdolote => rw_craprpp.nrdolote);

          FETCH cr_craplot INTO rw_craplot; 
          IF cr_craplot%FOUND THEN
              BEGIN
                  UPDATE craplot SET
                         vlcompcr = rw_craplot.vlcompcr - rw_craprpp.vlprerpp + pr_vlprerpp,
                         vlinfocr = rw_craplot.vlinfocr - rw_craprpp.vlprerpp + pr_vlprerpp
                  WHERE current of cr_craplot;
              EXCEPTION 
                  WHEN OTHERS THEN
                       vr_dscritic := 'Erro atualizacao CRAPLOT';
              END;
          END IF;
          IF vr_dscritic IS NOT NULL THEN
             RAISE vr_exc_saida;
          END IF;

          /* Na conta online e mobile devemos validar os valores minimos cfme CADSOA 
          no aimaro web o sistema chama na etapa de validacao, pois tem permissao de coordenador */
          IF pr_idorigem = 3 /* INTERNET */ THEN
            CADA0006.pc_valida_valor_de_adesao(pr_cdcooper => pr_cdcooper
                                              ,pr_nrdconta => pr_nrdconta
                                              ,pr_cdprodut => 16          -- Poup./Apl. Programada
                                              ,pr_vlcontra => pr_vlprerpp
                                              ,pr_idorigem => pr_idorigem
                                              ,pr_cddchave => 0
                                              ,pr_solcoord => vr_solcoord
                                              ,pr_cdcritic => vr_cdcritic
                                              ,pr_dscritic => vr_dscritic);
            IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          END IF;

          -- Guardar valores anterior e Atualizar valores da Prestaçao
          vr_vlprerpp_ant := rw_craprpp.vlprerpp;
          vr_dsfinali_ant := rw_craprpp.dsfinali;
          vr_diadebit_ant := rw_craprpp.diadebit;
          
          BEGIN
              UPDATE craprpp SET
                     vlprerpp = pr_vlprerpp,
                     dtaltrpp = pr_dtmvtolt,
                     diadebit = pr_indebito,
                     dtdebito = pr_dtdebito,
                     dsfinali = pr_dsfinali
              WHERE current of cr_craprpp;
          EXCEPTION
              WHEN OTHERS THEN
                   vr_dscritic := 'Erro atualizacao CRAPRPP';
          END;
          IF vr_dscritic IS NOT NULL THEN
             RAISE vr_exc_saida;
          END IF;

          -- Se for necessário gerar log
          IF  pr_flgerlog = 1 Then
              gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                  ,pr_cdoperad => pr_cdoperad
                                  ,pr_dscritic => ''
                                  ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
                                  ,pr_dstransa => vr_dstransa
                                  ,pr_dttransa => TRUNC(SYSDATE)
                                  ,pr_flgtrans => 1 --> TRUE
                                  ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                                  ,pr_idseqttl => pr_idseqttl
                                  ,pr_nmdatela => pr_nmdatela
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrdrowid => vr_nrdrowid); 

              gene0001.pc_gera_log_item (pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'NRCTRRPP'
                                        ,pr_dsdadant => ''
                                        ,pr_dsdadatu => pr_nrctrrpp);

              gene0001.pc_gera_log_item (pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'VLPRERPP'
                                        ,pr_dsdadant => vr_vlprerpp_ant
                                        ,pr_dsdadatu => pr_vlprerpp);

              gene0001.pc_gera_log_item (pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'DSFINALI'
                                        ,pr_dsdadant => vr_dsfinali_ant
                                        ,pr_dsdadatu => pr_dsfinali);
              
              gene0001.pc_gera_log_item (pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'DIADEBIT'
                                        ,pr_dsdadant => vr_diadebit_ant
                                        ,pr_dsdadatu => pr_indebito);

              gene0001.pc_gera_log_item (pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'DTDEBITO'
                                        ,pr_dsdadant => vr_dtdebito_ant
                                        ,pr_dsdadatu => pr_dtdebito);

           END IF;
           COMMIT;
           pr_nrdrowid := rw_craprpp.rowid;
           -- Fecha os cursores
           IF cr_craplot%ISOPEN THEN
              CLOSE cr_craplot;
           END IF;
           IF cr_craprpp%ISOPEN THEN
              CLOSE cr_craprpp;
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
               -- Verifica se deve gerar log
               IF pr_flgerlog = 1 THEN
                  GENE0001.pc_gera_log (pr_cdcooper => pr_cdcooper
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_dscritic => pr_dscritic
                                       ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
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
               -- Fecha os cursores
               IF cr_craplot%ISOPEN THEN
                  CLOSE cr_craplot;
               END IF;
               IF cr_craprpp%ISOPEN THEN
                  CLOSE cr_craprpp;
               END IF;
          WHEN OTHERS THEN
               -- Verifica se deve gerar log
               ROLLBACK;
               IF pr_flgerlog = 1 THEN
                  GENE0001.pc_gera_log (pr_cdcooper => pr_cdcooper
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_dscritic => pr_dscritic
                                       ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
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
               pr_cdcritic := vr_cdcritic;
               pr_dscritic := 'Erro nao tratado na APLI0008.pc_alterar_apl_prog: ' || SQLERRM;
               -- Fecha os cursores
               IF cr_craplot%ISOPEN THEN
                  CLOSE cr_craplot;
               END IF;
               IF cr_craprpp%ISOPEN THEN
                  CLOSE cr_craprpp;
               END IF;
      END;
  END pc_alterar_apl_prog;

  PROCEDURE pc_alterar_apl_prog_web (pr_nrdconta IN craprpp.nrdconta%TYPE  --> Número da conta
                                    ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequêncial do titular   
                                    ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE  --> Número do Contrato - CRAPRPP
                                    ,pr_dtmvtolt IN VARCHAR2               --> Data do movimento atual - DD/MM/YYYY
                                    ,pr_vlprerpp IN craprpp.vlprerpp%TYPE  --> Valor da parcela
                                    ,pr_indebito IN INTEGER                --> Dia de debito
                                    ,pr_dtdebito IN VARCHAR2               --> Data do proximo débito
                                    ,pr_dsfinali IN craprpp.dsfinali%TYPE  --> Finalidade do fundo (proveniente da tela)
                                    ,pr_flgerlog IN INTEGER                --> Gerar log (0 = Não / 1 = Sim)
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
    --  Programa : pc_alterar_apl_prog_web
    --  Sistema  : Captação (Aplicação Programada)
    --  Sigla    : CRED
    --  Autor    : CIS Corporate
    --  Data     : Setembro/2018.                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: ----
    -- Objetivo  : Altera  plano aplicação programada - Mensageria
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
      vr_dtdebito Date := TO_DATE(pr_dtdebito,'DD/MM/YYYY');

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

      -- Efetua a alteração da Aplicação Programada
      pc_alterar_apl_prog (pr_cdcooper => vr_cdcooper
                          ,pr_cdagenci => vr_cdagenci
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_idorigem => vr_idorigem
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_idseqttl => pr_idseqttl
                          ,pr_dtmvtolt => vr_dtmvtolt
                          ,pr_nrctrrpp => pr_nrctrrpp
                          ,pr_vlprerpp => pr_vlprerpp
                          ,pr_indebito => pr_indebito
                          ,pr_dtdebito => vr_dtdebito
                          ,pr_dsfinali => pr_dsfinali
                          ,pr_flgerlog => pr_flgerlog
                          ,pr_nrdrowid => vr_rpprowid
                          ,pr_cdcritic => vr_cdcritic
                          ,pr_dscritic => vr_dscritic);

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
                             ,pr_texto_novo     => '<nrdrowid>' || vr_rpprowid || '</nrdrowid>');

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
  END pc_alterar_apl_prog_web;

  PROCEDURE pc_cancelar_apl_prog (pr_cdcooper IN crapcop.cdcooper%TYPE             --> Código da cooperativa
                                ,pr_cdagenci IN crapage.cdagenci%TYPE             --> Código da agência
                                ,pr_cdoperad IN crapope.cdoperad%TYPE             --> Código do operador
                                ,pr_nmdatela VARCHAR2                             --> Nome da tela
                                ,pr_idorigem IN INTEGER                           --> Código de origem
                                ,pr_nrdconta IN craprpp.nrdconta%TYPE             --> Número da conta
                                ,pr_idseqttl IN crapttl.idseqttl%TYPE             --> Sequêncial do titular   
                                ,pr_dtmvtolt IN craprpp.dtmvtolt%TYPE             --> Data do movimento atual
                                ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE             --> Número do Contrato - CRAPRPP
                                ,pr_flgerlog IN INTEGER                           --> Gerar log (0 = Não / 1 = Sim)
                                ,pr_nrdrowid OUT rowid                            --> Oracle ROWID
                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE            --> Codigo da critica de erro
                                ,pr_dscritic OUT crapcri.dscritic%TYPE)           --> Descricao da critica de erro

  IS
    BEGIN
      ---------------------------------------------------------------------------------------------------------------
      --
      --  Programa : pc_cancelar_apl_prog
      --  Sistema  : Captação (Aplicação Programada)
      --  Sigla    : CRED
      --  Autor    : CIS Corporate
      --  Data     : Setembro/2018.                   Ultima atualizacao: 
      --
      -- Dados referentes ao programa:
      --
      -- Frequencia: ----
      -- Objetivo  : Cancela novo plano aplicação programada
      --
      -- Alteracoes:
      -- 
      ---------------------------------------------------------------------------------------------------------------
      DECLARE
      
        vr_cdcritic crapcri.cdcritic%TYPE;       -- Cód. Erro
        vr_dscritic VARCHAR2(1000);              -- Desc. Erro
      
        vr_exc_saida EXCEPTION; 
        vr_nrdrowid rowid;
        vr_dstransa VARCHAR2(80) := 'Cancelamento de aplicacao programada';
      
        -- Cursores
        -- Apl. Programada
        CURSOR cr_craprpp(pr_cdcooper craprpp.cdcooper%TYPE,
                          pr_nrdconta craprpp.nrdconta%TYPE,
                          pr_nrctrrpp craprpp.nrctrrpp%TYPE) IS
          Select  rpp.vlprerpp 
                 ,rpp.dtaltrpp
                 ,rpp.dtdebito
                 ,rpp.diadebit
                 ,rpp.dsfinali
                 ,rpp.cdbccxlt
                 ,rpp.nrdolote
                 ,rpp.cdsitrpp
                 ,rpp.rowid
            From craprpp rpp
           where rpp.cdcooper = pr_cdcooper
             and rpp.nrdconta = pr_nrdconta
             and rpp.nrctrrpp = pr_nrctrrpp
             for update;
        rw_craprpp cr_craprpp%ROWTYPE;
        
        -- Lotes
        CURSOR cr_craplot(pr_cdcooper crapcop.cdcooper%TYPE,
                          pr_cdagenci craplot.cdagenci%TYPE,
                          pr_dtmvtolt craplot.dtmvtolt%TYPE,
                          pr_cdbccxlt craplot.cdbccxlt%TYPE,
                          pr_nrdolote craplot.nrdolote%TYPE) IS
          Select  lot.vlcompcr
                 ,lot.vlinfocr
                 ,lot.qtcompln
                 ,lot.qtinfoln
            From craplot lot
           where lot.cdcooper = pr_cdcooper
             and lot.dtmvtolt = pr_dtmvtolt
             and lot.cdagenci = pr_cdagenci
             and lot.cdbccxlt = pr_cdbccxlt
             and lot.nrdolote = pr_nrdolote
             for update; 

        rw_craplot cr_craplot%ROWTYPE;
        
      BEGIN
          -- Verifica se existe a conta poupança
          OPEN cr_craprpp (pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrctrrpp => pr_nrctrrpp);
          FETCH cr_craprpp INTO rw_craprpp;
          -- Se não encontrar
          IF cr_craprpp%NOTFOUND THEN
             vr_cdcritic := 495;
             RAISE vr_exc_saida;
          END IF;

          IF rw_craprpp.cdsitrpp = 5 THEN
             vr_cdcritic := 919;
             RAISE vr_exc_saida;
          END IF;
    
          IF rw_craprpp.cdsitrpp > 2 THEN
             vr_cdcritic := 481;
             RAISE vr_exc_saida;
          END IF;

          -- Se o lote for de hoje , entao alterar o valor dele tambem 
          OPEN cr_craplot (pr_cdcooper => pr_cdcooper
                          ,pr_cdagenci => pr_cdagenci
                          ,pr_dtmvtolt => pr_dtmvtolt
                          ,pr_cdbccxlt => rw_craprpp.cdbccxlt
                          ,pr_nrdolote => rw_craprpp.nrdolote);

          FETCH cr_craplot INTO rw_craplot; 
          IF cr_craplot%FOUND THEN
              BEGIN
                  UPDATE craplot SET
                         vlcompcr = rw_craplot.vlcompcr - rw_craprpp.vlprerpp,
                         vlinfocr = rw_craplot.vlinfocr - rw_craprpp.vlprerpp,
                         qtcompln = rw_craplot.qtcompln - 1,
                         qtinfoln = rw_craplot.qtinfoln - 1
                  WHERE current of cr_craplot;
              EXCEPTION 
                  WHEN OTHERS THEN
                       vr_dscritic := 'Erro atualizacao CRAPLOT';
              END;
          END IF;
          IF vr_dscritic IS NOT NULL THEN
             RAISE vr_exc_saida;
          END IF;
          
          BEGIN
              UPDATE craprpp SET
                     cdsitrpp = rw_craprpp.cdsitrpp + 2,
                     dtaltrpp = pr_dtmvtolt,
                     dtcancel = pr_dtmvtolt,
                     cdopeexc = pr_cdoperad,
                     cdageexc = pr_cdagenci,
                     dtinsexc = TRUNC(SYSDATE)
              WHERE current of cr_craprpp;
          EXCEPTION
              WHEN OTHERS THEN
                   vr_dscritic := 'Erro atualizacao CRAPRPP';
          END;
          IF vr_dscritic IS NOT NULL THEN
             RAISE vr_exc_saida;
          END IF;

          -- Se for necessário gerar log
          IF  pr_flgerlog = 1 Then
              gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                  ,pr_cdoperad => pr_cdoperad
                                  ,pr_dscritic => ''
                                  ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
                                  ,pr_dstransa => vr_dstransa
                                  ,pr_dttransa => TRUNC(SYSDATE)
                                  ,pr_flgtrans => 1 --> TRUE
                                  ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                                  ,pr_idseqttl => pr_idseqttl
                                  ,pr_nmdatela => pr_nmdatela
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrdrowid => vr_nrdrowid); 

              gene0001.pc_gera_log_item (pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'NRCTRRPP'
                                        ,pr_dsdadant => ''
                                        ,pr_dsdadatu => pr_nrctrrpp);

           END IF;
           COMMIT;
           pr_nrdrowid := rw_craprpp.rowid;
           -- Fecha os cursores
           IF cr_craplot%ISOPEN THEN
              CLOSE cr_craplot;
           END IF;
           IF cr_craprpp%ISOPEN THEN
              CLOSE cr_craprpp;
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
               -- Verifica se deve gerar log
               IF pr_flgerlog = 1 THEN
                  GENE0001.pc_gera_log (pr_cdcooper => pr_cdcooper
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_dscritic => pr_dscritic
                                       ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
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
               -- Fecha os cursores
               IF cr_craplot%ISOPEN THEN
                  CLOSE cr_craplot;
               END IF;
               IF cr_craprpp%ISOPEN THEN
                  CLOSE cr_craprpp;
               END IF;
          WHEN OTHERS THEN
               -- Verifica se deve gerar log
               ROLLBACK;
               IF pr_flgerlog = 1 THEN
                  GENE0001.pc_gera_log (pr_cdcooper => pr_cdcooper
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_dscritic => pr_dscritic
                                       ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
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
               pr_cdcritic := vr_cdcritic;
               pr_dscritic := 'Erro nao tratado na APLI0008.pc_cancelar_apl_prog: ' || SQLERRM;
               -- Fecha os cursores
               IF cr_craplot%ISOPEN THEN
                  CLOSE cr_craplot;
               END IF;
               IF cr_craprpp%ISOPEN THEN
                  CLOSE cr_craprpp;
               END IF;
      END;
  END pc_cancelar_apl_prog;

  PROCEDURE pc_cancelar_apl_prog_web (pr_nrdconta IN craprpp.nrdconta%TYPE  --> Número da conta
                                    ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequêncial do titular   
                                    ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE  --> Número do Contrato - CRAPRPP
                                    ,pr_dtmvtolt IN VARCHAR2               --> Data do movimento atual - DD/MM/YYYY
                                    ,pr_flgerlog IN INTEGER                --> Gerar log (0 = Não / 1 = Sim)
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
    --  Programa : pc_cancelar_apl_prog_web
    --  Sistema  : Captação (Aplicação Programada)
    --  Sigla    : CRED
    --  Autor    : CIS Corporate
    --  Data     : Setembro/2018.                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: ----
    -- Objetivo  : Cancela  plano aplicação programada - Mensageria
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

      -- Efetua o cancelamento da Aplicação Programada
      pc_cancelar_apl_prog (pr_cdcooper => vr_cdcooper
                          ,pr_cdagenci => vr_cdagenci
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_idorigem => vr_idorigem
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_idseqttl => pr_idseqttl
                          ,pr_dtmvtolt => vr_dtmvtolt
                          ,pr_nrctrrpp => pr_nrctrrpp
                          ,pr_flgerlog => pr_flgerlog
                          ,pr_nrdrowid => vr_rpprowid
                          ,pr_cdcritic => vr_cdcritic
                          ,pr_dscritic => vr_dscritic);

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
                             ,pr_texto_novo     => '<nrdrowid>' || vr_rpprowid || '</nrdrowid>');

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
        pr_dscritic := 'Erro geral em APLI0008.pc_cancelar_apl_prog_web: '||SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
      
    END;
  END pc_cancelar_apl_prog_web;

  PROCEDURE pc_suspender_apl_prog (pr_cdcooper IN crapcop.cdcooper%TYPE             --> Código da cooperativa
                                ,pr_cdagenci IN crapage.cdagenci%TYPE             --> Código da agência
                                ,pr_cdoperad IN crapope.cdoperad%TYPE             --> Código do operador
                                ,pr_nmdatela VARCHAR2                             --> Nome da tela
                                ,pr_idorigem IN INTEGER                           --> Código de origem
                                ,pr_nrdconta IN craprpp.nrdconta%TYPE             --> Número da conta
                                ,pr_idseqttl IN crapttl.idseqttl%TYPE             --> Sequêncial do titular   
                                ,pr_dtmvtolt IN craprpp.dtmvtolt%TYPE             --> Data do movimento atual
                                ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE             --> Número do Contrato - CRAPRPP
                                ,pr_nrmesusp IN INTEGER                          --> Periodo de Suspensão em meses
                                ,pr_flgerlog IN INTEGER                           --> Gerar log (0 = Não / 1 = Sim)
                                ,pr_nrdrowid OUT rowid                            --> Oracle ROWID
                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE            --> Codigo da critica de erro
                                ,pr_dscritic OUT crapcri.dscritic%TYPE)           --> Descricao da critica de erro

  IS
    BEGIN
      ---------------------------------------------------------------------------------------------------------------
      --
      --  Programa : pc_suspender_apl_prog
      --  Sistema  : Captação (Aplicação Programada)
      --  Sigla    : CRED
      --  Autor    : CIS Corporate
      --  Data     : Setembro/2018.                   Ultima atualizacao: 
      --
      -- Dados referentes ao programa:
      --
      -- Frequencia: ----
      -- Objetivo  : Suspende novo plano aplicação programada
      --
      -- Alteracoes:
      -- 
      ---------------------------------------------------------------------------------------------------------------
      DECLARE
      
        vr_cdcritic crapcri.cdcritic%TYPE;       -- Cód. Erro
        vr_dscritic VARCHAR2(1000);              -- Desc. Erro
      
        vr_exc_saida EXCEPTION; 
        vr_nrdrowid rowid;
        vr_dstransa VARCHAR2(80) := 'Suspensao de aplicacao programada';
      
        -- Cursores
        -- Apl. Programada
        CURSOR cr_craprpp(pr_cdcooper craprpp.cdcooper%TYPE,
                          pr_nrdconta craprpp.nrdconta%TYPE,
                          pr_nrctrrpp craprpp.nrctrrpp%TYPE) IS
          Select  rpp.vlprerpp 
                 ,rpp.dtaltrpp
                 ,rpp.dtdebito
                 ,rpp.diadebit
                 ,rpp.dsfinali
                 ,rpp.cdbccxlt
                 ,rpp.nrdolote
                 ,rpp.rowid
            From craprpp rpp
           where rpp.cdcooper = pr_cdcooper
             and rpp.nrdconta = pr_nrdconta
             and rpp.nrctrrpp = pr_nrctrrpp
             for update;
        rw_craprpp cr_craprpp%ROWTYPE;
        
      BEGIN
          -- Verifica se existe a conta poupança
          OPEN cr_craprpp (pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrctrrpp => pr_nrctrrpp);
          FETCH cr_craprpp INTO rw_craprpp;
          -- Se não encontrar
          IF cr_craprpp%NOTFOUND THEN
             vr_cdcritic := 495;
             RAISE vr_exc_saida;
          END IF;

          BEGIN
              UPDATE craprpp SET
                     dtrnirpp = ADD_MONTHS(rw_craprpp.dtdebito, pr_nrmesusp),
                     dtaltrpp = pr_dtmvtolt,
                     cdsitrpp = 2
              WHERE current of cr_craprpp;
          EXCEPTION
              WHEN OTHERS THEN
                   vr_dscritic := 'Erro atualizacao CRAPRPP';
          END;
          IF vr_dscritic IS NOT NULL THEN
             RAISE vr_exc_saida;
          END IF;

          -- Se for necessário gerar log
          IF  pr_flgerlog = 1 Then
              gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                  ,pr_cdoperad => pr_cdoperad
                                  ,pr_dscritic => ''
                                  ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
                                  ,pr_dstransa => vr_dstransa
                                  ,pr_dttransa => TRUNC(SYSDATE)
                                  ,pr_flgtrans => 1 --> TRUE
                                  ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                                  ,pr_idseqttl => pr_idseqttl
                                  ,pr_nmdatela => pr_nmdatela
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrdrowid => vr_nrdrowid); 

              gene0001.pc_gera_log_item (pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'NRCTRRPP'
                                        ,pr_dsdadant => ''
                                        ,pr_dsdadatu => pr_nrctrrpp);

           END IF;
           COMMIT;
           pr_nrdrowid := rw_craprpp.rowid;
           -- Fecha os cursores
           IF cr_craprpp%ISOPEN THEN
              CLOSE cr_craprpp;
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
               -- Verifica se deve gerar log
               IF pr_flgerlog = 1 THEN
                  GENE0001.pc_gera_log (pr_cdcooper => pr_cdcooper
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_dscritic => pr_dscritic
                                       ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
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
               IF cr_craprpp%ISOPEN THEN
                  CLOSE cr_craprpp;
               END IF;
          WHEN OTHERS THEN
               -- Verifica se deve gerar log
               ROLLBACK;
               IF pr_flgerlog = 1 THEN
                  GENE0001.pc_gera_log (pr_cdcooper => pr_cdcooper
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_dscritic => pr_dscritic
                                       ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
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
               pr_cdcritic := vr_cdcritic;
               pr_dscritic := 'Erro nao tratado na APLI0008.pc_suspender_apl_prog: ' || SQLERRM;
               IF cr_craprpp%ISOPEN THEN
                  CLOSE cr_craprpp;
               END IF;
      END;
  END pc_suspender_apl_prog;

  PROCEDURE pc_suspender_apl_prog_web (pr_nrdconta IN craprpp.nrdconta%TYPE  --> Número da conta
                                    ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequêncial do titular   
                                    ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE  --> Número do Contrato - CRAPRPP
                                    ,pr_nrmesusp IN INTEGER                --> Periodo de Suspensão em meses
                                    ,pr_dtmvtolt IN VARCHAR2               --> Data do movimento atual - DD/MM/YYYY
                                    ,pr_flgerlog IN INTEGER                --> Gerar log (0 = Não / 1 = Sim)
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
    --  Programa : pc_suspender_apl_prog_web
    --  Sistema  : Captação (Aplicação Programada)
    --  Sigla    : CRED
    --  Autor    : CIS Corporate
    --  Data     : Setembro/2018.                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: ----
    -- Objetivo  : Suspende  plano aplicação programada - Mensageria
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

      -- Variaveis de retorno
      vr_nrctrrpp craprpp.nrctrrpp%TYPE;
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

      -- Efetua a alteração da Aplicação Programada
      pc_suspender_apl_prog (pr_cdcooper => vr_cdcooper
                          ,pr_cdagenci => vr_cdagenci
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_idorigem => vr_idorigem
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_idseqttl => pr_idseqttl
                          ,pr_dtmvtolt => vr_dtmvtolt
                          ,pr_nrctrrpp => pr_nrctrrpp
                          ,pr_nrmesusp => pr_nrmesusp
                          ,pr_flgerlog => pr_flgerlog
                          ,pr_nrdrowid => vr_rpprowid
                          ,pr_cdcritic => vr_cdcritic
                          ,pr_dscritic => vr_dscritic);

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
                             ,pr_texto_novo     => '<nrdrowid>' || vr_rpprowid || '</nrdrowid>');

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
        pr_dscritic := 'Erro geral em APLI0008.pc_suspender_apl_prog_web: '||SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
      
    END;
  END pc_suspender_apl_prog_web;

  PROCEDURE pc_reativar_apl_prog (pr_cdcooper IN crapcop.cdcooper%TYPE             --> Código da cooperativa
                                ,pr_cdagenci IN crapage.cdagenci%TYPE             --> Código da agência
                                ,pr_cdoperad IN crapope.cdoperad%TYPE             --> Código do operador
                                ,pr_nmdatela VARCHAR2                             --> Nome da tela
                                ,pr_idorigem IN INTEGER                           --> Código de origem
                                ,pr_nrdconta IN craprpp.nrdconta%TYPE             --> Número da conta
                                ,pr_idseqttl IN crapttl.idseqttl%TYPE             --> Sequêncial do titular   
                                ,pr_dtmvtolt IN craprpp.dtmvtolt%TYPE             --> Data do movimento atual
                                ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE             --> Número do Contrato - CRAPRPP
                                ,pr_flgerlog IN INTEGER                           --> Gerar log (0 = Não / 1 = Sim)
                                ,pr_nrdrowid OUT rowid                            --> Oracle ROWID
                                ,pr_cdcritic OUT crapcri.cdcritic%TYPE            --> Codigo da critica de erro
                                ,pr_dscritic OUT crapcri.dscritic%TYPE)           --> Descricao da critica de erro

  IS
    BEGIN
      ---------------------------------------------------------------------------------------------------------------
      --
      --  Programa : pc_reativar_apl_prog
      --  Sistema  : Captação (Aplicação Programada)
      --  Sigla    : CRED
      --  Autor    : CIS Corporate
      --  Data     : Setembro/2018.                   Ultima atualizacao: 
      --
      -- Dados referentes ao programa:
      --
      -- Frequencia: ----
      -- Objetivo  : Reativa novo plano aplicação programada
      --
      -- Alteracoes:
      -- 
      ---------------------------------------------------------------------------------------------------------------
      DECLARE
      
        vr_cdcritic crapcri.cdcritic%TYPE;       -- Cód. Erro
        vr_dscritic VARCHAR2(1000);              -- Desc. Erro

        --Registro do tipo calendario
        rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
      
        vr_exc_saida EXCEPTION; 
        vr_nrdrowid rowid;
        vr_dstransa VARCHAR2(80) := 'Suspensao de aplicacao programada';
        vr_dtmvtolt crapdat.dtmvtolt%TYPE;
        vr_dtdebito craprpp.dtdebito%TYPE;
      
        -- Cursores
        -- Apl. Programada
        CURSOR cr_craprpp(pr_cdcooper craprpp.cdcooper%TYPE,
                          pr_nrdconta craprpp.nrdconta%TYPE,
                          pr_nrctrrpp craprpp.nrctrrpp%TYPE) IS
          Select  rpp.vlprerpp 
                 ,rpp.dtaltrpp
                 ,rpp.dtdebito
                 ,rpp.dtrnirpp
                 ,rpp.dtfimper
                 ,rpp.flgctain
                 ,rpp.cdsitrpp
                 ,rpp.cdprodut
                 ,rpp.diadebit
                 ,rpp.dsfinali
                 ,rpp.cdbccxlt
                 ,rpp.nrdolote
                 ,rpp.rowid
            From craprpp rpp
           where rpp.cdcooper = pr_cdcooper
             and rpp.nrdconta = pr_nrdconta
             and rpp.nrctrrpp = pr_nrctrrpp
             for update;
        rw_craprpp cr_craprpp%ROWTYPE;
        
      BEGIN
          -- Verifica se existe a conta poupança
          OPEN cr_craprpp (pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrctrrpp => pr_nrctrrpp);
          FETCH cr_craprpp INTO rw_craprpp;
          -- Se não encontrar
          IF cr_craprpp%NOTFOUND THEN
             vr_cdcritic := 495;
             RAISE vr_exc_saida;
          END IF;

          IF cr_craprpp%NOTFOUND THEN
             vr_cdcritic := 495;
             RAISE vr_exc_saida;
          END IF;
        IF  rw_craprpp.cdsitrpp = 5  THEN
             vr_cdcritic := 919;
             RAISE vr_exc_saida;
          END IF;
    
        IF  (rw_craprpp.cdsitrpp = 3 OR rw_craprpp.cdsitrpp = 4) AND rw_craprpp.cdprodut <= 0  THEN 
             vr_cdcritic := 0;
             vr_dscritic := 'Este e um plano antigo que nao pode ser reativado. Cadastre um novo plano';
             RAISE vr_exc_saida;
          END IF;

        IF  rw_craprpp.cdsitrpp = 1  THEN
             vr_cdcritic := 483;
             RAISE vr_exc_saida;
          END IF;
            
        IF  rw_craprpp.flgctain = 0  THEN
             vr_cdcritic := 0;
             vr_dscritic := 'Aplicacao programada nao pode ser reativada';
             RAISE vr_exc_saida;
          END IF;

        OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
        FETCH btch0001.cr_crapdat
         INTO rw_crapdat;
        -- Se não encontrar
        IF btch0001.cr_crapdat%NOTFOUND THEN
          -- Fechar o cursor pois efetuaremos raise
          CLOSE btch0001.cr_crapdat;
          -- Montar mensagem de critica
          vr_cdcritic := 1;
          RAISE vr_exc_saida;
        ELSE
          vr_dtmvtolt := rw_crapdat.dtmvtolt;
          CLOSE btch0001.cr_crapdat;
        END IF;

        /* Calcular a proxima data de debito */
        vr_dtdebito := rw_craprpp.dtdebito;
        /* Precaucao: a proxima data de debito sempre devera ser superior a data atual,
           caso contrario podemos ficar raspando a conta muitas vezes ate que a data fique maior que a atual */
        IF vr_dtmvtolt > vr_dtdebito THEN
          LOOP 
            EXIT WHEN vr_dtmvtolt < vr_dtdebito;
            vr_dtdebito := add_months(vr_dtdebito,1);
          END LOOP;
        END IF;

          BEGIN
            IF  rw_craprpp.cdsitrpp = 2  THEN
                        UPDATE craprpp SET
                         dtrnirpp = NULL,
                         dtaltrpp = pr_dtmvtolt,
                         dtdebito = vr_dtdebito,
                         cdsitrpp = 1,
                         indebito = 0
                       WHERE current of cr_craprpp;
            ELSIF rw_craprpp.cdsitrpp = 3  THEN
                        UPDATE craprpp SET
                         dtcancel = NULL,
                         dtdebito = vr_dtdebito,
                         dtaltrpp = pr_dtmvtolt,
                         cdsitrpp = 1,
                         indebito = 0
                       WHERE current of cr_craprpp;
            ELSIF  rw_craprpp.cdsitrpp = 4  THEN
                    IF  rw_craprpp.dtrnirpp < pr_dtmvtolt  THEN
                            UPDATE craprpp SET
                             dtcancel = NULL,
                             dtdebito = vr_dtdebito,
                             dtaltrpp = pr_dtmvtolt,
                             cdsitrpp = 1,
                             indebito = 0
                           WHERE current of cr_craprpp;
                    ELSE
                            UPDATE craprpp SET
                             dtcancel = NULL,
                             dtaltrpp = pr_dtmvtolt,
                             cdsitrpp = 2
                           WHERE current of cr_craprpp;
            END IF;
            END IF;
          EXCEPTION
              WHEN OTHERS THEN
                   vr_dscritic := 'Erro atualizacao CRAPRPP';
          END;
          IF vr_dscritic IS NOT NULL THEN
             RAISE vr_exc_saida;
          END IF;

          -- Se for necessário gerar log
          IF  pr_flgerlog = 1 Then
              gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                  ,pr_cdoperad => pr_cdoperad
                                  ,pr_dscritic => ''
                                  ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
                                  ,pr_dstransa => vr_dstransa
                                  ,pr_dttransa => TRUNC(SYSDATE)
                                  ,pr_flgtrans => 1 --> TRUE
                                  ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                                  ,pr_idseqttl => pr_idseqttl
                                  ,pr_nmdatela => pr_nmdatela
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_nrdrowid => vr_nrdrowid); 

              gene0001.pc_gera_log_item (pr_nrdrowid => vr_nrdrowid
                                        ,pr_nmdcampo => 'NRCTRRPP'
                                        ,pr_dsdadant => ''
                                        ,pr_dsdadatu => pr_nrctrrpp);

           END IF;
           COMMIT;
           pr_nrdrowid := rw_craprpp.rowid;
           -- Fecha os cursores
           IF cr_craprpp%ISOPEN THEN
              CLOSE cr_craprpp;
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
               -- Verifica se deve gerar log
               IF pr_flgerlog = 1 THEN
                  GENE0001.pc_gera_log (pr_cdcooper => pr_cdcooper
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_dscritic => pr_dscritic
                                       ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
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
               IF cr_craprpp%ISOPEN THEN
                  CLOSE cr_craprpp;
               END IF;
          WHEN OTHERS THEN
               -- Verifica se deve gerar log
               ROLLBACK;
               IF pr_flgerlog = 1 THEN
                  GENE0001.pc_gera_log (pr_cdcooper => pr_cdcooper
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_dscritic => pr_dscritic
                                       ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
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
               pr_cdcritic := vr_cdcritic;
               pr_dscritic := 'Erro nao tratado na APLI0008.pc_reativar_apl_prog: ' || SQLERRM;
               IF cr_craprpp%ISOPEN THEN
                  CLOSE cr_craprpp;
               END IF;
      END;
  END pc_reativar_apl_prog;

  PROCEDURE pc_reativar_apl_prog_web (pr_nrdconta IN craprpp.nrdconta%TYPE  --> Número da conta
                                    ,pr_idseqttl IN crapttl.idseqttl%TYPE  --> Sequêncial do titular   
                                    ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE  --> Número do Contrato - CRAPRPP
                                    ,pr_dtmvtolt IN VARCHAR2               --> Data do movimento atual - DD/MM/YYYY
                                    ,pr_flgerlog IN INTEGER                --> Gerar log (0 = Não / 1 = Sim)
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
    --  Programa : pc_reativar_apl_prog_web
    --  Sistema  : Captação (Aplicação Programada)
    --  Sigla    : CRED
    --  Autor    : CIS Corporate
    --  Data     : Setembro/2018.                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: ----
    -- Objetivo  : Reativa  plano aplicação programada - Mensageria
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

      -- Variaveis de retorno
      vr_nrctrrpp craprpp.nrctrrpp%TYPE;
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

      -- Efetua a alteração da Aplicação Programada
      pc_reativar_apl_prog (pr_cdcooper => vr_cdcooper
                          ,pr_cdagenci => vr_cdagenci
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_idorigem => vr_idorigem
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_idseqttl => pr_idseqttl
                          ,pr_dtmvtolt => vr_dtmvtolt
                          ,pr_nrctrrpp => pr_nrctrrpp
                          ,pr_flgerlog => pr_flgerlog
                          ,pr_nrdrowid => vr_rpprowid
                          ,pr_cdcritic => vr_cdcritic
                          ,pr_dscritic => vr_dscritic);

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
                             ,pr_texto_novo     => '<nrdrowid>' || vr_rpprowid || '</nrdrowid>');

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
        pr_dscritic := 'Erro geral em APLI0008.pc_reativar_apl_prog_web: '||SQLERRM;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic ||
                                       '</Erro></Root>');
      
    END;
  END pc_reativar_apl_prog_web;

   PROCEDURE pc_posicao_saldo_apl_prog (pr_cdcooper IN crapcop.cdcooper%TYPE     --> Cooperativa
                                       ,pr_cdprogra IN crapres.cdprogra%TYPE     --> Programa que esta executando
                                       ,pr_cdoperad IN craplrg.cdoperad%TYPE     --> Codigo do Operador
                                       ,pr_nrdconta IN craprpp.nrdconta%TYPE     --> Numero da conta da aplicacao
                                       ,pr_idseqttl IN INTEGER                   --> Identificador Sequencial
                                       ,pr_idorigem IN INTEGER                   --> Identificador da Origem
                                       ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE     --> Numero do contrato 
                                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE     --> Data do movimento atual
                                       ,pr_inrendim IN PLS_INTEGER default 1     --> Carrega o rendimento (pr_vlrebtap) [1 - Sim, 0 - Nao]
                                       ,pr_vlbascal OUT NUMBER                   --> Valor Base Total
                                       ,pr_vlsdtoap OUT NUMBER                   --> Valor de Saldo Total
                                       ,pr_vlsdrgap OUT NUMBER                   --> Valor do saldo disponível para resgate
                                       ,pr_vlrebtap OUT NUMBER                   --> Valor de rendimento bruto total
                                       ,pr_vlrdirrf OUT NUMBER                   --> Valor de IRRF
                                       ,pr_des_erro OUT VARCHAR2) IS             --> Saida com erros;
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_posicao_saldo_apl_prog
  --  Sistema  : Captação (Aplicação Programada)
  --  Sigla    : CRED
  --  Autor    : CIS Corporate
  --  Data     : Julho/2018.                   Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: ----
  -- Objetivo  : Procedure para calcular diversos valores de uma aplicacao programada a partir da RPP
  --             Ela é invocada a partir de outras procs. então não revalida cooperativa, cooperado, etc.
  -- 
  -- Alteracoes: 20/12/2018 - Correcao no tratamento de erro (Anderson).
  --
  --             16/01/2019 - Alterado para receber o parametro flag inrendim indicando se deve buscar
  --             o rendimento, pois o processo pode ser lento e nem sempre sera utilizado (Anderson).
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
     
    -- Recuperar os históricos
    CURSOR cr_crapcpc IS
    SELECT rpp.dtinirpp
          ,cpc.idtippro            
          ,cpc.idtxfixa
          ,cpc.cddindex
          ,cpc.cdhsraap 
          ,cpc.cdhsnrap
          ,cpc.cdhsprap
          ,cpc.cdhsrvap
          ,cpc.cdhsrdap 
          ,cpc.cdhsirap
          ,cpc.cdhsrgap
          ,cpc.cdhsvtap 
     FROM craprpp rpp, crapcpc cpc
    WHERE rpp.cdcooper = pr_cdcooper
      AND rpp.nrdconta = pr_nrdconta
      AND rpp.nrctrrpp = pr_nrctrrpp
      AND rpp.cdprodut = cpc.cdprodut;

      rw_crapcpc cr_crapcpc%ROWTYPE;    
    
      -- Selecionar os fundos a partir do numero de contrato de apl. programada
      CURSOR cr_craprac IS
        SELECT rac.nraplica
              ,rac.cdprodut
              ,rac.txaplica 
              ,rac.qtdiacar
              ,rac.dtmvtolt
              ,cpc.idtippro
              ,cpc.idtxfixa
              ,cpc.cddindex 
          FROM craprac rac, crapcpc cpc
         WHERE rac.cdcooper = pr_cdcooper
           AND rac.nrdconta = pr_nrdconta
           AND rac.nrctrrpp = pr_nrctrrpp
           AND rac.cdprodut = cpc.cdprodut;

      rw_craprac cr_craprac%ROWTYPE;
      
      -- Variaveis
      vr_vlsdappr NUMBER(15,2) :=0;
      vr_vlrgappr NUMBER(15,2) :=0;
      vr_vlbascal NUMBER(15,2) :=0;
      vr_vlsldtot NUMBER(15,2) :=0;
      vr_vlsldrgt NUMBER(15,2) :=0;
      vr_vlultren NUMBER(15,2) :=0;
      vr_vlrentot NUMBER(15,2) :=0;
      vr_vlrevers NUMBER(15,2) :=0;
      vr_vlrdirrf NUMBER(15,2) :=0;
      vr_percirrf NUMBER(15,2) :=0;

      vr_vlresgat NUMBER(15,2) :=0;
      vr_vlrendim NUMBER(15,2) :=0;
      
      vr_tab_extrato typ_tab_extrato_apl_prog;

      -- Variaveis de retorno de erro
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(4000);
      vr_exc_erro  EXCEPTION; -- Com rollback
    
    BEGIN
      pr_vlbascal := 0;
      pr_vlsdtoap := 0;
      pr_vlsdrgap := 0;
      pr_vlrebtap := 0;
      pr_vlrdirrf := 0;

      OPEN cr_craprac;
      LOOP
        FETCH cr_craprac
          INTO rw_craprac;
          EXIT WHEN cr_craprac%NOTFOUND;

          BEGIN 
            -- Calcula os juros
            IF rw_craprac.idtippro = 1 THEN 
                -- Consulta saldo de aplicacao pre
                apli0006.pc_posicao_saldo_aplicacao_pre(pr_cdcooper => pr_cdcooper          -- Codigo da Cooperativa
                                                       ,pr_nrdconta => pr_nrdconta          -- Conta do Cooperado
                                                       ,pr_nraplica => rw_craprac.nraplica  -- Numero da Aplicacao
                                                       ,pr_dtiniapl => rw_craprac.dtmvtolt  -- Data Inicial
                                                       ,pr_txaplica => rw_craprac.txaplica  -- Taxa de Aplicacao
                                                       ,pr_idtxfixa => rw_craprac.idtxfixa  -- Taxa Fixa (0-Nao / 1-Sim)
                                                       ,pr_cddindex => rw_craprac.cddindex  -- Codigo de Indexador
                                                       ,pr_qtdiacar => rw_craprac.qtdiacar  -- Quantidade de Dias de Carencia
                                                       ,pr_idgravir => 0                    -- Imunidade Tributaria
                                                       ,pr_dtinical => rw_craprac.dtmvtolt  -- Data de Inicio do Calculo
                                                       ,pr_dtfimcal => pr_dtmvtolt          -- Data de Fim do Calculo
                                                       ,pr_idtipbas => 2                    -- Tipo Base / 2-Total
                                                       ,pr_vlbascal => vr_vlbascal          -- Valor de Base
                                                       ,pr_vlsldtot => vr_vlsldtot          -- Valor de Saldo Total
                                                       ,pr_vlsldrgt => vr_vlsldrgt          -- Valor de Saldo p/ Resgate
                                                       ,pr_vlultren => vr_vlultren          -- Valor do ultimo rendimento
                                                       ,pr_vlrentot => vr_vlrentot          -- Valor de rendimento total
                                                       ,pr_vlrevers => vr_vlrevers          -- Valor de reversao
                                                       ,pr_vlrdirrf => vr_vlrdirrf          -- Valor de IRRF
                                                       ,pr_percirrf => vr_percirrf          -- Percentual de IRRF
                                                       ,pr_cdcritic => vr_cdcritic          -- Codigo de Critica
                                                       ,pr_dscritic => vr_dscritic);        -- Descricao de Critica
            ELSE 
                -- Consulta saldo de aplicacao pos
                apli0006.pc_posicao_saldo_aplicacao_pos(pr_cdcooper => pr_cdcooper          -- Codigo da Cooperativa
                                                       ,pr_nrdconta => pr_nrdconta          -- Conta do Cooperado
                                                       ,pr_nraplica => rw_craprac.nraplica  -- Numero da Aplicacao
                                                       ,pr_dtiniapl => rw_craprac.dtmvtolt  -- Data de Movimento
                                                       ,pr_txaplica => rw_craprac.txaplica  -- Taxa de Aplicacao
                                                       ,pr_idtxfixa => rw_craprac.idtxfixa  -- Taxa Fixa (0-Nao / 1-Sim)
                                                       ,pr_cddindex => rw_craprac.cddindex  -- Codigo de Indexador
                                                       ,pr_qtdiacar => rw_craprac.qtdiacar  -- Quantidade de Dias de Carencia
                                                       ,pr_idgravir => 0                    -- Imunidade Tributaria
                                                       ,pr_dtinical => rw_craprac.dtmvtolt  -- Data de Inicio do Calculo
                                                       ,pr_dtfimcal => pr_dtmvtolt          -- Data de Fim do Calculo
                                                       ,pr_idtipbas => 2                    -- Tipo Base / 2-Total
                                                       ,pr_vlbascal => vr_vlbascal          -- Valor de Base
                                                       ,pr_vlsldtot => vr_vlsldtot          -- Valor de Saldo Total
                                                       ,pr_vlsldrgt => vr_vlsldrgt          -- Valor de Saldo p/ Resgate
                                                       ,pr_vlultren => vr_vlultren          -- Valor do ultimo rendimento
                                                       ,pr_vlrentot => vr_vlrentot          -- Valor de rendimento total
                                                       ,pr_vlrevers => vr_vlrevers          -- Valor de reversao
                                                       ,pr_vlrdirrf => vr_vlrdirrf          -- Valor de IRRF
                                                       ,pr_percirrf => vr_percirrf          -- Percentual de IRRF
                                                       ,pr_cdcritic => vr_cdcritic          -- Codigo de Critica
                                                       ,pr_dscritic => vr_dscritic);        -- Descricao de Critica
            END IF;
            IF vr_dscritic IS NOT NULL THEN
               pr_des_erro := vr_dscritic;
               EXIT;
            END IF;
            pr_vlbascal := pr_vlbascal + vr_vlbascal;  -- Base de Cálculo
            pr_vlsdrgap := pr_vlsdrgap + vr_vlsldrgt;  -- Saldo Resgate
            pr_vlsdtoap := pr_vlsdtoap + vr_vlsldtot;  -- Saldo Total
            pr_vlrdirrf := pr_vlrdirrf + vr_vlrdirrf;  -- Valor IRRF total
          END;
        END LOOP;
      CLOSE cr_craprac;
      -- Recupera informações de datas e históricos. Nao existe a possibilidade de ocorrer um not found aqui
      OPEN cr_crapcpc;
      FETCH cr_crapcpc
          INTO rw_crapcpc;
      CLOSE cr_crapcpc;
      
      /* Se solicitado, busca o rendimento */
      IF pr_inrendim = 1 THEN
      -- Calcula o rendimento bruto total
      pc_buscar_extrato_apl_prog (pr_cdcooper => pr_cdcooper
                                 ,pr_cdoperad => pr_cdoperad
                                 ,pr_nmdatela => pr_cdprogra
                                 ,pr_idorigem => pr_idorigem
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_idseqttl => pr_idseqttl
                                 ,pr_nrctrrpp => pr_nrctrrpp
                                 ,pr_dtmvtolt_ini => rw_crapcpc.dtinirpp
                                 ,pr_dtmvtolt_fim => pr_dtmvtolt
                                 ,pr_idlstdhs => 1
                                 ,pr_idgerlog => 0
                                 ,pr_tab_extrato => vr_tab_extrato
                                 ,pr_vlresgat => vr_vlresgat
                                 ,pr_vlrendim => vr_vlrendim
                                 ,pr_vldoirrf => vr_vlrdirrf
                                 ,pr_cdcritic => vr_cdcritic
                                 ,pr_dscritic => vr_dscritic);
        IF pr_des_erro is null and vr_dscritic is null THEN
          IF vr_tab_extrato.count >0 THEN
            FOR vr_idx_extrato in vr_tab_extrato.first .. vr_tab_extrato.last LOOP
                IF vr_tab_extrato(vr_idx_extrato).cdhistor in (rw_crapcpc.cdhsprap,rw_crapcpc.cdhsrdap) THEN -- Provisao do mês e rendimento
                   pr_vlrebtap := pr_vlrebtap + vr_tab_extrato(vr_idx_extrato).vllanmto;  
                ELSIF vr_tab_extrato(vr_idx_extrato).cdhistor in (rw_crapcpc.cdhsirap,rw_crapcpc.cdhsrvap) THEN -- IRRF e Ajuste Previsão
                   pr_vlrebtap := pr_vlrebtap - vr_tab_extrato(vr_idx_extrato).vllanmto;  
                END IF;
            END LOOP;
          END IF;
      END IF;
      END IF;
    
    EXCEPTION
      WHEN OTHERS THEN
        CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper, 
                                     pr_compleme => 'Conta: ' || pr_nrdconta ||
                                                    ' Contrato poupanca: ' || pr_nrctrrpp);
    END;
  END pc_posicao_saldo_apl_prog;
 
  PROCEDURE pc_calc_saldo_apl_prog (pr_cdcooper IN crapcop.cdcooper%TYPE      --> Cooperativa
                                   ,pr_cdprogra IN crapres.cdprogra%TYPE      --> Programa que esta executando
                                   ,pr_cdoperad IN craplrg.cdoperad%TYPE      --> Codigo do Operador
                                   ,pr_nrdconta IN craprpp.nrdconta%TYPE      --> Numero da conta da aplicacao
                                   ,pr_idseqttl IN INTEGER                    --> Identificador Sequencial
                                   ,pr_idorigem IN INTEGER                    --> Identificador da Origem
                                   ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE      --> Numero do contrato poupanca
                                   ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE      --> Data do movimento atual
                                   ,pr_vlsdrdpp IN OUT craprpp.vlsdrdpp%TYPE  --> Valor do saldo para resgate da poupanca programada
                                   ,pr_des_erro OUT VARCHAR2) IS              --> Saida com erros;
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
  --             16/01/2019 - Alterado para passar a flag inrendim = 0 para nao carregar o rendimento, pois nao 
  --             o campo nao eh nem retornado no output desta procedure (Anderson).
  ---------------------------------------------------------------------------------------------------------------
  BEGIN
    DECLARE
      vr_vlbascal NUMBER(15,2) :=0;
      vr_vlsdtoap NUMBER(15,2) :=0;
      vr_vlrebtap NUMBER(15,2) :=0;
      vr_vlrdirrf NUMBER(15,2) :=0;
    
    BEGIN
      pc_posicao_saldo_apl_prog(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => pr_cdprogra
                                               ,pr_cdoperad => pr_cdoperad
                                               ,pr_nrdconta => pr_nrdconta
                                               ,pr_idseqttl => pr_idseqttl
                               ,pr_idorigem => pr_idorigem
                               ,pr_nrctrrpp => pr_nrctrrpp
                                               ,pr_dtmvtolt => pr_dtmvtolt
                               ,pr_inrendim => 0             -- Nao precisa carregar rendimento
                               ,pr_vlbascal => vr_vlbascal
                               ,pr_vlsdtoap => vr_vlsdtoap
                               ,pr_vlsdrgap => pr_vlsdrdpp 
                               ,pr_vlrebtap => vr_vlrebtap
                               ,pr_vlrdirrf => vr_vlrdirrf
                               ,pr_des_erro => pr_des_erro);


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
    
    vr_vlsdrdpp NUMBER(15,2) := 0;
    vr_vlbascal NUMBER(15,2) :=0;
    vr_vlsdtoap NUMBER(15,2) :=0;
    vr_vlrebtap NUMBER(15,2) :=0;
    vr_vlrdirrf NUMBER(15,2) :=0;

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
    pc_posicao_saldo_apl_prog(pr_cdcooper => vr_cdcooper
                           ,pr_cdprogra => vr_nmdatela
                           ,pr_cdoperad => vr_cdoperad
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_idseqttl => pr_idseqttl
                           ,pr_idorigem => vr_idorigem
                           ,pr_nrctrrpp => pr_nrctrrpp
                           ,pr_dtmvtolt => vr_dtmvtolt
                             ,pr_vlbascal => vr_vlbascal
                             ,pr_vlsdtoap => vr_vlsdtoap
                             ,pr_vlsdrgap => vr_vlsdrdpp
                             ,pr_vlrebtap => vr_vlrebtap        --> Valor de rendimento bruto total
                             ,pr_vlrdirrf => vr_vlrdirrf
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
                           '<vlsdtoap>'||vr_vlsdtoap||'</vlsdtoap>'||
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

     Alteracoes: 20/12/2018 - Adequação do ROLLBACK no tratamento de excecao (Anderson)

                 16/01/2019 - Remocao da chamada das procedures apli0006.pc_taxa_acumul_aplic_pos e _pre
                              pois seu output nao eh utilizado (Anderson).
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
                ELSIF rw_craphis.indebcre = 'D' THEN  /* Débito  */
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
                      IF rw_craphis.cdhistor IN 
                                             (rw_craplac.cdhsprap
                                             ,rw_craplac.cdhsrgap
                                             ,rw_craplac.cdhsrvap
                                             ,rw_craplac.cdhsrdap
                                             ,rw_craplac.cdhsirap) THEN
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
                        IF vr_tab_extrato_temp(vr_ind_extrato_temp).indebcre = 'C' THEN
                        vr_tab_extrato(vr_ind_extrato).vlsldtot := vr_tab_extrato(vr_ind_extrato).vlsldtot + vr_tab_extrato_temp(vr_ind_extrato_temp).vllanmto;
                   ELSE
                           vr_tab_extrato(vr_ind_extrato).vlsldtot := vr_tab_extrato(vr_ind_extrato).vlsldtot - vr_tab_extrato_temp(vr_ind_extrato_temp).vllanmto;
                        END IF;
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

                 -- Verifica se deve gerar log
                 IF pr_idgerlog = 1 THEN
                    ROLLBACK;
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
                 CECRED.pc_internal_exception(pr_cdcooper => pr_cdcooper, 
                                              pr_compleme => 'Conta: ' || pr_nrdconta ||
                                                             ' Contrato poupanca: ' || pr_nrctrrpp);
                 pr_cdcritic := vr_cdcritic;
                 pr_dscritic := 'Erro nao tratado APLI0008.pc_buscar_extrato_apl_prog: ' || SQLERRM;
                 -- Verifica se deve gerar log
                 IF pr_idgerlog = 1 THEN
                    ROLLBACK;
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
                                  '<vllanmto>'||to_char(pr_tab_extrato(ctLinha).vllanmto,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS=,.')||'</vllanmto>'||
                                  '<vlsldppr>'||to_char(pr_tab_extrato(ctLinha).vlsldtot,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS=,.')||'</vlsldppr>'||
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

  PROCEDURE pc_buscar_extrato_apl_prog_car (pr_cdcooper IN craprac.cdcooper%TYPE                  -- Código da Cooperativa
                                           ,pr_cdoperad IN crapope.cdoperad%TYPE                  -- Código do Operador 
                                           ,pr_nmdatela IN craptel.nmdatela%TYPE                  -- Nome da Tela
                                           ,pr_idorigem IN NUMBER   -- Código de Origem
                                           ,pr_nrdconta IN craprac.nrdconta%TYPE   -- Número da Conta
                                           ,pr_idseqttl IN crapttl.idseqttl%TYPE   -- Titular da Conta
                                           ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE   -- Número da Aplicação Programada.
                                           ,pr_dtmvtolt_ini IN DATE            -- Data de Movimento Inicial
                                           ,pr_dtmvtolt_fim IN DATE            -- Data de Movimento Fim
                                           ,pr_idlstdhs IN NUMBER                  -- Identificador de Listagem de Todos Históricos (Fixo na chamada, 0 – Não / 1 – Sim)
                                           ,pr_idgerlog IN NUMBER                  -- Identificador de Log (Fixo na chamada, 0 – Não / 1 – Sim)
                                           ,pr_xmllog   IN VARCHAR2                -- XML com informacoes de LOG
                                           ,pr_cdcritic OUT PLS_INTEGER            -- Código da crítica
                                           ,pr_dscritic OUT VARCHAR2               -- Descrição da crítica
                                           ,pr_clobxmlc   OUT CLOB                   -- Arquivo de retorno do XML
                                           ,pr_nmdcampo OUT VARCHAR2               -- Nome do campo com erro
                                           ,pr_des_erro OUT VARCHAR2)              -- Erros do processo


  IS
  BEGIN
   /* .............................................................................

   Programa: pc_buscar_extrato_apl_prog_car
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

    -- Variaveis de retorno
    pr_tab_extrato apli0008.typ_tab_extrato_apl_prog;
    vr_vlresgat NUMBER (15,2);
    vr_vlrendim NUMBER (15,2);
    vr_vldoirrf NUMBER (15,2);
    vr_percirrf NUMBER (15,2);

    -- Variaveis de log
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);

    -- Variaveis de XML 
    vr_xml_temp VARCHAR2(32767);
    
  BEGIN
    -- Busca o extrato da apl. programada
    pc_buscar_extrato_apl_prog (pr_cdcooper => pr_cdcooper
                               ,pr_cdoperad => pr_cdoperad
                               ,pr_nmdatela => pr_nmdatela
                               ,pr_idorigem => pr_idorigem
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_idseqttl => pr_idseqttl
                               ,pr_nrctrrpp => pr_nrctrrpp
                               ,pr_dtmvtolt_ini => pr_dtmvtolt_ini
                               ,pr_dtmvtolt_fim => pr_dtmvtolt_fim
                               ,pr_idlstdhs => 1
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
    dbms_lob.createtemporary(pr_clobxmlc, TRUE); 
    dbms_lob.open(pr_clobxmlc, dbms_lob.lob_readwrite);
    -- Insere o cabeçalho do XML 
    gene0002.pc_escreve_xml (pr_xml            => pr_clobxmlc 
                            ,pr_texto_completo => vr_xml_temp 
                            ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>');
      
    IF pr_tab_extrato.count >0 THEN
       FOR ctLinha in pr_tab_extrato.First .. pr_tab_extrato.Last LOOP
           gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc
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
       gene0002.pc_escreve_xml(pr_xml            => pr_clobxmlc 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => '</Dados></Root>' 
                               ,pr_fecha_xml      => TRUE);
                                 
  Exception
    When vr_exc_erro Then
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
        
    When others Then
      pr_cdcritic := null; -- não será utilizado
      pr_dscritic := 'Erro geral em APLI0008.pc_buscar_extrato_apl_prog_web: '||SQLERRM;
      
  END;

  END pc_buscar_extrato_apl_prog_car;

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
                ELSIF rw_craphis.indebcre = 'D' THEN  /* Débito  */
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
                                       ,pr_tab_dados_rpp OUT typ_tab_dados_rpp                -- PLTable com os detalhes;
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
      vr_vlsdrdpp NUMBER(25,8):=0;  -- Valor do saldo disponível para resgate
      vr_vlsdtoap NUMBER(25,8):=0;  -- Saldo total
      vr_vlsdrgap NUMBER(25,8):=0;
      vr_vlrebtap NUMBER(25,8):=0;
      vr_vlrdirrf NUMBER(25,8):=0;
      vr_vlbascal NUMBER(25,8):=0;

      vr_dsfinali crapcpc.nmprodut%TYPE;
      -- PLTable de retorno
      
      vr_tab_dados_rpp typ_tab_dados_rpp;
        
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
              (CASE 
                 WHEN 
                   (diadebit IS NOT NULL) THEN diadebit
                  ELSE
                   extract (day from dtdebito)
              END) indiadeb,
              vlprerpp,
              qtprepag,
              vlprepag,
              vlrgtacu,
              dtinirpp,
              dtrnirpp,
              dtaltrpp,
              dtiniper,
              dtfimper,
              vlabcpmf,
              vlsdrdpp,
              dtcancel,
              cdprodut,
              dsfinali,
              cdsitrpp,
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

      -- Busca Informações sobre o produto
      CURSOR cr_crapcpc (pr_cdprodut crapcpc.cdprodut%TYPE) IS
      SELECT nmprodut 
      FROM   crapcpc
      WHERE  cdprodut = pr_cdprodut
      AND    indplano = 1; -- Apenas Apl. Programada
      rw_crapcpc cr_crapcpc%ROWTYPE;

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
        vr_dsfinali:=TRIM(rw_craprpp.dsfinali);
        IF (vr_dsfinali IS NULL) THEN   
          OPEN cr_crapcpc(rw_craprpp.cdprodut);
          FETCH cr_crapcpc INTO rw_crapcpc;
          IF cr_crapcpc%NOTFOUND THEN
             vr_dsfinali:='Poupança Programada';
          ELSE
             vr_dsfinali:=rw_crapcpc.nmprodut;
          END IF;
          CLOSE cr_crapcpc;
        END IF;
        
          If rw_craprpp.cdprodut < 1 Then 
            vr_vlsdrdpp := rw_craprpp.vlsdrdpp;
            --Executar rotina para calcular saldo poupanca programada
            apli0001.pc_calc_saldo_rpp (pr_cdcooper => pr_cdcooper
                                       ,pr_cdprogra => pr_nmdatela
                                       ,pr_inproces => 1
                                       ,pr_percenir => 0
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrctrrpp => rw_craprpp.nrctrrpp
                                       ,pr_dtiniper => rw_craprpp.dtiniper
                                       ,pr_dtfimper => rw_craprpp.dtfimper
                                       ,pr_vlabcpmf => rw_craprpp.vlabcpmf
                                       ,pr_dtmvtolt => pr_dtmvtolt
                                       ,pr_dtmvtopr => pr_dtmvtolt
                                       ,pr_vlsdrdpp => vr_vlsdrdpp
                                       ,pr_des_erro => vr_dscritic);
          Else -- Aplicacao Programada
          -- Calcula o saldo atual
        pc_posicao_saldo_apl_prog(pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => pr_nmdatela
                                 ,pr_cdoperad => pr_cdoperad
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_idseqttl => pr_idseqttl
                                 ,pr_idorigem => pr_idorigem
                                 ,pr_nrctrrpp => pr_nrctrrpp
                                 ,pr_dtmvtolt => pr_dtmvtolt
                                 ,pr_vlbascal => vr_vlbascal
                                 ,pr_vlsdtoap => vr_vlsdtoap    --> Valor de Saldo Total
                                 ,pr_vlsdrgap => vr_vlsdrdpp    --> Valor do saldo disponível para resgate
                                 ,pr_vlrebtap => vr_vlrebtap
                                 ,pr_vlrdirrf => vr_vlrdirrf
                                 ,pr_des_erro => vr_dscritic);
          END IF;

          IF vr_dscritic is not null THEN
              RAISE vr_exc_saida;
          END IF;

          If rw_craprpp.cdprodut < 1 Then 
          vr_vlsdtoap := vr_vlsdrdpp;                                         
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
          vr_tab_dados_rpp(1).vlrgtacu:=rw_craprpp.vlrgtacu;    -- Resgate acumulado
          vr_tab_dados_rpp(1).vlsdtoap:=vr_vlsdtoap;            -- Valor de Saldo Total
          vr_tab_dados_rpp(1).vlsdrdpp:=vr_vlsdrdpp;            -- Valor do saldo disponível para resgate
          vr_tab_dados_rpp(1).vljuracu:=vr_vlrebtap;
          vr_tab_dados_rpp(1).dtinirpp:=rw_craprpp.dtinirpp;
          /* Enviaremos aqui o dtmvtolt (data contratacao) para o servico como dtinirpp, pois o servico
             esta exportando esse campo como data da contratacao equivocadamente. Quando o servico for ajustado,
             este tratamento temporario podera ser removido. */
          IF pr_idorigem = 3 /* INTERNET */ THEN
            vr_tab_dados_rpp(1).dtinirpp:=rw_craprpp.dtmvtolt;
          END IF;
          
          vr_tab_dados_rpp(1).dtrnirpp:=rw_craprpp.dtrnirpp;
          vr_tab_dados_rpp(1).dtaltrpp:=rw_craprpp.dtaltrpp;
          vr_tab_dados_rpp(1).dtcancel:=rw_craprpp.dtcancel;
          vr_tab_dados_rpp(1).cdsitrpp:=rw_craprpp.cdsitrpp;
          vr_tab_dados_rpp(1).dssitrpp:=rw_craprpp.dssitrpp;
          vr_tab_dados_rpp(1).dsctainv:=rw_craprpp.flgctain;
          vr_tab_dados_rpp(1).cdprodut:=rw_craprpp.cdprodut;
          vr_tab_dados_rpp(1).dsfinali:=vr_dsfinali;
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

    --Registro do tipo calendario
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

    -- Variaveis de entrada
    vr_dtmvtolt Date;  
    vr_dtmvtopr Date;  

    -- Variaveis de retorno
    vr_tab_dados_rpp typ_tab_dados_rpp;

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
    
    IF pr_dtmvtolt IS NOT NULL THEN
        vr_dtmvtolt := TO_DATE(pr_dtmvtolt,'dd/mm/yyyy');
    ELSE
        -- Leitura do calendário da cooperativa
        OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
        FETCH btch0001.cr_crapdat
          INTO rw_crapdat;
    
        -- Se não encontrar
        IF btch0001.cr_crapdat%NOTFOUND THEN
          -- Fechar o cursor pois efetuaremos raise
          CLOSE btch0001.cr_crapdat;
          -- Montar mensagem de critica
          vr_cdcritic := 1;
          RAISE vr_exc_erro;
        ELSE
          vr_dtmvtolt := rw_crapdat.dtmvtolt;
          vr_dtmvtopr := rw_crapdat.dtmvtopr;
          -- Apenas fechar o cursor
          CLOSE btch0001.cr_crapdat;
        END IF;
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
                              '<cdbccxlt>'||vr_tab_dados_rpp(1).cdbccxlt||'</cdbccxlt>'|| --00
                              '<nrdolote>'||vr_tab_dados_rpp(1).nrdolote||'</nrdolote>'||
                              '<dtmvtolt>'||to_char(vr_tab_dados_rpp(1).dtmvtolt,'dd/mm/yyyy')||'</dtmvtolt>'||
                              '<dtvctopp>'||to_char(vr_tab_dados_rpp(1).dtvctopp,'dd/mm/yyyy')||'</dtvctopp>'||
                              '<dtdebito>'||to_char(vr_tab_dados_rpp(1).dtdebito,'dd/mm/yyyy')||'</dtdebito>'||
                              '<indiadeb>'||vr_tab_dados_rpp(1).indiadeb||'</indiadeb>'||  -- 05
                              '<vlprerpp>'||to_char(vr_tab_dados_rpp(1).vlprerpp,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS=,.')||'</vlprerpp>'||
                              '<qtprepag>'||vr_tab_dados_rpp(1).qtprepag||'</qtprepag>'||
                              '<vlprepag>'||to_char(vr_tab_dados_rpp(1).vlprepag,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS=,.')||'</vlprepag>'||
                              '<vlrgtacu>'||to_char(vr_tab_dados_rpp(1).vlrgtacu,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS=,.')||'</vlrgtacu>'||
                              '<vlsdrdpp>'||to_char(vr_tab_dados_rpp(1).vlsdrdpp,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS=,.')||'</vlsdrdpp>'|| -- 10
                              '<vljuracu>'||to_char(vr_tab_dados_rpp(1).vljuracu,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS=,.')||'</vljuracu>'||
                              '<dtinirpp>'||to_char(vr_tab_dados_rpp(1).dtinirpp,'dd/mm/yyyy')||'</dtinirpp>'||
                              '<dtrnirpp>'||to_char(vr_tab_dados_rpp(1).dtrnirpp,'dd/mm/yyyy')||'</dtrnirpp>'||
                              '<dtaltrpp>'||to_char(vr_tab_dados_rpp(1).dtaltrpp,'dd/mm/yyyy')||'</dtaltrpp>'||
                              '<dtcancel>'||to_char(vr_tab_dados_rpp(1).dtcancel,'dd/mm/yyyy')||'</dtcancel>'||  -- 15
                              '<dssitrpp>'||vr_tab_dados_rpp(1).dssitrpp||'</dssitrpp>'||
                              '<dsctainv>'||vr_tab_dados_rpp(1).dsctainv||'</dsctainv>'||
                              '<dsfinali>'||vr_tab_dados_rpp(1).dsfinali||'</dsfinali>'||  -- 18
                              '<nrctrrpp>'||vr_tab_dados_rpp(1).nrctrrpp||'</nrctrrpp>'||  -- 19
                              '<cdsitrpp>'||vr_tab_dados_rpp(1).cdsitrpp||'</cdsitrpp>'||
                              '<cdprodut>'||vr_tab_dados_rpp(1).cdprodut||'</cdprodut>'||
                              '<vlsdtoap>'||to_char(vr_tab_dados_rpp(1).vlsdtoap,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS=,.')||'</vlsdtoap>'|| -- 22
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

  /* Recuperar lista das poupancas programadas e aplicações programadas */
  PROCEDURE pc_lista_poupanca (pr_cdcooper IN crapcop.cdcooper%TYPE            --> Cooperativa
                              ,pr_cdagenci IN crapage.cdagenci%TYPE            --> Codigo da Agencia
                              ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE            --> Numero do caixa
                              ,pr_cdoperad IN craplrg.cdoperad%TYPE            --> Codigo do Operador
                              ,pr_idorigem IN INTEGER                          --> Identificador da Origem
                              ,pr_nrdconta IN craprda.nrdconta%TYPE            --> Nro da conta da aplicacao RDCA
                              ,pr_idseqttl IN INTEGER                          --> Identificador Sequencial
                              ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE            --> Contrato Poupanca Programada
                              ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE            --> Data do movimento atual
                              ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE            --> Data do proximo movimento
                              ,pr_inproces IN crapdat.inproces%TYPE            --> Indicador de processo
                              ,pr_cdprogra IN crapprg.cdprogra%TYPE            --> Nome do programa chamador
                              ,pr_flgerlog IN BOOLEAN                          --> Flag erro log
                              ,pr_percenir IN NUMBER                           --> % IR para Calculo Poupanca
                              ,pr_tpapprog IN INTEGER default 0                --> Tipo de aplicacao poupanca (1 = Poupanca Antiga, 2 = Aplicações Programadas, 0 = Ambas)
                              ,pr_tpinvest IN INTEGER default 3                --> Tipo de aplicacao poupanca (1 = Poupanca Antiga, 2 = Aplicações Programadas, 0 = Ambas)
                              ,pr_situacao IN INTEGER default 4                --> Tipo de aplicacao poupanca (1 = Poupanca Antiga, 2 = Aplicações Programadas, 0 = Ambas)
                              ,pr_vlsldrpp OUT NUMBER                          --> Valor saldo poupanca programada
                              ,pr_retorno  OUT VARCHAR2                        --> Descricao de erro ou sucesso OK/NOK
                              ,pr_tab_dados_rpp OUT typ_tab_dados_rpp          --> Poupancas Programadas
                              ,pr_tab_erro      IN OUT NOCOPY GENE0001.typ_tab_erro) IS  --> Saida com erros;
  BEGIN
  /* .............................................................................

   Programa: pc_consulta_pp_ap               
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : CIS Corporate
   Data    : Agosto/2018.                        Ultima atualizacao: 11/10/2018

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para consultar saldo e demais dados de poupancas programadas e aplicações progamadas. Derivado de pc_consulta_poupanca

   Alteracoes: 11/10/2018 - Recuperar data de débito da nova coluna "indebit" (CIS Corporate)
  ............................................................................. */
    DECLARE

      --Selecionar informacoes das poupancas programadas
      CURSOR cr_craprpp IS
        SELECT rpp.nrctrrpp
              ,rpp.nrdconta
              ,rpp.cdagenci
              ,rpp.cdbccxlt
              ,rpp.nrdolote
              ,rpp.dtmvtolt
              ,rpp.dtvctopp
              ,rpp.dtdebito
              ,rpp.vlprerpp
              ,rpp.qtprepag
              ,rpp.vlprepag
              ,rpp.vljuracu
              ,rpp.vlrgtacu
              ,rpp.dtinirpp
              ,rpp.dtrnirpp
              ,rpp.dtaltrpp
              ,rpp.dtcancel
              ,rpp.flgctain
              ,rpp.dtiniper
              ,rpp.dtfimper
              ,rpp.vlabcpmf
              ,rpp.cdsitrpp
              ,rpp.vlsdrdpp
              ,rpp.cdprodut
              ,(CASE 
                     WHEN ((rpp.dsfinali IS NULL) and (cpc.nmprodut IS NOT NULL)) OR ((rpp.dsfinali IS NOT NULL) and (trim(rpp.dsfinali))is null)  THEN cpc.nmprodut
                     WHEN (rpp.dsfinali IS NULL) and (cpc.nmprodut IS NULL) OR ((rpp.dsfinali IS NOT NULL) and (trim(rpp.dsfinali))is null) THEN 'Poupança Programada'
                     WHEN ((rpp.dsfinali IS NOT NULL) and (trim(rpp.dsfinali))is not null) THEN rpp.dsfinali
                     END) dsfinali
              ,rpp.flgteimo
              ,rpp.flgdbpar
              ,(CASE 
                    WHEN (rpp.diadebit IS NOT NULL) THEN rpp.diadebit
                    ELSE extract (day from dtdebito)
                    END) diadebit
              ,rpp.ROWID
              ,To_Char((CASE rpp.cdsitrpp
                 WHEN 1 THEN 'Ativa'
                 WHEN 2 THEN 'Suspensa'
                 WHEN 3 THEN 'Cancelada'
                 WHEN 4 THEN 'Cancelada'
                 WHEN 5 THEN 'Vencida'
                 ELSE ''
                END ))  dssitrpp
        FROM craprpp rpp, crapcpc cpc
        WHERE rpp.cdcooper = pr_cdcooper
        AND   rpp.nrdconta = pr_nrdconta
        AND   cpc.cdprodut(+) = rpp.cdprodut 
        AND   (pr_nrctrrpp = 0 OR (pr_nrctrrpp > 0 AND rpp.nrctrrpp = pr_nrctrrpp))
        AND   (pr_tpapprog = 0 OR (pr_tpapprog = 1 AND rpp.cdprodut < 1) OR (pr_tpapprog = 2 and rpp.cdprodut >0))
        AND   ( -- Tipo do investimento
               (pr_tpinvest = 0 AND rpp.cdprodut < 1) OR -- aplicacoes antigas
               (pr_tpinvest = cpc.idtippro AND rpp.cdprodut >0) OR -- aplicacoes novas (PRE ou POS)
               (pr_tpinvest = 3)) -- TODAS
        AND   ( -- Situacao
               (rpp.cdsitrpp = 1 AND pr_situacao = 1) OR -- Ativos
               (rpp.cdsitrpp = 2 AND pr_situacao = 2) OR -- Suspensos
               (rpp.cdsitrpp in (0,3,4,5) AND pr_situacao = 3) OR -- Não ativos
               (pr_situacao = 4)); -- Todas;
      rw_craprpp cr_craprpp%ROWTYPE;

      -- Resgates
      CURSOR cr_craplrg (pr_cdcooper IN craplrg.cdcooper%TYPE
                        ,pr_nrdconta IN craplrg.nrdconta%TYPE
                        ,pr_nrctrrpp IN craplrg.nraplica%TYPE
                        ,pr_dtmvtopr IN craplrg.dtresgat%TYPE DEFAULT sysdate -- Data default
                        ,pr_dtconsid IN PLS_INTEGER DEFAULT 1) IS             -- Considerar data ( 0 = Nao, ignorar / 1 = Sim) 
         SELECT  lrg.tpresgat
                ,lrg.vllanmto
           FROM craplrg lrg
          WHERE lrg.cdcooper = pr_cdcooper
          AND   lrg.nrdconta = pr_nrdconta
          AND   lrg.nraplica = pr_nrctrrpp
          AND   ((lrg.dtresgat <= pr_dtmvtopr AND pr_dtconsid=1) OR (pr_dtconsid=0))
          AND   lrg.tpaplica = 4
          AND   lrg.inresgat = 0;
       
      rw_craplrg cr_craplrg%ROWTYPE;

      -- Selecionar quantidade de saques em poupanca e aplicacoes programadas nos ultimos 6 meses
      CURSOR cr_lancame (pr_cdcooper IN craplpp.cdcooper%TYPE
                        ,pr_nrdconta IN craplpp.nrdconta%TYPE
                        ,pr_nrctrrpp IN craplpp.nrctrrpp%TYPE
                        ,pr_dtmvtolt IN craplpp.dtmvtolt%TYPE) IS
        
        SELECT SUM (qtlancmto) tolancmto
        FROM
        (
            SELECT Count(*) qtlancmto
              FROM craplpp lpp
             WHERE lpp.cdcooper = pr_cdcooper
               AND lpp.nrdconta = pr_nrdconta
               AND lpp.nrctrrpp = pr_nrctrrpp
               AND lpp.cdhistor IN (158,496)
               AND lpp.dtmvtolt >= (pr_dtmvtolt-180)
            UNION ALL 
            SELECT Count(*) qtlancmto
            FROM crapcpc cpc, craprac rac, craplac lac
            WHERE rac.cdcooper = pr_cdcooper
            AND   rac.nrdconta = pr_nrdconta
            AND   rac.nrctrrpp = pr_nrctrrpp
            AND   cpc.cdprodut = rac.cdprodut
            AND   rac.cdcooper = lac.cdcooper
            AND   rac.nrdconta = lac.nrdconta
            AND   rac.nraplica = lac.nraplica 
            AND   lac.cdhistor in (cpc.cdhsrgap)
            AND   lac.dtmvtolt >= (pr_dtmvtolt-180)     
         );
         
      rw_lancame  cr_lancame%ROWTYPE;

      -- Verifica se poupanca esta bloqueada
      CURSOR cr_craptab (pr_cdcooper IN craplpp.cdcooper%TYPE
                        ,pr_nrdconta IN craplpp.nrdconta%TYPE
                        ,pr_nrctrrpp IN craplpp.nrctrrpp%TYPE) IS
        SELECT tab.*FROM craptab tab
         WHERE tab.cdcooper=pr_cdcooper
         AND   tab.nmsistem = 'CRED'                   
         AND   tab.tptabela = 'BLQRGT'                 
         AND   tab.cdempres = 0                       
         AND   to_number(tab.cdacesso) = pr_nrdconta 
         AND   to_number(Substr(tab.dstextab,1,7)) =  pr_nrctrrpp;
         
      rw_craptab  cr_craptab%ROWTYPE;

      --Selecionar informacoes dos saldos da poupanca no aniversario
      CURSOR cr_crapspp (pr_cdcooper IN crapspp.cdcooper%TYPE
                        ,pr_nrdconta IN crapspp.nrdconta%TYPE
                        ,pr_nrctrrpp IN crapspp.nrctrrpp%TYPE) IS
          SELECT MIN(crapspp.dtsldrpp) dtsldrpp
        FROM crapspp crapspp
        WHERE crapspp.cdcooper = pr_cdcooper
        AND   crapspp.nrdconta = pr_nrdconta
             AND crapspp.nrctrrpp = pr_nrctrrpp;
      rw_crapspp cr_crapspp%ROWTYPE;

      --Variaveis Locais
      vr_flgtrans BOOLEAN;
      vr_vlsdrdpp NUMBER(25,8);
      vr_vlrgtrpp NUMBER(25,8);
      vr_qtsaqppr INTEGER;
      vr_dsblqrpp VARCHAR2(3);
      vr_dsresgat VARCHAR2(3);
      vr_dsctainv VARCHAR2(3);
      vr_dsorigem VARCHAR2(40);
      vr_dstransa VARCHAR2(100);
      vr_dsmsgsaq VARCHAR2(100);

      vr_vlsdappr NUMBER(25,8); -- Saldo total -  aplicacao programada
      vr_vlrgappr NUMBER(25,8);-- Saldo total para resgate - aplicacao programada
      vr_vlsdtoap NUMBER(25,8); -- Saldo total -  aplicacao programada
      vr_vlbascal NUMBER(15,2) :=0;
      vr_vlrebtap NUMBER(15,2) :=0;
      vr_vlrdirrf NUMBER(15,2) :=0;

      --Variaveis de retorno de erro
      vr_des_erro VARCHAR2(4000);
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(4000);

      --Variaveis de Indice para tabela memoria
      vr_index_tab     NUMBER;
      vr_index_craptab VARCHAR2(20);
      vr_index_craplpp VARCHAR2(20);
      vr_index_craplrg VARCHAR2(20);
      vr_index_resgate VARCHAR2(25);


      -- Rowid para tabela de log
      vr_nrdrowid ROWID;

      --Variaveis de Excecao
      vr_exc_erro EXCEPTION; --ERRO
      vr_exc_pula EXCEPTION; --NEXT
      vr_exc_sair EXCEPTION; --LEAVE

    BEGIN

      --Inicializar controle de erro
      pr_retorno:= 'OK';
      --Limpar tabela de memoria
      pr_tab_erro.DELETE;
      pr_tab_dados_rpp.DELETE;

      --Se for para gerar log
      IF pr_flgerlog  THEN
        --Atribuir Descricao da Origem
        vr_dsorigem:= GENE0001.vr_vet_des_origens(pr_idorigem);
        --Atribuir Descricao da Transacao
        vr_dstransa:= 'Consulta de aplicacao programada';
      END IF;

      --Inicializar variaveis
      vr_cdcritic:= 0;
      vr_dscritic:= NULL;
      vr_flgtrans:= TRUE;
      
      -- Verifica se o parâmetro é valido
      if pr_tpapprog not in (0,1,2) THEN
         vr_dscritic := 'Valor invalido para pr_tpapprog';
         RAISE vr_exc_erro;
      END IF;
      --Selecionar informacoes das poupancas programadas
      OPEN cr_craprpp;
      LOOP
        --Posicionar no proximo registro
        FETCH cr_craprpp INTO rw_craprpp;
        --Sair quando nao encontrar mais registros
        EXIT WHEN cr_craprpp%NOTFOUND;

        --Bloco necessario para controle fluxo
        BEGIN
          --Se for vencida e nome da tela for EXTPPR ou ADITIV ou IMPRES ignorar
          IF pr_cdprogra NOT IN ('EXTPPR','ADITIV','IMPRES') AND
             rw_craprpp.cdsitrpp = 5 /* Vencida */  THEN
            RAISE vr_exc_pula;
          END IF;

          -- Incializar o saldo com o valor da tabela
          vr_vlsdrdpp := rw_craprpp.vlsdrdpp;

          -- Verificar se é Poupança programada
          -- As aplicações programadas não serão tratadas linha a linha, mas evitaremos fazer 
          -- chamadas desnecessárias abaixo
          
          vr_vlsdtoap := 0;
          If rw_craprpp.cdprodut < 1 Then 
            --Executar rotina para calcular saldo poupanca programada
            apli0001.pc_calc_saldo_rpp (pr_cdcooper => pr_cdcooper
                                       ,pr_cdprogra => pr_cdprogra
                                       ,pr_inproces => pr_inproces
                                       ,pr_percenir => pr_percenir
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrctrrpp => rw_craprpp.nrctrrpp
                                       ,pr_dtiniper => rw_craprpp.dtiniper
                                       ,pr_dtfimper => rw_craprpp.dtfimper
                                       ,pr_vlabcpmf => rw_craprpp.vlabcpmf
                                       ,pr_dtmvtolt => pr_dtmvtolt
                                       ,pr_dtmvtopr => pr_dtmvtopr
                                       ,pr_vlsdrdpp => vr_vlsdrdpp
                                       ,pr_des_erro => vr_des_erro);
                                         
          Else -- Aplicacao Programada
              vr_vlsdrdpp := 0;
                apli0008.pc_posicao_saldo_apl_prog(pr_cdcooper => pr_cdcooper
                                             ,pr_cdprogra => pr_cdprogra
                                             ,pr_cdoperad => pr_cdoperad
                                             ,pr_nrdconta => pr_nrdconta
                                             ,pr_idseqttl => pr_idseqttl
                                             ,pr_idorigem => pr_idorigem
                                             ,pr_nrctrrpp => rw_craprpp.nrctrrpp
                                             ,pr_dtmvtolt => pr_dtmvtolt
                               ,pr_inrendim => 0             -- Nao precisa carregar rendimento
                               ,pr_vlbascal => vr_vlbascal
                               ,pr_vlsdtoap => vr_vlsdtoap
                               ,pr_vlsdrgap => vr_vlsdrdpp
                               ,pr_vlrebtap => vr_vlrebtap
                               ,pr_vlrdirrf => vr_vlrdirrf
                                             ,pr_des_erro => vr_des_erro);
          End If; -- Aplicacao Programada

          --Se ocorreu erro
          IF vr_des_erro IS NOT NULL THEN
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
                      
          --Ignorar se o saldo for negativo e a origem nao for AYLLOS/INTRANET
          IF vr_vlsdrdpp < 0 AND pr_idorigem NOT IN (1,5) THEN
            --Levantar excecao para pular registro
            RAISE vr_exc_pula;
          END IF;
          --Valor do Saldo da poupanca recebe atual + calculado
          pr_vlsldrpp:= Nvl(pr_vlsldrpp,0) + Nvl(vr_vlsdrdpp,0);
          --Valor resgatado recebe valor saldo
          vr_vlrgtrpp:= vr_vlsdrdpp;
          -- Zera quantidade de saques
          vr_qtsaqppr := 0;
          --Descricao resgate e bloqueio recebem N
          vr_dsresgat:= 'Nao';
          vr_dsblqrpp:= 'Nao'; 

          --Mensagem de saque recebe null
          vr_dsmsgsaq:= NULL;

          -- Totalizar valores de resgate
          OPEN cr_craplrg (pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrctrrpp => rw_craprpp.nrctrrpp
                          ,pr_dtmvtopr => pr_dtmvtopr
                          ,pr_dtconsid => 1);
                          
          FETCH cr_craplrg INTO rw_craplrg;
          -- Se encontrar
          IF cr_craplrg%FOUND THEN
            vr_dsresgat:='Sim';
            IF rw_craplrg.tpresgat = 2 THEN
               vr_vlrgtrpp := 0;
            ELSE
              vr_vlrgtrpp := vr_vlrgtrpp - rw_craplrg.vllanmto;
            END IF;
          END IF;
          CLOSE cr_craplrg;
          
          -- Verifica se há resgate programado para a poupanca (apenas se não encontrou na consulta anterior)
          IF vr_dsresgat ='Nao' THEN
              OPEN cr_craplrg (pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrctrrpp => rw_craprpp.nrctrrpp
                              ,pr_dtmvtopr => pr_dtmvtopr
                              ,pr_dtconsid => 0);
                          
              FETCH cr_craplrg INTO rw_craplrg;
              --Se encontrar
              IF cr_craplrg%FOUND THEN
                 vr_dsresgat:='Sim';
              END IF;
              CLOSE cr_craplrg;
          END IF;
      
          -- Verificar a quantidade de resgastes nos últimos 6 meses
          OPEN cr_lancame (pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrctrrpp => rw_craprpp.nrctrrpp
                          ,pr_dtmvtolt => pr_dtmvtolt);
                          
          FETCH cr_lancame INTO rw_lancame;
          CLOSE cr_lancame;
          vr_qtsaqppr := rw_lancame.tolancmto;
          
          IF vr_qtsaqppr>=3 THEN
            vr_dsmsgsaq:='ATENCAO! Mais de 3 saques em 180 dias.';
          END IF;

          -- Verificar bloqueios
          OPEN cr_craptab (pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrctrrpp => rw_craprpp.nrctrrpp);
                          
          FETCH cr_craptab INTO rw_craptab;
          IF cr_craptab%FOUND THEN
             vr_dsblqrpp:='Sim';
          END IF;
          CLOSE cr_craptab;

          --Se a conta estiver inativa
          IF rw_craprpp.flgctain = 1 THEN
            vr_dsctainv:= 'Sim';
          ELSE
            vr_dsctainv:= 'Nao';
          END IF;

          If rw_craprpp.cdprodut < 1 Then 
              vr_vlsdtoap := vr_vlsdrdpp;
          END IF;

          --Encontrar o proximo indice para a tabela
          vr_index_tab:= pr_tab_dados_rpp.Count+1;
          --Atualizar informacoes na tabela de memoria
          pr_tab_dados_rpp(vr_index_tab).nrctrrpp:= rw_craprpp.nrctrrpp;
          pr_tab_dados_rpp(vr_index_tab).cdagenci:= rw_craprpp.cdagenci;
          pr_tab_dados_rpp(vr_index_tab).cdbccxlt:= rw_craprpp.cdbccxlt;
          pr_tab_dados_rpp(vr_index_tab).nrdolote:= rw_craprpp.nrdolote;
          pr_tab_dados_rpp(vr_index_tab).dtmvtolt:= rw_craprpp.dtmvtolt;
          pr_tab_dados_rpp(vr_index_tab).dtvctopp:= rw_craprpp.dtvctopp;
          pr_tab_dados_rpp(vr_index_tab).dtdebito:= rw_craprpp.dtdebito;
          pr_tab_dados_rpp(vr_index_tab).indiadeb:= rw_craprpp.diadebit;
          pr_tab_dados_rpp(vr_index_tab).vlprerpp:= rw_craprpp.vlprerpp;
          pr_tab_dados_rpp(vr_index_tab).qtprepag:= rw_craprpp.qtprepag;
          pr_tab_dados_rpp(vr_index_tab).vlprepag:= rw_craprpp.vlprepag;
          pr_tab_dados_rpp(vr_index_tab).vlsdtoap:= vr_vlsdtoap;
          pr_tab_dados_rpp(vr_index_tab).vlsdrdpp:= vr_vlsdrdpp;
          pr_tab_dados_rpp(vr_index_tab).vlrgtrpp:= vr_vlrgtrpp;
          pr_tab_dados_rpp(vr_index_tab).vljuracu:= rw_craprpp.vljuracu;
          pr_tab_dados_rpp(vr_index_tab).vlrgtacu:= rw_craprpp.vlrgtacu;
          pr_tab_dados_rpp(vr_index_tab).dtinirpp:= rw_craprpp.dtinirpp;
          pr_tab_dados_rpp(vr_index_tab).dtrnirpp:= rw_craprpp.dtrnirpp;
          pr_tab_dados_rpp(vr_index_tab).dtaltrpp:= rw_craprpp.dtaltrpp;
          pr_tab_dados_rpp(vr_index_tab).dtcancel:= rw_craprpp.dtcancel;
          pr_tab_dados_rpp(vr_index_tab).cdsitrpp:= rw_craprpp.cdsitrpp;
          pr_tab_dados_rpp(vr_index_tab).dssitrpp:= rw_craprpp.dssitrpp;
          pr_tab_dados_rpp(vr_index_tab).dsblqrpp:= vr_dsblqrpp;
          pr_tab_dados_rpp(vr_index_tab).dsresgat:= vr_dsresgat;
          pr_tab_dados_rpp(vr_index_tab).dsctainv:= vr_dsctainv;
          pr_tab_dados_rpp(vr_index_tab).dsmsgsaq:= vr_dsmsgsaq;
          pr_tab_dados_rpp(vr_index_tab).cdtiparq:= 0;
--          pr_tab_dados_rpp(vr_index_tab).dtsldrpp:= rw_crapspp.dtsldrpp;
          pr_tab_dados_rpp(vr_index_tab).cdprodut:= rw_craprpp.cdprodut;          
          pr_tab_dados_rpp(vr_index_tab).dsfinali:= rw_craprpp.dsfinali;          
          pr_tab_dados_rpp(vr_index_tab).flgteimo:= rw_craprpp.flgteimo;
          pr_tab_dados_rpp(vr_index_tab).flgdbpar:= rw_craprpp.flgdbpar;
          pr_tab_dados_rpp(vr_index_tab).nrdrowid:= rw_craprpp.ROWID;
        EXCEPTION
          WHEN vr_exc_pula THEN
            --Atribuir TRUE para flag transacao
            vr_flgtrans:= TRUE;
          WHEN vr_exc_sair THEN
            --Atribuir FALSE para flag transacao pois ocorreu erro
            vr_flgtrans:= FALSE;
            --Sair do loop
            EXIT;
          WHEN vr_exc_erro THEN
            --Atribuir FALSE para flag transacao pois ocorreu erro
            vr_flgtrans:= FALSE;
            --Sair do loop
            EXIT;
        END;
      END LOOP;  --cr_craprpp
      --Fechar Cursor
      CLOSE cr_craprpp;

      --Se nao executou loop craprpp corretamente
      IF NOT vr_flgtrans THEN
        --Se nao ocorreu critica
        IF vr_cdcritic = 0 AND vr_dscritic IS NULL THEN
          --Atribuir descricao para a critica
          vr_dscritic:= 'Nao foi possivel consultar as aplicacoes programadas. Aplicacao: '||rw_craprpp.nrctrrpp;
        END IF;
        --Executar rotina geracao erro
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
                              ,pr_cdoperad => SubStr(pr_cdoperad,1,10)
                              ,pr_dscritic => SubStr(vr_dscritic,1,159)
                              ,pr_dsorigem => SubStr(vr_dsorigem,1,13)
                              ,pr_dstransa => SubStr(vr_dstransa,1,121)
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => SubStr(pr_cdprogra,1,12)
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
        END IF;
        --Indicar que ocorreu erro
        pr_retorno:= 'NOK';
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Se for para gerar log
      IF pr_flgerlog THEN
        --Executar rotina geracao log
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => NULL
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_cdprogra
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;
      --Indicar que nao ocorreu erro
      pr_retorno:= 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK
        pr_retorno := 'NOK';
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_retorno := 'NOK';
        -- Gerar erro montado
        vr_dscritic := 'APLI0008.pc_lista_poupanca --> Erro não tratado na rotina: '||sqlerrm;
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => 1
                             ,pr_nrdcaixa => 999
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0 --> Critica 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END;
  END pc_lista_poupanca;

  /* Recuperar lista das poupancas programadas e aplicações programadas - Mensageria*/
  PROCEDURE pc_lista_poupanca_web (pr_nrdconta IN craprda.nrdconta%TYPE  -- Nro da conta da aplicacao RDCA
                                  ,pr_idseqttl IN INTEGER                -- Identificador Sequencial
                                  ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE  -- Contrato Poupanca Programada
                                  ,pr_dtmvtolt IN VARCHAR2               -- Data do movimento atual
                                  ,pr_dtmvtopr IN VARCHAR2               -- Data do proximo movimento
                                  ,pr_inproces IN crapdat.inproces%TYPE  -- Indicador de processo
                                  ,pr_flgerlog IN INTEGER                -- Flag erro log
                                  ,pr_percenir IN NUMBER                 -- % IR para Calculo Poupanca
                                  ,pr_tpapprog IN INTEGER default 0      -- Tipo de aplicacao poupanca (1 = Poupanca Antiga, 2 = Aplicações Programadas, 0 = Ambas)
                                  ,pr_xmllog   IN VARCHAR2               -- XML com informacoes de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER           -- Código da crítica
                                  ,pr_dscritic OUT VARCHAR2              -- Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType     -- Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2              -- Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2)             -- Erros do processo
   IS BEGIN
   /* .............................................................................

   Programa: pc_consulta_pp_ap_web
   Sistema : Novos Produtos de Captação - Aplicação Programada
   Sigla   : APLI
   Autor   : CIS Corporate
   Data    : Agosto/2018.                    Ultima atualizacao: --/--/----

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
    vr_dtmvtopr Date := TO_DATE(pr_dtmvtopr,'dd/mm/yyyy');

    vr_vlsldrpp NUMBER;
    vr_retorno VARCHAR(10);
    

    -- Variaveis de retorno
    vr_tab_craptab APLI0001.typ_tab_ctablq;
    vr_tab_craplpp APLI0001.typ_tab_craplpp;
    vr_tab_craplrg APLI0001.typ_tab_craplpp;
    vr_tab_resgate APLI0001.typ_tab_resgate;
    vr_tab_dados_rpp typ_tab_dados_rpp;
    vr_tab_erro gene0001.typ_tab_erro;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_tpapprog VARCHAR2(100);
    vr_flgerlog BOOLEAN := FALSE; 
    

    -- Variaveis de XML 
    vr_xml_temp VARCHAR2(32767);
    vr_clobxmlc CLOB;
    vr_texto_novo VARCHAR2(1000);

    
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
    
    IF pr_flgerlog = 1 THEN
      vr_flgerlog := TRUE;
    END IF;

    -- Busca as informações da apl. programada
    pc_lista_poupanca (pr_cdcooper => vr_cdcooper
                      ,pr_cdagenci => vr_cdagenci
                      ,pr_nrdcaixa => vr_nrdcaixa
                      ,pr_cdoperad => vr_cdoperad
                      ,pr_idorigem => vr_idorigem
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_idseqttl => pr_idseqttl
                      ,pr_nrctrrpp => pr_nrctrrpp
                      ,pr_dtmvtolt => vr_dtmvtolt
                      ,pr_dtmvtopr => vr_dtmvtopr
                      ,pr_inproces => pr_inproces
                      ,pr_cdprogra => vr_nmdatela
                      ,pr_flgerlog => vr_flgerlog
                      ,pr_percenir => pr_percenir
                      ,pr_tpapprog => pr_tpapprog
                      ,pr_vlsldrpp => vr_vlsldrpp
                      ,pr_retorno  => vr_retorno
                      ,pr_tab_dados_rpp => vr_tab_dados_rpp
                      ,pr_tab_erro => vr_tab_erro);

    IF vr_retorno='NOK' THEN
       RAISE vr_exc_erro;
    END IF;
    -- Criar cabeçalho do XML
    dbms_lob.createtemporary(vr_clobxmlc, TRUE); 
    dbms_lob.open(vr_clobxmlc, dbms_lob.lob_readwrite);
    -- Insere o cabeçalho do XML 
    gene0002.pc_escreve_xml (pr_xml            => vr_clobxmlc 
                            ,pr_texto_completo => vr_xml_temp 
                            ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados vlsldrpp="'||vr_vlsldrpp||'">');
    
    -- Dados
    IF vr_tab_dados_rpp.count >0 THEN
       FOR i1 in vr_tab_dados_rpp.FIRST..vr_tab_dados_rpp.LAST LOOP
             IF vr_tab_dados_rpp(i1).cdprodut < 0 THEN -- ANTIGO
                vr_tpapprog := 'RPP';
             ELSE
                vr_tpapprog := 'APR';
             END IF; 
             vr_texto_novo := vr_texto_novo ||
                              '<Registro>'||
                              '<nrctrrpp>'||vr_tab_dados_rpp(i1).nrctrrpp||'</nrctrrpp>'||
                              '<cdagenci>'||vr_tab_dados_rpp(i1).cdagenci||'</cdagenci>'||  
                              '<cdbccxlt>'||vr_tab_dados_rpp(i1).cdbccxlt||'</cdbccxlt>'||
                              '<nrdolote>'||vr_tab_dados_rpp(i1).nrdolote||'</nrdolote>'||
                              '<dtmvtolt>'||to_char(vr_tab_dados_rpp(i1).dtmvtolt,'dd/mm/yyyy')||'</dtmvtolt>'||
                              '<dtvctopp>'||to_char(vr_tab_dados_rpp(i1).dtvctopp,'dd/mm/yyyy')||'</dtvctopp>'||
                              '<dtdebito>'||to_char(vr_tab_dados_rpp(i1).dtdebito,'dd/mm/yyyy')||'</dtdebito>'||
                              '<indiadeb>'||vr_tab_dados_rpp(i1).indiadeb||'</indiadeb>'||
                              '<vlprerpp>'||vr_tab_dados_rpp(i1).vlprerpp||'</vlprerpp>'||
                              '<qtprepag>'||vr_tab_dados_rpp(i1).qtprepag||'</qtprepag>'||
                              '<vlprepag>'||vr_tab_dados_rpp(i1).vlprepag||'</vlprepag>'||
                              '<vlsdrdpp>'||vr_tab_dados_rpp(i1).vlsdrdpp||'</vlsdrdpp>'||
                              '<vlrgtrpp>'||vr_tab_dados_rpp(i1).vlrgtrpp||'</vlrgtrpp>'||
                              '<vljuracu>'||vr_tab_dados_rpp(i1).vljuracu||'</vljuracu>'||
                              '<vlrgtacu>'||vr_tab_dados_rpp(i1).vlrgtacu||'</vlrgtacu>'||
                              '<dtinirpp>'||to_char(vr_tab_dados_rpp(i1).dtinirpp,'dd/mm/yyyy')||'</dtinirpp>'||
                              '<dtrnirpp>'||to_char(vr_tab_dados_rpp(i1).dtrnirpp,'dd/mm/yyyy')||'</dtrnirpp>'||
                              '<dtaltrpp>'||to_char(vr_tab_dados_rpp(i1).dtaltrpp,'dd/mm/yyyy')||'</dtaltrpp>'||
                              '<dtcancel>'||to_char(vr_tab_dados_rpp(i1).dtcancel,'dd/mm/yyyy')||'</dtcancel>'||
                              '<dssitrpp>'||vr_tab_dados_rpp(i1).dssitrpp||'</dssitrpp>'||
                              '<dsblqrpp>'||vr_tab_dados_rpp(i1).dsblqrpp||'</dsblqrpp>'||  
                              '<dsresgat>'||vr_tab_dados_rpp(i1).dsresgat||'</dsresgat>'||  
                              '<dsctainv>'||vr_tab_dados_rpp(i1).dsctainv||'</dsctainv>'||
                              '<dsmsgsaq>'||vr_tab_dados_rpp(i1).dsmsgsaq||'</dsmsgsaq>'||
                              '<cdtiparq>'||vr_tab_dados_rpp(i1).cdtiparq||'</cdtiparq>'||
                              '<dtsldrpp/>'||
                              '<nrdrowid>'||vr_tab_dados_rpp(i1).nrdrowid||'</nrdrowid>'||
                              '<cdprodut>'||vr_tab_dados_rpp(i1).cdprodut||'</cdprodut>'||
                              '<dsfinali>'||vr_tab_dados_rpp(i1).dsfinali||'</dsfinali>'||
                              '<vlsdtoap>'||vr_tab_dados_rpp(i1).vlsdtoap||'</vlsdtoap>'||
                              '</Registro>';

             gene0002.pc_escreve_xml(pr_xml            => vr_clobxmlc
                                    ,pr_texto_completo => vr_xml_temp 
                                    ,pr_texto_novo     => vr_texto_novo);
             vr_texto_novo :='';                                                           
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
END pc_lista_poupanca_web;

  /* Obter dados para alterar ou suspender poupanca/aplicacao programada */
  PROCEDURE pc_obtem_dados_alte_susp (pr_cdcooper IN craprpp.cdcooper%TYPE            -- Código da Cooperativa
                                     ,pr_cdagenci IN craprpp.cdagenci%TYPE            -- Código da Agencia
                                     ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE            -- Numero do caixa
                                     ,pr_cdoperad IN crapope.cdoperad%TYPE            -- Código do Operador 
                                     ,pr_nmdatela IN craptel.nmdatela%TYPE            -- Nome da Tela
                                     ,pr_idorigem IN NUMBER                           -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA                  
                                     ,pr_nrdconta IN craprpp.nrdconta%TYPE            -- Número da Conta
                                     ,pr_idseqttl IN crapttl.idseqttl%TYPE            -- Titular da Conta
                                     ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE            -- Número da Aplicação Programada
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE            -- Data de Movimento
                                     ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE            -- Data da Operação
                                     ,pr_tpoperac IN PLS_INTEGER                      -- Tipo de Operacao - 1 = Alterar, 2 = Suspender
                                     ,pr_inproces IN PLS_INTEGER                      --
                                     ,pr_flgerlog IN BOOLEAN                          -- Flag erro log
                                     ,pr_retorno  OUT VARCHAR2                        -- Descricao de erro ou sucesso OK/NOK
                                     ,pr_tab_dados_rpp OUT typ_tab_dados_rpp          -- PLTable com os detalhes
                                     ,pr_tab_erro IN OUT NOCOPY GENE0001.typ_tab_erro -- Saida com erros
   ) IS
    BEGIN
      
     /* .............................................................................

     Programa: pc_obtem_dados_alte_susp
     Sistema : Novos Produtos de Captação - Aplicação Programada
     Sigla   : APLI
     Autor   : CIS Corporate
     Data    : Setembro/2018.                    Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina que obtem dados para alterar ou suspender poupanca/aplicacao programada 
                 Baseada no b1wgen0006.obtem-dados-alteracao e b1wgen0006.obtem-dados-suspensao
                 
     Observacao: -----

     Alteracoes: 
    ..............................................................................*/                
      
      DECLARE
        
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE:= NULL;
      vr_dscritic crapcri.dscritic%TYPE:= NULL;
      
      -- Tratamento de erros
      vr_exc_saida EXCEPTION;      
            
      --Variáveis locais
      vr_vlsldrpp NUMBER(25,8):=0;

      vr_dstransa VARCHAR2(50);
      vr_tpapprog INTEGER:=2; -- Default - apl. programada
      vr_retorno VARCHAR2(10);
      vr_rpprowid rowid;

      vr_dsfinali crapcpc.nmprodut%TYPE;
      -- PLTable de retorno
      
      vr_tab_dados_rpp typ_tab_dados_rpp;
        
      -- Busca Aplicações de captação 
      CURSOR cr_craprpp IS
      SELECT 
             cdsitrpp,
             dtvctopp,
             dtdebito,
             cdprodut,
             rowid
        FROM craprpp rpp
       WHERE rpp.cdcooper=pr_cdcooper 
         AND rpp.nrdconta=pr_nrdconta
         AND rpp.nrctrrpp=pr_nrctrrpp;
      rw_craprpp cr_craprpp%ROWTYPE;

      BEGIN -- Principal
        
        OPEN cr_craprpp;
        FETCH cr_craprpp INTO rw_craprpp;
        IF cr_craprpp%NOTFOUND THEN
           vr_cdcritic := 495;
        END IF;
        CLOSE cr_craprpp;
        IF rw_craprpp.cdsitrpp IN (4,5) THEN -- Cancelados
           vr_cdcritic := 919;
        END IF;
        IF rw_craprpp.cdsitrpp IN (2,3) THEN 
           vr_cdcritic := 481;
        END IF;
        IF pr_tpoperac = 1 THEN  -- Alteracao
           vr_dstransa := 'Obtem dados da aplicacao para alteracao';
            IF rw_craprpp.dtvctopp < rw_craprpp.dtdebito THEN 
               vr_dscritic := 'Transacao nao permitida. Data de vencimento proxima.';
            END IF;
        ELSE
            vr_dstransa := 'Obtem dados da aplicacao para suspensao';
        END IF;
          
        IF (vr_cdcritic IS NOT NULL) OR (vr_dscritic IS NOT NULL) THEN
           RAISE vr_exc_saida;
        END IF;
        
        IF rw_craprpp.cdprodut <1 THEN
           vr_tpapprog := 1; -- Poupanca programada
        END IF;
        vr_rpprowid := rw_craprpp.rowid;
        
        pr_tab_erro.DELETE;

        pc_lista_poupanca(pr_cdcooper => pr_cdcooper
                         ,pr_cdagenci => pr_cdagenci
                         ,pr_nrdcaixa => pr_nrdcaixa
                         ,pr_cdoperad => pr_cdoperad
                         ,pr_idorigem => pr_idorigem
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_idseqttl => pr_idseqttl
                         ,pr_nrctrrpp => pr_nrctrrpp
                         ,pr_dtmvtolt => pr_dtmvtolt
                         ,pr_dtmvtopr => pr_dtmvtopr
                         ,pr_inproces => pr_inproces
                         ,pr_cdprogra => pr_nmdatela
                         ,pr_flgerlog => pr_flgerlog
                         ,pr_percenir => 0
                         ,pr_tpapprog => vr_tpapprog
                         ,pr_vlsldrpp => vr_vlsldrpp
                         ,pr_retorno  => vr_retorno
                         ,pr_tab_dados_rpp => vr_tab_dados_rpp
                         ,pr_tab_erro => pr_tab_erro);

          IF vr_retorno ='NOK' THEN
              RAISE vr_exc_saida;
          END IF;
          pr_retorno := 'OK';
          pr_tab_dados_rpp := vr_tab_dados_rpp;
      EXCEPTION
          WHEN vr_exc_saida THEN
               IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
                  vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
               END IF;
               pr_retorno := 'NOK';
                --Executar rotina geracao erro
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
                                      ,pr_dscritic => SubStr(vr_dscritic,1,159)
                                      ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
                                      ,pr_dstransa => SubStr(vr_dstransa,1,121)
                                      ,pr_dttransa => TRUNC(SYSDATE)
                                      ,pr_flgtrans => 0
                                      ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                                      ,pr_idseqttl => pr_idseqttl
                                      ,pr_nmdatela => pr_nmdatela
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_nrdrowid => vr_rpprowid);
                END IF;
          WHEN OTHERS THEN
               vr_dscritic := 'Erro nao tratado APLI0008.pc_obtem_dados_alte_susp: ' || SQLERRM;
               pr_retorno := 'NOK';
                --Executar rotina geracao erro
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
                                      ,pr_dscritic => SubStr(vr_dscritic,1,159)
                                      ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
                                      ,pr_dstransa => SubStr(vr_dstransa,1,121)
                                      ,pr_dttransa => TRUNC(SYSDATE)
                                      ,pr_flgtrans => 0
                                      ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                                      ,pr_idseqttl => pr_idseqttl
                                      ,pr_nmdatela => pr_nmdatela
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_nrdrowid => vr_rpprowid);
                END IF;
      END; -- Principal
  END pc_obtem_dados_alte_susp;

  /* Obter dados para alterar poupanca/aplicacao programada - Mensageria */
  PROCEDURE pc_obtem_dados_alteracao_web (pr_nrdconta IN crapass.nrdconta%TYPE  -- Nro da conta da aplicacao 
                                         ,pr_idseqttl IN INTEGER                -- Identificador Sequencial
                                         ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE  -- Contrato Poupanca Programada
                                         ,pr_dtmvtolt IN VARCHAR2               -- Data do movimento atual
                                         ,pr_dtmvtopr IN VARCHAR2               -- Data do proximo movimento
                                         ,pr_inproces IN crapdat.inproces%TYPE  -- Indicador de processo
                                         ,pr_flgerlog IN INTEGER                -- Flag erro log
                                         ,pr_xmllog   IN VARCHAR2               -- XML com informacoes de LOG
                                         ,pr_cdcritic OUT PLS_INTEGER           -- Código da crítica
                                         ,pr_dscritic OUT VARCHAR2              -- Descrição da crítica
                                         ,pr_retxml   IN OUT NOCOPY XMLType     -- Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2              -- Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2)             -- Erros do processo
   IS BEGIN
   /* .............................................................................

   Programa: pc_obtem_dados_alteracao_web
   Sistema : Novos Produtos de Captação - Aplicação Programada
   Sigla   : APLI
   Autor   : CIS Corporate
   Data    : Setembro/2018.                    Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Rotina que obtem dados para alterar poupanca/aplicacao programada  - Mensageria. 

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
    vr_dtmvtopr Date := TO_DATE(pr_dtmvtopr,'dd/mm/yyyy');

    vr_vlsldrpp NUMBER;
    vr_retorno VARCHAR(10);
    

    -- Variaveis de retorno
    vr_tab_dados_rpp typ_tab_dados_rpp;
    vr_tab_erro gene0001.typ_tab_erro;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_tpapprog VARCHAR2(100);
    vr_flgerlog BOOLEAN := FALSE; 
    

    -- Variaveis de XML 
    vr_xml_temp VARCHAR2(32767);
    vr_clobxmlc CLOB;
    vr_texto_novo VARCHAR2(1000);

    
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
    
    IF pr_flgerlog = 1 THEN
      vr_flgerlog := TRUE;
    END IF;

    -- Busca as informações da apl. programada
    pc_obtem_dados_alte_susp (pr_cdcooper => vr_cdcooper
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_idorigem => vr_idorigem
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_idseqttl => pr_idseqttl
                             ,pr_nrctrrpp => pr_nrctrrpp
                             ,pr_dtmvtolt => vr_dtmvtolt
                             ,pr_dtmvtopr => vr_dtmvtopr
                             ,pr_tpoperac => 1           -- Alteracao
                             ,pr_inproces => pr_inproces
                             ,pr_flgerlog => vr_flgerlog
                             ,pr_retorno  => vr_retorno
                             ,pr_tab_dados_rpp => vr_tab_dados_rpp
                             ,pr_tab_erro => vr_tab_erro);

    IF vr_retorno='NOK' THEN
       vr_cdcritic:= vr_tab_erro(0).cdcritic;
       vr_dscritic:= vr_tab_erro(0).dscritic;
       RAISE vr_exc_erro;
    END IF;
    -- Criar cabeçalho do XML
    dbms_lob.createtemporary(vr_clobxmlc, TRUE); 
    dbms_lob.open(vr_clobxmlc, dbms_lob.lob_readwrite);
    -- Insere o cabeçalho do XML 
    gene0002.pc_escreve_xml (pr_xml            => vr_clobxmlc 
                            ,pr_texto_completo => vr_xml_temp 
                            ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados vlsldrpp="'||vr_vlsldrpp||'">');
    
    -- Dados
    IF vr_tab_dados_rpp.count >0 THEN
       FOR i1 in vr_tab_dados_rpp.FIRST..vr_tab_dados_rpp.LAST LOOP
             IF vr_tab_dados_rpp(i1).cdprodut < 0 THEN -- ANTIGO
                vr_tpapprog := 'RPP';
             ELSE
                vr_tpapprog := 'APR';
             END IF; 
             vr_texto_novo := vr_texto_novo ||
                              '<Registro>'||
                              '<nrctrrpp>'||vr_tab_dados_rpp(i1).nrctrrpp||'</nrctrrpp>'||
                              '<cdagenci>'||vr_tab_dados_rpp(i1).cdagenci||'</cdagenci>'||  
                              '<cdbccxlt>'||vr_tab_dados_rpp(i1).cdbccxlt||'</cdbccxlt>'||
                              '<nrdolote>'||vr_tab_dados_rpp(i1).nrdolote||'</nrdolote>'||
                              '<dtmvtolt>'||to_char(vr_tab_dados_rpp(i1).dtmvtolt,'dd/mm/yyyy')||'</dtmvtolt>'||
                              '<dtvctopp>'||to_char(vr_tab_dados_rpp(i1).dtvctopp,'dd/mm/yyyy')||'</dtvctopp>'||
                              '<dtdebito>'||to_char(vr_tab_dados_rpp(i1).dtdebito,'dd/mm/yyyy')||'</dtdebito>'||
                              '<indiadeb>'||vr_tab_dados_rpp(i1).indiadeb||'</indiadeb>'||
                              '<vlprerpp>'||vr_tab_dados_rpp(i1).vlprerpp||'</vlprerpp>'||
                              '<qtprepag>'||vr_tab_dados_rpp(i1).qtprepag||'</qtprepag>'||
                              '<vlprepag>'||vr_tab_dados_rpp(i1).vlprepag||'</vlprepag>'||
                              '<vlsdrdpp>'||vr_tab_dados_rpp(i1).vlsdrdpp||'</vlsdrdpp>'||
                              '<vlrgtrpp>'||vr_tab_dados_rpp(i1).vlrgtrpp||'</vlrgtrpp>'||
                              '<vljuracu>'||vr_tab_dados_rpp(i1).vljuracu||'</vljuracu>'||
                              '<vlrgtacu>'||vr_tab_dados_rpp(i1).vlrgtacu||'</vlrgtacu>'||
                              '<dtinirpp>'||to_char(vr_tab_dados_rpp(i1).dtinirpp,'dd/mm/yyyy')||'</dtinirpp>'||
                              '<dtrnirpp>'||to_char(vr_tab_dados_rpp(i1).dtrnirpp,'dd/mm/yyyy')||'</dtrnirpp>'||
                              '<dtaltrpp>'||to_char(vr_tab_dados_rpp(i1).dtaltrpp,'dd/mm/yyyy')||'</dtaltrpp>'||
                              '<dtcancel>'||to_char(vr_tab_dados_rpp(i1).dtcancel,'dd/mm/yyyy')||'</dtcancel>'||
                              '<dssitrpp>'||vr_tab_dados_rpp(i1).dssitrpp||'</dssitrpp>'||
                              '<dsblqrpp>'||vr_tab_dados_rpp(i1).dsblqrpp||'</dsblqrpp>'||
                              '<dsresgat>'||vr_tab_dados_rpp(i1).dsresgat||'</dsresgat>'||  
                              '<dsctainv>'||vr_tab_dados_rpp(i1).dsctainv||'</dsctainv>'||
                              '<dsmsgsaq>'||vr_tab_dados_rpp(i1).dsmsgsaq||'</dsmsgsaq>'||
                              '<cdtiparq>'||vr_tab_dados_rpp(i1).cdtiparq||'</cdtiparq>'||
                              '<dtsldrpp/>'||
                              '<nrdrowid>'||vr_tab_dados_rpp(i1).nrdrowid||'</nrdrowid>'||
                              '<cdprodut>'||vr_tab_dados_rpp(i1).cdprodut||'</cdprodut>'||
                              '<dsfinali>'||vr_tab_dados_rpp(i1).dsfinali||'</dsfinali>'||
                              '</Registro>';

             gene0002.pc_escreve_xml(pr_xml            => vr_clobxmlc
                                    ,pr_texto_completo => vr_xml_temp 
                                    ,pr_texto_novo     => vr_texto_novo);
             vr_texto_novo :='';                                                           
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
END pc_obtem_dados_alteracao_web;
  
  /* Obter dados para suspender poupanca/aplicacao programada - Mensageria */
  PROCEDURE pc_obtem_dados_suspensao_web (pr_nrdconta IN crapass.nrdconta%TYPE  -- Nro da conta da aplicacao 
                                         ,pr_idseqttl IN INTEGER                -- Identificador Sequencial
                                         ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE  -- Contrato Poupanca Programada
                                         ,pr_dtmvtolt IN VARCHAR2               -- Data do movimento atual
                                         ,pr_dtmvtopr IN VARCHAR2               -- Data do proximo movimento
                                         ,pr_inproces IN crapdat.inproces%TYPE  -- Indicador de processo
                                         ,pr_flgerlog IN INTEGER                -- Flag erro log
                                         ,pr_xmllog   IN VARCHAR2               -- XML com informacoes de LOG
                                         ,pr_cdcritic OUT PLS_INTEGER           -- Código da crítica
                                         ,pr_dscritic OUT VARCHAR2              -- Descrição da crítica
                                         ,pr_retxml   IN OUT NOCOPY XMLType     -- Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2              -- Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2)             -- Erros do processo
   IS BEGIN
   /* .............................................................................

   Programa: pc_obtem_dados_suspensao_web
   Sistema : Novos Produtos de Captação - Aplicação Programada
   Sigla   : APLI
   Autor   : CIS Corporate
   Data    : Setembro/2018.                    Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Rotina que obtem dados para alterar poupanca/aplicacao programada  - Mensageria. 

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
    vr_dtmvtopr Date := TO_DATE(pr_dtmvtopr,'dd/mm/yyyy');

    vr_vlsldrpp NUMBER;
    vr_retorno VARCHAR(10);
    

    -- Variaveis de retorno
    vr_tab_dados_rpp typ_tab_dados_rpp;
    vr_tab_erro gene0001.typ_tab_erro;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_tpapprog VARCHAR2(100);
    vr_flgerlog BOOLEAN := FALSE; 
    

    -- Variaveis de XML 
    vr_xml_temp VARCHAR2(32767);
    vr_clobxmlc CLOB;
    vr_texto_novo VARCHAR2(1000);

    
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
    
    IF pr_flgerlog = 1 THEN
      vr_flgerlog := TRUE;
    END IF;

    -- Busca as informações da apl. programada
    pc_obtem_dados_alte_susp (pr_cdcooper => vr_cdcooper
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_idorigem => vr_idorigem
                             ,pr_nrdconta => pr_nrdconta
                             ,pr_idseqttl => pr_idseqttl
                             ,pr_nrctrrpp => pr_nrctrrpp
                             ,pr_dtmvtolt => vr_dtmvtolt
                             ,pr_dtmvtopr => vr_dtmvtopr
                             ,pr_tpoperac => 2           -- Suspensao
                             ,pr_inproces => pr_inproces
                             ,pr_flgerlog => vr_flgerlog
                             ,pr_retorno  => vr_retorno
                             ,pr_tab_dados_rpp => vr_tab_dados_rpp
                             ,pr_tab_erro => vr_tab_erro);

    IF vr_retorno='NOK' THEN
       vr_cdcritic:= vr_tab_erro(0).cdcritic;
       vr_dscritic:= vr_tab_erro(0).dscritic;
       RAISE vr_exc_erro;
    END IF;
    -- Criar cabeçalho do XML
    dbms_lob.createtemporary(vr_clobxmlc, TRUE); 
    dbms_lob.open(vr_clobxmlc, dbms_lob.lob_readwrite);
    -- Insere o cabeçalho do XML 
    gene0002.pc_escreve_xml (pr_xml            => vr_clobxmlc 
                            ,pr_texto_completo => vr_xml_temp 
                            ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados vlsldrpp="'||vr_vlsldrpp||'">');
    
    -- Dados
    IF vr_tab_dados_rpp.count >0 THEN
       FOR i1 in vr_tab_dados_rpp.FIRST..vr_tab_dados_rpp.LAST LOOP
             IF vr_tab_dados_rpp(i1).cdprodut < 0 THEN -- ANTIGO
                vr_tpapprog := 'RPP';
             ELSE
                vr_tpapprog := 'APR';
             END IF; 
             vr_texto_novo := vr_texto_novo ||
                              '<Registro>'||
                              '<nrctrrpp>'||vr_tab_dados_rpp(i1).nrctrrpp||'</nrctrrpp>'||
                              '<cdagenci>'||vr_tab_dados_rpp(i1).cdagenci||'</cdagenci>'||  
                              '<cdbccxlt>'||vr_tab_dados_rpp(i1).cdbccxlt||'</cdbccxlt>'||
                              '<nrdolote>'||vr_tab_dados_rpp(i1).nrdolote||'</nrdolote>'||
                              '<dtmvtolt>'||to_char(vr_tab_dados_rpp(i1).dtmvtolt,'dd/mm/yyyy')||'</dtmvtolt>'||
                              '<dtvctopp>'||to_char(vr_tab_dados_rpp(i1).dtvctopp,'dd/mm/yyyy')||'</dtvctopp>'||
                              '<dtdebito>'||to_char(vr_tab_dados_rpp(i1).dtdebito,'dd/mm/yyyy')||'</dtdebito>'||
                              '<indiadeb>'||vr_tab_dados_rpp(i1).indiadeb||'</indiadeb>'||
                              '<vlprerpp>'||vr_tab_dados_rpp(i1).vlprerpp||'</vlprerpp>'||
                              '<qtprepag>'||vr_tab_dados_rpp(i1).qtprepag||'</qtprepag>'||
                              '<vlprepag>'||vr_tab_dados_rpp(i1).vlprepag||'</vlprepag>'||
                              '<vlsdrdpp>'||vr_tab_dados_rpp(i1).vlsdrdpp||'</vlsdrdpp>'||
                              '<vlrgtrpp>'||vr_tab_dados_rpp(i1).vlrgtrpp||'</vlrgtrpp>'||
                              '<vljuracu>'||vr_tab_dados_rpp(i1).vljuracu||'</vljuracu>'||
                              '<vlrgtacu>'||vr_tab_dados_rpp(i1).vlrgtacu||'</vlrgtacu>'||
                              '<dtinirpp>'||to_char(vr_tab_dados_rpp(i1).dtinirpp,'dd/mm/yyyy')||'</dtinirpp>'||
                              '<dtrnirpp>'||to_char(vr_tab_dados_rpp(i1).dtrnirpp,'dd/mm/yyyy')||'</dtrnirpp>'||
                              '<dtaltrpp>'||to_char(vr_tab_dados_rpp(i1).dtaltrpp,'dd/mm/yyyy')||'</dtaltrpp>'||
                              '<dtcancel>'||to_char(vr_tab_dados_rpp(i1).dtcancel,'dd/mm/yyyy')||'</dtcancel>'||
                              '<dssitrpp>'||vr_tab_dados_rpp(i1).dssitrpp||'</dssitrpp>'||
                              '<dsblqrpp>'||vr_tab_dados_rpp(i1).dsblqrpp||'</dsblqrpp>'||
                              '<dsresgat>'||vr_tab_dados_rpp(i1).dsresgat||'</dsresgat>'||  
                              '<dsctainv>'||vr_tab_dados_rpp(i1).dsctainv||'</dsctainv>'||
                              '<dsmsgsaq>'||vr_tab_dados_rpp(i1).dsmsgsaq||'</dsmsgsaq>'||
                              '<cdtiparq>'||vr_tab_dados_rpp(i1).cdtiparq||'</cdtiparq>'||
                              '<dtsldrpp/>'||
                              '<nrdrowid>'||vr_tab_dados_rpp(i1).nrdrowid||'</nrdrowid>'||
                              '<cdprodut>'||vr_tab_dados_rpp(i1).cdprodut||'</cdprodut>'||
                              '<dsfinali>'||vr_tab_dados_rpp(i1).dsfinali||'</dsfinali>'||
                              '</Registro>';

             gene0002.pc_escreve_xml(pr_xml            => vr_clobxmlc
                                    ,pr_texto_completo => vr_xml_temp 
                                    ,pr_texto_novo     => vr_texto_novo);
             vr_texto_novo :='';                                                           
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
END pc_obtem_dados_suspensao_web;

procedure pc_calc_app_programada (pr_cdcooper  in crapcop.cdcooper%type,          --> Cooperativa
                              pr_dstextab  in craptab.dstextab%type,          --> Percentual de IR da aplicação
                              pr_cdprogra  in crapprg.cdprogra%type,          --> Programa chamador
                              pr_inproces  in crapdat.inproces%type,          --> Indicador do processo
                              pr_dtmvtolt  in crapdat.dtmvtolt%type,          --> Data do processo
                              pr_dtmvtopr  in crapdat.dtmvtopr%type,          --> Próximo dia útil
                              pr_rpp_rowid in varchar2,                       --> Identificador do registro da tabela CRAPRPP em processamento
                              pr_vlsdrdpp  in out craprpp.vlsdrdpp%type,      --> Saldo da poupança programada
                              pr_cdcritic out crapcri.cdcritic%type,          --> Codigo da crítica de erro
                              pr_des_erro out varchar2) is                    --> Descrição do erro encontrado
/* ...........................................................................

   Programa: APLI0008.PC_CALC_APP_PROGRAMADA
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : CIS Corporate
   Data    : Julho/2018.                       Ultima atualizacao: 19/08/2018

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina de calculo do RPP  -- Deve ser chamada de dentro de um
               FOR EACH ou DO WHILE e com label TRANS_POUP.

                                   
                                                      
................................................................................................... */
    -- Variaveis para auxiliar nos calculos
    vr_exc_erro         EXCEPTION;
    vr_des_erro         varchar2(4000);
    vr_tab_erro GENE0001.typ_tab_erro;
    
    vr_percenir         number(8,4);
    vr_vlrentot         number(25,8);
    vr_vlrendim         number(25,8);
    vr_vlajuste         number(25,8);
    vr_vlajuste_cr      number(25,8);
    vr_vlajuste_db      number(25,8);
    vr_vlsdrdpp         number(25,8);
    vr_vllan150         craplpp.vllanmto%type;
    vr_vllan152         craplpp.vllanmto%type;
    vr_vllan158         craplpp.vllanmto%type;
    vr_vllan925         craplpp.vllanmto%type;
    vr_vlprovis         number(25,8);
    vr_txaplica         number(25,8);
    vr_txaplmes         number(25,8);
    vr_vlrirrpp         number(25,8);
    vr_vlsdtoap        number(25,8) := 0;
    vr_dtcalcul         craprpp.dtiniper%type;
    vr_dtrefere         craprpp.dtfimper%type;
    vr_dtultdia         craprpp.dtfimper%type;
    vr_dtmvtolt         crapdat.dtmvtolt%type;
    vr_qtmesext         craprpp.qtmesext%type;
    vr_dtdolote         date;
    vr_nrdolote         number(4);
    vr_cdhistor         number(3);
    vr_cdagenci         craplot.cdagenci%type := 1;
    vr_cdbccxlt         craplot.cdbccxlt%type := 100;
    vr_cdprogra         VARCHAR2(20);
    vr_flgimune         boolean;
    vr_flggrvir         boolean;
    vr_des_reto         varchar2(10);
    vr_tptaxrda         craptrd.tptaxrda%type;

    --Variáveis lote
    rw_craplot          lote0001.cr_craplot_sem_lock%rowtype;
    vr_dscritic VARCHAR2(4000);

    -- Informações da poupança programada
    cursor cr_craprpp (pr_rowid in varchar2) is
      select /*+ NOPARALLEL */
             craprpp.vlsdrdpp,
             craprpp.dtiniper,
             craprpp.dtfimper,
             craprpp.vlabcpmf,
             craprpp.qtmesext,
             craprpp.nrdconta,
             craprpp.nrctrrpp,
             craprpp.vlabdiof,
             craprpp.dtmvtolt,
             craprpp.cdprodut
        from craprpp
       where craprpp.rowid = pr_rowid;
    rw_craprpp     cr_craprpp%rowtype;

    -- Taxas de RDCA
    cursor cr_craptrd (pr_cdcooper craptrd.cdcooper%type,
                       pr_dtiniper craptrd.dtiniper%type,
                       pr_vlsdrdpp craptrd.vlfaixas%type,
                       pr_tptaxrda craptrd.tptaxrda%type) is
      select craptrd.rowid,
             craptrd.txofidia,
             craptrd.txofimes,
             craptrd.txprodia,
             craptrd.dtfimper
        from craptrd
       where craptrd.cdcooper  = pr_cdcooper
         and craptrd.dtiniper  = pr_dtiniper
         and craptrd.tptaxrda  = pr_tptaxrda
         and craptrd.incarenc  = 0
         and craptrd.vlfaixas <= pr_vlsdrdpp
       order by craptrd.vlfaixas desc; --find first

    rw_craptrd   cr_craptrd%rowtype;
    -- Taxas de RDCA (sem considerar faixa)
    cursor cr_craptrd2 is
      select dtfimper
        from craptrd
       where craptrd.cdcooper = pr_cdcooper
         and craptrd.dtiniper = rw_craprpp.dtfimper
         and craptrd.tptaxrda = 2
         and craptrd.incarenc = 0
         and craptrd.vlfaixas = 0;
    rw_craptrd2    cr_craptrd2%rowtype;
    -- Cotas e recursos
    cursor cr_crapcot is
      select crapcot.rowid
        from crapcot
       where crapcot.cdcooper = pr_cdcooper
         and crapcot.nrdconta = rw_craprpp.nrdconta;
    rw_crapcot     cr_crapcot%rowtype;

  BEGIN
    vr_cdprogra := pr_cdprogra;

    -- Buscar informações da poupança programada
    open cr_craprpp (pr_rpp_rowid);
      fetch cr_craprpp into rw_craprpp;
    close cr_craprpp;
    --
    vr_percenir := gene0002.fn_char_para_number(pr_dstextab);
    vr_vlrentot := 0;
    vr_vlrendim := 0;
    vr_vlajuste := 0;
    vr_vllan150 := 0;
    vr_vllan152 := 0;
    vr_vllan158 := 0;
    vr_vllan925 := 0;
    vr_vlprovis := 0;
    vr_txaplica := 0;
    vr_txaplmes := 0;
    vr_vlrirrpp := 0;
    vr_dtcalcul := rw_craprpp.dtiniper;
    vr_dtrefere := rw_craprpp.dtfimper;
    vr_vlsdrdpp := rw_craprpp.vlsdrdpp;

    -- Define qual data deve utilizar como último dia
    IF vr_cdprogra = 'CRPS147' then
      vr_dtultdia := last_day(add_months(pr_dtmvtolt, -1));
    else
      vr_dtultdia := last_day(add_months(pr_dtmvtopr, -1));
    end if;

    -- Define qual data deve utilizar como data do movimento
    if pr_inproces > 2 THEN /* BATCH */ 
      IF vr_cdprogra = 'CRPS147' then /* MENSAL */
        -- Cálculo até o dia do movimento
        vr_dtmvtolt := pr_dtmvtolt + 1;
      end if;
    else /* ONLINE */
      IF vr_cdprogra = 'CRPS156' then /* RESGATE */
        -- Cálculo até o dia do resgate
        vr_dtmvtolt := pr_dtmvtopr;
      end if;
    end if;

        apli0008.pc_calc_saldo_apl_prog (pr_cdcooper => pr_cdcooper
                                        ,pr_cdprogra => pr_cdprogra
                                        ,pr_cdoperad => '1'
                                        ,pr_nrdconta => rw_craprpp.nrdconta
                                        ,pr_idseqttl => 1
                                        ,pr_idorigem => 5
                                        ,pr_nrctrrpp => rw_craprpp.nrctrrpp
                                        ,pr_dtmvtolt => pr_dtmvtolt
                                        ,pr_vlsdrdpp => vr_vlsdrdpp
                                        ,pr_des_erro => pr_des_erro);

         if pr_des_erro is not null then
           raise vr_exc_erro;
         end if;

    if vr_vlsdrdpp < 0 or  vr_vlsdrdpp is null then
      vr_vlsdrdpp := 0;
    end if;
    --

    if pr_inproces > 2 and /* BATCH */
       vr_cdprogra in ('CRPS147') then

      /********************************************************************/
      /** Em maio de 2012 o novo calculo foi liberado para utilizacao,   **/
      /** portanto poupancas cadastradas a partir desta data poderiam    **/
      /** ser remuneradas conforme a nova regra, porem, em nosso sistema **/
      /** a nova regra sera utilizada somentepara poupancas cadastradas  **/
      /** apos a liberacao do projeto de novoindexador de poupanca,      **/
      /** pois o passado anterior a liberacaoja foi contratado com a     **/
      /** regra antiga                                                   **/
      /********************************************************************/

      -- Compara da de liberacao do projeto de novo indexador da poupanca
      IF rw_craprpp.dtmvtolt >= to_date('01/07/2014','dd/mm/yyyy') then
        vr_tptaxrda := 4; /*Novo Indexador poupanca - Lei 12.703*/
      ELSE
        vr_tptaxrda := 2; /*Regra Antiga*/
      end IF;

      -- Escolhe a taxa a utilizar
      open cr_craptrd (pr_cdcooper => pr_cdcooper,
                       pr_dtiniper => rw_craprpp.dtiniper,
                       pr_vlsdrdpp => vr_vlsdrdpp,
                       pr_tptaxrda => vr_tptaxrda);
        fetch cr_craptrd into rw_craptrd;
        if cr_craptrd%notfound then
          pr_cdcritic := 347;
          vr_des_erro := gene0001.fn_busca_critica(347)||
                         ' Data: '||to_char(rw_craprpp.dtiniper, 'dd/mm/yyyy')||
                         ' NrCtrRpp: '||to_char(rw_craprpp.nrctrrpp, 'fm999g999g990')||
                         ' Faixa: '||to_char(vr_vlsdrdpp, 'fm999g999g990d00');
          raise vr_exc_erro;
        end if;
      close cr_craptrd;
      if rw_craptrd.txofidia > 0 then
        vr_txaplica := (rw_craptrd.txofidia / 100);
        vr_txaplmes := rw_craptrd.txofimes;
      elsif rw_craptrd.txprodia > 0 then
        vr_txaplica := (rw_craptrd.txprodia / 100);
        vr_txaplmes := 0;
      else
        vr_des_erro := gene0001.fn_busca_critica(427)||
                       ' Data: '||to_char(rw_craprpp.dtiniper, 'dd/mm/yyyy');
        raise vr_exc_erro;
      end if;

      -- Para os programas CRPS147 e 148, foi realizado o upate no próprio crps, visto que teríamos problemas no paralelismo           
      if vr_cdprogra IN('CRPS148','CRPS147') then
        begin

          apli0001.pc_insere_tab_wrk(pr_cdcooper     => pr_cdcooper 
                                    ,pr_nrdconta     => rw_craprpp.nrdconta
                                    ,pr_cdprogra     => vr_cdprogra
                                    ,pr_dsrelatorio  => 'CRAPTRD'
                                    ,pr_dtmvtolt     => pr_dtmvtolt
                                    ,pr_dschave      => rw_craptrd.rowid
                                    ,pr_dsinformacao => null 
                                    ,pr_dscritic     => vr_des_erro);          
        
          if vr_des_erro is not null then
            raise vr_exc_erro; 
    end if;

        exception
          when others then
            vr_des_erro := 'Erro ao chamar procedure apli0001.pc_insere_tab_wrk: '||sqlerrm;
            raise vr_exc_erro;              
        end;
      else
      -- Atualiza o indicador de cálculo
      begin
        update craptrd
             set incalcul = 1
         where rowid = rw_craptrd.rowid;
      exception
        when others then
          vr_des_erro := 'Erro ao atualizar indicador de calculo na craptrd: '||sqlerrm;
          raise vr_exc_erro;
      end;
    end if;
    end if;

    --
    if pr_inproces > 2 and
       vr_cdprogra in ('CRPS147', 'CRPS148') and
       vr_dtcalcul < vr_dtmvtolt and
       vr_vlsdrdpp > 0 then
      -- Acrescenta o rendimento para o período VR_DTCALCUL ate VR_DTMVTOLT
      while vr_dtcalcul < vr_dtmvtolt loop
        -- Busca o próximo dia útil
        vr_dtcalcul := gene0005.fn_valida_dia_util(pr_cdcooper,
                                                   vr_dtcalcul);
        if vr_dtcalcul >= vr_dtmvtolt then
          exit;
        end if;
        -- Incrementa os valores
        vr_vlrendim := trunc(vr_vlsdrdpp * vr_txaplica, 8);
        vr_vlsdrdpp := vr_vlsdrdpp + vr_vlrendim;
        vr_vlrentot := vr_vlrentot + vr_vlrendim;
        if vr_dtcalcul <= vr_dtultdia then
          vr_vlprovis := vr_vlprovis + vr_vlrendim;
        end if;
        -- Próxima data
        vr_dtcalcul := vr_dtcalcul + 1;
      end loop;  /* Fim do WHILE */
    end if;

    /*  Arredondamento dos valores calculados  */
    vr_vlsdrdpp := APLI0001.fn_round(vr_vlsdrdpp,2);
    vr_vlrentot := APLI0001.fn_round(vr_vlrentot,2);
    vr_vlprovis := APLI0001.fn_round(vr_vlprovis,2);
    vr_vlrirrpp := trunc((vr_vlrentot * vr_percenir / 100),2);

    /* Tratamento para Imunidade Tributaria */
    IF pr_inproces > 2  AND upper(pr_cdprogra) = 'CRPS148'   THEN
      vr_flggrvir := TRUE;
    ELSE
      vr_flggrvir := FALSE;
    END IF;

    /* Procedure para verificar imunidade tributaria e inserir valor de insenção */
    IMUT0001.pc_verifica_imunidade_trib(  pr_cdcooper  => pr_cdcooper  --> Codigo Cooperativa
                                         ,pr_nrdconta  => rw_craprpp.nrdconta  --> Numero da Conta
                                         ,pr_dtmvtolt  => pr_dtmvtolt  --> Data movimento
                                         ,pr_flgrvvlr  => vr_flggrvir  --> Identificador se deve gravar valor
                                         ,pr_cdinsenc  => 5            --> Codigo da insenção
                                         ,pr_vlinsenc  => TRUNC((vr_vlrentot *
                                                                 vr_percenir / 100),2)--> Valor insento
                                         ,pr_flgimune  => vr_flgimune  --> Identificador se é imune
                                         ,pr_dsreturn  => vr_des_reto  --> Descricao Critica
                                         ,pr_tab_erro  => vr_tab_erro);--> Tabela erros

    -- Se retornar alguma mensagem de erro
    IF vr_tab_erro.COUNT() > 0 THEN
      -- Mostrar mensagem de log
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_nmarqlog     => gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_MESSAGE')
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || pr_cdprogra || ' --> '
                                                 || vr_tab_erro(vr_tab_erro.FIRST).dscritic);

      -- Limpeza dos erros
      vr_tab_erro.DELETE;
    END IF;

    IF vr_flgimune THEN
      vr_vlrirrpp := 0;
    ELSE
      vr_vlrirrpp := trunc((vr_vlrentot * vr_percenir / 100),2);
    END IF;

    -- Ajusta o saldo da poupança programada
    if pr_inproces = 1 and
       vr_flgimune = false then
      vr_vlsdrdpp := vr_vlsdrdpp - trunc((rw_craprpp.vlabcpmf * vr_percenir / 100), 2);
      if vr_vlsdrdpp < 0 then
        vr_vlsdrdpp := 0;
      end if;
    end if;
    -- Atualiza a variável de retorno
    pr_vlsdrdpp := vr_vlsdrdpp;
    --
    if pr_inproces > 2 then
        vr_dtdolote := pr_dtmvtolt;
        vr_nrdolote := 8383;

        -- Busca a taxa RDCA
        open cr_craptrd2;
          fetch cr_craptrd2 into rw_craptrd2;
          if cr_craptrd2%notfound then
            close cr_craptrd2;
            vr_des_erro := gene0001.fn_busca_critica(347)||
                           ' Data: '||to_char(rw_craprpp.dtfimper, 'dd/mm/yyyy')||
                           ' Conta: '||to_char(rw_craprpp.nrdconta, '9999G999D0')||
                           ' NrCtrRpp: '||to_char(rw_craprpp.nrctrrpp, '999g999');
            raise vr_exc_erro;
          end if;
        close cr_craptrd2;
        --
        vr_qtmesext := rw_craprpp.qtmesext + 1;
        if vr_qtmesext = 4 then
          vr_qtmesext := 1;
        end if;
        if to_char(rw_craprpp.dtfimper, 'mm') = '12' then
          vr_qtmesext := 3;
        end if;
        -- Atualiza poupança programada
        begin
          update craprpp
             set craprpp.qtmesext = vr_qtmesext,
                 craprpp.dtiniext = decode(vr_qtmesext,
                                           1, craprpp.dtfimext,
                                           craprpp.dtiniext),
                 craprpp.dtsdppan = decode(vr_qtmesext,
                                           1, craprpp.dtiniper,
                                           craprpp.dtsdppan),
                 craprpp.vlsdppan = decode(vr_qtmesext,
                                           1, craprpp.vlsdrdpp,
                                           craprpp.vlsdppan),
                 craprpp.incalmes = 0,
                 indebito = 0,
                 craprpp.dtfimext = craprpp.dtfimper,
                 craprpp.dtiniper = craprpp.dtfimper,
                 craprpp.dtfimper = rw_craptrd2.dtfimper,
                 craprpp.vlsdrdpp = pr_vlsdrdpp - vr_vlrirrpp,
                 craprpp.dtcalcul = pr_dtmvtopr
           where craprpp.rowid = pr_rpp_rowid;
        exception
          when others then
            vr_des_erro := 'Erro ao atualizar informações da aplicação programada: '||sqlerrm;
            raise vr_exc_erro;
        end;
        --
        vr_dtdolote := pr_dtmvtopr;
        vr_nrdolote := 8384;
        --vamos informar a agêcia executada no paralelismo
        --e montar a chave para buscar o nrseqdig por ela.
        --
        if rw_craprpp.vlabcpmf > 0 then
          begin
            -- Atualiza o saldo da poupança programada
            update craprpp
               set craprpp.vlsdrdpp = craprpp.vlsdrdpp - trunc((craprpp.vlabcpmf * vr_percenir / 100),2)
             where craprpp.rowid = pr_rpp_rowid;
          exception
            when others then
              vr_des_erro := 'Erro ao atualizar saldo da aplicação programada: '||sqlerrm;
              raise vr_exc_erro;
          end;
        end if;
        -- Lê novamente as informações da craprpp para recuperar os valores atualizados
        open cr_craprpp (pr_rpp_rowid);
          fetch cr_craprpp into rw_craprpp;
        close cr_craprpp;
        --
        begin
          update crapspp
             set crapspp.vlsldrpp = rw_craprpp.vlsdrdpp,
                 crapspp.dtmvtolt = pr_dtmvtolt
           where crapspp.cdcooper = pr_cdcooper
             and crapspp.nrdconta = rw_craprpp.nrdconta
             and crapspp.nrctrrpp = rw_craprpp.nrctrrpp
             and crapspp.dtsldrpp = rw_craprpp.dtiniper;
          --
          if sql%rowcount = 0 then
            -- Não encontrou registro para atualizar, portanto deve incluir um novo
            begin
              insert into crapspp (cdcooper,
                                   nrdconta,
                                   nrctrrpp,
                                   dtsldrpp,
                                   vlsldrpp,
                                   dtmvtolt)
              values (pr_cdcooper,
                      rw_craprpp.nrdconta,
                      rw_craprpp.nrctrrpp,
                      rw_craprpp.dtiniper,
                      rw_craprpp.vlsdrdpp,
                      pr_dtmvtolt);
            exception
              when others then
                vr_des_erro := 'Erro ao inserir saldo da aplicação programada no aniversario: '||sqlerrm;
                raise vr_exc_erro;
            end;
          end if;
        exception
          when vr_exc_erro then
            raise vr_exc_erro;
          when others then
            vr_des_erro := 'Erro ao atualizar saldo da aplicação programada no aniversario: '||sqlerrm;
            raise vr_exc_erro;
        end;
      end if;
      --
      IF vr_cdprogra = 'CRPS147' then
        vr_vlrentot := vr_vlrentot - vr_vlprovis;
      end if;
      --
      if vr_vlrentot > 0 then
        -- Atualizar o tipo do lote
        /* Projeto Revitalizacao - Remocao de lote */
        lote0001.pc_insere_lote_rvt(pr_cdcooper => pr_cdcooper
                                  , pr_dtmvtolt => vr_dtdolote
                                  , pr_cdagenci => vr_cdagenci
                                  , pr_cdbccxlt => vr_cdbccxlt
                                  , pr_nrdolote => vr_nrdolote
                                  , pr_cdoperad => '1'
                                  , pr_nrdcaixa => 0
                                  , pr_tplotmov => 14
                                  , pr_cdhistor => 0
                                  , pr_craplot  => rw_craplot
                                  , pr_dscritic => vr_dscritic);
        
        if vr_dscritic is not null then
          vr_des_erro := 'Erro ao inserir informações da capa de lote: '||vr_dscritic;
              raise vr_exc_erro;
        end if;

      IF vr_cdprogra = 'CRPS147' and
         (vr_vlrentot > 0 or
          rw_craprpp.vlabdiof > 0 or
          vr_vlrirrpp > 0) then
        -- Busca as informações de cotas e recursos
        open cr_crapcot;
          fetch cr_crapcot into rw_crapcot;
          if cr_crapcot%notfound then
            close cr_crapcot;
            pr_cdcritic := 169;
            vr_des_erro := gene0001.fn_busca_critica(169)||
                           ' Conta: '||to_char(rw_craprpp.nrdconta, '9999G999D0');
            raise vr_exc_erro;
          end if;
        close cr_crapcot;
        --
        if vr_vlrentot > 0 then
          -- Atualiza os juros acumulados da poupança programada
          begin
            update craprpp
               set craprpp.vljuracu = craprpp.vljuracu + vr_vlrentot
             where craprpp.rowid = pr_rpp_rowid;
          exception
            when others then
              vr_des_erro := 'Erro ao atualizar os juros acumulados da aplicação programada: '||sqlerrm;
              raise vr_exc_erro;
          end;
          -- Atualiza cotas e recursos (somente os campos correspondentes ao mês de referência)
          begin
            update crapcot
               set crapcot.vlrenrpp = crapcot.vlrenrpp + vr_vlrentot,
                   crapcot.vlrenrpp_ir##1 = crapcot.vlrenrpp_ir##1 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '01', vr_vlrentot,
                                                                            0),
                   crapcot.vlrentot##1 = crapcot.vlrentot##1 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '01', vr_vlrentot,
                                                                      0),
                   crapcot.vlrenrpp_ir##2 = crapcot.vlrenrpp_ir##2 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '02', vr_vlrentot,
                                                                            0),
                   crapcot.vlrentot##2 = crapcot.vlrentot##2 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '02', vr_vlrentot,
                                                                      0),
                   crapcot.vlrenrpp_ir##3 = crapcot.vlrenrpp_ir##3 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '03', vr_vlrentot,
                                                                            0),
                   crapcot.vlrentot##3 = crapcot.vlrentot##3 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '03', vr_vlrentot,
                                                                      0),
                   crapcot.vlrenrpp_ir##4 = crapcot.vlrenrpp_ir##4 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '04', vr_vlrentot,
                                                                            0),
                   crapcot.vlrentot##4 = crapcot.vlrentot##4 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '04', vr_vlrentot,
                                                                      0),
                   crapcot.vlrenrpp_ir##5 = crapcot.vlrenrpp_ir##5 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '05', vr_vlrentot,
                                                                            0),
                   crapcot.vlrentot##5 = crapcot.vlrentot##5 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '05', vr_vlrentot,
                                                                      0),
                   crapcot.vlrenrpp_ir##6 = crapcot.vlrenrpp_ir##6 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '06', vr_vlrentot,
                                                                            0),
                   crapcot.vlrentot##6 = crapcot.vlrentot##6 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '06', vr_vlrentot,
                                                                      0),
                   crapcot.vlrenrpp_ir##7 = crapcot.vlrenrpp_ir##7 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '07', vr_vlrentot,
                                                                            0),
                   crapcot.vlrentot##7 = crapcot.vlrentot##7 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '07', vr_vlrentot,
                                                                      0),
                   crapcot.vlrenrpp_ir##8 = crapcot.vlrenrpp_ir##8 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '08', vr_vlrentot,
                                                                            0),
                   crapcot.vlrentot##8 = crapcot.vlrentot##8 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '08', vr_vlrentot,
                                                                      0),
                   crapcot.vlrenrpp_ir##9 = crapcot.vlrenrpp_ir##9 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '09', vr_vlrentot,
                                                                            0),
                   crapcot.vlrentot##9 = crapcot.vlrentot##9 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '09', vr_vlrentot,
                                                                      0),
                   crapcot.vlrenrpp_ir##10 = crapcot.vlrenrpp_ir##10 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '10', vr_vlrentot,
                                                                            0),
                   crapcot.vlrentot##10 = crapcot.vlrentot##10 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '10', vr_vlrentot,
                                                                      0),
                   crapcot.vlrenrpp_ir##11 = crapcot.vlrenrpp_ir##11 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '11', vr_vlrentot,
                                                                            0),
                   crapcot.vlrentot##11 = crapcot.vlrentot##11 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '11', vr_vlrentot,
                                                                      0),
                   crapcot.vlrenrpp_ir##12 = crapcot.vlrenrpp_ir##12 + decode(to_char(vr_dtrefere, 'mm'),
                                                                            '12', vr_vlrentot,
                                                                            0),
                   crapcot.vlrentot##12 = crapcot.vlrentot##12 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '12', vr_vlrentot,
                                                                      0)
             where crapcot.rowid = rw_crapcot.rowid;
          exception
            when others then
              vr_des_erro := 'Erro ao atualizar cotas e recursos (1): '||sqlerrm;
              raise vr_exc_erro;
          end;
        end if;
        --
        if rw_craprpp.vlabdiof > 0 then
          -- Atualiza os campos correspondentes ao mês de referência
          begin
            update crapcot
               set crapcot.vlabiopp = crapcot.vlabiopp + rw_craprpp.vlabdiof,
                   crapcot.vlrentot##1 = crapcot.vlrentot##1 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '01', rw_craprpp.vlabdiof,
                                                                      0),
                   crapcot.vlrentot##2 = crapcot.vlrentot##2 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '02', rw_craprpp.vlabdiof,
                                                                      0),
                   crapcot.vlrentot##3 = crapcot.vlrentot##3 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '03', rw_craprpp.vlabdiof,
                                                                      0),
                   crapcot.vlrentot##4 = crapcot.vlrentot##4 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '04', rw_craprpp.vlabdiof,
                                                                      0),
                   crapcot.vlrentot##5 = crapcot.vlrentot##5 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '05', rw_craprpp.vlabdiof,
                                                                      0),
                   crapcot.vlrentot##6 = crapcot.vlrentot##6 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '06', rw_craprpp.vlabdiof,
                                                                      0),
                   crapcot.vlrentot##7 = crapcot.vlrentot##7 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '07', rw_craprpp.vlabdiof,
                                                                      0),
                   crapcot.vlrentot##8 = crapcot.vlrentot##8 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '08', rw_craprpp.vlabdiof,
                                                                      0),
                   crapcot.vlrentot##9 = crapcot.vlrentot##9 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '09', rw_craprpp.vlabdiof,
                                                                      0),
                   crapcot.vlrentot##10 = crapcot.vlrentot##10 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '10', rw_craprpp.vlabdiof,
                                                                      0),
                   crapcot.vlrentot##11 = crapcot.vlrentot##11 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '11', rw_craprpp.vlabdiof,
                                                                      0),
                   crapcot.vlrentot##12 = crapcot.vlrentot##12 + decode(to_char(vr_dtrefere, 'mm'),
                                                                      '12', rw_craprpp.vlabdiof,
                                                                      0)
             where crapcot.rowid = rw_crapcot.rowid;
          exception
            when others then
              vr_des_erro := 'Erro ao atualizar cotas e recursos (2): '||sqlerrm;
              raise vr_exc_erro;
          end;
          -- Zerar o abono de IOF
          begin
            update craprpp
               set craprpp.vlabdiof = 0
             where craprpp.rowid = pr_rpp_rowid;
          exception
            when others then
              vr_des_erro := 'Erro ao zerar o abono de IOF na aplicação programada: '||sqlerrm;
              raise vr_exc_erro;
          end;
        end if;
        --
      end if;
      --
      
      IF vr_cdprogra = 'CRPS147' and
         rw_craprpp.vlabcpmf > 0 then
        /* IR sobre o abono de cpmf na poupança */
        if trunc((rw_craprpp.vlabcpmf * vr_percenir / 100),2) > 0 then
          -- Zera o abono de cpfm na poupança programada
          begin
            update craprpp
               set vlabcpmf = 0
             where rowid = pr_rpp_rowid;
          exception
            when others then
              vr_des_erro := 'Erro ao zerar o abono de cpmf na aplicação programada: '||sqlerrm;
              raise vr_exc_erro;
          end;
        end if;
      end if;
      --
      if vr_cdprogra in ('CRPS147', 'CRPS148') then
        /* Ajuste */
        vr_vlajuste := vr_vlprovis - vr_vllan152;
        --
        if vr_vlajuste <> 0 then
          -- Define qual histórico será utilizado
          if vr_vlajuste > 0 then
            vr_vlajuste_cr := abs(vr_vlajuste);
            vr_vlajuste_db := 0;
          else
            vr_vlajuste_cr := 0;
            vr_vlajuste_db := abs(vr_vlajuste);
          end if;
        end if;
      end if;
    end if;
  exception
    when vr_exc_erro THEN
      pr_cdcritic := nvl(pr_cdcritic,0);
      pr_des_erro := vr_des_erro;
    when others then
      pr_cdcritic := 0;
      pr_des_erro := 'Erro ao fazer o cálculo da aplicação programada para a conta '||rw_craprpp.nrdconta||': '||sqlerrm;
END pc_calc_app_programada;

  PROCEDURE pc_lista_aplicacoes_progr (pr_cdcooper    IN craprac.cdcooper%TYPE           --> Código da Cooperativa
                                      ,pr_cdoperad    IN crapope.cdoperad%TYPE           --> Código do Operador
                                      ,pr_nmdatela    IN craptel.nmdatela%TYPE           --> Nome da Tela
                                      ,pr_idorigem    IN INTEGER                         --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA                  
                                      ,pr_nrdcaixa    IN craplot.nrdcaixa%TYPE           --> Numero do Caixa                  
                                      ,pr_nrdconta    IN craprac.nrdconta%TYPE           --> Número da Conta
                                      ,pr_idseqttl    IN crapttl.idseqttl%TYPE           --> Titular da Conta
                                      ,pr_cdagenci    IN crapage.cdagenci%TYPE           --> Codigo da Agencia
                                      ,pr_cdprogra    IN craplog.cdprogra%TYPE           --> Codigo do Programa
                                      ,pr_nraplica    IN craprac.nraplica%TYPE DEFAULT 0 --> Número da Aplicação - Parâmetro Opcional
                                      ,pr_cdprodut    IN craprac.cdprodut%TYPE DEFAULT 0 --> Código do Produto – Parâmetro Opcional 
                                      ,pr_dtmvtolt    IN crapdat.dtmvtolt%TYPE           --> Data de Movimento
                                      ,pr_idconsul    IN INTEGER                         --> Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas)
                                      ,pr_idgerlog    IN INTEGER                         --> Identificador de Log (0 – Não / 1 – Sim)                                                                  
                                      ,pr_tpaplica    IN PLS_INTEGER DEFAULT 0           --> Tipo Aplicacao (0 - Todas / 1 - Não PCAPTA (RDC PÓS, PRE e RDCA) / 2 - Apenas PCAPTA)
                                      ,pr_cdcritic   OUT INTEGER                         --> Código da crítica
                                      ,pr_dscritic   OUT VARCHAR2                        --> Descrição da crítica
                                      ,pr_saldo_rdca OUT apli0001.typ_tab_saldo_rdca) IS --> Tabela com os dados da aplicação

   BEGIN                                                             
     /* .............................................................................

     Programa: pc_lista_aplicacoes_progr
     Sistema : Novos Produtos de Aplicação Programadas
     Sigla   : APLI
     Autor   : CIS Corporate
     Data    : Agosto/18.                    Ultima atualizacao: 22/08/2018

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina geral referente a listagem de aplicacoes.

     Observacao: -----

    ..............................................................................*/                                                
        
        DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
            
            -- Declaração da tabela que conterá os dados da aplicação
            vr_tab_aplica apli0005.typ_tab_aplicacao;
      vr_ind_aplica_tmp VARCHAR2(25);
      vr_saldo_rdca apli0001.typ_tab_saldo_rdca;                 --> Tabela para armazenar saldos de aplicacao
      vr_saldo_rdca_tmp apli0001.typ_tab_saldo_rdca_tmp;         --> Tabela para armazenar saldos de aplicacao
      vr_tab_erro gene0001.typ_tab_erro;                         --> Tabela para armazenar os erros
      
      vr_ind_tab_rdca BINARY_INTEGER;
      vr_nrdrowid ROWID;
      vr_dstransa VARCHAR2(100) := 'Lista aplicacoes.';
      vr_dsorigem VARCHAR2(100) := gene0001.vr_vet_des_origens(pr_idorigem);
      vr_contador PLS_INTEGER;

      BEGIN

          /* 0 - Todas ou 2 - PCAPTA */
          IF pr_tpaplica IN (0,2) THEN
            -- Consulta de novas aplicacoes
          pc_busca_aplicacoes_prog (pr_cdcooper   => pr_cdcooper     --> Código da Cooperativa
                                     ,pr_cdoperad   => pr_cdoperad     --> Código do Operador
                                     ,pr_nmdatela   => pr_nmdatela     --> Nome da Tela
                                     ,pr_idorigem   => pr_idorigem     --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA                  
                                     ,pr_nrdconta   => pr_nrdconta     --> Número da Conta
                                     ,pr_idseqttl   => pr_idseqttl     --> Titular da Conta
                                     ,pr_nraplica   => pr_nraplica     --> Número da Aplicação - Parâmetro Opcional
                                     ,pr_cdprodut   => pr_cdprodut     --> Código do Produto – Parâmetro Opcional 
                                     ,pr_dtmvtolt   => pr_dtmvtolt     --> Data de Movimento
                                     ,pr_idconsul   => pr_idconsul     --> Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas)
                                     ,pr_idgerlog   => 0               --> Identificador de Log (0 – Não / 1 – Sim)                                                                                                 
                                     ,pr_cdcritic   => vr_cdcritic     --> Código da crítica
                                     ,pr_dscritic   => vr_dscritic     --> Descrição da crítica
                                     ,pr_tab_aplica => vr_tab_aplica); --> Tabela com os dados da aplicação );
       
            IF vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_saida;
            END IF;
          END IF;

          /* 0 - Todas ou 1 - Não PCAPTA */
          IF pr_tpaplica IN (0,1) THEN
            -- Consulta de aplicacoes antigas
            APLI0001.pc_consulta_aplicacoes(pr_cdcooper   => pr_cdcooper   --> Cooperativa
                                           ,pr_cdagenci   => pr_cdagenci   --> Codigo da agencia
                                           ,pr_nrdcaixa   => pr_nrdcaixa   --> Numero do caixa
                                           ,pr_nrdconta   => pr_nrdconta   --> Conta do associado
                                           ,pr_nraplica   => pr_nraplica   --> Numero da aplicacao
                                           ,pr_tpaplica   => 0             --> Tipo de aplicacao
                                           ,pr_dtinicio   => NULL          --> Data de inicio da aplicacao
                                           ,pr_dtfim      => NULL          --> Data final da aplicacao
                                           ,pr_cdprogra   => pr_cdprogra   --> Codigo do programa chamador da rotina
                                           ,pr_nrorigem   => pr_idorigem   --> Origem da chamada da rotina
                                           ,pr_saldo_rdca => vr_saldo_rdca --> Tipo de tabela com o saldo RDCA
                                           ,pr_des_reto   => vr_dscritic   --> OK ou NOK
                                           ,pr_tab_erro   => vr_tab_erro); --> Tabela com erros

            IF vr_dscritic = 'NOK' THEN
              -- Se existir erro adiciona na crítica
              vr_cdcritic := vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
              vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
              RAISE vr_exc_saida;
            END IF;
          END IF;                                     

      -- Montagem do XML com todas as aplicacoes que deverao ser exibidas na tela atenda
      IF vr_tab_aplica.COUNT > 0 THEN
        -- Percorre todas as aplicações de captação da conta                                             
        FOR vr_contador IN vr_tab_aplica.FIRST..vr_tab_aplica.LAST LOOP

          -- Proximo indice da tabela vr_saldo_rdca
          vr_ind_tab_rdca := vr_saldo_rdca.COUNT + 1;

          vr_saldo_rdca(vr_ind_tab_rdca).DTMVTOLT := vr_tab_aplica(vr_contador).DTMVTOLT;
          vr_saldo_rdca(vr_ind_tab_rdca).NRAPLICA := vr_tab_aplica(vr_contador).NRAPLICA;
          vr_saldo_rdca(vr_ind_tab_rdca).QTDIAUTI := vr_tab_aplica(vr_contador).QTDIACAR;
          vr_saldo_rdca(vr_ind_tab_rdca).DSHISTOR := vr_tab_aplica(vr_contador).DSNOMENC;
          vr_saldo_rdca(vr_ind_tab_rdca).VLAPLICA := vr_tab_aplica(vr_contador).VLAPLICA;
          vr_saldo_rdca(vr_ind_tab_rdca).NRDOCMTO := vr_tab_aplica(vr_contador).NRAPLICA;
          vr_saldo_rdca(vr_ind_tab_rdca).DTVENCTO := vr_tab_aplica(vr_contador).DTVENCTO;
          vr_saldo_rdca(vr_ind_tab_rdca).INDEBCRE := SUBSTR(vr_tab_aplica(vr_contador).DSBLQRGT,0,1);
          vr_saldo_rdca(vr_ind_tab_rdca).VLLANMTO := vr_tab_aplica(vr_contador).VLSLDTOT;          
          vr_saldo_rdca(vr_ind_tab_rdca).VLSDRDAD := vr_tab_aplica(vr_contador).VLSLDTOT;          
          vr_saldo_rdca(vr_ind_tab_rdca).SLDRESGA := vr_tab_aplica(vr_contador).VLSLDRGT;
          vr_saldo_rdca(vr_ind_tab_rdca).VLSLDRGT := vr_tab_aplica(vr_contador).VLSLDRGT;
          vr_saldo_rdca(vr_ind_tab_rdca).CDDRESGA := vr_tab_aplica(vr_contador).DSRESGAT;
          vr_saldo_rdca(vr_ind_tab_rdca).DTRESGAT := vr_tab_aplica(vr_contador).DTRESGAT;
          vr_saldo_rdca(vr_ind_tab_rdca).DSSITAPL := vr_tab_aplica(vr_contador).DSBLQRGT;
          vr_saldo_rdca(vr_ind_tab_rdca).TXAPLMAX := vr_tab_aplica(vr_contador).TXAPLICA; 
          vr_saldo_rdca(vr_ind_tab_rdca).TXAPLMIN := vr_tab_aplica(vr_contador).TXAPLICA; 
          vr_saldo_rdca(vr_ind_tab_rdca).CDPRODUT := NVL(vr_tab_aplica(vr_contador).CDPRODUT,0);
          vr_saldo_rdca(vr_ind_tab_rdca).NMPRODUT := vr_tab_aplica(vr_contador).NMPRODUT;
          vr_saldo_rdca(vr_ind_tab_rdca).IDTIPAPL := vr_tab_aplica(vr_contador).IDTIPAPL;
          vr_saldo_rdca(vr_ind_tab_rdca).TPAPLICA := vr_tab_aplica(vr_contador).CDPRODUT;
          vr_saldo_rdca(vr_ind_tab_rdca).IDTIPPRO := vr_tab_aplica(vr_contador).IDTIPPRO;
          vr_saldo_rdca(vr_ind_tab_rdca).DTCARENC := vr_tab_aplica(vr_contador).DTMVTOLT + vr_tab_aplica(vr_contador).QTDIACAR;
          -- Campos adicionados para serem usados no INTERNET BANK (extrado de aplicacoes)
          vr_saldo_rdca(vr_ind_tab_rdca).PERCIRRF := vr_tab_aplica(vr_contador).PERCIRRF;
          vr_saldo_rdca(vr_ind_tab_rdca).DSNOMENC := vr_tab_aplica(vr_contador).DSNOMENC;
          vr_saldo_rdca(vr_ind_tab_rdca).QTDIAAPL := vr_tab_aplica(vr_contador).QTDIAAPL;
          vr_saldo_rdca(vr_ind_tab_rdca).IDTXFIXA := vr_tab_aplica(vr_contador).IDTXFIXA;          
          vr_saldo_rdca(vr_ind_tab_rdca).NMDINDEX := vr_tab_aplica(vr_contador).NMDINDEX; 
          vr_saldo_rdca(vr_ind_tab_rdca).CDOPERAD := vr_tab_aplica(vr_contador).CDOPERAD;
          vr_saldo_rdca(vr_ind_tab_rdca).TPAPLRDC := vr_tab_aplica(vr_contador).TPAPLRDC;
          vr_saldo_rdca(vr_ind_tab_rdca).QTDIACAR := vr_tab_aplica(vr_contador).QTDIACAR;
          vr_saldo_rdca(vr_ind_tab_rdca).IDTXFIXA := vr_tab_aplica(vr_contador).IDTXFIXA;
          
        END LOOP;
      END IF;    
      
      -- Ordenacao da temp-table pelo num da aplicacao
      IF vr_saldo_rdca.count() > 0 THEN
        FOR vr_contador IN vr_saldo_rdca.FIRST..vr_saldo_rdca.LAST LOOP
          vr_ind_aplica_tmp := TO_CHAR(vr_saldo_rdca(vr_contador).dtmvtolt,'RRRRMMDD') || lpad(vr_saldo_rdca(vr_contador).nraplica,15,'0');
          vr_saldo_rdca_tmp(vr_ind_aplica_tmp) := vr_saldo_rdca(vr_contador);
        END LOOP;   
      END IF;

      vr_ind_aplica_tmp := vr_saldo_rdca_tmp.FIRST;
      vr_contador := 0;
      vr_saldo_rdca.delete;

      WHILE vr_ind_aplica_tmp IS NOT NULL LOOP
        vr_saldo_rdca(vr_contador) := vr_saldo_rdca_tmp(vr_ind_aplica_tmp);
        vr_ind_aplica_tmp := vr_saldo_rdca_tmp.next(vr_ind_aplica_tmp);
        vr_contador := vr_contador + 1;
      END LOOP;

      pr_saldo_rdca := vr_saldo_rdca;

      -- Verifica se deve gerar log
      IF pr_idgerlog = 1 THEN
        GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => pr_dscritic
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 0 --> FALSE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;  

        EXCEPTION
            WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
                    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
                END IF;

              -- Alimenta parametros com as críticas
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        
        -- Verifica se deve gerar log
        IF pr_idgerlog = 1 THEN
          GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => pr_dscritic
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
        -- Verifica se deve gerar log
        IF pr_idgerlog = 1 THEN
          GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => pr_dscritic
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

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado na APLI0008.pc_lista_aplicacoes: ' || SQLERRM;

        END;
    END pc_lista_aplicacoes_progr;

    PROCEDURE pc_busca_aplicacoes_prog(pr_cdcooper IN craprac.cdcooper%TYPE             --> Código da Cooperativa
                                                             ,pr_cdoperad IN crapope.cdoperad%TYPE             --> Código do Operador
                                                             ,pr_nmdatela IN craptel.nmdatela%TYPE             --> Nome da Tela
                                                             ,pr_idorigem IN INTEGER                           --> Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA                  
                                                             ,pr_nrdconta IN craprac.nrdconta%TYPE             --> Número da Conta
                                                             ,pr_idseqttl IN crapttl.idseqttl%TYPE             --> Titular da Conta
                                                             ,pr_nraplica IN craprac.nraplica%TYPE DEFAULT 0   --> Número da Aplicação - Parâmetro Opcional
                                                             ,pr_cdprodut IN craprac.cdprodut%TYPE DEFAULT 0   --> Código do Produto – Parâmetro Opcional 
                                                             ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE             --> Data de Movimento
                                                             ,pr_idconsul IN INTEGER                           --> Identificador de Consulta (0 – Ativas / 1 – Encerradas / 2 – Todas)
                                                             ,pr_idgerlog IN INTEGER                           --> Identificador de Log (0 – Não / 1 – Sim)                                                                  
                                                             ,pr_cdcritic OUT INTEGER                          --> Código da crítica
                                                             ,pr_dscritic OUT VARCHAR2                         --> Descrição da crítica
                                                             ,pr_tab_aplica OUT apli0005.typ_tab_aplicacao)--> Tabela com os dados da aplicação
                                                             IS  
   BEGIN                                                             
     /* .............................................................................

     Programa: pc_busca_aplicacoes_prog
     Sistema : Novos Produtos de Aplicação Programada
     Sigla   : APLI
     Autor   : CIS
     Data    : Agosto/18.                    Ultima atualizacao: --/--/----

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a busca de aplicacoes programadas.

     Observacao: -----
    ..............................................................................*/                                                
        
        DECLARE
    
      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;
            
            vr_vlbascal NUMBER := 0; -- Base de Calculo
      vr_vlsldtot NUMBER := 0; -- Saldo Total
      vr_vlsldrgt NUMBER := 0; -- Saldo de Resgate
      vr_vlultren NUMBER := 0; -- Ultimo Rendimento
      vr_vlrentot NUMBER := 0; -- Rendimento Total
      vr_vlrevers NUMBER := 0; -- Valor de Reversão
      vr_vlrdirrf NUMBER := 0; -- Valor de IRRF
      vr_percirrf NUMBER := 0; -- Percentual de IRRF

      --Variáveis locais
      vr_dstransa VARCHAR2(100) := 'Busca saldo da aplicacao num: ' || pr_nraplica;
      vr_dsorigem VARCHAR2(100) := gene0001.vr_vet_des_origens(pr_idorigem);
      vr_nrdrowid ROWID;
            
            -- Declaração da tabela que conterá os dados da aplicação
            vr_tab_aplica apli0005.typ_tab_aplicacao;
            vr_ind_aplica PLS_INTEGER := 0;

      -- Seleciona registro de aplicação de captação       
        CURSOR cr_craprac(pr_dtmvtolt_cop IN crapdat.dtmvtolt%TYPE) IS 
              SELECT rac.cdprodut
                      ,rac.cdcooper
                            ,rac.nrdconta
                            ,rac.nraplica
                            ,rac.cdnomenc
                            ,rac.dtmvtolt
                            ,rac.txaplica
                            ,rac.qtdiacar
                            ,rac.vlaplica
              ,rac.vlsldacu
                            ,rac.dtvencto
                            ,rac.idblqrgt
                            ,rac.cdoperad
              ,rac.qtdiaapl
              ,rga.dtresgat
              ,npc.dsnomenc
                  FROM craprac rac, craprga rga, crapnpc npc
         WHERE rac.cdcooper = pr_cdcooper AND
                             rac.nrdconta = pr_nrdconta AND
                            (pr_nraplica = 0 OR rac.nraplica = pr_nraplica) AND
                            (pr_cdprodut = 0 OR rac.cdprodut = pr_cdprodut) AND
                            ( /* Encerradas */
                             (pr_idconsul = 4 AND rac.idsaqtot > 0)         OR
                                /* Todas  */
                             (pr_idconsul = 5)                              OR
                                /* Disponíveis para resgate */
                             (pr_idconsul = 6 AND (rac.idsaqtot = 0         OR
                             (rac.idsaqtot = 1 AND rac.dtatlsld = pr_dtmvtolt_cop))) OR
                                /* Ativas ou Resgatadas ou Vencidas */
                             (rac.idsaqtot = pr_idconsul)
              ) AND
                 rga.cdcooper (+) = rac.cdcooper AND
                 rga.nrdconta (+) = rac.nrdconta AND
                 rga.nraplica (+) = rac.nraplica AND
                 (rga.idresgat (+) = 0 OR
                 (rga.idresgat (+) = 1 AND
                  rga.dtresgat (+) = pr_dtmvtolt_cop AND
                  rga.dtmvtolt (+) = pr_dtmvtolt_cop))
                AND npc.cdnomenc (+) = rac.cdnomenc;

            rw_craprac cr_craprac%ROWTYPE;
            
            -- Seleciona produto de captação
      CURSOR cr_crapcpc(pr_cdprodut crapcpc.cdprodut%TYPE) IS
              SELECT cpc.cddindex
                      ,cpc.idtippro
                            ,cpc.idtxfixa
                            ,cpc.cdprodut
                            ,cpc.nmprodut
                            ,ind.nmdindex
                  FROM crapcpc cpc, crapind ind
                 WHERE cpc.cdprodut = pr_cdprodut
           AND cpc.cddindex = ind.cddindex;         
            rw_crapcpc cr_crapcpc%ROWTYPE;
    
            -- Seleciona registro de resgate disponível
            CURSOR cr_craprga_disp(pr_cdcooper craprga.cdcooper%TYPE
                                                        ,pr_nrdconta craprga.nrdconta%TYPE
                                                        ,pr_nraplica craprga.nraplica%TYPE
                                                        ,pr_dtmvtolt crapdat.dtmvtolt%TYPE) IS
              SELECT craprga.cdcooper, craprga.nrdconta, craprga.nraplica 
                  FROM craprga 
                 WHERE craprga.cdcooper = pr_cdcooper AND
                            craprga.nrdconta = pr_nrdconta AND
                           craprga.nraplica = pr_nraplica AND
                           craprga.idresgat = 1           AND
                           craprga.dtresgat = pr_dtmvtolt AND
                           craprga.dtmvtolt = pr_dtmvtolt;            
             
            -- Seleciona nomenclaturas comerciais dos produtos de captação
            CURSOR cr_crapnpc(pr_cdnomenc crapnpc.cdnomenc%TYPE) IS
              SELECT npc.dsnomenc
                  FROM crapnpc npc
                 WHERE npc.cdnomenc = pr_cdnomenc;
            rw_crapnpc cr_crapnpc%ROWTYPE;
            
            -- Seleciona cadastro de indexadores de remuneração
            CURSOR cr_crapind(pr_cddindex crapind.cddindex%TYPE) IS
              SELECT ind.nmdindex
                  FROM crapind ind
                 WHERE ind.cddindex = pr_cddindex;
            rw_crapind cr_crapind%ROWTYPE;
            
            -- Seleciona operador
            CURSOR cr_crapope(pr_cdcooper crapope.cdcooper%TYPE
                             ,pr_cdoperad crapope.cdoperad%TYPE) IS
                SELECT ope.nmoperad
                  FROM crapope ope
                 WHERE ope.cdcooper = pr_cdcooper
                   AND upper(ope.cdoperad) = upper(pr_cdoperad);
            rw_crapope cr_crapope%ROWTYPE;
            
            -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
      BEGIN
            
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
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;
        
          -- Busca nome do operador
          OPEN cr_crapope(pr_cdcooper => pr_cdcooper
                           ,pr_cdoperad => pr_cdoperad);
            FETCH cr_crapope INTO rw_crapope;
            CLOSE cr_crapope;

            -- Para cada registro de aplicação 
            FOR rw_craprac IN cr_craprac(pr_dtmvtolt_cop => rw_crapdat.dtmvtolt) LOOP

                IF pr_idconsul = 6 THEN                
                    -- Abre cursor para verificar se registro de aplicação está disponível para resgate
                    OPEN cr_craprga_disp(pr_cdcooper => rw_craprac.cdcooper
                                                            ,pr_nrdconta => rw_craprac.nrdconta
                                                            ,pr_nraplica => rw_craprac.nraplica
                                                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt);
                    
                    -- Se não encontrar registro pula para próximo registro de aplicação de captação
                    IF cr_craprga_disp%NOTFOUND THEN
            CLOSE cr_craprga_disp;
                        CONTINUE;
          ELSE
            CLOSE cr_craprga_disp;  
                    END IF;

                END IF;
            
                -- Busca informações do produto cadastrado
                OPEN cr_crapcpc(rw_craprac.cdprodut);
                FETCH cr_crapcpc INTO rw_crapcpc;
              
        -- Verifica se informacoes de produtos existe
        IF cr_crapcpc%NOTFOUND THEN
          CLOSE cr_crapcpc;
          vr_dscritic := 'Erro ao consultar produto.';
          RAISE vr_exc_saida;
        ELSE
          CLOSE cr_crapcpc;
        END IF;

        vr_vlbascal := rw_craprac.vlsldacu;

        -- Se produto for pré-fixado
                IF rw_crapcpc.idtippro = 1 THEN
                  
                  -- Chama procedure para obter saldo atualizado da aplicação
                    APLI0006.pc_posicao_saldo_aplicacao_pre
                                                        (pr_cdcooper => rw_craprac.cdcooper,   --> Código da cooperativa
                                                         pr_nrdconta => rw_craprac.nrdconta,   --> Nr. da conta
                                                         pr_nraplica => rw_craprac.nraplica,   --> Nr. da aplicação
                                                         pr_dtiniapl => rw_craprac.dtmvtolt,   --> Data de inicio da aplicação
                                                         pr_txaplica => rw_craprac.txaplica,   --> Taxa da aplicação
                                                         pr_idtxfixa => rw_crapcpc.idtxfixa,   --> Taxa fixa (1 - Sim/ 2 - Não)
                                                         pr_cddindex => rw_crapcpc.cddindex,   --> Código do indexador
                                                         pr_qtdiacar => rw_craprac.qtdiacar,   --> Dias de carencia
                                                         pr_idgravir => 0,                     --> Não gravar imunidade IRRF
                                                         pr_dtinical => rw_craprac.dtmvtolt,   --> Data inicial cálculo
                                                         pr_dtfimcal => pr_dtmvtolt,           --> Data final cálculo
                                                         pr_idtipbas => 2,                     --> Tipo Base - Total 
                                                         pr_vlbascal => vr_vlbascal,           --> Valor Base Cálculo
                                                         pr_vlsldtot => vr_vlsldtot,           --> Valor saldo total da aplicação
                                                         pr_vlsldrgt => vr_vlsldrgt,           --> Valor saldo total para resgate
                                                         pr_vlultren => vr_vlultren,           --> Valor último rendimento
                                                         pr_vlrentot => vr_vlrentot,           --> Valor rendimento total
                                                         pr_vlrevers => vr_vlrevers,           --> Valor de reversão
                                                         pr_vlrdirrf => vr_vlrdirrf,           --> Valor do IRRF
                                                         pr_percirrf => vr_percirrf,           --> Percentual do IRRF
                                                         pr_cdcritic => vr_cdcritic,           --> Código da crítica
                                                         pr_dscritic => vr_dscritic);          --> Descrição da crítica

                    -- Se retornou crítica                    
                    IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                        vr_dscritic := 'Erro na chamada da procedure APLI0006.pc_posicao_saldo_aplicacao_pre -> '
                                       || vr_dscritic;
                        RAISE vr_exc_saida;
                    END IF;                                     
                                                         
                -- Se produto for pós-fixado
                ELSIF rw_crapcpc.idtippro = 2 THEN
                    
                  -- Chama procedure para obter saldo atualizado da aplicação
                    APLI0006.pc_posicao_saldo_aplicacao_pos(pr_cdcooper => rw_craprac.cdcooper,   --> Código da cooperativa
                                                  pr_nrdconta => rw_craprac.nrdconta,   --> Nr. da conta
                                                  pr_nraplica => rw_craprac.nraplica,   --> Nr. da aplicação
                                                  pr_dtiniapl => rw_craprac.dtmvtolt,   --> Data de inicio da aplicação
                                                  pr_txaplica => rw_craprac.txaplica,   --> Taxa da aplicação
                                                  pr_idtxfixa => rw_crapcpc.idtxfixa,   --> Taxa fixa (1 - Sim/ 2 - Não)
                                                  pr_cddindex => rw_crapcpc.cddindex,   --> Código do indexador
                                                  pr_qtdiacar => rw_craprac.qtdiacar,   --> Dias de carencia
                                                  pr_idgravir => 0,                     --> Não gravar imunidade IRRF
                                                  pr_dtinical => rw_craprac.dtmvtolt,   --> Data inicial cálculo
                                                  pr_dtfimcal => pr_dtmvtolt,           --> Data final cálculo
                                                  pr_idtipbas => 2,                     --> Tipo Base - Total 
                                                  pr_vlbascal => vr_vlbascal,           --> Valor Base Cálculo
                                                  pr_vlsldtot => vr_vlsldtot,           --> Valor saldo total da aplicação
                                                  pr_vlsldrgt => vr_vlsldrgt,           --> Valor saldo total para resgate
                                                  pr_vlultren => vr_vlultren,           --> Valor último rendimento
                                                  pr_vlrentot => vr_vlrentot,           --> Valor rendimento total
                                                  pr_vlrevers => vr_vlrevers,           --> Valor de reversão
                                                  pr_vlrdirrf => vr_vlrdirrf,           --> Valor do IRRF
                                                  pr_percirrf => vr_percirrf,           --> Percentual do IRRF
                                                  pr_cdcritic => vr_cdcritic,           --> Código da crítica
                                                  pr_dscritic => vr_dscritic);          --> Descrição da crítica);                       
                   
                    -- Se retornou crítica
                    IF vr_cdcritic <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                        vr_dscritic := 'Erro na chamada da procedure APLI0006.pc_posicao_saldo_aplicacao_pos  -> '
                                       || vr_dscritic;
                        RAISE vr_exc_saida;
                    END IF;
                
                END IF; -- if rw_crapcpc.idtippro

          -- Buscar qual a quantidade atual de registros na tabela para posicionar na próxima
          vr_ind_aplica := vr_tab_aplica.COUNT() + 1;

              vr_tab_aplica(vr_ind_aplica).nraplica := TRIM(rw_craprac.nraplica);            --> Nr. da aplicação
                vr_tab_aplica(vr_ind_aplica).idtippro := TRIM(rw_crapcpc.idtippro);            --> Tipo do produto
                vr_tab_aplica(vr_ind_aplica).cdprodut := TRIM(rw_craprac.cdprodut);            --> Cód. do produto
                vr_tab_aplica(vr_ind_aplica).nmprodut := TRIM(rw_crapcpc.nmprodut);            --> Nome do produto
                
        IF rw_craprac.dsnomenc IS NOT NULL THEN                                                 
                  vr_tab_aplica(vr_ind_aplica).dsnomenc := TRIM(rw_craprac.dsnomenc);          --> Descrição da nomenclatura do produto de captação
                ELSE 
                    vr_tab_aplica(vr_ind_aplica).dsnomenc := TRIM(rw_crapcpc.nmprodut);          --> Nome do produto
                END IF;

                vr_tab_aplica(vr_ind_aplica).nmdindex := TRIM(rw_crapcpc.nmdindex);            --> Nome do indexador 
                vr_tab_aplica(vr_ind_aplica).vlaplica := TRIM(rw_craprac.vlaplica);            --> Valor da aplicação
                vr_tab_aplica(vr_ind_aplica).vlsldtot := TRIM(vr_vlsldtot);                    --> Valor saldo total da aplicação
                vr_tab_aplica(vr_ind_aplica).vlsldrgt := TRIM(vr_vlsldrgt);                    --> Valor saldo total para resgate
                vr_tab_aplica(vr_ind_aplica).vlrdirrf := TRIM(vr_vlrdirrf);                    --> Valor do IRRF
                vr_tab_aplica(vr_ind_aplica).percirrf := TRIM(vr_percirrf);                    --> Percentual do IRRF
                vr_tab_aplica(vr_ind_aplica).dtmvtolt := TRIM(rw_craprac.dtmvtolt);            --> Data de movimento da aplicação
                vr_tab_aplica(vr_ind_aplica).dtvencto := TRIM(rw_craprac.dtvencto);            --> Data de vencimento da aplicação
                vr_tab_aplica(vr_ind_aplica).qtdiacar := TRIM(rw_craprac.qtdiacar);            --> Quantidade de dias da carência da aplicação
                vr_tab_aplica(vr_ind_aplica).txaplica := TRIM(rw_craprac.txaplica);            --> Taxa da aplicação
                vr_tab_aplica(vr_ind_aplica).idblqrgt := TRIM(rw_craprac.idblqrgt);            --> Indicador de bloqueio de resgate (0-Desbloqueada/1-Bloqueada BLQRGT/2-Bloqueada ADTIVI) 
        vr_tab_aplica(vr_ind_aplica).qtdiauti := TRIM(rw_craprac.qtdiaapl);            --> Qtd dias de aplicacao
                vr_tab_aplica(vr_ind_aplica).idtxfixa := TRIM(rw_crapcpc.idtxfixa);            --> Produto com taxa fixa (1 - SIM / 2 - NAO)
        vr_tab_aplica(vr_ind_aplica).qtdiaapl := TRIM(rw_craprac.qtdiaapl);            --> Qtd dias de aplicacao
                
        IF rw_craprac.idblqrgt = 0 THEN 
                  vr_tab_aplica(vr_ind_aplica).dsblqrgt := TRIM('DISPONIVEL');                 --> Descrição do indicador de bloque de resgate
                ELSE 
                  vr_tab_aplica(vr_ind_aplica).dsblqrgt := TRIM('BLOQUEADA');                  --> Descrição do indicador de bloque de resgate
                END IF;

                IF rw_craprac.dtresgat IS NOT NULL THEN
                  vr_tab_aplica(vr_ind_aplica).dsresgat := TRIM('SIM');                        --> Solicitação de resgate SIM/NAO
                ELSE
                    vr_tab_aplica(vr_ind_aplica).dsresgat := TRIM('NAO');                        --> Solicitação de resgate SIM/NAO
        END IF;    
            
                IF rw_craprac.dtresgat IS NOT NULL THEN 
          vr_tab_aplica(vr_ind_aplica).dtresgat := rw_craprac.dtresgat;          --> Data do resgate
                END IF;                
                vr_tab_aplica(vr_ind_aplica).cdoperad := TRIM(rw_craprac.cdoperad);            --> Cód. do operador
                vr_tab_aplica(vr_ind_aplica).nmoperad := TRIM(rw_crapope.nmoperad);            --> Nome do operador
                vr_tab_aplica(vr_ind_aplica).idtipapl := TRIM('N');                            --> Identificador de nova aplicacao
        
            END LOOP; -- FOR rw_craprac

            -- Alimenta parâmetro com a PL/Table gerada
            pr_tab_aplica := vr_tab_aplica;
            
            -- Gerar log
            IF pr_idgerlog = 1 THEN
          GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => pr_dscritic
                              ,pr_dsorigem => GENE0002.fn_busca_entrada(pr_postext => pr_idorigem,pr_dstext => vr_dsorigem,pr_delimitador => ',')
                              ,pr_dstransa => vr_dstransa
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 1 --> FALSE
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

              -- Alimenta parametros com as críticas
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
        
        -- Verifica se deve gerar log
        IF pr_idgerlog = 1 THEN
          GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => pr_dscritic
                              ,pr_dsorigem => GENE0002.fn_busca_entrada(pr_postext => pr_idorigem,pr_dstext => vr_dsorigem,pr_delimitador => ',')
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
        pr_dscritic := 'Erro nao tratado na APLI0005.pc_busca_aplicacoes: ' || SQLERRM;
        
        -- Verifica se deve gerar log
        IF pr_idgerlog = 1 THEN
          GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => pr_dscritic
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
        END;
    END pc_busca_aplicacoes_prog;

  PROCEDURE pc_impres_termo_adesao_ap(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                     ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Código da agencia
                                     ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                     ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Código do Operador
                                     ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da Tela
                                     ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                     ,pr_cdprogra IN crapprg.cdprogra%TYPE  --> Codigo do programa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de Movimento
                                     ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE  --> Contrato
                                     ,pr_flgerlog IN INTEGER                --> Indicador se deve gerar log(0-nao, 1-sim)
                                     ,pr_nmarqpdf OUT VARCHAR2              --> Nome do PDF                           
                                     ,pr_dssrvarq OUT VARCHAR2              --> Diretorio do servidor do PDF                           
                                     ,pr_dsdirarq OUT VARCHAR2              --> Diretorio do PDF                           
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da crítica
    /* .............................................................................

     Programa: pc_impres_termo_adesao_ap
     Sistema : Rotinas referentes à aplicação programada
     Sigla   : CRED
     Autor   : CIS Corporate
     Data    : Agosto/2018.                    

     Dados referentes ao programa:

     Frequencia:
     Objetivo  : Rotina para geração do Termo de Adesão de uma Aplicação programada
     Alteracoes: 
     
    ..............................................................................*/
    
    ---- Cursores
    
     CURSOR cr_info IS
     SELECT
        cop.nmcidade, 
        cop.cdufdcop,
        ass.cdagenci, -- numero da PA
        ass.nmprimtl,
        ass.nrcpfcgc,
        ass.inpessoa,
        rpp.dtmvtolt,
        rpp.vlprerpp,
        (CASE 
          WHEN (diadebit IS NOT NULL) THEN diadebit
          ELSE extract (day from dtdebito)
          END) indiadeb,
        (CASE 
           WHEN ((rpp.dsfinali IS NULL) and (cpc.nmprodut IS NOT NULL)) OR ((rpp.dsfinali IS NOT NULL) and (trim(rpp.dsfinali))is null)  THEN cpc.nmprodut
           WHEN ((rpp.dsfinali IS NOT NULL) and (trim(rpp.dsfinali))is not null) THEN rpp.dsfinali
           END) dsfinali
     FROM 
        crapcop cop, 
        crapass ass, 
        craprpp rpp, 
        crapcpc cpc
  WHERE ass.cdcooper = pr_cdcooper
    AND ass.nrdconta = pr_nrdconta
    AND rpp.nrctrrpp = pr_nrctrrpp
    AND ass.cdcooper = cop.cdcooper
    AND ass.cdcooper = rpp.cdcooper
    AND ass.nrdconta = rpp.nrdconta
    AND rpp.cdprodut = cpc.cdprodut;
    
    rw_info cr_info%ROWTYPE;
    
    -- RG
    CURSOR cr_rg IS
    SELECT nrdocttl 
      FROM crapttl 
     WHERE tpdocttl = 'CI'
      AND cdcooper = pr_cdcooper
      AND nrdconta = pr_nrdconta;
    rw_rg cr_rg%ROWTYPE;

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
    
    vr_rg varchar2(20);
        
    vr_dsmailcop VARCHAR2(4000);
    vr_dsassmail VARCHAR2(200);
    vr_dscormail VARCHAR2(50);

    vr_cpfcgc VARCHAR2 (30);    
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
                                         
    vr_nmendter := vr_dsdireto ||'/rl/taap001';
    
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
    pr_nmarqpdf := 'taap001'|| gene0002.fn_busca_time || '.pdf';

    --> Buscar dados para impressao do Termo de Adesão 
    OPEN cr_info;
    FETCH cr_info INTO rw_info;
    IF cr_info%NOTFOUND THEN
        vr_dscritic:='Aplicacao programada nao encontrada.';
        CLOSE cr_info;
        RAISE vr_exc_erro;
    END IF;
    CLOSE cr_info;

    -- Busca rg
    OPEN cr_rg;
    FETCH cr_rg INTO rw_rg;
    IF cr_rg%FOUND THEN
       vr_rg := rw_rg.nrdocttl;
    END IF;
    CLOSE cr_rg;

    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    
    vr_txtcompl := NULL;
    IF rw_info.inpessoa = 1 THEN -- CPF 
        vr_cpfcgc := regexp_replace(lpad(rw_info.nrcpfcgc,11,0), '([0-9]{3})([0-9]{3})([0-9]{3})([0-9]{2})', '\1.\2.\3-\4');
    ELSE -- CNPJ
        vr_cpfcgc := regexp_replace(lpad(rw_info.nrcpfcgc,14,0), '([0-9]{2})([0-9]{3})([0-9]{3})([0-9]{4})([0-9]{2})', '\1.\2.\3/\4-\5') ;      
    END IF;
    
    --> INICIO
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz>'); 
    
    pc_escreve_xml('<nrctrrpp>'     || to_char(pr_nrctrrpp,'fm99g999g990','NLS_NUMERIC_CHARACTERS=,.') ||'</nrctrrpp>'||
                   '<nomeCompleto>' || rw_info.nmprimtl     ||'</nomeCompleto>'||     
                   '<contaCorrente>'|| to_char(pr_nrdconta,'fm9g999g999g0','NLS_NUMERIC_CHARACTERS=,.') ||'</contaCorrente>'||     
                   '<cpf>'          || vr_cpfcgc     ||'</cpf>'||
                   '<valorParcela>' || to_char(rw_info.vlprerpp,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS=,.') ||'</valorParcela>'||
                   '<identidade>'   || vr_rg                ||'</identidade>'|| 
                   '<postoAtendimento>'||rw_info.cdagenci   ||'</postoAtendimento>'||
                   '<cidade>'       || rw_info.nmcidade     ||'</cidade>'||
                   '<uf>'           || rw_info.cdufdcop     ||'</uf>'||
                   '<dataInicio>'   || to_char(rw_info.dtmvtolt,'dd/mm/yyyy') ||'</dataInicio>'||
                   '<finalidade>'   || rw_info.dsfinali     ||'</finalidade>'||
                   '<indice>'       || 'CDI'                ||'</indice>'||
                   '<carencia>'     || '30'                 ||'</carencia>'||
                   '<diaDebito>'    || rw_info.indiadeb     ||'</diaDebito>');    
    --> Descarregar buffer    
    pc_escreve_xml(' ',TRUE); 
    
    --> Descarregar buffer    
    pc_escreve_xml('</raiz>',TRUE); 
    
   loop exit when l_offset > dbms_lob.getlength(vr_des_xml);
   l_offset := l_offset + 255;
   end loop;
    
    --> Solicita geracao do PDF
    gene0002.pc_solicita_relato(pr_cdcooper   => pr_cdcooper
                               , pr_cdprogra  => pr_cdprogra
                               , pr_dtmvtolt  => pr_dtmvtolt
                               , pr_dsxml     => vr_des_xml
                               , pr_dsxmlnode => '/raiz'
                               , pr_dsjasper  => 'termo_adesao_appr.jasper'
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
    ELSE
          gene0002.pc_copia_arq_para_download(pr_cdcooper => pr_cdcooper, 
                                          pr_dsdirecp => vr_dsdireto ||'/rl/', 
                                          pr_nmarqucp => pr_nmarqpdf, 
                                          pr_flgcopia => 1, 
                                          pr_dssrvarq => pr_dssrvarq, 
                                          pr_dsdirarq => pr_dsdirarq,
                                          pr_des_erro => vr_dscritic);

    END IF;        
    
    --> Gerar log de sucesso
    IF pr_flgerlog = 1 THEN
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                           pr_cdoperad => pr_cdoperad, 
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
                                pr_nmdcampo => 'nrctrrpp', 
                                pr_dsdadant => NULL, 
                                pr_dsdadatu => pr_nrctrrpp);
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
                             pr_cdoperad => pr_cdoperad, 
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
                                  pr_nmdcampo => 'nrctrrpp', 
                                  pr_dsdadant => NULL, 
                                  pr_dsdadatu => pr_nrctrrpp);
      END IF;
      
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := replace(replace('Erro ao gerar impressao do termo de adesao: ' || SQLERRM, chr(13)),chr(10));   
  
      IF pr_flgerlog = 1 THEN
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                             pr_cdoperad => pr_cdoperad, 
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
                                  pr_nmdcampo => 'nrctrrpp', 
                                  pr_dsdadant => NULL, 
                                  pr_dsdadatu => pr_nrctrrpp);
      END IF; 
      
  END pc_impres_termo_adesao_ap;

  PROCEDURE pc_impres_termo_adesao_ib(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                     ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Código da agencia
                                     ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                     ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Código do Operador
                                     ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da Tela
                                     ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                     ,pr_cdprogra IN crapprg.cdprogra%TYPE  --> Codigo do programa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de Movimento
                                     ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE  --> Contrato
                                     ,pr_inprevio IN INTEGER                --> Indicador se deve gerar log(0-nao, 1-sim)
                                     ,pr_vlprerpp IN craprpp.vlprerpp%TYPE  --> Valor Previsto
                                     ,pr_dtmvinic IN craprpp.dtmvtolt%TYPE  --> Data de Inicio de Contratacao
                                     ,pr_dsfinali IN craprpp.dsfinali%TYPE  --> Descricao de Finalidade
                                     ,pr_indiadeb IN INTEGER              --> Dia de Debito
                                     ,pr_flgerlog IN INTEGER                --> Indicador se deve gerar log(0-nao, 1-sim)
                                     ,pr_nmarqpdf OUT VARCHAR2              --> Nome do PDF                           
                                     ,pr_dssrvarq OUT VARCHAR2              --> Diretorio do servidor do PDF                           
                                     ,pr_dsdirarq OUT VARCHAR2              --> Diretorio do PDF                           
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da crítica
    /* .............................................................................

     Programa: pc_impres_termo_adesao_ib
     Sistema : Rotinas referentes à aplicação programada
     Sigla   : CRED
     Autor   : CIS Corporate
     Data    : Agosto/2018.                    

     Dados referentes ao programa:

     Frequencia:
     Objetivo  : Rotina para geração do Termo de Adesão de uma Aplicação programada atraves de canais eletronicos
     Alteracoes: 
     
    ..............................................................................*/
    
    ---- Cursores
    
    ---- Cursores
    
     CURSOR cr_info IS
     SELECT
        cop.nmcidade, 
        cop.cdufdcop,
        ass.cdagenci, -- numero da PA
        ass.nmprimtl,
        ass.nrcpfcgc,
        ass.inpessoa
     FROM 
        crapcop cop, 
        crapass ass
  WHERE ass.cdcooper = pr_cdcooper
    AND ass.nrdconta = pr_nrdconta
    AND ass.cdcooper = cop.cdcooper;
    
    rw_info cr_info%ROWTYPE;
    
     CURSOR cr_rpp IS
     SELECT
        rpp.dtmvtolt,
        rpp.vlprerpp,
        (CASE 
          WHEN (diadebit IS NOT NULL) THEN diadebit
          ELSE extract (day from dtdebito)
          END) indiadeb,
        (CASE 
           WHEN ((rpp.dsfinali IS NULL) and (cpc.nmprodut IS NOT NULL)) OR ((rpp.dsfinali IS NOT NULL) and (trim(rpp.dsfinali))is null)  THEN cpc.nmprodut
           WHEN ((rpp.dsfinali IS NOT NULL) and (trim(rpp.dsfinali))is not null) THEN rpp.dsfinali
           END) dsfinali
     FROM 
        craprpp rpp, 
        crapcpc cpc
  WHERE rpp.cdcooper = pr_cdcooper
    AND rpp.nrdconta = pr_nrdconta
    AND rpp.nrctrrpp = pr_nrctrrpp
    AND rpp.cdprodut = cpc.cdprodut;
    
    rw_rpp cr_rpp%ROWTYPE;
    -- RG
    CURSOR cr_rg IS
    SELECT nrdocttl 
      FROM crapttl 
     WHERE tpdocttl = 'CI'
      AND cdcooper = pr_cdcooper
      AND nrdconta = pr_nrdconta;
    rw_rg cr_rg%ROWTYPE;

    CURSOR cr_craptab (pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT * 
      FROM   craptab tab
      WHERE  tab.cdcooper = pr_cdcooper
      AND    tab.nmsistem = 'CRED'
      AND    tab.tptabela = 'GENERI'     
      AND    tab.cdempres = 0           
      AND    tab.cdacesso = 'PZMAXPPROG' 
      AND    tab.tpregist = 2;                
    rw_craptab cr_craptab%ROWTYPE;

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
    
    vr_rg varchar2(20);
        
    vr_dsmailcop VARCHAR2(4000);
    vr_dsassmail VARCHAR2(200);
    vr_dscormail VARCHAR2(50);

    vr_cpfcgc VARCHAR2 (30);    
    -- Variáveis para armazenar as informações em XML
    vr_des_xml   CLOB;
    vr_txtcompl  VARCHAR2(32600);
    
    l_offset     NUMBER:=0;
    
    vr_pzmaxpro pls_integer := 0;      -- Prazo 
     
    vr_vlprerpp craprpp.vlprerpp%TYPE := pr_vlprerpp;
    vr_dtmvtolt craprpp.dtmvtolt%TYPE := pr_dtmvinic;
    vr_dsfinali craprpp.dsfinali%TYPE := pr_dsfinali;
    vr_indiadeb craprpp.diadebit%TYPE := pr_indiadeb;

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
                                         
    vr_nmendter := vr_dsdireto ||'/rl/taap001';
    
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
    pr_nmarqpdf := 'taap001'|| gene0002.fn_busca_time || '.pdf';

    --> Buscar dados para impressao do Termo de Adesão 
    OPEN cr_info;
    FETCH cr_info INTO rw_info;
    IF cr_info%NOTFOUND THEN
        vr_dscritic:='Aplicacao programada nao encontrada.';
        CLOSE cr_info;
        RAISE vr_exc_erro;
    END IF;
    CLOSE cr_info;

    Open cr_craptab (pr_cdcooper);
    Fetch cr_craptab Into rw_craptab;
    CLOSE cr_craptab;
    IF (rw_craptab.dstextab IS NULL) THEN
        vr_pzmaxpro := 0;
    ELSE
        vr_pzmaxpro := rw_craptab.dstextab;
    END IF;

    -- Busca rg
    OPEN cr_rg;
    FETCH cr_rg INTO rw_rg;
    IF cr_rg%FOUND THEN
       vr_rg := rw_rg.nrdocttl;
    END IF;
    CLOSE cr_rg;

    --> Buscar dados de aplicacao para Termo de Adesão 
    IF (pr_inprevio = 0) THEN
        OPEN cr_rpp;
        FETCH cr_rpp INTO rw_rpp;
        IF cr_rpp%NOTFOUND THEN
            vr_dscritic:='Aplicacao programada nao encontrada.';
            CLOSE cr_rpp;
            RAISE vr_exc_erro;
        END IF;

        vr_vlprerpp := rw_rpp.vlprerpp;
            vr_dtmvtolt := rw_rpp.dtmvtolt;
            vr_dsfinali := rw_rpp.dsfinali;
            vr_indiadeb := rw_rpp.indiadeb;

        CLOSE cr_rpp;
     END IF;

    -- Inicializar o CLOB
    vr_des_xml := NULL;
    dbms_lob.createtemporary(vr_des_xml, TRUE);
    dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
    
    vr_txtcompl := NULL;
    IF rw_info.inpessoa = 1 THEN -- CPF 
        vr_cpfcgc := regexp_replace(lpad(rw_info.nrcpfcgc,11,0), '([0-9]{3})([0-9]{3})([0-9]{3})([0-9]{2})', '\1.\2.\3-\4');
    ELSE -- CNPJ
        vr_cpfcgc := regexp_replace(lpad(rw_info.nrcpfcgc,14,0), '([0-9]{2})([0-9]{3})([0-9]{3})([0-9]{4})([0-9]{2})', '\1.\2.\3/\4-\5') ;      
    END IF;
    
    --> INICIO
    pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><raiz>'); 
    
    pc_escreve_xml('<nrctrrpp>'     || to_char(pr_nrctrrpp,'fm99g999g990','NLS_NUMERIC_CHARACTERS=,.') ||'</nrctrrpp>'||
                   '<nomeCompleto>' || rw_info.nmprimtl     ||'</nomeCompleto>'||     
                   '<contaCorrente>'|| to_char(pr_nrdconta,'fm9g999g999g0','NLS_NUMERIC_CHARACTERS=,.') ||'</contaCorrente>'||     
                   '<cpf>'          || vr_cpfcgc     ||'</cpf>'||
                   '<valorParcela>' || to_char(vr_vlprerpp,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS=,.') ||'</valorParcela>'||
                   '<identidade>'   || vr_rg                ||'</identidade>'|| 
                   '<postoAtendimento>'||rw_info.cdagenci   ||'</postoAtendimento>'||
                   '<cidade>'       || rw_info.nmcidade     ||'</cidade>'||
                   '<uf>'           || rw_info.cdufdcop     ||'</uf>'||
                   '<dataInicio>'   || to_char(vr_dtmvtolt,'dd/mm/yyyy') ||'</dataInicio>'||
                   '<finalidade>'   || vr_dsfinali     ||'</finalidade>'||
                   '<indice>'       || 'CDI'                ||'</indice>'||
                   '<carencia>'     || '30'                 ||'</carencia>'||
                   '<remuneracao>'     || 'Diária'                 ||'</remuneracao>'||
                   '<quantidadeDiasContrato>'||vr_pzmaxpro / 12||'</quantidadeDiasContrato>'||
                   '<diaDebito>'    || vr_indiadeb     ||'</diaDebito>');    

    --> Descarregar buffer    
    pc_escreve_xml(' ',TRUE); 
    
    --> Descarregar buffer    
    pc_escreve_xml('</raiz>',TRUE); 
    
   loop exit when l_offset > dbms_lob.getlength(vr_des_xml);
   l_offset := l_offset + 255;
   end loop;
    
    --> Solicita geracao do PDF
    gene0002.pc_solicita_relato(pr_cdcooper   => pr_cdcooper
                               , pr_cdprogra  => pr_cdprogra
                               , pr_dtmvtolt  => pr_dtmvtolt
                               , pr_dsxml     => vr_des_xml
                               , pr_dsxmlnode => '/raiz'
                               , pr_dsjasper  => 'termo_adesao_appr.jasper'
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
    ELSE
          gene0002.pc_copia_arq_para_download(pr_cdcooper => pr_cdcooper, 
                                          pr_dsdirecp => vr_dsdireto ||'/rl/', 
                                          pr_nmarqucp => pr_nmarqpdf, 
                                          pr_flgcopia => 1, 
                                          pr_dssrvarq => pr_dssrvarq, 
                                          pr_dsdirarq => pr_dsdirarq,
                                          pr_des_erro => vr_dscritic);

    END IF;        
    
    --> Gerar log de sucesso
    IF pr_flgerlog = 1 THEN
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                           pr_cdoperad => pr_cdoperad, 
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
                                pr_nmdcampo => 'nrctrrpp', 
                                pr_dsdadant => NULL, 
                                pr_dsdadatu => pr_nrctrrpp);
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
                             pr_cdoperad => pr_cdoperad, 
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
                                  pr_nmdcampo => 'nrctrrpp', 
                                  pr_dsdadant => NULL, 
                                  pr_dsdadatu => pr_nrctrrpp);
      END IF;
      
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := replace(replace('Erro ao gerar impressao do termo de adesao: ' || SQLERRM, chr(13)),chr(10));   
  
      IF pr_flgerlog = 1 THEN
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                             pr_cdoperad => pr_cdoperad, 
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
                                  pr_nmdcampo => 'nrctrrpp', 
                                  pr_dsdadant => NULL, 
                                  pr_dsdadatu => pr_nrctrrpp);
      END IF; 
      
  END pc_impres_termo_adesao_ib;

  PROCEDURE pc_impres_termo_adesao_ap_web (pr_nrdconta IN craprac.nrdconta%TYPE   -- Número da Conta
                                          ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE   -- Número da Aplicação Programada.
                                          ,pr_dtmvtolt IN VARCHAR2                -- Data de Movimento Inicial
                                          ,pr_flgerlog IN INTEGER                --> Indicador se deve gerar log(0-nao, 1-sim)
                                          ,pr_xmllog   IN VARCHAR2                -- XML com informacoes de LOG
                                          ,pr_cdcritic OUT PLS_INTEGER            -- Código da crítica
                                          ,pr_dscritic OUT VARCHAR2               -- Descrição da crítica
                                          ,pr_retxml   IN OUT NOCOPY XMLType      -- Arquivo de retorno do XML
                                          ,pr_nmdcampo OUT VARCHAR2               -- Nome do campo com erro
                                          ,pr_des_erro OUT VARCHAR2)              -- Erros do processo

  IS
  BEGIN
    /* .............................................................................

     Programa: pc_impres_termo_adesao_ap_web
     Sistema : Rotinas referentes à aplicação programada
     Sigla   : CRED
     Autor   : CIS Corporate
     Data    : Agosto/2018.                    

     Dados referentes ao programa:

     Frequencia:
     Objetivo  : Rotina para geração do Termo de Adesão de uma Aplicação programada - Mensageria
     Alteracoes: 
     
    ..............................................................................*/

  DECLARE
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    
    vr_nmarqpdf VARCHAR2(100);
    vr_dssrvarq VARCHAR2(200);
    vr_dsdirarq VARCHAR2(200);
    
    -- Variaveis auxiliares
    vr_exc_erro EXCEPTION;

    -- Variaveis de entrada
    vr_dtmvtolt Date := TO_DATE(pr_dtmvtolt,'dd/mm/yyyy');  

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
    
    vr_inprevio pls_integer := 0;      -- Indicador de Previo de Contrato 

    vr_vlprerpp craprpp.vlprerpp%TYPE;
    vr_dtmvinic craprpp.dtmvtolt%TYPE;
    vr_dsfinali craprpp.dsfinali%TYPE;
    vr_indiadeb craprpp.diadebit%TYPE;
    
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

     FOR data IN (SELECT VALUE(xml) col_val
             FROM TABLE(XMLSEQUENCE(EXTRACT(pr_retxml, '/Root/Dados/Registros/PrevioContrato'))) xml
            )LOOP
                vr_inprevio := 1;
            vr_vlprerpp := to_number(data.col_val.EXTRACT('/PrevioContrato/vlprerpp/text()').getstringVal(), '9999999999999999D99', 'NLS_NUMERIC_CHARACTERS=''.,''');
            vr_dtmvtolt := NULL;
            vr_dsfinali := data.col_val.EXTRACT('/PrevioContrato/dsfinali/text()').getstringVal();
            vr_indiadeb := data.col_val.EXTRACT('/PrevioContrato/indiadeb/text()').getstringVal();
     END LOOP;

    -- Imprime o termo
    IF (vr_inprevio = 0) THEN
    pc_impres_termo_adesao_ap (pr_cdcooper => vr_cdcooper
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdprogra => 'ATENDA'
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_dtmvtolt => vr_dtmvtolt
                              ,pr_nrctrrpp => pr_nrctrrpp
                              ,pr_flgerlog => pr_flgerlog
                              ,pr_nmarqpdf => vr_nmarqpdf
                                  ,pr_dssrvarq => vr_dssrvarq
                                  ,pr_dsdirarq => vr_dsdirarq
                              ,pr_cdcritic => vr_cdcritic
                              ,pr_dscritic => vr_dscritic);
    ELSE
        pc_impres_termo_adesao_ib (pr_cdcooper => vr_cdcooper
                                  ,pr_cdagenci => vr_cdagenci
                                  ,pr_nrdcaixa => vr_nrdcaixa
                                  ,pr_cdoperad => vr_cdoperad
                                  ,pr_nmdatela => vr_nmdatela
                                  ,pr_idorigem => vr_idorigem
                                  ,pr_cdprogra => 'ATENDA'
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_dtmvtolt => vr_dtmvtolt
                                  ,pr_nrctrrpp => pr_nrctrrpp
                                  ,pr_inprevio => vr_inprevio
                                  ,pr_vlprerpp => vr_vlprerpp
                                  ,pr_dtmvinic => vr_dtmvinic
                                  ,pr_dsfinali => vr_dsfinali
                                  ,pr_indiadeb => vr_indiadeb
                                  ,pr_flgerlog => pr_flgerlog
                                  ,pr_nmarqpdf => vr_nmarqpdf
                                  ,pr_dssrvarq => vr_dssrvarq
                                  ,pr_dsdirarq => vr_dsdirarq
                                  ,pr_cdcritic => vr_cdcritic
                                  ,pr_dscritic => vr_dscritic);
    END IF;

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
                            '<nmarqpdf>'||vr_nmarqpdf||'</nmarqpdf>'||
                            '<dssrvarq>'||NVL(vr_dssrvarq,'')||'</dssrvarq>'||
                            '<dsdirarq>'||NVL(vr_dsdirarq,'')||'</dsdirarq>'||
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
      pr_dscritic := 'Erro geral em APLI0008.pc_buscar_extrato_apl_prog_web: '||SQLERRM;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
      
  END;


  END pc_impres_termo_adesao_ap_web;

  PROCEDURE pc_val_resgate_apl_prog (pr_cdcooper IN crapcop.cdcooper%TYPE             --> Código da cooperativa
                                    ,pr_cdagenci IN crapage.cdagenci%TYPE             --> Código da agência
                                    ,pr_nrdcaixa IN INTEGER                           --> Número do caixa
                                    ,pr_cdoperad IN crapope.cdoperad%TYPE             --> Código do operador
                                    ,pr_nmdatela VARCHAR2                             --> Nome da tela
                                    ,pr_idorigem IN INTEGER                           --> Código de origem
                                    ,pr_nrdconta IN craprpp.nrdconta%TYPE             --> Número da conta
                                    ,pr_idseqttl IN crapttl.idseqttl%TYPE             --> Sequêncial do titular   
                                    ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE             --> Código do contrato da poupança
                                    ,pr_dtmvtolt IN craprpp.dtmvtolt%TYPE             --> Data do movimento atual
                                    ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE             --> Data do proximo movimento
                                    ,pr_inproces IN crapdat.inproces%TYPE             --> Indicador de processo
                                    ,pr_cdprogra IN crapprg.cdprogra%TYPE             --> Nome do programa chamador
                                    ,pr_tpresgat IN VARCHAR2                          --> Tipo de Resgate (T = Total / P = Parcial)
                                    ,pr_vlresgat IN craplrg.vllanmto%TYPE             --> Valor do resgate
                                    ,pr_dtresgat IN craplrg.dtresgat%TYPE             --> Data para resgate
                                    ,pr_flgoprgt IN INTEGER DEFAULT 0                 --> Flag Op. Resgate ( 0 = Validar dados do resgate / 1 = Validar acesso a opcao resgate)
                                    ,pr_cdopeaut IN crapope.cdoperad%TYPE             --> Código do operador autorizacao
                                    ,pr_cddsenha IN crapope.cddsenha%TYPE             --> Senha do operador
                                    ,pr_flgsenha IN INTEGER                           --> Senha (0 = Não / 1 = Sim)
                                    ,pr_flgerlog IN INTEGER                           --> Gerar log (0 = Não / 1 = Sim)
                                    ,pr_vlsldrpp OUT NUMBER                           --> Valor do saldo
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE            --> Codigo da critica de erro
                                    ,pr_dscritic OUT crapcri.dscritic%TYPE)           --> Descricao da critica de erro
   IS  
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_val_resgate_apl_prog
    --  Sistema  : Captação (Aplicação Programada)
    --  Sigla    : CRED
    --  Autor    : CIS Corporate
    --  Data     : Setembro/2018.                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: ----
    -- Objetivo  : Valida o resgate de uma aplicação programada
    --             b1wgen0006.valida-resgate + b1wgen0006.validar-limite-resgate  
    --
    -- Alteracoes:
    -- 
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      -- Constantes
      vr_dstransa VARCHAR2(30);
      vr_cdcritic PLS_INTEGER;
      vr_dscritic VARCHAR2(100);
      vr_vlsldrpp NUMBER(25,8);      -- Saldo 
      vr_vlresgat NUMBER(25,8);      -- Valor resgate
      vr_retorno VARCHAR(10);
      vr_dtmvtopr DATE;
      vr_flgerlog BOOLEAN := FALSE;

      -- Variaveis de retorno
      vr_tab_craptab apli0001.typ_tab_ctablq;
      vr_tab_craplpp apli0001.typ_tab_craplpp;
      vr_tab_craplrg apli0001.typ_tab_craplpp;
      vr_tab_resgate apli0001.typ_tab_resgate;
      vr_tab_dados_rpp apli0001.typ_tab_dados_rpp;
      vr_tab_erro gene0001.typ_tab_erro;
         
      vr_nrdrowid rowid;
    
      -- Variaveis auxiliares
      vr_exc_saida EXCEPTION; 
    
      -- Cursores
      -- Poupanca/Aplicação Programada
      CURSOR cr_craprpp IS
        SELECT cdsitrpp,dtvctopp
        FROM   craprpp rpp
        WHERE  rpp.cdcooper = pr_cdcooper AND
               rpp.nrdconta = pr_nrdconta AND
               rpp.nrctrrpp = pr_nrctrrpp;
      rw_craprpp cr_craprpp%ROWTYPE;

      -- Feriados
      CURSOR cr_crapfer IS 
        SELECT 1
        FROM   crapfer fer
        WHERE  fer.cdcooper = pr_cdcooper AND
               fer.dtferiad = pr_dtresgat;
      rw_crapfer cr_crapfer%ROWTYPE;      

      CURSOR cr_craptab IS
        SELECT * 
        FROM   craptab tab
        WHERE  tab.cdcooper = pr_cdcooper
        AND    tab.nmsistem = 'CRED'
        AND    tab.tptabela = 'USUARI'     
        AND    tab.cdempres = 11           
        AND    tab.cdacesso = 'DIARESGATE' 
        AND    tab.tpregist = 001;                
      rw_craptab cr_craptab%ROWTYPE;
      
    rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
      
    BEGIN
         vr_vlresgat := pr_vlresgat;
         IF pr_flgoprgt = 1 THEN
            vr_dstransa := 'Validar acesso a opcao resgate';
         ELSE
            vr_dstransa := 'Validar dados do resgate';
         END IF;
         If pr_flgerlog = 1 THEN
            vr_flgerlog := TRUE;
         END IF;
         
         apli0001.pc_consulta_poupanca (pr_cdcooper      => pr_cdcooper
                                       ,pr_cdagenci      => pr_cdagenci
                                       ,pr_nrdcaixa      => pr_nrdcaixa
                                       ,pr_cdoperad      => pr_cdoperad
                                       ,pr_idorigem      => pr_idorigem
                                       ,pr_nrdconta      => pr_nrdconta
                                       ,pr_idseqttl      => pr_idseqttl
                                       ,pr_nrctrrpp      => pr_nrctrrpp
                                       ,pr_dtmvtolt      => pr_dtmvtolt
                                       ,pr_dtmvtopr      => pr_dtmvtopr
                                       ,pr_inproces      => pr_inproces
                                       ,pr_cdprogra      => pr_cdprogra
                                       ,pr_flgerlog      => vr_flgerlog
                                       ,pr_percenir      => 0
                                       ,pr_tab_craptab   => vr_tab_craptab
                                       ,pr_tab_craplpp   => vr_tab_craplpp
                                       ,pr_tab_craplrg   => vr_tab_craplrg
                                       ,pr_tab_resgate   => vr_tab_resgate
                                       ,pr_vlsldrpp      => vr_vlsldrpp
                                       ,pr_retorno       => vr_retorno
                                       ,pr_tab_dados_rpp => vr_tab_dados_rpp
                                       ,pr_tab_erro      => vr_tab_erro);
         
         IF vr_tab_erro.Count > 0 THEN
            vr_cdcritic := vr_tab_erro(1).cdcritic;
            vr_dscritic := vr_tab_erro(1).dscritic;
            RAISE vr_exc_saida;
         END IF;
         
         -- Verifica se a conta poupança existe
         OPEN cr_craprpp;
         FETCH cr_craprpp INTO rw_craprpp;
         -- Se não encontrar
         IF cr_craprpp%NOTFOUND THEN
            vr_cdcritic := 495;
            CLOSE cr_craprpp;
            RAISE vr_exc_saida;
         END IF;         
         IF rw_craprpp.cdsitrpp = 5 THEN
            vr_cdcritic := 919;   -- Deve sair??
            CLOSE cr_craprpp;
            RAISE vr_exc_saida;
         END IF;         
         CLOSE cr_craprpp;

         OPEN cr_craptab;
         FETCH cr_craptab INTO rw_craptab;
         IF cr_craptab%NOTFOUND THEN
            vr_cdcritic := 486;
            CLOSE cr_craptab;
            RAISE vr_exc_saida;
         END IF;         
         CLOSE cr_craptab;
         --vr_dtmvtopr:= pr_dtmvtolt + CAST(SUBSTR(rw_craptab.dstextab,1,3)AS INTEGER); Fix me - remover o comentário
         vr_dtmvtopr:= pr_dtmvtolt + 0; -- fix me remover esta linha
         
         -- Verifica qual o tipo do resgate solicitado         
         IF pr_tpresgat IS NULL THEN
            vr_dscritic := 'Tipo de resgate invalido.';
            RAISE vr_exc_saida;
         END IF;

         IF UPPER(pr_tpresgat) NOT IN ('P','T') THEN
            vr_dscritic := 'Tipo de resgate invalido.';
            RAISE vr_exc_saida;
         END IF;
         IF UPPER(pr_tpresgat) = 'P' AND (pr_vlresgat  =  0 OR pr_vlresgat >= vr_vlsldrpp) THEN -- Parcial
            vr_cdcritic := 269;
            RAISE vr_exc_saida;
         END IF;
         IF ((UPPER(pr_tpresgat) = 'T') AND (pr_vlresgat  =  0)) THEN -- Parcial
            vr_vlresgat := vr_vlsldrpp;
         END IF;

         -- Valida data resgate         
         IF pr_dtresgat IS NULL THEN
            vr_cdcritic := 13;
            RAISE vr_exc_saida;
         END IF;

         IF pr_dtresgat = rw_craprpp.dtvctopp  THEN
            vr_cdcritic := 907;
            RAISE vr_exc_saida;
         END IF;

         IF pr_flgoprgt = 0 THEN
            apli0002.pc_ver_val_bloqueio_poup (pr_cdcooper => pr_cdcooper
                                              ,pr_cdagenci => pr_cdagenci
                                              ,pr_nrdcaixa => pr_nrdcaixa
                                              ,pr_cdoperad => pr_cdoperad
                                              ,pr_nmdatela => pr_nmdatela
                                              ,pr_idorigem => pr_idorigem
                                              ,pr_nrdconta => pr_nrdconta
                                              ,pr_idseqttl => pr_idseqttl
                                              ,pr_dtmvtolt => pr_dtmvtolt
                                              ,pr_dtmvtopr => pr_dtmvtopr
                                              ,pr_inproces => pr_inproces
                                              ,pr_cdprogra => pr_cdprogra
                                              ,pr_vlresgat => vr_vlresgat
                                              ,pr_flgerlog => pr_flgerlog
                                              ,pr_flgrespr => 1
                                              ,pr_cdcritic => vr_cdcritic
                                              ,pr_dscritic => vr_dscritic);

         END IF;
         -- pr_cdcritic = 0
         -- pr_dscritic = Nao foi possivel resgatar. Ha valores bloqueados judicialmente
         IF (vr_cdcritic IS NOT NULL)  OR (vr_dscritic IS NOT NULL) THEN
            RAISE vr_exc_saida;
         END IF;

         OPEN cr_crapfer;
         FETCH cr_crapfer INTO rw_crapfer;
         IF cr_crapfer%FOUND                               -- Feriado
         OR pr_dtresgat < vr_dtmvtopr                      -- Data anterior
         OR pr_dtresgat > (pr_dtmvtolt+180)                -- Acima de 6 meses no futuro
         OR (TO_CHAR (pr_dtresgat, 'D') IN ('1','7')) THEN -- Domingo ou Sabado
            vr_cdcritic := 13;
            CLOSE cr_crapfer;
            RAISE vr_exc_saida;
         END IF;         
         CLOSE cr_crapfer;
         
         -- Início b1wgen0006.validar-limite-resgate
         apli0002.pc_validar_limite_resgate (pr_cdcooper => pr_cdcooper
                                            ,pr_idorigem => pr_idorigem
                                            ,pr_nmdatela => pr_nmdatela
                                            ,pr_idseqttl => pr_idseqttl
                                            ,pr_nrdconta => pr_nrdconta
                                            ,pr_vlrrsgat => vr_vlresgat
                                            ,pr_cdoperad => pr_cdopeaut
                                            ,pr_cddsenha => pr_cddsenha
                                            ,pr_flgsenha => pr_flgsenha
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);         

         IF (vr_cdcritic IS NOT NULL)  OR (vr_dscritic IS NOT NULL) THEN
            RAISE vr_exc_saida;
         END IF;
         pr_vlsldrpp := vr_vlsldrpp;
         -- Se for necessário gerar log
         IF pr_flgerlog = 1 THEN
            GENE0001.pc_gera_log (pr_cdcooper => pr_cdcooper
                                 ,pr_cdoperad => pr_cdoperad
                                 ,pr_dscritic => pr_dscritic
                                 ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
                                 ,pr_dstransa => vr_dstransa
                                 ,pr_dttransa => TRUNC(SYSDATE)
                                 ,pr_flgtrans => 0 --> FALSE
                                 ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                                 ,pr_idseqttl => pr_idseqttl
                                 ,pr_nmdatela => pr_nmdatela
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrdrowid => vr_nrdrowid);
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
               --Executar rotina geracao erro
               gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                    ,pr_cdagenci => pr_cdagenci
                                    ,pr_nrdcaixa => pr_nrdcaixa
                                    ,pr_nrsequen => 1 --> Fixo
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic
                                    ,pr_tab_erro => vr_tab_erro);

               -- Verifica se deve gerar log
               IF pr_flgerlog = 1 THEN
                  GENE0001.pc_gera_log (pr_cdcooper => pr_cdcooper
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_dscritic => pr_dscritic
                                       ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
                                       ,pr_dstransa => vr_dstransa
                                       ,pr_dttransa => TRUNC(SYSDATE)
                                       ,pr_flgtrans => 0 --> FALSE
                                       ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                                       ,pr_idseqttl => pr_idseqttl
                                       ,pr_nmdatela => pr_nmdatela
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrdrowid => vr_nrdrowid);
               END IF;
          WHEN OTHERS THEN
               pr_cdcritic := vr_cdcritic;
               pr_dscritic := vr_dscritic;
               --Executar rotina geracao erro
               gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                    ,pr_cdagenci => pr_cdagenci
                                    ,pr_nrdcaixa => pr_nrdcaixa
                                    ,pr_nrsequen => 1 --> Fixo
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic
                                    ,pr_tab_erro => vr_tab_erro);
               -- Verifica se deve gerar log
               IF pr_flgerlog = 1 THEN
                  GENE0001.pc_gera_log (pr_cdcooper => pr_cdcooper
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_dscritic => pr_dscritic
                                       ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
                                       ,pr_dstransa => vr_dstransa
                                       ,pr_dttransa => TRUNC(SYSDATE)
                                       ,pr_flgtrans => 0 --> FALSE
                                       ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                                       ,pr_idseqttl => pr_idseqttl
                                       ,pr_nmdatela => pr_nmdatela
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrdrowid => vr_nrdrowid);
               END IF;
    END;
  END pc_val_resgate_apl_prog;

  PROCEDURE pc_val_resgate_apl_prog_web (pr_nrdconta IN craprac.nrdconta%TYPE -- Número da Conta
                                        ,pr_idseqttl IN crapttl.idseqttl%TYPE -- Sequêncial do titular   
                                        ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE -- Número da Aplicação Programada.
                                        ,pr_dtmvtolt IN VARCHAR2              -- Data de Movimento 
                                        ,pr_dtmvtopr IN VARCHAR2              -- Data do proximo movimento
                                        ,pr_inproces IN crapdat.inproces%TYPE -- Indicador de processo
                                        ,pr_tpresgat IN VARCHAR2              -- Tipo de Resgate (T = Total / P = Parcial)
                                        ,pr_vlresgat IN craplrg.vllanmto%TYPE -- Valor do resgate
                                        ,pr_dtresgat IN VARCHAR2              -- Data para resgate
                                        ,pr_flgoprgt IN INTEGER               -- Flag Op. Resgate ( 0 = Validar dados do resgate / 1 = Validar acesso a opcao resgate)
                                        ,pr_cdopeaut IN crapope.cdoperad%TYPE -- Código do operador autorizacao
                                        ,pr_cddsenha IN crapope.cddsenha%TYPE -- Senha do operador
                                        ,pr_flgsenha IN INTEGER               -- Senha (0 = Não / 1 = Sim)
                                        ,pr_flgerlog IN INTEGER               -- Indicador se deve gerar log(0-nao, 1-sim)
                                        ,pr_xmllog   IN VARCHAR2              -- XML com informacoes de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER          -- Código da crítica
                                        ,pr_dscritic OUT VARCHAR2             -- Descrição da crítica
                                        ,pr_retxml   IN OUT NOCOPY XMLType    -- Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2             -- Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2)            -- Erros do processo

  IS
      BEGIN
        /* .............................................................................

         Programa: pc_val_resgate_apl_prog_web
         Sistema : Rotinas referentes à aplicação programada
         Sigla   : CRED
         Autor   : CIS Corporate
         Data    : Setembro/2018.                    

         Dados referentes ao programa:

         Frequencia:
         Objetivo  : Valida o resgate de uma aplicação programada - Mensageria
         Alteracoes: 
         
        ..............................................................................*/

      DECLARE
        -- Variável de críticas
        vr_cdcritic crapcri.cdcritic%TYPE;
        vr_dscritic crapcri.dscritic%TYPE;
             
        -- Variaveis auxiliares
        vr_exc_erro EXCEPTION;
        vr_vlsldrpp NUMBER(25,2);
        
        -- Variaveis de entrada
        vr_dtmvtolt Date := TO_DATE(pr_dtmvtolt,'dd/mm/yyyy');
        vr_dtmvtopr Date := TO_DATE(pr_dtmvtopr,'dd/mm/yyyy'); 
        vr_dtresgat Date := TO_DATE(pr_dtresgat,'dd/mm/yyyy');   

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
        
      --Registro do tipo calendario
      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
        
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

    IF (pr_dtmvtolt IS NULL) THEN
           -- Verifica se a cooperativa esta cadastrada
            OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
     
            FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
     
            -- Se não encontrar
            IF BTCH0001.cr_crapdat%NOTFOUND THEN
       
                  -- Fechar o cursor pois haverá raise
                  CLOSE BTCH0001.cr_crapdat;
           
                  -- Montar mensagem de critica
                  vr_cdcritic := 1;
                  vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
           
                   -- Gera exceção
                  RAISE vr_exc_erro;
       
       ELSE
              vr_dtmvtolt := rw_crapdat.dtmvtolt;
              vr_dtmvtopr := rw_crapdat.dtmvtopr;
              vr_dtresgat := rw_crapdat.dtmvtolt;

                -- Apenas fechar o cursor
                CLOSE BTCH0001.cr_crapdat;
             END IF;
       
        END IF;     

        -- Valida o resgate da aplicação programada
        pc_val_resgate_apl_prog (pr_cdcooper => vr_cdcooper
                                ,pr_cdagenci => vr_cdagenci
                                ,pr_nrdcaixa => vr_nrdcaixa
                                ,pr_cdoperad => vr_cdoperad
                                ,pr_nmdatela => vr_nmdatela
                                ,pr_idorigem => vr_idorigem
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_idseqttl => pr_idseqttl
                                ,pr_nrctrrpp => pr_nrctrrpp
                                ,pr_dtmvtolt => vr_dtmvtolt
                                ,pr_dtmvtopr => vr_dtmvtopr
                                ,pr_inproces => pr_inproces
                                ,pr_cdprogra => vr_nmdatela
                                ,pr_tpresgat => pr_tpresgat
                                ,pr_vlresgat => pr_vlresgat
                                ,pr_dtresgat => vr_dtresgat
                                ,pr_flgoprgt => pr_flgoprgt
                                ,pr_cdopeaut => pr_cdopeaut
                                ,pr_cddsenha => pr_cddsenha
                                ,pr_flgsenha => pr_flgsenha
                                ,pr_flgerlog => pr_flgerlog
                                ,pr_vlsldrpp => vr_vlsldrpp
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
                                 ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>'
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
          pr_dscritic := 'Erro geral em APLI0008.pc_val_resgate_apl_prog_web: '||SQLERRM;
          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_dscritic ||
                                         '</Erro></Root>');
          
      END;

  END pc_val_resgate_apl_prog_web;

  PROCEDURE pc_efet_resgate_apl_prog (pr_cdcooper IN crapcop.cdcooper%TYPE    -- Código da cooperativa
                                     ,pr_cdagenci IN crapage.cdagenci%TYPE    -- Código da agência
                                     ,pr_nrdcaixa IN INTEGER                  -- Número do caixa
                                     ,pr_cdoperad IN crapope.cdoperad%TYPE    -- Código do operador
                                     ,pr_nmdatela VARCHAR2                    -- Nome da tela
                                     ,pr_idorigem IN INTEGER                  -- Código de origem
                                     ,pr_nrdconta IN craprpp.nrdconta%TYPE    -- Número da conta
                                     ,pr_idseqttl IN crapttl.idseqttl%TYPE    -- Sequêncial do titular   
                                     ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE    -- Código do contrato da poupança
                                     ,pr_dtmvtolt IN craprpp.dtmvtolt%TYPE    -- Data do movimento atual
                                     ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE    -- Data do proximo movimento
                                     ,pr_tpresgat IN VARCHAR2                 -- Tipo de Resgate (T = Total / P = Parcial)
                                     ,pr_vlresgat IN craplrg.vllanmto%TYPE    -- Valor do resgate
                                     ,pr_dtresgat IN craplrg.dtresgat%TYPE    -- Data para resgate
                                     ,pr_flgctain IN INTEGER                  -- Flag Conta Investimento ( 0 = Não / 1 = Sim)
                                     ,pr_flgerlog IN INTEGER                  -- Gerar log (0 = Não / 1 = Sim)
                                     ,pr_cdcritic OUT crapcri.cdcritic%TYPE   -- Codigo da critica de erro
                                     ,pr_dscritic OUT crapcri.dscritic%TYPE)  -- Descricao da critica de erro
   IS  
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_efet_resgate_apl_prog
    --  Sistema  : Captação (Aplicação Programada)
    --  Sigla    : CRED
    --  Autor    : CIS Corporate
    --  Data     : Setembro/2018.                   Ultima atualizacao: 15/04/2019
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: ----
    -- Objetivo  : Efetiva o resgate da aplicação programada + resgate no momento
    --             b1wgen0006.efetuar-resgate 
    --
    -- Alteracoes: 15/04/2019 - P450 - Inclusão da centralizadora de lançamentos da CRAPLCM (LANC0001) 
    --                          (Reginaldo/AMcom)
    -- 
    ---------------------------------------------------------------------------------------------------------------
   BEGIN
    DECLARE
      -- Constantes
      vr_dstransa VARCHAR2(100);
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      
      vr_idautblq INTEGER := 1;
      vr_nrseqdig craplot.nrseqdig%TYPE;
      vr_tpresgat INTEGER;
      vr_flgctain VARCHAR2(3):='NAO';
      vr_craplrg_rowid ROWID;

      -- Variaveis auxiliares
      vr_exc_saida EXCEPTION; 
      vr_nrdrowid rowid;
      vr_tab_erro gene0001.typ_tab_erro;

      vr_dstextab_apli  craptab.dstextab%TYPE;
      vr_percenir       NUMBER;
      
      vr_perirapl NUMBER := 0;
      vr_valortir  NUMBER := 0;
      vr_vlsdtoap NUMBER := 0;
      vr_dsperirapl VARCHAR2(1000);      
      
      vr_vlsdrdppe      NUMBER;
      vr_vlresgat       NUMBER;
      vr_saldorpp       NUMBER;
      vr_vlirabap       NUMBER;    
        vr_vlabcpmf       NUMBER;
      vr_flgimune       BOOLEAN;
      vr_nrseqrgt       INTEGER := 0;
      vr_tpresgate_apl  INTEGER := 0;
      vr_vlrtotresgate_apl   NUMBER := 0;
      vr_vlresgat_apl   NUMBER := 0;
      vr_vlresgat_acu   NUMBER := 0;
      vr_flgfimresga    BOOLEAN := FALSE;
      vr_rpp_txaplica   NUMBER := 0;
      vr_rpp_txaplmes   NUMBER := 0;
      -- Vari?veis usadas na chamada da LANC0001
      vr_incrineg       INTEGER;
      vr_tab_retorno    LANC0001.typ_reg_retorno;      
      
      vr_dtmvtopr       DATE := pr_dtmvtolt; -- data da operação deve ser igual a do movimento para que o crédito seja efetivado no mesmo dia
      vr_fase           PLS_INTEGER:=0;

      vr_geraprotocolo PLS_INTEGER:=0;

      vr_dsinfor1 VARCHAR2(1000);
      vr_dsinfor2 VARCHAR2(1000);
      vr_dsinfor3 VARCHAR2(1000);
      vr_nrdconta VARCHAR2(1000);
      vr_nmextttl VARCHAR2(1000);      
      vr_dsprotoc crappro.dsprotoc%TYPE;
      vr_nmcidade crapage.nmcidade%TYPE;
      
      -- Variaveis Erro
      vr_des_erro VARCHAR2(1000);

      -- Cursores
      -- Lote
      CURSOR cr_craplot IS
        SELECT *
        FROM   craplot lot
        WHERE  lot.cdcooper = pr_cdcooper AND
               lot.dtmvtolt = pr_dtmvtolt AND
               lot.cdagenci = 99 AND
               lot.cdbccxlt = 400 AND
               lot.nrdolote = 999
        FOR UPDATE;
      rw_craplot cr_craplot%ROWTYPE;

      -- Bloqueio
      CURSOR cr_craptab IS
        SELECT * 
        FROM   craptab tab
        WHERE  tab.cdcooper = pr_cdcooper
        AND    tab.nmsistem = 'CRED'
        AND    tab.tptabela = 'BLQRGT'     
        AND    tab.cdempres = 00           
        AND    tab.cdacesso = LPAD(pr_nrdconta,10,'0') 
        AND    CAST(SUBSTR(tab.dstextab,1,7)AS INTEGER) = pr_nrctrrpp;
        
      rw_craptab cr_craptab%ROWTYPE;
    
    -- Buscar cadastro da poupanca programada.
    CURSOR cr_craprpp IS
      SELECT /*+ index (craprpp craprpp#craprpp1)*/
             craprpp.nrdconta
            ,craprpp.nrctrrpp
            ,craprpp.dtvctopp
            ,craprpp.vlabcpmf
            ,craprpp.flgctain
            ,craprpp.dtfimper
            ,craprpp.cdprodut
            ,craprpp.rowid            
        FROM craprpp
       WHERE craprpp.cdcooper = pr_cdcooper
         AND craprpp.nrdconta = pr_nrdconta
         AND craprpp.nrctrrpp = pr_nrctrrpp
         FOR UPDATE NOWAIT;
    rw_craprpp cr_craprpp%ROWTYPE;   

    -- Cursor para encontrar o associado
    CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
    SELECT ass.nrdconta
          ,ass.nmprimtl
          ,ass.vllimcre
          ,ass.nrcpfcgc
          ,ass.inpessoa
          ,ass.cdcooper
          ,ass.cdagenci
          ,ass.idastcjt
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;   

    --Selecionar informacoes do titular
    CURSOR cr_crapttl (pr_cdcooper IN crapttl.cdcooper%type
                      ,pr_nrdconta IN crapttl.nrdconta%type
                      ,pr_idseqttl IN crapttl.idseqttl%type) IS
    SELECT ttl.nmextttl
          ,ttl.nrcpfcgc
      FROM crapttl ttl
     WHERE ttl.cdcooper = pr_cdcooper
       AND ttl.nrdconta = pr_nrdconta
       AND ttl.idseqttl = pr_idseqttl;
    rw_crapttl cr_crapttl%ROWTYPE;
    
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
          ,crapcop.nrdocnpj
          ,crapcop.nrtelura
     FROM crapcop crapcop
    WHERE crapcop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    
    -- Cursosr para encontrar a cidade do PA do associado
    CURSOR cr_crapage(pr_cdcooper IN crapage.cdcooper%TYPE
                     ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
    SELECT age.nmcidade
      FROM crapage age
     WHERE age.cdcooper = pr_cdcooper 
       AND age.cdagenci = pr_cdagenci;

    -- Procedures Internas
    PROCEDURE pc_gera_resgate_apl_prog (pr_cdcooper crapcop.cdcooper%TYPE
                                       ,pr_tpresgat craplrg.tpresgat%TYPE
                                       ,pr_flgcreci craplrg.flgcreci%TYPE
                                       ,pr_vlresgat NUMBER) IS

      ------------------------------- VARIAVEIS -------------------------------
    vr_cdcritic_apl   PLS_INTEGER := 0;
    vr_dscritic_apl   VARCHAR2(4000) := NULL;
    vr_tpcritic_apl crapcri.cdcritic%TYPE;
    
    vr_lista_inf   VARCHAR2(4000) := '';

    vr_vlrgappr NUMBER(25,2):= 0;
    vr_vlsdappr NUMBER(25,2):= 0;

    vr_vlultren NUMBER(20,8) := 0; --> Valor de ultimo rendimento
    vr_vlrentot NUMBER(20,8) := 0; --> Valor de rendimento total
    vr_vlrevers NUMBER(20,8) := 0; --> Valor de reversao
    vr_vlrdirrf NUMBER(20,8) := 0; --> Valor de IRRF
    vr_percirrf NUMBER(20,8) := 0; --> Valor percentual de IRRF
    vr_vlsldttr NUMBER(20,8) := 0; --> Valor Saldo Total de Resgate
      -- Selecionar dados de aplicacao
      CURSOR cr_craprac (pr_cdcooper craplrg.cdcooper%TYPE
                        ,pr_nrdconta craprac.nrdconta%TYPE
                        ,pr_nrctrrpp craprac.nrctrrpp%TYPE) IS
        SELECT
        rac.cdcooper, rac.nrdconta,
        rac.nraplica, rac.cdprodut,
        rac.cdnomenc, rac.dtmvtolt,
        rac.dtvencto, rac.dtatlsld,
        rac.vlaplica, rac.vlbasapl,
        rac.vlsldatl, rac.vlslfmes,
        rac.vlsldacu, rac.qtdiacar,
        rac.qtdiaprz, rac.qtdiaapl,
        rac.txaplica, rac.idsaqtot,
        rac.idblqrgt, rac.idcalorc,
        rac.cdoperad, rac.progress_recid,
        rac.iddebcti, rac.vlbasant,
        rac.vlsldant, rac.dtsldant,
        rac.rowid,
        cpc.nmprodut, cpc.idsitpro,
        cpc.cddindex, cpc.idtippro,
        cpc.idtxfixa, cpc.idacumul,
        cpc.cdhscacc, cpc.cdhsvrcc,
        cpc.cdhsraap, cpc.cdhsnrap, 
        cpc.cdhsprap, cpc.cdhsrvap,
        cpc.cdhsrdap, cpc.cdhsirap,
        cpc.cdhsrgap, cpc.cdhsvtap
        FROM 
        craprac rac,
        crapcpc cpc 
        WHERE
        rac.cdcooper = pr_cdcooper  AND
        rac.nrdconta = pr_nrdconta AND
        rac.nrctrrpp = pr_nrctrrpp AND
        cpc.cdprodut = rac.cdprodut AND
        rac.idsaqtot = 0
        ORDER BY 
        rac.nraplica;
        
        rw_craprac     cr_craprac%rowtype;
    BEGIN
        vr_nrseqrgt := 0;
        vr_vlrtotresgate_apl := 0;
        vr_vlresgat_acu := 0;
        vr_flgfimresga := FALSE;       
        
        BEGIN
             -- Buscar aplicações para os resgates solicitados.
             FOR rw_craprac IN cr_craprac (pr_cdcooper => pr_cdcooper
                                          ,pr_nrdconta => rw_craprpp.nrdconta
                                          ,pr_nrctrrpp => rw_craprpp.nrctrrpp) LOOP

                 vr_vlrgappr := 0;
                 vr_vlsdappr := 0;
              vr_vlsldttr := 0;
         
              vr_tpresgate_apl := 1;
                 vr_nrseqrgt := vr_nrseqrgt + 1;

                 pc_calc_saldo_resgate (pr_cdcooper => pr_cdcooper
                                                    ,pr_nrdconta => rw_craprac.nrdconta
                                                    ,pr_nraplica => rw_craprac.nraplica 
                                                    ,pr_vlresgat => vr_vlresgat - vr_vlresgat_acu
                                                    ,pr_idtiprgt => vr_tpresgate_apl
                                                    ,pr_dtresgat => vr_dtmvtopr
                                                    ,pr_nrseqrgt => 0
                                                    ,pr_idrgtcti => 0
                                                    ,pr_vlsldtot => vr_vlsdappr 
                                                    ,pr_vlsldrgt => vr_vlrgappr
                                                    ,pr_vlultren => vr_vlultren 
                                                    ,pr_vlrentot => vr_vlrentot
                                                    ,pr_vlrevers => vr_vlrevers 
                                                    ,pr_vlrdirrf => vr_vlrdirrf
                                                    ,pr_percirrf => vr_percirrf
                                                    ,pr_vlsldttr => vr_vlsldttr
                                                    ,pr_tpcritic => vr_tpcritic_apl
                                                    ,pr_cdcritic => vr_cdcritic_apl
                                                    ,pr_dscritic => vr_dscritic_apl);

                 -- Se encontrar erros na execucão
                 IF vr_dscritic_apl is not null THEN
                    RAISE vr_exc_saida;
                 END IF;

                 IF (vr_nrseqrgt > 1) THEN
                   vr_perirapl := -1;
                 ELSE
                   vr_perirapl := vr_percirrf;
                 END IF;
                       
                 vr_valortir := vr_valortir + vr_vlrdirrf;

                 vr_vlrtotresgate_apl := vr_vlrtotresgate_apl + vr_vlsldttr;
                 vr_vlresgat_apl := vr_vlsldttr;
                 vr_tpresgate_apl := 1;
                 IF (pr_tpresgat = 1) THEN
                    IF (vr_vlresgat > vr_vlrtotresgate_apl) THEN
                        vr_tpresgate_apl := 2;
                    ELSIF (vr_vlresgat = vr_vlrtotresgate_apl) THEN
                           vr_tpresgate_apl := 2;
                           vr_flgfimresga := TRUE;
                    ELSE
                        vr_vlresgat_apl := vr_vlresgat - vr_vlresgat_acu;    
                        vr_flgfimresga := TRUE;
                    END IF;
                  ELSE
                    vr_tpresgate_apl := 2;
                  END IF;
                  
                  apli0005.pc_efetua_resgate (pr_cdcooper => pr_cdcooper
                                             ,pr_nrdconta => rw_craprac.nrdconta
                                             ,pr_nraplica => rw_craprac.nraplica
                                             ,pr_vlresgat => vr_vlresgat_apl
                                             ,pr_idtiprgt => vr_tpresgate_apl
                                             ,pr_dtresgat => vr_dtmvtopr
                                             ,pr_nrseqrgt => vr_nrseqrgt
                                             ,pr_idrgtcti => pr_flgcreci
                                             ,pr_tpcritic => vr_tpcritic_apl
                                             ,pr_cdcritic => vr_cdcritic_apl
                                             ,pr_dscritic => vr_dscritic_apl);
                 -- Se encontrar erros na execucão
                  IF vr_dscritic_apl is not null THEN
                     RAISE vr_exc_saida;
                  END IF;
                  vr_vlresgat_acu := vr_vlresgat_acu + vr_vlresgat_apl;

                  IF (vr_flgfimresga) THEN
                     EXIT;
                  END IF;
             END LOOP; -- fim loop rac
        EXCEPTION
           WHEN vr_exc_saida THEN
             vr_cdcritic := vr_cdcritic_apl;
             vr_dscritic := vr_dscritic_apl;
             RAISE vr_exc_saida;
           WHEN OTHERS THEN
             vr_dscritic := 'Não foi possivel inserir craplot(8383): '||SQLERRM;
             RAISE vr_exc_saida;
         END;
    END pc_gera_resgate_apl_prog;

    PROCEDURE pc_gera_resgate_poup_prog (pr_cdcooper crapcop.cdcooper%TYPE
                                        ,pr_flgcreci craplrg.flgcreci%TYPE  
                                        ,pr_vlresgat NUMBER) IS
        ---- Cursores
        -- Buscar dados do lote
        CURSOR cr_craplot (pr_cdcooper craplot.cdcooper%TYPE,
                           pr_dtmvtopr craplot.dtmvtolt%TYPE,
                           pr_nrdolote craplot.nrdolote%TYPE) IS
          SELECT craplot.cdcooper,
                 craplot.nrseqdig,
                 craplot.dtmvtolt,
                 craplot.cdagenci,
                 craplot.cdbccxlt,
                 craplot.nrdolote,
                 craplot.tplotmov,
                 craplot.qtcompln,
                 craplot.vlcompdb,
                 craplot.vlcompcr,
                 craplot.ROWID
            FROM craplot
           WHERE craplot.cdcooper = pr_cdcooper
             AND craplot.dtmvtolt = pr_dtmvtopr
             AND craplot.cdagenci = 1
             AND craplot.cdbccxlt = 100
             AND craplot.nrdolote = pr_nrdolote;
        rw_craplot  cr_craplot%ROWTYPE;
		rw_craplot_rvt lote0001.cr_craplot_sem_lock%rowtype;

        /* Gerar  lançamento na conta investimento*/
        PROCEDURE pc_gera_lancamentos_craplci (pr_cdcooper crapcop.cdcooper%TYPE
                                              ,pr_flgctain craprpp.flgctain%TYPE
                                              ,pr_flgcreci craplrg.flgcreci%TYPE
                                              ,pr_nrdconta craprpp.nrdconta%TYPE
                                              ,pr_vlresgat NUMBER) IS
                                          
        ------------------------------- VARIAVEIS -------------------------------
        vr_qtdsli PLS_INTEGER;
      
        BEGIN
            IF pr_flgctain = 1 /* True */ AND  /* Nova aplicacao  */    
            pr_flgcreci = 0 /* False*/ THEN  /* Somente Transferencia */
        
                  /*  Gera lancamentos Conta Investimento  - Debito Transf */
                -- Buscar dados do lote
                -- Buscar dados do lote
                lote0001.pc_insere_lote_rvt(pr_cdcooper => pr_cdcooper
                                          , pr_dtmvtolt => vr_dtmvtopr
                                          , pr_cdagenci => 1
                                          , pr_cdbccxlt => 100
                                          , pr_nrdolote => 10105
                                          , pr_cdoperad => '1'
                                          , pr_nrdcaixa => 0
                                          , pr_tplotmov => 29
                                          , pr_cdhistor => 0
                                          , pr_craplot  => rw_craplot_rvt
                                          , pr_dscritic => vr_dscritic);
                      
                if vr_dscritic is not null then
                  vr_dscritic := 'Erro ao inserir informações da capa de lote: '||vr_dscritic;
                             RAISE vr_exc_saida;
                END IF;
                  
                rw_craplot_rvt.nrseqdig := fn_sequence('CRAPLOT'
                                                      ,'NRSEQDIG'
                                                      ,''||pr_cdcooper||';'
                                                         ||to_char(vr_dtmvtopr,'DD/MM/RRRR')||';'
                                                         ||1||';'
                                                         ||100||';'
                                                         ||10105);
        
                BEGIN
                  INSERT INTO craplci
                              (craplci.dtmvtolt 
                              ,craplci.cdagenci 
                              ,craplci.cdbccxlt 
                              ,craplci.nrdolote 
                              ,craplci.nrdconta 
                              ,craplci.nrdocmto 
                              ,craplci.cdhistor 
                              ,craplci.vllanmto 
                              ,craplci.nrseqdig 
                              ,craplci.cdcooper )
                       VALUES (rw_craplot_rvt.dtmvtolt -- craplci.dtmvtolt
                              ,rw_craplot_rvt.cdagenci -- craplci.cdagenci
                              ,rw_craplot_rvt.cdbccxlt -- craplci.cdbccxlt
                              ,rw_craplot_rvt.nrdolote -- craplci.nrdolote
                              ,pr_nrdconta         -- craplci.nrdconta 
                              ,rw_craplot_rvt.nrseqdig -- craplci.nrdocmto
                              ,496 /* Debito */    -- craplci.cdhistor 
                              ,pr_vlresgat         -- craplci.vllanmto 
                              ,rw_craplot_rvt.nrseqdig -- craplci.nrseqdig
                              ,pr_cdcooper);       -- craplci.cdcooper 
                EXCEPTION
                     WHEN OTHERS THEN
                          vr_dscritic := 'Não foi possivel inserir craplci(nrdconta:'||pr_nrdconta ||'): '||SQLERRM;
                          RAISE vr_exc_saida;  
                END;
            
                /*** Gera lancamentos Conta Investmento  - Credito Transf. ***/
                -- Buscar dados do lote
                lote0001.pc_insere_lote_rvt(pr_cdcooper => pr_cdcooper
                                          , pr_dtmvtolt => vr_dtmvtopr
                                          , pr_cdagenci => 1
                                          , pr_cdbccxlt => 100
                                          , pr_nrdolote => 10104
                                          , pr_cdoperad => '1'
                                          , pr_nrdcaixa => 0
                                          , pr_tplotmov => 29
                                          , pr_cdhistor => 0
                                          , pr_craplot  => rw_craplot_rvt
                                          , pr_dscritic => vr_dscritic);
                      
                if vr_dscritic is not null then
                  vr_dscritic := 'Erro ao inserir informações da capa de lote: '||vr_dscritic;
                            RAISE vr_exc_saida;
                END IF;
              
                rw_craplot_rvt.nrseqdig := fn_sequence('CRAPLOT'
                                                      ,'NRSEQDIG'
                                                      ,''||pr_cdcooper||';'
                                                         ||to_char(vr_dtmvtopr,'DD/MM/RRRR')||';'
                                                         ||1||';'
                                                         ||100||';'
                                                         ||10104);
        
                BEGIN
                  INSERT INTO craplci
                              (craplci.dtmvtolt 
                              ,craplci.cdagenci 
                              ,craplci.cdbccxlt 
                              ,craplci.nrdolote 
                              ,craplci.nrdconta 
                              ,craplci.nrdocmto 
                              ,craplci.cdhistor 
                              ,craplci.vllanmto 
                              ,craplci.nrseqdig 
                              ,craplci.cdcooper )
                       VALUES (rw_craplot_rvt.dtmvtolt -- craplci.dtmvtolt
                              ,rw_craplot_rvt.cdagenci -- craplci.cdagenci
                              ,rw_craplot_rvt.cdbccxlt -- craplci.cdbccxlt
                              ,rw_craplot_rvt.nrdolote -- craplci.nrdolote
                              ,pr_nrdconta         -- craplci.nrdconta 
                              ,rw_craplot_rvt.nrseqdig -- craplci.nrdocmto
                              ,489 /*credito*/     -- craplci.cdhistor 
                              ,pr_vlresgat         -- craplci.vllanmto 
                              ,rw_craplot_rvt.nrseqdig -- craplci.nrseqdig
                              ,pr_cdcooper);       -- craplci.cdcooper 
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_dscritic := 'Não foi possivel inserir craplci (nrdconta:'||pr_nrdconta ||'): '||SQLERRM;
                    RAISE vr_exc_saida;  
                END;
        END IF;   
      
        /* Resgatar para Conta Investimento */
        IF pr_flgcreci = 1 /*True*/ THEN  
        
            /*** Gera lancamentos Credito Saldo Conta Investimento ***/
            -- Buscar dados do lote
            lote0001.pc_insere_lote_rvt(pr_cdcooper => pr_cdcooper
                                      , pr_dtmvtolt => vr_dtmvtopr
                                      , pr_cdagenci => 1
                                      , pr_cdbccxlt => 100
                                      , pr_nrdolote => 10106
                                      , pr_cdoperad => '1'
                                      , pr_nrdcaixa => 0
                                      , pr_tplotmov => 29
                                      , pr_cdhistor => 0
                                      , pr_craplot  => rw_craplot_rvt
                                      , pr_dscritic => vr_dscritic);
                      
            if vr_dscritic is not null then
              vr_dscritic := 'Erro ao inserir informações da capa de lote: '||vr_dscritic;
                  RAISE vr_exc_saida;
            END IF;
              
            rw_craplot_rvt.nrseqdig := fn_sequence('CRAPLOT'
                                                  ,'NRSEQDIG'
                                                  ,''||pr_cdcooper||';'
                                                     ||to_char(vr_dtmvtopr,'DD/MM/RRRR')||';'
                                                     ||1||';'
                                                     ||100||';'
                                                     ||10106);
        
            BEGIN
              INSERT INTO craplci
                          (craplci.dtmvtolt 
                          ,craplci.cdagenci 
                          ,craplci.cdbccxlt 
                          ,craplci.nrdolote 
                          ,craplci.nrdconta 
                          ,craplci.nrdocmto 
                          ,craplci.cdhistor 
                          ,craplci.vllanmto 
                          ,craplci.nrseqdig 
                          ,craplci.cdcooper )
                   VALUES (rw_craplot_rvt.dtmvtolt -- craplci.dtmvtolt
                          ,rw_craplot_rvt.cdagenci -- craplci.cdagenci
                          ,rw_craplot_rvt.cdbccxlt -- craplci.cdbccxlt
                          ,rw_craplot_rvt.nrdolote -- craplci.nrdolote
                          ,pr_nrdconta         -- craplci.nrdconta 
                          ,rw_craplot_rvt.nrseqdig -- craplci.nrdocmto
                          ,490   /* Credito Proveniente Aplicacao*/     -- craplci.cdhistor 
                          ,pr_vlresgat         -- craplci.vllanmto 
                          ,rw_craplot_rvt.nrseqdig -- craplci.nrseqdig
                          ,pr_cdcooper);       -- craplci.cdcooper 
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Não foi possivel inserir craplci (nrdconta:'||pr_nrdconta ||'): '||SQLERRM;
                RAISE vr_exc_saida;  
            END;  
            
            --- Atualizar Saldo Conta Investimento ---
            BEGIN
              UPDATE crapsli
                 SET crapsli.vlsddisp = crapsli.vlsddisp + pr_vlresgat
               WHERE crapsli.cdcooper = pr_cdcooper
                 AND crapsli.nrdconta = pr_nrdconta
                 AND to_char(crapsli.dtrefere,'MMRRRR') = to_char(vr_dtmvtopr,'MMRRRR');
                 
              -- guardar qtd de registros alterados   
              vr_qtdsli := SQL%ROWCOUNT;  
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Não foi possivel alterar crapsli (nrdconta:'||pr_nrdconta ||'): '||SQLERRM;
                RAISE vr_exc_saida;  
            END;
        
            -- se não alterou nenhum registro, deve inserir
            IF vr_qtdsli = 0 THEN
              BEGIN
                INSERT INTO crapsli
                            (crapsli.dtrefere,
                             crapsli.nrdconta,
                             crapsli.cdcooper,
                             crapsli.vlsddisp)
                     VALUES (last_day(vr_dtmvtopr)
                            ,pr_nrdconta
                            ,pr_cdcooper
                            ,pr_vlresgat);
              EXCEPTION 
                WHEN OTHERS THEN
                  vr_dscritic := 'Não foi possivel inserir crapsli (nrdconta:'||pr_nrdconta ||'): '||SQLERRM;
                  RAISE vr_exc_saida;  
              END;
            END IF;
        
      END IF;
    END pc_gera_lancamentos_craplci;

  BEGIN


      ------------------------------- VARIAVEIS -------------------------------
            IF pr_flgcreci = 0 /* false */ THEN /*Resgate Conta Corrente*/
                      
              lote0001.pc_insere_lote_rvt(pr_cdcooper => pr_cdcooper
                                        , pr_dtmvtolt => vr_dtmvtopr
                                        , pr_cdagenci => 1
                                        , pr_cdbccxlt => 100
                                        , pr_nrdolote => 8473
                                        , pr_cdoperad => '1'
                                        , pr_nrdcaixa => 0
                                        , pr_tplotmov => 1
                                        , pr_cdhistor => 0
                                        , pr_craplot => rw_craplot_rvt
                                        , pr_dscritic => vr_dscritic);                      
              IF vr_dscritic IS NOT NULL THEN
                    RAISE vr_exc_saida;
              END IF;
                  
              rw_craplot_rvt.nrseqdig := fn_sequence('CRAPLOT'
                                                    ,'NRSEQDIG'
                                                    ,''||pr_cdcooper||';'
                                                     ||to_char(vr_dtmvtopr,'DD/MM/RRRR')||';'
                                                     ||1||';'
                                                     ||100||';'
                                                     ||8473);
                  
              /* P450 - Inclusão da centralizadora de lançamentos da CRAPLCM (Reginaldo/AMcom) */
              LANC0001.pc_gerar_lancamento_conta(pr_dtmvtolt => rw_craplot_rvt.dtmvtolt
                                               , pr_cdagenci => rw_craplot_rvt.cdagenci
                                               , pr_cdbccxlt => rw_craplot_rvt.cdbccxlt
                                               , pr_nrdolote => rw_craplot_rvt.nrdolote
                                               , pr_nrdconta => rw_craprpp.nrdconta
                                               , pr_nrdocmto => rw_craplot_rvt.nrseqdig
                                               , pr_cdhistor => (CASE rw_craprpp.flgctain 
                               WHEN 1 /* true */ THEN 501 -- TRANSF. RESGATE POUP.PROGRAMADA DA C/I PARA C/C
                               ELSE 159 -- CR.POUP.PROGR
                                                                 END)
                                               , pr_nrseqdig => rw_craplot_rvt.nrseqdig
                                               , pr_vllanmto => vr_vlresgat
                                               , pr_nrdctabb => rw_craprpp.nrdconta
                                               , pr_cdcooper => pr_cdcooper
                                               , pr_nrdctitg => gene0002.fn_mask(rw_craprpp.nrdconta,'99999999')
                                               , pr_tab_retorno => vr_tab_retorno
                                               , pr_incrineg => vr_incrineg
                                               , pr_cdcritic => vr_cdcritic
                                               , pr_dscritic => vr_dscritic);
                                               
              IF trim(vr_dscritic) IS NOT NULL OR nvl(vr_cdcritic, 0) > 0 THEN
                vr_dscritic := 'Não foi possivel inserir na craplcm (nrdconta:'||rw_craprpp.nrdconta||'): '|| vr_dscritic;
                  RAISE vr_exc_saida;  
              END IF;
              
              vr_cdcritic := NULL;
              vr_dscritic := NULL;
            END IF; --> Fim IF rw_craplrg.flgcreci = 0 /* false */ /*Resgate Conta Corrente*/
                                              
            /* Gerar  lançamento na conta investimento*/
            pc_gera_lancamentos_craplci(pr_cdcooper => pr_cdcooper,
                                        pr_flgctain => rw_craprpp.flgctain,
                                        pr_flgcreci => pr_flgcreci,
                                        pr_nrdconta => rw_craprpp.nrdconta,
                                        pr_vlresgat => vr_vlresgat);
                                              
            --> Gera lancamento do resgate <--
            /* Projeto Revitalizacao - Remocao de lote */
            lote0001.pc_insere_lote_rvt(pr_cdcooper => pr_cdcooper
                                      , pr_dtmvtolt => vr_dtmvtopr
                                      , pr_cdagenci => 1
                                      , pr_cdbccxlt => 100
                                      , pr_nrdolote => 8383
                                      , pr_cdoperad => '1'
                                      , pr_nrdcaixa => 0
                                      , pr_tplotmov => 14
                                      , pr_cdhistor => 0
                                      , pr_craplot => rw_craplot_rvt
                                      , pr_dscritic => vr_dscritic);
                      
            if vr_dscritic is not null then
                  RAISE vr_exc_saida;
            END IF;
                  
            rw_craplot_rvt.nrseqdig := fn_sequence('CRAPLOT'
                                                  ,'NRSEQDIG'
                                                  ,''||pr_cdcooper||';'
                                                   ||to_char(vr_dtmvtopr,'DD/MM/RRRR')||';'
                                                   ||1||';'
                                                   ||100||';'
                                                   ||8383);
                  
            -- inserir lançamento
            BEGIN
              INSERT INTO craplpp
                          (craplpp.dtmvtolt
                          ,craplpp.cdagenci
                          ,craplpp.cdbccxlt
                          ,craplpp.nrdolote
                          ,craplpp.nrdconta
                          ,craplpp.nrctrrpp
                          ,craplpp.nrdocmto
                          ,craplpp.txaplmes
                          ,craplpp.txaplica
                          ,craplpp.cdhistor
                          ,craplpp.nrseqdig
                          ,craplpp.dtrefere
                          ,craplpp.vllanmto
                          ,craplpp.cdcooper)
                   VALUES( rw_craplot_rvt.dtmvtolt           -- craplpp.dtmvtolt
                          ,rw_craplot_rvt.cdagenci           -- craplpp.cdagenci
                          ,rw_craplot_rvt.cdbccxlt           -- craplpp.cdbccxlt
                          ,rw_craplot_rvt.nrdolote           -- craplpp.nrdolote
                          ,rw_craprpp.nrdconta           -- craplpp.nrdconta
                          ,rw_craprpp.nrctrrpp           -- craplpp.nrctrrpp
                          ,rw_craplot_rvt.nrseqdig           -- craplpp.nrdocmto
                          ,vr_rpp_txaplmes               -- craplpp.txaplmes
                          ,vr_rpp_txaplica               -- craplpp.txaplica
                          ,(CASE rw_craprpp.flgctain 
                              WHEN 1 /*YES*/  THEN 
                                  496   /* RESGATE POUP. p/ C.I */ 
                              ELSE 158  /* RESGATE POUP. */       -- craplpp.cdhistor
                            END) 
                          ,rw_craplot_rvt.nrseqdig           -- craplpp.nrseqdig
                          ,rw_craprpp.dtfimper           -- craplpp.dtrefere
                          ,vr_vlresgat                   -- craplpp.vllanmto
                          ,pr_cdcooper );                -- craplpp.cdcooper 
                  
            EXCEPTION
              WHEN OTHERS THEN
                vr_dscritic := 'Não foi possivel atualizar craplpp (nrdconta:'||rw_craprpp.nrdconta||'): '||SQLERRM;
                RAISE vr_exc_saida;  
            END;  
    END pc_gera_resgate_poup_prog;

    
    BEGIN -- Rotina principal
      
         vr_dstransa := 'Efetuar resgate de aplicacao programada';
         vr_fase := 10;
         -- Verifica se o lote existe
         OPEN cr_craplot;
         FETCH cr_craplot INTO rw_craplot;
         IF cr_craplot%FOUND THEN
            BEGIN
               UPDATE craplot SET
                      nrseqdig = rw_craplot.nrseqdig + 1,
                      qtcompln = rw_craplot.qtcompln + 1,
                      qtinfoln = rw_craplot.qtinfoln + 1,
                      vlcompdb = rw_craplot.vlcompdb + pr_vlresgat,
                      vlinfodb = rw_craplot.vlinfodb + pr_vlresgat 
               WHERE current of cr_craplot;
               vr_nrseqdig := rw_craplot.nrseqdig + 1;
            EXCEPTION 
               WHEN OTHERS THEN
                   vr_dscritic := 'Erro atualizacao CRAPLOT';
            END;
         ELSE
            BEGIN 
              INSERT INTO craplot (cdcooper,dtmvtolt,dtmvtopg,cdoperad,cdagenci
                                  ,cdbccxlt,cdbccxpg,cdhistor,nrdolote,tplotmov
                                  ,tpdmoeda,nrseqdig,qtcompln,qtinfoln,vlcompdb
                                  ,vlinfodb)
              VALUES 
                                  (pr_cdcooper,pr_dtmvtolt,pr_dtmvtopr,pr_cdoperad,99
                                  ,400,0,0,999,11
                                  ,1,1,1,1,pr_vlresgat
                                  ,pr_vlresgat)
                                  
              Returning nrseqdig into vr_nrseqdig;
            EXCEPTION 
               WHEN OTHERS THEN
                   vr_dscritic := 'Erro ao inserir CRAPLOT'||sqlerrm;
            END;
         END IF;
         CLOSE cr_craplot;
         IF vr_dscritic IS NOT NULL THEN
            vr_cdcritic := 0;
            RAISE vr_exc_saida;
         END IF;

         -- Verifica bloqueio
         OPEN cr_craptab;
         FETCH cr_craptab INTO rw_craptab;
         IF (cr_craptab%FOUND) AND (pr_idorigem = 5) AND (UPPER(pr_nmdatela)='ATENDA') THEN
            vr_idautblq := 0;
         END IF; 
         CLOSE cr_craptab; 
         
         IF UPPER(pr_tpresgat)='P' THEN -- Parcial
            vr_tpresgat := 1;
         ELSE
            vr_tpresgat := 2;
         END IF;
         
         IF pr_flgctain = 1 THEN
            vr_flgctain := 'SIM';
         END IF;

         BEGIN
            INSERT INTO craplrg (cdcooper,cdagenci,cdbccxlt,dtmvtolt,dtresgat
                                ,inresgat,nraplica,nrdconta,nrdocmto,nrdolote
                                ,nrseqdig,tpaplica,tpresgat,vllanmto,cdoperad
                                ,hrtransa,flgcreci,idautblq)
            VALUES
                                (pr_cdcooper,99,400,pr_dtmvtolt,pr_dtresgat
                                ,0,pr_nrctrrpp,pr_nrdconta,vr_nrseqdig,999
                                ,vr_nrseqdig,4,vr_tpresgat,pr_vlresgat,pr_cdoperad
                                ,TO_NUMBER(TO_CHAR(CURRENT_DATE,'SSSSS')),pr_flgctain,vr_idautblq)
            RETURNING           rowid INTO vr_craplrg_rowid;
            EXCEPTION 
               WHEN OTHERS THEN
                   vr_dscritic := 'Erro ao inserir CRAPLRG'||sqlerrm;
         END;
         IF vr_dscritic IS NOT NULL THEN
            vr_cdcritic := 0;
            RAISE vr_exc_saida;
         END IF;
         vr_fase := 20;
         IF pr_dtmvtolt = pr_dtresgat THEN -- Efetuar o resgate agora
            -- recuperar informações de IR
            vr_dstextab_apli :=  tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                           ,pr_nmsistem => 'CRED'
                                                           ,pr_tptabela => 'CONFIG'
                                                           ,pr_cdempres => 0
                                                           ,pr_cdacesso => 'PERCIRAPLI'
                                                           ,pr_tpregist => 0);
            vr_fase := 21;
            IF TRIM(vr_dstextab_apli) IS NOT NULL THEN
              -- Como o retorno é texto. O separador decimal é a ,
              vr_percenir := to_number(vr_dstextab_apli, '999D99', 'NLS_NUMERIC_CHARACTERS='',.''');
            ELSE
              vr_percenir := 0;
            END IF;
            OPEN cr_craprpp;
            FETCH cr_craprpp INTO rw_craprpp;
            IF cr_craprpp%NOTFOUND THEN -- Não deveria ocorrer em situação normal, apenas se invocada diretamente
               vr_cdcritic := 484;
               CLOSE cr_craprpp;
               RAISE vr_exc_saida;              
            END IF;       
            IF (rw_craprpp.cdprodut < 1) THEN -- Aplicacoes antigas
               vr_fase := 24;
               /* Rotina de calculo do saldo da aplicac?o ate a data do movimento */
               APLI0001.pc_calc_poupanca (pr_cdcooper  => pr_cdcooper         --> Cooperativa
                                         ,pr_dstextab  => vr_dstextab_apli    --> Percentual de IR da aplicac?o
                                         ,pr_cdprogra  => pr_nmdatela         --> Programa chamador
                                         ,pr_inproces  => 0                   --> Indicador do processo
                                         ,pr_dtmvtolt  => pr_dtmvtolt         --> Data do processo
                                         ,pr_dtmvtopr  => pr_dtmvtopr         --> Proximo dia util
                                         ,pr_rpp_rowid => rw_craprpp.rowid    --> Identificador do registro da tabela CRAPRPP em processamento
                                         ,pr_vlsdrdpp  => vr_vlsdrdppe        --> Saldo da poupanca programada
                                         ,pr_cdcritic  => vr_cdcritic         --> Codigo da critica de erro
                                         ,pr_des_erro  => vr_dscritic);       --> Descrição do erro encontrado
            ELSE 
               vr_vlresgat := 0;
               vr_saldorpp := 0;
               vr_vlsdrdppe := 0;
               vr_fase := 25;
               /* Rotina de calculo do saldo da aplicação até a data do movimento */
               pc_calc_saldo_apl_prog (pr_cdcooper => pr_cdcooper   --> Cooperativa
                                      ,pr_cdprogra => pr_nmdatela   --> Programa chamador
                                      ,pr_cdoperad => pr_cdoperad   --> Operador
                                      ,pr_nrdconta => pr_nrdconta   --> Número da conta
                                      ,pr_idseqttl => pr_idseqttl   -->
                                      ,pr_idorigem => pr_idorigem   --> Origem
                                      ,pr_nrctrrpp => pr_nrctrrpp   --> Contrato da poupança
                                      ,pr_dtmvtolt => pr_dtmvtolt   --> Data Movimento
                                      ,pr_vlsdrdpp => vr_vlsdrdppe  --> Saldo da poupanca programada
                                      ,pr_des_erro => vr_dscritic); --> Descrição do erro encontrado
            END IF;           
            -- Se encontrar erros na execução
            IF vr_dscritic is not null THEN
               vr_cdcritic := 0;
               RAISE vr_exc_saida;
            END IF;
            vr_saldorpp := vr_vlsdrdppe;
            -- 
            vr_fase := 30;
            IF vr_saldorpp > 0   THEN
               vr_vlirabap := 0;
               IF rw_craprpp.vlabcpmf is NULL THEN
                  vr_vlabcpmf := 0;
               ELSE
                 vr_vlabcpmf := rw_craprpp.vlabcpmf;
               END IF;
               IF vr_vlabcpmf <> 0 THEN
                  /* Procedure para verificar imunidade tributaria e inserir valor de insenção */
                  IMUT0001.pc_verifica_imunidade_trib (pr_cdcooper  => pr_cdcooper  --> Codigo Cooperativa
                                                      ,pr_nrdconta  => pr_nrdconta  --> Numero da Conta
                                                      ,pr_dtmvtolt  => pr_dtmvtolt  --> Data movimento
                                                      ,pr_flgrvvlr  => FALSE        --> Identificador se deve gravar valor
                                                      ,pr_cdinsenc  => 5            --> Codigo da insenção
                                                      ,pr_vlinsenc  => 0            --> Valor insento
                                                      ,pr_flgimune  => vr_flgimune  --> Identificador se é imune
                                                      ,pr_dsreturn  => vr_dscritic  --> Descricao Critica
                                                      ,pr_tab_erro  => vr_tab_erro);--> Tabela erros

              
                  -- se nao for imune, calcular valor
                  IF NOT vr_flgimune THEN
                     vr_vlirabap := TRUNC((vr_vlabcpmf * vr_percenir / 100),2);
                  END IF;                                     
               END IF; -- FIM IF rw_craprpp.vlabcpmf <> 0   
               CASE vr_tpresgat
                    WHEN  1  THEN  /*  Parcial  */
                          IF pr_vlresgat > (vr_saldorpp - vr_vlirabap) THEN
                             vr_vlresgat := vr_saldorpp - vr_vlirabap;
                             vr_cdcritic := 429; -- 429 - Resgate menor que o solicitado.
                          ELSE
                             vr_vlresgat := pr_vlresgat;
                          END IF;
                     WHEN  2  THEN  /*  Total  */
                           vr_vlresgat := vr_saldorpp - vr_vlirabap;
               END CASE;
            ELSE
               vr_cdcritic := 494; --> 494 - Poupanca programada sem saldo.
            END IF;
            -- Se não há critica ainda 
            IF nvl(vr_cdcritic,0) NOT IN(484,828,640,494)  THEN
               vr_fase := 40;
               -- Validar resgate
               Apli0002.pc_ver_val_bloqueio_poup (pr_cdcooper => pr_cdcooper,
                                                  pr_cdagenci => pr_cdagenci,
                                                  pr_nrdcaixa => pr_nrdcaixa,
                                                  pr_cdoperad => pr_cdoperad,
                                                  pr_nmdatela => pr_nmdatela,
                                                  pr_idorigem => 7,
                                                  pr_nrdconta => pr_nrdconta,
                                                  pr_idseqttl => pr_idseqttl,
                                                  pr_dtmvtolt => pr_dtmvtolt,
                                                  pr_dtmvtopr => vr_dtmvtopr,
                                                  pr_inproces => 1, -- On line
                                                  pr_cdprogra => pr_nmdatela,
                                                  pr_vlresgat => vr_vlresgat,
                                                  pr_flgerlog => 1,
                                                  pr_flgrespr => 0,
                                                  pr_cdcritic => vr_cdcritic,
                                                  pr_dscritic => vr_dscritic);
        
               -- Verifica se houve retorno de erros
               IF (NVL(vr_dscritic, 'OK') <> 'OK') OR (NVL(vr_cdcritic,0) > 0)  THEN
                  IF rw_craprpp.dtvctopp <= vr_dtmvtopr  THEN
                     vr_cdcritic := 828;
                     vr_dscritic := '';
                  ELSE
                     /* caso contrario critica, esta bloqueada e nao venceu */
                     vr_cdcritic := 640;
                     vr_dscritic := '';
                  END IF;
               END IF;
            END IF;
            IF  (nvl(vr_cdcritic,0) = 0 OR vr_cdcritic = 828 OR vr_cdcritic = 429) THEN
                vr_fase := 50;
                IF (rw_craprpp.cdprodut <= 0) THEN
                   pc_gera_resgate_poup_prog (pr_cdcooper => pr_cdcooper,
                                              pr_flgcreci => pr_flgctain,
                                              pr_vlresgat => vr_vlresgat);
                ELSE
                   pc_gera_resgate_apl_prog (pr_cdcooper => pr_cdcooper,
                                             pr_tpresgat => Vr_tpresgat,
                                             pr_flgcreci => pr_flgctain,
                                             pr_vlresgat => vr_vlresgat);
                END IF;
                
                IF (vr_dscritic IS NULL) THEN         
                   vr_fase := 60;
           vr_geraprotocolo := 1;
                   /* Atualizar valor resgatado */
                   BEGIN
                      UPDATE craprpp
                      SET craprpp.vlrgtacu = craprpp.vlrgtacu + vr_vlresgat
                      WHERE craprpp.rowid = rw_craprpp.rowid;
                   EXCEPTION
                      WHEN OTHERS THEN
                           vr_cdcritic := 0;
                           vr_dscritic := 'Não foi possivel atualizar craprpp (nrdconta:'||rw_craprpp.nrdconta||'): '||SQLERRM;
                           RAISE vr_exc_saida; 
                   END;
                END IF;
                /* Atualizar lancamentos de resgates solicitados como processado */
                BEGIN
                  UPDATE craplrg
                     SET craplrg.inresgat = 1
                   WHERE craplrg.rowid = vr_craplrg_rowid;
                EXCEPTION
                  WHEN OTHERS THEN
                    vr_cdcritic := 0;
                    vr_dscritic := 'Não foi possivel atualizar craplrg (nrdconta:'||rw_craprpp.nrdconta||'): '||SQLERRM;
                    RAISE vr_exc_saida; 
                END; 
            END IF;

         END IF; -- Resgate não agendado

     /*##############################
         INICIO GERA PROTOCOLO
     ###############################*/
   
     IF vr_geraprotocolo = 1 THEN
         -- Encontra registro do associado
         OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta);
                          
         FETCH cr_crapass INTO rw_crapass;
           
         IF cr_crapass%NOTFOUND THEN
             
           -- Fecha o cursor
           CLOSE cr_crapass;
             
           -- Monta critica
           vr_cdcritic := 9;
           vr_dscritic := NULL;
             
           -- Gera exceção
           RAISE vr_exc_saida;
             
         ELSE
           -- Fecha o cursor
           CLOSE cr_crapass;   
           
         END IF;        
        
           -- Busca cooperativa
         OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
         
         FETCH cr_crapcop INTO rw_crapcop;
         
         --Se nao encontrou
         IF cr_crapcop%NOTFOUND THEN
           
           --Fechar Cursor
           CLOSE cr_crapcop;
           
           vr_cdcritic:= 651;
           vr_dscritic:= NULL;
           
           -- Gera exceção
           RAISE vr_exc_saida;
           
         END IF;
         
         --Fechar Cursor
         CLOSE cr_crapcop;
        
         -- Busca a cidade do PA do associado
         OPEN cr_crapage(pr_cdcooper => rw_crapass.cdcooper
                        ,pr_cdagenci => rw_crapass.cdagenci);
                              
         FETCH cr_crapage INTO vr_nmcidade;
               
         IF cr_crapage%NOTFOUND THEN
           --Fechar Cursor
           CLOSE cr_crapage;
                   
           vr_cdcritic:= 962;
           vr_dscritic:= NULL;
                   
           -- Gera exceção
           RAISE vr_exc_saida;
         ELSE
           -- Fechar o cursor
           CLOSE cr_crapage;
                 
         END IF; 
        
         --Formata nrdconta para visualizacao na internet 
         vr_nrdconta:= GENE0002.fn_mask_conta(rw_crapass.nrdconta);
           
         --Trocar o ultimo ponto por traco
         vr_nrdconta:= SubStr(vr_nrdconta,1,Length(vr_nrdconta)-2)||'-'||
                       SubStr(vr_nrdconta,Length(vr_nrdconta),1);
           
         --Se for pessoa fisica
         IF rw_crapass.inpessoa = 1 THEN
             
           --ome do titular que fez a transferencia
           OPEN cr_crapttl (pr_cdcooper => rw_crapass.cdcooper
                           ,pr_nrdconta => rw_crapass.nrdconta
                           ,pr_idseqttl => pr_idseqttl);
             
           --Posicionar no proximo registro
           FETCH cr_crapttl INTO rw_crapttl;
             
           --Se nao encontrar
           IF cr_crapttl%NOTFOUND THEN
             --Fechar Cursor
             CLOSE cr_crapttl;
               
             vr_cdcritic:= 0;
             vr_dscritic:= 'Titular nao encontrado.';
               
             -- Gera exceção
             RAISE vr_exc_saida;
           END IF;
             
           --Fechar Cursor
           CLOSE cr_crapttl;
             
           --Nome titular
           vr_nmextttl:= rw_crapttl.nmextttl;
             
         ELSE
           vr_nmextttl:= rw_crapass.nmprimtl;
         END IF;
        
         IF (vr_perirapl < 0) THEN
            vr_dsperirapl := '';
         ELSE
             vr_dsperirapl := TO_CHAR(NVL(vr_perirapl, '0'), 'fm990D00') || '%';
         END IF;
         
         vr_dsinfor1:= 'Resgate Aplic. Programada';          
        
         vr_dsinfor2:= vr_nmextttl ||'#' ||
                       'Conta/dv: ' ||vr_nrdconta ||' - '||
                       rw_crapass.nmprimtl||'#'|| gene0002.fn_mask(rw_crapcop.cdagectl,'9999')||
                       ' - '|| rw_crapcop.nmrescop;
         vr_dsinfor3:= 'Data do Resgate: '   || TO_CHAR(pr_dtmvtolt,'dd/mm/yyyy')           || '#' ||
                       'Numero do Resgate: ' || TO_CHAR(pr_nrctrrpp,'9G999G990')    || '#' ||
               'IRRF (Imposto de Renda Retido na Fonte): ' || TO_CHAR(vr_valortir,'999G999G990D00') || '#' ||
                       'Aliquota IRRF: '       || vr_dsperirapl  || '#' ||
                       'Valor Bruto: '         || TO_CHAR(pr_vlresgat  + vr_valortir,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS=,.') || '#'  ||                                 
                       'Cooperativa: '         || UPPER(rw_crapcop.nmextcop) || '#' || 
                       'CNPJ: '                || TO_CHAR(gene0002.fn_mask_cpf_cnpj(rw_crapcop.nrdocnpj,2)) || '#' ||
                       UPPER(TRIM(vr_nmcidade)) || ', ' || TO_CHAR(pr_dtmvtolt,'dd') || ' DE ' || GENE0001.vr_vet_nmmesano(TO_CHAR(pr_dtmvtolt,'mm')) || ' DE ' || TO_CHAR(pr_dtmvtolt,'RRRR') || '.';                             
        
         --Gerar protocolo
         GENE0006.pc_gera_protocolo(pr_cdcooper => pr_cdcooper                         --> Código da cooperativa
                                   ,pr_dtmvtolt => pr_dtmvtolt                 --> Data movimento
                                   ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS')) --> Hora da transação NOK
                                   ,pr_nrdconta => pr_nrdconta                         --> Número da conta
                                   ,pr_nrdocmto => pr_nrctrrpp                         --> Número do documento
                                   ,pr_nrseqaut => 0                                   --> Número da sequencia
                                   ,pr_vllanmto => pr_vlresgat                         --> Valor lançamento
                                   ,pr_nrdcaixa => pr_nrdcaixa                         --> Número do caixa NOK
                                   ,pr_gravapro => TRUE                                --> Controle de gravação
                                   ,pr_cdtippro => 12                                  --> Código de operação
                                   ,pr_dsinfor1 => vr_dsinfor1                         --> Descrição 1
                                   ,pr_dsinfor2 => vr_dsinfor2                         --> Descrição 2
                                   ,pr_dsinfor3 => vr_dsinfor3                         --> Descrição 3
                                   ,pr_dscedent => NULL                                --> Descritivo
                                   ,pr_flgagend => FALSE                               --> Controle de agenda
                                   ,pr_nrcpfope => 0                                   --> Número de operação
                                   ,pr_nrcpfpre => 0                                   --> Número pré operação
                                   ,pr_nmprepos => ''                                  --> Nome
                                   ,pr_dsprotoc => vr_dsprotoc                         --> Descrição do protocolo
                                   ,pr_dscritic => vr_dscritic                         --> Descrição crítica
                                   ,pr_des_erro => vr_des_erro);                       --> Descrição dos erros de processo
                                 
         IF (vr_cdcritic IS NOT NULL ) OR (vr_dscritic IS NOT NULL) THEN
            RAISE vr_exc_saida;
             END IF;
         END IF;
         -- Verifica se deve gerar log
         IF pr_flgerlog = 1 THEN
            gene0001.pc_gera_log (pr_cdcooper => pr_cdcooper
                                 ,pr_cdoperad => pr_cdoperad
                                 ,pr_dscritic => pr_dscritic
                                 ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
                                 ,pr_dstransa => vr_dstransa
                                 ,pr_dttransa => TRUNC(SYSDATE)
                                 ,pr_flgtrans => 0 --> FALSE
                                 ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                                 ,pr_idseqttl => pr_idseqttl
                                 ,pr_nmdatela => pr_nmdatela
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrdrowid => vr_nrdrowid);

            gene0001.pc_gera_log_item (pr_nrdrowid => vr_nrdrowid
                                      ,pr_nmdcampo => 'NRCTRRPP'
                                      ,pr_dsdadant => ''
                                      ,pr_dsdadatu => pr_nrctrrpp);

            gene0001.pc_gera_log_item (pr_nrdrowid => vr_nrdrowid
                                      ,pr_nmdcampo => 'TPRESGAT'
                                      ,pr_dsdadant => ''
                                      ,pr_dsdadatu => pr_tpresgat);

            gene0001.pc_gera_log_item (pr_nrdrowid => vr_nrdrowid
                                      ,pr_nmdcampo => 'VLRESGAT'
                                      ,pr_dsdadant => ''
                                      ,pr_dsdadatu => to_char(pr_vlresgat,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS=,.'));

            gene0001.pc_gera_log_item (pr_nrdrowid => vr_nrdrowid
                                      ,pr_nmdcampo => 'DTRESGAT'
                                      ,pr_dsdadant => ''
                                      ,pr_dsdadatu => to_char(pr_dtresgat,'dd/mm/yyyy'));                                       

            gene0001.pc_gera_log_item (pr_nrdrowid => vr_nrdrowid
                                      ,pr_nmdcampo => 'FLGCTAIN'
                                      ,pr_dsdadant => ''
                                      ,pr_dsdadatu => vr_flgctain);
                                                                                   
         END IF;
         COMMIT;

    EXCEPTION
          WHEN vr_exc_saida THEN
               IF vr_cdcritic <> 0 and trim(vr_dscritic) IS NULL THEN
                 pr_cdcritic := vr_cdcritic;
                 pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
               ELSE
                 pr_cdcritic := vr_cdcritic;
                 pr_dscritic := vr_dscritic;
               END IF;
               ROLLBACK;
               --Executar rotina geracao erro
               gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                    ,pr_cdagenci => pr_cdagenci
                                    ,pr_nrdcaixa => pr_nrdcaixa
                                    ,pr_nrsequen => 1 --> Fixo
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic
                                    ,pr_tab_erro => vr_tab_erro);

               -- Verifica se deve gerar log
               IF pr_flgerlog = 1 THEN
                  gene0001.pc_gera_log (pr_cdcooper => pr_cdcooper
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_dscritic => pr_dscritic
                                       ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
                                       ,pr_dstransa => vr_dstransa
                                       ,pr_dttransa => TRUNC(SYSDATE)
                                       ,pr_flgtrans => 0 --> FALSE
                                       ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                                       ,pr_idseqttl => pr_idseqttl
                                       ,pr_nmdatela => pr_nmdatela
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrdrowid => vr_nrdrowid);

                  gene0001.pc_gera_log_item (pr_nrdrowid => vr_nrdrowid
                                            ,pr_nmdcampo => 'NRCTRRPP'
                                            ,pr_dsdadant => ''
                                            ,pr_dsdadatu => pr_nrctrrpp);

                  gene0001.pc_gera_log_item (pr_nrdrowid => vr_nrdrowid
                                            ,pr_nmdcampo => 'TPRESGAT'
                                            ,pr_dsdadant => ''
                                            ,pr_dsdadatu => pr_tpresgat);

                  gene0001.pc_gera_log_item (pr_nrdrowid => vr_nrdrowid
                                            ,pr_nmdcampo => 'VLRESGAT'
                                            ,pr_dsdadant => ''
                                            ,pr_dsdadatu => to_char(pr_vlresgat,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS=,.'));

                  gene0001.pc_gera_log_item (pr_nrdrowid => vr_nrdrowid
                                            ,pr_nmdcampo => 'DTRESGAT'
                                            ,pr_dsdadant => ''
                                            ,pr_dsdadatu => to_char(pr_dtresgat,'dd/mm/yyyy'));                                       

                  gene0001.pc_gera_log_item (pr_nrdrowid => vr_nrdrowid
                                            ,pr_nmdcampo => 'FLGCTAIN'
                                            ,pr_dsdadant => ''
                                            ,pr_dsdadatu => vr_flgctain);
                                                                                   
               END IF;
               COMMIT;
          WHEN OTHERS THEN
               pr_cdcritic := null; -- não será utilizado
               pr_dscritic := 'Erro geral em APLI0008.pc_efet_resgate_apl_prog: ('||vr_fase||')'||SQLERRM;
               ROLLBACK;

               --Executar rotina geracao erro
               gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                    ,pr_cdagenci => pr_cdagenci
                                    ,pr_nrdcaixa => pr_nrdcaixa
                                    ,pr_nrsequen => 1 --> Fixo
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic
                                    ,pr_tab_erro => vr_tab_erro);
               -- Verifica se deve gerar log
               IF pr_flgerlog = 1 THEN
                  gene0001.pc_gera_log (pr_cdcooper => pr_cdcooper
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_dscritic => pr_dscritic
                                       ,pr_dsorigem => gene0001.vr_vet_des_origens(pr_idorigem)
                                       ,pr_dstransa => vr_dstransa
                                       ,pr_dttransa => TRUNC(SYSDATE)
                                       ,pr_flgtrans => 0 --> FALSE
                                       ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                                       ,pr_idseqttl => pr_idseqttl
                                       ,pr_nmdatela => pr_nmdatela
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrdrowid => vr_nrdrowid);

                  gene0001.pc_gera_log_item (pr_nrdrowid => vr_nrdrowid
                                            ,pr_nmdcampo => 'NRCTRRPP'
                                            ,pr_dsdadant => ''
                                            ,pr_dsdadatu => pr_nrctrrpp);

                  gene0001.pc_gera_log_item (pr_nrdrowid => vr_nrdrowid
                                            ,pr_nmdcampo => 'TPRESGAT'
                                            ,pr_dsdadant => ''
                                            ,pr_dsdadatu => pr_tpresgat);

                  gene0001.pc_gera_log_item (pr_nrdrowid => vr_nrdrowid
                                            ,pr_nmdcampo => 'VLRESGAT'
                                            ,pr_dsdadant => ''
                                            ,pr_dsdadatu => to_char(pr_vlresgat,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS=,.'));

                  gene0001.pc_gera_log_item (pr_nrdrowid => vr_nrdrowid
                                            ,pr_nmdcampo => 'DTRESGAT'
                                            ,pr_dsdadant => ''
                                            ,pr_dsdadatu => to_char(pr_dtresgat,'dd/mm/yyyy'));                                       

                  gene0001.pc_gera_log_item (pr_nrdrowid => vr_nrdrowid
                                            ,pr_nmdcampo => 'FLGCTAIN'
                                            ,pr_dsdadant => ''
                                            ,pr_dsdadatu => vr_flgctain);
                                                                                   
               END IF;
               COMMIT;
    END;
  END pc_efet_resgate_apl_prog;

  PROCEDURE pc_efet_resgate_apl_prog_web (pr_nrdconta IN craprac.nrdconta%TYPE -- Número da Conta
                                         ,pr_idseqttl IN crapttl.idseqttl%TYPE -- Sequêncial do titular   
                                         ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE -- Número da Aplicação Programada.
                                         ,pr_dtmvtolt IN VARCHAR2              -- Data de Movimento 
                                         ,pr_dtmvtopr IN VARCHAR2              -- Data do proximo movimento
                                         ,pr_inproces IN crapdat.inproces%TYPE -- Indicador de processo
                                         ,pr_tpresgat IN VARCHAR2              -- Tipo de Resgate (T = Total / P = Parcial)
                                         ,pr_vlresgat IN craplrg.vllanmto%TYPE -- Valor do resgate
                                         ,pr_dtresgat IN VARCHAR2              -- Data para resgate
                                         ,pr_flgctain IN VARCHAR2              -- Flag Conta Investimento ( yes / no )
                                         ,pr_flgerlog IN INTEGER               -- Indicador se deve gerar log(0-nao, 1-sim)
                                         ,pr_xmllog   IN VARCHAR2              -- XML com informacoes de LOG
                                         ,pr_cdcritic OUT PLS_INTEGER          -- Código da crítica
                                         ,pr_dscritic OUT VARCHAR2             -- Descrição da crítica
                                         ,pr_retxml   IN OUT NOCOPY XMLType    -- Arquivo de retorno do XML
                                         ,pr_nmdcampo OUT VARCHAR2             -- Nome do campo com erro
                                         ,pr_des_erro OUT VARCHAR2)            -- Erros do processo

  IS
      BEGIN
        /* .............................................................................

         Programa: pc_efet_resgate_apl_prog_web
         Sistema : Rotinas referentes à aplicação programada
         Sigla   : CRED
         Autor   : CIS Corporate
         Data    : Setembro/2018.                    

         Dados referentes ao programa:

         Frequencia:
         Objetivo  : Efetiva o resgate de uma aplicação programada - Mensageria
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
        vr_dtmvtopr Date := TO_DATE(pr_dtmvtopr,'dd/mm/yyyy'); 
        vr_dtresgat Date := TO_DATE(pr_dtresgat,'dd/mm/yyyy');
        vr_flgctain INTEGER:=0; -- No

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
        
      --Registro do tipo calendario
      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

        
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

        -- Verifica se a cooperativa esta cadastrada
        OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);     
        FETCH BTCH0001.cr_crapdat INTO rw_crapdat;     
        -- Se não encontrar
        IF BTCH0001.cr_crapdat%NOTFOUND THEN       
           -- Fechar o cursor pois haverá raise
           CLOSE BTCH0001.cr_crapdat;           
           -- Montar mensagem de critica
           vr_cdcritic := 1;
           vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
           -- Gera exceção
           RAISE vr_exc_erro;
        END IF;

        IF (pr_dtmvtolt IS NULL) THEN            
           vr_dtmvtolt := rw_crapdat.dtmvtolt;
           vr_dtmvtopr := rw_crapdat.dtmvtopr;
           vr_dtresgat := rw_crapdat.dtmvtolt;
        END IF;
        
        /* Se o batch estiver em execucao */
        IF rw_crapdat.inproces > 1 THEN
           vr_dtmvtolt := rw_crapdat.dtmvtocd;
           vr_dtmvtopr := gene0005.fn_valida_dia_util(pr_cdcooper => vr_cdcooper
                                                     ,pr_dtmvtolt => (rw_crapdat.dtmvtocd + 1)
                                                     ,pr_tipo => 'P'
                                                     ,pr_feriado => true
                                                     ,pr_excultdia => true);
           vr_dtresgat := rw_crapdat.dtmvtocd;
        END IF;
        
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;

        IF lower(pr_flgctain) = 'yes' THEN
           vr_flgctain := 1;
        END IF;
        -- Efetiva o resgate da aplicação programada
        pc_efet_resgate_apl_prog (pr_cdcooper => vr_cdcooper
                                   ,pr_cdagenci => vr_cdagenci
                                 ,pr_nrdcaixa => vr_nrdcaixa
                                 ,pr_cdoperad => vr_cdoperad
                                 ,pr_nmdatela => vr_nmdatela
                                 ,pr_idorigem => vr_idorigem
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_idseqttl => pr_idseqttl
                                 ,pr_nrctrrpp => pr_nrctrrpp
                                 ,pr_dtmvtolt => vr_dtmvtolt
                                 ,pr_dtmvtopr => vr_dtmvtopr
                                 ,pr_tpresgat => pr_tpresgat
                                 ,pr_vlresgat => pr_vlresgat
                                 ,pr_dtresgat => vr_dtresgat
                                 ,pr_flgctain => vr_flgctain
                                 ,pr_flgerlog => pr_flgerlog
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
                                 ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>'
                                 ,pr_fecha_xml      => TRUE);

                                    
         pr_retxml := XMLType.createXML(vr_clobxmlc);
         COMMIT;
      Exception
        When vr_exc_erro Then
          --vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
          ROLLBACK;

          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
            
        When others Then
          pr_cdcritic := null; -- não será utilizado
          pr_dscritic := 'Erro geral em APLI0008.pc_efet_resgate_apl_prog_web: '||SQLERRM;
          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_dscritic ||
                                         '</Erro></Root>');
          ROLLBACK;
      END;

  END pc_efet_resgate_apl_prog_web;

  /* Recupera a configuração da apl. programada de uma cooperativa + Produto */
  PROCEDURE pc_buscar_conf_apl_prog (pr_cdcooper IN crapcop.cdcooper%TYPE                                 --> Código da cooperativa a ser alterada 
                                    ,pr_cdprodut IN crapcpc.cdprodut%TYPE                                 --> Código do produto
                                    ,pr_idconfig OUT tbcapt_config_planos_apl_prog.idconfiguracao%TYPE 
                                                                                                          --> ID da configuração  
                                    ,pr_flgteimo OUT tbcapt_config_planos_apl_prog.flgteimosinha%TYPE     --> Teimosinha? (0 = Nao, 1 = Sim)
                                    ,pr_fldbparc OUT tbcapt_config_planos_apl_prog.flgdebito_parcial%TYPE --> Debito Parcial (0 = Nao, 1 = Sim)
                                    ,pr_vlminimo OUT tbcapt_config_planos_apl_prog.vlminimo%TYPE          --> Valor mínimo do débito parcial
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE                                --> Codigo da critica de erro
                                    ,pr_dscritic OUT crapcri.dscritic%TYPE)                               --> Descricao da critica de erro

   IS
      /* .............................................................................
        Programa:  pc_buscar_conf_apl_prog
        Sistema  : Ayllos Web
        Autor    : CIS Corporate
        Data     : Outubro/2018.                   Ultima atualizacao: 
        
        Dados referentes ao programa:
        
        Frequencia: Sempre que for chamado
        Objetivo  : Recupera a configuração da aplicação programada de um produto em uma cooperativa
        
        Alteracoes: 
      ............................................................................. */
      BEGIN
        
      DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      
      vr_exc_saida exception;     

      -------------------- CURSORES --------------------
      
      -- Recupera prox. número da configuração
      CURSOR cr_config_planos IS 
      SELECT  tb.idconfiguracao
             ,tb.flgteimosinha
             ,tb.flgdebito_parcial
             ,tb.vlminimo
      FROM  tbcapt_config_planos_apl_prog tb
      WHERE tb.cdcooper = pr_cdcooper 
      AND   tb.cdprodut = pr_cdprodut;
      
      rw_config_planos cr_config_planos%ROWTYPE;
      
      BEGIN -- Inicio da procedure
        
            -- Verifica se a configuracao existe
            OPEN cr_config_planos;
            FETCH cr_config_planos INTO rw_config_planos;
            -- Se não encontrar
            IF cr_config_planos%NOTFOUND THEN
                   vr_cdcritic := 999;                              -- Critica 999 para que o front end possa continuar, não mas poderá ser criado
                   vr_dscritic := 'Configuração não encontrada';
            ELSE
                   pr_idconfig := rw_config_planos.idconfiguracao;
                   pr_flgteimo := rw_config_planos.flgteimosinha;
                   pr_fldbparc := rw_config_planos.flgdebito_parcial;
                   pr_vlminimo := rw_config_planos.vlminimo;
            END IF;
            CLOSE cr_config_planos;
            IF vr_dscritic IS NOT NULL THEN
                   RAISE vr_exc_saida;
            END IF;              
      EXCEPTION
        WHEN vr_exc_saida THEN
              pr_cdcritic := vr_cdcritic;
              pr_dscritic := vr_dscritic;
        WHEN OTHERS THEN
              pr_cdcritic := 0;                                      -- Critica 0 = Não foi um not found
              pr_dscritic := 'Erro geral em apli0008.pc_buscar_conf_apl_prog: ' ||
                          SQLERRM;
        END;
  END pc_buscar_conf_apl_prog;   

  /* Recupera a configuração da apl. programada de uma cooperativa + Produto  - Mensageria */
  PROCEDURE pc_buscar_conf_apl_prog_web (pr_cdcooper_b IN craprac.nrdconta%TYPE -- Código da cooperativa a ser procurada
                                        ,pr_cdprodut   IN crapcpc.cdprodut%TYPE -- Código do produto
                                        ,pr_xmllog     IN VARCHAR2              -- XML com informacoes de LOG
                                        ,pr_cdcritic   OUT PLS_INTEGER          -- Código da crítica
                                        ,pr_dscritic   OUT VARCHAR2             -- Descrição da crítica
                                        ,pr_retxml     IN OUT NOCOPY XMLType    -- Arquivo de retorno do XML
                                        ,pr_nmdcampo   OUT VARCHAR2             -- Nome do campo com erro
                                        ,pr_des_erro   OUT VARCHAR2)            -- Erros do processo

  IS
      BEGIN
        /* .............................................................................

         Programa: pc_buscar_conf_apl_prog_web
         Sistema : Rotinas referentes à aplicação programada
         Sigla   : CRED
         Autor   : CIS Corporate
         Data    : Outubro/2018.                    

         Dados referentes ao programa:

         Frequencia:
         Objetivo  : Recupera a configuração da aplicação programada de um produto em uma cooperativa - Mensageria
         Alteracoes: 
         
        ..............................................................................*/

      DECLARE
        -- Variável de críticas
        vr_cdcritic crapcri.cdcritic%TYPE;
        vr_dscritic crapcri.dscritic%TYPE;
             
        -- Variaveis auxiliares
        vr_exc_erro EXCEPTION;

        -- Variaveis de log
        vr_cdcooper crapcop.cdcooper%TYPE;
        vr_cdoperad VARCHAR2(100);
        vr_nmdatela VARCHAR2(100);
        vr_nmeacao  VARCHAR2(100);
        vr_cdagenci VARCHAR2(100);
        vr_nrdcaixa VARCHAR2(100);
        vr_idorigem VARCHAR2(100);
        
        -- Variáveis de retorno
        
        vr_idconfig tbcapt_config_planos_apl_prog.idconfiguracao%TYPE;
        vr_flgteimo pls_integer; -- Obs. O retorno através da xml é diferente da proc normal 
        vr_fldbparc pls_integer; -- para ser compatível com a tela (1 = sim, 2 = nao)
        vr_vlminimo tbcapt_config_planos_apl_prog.vlminimo%TYPE;
        
        vr_texto_novo VARCHAR2(5000);

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
        -- Efetua a consulta
        pc_buscar_conf_apl_prog (pr_cdcooper => pr_cdcooper_b
                                ,pr_cdprodut => pr_cdprodut
                                ,pr_idconfig => vr_idconfig
                                ,pr_flgteimo => vr_flgteimo
                                ,pr_fldbparc => vr_fldbparc
                                ,pr_vlminimo => vr_vlminimo
                                ,pr_cdcritic => vr_cdcritic
                                ,pr_dscritic => vr_dscritic);        

        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_erro;
        END IF;     
        IF vr_flgteimo = 0 THEN
          vr_flgteimo:=2;
        END IF;
        IF vr_fldbparc = 0 THEN
          vr_fldbparc := 2;
        END IF;
        -- Criar cabeçalho do XML
        dbms_lob.createtemporary(vr_clobxmlc, TRUE); 
        dbms_lob.open(vr_clobxmlc, dbms_lob.lob_readwrite);
        -- Insere o cabeçalho do XML 
        gene0002.pc_escreve_xml (pr_xml            => vr_clobxmlc 
                                ,pr_texto_completo => vr_xml_temp 
                                ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados>');

        vr_texto_novo := vr_texto_novo ||
                      '<Registro>'||
                      '<idconfiguracao>'||vr_idconfig||'</idconfiguracao>'||
                      '<teimosinha>'    ||vr_flgteimo||'</teimosinha>'||  
                      '<debito_parcial>'||vr_fldbparc||'</debito_parcial>'||
                      '<vlminimo>'      ||to_char(vr_vlminimo, 'fm999g999g990d00')||'</vlminimo>'||
                      '</Registro>';

        gene0002.pc_escreve_xml(pr_xml            => vr_clobxmlc
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => vr_texto_novo);
        -- Encerrar a tag raiz 
        gene0002.pc_escreve_xml(pr_xml            => vr_clobxmlc 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => '</Dados></Root>' 
                               ,pr_fecha_xml      => TRUE);
        
        pr_retxml := XMLType.createXML(vr_clobxmlc);
        COMMIT;
      Exception
        When vr_exc_erro Then
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
          ROLLBACK;

          IF vr_cdcritic = 999 THEN -- Not found, tratar no front-end
             vr_dscritic := '999';
          END IF;
          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || vr_dscritic || '</Erro></Root>');
            
        When others Then
          pr_cdcritic := null; -- não será utilizado
          pr_dscritic := 'Erro geral em APLI0008.pc_buscar_conf_apl_prog_web: '||SQLERRM;
          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_dscritic ||
                                         '</Erro></Root>');
          ROLLBACK;
      END;

  END pc_buscar_conf_apl_prog_web;

  /* Mantém a configuração da apl. programada de uma cooperativa */
  PROCEDURE pc_manter_conf_apl_prog (pr_cdcooper IN crapcop.cdcooper%TYPE                       --> Código da cooperativa a ser alterada 
                                    ,pr_cdprodut IN crapcpc.cdprodut%TYPE                       --> Código do produto
                                    ,pr_flgteimo IN pls_integer DEFAULT 0                       --> Teimosinha? (0 = Nao, 1 = Sim)
                                    ,pr_fldbparc IN pls_integer DEFAULT 0                       --> Debito Parcial (0 = Nao, 1 = Sim)
                                    ,pr_vlminimo IN tbcapt_config_planos_apl_prog.vlminimo%TYPE --> Valor mínimo do débito parcial
                                    ,pr_idconfig OUT tbcapt_config_planos_apl_prog.idconfiguracao%TYPE 
                                                                                                --> ID da configuração  
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE                      --> Codigo da critica de erro
                                    ,pr_dscritic OUT crapcri.dscritic%TYPE)                     --> Descricao da critica de erro

   IS
      /* .............................................................................
        Programa:  pc_manter_conf_apl_prog
        Sistema  : Ayllos Web
        Autor    : CIS Corporate
        Data     : Outubro/2018.                   Ultima atualizacao: 
        
        Dados referentes ao programa:
        
        Frequencia: Sempre que for chamado
        Objetivo  : Atualiza a configuração da aplicação programada de uma cooperativa
        
        Alteracoes: 
      ............................................................................. */
      BEGIN
        
      DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(10000);
      
      vr_vlminimo tbcapt_config_planos_apl_prog.vlminimo%TYPE := pr_vlminimo;
      vr_exc_saida exception;     

      -------------------- CURSORES --------------------
      -- Busca dos dados da cooperativa
      CURSOR cr_crapcop IS
        SELECT cop.nmrescop
          FROM crapcop cop
         WHERE cop.cdcooper = pr_cdcooper
           AND cop.flgativo = 1;
      rw_crapcop cr_crapcop%ROWTYPE;
      
      -- Busca dos dados do produto
      CURSOR cr_crapcpc IS
        SELECT  cpc.idsitpro
               ,cpc.indplano
          FROM crapcpc cpc
         WHERE cpc.cdprodut = pr_cdprodut;
      rw_crapcpc cr_crapcpc%ROWTYPE;
      
      -- Recupera prox. número da configuração
      CURSOR cr_config_planos IS 
      SELECT NVL(max(idconfiguracao),0)+1 prox_idconfiguracao
      FROM  tbcapt_config_planos_apl_prog;
      rw_config_planos cr_config_planos%ROWTYPE;
      
      -- Cursor para altercao configuração
      CURSOR cr_config_planos_update IS
      SELECT 
             *   
      FROM  tbcapt_config_planos_apl_prog tbconfig
      WHERE tbconfig.cdcooper = pr_cdcooper
      AND   tbconfig.cdprodut = pr_cdprodut
      FOR   update;

      rw_config_planos_update cr_config_planos_update%ROWTYPE;             
    
      BEGIN -- Inicio da procedure
        
            -- Verifica se a cooperativa esta cadastrada
            OPEN cr_crapcop;
            FETCH cr_crapcop INTO rw_crapcop;
            -- Se não encontrar
            IF cr_crapcop%NOTFOUND THEN
                  -- Fechar o cursor pois haverá raise
                  CLOSE cr_crapcop;
                   -- Montar mensagem de critica
                   vr_cdcritic := 651;
                   vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 651);
                   RAISE vr_exc_saida;
            ELSE
                   CLOSE cr_crapcop;
            END IF;
            -- Verifica se o produto existe 
            OPEN cr_crapcpc;
            FETCH cr_crapcpc INTO rw_crapcpc;
            -- Se não encontrar
            IF cr_crapcpc%NOTFOUND THEN
                  -- Fechar o cursor pois haverá raise
                   vr_cdcritic := 0;
                   vr_dscritic := 'Produto não encontrado.';
            ELSE
                   IF rw_crapcpc.indplano <> 1 THEN -- Não é um produto de apl. programada
                      vr_cdcritic := 0;
                      vr_dscritic := 'Este produto não é uma aplicação programada.';
                   ELSIF rw_crapcpc.idsitpro <> 1 THEN  -- Não está ativo
                      vr_cdcritic := 0;
                      vr_dscritic := 'Este produto não está ativo.';
                   END IF;
            END IF;
            IF vr_dscritic IS NOT NULL THEN
                   CLOSE cr_crapcpc;
                   RAISE vr_exc_saida;
            END IF;              
            
            OPEN cr_config_planos_update;
            FETCH cr_config_planos_update INTO rw_config_planos_update;
            IF cr_config_planos_update%NOTFOUND THEN -- Não encontrou, incluir
               -- Recupera o próximo ID
               OPEN cr_config_planos;
               FETCH cr_config_planos INTO rw_config_planos;
               CLOSE cr_config_planos;
               BEGIN
                   -- Executa a inserção
                   INSERT INTO
                          tbcapt_config_planos_apl_prog (idconfiguracao
                                                        ,cdcooper
                                                        ,cdprodut
                                                        ,flgteimosinha
                                                        ,flgdebito_parcial
                                                        ,vlminimo) values (
                                                        rw_config_planos.prox_idconfiguracao
                                                        ,pr_cdcooper
                                                        ,pr_cdprodut
                                                        ,pr_flgteimo
                                                        ,pr_fldbparc
                                                        ,pr_vlminimo);

                   pr_idconfig := rw_config_planos.prox_idconfiguracao;
               EXCEPTION
                 WHEN OTHERS THEN
                      vr_cdcritic := 0;
                      vr_dscritic := 'Erro na inclusão na tabela tbcapt_config_planos_apl_prog' ||SQLERRM;
                      RAISE vr_exc_saida;                
               END;
            ELSE -- Alterar
               IF pr_fldbparc = 0 THEN  -- Se não aceita débito parcial, zeramos o valor mínimo
                   vr_vlminimo := 0;
               END IF;
               pr_idconfig:= rw_config_planos_update.idconfiguracao;          
               BEGIN
                    UPDATE 
                        tbcapt_config_planos_apl_prog
                    SET 
                        flgteimosinha     = pr_flgteimo
                       ,flgdebito_parcial = pr_fldbparc
                       ,vlminimo          = vr_vlminimo
                    WHERE
                       CURRENT OF cr_config_planos_update;   
               EXCEPTION
                 WHEN OTHERS THEN
                      vr_cdcritic := 0;
                      vr_dscritic := 'Erro na alteração na tabela tbcapt_config_planos_apl_prog' ||SQLERRM;
                      RAISE vr_exc_saida;                
               END;
            END IF;
            -- Fechar o cursor utilizado para busca
            CLOSE cr_config_planos_update;
            IF vr_dscritic IS NOT NULL THEN
               RAISE vr_exc_saida;    
            END IF;
            COMMIT;
      EXCEPTION
        WHEN vr_exc_saida THEN
              IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
                vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
              END IF;
              ROLLBACK;
              pr_cdcritic := vr_cdcritic;
              pr_dscritic := vr_dscritic;
        WHEN OTHERS THEN
              pr_cdcritic := vr_cdcritic;
              pr_dscritic := 'Erro geral em apli0008.pc_manter_conf_apl_prog: ' ||
                          SQLERRM;
                          ROLLBACK;
        END;
  END pc_manter_conf_apl_prog;   

  /* Mantém a configuração da apl. programada de uma cooperativa  - Mensageria */
  PROCEDURE pc_manter_conf_apl_prog_web (pr_cdcooper_a IN craprac.nrdconta%TYPE                     -- Código da cooperativa a ter a config alterada
                                        ,pr_cdprodut   IN crapcpc.cdprodut%TYPE                     -- Código do produto
                                        ,pr_flgteimo IN pls_integer                                 -- Teimosinha? (0 = Nao, 1 = Sim)
                                        ,pr_fldbparc IN pls_integer                                 -- Debito Parcial (0 = Nao, 1 = Sim)
                                        ,pr_vlminimo IN tbcapt_config_planos_apl_prog.vlminimo%TYPE -- Valor mínimo do débito parcial
                                        ,pr_xmllog     IN VARCHAR2                                  -- XML com informacoes de LOG
                                        ,pr_cdcritic   OUT PLS_INTEGER                              -- Código da crítica
                                        ,pr_dscritic   OUT VARCHAR2                                 -- Descrição da crítica
                                        ,pr_retxml     IN OUT NOCOPY XMLType                        -- Arquivo de retorno do XML
                                        ,pr_nmdcampo   OUT VARCHAR2                                 -- Nome do campo com erro
                                        ,pr_des_erro   OUT VARCHAR2)                                -- Erros do processo

  IS
      BEGIN
        /* .............................................................................

         Programa: pc_manter_conf_apl_prog_web
         Sistema : Rotinas referentes à aplicação programada
         Sigla   : CRED
         Autor   : CIS Corporate
         Data    : Outubro/2018.                    

         Dados referentes ao programa:

         Frequencia:
         Objetivo  : Atualiza a configuração da aplicação programada de uma cooperativa - Mensageria
         Alteracoes: 
         
        ..............................................................................*/

      DECLARE
        -- Variável de críticas
        vr_cdcritic crapcri.cdcritic%TYPE;
        vr_dscritic crapcri.dscritic%TYPE;
             
        -- Variaveis auxiliares
        vr_exc_erro EXCEPTION;

        -- Variaveis de log
        vr_cdcooper crapcop.cdcooper%TYPE;
        vr_cdoperad VARCHAR2(100);
        vr_nmdatela VARCHAR2(100);
        vr_nmeacao  VARCHAR2(100);
        vr_cdagenci VARCHAR2(100);
        vr_nrdcaixa VARCHAR2(100);
        vr_idorigem VARCHAR2(100);
        
        -- Variáveis de retorno
        
        vr_idconfig tbcapt_config_planos_apl_prog.idconfiguracao%TYPE;

        
        vr_texto_novo VARCHAR2(5000);

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
        -- Inclui/Atualiza
        pc_manter_conf_apl_prog (pr_cdcooper => pr_cdcooper_a
                                ,pr_idconfig => vr_idconfig
                                ,pr_cdprodut => pr_cdprodut
                                ,pr_flgteimo => pr_flgteimo
                                ,pr_fldbparc => pr_fldbparc
                                ,pr_vlminimo => pr_vlminimo
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

        vr_texto_novo := vr_texto_novo ||
                      '<Registro>'||
                      '<idconfiguracao>'||vr_idconfig||'</idconfiguracao>'||
                      '</Registro>';

        gene0002.pc_escreve_xml(pr_xml            => vr_clobxmlc
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => vr_texto_novo);
        -- Encerrar a tag raiz 
        gene0002.pc_escreve_xml(pr_xml            => vr_clobxmlc 
                               ,pr_texto_completo => vr_xml_temp 
                               ,pr_texto_novo     => '</Dados></Root>' 
                               ,pr_fecha_xml      => TRUE);
        
        pr_retxml := XMLType.createXML(vr_clobxmlc);
        COMMIT;
      Exception
        When vr_exc_erro Then
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
          ROLLBACK;
          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || vr_dscritic || '</Erro></Root>');
            
        When others Then
          pr_cdcritic := null; -- não será utilizado
          pr_dscritic := 'Erro geral em APLI0008.pc_buscar_conf_apl_prog_web: '||SQLERRM;
          -- Carregar XML padrão para variável de retorno não utilizada.
          -- Existe para satisfazer exigência da interface.
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                         '<Root><Erro>' || pr_dscritic ||
                                         '</Erro></Root>');
          ROLLBACK;
      END;

  END pc_manter_conf_apl_prog_web;

  PROCEDURE pc_ObterListaPlanoAplProg (pr_cdcooper IN crapcop.cdcooper%TYPE            --> Cooperativa
                                      ,pr_idorigem IN INTEGER                          --> Identificador da Origem
                                      ,pr_nrdconta IN craprda.nrdconta%TYPE            --> Nro da conta da aplicacao RDCA
                                      ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE            --> Data do movimento atual
                                      ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE            --> Data do proximo movimento
                                      ,pr_idseqttl IN INTEGER                          --> Identificador Sequencial
                                      ,pr_situacao IN INTEGER                          --> (0 = Todos, 1 = Ativos, 2 = Suspensos, 3 = Desativado: Não ativos, cancelados e vencidos)
                                      ,pr_tpinvest IN INTEGER                          --> (0 = Todos, 1/2 = Poupança Programada de planos antigos, 3 = Indexador Pre, 4 = Indexador POS)
                                      ,pr_cdagenci IN crapage.cdagenci%TYPE            --> Codigo da Agencia
                                      ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE            --> Numero do caixa
                                      ,pr_cdoperad IN craplrg.cdoperad%TYPE            --> Codigo do Operador
                                      ,pr_cdprogra IN crapprg.cdprogra%TYPE            --> Nome do programa chamador
                                      ,pr_flgerlog IN INTEGER                          --> Flag erro log
                                      ,pr_cdcritic OUT PLS_INTEGER                     --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2                        --> Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType) IS               --> Arquivo de retorno do XML
  BEGIN
  /* .............................................................................

   Programa: pc_ObterListaPlanoAplProg               
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : CIS Corporate
   Data    : Outubro/2018.                        Ultima atualizacao: 10/10/2018

   Dados referentes ao programa:

   Frequencia: Sempre que necessário
   Objetivo  : Rotina para consultar saldo e demais dados de poupancas programadas e aplicações programadas pelo IB

   Alteracoes: 
  ............................................................................. */
    DECLARE
    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    
    -- Variaveis auxiliares
    vr_exc_erro EXCEPTION;

    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    vr_vlsldrpp NUMBER;
    vr_retorno VARCHAR(10);
    
    vr_nrctrrpp craprpp.nrctrrpp%TYPE := 0;

    -- Variaveis de retorno
    vr_tab_craptab APLI0001.typ_tab_ctablq;
    vr_tab_craplpp APLI0001.typ_tab_craplpp;
    vr_tab_craplrg APLI0001.typ_tab_craplpp;
    vr_tab_resgate APLI0001.typ_tab_resgate;
    vr_tab_dados_rpp typ_tab_dados_rpp;
    vr_tab_erro gene0001.typ_tab_erro;

    vr_situacao INTEGER;
    vr_tpinvest INTEGER;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100) := 'INTERNET';
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_tpapprog VARCHAR2(100);
    vr_flgerlog BOOLEAN := FALSE; 
    

    -- Variaveis de XML 
    vr_xml_temp VARCHAR2(32767);
    vr_clobxmlc CLOB;
    vr_texto_novo VARCHAR2(1000);

    
  BEGIN
    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;     
    
    IF pr_flgerlog = 1 THEN
      vr_flgerlog := TRUE;
    END IF;

      -- Verifica se os parâmetros são válidos
      if pr_situacao not in (0,1,2,3) THEN
         vr_dscritic := 'Valor invalido para pr_situacao';
         RAISE vr_exc_erro;
      END IF;

      if pr_tpinvest not in (0,1,2,3) THEN
         vr_dscritic := 'Valor invalido para pr_tpinvest';
         RAISE vr_exc_erro;
      END IF;
      
      IF ((pr_situacao IS NULL) OR (pr_situacao = 0)) THEN
        vr_situacao := 4;
      ELSE 
        vr_situacao := pr_situacao;
      END IF;
      
      IF ((pr_tpinvest IS NULL) OR (pr_tpinvest = 0)) THEN
        vr_tpinvest := 3;
      ELSIF pr_tpinvest IN (1,2) THEN
        vr_tpinvest := 2; -- PRE OU POS (1 E 2)
      ELSE
        vr_tpinvest := 0; 
      END IF;

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
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;

    -- Busca as informações da apl. programada
    pc_lista_poupanca (pr_cdcooper => pr_cdcooper
                      ,pr_cdagenci => pr_cdagenci
                      ,pr_nrdcaixa => pr_nrdcaixa
                      ,pr_cdoperad => pr_cdoperad
                      ,pr_idorigem => pr_idorigem
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_idseqttl => pr_idseqttl
                      ,pr_nrctrrpp => vr_nrctrrpp
                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                      ,pr_dtmvtopr => rw_crapdat.dtmvtopr
                      ,pr_inproces => 0
                      ,pr_cdprogra => vr_nmdatela
                      ,pr_flgerlog => vr_flgerlog
                      ,pr_percenir => 0
                      ,pr_tpapprog => 0
                      ,pr_tpinvest => vr_tpinvest
                      ,pr_situacao => vr_situacao
                      ,pr_vlsldrpp => vr_vlsldrpp
                      ,pr_retorno  => vr_retorno
                      ,pr_tab_dados_rpp => vr_tab_dados_rpp
                      ,pr_tab_erro => vr_tab_erro);

    IF vr_retorno='NOK' THEN
       RAISE vr_exc_erro;
    END IF;
    -- Criar cabeçalho do XML
    dbms_lob.createtemporary(vr_clobxmlc, TRUE); 
    dbms_lob.open(vr_clobxmlc, dbms_lob.lob_readwrite);
    -- Insere o cabeçalho do XML 
    gene0002.pc_escreve_xml (pr_xml            => vr_clobxmlc 
                            ,pr_texto_completo => vr_xml_temp 
                            ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1" ?><Root><Dados vlsldrpp="'||vr_vlsldrpp||'">');
    
    -- Dados
    IF vr_tab_dados_rpp.count >0 THEN
       FOR i1 in vr_tab_dados_rpp.FIRST..vr_tab_dados_rpp.LAST LOOP
             IF vr_tab_dados_rpp(i1).cdprodut < 0 THEN -- ANTIGO
                vr_tpapprog := 'RPP';
             ELSE
                vr_tpapprog := 'APR';
             END IF; 
             
             /* O servico retorna se eh poupanca ou aplicacao programada de acordo com o codigo,
                porem no momento nao esta tratando cdprodut = 0 como antigo. Este tratamento eh 
                temporario ate que a CIS ajuste o servico */
             IF vr_tab_dados_rpp(i1).cdprodut = 0 THEN -- ANTIGO
               vr_tab_dados_rpp(i1).cdprodut := -1;
             END IF;
             
             vr_texto_novo := vr_texto_novo ||
                              '<Registro>'||
                              '<nrctrrpp>'||vr_tab_dados_rpp(i1).nrctrrpp||'</nrctrrpp>'||
                              '<cdagenci>'||vr_tab_dados_rpp(i1).cdagenci||'</cdagenci>'||  
                              '<cdbccxlt>'||vr_tab_dados_rpp(i1).cdbccxlt||'</cdbccxlt>'||
                              '<nrdolote>'||vr_tab_dados_rpp(i1).nrdolote||'</nrdolote>'||
                              '<dtmvtolt>'||to_char(vr_tab_dados_rpp(i1).dtmvtolt,'dd/mm/yyyy')||'</dtmvtolt>'||
                              '<dtvctopp>'||to_char(vr_tab_dados_rpp(i1).dtvctopp,'dd/mm/yyyy')||'</dtvctopp>'||
                              '<dtdebito>'||to_char(vr_tab_dados_rpp(i1).dtdebito,'dd/mm/yyyy')||'</dtdebito>'||
                              '<indiadeb>'||vr_tab_dados_rpp(i1).indiadeb||'</indiadeb>'||
                              '<vlprerpp>'||to_char(vr_tab_dados_rpp(i1).vlprerpp,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS=,.')||'</vlprerpp>'||
                              '<qtprepag>'||vr_tab_dados_rpp(i1).qtprepag||'</qtprepag>'||
                              '<vlprepag>'||to_char(vr_tab_dados_rpp(i1).vlprepag,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS=,.')||'</vlprepag>'||
                              '<vlsdtoap>'||to_char(vr_tab_dados_rpp(i1).vlsdtoap,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS=,.')||'</vlsdtoap>'||
                              '<vlsdrdpp>'||to_char(vr_tab_dados_rpp(i1).vlsdrdpp,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS=,.')||'</vlsdrdpp>'||
                              '<vlrgtrpp>'||to_char(vr_tab_dados_rpp(i1).vlrgtrpp,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS=,.')||'</vlrgtrpp>'||
                              '<vljuracu>'||to_char(vr_tab_dados_rpp(i1).vljuracu,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS=,.')||'</vljuracu>'||
                              '<vlrgtacu>'||to_char(vr_tab_dados_rpp(i1).vlrgtacu,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS=,.')||'</vlrgtacu>'||
                            --  '<dtinirpp>'||to_char(vr_tab_dados_rpp(i1).dtinirpp,'dd/mm/yyyy')||'</dtinirpp>'||
                              /* Enviaremos aqui o dtmvtolt (data contratacao) para o servico como dtinirpp, pois o servico
                                 esta exportando esse campo como data da contratacao equivocadamente. Quando o servico for ajustado,
                                 este tratamento temporario podera ser removido. */
                              '<dtinirpp>'||to_char(vr_tab_dados_rpp(i1).dtmvtolt,'dd/mm/yyyy')||'</dtinirpp>'||
                              '<dtrnirpp>'||to_char(vr_tab_dados_rpp(i1).dtrnirpp,'dd/mm/yyyy')||'</dtrnirpp>'||
                              '<dtaltrpp>'||to_char(vr_tab_dados_rpp(i1).dtaltrpp,'dd/mm/yyyy')||'</dtaltrpp>'||
                              '<dtcancel>'||to_char(vr_tab_dados_rpp(i1).dtcancel,'dd/mm/yyyy')||'</dtcancel>'||
                              '<cdsitrpp>'||vr_tab_dados_rpp(i1).cdsitrpp||'</cdsitrpp>'||
                              '<dssitrpp>'||vr_tab_dados_rpp(i1).dssitrpp||'</dssitrpp>'||
                              '<dsblqrpp>'||vr_tab_dados_rpp(i1).dsblqrpp||'</dsblqrpp>'||  
                              '<dsresgat>'||vr_tab_dados_rpp(i1).dsresgat||'</dsresgat>'||  
                              '<dsctainv>'||vr_tab_dados_rpp(i1).dsctainv||'</dsctainv>'||
                              '<dsmsgsaq>'||vr_tab_dados_rpp(i1).dsmsgsaq||'</dsmsgsaq>'||
                              '<cdtiparq>'||vr_tab_dados_rpp(i1).cdtiparq||'</cdtiparq>'||
                              '<dtsldrpp/>'||
                              '<nrdrowid>'||vr_tab_dados_rpp(i1).nrdrowid||'</nrdrowid>'||
                              '<cdprodut>'||vr_tab_dados_rpp(i1).cdprodut||'</cdprodut>'||
                              '<dsfinali>'||vr_tab_dados_rpp(i1).dsfinali||'</dsfinali>'||
                              '</Registro>';

             gene0002.pc_escreve_xml(pr_xml            => vr_clobxmlc
                                    ,pr_texto_completo => vr_xml_temp 
                                    ,pr_texto_novo     => vr_texto_novo);
             vr_texto_novo :='';                                                           
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
      pr_dscritic := 'Erro geral em APLI0008.pc_ObterListaPlanoAplProg: '||SQLERRM;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
      
  END;
END pc_ObterListaPlanoAplProg;

  PROCEDURE pc_retorna_texto_termo_adesao(pr_cdcooper IN crapcop.cdcooper%TYPE  --> Código da Cooperativa
                                     ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Código da agencia
                                     ,pr_nrdcaixa IN crapbcx.nrdcaixa%TYPE  --> Numero do caixa do operador
                                     ,pr_cdoperad IN crapope.cdoperad%TYPE  --> Código do Operador
                                     ,pr_nmdatela IN craptel.nmdatela%TYPE  --> Nome da Tela
                                     ,pr_idorigem IN INTEGER                --> Identificador de Origem
                                     ,pr_cdprogra IN crapprg.cdprogra%TYPE  --> Codigo do programa
                                     ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Número da Conta
                                     ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de Movimento
                                     ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE  --> Contrato
                                     ,pr_flgerlog IN INTEGER                --> Indicador se deve gerar log(0-nao, 1-sim)
                                     ,pr_retxml   IN OUT NOCOPY XMLType        --> Arquivo de retorno do XML
                                     ,pr_cdcritic OUT PLS_INTEGER           --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2) IS          --> Descrição da crítica
    /* .............................................................................

     Programa: pc_retorna_texto_termo_adesao
     Sistema : Rotinas referentes à aplicação programada
     Sigla   : CRED
     Autor   : CIS Corporate
     Data    : Agosto/2018.                    

     Dados referentes ao programa:

     Frequencia:
     Objetivo  : Rotina para geração do Texto de Termo de Adesão de uma Aplicação programada
     Alteracoes: 
     
    ..............................................................................*/
    
    ---- Cursores
    
     CURSOR cr_info IS
     SELECT
        cop.nmcidade, 
        cop.cdufdcop,
        ass.cdagenci, -- numero da PA
        ass.nmprimtl,
        ass.nrcpfcgc,
        ass.inpessoa
     FROM 
        crapcop cop, 
        crapass ass
  WHERE ass.cdcooper = pr_cdcooper
    AND ass.nrdconta = pr_nrdconta
    AND ass.cdcooper = cop.cdcooper;
    
    rw_info cr_info%ROWTYPE;
    
     CURSOR cr_rpp IS
     SELECT
        rpp.dtmvtolt,
        rpp.vlprerpp,
        (CASE 
          WHEN (diadebit IS NOT NULL) THEN diadebit
          ELSE extract (day from dtdebito)
          END) indiadeb,
        (CASE 
           WHEN ((rpp.dsfinali IS NULL) and (cpc.nmprodut IS NOT NULL)) OR ((rpp.dsfinali IS NOT NULL) and (trim(rpp.dsfinali))is null)  THEN cpc.nmprodut
           WHEN ((rpp.dsfinali IS NOT NULL) and (trim(rpp.dsfinali))is not null) THEN rpp.dsfinali
           END) dsfinali
     FROM 
        craprpp rpp, 
        crapcpc cpc
  WHERE rpp.cdcooper = pr_cdcooper
    AND rpp.nrdconta = pr_nrdconta
    AND rpp.nrctrrpp = pr_nrctrrpp
    AND rpp.cdprodut = cpc.cdprodut;
    
    rw_rpp cr_rpp%ROWTYPE;
    -- RG
    CURSOR cr_rg IS
    SELECT nrdocttl 
      FROM crapttl 
     WHERE tpdocttl = 'CI'
      AND cdcooper = pr_cdcooper
      AND nrdconta = pr_nrdconta;
    rw_rg cr_rg%ROWTYPE;

    CURSOR cr_craptab (pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT * 
      FROM   craptab tab
      WHERE  tab.cdcooper = pr_cdcooper
      AND    tab.nmsistem = 'CRED'
      AND    tab.tptabela = 'GENERI'     
      AND    tab.cdempres = 0           
      AND    tab.cdacesso = 'PZMAXPPROG' 
      AND    tab.tpregist = 2;                
    rw_craptab cr_craptab%ROWTYPE;

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
    
    vr_nmendter        VARCHAR2(4000);     
    
    vr_rg varchar2(20);
        
    vr_dsmailcop VARCHAR2(4000);
    vr_dsassmail VARCHAR2(200);
    vr_dscormail VARCHAR2(50);

    vr_cpfcgc VARCHAR2 (30);    

    vr_pzmaxpro pls_integer := 0;      -- Prazo 
     
    vr_inprevio pls_integer := 0;      -- Indicador de Previo de Contrato 

    -- Variaveis de XML 
    vr_xml_temp VARCHAR2(32767);
    vr_clobxmlc CLOB;
    vr_texto_novo VARCHAR2(1000);
    
    vr_vlprerpp craprpp.vlprerpp%TYPE;
    vr_dtmvtolt craprpp.dtmvtolt%TYPE;
    vr_dsfinali craprpp.dsfinali%TYPE;
    vr_indiadeb craprpp.diadebit%TYPE;
  BEGIN    
    --> Definir transação
    IF pr_flgerlog = 1 THEN
      vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
    END IF; 
    
    --> Buscar dados para impressao do Termo de Adesão 
    OPEN cr_info;
    FETCH cr_info INTO rw_info;
    IF cr_info%NOTFOUND THEN
        vr_dscritic:='Conta nao encontrada.';
        CLOSE cr_info;
        RAISE vr_exc_erro;
    END IF;
    CLOSE cr_info;

    -- Busca rg
    OPEN cr_rg;
    FETCH cr_rg INTO rw_rg;
    IF cr_rg%FOUND THEN
       vr_rg := rw_rg.nrdocttl;
    END IF;
    CLOSE cr_rg;

    Open cr_craptab (pr_cdcooper);
    Fetch cr_craptab Into rw_craptab;
    CLOSE cr_craptab;
    IF (rw_craptab.dstextab IS NULL) THEN
        vr_pzmaxpro := 0;
    ELSE
        vr_pzmaxpro := rw_craptab.dstextab;
    END IF;


     FOR data IN (SELECT VALUE(xml) col_val
             FROM TABLE(XMLSEQUENCE(EXTRACT(pr_retxml, '/Root/Dados/Registros/PrevioContrato'))) xml
            )LOOP
                vr_inprevio := 1;
            vr_vlprerpp := to_number(data.col_val.EXTRACT('/PrevioContrato/vlprerpp/text()').getstringVal(), '9999999999999999D99', 'NLS_NUMERIC_CHARACTERS=''.,''');
            vr_dtmvtolt := NULL;
            vr_dsfinali := data.col_val.EXTRACT('/PrevioContrato/dsfinali/text()').getstringVal();
            vr_indiadeb := data.col_val.EXTRACT('/PrevioContrato/indiadeb/text()').getstringVal();
     END LOOP;

    --> Buscar dados de aplicacao para Termo de Adesão 
    IF (vr_inprevio = 0) THEN
        OPEN cr_rpp;
        FETCH cr_rpp INTO rw_rpp;
        IF cr_rpp%NOTFOUND THEN
            vr_dscritic:='Aplicacao programada nao encontrada.';
            CLOSE cr_rpp;
            RAISE vr_exc_erro;
        END IF;

        vr_vlprerpp := rw_rpp.vlprerpp;
            vr_dtmvtolt := rw_rpp.dtmvtolt;
            vr_dsfinali := rw_rpp.dsfinali;
            vr_indiadeb := rw_rpp.indiadeb;

        CLOSE cr_rpp;
     END IF;


    -- Criar cabeçalho do XML
    dbms_lob.createtemporary(vr_clobxmlc, TRUE); 
    dbms_lob.open(vr_clobxmlc, dbms_lob.lob_readwrite);
    -- Insere o cabeçalho do XML 
    gene0002.pc_escreve_xml (pr_xml            => vr_clobxmlc 
                            ,pr_texto_completo => vr_xml_temp 
                            ,pr_texto_novo     => '<?xml version="1.0" encoding="utf-8"?><raiz>');

    IF rw_info.inpessoa = 1 THEN -- CPF 
        vr_cpfcgc := regexp_replace(lpad(rw_info.nrcpfcgc,11,0), '([0-9]{3})([0-9]{3})([0-9]{3})([0-9]{2})', '\1.\2.\3-\4');
    ELSE -- CNPJ
        vr_cpfcgc := regexp_replace(lpad(rw_info.nrcpfcgc,14,0), '([0-9]{2})([0-9]{3})([0-9]{3})([0-9]{4})([0-9]{2})', '\1.\2.\3/\4-\5') ;      
    END IF;
    
    vr_texto_novo := '<nrctrrpp>'     || to_char(pr_nrctrrpp,'fm99g999g990','NLS_NUMERIC_CHARACTERS=,.') ||'</nrctrrpp>'||
                   '<nomeCompleto>' || rw_info.nmprimtl     ||'</nomeCompleto>'||     
                   '<contaCorrente>'|| to_char(pr_nrdconta,'fm9g999g999g0','NLS_NUMERIC_CHARACTERS=,.') ||'</contaCorrente>'||     
                   '<cpf>'          || vr_cpfcgc     ||'</cpf>'||
                   '<valorParcela>' || to_char(vr_vlprerpp,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS=,.') ||'</valorParcela>'||
                   '<identidade>'   || vr_rg                ||'</identidade>'|| 
                   '<postoAtendimento>'||rw_info.cdagenci   ||'</postoAtendimento>'||
                   '<cidade>'       || rw_info.nmcidade     ||'</cidade>'||
                   '<uf>'           || rw_info.cdufdcop     ||'</uf>'||
                   '<dataInicio>'   || to_char(vr_dtmvtolt,'dd/mm/yyyy') ||'</dataInicio>'||
                   '<finalidade>'   || vr_dsfinali     ||'</finalidade>'||
                   '<indice>'       || 'CDI'                ||'</indice>'||
                   '<carencia>'     || '30'                 ||'</carencia>'||
                   '<remuneracao>'     || 'Diária'                 ||'</remuneracao>'||
                   '<quantidadeDiasContrato>'||vr_pzmaxpro / 12||'</quantidadeDiasContrato>'||
                   '<diaDebito>'    || vr_indiadeb     ||'</diaDebito>';    

    gene0002.pc_escreve_xml(pr_xml            => vr_clobxmlc
                            ,pr_texto_completo => vr_xml_temp 
                            ,pr_texto_novo     => vr_texto_novo);
    -- Encerrar a tag raiz 
    gene0002.pc_escreve_xml(pr_xml            => vr_clobxmlc 
                            ,pr_texto_completo => vr_xml_temp 
                            ,pr_texto_novo     => '</raiz>' 
                            ,pr_fecha_xml      => TRUE);
                                 
    pr_retxml := XMLType.createXML(vr_clobxmlc);
    
    --> Gerar log de sucesso
    IF pr_flgerlog = 1 THEN
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                           pr_cdoperad => pr_cdoperad, 
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
                                pr_nmdcampo => 'nrctrrpp', 
                                pr_dsdadant => NULL, 
                                pr_dsdadatu => pr_nrctrrpp);
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
      
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
        
      IF pr_flgerlog = 1 THEN
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                             pr_cdoperad => pr_cdoperad, 
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
                                  pr_nmdcampo => 'nrctrrpp', 
                                  pr_dsdadant => NULL, 
                                  pr_dsdadatu => pr_nrctrrpp);
      END IF;
      
    WHEN OTHERS THEN
      
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := replace(replace('Erro ao gerar impressao do termo de adesao: ' || SQLERRM, chr(13)),chr(10));   
  
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
      IF pr_flgerlog = 1 THEN
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                             pr_cdoperad => pr_cdoperad, 
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
                                  pr_nmdcampo => 'nrctrrpp', 
                                  pr_dsdadant => NULL, 
                                  pr_dsdadatu => pr_nrctrrpp);
      END IF; 
      
  END pc_retorna_texto_termo_adesao;

  PROCEDURE pc_calc_saldo_resgate(pr_cdcooper  IN craprga.cdcooper%TYPE     --> Código da cooperativa
                             ,pr_nrdconta  IN craprga.nrdconta%TYPE     --> Número da conta
                             ,pr_nraplica  IN craprga.nraplica%TYPE     --> Número da aplicação
                             ,pr_vlresgat  IN craprga.vlresgat%TYPE     --> Valor do resgate
                             ,pr_idtiprgt  IN craprga.idtiprgt%TYPE     --> Tipo do resgate 1 - Parcial / 2 - Total
                             ,pr_dtresgat  IN crapdat.dtmvtolt%TYPE     --> Data do resgate
                             ,pr_nrseqrgt  IN craprga.nrseqrgt%TYPE     --> Numero de sequencia do resgate
                             ,pr_idrgtcti  IN craprga.idrgtcti%TYPE     --> Indicador de resgate na conta investimento (0-Nao / 1-Sim)
                 ,pr_vlsldtot OUT NUMBER --> Valor de saldo total
                 ,pr_vlsldrgt OUT NUMBER --> Valor de saldo de resgate
                 ,pr_vlultren OUT NUMBER --> Valor de ultimo rendimento
                 ,pr_vlrentot OUT NUMBER --> Valor de rendimento total
                 ,pr_vlrevers OUT NUMBER --> Valor de reversao
                 ,pr_vlrdirrf OUT NUMBER --> Valor de IRRF
                 ,pr_percirrf OUT NUMBER --> Valor percentual de IRRF
                 ,pr_vlsldttr OUT NUMBER --> Valor de saldo total de resgate
                             ,pr_tpcritic OUT crapcri.cdcritic%TYPE     --> Tipo da crítica (0- Nao aborta Processo/ 1 - Aborta Processo)
                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Código da crítica
                             ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da Critica

    BEGIN
   /* .............................................................................

     Programa: pc_calc_saldo_resgate
     Sistema : Novos Produtos de Captação
     Sigla   : APLI
     Autor   : CIS Corporate
     Data    : Março/19.                    

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Rotina referente a calculo do saldo do resgate de aplicacao.

     Observacao: -----

     Alteracoes:
    ..............................................................................*/
    DECLARE

      -- Variável de críticas
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis de posicao de saldo
      vr_vlbascal NUMBER(20,8) := 0; -- Valor de base de calculo
      vr_auxulren NUMBER(20,8) := 0; -- Valor de ultimo rendimento
      vr_idcalorc NUMBER;

      vr_auxbasca NUMBER(20,8) := 0; -- Valor base calculo auxiliar
      vr_vllanmto NUMBER(20,8) := 0; -- Variavel com valor de lancamento
      vr_vlbasren NUMBER(20,8) := 0; -- Variavel com valor de rendimento

      vr_vlresgat NUMBER(20,8) := pr_vlresgat; -- Variavel com valor de resgate

      vr_dtfimcal DATE;         -- Data de fim de calculo de aplicacao
      vr_dtmvtolt DATE;

      -- Variaveis de carencia
      vr_flgaplca BOOLEAN := FALSE; -- Flag aplicacao esta dentro da carencia
      vr_flgprmap BOOLEAN := FALSE; -- Flag aplicacao esta dentro do primeiro mes
      
      vr_nrdocmto craplci.nrdocmto%TYPE; -- Numero de documento do lancamento

      -- Variaveis de atualizacao de registro de aplicacao
      vr_valresta NUMBER(20,8) := 0;       -- Valor de atualizacao de aplicacao
      vr_datresga DATE         := SYSDATE; -- Data de atualizacao de aplicacao

      -- Cursores

      -- Selecionar dados de carencia de aplicacao
      CURSOR cr_craprac(pr_cdcooper IN craprac.cdcooper%TYPE     --> Código da Cooperativa
                       ,pr_nrdconta IN craprac.nrdconta%TYPE     --> Numero da Conta
                       ,pr_nraplica IN craprac.nraplica%TYPE) IS --> Numero da Aplicacao

      SELECT
        rac.cdcooper, rac.nrdconta,
        rac.nraplica, rac.cdprodut,
        rac.cdnomenc, rac.dtmvtolt,
        rac.dtvencto, rac.dtatlsld,
        rac.vlaplica, rac.vlbasapl,
        rac.vlsldatl, rac.vlslfmes,
        rac.vlsldacu, rac.qtdiacar,
        rac.qtdiaprz, rac.qtdiaapl,
        rac.txaplica, rac.idsaqtot,
        rac.idblqrgt, rac.idcalorc,
        rac.cdoperad, rac.progress_recid,
        rac.iddebcti, rac.vlbasant,
        rac.vlsldant, rac.dtsldant,
        rac.rowid,
        cpc.nmprodut, cpc.idsitpro,
        cpc.cddindex, cpc.idtippro,
        cpc.idtxfixa, cpc.idacumul,
        cpc.cdhscacc, cpc.cdhsvrcc,
        cpc.cdhsraap, cpc.cdhsnrap,
        cpc.cdhsprap, cpc.cdhsrvap,
        cpc.cdhsrdap, cpc.cdhsirap,
        cpc.cdhsrgap, cpc.cdhsvtap
      FROM
        craprac rac,
        crapcpc cpc
      WHERE
        rac.cdcooper = pr_cdcooper AND
        rac.nrdconta = pr_nrdconta AND
        rac.nraplica = pr_nraplica AND
        cpc.cdprodut = rac.cdprodut;

      rw_craprac cr_craprac%ROWTYPE;

      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    BEGIN

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
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- Se for lancamento online data atual, caso contrario pega a proxima data util
      IF pr_dtresgat = rw_crapdat.dtmvtolt THEN
        vr_dtmvtolt := rw_crapdat.dtmvtolt;
      ELSE
        vr_dtmvtolt := rw_crapdat.dtmvtopr;
      END IF;

      -- Consulta registros de aplicaacao
      OPEN cr_craprac(pr_cdcooper => pr_cdcooper   -- Codigo da cooperativa
                     ,pr_nrdconta => pr_nrdconta   -- Numero da conta
                     ,pr_nraplica => pr_nraplica); -- Numero da aplicacao

      FETCH cr_craprac INTO rw_craprac;

      IF cr_craprac%NOTFOUND THEN
         -- Fecha cursor
         CLOSE cr_craprac;

         vr_cdcritic := 426;
         pr_tpcritic := 0;
         -- Executa excecao
         RAISE vr_exc_saida;
      ELSE
        -- Fecha cursor
        CLOSE cr_craprac;
      END IF;

      -- Validar se a aplicação ainda está ativa
      IF rw_craprac.idsaqtot <> 0 THEN
        vr_cdcritic := 0;
         vr_dscritic := 'Aplicacao inativa.';
         pr_tpcritic := 0;
         -- Executa excecao
         RAISE vr_exc_saida;
      END IF;

      -- Validar se a aplicação possui saldo
      IF rw_craprac.vlbasapl <= 0 THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Saldo insuficiente.';
        pr_tpcritic := 0;
        -- Executa excecao
        RAISE vr_exc_saida;
      END IF;

      -- Validar se a aplicação não está bloqueada para resgate
      IF rw_craprac.idblqrgt <> 0 THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Aplicacao bloqueada para resgate.';
        pr_tpcritic := 0;
        -- Executa excecao
        RAISE vr_exc_saida;
      END IF;

      -- Validar se o tipo de resgate é válido (1 - Parcial / 2 - Total)
      IF pr_idtiprgt NOT IN(1,2) THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Tipo de resgate invalido.';
        pr_tpcritic := 0;
        -- Executa excecao
        RAISE vr_exc_saida;
      END IF;

      -- Validar se o valor do resgate é válido quando for parcial
      IF pr_idtiprgt = 1 and pr_vlresgat <= 0 THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Valor de resgate parcial invalido.';
        pr_tpcritic := 0;
        -- Executa excecao
        RAISE vr_exc_saida;
      END IF;

      -- Se for lancamento online data atual, caso contrario pega a proxima data util
      IF pr_dtresgat = rw_crapdat.dtmvtolt THEN
        vr_dtfimcal := rw_crapdat.dtmvtolt;
      ELSE
        vr_dtfimcal := rw_crapdat.dtmvtopr;
      END IF;

      -- Verificar se a aplicação está no período de carência
      IF vr_dtfimcal - rw_craprac.dtmvtolt < rw_craprac.qtdiacar THEN

        vr_flgaplca := TRUE; -- Flag aplicacao esta dentro da carencia

        -- Identificar se a aplicação está no primeiro mês da carência
        IF TRUNC(rw_craprac.dtmvtolt,'mm') = TRUNC(vr_dtfimcal,'mm') THEN

          vr_flgprmap := TRUE; -- Flag aplicacao esta dentro do primeiro mes

          -- Zera valor de base de calculo
          vr_vlbascal := 0;

          -- Verifica o tipo de aplicacao PRE ou POS
          IF rw_craprac.idtippro = 1  THEN -- Pré-Fixada
            apli0006.pc_posicao_saldo_aplicacao_pre(pr_cdcooper => rw_craprac.cdcooper
                                                   ,pr_nrdconta => rw_craprac.nrdconta
                                                   ,pr_nraplica => rw_craprac.nraplica
                                                   ,pr_dtiniapl => rw_craprac.dtmvtolt
                                                   ,pr_txaplica => rw_craprac.txaplica
                                                   ,pr_idtxfixa => rw_craprac.idtxfixa
                                                   ,pr_cddindex => rw_craprac.cddindex
                                                   ,pr_qtdiacar => rw_craprac.qtdiacar
                                                   ,pr_idgravir => 0
                                                   ,pr_dtinical => rw_craprac.dtmvtolt
                                                   ,pr_dtfimcal => vr_dtfimcal
                                                   ,pr_idtipbas => 2
                                                   ,pr_vlbascal => vr_vlbascal
                                                   ,pr_vlsldtot => pr_vlsldtot
                                                   ,pr_vlsldrgt => pr_vlsldrgt
                                                   ,pr_vlultren => pr_vlultren
                                                   ,pr_vlrentot => pr_vlrentot
                                                   ,pr_vlrevers => pr_vlrevers
                                                   ,pr_vlrdirrf => pr_vlrdirrf
                                                   ,pr_percirrf => pr_percirrf
                                                   ,pr_cdcritic => vr_cdcritic
                                                   ,pr_dscritic => vr_dscritic);

            -- Verifica se houve critica no processamento
            IF vr_dscritic IS NOT NULL OR
               NVL(vr_cdcritic,0) <> 0 THEN
              -- Executa excecao
              pr_tpcritic := 1;
              RAISE vr_exc_saida;
            END IF;
          ELSIF rw_craprac.idtippro = 2  THEN -- Pós-Fixada
            apli0006.pc_posicao_saldo_aplicacao_pos(pr_cdcooper => rw_craprac.cdcooper
                                                   ,pr_nrdconta => rw_craprac.nrdconta
                                                   ,pr_nraplica => rw_craprac.nraplica
                                                   ,pr_dtiniapl => rw_craprac.dtmvtolt
                                                   ,pr_txaplica => rw_craprac.txaplica
                                                   ,pr_idtxfixa => rw_craprac.idtxfixa
                                                   ,pr_cddindex => rw_craprac.cddindex
                                                   ,pr_qtdiacar => rw_craprac.qtdiacar
                                                   ,pr_idgravir => 0
                                                   ,pr_dtinical => rw_craprac.dtmvtolt
                                                   ,pr_dtfimcal => vr_dtfimcal
                                                   ,pr_idtipbas => 2
                                                   ,pr_vlbascal => vr_vlbascal
                                                   ,pr_vlsldtot => pr_vlsldtot
                                                   ,pr_vlsldrgt => pr_vlsldrgt
                                                   ,pr_vlultren => pr_vlultren
                                                   ,pr_vlrentot => pr_vlrentot
                                                   ,pr_vlrevers => pr_vlrevers
                                                   ,pr_vlrdirrf => pr_vlrdirrf
                                                   ,pr_percirrf => pr_percirrf
                                                   ,pr_cdcritic => vr_cdcritic
                                                   ,pr_dscritic => vr_dscritic);

            -- Verifica se houve critica no processamento
            IF vr_dscritic IS NOT NULL OR
               NVL(vr_cdcritic,0) <> 0 THEN
              -- Executa excecao
              pr_tpcritic := 1;
              RAISE vr_exc_saida;
            END IF;
          END IF;

           -- Verifica saldo
           IF pr_vlsldrgt >= pr_vlresgat THEN

             IF pr_idtiprgt = 1 THEN -- Parcial
               pr_vlsldrgt := pr_vlresgat;
               vr_vlbasren := pr_vlresgat;
             ELSIF pr_idtiprgt = 2 THEN -- Total
               vr_vllanmto := pr_vlsldrgt;
               vr_vlbasren := rw_craprac.vlbasapl;
             END IF;

           ELSE -- Total
               vr_vllanmto := pr_vlsldrgt;
               vr_vlbasren := rw_craprac.vlbasapl;
           END IF;
	  pr_vlsldttr := pr_vlsldrgt;

        ELSE -- Resgate após primeiro mês da carência

          vr_flgprmap := FALSE; -- Flag aplicacao esta dentro do primeiro mes

          -- Zera valor de base de calculo
          vr_vlbascal := 0;
          vr_vlbasren := 0;
          -- Verifica o tipo de aplicacao PRE ou POS
          IF rw_craprac.idtippro = 1  THEN -- Pré-Fixada
            apli0006.pc_posicao_saldo_aplicacao_pre(pr_cdcooper => rw_craprac.cdcooper
                                                   ,pr_nrdconta => rw_craprac.nrdconta
                                                   ,pr_nraplica => rw_craprac.nraplica
                                                   ,pr_dtiniapl => rw_craprac.dtmvtolt
                                                   ,pr_txaplica => rw_craprac.txaplica
                                                   ,pr_idtxfixa => rw_craprac.idtxfixa
                                                   ,pr_cddindex => rw_craprac.cddindex
                                                   ,pr_qtdiacar => rw_craprac.qtdiacar
                                                   ,pr_idgravir => 0
                                                   ,pr_dtinical => rw_craprac.dtmvtolt
                                                   ,pr_dtfimcal => vr_dtfimcal
                                                   ,pr_idtipbas => 2
                                                   ,pr_vlbascal => vr_vlbascal
                                                   ,pr_vlsldtot => pr_vlsldtot
                                                   ,pr_vlsldrgt => pr_vlsldrgt
                                                   ,pr_vlultren => pr_vlultren
                                                   ,pr_vlrentot => pr_vlrentot
                                                   ,pr_vlrevers => pr_vlrevers
                                                   ,pr_vlrdirrf => pr_vlrdirrf
                                                   ,pr_percirrf => pr_percirrf
                                                   ,pr_cdcritic => vr_cdcritic
                                                   ,pr_dscritic => vr_dscritic);

             -- Verifica se houve critica no processamento
             IF vr_dscritic IS NOT NULL OR
               NVL(vr_cdcritic,0) <> 0 THEN
               -- Executa excecao
               pr_tpcritic := 1;
               RAISE vr_exc_saida;
             END IF;
           ELSIF rw_craprac.idtippro = 2  THEN -- Pós-Fixada
             apli0006.pc_posicao_saldo_aplicacao_pos(pr_cdcooper => rw_craprac.cdcooper
                                                    ,pr_nrdconta => rw_craprac.nrdconta
                                                    ,pr_nraplica => rw_craprac.nraplica
                                                    ,pr_dtiniapl => rw_craprac.dtmvtolt
                                                    ,pr_txaplica => rw_craprac.txaplica
                                                    ,pr_idtxfixa => rw_craprac.idtxfixa
                                                    ,pr_cddindex => rw_craprac.cddindex
                                                    ,pr_qtdiacar => rw_craprac.qtdiacar
                                                    ,pr_idgravir => 0
                                                    ,pr_dtinical => rw_craprac.dtmvtolt
                                                    ,pr_dtfimcal => vr_dtfimcal
                                                    ,pr_idtipbas => 2
                                                    ,pr_vlbascal => vr_vlbascal
                                                    ,pr_vlsldtot => pr_vlsldtot
                                                    ,pr_vlsldrgt => pr_vlsldrgt
                                                    ,pr_vlultren => pr_vlultren
                                                    ,pr_vlrentot => pr_vlrentot
                                                    ,pr_vlrevers => pr_vlrevers
                                                    ,pr_vlrdirrf => pr_vlrdirrf
                                                    ,pr_percirrf => pr_percirrf
                                                    ,pr_cdcritic => vr_cdcritic
                                                    ,pr_dscritic => vr_dscritic);
             -- Verifica se houve critica no processamento
             IF vr_dscritic IS NOT NULL OR
               NVL(vr_cdcritic,0) <> 0 THEN
               -- Executa excecao
               pr_tpcritic := 1;
               RAISE vr_exc_saida;
             END IF;

           END IF; -- Fim verificacao tipo de aplicacao

           -- Verifica se saldo é suficiente
           IF pr_vlsldrgt >= pr_vlresgat THEN

             -- Verifica tipo de resgate
             IF pr_idtiprgt = 1 THEN -- Parcial
               -- Valor do resgate
               vr_vlbascal := pr_vlresgat;

               -- Reversao de valor provisionado proporcional
               -- Verifica o tipo de aplicacao PRE ou POS
               IF rw_craprac.idtippro = 1  THEN -- Pré-Fixada
                 apli0006.pc_posicao_saldo_aplicacao_pre(pr_cdcooper => rw_craprac.cdcooper
                                                        ,pr_nrdconta => rw_craprac.nrdconta
                                                        ,pr_nraplica => rw_craprac.nraplica
                                                        ,pr_dtiniapl => rw_craprac.dtmvtolt
                                                        ,pr_txaplica => rw_craprac.txaplica
                                                        ,pr_idtxfixa => rw_craprac.idtxfixa
                                                        ,pr_cddindex => rw_craprac.cddindex
                                                        ,pr_qtdiacar => rw_craprac.qtdiacar
                                                        ,pr_idgravir => 0
                                                        ,pr_dtinical => rw_craprac.dtmvtolt
                                                        ,pr_dtfimcal => vr_dtfimcal
                                                        ,pr_idtipbas => pr_idtiprgt
                                                        ,pr_vlbascal => vr_vlbascal
                                                        ,pr_vlsldtot => pr_vlsldtot
                                                        ,pr_vlsldrgt => pr_vlsldrgt
                                                        ,pr_vlultren => vr_auxulren
                                                        ,pr_vlrentot => pr_vlrentot
                                                        ,pr_vlrevers => pr_vlrevers
                                                        ,pr_vlrdirrf => pr_vlrdirrf
                                                        ,pr_percirrf => pr_percirrf
                                                        ,pr_cdcritic => vr_cdcritic
                                                        ,pr_dscritic => vr_dscritic);

                 -- Verifica se houve critica no processamento
                 IF vr_dscritic IS NOT NULL OR
                    NVL(vr_cdcritic,0) <> 0 THEN
                   -- Executa excecao
                   pr_tpcritic := 1;
                   RAISE vr_exc_saida;
                 END IF;
               ELSIF rw_craprac.idtippro = 2  THEN -- Pós-Fixada
                 apli0006.pc_posicao_saldo_aplicacao_pos(pr_cdcooper => rw_craprac.cdcooper
                                                        ,pr_nrdconta => rw_craprac.nrdconta
                                                        ,pr_nraplica => rw_craprac.nraplica
                                                        ,pr_dtiniapl => rw_craprac.dtmvtolt
                                                        ,pr_txaplica => rw_craprac.txaplica
                                                        ,pr_idtxfixa => rw_craprac.idtxfixa
                                                        ,pr_cddindex => rw_craprac.cddindex
                                                        ,pr_qtdiacar => rw_craprac.qtdiacar
                                                        ,pr_idgravir => 0
                                                        ,pr_dtinical => rw_craprac.dtmvtolt
                                                        ,pr_dtfimcal => vr_dtfimcal
                                                        ,pr_idtipbas => pr_idtiprgt
                                                        ,pr_vlbascal => vr_vlbascal
                                                        ,pr_vlsldtot => pr_vlsldtot
                                                        ,pr_vlsldrgt => pr_vlsldrgt
                                                        ,pr_vlultren => vr_auxulren
                                                        ,pr_vlrentot => pr_vlrentot
                                                        ,pr_vlrevers => pr_vlrevers
                                                        ,pr_vlrdirrf => pr_vlrdirrf
                                                        ,pr_percirrf => pr_percirrf
                                                        ,pr_cdcritic => vr_cdcritic
                                                        ,pr_dscritic => vr_dscritic);
                 -- Verifica se houve critica no processamento
                 IF vr_dscritic IS NOT NULL OR
                    NVL(vr_cdcritic,0) <> 0 THEN
                   -- Executa excecao
                   pr_tpcritic := 1;
                   RAISE vr_exc_saida;
                 END IF;

               END IF; -- Fim verificacao tipo de aplicacao
               vr_vlbasren := vr_vlbascal;
               pr_vlsldrgt := pr_vlresgat; -- Valor para lancamento do resgate

             ELSIF pr_idtiprgt = 2 THEN -- Total
               vr_vlbasren := rw_craprac.vlbasapl;
             END IF; -- Fim verificacao tipo de aplicacao
           ELSE  -- Total
               vr_vlbasren := rw_craprac.vlbasapl;
           END IF;
	  pr_vlsldttr := pr_vlsldrgt;

        END IF; -- Fim mes de carencia

      ELSE -- Efetivacao de resgate apos carencia

        vr_flgaplca := FALSE; -- Flag aplicacao esta dentro da carencia
        vr_vlbascal := 0;

        -- Verifica tipo de resgate 1 - Parcial / 2 - Total
        IF pr_idtiprgt = 1 THEN -- Resgate Parcial

          -- Verifica o tipo de aplicacao PRE ou POS
          IF rw_craprac.idtippro = 1  THEN -- Pré-Fixada
            apli0006.pc_posicao_saldo_aplicacao_pre(pr_cdcooper => rw_craprac.cdcooper
                                                   ,pr_nrdconta => rw_craprac.nrdconta
                                                   ,pr_nraplica => rw_craprac.nraplica
                                                   ,pr_dtiniapl => rw_craprac.dtmvtolt
                                                   ,pr_txaplica => rw_craprac.txaplica
                                                   ,pr_idtxfixa => rw_craprac.idtxfixa
                                                   ,pr_cddindex => rw_craprac.cddindex
                                                   ,pr_qtdiacar => rw_craprac.qtdiacar
                                                   ,pr_idgravir => 0
                                                   ,pr_dtinical => rw_craprac.dtmvtolt
                                                   ,pr_dtfimcal => vr_dtfimcal
                                                   ,pr_idtipbas => 2
                                                   ,pr_vlbascal => vr_vlbascal
                                                   ,pr_vlsldtot => pr_vlsldtot
                                                   ,pr_vlsldrgt => pr_vlsldrgt
                                                   ,pr_vlultren => pr_vlultren
                                                   ,pr_vlrentot => pr_vlrentot
                                                   ,pr_vlrevers => pr_vlrevers
                                                   ,pr_vlrdirrf => pr_vlrdirrf
                                                   ,pr_percirrf => pr_percirrf
                                                   ,pr_cdcritic => vr_cdcritic
                                                   ,pr_dscritic => vr_dscritic);

            -- Verifica se houve critica no processamento
            IF vr_dscritic IS NOT NULL OR
               NVL(vr_cdcritic,0) <> 0 THEN
              -- Executa excecao
              pr_tpcritic := 1;
              RAISE vr_exc_saida;
            END IF;
          ELSIF rw_craprac.idtippro = 2  THEN -- Pós-Fixada
            apli0006.pc_posicao_saldo_aplicacao_pos(pr_cdcooper => rw_craprac.cdcooper
                                                   ,pr_nrdconta => rw_craprac.nrdconta
                                                   ,pr_nraplica => rw_craprac.nraplica
                                                   ,pr_dtiniapl => rw_craprac.dtmvtolt
                                                   ,pr_txaplica => rw_craprac.txaplica
                                                   ,pr_idtxfixa => rw_craprac.idtxfixa
                                                   ,pr_cddindex => rw_craprac.cddindex
                                                   ,pr_qtdiacar => rw_craprac.qtdiacar
                                                   ,pr_idgravir => 0
                                                   ,pr_dtinical => rw_craprac.dtmvtolt
                                                   ,pr_dtfimcal => vr_dtfimcal
                                                   ,pr_idtipbas => 2
                                                   ,pr_vlbascal => vr_vlbascal
                                                   ,pr_vlsldtot => pr_vlsldtot
                                                   ,pr_vlsldrgt => pr_vlsldrgt
                                                   ,pr_vlultren => pr_vlultren
                                                   ,pr_vlrentot => pr_vlrentot
                                                   ,pr_vlrevers => pr_vlrevers
                                                   ,pr_vlrdirrf => pr_vlrdirrf
                                                   ,pr_percirrf => pr_percirrf
                                                   ,pr_cdcritic => vr_cdcritic
                                                   ,pr_dscritic => vr_dscritic);

            -- Verifica se houve critica no processamento
            IF vr_dscritic IS NOT NULL OR
               NVL(vr_cdcritic,0) <> 0 THEN
              -- Executa excecao
              pr_tpcritic := 1;
              RAISE vr_exc_saida;
            END IF;

          END IF; -- Fim verificacao tipo de aplicacao
      
      pr_vlsldttr := pr_vlsldrgt;
          IF pr_vlsldrgt < pr_vlresgat THEN
              vr_vlresgat := pr_vlsldrgt;
                -- Valor de base de calculo
              vr_vlbascal := 0;
              GOTO resgate_total;
          END IF;
          -- Verifica se saldo é suficiente
          IF pr_vlsldrgt >= vr_vlresgat THEN

            pr_vlrentot := 0;
            vr_vlbasren := 0;
  
            -- Verifica tipo da aplicacao para retornar valor de reversao
  
            -- Calcula valor de base de calculo para resgate
            apli0006.pc_valor_base_resgate(pr_cdcooper => rw_craprac.cdcooper, --> Código da Cooperativa
                                           pr_nrdconta => rw_craprac.nrdconta, --> Conta do Cooperado
                                           pr_idtippro => rw_craprac.idtippro, --> Tipo do Produto da Aplicação
                                           pr_txaplica => rw_craprac.txaplica, --> Taxa da Aplicação
                                           pr_idtxfixa => rw_craprac.idtxfixa, --> Taxa Fixa (1-SIM/2-NAO)
                                           pr_cddindex => rw_craprac.cddindex, --> Código do Indexador
                                           pr_dtinical => rw_craprac.dtmvtolt, --> Data Inicial Cálculo (Fixo na chamada)
                                           pr_dtfimcal => vr_dtfimcal,         --> Data Final Cálculo (Fixo na chamada)
                                           pr_dtmvtolt => rw_crapdat.dtmvtolt, --> Data de Movimento
                                           pr_vlresgat => vr_vlresgat,         --> Valor do Resgate
                                           pr_percirrf => pr_percirrf,         --> Percentual de IRRF
                                           pr_vlbasrgt => vr_vlbascal,         --> Valor Base do Resgate
                                           pr_cdcritic => vr_cdcritic,         --> Código da crítica
                                           pr_dscritic => vr_dscritic);        --> Descrição da crítica
  
            -- Verifica se houve critica no processamento
            IF vr_dscritic IS NOT NULL OR
               NVL(vr_cdcritic,0) <> 0 THEN
              -- Executa excecao
              pr_tpcritic := 1;
              RAISE vr_exc_saida;
            END IF;
  
            -- Valor de base para calculo
            vr_auxbasca := vr_vlbascal;
  
            -- Verifica o tipo de aplicacao PRE ou POS
            IF rw_craprac.idtippro = 1  THEN -- Pré-Fixada
              apli0006.pc_posicao_saldo_aplicacao_pre(pr_cdcooper => rw_craprac.cdcooper
                                                     ,pr_nrdconta => rw_craprac.nrdconta
                                                     ,pr_nraplica => rw_craprac.nraplica
                                                     ,pr_dtiniapl => rw_craprac.dtmvtolt
                                                     ,pr_txaplica => rw_craprac.txaplica
                                                     ,pr_idtxfixa => rw_craprac.idtxfixa
                                                     ,pr_cddindex => rw_craprac.cddindex
                                                     ,pr_qtdiacar => rw_craprac.qtdiacar
                                                     ,pr_idgravir => 1
                                                     ,pr_dtinical => rw_craprac.dtmvtolt
                                                     ,pr_dtfimcal => vr_dtfimcal
                                                     ,pr_idtipbas => pr_idtiprgt
                                                     ,pr_vlbascal => vr_auxbasca
                                                     ,pr_vlsldtot => pr_vlsldtot
                                                     ,pr_vlsldrgt => pr_vlsldrgt
                                                     ,pr_vlultren => vr_auxulren
                                                     ,pr_vlrentot => pr_vlrentot
                                                     ,pr_vlrevers => pr_vlrevers
                                                     ,pr_vlrdirrf => pr_vlrdirrf
                                                     ,pr_percirrf => pr_percirrf
                                                     ,pr_cdcritic => vr_cdcritic
                                                     ,pr_dscritic => vr_dscritic);
  
              -- Verifica se houve critica no processamento
              IF vr_dscritic IS NOT NULL OR
                 NVL(vr_cdcritic,0) <> 0 THEN
                -- Executa excecao
                pr_tpcritic := 1;
                RAISE vr_exc_saida;
              END IF;
            ELSIF rw_craprac.idtippro = 2  THEN -- Pós-Fixada
              apli0006.pc_posicao_saldo_aplicacao_pos(pr_cdcooper => rw_craprac.cdcooper
                                                     ,pr_nrdconta => rw_craprac.nrdconta
                                                     ,pr_nraplica => rw_craprac.nraplica
                                                     ,pr_dtiniapl => rw_craprac.dtmvtolt
                                                     ,pr_txaplica => rw_craprac.txaplica
                                                     ,pr_idtxfixa => rw_craprac.idtxfixa
                                                     ,pr_cddindex => rw_craprac.cddindex
                                                     ,pr_qtdiacar => rw_craprac.qtdiacar
                                                     ,pr_idgravir => 1
                                                     ,pr_dtinical => rw_craprac.dtmvtolt
                                                     ,pr_dtfimcal => vr_dtfimcal
                                                     ,pr_idtipbas => pr_idtiprgt
                                                     ,pr_vlbascal => vr_auxbasca
                                                     ,pr_vlsldtot => pr_vlsldtot
                                                     ,pr_vlsldrgt => pr_vlsldrgt
                                                     ,pr_vlultren => vr_auxulren
                                                     ,pr_vlrentot => pr_vlrentot
                                                     ,pr_vlrevers => pr_vlrevers
                                                     ,pr_vlrdirrf => pr_vlrdirrf
                                                     ,pr_percirrf => pr_percirrf
                                                     ,pr_cdcritic => vr_cdcritic
                                                     ,pr_dscritic => vr_dscritic);
  
              -- Verifica se houve critica no processamento
              IF vr_dscritic IS NOT NULL OR
                 NVL(vr_cdcritic,0) <> 0 THEN
                -- Executa excecao
                pr_tpcritic := 1;
                RAISE vr_exc_saida;
              END IF;
  
            END IF; -- Fim verificacao tipo de aplicacao
  
            vr_vlbasren := vr_vlbascal;
            pr_vlsldrgt := vr_vlresgat; -- Valor de lancamento do resgate
  
          ELSE
             pr_tpcritic := 0;
             vr_cdcritic := 203;
             vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
             RAISE vr_exc_saida;
          END IF;  -- Fim Verifica saldo

        ELSIF pr_idtiprgt = 2 THEN -- Resgate Total

          -- Valor de base de calculo
          vr_vlbascal := 0;
          GOTO resgate_total;






        END IF;

      END IF; -- Fim verificacao periodo de carencia

      <<resgate_total>>
          -- Verifica o tipo de aplicacao PRE ou POS
          IF rw_craprac.idtippro = 1  THEN -- Pré-Fixada
            apli0006.pc_posicao_saldo_aplicacao_pre(pr_cdcooper => rw_craprac.cdcooper
                                                   ,pr_nrdconta => rw_craprac.nrdconta
                                                   ,pr_nraplica => rw_craprac.nraplica
                                                   ,pr_dtiniapl => rw_craprac.dtmvtolt
                                                   ,pr_txaplica => rw_craprac.txaplica
                                                   ,pr_idtxfixa => rw_craprac.idtxfixa
                                                   ,pr_cddindex => rw_craprac.cddindex
                                                   ,pr_qtdiacar => rw_craprac.qtdiacar
                                                   ,pr_idgravir => 1
                                                   ,pr_dtinical => rw_craprac.dtmvtolt
                                                   ,pr_dtfimcal => vr_dtfimcal
                                                   ,pr_idtipbas => 2
                                                   ,pr_vlbascal => vr_vlbascal
                                                   ,pr_vlsldtot => pr_vlsldtot
                                                   ,pr_vlsldrgt => pr_vlsldrgt
                                                   ,pr_vlultren => pr_vlultren
                                                   ,pr_vlrentot => pr_vlrentot
                                                   ,pr_vlrevers => pr_vlrevers
                                                   ,pr_vlrdirrf => pr_vlrdirrf
                                                   ,pr_percirrf => pr_percirrf
                                                   ,pr_cdcritic => vr_cdcritic
                                                   ,pr_dscritic => vr_dscritic);
            -- Verifica se houve critica no processamento
            IF vr_dscritic IS NOT NULL OR
               NVL(vr_cdcritic,0) <> 0 THEN
              -- Executa excecao
              pr_tpcritic := 1;
              RAISE vr_exc_saida;
            END IF;
          ELSIF rw_craprac.idtippro = 2  THEN -- Pós-Fixada
            apli0006.pc_posicao_saldo_aplicacao_pos(pr_cdcooper => rw_craprac.cdcooper
                                                   ,pr_nrdconta => rw_craprac.nrdconta
                                                   ,pr_nraplica => rw_craprac.nraplica
                                                   ,pr_dtiniapl => rw_craprac.dtmvtolt
                                                   ,pr_txaplica => rw_craprac.txaplica
                                                   ,pr_idtxfixa => rw_craprac.idtxfixa
                                                   ,pr_cddindex => rw_craprac.cddindex
                                                   ,pr_qtdiacar => rw_craprac.qtdiacar
                                                   ,pr_idgravir => 1
                                                   ,pr_dtinical => rw_craprac.dtmvtolt
                                                   ,pr_dtfimcal => vr_dtfimcal
                                                   ,pr_idtipbas => 2
                                                   ,pr_vlbascal => vr_vlbascal
                                                   ,pr_vlsldtot => pr_vlsldtot
                                                   ,pr_vlsldrgt => pr_vlsldrgt
                                                   ,pr_vlultren => pr_vlultren
                                                   ,pr_vlrentot => pr_vlrentot
                                                   ,pr_vlrevers => pr_vlrevers
                                                   ,pr_vlrdirrf => pr_vlrdirrf
                                                   ,pr_percirrf => pr_percirrf
                                                   ,pr_cdcritic => vr_cdcritic
                                                   ,pr_dscritic => vr_dscritic);
            -- Verifica se houve critica no processamento
            IF vr_dscritic IS NOT NULL OR
               NVL(vr_cdcritic,0) <> 0 THEN
              -- Executa excecao
              pr_tpcritic := 1;
              RAISE vr_exc_saida;
            END IF;
          END IF; -- Fim verificacao tipo de aplicacao
      pr_vlsldttr := pr_vlsldrgt;
          vr_vlbasren := rw_craprac.vlbasapl;

    EXCEPTION
      WHEN vr_exc_saida THEN
        IF vr_cdcritic <> 0 AND TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN

        pr_tpcritic := 1;
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro nao tratado no resgate de aplicacoes APLI0008.pc_calc_saldo_resgate: ' || SQLERRM;
    END;

  END pc_calc_saldo_resgate;
  
  PROCEDURE pc_buscar_sld_rgt_apl_prog (pr_cdcooper IN craprac.cdcooper%TYPE                  -- Código da Cooperativa
                                       ,pr_cdoperad IN crapope.cdoperad%TYPE                  -- Código do Operador 
                                       ,pr_nmdatela IN craptel.nmdatela%TYPE                  -- Nome da Tela
                                       ,pr_idorigem IN NUMBER                                 -- Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA                  
                                       ,pr_nrdconta IN craprac.nrdconta%TYPE                  -- Número da Conta
                                       ,pr_idseqttl IN crapttl.idseqttl%TYPE                  -- Titular da Conta
                                       ,pr_nrctrrpp IN craprac.nrctrrpp%TYPE                  -- Número da Aplicação Programada
                                       ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE                  -- Data de Movimento
                               ,pr_vlresgat  IN craprga.vlresgat%TYPE     --> Valor do resgate
                               ,pr_idtiprgt  IN craprga.idtiprgt%TYPE     --> Tipo do resgate 1 - Parcial / 2 - Total
                               ,pr_dtresgat  IN crapdat.dtmvtolt%TYPE     --> Data do resgate
                                       ,pr_tab_saldo_rpp OUT typ_tab_saldo_rpp                -- PLTable com os detalhes;
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE                 -- Código da crítica
                                       ,pr_dscritic OUT crapcri.dscritic%TYPE)                 -- Descrição da crítica
   IS  
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_buscar_sld_rgt_apl_prog
    --  Sistema  : Captação (Aplicação Programada)
    --  Sigla    : CRED
    --  Autor    : CIS Corporate
    --  Data     : Setembro/2018.                   Ultima atualizacao: 
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: ----
    -- Objetivo  : Consulta o saldo para resgate da aplicação programada + resgate no momento
    --
    -- Alteracoes:
    -- 
    ---------------------------------------------------------------------------------------------------------------
   BEGIN
    DECLARE
      -- Constantes
      vr_dstransa VARCHAR2(100);
      vr_cdcritic PLS_INTEGER;
      vr_dscritic VARCHAR2(100);
      vr_tpcritic crapcri.cdcritic%TYPE;
      
      -- Variaveis auxiliares
      vr_exc_saida EXCEPTION; 
      vr_nrdrowid rowid;
      vr_tab_erro gene0001.typ_tab_erro;

      vr_dstextab_apli  craptab.dstextab%TYPE;
      vr_percenir       NUMBER;
      
      vr_nrseqrgt       INTEGER := 0;
      
      vr_tpresgate_apl  INTEGER := 0;
      vr_vlrtotresgate_apl   NUMBER := 0;
      vr_vlresgat_apl   NUMBER := 0;
      vr_vlresgat_acu   NUMBER := 0;
      vr_flgfimresga    BOOLEAN := FALSE;
      
      vr_vlrgappr NUMBER(25,2):= 0;
      vr_vlsdappr NUMBER(25,2):= 0;

      vr_dtmvtopr       DATE := pr_dtmvtolt; -- data da operação deve ser igual a do movimento para que o crédito seja efetivado no mesmo dia

      vr_vlsldtot NUMBER(20,8) := 0; --> Valor de saldo total
      vr_vlsldrgt NUMBER(20,8) := 0; --> Valor de saldo de resgate
      vr_vlultren NUMBER(20,8) := 0; --> Valor de ultimo rendimento
      vr_vlrentot NUMBER(20,8) := 0; --> Valor de rendimento total
      vr_vlrevers NUMBER(20,8) := 0; --> Valor de reversao
      vr_vlrdirrf NUMBER(20,8) := 0; --> Valor de IRRF
      vr_percirrf NUMBER(20,8) := 0; --> Valor percentual de IRRF
      vr_vlsldttr NUMBER(20,8) := 0; --> Valor de saldo total de resgate
      
      -- Variaveis Erro
      vr_des_erro VARCHAR2(1000);

      --Variaveis de Indice para tabela memoria
      vr_index_tab     NUMBER;

      -- Cursores
      -- Selecionar dados de aplicacao
      CURSOR cr_craprac (pr_cdcooper craplrg.cdcooper%TYPE
                        ,pr_nrdconta craprac.nrdconta%TYPE
                        ,pr_nrctrrpp craprac.nrctrrpp%TYPE) IS
        SELECT
        rac.cdcooper, rac.nrdconta,
        rac.nraplica, rac.cdprodut,
        rac.cdnomenc, rac.dtmvtolt,
        rac.dtvencto, rac.dtatlsld,
        rac.vlaplica, rac.vlbasapl,
        rac.vlsldatl, rac.vlslfmes,
        rac.vlsldacu, rac.qtdiacar,
        rac.qtdiaprz, rac.qtdiaapl,
        rac.txaplica, rac.idsaqtot,
        rac.idblqrgt, rac.idcalorc,
        rac.cdoperad, rac.progress_recid,
        rac.iddebcti, rac.vlbasant,
        rac.vlsldant, rac.dtsldant,
        rac.rowid,
        cpc.nmprodut, cpc.idsitpro,
        cpc.cddindex, cpc.idtippro,
        cpc.idtxfixa, cpc.idacumul,
        cpc.cdhscacc, cpc.cdhsvrcc,
        cpc.cdhsraap, cpc.cdhsnrap, 
        cpc.cdhsprap, cpc.cdhsrvap,
        cpc.cdhsrdap, cpc.cdhsirap,
        cpc.cdhsrgap, cpc.cdhsvtap
        FROM 
        craprac rac,
        crapcpc cpc 
        WHERE
        rac.cdcooper = pr_cdcooper  AND
        rac.nrdconta = pr_nrdconta AND
        rac.nrctrrpp = pr_nrctrrpp AND
        cpc.cdprodut = rac.cdprodut AND
        rac.idsaqtot = 0
        ORDER BY 
        rac.nraplica;
        
        rw_craprac     cr_craprac%rowtype;

    BEGIN
        vr_nrseqrgt := 100;
        vr_vlrtotresgate_apl := 0;
        vr_vlresgat_acu := 0;
        vr_flgfimresga := FALSE;       
        vr_vlresgat_apl := pr_vlresgat;
        
        BEGIN
             -- Buscar aplicações para os resgates solicitados.
             FOR rw_craprac IN cr_craprac (pr_cdcooper => pr_cdcooper
                                          ,pr_nrdconta => pr_nrdconta
                                          ,pr_nrctrrpp => pr_nrctrrpp) LOOP
                 vr_vlsldrgt := 0;
                 vr_vlsldtot := 0;
                 vr_vlsldttr := 0;
         vr_tpresgate_apl := 1;
              vr_nrseqrgt := vr_nrseqrgt + 1;

                 pc_calc_saldo_resgate (pr_cdcooper => pr_cdcooper
                                                    ,pr_nrdconta => rw_craprac.nrdconta
                                                    ,pr_nraplica => rw_craprac.nraplica
                                                    ,pr_vlresgat => vr_vlresgat_apl
                                                    ,pr_idtiprgt => vr_tpresgate_apl
                                                    ,pr_dtresgat => pr_dtresgat
                                                    ,pr_nrseqrgt => 0
                                                    ,pr_idrgtcti => 0
                                                    ,pr_vlsldtot => vr_vlsldtot 
                                                    ,pr_vlsldrgt => vr_vlsldrgt
                                                    ,pr_vlultren => vr_vlultren 
                                                    ,pr_vlrentot => vr_vlrentot
                                                    ,pr_vlrevers => vr_vlrevers 
                                                    ,pr_vlrdirrf => vr_vlrdirrf
                                                    ,pr_percirrf => vr_percirrf
                                                    ,pr_vlsldttr => vr_vlsldttr
                                                    ,pr_tpcritic => vr_tpcritic
                                                    ,pr_cdcritic => vr_cdcritic
                                                    ,pr_dscritic => vr_dscritic);

                 -- Se encontrar erros na execucão
                 IF vr_dscritic is not null THEN
                    RAISE vr_exc_saida;
                 END IF;

                 vr_vlrtotresgate_apl := vr_vlrtotresgate_apl + vr_vlsldrgt;
                 
                 IF (pr_idtiprgt = 1) THEN
                    IF (pr_vlresgat > vr_vlrtotresgate_apl) THEN
                        vr_tpresgate_apl := 2;
                    ELSIF (pr_vlresgat = vr_vlrtotresgate_apl) THEN
                               vr_tpresgate_apl := 2;
                           vr_flgfimresga := TRUE;
                    ELSE
                        vr_vlresgat_apl := pr_vlresgat - vr_vlresgat_acu;    
                        vr_flgfimresga := TRUE;
                    END IF;
                  ELSE
                    vr_tpresgate_apl := 2;
                  END IF;

                  vr_vlresgat_acu := vr_vlresgat_acu + vr_vlresgat_apl;

                    --Encontrar o proximo indice para a tabela
                    vr_index_tab:= pr_tab_saldo_rpp.Count+1;
                    --Atualizar informacoes na tabela de memoria
                    pr_tab_saldo_rpp(vr_index_tab).vlsldtot:= vr_vlsldtot;
                    pr_tab_saldo_rpp(vr_index_tab).vlsldrgt:= vr_vlsldrgt;
                    pr_tab_saldo_rpp(vr_index_tab).vlultren:= vr_vlultren;
                    pr_tab_saldo_rpp(vr_index_tab).vlrentot:= vr_vlrentot;
                    pr_tab_saldo_rpp(vr_index_tab).vlrevers:= vr_vlrevers;
                    pr_tab_saldo_rpp(vr_index_tab).vlrdirrf:= vr_vlrdirrf;
                    pr_tab_saldo_rpp(vr_index_tab).percirrf:= vr_percirrf;
                    pr_tab_saldo_rpp(vr_index_tab).nraplica:= rw_craprac.nraplica;
                    pr_tab_saldo_rpp(vr_index_tab).vlaplica:= rw_craprac.vlaplica;
                    pr_tab_saldo_rpp(vr_index_tab).tpresgat:= vr_tpresgate_apl;
                    pr_tab_saldo_rpp(vr_index_tab).dtvencto:= rw_craprac.dtvencto;
                    pr_tab_saldo_rpp(vr_index_tab).dtcarenc:= rw_craprac.dtmvtolt + rw_craprac.qtdiacar;
                    pr_tab_saldo_rpp(vr_index_tab).qtdiacar:= rw_craprac.qtdiacar;

                  IF (vr_flgfimresga) THEN
                     EXIT;
                  END IF;
             END LOOP; -- fim loop rac
        EXCEPTION
           WHEN vr_exc_saida THEN
             pr_cdcritic := vr_cdcritic;
             pr_dscritic := vr_dscritic;
           WHEN OTHERS THEN
             pr_cdcritic := 0;
             pr_dscritic := 'Não foi possivel consultar o saldo: '||SQLERRM;
             RAISE vr_exc_saida;
         END;
    END;
  END pc_buscar_sld_rgt_apl_prog;

  /* Consulta o saldo para resgate da aplicação programada + resgate no momento - Mensageria */
  PROCEDURE pc_buscar_sld_rgt_apl_prog_web (pr_nrdconta IN craprda.nrdconta%TYPE  -- Nro da conta da aplicacao
                                  ,pr_idseqttl IN INTEGER                -- Identificador Sequencial
                                  ,pr_nrctrrpp IN craprpp.nrctrrpp%TYPE  -- Contrato Poupanca Programada
                                  ,pr_dtmvtolt IN VARCHAR2               -- Data do movimento atual
                                  ,pr_dtmvtopr IN VARCHAR2               -- Data do proximo movimento
                          ,pr_vlresgat  IN craprga.vlresgat%TYPE     --> Valor do resgate
                          ,pr_idtiprgt  IN craprga.idtiprgt%TYPE     --> Tipo do resgate 1 - Parcial / 2 - Total
                          ,pr_dtresgat  IN VARCHAR2     --> Data do resgate
                                  ,pr_inproces IN crapdat.inproces%TYPE  -- Indicador de processo
                                  ,pr_flgerlog IN INTEGER                -- Flag erro log
                                  ,pr_xmllog   IN VARCHAR2               -- XML com informacoes de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER           -- Código da crítica
                                  ,pr_dscritic OUT VARCHAR2              -- Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType     -- Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2              -- Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2)             -- Erros do processo
   IS BEGIN
   /* .............................................................................

   Programa: pc_buscar_sld_rgt_apl_prog_web
   Sistema : Novos Produtos de Captação - Aplicação Programada
   Sigla   : APLI
   Autor   : CIS Corporate
   Data    : Agosto/2018.                    Ultima atualizacao: --/--/----

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Rotina referente a busca do saldo para resgate da aplicação programada + resgate no momento - Mensageria. 

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
    vr_dtmvtopr Date := TO_DATE(pr_dtmvtopr,'dd/mm/yyyy');
    vr_dtresgat Date := TO_DATE(pr_dtresgat,'dd/mm/yyyy');

    -- Variaveis de retorno
    vr_tab_saldo_rpp typ_tab_saldo_rpp;
    vr_tab_erro gene0001.typ_tab_erro;

    -- Variaveis de log
    vr_cdcooper crapcop.cdcooper%TYPE;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);
    vr_flgerlog BOOLEAN := FALSE; 
    

    -- Variaveis de XML 
    vr_xml_temp VARCHAR2(32767);
    vr_clobxmlc CLOB;
    vr_texto_novo VARCHAR2(1000);

      --Registro do tipo calendario
      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

        
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

    IF (pr_dtmvtolt IS NULL) THEN
           -- Verifica se a cooperativa esta cadastrada
            OPEN BTCH0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
     
            FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
     
            -- Se não encontrar
            IF BTCH0001.cr_crapdat%NOTFOUND THEN
       
                  -- Fechar o cursor pois haverá raise
                  CLOSE BTCH0001.cr_crapdat;
           
                  -- Montar mensagem de critica
                  vr_cdcritic := 1;
                  vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
           
                   -- Gera exceção
                  RAISE vr_exc_erro;
       
       ELSE
              vr_dtmvtolt := rw_crapdat.dtmvtolt;
              vr_dtmvtopr := rw_crapdat.dtmvtopr;
              vr_dtresgat := rw_crapdat.dtmvtolt;

                -- Apenas fechar o cursor
                CLOSE BTCH0001.cr_crapdat;
             END IF;
       
        END IF;

    -- Verifica se houve erro recuperando informacoes de log                              
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;     
    
    IF pr_flgerlog = 1 THEN
      vr_flgerlog := TRUE;
    END IF;

    -- Busca as informações da apl. programada
    pc_buscar_sld_rgt_apl_prog (pr_cdcooper => vr_cdcooper
                      ,pr_cdoperad => vr_cdoperad
                      ,pr_nmdatela => vr_nmdatela
                      ,pr_idorigem => vr_idorigem
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_idseqttl => pr_idseqttl
                      ,pr_nrctrrpp => pr_nrctrrpp
                      ,pr_dtmvtolt => vr_dtmvtolt
                      ,pr_vlresgat => pr_vlresgat
                      ,pr_idtiprgt => pr_idtiprgt
                      ,pr_dtresgat => vr_dtresgat
                      ,pr_tab_saldo_rpp => vr_tab_saldo_rpp
                      ,pr_dscritic => vr_dscritic
                      ,pr_cdcritic => vr_cdcritic);

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
    
    -- Dados
    IF vr_tab_saldo_rpp.count >0 THEN
       FOR i1 in vr_tab_saldo_rpp.FIRST..vr_tab_saldo_rpp.LAST LOOP
             vr_texto_novo := vr_texto_novo ||
                              '<Registro>'||
                              '<vlaplica>'||to_char(vr_tab_saldo_rpp(i1).vlaplica,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS=,.')||'</vlaplica>'||
                              '<vlsldtot>'||to_char(vr_tab_saldo_rpp(i1).vlsldtot,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS=,.')||'</vlsldtot>'||
                              '<vlsldrgt>'||to_char(vr_tab_saldo_rpp(i1).vlsldrgt,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS=,.')||'</vlsldrgt>'||  
                              '<vlultren>'||to_char(vr_tab_saldo_rpp(i1).vlultren,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS=,.')||'</vlultren>'||
                              '<vlrentot>'||to_char(vr_tab_saldo_rpp(i1).vlrentot,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS=,.')||'</vlrentot>'||
                              '<vlrevers>'||to_char(vr_tab_saldo_rpp(i1).vlrevers,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS=,.')||'</vlrevers>'||
                              '<vlrdirrf>'||to_char(vr_tab_saldo_rpp(i1).vlrdirrf,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS=,.')||'</vlrdirrf>'||
                              '<percirrf>'||to_char(vr_tab_saldo_rpp(i1).percirrf,'fm99999g999g990d00','NLS_NUMERIC_CHARACTERS=,.')||'</percirrf>'||
                              '<dtresgat>'||to_char(vr_dtresgat, 'DD/MM/YYYY')||'</dtresgat>'||
                              '<nraplica>'||vr_tab_saldo_rpp(i1).nraplica||'</nraplica>'||
                              '<tpaplica>31</tpaplica>'||
                              '<tpresgat>'||vr_tab_saldo_rpp(i1).tpresgat||'</tpresgat>'||
                              '<dtvencto>'||to_char(vr_tab_saldo_rpp(i1).dtvencto, 'DD/MM/YYYY')||'</dtvencto>'||
                              '<dtcarenc>'||to_char(vr_tab_saldo_rpp(i1).dtcarenc, 'DD/MM/YYYY')||'</dtcarenc>'||
                              '<qtdiacar>'||vr_tab_saldo_rpp(i1).qtdiacar||'</qtdiacar>'||
                              '</Registro>';

             gene0002.pc_escreve_xml(pr_xml            => vr_clobxmlc
                                    ,pr_texto_completo => vr_xml_temp 
                                    ,pr_texto_novo     => vr_texto_novo);
             vr_texto_novo :='';                                                           
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
      pr_dscritic := 'Erro geral em APLI0008.pc_buscar_sld_rgt_apl_prog_web: '||SQLERRM;
      -- Carregar XML padrão para variável de retorno não utilizada.
      -- Existe para satisfazer exigência da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic ||
                                     '</Erro></Root>');
      
  END;
END pc_buscar_sld_rgt_apl_prog_web;

END APLI0008;
/
