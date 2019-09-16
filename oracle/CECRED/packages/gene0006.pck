CREATE OR REPLACE PACKAGE CECRED.GENE0006 IS
  /* .............................................................................

   Programa: sistema/generico/procedures/bo_algoritmo_seguranca.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Agosto/2006                   Ultima Atualizacao: 22/08/2019
   Dados referentes ao programa:

   Frequencia: Diario (internet)
   Objetivo  : Rotinas que auxiliam na seguranca das paginas da internet.

   Alteracoes: 25/06/2007 - Tratamento para pessoa juridica (David).

               13/09/2007 - Alimentar crappro.dttransa (Evandro).

               13/11/2007 - Incluida procedure lista_protocolos (Guilherme).
                          - Gerar protocolo para plano de capital (David).

               28/04/2008 - Adicionado o estorno de protocoloes (Evandro).
                          - Adaptacao para agendamentos (David).

               31/07/2008 - Incluir parametro para geracao do protocolo (David).

               15/06/2010 - Incluido parametro "origem" na procedure
                            lista_protocolos (Diego).

               03/10/2011 - Incluir informacoes do TAA (Gabriel).
                          - Adicionado campos nmprepo, nrcpfpre, nmoperad e
                            nrcpfope em cratpro da procedure lista_protocolos
                            (Jorge).

               27/10/2011 - Parametros de operador na gera_protocolo
                          - Melhoria, fazer a geração do protocolo em um
                            transaction para evitar duplicidade (Guilherme).

               09/03/2012 - Alimentado os campos cdbcoctl e cdagectl,
                            da temp-table cratpro, na procedure
                            lista_protocolos; somente se cdtippro = 2 ou 6.
                            (Fabricio)

               08/05/2012 - Projeto TED Internet (David).

               31/05/2013 - Conversão Progress-Oracle (Petter - Supero).
               
               06/06/2014 - Ajustes referente ao projeto de captação:
                            - Alterado a procedure pc_estorna_protocolo
                              para tratar o protocolos de aplicação.
                            (Adriano).
              
               12/03/2015 - Adicionado log no momento que insere um protocolo
                            na tabela crappro, pois houve erros ao inserir
                            que não foi possível ser identificado SD 253323 (Kelvin).
                            
               06/10/2015 - Incluindo procedure de validacao de protocolos
                            (Andre Santos - SUPERO).             

               06/12/2017 - Adicionado procedure PC_LISTA_PROTOCOLOS_POR_TIPOS 
                            (P285 - Ricardo Linhares).

               22/08/2019 - Ajustar tamanho do campo dscedent na typ_reg_protocolo
                            (Douglas - Projeto 363)
............................................................................. */

  /* Objetos de uso comum */

  /* PL Table para armazenar registros de protocolos */
  TYPE typ_reg_protocolo IS
    RECORD(cdtippro crappro.cdtippro%TYPE
          ,dtmvtolt crappro.dtmvtolt%TYPE
          ,dttransa crappro.dttransa%TYPE
          ,hrautent crappro.hrautent%TYPE
          ,vldocmto crappro.vldocmto%TYPE
          ,nrdocmto crappro.nrdocmto%TYPE
          ,nrseqaut crappro.nrseqaut%TYPE
          ,dsinform##1 crappro.dsinform##1%TYPE
          ,dsinform##2 crappro.dsinform##2%TYPE
          ,dsinform##3 crappro.dsinform##3%TYPE
          ,dsprotoc crappro.dsprotoc%TYPE
          ,dscedent VARCHAR(300)
          ,flgagend crappro.flgagend%TYPE
          ,nmprepos crappro.nmprepos%TYPE
          ,nrcpfpre crappro.nrcpfpre%TYPE
          ,nmoperad crapopi.nmoperad%TYPE
          ,nrcpfope crappro.nrcpfope%TYPE
          ,cdbcoctl crapcop.cdbcoctl%TYPE
          ,cdagectl crapcop.cdagectl%TYPE
					,nrcelular   VARCHAR2(100)
          ,nmoperadora VARCHAR2(100)
					,nrnsuope    VARCHAR2(100)
          ,cdhistor craphis.cdhistor%TYPE
          ,cdagesic crapcop.cdagesic%TYPE
          ,nmrescop crapcop.nmrescop%TYPE
          ,nmextcop_central crapcop.nmextcop%TYPE
          ,nmrescop_central crapcop.nmrescop%TYPE
          ,nrtelsac crapcop.nrtelsac%TYPE
          ,nrtelouv crapcop.nrtelouv%TYPE
          ,idlstdom INTEGER
          ,dsorigem VARCHAR2(50)
          -- Projeto 470
          ,dtinclusao crappro.dsinform##2%TYPE
          ,hrinclusao crappro.dsinform##2%TYPE
          ,dsfrase crappro.dsinform##1%TYPE
          ,dsoperacao VARCHAR2(100)
          ,cdbanco    VARCHAR2(100)
          ,cdagencia  VARCHAR2(100)
          ,cdconta    VARCHAR2(100)
          ,nrcheque_i VARCHAR2(100)
          ,nrcheque_f VARCHAR2(100)
          ,dsativo    VARCHAR2(100)
          -- Fim Projeto 470
          );

  /* Definição da PL Table de registros de protocolos */
  TYPE typ_tab_protocolo IS TABLE OF typ_reg_protocolo INDEX BY PLS_INTEGER;



  /* Funções e Procedures */

  /* Rotina para gerar um codigo identificador de sessão para ser usado na validacao de parametros na URL */
  FUNCTION fn_calcula_id(pr_dscampo1 IN VARCHAR2                       --> Campo 1 de cálculo
                        ,pr_dscampo2 IN VARCHAR2) RETURN VARCHAR2;     --> Campo 2 de cálculo

  /* Validar ID da sessão */
  PROCEDURE pc_id_sessao(pr_cdcooper IN crapttl.cdcooper%TYPE     --> Código da cooperativa
                        ,pr_nrdconta IN crapttl.nrdconta%TYPE     --> Número da conta
                        ,pr_idseqttl IN crapttl.idseqttl%TYPE     --> ID da sequencia
                        ,pr_idsessio OUT VARCHAR2                 --> ID da sessão
                        ,pr_des_erro OUT VARCHAR2);               --> Erros do processo

  /* Função para converter uma string em hexadecinal */
  FUNCTION fn_converte_hex(pr_vlconver IN VARCHAR2) RETURN VARCHAR2;   --> String para converção em hexadecinal
    
  PROCEDURE pc_valida_protocolo_md5(pr_cdcooper IN crappro.cdcooper%TYPE  --> Codigo da cooperativa
                                   ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo da Agencia
                                   ,pr_nrdcaixa IN crapaut.nrdcaixa%TYPE  --> Número do caixa
                                   ,pr_cdoperad IN VARCHAR2               --> Operador do Caixa
                                   ,pr_cdprogra IN VARCHAR2               --> Descricao do Programa
                                   ,pr_idorigem IN NUMBER                 --> Origem
                                   ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do Movimento Atual
                                   ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE  --> Data do Proximo dia
                                   ,pr_nmdatela IN VARCHAR2               --> Descricao da Tela
                                   ,pr_cddopcao IN VARCHAR2               --> Opcao da tela
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Nro da Conta
                                   ,pr_nrdocmto IN NUMBER                 --> Nro do Documento
                                   ,pr_dtmvtolx IN crapdat.dtmvtolt%TYPE  --> Data
                                   ,pr_horproto IN NUMBER                 --> Horario do protocolo
                                   ,pr_minproto IN NUMBER                 --> Minuto  do protocolo
                                   ,pr_segproto IN NUMBER                 --> Segundo do protocolo
                                   ,pr_vlprotoc IN NUMBER                 --> Valor do protocolo
                                   ,pr_dsprotoc IN VARCHAR2               --> Descricao do protocolo
                                   ,pr_nrseqaut IN VARCHAR2               --> Nro da Seq de Autenticacao
                                   ,pr_flgerlog IN NUMBER                 --> Flag de geracao de log
                                   ,pr_nmdcampo OUT VARCHAR2              --> Retorno do campo
                                   ,pr_desmensg OUT VARCHAR2              --> Retorno da mensagem de Sucesso
                                   ,pr_dscritic OUT VARCHAR2);            --> Descricao da crítica

  /* Procedure para gerar protocolos de segurança */
  PROCEDURE pc_gera_protocolo(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                             ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data movimento
                             ,pr_hrtransa IN craplcm.hrtransa%TYPE  --> Hora da transação
                             ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                             ,pr_nrdocmto IN craplcm.nrdocmto%TYPE  --> Número do documento
                             ,pr_nrseqaut IN crapaut.nrseqaut%TYPE  --> Número da sequencia
                             ,pr_vllanmto IN craplcm.vllanmto%TYPE  --> Valor lançamento
                             ,pr_nrdcaixa IN crapaut.nrdcaixa%TYPE  --> Número do caixa
                             ,pr_gravapro IN BOOLEAN                --> Controle de gravação
                             ,pr_cdtippro IN crappro.cdtippro%TYPE  --> Código de operação
                             ,pr_dsinfor1 IN VARCHAR2               --> Descrição 1
                             ,pr_dsinfor2 IN VARCHAR2               --> Descrição 2
                             ,pr_dsinfor3 IN VARCHAR2               --> Descrição 3
                             ,pr_dscedent IN VARCHAR2               --> Descritivo
                             ,pr_flgagend IN BOOLEAN                --> Controle de agenda
                             ,pr_nrcpfope IN NUMBER                 --> Número de operação
                             ,pr_nrcpfpre IN NUMBER                 --> Número pré operação
                             ,pr_nmprepos IN VARCHAR2               --> Nome
                             ,pr_dsprotoc OUT crappro.dsprotoc%TYPE --> Descrição do protocolo
                             ,pr_dscritic OUT VARCHAR2              --> Descrição crítica
                             ,pr_des_erro OUT VARCHAR2);            --> Descrição dos erros de processo

  /* Procedure para gerar protocolos de segurança */
  PROCEDURE pc_gera_protocolo_car(pr_cdcooper  IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                 ,pr_dtmvtolt  IN crapdat.dtmvtolt%TYPE  --> Data movimento
                                 ,pr_hrtransa  IN craplcm.hrtransa%TYPE  --> Hora da transação
                                 ,pr_nrdconta  IN crappro.nrdconta%TYPE  --> Número da conta
                                 ,pr_nrdocmto  IN craplcm.nrdocmto%TYPE  --> Número do documento
                                 ,pr_nrseqaut  IN crapaut.nrseqaut%TYPE  --> Número da sequencia
                                 ,pr_vllanmto  IN craplcm.vllanmto%TYPE  --> Valor lançamento
                                 ,pr_nrdcaixa  IN crapaut.nrdcaixa%TYPE  --> Número do caixa
                                 ,pr_gravapro  IN INTEGER                --> Controle de gravação (0-Nao/1-Sim)
                                 ,pr_cdtippro  IN crappro.cdtippro%TYPE  --> Código de operação
                                 ,pr_dsinfor1  IN VARCHAR2               --> Descrição 1
                                 ,pr_dsinfor2  IN VARCHAR2               --> Descrição 2
                                 ,pr_dsinfor3  IN VARCHAR2               --> Descrição 3
                                 ,pr_dscedent  IN VARCHAR2               --> Descritivo
                                 ,pr_flgagend  IN INTEGER                --> Controle de agenda (0-Nao/1-Sim)
                                 ,pr_nrcpfope  IN NUMBER                 --> Número de operação
                                 ,pr_nrcpfpre  IN NUMBER                 --> Número pré operação
                                 ,pr_nmprepos  IN VARCHAR2               --> Nome
                                 ,pr_dsprotoc OUT crappro.dsprotoc%TYPE  --> Descrição do protocolo
                                 ,pr_dscritic OUT VARCHAR2               --> Descrição crítica
                                 ,pr_des_erro OUT VARCHAR2);             --> Descrição dos erros de processo

  /* Procedure para gerar protocolos de segurança */
  PROCEDURE pc_gera_protocolo_md5(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data movimento
                                 ,pr_hrtransa IN craplcm.hrtransa%TYPE  --> Hora da transação
                                 ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                 ,pr_nrdocmto IN craplcm.nrdocmto%TYPE  --> Número do documento
                                 ,pr_nrseqaut IN crapaut.nrseqaut%TYPE  --> Número da sequencia
                                 ,pr_vllanmto IN craplcm.vllanmto%TYPE  --> Valor lançamento
                                 ,pr_nrdcaixa IN crapaut.nrdcaixa%TYPE  --> Número do caixa
                                 ,pr_gravapro IN BOOLEAN                --> Controle de gravação
                                 ,pr_cdtippro IN crappro.cdtippro%TYPE  --> Código de operação
                                 ,pr_dsinfor1 IN VARCHAR2               --> Descrição 1
                                 ,pr_dsinfor2 IN VARCHAR2               --> Descrição 2
                                 ,pr_dsinfor3 IN VARCHAR2               --> Descrição 3
                                 ,pr_dscedent IN VARCHAR2               --> Descritivo
                                 ,pr_flgagend IN BOOLEAN                --> Controle de agenda
                                 ,pr_nrcpfope IN NUMBER                 --> Número de operação
                                 ,pr_nrcpfpre IN NUMBER                 --> Número pré operação
                                 ,pr_nmprepos IN VARCHAR2               --> Nome
                                 ,pr_dsprotoc OUT crappro.dsprotoc%TYPE --> Descrição do protocolo
                                 ,pr_dscritic OUT VARCHAR2              --> Descrição crítica
                                 ,pr_des_erro OUT VARCHAR2);            --> Descrição dos erros de processo

  
  
  PROCEDURE pc_lista_protocolos_por_tipos(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                 ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                 ,pr_dtinipro IN crappro.dtmvtolt%TYPE  --> Data inicial do protocolo
                                 ,pr_dtfimpro IN crappro.dtmvtolt%TYPE  --> Data final do protocolo
                                 ,pr_dsprotoc IN VARCHAR2 DEFAULT NULL  --> Lista de protocolos a serem buscados
                                 ,pr_iniconta IN NUMBER                 --> Início da conta
                                 ,pr_nrregist IN NUMBER                 --> Número de registros
                                 ,pr_cdtippro IN VARCHAR2                 --> Código protocolo
                                 ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAS
                                 ,pr_dstransa OUT VARCHAR2              --> Descrição da transação
                                 ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                 ,pr_qttotreg OUT NUMBER                --> Quantidade de registros
                                 ,pr_protocolo  OUT typ_tab_protocolo       --> PL Table de registros
                                 ,pr_des_erro OUT VARCHAR2);

  
  /* Listar protocolos gerados */
  PROCEDURE pc_lista_protocolos(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                               ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                               ,pr_dtinipro IN crappro.dtmvtolt%TYPE  --> Data inicial do protocolo
                               ,pr_dtfimpro IN crappro.dtmvtolt%TYPE  --> Data final do protocolo
                               ,pr_dsprotoc IN VARCHAR2 DEFAULT NULL  --> Lista de protocolos a serem buscados
                               ,pr_iniconta IN NUMBER                 --> Início da conta
                               ,pr_nrregist IN NUMBER                 --> Número de registros
                               ,pr_cdtippro IN NUMBER                 --> Código protocolo
                               ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet
                               ,pr_dstransa OUT VARCHAR2              --> Descrição da transação
                               ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                               ,pr_qttotreg OUT NUMBER                --> Quantidade de registros
                               ,pr_protocolo  OUT typ_tab_protocolo       --> PL Table de registros
                               ,pr_des_erro OUT VARCHAR2);            --> Erros do processo

  /* Realiza estorno de protocolos */
  PROCEDURE pc_estorna_protocolo(pr_cdcooper IN crapcop.cdcooper%TYPE   --> Código da cooperativa
                                ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE   --> Data movimento
                                ,pr_nrdconta IN crapass.nrdconta%TYPE   --> Número da conta
                                ,pr_cdtippro IN crappro.cdtippro%TYPE   --> Código do protocolo
                                ,pr_nrdocmto IN craplcm.nrdocmto%TYPE   --> Número do documento
                                ,pr_dsprotoc OUT crappro.dsprotoc%TYPE  --> Descrição do protocolo
                                ,pr_retorno  OUT VARCHAR2);             --> Retorno do status da execução da exclusão
                                
  /* Busca protocolo */                              
  PROCEDURE pc_busca_protocolo(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                              ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de movimento
                              ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                              ,pr_cdtippro IN NUMBER                 --> Código protocolo
                              ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet
                              ,pr_nrdocmto IN VARCHAR2               --> Número do documento
                              ,pr_protocolo OUT typ_tab_protocolo   --> PL Table de registros
                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Código do erro
                              ,pr_dscritic OUT crapcri.dscritic%TYPE); --> Descrição do erro                                                                   
                              
  /* Responsável por buscar as informações do protocolo informado
     Possui a mesma funcionalidade da rotina acima, porem utiliza gravacao em tabelas para serem
     chamadas diretamente atraves de rotinas progress */
  PROCEDURE pc_busca_protocolo_wt(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de movimento
                                 ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                 ,pr_cdtippro IN NUMBER                 --> Código protocolo
                                 ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet
                                 ,pr_nrdocmto IN VARCHAR2               --> Número do documento
                                 ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Código do erro
                                 ,pr_dscritic OUT crapcri.dscritic%TYPE); --> Descrição da critica

  -- Efetua a busca do protocolo utilizando a chave cdcooper/dsprotoc                                
  PROCEDURE pc_busca_protocolo_por_protoc (pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                          ,pr_nrdconta IN crapopi.nrdconta%TYPE  --> Conta
                                          ,pr_dsprotoc IN crappro.dsprotoc%TYPE  --> Protocolo
                                          ,pr_cdorigem IN NUMBER
										  ,pr_flgativo IN crappro.flgativo%TYPE default 1 --> (0 - Inativos, 1 - Ativos, 2 - Todos)
                                          ,pr_protocolo OUT typ_tab_protocolo    --> PL Table de registros
                                          ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Código do erro
                                          ,pr_dscritic OUT crapcri.dscritic%TYPE);
                                                               
  /* Procedure para montar o protocolo de segurança */
  PROCEDURE pc_monta_protocolo(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                              ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data movimento
                              ,pr_hrtransa IN craplcm.hrtransa%TYPE  --> Hora da transação
                              ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                              ,pr_nrdocmto IN craplcm.nrdocmto%TYPE  --> Número do documento
                              ,pr_nrseqaut IN crapaut.nrseqaut%TYPE  --> Número da sequencia
                              ,pr_vllanmto IN craplcm.vllanmto%TYPE  --> Valor lançamento
                              ,pr_nrdcaixa IN crapaut.nrdcaixa%TYPE  --> Número do caixa
                              ,pr_tipo_protocolo IN INTEGER          --> Tipo de Protocolo (1-Velho/2-Novo)
                              ,pr_utiliza_seq IN INTEGER             --> Utilizar Sequence para gerar o protocolo novo (0-Nao / 1-Sim)
                              ,pr_dsprotoc OUT crappro.dsprotoc%TYPE --> Descrição do protocolo
                              ,pr_dscritic OUT VARCHAR2              --> Descrição crítica
                              ,pr_des_erro OUT VARCHAR2);            --> Descrição dos erros de processo

  /* Procedure para calcular o protocolo de segurança */
  PROCEDURE pc_criptografa_protocolo(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                    ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data movimento
                                    ,pr_hrtransa IN craplcm.hrtransa%TYPE  --> Hora da transação
                                    ,pr_sequence IN INTEGER                --> Sequence utilizada no protocolo
                                    ,pr_nrprotoc IN NUMBER                 --> Número do Protocolo
                                    ,pr_tipo_protocolo IN INTEGER          --> Tipo de Protocolo (1-Velho/2-Novo)
                                    ,pr_dsprotoc OUT crappro.dsprotoc%TYPE --> Descrição do protocolo
                                    ,pr_dscritic OUT VARCHAR2);            --> Descricao do Erro

  /* Procedure para calcular o protocolo de segurança */
  PROCEDURE pc_calcula_protocolo(pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                ,pr_nrdocmto IN craplcm.nrdocmto%TYPE  --> Número do documento
                                ,pr_nrseqaut IN crapaut.nrseqaut%TYPE  --> Número da sequencia
                                ,pr_vllanmto IN craplcm.vllanmto%TYPE  --> Valor lançamento
                                ,pr_nrdcaixa IN crapaut.nrdcaixa%TYPE  --> Numero do Caixa
                                ,pr_nrprotoc OUT NUMBER                --> Numero do Protocolo
                                ,pr_dscritic OUT VARCHAR2);            --> Descricao do Erro

  /* Procedure para desmontar o protocolo de segurança */
  PROCEDURE pc_desmonta_protocolo(pr_dsprotoc  IN VARCHAR2     --> Protocolo
                                 ,pr_tipo_protocolo IN INTEGER --> Tipo de Protocolo (1-Velho/2-Novo)
                                 ,pr_nrprotoc OUT INTEGER      --> Número do protocolo
                                 ,pr_cdcooper OUT INTEGER      --> Cooperativa
                                 ,pr_dtmvtolt OUT DATE         --> Data
                                 ,pr_hrtransa OUT INTEGER      --> Hora
                                 ,pr_nrsequen OUT INTEGER      --> Sequencia
                                 ,pr_is_valid OUT VARCHAR2     --> Valido ? "OK" / "NOK"
                                 ,pr_dscritic OUT VARCHAR2);   --> Descricao do Erro

  /* Procedure para validar o protocolo de segurança */
  PROCEDURE pc_valida_protocolo(pr_cdcooper  IN INTEGER    --> Cooperativa
                               ,pr_cddopcao  IN VARCHAR2   --> Opcao
                               ,pr_nrdconta  IN INTEGER    --> Conta
                               ,pr_nrdocmto  IN INTEGER    --> Numero do Documento
                               ,pr_dtmvtolx  IN DATE       --> Data do Protocolo
                               ,pr_horproto  IN INTEGER    --> Hora do Protocolo
                               ,pr_minproto  IN INTEGER    --> Minuto do Protocolo
                               ,pr_segproto  IN INTEGER    --> Segundo do Protocolo
                               ,pr_vlprotoc  IN NUMBER     --> Valor do Protocolo
                               ,pr_dsprotoc  IN VARCHAR2   --> Protocolo
                               ,pr_nrseqaut  IN VARCHAR2   --> Sequencia de Autenticacao
                               ,pr_nmdcampo OUT VARCHAR2   --> Nome do Campo
                               ,pr_returnvl OUT VARCHAR2   --> Retorno "OK" / "NOK"
                               ,pr_msgretur OUT VARCHAR2   --> Mensagem de Retorno
                               ,pr_msgerror OUT VARCHAR2   --> Mensagem de Erro
                               ,pr_cdcritic OUT INTEGER    --> Codigo da Critica
                               ,pr_dscritic OUT VARCHAR2); --> Descricao da Critica

END GENE0006;
/
CREATE OR REPLACE PACKAGE BODY CECRED.GENE0006 IS
  /* .............................................................................

   Programa: GENE0006   (Antigo: sistema/generico/procedures/bo_algoritmo_seguranca.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Agosto/2006                   Ultima Atualizacao: 06/12/2017
   Dados referentes ao programa:

   Frequencia: Diario (internet)
   Objetivo  : Rotinas que auxiliam na seguranca das paginas da internet.

   Alteracoes: 25/06/2007 - Tratamento para pessoa juridica (David).

               13/09/2007 - Alimentar crappro.dttransa (Evandro).

               13/11/2007 - Incluida procedure lista_protocolos (Guilherme).
                          - Gerar protocolo para plano de capital (David).

               28/04/2008 - Adicionado o estorno de protocoloes (Evandro).
                          - Adaptacao para agendamentos (David).

               31/07/2008 - Incluir parametro para geracao do protocolo (David).

               15/06/2010 - Incluido parametro "origem" na procedure
                            lista_protocolos (Diego).

               03/10/2011 - Incluir informacoes do TAA (Gabriel).
                          - Adicionado campos nmprepo, nrcpfpre, nmoperad e
                            nrcpfope em cratpro da procedure lista_protocolos
                            (Jorge).

               27/10/2011 - Parametros de operador na gera_protocolo
                          - Melhoria, fazer a geração do protocolo em um
                            transaction para evitar duplicidade (Guilherme).

               09/03/2012 - Alimentado os campos cdbcoctl e cdagectl,
                            da temp-table cratpro, na procedure
                            lista_protocolos; somente se cdtippro = 2 ou 6.
                            (Fabricio)

               08/05/2012 - Projeto TED Internet (David).

               31/05/2013 - Conversão Progress-Oracle (Petter - Supero).
               
               06/06/2014 - Ajustes referente ao projeto de captação
                            (Adriano).
               
               12/03/2015 - Adicionado log no momento que insere um protocolo
                            na tabela crappro, pois houve erros ao inserir
                            que não foi possível ser identificado SD 253323 (Kelvin).
                            
               08/09/2015 - Criacao da procedure pc_gera_protocolo_md5 para o projeto
                            GPS que envolve mensagens no IBank (Carlos Rafael Tanholi).
                            
               06/10/2015 - Incluindo procedure de validacao de protocolos
                            (Andre Santos - SUPERO).

               06/07/2016 - Incluir log no exception da crappro na procedure 
                            pc_gera_protocolo (Lucas Ranghetti #468306)
                            
               29/09/2016 - Ajuste para gravar a data no formato DD/MM/RRRR ao gravar o protocolo
                            (Andrei - RKAM).             
                            
               05/10/2016 - Correcao na geracao de log de erro nas procedures de geração e listagem
                            de protocolo. SD 535051 (Carlos Rafael Tanholi)
                            
               13/03/2017 - Na procedure pc_gera_protocolo foi retirado pr_dscritic 
                            da exception vr_exc_erro pois é um erro tratado 
                            (Lucas Ranghetti #624628)

               24/10/2017 - #781206 Nas rotinas pc_gera_protocolo e pc_gera_protocolo_md5, nos inserts da tabela
                            crappro, restringido o campo dscedent em 50 caracteres. Na rotina pc_busca_protocolo_wt,
                            no insert da tabela wt_protocolo, restringido o campo dscedent em 40 caracteres (Carlos)

               06/12/2017 - Adicionado procedure PC_LISTA_PROTOCOLOS_POR_TIPOS 
                            (P285 - Ricardo Linhares).

............................................................................. */

  /* Rotina para gerar um codigo identificador de sessão para ser usado na validacao de parametros na URL */
  /* Rotina para gerar um codigo identificador de sessão para ser usado na validacao de parametros na URL */
  FUNCTION fn_calcula_id(pr_dscampo1 IN VARCHAR2                       --> Campo 1 de cálculo
                        ,pr_dscampo2 IN VARCHAR2) RETURN VARCHAR2 IS   --> Campo 2 de cálculo
    -- ..........................................................................
    --
    --  Programa : fn_calcula_id   (Antigo: sistema/generico/procedures/bo_algoritmo_seguranca.p --> calcula_id)
    --  Sistema  : Processos Genéricos
    --  Sigla    : GENE
    --  Autor    : Petter Rafael - Supero
    --  Data     : Maio/2013.                   Ultima atualização: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: ---
    --   Objetivo  : Gerar código de identificação de sessão para validar parametros de URL
    --
    --   Alteracoes: 02/05/2013 - Conversão Progress-Oracle (Petter - Supero).
    -- .............................................................................
  BEGIN
    DECLARE
      vr_dsembara   VARCHAR2(400);      --> Descritivo de controle
      vr_dscampos   VARCHAR2(400);      --> Descritivo de campos

    BEGIN
      -- Intercala o KEY-CODE de cada caractere dos dois campos
      FOR vr_contador IN 1..length(pr_dscampo1) LOOP
        -- Verifica o caracter de operação
        IF vr_contador <= length(pr_dscampo2) THEN
          vr_dscampos := vr_dscampos || ASCII(substr(pr_dscampo1, vr_contador, 1)) || ASCII(substr(pr_dscampo2, vr_contador, 1));
        ELSE
          vr_dscampos := vr_dscampos || ASCII(substr(pr_dscampo1, vr_contador, 1));
        END IF;
      END LOOP;

      -- "Embaralha" os caracteres intercalados
      FOR vr_contador IN 1..(length(vr_dscampos) / 2) LOOP
        vr_dsembara := vr_dsembara || substr(vr_dscampos, vr_contador, 1);

        -- Calcula o módulo da divisão
        IF MOD(length(vr_dscampos), 2) <> 0 THEN
          -- Verifica a diverença do contador
          IF vr_contador <> (length(vr_dscampos) / 2) THEN
            vr_dsembara := vr_dsembara || substr(vr_dscampos, length(vr_dscampos) + 1 - vr_contador, 1);
          END IF;
        ELSE
          vr_dsembara := vr_dsembara || substr(vr_dscampos, length(vr_dscampos) + 1 - vr_contador, 1);
        END IF;
      END LOOP;

      -- Assimila valor para retorno
      vr_dscampos := vr_dsembara;

      RETURN vr_dscampos;
    END;
  END fn_calcula_id;

  /* Validar ID da sessão */
  PROCEDURE pc_id_sessao(pr_cdcooper IN crapttl.cdcooper%TYPE   --> Código da cooperativa
                        ,pr_nrdconta IN crapttl.nrdconta%TYPE   --> Número da conta
                        ,pr_idseqttl IN crapttl.idseqttl%TYPE   --> ID da sequencia
                        ,pr_idsessio OUT VARCHAR2               --> ID da sessão
                        ,pr_des_erro OUT VARCHAR2) IS           --> Erros do processo
    -- ..........................................................................
    --
    --  Programa : pc_id_sessao   (Antigo: sistema/generico/procedures/bo_algoritmo_seguranca.p --> id_sessao)
    --  Sistema  : Processos Genéricos
    --  Sigla    : GENE
    --  Autor    : Petter Rafael - Supero
    --  Data     : Maio/2013.                   Ultima atualização: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: ---
    --   Objetivo  : Validar o ID de uma sessão
    --
    --   Alteracoes: 01/05/2013 - Conversão Progress-Oracle (Petter - Supero).
    -- .............................................................................
  BEGIN
    DECLARE
      vr_nmprimtl   VARCHAR2(100);        --> Nome de impressão
      vr_nrdconta   varchar2(40);         --> Número da conta
      vr_exc_erro   EXCEPTION;            --> Controle de exceção

      -- Busca dados sobre os associados
      CURSOR cr_crapass(pr_cdcooper IN crapttl.cdcooper%TYPE     --> Código da cooperativa
                       ,pr_nrdconta IN crapttl.nrdconta%TYPE) IS --> Número da conta
        SELECT cp.inpessoa
              ,cp.nmprimtl
        FROM crapass cp
        WHERE cp.cdcooper = pr_cdcooper
          AND cp.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;

      -- Busca dados sobre os tipos
      CURSOR cr_crapttl(pr_cdcooper IN crapttl.cdcooper%TYPE     --> Código da cooperativa
                       ,pr_nrdconta IN crapttl.nrdconta%TYPE     --> Número da conta
                       ,pr_idseqttl IN crapttl.idseqttl%TYPE) IS --> ID da sequencia
        SELECT cl.nmextttl
        FROM crapttl cl
        WHERE cl.cdcooper = pr_cdcooper
          AND cl.nrdconta = pr_nrdconta
          AND cl.idseqttl = pr_idseqttl;
      rw_crapttl cr_crapttl%ROWTYPE;

    BEGIN
      -- Buscar dados do associado
      OPEN cr_crapass(pr_cdcooper, pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;

      -- Verifica se a tupla retornou registros
      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;

        pr_des_erro := 'NOK';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapass;
      END IF;

      -- Verifica o tipo da pessoa
      IF rw_crapass.inpessoa = 1 THEN
        -- Busca dados de tipo
        OPEN cr_crapttl(pr_cdcooper, pr_nrdconta, pr_idseqttl);
        FETCH cr_crapttl INTO rw_crapttl;

        -- Verificar se a tupla retorno registro
        IF cr_crapttl%NOTFOUND THEN
          CLOSE cr_crapttl;

          pr_des_erro := 'NOK';
          RAISE vr_exc_erro;
        ELSE
          CLOSE cr_crapttl;
        END IF;

        vr_nmprimtl := gene0002.fn_busca_entrada(1, rw_crapttl.nmextttl, ' ');
      ELSE
        vr_nmprimtl := gene0002.fn_busca_entrada(1, rw_crapass.nmprimtl, ' ');
      END IF;

      -- Montar número ca conta
      vr_nrdconta := to_char(pr_cdcooper) || to_char(pr_idseqttl) || to_char(pr_nrdconta);

      -- Cálcula o tamanho das variáveis para montar o ID da sessão
      IF length(vr_nmprimtl) > length(vr_nrdconta) THEN
        pr_idsessio := fn_calcula_id(vr_nmprimtl, vr_nrdconta);
      ELSE
        pr_idsessio := fn_calcula_id(vr_nrdconta, vr_nmprimtl);
      END IF;
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_des_erro := 'Erro em GENE0006.pc_id_sessao: ' || pr_des_erro;
      WHEN OTHERS THEN
        pr_des_erro := 'Erro em GENE0006.pc_id_sessao: ' || SQLERRM;
    END;
  END pc_id_sessao;

  /* Função para converter uma string em hexadecinal */
  FUNCTION fn_converte_hex(pr_vlconver IN VARCHAR2) RETURN VARCHAR2 IS   --> String para converção em hexadecinal
    -- ..........................................................................
    --
    --  Programa : fn_converte_hex   (Antigo: sistema/generico/procedures/bo_algoritmo_seguranca.p --> converte_hex)
    --  Sistema  : Processos Genéricos
    --  Sigla    : GENE
    --  Autor    : Petter Rafael - Supero
    --  Data     : Maio/2013.                   Ultima atualização: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: ---
    --   Objetivo  : Converter uma string em hexadecinal
    --
    --   Alteracoes: 01/05/2013 - Conversão Progress-Oracle (Petter - Supero).
    -- .............................................................................
  BEGIN
    DECLARE
      vr_vldresto  INTEGER;          --> Controle do valor do resto
      vr_vlemhexa  VARCHAR2(100);    --> Valor hexadecinal
      vr_vlconver  VARCHAR2(400);    --> Auxiliar cálculo com o parâmetro

    BEGIN
      vr_vlconver := pr_vlconver;

      -- Iterar para formar a string hexadecinal
      LOOP
        -- Cálcular o módulo da divisão pela base 16
        vr_vldresto:= MOD(gene0002.fn_char_para_number(vr_vlconver), 16);

        -- Receber o valor do resto para formar o retorno hexadecinal
        IF vr_vldresto < 10 THEN
          vr_vlemhexa := to_char(vr_vldresto) || vr_vlemhexa;
        ELSE
          vr_vlemhexa := CHR(ASCII('A') + vr_vldresto - 10) || vr_vlemhexa;
        END IF;

        -- Controle de saída
        EXIT WHEN gene0002.fn_char_para_number(vr_vlconver) < 16;

        vr_vlconver:= to_char((gene0002.fn_char_para_number(vr_vlconver) - vr_vldresto) / 16);
      END LOOP;

      -- Medir tamanho da string para completar valores
      IF length(vr_vlemhexa) < 2 THEN
        vr_vlemhexa := '0'|| vr_vlemhexa;
      END IF;

      RETURN vr_vlemhexa;
    END;
  END fn_converte_hex;
  
  
  PROCEDURE pc_valida_protocolo_md5(pr_cdcooper IN crappro.cdcooper%TYPE  --> Codigo da cooperativa
                                   ,pr_cdagenci IN crapage.cdagenci%TYPE  --> Codigo da Agencia
                                   ,pr_nrdcaixa IN crapaut.nrdcaixa%TYPE  --> Número do caixa
                                   ,pr_cdoperad IN VARCHAR2               --> Operador do Caixa
                                   ,pr_cdprogra IN VARCHAR2               --> Descricao do Programa
                                   ,pr_idorigem IN NUMBER                 --> Origem
                                   ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data do Movimento Atual
                                   ,pr_dtmvtopr IN crapdat.dtmvtopr%TYPE  --> Data do Proximo dia
                                   ,pr_nmdatela IN VARCHAR2               --> Descricao da Tela
                                   ,pr_cddopcao IN VARCHAR2               --> Opcao da tela
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE  --> Nro da Conta
                                   ,pr_nrdocmto IN NUMBER                 --> Nro do Documento
                                   ,pr_dtmvtolx IN crapdat.dtmvtolt%TYPE  --> Data
                                   ,pr_horproto IN NUMBER                 --> Horario do protocolo
                                   ,pr_minproto IN NUMBER                 --> Minuto  do protocolo
                                   ,pr_segproto IN NUMBER                 --> Segundo do protocolo
                                   ,pr_vlprotoc IN NUMBER                 --> Valor do protocolo
                                   ,pr_dsprotoc IN VARCHAR2               --> Descricao do protocolo
                                   ,pr_nrseqaut IN VARCHAR2               --> Nro da Seq de Autenticacao
                                   ,pr_flgerlog IN NUMBER                 --> Flag de geracao de log
                                   ,pr_nmdcampo OUT VARCHAR2              --> Retorno do campo
                                   ,pr_desmensg OUT VARCHAR2              --> Retorno da mensagem de Sucesso
                                   ,pr_dscritic OUT VARCHAR2) IS          --> Descricao da crítica
  -- ..........................................................................
  --  Programa : pc_valida_protocolo   (Antigo: sistema/generico/procedures/b1wgen0127 --> Valida_Protocolo)
  --  Sistema  : Processos Genéricos
  --  Sigla    : GENE
  --  Autor    : Andre Santos - SUPERO
  --  Data     : Outubro/2015.                   Ultima atualização: --/--/----
  --
  --  Dados referentes ao programa:
  --
  --   Frequencia: ---
  --   Objetivo  : Validacao de protocolo pela tela VALPRO
  --
  --   Alteracoes:
  -- .............................................................................  
  
     -- Busca informacoes do associado
     CURSOR cr_crapass(p_cdcooper IN crapcop.cdcooper%TYPE
                      ,p_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT ass.nrdconta
          FROM crapass ass
         WHERE ass.cdcooper = p_cdcooper
           AND ass.nrdconta = p_nrdconta;
     rw_crapass cr_crapass%ROWTYPE;
     
     -- Busca informacoes da cooperativa anterior
     CURSOR cr_craptco(p_cdcooper IN crapcop.cdcooper%TYPE
                      ,p_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT tco.nrctaant
              ,tco.cdcopant
          FROM craptco tco
         WHERE tco.cdcooper = p_cdcooper
           AND tco.nrdconta = p_nrdconta
           AND tco.tpctatrf = 1;
     rw_craptco cr_craptco%ROWTYPE;

     -- Variaveies
     vr_tempotot VARCHAR2(10);
     vr_dsprotoc VARCHAR2(500);
  
     -- Variaveis de Excecao
     vr_erro EXCEPTION;
  
  BEGIN
     -- Inicializa Variavel
     pr_nmdcampo := NULL;
     pr_desmensg := NULL;
     pr_dscritic := NULL;
     
     OPEN cr_crapass(pr_cdcooper
                    ,pr_nrdconta);
     FETCH cr_crapass INTO rw_crapass;
     -- Se nao encontrou o associado     
     IF cr_crapass%NOTFOUND THEN
        -- Fecha cursor
        pr_dscritic := gene0001.fn_busca_critica(9);
        pr_nmdcampo := 'nrdconta';
        RAISE vr_erro;
     END IF;
     -- Apenas fecha cursor
     CLOSE cr_crapass;
     
     -- Se o nro do documento nao foi preenchido
     IF pr_nrdocmto = 0 THEN
        -- Gera critica
        pr_dscritic := 'Numero de documento invalido.';
        pr_nmdcampo := 'nrdocmto';        
        RAISE vr_erro;
     END IF;
     
     -- Se a data nao foi preenchida
     IF pr_dtmvtolx IS NULL THEN
        -- Gera critica
        pr_dscritic := 'Data incorreta.';
        pr_nmdcampo := 'dtmvtolt';
        RAISE vr_erro;
     END IF;

     -- Valida o campo de horas informado
     IF pr_horproto >= 24 THEN
        -- Gera critica
        pr_dscritic := 'Campo de Horas Invalido.';
        pr_nmdcampo := 'horproto';
        RAISE vr_erro;
     END IF;
     
     -- Valida o campo de minutos informado
     IF pr_minproto >= 60 THEN
        -- Gera critica
        pr_dscritic := 'Campo de Minutos Invalido.';
        pr_nmdcampo := 'minproto';
        RAISE vr_erro;
     END IF;
     
     -- Valida o campo de segundos informado
     IF pr_segproto >= 60 THEN
        -- Gera critica
        pr_dscritic := 'Campo de Segundos Invalido.';
        pr_nmdcampo := 'segproto';
        RAISE vr_erro;
     END IF;

     -- Verifica se o valor do protocolo foi preenchido
     IF pr_vlprotoc <= 0 THEN
        -- Gera critica
        pr_dscritic := 'Valor do protocolo nao pode ser 0,00.';
        pr_nmdcampo := 'vlprotoc';
        RAISE vr_erro;
     END IF;
     
     -- Transforma os campos de horas, minutios e segundo
     vr_tempotot := TO_CHAR(pr_segproto
                          +(pr_minproto*60)
                          +(pr_horproto*3600));

     -- Chamada de geracao de protocolo
     GENE0006.pc_gera_protocolo_md5(pr_cdcooper => pr_cdcooper
                                   ,pr_dtmvtolt => pr_dtmvtolx
                                   ,pr_hrtransa => vr_tempotot
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrdocmto => pr_nrdocmto
                                   ,pr_nrseqaut => pr_nrseqaut
                                   ,pr_vllanmto => pr_vlprotoc
                                   ,pr_nrdcaixa => 900
                                   ,pr_gravapro => FALSE
                                   ,pr_cdtippro => 0
                                   ,pr_dsinfor1 => NULL
                                   ,pr_dsinfor2 => NULL
                                   ,pr_dsinfor3 => NULL
                                   ,pr_dscedent => NULL
                                   ,pr_flgagend => FALSE
                                   ,pr_nrcpfope => 0
                                   ,pr_nrcpfpre => 0
                                   ,pr_nmprepos => 0
                                   ,pr_dsprotoc => vr_dsprotoc
                                   ,pr_dscritic => pr_dscritic
                                   ,pr_des_erro => pr_dscritic);

     -- Verifica se o protocolo esta correto
     IF vr_dsprotoc = pr_dsprotoc AND
        vr_dsprotoc IS NOT NULL THEN
        -- Retorna mensagem de sucesso
        pr_desmensg := 'Protocolo informado esta correto.';
     ELSE
        /* Verifica se eh uma conta migrada, e se for, valida novamente
        com a cooperativa e conta antiga, pois o comprovante tambem
        pode ter sido migrado */
        
        OPEN cr_craptco(pr_cdcooper
                       ,pr_nrdconta);
        FETCH cr_craptco INTO rw_craptco;
        -- Se nao encotra
        IF cr_craptco%NOTFOUND THEN
           -- Fecha Cursor
           CLOSE cr_craptco;
           pr_dscritic := 'Protocolo informado esta incorreto';
           RAISE vr_erro;
        END IF;
        -- Apenas Fecha Cursor
        CLOSE cr_craptco;

        -- Chamada de geracao de protocolo
        GENE0006.pc_gera_protocolo_md5(pr_cdcooper => rw_craptco.cdcopant
                                      ,pr_dtmvtolt => pr_dtmvtolx
                                      ,pr_hrtransa => vr_tempotot
                                      ,pr_nrdconta => rw_craptco.nrctaant
                                      ,pr_nrdocmto => pr_nrdocmto
                                      ,pr_nrseqaut => pr_nrseqaut
                                      ,pr_vllanmto => pr_vlprotoc
                                      ,pr_nrdcaixa => 900
                                      ,pr_gravapro => FALSE
                                      ,pr_cdtippro => 13 -- GPS SICREDI
                                      ,pr_dsinfor1 => NULL
                                      ,pr_dsinfor2 => NULL
                                      ,pr_dsinfor3 => NULL
                                      ,pr_dscedent => NULL
                                      ,pr_flgagend => FALSE
                                      ,pr_nrcpfope => 0
                                      ,pr_nrcpfpre => 0
                                      ,pr_nmprepos => 0
                                      ,pr_dsprotoc => vr_dsprotoc
                                      ,pr_dscritic => pr_dscritic
                                      ,pr_des_erro => pr_dscritic);

        -- Verifica se o protocolo esta correto
        IF vr_dsprotoc = pr_dsprotoc AND
           vr_dsprotoc IS NOT NULL THEN
           -- Retorna mensagem de sucesso
           pr_desmensg := 'Protocolo informado esta correto.';
        ELSE
           pr_desmensg := 'Protocolo informado esta incorreto.';
        END IF;
        
     END IF;
     
  EXCEPTION
     WHEN vr_erro THEN
        -- Retorno de Critica
        NULL;
     WHEN OTHERS THEN
        pr_nmdcampo := NULL;
        pr_desmensg := NULL;        
        pr_dscritic := 'Erro geral na rotina de validacao de protocolo. Erro: '||SQLERRM;
  END pc_valida_protocolo_md5;


  /* Procedure para gerar protocolos de segurança */
  PROCEDURE pc_gera_protocolo(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                             ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data movimento
                             ,pr_hrtransa IN craplcm.hrtransa%TYPE  --> Hora da transação
                             ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                             ,pr_nrdocmto IN craplcm.nrdocmto%TYPE  --> Número do documento
                             ,pr_nrseqaut IN crapaut.nrseqaut%TYPE  --> Número da sequencia
                             ,pr_vllanmto IN craplcm.vllanmto%TYPE  --> Valor lançamento
                             ,pr_nrdcaixa IN crapaut.nrdcaixa%TYPE  --> Número do caixa
                             ,pr_gravapro IN BOOLEAN                --> Controle de gravação
                             ,pr_cdtippro IN crappro.cdtippro%TYPE  --> Código de operação
                             ,pr_dsinfor1 IN VARCHAR2               --> Descrição 1
                             ,pr_dsinfor2 IN VARCHAR2               --> Descrição 2
                             ,pr_dsinfor3 IN VARCHAR2               --> Descrição 3
                             ,pr_dscedent IN VARCHAR2               --> Descritivo
                             ,pr_flgagend IN BOOLEAN                --> Controle de agenda
                             ,pr_nrcpfope IN NUMBER                 --> Número de operação
                             ,pr_nrcpfpre IN NUMBER                 --> Número pré operação
                             ,pr_nmprepos IN VARCHAR2               --> Nome
                             ,pr_dsprotoc OUT crappro.dsprotoc%TYPE --> Descrição do protocolo
                             ,pr_dscritic OUT VARCHAR2              --> Descrição crítica
                             ,pr_des_erro OUT VARCHAR2) IS          --> Descrição dos erros de processo
    -- ..........................................................................
    --
    --  Programa : pc_gera_protocolo   (Antigo: sistema/generico/procedures/bo_algoritmo_seguranca.p --> gera_protocolo)
    --  Sistema  : Processos Genéricos
    --  Sigla    : GENE
    --  Autor    : Petter Rafael - Supero
    --  Data     : Junho/2013.                   Ultima atualização: 13/03/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: ---
    --   Objetivo  : Recebe os parâmetros e gera um protocolo único em hexadecimal.
    --
    --   Observação: Os parâmetros são convertidos para números, multiplicados
    --               pela variável "aux_multipli" e depois somados.
    --               São adicionados alguns campos sem multiplicação para serem
    --               identificadores únicos. Após isto são transformados em
    --               hexadecimal de 2 em 2 caracteres.
    --               Quando o parâmetro par_gravapro for igual a YES/TRUE, será
    --               gravado um registro na tabela crappro.
    --
    --   Alteracoes: 01/06/2013 - Conversão Progress-Oracle (Petter - Supero).
    -- 
    --               06/07/2016 - Incluir log no exception da crappro (Lucas Ranghetti #468306)
    --
    --               29/09/2016 - Ajuste para gravar a data no formato DD/MM/RRRR ao gravar o protocolo
    --                            (Andrei - RKAM).
    --               
    --               05/10/2016 - Correcao no tratamento do LOG gerado "proc_agendamento". SD 535051
    --                            (Carlos Rafael Tanholi).      
    --                
    --               13/03/2017 - Retirado pr_dscritic da exception vr_exc_erro pois é
    --                            um erro tratado (Lucas Ranghetti #624628)
    -- .............................................................................
  BEGIN
    DECLARE
      vr_dsprotoc  crappro.dsprotoc%TYPE; --> Descrição protocolo
      vr_flgtrans  BOOLEAN;               --> Controle das transações
      vr_flgagend  NUMBER;                --> Conversão de flag booleano
      
      -- Erros 
      vr_dscritic  VARCHAR2(5000);        --> Descrição do erro
      vr_des_erro  VARCHAR2(3);           --> Retorno do processo "OK" / "NOK"
      vr_exc_erro  EXCEPTION;             --> Controle de erros

    BEGIN
      -- Montar o protocolo, sempre no formato novo, e utilizar a sequence
      GENE0006.pc_monta_protocolo(pr_cdcooper => pr_cdcooper   --> Código da cooperativa
                                 ,pr_dtmvtolt => pr_dtmvtolt   --> Data movimento
                                 ,pr_hrtransa => pr_hrtransa   --> Hora da transação
                                 ,pr_nrdconta => pr_nrdconta   --> Número da conta
                                 ,pr_nrdocmto => pr_nrdocmto   --> Número do documento
                                 ,pr_nrseqaut => pr_nrseqaut   --> Número da sequencia
                                 ,pr_vllanmto => pr_vllanmto   --> Valor lançamento
                                 ,pr_nrdcaixa => pr_nrdcaixa   --> Número do caixa
                                 ,pr_tipo_protocolo => 2       --> Tipo de Protocolo (1-Velho/2-Novo)
                                 ,pr_utiliza_seq => 1          --> Utilizar Sequence para gerar o protocolo novo (0-Nao / 1-Sim)
                                 ,pr_dsprotoc => vr_dsprotoc   --> Descrição do protocolo
                                 ,pr_dscritic => vr_dscritic   --> Descrição crítica
                                 ,pr_des_erro => vr_des_erro); --> Descrição do processo "OK" / "NOK"

      -- Verificar se ocorreu erro na geração do protocolo
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
      
      -- Devolver o protocolo que geramos
      pr_dsprotoc := vr_dsprotoc;

      -- Verifica se irá criar registro
      IF pr_gravapro THEN
        vr_flgtrans := FALSE;

        -- Bloco de controle para criar registros
        BEGIN
          SAVEPOINT sem_dados;

          -- Converte valores para insert
          IF pr_flgagend THEN
            vr_flgagend := 1;
          ELSE
            vr_flgagend := 0;
          END IF;

          -- Insere dados da transação
          INSERT INTO crappro(cdcooper
                             ,cdtippro
                             ,dscedent
                             ,dsinform##1
                             ,dsinform##2
                             ,dsinform##3
                             ,dsprotoc
                             ,dtmvtolt
                             ,dttransa
                             ,flgagend
                             ,hrautent
                             ,nrdconta
                             ,nrdocmto
                             ,nrseqaut
                             ,vldocmto
                             ,nrcpfope
                             ,nrcpfpre
                             ,nmprepos)
            VALUES(pr_cdcooper
                  ,nvl(pr_cdtippro,0)
                  ,nvl(upper(substr(pr_dscedent,1,50)),' ')
                  ,nvl(pr_dsinfor1,' ')
                  ,nvl(pr_dsinfor2,' ')
                  ,nvl(pr_dsinfor3,' ')
                  ,nvl(pr_dsprotoc,' ')
                  ,pr_dtmvtolt
                  ,SYSDATE
                  ,vr_flgagend
                  ,pr_hrtransa
                  ,nvl(pr_nrdconta,0)
                  ,nvl(pr_nrdocmto,0)
                  ,nvl(pr_nrseqaut,0)
                  ,nvl(pr_vllanmto,0)
                  ,nvl(pr_nrcpfope,0)
                  ,nvl(pr_nrcpfpre,0)
                  ,nvl(pr_nmprepos,' '));
                                     
          -- Indicador que realizou a transação
          vr_flgtrans := TRUE;
        EXCEPTION
          WHEN OTHERS THEN
            -- Gerar no log o erro na criacao do protocolo
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 3 
                                      ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') || ' - ' ||
                                                          'GENE0006.pc_gera_protocolo --> ' ||
                                                          'erro ao gravar crappro' ||
                                                          ' cdcooper: ' || pr_cdcooper ||
                                                          ' cdtippro: ' || pr_cdtippro ||
                                                          ' dscedent: ' || pr_dscedent ||
                                                          ' dsinform##1: ' || pr_dsinfor1 ||
                                                          ' dsinform##2: ' || pr_dsinfor2 ||
                                                          ' dsinform##3: ' || pr_dsinfor3 ||
                                                          ' dsprotoc: ' || pr_dsprotoc ||
                                                          ' dtmvtolt: ' || pr_dtmvtolt ||
                                                          ' dttransa: ' || SYSDATE ||
                                                          ' flgagend: ' || vr_flgagend ||
                                                          ' hrautent: ' || pr_hrtransa ||
                                                          ' nrdconta: ' || pr_nrdconta ||
                                                          ' nrdocmto: ' || pr_nrdocmto ||
                                                          ' nrseqaut: ' || pr_nrseqaut ||
                                                          ' vldocmto: ' || pr_vllanmto ||
                                                          ' nrcpfope: ' || pr_nrcpfope ||
                                                          ' dsprotoc: ' || pr_dsprotoc ||
                                                          ' nrcpfpre: ' || pr_nrcpfpre ||
                                                          ' nmprepos: ' || pr_nmprepos || ' - ' || sqlerrm
                                      ,pr_nmarqlog     => 'proc_agendamento'
                                      ,pr_flnovlog     => 'N');
          
            -- Volta os dados sem realizar o insert
            ROLLBACK TO SAVEPOINT sem_dados;
        END;
        
        -- Verifica se ocorreu a transação
        IF NOT vr_flgtrans THEN          
          vr_dscritic := 'Nao foi possivel gerar o protocolo. Tente novamente.';
          RAISE vr_exc_erro;
        END IF;
        
      END IF;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := vr_dscritic;
        pr_des_erro := 'NOK';
      WHEN OTHERS THEN
        pr_dscritic := 'Erro em GENE0006.pc_gera_protocolo: ' || SQLERRM;
        pr_des_erro := 'NOK';
    END;
  END pc_gera_protocolo;


  /* Procedure para gerar protocolos de segurança */
  PROCEDURE pc_gera_protocolo_car(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data movimento
                                 ,pr_hrtransa IN craplcm.hrtransa%TYPE  --> Hora da transação
                                 ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                 ,pr_nrdocmto IN craplcm.nrdocmto%TYPE  --> Número do documento
                                 ,pr_nrseqaut IN crapaut.nrseqaut%TYPE  --> Número da sequencia
                                 ,pr_vllanmto IN craplcm.vllanmto%TYPE  --> Valor lançamento
                                 ,pr_nrdcaixa IN crapaut.nrdcaixa%TYPE  --> Número do caixa
                                 ,pr_gravapro IN INTEGER                --> Controle de gravação (0-Nao/1-Sim)
                                 ,pr_cdtippro IN crappro.cdtippro%TYPE  --> Código de operação
                                 ,pr_dsinfor1 IN VARCHAR2               --> Descrição 1
                                 ,pr_dsinfor2 IN VARCHAR2               --> Descrição 2
                                 ,pr_dsinfor3 IN VARCHAR2               --> Descrição 3
                                 ,pr_dscedent IN VARCHAR2               --> Descritivo
                                 ,pr_flgagend IN INTEGER                --> Controle de agenda (0-Nao/1-Sim)
                                 ,pr_nrcpfope IN NUMBER                 --> Número de operação
                                 ,pr_nrcpfpre IN NUMBER                 --> Número pré operação
                                 ,pr_nmprepos IN VARCHAR2               --> Nome
                                 ,pr_dsprotoc OUT crappro.dsprotoc%TYPE --> Descrição do protocolo
                                 ,pr_dscritic OUT VARCHAR2              --> Descrição crítica
                                 ,pr_des_erro OUT VARCHAR2) IS          --> Descrição dos erros de processo
    -- ..........................................................................
    --
    --  Programa : pc_gera_protocolo_car
    --  Sistema  : Processos Genéricos
    --  Sigla    : GENE
    --  Autor    : Douglas Quisinski
    --  Data     : Maio/2017                       Ultima atualização: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: ---
    --   Objetivo  : Possibilitar a chamada da procedures pc_gera_protocolo pelo Progress
    --
    --   Alteracoes: 
    -- .............................................................................
  BEGIN
    DECLARE
      vr_gravapro BOOLEAN; --> Controle de gravação (0-Nao/1-Sim)
      vr_flgagend BOOLEAN; --> Controle de agenda (0-Nao/1-Sim)

    BEGIN
      vr_gravapro := sys.diutil.int_to_bool(pr_gravapro);
      vr_flgagend := sys.diutil.int_to_bool(pr_flgagend);

      GENE0006.pc_gera_protocolo(pr_cdcooper => pr_cdcooper   --> Código da cooperativa
                                ,pr_dtmvtolt => pr_dtmvtolt   --> Data movimento
                                ,pr_hrtransa => pr_hrtransa   --> Hora da transação
                                ,pr_nrdconta => pr_nrdconta   --> Número da conta
                                ,pr_nrdocmto => pr_nrdocmto   --> Número do documento
                                ,pr_nrseqaut => pr_nrseqaut   --> Número da sequencia
                                ,pr_vllanmto => pr_vllanmto   --> Valor lançamento
                                ,pr_nrdcaixa => pr_nrdcaixa   --> Número do caixa
                                ,pr_gravapro => vr_gravapro   --> Controle de gravação
                                ,pr_cdtippro => pr_cdtippro   --> Código de operação
                                ,pr_dsinfor1 => pr_dsinfor1   --> Descrição 1
                                ,pr_dsinfor2 => pr_dsinfor2   --> Descrição 2
                                ,pr_dsinfor3 => pr_dsinfor3   --> Descrição 3
                                ,pr_dscedent => pr_dscedent   --> Descritivo
                                ,pr_flgagend => vr_flgagend   --> Controle de agenda
                                ,pr_nrcpfope => pr_nrcpfope   --> Número de operação
                                ,pr_nrcpfpre => pr_nrcpfpre   --> Número pré operação
                                ,pr_nmprepos => pr_nmprepos   --> Nome
                                ,pr_dsprotoc => pr_dsprotoc   --> Descrição do protocolo
                                ,pr_dscritic => pr_dscritic   --> Descrição crítica
                                ,pr_des_erro => pr_des_erro); --> Descrição dos erros de processo
      
                                
      -- O progress aguarda um retorno
      IF TRIM(pr_des_erro) IS NULL THEN
        -- Se chegou ate aqui, foi executado com sucesso
        pr_des_erro := 'OK';
      END IF;
      
    EXCEPTION
      WHEN OTHERS THEN
        pr_dscritic := 'Erro em GENE0006.pc_gera_protocolo_car: ' || SQLERRM;
        pr_des_erro := 'NOK';
    END;
  END pc_gera_protocolo_car;

  /* Procedure para gerar protocolos de segurança com criptografia MD5 */
  PROCEDURE pc_gera_protocolo_md5(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data movimento
                                 ,pr_hrtransa IN craplcm.hrtransa%TYPE  --> Hora da transação
                                 ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                 ,pr_nrdocmto IN craplcm.nrdocmto%TYPE  --> Número do documento
                                 ,pr_nrseqaut IN crapaut.nrseqaut%TYPE  --> Número da sequencia
                                 ,pr_vllanmto IN craplcm.vllanmto%TYPE  --> Valor lançamento
                                 ,pr_nrdcaixa IN crapaut.nrdcaixa%TYPE  --> Número do caixa
                                 ,pr_gravapro IN BOOLEAN                --> Controle de gravação
                                 ,pr_cdtippro IN crappro.cdtippro%TYPE  --> Código de operação
                                 ,pr_dsinfor1 IN VARCHAR2               --> Descrição 1
                                 ,pr_dsinfor2 IN VARCHAR2               --> Descrição 2
                                 ,pr_dsinfor3 IN VARCHAR2               --> Descrição 3
                                 ,pr_dscedent IN VARCHAR2               --> Descritivo
                                 ,pr_flgagend IN BOOLEAN                --> Controle de agenda
                                 ,pr_nrcpfope IN NUMBER                 --> Número de operação
                                 ,pr_nrcpfpre IN NUMBER                 --> Número pré operação
                                 ,pr_nmprepos IN VARCHAR2               --> Nome
                                 ,pr_dsprotoc OUT crappro.dsprotoc%TYPE --> Descrição do protocolo
                                 ,pr_dscritic OUT VARCHAR2              --> Descrição crítica
                                 ,pr_des_erro OUT VARCHAR2) IS          --> Descrição dos erros de processo
    -- ..........................................................................
    --
    --  Programa : pc_gera_protocolo_md5
    --  Sistema  : Processos Genéricos
    --  Sigla    : GENE
    --  Autor    : Carlos Rafael Tanholi
    --  Data     : Setembro/2015.                   Ultima atualização: 05/10/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: ---
    --   Objetivo  : 
    --
    --   Observação: 
    --
    --   Alteracoes:     05/10/2016 - Correcao no tratamento do LOG gerado "proc_agendamento". 
    --                                SD 535051 (Carlos Rafael Tanholi).
    --
    -- .............................................................................
  BEGIN
    DECLARE
      vr_multipli  CONSTANT NUMBER := 4;  --> Fator multiplicador
      vr_nrprotoc  NUMBER;                --> Número protocolo
      vr_dsprotoc  crappro.dsprotoc%TYPE; --> Descrição protocolo
      vr_flgtrans  BOOLEAN;               --> Controle das transações
      vr_contador  PLS_INTEGER;           --> Contador de registros
      vr_flgagend  NUMBER;                --> Conversão de flag booleano
      vr_exc_erro  EXCEPTION;             --> Controle de erros

    BEGIN
      -- Conta
      vr_nrprotoc := nvl(vr_nrprotoc,0) + (pr_nrdconta * vr_multipli);
      -- Documento
      vr_nrprotoc := nvl(vr_nrprotoc,0) + (pr_nrdocmto * vr_multipli);
      -- Autenticação
      IF pr_nrseqaut > 0 THEN
        vr_nrprotoc := nvl(vr_nrprotoc,0) + (pr_nrseqaut * vr_multipli);
      END IF;
      -- Valor
      vr_nrprotoc := nvl(vr_nrprotoc,0) + (pr_vllanmto * 100 * vr_multipli);
      -- Caixa
      vr_nrprotoc := nvl(vr_nrprotoc,0) + (pr_nrdcaixa * vr_multipli);
      -- Cooperativa / Data / Horario
      vr_dsprotoc := to_char(vr_nrprotoc) ||
                     gene0002.fn_mask(pr_cdcooper, '999') ||
                     to_char(pr_dtmvtolt, 'DDMMYYYY') ||
                     gene0002.fn_mask(pr_hrtransa, '99999');
                     
      -- gera o hash MD5 
      vr_dsprotoc := rawtohex(DBMS_CRYPTO.Hash (UTL_I18N.STRING_TO_RAW (vr_dsprotoc, 'AL32UTF8'),2));                     
                     
      vr_contador := 1;
      WHILE vr_contador < length(vr_dsprotoc) LOOP
        -- Verifica se é o quarto caracter por iteração
        pr_dsprotoc := pr_dsprotoc || TRIM(substr(vr_dsprotoc, vr_contador, 4));

        IF (vr_contador + 4) < length(vr_dsprotoc) THEN
          pr_dsprotoc:= pr_dsprotoc || '.';
        END IF;
        --Incrementar iteracao em 4
        vr_contador := vr_contador + 4;
      END LOOP;
                                         

      -- Verifica se irá criar registro
      IF pr_gravapro THEN
        vr_flgtrans := FALSE;

        -- Bloco de controle para criar registros
        BEGIN
          SAVEPOINT sem_dados;

          -- Converte valores para insert
          IF pr_flgagend THEN
            vr_flgagend := 1;
          ELSE
            vr_flgagend := 0;
          END IF;

          -- Insere dados da transação
          INSERT INTO crappro(cdcooper
                             ,cdtippro
                             ,dscedent
                             ,dsinform##1
                             ,dsinform##2
                             ,dsinform##3
                             ,dsprotoc
                             ,dtmvtolt
                             ,dttransa
                             ,flgagend
                             ,hrautent
                             ,nrdconta
                             ,nrdocmto
                             ,nrseqaut
                             ,vldocmto
                             ,nrcpfope
                             ,nrcpfpre
                             ,nmprepos)
            VALUES(pr_cdcooper
                  ,nvl(pr_cdtippro,0)
                  ,nvl(upper(substr(pr_dscedent,1,50)),' ')
                  ,nvl(pr_dsinfor1,' ')
                  ,nvl(pr_dsinfor2,' ')
                  ,nvl(pr_dsinfor3,' ')
                  ,nvl(pr_dsprotoc,' ')
                  ,pr_dtmvtolt
                  ,SYSDATE
                  ,vr_flgagend
                  ,pr_hrtransa
                  ,nvl(pr_nrdconta,0)
                  ,nvl(pr_nrdocmto,0)
                  ,nvl(pr_nrseqaut,0)
                  ,nvl(pr_vllanmto,0)
                  ,nvl(pr_nrcpfope,0)
                  ,nvl(pr_nrcpfpre,0)
                  ,nvl(pr_nmprepos,' '));
                                     
          -- Indicador que realizou a transação
          vr_flgtrans := TRUE;
        EXCEPTION
          WHEN OTHERS THEN
            -- Volta os dados sem realizar o insert
            ROLLBACK TO SAVEPOINT sem_dados;
        END;

        -- Verifica se ocorreu a transação
        IF NOT vr_flgtrans THEN
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 3 
                                    ,pr_des_log      => to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') || ' - ' ||
                                                        'GENE0006.pc_gera_protocolo_md5 --> ' ||
                                                        'erro ao gravar crappro' ||
                                                        ' cdcooper: ' || pr_cdcooper ||
                                                        ' cdtippro: ' || pr_cdtippro ||
                                                        ' dscedent: ' || pr_dscedent ||
                                                        ' dsinform##1: ' || pr_dsinfor1 ||
                                                        ' dsinform##2: ' || pr_dsinfor2 ||
                                                        ' dsinform##3: ' || pr_dsinfor3 ||
                                                        ' dsprotoc: ' || pr_dsprotoc ||
                                                        ' dtmvtolt: ' || pr_dtmvtolt ||
                                                        ' dttransa: ' || SYSDATE ||
                                                        ' flgagend: ' || vr_flgagend ||
                                                        ' hrautent: ' || pr_hrtransa ||
                                                        ' nrdconta: ' || pr_nrdconta ||
                                                        ' nrdocmto: ' || pr_nrdocmto ||
                                                        ' nrseqaut: ' || pr_nrseqaut ||
                                                        ' vldocmto: ' || pr_vllanmto ||
                                                        ' nrcpfope: ' || pr_nrcpfope ||
                                                        ' dsprotoc: ' || pr_dsprotoc ||
                                                        ' nrcpfpre: ' || pr_nrcpfpre ||
                                                        ' nmprepos: ' || pr_nmprepos || ' - ' || sqlerrm
                                    ,pr_nmarqlog     => 'proc_agendamento'
                                    ,pr_flnovlog     => 'N');

          pr_dscritic := 'Nao foi possivel gerar o protocolo. Tente novamente.';
          pr_des_erro := 'NOK';
          RAISE vr_exc_erro;
        END IF;
      END IF;

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_dscritic := 'Erro em GENE0006.pc_gera_protocolo_md5: ' || pr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro em GENE0006.pc_gera_protocolo_md5: ' || SQLERRM;
        pr_des_erro := 'NOK';
    END;
  END pc_gera_protocolo_md5;

  

  /* Listar protocolos gerados podendo ser filtrado por vários tipos */
  PROCEDURE pc_lista_protocolos_por_tipos(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                         ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                         ,pr_dtinipro IN crappro.dtmvtolt%TYPE  --> Data inicial do protocolo
                                         ,pr_dtfimpro IN crappro.dtmvtolt%TYPE  --> Data final do protocolo
                                         ,pr_dsprotoc IN VARCHAR2 DEFAULT NULL  --> Lista de protocolos a serem buscados
                                         ,pr_iniconta IN NUMBER                 --> Início da conta
                                         ,pr_nrregist IN NUMBER                 --> Número de registros
                                         ,pr_cdtippro IN VARCHAR2               --> Código protocolo
                                         ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAS
                                         ,pr_dstransa OUT VARCHAR2              --> Descrição da transação
                                         ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                                         ,pr_qttotreg OUT NUMBER                --> Quantidade de registros
                                         ,pr_protocolo  OUT typ_tab_protocolo   --> PL Table de registros
                                         ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
                               
    -- ..........................................................................
    --
    --  Sistema  : Processos Genéricos
    --  Sigla    : GENE
    --  Autor    : Ricardo Linhares
    --  Data     : Dezembro/2017.                   Ultima atualização: 
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: ---
    --  Objetivo  : Gera listagem de protocolos podendo filtrar por vários Tipos Protocolos.
    --
    --  Alteração : 03/01/2017 - Incluido tratativas para arrecadação de FGTS.
    --                           PRJ406-FGTS(Odirlei-AMcom) 
    --  Alteração : 13/12/2018 - Incluido tratativas para os novos protocolos do 25 ao 31
    --                           PJ470 - Rubens Lima (Mouts)
    -- .............................................................................
  BEGIN
    DECLARE
      vr_exc_erro   EXCEPTION;                   --> Controle de execução
      vr_dtinipro   DATE;                        --> Auxiliar para data inicial do protocolo
      vr_dtfimpro   DATE;                        --> Auxiliar para data final do protocolo
	  vr_exc_iter   EXCEPTION;                   --> Controle de iteração
      vr_index      NUMBER;                      --> Indexador para PL Table
      vr_nmoperad   crapopi.nmoperad%TYPE;       --> Nome operador
      vr_cdcritic   crapcri.cdcritic%TYPE := 0;  --> Código da crítica
      vr_dscritic   crapcri.dscritic%TYPE := ''; --> Descrição da crítica

      -- Buscar dados da cooperativa
      CURSOR cr_crapcop(pr_cdcooper IN crappro.cdcooper%TYPE) IS   --> Código da cooperativa
        SELECT cp.cdbcoctl
              ,cp.cdagectl
              ,cp.cdagesic
              ,cp.nmrescop
              ,cp.nmextcop
              ,cp.nrsacbcb
              ,cp.nrouvbcb
        FROM crapcop cp
        WHERE cp.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      rw_crapcop_central cr_crapcop%ROWTYPE;

      -- Busca dados do protocolo
      CURSOR cr_crappro(pr_cdcooper IN crappro.cdcooper%TYPE      --> Código da cooperativa
                       ,pr_nrdconta IN crappro.nrdconta%TYPE      --> Número da conta
                       ,pr_dtfimpro IN crappro.dtmvtolt%TYPE      --> Data final do protocolo
                       ,pr_dtinipro IN crappro.dttransa%TYPE      --> Data inicial do protocolo
                       ,pr_dsprotoc IN VARCHAR2                   --> Lista de protocolos a serem buscados
                       ,pr_cdtippro IN VARCHAR2) IS  --> Tipo do protocolo
        --Busca por datas
        SELECT co.cdtippro
              ,co.nrcpfope
              ,co.dtmvtolt
              ,co.dttransa
              ,co.hrautent
              ,co.vldocmto
              ,co.nrdocmto
              ,co.nrseqaut
              ,co.dsinform##1
              ,co.dsinform##2
              ,co.dsinform##3
              ,co.dsprotoc
              ,co.flgagend
              ,co.nmprepos
              ,co.nrcpfpre
              ,co.dscedent
              ,DECODE(co.flgativo,1,'ATIVO','INATIVO') dsativo -- Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts
         FROM crappro co
        WHERE co.cdcooper  = pr_cdcooper
          AND co.nrdconta  = pr_nrdconta
          AND TRIM(pr_dsprotoc) IS NULL
          AND trunc(co.dttransa) >= pr_dtinipro
          AND trunc(co.dttransa) <= pr_dtfimpro
          AND (pr_cdtippro = '0' OR co.cdtippro IN(SELECT regexp_substr(pr_cdtippro, '[^;]+', 1, LEVEL)
                                                     FROM dual
                                                  CONNECT BY LEVEL <= regexp_count(pr_cdtippro, '[^;]+') ))
        UNION ALL
        --Busca por protocolos específicos
        SELECT co.cdtippro
              ,co.nrcpfope
              ,co.dtmvtolt
              ,co.dttransa
              ,co.hrautent
              ,co.vldocmto
              ,co.nrdocmto
              ,co.nrseqaut
              ,co.dsinform##1
              ,co.dsinform##2
              ,co.dsinform##3
              ,co.dsprotoc
              ,co.flgagend
              ,co.nmprepos
              ,co.nrcpfpre
              ,co.dscedent
              ,DECODE(co.flgativo,1,'ATIVO','INATIVO') dsativo -- Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts
         FROM crappro co
        WHERE co.cdcooper  = pr_cdcooper
          AND co.nrdconta  = pr_nrdconta
          AND TRIM(pr_dsprotoc) IS NOT NULL
          AND co.dsprotoc IN (SELECT regexp_substr(pr_dsprotoc, '[^;]+', 1, LEVEL) item
                                FROM dual
                             CONNECT BY LEVEL <= regexp_count(pr_dsprotoc, '[^;]+'))
        ORDER BY dttransa DESC
                ,hrautent DESC;

      -- Busca dados de operação
      CURSOR cr_crapopi(pr_cdcooper IN crapopi.cdcooper%TYPE      --> Código da cooperativa
                       ,pr_nrdconta IN crapopi.nrdconta%TYPE      --> Número da conta
                       ,pr_nrcpfope IN crappro.nrcpfope%TYPE) IS  --> Número da operação
        SELECT ci.nmoperad
        FROM crapopi ci
        WHERE ci.cdcooper = pr_cdcooper
          AND ci.nrdconta = pr_nrdconta
          AND ci.nrcpfope = pr_nrcpfope
          AND rownum = 1;
      rw_crapopi cr_crapopi%ROWTYPE;

      -- Cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    BEGIN
      -- Validar dados da cooperativa
      OPEN cr_crapcop(pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;

      -- Verifica se foi encontrado registro na tupla
      IF cr_crapcop%NOTFOUND THEN
        CLOSE cr_crapcop;
        pr_des_erro := 'NOK';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapcop;
      END IF;

      -- Buscar dados da cooperativa central
      OPEN cr_crapcop(3);
      FETCH cr_crapcop INTO rw_crapcop_central;

      -- Verifica se foi encontrado registro na tupla
      IF cr_crapcop%NOTFOUND THEN
        CLOSE cr_crapcop;
        pr_des_erro := 'NOK';
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapcop;
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

      -- Assimilar valores de saída
      vr_dtinipro := pr_dtinipro;
      vr_dtfimpro := pr_dtfimpro;
      pr_dstransa := 'Listagem de Protocolos';
      pr_qttotreg := 0;

      -- Valida data inicial do protocolo
      IF vr_dtinipro IS NULL THEN
        vr_dtinipro := to_date('15/06/2007', 'DD/MM/RRRR');
      END IF;

      -- Valida data final do protocolo
      IF vr_dtfimpro IS NULL THEN
        vr_dtfimpro := SYSDATE;
      END IF;

      -- Buscar dados dos protocolos
      FOR rw_crappro IN cr_crappro(pr_cdcooper => pr_cdcooper
                                  ,pr_nrdconta => pr_nrdconta
                                  ,pr_dtfimpro => vr_dtfimpro
                                  ,pr_dtinipro => vr_dtinipro
                                  ,pr_dsprotoc => pr_dsprotoc
                                  ,pr_cdtippro => pr_cdtippro) LOOP

        -- Bloco para iteração (escape)
        BEGIN

        -- Nao carregar Protocolo pagamento fatura caso seja o dia de geracao, devido o pagamento
        -- ainda poder ser estornado.
        IF rw_crappro.cdtippro = 15  AND rw_crappro.dtmvtolt = rw_crapdat.dtmvtolt THEN 
           CONTINUE;
        END IF;
   
        -- Valida protocolo Favorecido
        IF pr_cdtippro <> TO_CHAR(8) AND rw_crappro.cdtippro = 8 THEN
           RAISE vr_exc_iter;
        END IF;

        -- Incrementa quantidade de registros
        pr_qttotreg := pr_qttotreg + 1; 

        -- Valida condições sobre o registro
        IF pr_nrregist > 0 AND (pr_qttotreg <= pr_iniconta OR pr_nrregist < (pr_qttotreg - pr_iniconta)) THEN
           RAISE vr_exc_iter;
        END IF;

        vr_nmoperad := '';

        -- Busca dados sobre operação
        OPEN cr_crapopi(pr_cdcooper, pr_nrdconta, rw_crappro.nrcpfope);
        FETCH cr_crapopi INTO rw_crapopi;

        -- Verifica se retornou registro na tupla
        IF cr_crapopi%FOUND THEN
          CLOSE cr_crapopi;
          vr_nmoperad := rw_crapopi.nmoperad;
        ELSE
          CLOSE cr_crapopi;
        END IF;

        -- Criar indice para registro
        vr_index := pr_protocolo.count + 1;

        -- Grava dados do registro
        pr_protocolo(vr_index).cdtippro := rw_crappro.cdtippro;
        pr_protocolo(vr_index).dtmvtolt := rw_crappro.dtmvtolt;
        pr_protocolo(vr_index).dttransa := rw_crappro.dttransa;
        pr_protocolo(vr_index).hrautent := rw_crappro.hrautent;
        pr_protocolo(vr_index).vldocmto := rw_crappro.vldocmto;
        pr_protocolo(vr_index).nrdocmto := rw_crappro.nrdocmto;
        pr_protocolo(vr_index).nrseqaut := rw_crappro.nrseqaut;
        pr_protocolo(vr_index).dsinform##1 := rw_crappro.dsinform##1;
        pr_protocolo(vr_index).dsinform##2 := rw_crappro.dsinform##2;
        pr_protocolo(vr_index).dsinform##3 := rw_crappro.dsinform##3;
        pr_protocolo(vr_index).dsprotoc := rw_crappro.dsprotoc;
        pr_protocolo(vr_index).flgagend := rw_crappro.flgagend;
        pr_protocolo(vr_index).nmprepos := rw_crappro.nmprepos;
        pr_protocolo(vr_index).nrcpfpre := rw_crappro.nrcpfpre;
        pr_protocolo(vr_index).nmoperad := vr_nmoperad;
        pr_protocolo(vr_index).nrcpfope := rw_crappro.nrcpfope;
        pr_protocolo(vr_index).cdagesic := rw_crapcop.cdagesic;

        IF (rw_crappro.cdtippro = 1 AND pr_cdorigem = 3) OR rw_crappro.cdtippro IN (2,5,6,9,10,11,12,13,15,16,17,18,19,20,23,24) THEN
          pr_protocolo(vr_index).cdbcoctl := rw_crapcop.cdbcoctl;
          pr_protocolo(vr_index).cdagectl := rw_crapcop.cdagectl;
          pr_protocolo(vr_index).nmrescop := rw_crapcop.nmrescop;
            
          --> Dados da cooperativa central
          pr_protocolo(vr_index).nmextcop_central := rw_crapcop_central.nmextcop;
          pr_protocolo(vr_index).nmrescop_central := rw_crapcop_central.nmrescop;
                        
          --> Sac/Ouvidoria Bancoob
          pr_protocolo(vr_index).nrtelsac := rw_crapcop.nrsacbcb;
          pr_protocolo(vr_index).nrtelouv := rw_crapcop.nrouvbcb;
        END IF;
		  
        IF rw_crappro.cdtippro IN (20) THEN
           pr_protocolo(vr_index).nrcelular   := TRIM(gene0002.fn_busca_entrada(3, rw_crappro.dsinform##2, '#'));
           pr_protocolo(vr_index).nmoperadora := TRIM(gene0002.fn_busca_entrada(2, rw_crappro.dsinform##2, '#'));                      
        END IF;

        -- Valida TAA
        IF pr_cdorigem = 4 THEN
          -- Para transferência
          IF pr_protocolo(vr_index).cdtippro = 1 THEN
            pr_protocolo(vr_index).dscedent := substr(gene0002.fn_busca_entrada(2, rw_crappro.dsinform##2, '#'), 19);
          ELSE
            -- Verifica campo da tabela
            IF TRIM(rw_crappro.dscedent) IS NULL THEN
              pr_protocolo(vr_index).dscedent := 'PAGAMENTO TAA';
            ELSE
              pr_protocolo(vr_index).dscedent := rw_crappro.dscedent;
            END IF;
          END IF;
        ELSE
          pr_protocolo(vr_index).dscedent := rw_crappro.dscedent;
        END IF;
          
        -- Tratar para exibir o cedente quando for pagamento, porém a informação do cedente não existe no protocolo
        IF rw_crappro.cdtippro IN (2,6,15) THEN
          -- Verifica se existe o nome do cedente
          IF TRIM(rw_crappro.dscedent) IS NULL THEN
            -- Se nao possui nome de cedente, validar qual é o canal 
            IF gene0002.fn_busca_entrada(3, rw_crappro.dsinform##3, '#') LIKE '%TAA%' THEN
              -- Pagamento feito no ATM
              pr_protocolo(vr_index).dscedent := 'PAGAMENTO TAA';
            ELSE 
              -- Outro pagamento, onde nao existe o nome do cedente
              pr_protocolo(vr_index).dscedent := 'PAGAMENTO';
            END IF;
          ELSE
            pr_protocolo(vr_index).dscedent := rw_crappro.dscedent;
          END IF;
        --PJ470 - Rubens Lima (Mouts) - 13/12/2018
        ELSIF rw_crappro.cdtippro IN (25 -- Rescisão de Lim. Créd. (Termo)
                                     ,26 -- Solicitação de Portab. Créd. (Termo)
                                     ,27 -- Limite de Desc. Chq. (Contrato)
                                     ,28 -- Limite de Desc. Tit. (Contrato)
                                     ,29 -- Limite de Crédito (Contrato)
                                     ,30 -- Solicitação de Sustação de Chq.
                                     ,31) -- Sol.Canc.de Folha/Tal.de Chq. (Termo)
        THEN
          pr_protocolo(vr_index).dtinclusao := TRIM(gene0002.fn_busca_entrada(2,rw_crappro.dsinform##2, '#'));
          pr_protocolo(vr_index).hrinclusao := TRIM(gene0002.fn_busca_entrada(3,rw_crappro.dsinform##2, '#'));
          pr_protocolo(vr_index).dsfrase    := TRIM(gene0002.fn_busca_entrada(1,rw_crappro.dsinform##3, '#'));
          pr_protocolo(vr_index).dsativo    := rw_crappro.dsativo; -- Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts
          --
          IF rw_crappro.cdtippro IN (30 -- Solicitação de Sustação de Chq.
                                    ,31) -- Sol.Canc.de Folha/Tal.de Chq. (Termo)
          THEN
            IF rw_crappro.cdtippro = 30 THEN
              pr_protocolo(vr_index).dsoperacao := TRIM(gene0002.fn_busca_entrada(4,rw_crappro.dsinform##2, '#'));
            ELSE
              pr_protocolo(vr_index).dsoperacao := '-';
        END IF;
            pr_protocolo(vr_index).cdbanco    := TRIM(gene0002.fn_busca_entrada(5,rw_crappro.dsinform##2, '#'));
            pr_protocolo(vr_index).cdagencia  := TRIM(gene0002.fn_busca_entrada(6,rw_crappro.dsinform##2, '#'));
            pr_protocolo(vr_index).cdconta    := TRIM(gene0002.fn_busca_entrada(7,rw_crappro.dsinform##2, '#'));
            pr_protocolo(vr_index).nrcheque_i := TRIM(gene0002.fn_busca_entrada(8,rw_crappro.dsinform##2, '#'));
            pr_protocolo(vr_index).nrcheque_f := TRIM(gene0002.fn_busca_entrada(9,rw_crappro.dsinform##2, '#'));
          ELSE
            pr_protocolo(vr_index).cdbanco    := '-';
            pr_protocolo(vr_index).cdagencia  := '-';
            pr_protocolo(vr_index).cdconta    := '-';
            pr_protocolo(vr_index).nrcheque_i := '-';
            pr_protocolo(vr_index).nrcheque_f := '-';
          END IF;
        END IF;       
          -- Identificar a origem do comprovante
          -- Devido as informações presentes na crappro, será possivel apenas diferenciar em TAA e não TAA
          -- Quando não for TAA será devolvido como INTERNET
          -- Caso seja necessario diferenciar a origem, deverá ser revisto a criação do protocolo
          IF gene0002.fn_busca_entrada(3, rw_crappro.dsinform##3, '#') LIKE '%TAA%' THEN
            pr_protocolo(vr_index).dsorigem := 'TAA';
          ELSE 
            pr_protocolo(vr_index).dsorigem := 'INTERNET';
          END IF;
          
          -- Desmontar a lista de dominio dos protocolos
          -- Essa lista é referente ao TIPO DE COMPROVANTE
          CASE
            -- 2 = Pagamento (Tit/Cnv) / 6 = Pagamento (Tit/Cnv) no TAA
            WHEN pr_protocolo(vr_index).cdtippro IN ( 2, 6 ) THEN
              -- Verificar se é comprovante de boleto ou convenio
              IF UPPER(pr_protocolo(vr_index).dsinform##2) LIKE '%BANCO%'  THEN
                -- Boleto
                pr_protocolo(vr_index).idlstdom := 1;
              ELSIF UPPER(pr_protocolo(vr_index).dsinform##2) LIKE '%CONVENIO%'  THEN
                -- Convênio
                pr_protocolo(vr_index).idlstdom := 2;
              ELSE 
                -- Paramento não identificado
                pr_protocolo(vr_index).idlstdom := 15;
              END IF;
              
            -- Credito Salario
            WHEN pr_protocolo(vr_index).cdtippro = 4 THEN
              pr_protocolo(vr_index).idlstdom := 3;
              
            -- TED
            WHEN pr_protocolo(vr_index).cdtippro = 9 THEN							
              pr_protocolo(vr_index).idlstdom := 4;

            -- Transferência
            WHEN pr_protocolo(vr_index).cdtippro = 1 THEN
              -- Diferenciar entre intracooperativa e intercooperativa
              -- As Transferencias que no mesma cooperativa terão o "CDAGECTL" no campo dsinform3
              IF UPPER(pr_protocolo(vr_index).dsinform##3) LIKE '%' || to_char(rw_crapcop.cdagectl ) || '%'  THEN
                -- INTRACOOPERATIVA
                pr_protocolo(vr_index).idlstdom := 5;
              ELSE
                -- INTERCOOPERATIVA
                pr_protocolo(vr_index).idlstdom := 6;
              END IF;
              
            -- 16 = Pagamento DARF
            WHEN pr_protocolo(vr_index).cdtippro = 16 THEN
              pr_protocolo(vr_index).idlstdom := 7;
            
            -- 17 = Pagamento DAS
            WHEN pr_protocolo(vr_index).cdtippro = 17 THEN
              pr_protocolo(vr_index).idlstdom := 8;

            -- 18 = Agendamento DARF
            WHEN pr_protocolo(vr_index).cdtippro = 18 THEN
              pr_protocolo(vr_index).idlstdom := 16;
            
            -- 19 = Agendamento DAS
            WHEN pr_protocolo(vr_index).cdtippro = 19 THEN
              pr_protocolo(vr_index).idlstdom := 17;
              
            -- 13 = Pagamento/Agendamento GPS
            WHEN pr_protocolo(vr_index).cdtippro = 13 THEN              
              IF NVL(pr_protocolo(vr_index).flgagend,0) = 0 THEN
                pr_protocolo(vr_index).idlstdom := 9; -- Pagamento efetivado
              ELSE
                pr_protocolo(vr_index).idlstdom := 14; -- Agendamento
              END IF;              
              
            -- 24 = Pagamento FGTS
            WHEN pr_protocolo(vr_index).cdtippro = 24 THEN
              pr_protocolo(vr_index).idlstdom := 10;
              
            -- 23 = Pagamento DAE
            WHEN pr_protocolo(vr_index).cdtippro = 23 THEN
              pr_protocolo(vr_index).idlstdom := 11;
              
            -- 20 = Recarga de Celular
            WHEN pr_protocolo(vr_index).cdtippro = 20 THEN
              pr_protocolo(vr_index).idlstdom := 20; -- 285.2 - Card #766
              
            -- 10 = Aplicação Pre/Pos
            WHEN pr_protocolo(vr_index).cdtippro = 10 THEN
              pr_protocolo(vr_index).idlstdom := 30;
              
            -- 12 = Resgate Aplicação Pre/Pos
            WHEN pr_protocolo(vr_index).cdtippro = 12 THEN
              pr_protocolo(vr_index).idlstdom := 31;
              
            -- 11 = Operações DebAut 
            WHEN pr_protocolo(vr_index).cdtippro = 11  THEN
              CASE UPPER(pr_protocolo(vr_index).dsinform##1)
                WHEN 'CADASTRO - INCLUSAO' THEN
                  pr_protocolo(vr_index).idlstdom := 34;
                WHEN 'CADASTRO - ALTERACAO' THEN
                  pr_protocolo(vr_index).idlstdom := 35;
                WHEN 'CADASTRO - EXCLUSAO' THEN
                  pr_protocolo(vr_index).idlstdom := 36;
                WHEN 'SUSPENSAO - INCLUSAO' THEN
                  pr_protocolo(vr_index).idlstdom := 37;
                WHEN 'SUSPENSAO - EXCLUSAO' THEN
                  pr_protocolo(vr_index).idlstdom := 38;
                WHEN 'BLOQUEIO DE DEBITO - INCLUSAO' THEN
                  pr_protocolo(vr_index).idlstdom := 39;
                WHEN 'BLOQUEIO DE DEBITO - EXCLUSAO' THEN
                  pr_protocolo(vr_index).idlstdom := 40;
              END CASE;
              
            -- 15 = Pagamento DebAut
            WHEN pr_protocolo(vr_index).cdtippro = 15 THEN
              pr_protocolo(vr_index).idlstdom := 32;
              
            -- 3 = Capital
            WHEN pr_protocolo(vr_index).cdtippro = 3 THEN
              pr_protocolo(vr_index).idlstdom := 33;

            -- 5 = Depósito
            WHEN pr_protocolo(vr_index).cdtippro = 5 THEN
              pr_protocolo(vr_index).idlstdom := 12;
              
            -- Nao identificado 
            ELSE
              pr_protocolo(vr_index).idlstdom := 0;
          END CASE;  
          
        EXCEPTION
          WHEN vr_exc_iter THEN
            -- Somente passa para a próxima iteração do LOOP
            NULL;
        END;
      END LOOP;
    EXCEPTION
      WHEN vr_exc_erro THEN
        IF vr_cdcritic > 0 THEN
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
        pr_dscritic := vr_dscritic;
        pr_dscritic := 'Erro em GENE0006.pc_lista_protocolos: ' || pr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro em GENE0006.pc_lista_protocolos: ' || SQLERRM;
        pr_des_erro := 'NOK';
    END;
  END pc_lista_protocolos_por_tipos;

  /* Listar protocolos gerados */
  PROCEDURE pc_lista_protocolos(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                               ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                               ,pr_dtinipro IN crappro.dtmvtolt%TYPE  --> Data inicial do protocolo
                               ,pr_dtfimpro IN crappro.dtmvtolt%TYPE  --> Data final do protocolo
                               ,pr_dsprotoc IN VARCHAR2 DEFAULT NULL  --> Lista de protocolos a serem buscados
                               ,pr_iniconta IN NUMBER                 --> Início da conta
                               ,pr_nrregist IN NUMBER                 --> Número de registros
                               ,pr_cdtippro IN NUMBER                 --> Código protocolo
                               ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAS
                               ,pr_dstransa OUT VARCHAR2              --> Descrição da transação
                               ,pr_dscritic OUT VARCHAR2              --> Descrição da crítica
                               ,pr_qttotreg OUT NUMBER                --> Quantidade de registros
                               ,pr_protocolo  OUT typ_tab_protocolo   --> PL Table de registros
                               ,pr_des_erro OUT VARCHAR2) IS          --> Erros do processo
                               
    -- ..........................................................................
    --
    --  Programa : pc_lista_protocolos   (Antigo: sistema/generico/procedures/bo_algoritmo_seguranca.p --> lista_protocolos)
    --  Sistema  : Processos Genéricos
    --  Sigla    : GENE
    --  Autor    : Petter Rafael - Supero
    --  Data     : Junho/2013.                   Ultima atualização: 06/12/2017
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: ---
    --  Objetivo  : Gera listagem de protocolos.
    --
    --   Observação: Parâmetros para Internet: dtinipro, dtfimpro, iniconta, nrregist
    --              - dtinipro -> para consultar determinado periodo (inicio)
    --                            fora da internet passar parametro com valor NULL
    --              - dtfimpro -> para consultar determinado periodo (fim)
    --                            fora da internet passar parametro com valor NULL
    --              - iniconta -> a partir do registro nr X, gravar na TEMP-TABLE
    --                            fora da internet passar parametro com valor "0"
    --              - nrregist -> número de registros que devem ser gravados na TEMP-TABLE
    --                            fora da internet passar parametro com valor "0"
    --
    --  Alteracoes: 01/06/2013 - Conversão Progress-Oracle (Petter - Supero).
  	--               
	  --              19/05/2016 - Ajuste para exibir protocolos 15 - pagamento convenio
	  --  			                   PRJ320 - Oferta DebAut (Odirlei-AMcom)          
    --
    --              05/10/2016 - Correcao no tratamento de erros retornados pela procedure. 
    --                           SD 535051 (Carlos Rafael Tanholi).
    --
    --              05/06/2017 - Pesquisar comprovantes filtrando somente pela data 
	--            	             da transação (David).
    --
    --              30/10/2017 - Adequação da procedure conforme 
    --                           generico\procedures\bo_algoritmo_seguranca.p, Prj. 285
    --                           (Jean Michel).
	--
    --              06/12/2017 - Alterado para chamar rotinapc_lista_protocolos_por_tipos.
    --                           (p285 - Ricardo Linhares).
    -- .............................................................................
  BEGIN
    DECLARE
      vr_exc_erro   EXCEPTION;                   --> Controle de execução
      vr_dtinipro   DATE;                        --> Auxiliar para data inicial do protocolo
      vr_dtfimpro   DATE;                        --> Auxiliar para data final do protocolo
      vr_exc_iter   EXCEPTION;                   --> Controle de iteração
      vr_index      NUMBER;                      --> Indexador para PL Table
      vr_nmoperad   crapopi.nmoperad%TYPE;       --> Nome operador
      vr_cdcritic   crapcri.cdcritic%TYPE := 0;  --> Código da crítica
      vr_dscritic   crapcri.dscritic%TYPE := ''; --> Descrição da crítica
      vr_cdtippro   VARCHAR2(100);
    BEGIN
      
      IF(pr_cdtippro = 0) THEN
        vr_cdtippro := '0';
      ELSE
        vr_cdtippro := TO_CHAR(pr_cdtippro);
      END IF;
        
      pc_lista_protocolos_por_tipos(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_dtinipro => pr_dtinipro
                                   ,pr_dtfimpro => pr_dtfimpro
                                   ,pr_dsprotoc => pr_dsprotoc
                                   ,pr_iniconta => pr_iniconta
                                   ,pr_nrregist => pr_nrregist
                                   ,pr_cdtippro => vr_cdtippro
                                   ,pr_cdorigem => pr_cdorigem
                                   ,pr_dstransa => pr_dstransa
                                   ,pr_dscritic => pr_dscritic
                                   ,pr_qttotreg => pr_qttotreg
                                   ,pr_protocolo => pr_protocolo
                                   ,pr_des_erro => pr_des_erro);
     
    END;
  END pc_lista_protocolos;

  

  /* Realiza estorno de protocolos */
  PROCEDURE pc_estorna_protocolo(pr_cdcooper IN crapcop.cdcooper%TYPE      --> Código da cooperativa
                                ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE      --> Data movimento
                                ,pr_nrdconta IN crapass.nrdconta%TYPE      --> Número da conta
                                ,pr_cdtippro IN crappro.cdtippro%TYPE      --> Código do protocolo
                                ,pr_nrdocmto IN craplcm.nrdocmto%TYPE      --> Número do documento
                                ,pr_dsprotoc OUT crappro.dsprotoc%TYPE     --> Descrição do protocolo
                                ,pr_retorno  OUT VARCHAR2) IS              --> Retorno do status da execução da exclusão
    -- ..........................................................................
    --
    --  Programa : pc_estorna_protocolo   (Antigo: sistema/generico/procedures/bo_algoritmo_seguranca.p --> estorna_protocolo)
    --  Sistema  : Processos Genéricos
    --  Sigla    : GENE
    --  Autor    : Petter Rafael - Supero
    --  Data     : Junho/2013.                   Ultima atualização: 13/04/2018
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: ---
    --  Objetivo  : Exclui protocolo.
    --
    --  Alteracoes: 01/06/2013 - Conversão Progress-Oracle (Petter - Supero).
    --
    --              13/04/2018 - Replicado ajustes versao progress e incrementado
    --                           GPS. PRJ381 - Antifraude(Odirlei-AMcom)
    -- .............................................................................
  BEGIN
    DECLARE
      vr_exc_erro   EXCEPTION;        --> Controle de exceção

      -- Buscar dados dos protocolos
      CURSOR cr_crappro(pr_cdcooper IN crappro.cdcooper%TYPE
                       ,pr_nrdconta IN crappro.nrdconta%TYPE
                       ,pr_dtmvtolt IN crappro.dtmvtolt%TYPE
                       ,pr_cdtippro IN crappro.cdtippro%TYPE
                       ,pr_nrdocmto IN crappro.nrdocmto%TYPE) IS
        SELECT co.dsprotoc
        FROM crappro co
        WHERE co.cdcooper = pr_cdcooper
          AND co.nrdconta = pr_nrdconta
          AND co.dtmvtolt = pr_dtmvtolt
          AND co.cdtippro = pr_cdtippro
          AND co.nrdocmto = pr_nrdocmto;
      rw_crappro cr_crappro%ROWTYPE;
      
      -- Buscar dados dos protocolos de aplicação
      CURSOR cr_crappro_apl(pr_cdcooper IN crappro.cdcooper%TYPE
                           ,pr_nrdconta IN crappro.nrdconta%TYPE
                           ,pr_dtmvtolt IN crappro.dtmvtolt%TYPE
                           ,pr_cdtippro IN crappro.cdtippro%TYPE
                           ,pr_nrdocmto IN crappro.nrdocmto%TYPE) IS
      SELECT pro.rowid
            ,pro.dsprotoc             
        FROM crappro pro
       WHERE pro.cdcooper = pr_cdcooper
         AND pro.nrdconta = pr_nrdconta
         AND pro.dtmvtolt = pr_dtmvtolt
         AND pro.cdtippro = pr_cdtippro
         AND pro.nrdocmto = pr_nrdocmto
         AND pro.flgativo = 1;
      rw_crappro_apl cr_crappro_apl%ROWTYPE;

    BEGIN
      
      /*Aplicacao*/
      IF pr_cdtippro = 10 THEN
          
        -- Busca descrição do protocolo
        OPEN cr_crappro_apl(pr_cdcooper
                           ,pr_nrdconta
                           ,pr_dtmvtolt
                           ,pr_cdtippro
                           ,pr_nrdocmto);
                       
        FETCH cr_crappro_apl INTO rw_crappro_apl;

        -- Verifica se retornou registro na tupla
        IF cr_crappro_apl%NOTFOUND THEN
          CLOSE cr_crappro_apl;
          pr_retorno := 'NOK';
          RAISE vr_exc_erro;
        ELSE
          CLOSE cr_crappro_apl;
        END IF;

        -- Atribui valor de saída
        pr_dsprotoc := rw_crappro_apl.dsprotoc;

        -- Atualiza registro
        UPDATE crappro pro
        SET pro.flgativo = 0
           ,pro.dsprotoc = pro.dsprotoc || ' ' || '*** CANCELADO (' ||
                           to_char(pr_dtmvtolt, 'DD/MM/RRRR') || ' - ' ||
                           to_char(sysdate, 'HH24:MI:SS') || ')'
        WHERE pro.rowid = rw_crappro_apl.rowid;
          
      ELSE
        
        -- Busca descrição do protocolo
        OPEN cr_crappro(pr_cdcooper, pr_nrdconta, pr_dtmvtolt, pr_cdtippro, pr_nrdocmto);
        FETCH cr_crappro INTO rw_crappro;

        -- Verifica se retornou registro na tupla
        IF cr_crappro%NOTFOUND THEN
          CLOSE cr_crappro;
          pr_retorno := 'NOK';
          RAISE vr_exc_erro;
        ELSE
          CLOSE cr_crappro;
        END IF;

        -- Atribui valor de saída
        pr_dsprotoc := rw_crappro.dsprotoc;

        -- 13 - GPS, 23 - DAE, 24 - FGTS
        -- 17 - DAS,16 - DARF
        IF pr_cdtippro IN (13,23,24,16,17 )THEN  
             /* Padrao diferente pois para FGTS e DAE utiliza modelo MD5
                Gerando protocolo maior, e fazendo que estoure o campo 
                ao concatenar texto. PRJ406 - FGTS*/
          -- Atualiza registro
          UPDATE crappro co
          SET co.dsprotoc = co.dsprotoc || ' ' || '**ESTORNADO(' ||
                            to_char(pr_dtmvtolt, 'DD/MM/RR') || '-' ||
                            to_char(sysdate, 'HH24:MI:SS') || ')'
          WHERE co.cdcooper = pr_cdcooper
            AND co.nrdconta = pr_nrdconta
            AND co.dtmvtolt = pr_dtmvtolt
            AND co.cdtippro = pr_cdtippro
            AND co.nrdocmto = pr_nrdocmto;
             
        ELSE

        -- Atualiza registro
        UPDATE crappro co
        SET co.dsprotoc = co.dsprotoc || ' ' || '*** ESTORNADO (' ||
                          to_char(pr_dtmvtolt, 'DD/MM/RRRR') || ' - ' ||
                          to_char(sysdate, 'HH24:MI:SS') || ')'
        WHERE co.cdcooper = pr_cdcooper
          AND co.nrdconta = pr_nrdconta
          AND co.dtmvtolt = pr_dtmvtolt
          AND co.cdtippro = pr_cdtippro
          AND co.nrdocmto = pr_nrdocmto;
        END IF;
      END IF;

      -- Retorno para sucesso
      pr_retorno := 'OK';
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_retorno := 'NOK - Erro em GENE0006.pc_estorna_protocolo: ' || pr_retorno;
      WHEN OTHERS THEN
        pr_retorno := 'NOK - Erro em GENE0006.pc_estorna_protocolo: ' || SQLERRM;
    END;
  END pc_estorna_protocolo;
  
  /* Resonsavel por buscar as informações do protocolo informado */
  PROCEDURE pc_busca_protocolo(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                              ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de movimento
                              ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                              ,pr_cdtippro IN NUMBER                 --> Código protocolo
                              ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAA
                              ,pr_nrdocmto IN VARCHAR2               --> Número do documento
                              ,pr_protocolo OUT typ_tab_protocolo    --> PL Table de registros
                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Código do erro
                              ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descrição do erro    
  BEGIN
    DECLARE     
      -- Buscar dados da cooperativa
      CURSOR cr_crapcop(pr_cdcooper IN crappro.cdcooper%TYPE) IS   --> Código da cooperativa
      SELECT cop.cdbcoctl
            ,cop.cdagectl
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;

      -- Buscar dados dos protocolos
      CURSOR cr_crappro(pr_cdcooper IN crappro.cdcooper%TYPE
                       ,pr_nrdconta IN crappro.nrdconta%TYPE
                       ,pr_dtmvtolt IN crappro.dtmvtolt%TYPE
                       ,pr_cdtippro IN crappro.cdtippro%TYPE
                       ,pr_nrdocmto IN crappro.nrdocmto%TYPE) IS
      SELECT pro.dsprotoc
            ,pro.cdtippro
            ,pro.nrcpfope
            ,pro.dtmvtolt
            ,pro.dttransa
            ,pro.hrautent
            ,pro.vldocmto
            ,pro.nrdocmto
            ,pro.nrseqaut
            ,pro.dsinform##1 
            ,pro.dsinform##2 
            ,pro.dsinform##3 
            ,pro.flgagend
            ,pro.nmprepos
            ,pro.nrcpfpre
            ,pro.dscedent              
        FROM crappro pro
        WHERE pro.cdcooper = pr_cdcooper
          AND pro.nrdconta = pr_nrdconta
          AND pro.dtmvtolt = pr_dtmvtolt
          AND pro.cdtippro = pr_cdtippro
          AND pro.nrdocmto = pr_nrdocmto
          AND pro.flgativo = 1; --Ativo
      rw_crappro cr_crappro%ROWTYPE;
      
      -- Busca dados de operação
      CURSOR cr_crapopi(pr_cdcooper IN crapopi.cdcooper%TYPE      --> Código da cooperativa
                       ,pr_nrdconta IN crapopi.nrdconta%TYPE      --> Número da conta
                       ,pr_nrcpfope IN crappro.nrcpfope%TYPE) IS  --> Número da operação
      SELECT opi.nmoperad
        FROM crapopi opi
       WHERE opi.cdcooper = pr_cdcooper
         AND opi.nrdconta = pr_nrdconta
         AND opi.nrcpfope = pr_nrcpfope
         AND rownum = 1;
      rw_crapopi cr_crapopi%ROWTYPE;
      
      --> Controle de execução
      vr_exc_erro EXCEPTION;                

      -- Descrição e código da critica
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      
      -- Array para guardar o split dos dados contidos na dstexttb
      vr_vet_dados gene0002.typ_split;
     
      -- Controle de iteração    
      vr_exc_iter EXCEPTION;             
      
      -- Indexador para PL Table
      vr_index NUMBER;                
      
      -- Nome operador
      vr_nmoperad   crapopi.nmoperad%TYPE; 

    BEGIN
      
       -- Validar dados da cooperativa
      OPEN cr_crapcop(pr_cdcooper);
      
      FETCH cr_crapcop INTO rw_crapcop;

      --Se nao encontrou
      IF cr_crapcop%NOTFOUND THEN
        
        --Fechar Cursor
        CLOSE cr_crapcop;
        
        vr_cdcritic:= 651;
        vr_dscritic:= NULL;
        
        -- Gera exceção
        RAISE vr_exc_erro;
        
      END IF;
      
      --Fechar Cursor
      CLOSE cr_crapcop;
      
      -- Efetuar o split das informacoes contidas na nrdocmto separados por ;
      vr_vet_dados := gene0002.fn_quebra_string(pr_string  => pr_nrdocmto
                                               ,pr_delimit => ';');
     
      -- Pesquisar o vetor de faixas partindo do final ate o inicio
      FOR vr_pos IN REVERSE 1..vr_vet_dados.COUNT LOOP
        
        -- Busa o protocolo
        OPEN cr_crappro(pr_cdcooper => pr_cdcooper
                       ,pr_nrdconta => pr_nrdconta
                       ,pr_dtmvtolt => pr_dtmvtolt
                       ,pr_cdtippro => pr_cdtippro
                       ,pr_nrdocmto => TO_NUMBER(vr_vet_dados(vr_pos)));
                       
        FETCH cr_crappro INTO rw_crappro;
        
        IF cr_crappro%NOTFOUND THEN
          
          -- Fecha o cursor
          CLOSE cr_crappro;
          
          -- Monta critica
          vr_cdcritic := 0;
          vr_dscritic := 'Protocolo nao encontrado.';
          
          -- Gera exceção
          RAISE vr_exc_erro;
          
        ELSE
          -- Fecha o cursor
          CLOSE cr_crappro; 
        
        END IF;
        
        -- Valida protocolo Favorecido
        IF pr_cdtippro <> 8 AND rw_crappro.cdtippro = 8 THEN
          RAISE vr_exc_iter;
        END IF;

        vr_nmoperad := '';

        -- Busca dados sobre operação
        OPEN cr_crapopi(pr_cdcooper => pr_cdcooper, 
                        pr_nrdconta => pr_nrdconta, 
                        pr_nrcpfope => rw_crappro.nrcpfope);
        
        FETCH cr_crapopi INTO rw_crapopi;

        -- Verifica se retornou registro na tupla
        IF cr_crapopi%FOUND THEN
          CLOSE cr_crapopi;
          vr_nmoperad := rw_crapopi.nmoperad;
        ELSE
          CLOSE cr_crapopi;
        END IF;

        -- Criar indice para registro
        vr_index := pr_protocolo.count + 1;

        -- Grava dados do registro
        pr_protocolo(vr_index).cdtippro := rw_crappro.cdtippro;
        pr_protocolo(vr_index).dtmvtolt := rw_crappro.dtmvtolt;
        pr_protocolo(vr_index).dttransa := rw_crappro.dttransa;
        pr_protocolo(vr_index).hrautent := rw_crappro.hrautent;
        pr_protocolo(vr_index).vldocmto := rw_crappro.vldocmto;
        pr_protocolo(vr_index).nrdocmto := rw_crappro.nrdocmto;
        pr_protocolo(vr_index).nrseqaut := rw_crappro.nrseqaut;
        pr_protocolo(vr_index).dsinform##1 := rw_crappro.dsinform##1;
        pr_protocolo(vr_index).dsinform##2 := rw_crappro.dsinform##2;
        pr_protocolo(vr_index).dsinform##3 := rw_crappro.dsinform##3;
        pr_protocolo(vr_index).dsprotoc := rw_crappro.dsprotoc;
        pr_protocolo(vr_index).flgagend := rw_crappro.flgagend;
        pr_protocolo(vr_index).nmprepos := rw_crappro.nmprepos;
        pr_protocolo(vr_index).nrcpfpre := rw_crappro.nrcpfpre;
        pr_protocolo(vr_index).nmoperad := vr_nmoperad;
        pr_protocolo(vr_index).nrcpfope := rw_crappro.nrcpfope;

        IF rw_crappro.cdtippro IN (2,6,9) THEN
          pr_protocolo(vr_index).cdbcoctl := rw_crapcop.cdbcoctl;
          pr_protocolo(vr_index).cdagectl := rw_crapcop.cdagectl;
        END IF;

        -- Valida TAA
        IF pr_cdorigem = 4 THEN
          -- Para transferência
          IF pr_protocolo(vr_index).cdtippro = 1 THEN
            pr_protocolo(vr_index).dscedent := substr(gene0002.fn_busca_entrada(2, rw_crappro.dsinform##2, '#'), 19);
          ELSE
            -- Verifica campo da tabela
            IF TRIM(rw_crappro.dscedent) IS NULL THEN
              pr_protocolo(vr_index).dscedent := 'PAGAMENTO TAA';
            ELSE
              pr_protocolo(vr_index).dscedent := rw_crappro.dscedent;
            END IF;
          END IF;
        ELSE
          pr_protocolo(vr_index).dscedent := rw_crappro.dscedent;
        END IF;   
        
        -- Tratar para exibir o cedente quando for pagamento, porém a informação do cedente não existe no protocolo
        IF rw_crappro.cdtippro IN (2,6,15) THEN
          -- Verifica se existe o nome do cedente
          IF TRIM(rw_crappro.dscedent) IS NULL THEN
            -- Se nao possui nome de cedente, validar qual é o canal 
            IF gene0002.fn_busca_entrada(3, rw_crappro.dsinform##3, '#') LIKE '%TAA%' THEN
              -- Pagamento feito no ATM
              pr_protocolo(vr_index).dscedent := 'PAGAMENTO TAA';
            ELSE 
              -- Outro pagamento, onde nao existe o nome do cedente
              pr_protocolo(vr_index).dscedent := 'PAGAMENTO';
            END IF;
          ELSE
            pr_protocolo(vr_index).dscedent := rw_crappro.dscedent;
          END IF;
        END IF;
        
      END LOOP;         
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Monta mensagem de erro
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
      WHEN vr_exc_iter THEN
        NULL;
        
      WHEN OTHERS THEN
        -- Monta mensagem de erro
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := 'Erro em GENE0006.pc_busca_protocolo: ' || SQLERRM;
        
    END;
  END pc_busca_protocolo;

  -- 
  PROCEDURE pc_busca_protocolo_por_protoc (pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                          ,pr_nrdconta IN crapopi.nrdconta%TYPE  --> Conta
                                          ,pr_dsprotoc IN crappro.dsprotoc%TYPE  --> Protocolo
                                          ,pr_cdorigem IN NUMBER
										  ,pr_flgativo IN crappro.flgativo%TYPE default 1 --> (0 - Inativos, 1 - Ativos, 2 - Todos)
                                          ,pr_protocolo OUT typ_tab_protocolo    --> PL Table de registros
                                          ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Código do erro
                                          ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descrição do erro    
  
    -- ..........................................................................
    --
    --  Sistema  : Processos Genéricos
    --  Sigla    : GENE
    --  Autor    : 
    --  Data     : Dezembro/2017.                   Ultima atualização: 
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: ---
    --  Objetivo  : Gera listagem de protocolos podendo filtrar 
    --
    --  Alteração : 03/01/2017 - Incluido tratativas para arrecadação de FGTS.
    --                           PRJ406-FGTS(Odirlei-AMcom) 
    --
    -- .............................................................................
  BEGIN
    DECLARE     

      -- Buscar dados das Cooperativas
      CURSOR cr_crapcop(pr_cdcooper IN crappro.cdcooper%TYPE) IS 
      SELECT cop.cdbcoctl
            ,cop.cdagectl
						,cop.cdagesic
            ,cop.nmrescop
            ,cop.nmextcop
            ,cop.nrsacbcb
            ,cop.nrouvbcb
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
      rw_crapcop cr_crapcop%ROWTYPE;
      rw_crapcop_central cr_crapcop%ROWTYPE;

      -- Buscar dados dos protocolos
      CURSOR cr_crappro(pr_cdcooper IN crappro.cdcooper%TYPE
                       ,pr_dsprotoc IN crappro.dsprotoc%TYPE
                       ,pr_flgativo IN crappro.flgativo%TYPE) IS
      SELECT pro.dsprotoc
            ,pro.cdtippro
            ,pro.nrcpfope
            ,pro.dtmvtolt
            ,pro.dttransa
            ,pro.hrautent
            ,pro.vldocmto
            ,pro.nrdocmto
            ,pro.nrseqaut
            ,pro.dsinform##1 
            ,pro.dsinform##2 
            ,pro.dsinform##3 
            ,pro.flgagend
            ,pro.nmprepos
            ,pro.nrcpfpre
            ,pro.dscedent              
        FROM crappro pro
        WHERE pro.cdcooper = pr_cdcooper
          AND upper(pro.dsprotoc) = upper(pr_dsprotoc)
          AND pro.flgativo = decode(pr_flgativo,2,pro.flgativo,pr_flgativo); /* 2 - Todos */
      rw_crappro cr_crappro%ROWTYPE;
      
      -- Busca dados de operação
      CURSOR cr_crapopi(pr_cdcooper IN crapopi.cdcooper%TYPE      --> Código da cooperativa
                       ,pr_nrdconta IN crapopi.nrdconta%TYPE      --> Número da conta
                       ,pr_nrcpfope IN crappro.nrcpfope%TYPE) IS  --> Número da operação
      SELECT opi.nmoperad
        FROM crapopi opi
       WHERE opi.cdcooper = pr_cdcooper
         AND opi.nrdconta = pr_nrdconta
         AND opi.nrcpfope = pr_nrcpfope
         AND rownum = 1;
      rw_crapopi cr_crapopi%ROWTYPE;
      
      vr_exc_erro EXCEPTION;                
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic VARCHAR2(4000);
      vr_vet_dados gene0002.typ_split;
      vr_exc_iter EXCEPTION;             
      vr_index NUMBER;                
      vr_nmoperad   crapopi.nmoperad%TYPE; 

    BEGIN
      

      -- Busca dados da Cooperativa
      OPEN cr_crapcop(pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      IF cr_crapcop%NOTFOUND THEN
        CLOSE cr_crapcop;
        vr_cdcritic:= 651;
        vr_dscritic:= NULL;
        RAISE vr_exc_erro;
      END IF;
      CLOSE cr_crapcop;
      
      -- Buscar dados da cooperativa central
      OPEN cr_crapcop(3);
      FETCH cr_crapcop INTO rw_crapcop_central;

      -- Verifica se foi encontrado registro na tupla
      IF cr_crapcop%NOTFOUND THEN
        CLOSE cr_crapcop;
        vr_cdcritic:= 651;
        vr_dscritic:= NULL;
        RAISE vr_exc_erro;
      ELSE
        CLOSE cr_crapcop;
      END IF;
      
      -- Busca o protocolo
      OPEN cr_crappro(pr_cdcooper => pr_cdcooper
                     ,pr_dsprotoc => pr_dsprotoc
                     ,pr_flgativo => pr_flgativo);
                       
        FETCH cr_crappro INTO rw_crappro;
        
        IF cr_crappro%NOTFOUND THEN
          CLOSE cr_crappro;
          vr_cdcritic := 0;
          vr_dscritic := 'Protocolo nao encontrado.';
          RAISE vr_exc_erro;
        ELSE
          CLOSE cr_crappro; 
        END IF;
        
        -- Valida protocolo Favorecido
        /*IF pr_cdtippro <> 8 AND rw_crappro.cdtippro = 8 THEN
          RAISE vr_exc_iter;
        END IF; */

        vr_nmoperad := '';

        -- Busca dados sobre operação
        OPEN cr_crapopi(pr_cdcooper => pr_cdcooper, 
                        pr_nrdconta => pr_nrdconta, 
                        pr_nrcpfope => rw_crappro.nrcpfope);
        
        FETCH cr_crapopi INTO rw_crapopi;

        -- Verifica se retornou registro na tupla
        IF cr_crapopi%FOUND THEN
          CLOSE cr_crapopi;
          vr_nmoperad := rw_crapopi.nmoperad;
        ELSE
          CLOSE cr_crapopi;
        END IF;

        -- Criar indice para registro
        vr_index := 1;

        -- Grava dados do registro
        pr_protocolo(vr_index).cdtippro := rw_crappro.cdtippro;
        pr_protocolo(vr_index).dtmvtolt := rw_crappro.dtmvtolt;
        pr_protocolo(vr_index).dttransa := rw_crappro.dttransa;
        pr_protocolo(vr_index).hrautent := rw_crappro.hrautent;
        pr_protocolo(vr_index).vldocmto := rw_crappro.vldocmto;
        pr_protocolo(vr_index).nrdocmto := rw_crappro.nrdocmto;
        pr_protocolo(vr_index).nrseqaut := rw_crappro.nrseqaut;
        pr_protocolo(vr_index).dsinform##1 := rw_crappro.dsinform##1;
        pr_protocolo(vr_index).dsinform##2 := rw_crappro.dsinform##2;
        pr_protocolo(vr_index).dsinform##3 := rw_crappro.dsinform##3;
        pr_protocolo(vr_index).dsprotoc := rw_crappro.dsprotoc;
        pr_protocolo(vr_index).flgagend := rw_crappro.flgagend;
        pr_protocolo(vr_index).nmprepos := rw_crappro.nmprepos;
        pr_protocolo(vr_index).nrcpfpre := rw_crappro.nrcpfpre;
        pr_protocolo(vr_index).nmoperad := vr_nmoperad;
        pr_protocolo(vr_index).nrcpfope := rw_crappro.nrcpfope;

        IF rw_crappro.cdtippro IN (1,2,4,5,6,9,10,11,12,13,15,20,23,24) THEN
          pr_protocolo(vr_index).cdbcoctl := rw_crapcop.cdbcoctl;
          pr_protocolo(vr_index).cdagectl := rw_crapcop.cdagectl;
				  pr_protocolo(vr_index).nmrescop := rw_crapcop.nmrescop;
            
          --> Dados da cooperativa central
          pr_protocolo(vr_index).nmextcop_central := rw_crapcop_central.nmextcop;
          pr_protocolo(vr_index).nmrescop_central := rw_crapcop_central.nmrescop;
                        
          --> Sac/Ouvidoria Bancoob
          pr_protocolo(vr_index).nrtelsac := rw_crapcop.nrsacbcb;
          pr_protocolo(vr_index).nrtelouv := rw_crapcop.nrouvbcb;
        
				ELSIF rw_crappro.cdtippro IN (16,17,18,19) THEN
					pr_protocolo(vr_index).cdbcoctl := rw_crapcop.cdagesic;
					pr_protocolo(vr_index).cdagectl := rw_crapcop.cdagectl;
        END IF;
				
				IF rw_crappro.cdtippro IN (20) THEN
					pr_protocolo(vr_index).nrcelular   := TRIM(gene0002.fn_busca_entrada(3, rw_crappro.dsinform##2, '#'));
					pr_protocolo(vr_index).nmoperadora := TRIM(gene0002.fn_busca_entrada(2, rw_crappro.dsinform##2, '#'));
					pr_protocolo(vr_index).nrnsuope    := TRIM(gene0002.fn_busca_entrada(5, rw_crappro.dsinform##2, '#'));
				END IF;

        -- Valida TAA
        IF pr_cdorigem = 4 THEN
          -- Para transferência
          IF pr_protocolo(vr_index).cdtippro = 1 THEN
            pr_protocolo(vr_index).dscedent := substr(gene0002.fn_busca_entrada(2, rw_crappro.dsinform##2, '#'), 19);
          ELSE
            -- Verifica campo da tabela
            IF TRIM(rw_crappro.dscedent) IS NULL THEN
              pr_protocolo(vr_index).dscedent := 'PAGAMENTO TAA';
            ELSE
              pr_protocolo(vr_index).dscedent := rw_crappro.dscedent;
            END IF;
          END IF;
        ELSE
          pr_protocolo(vr_index).dscedent := rw_crappro.dscedent;
        END IF;   
        
        -- Tratar para exibir o cedente quando for pagamento, porém a informação do cedente não existe no protocolo
        IF rw_crappro.cdtippro IN (2,6,15) THEN
          -- Verifica se existe o nome do cedente
          IF TRIM(rw_crappro.dscedent) IS NULL THEN
            -- Se nao possui nome de cedente, validar qual é o canal 
            IF gene0002.fn_busca_entrada(3, rw_crappro.dsinform##3, '#') LIKE '%TAA%' THEN
              -- Pagamento feito no ATM
              pr_protocolo(vr_index).dscedent := 'PAGAMENTO TAA';
            ELSE 
              -- Outro pagamento, onde nao existe o nome do cedente
              pr_protocolo(vr_index).dscedent := 'PAGAMENTO';
            END IF;
          ELSE
            pr_protocolo(vr_index).dscedent := rw_crappro.dscedent;
          END IF;
        END IF;
        
        -- Identificar a origem do comprovante
        -- Devido as informações presentes na crappro, será possivel apenas diferenciar em TAA e não TAA
        -- Quando não for TAA será devolvido como INTERNET
        -- Caso seja necessario diferenciar a origem, deverá ser revisto a criação do protocolo
        IF gene0002.fn_busca_entrada(3, rw_crappro.dsinform##3, '#') LIKE '%TAA%' THEN
          pr_protocolo(vr_index).dsorigem := 'TAA';
        ELSE 
          pr_protocolo(vr_index).dsorigem := 'INTERNET';
        END IF;
            
        -- Desmontar a lista de dominio dos protocolos
        -- Essa lista é referente ao TIPO DE COMPROVANTE
        CASE
          -- 2 = Pagamento (Tit/Cnv) / 6 = Pagamento (Tit/Cnv) no TAA
          WHEN pr_protocolo(vr_index).cdtippro IN ( 2, 6 ) THEN
            -- Verificar se é comprovante de boleto ou convenio
            IF UPPER(pr_protocolo(vr_index).dsinform##2) LIKE '%BANCO%'  THEN
              -- Boleto
              pr_protocolo(vr_index).idlstdom := 1;
            ELSIF UPPER(pr_protocolo(vr_index).dsinform##2) LIKE '%CONVENIO%'  THEN
              -- Convênio
              pr_protocolo(vr_index).idlstdom := 2;
            ELSE 
              -- Paramento não identificado
              pr_protocolo(vr_index).idlstdom := 15;
            END IF;
                
          -- Credito Salario
          WHEN pr_protocolo(vr_index).cdtippro = 4 THEN
            pr_protocolo(vr_index).idlstdom := 3;
                
          -- TED
          WHEN pr_protocolo(vr_index).cdtippro = 9 THEN							
            pr_protocolo(vr_index).idlstdom := 4;

          -- Transferência
          WHEN pr_protocolo(vr_index).cdtippro = 1 THEN
            -- Diferenciar entre intracooperativa e intercooperativa
            -- As Transferencias que no mesma cooperativa terão o "CDAGECTL" no campo dsinform3
            IF UPPER(pr_protocolo(vr_index).dsinform##3) LIKE '%' || to_char(rw_crapcop.cdagectl ) || '%'  THEN
              -- INTRACOOPERATIVA
              pr_protocolo(vr_index).idlstdom := 5;
            ELSE
              -- INTERCOOPERATIVA
              pr_protocolo(vr_index).idlstdom := 6;
            END IF;

          -- 16 = Pagamento DARF
          WHEN pr_protocolo(vr_index).cdtippro = 16 THEN
            pr_protocolo(vr_index).idlstdom := 7;
          
          -- 17 = Pagamento DAS
          WHEN pr_protocolo(vr_index).cdtippro = 17 THEN
            pr_protocolo(vr_index).idlstdom := 8;

          -- 18 = Agendamento DARF
          WHEN pr_protocolo(vr_index).cdtippro = 18 THEN
            pr_protocolo(vr_index).idlstdom := 16;
          
          -- 19 = Agendamento DAS
          WHEN pr_protocolo(vr_index).cdtippro = 19 THEN
            pr_protocolo(vr_index).idlstdom := 17;
                
          -- 13 = Pagamento/Agendamento GPS
          WHEN pr_protocolo(vr_index).cdtippro = 13 THEN
            IF NVL(pr_protocolo(vr_index).flgagend,0) = 0 THEN
              pr_protocolo(vr_index).idlstdom := 9; -- Pagamento efetivado
            ELSE
              pr_protocolo(vr_index).idlstdom := 14; -- Agendamento
            END IF;
                
          -- 24 = Pagamento FGTS
          WHEN pr_protocolo(vr_index).cdtippro = 24 THEN
            pr_protocolo(vr_index).idlstdom := 10;
                
          -- 23 = Pagamento DAE
          WHEN pr_protocolo(vr_index).cdtippro = 23 THEN
            pr_protocolo(vr_index).idlstdom := 11;
                
          -- 20 = Recarga de Celular
          WHEN pr_protocolo(vr_index).cdtippro = 20 THEN
            pr_protocolo(vr_index).idlstdom := 20; -- 285.2 - Card #766
                
          -- 10 = Aplicação Pre/Pos
          WHEN pr_protocolo(vr_index).cdtippro = 10 THEN
            pr_protocolo(vr_index).idlstdom := 30;
                
          -- 12 = Resgate Aplicação Pre/Pos
          WHEN pr_protocolo(vr_index).cdtippro = 12 THEN
            pr_protocolo(vr_index).idlstdom := 31;
                
          -- 11 = Operações DebAut 
          WHEN pr_protocolo(vr_index).cdtippro = 11  THEN
            CASE UPPER(pr_protocolo(vr_index).dsinform##1)
              WHEN 'CADASTRO - INCLUSAO' THEN
                pr_protocolo(vr_index).idlstdom := 34;
              WHEN 'CADASTRO - ALTERACAO' THEN
                pr_protocolo(vr_index).idlstdom := 35;
              WHEN 'CADASTRO - EXCLUSAO' THEN
                pr_protocolo(vr_index).idlstdom := 36;
              WHEN 'SUSPENSAO - INCLUSAO' THEN
                pr_protocolo(vr_index).idlstdom := 37;
              WHEN 'SUSPENSAO - EXCLUSAO' THEN
                pr_protocolo(vr_index).idlstdom := 38;
              WHEN 'BLOQUEIO DE DEBITO - INCLUSAO' THEN
                pr_protocolo(vr_index).idlstdom := 39;
              WHEN 'BLOQUEIO DE DEBITO - EXCLUSAO' THEN
                pr_protocolo(vr_index).idlstdom := 40;
            END CASE;
            
          -- 15 = Pagamento DebAut
          WHEN pr_protocolo(vr_index).cdtippro = 15 THEN
            pr_protocolo(vr_index).idlstdom := 32;
                
          -- 3 = Capital
          WHEN pr_protocolo(vr_index).cdtippro = 3 THEN
            pr_protocolo(vr_index).idlstdom := 33;

          -- 5 = Depósito
          WHEN pr_protocolo(vr_index).cdtippro = 5 THEN
            pr_protocolo(vr_index).idlstdom := 12;
                
          -- Nao identificado 
          ELSE
            pr_protocolo(vr_index).idlstdom := 0;
        END CASE;  
          

    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := vr_dscritic;
      WHEN vr_exc_iter THEN
        NULL;
        
      WHEN OTHERS THEN
        pr_cdcritic := NVL(vr_cdcritic,0);
        pr_dscritic := 'Erro em GENE0006.pc_busca_protocolo: ' || SQLERRM;
        
    END;
  END pc_busca_protocolo_por_protoc;  
  
  
  /* Responsável por buscar as informações do protocolo informado
     Possui a mesma funcionalidade da rotina acima, porem utiliza gravacao em tabelas para serem
     chamadas diretamente atraves de rotinas progress */
  PROCEDURE pc_busca_protocolo_wt(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data de movimento
                                 ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                 ,pr_cdtippro IN NUMBER                 --> Código protocolo
                                 ,pr_cdorigem IN NUMBER                 --> Origem: 1-ayllos, 3-internet, 4-TAA
                                 ,pr_nrdocmto IN VARCHAR2               --> Número do documento
                                 ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Código do erro
                                 ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descrição da critica

    --> Tabela de retorno da rotina    
    vr_tab_protocolo  typ_tab_protocolo;      
    --> Indice da tabela de retorno
    vr_ind PLS_INTEGER;                 
  BEGIN
    -- Limpa a tabela temporaria de interface
    BEGIN
      DELETE wt_protocolo;
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro ao excluir wt_protocolo: ' || SQLERRM;
        RETURN;
    END;

    pc_busca_protocolo(pr_cdcooper => pr_cdcooper
                      ,pr_dtmvtolt => pr_dtmvtolt
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_cdtippro => pr_cdtippro
                      ,pr_cdorigem => pr_cdorigem
                      ,pr_nrdocmto => pr_nrdocmto
                      ,pr_protocolo  => vr_tab_protocolo   
                      ,pr_cdcritic => pr_cdcritic
                      ,pr_dscritic => pr_dscritic);

    -- Se ocorreu erro
    IF pr_cdcritic IS NOT NULL OR pr_dscritic IS NOT NULL THEN
   
      RETURN;
      
    ELSE -- Se nao ocorreu erro, percorre a tabela de retorno e efetua o insert na tabela de interface
      vr_ind := vr_tab_protocolo.first; -- Vai para o primeiro registro

      -- loop sobre a tabela de retorno
      WHILE vr_ind IS NOT NULL LOOP
        -- Insere na tabela de interface
        BEGIN
          INSERT INTO wt_protocolo
            (cdtippro
            ,dtmvtolt
            ,dttransa
            ,hrautent
            ,vldocmto
            ,nrdocmto
            ,nrseqaut
            ,dsinform##1
            ,dsinform##2
            ,dsinform##3
            ,dsprotoc
            ,dscedent
            ,flgagend
            ,nmprepos
            ,nrcpfpre
            ,nmoperad
            ,nrcpfope
            ,cdbcoctl
            ,cdagectl)
            VALUES
            (vr_tab_protocolo(vr_ind).cdtippro 
            ,vr_tab_protocolo(vr_ind).dtmvtolt 
            ,vr_tab_protocolo(vr_ind).dttransa 
            ,vr_tab_protocolo(vr_ind).hrautent 
            ,vr_tab_protocolo(vr_ind).vldocmto 
            ,vr_tab_protocolo(vr_ind).nrdocmto 
            ,vr_tab_protocolo(vr_ind).nrseqaut 
            ,vr_tab_protocolo(vr_ind).dsinform##1
            ,vr_tab_protocolo(vr_ind).dsinform##2
            ,vr_tab_protocolo(vr_ind).dsinform##3
            ,vr_tab_protocolo(vr_ind).dsprotoc 
            ,substr(vr_tab_protocolo(vr_ind).dscedent,1,40)
            ,vr_tab_protocolo(vr_ind).flgagend 
            ,vr_tab_protocolo(vr_ind).nmprepos 
            ,vr_tab_protocolo(vr_ind).nrcpfpre 
            ,vr_tab_protocolo(vr_ind).nmoperad 
            ,vr_tab_protocolo(vr_ind).nrcpfope 
            ,vr_tab_protocolo(vr_ind).cdbcoctl 
            ,vr_tab_protocolo(vr_ind).cdagectl);
        EXCEPTION
          WHEN OTHERS THEN
            pr_cdcritic := NULL;
            pr_dscritic := 'Erro ao inserir na tabela wt_protocolo: '||SQLERRM;
            RETURN;
        END;

        -- Vai para o proximo registro
        vr_ind := vr_tab_protocolo.next(vr_ind);

      END LOOP;
    END IF;
  END pc_busca_protocolo_wt;
  
  /* Procedure para montar o protocolo de segurança */
  PROCEDURE pc_monta_protocolo(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                              ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data movimento
                              ,pr_hrtransa IN craplcm.hrtransa%TYPE  --> Hora da transação
                              ,pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                              ,pr_nrdocmto IN craplcm.nrdocmto%TYPE  --> Número do documento
                              ,pr_nrseqaut IN crapaut.nrseqaut%TYPE  --> Número da sequencia
                              ,pr_vllanmto IN craplcm.vllanmto%TYPE  --> Valor lançamento
                              ,pr_nrdcaixa IN crapaut.nrdcaixa%TYPE  --> Número do caixa
                              ,pr_tipo_protocolo IN INTEGER          --> Tipo de Protocolo (1-Velho/2-Novo)
                              ,pr_utiliza_seq IN INTEGER             --> Utilizar Sequence para gerar o protocolo novo (0-Nao / 1-Sim)
                              ,pr_dsprotoc OUT crappro.dsprotoc%TYPE --> Descrição do protocolo
                              ,pr_dscritic OUT VARCHAR2              --> Descrição crítica
                              ,pr_des_erro OUT VARCHAR2) IS          --> Descrição dos erros de processo
    -- ..........................................................................
    --
    --  Programa : pc_monta_protocolo
    --  Sistema  : Processos Genéricos
    --  Sigla    : GENE
    --  Autor    : Douglas Quisinski
    --  Data     : Maio/2017.                   Ultima atualização: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: ---
    --   Objetivo  : Recebe os parâmetros e gera um protocolo único em hexadecimal.
    --
    --   Observação: Os parâmetros são convertidos para números, multiplicados
    --               pela variável "aux_multipli" e depois somados.
    --               São adicionados alguns campos sem multiplicação para serem
    --               identificadores únicos. Após isto são transformados em
    --               hexadecimal de 2 em 2 caracteres.
    --               Quando o parâmetro par_gravapro for igual a YES/TRUE, será
    --               gravado um registro na tabela crappro.
    --
    --   Alteracoes: 
    -- .............................................................................
  BEGIN
    DECLARE
      vr_nrprotoc  NUMBER;                --> Número protocolo
      vr_dsprotoc  crappro.dsprotoc%TYPE; --> Descrição protocolo
      
      vr_sequence  INTEGER;               --> Sequencial do Protocolo

      -- Erros
      vr_dscritic  VARCHAR2(5000);
      vr_exec_erro EXCEPTION;

    BEGIN
      -- Cacular o numero do protocolo, multiplica o valor dos parametros por 4
      pc_calcula_protocolo(pr_nrdconta => pr_nrdconta   --> Número da conta
                          ,pr_nrdocmto => pr_nrdocmto   --> Número do documento
                          ,pr_nrseqaut => pr_nrseqaut   --> Número da sequencia
                          ,pr_vllanmto => pr_vllanmto   --> Valor lançamento
                          ,pr_nrdcaixa => pr_nrdcaixa   --> Numero do Caixa
                          ,pr_nrprotoc => vr_nrprotoc   --> Numero do protocolo calculado
                          ,pr_dscritic => vr_dscritic); --> Descricao do erro
                          
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exec_erro;
      END IF;

      -- Verifica se deve utilizar sequence na geração do protocolo
      IF pr_utiliza_seq = 1 THEN
        vr_sequence := seq_crappro.nextval;
      ELSE
        vr_sequence := 0;
      END IF;

      -- Criptografar o numero do protocolo
      pc_criptografa_protocolo(pr_cdcooper => pr_cdcooper             --> Código da cooperativa
                              ,pr_dtmvtolt => pr_dtmvtolt             --> Data movimento
                              ,pr_hrtransa => pr_hrtransa             --> Hora da transação
                              ,pr_sequence => vr_sequence             --> Sequence utilizada no protocolo
                              ,pr_nrprotoc => vr_nrprotoc             --> Número do Protocolo
                              ,pr_tipo_protocolo => pr_tipo_protocolo --> Tipo de Protocolo (1-Velho/2-Novo)
                              ,pr_dsprotoc => vr_dsprotoc             --> Descrição do protocolo
                              ,pr_dscritic => vr_dscritic);           --> Descricao do Erro
    

      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exec_erro;
      END IF;
      
      pr_dsprotoc := vr_dsprotoc;
      pr_des_erro := 'OK';
      
    EXCEPTION
      WHEN vr_exec_erro THEN
        pr_dscritic := vr_dscritic;
        pr_des_erro := 'NOK';
        
      WHEN OTHERS THEN
        pr_dscritic := 'Erro em GENE0006.pc_monta_protocolo: ' || SQLERRM;
        pr_des_erro := 'NOK';
    END;
  END pc_monta_protocolo;

  /* Procedure para calcular o protocolo de segurança */
  PROCEDURE pc_criptografa_protocolo(pr_cdcooper IN crappro.cdcooper%TYPE  --> Código da cooperativa
                                    ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE  --> Data movimento
                                    ,pr_hrtransa IN craplcm.hrtransa%TYPE  --> Hora da transação
                                    ,pr_sequence IN INTEGER                --> Sequence utilizada no protocolo
                                    ,pr_nrprotoc IN NUMBER                 --> Número do Protocolo
                                    ,pr_tipo_protocolo IN INTEGER          --> Tipo de Protocolo (1-Velho/2-Novo)
                                    ,pr_dsprotoc OUT crappro.dsprotoc%TYPE --> Descrição do protocolo
                                    ,pr_dscritic OUT VARCHAR2) IS          --> Descricao do Erro
    -- ..........................................................................
    --
    --  Programa : pc_criptografa_protocolo
    --  Sistema  : Processos Genéricos
    --  Sigla    : GENE
    --  Autor    : Douglas Quisinski
    --  Data     : Maio/2017.                   Ultima atualização: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: ---
    --   Objetivo  : Recebe os parâmetros e gera um protocolo único em hexadecimal.
    --
    --   Observação: Os parâmetros são convertidos para números, multiplicados
    --               pela variável "aux_multipli" e depois somados.
    --               São adicionados alguns campos sem multiplicação para serem
    --               identificadores únicos. Após isto são transformados em
    --               hexadecimal de 2 em 2 caracteres.
    --               Quando o parâmetro par_gravapro for igual a YES/TRUE, será
    --               gravado um registro na tabela crappro.
    --
    --   Alteracoes: 
    -- .............................................................................
  BEGIN
    DECLARE
      vr_dsprotoc  crappro.dsprotoc%TYPE; --> Descrição protocolo
      vr_itera     PLS_INTEGER;           --> Controle para as iterações
      vr_contador  PLS_INTEGER;           --> Contador de registros
    BEGIN

      IF pr_tipo_protocolo = 2 THEN /* Novo formato */
        -- Cooperativa / Data / Horario
        vr_dsprotoc := to_char(pr_nrprotoc) ||
                       gene0002.fn_mask(pr_cdcooper, '99') ||
                       to_char(pr_dtmvtolt, 'DDMMYY') ||
                       gene0002.fn_mask(pr_hrtransa, '99999')  ||
                       gene0002.fn_mask(pr_sequence,'999');
                       
      ELSE /* Formato antigo do protocolo */

        -- Cooperativa / Data / Horario
        vr_dsprotoc := to_char(pr_nrprotoc) ||
                       gene0002.fn_mask(pr_cdcooper, '999') ||
                       to_char(pr_dtmvtolt, 'DDMMYYYY') ||
                       gene0002.fn_mask(pr_hrtransa, '99999');
                       
      END IF;

      -- Deixa um número PAR de caracteres
      IF MOD(length(vr_dsprotoc), 2) <> 0 THEN
        vr_dsprotoc := '0' || vr_dsprotoc;
      END IF;

      -- Converte em HEXADECIMAL de 2 em 2 caracteres
      vr_itera := 1;

      FOR vr_contador IN 1..(length(vr_dsprotoc) - 1) LOOP
        -- Verifica se é o segundo caracter por iteração
        IF vr_itera = 1 OR mod(vr_itera,2) <> 0  THEN
          pr_dsprotoc := pr_dsprotoc || fn_converte_hex(substr(vr_dsprotoc, vr_contador, 2));
        END IF;
        --Incrementar iteracao
        vr_itera:= vr_itera+1;
      END LOOP;

      -- Assimila valores nas variáveis
      vr_dsprotoc := pr_dsprotoc;
      pr_dsprotoc := NULL;

      -- Itera de 4 em 4 posições para gerar protocolo
      vr_contador := 1;
      WHILE vr_contador < length(vr_dsprotoc) LOOP
        -- Verifica se é o quarto caracter por iteração
        pr_dsprotoc := pr_dsprotoc || TRIM(substr(vr_dsprotoc, vr_contador, 4));

        IF (vr_contador + 4) < length(vr_dsprotoc) THEN
          pr_dsprotoc:= pr_dsprotoc || '.';
        END IF;
        --Incrementar iteracao em 4
        vr_contador := vr_contador + 4;
      END LOOP;

    EXCEPTION
      WHEN OTHERS THEN
        pr_dsprotoc:= NULL;
        pr_dscritic:= 'Erro na GENE0006.pc_criptografa_protocolo -> ' || SQLERRM;
    END;
  END pc_criptografa_protocolo;


  /* Procedure para calcular o protocolo de segurança */
  PROCEDURE pc_calcula_protocolo(pr_nrdconta IN crappro.nrdconta%TYPE  --> Número da conta
                                ,pr_nrdocmto IN craplcm.nrdocmto%TYPE  --> Número do documento
                                ,pr_nrseqaut IN crapaut.nrseqaut%TYPE  --> Número da sequencia
                                ,pr_vllanmto IN craplcm.vllanmto%TYPE  --> Valor lançamento
                                ,pr_nrdcaixa IN crapaut.nrdcaixa%TYPE  --> Numero do Caixa
                                ,pr_nrprotoc OUT NUMBER                --> Numero do Protocolo
                                ,pr_dscritic OUT VARCHAR2) IS          --> Descricao do Erro
    -- ..........................................................................
    --
    --  Programa : pc_calcula_protocolo
    --  Sistema  : Processos Genéricos
    --  Sigla    : GENE
    --  Autor    : Douglas Quisinski
    --  Data     : Maio/2017.                   Ultima atualização: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: ---
    --   Objetivo  : Recebe os parâmetros e gera um protocolo único em hexadecimal.
    --
    --   Observação: Os parâmetros são convertidos para números, multiplicados
    --               pela variável "aux_multipli" e depois somados.
    --               São adicionados alguns campos sem multiplicação para serem
    --               identificadores únicos. Após isto são transformados em
    --               hexadecimal de 2 em 2 caracteres.
    --               Quando o parâmetro par_gravapro for igual a YES/TRUE, será
    --               gravado um registro na tabela crappro.
    --
    --   Alteracoes: 
    -- .............................................................................
  BEGIN
    DECLARE
      vr_multipli  CONSTANT NUMBER := 4;  --> Fator multiplicador
      vr_nrprotoc  NUMBER;                --> Número protocolo
    BEGIN
      -- Conta
      vr_nrprotoc := nvl(vr_nrprotoc,0) + (pr_nrdconta * vr_multipli);
      -- Documento
      vr_nrprotoc := nvl(vr_nrprotoc,0) + (pr_nrdocmto * vr_multipli);

      -- Autenticação
      IF pr_nrseqaut > 0 THEN
        vr_nrprotoc := nvl(vr_nrprotoc,0) + (pr_nrseqaut * vr_multipli);
      END IF;

      -- Valor
      vr_nrprotoc := nvl(vr_nrprotoc,0) + (pr_vllanmto * 100 * vr_multipli);
      -- Caixa
      vr_nrprotoc := nvl(vr_nrprotoc,0) + (pr_nrdcaixa * vr_multipli);

      -- Devolver o valor calculado para o protocolo
      pr_nrprotoc:= nvl(vr_nrprotoc,0);

    EXCEPTION
      WHEN OTHERS THEN
        pr_nrprotoc:= 0;
        pr_dscritic:= 'Erro na GENE0006.pc_calcula_protocolo -> ' || SQLERRM;
    END;
  END pc_calcula_protocolo;

  /* Procedure para desmontar o protocolo de segurança */
  PROCEDURE pc_desmonta_protocolo(pr_dsprotoc  IN VARCHAR2     --> Protocolo
                                 ,pr_tipo_protocolo IN INTEGER --> Tipo de Protocolo (1-Velho/2-Novo)
                                 ,pr_nrprotoc OUT INTEGER      --> Número do protocolo
                                 ,pr_cdcooper OUT INTEGER      --> Cooperativa
                                 ,pr_dtmvtolt OUT DATE         --> Data
                                 ,pr_hrtransa OUT INTEGER      --> Hora
                                 ,pr_nrsequen OUT INTEGER      --> Sequencia
                                 ,pr_is_valid OUT VARCHAR2     --> Valido ? "OK" / "NOK"
                                 ,pr_dscritic OUT VARCHAR2) IS --> Descricao do Erro
    -- ..........................................................................
    --
    --  Programa : pc_desmonta_protocolo
    --  Sistema  : Processos Genéricos
    --  Sigla    : GENE
    --  Autor    : Douglas Quisinski
    --  Data     : Maio/2017.                   Ultima atualização: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: ---
    --   Objetivo  : Recebe os parâmetros e gera um protocolo único em hexadecimal.
    --
    --   Observação: Os parâmetros são convertidos para números, multiplicados
    --               pela variável "aux_multipli" e depois somados.
    --               São adicionados alguns campos sem multiplicação para serem
    --               identificadores únicos. Após isto são transformados em
    --               hexadecimal de 2 em 2 caracteres.
    --               Quando o parâmetro par_gravapro for igual a YES/TRUE, será
    --               gravado um registro na tabela crappro.
    --
    --   Alteracoes: 
    -- .............................................................................
  BEGIN
    DECLARE
      vr_itera     INTEGER;
      vr_contador  INTEGER;
      
      vr_dsprotoc  crappro.dsprotoc%TYPE;
      vr_dsprotoc2 crappro.dsprotoc%TYPE;
      
      vr_pos       INTEGER;
      
    BEGIN
      
      -- Remover a pontuação
      vr_dsprotoc := REPLACE(SRCSTR => pr_dsprotoc, OLDSUB => '.', NEWSUB => '');

      -- Converte em HEXADECIMAL de 2 em 2 caracteres
      vr_itera := 1;

      FOR vr_contador IN 1 .. (length(vr_dsprotoc) - 1) LOOP
        -- Verifica se é o segundo caracter por iteração
        IF vr_itera = 1 OR mod(vr_itera, 2) <> 0 THEN
          vr_dsprotoc2 := vr_dsprotoc2 || TO_CHAR(TO_NUMBER(substr(vr_dsprotoc,
                                                            vr_contador,
                                                            2),'XX') , 'FM00');
        END IF;
        --Incrementar iteracao
        vr_itera := vr_itera + 1;
      END LOOP;
      
      -- Verificar o tipo de protocolo que estamos desmontando
      IF pr_tipo_protocolo = 2 THEN
        -- Formato do Protocolo: Valor calculado + 
        --                       cdcooper "2" + 
        --                       dtmvtolt "6" + 
        --                       hrtransa "5" +
        --                       nrsequen "3"
        
        -- Posição inicial da "nrsequen"
        vr_pos := length(vr_dsprotoc2) - 2;
        -- Sequencial está no fim do protocolo
        pr_nrsequen := TO_NUMBER(substr(vr_dsprotoc2,vr_pos,3));

        -- Posição inicial da "hrtransa"
        vr_pos := vr_pos - 5;
        pr_hrtransa := TO_NUMBER(substr(vr_dsprotoc2,vr_pos,5));
        

        -- Posição inicial da "hrtransa"
        vr_pos := vr_pos - 6;
        pr_dtmvtolt := to_date(substr(vr_dsprotoc2,vr_pos,6),'DDMMYY');

        -- Posição inicial da "cdcooper"
        vr_pos := vr_pos - 2;
        pr_cdcooper := TO_NUMBER(substr(vr_dsprotoc2,vr_pos, 2));

        -- Posição inicial da "nrprotoc"
        pr_nrprotoc := TO_NUMBER(substr(vr_dsprotoc2,1, vr_pos));
      ELSE
        -- Formato do Protocolo: Valor calculado + 
        --                       cdcooper "3" + 
        --                       dtmvtolt "8" + 
        --                       hrtransa "5"

        -- Não tem sequencial
        pr_nrsequen := 0;

        -- Posição inicial da "hrtransa"
        vr_pos := length(vr_dsprotoc2) - 4;
        pr_hrtransa := TO_NUMBER(substr(vr_dsprotoc2,vr_pos,5));
        
        -- Posição inicial da "dtmvtolt"
        vr_pos := vr_pos - 8;
        pr_dtmvtolt := to_date(substr(vr_dsprotoc2,vr_pos,8),'DDMMYYYY');

        -- Posição inicial da "cdcooper"
        vr_pos := vr_pos - 3;
        pr_cdcooper := TO_NUMBER(substr(vr_dsprotoc2,vr_pos, 3));

        -- Posição inicial da "nrprotoc"
        pr_nrprotoc := TO_NUMBER(substr(vr_dsprotoc2,1, vr_pos));
      END IF;

      pr_is_valid:= 'OK';
    EXCEPTION
      WHEN OTHERS THEN
        pr_nrprotoc:= 0;
        pr_is_valid:= 'NOK';
        pr_dscritic:= 'Erro na GENE0006.pc_desmonta_protocolo -> ' || SQLERRM;
    END;
  END pc_desmonta_protocolo;


  /* Procedure para validar o protocolo de segurança */
  PROCEDURE pc_valida_protocolo(pr_cdcooper  IN INTEGER      --> Cooperativa
                               ,pr_cddopcao  IN VARCHAR2     --> Opcao
                               ,pr_nrdconta  IN INTEGER      --> Conta
                               ,pr_nrdocmto  IN INTEGER      --> Numero do Documento
                               ,pr_dtmvtolx  IN DATE         --> Data do Protocolo
                               ,pr_horproto  IN INTEGER      --> Hora do Protocolo
                               ,pr_minproto  IN INTEGER      --> Minuto do Protocolo
                               ,pr_segproto  IN INTEGER      --> Segundo do Protocolo
                               ,pr_vlprotoc  IN NUMBER       --> Valor do Protocolo
                               ,pr_dsprotoc  IN VARCHAR2     --> Protocolo
                               ,pr_nrseqaut  IN VARCHAR2     --> Sequencia de Autenticacao
                               ,pr_nmdcampo OUT VARCHAR2     --> Nome do Campo
                               ,pr_returnvl OUT VARCHAR2     --> Retorno "OK" / "NOK"
                               ,pr_msgretur OUT VARCHAR2     --> Mensagem de Retorno
                               ,pr_msgerror OUT VARCHAR2     --> Mensagem de Erro
                               ,pr_cdcritic OUT INTEGER      --> Codigo da Critica
                               ,pr_dscritic OUT VARCHAR2) IS --> Descricao da Critica
    -- ..........................................................................
    --
    --  Programa : pc_valida_protocolo     Antigo: b1wgen0127.Valida_Protocolo
    --  Sistema  : Processos Genéricos
    --  Sigla    : GENE
    --  Autor    : Douglas Quisinski
    --  Data     : Maio/2017.                   Ultima atualização: 
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: ---
    --   Objetivo  : Validar o protocolo gerado, com os dados informados em tela
    --
    --   Observação: Conversão da procedure b1wgen0127.Valida_Protocolo, com ajustes
    --               devido ao novo tipo de formatacao do protocolo, para evitar duplicidade
    --
    --   Alteracoes: 
    -- .............................................................................
  BEGIN
    DECLARE
      vr_tempotot INTEGER;
      
      -- Campos desmontados do protocolo no formato antigo
      vr_nrprotoc_des1 NUMBER;
      vr_cdcooper_des1 INTEGER;
      vr_dtmvtolt_des1 DATE;
      vr_hrtransa_des1 INTEGER;
      vr_nrsequen_des1 INTEGER;
      vr_is_valid1     VARCHAR2(5);
      
      -- Campos desmontados do protocolo no formato novo
      vr_nrprotoc_des2 NUMBER;
      vr_cdcooper_des2 INTEGER;
      vr_dtmvtolt_des2 DATE;
      vr_hrtransa_des2 INTEGER;
      vr_nrsequen_des2 INTEGER;
      vr_is_valid2     VARCHAR2(5);

      -- Calculo do protocolo (procedure multiplica os campos por 4 para totalizar)
      vr_nrprotoc_calc NUMBER;
      vr_dsprotoc_novo VARCHAR2(70);
      
      -- Erros
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(4000);
      vr_exec_err EXCEPTION;
      vr_exec_ok  EXCEPTION;
      vr_exec_nok EXCEPTION;
    
      -- Busca informacoes do associado
      CURSOR cr_crapass(p_cdcooper IN crapcop.cdcooper%TYPE,
                        p_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT ass.nrdconta
          FROM crapass ass
         WHERE ass.cdcooper = p_cdcooper
           AND ass.nrdconta = p_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
    
      -- Busca informacoes da cooperativa anterior
      CURSOR cr_craptco(p_cdcooper IN crapcop.cdcooper%TYPE
                       ,p_nrdconta IN crapass.nrdconta%TYPE) IS
        SELECT tco.nrctaant
              ,tco.cdcopant
          FROM craptco tco
         WHERE tco.cdcooper = p_cdcooper
           AND tco.nrdconta = p_nrdconta
           AND tco.tpctatrf = 1;
      rw_craptco cr_craptco%ROWTYPE;
      
    BEGIN
      
      pr_msgretur := NULL;
      pr_msgerror := NULL;
    
      IF pr_cddopcao <> 'C' THEN
        vr_cdcritic := 14;
        pr_nmdcampo := 'cddopcao';
        RAISE vr_exec_err;
      END IF;
    
      OPEN cr_crapass(p_cdcooper => pr_cdcooper
                     ,p_nrdconta => pr_nrdconta);
      FETCH cr_crapass
        INTO rw_crapass;
      -- Se nao encontrou o associado     
      IF cr_crapass%NOTFOUND THEN
        -- Apenas fecha cursor
        CLOSE cr_crapass;
        -- Fecha cursor
        vr_cdcritic := 9;
        pr_nmdcampo := 'nrdconta';
        RAISE vr_exec_err;
      END IF;
      -- Apenas fecha cursor
      CLOSE cr_crapass;
    
      -- Se o nro do documento nao foi preenchido
      IF pr_nrdocmto = 0 THEN
        -- Gera critica
        vr_cdcritic := 0;
        vr_dscritic := 'Numero de documento invalido.';
        pr_nmdcampo := 'nrdocmto';
        RAISE vr_exec_err;
      END IF;
    
      -- Se a data nao foi preenchida
      IF pr_dtmvtolx IS NULL THEN
        -- Gera critica
        vr_cdcritic := 0;
        vr_dscritic := 'Data incorreta.';
        pr_nmdcampo := 'dtmvtolt';
        RAISE vr_exec_err;
      END IF;
    
      -- Valida o campo de horas informado
      IF pr_horproto >= 24 THEN
        -- Gera critica
        vr_cdcritic := 0;
        vr_dscritic := 'Campo de Horas Invalido.';
        pr_nmdcampo := 'horproto';
        RAISE vr_exec_err;
      END IF;
    
      -- Valida o campo de minutos informado
      IF pr_minproto >= 60 THEN
        -- Gera critica
        vr_cdcritic := 0;
        vr_dscritic := 'Campo de Minutos Invalido.';
        pr_nmdcampo := 'minproto';
        RAISE vr_exec_err;
      END IF;
    
      -- Valida o campo de segundos informado
      IF pr_segproto >= 60 THEN
        -- Gera critica
        vr_cdcritic := 0;
        vr_dscritic := 'Campo de Segundos Invalido.';
        pr_nmdcampo := 'segproto';
        RAISE vr_exec_err;
      END IF;
    
      -- Verifica se o valor do protocolo foi preenchido
      IF pr_vlprotoc <= 0 THEN
        -- Gera critica
        pr_dscritic := 'Valor do protocolo nao pode ser 0,00.';
        pr_nmdcampo := 'vlprotoc';
        RAISE vr_exec_err;
      END IF;
    
      -- Verifica se o protocolo foi preenchido
      IF TRIM(pr_dsprotoc) IS NULL THEN
        -- Gera critica
        pr_dscritic := 'Protocolo nao informado';
        pr_nmdcampo := 'dsprotoc';
        RAISE vr_exec_err;
      END IF;
      
      -- Transforma os campos de horas, minutios e segundo
      vr_tempotot := TO_CHAR(pr_segproto
                           +(pr_minproto*60)
                           +(pr_horproto*3600));

      -- Calcular o total para o protocolo, com os parametros informados em tela
      GENE0006.pc_calcula_protocolo(pr_nrdconta => pr_nrdconta
                                   ,pr_nrdocmto => pr_nrdocmto
                                   ,pr_nrseqaut => pr_nrseqaut
                                   ,pr_vllanmto => pr_vlprotoc
                                   ,pr_nrdcaixa => 900 -- Esta fixo na b1wgen0127
                                   ,pr_nrprotoc => vr_nrprotoc_calc
                                   ,pr_dscritic => vr_dscritic);
            
      -- verificar se ocorreu erro no calculo do protocolo
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exec_err;
      END IF;
    
      -- Desmontar o protocolo para buscar a sequencia que foi gerado o boleto
      GENE0006.pc_desmonta_protocolo(pr_dsprotoc => pr_dsprotoc
                                    ,pr_tipo_protocolo => 2 -- Desmontar protocolo pelo tipo novo
                                    ,pr_nrprotoc => vr_nrprotoc_des2
                                    ,pr_cdcooper => vr_cdcooper_des2
                                    ,pr_dtmvtolt => vr_dtmvtolt_des2
                                    ,pr_hrtransa => vr_hrtransa_des2
                                    ,pr_nrsequen => vr_nrsequen_des2
                                    ,pr_is_valid => vr_is_valid2
                                    ,pr_dscritic => vr_dscritic);

      -- Desmontar o protocolo no formato antigo
      GENE0006.pc_desmonta_protocolo(pr_dsprotoc => pr_dsprotoc
                                    ,pr_tipo_protocolo => 1 -- Desmontar protocolo pelo tipo novo
                                    ,pr_nrprotoc => vr_nrprotoc_des1
                                    ,pr_cdcooper => vr_cdcooper_des1
                                    ,pr_dtmvtolt => vr_dtmvtolt_des1
                                    ,pr_hrtransa => vr_hrtransa_des1
                                    ,pr_nrsequen => vr_nrsequen_des1
                                    ,pr_is_valid => vr_is_valid1
                                    ,pr_dscritic => vr_dscritic);

      -- ############## VALIDACAO DO PROTOCOLO PELO FORMATO NOVO ############## --
      IF vr_is_valid2 = 'OK' THEN
        -- Criptografar o protocolo no formato novo
        GENE0006.pc_criptografa_protocolo(pr_cdcooper => pr_cdcooper
                                         ,pr_dtmvtolt => pr_dtmvtolx
                                         ,pr_hrtransa => vr_tempotot
                                         ,pr_sequence => vr_nrsequen_des2
                                         ,pr_nrprotoc => vr_nrprotoc_calc
                                         ,pr_tipo_protocolo => 2
                                         ,pr_dsprotoc => vr_dsprotoc_novo
                                         ,pr_dscritic => vr_dscritic);

        -- verificar se ocorreu erro na criptografia do protocolo
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exec_err;
        END IF;
      
        -- Verificar se os dois protocolos são iguais
        IF TRIM(vr_dsprotoc_novo) = TRIM(pr_dsprotoc) AND 
           TRIM(vr_dsprotoc_novo) IS NOT NULL         THEN
          RAISE vr_exec_ok;
        END IF;
      END IF;
    
      -- Se nao foi validado pelo formato novo, devemos validar o formato antigo
      -- ############## VALIDACAO DO PROTOCOLO PELO FORMATO ANTIGO ############## --
      IF vr_is_valid1 = 'OK' THEN
        -- Criptografar o protocolo no formato antigo
        GENE0006.pc_criptografa_protocolo(pr_cdcooper => pr_cdcooper
                                         ,pr_dtmvtolt => pr_dtmvtolx
                                         ,pr_hrtransa => vr_tempotot
                                         ,pr_sequence => 0
                                         ,pr_nrprotoc => vr_nrprotoc_calc
                                         ,pr_tipo_protocolo => 1
                                         ,pr_dsprotoc => vr_dsprotoc_novo
                                         ,pr_dscritic => vr_dscritic);

        -- verificar se ocorreu erro na criptografia do protocolo
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exec_err;
        END IF;
      
        -- Verificar se os dois protocolos são iguais
        IF TRIM(vr_dsprotoc_novo) = TRIM(pr_dsprotoc) AND 
           TRIM(vr_dsprotoc_novo) IS NOT NULL         THEN
          RAISE vr_exec_ok;
        END IF;
      END IF;
    
      -- Verifica se eh uma conta migrada, e se for, valida novamente
      -- com a cooperativa e conta antiga, pois o comprovante tambem
      -- pode ter sido migrado
      OPEN cr_craptco(p_cdcooper => pr_cdcooper
                     ,p_nrdconta => pr_nrdconta);
      FETCH cr_craptco INTO rw_craptco;
      -- Se nao encotra
      IF cr_craptco%NOTFOUND THEN
        -- Fecha Cursor
        CLOSE cr_craptco;
        RAISE vr_exec_nok;
      END IF;
      -- Apenas Fecha Cursor
      CLOSE cr_craptco;
      
      -- Como encontramos o protocolo de uma conta migrada temos que fazer as mesmas validações
      -- Montar o protocolo com os dados da tela, junto com o sequencial que encontramos na desmontagem
      GENE0006.pc_calcula_protocolo(pr_nrdconta => rw_craptco.nrctaant
                                   ,pr_nrdocmto => pr_nrdocmto
                                   ,pr_nrseqaut => pr_nrseqaut
                                   ,pr_vllanmto => pr_vlprotoc
                                   ,pr_nrdcaixa => 900 -- Esta fixo na b1wgen0127
                                   ,pr_nrprotoc => vr_nrprotoc_calc
                                   ,pr_dscritic => vr_dscritic);
        
      -- verificar se ocorreu erro no calculo do protocolo
      IF TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exec_err;
      END IF;
      
      IF vr_is_valid2 = 'OK' THEN
        -- Criptografar o protocolo no formato novo
        GENE0006.pc_criptografa_protocolo(pr_cdcooper => rw_craptco.cdcopant
                                         ,pr_dtmvtolt => pr_dtmvtolx
                                         ,pr_hrtransa => vr_tempotot
                                         ,pr_sequence => vr_nrsequen_des2
                                         ,pr_nrprotoc => vr_nrprotoc_calc
                                         ,pr_tipo_protocolo => 2
                                         ,pr_dsprotoc => vr_dsprotoc_novo
                                         ,pr_dscritic => vr_dscritic);

        -- verificar se ocorreu erro na criptografia do protocolo
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exec_err;
        END IF;
    
        -- Verificar se os dois protocolos são iguais
        IF TRIM(vr_dsprotoc_novo) = TRIM(pr_dsprotoc) AND 
           TRIM(vr_dsprotoc_novo) IS NOT NULL         THEN
          RAISE vr_exec_ok;
        END IF;
      END IF;
    
      -- Se nao foi validado pelo formato novo, devemos validar o formato antigo
      -- ############## VALIDACAO DO PROTOCOLO PELO FORMATO ANTIGO ############## --
      IF vr_is_valid1 = 'OK' THEN
        -- Criptografar o protocolo no formato antigo
        GENE0006.pc_criptografa_protocolo(pr_cdcooper => rw_craptco.cdcopant
                                         ,pr_dtmvtolt => pr_dtmvtolx
                                         ,pr_hrtransa => vr_tempotot
                                         ,pr_sequence => 0
                                         ,pr_nrprotoc => vr_nrprotoc_calc
                                         ,pr_tipo_protocolo => 1
                                         ,pr_dsprotoc => vr_dsprotoc_novo
                                         ,pr_dscritic => vr_dscritic);

        -- verificar se ocorreu erro na criptografia do protocolo
        IF TRIM(vr_dscritic) IS NOT NULL THEN
          RAISE vr_exec_err;
        END IF;
      
        -- Verificar se os dois protocolos são iguais
        IF TRIM(vr_dsprotoc_novo) = TRIM(pr_dsprotoc) AND 
           TRIM(vr_dsprotoc_novo) IS NOT NULL         THEN
          RAISE vr_exec_ok;
        END IF;
      END IF;
      
      -- Se nao eh um protocolo valido, enviamos mensagem de "Protocolo incorreto"
      RAISE vr_exec_nok;
    EXCEPTION
      WHEN vr_exec_ok  THEN
        -- A execução ocorreu com sucesso
        pr_returnvl := 'OK';
        pr_msgretur := 'Protocolo informado esta correto.';

      WHEN vr_exec_nok  THEN
        -- A execução ocorreu com sucesso
        pr_returnvl := 'OK';
        pr_msgerror := 'Protocolo informado esta incorreto.';

      
      WHEN vr_exec_err THEN
        IF vr_cdcritic > 0 THEN
          IF TRIM(vr_dscritic) IS NULL THEN
            vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          ELSE
            vr_dscritic := vr_dscritic || ' - ' ||
                           gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
          END IF;
        END IF;
      
        pr_returnvl := 'NOK';
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      
      WHEN OTHERS THEN
        
        pr_returnvl := 'NOK';
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na GENE0006.pc_valida_protocolo -> ' ||
                       SQLERRM;
    END;
  END pc_valida_protocolo;
  
END GENE0006;
/
