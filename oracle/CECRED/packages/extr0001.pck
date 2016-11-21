CREATE OR REPLACE PACKAGE CECRED.EXTR0001 AS

  /* -------------------------------------------------------------------------------------------------------------

    Programa : EXTR0001 (Antigo b1wgen0001.p )
    Sistema  : Rotinas gen�ricas para calculos e envios de extratos
    Sigla    : GENE
    Autor    : Mirtes.
    Data     : Dezembro/2012.                   Ultima atualizacao: 03/10/2016

    Alteracoes: 27/08/2014 - Incluida chamada da procedure pc_busca_saldo_aplicacoes,
                             na procedure pc_ver_saldos (Jean Michel).
                             
                22/09/2014 - Adicionado observacao no corpo de e-mail (Daniele).

                01/04/2015 - Ajuste na variavel vr_dshistor da procedure
                             pc_gera_registro_extrato (Jean Michel).
                
                27/10/2015 - Alterado o campo typ_reg_saldos.dslimcre de NUMBER
                             p/ VARCHAR2(100) (Odirlei Bussana/AMCOM)
                             
                17/11/2015 - Alterado para que na procedure pc_obtem_saldo_dia seja carregado 
                             o campo crapsda.vlsdcota na pr_tab_saldo, e que nas procedures
                             pc_obtem_saldo_dia_sd_wt e pc_obtem_saldo_dia_prog o valor seja
                             gravado na wt_saldos. (Douglas - Chamado 285228)
                             
               20/06/2016 - Correcao para o uso correto do indice da CRAPTAB em  varias procedures 
                            desta package.(Carlos Rafael Tanholi).                              
                            
               29/08/2016 - Criacao da procedure pc_obtem_saldo_car para uso da pc_obtem_saldo
                            atraves de rotinas PROGRESS. (Carlos Rafael Tanholi - SD 513352)    
							
			   03/10/2016 - Correcao no tratamento de retorno de campos data da pc_obtem_saldo_car
							com formato invalido. (Carlos Rafael Tanholi - SD 531031)
..............................................................................*/

  -- Tipo para guardar as 5 linhas da mensagem de e-mail
  TYPE tab_msgemail IS
    TABLE OF VARCHAR2(120)
    INDEX BY BINARY_INTEGER;
  -- Defini��o da tipo de registro que vai compreender as informa��es do extrato
  TYPE typ_reg_env_extrato IS
    RECORD (nrdconta crapcra.nrdconta%TYPE
           ,idseqttl crapcra.idseqttl%TYPE
           ,nmprimtl crapass.nmprimtl%TYPE
           ,vllimcre crapass.vllimcre%TYPE
           ,vltotcap crapcot.vldcotas%TYPE
           ,vlsmdmes NUMBER(10,2)
           ,vlsmtrim NUMBER(10,2)
           ,informat VARCHAR2(40)
           ,cdperiod crapcra.cdperiod%TYPE
           ,formaenv crapcra.cddfrenv%TYPE
           ,cdendere crapcem.cddemail%TYPE
           ,dsdemail crapcem.dsdemail%TYPE
           ,msgemail tab_msgemail);
  -- Tipo tabela para comportar um registro conforme acima
  TYPE typ_tab_env_extrato IS
    TABLE OF typ_reg_env_extrato
    INDEX BY BINARY_INTEGER;

  /* Tipo que compreende o registro da tab. tempor�ria tt-saldo */
  TYPE typ_reg_saldos IS
      RECORD (nrdconta crapsda.nrdconta%TYPE
             ,dtmvtolt crapsda.dtmvtolt%TYPE
             ,vlsddisp crapsda.vlsddisp%TYPE
             ,vlsdchsl crapsda.vlsdchsl%TYPE
             ,vlsdbloq crapsda.vlsdbloq%TYPE
             ,vlsdblpr crapsda.vlsdblpr%TYPE
             ,vlsdblfp crapsda.vlsdblfp%TYPE
             ,vlsdindi crapsda.vlsdindi%TYPE
             ,vllimcre crapsda.vllimcre%TYPE
             ,cdcooper crapsda.cdcooper%TYPE
             ,vlsdeved crapsda.vlsdeved%TYPE
             ,vldeschq crapsda.vldeschq%TYPE
             ,vllimutl crapsda.vllimutl%TYPE
             ,vladdutl crapsda.vladdutl%TYPE
             ,vlsdrdca crapsda.vlsdrdca%TYPE
             ,vlsdrdpp crapsda.vlsdrdpp%TYPE
             ,vllimdsc crapsda.vllimdsc%TYPE
             ,vlprepla crapsda.vlprepla%TYPE
             ,vlprerpp crapsda.vlprerpp%TYPE
             ,vlcrdsal crapsda.vlcrdsal%TYPE
             ,qtchqliq crapsda.qtchqliq%TYPE
             ,qtchqass crapsda.qtchqass%TYPE
             ,dtdsdclq crapsda.dtdsdclq%TYPE
             ,vltotpar crapsda.vltotpar%TYPE
             ,vlopcdia crapsda.vlopcdia%TYPE
             ,vlavaliz crapsda.vlavaliz%TYPE
             ,vlavlatr crapsda.vlavlatr%TYPE
             ,qtdevolu crapsda.qtdevolu%TYPE
             ,vltotren crapsda.vltotren%TYPE
             ,vldestit crapsda.vldestit%TYPE
             ,vllimtit crapsda.vllimtit%TYPE
             ,vlsdempr crapsda.vlsdempr%TYPE
             ,vlsdfina crapsda.vlsdfina%TYPE
             ,vlsrdc30 crapsda.vlsrdc30%TYPE
             ,vlsrdc60 crapsda.vlsrdc60%TYPE
             ,vlsrdcpr crapsda.vlsrdcpr%TYPE
             ,vlsrdcpo crapsda.vlsrdcpo%TYPE
             ,vlsdcota crapsda.vlsdcota%TYPE
             ,vlblqtaa NUMBER(18,6)
             ,vlstotal NUMBER(18,6)
             ,vlsaqmax NUMBER(18,6)
             ,vlacerto NUMBER(18,6)
             ,dslimcre VARCHAR2(100)
             ,vlipmfpg NUMBER(18,6)
             ,dtultlcr crapass.dtultlcr%TYPE
             ,vlblqjud crapblj.vlbloque%TYPE);
  /* Defini��o de tabela que compreende os registros acima declarados */
  TYPE typ_tab_saldos IS
    TABLE OF typ_reg_saldos
    INDEX BY BINARY_INTEGER;

  /* Tipo que compreende o registro da tab. tempor�ria tt-extrato_conta */
  TYPE typ_reg_extrato_conta IS
      RECORD (nrdconta crapass.nrdconta%TYPE
             ,dtmvtolt craplcm.dtmvtolt%TYPE
             ,nrsequen INTEGER
             ,cdhistor craplcm.cdhistor%TYPE
             ,dshistor VARCHAR2(100)
             ,nrdocmto VARCHAR2(11)
             ,indebcre VARCHAR2(3)
             ,dtliblan VARCHAR2(10)
             ,inhistor craphis.inhistor%TYPE
             ,vllanmto craplcm.vllanmto%TYPE
             ,vlsddisp crapsda.vlsddisp%TYPE
             ,vlsdchsl crapsda.vlsdchsl%TYPE
             ,vlsdbloq crapsda.vlsdbloq%TYPE
             ,vlsdblpr crapsda.vlsdblpr%TYPE
             ,vlsdblfp crapsda.vlsdblfp%TYPE
             ,vlsdtota crapsda.vlsddisp%TYPE
             ,vllimcre crapass.vllimcre%TYPE
             ,dsagenci crapage.nmextage%TYPE
             ,cdagenci crapage.cdagenci%TYPE
             ,cdbccxlt INTEGER
             ,nrdolote INTEGER
             ,dsidenti craplcm.dsidenti%TYPE
             ,nrparepr INTEGER
             ,dsextrat VARCHAR2(100)
             ,vlblqjud crapblj.vlbloque%TYPE
             ,cdcoptfn craplcm.cdcoptfn%TYPE
             ,nrseqlmt INTEGER);
  /* Defini��o de tabela que compreende os registros acima declarados */
  TYPE typ_tab_extrato_conta IS
    TABLE OF typ_reg_extrato_conta
    INDEX BY VARCHAR2(12); -- Chave composta por Data + Sequencial (YYMMDD999999)

  /* Tipo que compreende o registro da tab. tempor�ria tt-dep-identificado */
  TYPE typ_reg_dep_identificado IS
      RECORD(dtmvtolt craplcm.dtmvtolt%TYPE
            ,dshistor craphis.dshistor%TYPE
            ,nrdocmto VARCHAR2(100)
            ,indebcre craphis.indebcre%TYPE
            ,vllanmto craplcm.vllanmto%TYPE
            ,dsidenti craplcm.dsidenti%TYPE
            ,dsextrat craphis.dsextrat%TYPE);
  /* Defini��o de tabela que compreende os registros acima declarados */
  TYPE typ_tab_dep_identificado IS
    TABLE OF typ_reg_dep_identificado
    INDEX BY BINARY_INTEGER;
  
  --> TempTable para retornar dados para liberacao de emprestimos(antiga b1wgen0001tt./tt-libera-epr)
  TYPE typ_rec_libera_epr 
    IS RECORD (dtlibera crapdpb.dtliblan%TYPE,
               vllibera crapdpb.vllanmto%TYPE);
  TYPE typ_tab_libera_epr IS TABLE OF typ_rec_libera_epr
    INDEX BY PLS_INTEGER;
  
  /* Apenas faz a chamada para a pc_obtem_saldo_dia */
  PROCEDURE pc_obtem_saldo_dia_sd(pr_cdcooper   IN crapcop.cdcooper%TYPE                            
                                 ,pr_cdagenci   IN crapass.cdagenci%TYPE
                                 ,pr_nrdcaixa   IN craperr.nrdcaixa%TYPE
                                 ,pr_cdoperad   IN craplgm.cdoperad%TYPE
                                 ,pr_nrdconta   IN crapass.nrdconta%TYPE
                                 ,pr_vllimcre   IN crapass.vllimcre%TYPE 
                                 ,pr_tipo_busca IN VARCHAR2 DEFAULT 'A' /* I=usa dtrefere, A=Usa dtrefere-1, P=Usa dtrefere+1 */                                
                                 ,pr_des_reto  OUT VARCHAR2 --> OK ou NOK
                                 ,pr_tab_sald  OUT EXTR0001.typ_tab_saldos
                                 ,pr_tab_erro  OUT GENE0001.typ_tab_erro);                              
                                 
  PROCEDURE pc_obtem_saldo_dia_sd_wt(pr_cdcooper   IN crapcop.cdcooper%TYPE  --> Cooperativa
                                    ,pr_cdagenci   IN crapass.cdagenci%TYPE  --> Codigo da agencia
                                    ,pr_nrdcaixa   IN craperr.nrdcaixa%TYPE  --> Numero do caixa
                                    ,pr_cdoperad   IN craplgm.cdoperad%TYPE  --> C�digo do operador
                                    ,pr_nrdconta   IN crapass.nrdconta%TYPE  --> Conta do associado
                                    ,pr_vllimcre   IN crapass.vllimcre%TYPE  --> Valor do limite de cr�dito
                                    ,pr_tipo_busca IN VARCHAR2 DEFAULT 'A' /* I=usa dtrefere, A=Usa dtrefere-1, P=Usa dtrefere+1 */
                                    ,pr_cdcritic  OUT crapcri.cdcritic%type --> Codigo de Erro
                                    ,pr_dscritic  OUT VARCHAR2);            --> Descricao de Erro                                   
  
  PROCEDURE pc_obtem_saldo_dia_prog (pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa
                                    ,pr_cdagenci IN crapass.cdagenci%TYPE  --> Codigo da agencia
                                    ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE  --> Numero do caixa
                                    ,pr_cdoperad IN craplgm.cdoperad%TYPE  --> C�digo do operador
                                    ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Conta do associado
                                    ,pr_dtrefere IN crapdat.dtmvtolt%TYPE 
                                    ,pr_tipo_busca IN VARCHAR2 DEFAULT 'A'   --> /* I=usa dtrefere, A=Usa dtrefere-1, P=Usa dtrefere+1 */
                                    ,pr_cdcritic OUT crapcri.cdcritic%type --> Codigo de Erro
                                    ,pr_dscritic OUT VARCHAR2);            --> Descricao de Erro
                              
  /* Obten��o do saldo da conta sem o dia fechado */
  PROCEDURE pc_obtem_saldo_dia(pr_cdcooper   IN crapcop.cdcooper%TYPE
                              ,pr_rw_crapdat IN btch0001.cr_crapdat%ROWTYPE
                              ,pr_cdagenci   IN crapass.cdagenci%TYPE
                              ,pr_nrdcaixa   IN craperr.nrdcaixa%TYPE
                              ,pr_cdoperad   IN craplgm.cdoperad%TYPE
                              ,pr_nrdconta   IN crapass.nrdconta%TYPE
                              ,pr_vllimcre   IN crapass.vllimcre%TYPE
                              ,pr_dtrefere   IN crapdat.dtmvtolt%TYPE
                              ,pr_flgcrass   IN BOOLEAN DEFAULT TRUE
                              ,pr_tipo_busca IN VARCHAR2 DEFAULT 'A' /* I=usa dtrefere, A=Usa dtrefere-1, P=Usa dtrefere+1 */
                              ,pr_des_reto  OUT VARCHAR2 --> OK ou NOK
                              ,pr_tab_sald  OUT EXTR0001.typ_tab_saldos
                              ,pr_tab_erro  OUT GENE0001.typ_tab_erro);

  /* Obten��o do saldo da conta */
  PROCEDURE pc_obtem_saldo(pr_cdcooper   IN crapcop.cdcooper%TYPE
                          ,pr_rw_crapdat IN btch0001.cr_crapdat%ROWTYPE
                          ,pr_cdagenci   IN crapass.cdagenci%TYPE
                          ,pr_nrdcaixa   IN craperr.nrdcaixa%TYPE
                          ,pr_cdoperad   IN craplgm.cdoperad%TYPE
                          ,pr_nrdconta   IN crapass.nrdconta%TYPE
                          ,pr_dtrefere   IN crapdat.dtmvtolt%TYPE
                          ,pr_des_reto  OUT VARCHAR2 --> OK ou NOK
                          ,pr_tab_sald  OUT EXTR0001.typ_tab_saldos
                          ,pr_tab_erro  OUT GENE0001.typ_tab_erro);

  /* Meio de utilizacao da pc_onbtem_saldo no PROGRESS */
  PROCEDURE pc_obtem_saldo_car(pr_cdcooper IN crapcop.cdcooper%TYPE
                              ,pr_cdagenci IN crapass.cdagenci%TYPE
                              ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE
                              ,pr_cdoperad IN craplgm.cdoperad%TYPE
                              ,pr_nrdconta IN crapass.nrdconta%TYPE
                              ,pr_dtrefere IN crapdat.dtmvtolt%TYPE
                              ,pr_des_reto OUT VARCHAR2 --> OK ou NOK
                              ,pr_clob_ret OUT CLOB);   --> Tabela Extrato da Conta                          

  -- Chamar fun�ao para montagem do n�mero do documento para extrato
  FUNCTION fn_format_nrdocmto_extr(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
                                  ,pr_cdhistor IN craphis.cdhistor%TYPE --> C�digo do hist�rico
                                  ,pr_nrdocmto IN craplcm.nrdocmto%TYPE --> Nro documento do registro
                                  ,pr_cdpesqbb IN craplcm.cdpesqbb%TYPE --> Campo de pesquisa
                                  ,pr_nrdctabb IN craplcm.nrdctabb%TYPE --> Conta no BB
                                  ,pr_inpessoa IN crapass.inpessoa%TYPE --> Tipo da pessoa da conta
                                  ,pr_lshistor_cheque IN craptab.dstextab%TYPE --> Lista de hist�ricos de cheques
                                  ) RETURN VARCHAR2;

  /* Procedure para listar extrato da conta-corrente  */
  PROCEDURE pc_consulta_extrato(pr_cdcooper     IN crapcop.cdcooper%TYPE
                               ,pr_rw_crapdat   IN btch0001.cr_crapdat%ROWTYPE
                               ,pr_cdagenci     IN crapass.cdagenci%TYPE
                               ,pr_nrdcaixa     IN craperr.nrdcaixa%TYPE
                               ,pr_cdoperad     IN craplgm.cdoperad%TYPE
                               ,pr_nrdconta     IN crapass.nrdconta%TYPE
                               ,pr_vllimcre     IN crapass.vllimcre%TYPE
                               ,pr_dtiniper     IN crapdat.dtmvtolt%TYPE
                               ,pr_dtfimper     IN crapdat.dtmvtolt%TYPE
                               ,pr_lshistor     IN craptab.dstextab%TYPE
                               ,pr_idorigem     IN INTEGER
                               ,pr_idseqttl     IN INTEGER
                               ,pr_nmdatela     IN VARCHAR2
                               ,pr_flgerlog     IN BOOLEAN
                               ,pr_des_reto    OUT VARCHAR2 --> OK ou NOK
                               ,pr_tab_extrato OUT EXTR0001.typ_tab_extrato_conta
                               ,pr_tab_erro    OUT GENE0001.typ_tab_erro);


  /* Envio dos extratos aos cooperados */
  PROCEDURE pc_envia_extrato_email(pr_cdcooper        IN crapcop.cdcooper%TYPE
                                  ,pr_rw_crapdat      IN btch0001.cr_crapdat%ROWTYPE
                                  ,pr_nmrescop        IN crapcop.nmrescop%TYPE
                                  ,pr_cdprogra        IN crapprg.cdprogra%TYPE
                                  ,pr_dtmvtolt        IN crapdat.dtmvtolt%TYPE
                                  ,pr_lshistor        IN craptab.dstextab%TYPE
                                  ,pr_tab_env_extrato IN typ_tab_env_extrato
                                  ,pr_des_erro       OUT VARCHAR2);

  /* Procedure para obter saldos anteriores da conta-corrente */
  PROCEDURE pc_obtem_saldos_anteriores (pr_cdcooper    IN INTEGER      -- Codigo da Cooperativa
                                       ,pr_cdagenci    IN INTEGER      -- Codigo da agencia
                                       ,pr_nrdcaixa    IN INTEGER      -- Numero da caixa
                                       ,pr_cdopecxa    IN VARCHAR2     -- Codigo do operador do caixa
                                       ,pr_nmdatela    IN VARCHAR2     -- Nome da tela
                                       ,pr_idorigem    IN INTEGER      -- Indicador de origem
                                       ,pr_nrdconta    IN INTEGER      -- Numero da conta do cooperado
                                       ,pr_idseqttl    IN INTEGER      -- Indicador de sequencial
                                       ,pr_dtmvtolt    IN DATE         -- Data de movimento
                                       ,pr_dtmvtoan    IN DATE         -- Data de movimento anterior
                                       ,pr_dtrefere    IN DATE         -- Data de referencia
                                       ,pr_flgerlog    IN BOOLEAN      -- Flag se deve gerar log
                                       ,pr_dscritic   OUT VARCHAR2                   -- Retorno de critica
                                       ,pr_tab_saldos OUT typ_tab_saldos             -- Retorna os saldos
                                       ,pr_tab_erro   OUT gene0001.typ_tab_erro);    -- retorna os erros
                                       
  
  /*****************************************************************************
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Sidnei (Precise IT)
     Data    : Setembro/2007.                        Ultima atualizacao: 02/09/2015

     Objetivo  : Verificar se o associado possui capital 
                (conversao em BO do fontes/ver_capital.p)

                 p-nro-conta    = Conta do associado em questao
                 p-valor-lancto = Se maior que 0, verifica de pode sacar o valor
                                se for 0, apenas testa se o associado possui
                                capital suficiente para efetuar a operacao.
                                
  *****************************************************************************/       
  PROCEDURE pc_ver_capital(pr_cdcooper IN crapcop.cdcooper%TYPE -- C�digo da cooperativa
                          ,pr_cdagenci IN crapage.cdagenci%TYPE -- C�digo da ag�ncia
                          ,pr_nrdcaixa IN INTEGER               -- N�mero do caixa
                          ,pr_inproces IN crapdat.inproces%TYPE -- Indicador do processo
                          ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE -- Data de movimento
                          ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE -- Data do programa
                          ,pr_cdprogra IN VARCHAR2              -- C�digo do programa
                          ,pr_idorigem IN INTEGER               -- Origem do programa
                          ,pr_nrdconta IN crapass.nrdconta%TYPE -- N�mero da conta
                          ,pr_vllanmto IN NUMBER                -- Valor de lancamento
                          ,pr_des_reto OUT VARCHAR2             -- Retorno OK/NOK
                          ,pr_tab_erro OUT GENE0001.typ_tab_erro); -- Tabela de erros
                          
  PROCEDURE pc_ver_saldos(pr_cdcooper IN crapcop.cdcooper%TYPE -- C�digo da cooperativa
                         ,pr_cdagenci IN crapage.cdagenci%TYPE -- C�digo da ag�ncia
                         ,pr_nrdcaixa IN INTEGER               -- N�mero do caixa
                         ,pr_inproces IN crapdat.inproces%TYPE -- Indicador do processo
                         ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE -- Data de movimento
                         ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE -- Data do programa
                         ,pr_cdprogra IN VARCHAR2              -- C�digo do programa
                         ,pr_nrdconta IN crapass.nrdconta%TYPE -- Conta corrente
                         ,pr_vllimcre IN crapass.vllimcre%TYPE -- Valor limite de cr�ddito
                         ,pr_des_reto OUT VARCHAR2             -- Retorno OK/NOK
                         ,pr_tab_erro OUT GENE0001.typ_tab_erro); --Tabela de erros
                         
  /* Procedure para tratar registro do extrato de conta corrente */
  PROCEDURE pc_gera_registro_extrato(pr_cdcooper     IN crapcop.cdcooper%TYPE    --> Cooperativa conectada
                                    ,pr_rowid        IN ROWID                    --> Registro buscado da craplcm
                                    ,pr_flgident     IN BOOLEAN                  --> Se deve ou n�o usar o craplcm.dsidenti
                                    ,pr_nmdtable     IN VARCHAR2                 --> Extrato ou Dep�sito
                                    ,pr_lshistor     IN craptab.dstextab%TYPE    --> Lista de hist�ricos de cheques
                                    ,pr_tab_extr     IN OUT NOCOPY typ_tab_extrato_conta    --> Tabela Com Extrato de Conta
                                    ,pr_tab_depo     IN OUT NOCOPY typ_tab_dep_identificado --> Tabela Depositos Identificados
                                    ,pr_des_reto     OUT VARCHAR2                 --> Saida OK ou NOK
                                    ,pr_des_erro     OUT VARCHAR2);
                                    
  /* Subrotina para obter depositos Identificados */
  PROCEDURE pc_obtem_depos_identificad   (pr_cdcooper     IN crapcop.cdcooper%TYPE              --Codigo Cooperativa
                                         ,pr_cdagenci     IN crapass.cdagenci%TYPE              --Codigo Agencia
                                         ,pr_nrdcaixa     IN INTEGER                            --Numero do Caixa
                                         ,pr_cdoperad     IN VARCHAR2                           --Codigo Operador
                                         ,pr_nmdatela     IN VARCHAR2                           --Nome da Tela
                                         ,pr_idorigem     IN INTEGER                            --Origem dos Dados
                                         ,pr_nrdconta     IN crapass.nrdconta%TYPE              --Numero da Conta do Associado
                                         ,pr_idseqttl     IN INTEGER                            --Sequencial do Titular
                                         ,pr_dtiniper     IN DATE                               --Data Inicio periodo   
                                         ,pr_dtfimper     IN DATE                               --Data Final periodo
                                         ,pr_flgpagin     IN BOOLEAN                            --Imprimir pagina
                                         ,pr_iniregis     IN INTEGER                            --Indicador Registro
                                         ,pr_qtregpag     IN INTEGER                            --Quantidade Registros Pagos
                                         ,pr_flgerlog     IN BOOLEAN                            --Imprimir log
                                         ,pr_qtregist     OUT INTEGER                           --Quantidade Registros
                                         ,pr_des_reto     OUT VARCHAR2                          --Retorno OK ou NOK
                                         ,pr_tab_erro     OUT GENE0001.typ_tab_erro             --Tabela Retorno Erro
                                         ,pr_tab_dep_identific  OUT EXTR0001.typ_tab_dep_identificado);  --Vetor para o retorno das informa��es                                        
                                    
  --> Procedimento para buscar informa�oes de depositos avista
  PROCEDURE pc_carrega_dep_vista (pr_cdcooper  IN crapcop.cdcooper%TYPE    --> Codigo da cooperativa
                                 ,pr_cdagenci  IN crapage.cdagenci%TYPE    --> C�digo da agencia
                                 ,pr_nrdcaixa  IN crapbcx.nrdcaixa%TYPE    --> Numero do caixa
                                 ,pr_cdoperad  IN crapope.cdoperad%TYPE    --> Codigo do operador
                                 ,pr_nrdconta  IN crapass.nrdconta%TYPE    --> Numero da conta do cooperado
                                 ,pr_dtmvtolt  IN DATE                     --> Data do movimento
                                 ,pr_idorigem  IN INTEGER                  --> Id origem
                                 ,pr_idseqttl  IN crapttl.idseqttl%TYPE    --> Sequencial do titular
                                 ,pr_nmdatela  IN craptel.nmdatela%TYPE    --> Nome da tela
                                 ,pr_flgerlog  IN VARCHAR2                 --> Identificador se deve gerar log S-Sim e N-Nao
                                 -------> OUT <------
                                 ,pr_tab_saldos     OUT EXTR0001.typ_tab_saldos --> Retornar saldos
                                 ,pr_tab_libera_epr OUT typ_tab_libera_epr      --> Retornar dados de liberacao de epr
                                 ,pr_des_reto       OUT VARCHAR2                --> Retorno OK/NOK
                                 ,pr_tab_erro       OUT GENE0001.typ_tab_erro   --> Retorna os erros
                                 );


  /* Procedure para Consultar o Extrato da Conta no Modo Caracter */
  PROCEDURE pc_consulta_extrato_car (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                    ,pr_cdagenci  IN crapass.cdagenci%TYPE --> Agencia
                                    ,pr_nrdcaixa  IN craperr.nrdcaixa%TYPE --> Caixa
                                    ,pr_cdoperad  IN craplgm.cdoperad%TYPE --> Operador
                                    ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Conta
                                    ,pr_dtiniper  IN crapdat.dtmvtolt%TYPE --> Data Inicial
                                    ,pr_dtfimper  IN crapdat.dtmvtolt%TYPE --> Data Final
                                    ,pr_idorigem  IN INTEGER               --> Origem
                                    ,pr_idseqttl  IN INTEGER               --> Seq. Titular
                                    ,pr_nmdatela  IN VARCHAR2              --> Tela
                                    ,pr_flgerlog  IN INTEGER               --> Gerar Log?
                                    ,pr_des_erro OUT VARCHAR2              --> Saida OK/NOK
                                    ,pr_clob_ret OUT CLOB                  --> Tabela Extrato da Conta
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Codigo Erro
                                    ,pr_dscritic OUT VARCHAR2);            --> Descricao Erro

END EXTR0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.EXTR0001 AS

  /* -------------------------------------------------------------------------------------------------------------

    Programa : EXTR0001 (Antigo b1wgen0001.p )
    Sistema  : Rotinas gen�ricas para formul�rios postmix
    Sigla    : GENE
    Autor    : Mirtes.
    Data     : Dezembro/2012.                   Ultima atualizacao: 29/08/2016

   Dados referentes ao programa:

   Objetivo  : BO  EXTRATO CONTA CORRENTE/ CONSULTA SALDO CONTA CORRENTE

   Alteracoes: 26/12/2005 - Inclusao das alineas de devolucao de cheque no
                            historico (Junior).

               10/02/2006 - Desprezar custodia e desconto de cheques nos
                            lancamentos do dia (Junior).

               22/05/2006 - Incluido codigo da cooperativa nas leituras das
                            tabelas (Diego).

               29/05/2007 - SQLWorks - Murilo
                            Inclusao das procedures de obtencao de CPMF e
                            medias.

               03/08/2007 - Definicoes de temp-tables para include (David).
                          - Incluir procedure carrega_dados_atenda (David).
                          - Incluir procedure extrato_investimento (Guilherme).

               03/09/2007 - Conversao de programas para BO, adicionados a este:
                          - Inclusao procedure ver_capital  (Sidnei)
                          - Inclusao procedure ver_cadastro (Sidnei)

               04/10/2007 - Retirar procedure extrato_investimento, pois foi
                            incluida na BO b1wgen0020 (David);
                          - Retirar procedure extrato_cotas, pois foi incluida
                            na BO b1wgen0021 (David);
                          - Incluidas variaveis rd2_lshistor e rd2_contador
                            para a melhoria de performance (Evandro).

               24/10/2007 - Incluir Limpeza das Temp Tables de retorno nas
                            procedure obtem_cabecalho e carrega_dados_atenda.

               13/11/2007 - Incluir parametros para chamada das BO's b1wgen0020
                            e b1wgen0021 (David).

               22/11/2007 - Tratar consulta-extrato para Cash - FOTON (Ze).

               28/11/2007 - Separar Nome do Primeiro e Segundo Titular
                            do Obtem-Cabec - FOTON  (Ze).

               12/12/2007 - Incluir Valor do Limite no Obtem-Cabec - FOTON (Ze)

               07/02/2008 - Incluir procedure completa-cabecalho
                          - Incluir procedure zoom-associados
                          - Incluir procedure carrega_dep_vista
                          - Incluir procedure carrega_medias (Guilherme).
                          - Incluir procedure saldo_utiliza (David).

               12/03/2008 - Retirar procedure saldo_utiliza (David).
                          - Adaptacoes para agendamentos (David).

               16/07/2008 - Comentario de onde a consulta-extrato eh chamada
                          - Alimentado novos campos na tt-extrato_conta
                          - Incluir procedures tarext_cheque e
                            gera_extrato_especial(Guilherme).

               31/07/2008 - Incluir chamada da procedure busca_anota
                            na carrega_dados_atenda
                          - Incluir chamada procedure busca_cartoes_magneticos
                            na carrega_dados_atenda (Guilherme).
                          - Incluir chamada da procedure obtem-mensagens-alerta
                            na carrega_dados_atenda (David).

               28/08/2008 - Listar historicos 590,591,597,687 com o cdpesqbb
                          - Incluido RETURN "OK" na ver_cadastro (Guilherme).
                          - Tratamento para obter ocupacao de pessoas juridicas
                          - Chamada para procedure obtem-cartoes-magneticos
                          - Tratamento para desconto de titulos na procedure
                            ver_saldos (David).
               30/10/2008 - Incluir o historico 359 Est. Debito nos historico
                            utilizado pelo CASH para o final de semana (Ze).

               07/11/2008 - Troca do Histor. 359 p/ 767 (Estorno Debito) (Ze).

               11/02/2009 - Incluir procedure gera_extrato_tarifas (Gabriel).

               02/03/2009 - Alteracao cdempres (Diego).
                          - Incluir campo tt-cabec.inpessoa na procedure
                            obtem-cabecalho (David).
                          - Gerar log na procedure gera_extrato_tarifas (David).
                          - Ler total de descontos pela b1wgen0030(Guilherme).

               08/05/2009 - Para o zoom dos associados, mostrar somente os
                            associados da cooperativa em questao (Evandro).

               15/07/2009 - Incluir campo tt-cabec.dssititg na procedure
                            obtem-cabecalho (Guilherme).
                          - Paginacao na zoom-associados para ayllos WEB
                            (Guilherme).
                          - Tratamento para historicos 771 e 772 (David).

               23/09/2009 - Tratamento para listagem de depositos identificados
                            (David).

               19/10/2009 - Alteracao Codigo Historico (Kbase).

               21/10/2009 - Adaptacoes projeto IF CECRED (Guilherme).

               04/11/2009 - Incluir novas variaveis utilizadas na procedure
                            ver_saldos (David).

               08/01/2010 - Acrescentar historico 573 no mesmo CAN-DO do 338
                            (Guilherme/Precise)

               04/03/2010 - Novos parametros para procedure consulta-poupanca
                            da BO b1wgen0006 (David).

               05/04/2010 - Ajustes para saldo e extrato referente a envelopes
                            depositados no cash (Evandro).

               19/05/2010 - Acerto no SUBSTRING do campo craplcm.cdpesqbb
                            (Diego).
                          - Retornar limite de credito armazenado na crapass
                            na procedure obtem-saldo-dia (David).

               05/07/2010 - Retirar procedure zoom-associados. A procedure foi
                            movida para a BO b1wgen0059 (David).

               04/08/2010 - Incluir procedure extrato-paginado para utilizacao
                            na Internet (David).

               01/09/2010 - Ajuste para rotina DEP.VISTA (David).
                          - Inclusao historio 891, demandas BACEN (Guilherme).

               28/10/2010 - Incluidos parametros flgativo e nrctrhcj na
                            procedure lista_cartoes (Diego).

               03/11/2010 - Incluidos historicos 918(Saque) e 920(Estorno)
                            utilizados pelo TAA compartilhado (Henrique).

               05/11/2010 - Inclusao de parametros ref. TAA compartilhado na
                            procedure gera-tarifa-extrato (Diego).

               25/11/2010 - Inclus�o temporariamente do parametro flgliber
                            (Transferencia do PAC5 Acredi) (Irlan)

               08/12/2010 - Incluir na procedure que carrega os dados
                            da conta na atenda , o valor da rotina
                            Cobranca (Gabriel).

               13/12/2010 - Incluida situacao 3-recolhido no tratamento da
                            crapenl (Evandro).

               23/02/2011 - Modificada a funcao fgetnrramfon , que trata
                            do telefone na ATENDA (Gabriel).

               18/03/2011 - Nova BO de Anotacao para tela ATENDA (David).

               31/03/2011 - Para o extrato TAA, efetuar mesmos controle do
                            extrato INTERNET (Evandro).

               29/04/2011 - Aumento do formato do campo Nr. Documento (Gabriel)

               03/06/2011 - Ajustada posicao do cdpesqbb para a gendamento
                            (Evandro).

               22/08/2011 - Alimentar campo dsidenti na procedure que consulta
                            com a cooperativa, agencia e nr do terminal
                            (Gabriel).

               06/09/2011 - Incluir quantos titulares a conta tem no obtem
                            cabecalho (Gabriel)

               15/09/2011 - Ajuste na criacao da tt-extrato_conta, melhorando
                            o controle de sequencia dos registros encontrados.
                            WEB estava com falha para historico 698 (David);
                          - Permitir cobranca de tarifa para PJ (Evandro).

               26/10/2011 - Incluido parametro na procedure busca_seguros
                            (GATI).

               22/11/2011 - Incluido tratamento para transferencia entre
                            cooperativas historicos 1009, 1011, 1014 e 1015
                            (Elton).

               14/03/2012 - Atualizado o extrato de tarifas com novos
                            historicos e incluido juros (Tiago).

               10/10/2012 - Tratamento para novo campo da 'craphis' de descri��o
                            do hist�rico em extratos (Lucas) [Projeto Tarifas].

               11/10/2012 - Retirado condicao de filtrar resultados apenas do
                            mes inicial, respeitando data inicial e final em
                            procedure obtem-cheques-deposito. (Jorge).

               16/10/2012 - Nova chamada da procedure valida_operador_migrado
                            da b1wgen9998 para controle de contas e operadores
                            migrados (David Kruger).

               03/12/2012 - Migra��o das rotinas de Progress >> Oracle PLSQL (Marcos Supero)

               02/05/2013 - Incorpora��o das altera��es referente a transferencia
                            intercooperativa implementadas no Progress pelo Gabriel (Marcos-Supero)

               05/05/2013 - Alterado as chaves das pltables para utilizar tamb�m o cdcooper e incrementar
                            sempre que executado para uma nova cooperativa, pois a debnet executa informa��es
                            para todas as cooperativas  (Odirlei-AMcom)

              07/05/2014 - Ajuste referente ao projeto Capta��o:
                           - Criado a procedure pc_obtem_saldo_dia_sd
                           - Migracao da rotina ver_capital
                           - Migracao da rotina ver_saldos
                           (Adriano).

              08/07/2014 - (Chamado 118128) Exclus�o do uso da tabeca crapcar.
                           (Tiago Castro - RKAM)

              13/08/2014 - Realizado ajustes nas procedures:
                           - pc_ver_capital
                           - pc_ver_saldo
                           (Adriano)

              22/08/2014 - Ajuste para incluir os historicos de lancamentos
                           da tabela craphcb na variavel vr_cdhishcb.
                           (Jaison)

              27/08/2014 - Incluida chamada da procedure pc_busca_saldo_aplicacoes,
                           na procedure pc_ver_saldos (Jean Michel).

              30/10/2014 - Alterar procedures obtem-saldo-dia e consulta-extrato para
                           incluir o hist�rico 530 na lista de hist�ricos verificados
                           em finais de semana e feriados. E verificar se o lan�amento
                           de hist�rico 530 foi proveniente de agendamento.
                           (Douglas - Projeto Capta��o Internet 2014/2)

              21/11/2014 - Alterado a vari�vel de valida��o da cr�tica na procedure
                           pc_obtem_saldo_dia_sd (Douglas - Chamado 186184/192128)

              01/04/2015 - Ajuste na variavel vr_dshistor da procedure
                           pc_gera_registro_extrato (Jean Michel).

              06/05/2015 - Nas procedures pc_obtem_saldo_dia, pc_gera_registro_extrato,
                           pc_consulta_extrato eram feitas consistencias para o codigo
                           de tarifa utlizado sem diferenciar INPESSOA < 3 neste caso
                           para contas deste tipo gerava RAISE e abortava a execucao
                           do extrato - Chamado 282112 (Carlos Rafael Tanholi)

              17/11/2015 - Adicionado parametro pr_tipo_busca na pc_obtem_saldo_dia_sd
                           pc_obtem_saldo_dia_sd_wt e alterado para que na procedure 
                           pc_obtem_saldo_dia seja carregado o campo crapsda.vlsdcota 
                           na pr_tab_saldo, e que nas procedures pc_obtem_saldo_dia_sd_wt 
                           e pc_obtem_saldo_dia_prog o valor seja gravado na wt_saldos. 
                           (Douglas - Chamado 285228)
                           
              17/12/2015 - Ajuste na pc_obtem_saldo_dia_sd, para n�o buscar todas as contas
                           em mem�ria, e passar a buscar apenas a conta recebida por par�metro
                           (Dionathan)
                           
              22/12/2015 - Ajuste na pc_obtem_saldo_dia_prog, para n�o buscar todas as contas
                           em mem�ria, e passar a buscar apenas a conta recebida por par�metro
                           (Douglas - Chamado 285228)
              
              04/01/2016 - Altera��o na chamada da rotina extr0001.pc_obtem_saldo_dia
                           para passagem do par�metro pr_tipo_busca, para melhoria
                           de performance.
                           Chamado 291693 (Heitor - RKAM)
                           
              22/02/2016 - Ajustes referentes ao projeto melhoria 157 (Lucas Ranghetti #330322)
              
              01/06/2016 - Adicionado validacao para identificar se esta executando
                           no batch ou online na chamada da fun��o fn_inpessoa_nrdconta 
                           (Kelvin - Chamado 459346)

			  02/06/2016 - Adicionado valida��es Para melhorar desempenho da 
						   rotina pc_obtem_saldo_dia (Kelvin - SD 459346)
                           
              20/06/2016 - Correcao para o uso correto do indice da CRAPTAB em  varias procedures 
                           desta package.(Carlos Rafael Tanholi).                              
                           
              21/06/2016 - Ajuste para utilizar o cursor cr_crapsda_pk para encontrar o saldo
                           (Adriano).             
                           
              30/06/2016 - Alterado parametro (pr_flgcrass), para false, na fun��o fn_inpessoa_nrdconta.
                           Busca de saldo para popular a uma temp/table, chamando o conteudo da temp/table 
                           dentro do loop de saldo, evitando uma nova chamada dentro do loop de consulta de saldo. (Evandro)

              09/08/2016 - #483189 Retirada do cursor cr_max_sda pois o mesmo n�o � mais utilizado;
                           Mudan�a do default do par�metro pr_tipo_busca para 'A' nas rotinas 
                           pc_obtem_saldo_dia (Carlos)

               29/08/2016 - Criacao da procedure pc_obtem_saldo_car para uso da pc_obtem_saldo
                            atraves de rotinas PROGRESS. (Carlos Rafael Tanholi - SD 513352)
..............................................................................*/

  -- Tratamento de erros
  vr_exc_erro exception;
  vr_des_erro varchar2(4000);

  -- Leitura da ag�ncia do associado
  CURSOR cr_crapage(pr_cdcooper IN crapass.cdcooper%TYPE
                   ,pr_cdagenci IN crapage.cdagenci%TYPE) IS
    SELECT age.nmextage
      FROM crapage age
     WHERE age.cdcooper = pr_cdcooper
       AND age.cdagenci = pr_cdagenci;
  rw_crapage cr_crapage%ROWTYPE;

  -- Busca de lan�amentos na data para compor saldo
  CURSOR cr_craplcm_olt(pr_cdcooper  IN crapcop.cdcooper%TYPE    --> Cooperativa conectada
                       ,pr_nrdconta  IN crapass.nrdconta%TYPE    --> N�mero da conta
                       ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE  
                       ,pr_lsthistor_ret IN VARCHAR2 DEFAULT ' ' --> Lista com c�digos de hist�rico a retornar
                        ) IS 
    SELECT lcm.nrdconta
          ,lcm.nrdolote
          ,lcm.dtmvtolt
          ,lcm.cdagenci
          ,lcm.cdhistor
          ,lcm.cdpesqbb
          ,lcm.cdbccxlt
          ,lcm.nrdocmto
          ,lcm.nrparepr
          ,lcm.vllanmto
          ,lcm.dsidenti
          ,lcm.dscedent
          ,lcm.nrdctabb
          ,lcm.nrseqava
          ,his.dsextrat
          ,his.indebcre
          ,his.inhistor
          ,his.dshistor
          ,lcm.rowid
      FROM craplcm lcm
          ,craphis his
     WHERE lcm.cdcooper = his.cdcooper
       AND lcm.cdhistor = his.cdhistor
       AND lcm.cdcooper = pr_cdcooper
       AND lcm.nrdconta = pr_nrdconta
       AND lcm.dtmvtolt = pr_dtmvtolt       
       AND ( pr_lsthistor_ret = ' ' OR ','||pr_lsthistor_ret||',' LIKE ('%,'||lcm.cdhistor||',%') );     --> Retornar quando passado         
  rw_craplcm_olt cr_craplcm_olt%ROWTYPE;    
          
  -- Busca de lan�amentos no periodo para a conta do associado
  CURSOR cr_craplcm_ign(pr_cdcooper  IN crapcop.cdcooper%TYPE  --> Cooperativa conectada
                   ,pr_nrdconta  IN crapass.nrdconta%TYPE  --> N�mero da conta
                   ,pr_dtiniper  IN crapdat.dtmvtolt%TYPE  --> Data movimento inicial
                   ,pr_dtfimper  IN crapdat.dtmvtolt%TYPE  --> Data movimento final
                       ,pr_cdhistor_ign IN craplcm.cdhistor%TYPE) IS
    SELECT lcm.nrdconta
          ,lcm.nrdolote
          ,lcm.dtmvtolt
          ,lcm.cdagenci
          ,lcm.cdhistor
          ,lcm.cdpesqbb
          ,lcm.cdbccxlt
          ,lcm.nrdocmto
          ,lcm.nrparepr
          ,lcm.vllanmto
          ,lcm.dsidenti
          ,lcm.dscedent
          ,lcm.nrdctabb
          ,lcm.nrseqava
          ,his.dsextrat
          ,his.indebcre
          ,his.inhistor
          ,his.dshistor
          ,lcm.rowid
      FROM craplcm lcm
          ,craphis his
     WHERE lcm.cdcooper = his.cdcooper
       AND lcm.cdhistor = his.cdhistor
       AND lcm.cdcooper = pr_cdcooper
       AND lcm.nrdconta = pr_nrdconta
       AND lcm.dtmvtolt BETWEEN pr_dtiniper AND pr_dtfimper
       AND lcm.cdhistor <> pr_cdhistor_ign;
       
   rw_craplcm_ign cr_craplcm_ign%ROWTYPE;

  /* Cursor com informa��es dos empr�stimos */
  CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                   ,pr_inliquid IN crapepr.inliquid%TYPE
                   ,pr_inprejuz IN crapepr.inprejuz%TYPE
                   ,pr_nrdconta IN crapepr.nrdconta%TYPE
                   ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
    SELECT epr.dtmvtolt
          ,epr.nrdconta
          ,epr.nrctremp
          ,epr.vlsdeved
          ,epr.vljuracu
          ,epr.dtultpag
          ,epr.inliquid
          ,epr.qtprepag
          ,epr.cdlcremp
          ,epr.txjuremp
          ,epr.cdempres
          ,epr.flgpagto
          ,epr.dtdpagto
          ,epr.vlpreemp
          ,epr.qtprecal
          ,epr.qtpreemp
          ,epr.qtmesdec
      FROM crapepr epr
     WHERE epr.cdcooper = pr_cdcooper
       AND epr.inliquid = NVL(pr_inliquid,epr.inliquid)
       AND epr.inprejuz = NVL(pr_inprejuz,epr.inprejuz)
       AND epr.nrdconta = nvl(pr_nrdconta,epr.nrdconta)
       AND epr.nrctremp = nvl(pr_nrctremp,epr.nrctremp);
  rw_crapepr cr_crapepr%ROWTYPE;

  -- Gurdar o Progress Recid da tabela de saldo
  vr_progress_recid crapsda.progress_recid%TYPE;

  --> Retornar o primeiro registro com data superior ou igual a data passada
  CURSOR cr_min_sda(pr_cdcooper   IN crapsda.cdcooper%TYPE
                   ,pr_nrdconta   IN crapsda.nrdconta%TYPE
                   ,pr_dtrefere   IN crapsda.dtmvtolt%TYPE) IS
    SELECT MIN(sda.progress_recid)
      FROM crapsda sda
     WHERE sda.cdcooper = pr_cdcooper
       AND sda.nrdconta = pr_nrdconta
       AND sda.dtmvtolt >= pr_dtrefere;

  --> Retornar o registro de saldo cfme Progress Recid passado
  CURSOR cr_crapsda(pr_progress_recid IN crapsda.progress_recid%TYPE) IS
    SELECT sda.nrdconta
          ,sda.dtmvtolt
          ,sda.vlsddisp
          ,sda.vlsdchsl
          ,sda.vlsdbloq
          ,sda.vlsdblpr
          ,sda.vlsdblfp
          ,sda.vlsdindi
          ,sda.vllimcre
          ,sda.cdcooper
          ,sda.vlsdeved
          ,sda.vldeschq
          ,sda.vllimutl
          ,sda.vladdutl
          ,sda.vlsdrdca
          ,sda.vlsdrdpp
          ,sda.vllimdsc
          ,sda.vlprepla
          ,sda.vlprerpp
          ,sda.vlcrdsal
          ,sda.qtchqliq
          ,sda.qtchqass
          ,sda.dtdsdclq
          ,sda.vltotpar
          ,sda.vlopcdia
          ,sda.vlavaliz
          ,sda.vlavlatr
          ,sda.qtdevolu
          ,sda.vltotren
          ,sda.vldestit
          ,sda.vllimtit
          ,sda.vlsdempr
          ,sda.vlsdfina
          ,sda.vlsrdc30
          ,sda.vlsrdc60
          ,sda.vlsrdcpr
          ,sda.vlsrdcpo
          ,sda.vlsdcota
      FROM crapsda sda
     WHERE sda.progress_recid = pr_progress_recid;
  rw_crapsda cr_crapsda%ROWTYPE;

  --> Retornar o registro de saldo cfme cdcooper, dtmvtolt e nrdconta passados
  CURSOR cr_crapsda_pk(pr_cdcooper IN crapsda.cdcooper%TYPE
                      ,pr_dtmvtolt IN crapsda.dtmvtolt%TYPE
                      ,pr_nrdconta IN crapsda.nrdconta%TYPE) IS
    SELECT sda.nrdconta
          ,sda.dtmvtolt
          ,sda.vlsddisp
          ,sda.vlsdchsl
          ,sda.vlsdbloq
          ,sda.vlsdblpr
          ,sda.vlsdblfp
          ,sda.vlsdindi
          ,sda.vllimcre
          ,sda.cdcooper
          ,sda.vlsdeved
          ,sda.vldeschq
          ,sda.vllimutl
          ,sda.vladdutl
          ,sda.vlsdrdca
          ,sda.vlsdrdpp
          ,sda.vllimdsc
          ,sda.vlprepla
          ,sda.vlprerpp
          ,sda.vlcrdsal
          ,sda.qtchqliq
          ,sda.qtchqass
          ,sda.dtdsdclq
          ,sda.vltotpar
          ,sda.vlopcdia
          ,sda.vlavaliz
          ,sda.vlavlatr
          ,sda.qtdevolu
          ,sda.vltotren
          ,sda.vldestit
          ,sda.vllimtit
          ,sda.vlsdempr
          ,sda.vlsdfina
          ,sda.vlsrdc30
          ,sda.vlsrdc60
          ,sda.vlsrdcpr
          ,sda.vlsrdcpo
          ,sda.vlsdcota
      FROM crapsda sda
     WHERE sda.cdcooper = pr_cdcooper
     AND   sda.dtmvtolt = pr_dtmvtolt
     AND   sda.nrdconta = pr_nrdconta;

  -- Verifica os envelopes nao processados, depositados no cash para o saldo bloqueado
  CURSOR cr_crapenl(pr_cdcooper   IN crapsda.cdcooper%TYPE
                   ,pr_nrdconta   IN crapsda.nrdconta%TYPE
                   ,pr_dtiniper   IN crapenl.dtmvtolt%TYPE DEFAULT NULL
                   ,pr_dtfimper   IN crapenl.dtmvtolt%TYPE DEFAULT NULL) IS
    SELECT enl.dtmvtolt
          ,enl.vldininf
          ,enl.vlchqinf
          ,enl.cdcoptfn
          ,enl.cdagetfn
          ,enl.nrterfin
          ,enl.nrseqenv
      FROM crapenl enl
     WHERE enl.cdcooper = pr_cdcooper
       AND enl.nrdconta = pr_nrdconta
       -- Filtra caso foi enviado data
       AND enl.dtmvtolt >= NVL(pr_dtiniper,enl.dtmvtolt)
       AND enl.dtmvtolt <= NVL(pr_dtfimper,enl.dtmvtolt)
       -- Nao liberado ou recolhido
       AND enl.cdsitenv IN(0,3)
     ORDER BY enl.progress_recid ASC;

  -- Selecionar os codigos de historico 'de-para' Cabal
  CURSOR cr_craphcb IS
    SELECT tbcrd.cdhistor
      FROM craphcb hcb,
           tbcrd_his_vinculo_bancoob tbcrd
     WHERE tbcrd.cdtrnbcb = hcb.cdtrnbcb;

  /* Tabelas de mem�ria para guardar registros cfme estrutura das Temp Tables */
  vr_tab_extr typ_tab_extrato_conta;    --> tt-extrato_conta
  vr_tab_depo typ_tab_dep_identificado; --> tt-dep-identificado

  -- Tipos e tabelas de mem�ria para armazenar as informa��es
  -- de tarifas e estornos de transferencias entre contas
  TYPE typ_reg_tarifa_transfe IS
    RECORD (cdbattaa VARCHAR2(10)  --> Tarifa TAA
           ,cdbatint VARCHAR2(10)  --> Tarifa Internet
           ,cdhistaa PLS_INTEGER   --> C�digo do hist�rico tarifa para TAA
           ,cdhsetaa PLS_INTEGER   --> C�digo do hist�rico estorno para TAA
           ,cdhisint PLS_INTEGER   --> C�digo do hist�rico tarifa para Internet
           ,cdhseint PLS_INTEGER   --> C�digo do hist�rico estorno para Internet
           ,vltarpro NUMBER        --> Valor da tarifa
           ,dtdivulg DATE          --> Data divulga��o tarifa
           ,dtvigenc DATE          --> Data vig�ncia da tarifa
           ,cdfvlcop PLS_INTEGER); --> Codigo faixa valor cooperativa);
  -- Tipo tabela para comportar um registro conforme acima
  TYPE typ_tab_tarifa_transfere IS
    TABLE OF typ_reg_tarifa_transfe
    INDEX BY VARCHAR2(11); --> A chave ser� a cdcooper(10) + tipo de pessoa(1)

  -- Vetor para armazenamento
  vr_tab_tarifa_transf typ_tab_tarifa_transfere;

  -- Tipos e tabelas de mem�ria para armazenar o tipo da pessoa de cada conta
  TYPE typ_tab_inpessoa IS
    TABLE OF crapass.inpessoa%TYPE
      INDEX BY VARCHAR2(20); --> A chave ser� a cdcooper(10) + conta(10)
  -- Vetor para armazenamento
  vr_tab_inpessoa typ_tab_inpessoa;

  /* Subrotina para buscar as tarifas de transferencia */
  PROCEDURE pc_busca_tarifa_transfere(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                     ,pr_dscritic OUT VARCHAR2) IS
  BEGIN
    --    Programa: pc_busca_tarifa_transfere
    --    Sistema : Conta-Corrente - Cooperativa de Credito
    --    Sigla   : CRED
    --    Autor   : Marcos (Supero)
    --    Data    : Ago/2013                         Ultima atualizacao: 27/08/2013
    --
    --    Dados referetes ao programa:
    --    Frequencia: Sempre que chamado pelos programas de extrato da conta
    --
    --    Objetivo  : Compor as informa��es das tarifas de trasnferencias entre contas
    --
    --    Alteracoes:
    DECLARE
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_tab_erro gene0001.typ_tab_erro;

       vr_idx VARCHAR2(20) := NULL;

    BEGIN
      -- Limpar o vetor
      --vr_tab_tarifa_transf.DELETE;

      ---------------------------- PESSOA FISICA ---------------------------------
      -- definir index
      vr_idx := lpad(pr_cdcooper,10,'0')||'1';

      -- Carregar as chaves de acesso das tarifas PF
      vr_tab_tarifa_transf(vr_idx).cdbattaa := 'TROUTTAAPF'; /* Pessoa F�sica via TAA */
      vr_tab_tarifa_transf(vr_idx).cdbatint := 'TROUTINTPF'; /* Pessoa F�sica via Internet */

      -- Carregar o restante das informa��es de tarifas TAA (PF)
      TARI0001.pc_carrega_dados_tar_vigente(pr_cdcooper  => pr_cdcooper                             -- Codigo Cooperativa
                                           ,pr_cdbattar  => vr_tab_tarifa_transf(vr_idx).cdbattaa   -- Codigo Tarifa
                                           ,pr_vllanmto  => 1                                       -- Valor Lancamento
                                           ,pr_cdprogra  => NULL                                    -- Codigo Programa
                                           ,pr_cdhistor  => vr_tab_tarifa_transf(vr_idx).cdhistaa   -- Codigo Historico
                                           ,pr_cdhisest  => vr_tab_tarifa_transf(vr_idx).cdhsetaa   -- Historico Estorno
                                           ,pr_vltarifa  => vr_tab_tarifa_transf(vr_idx).vltarpro   -- Valor tarifa
                                           ,pr_dtdivulg  => vr_tab_tarifa_transf(vr_idx).dtdivulg   -- Data Divulgacao
                                           ,pr_dtvigenc  => vr_tab_tarifa_transf(vr_idx).dtvigenc   -- Data Vigencia
                                           ,pr_cdfvlcop  => vr_tab_tarifa_transf(vr_idx).cdfvlcop   -- Codigo faixa valor cooperativa
                                           ,pr_cdcritic  => vr_cdcritic   -- Codigo Critica
                                           ,pr_dscritic  => pr_dscritic   -- Descricao Critica
                                           ,pr_tab_erro  => vr_tab_erro); -- Tabela erros
      -- Se houver algum retorno de erro
      IF vr_cdcritic > 0 OR pr_dscritic IS NOT NULL OR vr_tab_erro.COUNT > 0 THEN
        -- Sair com erro
        RAISE vr_exc_erro;
      END IF;

      -- Carregar o restante das informa��es de tarifas Internet (PF)
      TARI0001.pc_carrega_dados_tar_vigente(pr_cdcooper  => pr_cdcooper                             -- Codigo Cooperativa
                                           ,pr_cdbattar  => vr_tab_tarifa_transf(vr_idx).cdbatint   -- Codigo Tarifa
                                           ,pr_vllanmto  => 1                                       -- Valor Lancamento
                                           ,pr_cdprogra  => NULL                                    -- Codigo Programa
                                           ,pr_cdhistor  => vr_tab_tarifa_transf(vr_idx).cdhisint   -- Codigo Historico
                                           ,pr_cdhisest  => vr_tab_tarifa_transf(vr_idx).cdhseint   -- Historico Estorno
                                           ,pr_vltarifa  => vr_tab_tarifa_transf(vr_idx).vltarpro   -- Valor tarifa
                                           ,pr_dtdivulg  => vr_tab_tarifa_transf(vr_idx).dtdivulg   -- Data Divulgacao
                                           ,pr_dtvigenc  => vr_tab_tarifa_transf(vr_idx).dtvigenc   -- Data Vigencia
                                           ,pr_cdfvlcop  => vr_tab_tarifa_transf(vr_idx).cdfvlcop   -- Codigo faixa valor cooperativa
                                           ,pr_cdcritic  => vr_cdcritic   -- Codigo Critica
                                           ,pr_dscritic  => pr_dscritic   -- Descricao Critica
                                           ,pr_tab_erro  => vr_tab_erro); -- Tabela erros
      -- Se houver algum retorno de erro
      IF vr_cdcritic > 0 OR pr_dscritic IS NOT NULL OR vr_tab_erro.COUNT > 0 THEN
        -- Sair com erro
        RAISE vr_exc_erro;
      END IF;

      ---------------------------- PESSOA JURIDICA ---------------------------------
      -- definir index
      vr_idx := lpad(pr_cdcooper,10,'0')||'2';

      -- Carregar as chaves de acesso das tarifas
      vr_tab_tarifa_transf(vr_idx).cdbattaa := 'TROUTTAAPJ'; /* Pessoa Jur�dica via TAA */
      vr_tab_tarifa_transf(vr_idx).cdbatint := 'TROUTINTPJ'; /* Pessoa Jur�dica via Internet */

      -- Carregar o restante das informa��es de tarifas TAA (PJ)
      TARI0001.pc_carrega_dados_tar_vigente(pr_cdcooper  => pr_cdcooper                             -- Codigo Cooperativa
                                           ,pr_cdbattar  => vr_tab_tarifa_transf(vr_idx).cdbattaa   -- Codigo Tarifa
                                           ,pr_vllanmto  => 1                                       -- Valor Lancamento
                                           ,pr_cdprogra  => NULL                                    -- Codigo Programa
                                           ,pr_cdhistor  => vr_tab_tarifa_transf(vr_idx).cdhistaa   -- Codigo Historico
                                           ,pr_cdhisest  => vr_tab_tarifa_transf(vr_idx).cdhsetaa   -- Historico Estorno
                                           ,pr_vltarifa  => vr_tab_tarifa_transf(vr_idx).vltarpro   -- Valor tarifa
                                           ,pr_dtdivulg  => vr_tab_tarifa_transf(vr_idx).dtdivulg   -- Data Divulgacao
                                           ,pr_dtvigenc  => vr_tab_tarifa_transf(vr_idx).dtvigenc   -- Data Vigencia
                                           ,pr_cdfvlcop  => vr_tab_tarifa_transf(vr_idx).cdfvlcop   -- Codigo faixa valor cooperativa
                                           ,pr_cdcritic  => vr_cdcritic   -- Codigo Critica
                                           ,pr_dscritic  => pr_dscritic   -- Descricao Critica
                                           ,pr_tab_erro  => vr_tab_erro); -- Tabela erros
      -- Se houver algum retorno de erro
      IF vr_cdcritic > 0 OR pr_dscritic IS NOT NULL OR vr_tab_erro.COUNT > 0 THEN
        -- Sair com erro
        RAISE vr_exc_erro;
      END IF;

      -- Carregar o restante das informa��es de tarifas Internet (PJ)
      TARI0001.pc_carrega_dados_tar_vigente(pr_cdcooper  => pr_cdcooper                             -- Codigo Cooperativa
                                           ,pr_cdbattar  => vr_tab_tarifa_transf(vr_idx).cdbatint   -- Codigo Tarifa
                                           ,pr_vllanmto  => 1                                       -- Valor Lancamento
                                           ,pr_cdprogra  => NULL                                    -- Codigo Programa
                                           ,pr_cdhistor  => vr_tab_tarifa_transf(vr_idx).cdhisint   -- Codigo Historico
                                           ,pr_cdhisest  => vr_tab_tarifa_transf(vr_idx).cdhseint   -- Historico Estorno
                                           ,pr_vltarifa  => vr_tab_tarifa_transf(vr_idx).vltarpro   -- Valor tarifa
                                           ,pr_dtdivulg  => vr_tab_tarifa_transf(vr_idx).dtdivulg   -- Data Divulgacao
                                           ,pr_dtvigenc  => vr_tab_tarifa_transf(vr_idx).dtvigenc   -- Data Vigencia
                                           ,pr_cdfvlcop  => vr_tab_tarifa_transf(vr_idx).cdfvlcop   -- Codigo faixa valor cooperativa
                                           ,pr_cdcritic  => vr_cdcritic   -- Codigo Critica
                                           ,pr_dscritic  => pr_dscritic   -- Descricao Critica
                                           ,pr_tab_erro  => vr_tab_erro); -- Tabela erros
      -- Se houver algum retorno de erro
      IF vr_cdcritic > 0 OR pr_dscritic IS NOT NULL OR vr_tab_erro.COUNT > 0 THEN
        -- Sair com erro
        RAISE vr_exc_erro;
      END IF;
      
      -- Para o inpessoa = 3, deve carregar as informacoes do inpessoa = 2
      -- definir index
      vr_idx := lpad(pr_cdcooper,10,'0')||'3';
      -- Carregar as chaves de acesso das tarifas
      vr_tab_tarifa_transf(vr_idx).cdbattaa := vr_tab_tarifa_transf(lpad(pr_cdcooper,10,'0')||'2').cdbattaa; /* Pessoa Jur�dica via TAA */
      vr_tab_tarifa_transf(vr_idx).cdbatint := vr_tab_tarifa_transf(lpad(pr_cdcooper,10,'0')||'2').cdbatint; /* Pessoa Jur�dica via Internet */
      vr_tab_tarifa_transf(vr_idx).cdhistaa := vr_tab_tarifa_transf(lpad(pr_cdcooper,10,'0')||'2').cdhistaa;  -- Codigo Historico
      vr_tab_tarifa_transf(vr_idx).cdhsetaa := vr_tab_tarifa_transf(lpad(pr_cdcooper,10,'0')||'2').cdhsetaa;  -- Historico Estorno
      vr_tab_tarifa_transf(vr_idx).vltarpro := vr_tab_tarifa_transf(lpad(pr_cdcooper,10,'0')||'2').vltarpro;  -- Valor tarifa
      vr_tab_tarifa_transf(vr_idx).dtdivulg := vr_tab_tarifa_transf(lpad(pr_cdcooper,10,'0')||'2').dtdivulg;  -- Data Divulgacao
      vr_tab_tarifa_transf(vr_idx).dtvigenc := vr_tab_tarifa_transf(lpad(pr_cdcooper,10,'0')||'2').dtvigenc;  -- Data Vigencia
      vr_tab_tarifa_transf(vr_idx).cdfvlcop := vr_tab_tarifa_transf(lpad(pr_cdcooper,10,'0')||'2').cdfvlcop;  -- Codigo faixa valor cooperativa
      vr_tab_tarifa_transf(vr_idx).cdhisint := vr_tab_tarifa_transf(lpad(pr_cdcooper,10,'0')||'2').cdhisint;  -- Codigo Historico
      vr_tab_tarifa_transf(vr_idx).cdhseint := vr_tab_tarifa_transf(lpad(pr_cdcooper,10,'0')||'2').cdhseint;  -- Historico Estorno

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Se veio apenas o c�digo
        IF vr_cdcritic > 0 AND pr_dscritic IS NULL THEN
          -- Buscar a descri��o
          pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        -- Se por algum motivo ainda n�o existe erro na pr_dscritic
        -- mas existe informa��o na vr_tab_erro
        IF pr_dscritic IS NULL AND vr_tab_erro.COUNT > 0 THEN
          -- Usamos a descri��o do primeiro registro da tabela de erro
          pr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        END IF;
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_dscritic := 'Erro nao tratado na rotina EXTR0001.pc_busca_tarifa_transfere: '||sqlerrm;
    END;

  END pc_busca_tarifa_transfere;

  /* Fun��o para buscar o tipo da pessoa da conta passada */
  FUNCTION fn_inpessoa_nrdconta(pr_cdcooper IN crapcop.cdcooper%TYPE
                               ,pr_nrdconta IN crapass.nrdconta%TYPE
                               ,pr_flgcrass IN BOOLEAN DEFAULT TRUE) RETURN crapass.inpessoa%TYPE IS
  BEGIN
    --    Programa: fn_inpessoa_nrdconta
    --    Sistema : Conta-Corrente - Cooperativa de Credito
    --    Sigla   : CRED
    --    Autor   : Marcos (Supero)
    --    Data    : Ago/2013                         Ultima atualizacao: 14/08/2014
    --
    --    Dados referetes ao programa:
    --    Frequencia: Sempre que chamado pelos programas de extrato da conta
    --
    --    Objetivo  : Buscar o tipo de pessoa de determinada conta
    --         Obs  : Essa fun��o usa o vetor vr_tab_inpessoa, e se o mesmo
    --                n�o estiver carregado, ent�o ele � eliminado
    --
    --    Alteracoes: 14/08/2014 - Ajuste para filtrar a conta no cursor
    --                             cr_crapass. (James)
    --
    DECLARE
      -- Busca dos associados da cooperativa
      CURSOR cr_crapass_all IS
        SELECT inpessoa,
               nrdconta
          FROM crapass
         WHERE cdcooper = pr_cdcooper;

      CURSOR cr_crapass(pr_cdcooper IN crapass.cdcooper%TYPE,
                        pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT inpessoa
          FROM crapass
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      vr_inpessoa crapass.inpessoa%TYPE;

      vr_idx VARCHAR2(20) := NULL;
    BEGIN
      /* Verifica se a consulta do tipo da pessoa sera feito por processo BATCH */
      IF pr_flgcrass THEN
        -- Se o vetor ainda n�o foi carregado
        IF NOT vr_tab_inpessoa.EXISTS(lpad(pr_cdcooper,10,'0')||lpad('0',10,'0')) THEN
          -- Buscar todos os associados
          FOR rw_crapass IN cr_crapass_all LOOP
            -- definir index
            vr_idx := lpad(pr_cdcooper,10,'0')||lpad(rw_crapass.nrdconta,10,'0');
            -- Carregar o vetor chaveando pela conta
            vr_tab_inpessoa(vr_idx) := rw_crapass.inpessoa;
          END LOOP;
          --criar registro de controle para identificar que j� carregou a cooperativa
          vr_tab_inpessoa(lpad(pr_cdcooper,10,'0')||lpad('0',10,'0')) := 1;
        END IF;

        -- definir index
        vr_idx := lpad(pr_cdcooper,10,'0')||lpad(pr_nrdconta,10,'0');
        -- Se a conta atual n�o existir no vetor
        IF NOT vr_tab_inpessoa.exists(vr_idx) THEN
          -- Retornar zero e testar na rotina chamadora
          vr_inpessoa := 0;
        ELSE
          -- Retornar o tipo armazenado no vetor pela conta
          vr_inpessoa := vr_tab_inpessoa(vr_idx);
        END IF;
      ELSE
        /* Buscar os dados da tabela crapdat */
        OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                        ,pr_nrdconta => pr_nrdconta);
        FETCH cr_crapass
         INTO vr_inpessoa;
        CLOSE cr_crapass;
      END IF;

      RETURN vr_inpessoa;

    END;
  END fn_inpessoa_nrdconta;

  /* Rotina utilizada para compor saldo do dia para procedure obtem-saldo-dia */
  PROCEDURE pc_compor_saldo_dia(pr_vllanmto     IN craplcm.vllanmto%TYPE
                               ,pr_inhistor       IN craphis.inhistor%TYPE
                               ,pr_vlsddisp IN OUT crapsda.vlsddisp%TYPE
                               ,pr_vlsdchsl IN OUT crapsda.vlsdchsl%TYPE
                               ,pr_vlsdbloq IN OUT crapsda.vlsdbloq%TYPE
                               ,pr_vlsdblpr IN OUT crapsda.vlsdblpr%TYPE
                               ,pr_vlsdblfp IN OUT crapsda.vlsdblfp%TYPE
                               ,pr_vlsdindi IN OUT crapsda.vlsdindi%TYPE
                               ,pr_des_reto    OUT VARCHAR2 --> OK ou NOK
                               ,pr_cdcritic    OUT crapcri.cdcritic%TYPE) AS
  BEGIN
    --    Programa: pc_compor_saldo_dia (antigo BO b1wgen0001.compor-saldo-dia)
    --    Sistema : Conta-Corrente - Cooperativa de Credito
    --    Sigla   : CRED
    --    Autor   : Marcos (Supero)
    --    Data    : Dez/2012                         Ultima atualizacao: 02/12/2012
    --
    --    Dados referetes ao programa:
    --    Frequencia: Sempre que chamado pelos programas de extrato da conta
    --
    --    Objetivo  : Compor o saldo do dia conforme o lan�amento e historio passado
    --
    --    Alteracoes: 05/12/2012 - Convers�o de Progress >> Oracle PLSQL
    BEGIN
      -- Conforme cada tipo de lan�amento do hist�rico
      CASE pr_inhistor
        WHEN 1 THEN --> credito no vlsddisp
          pr_vlsddisp := nvl(pr_vlsddisp,0) + nvl(pr_vllanmto,0);
        WHEN 2 THEN --> credito no vlsdchsl
          pr_vlsdchsl := nvl(pr_vlsdchsl,0) + nvl(pr_vllanmto,0);
        WHEN 3 THEN --> credito no vlsdbloq
          pr_vlsdbloq := nvl(pr_vlsdbloq,0) + nvl(pr_vllanmto,0);
        WHEN 4 THEN --> credito no vlsdblpr
          pr_vlsdblpr := nvl(pr_vlsdblpr,0) + nvl(pr_vllanmto,0);
        WHEN 5 THEN --> credito no vlsdblfp
          pr_vlsdblfp := nvl(pr_vlsdblfp,0) + nvl(pr_vllanmto,0);
        WHEN 6 THEN --> credito no vldcotas
          pr_vlsdindi := nvl(pr_vlsdindi,0) + nvl(pr_vllanmto,0);
        WHEN 11 THEN --> debito no vlsddisp
          pr_vlsddisp := nvl(pr_vlsddisp,0) - nvl(pr_vllanmto,0);
        WHEN 12 THEN --> debito no vlsdchsl
          pr_vlsdchsl := nvl(pr_vlsdchsl,0) - nvl(pr_vllanmto,0);
        WHEN 13 THEN --> debito no vlsdbloq
          pr_vlsdbloq := nvl(pr_vlsdbloq,0) - nvl(pr_vllanmto,0);
        WHEN 14 THEN --> debito no vlsdblpr
          pr_vlsdblpr := nvl(pr_vlsdblpr,0) - nvl(pr_vllanmto,0);
        WHEN 15 THEN --> debito no vlsdblfp
          pr_vlsdblfp := nvl(pr_vlsdblfp,0) - nvl(pr_vllanmto,0);
        WHEN 16 THEN --> debito no vldcotas
          pr_vlsdindi := nvl(pr_vlsdindi,0) - nvl(pr_vllanmto,0);
        ELSE
          -- Gerar cr�tica
          pr_cdcritic := 83;
          -- Sair com erro
          RAISE vr_exc_erro;
      END CASE;
      -- Chegou ao final sem problemas
      pr_des_reto := 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
    END;
  END pc_compor_saldo_dia;

  /* Apenas faz a chamada para pc_obtem_saldo_dia */
  PROCEDURE pc_obtem_saldo_dia_sd(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                 ,pr_cdagenci   IN crapass.cdagenci%TYPE
                                 ,pr_nrdcaixa   IN craperr.nrdcaixa%TYPE
                                 ,pr_cdoperad   IN craplgm.cdoperad%TYPE
                                 ,pr_nrdconta   IN crapass.nrdconta%TYPE
                                 ,pr_vllimcre   IN crapass.vllimcre%TYPE
                                 ,pr_tipo_busca IN VARCHAR2 DEFAULT 'A' /* I=usa dtrefere, A=Usa dtrefere-1, P=Usa dtrefere+1 */
                                 ,pr_des_reto  OUT VARCHAR2 --> OK ou NOK
                                 ,pr_tab_sald  OUT EXTR0001.typ_tab_saldos
                                 ,pr_tab_erro  OUT GENE0001.typ_tab_erro) AS

    --    Programa: pc_obtem_saldo_dia_sd
    --    Sistema : CECRED
    --    Sigla   : CRED
    --    Ultima atualizacao: 21/11/2014
    --
    --    Dados referetes ao programa:
    --    Objetivo  : Apenas faz a chamada para pc_obtem_saldo_dia
    --
    --    Alteracoes: 21/11/2014 - Alterado a vari�vel de valida��o da cr�tica
    --                             (Douglas - Chamado 186184/192128)

  BEGIN
    DECLARE
      -- Descri��o e c�digo da critica
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);

      -- CURSOR GEN�RICO DE CALEND�RIO
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    BEGIN

      -- DATAS DA COOPERATIVA
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);

      FETCH btch0001.cr_crapdat INTO rw_crapdat;

      IF btch0001.cr_crapdat%NOTFOUND THEN

        -- FECHAR CR_CRAPDAT CURSOR POIS HAVER� RAISE
        CLOSE btch0001.cr_crapdat;

        -- MONTAR MENSAGEM DE CRITICA
        vr_cdcritic := 1;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);

        -- Chamar rotina de grava��o de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

        RAISE vr_exc_erro;
      ELSE
        -- APENAS FECHAR O CURSOR
        CLOSE btch0001.cr_crapdat;
      END IF;

      -- OBTEN��O DO SALDO DA CONTA
      extr0001.pc_obtem_saldo_dia(pr_cdcooper   => pr_cdcooper,
                                  pr_rw_crapdat => rw_crapdat,
                                  pr_cdagenci   => pr_cdagenci,
                                  pr_nrdcaixa   => pr_nrdcaixa,
                                  pr_cdoperad   => pr_cdoperad,
                                  pr_nrdconta   => pr_nrdconta,
                                  pr_vllimcre   => pr_vllimcre,
                                  pr_dtrefere   => rw_crapdat.dtmvtopr,
                                  pr_flgcrass   => FALSE, -- N�o deve carregar todas as contas em mem�ria, apenas a conta em quest�o
                                  pr_tipo_busca => pr_tipo_busca,
                                  pr_des_reto   => pr_des_reto,
                                  pr_tab_sald   => pr_tab_sald,
                                  pr_tab_erro   => pr_tab_erro);

      --Se ocorreu erro
      IF pr_des_reto <> 'OK' THEN
        -- Tenta buscar o erro no vetor de erro
        IF pr_tab_erro.COUNT = 0 THEN

          vr_cdcritic:= 0;
          vr_dscritic:= 'Retorno NOK na extr0001.pc_obtem_saldo_dia_sd e sem informa��o na pr_tab_erro, Conta: '|| pr_nrdconta;

          -- Chamar rotina de grava��o de erro
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);

        END IF;
        --Levantar Excecao
        RAISE vr_exc_erro;

      END IF;

      -- Chegou ao final sem problemas
      pr_des_reto := 'OK';

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
    END;
  END pc_obtem_saldo_dia_sd;

  /* Efetua uma consulta sobre o saldo do cooperado.
     Possui a mesma funcionalidade da rotina acima, porem utiliza gravacao em tabelas para serem
     chamadas diretamente atraves de rotinas progress */
  PROCEDURE pc_obtem_saldo_dia_sd_wt(pr_cdcooper   IN crapcop.cdcooper%TYPE  --> Cooperativa
                                    ,pr_cdagenci   IN crapass.cdagenci%TYPE  --> Codigo da agencia
                                    ,pr_nrdcaixa   IN craperr.nrdcaixa%TYPE  --> Numero do caixa
                                    ,pr_cdoperad   IN craplgm.cdoperad%TYPE  --> C�digo do operador
                                    ,pr_nrdconta   IN crapass.nrdconta%TYPE  --> Conta do associado
                                    ,pr_vllimcre   IN crapass.vllimcre%TYPE  --> Valor do limite de cr�dito
                                    ,pr_tipo_busca IN VARCHAR2 DEFAULT 'A' /* I=usa dtrefere, A=Usa dtrefere-1, P=Usa dtrefere+1 */
                                    ,pr_cdcritic  OUT crapcri.cdcritic%type --> Codigo de Erro
                                    ,pr_dscritic  OUT VARCHAR2) IS          --> Descricao de Erro
    vr_des_reto VARCHAR2(03);           --> OK ou NOK
    vr_tab_erro GENE0001.typ_tab_erro;  --> Tabela com erros
    vr_tab_saldos  typ_tab_saldos;      --> Tabela de retorno da rotina
    vr_ind PLS_INTEGER;                 --> Indice da tabela de retorno
  BEGIN
    -- Limpa a tabela temporaria de interface
    BEGIN
      DELETE wt_saldos;
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro ao excluir wt_saldo: '||SQLERRM;
        RETURN;
    END;

    pc_obtem_saldo_dia_sd(pr_cdcooper => pr_cdcooper
                         ,pr_cdagenci => pr_cdagenci
                         ,pr_nrdcaixa => pr_nrdcaixa
                         ,pr_cdoperad => pr_cdoperad
                         ,pr_nrdconta => pr_nrdconta
                         ,pr_vllimcre => pr_vllimcre
                         ,pr_tipo_busca => pr_tipo_busca
                         ,pr_des_reto => vr_des_reto
                         ,pr_tab_sald => vr_tab_saldos
                         ,pr_tab_erro => vr_tab_erro);

    -- Verifica se deu erro
    IF vr_des_reto = 'NOK' THEN
      pr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
      pr_cdcritic := vr_tab_erro(vr_tab_erro.first).dscritic;
      RETURN;
    ELSE -- Se nao ocorreu erro, percorre a tabela de retorno e efetua o insert na tabela de interface
      vr_ind := vr_tab_saldos.first; -- Vai para o primeiro registro

      -- loop sobre a tabela de retorno
      WHILE vr_ind IS NOT NULL LOOP
        -- Insere na tabela de interface
        BEGIN
          INSERT INTO wt_saldos
            (nrdconta
            ,dtmvtolt
            ,vlsddisp
            ,vlsdchsl
            ,vlsdbloq
            ,vlsdblpr
            ,vlsdblfp
            ,vlsdindi
            ,vllimcre
            ,cdcooper
            ,vlsdeved
            ,vldeschq
            ,vllimutl
            ,vladdutl
            ,vlsdrdca
            ,vlsdrdpp
            ,vllimdsc
            ,vlprepla
            ,vlprerpp
            ,vlcrdsal
            ,qtchqliq
            ,qtchqass
            ,dtdsdclq
            ,vltotpar
            ,vlopcdia
            ,vlavaliz
            ,vlavlatr
            ,qtdevolu
            ,vltotren
            ,vldestit
            ,vllimtit
            ,vlsdempr
            ,vlsdfina
            ,vlsrdc30
            ,vlsrdc60
            ,vlsrdcpr
            ,vlsrdcpo
            ,vlblqjud
            ,vlsdcota
            ,vlblqtaa)
            VALUES
            (vr_tab_saldos(vr_ind).nrdconta
            ,vr_tab_saldos(vr_ind).dtmvtolt
            ,vr_tab_saldos(vr_ind).vlsddisp
            ,vr_tab_saldos(vr_ind).vlsdchsl
            ,vr_tab_saldos(vr_ind).vlsdbloq
            ,vr_tab_saldos(vr_ind).vlsdblpr
            ,vr_tab_saldos(vr_ind).vlsdblfp
            ,vr_tab_saldos(vr_ind).vlsdindi
            ,vr_tab_saldos(vr_ind).vllimcre
            ,vr_tab_saldos(vr_ind).cdcooper
            ,vr_tab_saldos(vr_ind).vlsdeved
            ,vr_tab_saldos(vr_ind).vldeschq
            ,vr_tab_saldos(vr_ind).vllimutl
            ,vr_tab_saldos(vr_ind).vladdutl
            ,vr_tab_saldos(vr_ind).vlsdrdca
            ,vr_tab_saldos(vr_ind).vlsdrdpp
            ,vr_tab_saldos(vr_ind).vllimdsc
            ,vr_tab_saldos(vr_ind).vlprepla
            ,vr_tab_saldos(vr_ind).vlprerpp
            ,vr_tab_saldos(vr_ind).vlcrdsal
            ,vr_tab_saldos(vr_ind).qtchqliq
            ,vr_tab_saldos(vr_ind).qtchqass
            ,vr_tab_saldos(vr_ind).dtdsdclq
            ,vr_tab_saldos(vr_ind).vltotpar
            ,vr_tab_saldos(vr_ind).vlopcdia
            ,vr_tab_saldos(vr_ind).vlavaliz
            ,vr_tab_saldos(vr_ind).vlavlatr
            ,vr_tab_saldos(vr_ind).qtdevolu
            ,vr_tab_saldos(vr_ind).vltotren
            ,vr_tab_saldos(vr_ind).vldestit
            ,vr_tab_saldos(vr_ind).vllimtit
            ,vr_tab_saldos(vr_ind).vlsdempr
            ,vr_tab_saldos(vr_ind).vlsdfina
            ,vr_tab_saldos(vr_ind).vlsrdc30
            ,vr_tab_saldos(vr_ind).vlsrdc60
            ,vr_tab_saldos(vr_ind).vlsrdcpr
            ,vr_tab_saldos(vr_ind).vlsrdcpo
            ,vr_tab_saldos(vr_ind).vlblqjud
            ,vr_tab_saldos(vr_ind).vlsdcota
            ,vr_tab_saldos(vr_ind).vlblqtaa);
        EXCEPTION
          WHEN OTHERS THEN
            pr_cdcritic := 0;
            pr_dscritic := 'Erro ao inserir na tabela wt_saldos: '||SQLERRM;
            RETURN;
        END;

        -- Vai para o proximo registro
        vr_ind := vr_tab_saldos.next(vr_ind);

      END LOOP;
    END IF;
  END;


  /* Possui a mesma funcionalidade da rotina pc_obtem_saldo_dia,
     porem utiliza gravacao em tabelas para serem
     chamadas diretamente atraves de rotinas progress */
  PROCEDURE pc_obtem_saldo_dia_prog (pr_cdcooper   IN crapcop.cdcooper%TYPE  --> Cooperativa
                                    ,pr_cdagenci   IN crapass.cdagenci%TYPE  --> Codigo da agencia
                                    ,pr_nrdcaixa   IN craperr.nrdcaixa%TYPE  --> Numero do caixa
                                    ,pr_cdoperad   IN craplgm.cdoperad%TYPE  --> C�digo do operador
                                    ,pr_nrdconta   IN crapass.nrdconta%TYPE  --> Conta do associado
                                    ,pr_dtrefere   IN crapdat.dtmvtolt%TYPE  --> Data de referencia
                                    ,pr_tipo_busca IN VARCHAR2 DEFAULT 'A'   --> /* I=usa dtrefere, A=Usa dtrefere-1, P=Usa dtrefere+1 */
                                    ,pr_cdcritic  OUT crapcri.cdcritic%type  --> Codigo de Erro
                                    ,pr_dscritic  OUT VARCHAR2) IS           --> Descricao de Erro

    /* ..........................................................................

        Programa : pc_obtem_saldo_dia_prog
        Sistema  : Conta-Corrente - Cooperativa de Credito
        Sigla    : CRED
        Autor    : Odirlei Busana - AMcom
        Data     : Maio/2015.                   Ultima atualizacao: 17/11/2015

        Dados referentes ao programa:

         Frequencia: Sempre que for chamado
         Objetivo  : Possui a mesma funcionalidade da rotina pc_obtem_saldo_dia,
                     porem utiliza gravacao em tabelas para serem
                     chamadas diretamente atraves de rotinas progress

        Altera��o : 17/11/2015 - Alterado para que na procedure pc_obtem_saldo_dia seja carregado 
                                 o campo crapsda.vlsdcota na vr_tab_saldo, e que o valor seja
                                 gravado na wt_saldos. (Douglas - Chamado 285228)

                    22/12/2015 - Ajustado parametro pr_flgcrass para FALSE na chamada de
                                 pc_obtem_saldo_dia. (Douglas - Chamado 285228)
    ..........................................................................*/


    ------------> CURSORES <------------
    -- Cursor para encontrar a conta/corrente
    CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                     ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ass.inpessoa
            ,ass.nrdconta
            ,ass.vllimcre
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

    -------------> VARIAVEIS <-----------
    vr_des_reto    VARCHAR2(03);           --> OK ou NOK
    vr_tab_erro    GENE0001.typ_tab_erro;  --> Tabela com erros
    vr_tab_saldos  typ_tab_saldos;         --> Tabela de retorno da rotina
    vr_ind         PLS_INTEGER;            --> Indice da tabela de retorno
    vr_cdcritic    NUMBER;
    vr_dscritic    VARCHAR2(1000);
    rw_crapdat    btch0001.cr_crapdat%ROWTYPE;

  BEGIN
    -- Limpa a tabela temporaria de interface
    BEGIN
      DELETE wt_saldos;
    EXCEPTION
      WHEN OTHERS THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro ao excluir wt_saldo: '||SQLERRM;
        RAISE vr_exc_erro;
    END;

    -- DATAS DA COOPERATIVA
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- FECHAR CR_CRAPDAT CURSOR POIS HAVER� RAISE
      CLOSE btch0001.cr_crapdat;

      -- MONTAR MENSAGEM DE CRITICA
      vr_cdcritic := 1;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);
      RAISE vr_exc_erro;
    ELSE
      -- APENAS FECHAR O CURSOR
      CLOSE btch0001.cr_crapdat;
    END IF;

    -- Buscar limite de credito
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;

    -- Se n�o encontrar
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;

      -- Monta critica
      vr_cdcritic := 9;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      -- Gera exce��o
      RAISE vr_exc_erro;

    ELSE
      -- Fecha o cursor
      CLOSE cr_crapass;
    END IF;

    -- OBTEN��O DO SALDO DA CONTA
    extr0001.pc_obtem_saldo_dia(pr_cdcooper   => pr_cdcooper,
                                pr_rw_crapdat => rw_crapdat,
                                pr_cdagenci   => pr_cdagenci,
                                pr_nrdcaixa   => pr_nrdcaixa,
                                pr_cdoperad   => pr_cdoperad,
                                pr_nrdconta   => pr_nrdconta,
                                pr_vllimcre   => rw_crapass.vllimcre,
                                pr_flgcrass   => FALSE, -- N�o deve carregar todas as contas em mem�ria, apenas a conta em quest�o
                                pr_tipo_busca => pr_tipo_busca,
                                pr_dtrefere   => pr_dtrefere,
                                pr_des_reto   => vr_des_reto,
                                pr_tab_sald   => vr_tab_saldos,
                                pr_tab_erro   => vr_tab_erro);

     -- Verifica se deu erro
    IF vr_des_reto = 'NOK' THEN
      vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
      vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
      RAISE vr_exc_erro;
    ELSE
      -- Se nao ocorreu erro, percorre a tabela de retorno e efetua o insert na tabela de interface
      vr_ind := vr_tab_saldos.first; -- Vai para o primeiro registro
      -- loop sobre a tabela de retorno
      WHILE vr_ind IS NOT NULL LOOP
        -- Insere na tabela de interface
        BEGIN
          INSERT INTO wt_saldos
            (nrdconta
            ,dtmvtolt
            ,vlsddisp
            ,vlsdchsl
            ,vlsdbloq
            ,vlsdblpr
            ,vlsdblfp
            ,vlsdindi
            ,vllimcre
            ,cdcooper
            ,vlsdeved
            ,vldeschq
            ,vllimutl
            ,vladdutl
            ,vlsdrdca
            ,vlsdrdpp
            ,vllimdsc
            ,vlprepla
            ,vlprerpp
            ,vlcrdsal
            ,qtchqliq
            ,qtchqass
            ,dtdsdclq
            ,vltotpar
            ,vlopcdia
            ,vlavaliz
            ,vlavlatr
            ,qtdevolu
            ,vltotren
            ,vldestit
            ,vllimtit
            ,vlsdempr
            ,vlsdfina
            ,vlsrdc30
            ,vlsrdc60
            ,vlsrdcpr
            ,vlsrdcpo
            ,vlblqjud
            ,vlsdcota
            ,vlblqtaa)
            VALUES
            (vr_tab_saldos(vr_ind).nrdconta
            ,vr_tab_saldos(vr_ind).dtmvtolt
            ,vr_tab_saldos(vr_ind).vlsddisp
            ,vr_tab_saldos(vr_ind).vlsdchsl
            ,vr_tab_saldos(vr_ind).vlsdbloq
            ,vr_tab_saldos(vr_ind).vlsdblpr
            ,vr_tab_saldos(vr_ind).vlsdblfp
            ,vr_tab_saldos(vr_ind).vlsdindi
            ,vr_tab_saldos(vr_ind).vllimcre
            ,vr_tab_saldos(vr_ind).cdcooper
            ,vr_tab_saldos(vr_ind).vlsdeved
            ,vr_tab_saldos(vr_ind).vldeschq
            ,vr_tab_saldos(vr_ind).vllimutl
            ,vr_tab_saldos(vr_ind).vladdutl
            ,vr_tab_saldos(vr_ind).vlsdrdca
            ,vr_tab_saldos(vr_ind).vlsdrdpp
            ,vr_tab_saldos(vr_ind).vllimdsc
            ,vr_tab_saldos(vr_ind).vlprepla
            ,vr_tab_saldos(vr_ind).vlprerpp
            ,vr_tab_saldos(vr_ind).vlcrdsal
            ,vr_tab_saldos(vr_ind).qtchqliq
            ,vr_tab_saldos(vr_ind).qtchqass
            ,vr_tab_saldos(vr_ind).dtdsdclq
            ,vr_tab_saldos(vr_ind).vltotpar
            ,vr_tab_saldos(vr_ind).vlopcdia
            ,vr_tab_saldos(vr_ind).vlavaliz
            ,vr_tab_saldos(vr_ind).vlavlatr
            ,vr_tab_saldos(vr_ind).qtdevolu
            ,vr_tab_saldos(vr_ind).vltotren
            ,vr_tab_saldos(vr_ind).vldestit
            ,vr_tab_saldos(vr_ind).vllimtit
            ,vr_tab_saldos(vr_ind).vlsdempr
            ,vr_tab_saldos(vr_ind).vlsdfina
            ,vr_tab_saldos(vr_ind).vlsrdc30
            ,vr_tab_saldos(vr_ind).vlsrdc60
            ,vr_tab_saldos(vr_ind).vlsrdcpr
            ,vr_tab_saldos(vr_ind).vlsrdcpo
            ,vr_tab_saldos(vr_ind).vlblqjud
            ,vr_tab_saldos(vr_ind).vlsdcota
            ,vr_tab_saldos(vr_ind).vlblqtaa);
        EXCEPTION
          WHEN OTHERS THEN
            pr_cdcritic := 0;
            pr_dscritic := 'Erro ao inserir na tabela wt_saldos: '||SQLERRM;
            RETURN;
        END;

        -- Vai para o proximo registro
        vr_ind := vr_tab_saldos.next(vr_ind);

      END LOOP;

    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro ao buscar saldo(EXTR0001.pc_obtem_saldo_dia_prog): '|| SQLERRM;

  END pc_obtem_saldo_dia_prog;

  /* Obten��o do saldo da conta sem o dia fechado */
  PROCEDURE pc_obtem_saldo_dia(pr_cdcooper   IN crapcop.cdcooper%TYPE
                              ,pr_rw_crapdat IN btch0001.cr_crapdat%ROWTYPE
                              ,pr_cdagenci   IN crapass.cdagenci%TYPE
                              ,pr_nrdcaixa   IN craperr.nrdcaixa%TYPE
                              ,pr_cdoperad   IN craplgm.cdoperad%TYPE
                              ,pr_nrdconta   IN crapass.nrdconta%TYPE
                              ,pr_vllimcre   IN crapass.vllimcre%TYPE
                              ,pr_dtrefere   IN crapdat.dtmvtolt%TYPE
                              ,pr_flgcrass   IN BOOLEAN DEFAULT TRUE
                              ,pr_tipo_busca IN VARCHAR2 DEFAULT 'A' /* I=usa dtrefere, A=Usa dtrefere-1, P=Usa dtrefere+1 */
                              ,pr_des_reto  OUT VARCHAR2 --> OK ou NOK
                              ,pr_tab_sald  OUT EXTR0001.typ_tab_saldos
                              ,pr_tab_erro  OUT GENE0001.typ_tab_erro) AS
  BEGIN
    --    Programa: pc_obtem_saldo_dia (antigo BO b1wgen0001.obtem-saldo-dia)
    --    Sistema : Conta-Corrente - Cooperativa de Credito
    --    Sigla   : CRED
    --    Autor   : Marcos (Supero)
    --    Data    : Dez/2012                         Ultima atualizacao: 17/11/2015
    --
    --    Dados referetes ao programa:
    --    Frequencia: Sempre que chamado pelos programas de extrato da conta
    --
    --    Objetivo  : Retornar um registro com o saldo da conta no dia processando
    --                todos os lan�amentos pendentes de concilia��o
    --
    --    Alteracoes: 05/12/2012 - Convers�o de Progress >> Oracle PLSQL
    --
    --                29/01/2013 - Inclusao historicos 1109 e 1110 na busca dos lan�amentos
    --
    --                02/05/2013 - Inclus�o de ajustes para trasnfer�ncia intercooperativa (Marcos-Supero)
    --
    --                04/06/2013 - Buscar Saldo Bloqueado Judicial e grava nas pltable (Marcos-Supero)
    --
    --                27/08/2013 - Ajustes para buscar os hist�ricos de transferencia entre contas n�o mais
    --                             fixamente, mas sim a partir das informa��es do vetor vr_tab_tarifa_transf (Marcos-Supero)
    --
    --                14/08/2014 - Incluir o parametro pr_flgcrass, para verificar se carrega todos os associados. (James)
    --
    --                24/09/2014 - Ajuste para compor o credito do emprestimo no dia. (James)
    --
    --                30/10/2014 - Incluir o hist�rico 530 na lista de hist�ricos verificados
    --                             em finais de semana e feriados. E verificar se o lan�amento
    --                             de hist�rico 530 foi proveniente de agendamento.
    --                             (Douglas - Projeto Capta��o Internet 2014/2)
    --
    --                19/03/2015 - Inclus�o de leituras de novas aplica��es (Jean Michel).
    --
    --                07/04/2015 - Inclusao do parametro pr_flgsdapk para melhorar a performance
    --                             do programa pc_crps654. Chamado 272914 - Alisson (AMcom)
    --
    --                16/11/2015 - SD359826 - Inclus�o da NVL na busca do cdpesqbb, pois quando n�o h�
    --                             54 posi��es o substr estava ficando null e invalidando o teste
    --                             (Marcos-Supero)
    -- 
    --                17/11/2015 - Alterado para que na procedure pc_obtem_saldo_dia seja carregado 
    --                             o campo crapsda.vlsdcota na pr_tab_saldo, e que nas procedures
    --                             pc_obtem_saldo_dia_sd_wt e pc_obtem_saldo_dia_prog o valor seja
    --                             gravado na wt_saldos. (Douglas - Chamado 285228)
	--
    --               08/12/2015 - Ajustado query da craplcm para melhor performace SD358495 (Odirlei-AMcom)
    --
    DECLARE
      -- Descri��o e c�digo da critica
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      -- Dia para busca
      vr_dtrefere DATE;
      vr_dtmvtaux DATE;
      -- Sequencia do vetor de saldos
      vr_ind BINARY_INTEGER;
      -- Retorno dos valores de bloqueio judiciais
      vr_vlblqjud NUMBER;
      vr_vlresblq NUMBER;
      -- Busca do tipo de pessoa do associado
      vr_inpessoa crapass.inpessoa%TYPE;
      -- Index para a temptable de tarifa
      vr_tariidx varchar2(11);
      -- Historicos 'de-para' Cabal
      vr_cdhishcb VARCHAR2(4000);
      -- Flag selecionar crapsda
      vr_crapsda BOOLEAN;
      vr_lscdhist_ret     VARCHAR2(1000);
      
    BEGIN
      
      -- Se o dia para busca � superior ao dia corrente
      IF pr_dtrefere > trunc(sysdate) THEN
        -- Utilizar o dia corrente para busca
        vr_dtrefere := trunc(sysdate);
      ELSE
        -- Utilizar o dia passado
        vr_dtrefere := pr_dtrefere;
      END IF;
      -- Verificar qual data usar para acessar crapsda
      CASE pr_tipo_busca
        WHEN 'I' THEN --Mesmo Dia
          vr_dtmvtaux:= pr_rw_crapdat.dtmvtolt;
        WHEN 'A' THEN --Dia Anterior
          vr_dtmvtaux:= pr_rw_crapdat.dtmvtoan;
        WHEN 'P' THEN --Proximo Dia
          vr_dtmvtaux:= pr_rw_crapdat.dtmvtopr;
        ELSE
          vr_dtmvtaux:= NULL;
      END CASE;

        -- Busca do Saldo da conta pela PK
        OPEN cr_crapsda_pk(pr_cdcooper => pr_cdcooper
                          ,pr_dtmvtolt => vr_dtmvtaux
                          ,pr_nrdconta => pr_nrdconta);
        FETCH cr_crapsda_pk INTO rw_crapsda;
        vr_crapsda:= cr_crapsda_pk%FOUND;
        --Fechar Cursor
        CLOSE cr_crapsda_pk;

      -- Se n�o encontrou crapsda
      IF NOT vr_crapsda THEN
        -- Chamar rotina de grava��o de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 853 --> Critica 853
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Levantar exce��o
        RAISE vr_exc_erro;
      ELSE
        -- Busca Saldo Bloqueado Judicial
        gene0005.pc_retorna_valor_blqjud(pr_cdcooper => pr_cdcooper            --> Cooperativa
                                        ,pr_nrdconta => pr_nrdconta            --> Conta
                                        ,pr_nrcpfcgc => 0                      --> Fixo - CPF/CGC
                                        ,pr_cdtipmov => 0                      --> Fixo - Tipo do movimento
                                        ,pr_cdmodali => 1                      --> Modalidade Cta Corrente
                                        ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt --> Data atual
                                        ,pr_vlbloque => vr_vlblqjud            --> Valor bloqueado
                                        ,pr_vlresblq => vr_vlresblq            --> Valor que falta bloquear
                                        ,pr_dscritic => vr_dscritic);          --> Erros encontrados no processo
        /**************************************************************/
        /** Retorna limite de credito armazenado na crapass, pois se **/
        /** o limite for alterado durante o dia de movimento o mesmo **/
        /** nao � atualizado na crapsda. Somente no processo batch.  **/
        /**************************************************************/
        vr_ind := pr_tab_sald.COUNT;
        pr_tab_sald(vr_ind).nrdconta := rw_crapsda.nrdconta;
        pr_tab_sald(vr_ind).dtmvtolt := rw_crapsda.dtmvtolt;
        pr_tab_sald(vr_ind).vlsddisp := rw_crapsda.vlsddisp;
        pr_tab_sald(vr_ind).vlsdchsl := rw_crapsda.vlsdchsl;
        pr_tab_sald(vr_ind).vlsdbloq := rw_crapsda.vlsdbloq;
        pr_tab_sald(vr_ind).vlsdblpr := rw_crapsda.vlsdblpr;
        pr_tab_sald(vr_ind).vlsdblfp := rw_crapsda.vlsdblfp;
        pr_tab_sald(vr_ind).vlsdindi := rw_crapsda.vlsdindi;
        pr_tab_sald(vr_ind).vllimcre := pr_vllimcre; --> Apenas esta informa��o n�o vem da crapsda, cfme coment�rio acima
        pr_tab_sald(vr_ind).cdcooper := rw_crapsda.cdcooper;
        pr_tab_sald(vr_ind).vlsdeved := rw_crapsda.vlsdeved;
        pr_tab_sald(vr_ind).vldeschq := rw_crapsda.vldeschq;
        pr_tab_sald(vr_ind).vllimutl := rw_crapsda.vllimutl;
        pr_tab_sald(vr_ind).vladdutl := rw_crapsda.vladdutl;
        pr_tab_sald(vr_ind).vlsdrdca := rw_crapsda.vlsdrdca;
        pr_tab_sald(vr_ind).vlsdrdpp := rw_crapsda.vlsdrdpp;
        pr_tab_sald(vr_ind).vllimdsc := rw_crapsda.vllimdsc;
        pr_tab_sald(vr_ind).vlprepla := rw_crapsda.vlprepla;
        pr_tab_sald(vr_ind).vlprerpp := rw_crapsda.vlprerpp;
        pr_tab_sald(vr_ind).vlcrdsal := rw_crapsda.vlcrdsal;
        pr_tab_sald(vr_ind).qtchqliq := rw_crapsda.qtchqliq;
        pr_tab_sald(vr_ind).qtchqass := rw_crapsda.qtchqass;
        pr_tab_sald(vr_ind).dtdsdclq := rw_crapsda.dtdsdclq;
        pr_tab_sald(vr_ind).vltotpar := rw_crapsda.vltotpar;
        pr_tab_sald(vr_ind).vlopcdia := rw_crapsda.vlopcdia;
        pr_tab_sald(vr_ind).vlavaliz := rw_crapsda.vlavaliz;
        pr_tab_sald(vr_ind).vlavlatr := rw_crapsda.vlavlatr;
        pr_tab_sald(vr_ind).qtdevolu := rw_crapsda.qtdevolu;
        pr_tab_sald(vr_ind).vltotren := rw_crapsda.vltotren;
        pr_tab_sald(vr_ind).vldestit := rw_crapsda.vldestit;
        pr_tab_sald(vr_ind).vllimtit := rw_crapsda.vllimtit;
        pr_tab_sald(vr_ind).vlsdempr := rw_crapsda.vlsdempr;
        pr_tab_sald(vr_ind).vlsdfina := rw_crapsda.vlsdfina;
        pr_tab_sald(vr_ind).vlsrdc30 := rw_crapsda.vlsrdc30;
        pr_tab_sald(vr_ind).vlsrdc60 := rw_crapsda.vlsrdc60;
        pr_tab_sald(vr_ind).vlsrdcpr := rw_crapsda.vlsrdcpr;
        pr_tab_sald(vr_ind).vlsrdcpo := rw_crapsda.vlsrdcpo;
        pr_tab_sald(vr_ind).vlblqjud := vr_vlblqjud;
        pr_tab_sald(vr_ind).vlsdcota := rw_crapsda.vlsdcota;
      END IF;
      -- Busca de todos os lan�amentos
      FOR rw_craplcm_ign IN cr_craplcm_ign(pr_cdcooper => pr_cdcooper           --> Cooperativa conectada
                                  ,pr_nrdconta => pr_nrdconta           --> N�mero da conta
                                  ,pr_dtiniper => rw_crapsda.dtmvtolt+1 --> Data do saldo da conta + 1 dia, para n�o trazer ele
                                  ,pr_dtfimper => vr_dtrefere           --> Data movimento final processado acima
                                  ,pr_cdhistor_ign => '289') LOOP      --> Lista com c�digos de hist�rico a ignorar
        -- Chama rotina que comp�e o saldo do dia
        pc_compor_saldo_dia(pr_vllanmto => rw_craplcm_ign.vllanmto
                           ,pr_inhistor => rw_craplcm_ign.inhistor
                           ,pr_vlsddisp => pr_tab_sald(vr_ind).vlsddisp
                           ,pr_vlsdchsl => pr_tab_sald(vr_ind).vlsdchsl
                           ,pr_vlsdbloq => pr_tab_sald(vr_ind).vlsdbloq
                           ,pr_vlsdblpr => pr_tab_sald(vr_ind).vlsdblpr
                           ,pr_vlsdblfp => pr_tab_sald(vr_ind).vlsdblfp
                           ,pr_vlsdindi => pr_tab_sald(vr_ind).vlsdindi
                           ,pr_des_reto => pr_des_reto
                           ,pr_cdcritic => vr_cdcritic);
        -- Se houve erro
        IF pr_des_reto = 'NOK' THEN
          -- Chamar rotina de grava��o de erro
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => vr_cdcritic --> Retornando na compor saldo
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
          -- Levantar exce��o
          RAISE vr_exc_erro;
        END IF;
      END LOOP; --> Fim leitura lan�amentos
      /***********************************************************************/
      /** Se for feriado ou final de semana, os historicos abaixo devem ser **/
      /** entrar na contagem mesmo que a dtmvtolt do lancamento seja maior  **/
      /** que TODAY. Valido somente se par_dtrefere igual ao dia do feriado,**/
      /** sabado ou domingo.                                                **/
      /***********************************************************************/
      IF vr_dtrefere > pr_rw_crapdat.dtmvtoan AND vr_dtrefere < pr_rw_crapdat.dtmvtocd THEN
        -- Busca de dos lan�amentos:
        -- --- ---------------------------------
        -- 316 SAQUE CARTAO
        -- 375 TRANSF CARTAO
        -- 376 TRF.CARTAO I.
        -- 377 CR.TRF.CARTAO
        -- 450 SAQUE CARTAO
        -- 530 CR.APL.RDCPOS
        -- 537 TR.INTERNET
        -- 538 TR.INTERNET I
        -- 539 CR. INTERNET
        -- 767 ESTORNO SAQUE
        -- 771 TR. SALARIO
        -- 772 CR. SALARIO
        -- 918 SAQUE TAA
        -- 920 EST.SAQUE TAA
        -- 1109 CR. CESSAO
        -- 1110 DB.CESSAO
        -- 1009 TRANSF.INTERC
        -- 1011 CR.TRF.INTERC
        
        -- Busca o inpessoa da conta
        vr_inpessoa := fn_inpessoa_nrdconta(pr_cdcooper => pr_cdcooper
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_flgcrass => pr_flgcrass);
        -- Se retornar zero � porque n�o existe esta conta na cooperativa
        IF vr_inpessoa = 0 THEN
          -- Chamar rotina de grava��o de erro
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => 9 --> Associado nao cadastrado
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
          -- Gerar erro
          RAISE vr_exc_erro;
        END IF;
        -- Se o vetor de tarifas transferencia entre contas n�o conter para cooperativa
        IF NOT vr_tab_tarifa_transf.exists(lpad(pr_cdcooper,10,'0')||'1') OR
           NOT vr_tab_tarifa_transf.exists(lpad(pr_cdcooper,10,'0')||'2') THEN
          -- Subrotina para buscar as tarifas de transferencia
          pc_busca_tarifa_transfere(pr_cdcooper => pr_cdcooper
                                   ,pr_dscritic => vr_dscritic);
          -- Se ocorrer erro
          IF vr_dscritic IS NOT NULL THEN
            -- Gerar erro
            gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                 ,pr_cdagenci => pr_cdagenci
                                 ,pr_nrdcaixa => pr_nrdcaixa
                                 ,pr_nrsequen => 1 --> Fixo
                                 ,pr_cdcritic => 0
                                 ,pr_dscritic => vr_dscritic
                                 ,pr_tab_erro => pr_tab_erro);
            -- Efetuar raise para sair do processo
            RAISE vr_exc_erro;
          END IF;
        END IF;
        
        
        --Definir index
        vr_tariidx := lpad(pr_cdcooper,10,'0')||vr_inpessoa;
        --Verificar se existe tarifa para pessoa fisica 1 ou juridica 2
        IF NOT vr_tab_tarifa_transf.EXISTS(vr_tariidx) AND vr_inpessoa < 3 THEN
          vr_dscritic := 'Tarifa para cooperativa '||pr_cdcooper||' inpessoa '||vr_inpessoa||' n�o localizada!';
          -- Gerar erro
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => 0
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
          -- Efetuar raise para sair do processo
          RAISE vr_exc_erro;
        END IF;

        -- Busca os historicos da tabela 'de-para' da Cabal
        FOR rw_craphcb IN cr_craphcb LOOP
          vr_cdhishcb := vr_cdhishcb || ',' || rw_craphcb.cdhistor;
        END LOOP;

        vr_lscdhist_ret := '15,316,375,376,377,450,530,537,538,539,767,771,772,918,920,1109,1110,1009,1011,'||vr_tab_tarifa_transf(vr_tariidx).cdhisint||','||vr_tab_tarifa_transf(vr_tariidx).cdhistaa || vr_cdhishcb; --> Lista com c�digos de hist�rico a retornar         
        -- Buscar lan�amentos no dia apenas dos historicos listados acima
        FOR rw_craplcm_olt IN cr_craplcm_olt(pr_cdcooper => pr_cdcooper    --> Cooperativa conectada
                                    ,pr_nrdconta => pr_nrdconta            --> N�mero da conta
                                    ,pr_dtmvtolt => pr_rw_crapdat.dtmvtocd --> Data do movimento utilizada no cash dispenser.                                    
                                    ,pr_lsthistor_ret => vr_lscdhist_ret   --> Lista com c�digos de hist�rico a retornar
                                    ) LOOP
          -- Se for uma transferencia agendada, nao compor saldo
          IF NOT((rw_craplcm_olt.cdhistor IN(375,376,377,537,538,539,771,772) AND nvl(SUBSTR(rw_craplcm_olt.cdpesqbb,54,8),' ') = 'AGENDADO')
                 OR
                 (rw_craplcm_olt.cdhistor IN(1009,1011,vr_tab_tarifa_transf(vr_tariidx).cdhisint,vr_tab_tarifa_transf(vr_tariidx).cdhistaa) AND NVL(SUBSTR(rw_craplcm_olt.cdpesqbb,15,8),' ') = 'AGENDADO')
                 OR
                 (rw_craplcm_olt.cdhistor = 530 AND rw_craplcm_olt.cdpesqbb <> 'ONLINE')
                ) THEN
            -- Chama rotina que comp�e o saldo do dia
            pc_compor_saldo_dia(pr_vllanmto => rw_craplcm_olt.vllanmto
                               ,pr_inhistor => rw_craplcm_olt.inhistor
                               ,pr_vlsddisp => pr_tab_sald(vr_ind).vlsddisp
                               ,pr_vlsdchsl => pr_tab_sald(vr_ind).vlsdchsl
                               ,pr_vlsdbloq => pr_tab_sald(vr_ind).vlsdbloq
                               ,pr_vlsdblpr => pr_tab_sald(vr_ind).vlsdblpr
                               ,pr_vlsdblfp => pr_tab_sald(vr_ind).vlsdblfp
                               ,pr_vlsdindi => pr_tab_sald(vr_ind).vlsdindi
                               ,pr_des_reto => pr_des_reto
                               ,pr_cdcritic => vr_cdcritic);
            -- Se houve erro
            IF pr_des_reto = 'NOK' THEN
              -- Chamar rotina de grava��o de erro
              gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                   ,pr_cdagenci => pr_cdagenci
                                   ,pr_nrdcaixa => pr_nrdcaixa
                                   ,pr_nrsequen => 1 --> Fixo
                                   ,pr_cdcritic => vr_cdcritic --> Retornando na compor saldo
                                   ,pr_dscritic => vr_dscritic
                                   ,pr_tab_erro => pr_tab_erro);
              -- Levantar exce��o
              RAISE vr_exc_erro;
            END IF;
          END IF;
        END LOOP;
      END IF;
      /* Verifica os envelopes nao processados, depositados no cash para o saldo bloqueado */
      pr_tab_sald(vr_ind).vlblqtaa := 0;
      FOR rw_crapenl IN cr_crapenl(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta) LOOP
        -- saldo bloqueado em dep. no TAA
        pr_tab_sald(vr_ind).vlblqtaa := nvl(pr_tab_sald(vr_ind).vlblqtaa,0) + nvl(rw_crapenl.vldininf,0) + nvl(rw_crapenl.vlchqinf,0);
      END LOOP;
      -- Chegou ao final sem problemas
      pr_des_reto := 'OK';      
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
    END;
  END pc_obtem_saldo_dia;

  /* Obten��o do saldo da conta */
  PROCEDURE pc_obtem_saldo(pr_cdcooper   IN crapcop.cdcooper%TYPE
                          ,pr_rw_crapdat IN btch0001.cr_crapdat%ROWTYPE
                          ,pr_cdagenci   IN crapass.cdagenci%TYPE
                          ,pr_nrdcaixa   IN craperr.nrdcaixa%TYPE
                          ,pr_cdoperad   IN craplgm.cdoperad%TYPE
                          ,pr_nrdconta   IN crapass.nrdconta%TYPE
                          ,pr_dtrefere   IN crapdat.dtmvtolt%TYPE
                          ,pr_des_reto  OUT VARCHAR2 --> OK ou NOK
                          ,pr_tab_sald  OUT EXTR0001.typ_tab_saldos
                          ,pr_tab_erro  OUT GENE0001.typ_tab_erro) AS
  BEGIN
    --    Programa: pc_obtem_saldo (antigo BO b1wgen0001.obtem-saldo)
    --    Sistema : Conta-Corrente - Cooperativa de Credito
    --    Sigla   : CRED
    --    Autor   : Marcos (Supero)
    --    Data    : Dez/2012                         Ultima atualizacao: 30/06/2016
    --
    --    Dados referetes ao programa:
    --    Frequencia: Sempre que chamado pelos programas de extrato da conta
    --
    --    Objetivo  : Retornar um registro com o saldo da conta
    --
    --    Alteracoes: 04/12/2012 - Convers�o de Progress >> Oracle PLSQL
    --
    --                04/06/2013 - Buscar Saldo Bloqueado Judicial e grava nas pltable (Marcos-Supero)
    --
    --                09/06/2016 - Alterar leitura na tabela crapsda para buscar dia anterior antes de     
    --                             executar a query para utilizar a op��o pr_tipo_busca I(melhoria de performace).
    --                             SD467445 (Odirlei-AMcom)
    --
    --                21/06/2016 - Ajuste para utilizar o cursor cr_crapsda_pk para encontrar o saldo
    --                            (Adriano).
    --
    --
    ---------------------------------------------------------------------------------------------------------------------

    DECLARE
      -- Descri��o da critica
      vr_dscritic VARCHAR2(4000);
      -- Sequencia do vetor de saldos
      vr_ind BINARY_INTEGER;
      -- Retorno dos valores de bloqueio judiciais
      vr_vlblqjud NUMBER;
      vr_vlresblq NUMBER;
      vr_dtrefere DATE;
    BEGIN
      
      vr_dtrefere := gene0005.fn_valida_dia_util
                                       (pr_cdcooper => pr_cdcooper, 
                                        pr_dtmvtolt => pr_dtrefere-1,
                                        pr_tipo => 'A');
                                
      -- Busca do Saldo da conta pela PK
      OPEN cr_crapsda_pk(pr_cdcooper => pr_cdcooper
                        ,pr_dtmvtolt => vr_dtrefere
                        ,pr_nrdconta => pr_nrdconta);
                        
      FETCH cr_crapsda_pk INTO rw_crapsda;

      -- Se n�o encontrar
      IF cr_crapsda_pk%NOTFOUND THEN
        
        -- Fechar o cursor pois precisamos pesquis�-lo novamente
        CLOSE cr_crapsda_pk;
        
        -- Busca do Saldo da conta tentativa D -> Retornar o primeiro registro com data superior ou igual a data passada
        OPEN cr_min_sda(pr_cdcooper   => pr_cdcooper
                       ,pr_nrdconta   => pr_nrdconta
                       ,pr_dtrefere   => pr_dtrefere);
                       
        FETCH cr_min_sda INTO vr_progress_recid;
        
        CLOSE cr_min_sda;
        
        -- Busca do saldo ap�s achar o Progress Recid
        OPEN cr_crapsda(pr_progress_recid => vr_progress_recid);

        FETCH cr_crapsda INTO rw_crapsda;
        
        -- Se n�o encontrar,
        IF cr_crapsda%NOTFOUND THEN
          -- Fechar o cursor pois precisamos de raise
          CLOSE cr_crapsda;
          
          -- Chamar rotina de grava��o de erro
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => 853 --> Critica 853
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
                               
          -- Levantar exce��o
          RAISE vr_exc_erro;
          
        ELSE
          -- Apenas fechar pois j� encontrou
          CLOSE cr_crapsda;
        END IF;
        
      ELSE
        -- Apenas fechar pois j� encontrou
        CLOSE cr_crapsda_pk;
      END IF;
      
      -- Busca Saldo Bloqueado Judicial
      gene0005.pc_retorna_valor_blqjud(pr_cdcooper => pr_cdcooper            --> Cooperativa
                                      ,pr_nrdconta => pr_nrdconta            --> Conta
                                      ,pr_nrcpfcgc => 0                      --> Fixo - CPF/CGC
                                      ,pr_cdtipmov => 0                      --> Fixo - Tipo do movimento
                                      ,pr_cdmodali => 1                      --> Modalidade Cta Corrente
                                      ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt --> Data atual
                                      ,pr_vlbloque => vr_vlblqjud            --> Valor bloqueado
                                      ,pr_vlresblq => vr_vlresblq            --> Valor que falta bloquear
                                      ,pr_dscritic => vr_dscritic);          --> Erros encontrados no processo
      -- Se chegou nesse ponto � pq encontrou saldo, ent�o copia as informa��es pro vetor de saldo
      vr_ind := pr_tab_sald.COUNT;
      pr_tab_sald(vr_ind).nrdconta := rw_crapsda.nrdconta;
      pr_tab_sald(vr_ind).dtmvtolt := rw_crapsda.dtmvtolt;
      pr_tab_sald(vr_ind).vlsddisp := rw_crapsda.vlsddisp;
      pr_tab_sald(vr_ind).vlsdchsl := rw_crapsda.vlsdchsl;
      pr_tab_sald(vr_ind).vlsdbloq := rw_crapsda.vlsdbloq;
      pr_tab_sald(vr_ind).vlsdblpr := rw_crapsda.vlsdblpr;
      pr_tab_sald(vr_ind).vlsdblfp := rw_crapsda.vlsdblfp;
      pr_tab_sald(vr_ind).vlsdindi := rw_crapsda.vlsdindi;
      pr_tab_sald(vr_ind).vllimcre := rw_crapsda.vllimcre;
      pr_tab_sald(vr_ind).cdcooper := rw_crapsda.cdcooper;
      pr_tab_sald(vr_ind).vlsdeved := rw_crapsda.vlsdeved;
      pr_tab_sald(vr_ind).vldeschq := rw_crapsda.vldeschq;
      pr_tab_sald(vr_ind).vllimutl := rw_crapsda.vllimutl;
      pr_tab_sald(vr_ind).vladdutl := rw_crapsda.vladdutl;
      pr_tab_sald(vr_ind).vlsdrdca := rw_crapsda.vlsdrdca;
      pr_tab_sald(vr_ind).vlsdrdpp := rw_crapsda.vlsdrdpp;
      pr_tab_sald(vr_ind).vllimdsc := rw_crapsda.vllimdsc;
      pr_tab_sald(vr_ind).vlprepla := rw_crapsda.vlprepla;
      pr_tab_sald(vr_ind).vlprerpp := rw_crapsda.vlprerpp;
      pr_tab_sald(vr_ind).vlcrdsal := rw_crapsda.vlcrdsal;
      pr_tab_sald(vr_ind).qtchqliq := rw_crapsda.qtchqliq;
      pr_tab_sald(vr_ind).qtchqass := rw_crapsda.qtchqass;
      pr_tab_sald(vr_ind).dtdsdclq := rw_crapsda.dtdsdclq;
      pr_tab_sald(vr_ind).vltotpar := rw_crapsda.vltotpar;
      pr_tab_sald(vr_ind).vlopcdia := rw_crapsda.vlopcdia;
      pr_tab_sald(vr_ind).vlavaliz := rw_crapsda.vlavaliz;
      pr_tab_sald(vr_ind).vlavlatr := rw_crapsda.vlavlatr;
      pr_tab_sald(vr_ind).qtdevolu := rw_crapsda.qtdevolu;
      pr_tab_sald(vr_ind).vltotren := rw_crapsda.vltotren;
      pr_tab_sald(vr_ind).vldestit := rw_crapsda.vldestit;
      pr_tab_sald(vr_ind).vllimtit := rw_crapsda.vllimtit;
      pr_tab_sald(vr_ind).vlsdempr := rw_crapsda.vlsdempr;
      pr_tab_sald(vr_ind).vlsdfina := rw_crapsda.vlsdfina;
      pr_tab_sald(vr_ind).vlsrdc30 := rw_crapsda.vlsrdc30;
      pr_tab_sald(vr_ind).vlsrdc60 := rw_crapsda.vlsrdc60;
      pr_tab_sald(vr_ind).vlsrdcpr := rw_crapsda.vlsrdcpr;
      pr_tab_sald(vr_ind).vlsrdcpo := rw_crapsda.vlsrdcpo;
      pr_tab_sald(vr_ind).vlblqjud := vr_vlblqjud;
      pr_tab_sald(vr_ind).vlsdcota := rw_crapsda.vlsdcota;
      -- Chegou ao final sem problemas
      pr_des_reto := 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Limpa vetor de saldo
        pr_tab_sald.DELETE;
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Limpa vetor de saldo
        pr_tab_sald.DELETE;
    END;
  END pc_obtem_saldo;

  /* Utiliza a pc_obtem_saldo atraves do PROGRESS */
  PROCEDURE pc_obtem_saldo_car(pr_cdcooper IN crapcop.cdcooper%TYPE
                              ,pr_cdagenci IN crapass.cdagenci%TYPE
                              ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE
                              ,pr_cdoperad IN craplgm.cdoperad%TYPE
                              ,pr_nrdconta IN crapass.nrdconta%TYPE
                              ,pr_dtrefere IN crapdat.dtmvtolt%TYPE
                              ,pr_des_reto OUT VARCHAR2 --> OK ou NOK
                              ,pr_clob_ret OUT CLOB) AS --> Tabela Extrato da Conta
  BEGIN
    --    Programa: pc_obtem_saldo_car
    --    Sistema : Conta-Corrente - Cooperativa de Credito
    --    Sigla   : CRED
    --    Autor   : Carlos Rafael Tanholi
    --    Data    : Agosto/2016                         Ultima atualizacao: 
    --
    --    Dados referetes ao programa:
    --    Frequencia: Sempre que chamado pelos programas de extrato da conta
    ---------------------------------------------------------------------------

    DECLARE
      vr_cdcritic crapcri.cdcritic%TYPE;    
      -- Descri��o da critica
      vr_dscritic VARCHAR2(4000);
      -- Sequencia do vetor de saldos
      vr_ind BINARY_INTEGER;

      -- Saida da rotina de extrato
      vr_des_reto VARCHAR2(3);      
      -- PLTABLE
      vr_tab_sald EXTR0001.typ_tab_saldos;
      vr_tab_erro GENE0001.typ_tab_erro;
      
      -- CURSOR GEN�RICO DE CALEND�RIO
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;      

      --Variaveis de Indice
      vr_index VARCHAR(12);
      --Variaveis Arquivo Dados
      vr_dstexto VARCHAR2(32767);
      vr_string  VARCHAR2(32767);

    BEGIN
      
      -- datas da cooperativa
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;

      IF btch0001.cr_crapdat%NOTFOUND THEN
        CLOSE btch0001.cr_crapdat;
        -- monta msg de critica
        vr_cdcritic := 1;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => 1);

        -- Chamar rotina de grava��o de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => vr_tab_erro);
        RAISE vr_exc_erro;
      ELSE
        CLOSE btch0001.cr_crapdat;
      END IF;    
    
      EXTR0001.pc_obtem_saldo(pr_cdcooper   => pr_cdcooper
                             ,pr_rw_crapdat => rw_crapdat
                             ,pr_cdagenci   => pr_cdagenci
                             ,pr_nrdcaixa   => pr_nrdcaixa
                             ,pr_cdoperad   => pr_cdoperad
                             ,pr_nrdconta   => pr_nrdconta
                             ,pr_dtrefere   => pr_dtrefere
                             ,pr_des_reto   => vr_des_reto
                             ,pr_tab_sald   => vr_tab_sald
                             ,pr_tab_erro   => vr_tab_erro);
                             
      -- Se houve retorno n�o Ok
      IF vr_des_reto = 'NOK' THEN
        -- Tenta buscar o erro no vetor de erro
        IF vr_tab_erro.COUNT > 0 THEN
          vr_des_erro := vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||pr_nrdconta;
        ELSE
          vr_des_erro := 'Retorno "NOK" na extr0001.pc_obtem_saldo e sem informa��o na pr_vet_erro, Conta: '||pr_nrdconta;

        END IF;

        -- Abandona o processo
        RAISE vr_exc_erro;
      ELSE  
        --Montar CLOB
        IF vr_tab_sald.COUNT > 0 THEN
          
          -- Criar documento XML
          dbms_lob.createtemporary(pr_clob_ret, TRUE); 
          dbms_lob.open(pr_clob_ret, dbms_lob.lob_readwrite);
          
          -- Insere o cabe�alho do XML 
          gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret 
                                 ,pr_texto_completo => vr_dstexto 
                                 ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root>');
           
          --Buscar Primeiro beneficiario
          vr_index:= vr_tab_sald.FIRST;
          
          --Percorrer todos os beneficiarios
          WHILE vr_index IS NOT NULL LOOP
            vr_string:= '<extrato>'||
                          '<nrdconta>'||NVL(TO_CHAR(vr_tab_sald(vr_index).nrdconta),' ')||'</nrdconta>'|| 
                          '<dtmvtolt>'||NVL(TO_CHAR(vr_tab_sald(vr_index).dtmvtolt,'DD/MM/YYYY'), ' ')||'</dtmvtolt>'||
                          '<vlsddisp>'||NVL(TO_CHAR(vr_tab_sald(vr_index).vlsddisp),' ')||'</vlsddisp>'||
                          '<vlsdchsl>'||NVL(TO_CHAR(vr_tab_sald(vr_index).vlsdchsl),' ')||'</vlsdchsl>'||
                          '<vlsdbloq>'||NVL(TO_CHAR(vr_tab_sald(vr_index).vlsdbloq),' ')||'</vlsdbloq>'||
                          '<vlsdblpr>'||NVL(TO_CHAR(vr_tab_sald(vr_index).vlsdblpr),' ')||'</vlsdblpr>'||
                          '<vlsdblfp>'||NVL(TO_CHAR(vr_tab_sald(vr_index).vlsdblfp),' ')||'</vlsdblfp>'||
                          '<vlsdindi>'||NVL(TO_CHAR(vr_tab_sald(vr_index).vlsdindi),' ')||'</vlsdindi>'||
                          '<vllimcre>'||NVL(TO_CHAR(vr_tab_sald(vr_index).vllimcre),' ')||'</vllimcre>'||
                          '<cdcooper>'||NVL(TO_CHAR(vr_tab_sald(vr_index).cdcooper),' ')||'</cdcooper>'||
                          '<vlsdeved>'||NVL(TO_CHAR(vr_tab_sald(vr_index).vlsdeved),' ')||'</vlsdeved>'||
                          '<vldeschq>'||NVL(TO_CHAR(vr_tab_sald(vr_index).vldeschq),' ')||'</vldeschq>'||
                          '<vllimutl>'||NVL(TO_CHAR(vr_tab_sald(vr_index).vllimutl),' ')||'</vllimutl>'||
                          '<vladdutl>'||NVL(TO_CHAR(vr_tab_sald(vr_index).vladdutl),' ')||'</vladdutl>'||
                          '<vlsdrdca>'||NVL(TO_CHAR(vr_tab_sald(vr_index).vlsdrdca),' ')||'</vlsdrdca>'||
                          '<vlsdrdpp>'||NVL(TO_CHAR(vr_tab_sald(vr_index).vlsdrdpp),' ')||'</vlsdrdpp>'||
                          '<vllimdsc>'||NVL(TO_CHAR(vr_tab_sald(vr_index).vllimdsc),' ')||'</vllimdsc>'||
                          '<vlprepla>'||NVL(TO_CHAR(vr_tab_sald(vr_index).vlprepla),' ')||'</vlprepla>'||
                          '<vlprerpp>'||NVL(TO_CHAR(vr_tab_sald(vr_index).vlprerpp),' ')||'</vlprerpp>'||
                          '<vlcrdsal>'||NVL(TO_CHAR(vr_tab_sald(vr_index).vlcrdsal),' ')||'</vlcrdsal>'||
                          '<qtchqliq>'||NVL(TO_CHAR(vr_tab_sald(vr_index).qtchqliq),' ')||'</qtchqliq>'||
                          '<qtchqass>'||NVL(TO_CHAR(vr_tab_sald(vr_index).qtchqass),' ')||'</qtchqass>'||
                          '<dtdsdclq>'||NVL(TO_CHAR(vr_tab_sald(vr_index).dtdsdclq),' ')||'</dtdsdclq>'||
                          '<vltotpar>'||NVL(TO_CHAR(vr_tab_sald(vr_index).vltotpar),' ')||'</vltotpar>'||
                          '<vlopcdia>'||NVL(TO_CHAR(vr_tab_sald(vr_index).vlopcdia),' ')||'</vlopcdia>'||
                          '<vlavaliz>'||NVL(TO_CHAR(vr_tab_sald(vr_index).vlavaliz),' ')||'</vlavaliz>'||
                          '<vlavlatr>'||NVL(TO_CHAR(vr_tab_sald(vr_index).vlavlatr),' ')||'</vlavlatr>'||
                          '<qtdevolu>'||NVL(TO_CHAR(vr_tab_sald(vr_index).qtdevolu),' ')||'</qtdevolu>'||
                          '<vltotren>'||NVL(TO_CHAR(vr_tab_sald(vr_index).vltotren),' ')||'</vltotren>'||
                          '<vldestit>'||NVL(TO_CHAR(vr_tab_sald(vr_index).vldestit),' ')||'</vldestit>'||
                          '<vllimtit>'||NVL(TO_CHAR(vr_tab_sald(vr_index).vllimtit),' ')||'</vllimtit>'||
                          '<vlsdempr>'||NVL(TO_CHAR(vr_tab_sald(vr_index).vlsdempr),' ')||'</vlsdempr>'||
                          '<vlsdfina>'||NVL(TO_CHAR(vr_tab_sald(vr_index).vlsdfina),' ')||'</vlsdfina>'||
                          '<vlsrdc30>'||NVL(TO_CHAR(vr_tab_sald(vr_index).vlsrdc30),' ')||'</vlsrdc30>'||
                          '<vlsrdc60>'||NVL(TO_CHAR(vr_tab_sald(vr_index).vlsrdc60),' ')||'</vlsrdc60>'||
                          '<vlsrdcpr>'||NVL(TO_CHAR(vr_tab_sald(vr_index).vlsrdcpr),' ')||'</vlsrdcpr>'||
                          '<vlsrdcpo>'||NVL(TO_CHAR(vr_tab_sald(vr_index).vlsrdcpo),' ')||'</vlsrdcpo>'||
                          '<vlsdcota>'||NVL(TO_CHAR(vr_tab_sald(vr_index).vlsdcota),' ')||'</vlsdcota>'||
                          '<vlblqtaa>'||NVL(TO_CHAR(vr_tab_sald(vr_index).vlblqtaa),' ')||'</vlblqtaa>'||
                          '<vlstotal>'||NVL(TO_CHAR(vr_tab_sald(vr_index).vlstotal),' ')||'</vlstotal>'||
                          '<vlsaqmax>'||NVL(TO_CHAR(vr_tab_sald(vr_index).vlsaqmax),' ')||'</vlsaqmax>'||
                          '<vlacerto>'||NVL(TO_CHAR(vr_tab_sald(vr_index).vlacerto),' ')||'</vlacerto>'||
                          '<dslimcre>'||NVL(TO_CHAR(vr_tab_sald(vr_index).dslimcre),' ')||'</dslimcre>'||
                          '<vlipmfpg>'||NVL(TO_CHAR(vr_tab_sald(vr_index).vlipmfpg),' ')||'</vlipmfpg>'||
                          '<dtultlcr>'||NVL(TO_CHAR(vr_tab_sald(vr_index).dtultlcr,'DD/MM/YYYY'), ' ')||'</dtultlcr>'||
                          '<vlblqjud>'||NVL(TO_CHAR(vr_tab_sald(vr_index).vlblqjud),' ')||'</vlblqjud>'||
                        '</extrato>';

            -- Escrever no XML
            gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret 
                                   ,pr_texto_completo => vr_dstexto 
                                   ,pr_texto_novo     => vr_string
                                   ,pr_fecha_xml      => FALSE);   
                                                      
            --Proximo Registro
            vr_index:= vr_tab_sald.NEXT(vr_index);
            
          END LOOP;  
          
          -- Encerrar a tag raiz 
          gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret 
                                 ,pr_texto_completo => vr_dstexto 
                                 ,pr_texto_novo     => '</root>' 
                                 ,pr_fecha_xml      => TRUE);      
        END IF;
      END IF;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';

    END;

  END pc_obtem_saldo_car;    



  -- Chamar fun�ao para montagem do n�mero do documento para extrato
  FUNCTION fn_format_nrdocmto_extr(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
                                  ,pr_cdhistor IN craphis.cdhistor%TYPE --> C�digo do hist�rico
                                  ,pr_nrdocmto IN craplcm.nrdocmto%TYPE --> Nro documento do registro
                                  ,pr_cdpesqbb IN craplcm.cdpesqbb%TYPE --> Campo de pesquisa
                                  ,pr_nrdctabb IN craplcm.nrdctabb%TYPE --> Conta no BB
                                  ,pr_inpessoa IN crapass.inpessoa%TYPE --> Tipo da pessoa da conta
                                  ,pr_lshistor_cheque IN craptab.dstextab%TYPE --> Lista de hist�ricos de cheques
                                  ) RETURN VARCHAR2 IS
  BEGIN
    --    Programa: fn_format_nrdocmto_extr
    --    Sistema : Conta-Corrente - Cooperativa de Credito
    --    Sigla   : CRED
    --    Autor   : Marcos (Supero)
    --    Data    : Dez/2012                         Ultima atualizacao: 02/09/2015
    --
    --    Dados referetes ao programa:
    --    Frequencia: Sempre que chamado pelos programas de extrato da conta
    --
    --    Objetivo  : Formatar o n�mero do documento conforme o tipo de hist�rico
    --
    --    Alteracoes:
    --
    --    02/05/2013 - Ajustes na formata��o de hist�rio de transfer�ncia intercooperativa (Marcos-Supero)
    --
    --    27/08/2013 - Ajustes para buscar os hist�ricos de transferencia entre contas n�o mais
    --                 fixamente, mas sim a partir das informa��es do vetor vr_tab_tarifa_transf (Marcos-Supero)
    --
    --    02/09/2015 - Incluida a verificao do campo cdpesqbb = 'Fato gerador tarifa:', Prj. Tarifas - 218 (Jean Michel)

    DECLARE
      vr_dscritic VARCHAR2(4000);
    BEGIN

            -- Se o vetor de tarifas transferencia entre contas n�o conter para cooperativa
      IF NOT vr_tab_tarifa_transf.exists(lpad(pr_cdcooper,10,'0')||'1') OR
         NOT vr_tab_tarifa_transf.exists(lpad(pr_cdcooper,10,'0')||'2') THEN
        -- Subrotina para buscar as tarifas de transferencia
        pc_busca_tarifa_transfere(pr_cdcooper => pr_cdcooper
                                 ,pr_dscritic => vr_dscritic);
        -- Se ocorrer erro
        IF vr_dscritic IS NOT NULL OR
           NOT vr_tab_tarifa_transf.exists(lpad(pr_cdcooper,10,'0')||pr_inpessoa) AND pr_inpessoa < 3 THEN
          IF TRIM(vr_dscritic) is null THEN
            vr_dscritic := 'Tarifa para cooperativa '||pr_cdcooper||' inpessoa '||pr_inpessoa||' n�o localizada!';
          END IF;
          -- Gerar LOG
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper     --> Cooperativa
                                    ,pr_ind_tipo_log => 3               --> Erro critico
                                    ,pr_des_log      => vr_dscritic);
          -- Efetuar raise para usar a mascara padr�o
          RAISE vr_exc_erro;
        END IF;
      END IF;

      IF SUBSTR(pr_cdpesqbb,1,20) = 'Fato gerador tarifa:' THEN
         RETURN TO_CHAR(SUBSTR(pr_cdpesqbb,21));
      -- Para os tipos de hist�rico abaixo relacionados
      -- CDHISTOR DSHISTOR
      -- --- --------------------------------------------------
      -- 375 TRANSF CARTAO
      -- 376 TRF.CARTAO I.
      -- 377 CR.TRF.CARTAO
      -- 537 TR.INTERNET
      -- 538 TR.INTERNET I
      -- 539 CR. INTERNET
      -- 771 TR. SALARIO
      -- 772 CR. SALARIO
      ELSIF pr_cdhistor IN(375,376,377,537,538,539,771,772) THEN
        -- Buscar as 8 posi��es a partir do caracter 45 do campo cdpesqbb
        RETURN gene0002.fn_mask(to_number(substr(pr_cdpesqbb,45,8)),'zzzzz.zzz.9');
      -- Para Estorno Transferencia
      -- --- ----------------------
      -- 567 EST.TRF.INT.
      -- 568 EST.TRF.INT.I
      -- 569 EST.TRF.INT.
      -- 773 EST.TR.SALAR.
      -- 774 EST.CR.SALAR.
      ELSIF pr_cdhistor IN(567,568,569,773,774) THEN
        -- Buscar as 8 posi��es a partir do caracter 50 do campo cdpesqbb
        RETURN gene0002.fn_mask(to_number(substr(pr_cdpesqbb,50,8)),'zzzzz.zzz.9');
      -- Para os tipos de movimento abaixo e emiss�o
      -- --- --------------------------------------------------
      -- 316 SAQUE CARTAO
      -- 918 SAQUE TAA
      ELSIF pr_cdhistor IN(316,918) THEN
        -- mostra no extrato o numero do documento e a hora
        RETURN LTRIM(to_char(pr_nrdocmto,'99990') || ' ' || to_char(to_date(pr_nrdocmto,'sssss'),'hh24:mi'));
      -- Para os tipos de movimento:
      -- --- --------------------------------------------------
      -- 104 TRF.MESM.TTL.
      -- 302 DB.P/TRANSFER
      -- 303 CR.TRANSFEREN
      -- 590 AJTE DESC TIT
      -- 591 DB TIT VENCID
      -- 597 ABT JRS TIT D
      -- 687 RESG.TIT.DESC
      ELSIF pr_cdhistor IN(104,302,303,590,591,597,687) THEN
        -- Se existir informa��o no campo pesqbb e � um n�mero
        DECLARE
          vr_nraux NUMBER;
        BEGIN
          -- Tenta converter para numero
          vr_nraux := to_number(pr_cdpesqbb);
          -- Se n�o ir para a exce��o abaixo, � pq o campo era n�mero,
          -- ent�o utilizaremos eles como n�mero do documento
          RETURN gene0002.fn_mask(vr_nraux,'zzzzz.zzz.9');
        EXCEPTION
          WHEN OTHERS THEN
            -- O campo n�o era n�mero, ent�o usamos a mascara zzz.zzz.zz9
            RETURN gene0002.fn_mask(pr_cdpesqbb,'zzz.zzz.zz9');
        END;
      -- Para o tipo de movimento 418 -> TRFA EXT.CASH
      ELSIF pr_cdhistor = 418 THEN
        -- Usar os 7 caracteres ap�s a posi��o 60 do cdpesqbb
        RETURN SUBSTR(pr_cdpesqbb,60,7);
      -- Para transfer�ncia entre contas
      -- ---- --------------------------------------------------
      -- 1009 TRANSF.INTERC
      -- 1011 CR.TRF.INTERC
      -- 1014 DB.TRF.INTRAC
      -- 1015 CR.TRF.INTRAC
      -- 1163 ESTOR.TRANSF.
      -- 1167 ESTOR.TRANSF.
      -- cdhistaa --> Transf. Entre Contas (Taa)
      -- cdhsetaa --> Estorno Transf. Entre Contas (Taa)
      -- cdhisint --> Transf. Entre Contas (Internet)
      -- cdhseint --> Estorno Transf. Entre Contas (Internet)
      ELSIF pr_cdhistor IN (1009,1011,1014,1015,1163,1167
                           ,vr_tab_tarifa_transf(lpad(pr_cdcooper,10,'0')||pr_inpessoa).cdhistaa
                           ,vr_tab_tarifa_transf(lpad(pr_cdcooper,10,'0')||pr_inpessoa).cdhisint
                           ,vr_tab_tarifa_transf(lpad(pr_cdcooper,10,'0')||pr_inpessoa).cdhsetaa
                           ,vr_tab_tarifa_transf(lpad(pr_cdcooper,10,'0')||pr_inpessoa).cdhseint) THEN
        -- Guardar n�mero da conta no BB
        RETURN gene0002.fn_mask_conta(pr_nrdctabb);
      -- Para os tipos de documento encontrados na vari�vel vr_lshistor (Hist�ricos de Cheques)
      ELSIF ','||pr_lshistor_cheque||',' LIKE ('%,'||pr_cdhistor||',%') THEN
        -- Usa mascara de cheque
        RETURN gene0002.fn_mask(pr_nrdocmto,'zzzzz.zz9.9');
      -- Para o tipo de movimento 100 - C.P.M.F.
      ELSIF pr_cdhistor IN (100) THEN
        -- Se houver cdpesqbb
        IF pr_cdpesqbb IS NOT NULL THEN
          -- Usar este
          RETURN SUBSTR(pr_cdpesqbb,1,11);
        ELSE
          -- Usar campo do lan�amento com mascara "zzzzzzz.zz9"
          RETURN gene0002.fn_mask(pr_nrdocmto,'zzzzzzz.zz9');
        END IF;
      -- Se o tamanho for menor que 10 caracteres
      ELSIF LENGTH(pr_nrdocmto) < 10 THEN
        -- Usa mascara zzzzzzz.zz9
        RETURN gene0002.fn_mask(pr_nrdocmto,'zzzzzzz.zz9');
      ELSE --> Mascara padr�o para todos outros casos
          RETURN SUBSTR(gene0002.fn_mask(pr_nrdocmto,'99999999999999999999'),10,11);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
         -- Retornar op��o default (Else acima)
        RETURN SUBSTR(gene0002.fn_mask(pr_nrdocmto,'99999999999999999999'),10,11);
    END;
  END fn_format_nrdocmto_extr;

  /* Procedure que monta a chave hash para o vetor de extrato (composta por Data + Sequencial) */
  PROCEDURE pc_chave_extrato_conta(pr_dtmvtolt   IN craplcm.dtmvtolt%TYPE
                                  ,pr_tab_extr   IN typ_tab_extrato_conta
                                  ,pr_des_chave  OUT VARCHAR2
                                  ,pr_seq_reg    OUT INTEGER) IS

    --    Programa: pc_chave_extrato_conta
    --    Sistema : Conta-Corrente - Cooperativa de Credito
    --    Sigla   : CRED
    --    Autor   : Marcos (Supero)
    --    Data    : Dez/2012                         Ultima atualizacao: 04/12/2012
    --
    --    Dados referetes ao programa:
    --    Frequencia: Sempre que chamado pelos programas de extrato da conta
    --
    --    Objetivo  : Esta rotina criar� a chave hash do vetor, que � composta
    --                por data + sequencial, como n�o sabemos qual foi o ultimo
    --                sequencial da data passada, fazemos um loop para varrer
    --                o vetor at� achar uma posi��o que nao foi usada
    --
  BEGIN
    BEGIN
      -- Adicionar a data na chave no formato yymmdd
      pr_des_chave := to_char(pr_dtmvtolt,'yymmdd');
      -- Efetuar um loop e parar somente quando encontrar
      -- uma sequencia ainda n�o utilizada no hash do dia
      FOR vr_seq IN 1..999999 LOOP --> 999999 � a quantidade m�xima de lan�amentos
        -- Se n�o existir essa posi�ao
        IF NOT pr_tab_extr.EXISTS(pr_des_chave||LPAD(vr_seq,6,'0')) THEN
          -- Retornar a posi��o encontrada
          pr_seq_reg := vr_seq;
          -- Adicionamos na chave a posi��o encontrada
          pr_des_chave := pr_des_chave || LPAD(vr_seq,6,'0');
          -- sair da repeti�ao
          EXIT;
        END IF;
      END LOOP;
    END;
  END pc_chave_extrato_conta;

  /* Procedure para tratar registro do extrato de conta corrente */
  PROCEDURE pc_gera_registro_extrato(pr_cdcooper     IN crapcop.cdcooper%TYPE    --> Cooperativa conectada
                                    ,pr_rowid        IN ROWID                    --> Registro buscado da craplcm
                                    ,pr_flgident     IN BOOLEAN                  --> Se deve ou n�o usar o craplcm.dsidenti
                                    ,pr_nmdtable     IN VARCHAR2                 --> Extrato ou Dep�sito
                                    ,pr_lshistor     IN craptab.dstextab%TYPE    --> Lista de hist�ricos de cheques
                                    ,pr_tab_extr     IN OUT NOCOPY typ_tab_extrato_conta    --> Tabela Com Extrato de Conta
                                    ,pr_tab_depo     IN OUT NOCOPY typ_tab_dep_identificado --> Tabela Depositos Identificados
                                    ,pr_des_reto     OUT VARCHAR2                 --> Saida OK ou NOK
                                    ,pr_des_erro     OUT VARCHAR2) IS
  BEGIN
    /*
        Programa: pc_gera_registro_extrato (antigo BO b1wgen0001.gera-registro-extrato)
        Sistema : Conta-Corrente - Cooperativa de Credito
        Sigla   : CRED
        Autor   : Marcos (Supero)
        Data    : Dez/2012                         Ultima atualizacao: 17/05/2016

        Dados referetes ao programa:
        Frequencia: Sempre que chamado pelos programas de extrato da conta

        Objetivo  : Retornar registros processados de extrato de conta

        Alteracoes: 04/12/2012 - Convers�o de Progress >> Oracle PLSQL (Marcos-Supero)

                    02/05/2013 - Inclus�o de ajustes para trasnfer�ncia intercooperativa (Marcos-Supero)

                    27/08/2013 - Inclus�o da busca do tipo de pessoa para passar a rotina de
                                 montagem do nrdocmto (Marcos-Supero)

                    17/01/2014 - Melhor devolu��o de erro na when-others (Marcos-Supero)

                    16/06/2014 - Ajuste para mostrar o avalista que efetuou o pagamento. (James)

                    03/07/2014 - Buscar informacoes da craplcm apartir do rowid passado como
                                 parametro (Alisson - AMcom)

                    15/09/2014 - Adicionados parametros de saida das tabelas de extrato conta e
                                 Depositos Identificados (Alisson - AMcom)

                    01/04/2015 - Ajuste na variavel vr_dshistor (Jean Michel).

                    17/05/2016 - Incluido tratamento para historico 1019 exibir o correta
                                 descri��o no historico e para caso for um lan�amento de 
                                 debito automatico concatenar com historico complementar
                                 PRJ320 - Ofernta conv Debaut(Odirlei-AMcom)

    */
    DECLARE
      -- Var�aveis para montagem do novo registro
      vr_nrdconta craplcm.nrdconta%TYPE;
      vr_dtmvtolt craplcm.dtmvtolt%TYPE;
      vr_nrdolote craplcm.nrdolote%TYPE;
      vr_cdagenci craplcm.cdagenci%TYPE;
      vr_cdbccxlt craplcm.cdbccxlt%TYPE;
      vr_vllanmto craplcm.vllanmto%TYPE;
      vr_dsidenti craplcm.dsidenti%TYPE;
      vr_cdcoptfn craplcm.cdcoptfn%TYPE;
      vr_indebcre craphis.indebcre%TYPE;
      vr_inhistor craphis.inhistor%TYPE;
      vr_cdhistor craphis.cdhistor%TYPE;
      vr_dsextrat VARCHAR2(100);
      vr_dshistor VARCHAR2(100);
      vr_nrdocmto VARCHAR2(40);
      vr_dslibera VARCHAR2(10);
      vr_nrsequen INTEGER;
      -- Buscar informa��es de dep�sitos bloqueados
      CURSOR cr_crapdpb (pr_cdcooper IN craplcm.cdcooper%TYPE
                        ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE
                        ,pr_cdagenci IN craplcm.cdagenci%TYPE
                        ,pr_cdbccxlt IN craplcm.cdbccxlt%TYPE
                        ,pr_nrdolote IN craplcm.nrdolote%TYPE
                        ,pr_nrdconta IN craplcm.nrdconta%TYPE
                        ,pr_nrdocmto IN craplcm.nrdocmto%TYPE) IS
        SELECT dpb.inlibera
              ,dpb.dtliblan
          FROM crapdpb dpb
         WHERE dpb.cdcooper = pr_cdcooper
           AND dpb.dtmvtolt = pr_dtmvtolt
           AND dpb.cdagenci = pr_cdagenci
           AND dpb.cdbccxlt = pr_cdbccxlt
           AND dpb.nrdolote = pr_nrdolote
           AND dpb.nrdconta = pr_nrdconta
           AND dpb.nrdocmto = pr_nrdocmto;
      rw_crapdpb cr_crapdpb%ROWTYPE;

      --Selecionar Lancamentos pelo Rowid
      CURSOR cr_craplcm(pr_rowid IN ROWID) IS  --> Rowid Lancamento
        SELECT lcm.cdcooper
          ,lcm.nrdconta
          ,lcm.nrdolote
          ,lcm.dtmvtolt
          ,lcm.cdagenci
          ,lcm.cdhistor
          ,lcm.cdpesqbb
          ,lcm.cdbccxlt
          ,lcm.nrdocmto
          ,lcm.nrparepr
          ,lcm.vllanmto
          ,lcm.dsidenti
          ,lcm.dscedent
          ,lcm.nrdctabb
          ,lcm.nrseqava
          ,lcm.cdcoptfn
          ,lcm.hrtransa
          ,his.dsextrat
          ,his.indebcre
          ,his.inhistor
          ,his.dshistor
        FROM craplcm lcm
            ,craphis his
        WHERE lcm.cdcooper = his.cdcooper
        AND   lcm.cdhistor = his.cdhistor
        AND   lcm.rowid    = pr_rowid;
      --Tipo de Registro de Lancamento
      rw_craplcm cr_craplcm%ROWTYPE;
      
      --> Buscar nome do convenio
      CURSOR cr_crapscn (pr_cdcooper IN crapatr.cdcooper%TYPE     
                        ,pr_cdempcon IN crapatr.cdempcon%TYPE     
                        ,pr_cdsegmto IN crapatr.cdsegmto%TYPE) IS 
        SELECT  TRIM(REPLACE(REPLACE(dsnomcnv,'-F','- F'),'- FEBRABAN')) dsnomcnv
          FROM crapscn scn
         WHERE scn.cdempcon = pr_cdempcon    
           AND scn.cdsegmto = pr_cdsegmto
           AND scn.dsoparre = 'E'
           AND scn.cddmoden IN ('A','C');
      rw_crapscn cr_crapscn%ROWTYPE;
      
      --> Buscar autoriza��o de debito automatico
      CURSOR cr_crapatr (pr_cdcooper IN crapatr.cdcooper%TYPE     --> Cooperativa
                        ,pr_nrdconta IN crapatr.nrdconta%TYPE     --> Conta
                        ,pr_cdhistor IN crapatr.cdhistor%TYPE     --> historico
                        ,pr_cdrefere IN crapatr.cdrefere%TYPE) IS --> Referencia
        SELECT  decode(TRIM(atr.dshisext),NULL,NULL,' - '|| TRIM(atr.dshisext)) dshisext
               ,atr.cdempcon
               ,atr.cdsegmto
          FROM crapatr atr
         WHERE atr.cdcooper = pr_cdcooper
           AND atr.nrdconta = pr_nrdconta
           AND atr.cdhistor = pr_cdhistor
           AND atr.cdrefere = pr_cdrefere;
           
      rw_crapatr cr_crapatr%ROWTYPE;                
      
      -- Buscar o sequencia do log de mensagens do SPB
      CURSOR cr_craplmt(pr_cdcooper IN craplcm.cdcooper%TYPE     --> Cooperativa
                       ,pr_nrdconta IN craplcm.nrdconta%TYPE     --> Conta
                       ,pr_dtmvtolt IN craplcm.dtmvtolt%TYPE     --> Data da Transacao
                       ,pr_hrtransa IN craplcm.hrtransa%TYPE     --> Hora da Transacao
                       ,pr_vllanmto IN craplcm.vllanmto%TYPE) IS --> Valor do Documento
        SELECT craplmt.nrsequen
          FROM craplmt 
         WHERE craplmt.cdcooper = pr_cdcooper
           AND craplmt.nrdconta = pr_nrdconta
           AND craplmt.dttransa = pr_dtmvtolt
	       AND craplmt.hrtransa = pr_hrtransa
           AND craplmt.vldocmto = pr_vllanmto;
      -- Tipo de registro do Log do SPB
      rw_craplmt cr_craplmt%ROWTYPE;  
      
      --Busca o inprocess na crapdat
      CURSOR cr_crapdat(pr_cdcooper IN crapdat.cdcooper%TYPE) IS --> Cooperativa
        SELECT dat.inproces
          FROM crapdat dat
         WHERE dat.cdcooper = pr_cdcooper;
      rw_crapdat cr_crapdat%ROWTYPE;                                               
       
      -- Sequencia das tabelas internas
      vr_ind_tab VARCHAR2(12); -- Chave composta por Data + Sequencial (YYMMDD999999)
      vr_ind_dep PLS_INTEGER;
      -- Busca do tipo de pessoa do associado
      vr_inpessoa crapass.inpessoa%TYPE;
      -- Index para a temptable de tarifa
      vr_tariidx varchar2(11);      
     --Flag valida se estar rodando no batch
      vr_flgcrass BOOLEAN;
      
    BEGIN
      
      -- Selecionar Informacoes do Lancamento
      OPEN cr_craplcm (pr_rowid => pr_rowid);
      FETCH cr_craplcm INTO rw_craplcm;
      --Fechar Cursor
      CLOSE cr_craplcm;

      rw_crapatr := NULL;
      --> Verificar se convenio � de debito automatico
      OPEN cr_crapatr (pr_cdcooper => rw_craplcm.cdcooper   --> Cooperativa
                      ,pr_nrdconta => rw_craplcm.nrdconta   --> Conta
                      ,pr_cdhistor => rw_craplcm.cdhistor   --> historico
                      ,pr_cdrefere => rw_craplcm.nrdocmto); --> Referencia
      FETCH cr_crapatr INTO rw_crapatr;
      CLOSE cr_crapatr;
      
      -- Copiar informa��es comuns
      vr_nrdconta := rw_craplcm.nrdconta;
      vr_dtmvtolt := rw_craplcm.dtmvtolt;
      vr_nrdolote := rw_craplcm.nrdolote;
      vr_cdagenci := rw_craplcm.cdagenci;
      vr_cdbccxlt := rw_craplcm.cdbccxlt;
      vr_vllanmto := rw_craplcm.vllanmto;
      vr_cdcoptfn := rw_craplcm.cdcoptfn;
      
      OPEN cr_crapdat(pr_cdcooper);
        FETCH cr_crapdat
        INTO rw_crapdat;
      CLOSE cr_crapdat;
      
      -- Verificar se o BATCH esta rodando
      IF rw_crapdat.inproces <> 1 THEN
        -- Se estiver no BATCH, utiliza a verificacao da conta a partir do vetor de contas
        -- que se nao estiver carregado fara a leitura de todas as contas da cooperativa
        -- Quando eh BATCH mantem o padrao TRUE
        vr_flgcrass := TRUE;
      ELSE 
        -- Se nao estiver no BATCH, busca apenas a informacao da conta que esta sendo passada
        vr_flgcrass := FALSE;
      END IF;
      
      -- Busca o inpessoa da conta
      vr_inpessoa := fn_inpessoa_nrdconta(pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => vr_nrdconta
                                         ,pr_flgcrass => vr_flgcrass);
      -- Se retornar zero � porque n�o existe esta conta na cooperativa
      IF vr_inpessoa = 0 THEN
        -- Gerar erro
        pr_des_erro := 'Nao foi possivel retornar o tipo da pessoa da conta: '||vr_nrdconta;
        RAISE vr_exc_erro;
      END IF;
      -- Se o vetor de tarifas transferencia entre contas n�o conter para cooperativa
      IF NOT vr_tab_tarifa_transf.exists(lpad(pr_cdcooper,10,'0')||'1') OR
         NOT vr_tab_tarifa_transf.exists(lpad(pr_cdcooper,10,'0')||'2') THEN
        -- Subrotina para buscar as tarifas de transferencia
        pc_busca_tarifa_transfere(pr_cdcooper => pr_cdcooper
                                 ,pr_dscritic => pr_des_erro);
        -- Se ocorrer erro
        IF pr_des_erro IS NOT NULL THEN
          -- Efetuar raise para sair do processo
          RAISE vr_exc_erro;
        END IF;
      END IF;
      -- Se deve-se utilizar o dsident
      IF pr_flgident THEN
        -- Usar o que vem no registro
        vr_dsidenti := rw_craplcm.dsidenti;
      ELSE
        -- N�o enviar nada
        vr_dsidenti := '';
      END IF;
      vr_dslibera := '';
      -- Para hist�ricos de entrada
      IF rw_craplcm.inhistor IN(3,4,5) THEN
        -- Buscar informa��es de dep�sitos bloqueados
        OPEN cr_crapdpb (pr_cdcooper => pr_cdcooper
                        ,pr_dtmvtolt => rw_craplcm.dtmvtolt
                        ,pr_cdagenci => rw_craplcm.cdagenci
                        ,pr_cdbccxlt => rw_craplcm.cdbccxlt
                        ,pr_nrdolote => rw_craplcm.nrdolote
                        ,pr_nrdconta => rw_craplcm.nrdconta
                        ,pr_nrdocmto => rw_craplcm.nrdocmto);
        FETCH cr_crapdpb INTO rw_crapdpb;
        -- Se encontrou dep�sito bloqueado
        IF cr_crapdpb%FOUND THEN
          -- Se j� foi liberado
          IF rw_crapdpb.inlibera = 1 THEN
            -- Guardar a data
            vr_dslibera := '('||to_char(rw_crapdpb.dtliblan,'dd/mm')||')';
          ELSE
            -- INdicar que h� estorno
            vr_dslibera := '(Estorno)';
          END IF;
        ELSE
          -- Usar descri��o padr�o
          vr_dslibera := '(**/**)';
        END IF;
        -- Fechar o cursor
        CLOSE cr_crapdpb;
      END IF;
      -- Guardar informa��es provenientes do hist�rico
      vr_indebcre := rw_craplcm.indebcre;
      vr_inhistor := rw_craplcm.inhistor;
      vr_cdhistor := rw_craplcm.cdhistor;
      
      IF rw_craplcm.cdhistor IN (1019) THEN

        --> Buscar autoriza��o de debito automatico
        OPEN cr_crapscn (pr_cdcooper => rw_craplcm.cdcooper   
                        ,pr_cdempcon => rw_crapatr.cdempcon   
                        ,pr_cdsegmto => rw_crapatr.cdsegmto); 
        FETCH cr_crapscn INTO rw_crapscn;
        -- Senao encontrar
        IF cr_crapscn%NOTFOUND THEN
          CLOSE cr_crapscn;
          -- Usar descri��es do hist�rico apenas
          vr_dsextrat := rw_craplcm.dsextrat|| rw_crapatr.dshisext;
          vr_dshistor := rw_craplcm.dshistor|| rw_crapatr.dshisext;
        ELSE
          CLOSE cr_crapscn;
          
          vr_dsextrat := rw_crapscn.dsnomcnv || rw_crapatr.dshisext;
          vr_dshistor := rw_crapscn.dsnomcnv || rw_crapatr.dshisext;
          
        END IF;
        
      -- Para hist�rico 508 - PG.P/INTERNET
      ELSIF rw_craplcm.cdhistor = 508 THEN
        -- Utilizar a descri��o proveniente do hist�rico
        vr_dsextrat := rw_craplcm.dsextrat;
        vr_dshistor := rw_craplcm.dshistor;
        -- Se houver cedente do pagamento
        IF TRIM(rw_craplcm.dscedent) IS NOT NULL THEN
          -- Adicionar o cedente
          vr_dsextrat := substr(vr_dsextrat || ' - ' || rw_craplcm.dscedent,1,100);
          vr_dshistor := substr(vr_dshistor || ' - ' || rw_craplcm.dscedent,1,100);

        END IF;

      /* Lancamento de pagamento de avalista */
      ELSIF ((rw_craplcm.cdhistor IN(1539,1541,1542,1543,1544)) AND (rw_craplcm.nrseqava > 0)) THEN
        vr_dsextrat := rw_craplcm.dsextrat;
        vr_dshistor := SUBSTR(rw_craplcm.dshistor,1,11) || ' ' ||rw_craplcm.nrseqava;
      ELSE
        -- Para os tipos de hist�rico abaixo relacionados
        -- CDHISTOR DSHISTOR
        -- --- --------------------------------------------------
        --  24 CH.DEV.PRC.
        --  27 CH.DEV.FPR.
        --  47 CHQ.DEVOL.
        --  78 CH.DEV.TRF.
        -- 156 CHQ.DEVOL.
        -- 191 CHQ.DEVOL.
        -- 338 CHQ.DEVOL.
        -- 351 DEV.CH.DEP.
        -- 399 DEV.CH.DESCTO
        -- 573 CHQ.DEVOL.
        -- 657 CH.DEV.CUST.
        IF rw_craplcm.cdhistor IN(24,27,47,78,156,191,338,351,399,573,657) THEN
          -- Usar descri��es do hist�rico mais o cdpesqbb
          vr_dsextrat := rw_craplcm.dsextrat || rw_craplcm.cdpesqbb;
          vr_dshistor := rw_craplcm.dshistor || rw_craplcm.cdpesqbb;
        ELSE
          -- Usar descri��es do hist�rico apenas
          -- concatenar historico complementat do debito automatico caso encontrado
          vr_dsextrat := rw_craplcm.dsextrat || rw_crapatr.dshisext;
          vr_dshistor := rw_craplcm.dshistor || rw_crapatr.dshisext;
        END IF;
      END IF;
      -- Chamar fun�ao para montagem do n�mero do documento para extrato
      vr_nrdocmto := extr0001.fn_format_nrdocmto_extr(pr_cdcooper => pr_cdcooper            --> Cooperativa
                                                     ,pr_cdhistor => rw_craplcm.cdhistor --> C�digo do hist�rico
                                                     ,pr_nrdocmto => rw_craplcm.nrdocmto --> Nro documento do registro
                                                     ,pr_cdpesqbb => rw_craplcm.cdpesqbb --> Campo de pesquisa
                                                     ,pr_nrdctabb => rw_craplcm.nrdctabb --> Conta no BB
                                                     ,pr_inpessoa => vr_inpessoa            --> Tipo da pessoa da conta
                                                     ,pr_lshistor_cheque => pr_lshistor);

      --definir index
      vr_tariidx := lpad(pr_cdcooper,10,'0')||vr_inpessoa;
      --Verificar se existe tarifa para pessoa fisica 1 ou juridica 2
      IF NOT vr_tab_tarifa_transf.EXISTS(vr_tariidx) AND vr_inpessoa < 3 THEN
        pr_des_erro := 'Tarifa para cooperativa '||pr_cdcooper||' inpessoa '||vr_inpessoa||' n�o localizada!';

        -- Efetuar raise para sair do processo
        RAISE vr_exc_erro;
      END IF;

      -- Para transfer�ncia entre contas
      -- ---- --------------------------------------------------
      -- 1009 TRANSF.INTERC
      -- 1011 CR.TRF.INTERC
      -- 1163 ESTOR.TRANSF.
      -- 1167 ESTOR.TRANSF.
      -- cdhistaa --> Transf. Entre Contas (Taa)
      -- cdhsetaa --> Estorno Transf. Entre Contas (Taa)
      -- cdhisint --> Transf. Entre Contas (Internet)
      -- cdhseint --> Estorno Transf. Entre Contas (Internet)
      IF vr_tab_tarifa_transf.EXISTS(vr_tariidx) THEN
        IF rw_craplcm.cdhistor IN (1009,1011,1163,1167 ,vr_tab_tarifa_transf(vr_tariidx).cdhistaa
                                                       ,vr_tab_tarifa_transf(vr_tariidx).cdhisint
                                                       ,vr_tab_tarifa_transf(vr_tariidx).cdhsetaa
                                                       ,vr_tab_tarifa_transf(vr_tariidx).cdhseint) THEN
          -- Guardar agencia no dsidenti
          vr_dsidenti := 'Agencia: '||gene0002.fn_mask(SUBSTR(rw_craplcm.cdpesqbb,10,4),'9999');
        END IF;
      END IF;

      -- Se foi um lan�amento de pagamento de parcela
      IF rw_craplcm.nrparepr > 0 THEN
        -- Buscar destalhes do empr�stimo
        rw_crapepr := NULL;
        OPEN cr_crapepr(pr_cdcooper => pr_cdcooper
                       ,pr_inliquid => NULL
                       ,pr_inprejuz => NULL
                       ,pr_nrdconta => rw_craplcm.nrdconta
                       ,pr_nrctremp => TRIM(REPLACE(rw_craplcm.cdpesqbb,'.','')));
        FETCH cr_crapepr
         INTO rw_crapepr;
        CLOSE cr_crapepr;
        -- Se tiver encontrado
        IF nvl(rw_crapepr.qtpreemp,0) <> 0  THEN
          -- Adicionar na descri��o a parcela
          vr_dsextrat := substr(vr_dsextrat,1,13)||' '||to_char(rw_craplcm.nrparepr,'fm000')||'/'||to_char(rw_crapepr.qtpreemp,'fm000');
        END IF;
      END IF;
      -- Processar o retorno conforme o tipo solicitado
      IF pr_nmdtable = 'E' THEN
        -- Monta a chave hash para o vetor (Data + Sequencial)
        pc_chave_extrato_conta(pr_dtmvtolt  => rw_craplcm.dtmvtolt
                              ,pr_tab_extr  => pr_tab_extr
                              ,pr_des_chave => vr_ind_tab
                              ,pr_seq_reg   => vr_nrsequen);
        -- Finalmente cria o novo registro
        pr_tab_extr(vr_ind_tab).nrdconta := vr_nrdconta;
        pr_tab_extr(vr_ind_tab).dtmvtolt := vr_dtmvtolt;
        pr_tab_extr(vr_ind_tab).nrsequen := vr_nrsequen;
        pr_tab_extr(vr_ind_tab).nrdolote := vr_nrdolote;
        pr_tab_extr(vr_ind_tab).cdagenci := vr_cdagenci;
        pr_tab_extr(vr_ind_tab).cdbccxlt := vr_cdbccxlt;
        pr_tab_extr(vr_ind_tab).vllanmto := vr_vllanmto;
        pr_tab_extr(vr_ind_tab).dsidenti := vr_dsidenti;
        pr_tab_extr(vr_ind_tab).nrdocmto := vr_nrdocmto;
        pr_tab_extr(vr_ind_tab).dtliblan := vr_dslibera;
        pr_tab_extr(vr_ind_tab).indebcre := vr_indebcre;
        pr_tab_extr(vr_ind_tab).inhistor := vr_inhistor;
        pr_tab_extr(vr_ind_tab).cdhistor := vr_cdhistor;
        pr_tab_extr(vr_ind_tab).dsextrat := vr_dsextrat;
        pr_tab_extr(vr_ind_tab).dshistor := vr_dshistor;
        pr_tab_extr(vr_ind_tab).cdcoptfn := vr_cdcoptfn;
        
        IF rw_craplcm.cdhistor IN(519,555,578,799,958) THEN
          OPEN cr_craplmt(pr_cdcooper => rw_craplcm.cdcooper
                         ,pr_nrdconta => rw_craplcm.nrdconta
                         ,pr_dtmvtolt => rw_craplcm.dtmvtolt
                         ,pr_hrtransa => rw_craplcm.hrtransa
                         ,pr_vllanmto => rw_craplcm.vllanmto);
          FETCH cr_craplmt INTO rw_craplmt;
          IF cr_craplmt%FOUND THEN
            pr_tab_extr(vr_ind_tab).nrseqlmt := rw_craplmt.nrsequen;
          END IF;
          CLOSE cr_craplmt;
        END IF;
        
      ELSIF pr_nmdtable = 'D' THEN
        -- Guardar o ID do novo registro
        vr_ind_dep := pr_tab_depo.COUNT + 1;
        -- Criar o registro na tabela
        pr_tab_depo(vr_ind_dep).dtmvtolt := vr_dtmvtolt;
        pr_tab_depo(vr_ind_dep).dsextrat := vr_dsextrat;
        pr_tab_depo(vr_ind_dep).dshistor := vr_dshistor;
        pr_tab_depo(vr_ind_dep).nrdocmto := vr_nrdocmto;
        pr_tab_depo(vr_ind_dep).indebcre := vr_indebcre;
        pr_tab_depo(vr_ind_dep).vllanmto := vr_vllanmto;
        pr_tab_depo(vr_ind_dep).dsidenti := vr_dsidenti;
      END IF;
      -- Chegou neste ponto sem problemas
      pr_des_reto := 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
      WHEN OTHERS THEN
        -- Montar texto erro n�o tratado
        pr_des_erro := 'Erro na pc_gera_registro_extrato --> '||sqlerrm;
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
    END;
  END pc_gera_registro_extrato;

  /* Procedure para listar extrato da conta-corrente */
  PROCEDURE pc_consulta_extrato(pr_cdcooper     IN crapcop.cdcooper%TYPE
                               ,pr_rw_crapdat   IN btch0001.cr_crapdat%ROWTYPE
                               ,pr_cdagenci     IN crapass.cdagenci%TYPE
                               ,pr_nrdcaixa     IN craperr.nrdcaixa%TYPE
                               ,pr_cdoperad     IN craplgm.cdoperad%TYPE
                               ,pr_nrdconta     IN crapass.nrdconta%TYPE
                               ,pr_vllimcre     IN crapass.vllimcre%TYPE
                               ,pr_dtiniper     IN crapdat.dtmvtolt%TYPE
                               ,pr_dtfimper     IN crapdat.dtmvtolt%TYPE
                               ,pr_lshistor     IN craptab.dstextab%TYPE
                               ,pr_idorigem     IN INTEGER
                               ,pr_idseqttl     IN INTEGER
                               ,pr_nmdatela     IN VARCHAR2
                               ,pr_flgerlog     IN BOOLEAN
                               ,pr_des_reto    OUT VARCHAR2 --> OK ou NOK
                               ,pr_tab_extrato OUT EXTR0001.typ_tab_extrato_conta
                               ,pr_tab_erro    OUT GENE0001.typ_tab_erro) IS
  BEGIN
    /*
        Programa: pc_consulta_extrato (antigo BO b1wgen0001.consulta-extrato)
        Sistema : Conta-Corrente - Cooperativa de Credito
        Sigla   : CRED
        Autor   : Marcos (Supero)
        Data    : Dez/2012                         Ultima atualizacao: 16/11/2015

        Dados referetes ao programa:
        Frequencia: Sempre que chamado pelos programas de extrato da conta

        Objetivo  : Retornar registro com movimenta��es da conta

        Alteracoes: 04/12/2012 - Convers�o de Progress >> Oracle PLSQL

                    29/01/2013 - Inclusao historicos 1109 e 1110 na busca dos lan�amentos

                    02/05/2013 - Inclus�o de ajustes para trasnfer�ncia intercooperativa (Marcos-Supero)

                    04/06/2013 - Buscar Saldo Bloqueado Judicial e grava nas pltable (Marcos-Supero)

                    27/08/2013 - Incluso processo para buscar valor da tarifa usando b1wgen0153.
                               - Tratamento para hist�ricos 1009 e 1011 e remo��o do
                                 hist�rico fixo 1162 na procedure 'consulta-extrato' (Marcos-Supero);

                    15/01/2014 - Ajustada a leitura do cursor cr_crapepr, onde o campo
                                 craplcm.cdpesqbb estava sendo passado para compara��o
                                 com o crapepr.nrctremp, com a mascara do empr�stimo, o
                                 que causava invalid number (Marcos-Supero)

                    24/09/2014 - Ajuste para compor o credito do emprestimo no dia. (James)

                    30/10/2014 - Incluir o hist�rico 530 na lista de hist�ricos verificados
                                 em finais de semana e feriados. E verificar se o lan�amento
                                 de hist�rico 530 foi proveniente de agendamento.
                                 (Douglas - Projeto Capta��o Internet 2014/2)

                    16/11/2015 - SD359826 - Inclus�o da NVL na busca do cdpesqbb, pois quando n�o h�
                                 54 posi��es o substr estava ficando null e invalidando o teste
                                 (Marcos-Supero)
                    
                    30/11/2015 - Ajustar a busca do nome da agencia, pela agencia do cooperado
                                 (Douglas - Chamado 285228)

                    08/12/2015 - Ajustado query da craplcm para melhor performace SD358495 (Odirlei-AMcom)             
                    
                    20/01/2015 - Ajustado o indice da temptable de extrato ao criar registro de SALDO DO DIA 
                                 SD389994 (Odirlei-AMcom)
    */

    DECLARE
      -- Descri��o da origem da chamada
      vr_dsorigem VARCHAR2(10);
      -- Descri��o da transa��o
      vr_dstransa VARCHAR2(100);
      -- Descri��o da critica
      vr_dscritic VARCHAR2(4000);
      -- rowid tabela de log
      vr_nrdrowid ROWID;
      -- Data inicial e final para busca
      vr_dtiniper DATE;
      vr_dtfimper DATE;
      -- SAida da rotina de extrato
      vr_des_reto VARCHAR2(3);
      -- Sequencia das tabelas internas
      vr_ind_tab     VARCHAR2(12);
      vr_ind_tab_new VARCHAR2(12);
      -- Sequencia de data dentro da tabela de extrato
      vr_nrsequen INTEGER;
      -- Flag de primeiro registro encontrado
      vr_flgfirst BOOLEAN;
      -- Trabalho com a rotina Obtem_saldo
      vr_tab_sald EXTR0001.typ_tab_saldos;
      -- Retorno dos valores de bloqueio judiciais
      vr_vlblqjud NUMBER;
      vr_vlresblq NUMBER;
      -- Busca do tipo de pessoa do associado
      vr_inpessoa crapass.inpessoa%TYPE;
      -- Index para a temptable de tarifa
      vr_tariidx varchar2(11);
      -- Historicos 'de-para' Cabal
      vr_cdhishcb VARCHAR2(4000);
      --Flag valida se estar rodando no batch
      vr_flgcrass BOOLEAN;

      /* Tabelas de mem�ria para guardar registros cfme estrutura das Temp Tables */
      vr_tab_extr typ_tab_extrato_conta;    --> tt-extrato_conta
      vr_tab_depo typ_tab_dep_identificado; --> tt-dep-identificado
      
      CURSOR cr_crapass_age(pr_cdcooper IN crapass.cdcooper%TYPE,
                            pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT cdagenci
          FROM crapass
         WHERE crapass.cdcooper = pr_cdcooper
           AND crapass.nrdconta = pr_nrdconta;
      rw_crapass_age cr_crapass_age%ROWTYPE;


   -- Tipo de registro para o saldo da conta
   TYPE typ_reg_saldo IS
       RECORD(vlsddisp crapsda.vlsddisp%TYPE,
              vlsdchsl crapsda.vlsdchsl%TYPE,
              vlsdbloq crapsda.vlsdbloq%TYPE,
              vlsdblpr crapsda.vlsdblpr%TYPE,
              vlsdblfp crapsda.vlsdblfp%TYPE);

   /* Defini��o de tabela que compreende os registros acima declarados */

   TYPE typ_tab_saldo IS
     TABLE OF typ_reg_saldo
     INDEX BY PLS_INTEGER;

   vr_tab_saldo typ_tab_saldo;
    
   -- Busca o saldo para popular a temp/table
   CURSOR cr_crapsda2 IS
    SELECT dtmvtolt,
           vlsddisp,
           vlsdchsl,
           vlsdbloq,
           vlsdblpr,
           vlsdblfp
      FROM crapsda sda
     WHERE cdcooper = pr_cdcooper
       and nrdconta = pr_nrdconta
       and dtmvtolt between pr_dtiniper and pr_dtfimper;


    BEGIN

      -- Se foi solicitado LOG
      IF pr_flgerlog THEN
        -- busca informa��es que ser�o aproveitas posteriormente
        vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
        vr_dstransa := 'Consultar dados Dep. Vista.';
      END IF;
      
      -- Verificar se o BATCH esta rodando
      IF pr_rw_crapdat.inproces <> 1 THEN
        -- Se estiver no BATCH, utiliza a verificacao da conta a partir do vetor de contas
        -- que se nao estiver carregado fara a leitura de todas as contas da cooperativa
        -- Quando eh BATCH mantem o padrao TRUE
        vr_flgcrass := TRUE;
      ELSE 
        -- Se nao estiver no BATCH, busca apenas a informacao da conta que esta sendo passada
        vr_flgcrass := FALSE;
      END IF;
      
      -- Busca do tipo de pessoa do associado
      vr_inpessoa := fn_inpessoa_nrdconta(pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_flgcrass => vr_flgcrass);
      -- Se retornou zero n�o existe essa conta na cooperativa
      IF vr_inpessoa = 0 THEN
        -- Gerar critica 9
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 9 --> Critica
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Se foi solicitado gera��o de LOG
        IF pr_flgerlog THEN
          -- Chamar gera��o de LOG
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => vr_dsorigem
                              ,pr_dstransa => vr_dstransa
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0 --> FALSE
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
          -- Levantar exce��o
          RAISE vr_exc_erro;
        END IF;
      END IF;

      -- Se o vetor de tarifas transferencia entre contas n�o conter para cooperativa
      IF NOT vr_tab_tarifa_transf.exists(lpad(pr_cdcooper,10,'0')||'1') OR
         NOT vr_tab_tarifa_transf.exists(lpad(pr_cdcooper,10,'0')||'2') THEN
        -- Subrotina para buscar as tarifas de transferencia
        pc_busca_tarifa_transfere(pr_cdcooper => pr_cdcooper
                                 ,pr_dscritic => vr_dscritic);
        -- Se houver retorno de erro
        IF vr_dscritic IS NOT NULL THEN
          -- Gerar o erro
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => 0 --> Critica 0
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
          -- Sair
          RAISE vr_exc_erro;
        END IF;
      END IF;

      -- Limpar o vetor de lan�amentos
      vr_tab_extr.DELETE;
      -- Se n�o foi passado per�odo inicial
      IF pr_dtiniper IS NULL THEN
        -- Usa o primeiro dia do m�s corrente
        vr_dtiniper := TRUNC(pr_rw_crapdat.dtmvtolt,'mm');
      ELSE
        -- Usar a data informada
        vr_dtiniper := pr_dtiniper;
      END IF;
      -- Para caixa ON_LINE - pr_idorigem = 2
      IF pr_idorigem = 2 THEN
        -- A data inicial n�o pode ser inferior ao
        -- primeiro dia do m�s anterior ao movimento
        IF vr_dtiniper < ADD_MONTHS(TRUNC(pr_rw_crapdat.dtmvtolt,'mm'),-1) THEN
          -- Usar o primeiro dia do m�s anterior ao movimento
          vr_dtiniper := ADD_MONTHS(TRUNC(pr_rw_crapdat.dtmvtolt,'mm'),-1);
        END IF;
      END IF;
      -- Para Internet ou TAA (pr_idorigem 3 ou 4) THEN
      IF pr_idorigem IN (3,4) THEN
        -- DAta final n�o pode ser superior a hoje
        IF pr_dtfimper > trunc(sysdate) THEN
          -- Usar o dia de hoje como data final
          vr_dtfimper := trunc(sysdate);
        ELSE
          -- Usar a data passada
          vr_dtfimper := pr_dtfimper;
        END IF;
      ELSE --> Todos outros
        -- Se a data final n�o foi passada ou � superior ao movimento atual
        IF pr_dtfimper IS NULL OR pr_dtfimper > pr_rw_crapdat.dtmvtolt THEN
          -- Usar a data do movimento atual
          vr_dtfimper := pr_rw_crapdat.dtmvtolt;
        ELSE
          -- Usar a data passada
          vr_dtfimper := pr_dtfimper;
        END IF;
      END IF;
      -- Busca de todos os lan�amentos
      FOR rw_craplcm_ign IN cr_craplcm_ign(pr_cdcooper => pr_cdcooper      --> Cooperativa conectada
                                  ,pr_nrdconta => pr_nrdconta      --> N�mero da conta
                                  ,pr_dtiniper => vr_dtiniper      --> Data movimento inicial
                                  ,pr_dtfimper => vr_dtfimper      --> Data movimento final
                                          ,pr_cdhistor_ign => '289') LOOP  --> Lista com c�digos de hist�rico a ignorar
        -- Chama rotina que gera-registro-extrato na temp-table
        pc_gera_registro_extrato(pr_cdcooper     => pr_cdcooper   --> Cooperativa conectada
                                ,pr_rowid        => rw_craplcm_ign.rowid --> Registro buscado da craplcm
                                ,pr_flgident     => FALSE         --> Se deve ou n�o usar o craplcm.dsidenti
                                ,pr_nmdtable     => 'E'           --> Extrato ou Dep�sito
                                ,pr_lshistor     => pr_lshistor   --> Lista de hist�ricos de Cheques
                                ,pr_tab_extr     => vr_tab_extr   --> Tabela Extrato
                                ,pr_tab_depo     => vr_tab_depo   --> Tabela Depositos
                                ,pr_des_reto     => vr_des_reto   --> Retorno OK ou NOK
                                ,pr_des_erro     => vr_dscritic);
        -- Se houve erro
        IF vr_des_reto = 'NOK' THEN
          -- Chamar rotina de grava��o de erro
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => 0 --> Critica 0
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
          -- Se foi solicitado gera��o de LOG
          IF pr_flgerlog THEN
            -- Chamar gera��o de LOG
            gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                ,pr_cdoperad => pr_cdoperad
                                ,pr_dscritic => vr_dscritic
                                ,pr_dsorigem => vr_dsorigem
                                ,pr_dstransa => vr_dstransa
                                ,pr_dttransa => TRUNC(SYSDATE)
                                ,pr_flgtrans => 0 --> FALSE
                                ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                                ,pr_idseqttl => pr_idseqttl
                                ,pr_nmdatela => pr_nmdatela
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrdrowid => vr_nrdrowid);
          END IF;
          -- Levantar exce��o
          RAISE vr_exc_erro;
        END IF;
      END LOOP; --> Fim leitura lan�amentos

      --Definir index
      vr_tariidx := lpad(pr_cdcooper,10,'0')||vr_inpessoa;
      --Verificar se existe tarifa para pessoa fisica 1 ou juridica 2
      IF NOT vr_tab_tarifa_transf.EXISTS(vr_tariidx) AND vr_inpessoa < 3 THEN
        vr_dscritic := 'Tarifa para cooperativa '||pr_cdcooper||' inpessoa '||vr_inpessoa||' n�o localizada!';
        -- Gerar erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Efetuar raise para sair do processo
        RAISE vr_exc_erro;
      END IF;


      /***********************************************************************/
      /** Se for feriado ou final de semana, os historicos abaixo devem ser **/
      /** listados mesmo que a dtmvtolt do lancamento seja maior que TODAY, **/
      /** Valido somente se par_dtfimper igual ao dia do feriado, sabado ou **/
      /** domingo.                                                          **/
      /***********************************************************************/
      IF pr_dtfimper > pr_rw_crapdat.dtmvtoan AND pr_dtfimper < pr_rw_crapdat.dtmvtocd THEN
        -- Busca de dos lan�amentos:
        -- --- ---------------------------------
        -- 316 SAQUE CARTAO
        -- 375 TRANSF CARTAO
        -- 376 TRF.CARTAO I.
        -- 377 CR.TRF.CARTAO
        -- 450 SAQUE CARTAO
        -- 530 CR.APL.RDCPOS
        -- 537 TR.INTERNET
        -- 538 TR.INTERNET I
        -- 539 CR. INTERNET
        -- 767 ESTORNO SAQUE
        -- 771 TR. SALARIO
        -- 772 CR. SALARIO
        -- 918 SAQUE TAA
        -- 920 EST.SAQUE TAA
        -- 1109 CR. CESSAO
        -- 1110 DB.CESSAO
        -- 1009 TRANSF.INTERC
        -- 1011 CR.TRF.INTERC
        -- vr_cdhisint --> Hist�rico de tarifa de transferencia Internet (TARI0001.pc_carrega_dados_tar_vigente)
        -- vr_cdhistaa --> Hist�rico de tarifa de transferencia TAA      (TARI0001.pc_carrega_dados_tar_vigente)

        -- Busca os historicos da tabela 'de-para' da Cabal
        FOR rw_craphcb IN cr_craphcb LOOP
          vr_cdhishcb := vr_cdhishcb || ',' || rw_craphcb.cdhistor;
        END LOOP;

        FOR rw_craplcm_olt IN cr_craplcm_olt(pr_cdcooper => pr_cdcooper            --> Cooperativa conectada
                                    ,pr_nrdconta => pr_nrdconta            --> N�mero da conta
                                    ,pr_dtmvtolt => pr_rw_crapdat.dtmvtocd --> Data do movimento utilizada no cash dispenser.                                    
                                    ,pr_lsthistor_ret => '15,316,375,376,377,450,530,537,538,539,767,771,772,918,920,1109,1110,1009,1011,'||vr_tab_tarifa_transf(vr_tariidx).cdhisint||','||vr_tab_tarifa_transf(vr_tariidx).cdhistaa || vr_cdhishcb) LOOP --> Lista com c�digos de hist�rico a retornar
          -- Se for uma transferencia agendada, nao compor saldo
          IF NOT( (rw_craplcm_olt.cdhistor IN(375,376,377,537,538,539,771,772) AND NVL(SUBSTR(rw_craplcm_olt.cdpesqbb,54,8),' ') = 'AGENDADO')
                 OR
                  (rw_craplcm_olt.cdhistor IN(1009,1011,vr_tab_tarifa_transf(vr_tariidx).cdhisint,vr_tab_tarifa_transf(vr_tariidx).cdhistaa) AND NVL(SUBSTR(rw_craplcm_olt.cdpesqbb,15,8),' ') = 'AGENDADO')
                 OR
                  (rw_craplcm_olt.cdhistor = 530 AND rw_craplcm_olt.cdpesqbb <> 'ONLINE')
                ) THEN
            -- Chama rotina que gera-registro-extrato na temp-table
            pc_gera_registro_extrato(pr_cdcooper     => pr_cdcooper   --> Cooperativa conectada
                                    ,pr_rowid        => rw_craplcm_olt.rowid --> Registro buscado da craplcm
                                    ,pr_flgident     => FALSE         --> Se deve ou n�o usar o craplcm.dsidenti
                                    ,pr_nmdtable     => 'E'           --> Extrato ou Dep�sito
                                    ,pr_lshistor     => pr_lshistor   --> Lista de hist�ricos de Cheques
                                    ,pr_tab_extr     => vr_tab_extr   --> Tabela Extrato
                                    ,pr_tab_depo     => vr_tab_depo   --> Tabela Depositos
                                    ,pr_des_reto     => vr_des_reto   --> Retorno OK ou NOK
                                    ,pr_des_erro     => vr_dscritic);
            -- Se houve erro
            IF pr_des_reto = 'NOK' THEN
              -- Chamar rotina de grava��o de erro
              gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                   ,pr_cdagenci => pr_cdagenci
                                   ,pr_nrdcaixa => pr_nrdcaixa
                                   ,pr_nrsequen => 1 --> Fixo
                                   ,pr_cdcritic => 0 --> Critica 0
                                   ,pr_dscritic => vr_dscritic
                                   ,pr_tab_erro => pr_tab_erro);
              -- Se foi solicitado gera��o de LOG
              IF pr_flgerlog THEN
                -- Chamar gera��o de LOG
                gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                    ,pr_cdoperad => pr_cdoperad
                                    ,pr_dscritic => vr_dscritic
                                    ,pr_dsorigem => vr_dsorigem
                                    ,pr_dstransa => vr_dstransa
                                    ,pr_dttransa => TRUNC(SYSDATE)
                                    ,pr_flgtrans => 0 --> FALSE
                                    ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                                    ,pr_idseqttl => pr_idseqttl
                                    ,pr_nmdatela => pr_nmdatela
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_nrdrowid => vr_nrdrowid);
              END IF;
              -- Levantar exce��o
              RAISE vr_exc_erro;
            END IF;
          END IF;
        END LOOP;
      END IF;
      /* Verifica os envelopes nao processados, depositados no cash para o saldo bloqueado */
      FOR rw_crapenl IN cr_crapenl(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_dtiniper => pr_dtiniper
                                  ,pr_dtfimper => pr_dtfimper) LOOP
        -- Busca Saldo Bloqueado Judicial
        gene0005.pc_retorna_valor_blqjud(pr_cdcooper => pr_cdcooper            --> Cooperativa
                                        ,pr_nrdconta => pr_nrdconta            --> Conta
                                        ,pr_nrcpfcgc => 0                      --> Fixo - CPF/CGC
                                        ,pr_cdtipmov => 0                      --> Fixo - Tipo do movimento
                                        ,pr_cdmodali => 1                      --> Modalidade Cta Corrente
                                        ,pr_dtmvtolt => pr_rw_crapdat.dtmvtolt --> Data atual
                                        ,pr_vlbloque => vr_vlblqjud            --> Valor bloqueado
                                        ,pr_vlresblq => vr_vlresblq            --> Valor que falta bloquear
                                        ,pr_dscritic => vr_dscritic);          --> Erros encontrados no processo
        -- Monta a chave hash para o vetor (Data + Sequencial)
        pc_chave_extrato_conta(pr_dtmvtolt  => rw_crapenl.dtmvtolt
                              ,pr_tab_extr  => vr_tab_extr
                              ,pr_des_chave => vr_ind_tab
                              ,pr_seq_reg   => vr_nrsequen);
        -- Finalmente cria o novo registro
        vr_tab_extr(vr_ind_tab).nrdconta := pr_nrdconta;
        vr_tab_extr(vr_ind_tab).dtmvtolt := rw_crapenl.dtmvtolt;
        vr_tab_extr(vr_ind_tab).nrsequen := vr_nrsequen;
        vr_tab_extr(vr_ind_tab).vlblqjud := vr_vlblqjud;
        vr_tab_extr(vr_ind_tab).nrdolote := 0;
        vr_tab_extr(vr_ind_tab).cdagenci := 0;
        vr_tab_extr(vr_ind_tab).cdbccxlt := 0;
        vr_tab_extr(vr_ind_tab).cdcoptfn := 0;
        vr_tab_extr(vr_ind_tab).vllanmto := nvl(rw_crapenl.vldininf,0) + nvl(rw_crapenl.vlchqinf,0);
        vr_tab_extr(vr_ind_tab).dsidenti := gene0002.fn_mask(rw_crapenl.cdcoptfn,'9999') || '/'
                                         || gene0002.fn_mask(rw_crapenl.cdagetfn,'9999') || '/'
                                         || gene0002.fn_mask(rw_crapenl.nrterfin,'9999');
        vr_tab_extr(vr_ind_tab).nrdocmto := gene0002.fn_mask(rw_crapenl.nrseqenv,'zzzzzzz.zz9');
        vr_tab_extr(vr_ind_tab).dtliblan := '(**/**)';
        vr_tab_extr(vr_ind_tab).indebcre := 'C';
        vr_tab_extr(vr_ind_tab).inhistor := 3;
        vr_tab_extr(vr_ind_tab).cdhistor := 698;
        vr_tab_extr(vr_ind_tab).dsextrat := 'DEPOSITO TAA*';
        vr_tab_extr(vr_ind_tab).dshistor := 'DEPOSITO TAA*';
      END LOOP;
      -- Ativa flag de primeiro registro encontrado
      vr_flgfirst := TRUE;
      -- Varrer o vetor usando as chaves hash
      vr_ind_tab := vr_tab_extr.FIRST;
      

      
      -- Popula a temp table de saldo
      FOR rw_crapsda IN cr_crapsda2 LOOP
        vr_tab_saldo(to_char(rw_crapsda.dtmvtolt,'YYYYMMDD')).vlsddisp := rw_crapsda.vlsddisp;
        vr_tab_saldo(to_char(rw_crapsda.dtmvtolt,'YYYYMMDD')).vlsdchsl := rw_crapsda.vlsdchsl;
        vr_tab_saldo(to_char(rw_crapsda.dtmvtolt,'YYYYMMDD')).vlsdbloq := rw_crapsda.vlsdbloq;
        vr_tab_saldo(to_char(rw_crapsda.dtmvtolt,'YYYYMMDD')).vlsdblpr := rw_crapsda.vlsdblpr;
        vr_tab_saldo(to_char(rw_crapsda.dtmvtolt,'YYYYMMDD')).vlsdblfp := rw_crapsda.vlsdblfp;
      END LOOP;

      
      LOOP
        -- Sair quando n�o existir a informa��o
        EXIT WHEN vr_ind_tab IS NULL;
        -- Se for o ultimo registro da data ou do vetor
        IF vr_ind_tab = vr_tab_extr.LAST OR vr_tab_extr(vr_ind_tab).dtmvtolt <> vr_tab_extr(vr_tab_extr.NEXT(vr_ind_tab)).dtmvtolt THEN
          -- Para origens 3,4,5 ('INTERNET','CASH','INTRANET') e na primeira intera��o
          IF pr_idorigem IN(3,4,5) AND vr_flgfirst THEN
            -- Desativa flag de primeiro encontro
            vr_flgfirst := FALSE;
            -- Chamar rotina para busca do saldo
            extr0001.pc_obtem_saldo(pr_cdcooper   => pr_cdcooper
                                   ,pr_rw_crapdat => pr_rw_crapdat
                                   ,pr_cdagenci   => pr_cdagenci
                                   ,pr_nrdcaixa   => pr_nrdcaixa
                                   ,pr_cdoperad   => pr_cdoperad
                                   ,pr_nrdconta   => pr_nrdconta
                                   ,pr_dtrefere   => vr_tab_extr(vr_ind_tab).dtmvtolt
                                   ,pr_des_reto   => vr_des_reto
                                   ,pr_tab_sald   => vr_tab_sald
                                   ,pr_tab_erro   => pr_tab_erro);
            -- Leitura dos dados do associados
            rw_crapage := NULL;
            OPEN cr_crapass_age(pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => pr_nrdconta);
            FETCH cr_crapass_age INTO rw_crapass_age;
            IF cr_crapass_age%FOUND THEN
              -- Leitura da ag�ncia do associado
              OPEN cr_crapage(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => rw_crapass_age.cdagenci);
              FETCH cr_crapage
               INTO rw_crapage;
              CLOSE cr_crapage;
            ELSE 
              -- Leitura da ag�ncia do associado
              OPEN cr_crapage(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci);
              FETCH cr_crapage
               INTO rw_crapage;
              CLOSE cr_crapage;
            END IF;
              
            -- Monta uma nova chave usando a data atual e a sequencia zero para inserir no in�cio
            vr_ind_tab_new := to_char(vr_tab_extr(vr_ind_tab).dtmvtolt,'yymmdd')||LPAD(0,6,'0');
            -- Criar um registro totalizador do dia
            vr_tab_extr(vr_ind_tab_new).vllanmto := nvl(vr_tab_sald(vr_tab_sald.FIRST).vlsddisp,0) + nvl(vr_tab_sald(vr_tab_sald.FIRST).vlsdchsl,0)
                                                  + nvl(vr_tab_sald(vr_tab_sald.FIRST).vlsdbloq,0) + nvl(vr_tab_sald(vr_tab_sald.FIRST).vlsdblpr,0)
                                                  + nvl(vr_tab_sald(vr_tab_sald.FIRST).vlsdblfp,0);
            vr_tab_extr(vr_ind_tab_new).nrsequen := 0;
            vr_tab_extr(vr_ind_tab_new).nrdconta := pr_nrdconta;
            vr_tab_extr(vr_ind_tab_new).dtmvtolt := vr_tab_extr(vr_ind_tab).dtmvtolt;
            vr_tab_extr(vr_ind_tab_new).nrdocmto := '';
            vr_tab_extr(vr_ind_tab_new).indebcre := '';
            vr_tab_extr(vr_ind_tab_new).inhistor := 0;
            vr_tab_extr(vr_ind_tab_new).cdhistor := 0;
            vr_tab_extr(vr_ind_tab_new).dshistor := 'SALDO ANTERIOR';
            vr_tab_extr(vr_ind_tab_new).dsextrat := 'SALDO ANTERIOR';
            vr_tab_extr(vr_ind_tab_new).vllimcre := pr_vllimcre;
            vr_tab_extr(vr_ind_tab_new).dsagenci := rw_crapage.nmextage;
          END IF;

          OPEN cr_crapsda_pk(pr_cdcooper => pr_cdcooper
                            ,pr_dtmvtolt => vr_tab_extr(vr_ind_tab).dtmvtolt
                            ,pr_nrdconta => pr_nrdconta);
          FETCH cr_crapsda_pk INTO rw_crapsda;

          -- Se encontrar
          IF cr_crapsda_pk%FOUND THEN
            -- Fechar cursor
            CLOSE cr_crapsda_pk;
            -- Atualiza o registro base da repeti��o
            vr_tab_extr(vr_ind_tab).vlsddisp := rw_crapsda.vlsddisp;
            vr_tab_extr(vr_ind_tab).vlsdchsl := rw_crapsda.vlsdchsl;
            vr_tab_extr(vr_ind_tab).vlsdbloq := rw_crapsda.vlsdbloq;
            vr_tab_extr(vr_ind_tab).vlsdblpr := rw_crapsda.vlsdblpr;
            vr_tab_extr(vr_ind_tab).vlsdblfp := rw_crapsda.vlsdblfp;
            vr_tab_extr(vr_ind_tab).vlsdtota := nvl(rw_crapsda.vlsddisp,0) + nvl(rw_crapsda.vlsdchsl,0)
                                              + nvl(rw_crapsda.vlsdbloq,0) + nvl(rw_crapsda.vlsdblpr,0)
                                              + nvl(rw_crapsda.vlsdblfp,0);
          ELSE
            -- Fechar cursor
            CLOSE cr_crapsda_pk;
            -- Chamar rotina para busca do saldo do dia
            extr0001.pc_obtem_saldo_dia(pr_cdcooper   => pr_cdcooper
                                       ,pr_rw_crapdat => pr_rw_crapdat
                                       ,pr_cdagenci   => pr_cdagenci
                                       ,pr_nrdcaixa   => pr_nrdcaixa
                                       ,pr_cdoperad   => pr_cdoperad
                                       ,pr_nrdconta   => pr_nrdconta
                                       ,pr_vllimcre   => pr_vllimcre
                                       ,pr_dtrefere   => vr_tab_extr(vr_ind_tab).dtmvtolt
                                       ,pr_tipo_busca => 'A' --Chamado 291693 (Heitor - RKAM)
                                       ,pr_des_reto   => vr_des_reto
                                       ,pr_tab_sald   => vr_tab_sald
                                       ,pr_tab_erro   => pr_tab_erro);
            -- Se encontrou alguma informa��o no vetor
            IF vr_tab_sald.COUNT > 0 THEN
              -- Atualiza o registro base da repeti��o
              vr_tab_extr(vr_ind_tab).vlsddisp := vr_tab_sald(vr_tab_sald.FIRST).vlsddisp;
              vr_tab_extr(vr_ind_tab).vlsdchsl := vr_tab_sald(vr_tab_sald.FIRST).vlsdchsl;
              vr_tab_extr(vr_ind_tab).vlsdbloq := vr_tab_sald(vr_tab_sald.FIRST).vlsdbloq;
              vr_tab_extr(vr_ind_tab).vlsdblpr := vr_tab_sald(vr_tab_sald.FIRST).vlsdblpr;
              vr_tab_extr(vr_ind_tab).vlsdblfp := vr_tab_sald(vr_tab_sald.FIRST).vlsdblfp;
              vr_tab_extr(vr_ind_tab).vlsdtota := nvl(vr_tab_sald(vr_tab_sald.FIRST).vlsddisp,0) + nvl(vr_tab_sald(vr_tab_sald.FIRST).vlsdchsl,0)
                                                + nvl(vr_tab_sald(vr_tab_sald.FIRST).vlsdbloq,0) + nvl(vr_tab_sald(vr_tab_sald.FIRST).vlsdblpr,0)
                                                + nvl(vr_tab_sald(vr_tab_sald.FIRST).vlsdblfp,0);
            ELSE
              -- Sumarizar zero
              vr_tab_extr(vr_ind_tab).vlsdtota := 0;
            END IF;
          END IF;
          -- Para origem 4 - Cash
          IF pr_idorigem = 4  THEN
            -- Inserir este registro no final dos lan�amentos deste dia
            vr_ind_tab_new := to_char(vr_tab_extr(vr_ind_tab).dtmvtolt,'yymmdd')||LPAD(vr_tab_extr(vr_ind_tab).nrsequen + 1,6,'0');
            -- Cria um registro de Saldo do Dia
            vr_tab_extr(vr_ind_tab_new).nrdconta := vr_tab_extr(vr_ind_tab).nrdconta;
            vr_tab_extr(vr_ind_tab_new).dtmvtolt := vr_tab_extr(vr_ind_tab).dtmvtolt;
            vr_tab_extr(vr_ind_tab_new).nrdocmto := '';
            vr_tab_extr(vr_ind_tab_new).indebcre := '';
            vr_tab_extr(vr_ind_tab_new).inhistor := 0;
            vr_tab_extr(vr_ind_tab_new).cdhistor := 0;
            vr_tab_extr(vr_ind_tab_new).dshistor := 'SALDO DO DIA';
            vr_tab_extr(vr_ind_tab_new).dsextrat := 'SALDO DO DIA';
            vr_tab_extr(vr_ind_tab_new).nrsequen := vr_tab_extr(vr_ind_tab).nrsequen + 1;
            vr_tab_extr(vr_ind_tab_new).vllanmto := vr_tab_extr(vr_ind_tab).vlsdtota;
            
            vr_ind_tab := vr_ind_tab_new;
          END IF;
        END IF;
        -- Buscar o pr�ximo registro do Hash
        vr_ind_tab := vr_tab_extr.NEXT(vr_ind_tab);
      END LOOP;
      -- Ap�s processar todos os extratos, copiar o vetor montado para a sa�da do procedicmento
      pr_tab_extrato := vr_tab_extr;
      -- Se foi solicitado gera��o de LOG
      IF pr_flgerlog THEN
        -- Efetuar grava��o do LOG final
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => ' '
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1 --> TRUE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;
      -- Retorno OK
      pr_des_reto := 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Limpa vetor de saldo
        pr_tab_extrato.DELETE;
      WHEN OTHERS THEN

        btch0001.pc_log_internal_exception(pr_cdcooper);
      
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Limpa vetor de saldo
        pr_tab_extrato.DELETE;
        -- Chamar rotina de grava��o de erro
        vr_dscritic := 'Erro na pc_consulta_extrato --> '|| sqlerrm;
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0 --> Critica 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Se foi solicitado gera��o de LOG
        IF pr_flgerlog THEN
          -- Chamar gera��o de LOG
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => vr_dsorigem
                              ,pr_dstransa => vr_dstransa
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0 --> FALSE
                              ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
        END IF;
    END;
  END pc_consulta_extrato;

/* Envio dos extratos aos cooperados */
  PROCEDURE pc_envia_extrato_email(pr_cdcooper        IN crapcop.cdcooper%TYPE
                                  ,pr_rw_crapdat      IN btch0001.cr_crapdat%ROWTYPE
                                  ,pr_nmrescop        IN crapcop.nmrescop%TYPE
                                  ,pr_cdprogra        IN crapprg.cdprogra%TYPE
                                  ,pr_dtmvtolt        IN crapdat.dtmvtolt%TYPE
                                  ,pr_lshistor        IN craptab.dstextab%TYPE
                                  ,pr_tab_env_extrato IN typ_tab_env_extrato
                                  ,pr_des_erro       OUT VARCHAR2) IS
  BEGIN
    --    Programa: pc_envia_extrato_email (antigo trecho da fontes/crps217.p)
    --    Sistema : Conta-Corrente - Cooperativa de Credito
    --    Sigla   : CRED
    --    Autor   : Marcos (Supero)
    --    Data    : Dez/2012                         Ultima atualizacao: 22/09/2014
    --
    --    Dados referetes ao programa:
    --    Frequencia: Sempre que chamado pelos programas de extrato da conta
    --
    --    Objetivo  : Varrer a pltable pr_tab_env_extrato e gerar os extratos
    --                para envio por email dos cooperados
    --
    --    Alteracoes: 04/12/2012 - Convers�o de Progress >> Oracle PLSQL
    --
    --                31/07/2013 - Incluir novo par�metro pr_flg_log_batch (Marcos/Supero)
    --
    --                09/08/2013 - Troca da busca do mes por extenso com to_char para
    --                             utilizarmos o vetor gene0001.vr_vet_nmmesano (Marcos-Supero)
    --
    --                25/09/2013 - Substitui��o do tipo da variavel vr_dsdemail para varchar2(4000)
    --                             pois baseada na tabela crapcem estava estourando a variavel
    --                             (Marcos-Supero)
    --
    --                20/01/2014 - N�o remover o arquivo na solicita��o de e-mail (Marcos-Supero)
    --
    --                22/09/2014 - Adicionado observacao no corpo de e-mail (Daniele).


    DECLARE
      -- Per�odo do extrato
      vr_dsperiod VARCHAR2(400);
      -- Diret�rio para grava��o de arquivos
      vr_dsdireto VARCHAR2(400);
      vr_dsdircop VARCHAR2(400);
      -- Apontadores para os registros de extrato
      vr_ind_ext VARCHAR2(12); -- Chave da tabela Dta + Sequencia
      vr_ind_pri BINARY_INTEGER;
      -- Lista de remetentes
      vr_dsdemail VARCHAR2(4000);
      -- Nome do arquivo
      vr_nmarquiv VARCHAR2(400);
      -- Handle para arquivo
      vr_ind_arq UTL_FILE.FILE_TYPE;
      -- LInha tracejada
      vr_dslinha VARCHAR2(100)  := '------------------------------------------------------------------------------';
      -- Header dos dados
      vr_dsheader VARCHAR2(100) := 'DATA        HISTORICO                DOCUMENTO         VALOR  D/C        SALDO';
      -- Linha tempor�ria gen�rica
      vr_dslintmp VARCHAR2(100);
      -- Trabalho com a rotina Obtem_saldo e Consulta_Extrato
      vr_des_reto VARCHAR2(3);
      vr_tab_sald EXTR0001.typ_tab_saldos;
      vr_tab_erro GENE0001.typ_tab_erro;
      vr_vlsdtota NUMBER(18,6);
      vr_tab_extr EXTR0001.typ_tab_extrato_conta;
      -- Contagem de linhas da p�gina e controle de quebra
      vr_qtd_linhas   NUMBER;
      vr_qtd_pagesize NUMBER := 84;
      -- Nomes para arquivo gerado e .zip
      vr_arquipdf VARCHAR2(4000);
      -- Busca senha que sera solicitada no arquivo por email
      CURSOR cr_crapsnh(pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT snh.cddsenha
          FROM crapsnh snh
         WHERE snh.cdcooper = pr_cdcooper
           AND snh.nrdconta = pr_nrdconta
           AND snh.idseqttl = 0
           AND snh.tpdsenha = 2;
      vr_cddsenha crapsnh.cddsenha%TYPE;
      -- Assunto para montagem do e-mail
      vr_dscorpo VARCHAR2(2000);
      -- Rowid para inser��o de log
      vr_nrdrowid ROWID;

      /* Cursor gen�rico de parametriza��o */
      CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE
                       ,pr_nmsistem IN craptab.nmsistem%TYPE
                       ,pr_tptabela IN craptab.tptabela%TYPE
                       ,pr_cdempres IN craptab.cdempres%TYPE
                       ,pr_cdacesso IN craptab.cdacesso%TYPE) IS
        SELECT tab.tpregist
              ,tab.dstextab
          FROM craptab tab
         WHERE tab.cdcooper = pr_cdcooper
           AND UPPER(tab.nmsistem) = pr_nmsistem
           AND UPPER(tab.tptabela) = pr_tptabela
           AND tab.cdempres = pr_cdempres
           AND UPPER(tab.cdacesso) = pr_cdacesso;
      vr_dstextab craptab.dstextab%TYPE;

      -- Defini��o de tabela de mem�ria para armazenar
      -- as descri��es gen�ricas da craptab para esquemas de envio
      TYPE typ_tab_craptab IS
        TABLE OF craptab.dstextab%TYPE
          INDEX BY PLS_INTEGER; -- Cod linha de cr�dito
      vr_tab_cdperiod typ_tab_craptab; --> tipos de periodo
      vr_tab_formaenv typ_tab_craptab; --> formas de envio

      -- Subrotina que grava a linha passada ao arquivo e incrementa sua contagem
      PROCEDURE pc_insere_linha(pr_deslinha IN VARCHAR2) IS
      BEGIN
        -- Adiciona a linha no arquivo
        gene0001.pc_escr_linha_arquivo(vr_ind_arq,pr_deslinha);
        -- Incrementa a quantidade de linhas
        vr_qtd_linhas := vr_qtd_linhas + 1;
      END;

      -- Subrotina padr�o para montagem do cabe�alho do extrado
      PROCEDURE pc_insere_cabecalho(pr_ind_reg     IN BINARY_INTEGER --> Posi��o no vetor
                                   ,pr_envia_limi  IN BOOLEAN        --> Se devemos enviar a linha de saldos e limites
                                   ,pr_envia_head  IN BOOLEAN        --> Se enviaremos ou nao a linha de cabe�alho de lan�amentos
                                   ,pr_envia_saldo IN BOOLEAN) IS    --> Parametro para buscar e lan�ar o saldo santerior
      BEGIN
        -- Enviar o cabe�alho padr�o (Frame f_titulo)
        pc_insere_linha(rpad(pr_nmrescop,20,' ')||' - EXTRATO DE C/C      EMISSAO: '||to_char(pr_dtmvtolt,'dd/mm/yyyy')||' HORA: '||to_char(sysdate,'hh24:mi:ss'));
        pc_insere_linha(vr_dslinha); --> Linha tracejada
        pc_insere_linha(vr_dsperiod);
        pc_insere_linha(vr_dslinha); --> Linha tracejada
        -- Nome e conta do cooperado e valores (Frame f_destino)
        pc_insere_linha(rpad(pr_tab_env_extrato(pr_ind_reg).nmprimtl,68,' ')||gene0002.fn_mask_conta(pr_tab_env_extrato(pr_ind_reg).nrdconta));
        pc_insere_linha(vr_dslinha); --> Linha tracejada
        -- Se foi solicitado o envio des limites e saldo
        IF pr_envia_limi THEN
          pc_insere_linha('    Limite de Credito          Capital     Saldo Medio Mes   Saldo Medio Trim');
          -- Monta linha com limites e saldos
          vr_dslintmp := '        '||TO_CHAR(pr_tab_env_extrato(pr_ind_reg).vllimcre,'9g999g990d00')||'    ';
          -- Concatena na vr_dslintmp CAmpos total capitaliza��o, saldo mensal e trimestral
          vr_dslintmp := vr_dslintmp || TO_CHAR(pr_tab_env_extrato(pr_ind_reg).vltotcap,'9g999g990d00')||'      ';
          vr_dslintmp := vr_dslintmp || TO_CHAR(pr_tab_env_extrato(pr_ind_reg).vlsmdmes,'99g999g990d00')||'     ';
          vr_dslintmp := vr_dslintmp || TO_CHAR(pr_tab_env_extrato(pr_ind_reg).vlsmtrim,'99g999g990d00')||'      ';
          -- Envia a linha montada
          pc_insere_linha(vr_dslintmp);
        END IF;
        -- Enviar linha em branco
        pc_insere_linha('');
        -- Se foi solicitado para enviar o Header
        IF pr_envia_head THEN
          -- envia o cabe�alho de lan�amentos
          pc_insere_linha(vr_dsheader);
        ELSE
          -- envia uma linha em branco
          pc_insere_linha('');
        END IF;
        -- Se foi solicitando para enviar o saldo anterior
        IF pr_envia_saldo THEN
          -- Busca do saldo da conta no in�cio do m�s
          extr0001.pc_obtem_saldo(pr_cdcooper   => pr_cdcooper
                                 ,pr_rw_crapdat => pr_rw_crapdat
                                 ,pr_cdagenci   => 1 -- Fixo 1
                                 ,pr_nrdcaixa   => 900 -- Fixo 900
                                 ,pr_cdoperad   => '1' -- Fixo 1
                                 ,pr_nrdconta   => pr_tab_env_extrato(pr_ind_reg).nrdconta
                                 ,pr_dtrefere   => trunc(pr_dtmvtolt,'mm') --> In�cio do m�s
                                 ,pr_des_reto   => vr_des_reto
                                 ,pr_tab_sald   => vr_tab_sald
                                 ,pr_tab_erro   => vr_tab_erro);
          -- Se houve retorno n�o Ok
          IF vr_des_reto = 'NOK' THEN
            -- Tenta buscar o erro no vetor de erro
            IF vr_tab_erro.COUNT > 0 THEN
              vr_des_erro := vr_tab_erro(vr_tab_erro.FIRST).dscritic|| ' Conta: '||pr_tab_env_extrato(pr_ind_reg).nrdconta;
            ELSE
              vr_des_erro := 'Retorno "NOK" na extr0001.pc_obtem_saldo e sem informa��o na pr_vet_erro, Conta: '||pr_tab_env_extrato(pr_ind_reg).nrdconta;
            END IF;
            -- Abandona o processo
            RAISE vr_exc_erro;
          END IF;
          -- Montar a linha do saldo anterior encontrado
          vr_dslintmp := '            SALDO ANTERIOR';
          FOR vr_aux IN LENGTH(vr_dslintmp)..64 LOOP
            vr_dslintmp := vr_dslintmp || ' ';
          END LOOP;
          -- Acumular o saldo
          vr_vlsdtota := NVL(vr_tab_sald(vr_tab_sald.FIRST).vlsddisp,0)
                       + NVL(vr_tab_sald(vr_tab_sald.FIRST).vlsdchsl,0)
                       + NVL(vr_tab_sald(vr_tab_sald.FIRST).vlsdbloq,0)
                       + NVL(vr_tab_sald(vr_tab_sald.FIRST).vlsdblpr,0)
                       + NVL(vr_tab_sald(vr_tab_sald.FIRST).vlsdblfp,0);
          -- Adiciona o saldo computado
          vr_dslintmp := vr_dslintmp || to_char(vr_vlsdtota,'9g999g990d00');
          -- Finalmente envia a linha montada
          pc_insere_linha(vr_dslintmp);
        ELSE
          -- Insere um linha em branco
          pc_insere_linha('');
        END IF;
      END;

    BEGIN
      -- Somente se existirem informa��es
      IF pr_tab_env_extrato.COUNT > 0 THEN
        -- Busca descri��o do per�odo vinculado ao extrato
        FOR rw_craptab IN cr_craptab(pr_cdcooper => 0
                                    ,pr_nmsistem => 'CRED'
                                    ,pr_tptabela => 'USUARI'
                                    ,pr_cdempres => 11
                                    ,pr_cdacesso => 'PERIODICID') LOOP
          -- Povoar a pltable e chave�-la pelo c�digo do periodo
          vr_tab_cdperiod(rw_craptab.tpregist) := rw_craptab.dstextab;
        END LOOP;
        -- Busca descri��o da forma de envio
        FOR rw_craptab IN cr_craptab(pr_cdcooper => 0
                                    ,pr_nmsistem => 'CRED'
                                    ,pr_tptabela => 'USUARI'
                                    ,pr_cdempres => 11
                                    ,pr_cdacesso => 'FORENVINFO') LOOP
          -- Povoar a pltable e chave�-la pelo c�digo da forma de envio
          vr_tab_formaenv(rw_craptab.tpregist) := rw_craptab.dstextab;
        END LOOP;
        -- Monta per�odo do extrado
        vr_dsperiod := to_char(trunc(pr_dtmvtolt,'mm'),'dd')||' A '
                    || to_char(pr_dtmvtolt,'dd') || ' DE '
                    || gene0001.vr_vet_nmmesano(to_char(pr_dtmvtolt,'MM')) || ' DE '
                    || to_char(pr_dtmvtolt,'YYYY');
        -- Adicionar espa�os a esquerda para centralizar o campo na linha
        FOR vr_aux IN 1..41-TRUNC(LENGTH(vr_dsperiod)/2) LOOP
          vr_dsperiod := ' '||vr_dsperiod;
        END LOOP;
        -- Busca do diret�rio para grava��o
        vr_dsdircop := GENE0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/Coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => null);

        vr_dsdireto := vr_dsdircop||'/rl';

        -- Inicializar a lista de e-mails
        vr_dsdemail := '';
        -- Busca de todos os registros do vetor passado
        FOR vr_ind IN pr_tab_env_extrato.FIRST..pr_tab_env_extrato.LAST LOOP
          -- Se for o primeiro registro do vetor ou � o primeiro desta conta
          IF vr_ind = pr_tab_env_extrato.FIRST OR pr_tab_env_extrato(vr_ind).nrdconta <> pr_tab_env_extrato(vr_ind-1).nrdconta THEN
            -- Mudou a conta, guardar o primeiro registro desta conta
            vr_ind_pri := vr_ind;
          END IF;
          -- Agrega a lista de remetentes o e-mail atual
          vr_dsdemail := vr_dsdemail || pr_tab_env_extrato(vr_ind).dsdemail|| ';';
          -- Se este registro � o ultimo da conta ou o ultimo do vetor inteiro
          IF vr_ind = pr_tab_env_extrato.LAST OR pr_tab_env_extrato(vr_ind).nrdconta <>  pr_tab_env_extrato(vr_ind+1).nrdconta THEN
            -- Montar nome do arquivo
            vr_nmarquiv := 'extrato_'||pr_tab_env_extrato(vr_ind).nrdconta||'.lst';
            -- Tenta abrir o arquivo para envio das informa��es
            gene0001.pc_abre_arquivo(pr_nmdireto => vr_dsdireto    --> Diret�rio do arquivo
                                    ,pr_nmarquiv => vr_nmarquiv    --> Nome do arquivo
                                    ,pr_tipabert => 'W'            --> Modo de abertura (R,W,A)
                                    ,pr_utlfileh => vr_ind_arq     --> Handle do arquivo aberto
                                    ,pr_des_erro => vr_des_erro);
            IF vr_des_erro IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
            -- Zerar contagem de linhas
            vr_qtd_linhas := 0;
            -- Enviar o cabe�alho padr�o (Frame f_titulo + f_destino)
            pc_insere_cabecalho(pr_ind_reg     => vr_ind --> Posi��o no vetor
                               ,pr_envia_limi  => TRUE
                               ,pr_envia_head  => TRUE   --> envia cabe�alho de lan�amentos
                               ,pr_envia_saldo => TRUE); --> Fazer nova busca de saldo anterior
            -- Efetuar chamada a rotina que monta a tabela tempor�ria de extrato da conta
            extr0001.pc_consulta_extrato(pr_cdcooper     => pr_cdcooper
                                        ,pr_rw_crapdat   => pr_rw_crapdat
                                        ,pr_cdagenci     => 1
                                        ,pr_nrdcaixa     => 900
                                        ,pr_cdoperad     => '1'
                                        ,pr_nrdconta     => pr_tab_env_extrato(vr_ind).nrdconta
                                        ,pr_vllimcre     => pr_tab_env_extrato(vr_ind).vllimcre
                                        ,pr_dtiniper     => trunc(pr_dtmvtolt,'mm') --> In�cio do m�s
                                        ,pr_dtfimper     => pr_dtmvtolt     --> Data corrente
                                        ,pr_lshistor     => pr_lshistor
                                        ,pr_idorigem     => 2 --> Caixa
                                        ,pr_idseqttl     => 1
                                        ,pr_nmdatela     => pr_cdprogra
                                        ,pr_flgerlog     => FALSE        --> Sem log
                                        ,pr_des_reto     => vr_des_reto  --> OK ou NOK
                                        ,pr_tab_extrato  => vr_tab_extr  --> Vetor para o retorno das informa��es
                                        ,pr_tab_erro     => vr_tab_erro);
            -- Se houve retorno n�o Ok
            IF vr_des_reto = 'NOK' THEN
              -- Tenta buscar o erro no vetor de erro
              IF vr_tab_erro.COUNT > 0 THEN
                vr_des_erro := vr_tab_erro(vr_tab_erro.FIRST).dscritic || ' Conta: '||pr_tab_env_extrato(vr_ind).nrdconta;
              ELSE
                vr_des_erro := 'Retorno "NOK" na extr0001.pc_consulta_extrato e sem informa��o na pr_vet_erro, Conta: '||pr_tab_env_extrato(vr_ind).nrdconta;
              END IF;
              -- Abandona o processo
              RAISE vr_exc_erro;
            END IF;
            -- Busca a chave do primeiro registro do extrato
            vr_ind_ext := vr_tab_extr.FIRST;
            -- Varrer todos os registros do vetor atraves do .NEXT
            LOOP
              -- Sair quando n�o encontrou mais informa��es
              EXIT WHEN vr_ind_ext IS NULL;
              -- Se a quantidade de linhas atual + 2 excede o pagesize
              IF vr_qtd_linhas + 2 >= vr_qtd_pagesize THEN
                -- Enviar uma quebra de p�gina sem quebrar a linha
                gene0001.pc_escr_texto_arquivo(vr_ind_arq,chr(12));
                -- Zerar o contador de linhas
                vr_qtd_linhas := 0;
                -- Enviar o cabe�alho padr�o (Frame f_titulo_quebra)
                pc_insere_cabecalho(pr_ind_reg     => vr_ind  --> Posi��o no vetor principal
                                   ,pr_envia_limi  => FALSE   --> N�o envia saldos e limites
                                   ,pr_envia_head  => TRUE    --> envia cabe�alho de lan�amentos
                                   ,pr_envia_saldo => FALSE); --> N�o precisa fazer nova busca de saldo
              END IF;
              -- Enviar os lan�amentos do extrato
              vr_dslintmp := to_char(vr_tab_extr(vr_ind_ext).dtmvtolt,'dd/mm/yyyy')||'  '
                          || RPAD(SUBSTR(vr_tab_extr(vr_ind_ext).dsextrat,1,21),21,' ')||'  '
                          || LPAD(vr_tab_extr(vr_ind_ext).nrdocmto,11,' ')||' '
                          || to_char(vr_tab_extr(vr_ind_ext).vllanmto,'9G999G990D00')||'   '
                          || vr_tab_extr(vr_ind_ext).indebcre||' ';
              -- Se houver totalizador
              IF NVL(vr_tab_extr(vr_ind_ext).vlsdtota,0) <> 0 THEN
                -- Incluir o totalizador na linha
                vr_dslintmp := vr_dslintmp || to_char(vr_tab_extr(vr_ind_ext).vlsdtota,'9G999G990D00');
              END IF;
              -- Envia a linha de lan�amento montada
              pc_insere_linha(vr_dslintmp);
              -- Buscar a chave do pr�ximo registro
              vr_ind_ext := vr_tab_extr.NEXT(vr_ind_ext);
            END LOOP;
            -- Envia linha em branco
            pc_insere_linha('');
            -- Enviar linha tracejada
            pc_insere_linha(vr_dslinha); --> Linha tracejada
            -- Se a quantidade de linhas atual excede ou chegou no pagesize
            IF vr_qtd_linhas >= vr_qtd_pagesize THEN
              -- Enviar uma quebra de p�gina sem quebrar a linha
              gene0001.pc_escr_texto_arquivo(vr_ind_arq,chr(12));
              -- Zerar o contador de linhas
              vr_qtd_linhas := 0;
              -- Enviar o cabe�alho padr�o (Frame f_titulo_quebra)
              pc_insere_cabecalho(pr_ind_reg     => vr_ind  --> Posi��o no vetor
                                 ,pr_envia_limi  => FALSE   --> N�o envia saldos e limites
                                 ,pr_envia_head  => FALSE   --> N�o envia cabe�alho de lan�amentos
                                 ,pr_envia_saldo => FALSE); --> N�o precisa fazer nova busca de saldo
            END IF;
            -- Enviar as mensagens de aviso ao cooperado
            FOR vr_ind_msg IN pr_tab_env_extrato(vr_ind).msgemail.FIRST..pr_tab_env_extrato(vr_ind).msgemail.LAST LOOP
              pc_insere_linha(pr_tab_env_extrato(vr_ind).msgemail(vr_ind_msg));
            END LOOP;
            -- Fechar o arquivo
            BEGIN
              gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arq);
            EXCEPTION
              WHEN OTHERS THEN
                vr_des_erro := 'Problema ao fechar o arquivo '||vr_nmarquiv||' no diret�rio: '||vr_dsdireto||'. Erro --> '||sqlerrm;
                RAISE vr_exc_erro;
            END;
            -- Criar o arquivo PDF do arquivo gerado
            gene0002.pc_cria_PDF(pr_cdcooper => pr_cdcooper                   --> Cooperativa conectada
                                ,pr_nmorigem => vr_dsdireto||'/'||vr_nmarquiv --> Path arquivo origem
                                ,pr_ingerenc => 'NAO'                         --> N�o gerencial
                                ,pr_tirelato => '80col'                       --> Tipo (80col, etc..)
                                ,pr_dtrefere => pr_dtmvtolt                   --> Data de referencia
                                ,pr_nmsaida  => vr_arquipdf                   --> Path do arquivo gerado
                                ,pr_des_erro => vr_des_erro);
            -- Se por ventura retornar erro
            IF vr_des_erro IS NOT NULL THEN
              -- Gerar erro
              RAISE vr_exc_erro;
            END IF;
            -- Remove o arquivo de origem
            gene0001.pc_OScommand_Shell('rm '||vr_dsdireto||'/'||vr_nmarquiv);
            -- Busca senha que sera solicitada no arquivo por email
            vr_cddsenha := null;
            OPEN cr_crapsnh(pr_nrdconta => pr_tab_env_extrato(vr_ind).nrdconta);
            FETCH cr_crapsnh
             INTO vr_cddsenha;
            CLOSE cr_crapsnh;
            -- Zipa e protege arquivo com senha
            gene0002.pc_zipcecred(pr_cdcooper => pr_cdcooper                                         --> Cooperativa conectada
                                 ,pr_tpfuncao => 'A'
                                 ,pr_dsorigem => vr_arquipdf                                         --> Lista de arquivos a compactar (separados por espa�o)
                                 ,pr_dsdestin => SUBSTR(vr_arquipdf,1,LENGTH(vr_arquipdf)-4)||'.zip' --> Caminho para o arquivo Zip a gerar
                                 ,pr_dspasswd => vr_cddsenha                                         --> Password a incluir no arquivo
                                 ,pr_des_erro => vr_des_erro);
            -- Testar erro
            IF pr_des_erro IS NOT NULL THEN
              -- O comando shell executou com erro, gerar log e sair do processo
              RAISE vr_exc_erro;
            END IF;

            -- Remove arquivo PDF
            gene0001.pc_OScommand_Shell('rm '||vr_arquipdf);

            -- Montagem do corpo do e-mail
            vr_dscorpo := 'Prezado (a) Cooperado (a),<br><br>'
                       || 'Voc� esta recebendo o extrato da sua conta. Para visualiza-lo, clique no arquivo anexo<br>'
                       || 'e digite sua senha. A senha � a mesma utilizada no tele-atendimento. Se voce ainda nao possui<br>'
                       || 'esta senha, dirija-se ao seu Posto de Atendimento para cadastrar uma.<br><br>'
                       || 'Se voc� preferir cancelar o recebimento, basta acessar sua conta no site da cooperativa, opcao de '
                       || 'Informativos/Recebimento, ou entrar em contato com o Posto de Atendimento onde voce movimenta sua conta.<br><br>'
                       || 'OBS.: Esta mensagem foi enviada automaticamente, em caso de duvidas entre em contato com sua cooperativa!<br><br>'
                       || 'Atenciosamente,<br>'
                       || pr_nmrescop||'.';
            -- Enviar por e-mail o arquivo gerado
            gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                      ,pr_flg_remete_coop => 'S' --> Envio pelo e-mail da Cooperativa
                                      ,pr_cdprogra        => pr_cdprogra
                                      ,pr_des_destino     => vr_dsdemail
                                      ,pr_des_assunto     => 'Extrato de Conta Corrente '||pr_nmrescop
                                      ,pr_des_corpo       => vr_dscorpo
                                      ,pr_des_anexo       => SUBSTR(vr_arquipdf,1,LENGTH(vr_arquipdf)-4)||'.zip'
                                      ,pr_flg_log_batch   => 'N' --> N�o gerar log
                                      ,pr_des_erro        => vr_des_erro
                                      ,pr_flg_remove_anex => 'N'); --> N�o remover o arquivo da converte.
            -- Se houver erro
            IF vr_des_erro IS NOT NULL THEN
              -- Levantar exce��o
              RAISE vr_exc_erro;
            END IF;
            -- Limpa a lista de destinat�rios
            vr_dsdemail := '';
            -- Para todos os registros desta conta
            -- (primeiro registro da conta ate o atual que � o ultimo)
            FOR vr_ind_reg IN vr_ind_pri..vr_ind LOOP
              -- Gerar LOG de envio do e-mail
              gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                  ,pr_cdoperad => 1
                                  ,pr_dscritic => ''
                                  ,pr_dsorigem => 'AYLLOS'
                                  ,pr_dstransa => 'Envio de informativo: '||pr_tab_env_extrato(vr_ind_reg).informat
                                  ,pr_dttransa => pr_dtmvtolt
                                  ,pr_flgtrans => 1 --> TRUE
                                  ,pr_hrtransa => TO_NUMBER(TO_CHAR(sysdate,'SSSSS'))
                                  ,pr_idseqttl => pr_tab_env_extrato(vr_ind_reg).idseqttl
                                  ,pr_nmdatela => pr_cdprogra
                                  ,pr_nrdconta => pr_tab_env_extrato(vr_ind_reg).nrdconta
                                  ,pr_nrdrowid => vr_nrdrowid);
              -- Se h� registro na pltable
              IF vr_tab_cdperiod.EXISTS(pr_tab_env_extrato(vr_ind_reg).cdperiod) THEN
                -- Us�-lo
                vr_dstextab := vr_tab_cdperiod(pr_tab_env_extrato(vr_ind_reg).cdperiod);
              ELSE
                -- Usar null
                vr_dstextab := null;
              END IF;
              -- Inserir log de item do per�odo do extrato
              gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                       ,pr_nmdcampo => 'Periodo'
                                       ,pr_dsdadant => '0'
                                       ,pr_dsdadatu => pr_tab_env_extrato(vr_ind_reg).cdperiod||'-'||vr_dstextab);
              -- Se h� registro na pltable
              IF vr_tab_formaenv.EXISTS(pr_tab_env_extrato(vr_ind_reg).formaenv) THEN
                -- Us�-lo
                vr_dstextab := vr_tab_formaenv(pr_tab_env_extrato(vr_ind_reg).formaenv);
              ELSE
                -- Usar null
                vr_dstextab := null;
              END IF;
              -- Inserir log da Forma de envio
              gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                       ,pr_nmdcampo => 'Canal'
                                       ,pr_dsdadant => '0'
                                       ,pr_dsdadatu => pr_tab_env_extrato(vr_ind_reg).formaenv||'-'||gene0002.fn_busca_entrada(1,vr_dstextab,','));
              -- Enviar por fim o e-mail que recebeu o informativo
              gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                                       ,pr_nmdcampo => 'Endereco'
                                       ,pr_dsdadant => '0'
                                       ,pr_dsdadatu => pr_tab_env_extrato(vr_ind_reg).cdendere||'-'||pr_tab_env_extrato(vr_ind_reg).dsdemail);
            END LOOP; --> Fim busca todos vinculados a conta
          END IF; --> Fim teste ultimo registro da conta
        END LOOP; --> Fim leitura dos registros
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Efetuar rollback
        ROLLBACK;
        -- Concatenar o erro previamente montado e retornar
        pr_des_erro := 'EXTR0001.pc_envia_extrato_email --> ' || vr_des_erro;
      WHEN OTHERS THEN
        -- Efetuar rollback
        ROLLBACK;
        -- Retornar o erro contido na sqlerrm
        pr_des_erro := 'EXTR0001.pc_envia_extrato_email --> : '|| sqlerrm;
    END;
  END pc_envia_extrato_email;

  /* Procedure para obter saldos anteriores da conta-corrente */
  PROCEDURE pc_obtem_saldos_anteriores (pr_cdcooper    IN INTEGER      -- Codigo da Cooperativa
                                       ,pr_cdagenci    IN INTEGER      -- Codigo da agencia
                                       ,pr_nrdcaixa    IN INTEGER      -- Numero da caixa
                                       ,pr_cdopecxa    IN VARCHAR2     -- Codigo do operador do caixa
                                       ,pr_nmdatela    IN VARCHAR2     -- Nome da tela
                                       ,pr_idorigem    IN INTEGER      -- Indicador de origem
                                       ,pr_nrdconta    IN INTEGER      -- Numero da conta do cooperado
                                       ,pr_idseqttl    IN INTEGER      -- Indicador de sequencial
                                       ,pr_dtmvtolt    IN DATE         -- Data de movimento
                                       ,pr_dtmvtoan    IN DATE         -- Data de movimento anterior
                                       ,pr_dtrefere    IN DATE         -- Data de referencia
                                       ,pr_flgerlog    IN BOOLEAN      -- Flag se deve gerar log
                                       ,pr_dscritic   OUT VARCHAR2                   -- Retorno de critica
                                       ,pr_tab_saldos OUT typ_tab_saldos             -- Retorna os saldos
                                       ,pr_tab_erro   OUT gene0001.typ_tab_erro) IS  -- retorna os erros

    /*---------------------------------------------------------------------------------------------
    --    Programa: pc_obtem_saldos_anteriores�    antiga: b1wgen0001.p/obtem-saldos-anteriores
    --    Sistema : Conta-Corrente - Cooperativa de Credito
    --    Sigla   : CRED
    --    Autor   : Odirlei Busana (AMcom)
    --    Data    : Novembro/2013                         Ultima atualizacao: 25/11/2013
    --
    --    Dados referetes ao programa:
    --    Frequencia: Sempre que chamado pelos programas de extrato da conta
    --
    --    Objetivo  : Obter saldos anteriores da conta-corrente
    --
    --    Alteracoes: 25/11/2013 - Convers�o de Progress >> Oracle PLSQL
    --
    --
    ---------------------------------------------------------------------------------------------*/

    -- Descri��o da origem da chamada
    vr_dsorigem VARCHAR2(10);
    -- Descri��o da transa��o
    vr_dstransa VARCHAR2(100);
    -- critica
    vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(4000);
    -- rowid tabela de log
    vr_nrdrowid ROWID;
    -- Retorno dos valores de bloqueio judiciais
    vr_vlblqjud NUMBER;
    vr_vlresblq NUMBER;
    -- data de referencia
    vr_dtrefere DATE;
    --indice da temptable
    vr_ind      number;

    -- Buscar saldo diarios do associado
    CURSOR cr_crapsda (pr_cdcooper IN NUMBER,
                       pr_nrdconta IN NUMBER,
                       pr_dtrefere IN DATE )is
      SELECT vlsddisp,
             vlsdchsl,
             vlsdbloq,
             vlsdblpr,
             vlsdblfp,
             vlsdindi,
             vllimcre,
             COUNT(1) OVER (PARTITION BY cdcooper,nrdconta,dtmvtolt
                                ORDER BY cdcooper,nrdconta,dtmvtolt) QTD_REG
        FROM crapsda
       WHERE crapsda.cdcooper = pr_cdcooper
         AND crapsda.nrdconta = pr_nrdconta
         AND crapsda.dtmvtolt = pr_dtrefere;

    rw_crapsda cr_crapsda%ROWTYPE;

  BEGIN
    -- Verificar se deve gerar log
    IF pr_flgerlog THEN /*TRUE*/
      -- Buscar descri��o de origem
      vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
      vr_dstransa := 'Consultar saldo anterior do cooperado.';
    END IF;

    -- definir dt de referencia caso esteja em branco
    IF pr_dtrefere is null  THEN
      vr_dtrefere := pr_dtmvtoan;
    --Verificar se a data de refe � maior que a data do movimento ou se � sabado ou domingo ou feriado
    ELSIF pr_dtrefere >= pr_dtmvtolt  OR
          to_char(pr_dtrefere,'D') = 1     OR
          to_char(pr_dtrefere,'D') = 7     OR
          FLXF0001.fn_verifica_feriado(pr_cdcooper,pr_dtrefere)  THEN

      -- Gerar critica
      vr_cdcritic := 13;
      vr_dscritic := NULL ;
      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                            pr_cdagenci => pr_cdagenci,
                            pr_nrdcaixa => pr_nrdcaixa,
                            pr_nrsequen => 1,
                            pr_cdcritic => vr_cdcritic,
                            pr_dscritic => vr_dscritic,
                            pr_tab_erro => pr_tab_erro);

      IF pr_flgerlog  THEN
        -- Gerar log
        GENE0001.pc_gera_log( pr_cdcooper => pr_cdcooper
                             ,pr_cdoperad => pr_cdopecxa
                             ,pr_dscritic => vr_cdcritic
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

      pr_dscritic := 'NOK';
      RETURN;

    ELSE
      vr_dtrefere := pr_dtrefere;

    END IF;

    -- Ler saldos diarios dos associados.
    OPEN cr_crapsda (pr_cdcooper => pr_cdcooper,
                     pr_nrdconta => pr_nrdconta,
                     pr_dtrefere => vr_dtrefere);
    FETCH cr_crapsda
      INTO rw_crapsda;

    --Se n�o encontrar ou encontrar mais de um, gerar critica
    IF cr_crapsda%NOTFOUND OR
       NVL(rw_crapsda.QTD_REG,0) > 1 THEN

       -- Se n�o encontrar ou existir mais de um registro, gerar critica
      vr_cdcritic := 853; -- 853 - Nao ha saldo para esta data.
      vr_dscritic := NULL ;
      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                            pr_cdagenci => pr_cdagenci,
                            pr_nrdcaixa => pr_nrdcaixa,
                            pr_nrsequen => 1,
                            pr_cdcritic => vr_cdcritic,
                            pr_dscritic => vr_dscritic,
                            pr_tab_erro => pr_tab_erro);

      IF pr_flgerlog  THEN
        -- Gerar Log
        GENE0001.pc_gera_log( pr_cdcooper => pr_cdcooper
                             ,pr_cdoperad => pr_cdopecxa
                             ,pr_dscritic => vr_cdcritic
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

      pr_dscritic := 'NOK';
      CLOSE cr_crapsda;
      RETURN;

    ELSE
      -- se encontrou somente um, somente fechar o cursor
      CLOSE cr_crapsda;
    END IF;

    vr_vlblqjud := 0;
    vr_vlresblq := 0;

    /*** Busca Saldo Bloqueado Judicial ***/
    gene0005.pc_retorna_valor_blqjud(  pr_cdcooper => pr_cdcooper
                                     , pr_nrdconta => pr_nrdconta
                                     , pr_nrcpfcgc => 0
                                     , pr_cdtipmov => 1  /* 1 - Bloqueio  */
                                     , pr_cdmodali => 1  /* 1 - Dep.Vista */
                                     , pr_dtmvtolt => pr_dtmvtolt
                                     , pr_vlbloque => vr_vlblqjud
                                     , pr_vlresblq => vr_vlresblq
                                     , pr_dscritic => pr_dscritic);

    /**************************************************************/
    /** Retorna limite de credito armazenado na crapass, pois se **/
    /** o limite for alterado durante o dia de movimento o mesmo **/
    /** nao � atualizado na crapsda. Somente no processo batch.  **/
    /**************************************************************/
    vr_ind := pr_tab_saldos.COUNT;
    pr_tab_saldos(vr_ind).vlsddisp := rw_crapsda.vlsddisp;
    pr_tab_saldos(vr_ind).vlsdchsl := rw_crapsda.vlsdchsl;
    pr_tab_saldos(vr_ind).vlsdbloq := rw_crapsda.vlsdbloq;
    pr_tab_saldos(vr_ind).vlsdblpr := rw_crapsda.vlsdblpr;
    pr_tab_saldos(vr_ind).vlsdblfp := rw_crapsda.vlsdblfp;
    pr_tab_saldos(vr_ind).vlsdindi := rw_crapsda.vlsdindi;
    pr_tab_saldos(vr_ind).vllimcre := rw_crapsda.vllimcre;
    pr_tab_saldos(vr_ind).vlstotal := rw_crapsda.vlsddisp + rw_crapsda.vlsdbloq +
                                      rw_crapsda.vlsdblpr + rw_crapsda.vlsdblfp +
                                      rw_crapsda.vlsdchsl + rw_crapsda.vlsdindi;
    pr_tab_saldos(vr_ind).vlblqjud := vr_vlblqjud;

    IF pr_flgerlog  THEN
      -- Gerar log
      GENE0001.pc_gera_log( pr_cdcooper => pr_cdcooper
                           ,pr_cdoperad => pr_cdopecxa
                           ,pr_dscritic => NULL
                           ,pr_dsorigem => vr_dsorigem
                           ,pr_dstransa => vr_dstransa
                           ,pr_dttransa => TRUNC(SYSDATE)
                           ,pr_flgtrans => 1 --> TRUE
                           ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                           ,pr_idseqttl => pr_idseqttl
                           ,pr_nmdatela => pr_nmdatela
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrdrowid => vr_nrdrowid);
    END IF;

    -- Retornar OK
    pr_dscritic := 'OK';

  EXCEPTION
    WHEN OTHERS THEN
      -- Tratar erro gererico
      vr_dscritic := 'Erro ao obter saldo anterior(pc_obtem_saldos_anteriores): '|| SQLErrm ;
      GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                            pr_cdagenci => pr_cdagenci,
                            pr_nrdcaixa => pr_nrdcaixa,
                            pr_nrsequen => 1,
                            pr_cdcritic => vr_cdcritic,
                            pr_dscritic => vr_dscritic,
                            pr_tab_erro => pr_tab_erro);

      pr_dscritic := 'NOK';

  END pc_obtem_saldos_anteriores;

  PROCEDURE pc_ver_capital(pr_cdcooper IN crapcop.cdcooper%TYPE -- C�digo da cooperativa
                          ,pr_cdagenci IN crapage.cdagenci%TYPE -- C�digo da ag�ncia
                          ,pr_nrdcaixa IN INTEGER               -- N�mero do caixa
                          ,pr_inproces IN crapdat.inproces%TYPE -- Indicador do processo
                          ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE -- Data de movimento
                          ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE -- Data do programa
                          ,pr_cdprogra IN VARCHAR2              -- C�digo do programa
                          ,pr_idorigem IN INTEGER               -- Origem do programa
                          ,pr_nrdconta IN crapass.nrdconta%TYPE -- N�mero da conta
                          ,pr_vllanmto IN NUMBER                -- Valor de lancamento
                          ,pr_des_reto OUT VARCHAR2             -- Retorno OK/NOK
                          ,pr_tab_erro OUT GENE0001.typ_tab_erro) IS -- Tabela de erros

  BEGIN
    /*****************************************************************************
     Sistema : pc_ver_capital
     Sigla   : CRED
     Autor   : Adriano
     Data    : Maio/2014.                        Ultima atualizacao: 13/08/2014

     Objetivo  : Verificar se o associado possui capital
                (conversao em BO do fontes/ver_capital.p)

                 p-nro-conta    = Conta do associado em questao
                 p-valor-lancto = Se maior que 0, verifica de pode sacar o valor
                                se for 0, apenas testa se o associado possui
                                capital suficiente para efetuar a operacao.

     Alteracoes: 13/08/2014 - Ajuste para uitilizar dtadmis ao inv�s de dtdemiss
                             (Adriano).

    *****************************************************************************/
    DECLARE

      -- Cursor para encontrar a cooperativa
      CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT cop.cdcooper
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Cursor para encontrar a matricula do cooperado
      CURSOR cr_crapmat(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT mat.vlcapini
        FROM crapmat mat
       WHERE mat.cdcooper = pr_cdcooper;
      rw_crapmat cr_crapmat%ROWTYPE;

      -- Cursor para encontrar a conta/corrente
      CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT ass.inpessoa
            ,ass.dtdemiss
            ,ass.nrdconta
            ,ass.vllimcre
            ,ass.dtadmiss
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

      -- Cursor para buscar a cota
      CURSOR cr_crapcot(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT cot.vldcotas
        FROM crapcot cot
       WHERE cot.cdcooper = pr_cdcooper
         AND cot.nrdconta = pr_nrdconta;
      rw_crapcot cr_crapcot%ROWTYPE;

      -- Cursor para encontar os os admitidos do mes.
      CURSOR cr_crapadm(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT adm.cdcooper
        FROM crapadm adm
       WHERE adm.cdcooper = pr_cdcooper
         AND adm.nrdconta = pr_nrdconta;
      rw_crapadm cr_crapadm%ROWTYPE;

      --Registro do tipo calendario
      rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

      -- Descri��o e c�digo da critica
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);

      -- Valor minimo do capital
      vr_vlcapmin NUMBER;

      -- Armazena data
      vr_data DATE;

      -- Guardar registro dstextab
      vr_dstextab craptab.dstextab%TYPE;      

    BEGIN

      -- Inicializar variaveis erro
      vr_cdcritic:= NULL;
      vr_dscritic:= NULL;

      -- Limpar tabelas
      pr_tab_erro.DELETE;

      -- Verifica se a cooperativa esta cadastrada
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);

      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;

      -- Se n�o encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN

        -- Fechar o cursor pois haver� raise
        CLOSE BTCH0001.cr_crapdat;

        -- Montar mensagem de critica
        vr_cdcritic := 1;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

        -- Gera exce��o
        RAISE vr_exc_erro;

      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;

      -- Encontra a cooperativa
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);

      FETCH cr_crapcop INTO rw_crapcop;

      -- Se n�o encontrar
      IF cr_crapcop%NOTFOUND THEN

        -- Fechar o cursor
        CLOSE cr_crapcop;

        -- Montar mensagem de critica
        vr_cdcritic := 651;

        RAISE vr_exc_erro;

      ELSE

        -- Apenas fechar o cursor
        CLOSE cr_crapcop;

      END IF;

      -- Emcontra a matricula
      OPEN cr_crapmat(pr_cdcooper => pr_cdcooper);

      FETCH cr_crapmat INTO rw_crapmat;

      -- Se n�o encontrar
      IF cr_crapmat%NOTFOUND THEN

        -- Fechar o cursor pois haver� raise
        CLOSE cr_crapmat;

        -- Montar mensagem de critica
        vr_cdcritic := 642;

        -- Gera exce��o
        RAISE vr_exc_erro;

      ELSE

        -- Apenas fechar o cursor
        CLOSE cr_crapmat;

      END IF;

      -- Buscar configura��o na tabela, valor minimo do capital
      vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'VLRUNIDCAP'
                                               ,pr_tpregist => 1);         

      -- Se n�o encontrar
      IF TRIM(vr_dstextab) IS NULL THEN 
        vr_vlcapmin := rw_crapmat.vlcapini;
      ELSE
        vr_vlcapmin := gene0002.fn_char_para_number(vr_dstextab);
      END IF;

      -- Encontra a conta corrente
      OPEN cr_crapass(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);

      FETCH cr_crapass INTO rw_crapass;

      -- Se n�o encontrar
      IF cr_crapass%NOTFOUND THEN

        -- Fecha o cursor
        CLOSE cr_crapass;

        -- Monta critica
        vr_cdcritic := 9;

        -- Gera exce��o
        RAISE vr_exc_erro;

      ELSE

        -- Fecha o cursor
        CLOSE cr_crapass;

      END IF;

      -- Fisica e juridica
      IF rw_crapass.inpessoa <> 3 THEN

        -- Le o registro de capital
        OPEN cr_crapcot(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta);

        FETCH cr_crapcot INTO rw_crapcot;

        -- Se n�o encontrar
        IF cr_crapcot%NOTFOUND THEN

          -- Fecha o cursor
          CLOSE cr_crapcot;

          -- Monta critica
          vr_cdcritic := 169;

          -- Gera exce��o
          RAISE vr_exc_erro;

        ELSE

          -- Fecha o cursor
          CLOSE cr_crapcot;

        END IF;

        IF pr_vllanmto = 0 THEN

          -- Verifica se ha capital suficiente
          IF rw_crapcot.vldcotas < vr_vlcapmin THEN

            -- Encontra registro de admitidos do mes.
            OPEN cr_crapadm(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => pr_nrdconta);

            FETCH cr_crapadm INTO rw_crapadm;

            -- Se n�o encontrar
            IF cr_crapadm%NOTFOUND THEN

              -- Fecha o cursor
              CLOSE cr_crapadm;

              IF rw_crapass.dtdemiss IS NULL THEN

                vr_data := rw_crapdat.dtmvtolt - TO_CHAR(rw_crapdat.dtmvtolt);
                vr_data := vr_data - TO_CHAR(vr_data);

                IF rw_crapass.dtadmiss <= vr_data THEN

                  -- Monta critica
                  vr_cdcritic := 735;

                  -- Gera exe��o
                  RAISE vr_exc_erro;

                END IF;

              END IF;

           ELSE
              -- Fecha o cursor
              CLOSE cr_crapadm;

            END IF;

          END IF;

        ELSE

          IF rw_crapcot.vldcotas <> pr_vllanmto OR
             rw_crapass.dtdemiss IS NULL        THEN

            IF (rw_crapcot.vldcotas - pr_vllanmto) < vr_vlcapmin THEN

              -- Monta critica
              vr_cdcritic := 630;

              -- Gera exce��o
              RAISE vr_exc_erro;
            ELSE

              -- Retorno OK
              pr_des_reto := 'OK';

              RETURN;

            END IF;

          END IF;

          pc_ver_saldos(pr_cdcooper => pr_cdcooper -- C�digo da cooperativa
                       ,pr_cdagenci => pr_cdagenci -- C�digo da ag�ncia
                       ,pr_nrdcaixa => pr_nrdcaixa -- N�mero do caixa
                       ,pr_inproces => pr_inproces -- Indicador do processo
                       ,pr_dtmvtolt => pr_dtmvtolt -- Data de movimento
                       ,pr_dtmvtopr => pr_dtmvtopr -- Data do programa
                       ,pr_cdprogra => pr_cdprogra -- C�digo do programa
                       ,pr_nrdconta => rw_crapass.nrdconta -- Conta corrente
                       ,pr_vllimcre => rw_crapass.vllimcre -- Valor limite de cr�dito
                       ,pr_des_reto => pr_des_reto         -- Retorno OK/NOK
                       ,pr_tab_erro => pr_tab_erro);

          -- Se ocorreu erro
          IF pr_des_reto <> 'OK' THEN

            IF pr_tab_erro.COUNT > 0 THEN
              vr_cdcritic:= pr_tab_erro(pr_tab_erro.FIRST).cdcritic;
              vr_dscritic:= pr_tab_erro(pr_tab_erro.FIRST).dscritic|| ' Conta: '|| pr_nrdconta;
            ELSE
              vr_cdcritic:= 0;
              vr_dscritic:= 'Retorno "NOK" na EXTR0001.pc_ver_saldos e sem informa��o na pr_tab_erro, Conta: '|| pr_nrdconta;

            END IF;

            -- Gera exce��o
            RAISE vr_exc_erro;

          END IF;

        END IF;

      END IF;

      -- Retorno OK
      pr_des_reto := 'OK';

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';

        -- Gera erro
        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => 1,
                              pr_cdcritic => vr_cdcritic,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);

      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';

        -- Chamar rotina de grava��o de erro
        vr_dscritic := 'Erro na EXTR0001.pc_ver_capital --> '|| SQLERRM;

        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0 --> Critica 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

    END;

  END pc_ver_capital;

  PROCEDURE pc_ver_saldos(pr_cdcooper IN crapcop.cdcooper%TYPE -- C�digo da cooperativa
                         ,pr_cdagenci IN crapage.cdagenci%TYPE -- C�digo da ag�ncia
                         ,pr_nrdcaixa IN INTEGER               -- N�mero do caixa
                         ,pr_inproces IN crapdat.inproces%TYPE -- Indicador do processo
                         ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE -- Data de movimento
                         ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE -- Data do programa
                         ,pr_cdprogra IN VARCHAR2              -- C�digo do programa
                         ,pr_nrdconta IN crapass.nrdconta%TYPE -- Conta corrente
                         ,pr_vllimcre IN crapass.vllimcre%type -- Valor limite de cr�dito
                         ,pr_des_reto OUT VARCHAR2             -- Retorno OK/NOK
                         ,pr_tab_erro OUT GENE0001.typ_tab_erro) IS --Tabela de erros

  BEGIN
     /*
        Programa: pc_ver_saldos (antigo BO b1wgen0001.ver_saldos)
        Sistema : Conta-Corrente - Cooperativa de Credito
        Sigla   : CRED
        Autor   : Adriano
        Data    : Maio/2014                         Ultima atualizacao: 27/08/2014

        Dados referetes ao programa:

        Objetivo  : Busca saldos do associado

        Alteracoes: 13/08/2014 - Ajuste para encerrar corretamente o cursor cr_craptit
                                (Adriano).

                    27/08/2014 - Incluida chamada da procedure pc_busca_saldo_aplicacoes
                                 (Jean Michel).

    */
    DECLARE
            -- Cursor para encontrar registro de empr�stimo
      CURSOR cr_crapepr(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT epr.cdcooper
        FROM crapepr epr
       WHERE epr.cdcooper = pr_cdcooper
         AND epr.nrdconta = pr_nrdconta
         AND epr.inliquid = 0; -- Ainda n�o foi liquidado
      rw_crapepr cr_crapepr%ROWTYPE;

      -- Cursor para encontrar o Plano de capitalizacao.
      CURSOR cr_crappla(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT pla.cdcooper
        FROM crappla pla
       WHERE pla.cdcooper = pr_cdcooper
         AND pla.nrdconta = pr_nrdconta
         AND pla.cdsitpla = 1; -- Ativo
      rw_crappla cr_crappla%ROWTYPE;

      -- Cursor para encontrar um cart�o ativo
      CURSOR cr_crapcrd(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT crd.cdcooper
        FROM crapcrd crd
       WHERE crd.cdcooper = pr_cdcooper
         AND crd.nrdconta = pr_nrdconta
         AND crd.dtcancel IS NULL;
      rw_crapcrd cr_crapcrd%ROWTYPE;

      -- Cursor para encontrar as aplica��es
      CURSOR cr_craprda(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT rda.cdcooper
            ,rda.tpaplica
            ,rda.nrdconta
            ,rda.nraplica
        FROM craprda rda
       WHERE rda.cdcooper = pr_cdcooper
         AND rda.nrdconta = pr_nrdconta
         AND rda.insaqtot = 0 -- Ainda n�o teve o saque total
         AND (rda.tpaplica = 3 OR rda.tpaplica = 5 ); -- 3 RDCA / 5 RDCAII
      rw_craprda cr_craprda%ROWTYPE;

      -- Cursor para buscar o saldo rdc
      CURSOR cr_saldo_rdc(pr_cdcooper IN crapcop.cdcooper%TYPE
                         ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT dtc.tpaplrdc
            ,rda.vlsdrdca
            ,rda.nrdconta
            ,rda.nraplica
        FROM crapdtc dtc
            ,craprda rda
       WHERE dtc.cdcooper = pr_cdcooper
         AND (dtc.tpaplrdc = 1 OR dtc.tpaplrdc = 2) -- 1 RDCPRE / 2 RDPOS
         AND rda.cdcooper = pr_cdcooper
         AND rda.nrdconta = pr_nrdconta
         AND rda.insaqtot = 0 -- Ainda teve o saque total
         AND rda.tpaplica = dtc.tpaplica;
      rw_saldo_rdc cr_saldo_rdc%ROWTYPE;

      -- Cursor para encontrar os seguros
      CURSOR cr_crapseg(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE
                       ,pr_dtfimvig IN crapseg.dtfimvig%TYPE) IS
      SELECT seg.cdcooper
        FROM crapseg seg
       WHERE seg.cdcooper = pr_cdcooper
         AND seg.nrdconta = pr_nrdconta
         AND seg.dtfimvig > pr_dtfimvig
         AND seg.dtcancel IS NULL;
      rw_crapseg cr_crapseg%ROWTYPE;

      -- Cursor para encontrar Cadastro das autorizacoes de debito em conta
      CURSOR cr_crapatr(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT atr.cdcooper
        FROM crapatr atr
       WHERE atr.cdcooper = pr_cdcooper
         AND atr.nrdconta = pr_nrdconta
         AND atr.dtfimatr IS NULL;
      rw_crapatr cr_crapatr%ROWTYPE;

      -- Cursor para encontrar o Cadastro de poupanca programada.
      CURSOR cr_craprpp(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT rpp.cdcooper
            ,rpp.vlsdrdpp
            ,rpp.nrdconta
            ,rpp.nrctrrpp
        FROM craprpp rpp
       WHERE rpp.cdcooper = pr_cdcooper
         AND rpp.nrdconta = pr_nrdconta
         AND (rpp.vlsdrdpp > 0 OR rpp.dtcancel IS NULL);
      rw_craprpp cr_craprpp%ROWTYPE;

      -- Cursor para encontrar Cadastro de lancamentos de aplicacoes de poupanca
      CURSOR cr_craplpp(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE
                       ,pr_nrctrrpp IN craplpp.nrctrrpp%TYPE) IS
      SELECT lpp.vllanmto
        FROM craplpp lpp
       WHERE lpp.cdcooper = pr_cdcooper
         AND lpp.nrdconta = pr_nrdconta
         AND lpp.nrctrrpp = pr_nrctrrpp
         AND (lpp.cdhistor = 496 OR lpp.cdhistor = 158);
      rw_craplpp cr_craplpp%ROWTYPE;

      -- Cursor para encontrar a folha de cheques
      CURSOR cr_crapfdc(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT fdc.incheque
            ,fdc.tpcheque
        FROM crapfdc fdc
       WHERE fdc.cdcooper = pr_cdcooper
         AND fdc.nrdconta = pr_nrdconta
         AND NOT fdc.dtretchq IS NULL; -- Cheque j� retirado
      rw_crapfdc cr_crapfdc%ROWTYPE;

      -- Cursor para encontrar custodias de cheques
      CURSOR cr_crapcst(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE
                       ,pr_dtlibera IN crapcst.dtlibera%TYPE) IS
      SELECT cst.cdcooper
        FROM crapcst cst
       WHERE cst.cdcooper = pr_cdcooper
         AND cst.nrdconta = pr_nrdconta
         AND cst.dtlibera > pr_dtlibera
         AND cst.dtdevolu IS NULL;
      rw_crapcst cr_crapcst%ROWTYPE;

      -- Cursor para encontrar Cheques contidos do Bordero de desconto de cheques
      CURSOR cr_crapcdb(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE
                       ,pr_dtlibera IN crapcdb.dtmvtolt%TYPE) IS
      SELECT cdb.cdcooper
        FROM crapcdb cdb
       WHERE cdb.cdcooper = pr_cdcooper
         AND cdb.nrdconta = pr_nrdconta
         AND cdb.dtlibera > pr_dtlibera
         AND cdb.dtdevolu IS NULL;
      rw_crapcdb cr_crapcdb%ROWTYPE;

      -- Cursor para encontrar Titulos contidos do Bordero de desconto de titulos
      CURSOR cr_craptdb(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT tdb.cdcooper
        FROM craptdb tdb
       WHERE tdb.cdcooper = pr_cdcooper
         AND tdb.nrdconta = pr_nrdconta
         AND tdb.insittit = 4; --Liberado
      rw_craptdb cr_craptdb%ROWTYPE;

      -- Cursor para encotrar os titulos
      CURSOR cr_craptit(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE
                       ,pr_dtdpagto IN craptit.dtmvtolt%TYPE) IS
      SELECT tit.cdcooper
        FROM craptit tit
       WHERE tit.cdcooper = pr_cdcooper
         AND tit.nrdconta = pr_nrdconta
         AND tit.dtdpagto > pr_dtdpagto
         AND tit.dtdevolu IS NULL;
      rw_craptit cr_craptit%ROWTYPE;

      -- Descri��o e c�digo da critica
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);

      -- Valor do saldo
      vr_vldsaldo NUMBER;

      -- Data
      vr_datdodia DATE;

      --Variaveis usadas no retorno da procedure pc_saldo_rgt_rdc_pos
      vr_sldpresg NUMBER(18,8); --> Saldo para resgate
      vr_vlrenrgt NUMBER(18,8);          --> Rendimento resgatado periodo
      vr_vlrdirrf craplap.vllanmto%TYPE; --> Valor do irrf sobre o rendimento
      vr_perirrgt NUMBER(18,2);          --> % de IR Resgatado
      vr_vlrrgtot craplap.vllanmto%TYPE; --> Resgate para zerar a aplica��o
      vr_vlirftot craplap.vllanmto%TYPE; --> IRRF para finalizar a aplicacao
      vr_vlrendmm craplap.vlrendmm%TYPE; --> Rendimento da ultima provisao at� a data do resgate
      vr_vlrvtfim craplap.vllanmto%TYPE; --> Quantia provisao reverter para zerar a aplica��o
      vr_vlsldapl     NUMBER(18,8); --> Saldo da aplica��o RDCA

      -- Vari�veis auxiliares para os rendimentos
      vr_apl_vlsldapl NUMBER(18,8); --> Saldo da aplica��o
      vr_apl_vlsaques NUMBER(18,8); --> Acumulador de saques
      vr_vlsdrdca     NUMBER(18,8); --> Saldo da aplica��o
      vr_vldperda     NUMBER(18,8); --> Valor calculado da perda
      vr_apl_txaplica NUMBER(18,8); --> Taxa da aplica��o
      vr_sldresga NUMBER;
      vr_dtinitax DATE;
      vr_dtfimtax DATE;
      vr_dstextab VARCHAR2(1000);

      -- Variaveis para retorno da APLI0005.pc_busca_saldo_aplicacoes
      vr_vlsldtot NUMBER(20,8);
      vr_vlsldrgt NUMBER(20,8);
    BEGIN

      -- Inicializar variaveis erro
      vr_cdcritic:= NULL;
      vr_dscritic:= NULL;

      -- Limpar tabelas
      pr_tab_erro.DELETE;

      -- Verifica se existe emprestimo com saldo devedor
      OPEN cr_crapepr(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);

      FETCH cr_crapepr INTO rw_crapepr;

      -- Se encontrar
      IF cr_crapepr%FOUND THEN

        -- Fecha o cursor
        CLOSE cr_crapepr;

        -- Monta a critica
        vr_cdcritic := NULL;
        vr_dscritic := 'EMPRESTIMO COM SALDO DEVEDOR.';

        -- Gera exce��o
        RAISE vr_exc_erro;

      ELSE
        -- Fecha o cursor
        CLOSE cr_crapepr;

      END IF;

      -- Verfica se existe um plano de capital ativo
      OPEN cr_crappla(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);

      FETCH cr_crappla INTO rw_crappla;

      -- Se encontrar
      IF cr_crappla%FOUND THEN

        -- Fecha o cursor
        CLOSE cr_crappla;

        -- Monta a critica
        vr_cdcritic := NULL;
        vr_dscritic := 'PLANO DE CAPITAL ATIVO.';

        -- Gera exce��o
        RAISE vr_exc_erro;

      ELSE
        -- Fecha o cursor
        CLOSE cr_crappla;

      END IF;

      IF pr_vllimcre > 0 THEN

        -- Monta critica
        vr_cdcritic := NULL;
        vr_dscritic := 'LIMITE DE CREDITO EM CONTA-CORRENTE.';

        -- Gera exce��o
        RAISE vr_exc_erro;

      END IF;

      -- Encontra cart�o de cr�dito ativo
      OPEN cr_crapcrd(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);

      FETCH cr_crapcrd INTO rw_crapcrd;

      -- Se encontrar
      IF cr_crapcrd%FOUND THEN

        -- Fecha o cursor
        CLOSE cr_crapcrd;

        -- Monta a critica
        vr_cdcritic := NULL;
        vr_dscritic := 'CARTAO DE CREDITO ATIVO.';

        -- Gera exce��o
        RAISE vr_exc_erro;

      ELSE
        -- Fecha o cursor
        CLOSE cr_crapcrd;

      END IF;

      /*Busca saldo Aplicacoe */
      APLI0005.pc_busca_saldo_aplicacoes(pr_cdcooper => pr_cdcooper
                                        ,pr_cdoperad => 1
                                        ,pr_nmdatela => pr_cdprogra
                                        ,pr_idorigem => 1
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_idseqttl => 1
                                        ,pr_nraplica => 0
                                        ,pr_dtmvtolt => pr_dtmvtolt
                                        ,pr_cdprodut => 0
                                        ,pr_idblqrgt => 1
                                        ,pr_idgerlog => 1
                                        ,pr_vlsldtot => vr_vlsldtot
                                        ,pr_vlsldrgt => vr_vlsldrgt
                                        ,pr_cdcritic => vr_cdcritic
                                        ,pr_dscritic => vr_dscritic);

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;

      -- Calcular o Saldo da aplicacao ate a data do movimento
      -- de acordo com o tipo de aplica��o do registro
      FOR rw_craprda IN cr_craprda(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta) LOOP

        IF rw_craprda.tpaplica = 3 THEN

          -- Reiniciar contador de saques
          vr_apl_vlsaques := 0;
          vr_apl_vlsldapl := 0;
          vr_vlsdrdca     := 0;

          -- Consultar o saldo da aplica��o
          apli0001.pc_consul_saldo_aplic_rdca30(pr_cdcooper => pr_cdcooper --> Cooperativa
                                               ,pr_dtmvtolt => pr_dtmvtolt --> Data do processo
                                               ,pr_inproces => pr_inproces --> Indicador do processo
                                               ,pr_dtmvtopr => pr_dtmvtopr --> Pr�ximo dia util
                                               ,pr_cdprogra => pr_cdprogra --> Programa em execu��o
                                               ,pr_cdagenci => 1           --> C�digo da ag�ncia
                                               ,pr_nrdcaixa => 999         --> N�mero do caixa
                                               ,pr_nrdconta => rw_craprda.nrdconta --> Nro da conta da aplica��o RDCA
                                               ,pr_nraplica => rw_craprda.nraplica --> Nro da aplica��o RDCA
                                               ,pr_vlsdrdca => vr_vlsdrdca         --> Saldo da aplica��o
                                               ,pr_vlsldapl => vr_vlsldapl         --> Saldo da aplica��o RDCA
                                               ,pr_sldpresg => vr_sldpresg     --> Valor saldo de resgate
                                               ,pr_dup_vlsdrdca => vr_vlsdrdca --> Acumulo do saldo da aplicacao RDCA
                                               ,pr_vldperda => vr_vldperda         --> Valor calculado da perda
                                               ,pr_txaplica => vr_apl_txaplica     --> TAxa utilizada
                                               ,pr_des_reto => pr_des_reto         --> OK ou NOK
                                               ,pr_tab_erro => pr_tab_erro);       --> Tabela com erros
          -- Se retornar erro
          IF pr_des_reto = 'NOK' THEN
            -- Tenta buscar o erro no vetor de erro
            IF pr_tab_erro.COUNT > 0 THEN
              vr_cdcritic := pr_tab_erro(pr_tab_erro.FIRST).cdcritic;
              vr_dscritic := pr_tab_erro(pr_tab_erro.FIRST).dscritic|| ' Conta: '||rw_craprda.nrdconta||' Aplica: '||rw_craprda.nraplica;
            ELSE
              vr_dscritic := 'Retorno "NOK" na APLI0001.pc_consul_saldo_aplic_rdca30 e sem informa��o na pr_vet_erro, Conta: '||rw_craprda.nrdconta||' Aplica: '||rw_craprda.nraplica;
            END IF;
            -- Levantar exce��o
            RAISE vr_exc_erro;
          END IF;

        ELSIF rw_craprda.tpaplica = 5 THEN

          APLI0001.pc_consul_saldo_aplic_rdca60(pr_cdcooper => pr_cdcooper         --> Cooperativa
                                               ,pr_dtmvtolt => pr_dtmvtolt --> Data do processo
                                               ,pr_dtmvtopr => pr_dtmvtopr --> Proximo dia util
                                               ,pr_cdprogra => pr_cdprogra         --> Programa em execucao
                                               ,pr_cdagenci => 1                   --> Codigo da agencia
                                               ,pr_nrdcaixa => 999                 --> Numero do caixa
                                               ,pr_nrdconta => rw_craprda.nrdconta --> Nro da conta da aplicac?o RDCA
                                               ,pr_nraplica => rw_craprda.nraplica --> Nro da aplicac?o RDCA
                                               ,pr_vlsdrdca => vr_vlsdrdca         --> Saldo da aplicac?o
                                               ,pr_sldpresg => vr_sldpresg         --> Saldo para resgate
                                               ,pr_des_reto => pr_des_reto         --> OK ou NOK
                                               ,pr_tab_erro => pr_tab_erro);
          -- Se retornar erro
          IF pr_des_reto = 'NOK' THEN
            -- Tenta buscar o erro no vetor de erro
            IF pr_tab_erro.COUNT > 0 THEN
              vr_cdcritic := pr_tab_erro(pr_tab_erro.FIRST).cdcritic;
              vr_dscritic := pr_tab_erro(pr_tab_erro.FIRST).dscritic|| ' Conta: '||rw_craprda.nrdconta||' Aplica: '||rw_craprda.nraplica;
            ELSE
              vr_dscritic := 'Retorno "NOK" na APLI0001.pc_consul_saldo_aplic_rdca60 e sem informacao na pr_vet_erro, Conta: '||rw_craprda.nrdconta||' Aplica: '||rw_craprda.nraplica;
            END IF;
            -- Levantar excecao
            RAISE vr_exc_erro;
          END IF;

        END IF;

        vr_sldresga := vr_sldpresg;

        IF vr_sldresga = 0 THEN

          IF rw_craprda.tpaplica = 3 THEN

            vr_sldresga := vr_vlsdrdca;

          ELSIF rw_craprda.tpaplica = 5 THEN

            vr_sldresga := vr_vlsdrdca;

          ELSE

            vr_sldresga := 0;

          END IF;

        END IF;

        vr_vldsaldo := vr_vldsaldo + vr_sldresga + vr_vlsldrgt;

      END LOOP;

      IF vr_vldsaldo > 0 THEN

        -- Monta critica
        vr_cdcritic := NULL;
        vr_dscritic := 'SALDO EM APLICACAO RDCA.';

        -- Gera exce��o
        RAISE vr_exc_erro;

      END IF;

      /* Data de fim e inicio da utilizacao da taxa de poupanca.
      Utiliza-se essa data quando o rendimento da aplicacao for menor que
      a poupanca, a cooperativa opta por usar ou nao.
      Essa informacao � necess�ria para a rotina pc_saldo_rgt_rdc_pos */
      vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_tptabela => 'USUARI'
                                              ,pr_cdempres => 11
                                              ,pr_cdacesso => 'MXRENDIPOS'
                                              ,pr_tpregist => 1);

      --Determinar as data de inicio e fim das taxas para rotina pc_saldo_rgt_rdc_pos
      vr_dtinitax := To_Date(gene0002.fn_busca_entrada(1, vr_dstextab, ';'),'DD/MM/YYYY');
      vr_dtfimtax := To_Date(gene0002.fn_busca_entrada(2, vr_dstextab, ';'),'DD/MM/YYYY');

      -- Saldo RDC
      FOR rw_saldo_rdc IN cr_saldo_rdc(pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta) LOOP

        -- RDCPRE
        IF rw_saldo_rdc.tpaplrdc = 1 THEN

          vr_sldresga := rw_saldo_rdc.vlsdrdca;

        -- RDCPOS
        ELSIF rw_saldo_rdc.tpaplrdc = 2 THEN

          -- Inicializa as vari�veis
          vr_vlrrgtot := 0;
          vr_sldresga := 0;

          APLI0001.pc_saldo_rgt_rdc_pos(pr_cdcooper => pr_cdcooper --> Cooperativa
                                       ,pr_cdagenci => pr_cdagenci --> Codigo da agencia
                                       ,pr_nrdcaixa => pr_nrdcaixa --> Numero do caixa
                                       ,pr_nrctaapl => rw_saldo_rdc.nrdconta --> Numero da conta
                                       ,pr_nraplres => rw_saldo_rdc.nraplica --> Numero da aplicacao
                                       ,pr_dtmvtolt => pr_dtmvtolt --> Data do movimento
                                       ,pr_dtaplrgt => pr_dtmvtolt --> Data aplicacao
                                       ,pr_vlsdorgt => 0           --> Valor RDCA
                                       ,pr_flggrvir => FALSE --> Identificador se deve gravar valor insento
                                       ,pr_dtinitax => vr_dtinitax --> Data Inicial da Utilizacao da taxa da poupanca
                                       ,pr_dtfimtax => vr_dtfimtax --> Data Final da Utilizacao da taxa da poupanca
                                       ,pr_vlsddrgt => vr_sldpresg --> Valor do resgate total sem irrf ou o solicitado
                                       ,pr_vlrenrgt => vr_vlrenrgt --> Rendimento total a ser pago quando resgate total
                                       ,pr_vlrdirrf => vr_vlrdirrf --> IRRF do que foi solicitado
                                       ,pr_perirrgt => vr_perirrgt --> Percentual de aliquota para calculo do IRRF
                                       ,pr_vlrgttot => vr_vlrrgtot --> Resgate para zerar a aplicacao
                                       ,pr_vlirftot => vr_vlirftot --> IRRF para finalizar a aplicacao
                                       ,pr_vlrendmm => vr_vlrendmm --> Rendimento da ultima provisao ate a data do resgate
                                       ,pr_vlrvtfim => vr_vlrvtfim --> Quantia provisao reverter para zerar a aplicacao
                                       ,pr_des_reto => pr_des_reto --> Indicador de saida com erro (OK/NOK)
                                       ,pr_tab_erro => pr_tab_erro); --> Tabela de erro

          --Se retornou erro
          IF pr_des_reto = 'NOK' THEN
            -- Tenta buscar o erro no vetor de erro
            IF pr_tab_erro.COUNT > 0 THEN
              vr_cdcritic:=  pr_tab_erro(pr_tab_erro.FIRST).cdcritic;
              vr_des_erro := pr_tab_erro(pr_tab_erro.FIRST).dscritic|| ' Conta: '||rw_saldo_rdc.nrdconta ||' Nr.Aplicacao: '||rw_saldo_rdc.nraplica;
            ELSE
              vr_cdcritic:= 0;
              vr_des_erro := 'Retorno "NOK" na APLI0001.pc_saldo_rgt_rdc_pos e sem informa��o na pr_tab_erro, Conta: '||rw_saldo_rdc.nrdconta;
            END IF;
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;

          --Se o valor do resgate > 0
          IF NVL(vr_vlrrgtot,0) > 0 THEN
            --Valor saldo rdca recebe valor resgate
            vr_sldresga := vr_vlrrgtot;
          ELSE
            --Valor saldo rdca recebe valor saldo rdca
            vr_sldresga := NVL(rw_saldo_rdc.vlsdrdca,0);
          END IF;

        END IF;

        vr_vldsaldo := vr_vldsaldo + vr_sldresga;

      END LOOP;

      IF vr_vldsaldo > 0 THEN

        -- Monta critica
        vr_dscritic := 'SALDO EM APLICACAO RDC.';

        -- Gera exce��o
        RAISE vr_exc_erro;

      END IF;

      -- Encontra o seguros ativos
      OPEN cr_crapseg(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_dtfimvig => vr_datdodia);

      FETCH cr_crapseg INTO rw_crapseg;

      -- Se encontrar
      IF cr_crapseg%FOUND THEN

        -- Fecha o cursor
        CLOSE cr_crapseg;

        -- Monta a critica
        vr_dscritic := 'SEGURO ATIVO.';

        -- Gera exce��o
        RAISE vr_exc_erro;

      ELSE
        -- Fecha o cursor
        CLOSE cr_crapseg;

      END IF;

      -- Encontra autoriza��o de d�bito em conta-corrente
      OPEN cr_crapatr(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);

      FETCH cr_crapatr INTO rw_crapatr;

      -- Se encontrar
      IF cr_crapatr%FOUND THEN

        -- Fecha o cursor
        CLOSE cr_crapatr;

        -- Monta a critica
        vr_cdcritic := NULL;
        vr_dscritic := 'AUTORIZACAO DE DEBITO EM CONTA-CORRENTE.';

        -- Gera exce��o
        RAISE vr_exc_erro;

      ELSE
        -- Fecha o cursor
        CLOSE cr_crapatr;

      END IF;

      -- Encontra o Cadastro de poupanca programada
      FOR rw_craprpp IN cr_craprpp(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta) LOOP

        vr_vldsaldo := rw_craprpp.vlsdrdpp;

        -- Encontrar Cadastro de lancamentos de aplicacoes de poupanca
        FOR rw_craplpp IN cr_craplpp(pr_cdcooper => pr_cdcooper
                                    ,pr_nrdconta => rw_craprpp.nrdconta
                                    ,pr_nrctrrpp => rw_craprpp.nrctrrpp) LOOP

          vr_vldsaldo := vr_vldsaldo - rw_craplpp.vllanmto;

        END LOOP;

        IF vr_vldsaldo > 0 THEN

          -- Monta critica
          vr_cdcritic := NULL;
          vr_dscritic := 'POUPANCA PROGRAMADA COM SALDO.';

          -- Gera exce��o
          RAISE vr_exc_erro;

        END IF;

      END LOOP;

      -- Encontra folhas de cheque
      FOR rw_crapfdc IN cr_crapfdc(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta) LOOP

        IF rw_crapfdc.incheque = 0 THEN

          IF rw_crapfdc.tpcheque = 1 THEN

            -- Monta critica
            vr_cdcritic := NULL;
            vr_dscritic := 'TALAO DE CHEQUES EM USO.';

            -- Gera exce��o
            RAISE vr_exc_erro;

          ELSE

            -- Monta critica
            vr_cdcritic := NULL;
            vr_dscritic := 'TALAO DE CHEQUES TB EM USO.';

            -- Gera exce��o
            RAISE vr_exc_erro;

          END IF;

        END IF;

      END LOOP;

      -- Encontra se existe chques em custodia que ainda n�o foram resgatados
      OPEN cr_crapcst(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_dtlibera => pr_dtmvtolt);

      FETCH cr_crapcst INTO rw_crapcst;

      -- Se encontrar
      IF cr_crapcst%FOUND THEN

        -- Fecha o cursor
        CLOSE cr_crapcst;

        -- Monta a critica
        vr_cdcritic := NULL;
        vr_dscritic := 'CHEQUES EM CUSTODIA NAO RESGATADOS.';

        -- Gera exce��o
        RAISE vr_exc_erro;

      ELSE
        -- Fecha o cursor
        CLOSE cr_crapcst;

      END IF;

      -- Verifica se existe cheques descontados que ainda n�o foram resgatados
      OPEN cr_crapcdb(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_dtlibera => pr_dtmvtolt);

      FETCH cr_crapcdb INTO rw_crapcdb;

      -- Se encontrar
      IF cr_crapcdb%FOUND THEN

        -- Fecha o cursor
        CLOSE cr_crapcdb;

        -- Monta a critica
        vr_cdcritic := NULL;
        vr_dscritic := 'CHEQUES DESCONTADOS NAO RESGATADOS.';

        -- Gera exce��o
        RAISE vr_exc_erro;

      ELSE
        -- Fecha o cursor
        CLOSE cr_crapcdb;

      END IF;

      -- Verifica se existe titulos descontados que ainda n�o foram resgatados
      OPEN cr_craptdb(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta);

      FETCH cr_craptdb INTO rw_craptdb;

      -- Se encontrar
      IF cr_craptdb%FOUND THEN

        -- Fecha o cursor
        CLOSE cr_craptdb;

        -- Monta a critica
        vr_dscritic := 'TITULOS DESCONTADOS NAO RESGATADOS.';

        -- Gera exce��o
        RAISE vr_exc_erro;

      ELSE
        -- Fecha o cursor
        CLOSE cr_craptdb;

      END IF;

      -- Verifica se existem titulos programados e que ainda n�o foram resgatados
      OPEN cr_craptit(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => pr_nrdconta
                     ,pr_dtdpagto => pr_dtmvtolt);

      FETCH cr_craptit INTO rw_craptit;

      -- Se encontrar
      IF cr_craptit%FOUND THEN

        -- Fecha o cursor
        CLOSE cr_craptit;

        -- Monta a critica
        vr_dscritic := 'TITULOS PROGRAMADOS NAO RESGATADOS.';

        -- Gera exce��o
        RAISE vr_exc_erro;

      ELSE
        -- Fecha o cursor
        CLOSE cr_craptit;

      END IF;

      -- Retorno OK
      pr_des_reto := 'OK';

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';

        -- Gera erro
        GENE0001.pc_gera_erro(pr_cdcooper => pr_cdcooper,
                              pr_cdagenci => pr_cdagenci,
                              pr_nrdcaixa => pr_nrdcaixa,
                              pr_nrsequen => 1,
                              pr_cdcritic => vr_cdcritic,
                              pr_dscritic => vr_dscritic,
                              pr_tab_erro => pr_tab_erro);

      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';

        -- Chamar rotina de grava��o de erro
        vr_dscritic := 'Erro na APLI0002.pc_ver_saldo --> '|| SQLERRM;

        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0 --> Critica 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

    END;

  END pc_ver_saldos;

  /* Subrotina para obter depositos Identificados */
  PROCEDURE pc_obtem_depos_identificad   (pr_cdcooper     IN crapcop.cdcooper%TYPE              --Codigo Cooperativa
                                         ,pr_cdagenci     IN crapass.cdagenci%TYPE              --Codigo Agencia
                                         ,pr_nrdcaixa     IN INTEGER                            --Numero do Caixa
                                         ,pr_cdoperad     IN VARCHAR2                           --Codigo Operador
                                         ,pr_nmdatela     IN VARCHAR2                           --Nome da Tela
                                         ,pr_idorigem     IN INTEGER                            --Origem dos Dados
                                         ,pr_nrdconta     IN crapass.nrdconta%TYPE              --Numero da Conta do Associado
                                         ,pr_idseqttl     IN INTEGER                            --Sequencial do Titular
                                         ,pr_dtiniper     IN DATE                               --Data Inicio periodo
                                         ,pr_dtfimper     IN DATE                               --Data Final periodo
                                         ,pr_flgpagin     IN BOOLEAN                            --Imprimir pagina
                                         ,pr_iniregis     IN INTEGER                            --Indicador Registro
                                         ,pr_qtregpag     IN INTEGER                            --Quantidade Registros Pagos
                                         ,pr_flgerlog     IN BOOLEAN                            --Imprimir log
                                         ,pr_qtregist     OUT INTEGER                           --Quantidade Registros
                                         ,pr_des_reto     OUT VARCHAR2                          --Retorno OK ou NOK
                                         ,pr_tab_erro     OUT GENE0001.typ_tab_erro             --Tabela Retorno Erro
                                         ,pr_tab_dep_identific  OUT EXTR0001.typ_tab_dep_identificado) IS        --Vetor para o retorno das informa��es
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_obtem_depos_identificad            Antigo: procedures/b1wgen0001.p/obtem-depositos-identificados
  --  Sistema  :
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Julho/2014                           Ultima atualizacao: 02/07/2014
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo   : Procedure para obter depositos Identificados do associado
  --
  -- Altera��es : 02/07/2014 - Convers�o Progress -> Oracle (Alisson - AMcom)
  --
  ---------------------------------------------------------------------------------------------------------------
      -- Busca dos dados do associado
      CURSOR cr_crapass(pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT crapass.nrdconta
              ,crapass.nmprimtl
              ,crapass.vllimcre
              ,crapass.nrcpfcgc
              ,crapass.inpessoa
              ,crapass.cdcooper
              ,crapass.cdagenci
        FROM crapass crapass
        WHERE crapass.cdcooper = pr_cdcooper
        AND   crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
      --Selecionar Lancamentos
      CURSOR cr_craplcm (pr_cdcooper IN craplcm.cdcooper%TYPE
                        ,pr_nrdconta IN craplcm.nrdconta%TYPE
                        ,pr_dtiniper IN craplcm.dtmvtolt%TYPE
                        ,pr_dtfimper IN craplcm.dtmvtolt%TYPE) IS
        SELECT lcm.nrdconta
              ,lcm.nrdolote
              ,lcm.dtmvtolt
              ,lcm.cdagenci
              ,lcm.cdhistor
              ,lcm.cdpesqbb
              ,lcm.cdbccxlt
              ,lcm.nrdocmto
              ,lcm.nrparepr
              ,lcm.vllanmto
              ,lcm.dsidenti
              ,lcm.dscedent
              ,lcm.nrdctabb
              ,lcm.rowid
        FROM craplcm lcm
        WHERE lcm.cdcooper = pr_cdcooper
        AND   lcm.nrdconta = pr_nrdconta
        AND   lcm.dtmvtolt >= pr_dtiniper
        AND   lcm.dtmvtolt <= pr_dtfimper
        AND   trim(lcm.dsidenti) IS NOT NULL
        ORDER BY lcm.cdcooper, lcm.nrdconta, lcm.dtmvtolt, lcm.cdhistor, lcm.nrdocmto, lcm.progress_recid;
      rw_craplcm cr_craplcm%ROWTYPE;
      --Variaveis Locais
      vr_dsorigem VARCHAR2(100);
      vr_dtdivulg DATE;
      vr_dtvigenc DATE;
      vr_cdfvlcop INTEGER;
      vr_cdhistaa INTEGER;
      vr_cdhsetaa INTEGER;
      vr_cdhisint INTEGER;
      vr_cdhseint INTEGER;
      vr_vltarpro NUMBER;
      vr_cdbattaa VARCHAR2(100);
      vr_cdbatint VARCHAR2(100);
      vr_dstransa VARCHAR2(100);
      vr_lshistor craptab.dstextab%TYPE;
      vr_nrdrowid ROWID;
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(4000);
      vr_des_reto VARCHAR2(3);
      --Tabelas de Memoria
      vr_tab_extr extr0001.typ_tab_extrato_conta;
      --Variaveis de Excecoes
      vr_exc_erro EXCEPTION;
    BEGIN
      --Limpar tabelas memoria
      pr_tab_erro.DELETE;
      pr_tab_dep_identific.DELETE;

      --Inicializar transacao
      vr_dsorigem:= gene0001.vr_vet_des_origens(pr_idorigem);
      vr_dstransa:= 'Listar depositos identificados.';

      --Selecionar associado
      OPEN cr_crapass (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta);
      --Posicionar no proximo registro
      FETCH cr_crapass INTO rw_crapass;
      --Se nao encontrou
      IF cr_crapass%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crapass;
        --mensagem erro
        vr_cdcritic:= 9;
        vr_dscritic:= NULL;
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
      --Fechar Cursor
      CLOSE cr_crapass;

      --Zerar Historicos
      vr_cdhistaa:= 0;
      vr_cdhsetaa:= 0;
      vr_cdhisint:= 0;
      vr_cdhseint:= 0;

      --Determinar tipo pessoa e local transacao
      IF rw_crapass.inpessoa = 1 THEN
        vr_cdbattaa:= 'TROUTTAAPF';  /* Pessoa F�sica via TAA      */
        vr_cdbatint:= 'TROUTINTPF';  /* Pessoa F�sica via Internet */
      ELSE
        vr_cdbattaa:= 'TROUTTAAPJ';  /* Pessoa Jur�dica via TAA      */
        vr_cdbatint:= 'TROUTINTPJ';  /* Pessoa Jur�dica via Internet */
      END IF;

      /*  Busca valor da tarifa do extrato*/
      TARI0001.pc_carrega_dados_tar_vigente (pr_cdcooper  => pr_cdcooper  --Codigo Cooperativa
                                            ,pr_cdbattar  => vr_cdbattaa  --Codigo Tarifa
                                            ,pr_vllanmto  => 1            --Valor Lancamento
                                            ,pr_cdprogra  => NULL         --Codigo Programa
                                            ,pr_cdhistor  => vr_cdhistaa  --Codigo Historico
                                            ,pr_cdhisest  => vr_cdhsetaa  --Historico Estorno
                                            ,pr_vltarifa  => vr_vltarpro  --Valor tarifa
                                            ,pr_dtdivulg  => vr_dtdivulg  --Data Divulgacao
                                            ,pr_dtvigenc  => vr_dtvigenc  --Data Vigencia
                                            ,pr_cdfvlcop  => vr_cdfvlcop  --Codigo faixa valor cooperativa
                                            ,pr_cdcritic  => vr_cdcritic  --Codigo Critica
                                            ,pr_dscritic  => vr_dscritic  --Descricao Critica
                                            ,pr_tab_erro  => pr_tab_erro); --Tabela erros
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      /*  Busca valor da tarifa do extrato*/
      TARI0001.pc_carrega_dados_tar_vigente (pr_cdcooper  => pr_cdcooper  --Codigo Cooperativa
                                            ,pr_cdbattar  => vr_cdbatint  --Codigo Tarifa
                                            ,pr_vllanmto  => 1            --Valor Lancamento
                                            ,pr_cdprogra  => NULL         --Codigo Programa
                                            ,pr_cdhistor  => vr_cdhisint  --Codigo Historico
                                            ,pr_cdhisest  => vr_cdhseint  --Historico Estorno
                                            ,pr_vltarifa  => vr_vltarpro  --Valor tarifa
                                            ,pr_dtdivulg  => vr_dtdivulg  --Data Divulgacao
                                            ,pr_dtvigenc  => vr_dtvigenc  --Data Vigencia
                                            ,pr_cdfvlcop  => vr_cdfvlcop  --Codigo faixa valor cooperativa
                                            ,pr_cdcritic  => vr_cdcritic  --Codigo Critica
                                            ,pr_dscritic  => vr_dscritic  --Descricao Critica
                                            ,pr_tab_erro  => pr_tab_erro); --Tabela erros
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;

      --Buscar Lista Historicos Cheques
      vr_lshistor:= tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_tptabela => 'GENERI'
                                              ,pr_cdempres => 0
                                              ,pr_cdacesso => 'HSTCHEQUES'
                                              ,pr_tpregist => 0);
      --Se nao encontrou
      IF vr_lshistor IS NULL THEN
        vr_lshistor:= '999';
      END IF;

      --Selecionar Lancamentos
      FOR rw_craplcm IN cr_craplcm (pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_dtiniper => pr_dtiniper
                                   ,pr_dtfimper => pr_dtfimper) LOOP
        --Incrementar Contador
        pr_qtregist:= nvl(pr_qtregist,0) + 1;
        --Sem Pagina
        IF NOT pr_flgpagin OR
           (pr_qtregist >= pr_iniregis AND
            pr_qtregist < (pr_iniregis + pr_qtregpag)) THEN

          -- Chama rotina que gera-registro-extrato na temp-table
          extr0001.pc_gera_registro_extrato (pr_cdcooper   => pr_cdcooper      --> Cooperativa conectada
                                            ,pr_rowid      => rw_craplcm.rowid --> Registro buscado da craplcm
                                            ,pr_flgident   => TRUE             --> Se deve ou n�o usar o craplcm.dsidenti
                                            ,pr_nmdtable   => 'D'              --> Dep�sito Identificado
                                            ,pr_lshistor   => vr_lshistor      --> Lista de hist�ricos de Cheques
                                            ,pr_tab_extr   => vr_tab_extr      --> Tabela Extrato
                                            ,pr_tab_depo   => pr_tab_dep_identific --> Tabela Depositos
                                            ,pr_des_reto   => vr_des_reto      --> Retorno OK ou NOK
                                            ,pr_des_erro   => vr_dscritic);    --> Descricao erro
          -- Se houve erro
          IF vr_des_reto = 'NOK' THEN
            --Zerar Critica
            vr_cdcritic:= 0;
            --Levantar Excecao
            RAISE vr_exc_erro;
          END IF;
        END IF;
      END LOOP;

      -- Se foi solicitado gera��o de LOG
      IF pr_flgerlog THEN
        -- Chamar gera��o de LOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => NULL
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1 --> TRUE
                            ,pr_hrtransa => gene0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;
      --Retorno OK
      pr_des_reto:= 'OK';
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Chamar rotina de grava��o de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0 --> Critica 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Se foi solicitado gera��o de LOG
        IF pr_flgerlog THEN
          -- Chamar gera��o de LOG
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => vr_dsorigem
                              ,pr_dstransa => vr_dstransa
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0 --> FALSE
                              ,pr_hrtransa => gene0002.fn_busca_time
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
        END IF;
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_des_reto := 'NOK';
        -- Chamar rotina de grava��o de erro
        vr_dscritic := 'Erro na pc_obtem_depos_identificad --> '|| sqlerrm;
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0 --> Critica 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Se foi solicitado gera��o de LOG
        IF pr_flgerlog THEN
          -- Chamar gera��o de LOG
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => vr_dsorigem
                              ,pr_dstransa => vr_dstransa
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0 --> FALSE
                              ,pr_hrtransa => gene0002.fn_busca_time
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
        END IF;
    END pc_obtem_depos_identificad;

    --> Procedimento para buscar informa�oes de depositos avista
  PROCEDURE pc_carrega_dep_vista (pr_cdcooper  IN crapcop.cdcooper%TYPE    --> Codigo da cooperativa
                                 ,pr_cdagenci  IN crapage.cdagenci%TYPE    --> C�digo da agencia
                                 ,pr_nrdcaixa  IN crapbcx.nrdcaixa%TYPE    --> Numero do caixa
                                 ,pr_cdoperad  IN crapope.cdoperad%TYPE    --> Codigo do operador
                                 ,pr_nrdconta  IN crapass.nrdconta%TYPE    --> Numero da conta do cooperado
                                 ,pr_dtmvtolt  IN DATE                     --> Data do movimento
                                 ,pr_idorigem  IN INTEGER                  --> Id origem
                                 ,pr_idseqttl  IN crapttl.idseqttl%TYPE    --> Sequencial do titular
                                 ,pr_nmdatela  IN craptel.nmdatela%TYPE    --> Nome da tela
                                 ,pr_flgerlog  IN VARCHAR2                 --> Identificador se deve gerar log S-Sim e N-Nao
                                 -------> OUT <------
                                 ,pr_tab_saldos     OUT EXTR0001.typ_tab_saldos --> Retornar saldos
                                 ,pr_tab_libera_epr OUT typ_tab_libera_epr      --> Retornar dados de liberacao de epr
                                 ,pr_des_reto       OUT VARCHAR2                --> Retorno OK/NOK
                                 ,pr_tab_erro       OUT GENE0001.typ_tab_erro   --> Retorna os erros
                                 ) IS


    /* .............................................................................

     Programa: pc_carrega_dep_vista        antigo: b1wgen0001.p/carrega_dep_vista
     Sistema : Rotinas gen�ricas para calculos e envios de extratos
     Sigla   : EXTR
     Autor   : Odirlei Busana(AMcom)
     Data    : Outubro/2015.                    Ultima atualizacao: 19/10/2015

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Procedimento para buscar informa�oes de depositos avista

     Alteracoes: 19/10/2015 - Convers�o Progress -> Oracle (Odirlei/AMcom)
    ..............................................................................*/
    ---------------> CURSORES <-----------------
    --> buscar dados do associado
    CURSOR cr_crapass IS
      SELECT ass.cdcooper
            ,ass.nrdconta
            ,ass.flgcrdpa
            ,ass.inpessoa
            ,ass.vllimcre
            ,ass.tplimcre
            ,ass.dtultlcr
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    --> Buscar saldo do associado
    CURSOR cr_crapsld IS
      SELECT crapsld.vlsddisp
            ,crapsld.vlsdbloq
            ,crapsld.vlsdblpr
            ,crapsld.vlsdblfp
            ,crapsld.vlsdchsl
            ,crapsld.vlsdindi
            ,crapsld.vlipmfap
            ,crapsld.vlipmfpg
        FROM crapsld
       WHERE crapsld.cdcooper = pr_cdcooper
         AND crapsld.nrdconta = pr_nrdconta;
    rw_crapsld cr_crapsld%ROWTYPE;

    --> Buscar lan�amentos do cooperado
    CURSOR cr_craplcm IS
      SELECT /*+ index_asc (lcm CRAPLCM##CRAPLCM2) */
             lcm.vllanmto,
             lcm.cdhistor,
             lcm.dtrefere,
             his.inhistor,
             his.indoipmf,
             his.indebcre
        FROM craplcm lcm,
             craphis his
       WHERE lcm.cdcooper = his.cdcooper
         AND lcm.cdhistor = his.cdhistor
         AND lcm.cdcooper = pr_cdcooper
         AND lcm.nrdconta = pr_nrdconta
         AND lcm.dtmvtolt = pr_dtmvtolt
         AND lcm.cdhistor <> 289;

    --> Depositos Bloqueados
    CURSOR cr_crapdpb IS
      SELECT /*+index_asc (dpb CRAPDPB##CRAPDPB2)*/
             dpb.nrdconta,
             dpb.dtmvtolt,
             dpb.nrdocmto,
             dpb.dtliblan,
             dpb.vllanmto
        FROM crapdpb dpb
       WHERE dpb.cdcooper = pr_cdcooper
         AND dpb.nrdconta = pr_nrdconta
         AND dpb.cdhistor = 2
         AND dpb.inlibera = 1
         AND dpb.dtliblan > pr_dtmvtolt;

    CURSOR cr_craplcm2(pr_cdcooper craplcm.cdcooper%TYPE,
                       pr_nrdconta craplcm.nrdconta%TYPE,
                       pr_dtmvtolt craplcm.dtmvtolt%TYPE,
                       pr_nrdocmto crapdpb.nrdocmto%TYPE) IS
      SELECT /*+ index_asc (lcm CRAPLCM##CRAPLCM2) */
             lcm.vllanmto,
             lcm.cdhistor
        FROM craplcm lcm
       WHERE lcm.cdcooper = pr_cdcooper
         AND lcm.nrdconta = pr_nrdconta
         AND lcm.dtmvtolt = pr_dtmvtolt
         AND lcm.cdhistor IN (108, 161, 891, 282)
         AND lcm.cdpesqbb = to_char(pr_nrdocmto, 'fm0000000');

    -----------------------> VARIAVEIS <------------------------
    --> Tratamento de erros
    vr_exc_erro EXCEPTION;
    vr_des_reto VARCHAR2(4000);
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic VARCHAR2(4000);

    --> Variaveis para tratamento de log
    vr_dsorigem VARCHAR2(50);
    vr_dstransa VARCHAR2(200);
    vr_nrdrowid ROWID;

    vr_dstextab     craptab.dstextab%TYPE;
    vr_tab_dtinipmf DATE;
    vr_tab_dtfimpmf DATE;
    vr_tab_txcpmfcc NUMBER := 0;
    vr_txdoipmf     NUMBER := 0;
    vr_tab_txrdcpmf NUMBER := 0;
    vr_tab_indabono INTEGER;
    vr_tab_dtiniabo DATE;
    vr_indoipmf     INTEGER;

    vr_tab_dtiniiof DATE;
    vr_tab_dtfimiof DATE;
    vr_tab_txiofrda NUMBER := 0;
    vr_tab_txiofepr NUMBER := 0;

    vr_vlsddisp crapsld.vlsddisp%TYPE := 0;
    vr_vlsdbloq crapsld.vlsdbloq%TYPE := 0;
    vr_vlsdblpr crapsld.vlsdblpr%TYPE := 0;
    vr_vlsdblfp crapsld.vlsdblfp%TYPE := 0;
    vr_vlsdchsl crapsld.vlsdchsl%TYPE := 0;
    vr_vlsdindi crapsld.vlsdindi%TYPE := 0;
    vr_vlipmfap NUMBER := 0;
    vr_vlestabo NUMBER := 0;
    vr_vlestorn NUMBER := 0;
    vr_vlacerto NUMBER := 0;
    vr_vlsaqmax NUMBER := 0;
    vr_vlstotal NUMBER := 0;
    vr_vlblqjud NUMBER := 0;
    vr_vlresblq NUMBER := 0;
    vr_vllibera NUMBER := 0;

    vr_ind      PLS_INTEGER;
    vr_indlib   PLS_INTEGER;


  BEGIN

    IF pr_flgerlog = 'S' THEN
      vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem);
      vr_dstransa := 'Consultar dados Dep. Vista.';
    END IF;

    --> Buscar dados do associado
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

    --> Tabela com a taxa do CPMF
    vr_dstextab := tabe0001.fn_busca_dstextab ( pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'CTRCPMFCCR'
                                               ,pr_tpregist => 1 );

    IF TRIM(vr_dstextab) IS NULL THEN
      vr_cdcritic := 641; --> Falta tabela de controle da CPMF.
      vr_dscritic := NULL;
      RAISE vr_exc_erro;
    END IF;

    --> Quebrar informa��es do dstextab
    vr_tab_dtinipmf := to_date(SUBSTR(vr_dstextab, 1,10),'DD/MM/RRRR');
    vr_tab_dtfimpmf := to_date(SUBSTR(vr_dstextab,12,10),'DD/MM/RRRR');

    IF pr_dtmvtolt >= vr_tab_dtinipmf  AND
       pr_dtmvtolt <= vr_tab_dtfimpmf  THEN
      vr_tab_txcpmfcc := to_number(SUBSTR(vr_dstextab,23,13));
      vr_tab_txrdcpmf := to_number(SUBSTR(vr_dstextab,38,13));

    ELSE
      vr_tab_txcpmfcc := 0;
      vr_tab_txrdcpmf := 1;
    END IF;

    vr_tab_indabono := SUBSTR(vr_dstextab,51,1);
    vr_tab_dtiniabo := to_date(SUBSTR(vr_dstextab,53,10),'DD/MM/RRRR');

    --> Tabela com a taxa do IOF sobre aplicacoes
    vr_dstextab := tabe0001.fn_busca_dstextab ( pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'CTRIOFRDCA'
                                               ,pr_tpregist => 1 );

    IF TRIM(vr_dstextab) IS NULL THEN
      vr_cdcritic := 641; --> Falta tabela de controle da CPMF.
      vr_dscritic := NULL;
      RAISE vr_exc_erro;
    END IF;

    vr_tab_dtiniiof := to_date(SUBSTR(vr_dstextab, 1,10),'DD/MM/RRRR');
    vr_tab_dtfimiof := to_date(SUBSTR(vr_dstextab,12,10),'DD/MM/RRRR');

    IF pr_dtmvtolt >= vr_tab_dtiniiof  AND
       pr_dtmvtolt <= vr_tab_dtfimiof  THEN
      vr_tab_txiofrda := to_number(SUBSTR(vr_dstextab,23,16));
    ELSE
      vr_tab_txiofrda := 0;
    END IF;

    --> Tabela com a taxa do IOF sobre emprestimos
    vr_dstextab := tabe0001.fn_busca_dstextab ( pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'CTRIOFEMPR'
                                               ,pr_tpregist => 1 );

    IF TRIM(vr_dstextab) IS NULL THEN
      vr_cdcritic := 626; --> Falta tabela da aliquota do IOF sobre emprestimos
      vr_dscritic := NULL;
      RAISE vr_exc_erro;
    END IF;

    vr_tab_dtiniiof := to_date(SUBSTR(vr_dstextab, 1,10),'DD/MM/RRRR');
    vr_tab_dtfimiof := to_date(SUBSTR(vr_dstextab,12,10),'DD/MM/RRRR');
    IF pr_dtmvtolt >= vr_tab_dtiniiof  AND
       pr_dtmvtolt <= vr_tab_dtfimiof  THEN
      vr_tab_txiofepr := to_number(SUBSTR(vr_dstextab,23,16));
    ELSE
      vr_tab_txiofepr := 0;
    END IF;

    --> Buscar saldo do associado
    OPEN cr_crapsld;
    FETCH cr_crapsld INTO rw_crapsld;

    IF cr_crapsld%NOTFOUND THEN
      CLOSE cr_crapsld;
      vr_cdcritic := 0;
      vr_dscritic := 'Conta/dv: '|| pr_nrdconta|| 'sem registro de saldo.';
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapsld;
    END IF;

    vr_vlsddisp := rw_crapsld.vlsddisp;
    vr_vlsdbloq := rw_crapsld.vlsdbloq;
    vr_vlsdblpr := rw_crapsld.vlsdblpr;
    vr_vlsdblfp := rw_crapsld.vlsdblfp;
    vr_vlsdchsl := rw_crapsld.vlsdchsl;
    vr_vlsdindi := rw_crapsld.vlsdindi;
    vr_vlipmfap := 0;
    vr_vlestabo := 0;

    --> Buscar os lan�amentos do dia
    FOR rw_craplcm IN cr_craplcm LOOP

      --> Chamar rotina para compor o saldo
      pc_compor_saldo_dia(pr_vllanmto => rw_craplcm.vllanmto
                         ,pr_inhistor => rw_craplcm.inhistor
                         ,pr_vlsddisp => vr_vlsddisp
                         ,pr_vlsdchsl => vr_vlsdchsl
                         ,pr_vlsdbloq => vr_vlsdbloq
                         ,pr_vlsdblpr => vr_vlsdblpr
                         ,pr_vlsdblfp => vr_vlsdblfp
                         ,pr_vlsdindi => vr_vlsdindi
                         ,pr_des_reto => vr_des_reto
                         ,pr_cdcritic => vr_cdcritic);

      IF vr_des_reto = 'NOK' THEN
        RAISE vr_exc_erro;
      END IF;

      vr_txdoipmf := vr_tab_txcpmfcc;
      IF vr_tab_indabono = 0  AND
         rw_craplcm.cdhistor IN (114,117,127,160) THEN
        vr_indoipmf := 1;
      ELSE
        vr_indoipmf := rw_craplcm.indoipmf;
      END IF;

      --> Calcula CPMF para os lancamentos
      IF vr_indoipmf > 1  THEN
        IF rw_craplcm.indebcre = 'D'  THEN
          vr_vlipmfap := vr_vlipmfap + TRUNC(rw_craplcm.vllanmto * vr_tab_txcpmfcc,2);
        ELSIF rw_craplcm.indebcre = 'C' THEN
          vr_vlipmfap := vr_vlipmfap - TRUNC(rw_craplcm.vllanmto * vr_tab_txcpmfcc,2);
        END IF;
      ELSIF rw_craplcm.inhistor = 12  THEN
        IF rw_craplcm.cdhistor <> 43  THEN
          vr_vlsdchsl := vr_vlsdchsl - TRUNC(rw_craplcm.vllanmto * vr_tab_txcpmfcc,2);
          vr_vlsddisp := vr_vlsddisp + TRUNC(rw_craplcm.vllanmto * vr_tab_txcpmfcc,2);
          vr_vlipmfap := vr_vlipmfap + TRUNC(rw_craplcm.vllanmto * vr_tab_txcpmfcc,2);
        END IF;
      END IF;

      IF vr_tab_indabono = 0                       AND
         vr_tab_dtiniabo <= rw_craplcm.dtrefere    AND
         rw_craplcm.cdhistor IN (186,187,498,500)  THEN
        vr_vlestorn := TRUNC(rw_craplcm.vllanmto * vr_tab_txcpmfcc,2);
        vr_vlipmfap := nvl(vr_vlipmfap,0) + nvl(vr_vlestorn,0) + TRUNC(nvl(vr_vlestorn,0) * vr_tab_txcpmfcc,2);
        vr_vlestabo := nvl(vr_vlestabo,0) + rw_craplcm.vllanmto;
      END IF;
    END LOOP;

    vr_vlestabo := TRUNC(vr_vlestabo * vr_tab_txiofrda,2);
    vr_vlacerto := nvl(vr_vlsddisp,0) - rw_crapsld.vlipmfap - rw_crapsld.vlipmfpg -
                   nvl(vr_vlipmfap,0) - nvl(vr_vlestabo,0);
    IF vr_vlacerto <= 0  THEN
      vr_vlsaqmax := 0;
    ELSE
      vr_vlsaqmax := TRUNC(vr_vlacerto * vr_tab_txrdcpmf,2);
    END IF;

    vr_vlacerto := nvl(vr_vlacerto,0) + nvl(vr_vlsdbloq,0) + nvl(vr_vlsdblpr,0) + nvl(vr_vlsdblfp,0);
    IF vr_vlacerto < 0  THEN
      vr_vlacerto := TRUNC(vr_vlacerto * (1 + vr_tab_txcpmfcc),2);
    ELSE
      vr_vlacerto := vr_vlacerto;
    END IF;

    vr_vlstotal := nvl(vr_vlsddisp,0) + nvl(vr_vlsdbloq,0) + nvl(vr_vlsdblpr,0) +
                    nvl(vr_vlsdblfp,0) + nvl(vr_vlsdchsl,0);
    vr_vlblqjud := 0;
    vr_vlresblq := 0;

    -- Busca Saldo Bloqueado Judicial
    gene0005.pc_retorna_valor_blqjud(pr_cdcooper => pr_cdcooper            --> Cooperativa
                                    ,pr_nrdconta => pr_nrdconta            --> Conta
                                    ,pr_nrcpfcgc => 0                      --> Fixo - CPF/CGC
                                    ,pr_cdtipmov => 0                      --> Fixo - Tipo do movimento
                                    ,pr_cdmodali => 1                      --> Modalidade Cta Corrente
                                    ,pr_dtmvtolt => pr_dtmvtolt            --> Data atual
                                    ,pr_vlbloque => vr_vlblqjud            --> Valor bloqueado
                                    ,pr_vlresblq => vr_vlresblq            --> Valor que falta bloquear
                                    ,pr_dscritic => vr_dscritic);          --> Erros encontrados no processo

    --> Carregar temptable
    vr_ind := pr_tab_saldos.COUNT;
    pr_tab_saldos(vr_ind).vlsddisp := vr_vlsddisp;
    pr_tab_saldos(vr_ind).vlsdbloq := vr_vlsdbloq;
    pr_tab_saldos(vr_ind).vlsdblpr := vr_vlsdblpr;
    pr_tab_saldos(vr_ind).vlsdblfp := vr_vlsdblfp;
    pr_tab_saldos(vr_ind).vlsdchsl := vr_vlsdchsl;
    pr_tab_saldos(vr_ind).vlstotal := vr_vlsdchsl + vr_vlsdblfp + vr_vlsdblpr + vr_vlsdbloq + vr_vlsddisp;
    pr_tab_saldos(vr_ind).vlsaqmax := vr_vlsaqmax;
    pr_tab_saldos(vr_ind).vlacerto := vr_vlacerto;
    pr_tab_saldos(vr_ind).vllimcre := rw_crapass.vllimcre;

    IF rw_crapass.tplimcre = 1  THEN
      pr_tab_saldos(vr_ind).dslimcre := '(CP)';
    ELSIF rw_crapass.tplimcre = 2  THEN
      pr_tab_saldos(vr_ind).dslimcre := '(SM)';
    ELSE
      pr_tab_saldos(vr_ind).dslimcre := '';
    END IF;

    pr_tab_saldos(vr_ind).dtultlcr := rw_crapass.dtultlcr;
    pr_tab_saldos(vr_ind).vlipmfpg := rw_crapsld.vlipmfpg;
    pr_tab_saldos(vr_ind).vlblqjud := vr_vlblqjud;

    --> Buscar depositos bloqueados
    FOR rw_crapdpb IN cr_crapdpb LOOP

      vr_vllibera := rw_crapdpb.vllanmto;

      --> Buscar lan�amentos de depositos bloqueados
      FOR rw_craplcm2 IN cr_craplcm2 (pr_cdcooper => pr_cdcooper,
                                      pr_nrdconta => rw_crapdpb.nrdconta,
                                      pr_dtmvtolt => rw_crapdpb.dtmvtolt,
                                      pr_nrdocmto => rw_crapdpb.nrdocmto) LOOP

        vr_vllibera := vr_vllibera - rw_craplcm2.vllanmto - TRUNC(rw_craplcm2.vllanmto * vr_tab_txcpmfcc,2);
      END LOOP;

      vr_vllibera := TRUNC(nvl(vr_vllibera,0) * nvl(vr_tab_txrdcpmf,0),2);

      /** Calculo do IOF sobre o emprestimo **/
      vr_vllibera := vr_vllibera - TRUNC(rw_crapdpb.vllanmto * vr_tab_txiofepr,2);

      IF vr_vllibera <= 0  THEN
        continue;
      END IF;

      --> Armazenar na temptable de retorno
      vr_indlib := pr_tab_libera_epr.count;
      pr_tab_libera_epr(vr_indlib).dtlibera := rw_crapdpb.dtliblan;
      pr_tab_libera_epr(vr_indlib).vllibera := vr_vllibera;

    END LOOP;

    -- Se foi solicitado log
    IF pr_flgerlog = 'S' THEN
      -- Gerar LOG
      gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => NULL
                          ,pr_dsorigem => vr_dsorigem --> Origem enviada
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => pr_dtmvtolt
                          ,pr_flgtrans => 1
                          ,pr_hrtransa => gene0002.fn_busca_time
                          ,pr_idseqttl => pr_idseqttl
                          ,pr_nmdatela => pr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
    END IF;


  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Retorno n�o OK
      pr_des_reto := 'NOK';

      -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);

      -- Se foi solicitado log
      IF pr_flgerlog = 'S' THEN
        -- Gerar LOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem --> Origem enviada
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => pr_dtmvtolt
                            ,pr_flgtrans => 0
                            ,pr_hrtransa => gene0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;

    WHEN OTHERS THEN
      -- Retorno n�o OK
      pr_des_reto := 'NOK';
      -- Montar descri��o de erro n�o tratado
      vr_dscritic := 'Erro na rotina EXTR0001.pc_carrega_dep_vista: ' ||sqlerrm;
      -- Gerar rotina de grava��o de erro avisando sobre o erro n�o tratavo
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => 0
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);

      -- Se foi solicitado log
      IF pr_flgerlog = 'S' THEN
        -- Gerar LOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => vr_dscritic
                            ,pr_dsorigem => vr_dsorigem --> Origem enviada
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => pr_dtmvtolt
                            ,pr_flgtrans => 0
                            ,pr_hrtransa => gene0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;

  END pc_carrega_dep_vista;


  /* Procedure para Consultar o Extrato da Conta no Modo Caracter */
  PROCEDURE pc_consulta_extrato_car (pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa
                                    ,pr_cdagenci  IN crapass.cdagenci%TYPE --> Agencia
                                    ,pr_nrdcaixa  IN craperr.nrdcaixa%TYPE --> Caixa
                                    ,pr_cdoperad  IN craplgm.cdoperad%TYPE --> Operador
                                    ,pr_nrdconta  IN crapass.nrdconta%TYPE --> Conta
                                    ,pr_dtiniper  IN crapdat.dtmvtolt%TYPE --> Data Inicial
                                    ,pr_dtfimper  IN crapdat.dtmvtolt%TYPE --> Data Final
                                    ,pr_idorigem  IN INTEGER               --> Origem
                                    ,pr_idseqttl  IN INTEGER               --> Seq. Titular
                                    ,pr_nmdatela  IN VARCHAR2              --> Tela
                                    ,pr_flgerlog  IN INTEGER               --> Gerar Log?
                                    ,pr_des_erro OUT VARCHAR2              --> Saida OK/NOK
                                    ,pr_clob_ret OUT CLOB                  --> Tabela Extrato da Conta
                                    ,pr_cdcritic OUT PLS_INTEGER           --> Codigo Erro
                                    ,pr_dscritic OUT VARCHAR2) IS          --> Descricao Erro
  /*---------------------------------------------------------------------------------------------------------------
  
    Programa : pc_consulta_extrato_car                  Antigo: 
    Sistema  : Conta-Corrente - Cooperativa de Credito
    Sigla    : CRED
    Autor    : Douglas Quisinski
    Data     : Novembro/2015                        Ultima atualizacao:   /  /    
  
    Dados referentes ao programa:
   
    Frequencia: -----
    Objetivo   : Procedure para Consultar o Extrato da Conta no Modo Caracter
  
    Altera��es : 
                 
  ---------------------------------------------------------------------------------------------------------------*/

    --Variaveis de Criticas
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
    vr_des_reto VARCHAR2(3); 

    -- Variaveis Locais
    vr_lshistor craptab.dstextab%TYPE;
    vr_flgerlog BOOLEAN;

    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

    --Tabelas de Memoria
    vr_tab_erro gene0001.typ_tab_erro;
    vr_tab_extrato_conta  extr0001.typ_tab_extrato_conta;

    --Variaveis Arquivo Dados
    vr_dstexto VARCHAR2(32767);
    vr_string  VARCHAR2(32767);
    
    --Variaveis de Indice
    vr_index VARCHAR(12);
    
    --Variaveis de Excecoes
    vr_exc_ok    EXCEPTION;                                       
    vr_exc_erro  EXCEPTION;     
    
    -- Buscar cadastro do associado
    CURSOR cr_crapass (pr_cdcooper crapcop.cdcooper%type,
                       pr_nrdconta crapass.nrdconta%type) IS
      SELECT nrdconta,
             cdagenci,
             vllimcre
        FROM crapass 
       WHERE crapass.cdcooper = pr_cdcooper          
         AND crapass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%rowtype;
        
    BEGIN
      
      --Limpar tabela erros
      vr_tab_erro.DELETE;
      
      --Limpar tabela dados
      vr_tab_extrato_conta.DELETE;
      
      --Inicializar Variaveis
      vr_cdcritic:= 0;                         
      vr_dscritic:= null;
      
      -- DATA DA COOPERATIVA
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;

      IF btch0001.cr_crapdat%NOTFOUND THEN

        -- FECHAR CR_CRAPDAT CURSOR POIS HAVER� RAISE
        CLOSE btch0001.cr_crapdat;

        -- MONTAR MENSAGEM DE CRITICA
        vr_cdcritic := 1;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        
        RAISE vr_exc_erro;
      ELSE
        -- APENAS FECHAR O CURSOR
        CLOSE btch0001.cr_crapdat;
      END IF;
      
      -- Busca associado
      OPEN  cr_crapass (pr_cdcooper => pr_cdcooper,
                        pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      
      IF cr_crapass%NOTFOUND THEN
        -- FECHAR CURSOR 
        CLOSE cr_crapass;

        -- MONTAR MENSAGEM DE CRITICA
        vr_cdcritic := 9;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        
        RAISE vr_exc_erro;
      ELSE 
        -- APENAS FECHAR O CURSOR
        CLOSE cr_crapass;
      END IF;  
      
      -- Buscar informa��o na craptab
      vr_lshistor := TABE0001.fn_busca_dstextab( pr_cdcooper =>  pr_cdcooper,
                                                 pr_nmsistem =>  'CRED',
                                                 pr_tptabela =>  'GENERI',
                                                 pr_cdempres =>  0,
                                                 pr_cdacesso =>  'HSTCHEQUES', 
                                                 pr_tpregist =>  0);
      IF TRIM(vr_lshistor) IS NULL THEN
        vr_lshistor := '999';
      END IF;  
      
      -- FLAG PARA GERAR O LOG
      vr_flgerlog := sys.diutil.int_to_bool(pr_flgerlog);
      
      --Consultar Beneficiario
      extr0001.pc_consulta_extrato(pr_cdcooper => pr_cdcooper --> Cooperativa
                                  ,pr_rw_crapdat => rw_crapdat --> ROW data
                                  ,pr_cdagenci => pr_cdagenci --> Agencia
                                  ,pr_nrdcaixa => pr_nrdcaixa --> Caixa
                                  ,pr_cdoperad => pr_cdoperad --> Operador
                                  ,pr_nrdconta => pr_nrdconta --> Conta
                                  ,pr_vllimcre => rw_crapass.vllimcre --> Limite
                                  ,pr_dtiniper => pr_dtiniper --> Data Inicial
                                  ,pr_dtfimper => pr_dtfimper --> Data Fim 
                                  ,pr_lshistor => vr_lshistor --> Lista de hist�ricos de Cheques
                                  ,pr_idorigem => pr_idorigem --> Origem
                                  ,pr_idseqttl => pr_idseqttl --> Seq. do Titular
                                  ,pr_nmdatela => pr_nmdatela --> Nome da Tela
                                  ,pr_flgerlog => vr_flgerlog --> Gerar Log ?
                                  ,pr_des_reto => vr_des_reto --> Retorno da Saida
                                  ,pr_tab_extrato => vr_tab_extrato_conta --> Tabela de Extrato da Conta
                                  ,pr_tab_erro => vr_tab_erro); --> Tabela de Erros
                                       
      --Se Ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        --Se possuir dados na tabela
        IF vr_tab_erro.COUNT > 0 THEN
          --Mensagem erro
          vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          --Mensagem erro
          vr_dscritic:= 'Erro ao executar a extr0001.pc_consulta_extrato.';
        END IF;    
        
        --Levantar Excecao
        RAISE vr_exc_erro;
        
      END IF;
                                          
      --Montar CLOB
      IF vr_tab_extrato_conta.COUNT > 0 THEN
        
        -- Criar documento XML
        dbms_lob.createtemporary(pr_clob_ret, TRUE); 
        dbms_lob.open(pr_clob_ret, dbms_lob.lob_readwrite);
        
        -- Insere o cabe�alho do XML 
        gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret 
                               ,pr_texto_completo => vr_dstexto 
                               ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><root>');
         
        --Buscar Primeiro beneficiario
        vr_index:= vr_tab_extrato_conta.FIRST;
        
        --Percorrer todos os beneficiarios
        WHILE vr_index IS NOT NULL LOOP
          vr_string:= '<extrato>'||
                        '<nrdconta>'||NVL(TO_CHAR(vr_tab_extrato_conta(vr_index).nrdconta),' ')|| '</nrdconta>'|| 
                        '<dtmvtolt>'||NVL(TO_CHAR(vr_tab_extrato_conta(vr_index).dtmvtolt,'DD/MM/YYYY'),' ')|| '</dtmvtolt>'|| 
                        '<nrsequen>'||NVL(TO_CHAR(vr_tab_extrato_conta(vr_index).nrsequen),' ')|| '</nrsequen>'|| 
                        '<cdhistor>'||NVL(TO_CHAR(vr_tab_extrato_conta(vr_index).cdhistor),' ')|| '</cdhistor>'|| 
                        '<dshistor>'||NVL(TO_CHAR(vr_tab_extrato_conta(vr_index).dshistor),' ')|| '</dshistor>'|| 
                        '<nrdocmto>'||NVL(TO_CHAR(vr_tab_extrato_conta(vr_index).nrdocmto),' ')|| '</nrdocmto>'|| 
                        '<indebcre>'||NVL(TO_CHAR(vr_tab_extrato_conta(vr_index).indebcre),' ')|| '</indebcre>'|| 
                        '<dtliblan>'||NVL(TO_CHAR(vr_tab_extrato_conta(vr_index).dtliblan),' ')|| '</dtliblan>'|| 
                        '<inhistor>'||NVL(TO_CHAR(vr_tab_extrato_conta(vr_index).inhistor),' ')|| '</inhistor>'|| 
                        '<vllanmto>'||NVL(TO_CHAR(vr_tab_extrato_conta(vr_index).vllanmto),' ')|| '</vllanmto>'|| 
                        '<vlsddisp>'||NVL(TO_CHAR(vr_tab_extrato_conta(vr_index).vlsddisp),' ')|| '</vlsddisp>'|| 
                        '<vlsdchsl>'||NVL(TO_CHAR(vr_tab_extrato_conta(vr_index).vlsdchsl),' ')|| '</vlsdchsl>'|| 
                        '<vlsdbloq>'||NVL(TO_CHAR(vr_tab_extrato_conta(vr_index).vlsdbloq),' ')|| '</vlsdbloq>'|| 
                        '<vlsdblpr>'||NVL(TO_CHAR(vr_tab_extrato_conta(vr_index).vlsdblpr),' ')|| '</vlsdblpr>'|| 
                        '<vlsdblfp>'||NVL(TO_CHAR(vr_tab_extrato_conta(vr_index).vlsdblfp),' ')|| '</vlsdblfp>'|| 
                        '<vlsdtota>'||NVL(TO_CHAR(vr_tab_extrato_conta(vr_index).vlsdtota),' ')|| '</vlsdtota>'|| 
                        '<vllimcre>'||NVL(TO_CHAR(vr_tab_extrato_conta(vr_index).vllimcre),' ')|| '</vllimcre>'|| 
                        '<dsagenci>'||NVL(TO_CHAR(vr_tab_extrato_conta(vr_index).dsagenci),' ')|| '</dsagenci>'|| 
                        '<cdagenci>'||NVL(TO_CHAR(vr_tab_extrato_conta(vr_index).cdagenci),' ')|| '</cdagenci>'|| 
                        '<cdbccxlt>'||NVL(TO_CHAR(vr_tab_extrato_conta(vr_index).cdbccxlt),' ')|| '</cdbccxlt>'|| 
                        '<nrdolote>'||NVL(TO_CHAR(vr_tab_extrato_conta(vr_index).nrdolote),' ')|| '</nrdolote>'|| 
                        '<dsidenti>'||NVL(TO_CHAR(vr_tab_extrato_conta(vr_index).dsidenti),' ')|| '</dsidenti>'|| 
                        '<nrparepr>'||NVL(TO_CHAR(vr_tab_extrato_conta(vr_index).nrparepr),' ')|| '</nrparepr>'|| 
                        '<dsextrat>'||NVL(TO_CHAR(vr_tab_extrato_conta(vr_index).dsextrat),' ')|| '</dsextrat>'|| 
                        '<vlblqjud>'||NVL(TO_CHAR(vr_tab_extrato_conta(vr_index).vlblqjud),' ')|| '</vlblqjud>'|| 
                        '<cdcoptfn>'||NVL(TO_CHAR(vr_tab_extrato_conta(vr_index).cdcoptfn),'0')|| '</cdcoptfn>'|| 
                        '<nrseqlmt>'||NVL(TO_CHAR(vr_tab_extrato_conta(vr_index).nrseqlmt),' ')|| '</nrseqlmt>'|| 
                      '</extrato>';

          -- Escrever no XML
          gene0002.pc_escreve_xml(pr_xml            => pr_clob_ret 
                                 ,pr_texto_completo => vr_dstexto 
                                 ,pr_texto_novo     => vr_string
                                 ,pr_fecha_xml      => FALSE);   
                                                    
          --Proximo Registro
          vr_index:= vr_tab_extrato_conta.NEXT(vr_index);
          
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
        -- Retorno n�o OK          
        pr_des_erro:= 'NOK';
        
        --Erro
        pr_cdcritic:= vr_cdcritic;
        pr_dscritic:= vr_dscritic;        
          
      WHEN OTHERS THEN
        -- Retorno n�o OK
        pr_des_erro:= 'NOK';
        
        pr_cdcritic:= 0;
        -- Chamar rotina de grava��o de erro
        pr_dscritic:= 'Erro na extr0001.pc_consulta_extrato_car --> '|| SQLERRM;

  END pc_consulta_extrato_car;  

END EXTR0001;
/
