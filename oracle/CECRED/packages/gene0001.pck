CREATE OR REPLACE PACKAGE CECRED.GENE0001 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : GENE0001
  --  Sistema  : Rotinas genéricas
  --  Sigla    : GENE
  --  Autor    : Marcos E. Martini - Supero
  --  Data     : Novembro/2012.                   Ultima atualizacao: 24/10/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas genéricas focando em tratamento de seções e SO e paralelismos

  -- Alterações:
  -- 23/08/2013 - Inclusão de novo procedimento para chamar o LP
  --              no sistema Operacional (Marcos-Supero)
  -- 28/07/2013 - Inclusão do Tipo CONVENIO no array para nome origem do módulo SD154496
  -- (Vanessa Klein)
  -- 02/02/2016 - Ajustado o TYPE typ_des_dorigens incluso duas novas origens (Daniel)
  --
  -- 11/11/2016 - Inclusao da origem MOBILE e ACORDO no type de origens. PRJ335 - Analise Fraudes(Odirlei-AMcom)
  --  
  -- 24/01/2016 - Incluido Origem ANTIFRAUDE. PRJ335 - Analise de fraude (Odirlei-AMcom)
  --
  --
  --  08/06/2017 - #665812 le cadastro de critica CRAPCRI (Belli-Envolti)
  --  09/06/2017 - #660327 Criada a procudere pc_set_moduloLe informação do modulo  (Belli-Envolti)
  --  09/06/2017 - #660327 informa acesso dispara a procudere pc_set_modulo  (Belli-Envolti)
  --  16/06/2017 - #660327 Alteração incluindo num comando setar a forma de data e o decimal(Belli-Envolti)
  --  29/06/2017 - #660306 Alteração incluindo a possibilidade de setar somente a Action do Oracle (Belli-Envolti)
  --  24/10/2017 - #714566 Procedimento para verificar/controlar a execução de programas (Belli-Envolti)
  --
  --  14/12/2017 - Criação nova funçao para busca de quantidade total de paralelismo por cooperativa
  --               e por programa - Projeto Ligeirinho. (Jonatas Jaqmam - AMcom)
  --  18/12/2017 - Criação nova funçao para busca de quantidade total registro por commit
  --               Projeto Ligeirinho. (Jonatas Jaqmam - AMcom)  
  ---------------------------------------------------------------------------------------------------------------

  /** ---------------------------------------------------- **/
  /** Variavel para geracao de log - Origem da Solicitacao **/
  /** Cod = Descricao                                      **/
  /**  1  = DEP. A VISTA                                   **/
  /**  2  = CAPITAL                                        **/
  /**  3  = EMPRESTIMOS                                    **/
  /**  4  = DIGITACAO                                      **/
  /**  5  = GENERICO                                       **/
  /**  6  = PROCESSOS                                      **/
  /**  7  = PARAMETRIZACAO                                 **/
  /**  8  = SOLICITACOES                                   **/
  /**  9  = CADASTROS                                      **/
  /**  10 = CONVENIOS                                      **/
  /** ---------------------------------------------------- **/
  -- Definicao do tipo de array para nome origem do módulo
  TYPE typ_tab_nmmodulo IS VARRAY(10) OF VARCHAR2(15);
  -- Vetor de memória com as origens do módulo
  vr_vet_nmmodulo typ_tab_nmmodulo := typ_tab_nmmodulo('DEP. A VISTA'
                                                      ,'CAPITAL'
                                                      ,'EMPRESTIMOS'
                                                      ,'DIGITACAO'
                                                      ,'GENERICO'
                                                      ,'PROCESSOS'
                                                      ,'PARAMETRIZACAO'
                                                      ,'SOLICITACOES'
                                                      ,'CADASTROS'
                                                      ,'CONVENIOS');

  /** ------------------------------------------------------------**/
  /** Variavel para geracao de log - Origem da Solicitacao     **/
  /**                                                          **/
  /** -> Origem = 1 - AYLLOS                                   **/
  /** -> Origem = 2 - CAIXA                                    **/
  /** -> Origem = 3 - INTERNET                                 **/
  /** -> Origem = 4 - CASH                                     **/
  /** -> Origem = 5 - INTRANET (AYLLOS WEB)                    **/
  /** -> Origem = 6 - URA                                      **/
  /** -> Origem = 7 - PROCESSO (PROCESSO BATCH)                **/
  /** -> Origem = 8 - MENSAGERIA (DEBITO ONLINE CARTAO BANCOOB)**/
  /** -> Origem = 9 - ESTEIRA (WEBSERVICE ESTEIRA DE CREDITO)     **/
  /** -> Origem = 10 - MOBILE                                     **/
  /** -> Origem = 11 - ACORDO (WEBSERVICE DE ACORDOS)             **/
  /** -> Origem = 12 - ANTIFRAUDE (WEBSERVICE ANALISE ANTIFRAUDE) 	**/
  /** -> Origem = 13 - COBRANCA (RENOVACAO AUTOMATICA) 	**/
  /** ---------------------------------------------------------**/

  TYPE typ_des_dorigens IS VARRAY(13) OF VARCHAR2(13);
  vr_vet_des_origens typ_des_dorigens := typ_des_dorigens('AYLLOS','CAIXA','INTERNET','CASH','AYLLOS WEB','URA','PROCESSO','MENSAGERIA','ESTEIRA','MOBILE','ACORDO','ANTIFRAUDE','COBRANCA');


  /** ---------------------------------------------------- **/
  /** Variavel para Meses do Ano                           **/
  /** ---------------------------------------------------- **/
  TYPE typ_des_nmmesano IS VARRAY(12) OF VARCHAR2(09);
  vr_vet_nmmesano typ_des_nmmesano := typ_des_nmmesano('JANEIRO','FEVEREIRO','MARCO',
                                                       'ABRIL','MAIO','JUNHO','JULHO',
                                                       'AGOSTO','SETEMBRO','OUTUBRO',
                                                       'NOVEMBRO','DEZEMBRO');

  -- Definição da tipo de registro que vai
  -- compreender as informações de lock em tabelas
  TYPE typ_reg_locktab IS
    RECORD (loginusr V$SESSION.OSUSER%TYPE
           ,nmusuari VARCHAR2(600)
           ,dsdevice V$SESSION.TERMINAL%TYPE
           ,dtconnec V$SESSION.LOGON_TIME%TYPE);
  -- Tipo tabela para comportar os registros
  -- de locks em tabelas do banco de dados
  TYPE typ_tab_locktab IS
    TABLE OF typ_reg_locktab
    INDEX BY BINARY_INTEGER;

  /* Informação do modulo em execução na sessão */
  PROCEDURE pc_informa_acesso(pr_module IN VARCHAR2
                             ,pr_action IN VARCHAR2 DEFAULT NULL);

  /* Função que retorna o database name conectado */
  FUNCTION fn_database_name RETURN VARCHAR2;

  /* Função para retorno do OSUSer conectado a seção */
  FUNCTION fn_OSuser RETURN VARCHAR2;

  /* Busca dos usuários que estão lockando a tabela */
  PROCEDURE pc_ver_lock(pr_nmtabela     IN VARCHAR2                    --> Nome da tabela
                       ,pr_nrdrecid     IN NUMBER DEFAULT NULL         --> Recid da tabela
                       ,pr_des_reto    OUT VARCHAR2                     --> Retorno (OK - Sem Lock, NOK - Com Lock)
                       ,pt_tab_locktab OUT gene0001.typ_tab_locktab); --> Vetor com usuários do lock

  /* Função que retorna os parâmetros de sistema */
  FUNCTION fn_param_sistema(pr_nmsistem IN crapprm.nmsistem%TYPE
                           ,pr_cdcooper IN crapprm.cdcooper%TYPE DEFAULT 0 --> Zero é utilizado para todas as COOPs
                           ,pr_cdacesso IN crapprm.cdacesso%TYPE)          --> Chave de acesso do parametro
                                                                  RETURN crapprm.dsvlrprm%TYPE;

  /* Função que retorna os parâmetros de sistema */
  PROCEDURE pc_param_sistema(pr_nmsistem  IN crapprm.nmsistem%TYPE
                            ,pr_cdcooper  IN crapprm.cdcooper%TYPE DEFAULT 0 --> Zero é utilizado para todas as COOPs
                            ,pr_cdacesso  IN crapprm.cdacesso%TYPE          --> Chave de acesso do parametro
                            ,pr_dsvlrprm OUT crapprm.dsvlrprm%TYPE);

  /* Mostrar o texto das criticas na tela de acordo com o ocorrido. */
  FUNCTION fn_busca_critica(pr_cdcritic IN crapcri.cdcritic%TYPE DEFAULT 0
                           ,pr_dscritic IN crapcri.dscritic%TYPE DEFAULT NULL) RETURN VARCHAR2;

  /* Mostrar mensagem dbms_output.put_line */
  PROCEDURE pc_print(pr_des_mensag IN VARCHAR2);

  /* Função que retorna o caminho fisico de um diretório cfme a cooperativa passada */
  FUNCTION fn_diretorio(pr_tpdireto IN VARCHAR2
                       ,pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nmsubdir IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

  /* Procedure para listar arquivos com controle de erros */
  PROCEDURE pc_lista_arquivos(pr_path     IN VARCHAR2
                             ,pr_pesq     IN VARCHAR2 DEFAULT NULL
                             ,pr_listarq  OUT VARCHAR2
                             ,pr_des_erro OUT VARCHAR2);

  /* Procedimento para listar arquivos contidos em uma pasta - interface para classe Java com opção de filtro */
  PROCEDURE pc_lista_arquivos(pr_lista_arquivo OUT TYP_SIMPLESTRINGARRAY
                             ,pr_path          IN VARCHAR2
                             ,pr_pesq          IN VARCHAR2);

  /* Rotina para executar comandos Host pendentes de execução na tabela CRAPCSO */
  PROCEDURE pc_process_OSCommand_penden(pr_nrseqsol  IN crapcso.nrseqsol%TYPE DEFAULT NULL
                                       ,pr_typ_saida  OUT VARCHAR2
                                       ,pr_des_saida  OUT VARCHAR2);

  /* Executar um comando no Host usando a interface com saída */
  PROCEDURE pc_OScommand(pr_typ_comando IN VARCHAR2
                        ,pr_des_comando IN VARCHAR2
                        ,pr_flg_aguard  IN VARCHAR2 DEFAULT 'S' -- O processo deverá aguardar a execução do comando
                        ,pr_typ_saida  OUT VARCHAR2
                        ,pr_des_saida  OUT VARCHAR2);

  /* Executar um comando no Host usando a interface sem o retorno */
  PROCEDURE pc_OScommand(pr_typ_comando IN VARCHAR2
                        ,pr_des_comando IN VARCHAR2
                        ,pr_flg_aguard  IN VARCHAR2 DEFAULT 'S'); -- O processo deverá aguardar a execução do comando

  /* Executar um comando no Host usando a interface com saída */
  PROCEDURE pc_OScommand_Perl(pr_des_comando IN VARCHAR2
                             ,pr_flg_aguard  IN VARCHAR2 DEFAULT 'S' -- O processo deverá aguardar a execução do comando
                             ,pr_typ_saida  OUT VARCHAR2
                             ,pr_des_saida  OUT VARCHAR2);

  /* Executar um comando no Host usando a interface sem o retorno */
  PROCEDURE pc_OScommand_Perl(pr_des_comando IN VARCHAR2
                             ,pr_flg_aguard  IN VARCHAR2 DEFAULT 'S'); -- O processo deverá aguardar a execução do comando

  /* Executar o comando LP no Host usando a interface com saída */
  PROCEDURE pc_OScommand_LP(pr_des_comando IN VARCHAR2
                           ,pr_flg_aguard  IN VARCHAR2 DEFAULT 'S' -- O processo deverá aguardar a execução do comando
                           ,pr_typ_saida  OUT VARCHAR2
                           ,pr_des_saida  OUT VARCHAR2);

  /* Executar o comando LP no Host usando a interface sem o retorno */
  PROCEDURE pc_OScommand_LP(pr_des_comando IN VARCHAR2
                           ,pr_flg_aguard  IN VARCHAR2 DEFAULT 'S'); -- O processo deverá aguardar a execução do comando

  /* Executar um comando no Host usando a interface com saída */
  PROCEDURE pc_OScommand_Shell(pr_des_comando IN VARCHAR2
                              ,pr_flg_aguard  IN VARCHAR2 DEFAULT 'S' -- O processo deverá aguardar a execução do comando
                              ,pr_typ_saida  OUT VARCHAR2
                              ,pr_des_saida  OUT VARCHAR2);

  /* Executar um comando no Host usando a interface sem o retorno */
  PROCEDURE pc_OScommand_Shell(pr_des_comando IN VARCHAR2
                              ,pr_flg_aguard  IN VARCHAR2 DEFAULT 'S'); -- O processo deverá aguardar a execução do comando

  /* Definição de tabela de memória que compreende a mesma estrutura da craperr */
  TYPE typ_reg_erro IS
    RECORD(cdcooper       craperr.cdcooper%TYPE
          ,cdagenci       craperr.cdagenci%TYPE
          ,nrdcaixa       craperr.nrdcaixa%TYPE
          ,nrsequen       craperr.nrsequen%TYPE
          ,cdcritic       craperr.cdcritic%TYPE
          ,dscritic       VARCHAR2(4000)
          ,erro           craperr.erro%TYPE
          ,progress_recid craperr.progress_recid%TYPE);
  TYPE typ_tab_erro IS
    TABLE OF typ_reg_erro
    INDEX BY BINARY_INTEGER;
   /* Vetor para armazenar as informações de erro */
  vr_tab_erro typ_tab_erro;

  /* Retorno de erro da BO */
  PROCEDURE pc_gera_erro(pr_cdcooper IN craperr.cdcooper%TYPE
                        ,pr_cdagenci IN craperr.cdagenci%TYPE
                        ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE
                        ,pr_nrsequen IN craperr.nrsequen%TYPE
                        ,pr_cdcritic IN craperr.cdcritic%TYPE
                        ,pr_dscritic IN OUT craperr.dscritic%TYPE
                        ,pr_tab_erro IN OUT GENE0001.typ_tab_erro);

  /* Gerar ou ler xml da temptable de erros*/
  PROCEDURE pc_xml_tab_erro(pr_tab_erro   IN OUT GENE0001.typ_tab_erro, --> TempTable de erro
                            pr_xml_erro   IN OUT CLOB,                  --> XML dos registros da temptable de erro
                            pr_tipooper   IN INTEGER,                   --> Tipo de operação, 1 - Gerar XML, 2 --Gerar pltable
                            pr_dscritic   OUT VARCHAR2);                --> descrição da critica do erro

  /* Inclusão de log com retorno do rowid */
  PROCEDURE pc_gera_log(pr_cdcooper IN craplgm.cdcooper%TYPE
                       ,pr_cdoperad IN craplgm.cdoperad%TYPE
                       ,pr_dscritic IN craplgm.dscritic%TYPE
                       ,pr_dsorigem IN craplgm.dsorigem%TYPE
                       ,pr_dstransa IN craplgm.dstransa%TYPE
                       ,pr_dttransa IN craplgm.dttransa%TYPE
                       ,pr_flgtrans IN craplgm.flgtrans%TYPE
                       ,pr_hrtransa IN craplgm.hrtransa%TYPE
                       ,pr_idseqttl IN craplgm.idseqttl%TYPE
                       ,pr_nmdatela IN craplgm.nmdatela%TYPE
                       ,pr_nrdconta IN craplgm.nrdconta%TYPE
                       ,pr_nrdrowid OUT ROWID);

  /* Chamada para ser usada no progress
     Inclusão de log com retorno do rowid */
  PROCEDURE pc_gera_log_prog (pr_cdcooper IN craplgm.cdcooper%TYPE
                             ,pr_cdoperad IN craplgm.cdoperad%TYPE
                             ,pr_dscritic IN craplgm.dscritic%TYPE
                             ,pr_dsorigem IN craplgm.dsorigem%TYPE
                             ,pr_dstransa IN craplgm.dstransa%TYPE
                             ,pr_dttransa IN craplgm.dttransa%TYPE
                             ,pr_flgtrans IN craplgm.flgtrans%TYPE
                             ,pr_hrtransa IN craplgm.hrtransa%TYPE
                             ,pr_idseqttl IN craplgm.idseqttl%TYPE
                             ,pr_nmdatela IN craplgm.nmdatela%TYPE
                             ,pr_nrdconta IN craplgm.nrdconta%TYPE
                             ,pr_nrrecid OUT craplgm.progress_recid%TYPE);

  /* Inclusão de log a nível de item  */
  PROCEDURE pc_gera_log_item(pr_nrdrowid IN ROWID
                            ,pr_nmdcampo IN craplgi.nmdcampo%TYPE
                            ,pr_dsdadant IN craplgi.dsdadant%TYPE
                            ,pr_dsdadatu IN craplgi.dsdadatu%TYPE);

  /* Chamada para ser usada no progress
     Inclusão de log a nível de item  */
  PROCEDURE pc_gera_log_item_prog (pr_nrrecid  IN craplgm.progress_recid%TYPE
                                  ,pr_nmdcampo IN craplgi.nmdcampo%TYPE
                                  ,pr_dsdadant IN craplgi.dsdadant%TYPE
                                  ,pr_dsdadatu IN craplgi.dsdadatu%TYPE);

  /* Procedimento para gravar log na tabela craplog */
  PROCEDURE pc_gera_craplog(pr_cdcooper IN craplog.cdcooper%TYPE
                           ,pr_nrdconta IN craplog.nrdconta%TYPE
                           ,pr_cdoperad IN craplog.cdoperad%TYPE
                           ,pr_dstransa IN craplog.dstransa%TYPE
                           ,pr_cdprogra IN craplog.cdprogra%TYPE);

  /* Procedimento que separa o path e o nome do arquivo de um path completo */
  PROCEDURE pc_separa_arquivo_path(pr_caminho  IN VARCHAR2
                                  ,pr_direto  OUT VARCHAR2
                                  ,pr_arquivo OUT VARCHAR2);

  /* Procedimento para abertura de arquivo fisico */
  PROCEDURE pc_abre_arquivo(pr_nmdireto IN VARCHAR2            --> Diretório do arquivo
                           ,pr_nmarquiv IN VARCHAR2            --> Nome do arquivo
                           ,pr_tipabert IN VARCHAR2            --> Modo de abertura (R,W,A)
                           ,pr_flaltper IN INTEGER DEFAULT 1   --> Altera permissão de acesso do arquivo (0 - Não altera / 1 - Altera)
                           ,pr_utlfileh IN OUT NOCOPY UTL_FILE.file_type --> Handle do arquivo aberto
                           ,pr_des_erro OUT VARCHAR2);         --> Saída de erros

  /* Procedimento para abertura de arquivo fisico passando o caminho completo */
  PROCEDURE pc_abre_arquivo(pr_nmcaminh IN VARCHAR2            --> Nome do caminho completo
                           ,pr_tipabert IN VARCHAR2            --> Modo de abertura (R,W,A)
                           ,pr_utlfileh IN OUT NOCOPY UTL_FILE.file_type --> Handle do arquivo aberto
                           ,pr_des_erro OUT VARCHAR2);         --> Saída de erros

  /* Procedimento para fechamento de arquivo fisico */
  PROCEDURE pc_fecha_arquivo(pr_utlfileh IN OUT NOCOPY UTL_FILE.file_type); --> Handle do arquivo aberto

  /* Procedimento para escrita em arquivo fisico */
  PROCEDURE pc_escr_linha_arquivo(pr_utlfileh  IN OUT NOCOPY UTL_FILE.file_type --> Handle do arquivo aberto
                                 ,pr_des_text  IN VARCHAR2);                    --> Texto para escrita

  /* Procedimento para escrita em arquivo fisico sem quebrar a linha */
  PROCEDURE pc_escr_texto_arquivo(pr_utlfileh  IN OUT NOCOPY UTL_FILE.file_type --> Handle do arquivo aberto
                                 ,pr_des_text  IN VARCHAR2);                    --> Texto para escrita

  /* Função para leitura de arquivo fisico */
  PROCEDURE pc_le_linha_arquivo(pr_utlfileh  IN OUT NOCOPY UTL_FILE.file_type --> Handle do arquivo aberto
                               ,pr_des_text OUT VARCHAR2);                    --> Texto lido

  /* Função para testar a existência de um arquivo */
  FUNCTION fn_exis_arquivo(pr_caminho IN VARCHAR2) RETURN BOOLEAN;

  /* Verifica se existe diretorio */
  FUNCTION fn_exis_diretorio(pr_caminho IN VARCHAR2) RETURN BOOLEAN;

  /* Retornar o tamanho (bytes) do arquivo */
  FUNCTION fn_tamanho_arquivo(pr_caminho IN VARCHAR2) RETURN NUMBER;

  /* Função para retornar a extensão de um arquivo */
  FUNCTION fn_extensao_arquivo(pr_arquivo IN VARCHAR2) RETURN VARCHAR2;

  /* Geração de ID para paralelismo */
  FUNCTION fn_gera_ID_paralelo RETURN INTEGER;

  /* Inicializa os controles do paralelismo */
  PROCEDURE pc_ativa_paralelo(pr_idparale IN crappar.idparale%TYPE
                             ,pr_idprogra IN crappar.idprogra%TYPE
                             ,pr_des_erro OUT VARCHAR2);

  /* Procedure para aguardar a finalizacao dos programas em paralelo */
  PROCEDURE pc_aguarda_paralelo(pr_idparale IN crappar.idparale%TYPE
                               ,pr_qtdproce IN NUMBER
                               ,pr_des_erro OUT VARCHAR2);

  /* Inicializa os controles do paralelismo */
  PROCEDURE pc_encerra_paralelo(pr_idparale IN crappar.idparale%TYPE
                               ,pr_idprogra IN crappar.idprogra%TYPE
                               ,pr_des_erro OUT VARCHAR2);

  /* Incluir log de Jobs executados no Banco */
  PROCEDURE pc_gera_log_job(pr_cdcooper IN crapcop.cdcooper%TYPE
                           ,pr_des_log IN VARCHAR2);

  /* Rotina para submeter um Job ao Banco */
  PROCEDURE pc_submit_job(pr_cdcooper  IN crapcop.cdcooper%TYPE          --> Código da cooperativa
                         ,pr_cdprogra  IN VARCHAR2                       --> Código do programa
                         ,pr_dsplsql   IN VARCHAR2                       --> Bloco PLSQL a executar
                         ,pr_dthrexe   IN TIMESTAMP WITH TIME ZONE DEFAULT SYSTIMESTAMP --> Data/Hora de execução
                         ,pr_interva   IN VARCHAR2 DEFAULT NULL          --> Função para calculo da próxima execução, ex: 'sysdate+1'
                         ,pr_jobname IN OUT VARCHAR2                     --> Nome único para o Job
                         ,pr_des_erro OUT VARCHAR2);                     --> Saída com erro

  /* Rotina para gravar log de item campo a campo */
  PROCEDURE pc_grava_campos_log_item(pr_nmtabela IN VARCHAR2                   --> Nome da tabela
                                    ,pr_rowidlgm IN ROWID                      --> Numero do ROWID do registro que foi inserido na CRAPLGM
                                    ,pr_rowidtab IN ROWID                      --> Numero do ROWID do registro que foi inserido na CRAPLGM
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE   --> Codigo da critica
                                    ,pr_dscritic OUT crapcri.dscritic%TYPE); --> Descricao da critica

  /* Listagem das cooperativas */
  PROCEDURE pc_lista_cooperativas (pr_des_lista OUT VARCHAR2);
  
  /* Verificacao do controle do batch por agencia ou convenio */
  PROCEDURE pc_verifica_batch_controle(pr_cdcooper    IN tbgen_batch_controle.cdcooper%TYPE    -- Codigo da Cooperativa
                                      ,pr_cdprogra    IN tbgen_batch_controle.cdprogra%TYPE    -- Codigo do Programa
                                      ,pr_dtmvtolt    IN tbgen_batch_controle.dtmvtolt%TYPE    -- Data de Movimento
                                      ,pr_tpagrupador IN tbgen_batch_controle.tpagrupador%TYPE -- Tipo de Agrupador (1-PA/ 2-Convenio)
                                      ,pr_cdagrupador IN tbgen_batch_controle.cdagrupador%TYPE -- Codigo do agrupador conforme (tpagrupador)
                                      ,pr_nrexecucao  IN tbgen_batch_controle.nrexecucao%TYPE  -- Numero de identificacao da execucao do programa
                                      ,pr_cdrestart  OUT tbgen_batch_controle.cdrestart%TYPE   -- Controle do registro de restart em caso de erro na execucao
                                      ,pr_insituacao OUT tbgen_batch_controle.insituacao%TYPE  -- Situacao da execucao (1-Executado erro/ 2-Executado sucesso)
                                      ,pr_cdcritic   OUT crapcri.cdcritic%TYPE                 -- Codigo da critica
                                      ,pr_dscritic   OUT crapcri.dscritic%TYPE);               -- Descricao da critica

  /* Grava o controle do batch por agencia ou convenio */
  PROCEDURE pc_grava_batch_controle(pr_cdcooper    IN tbgen_batch_controle.cdcooper%TYPE    -- Codigo da Cooperativa
                                   ,pr_cdprogra    IN tbgen_batch_controle.cdprogra%TYPE    -- Codigo do Programa
                                   ,pr_dtmvtolt    IN tbgen_batch_controle.dtmvtolt%TYPE    -- Data de Movimento
                                   ,pr_tpagrupador IN tbgen_batch_controle.tpagrupador%TYPE -- Tipo de Agrupador (1-PA/ 2-Convenio)
                                   ,pr_cdagrupador IN tbgen_batch_controle.cdagrupador%TYPE -- Codigo do agrupador conforme (tpagrupador)
                                   ,pr_cdrestart   IN tbgen_batch_controle.cdrestart%TYPE   -- Controle do registro de restart em caso de erro na execucao
                                   ,pr_nrexecucao  IN tbgen_batch_controle.nrexecucao%TYPE  -- Numero de identificacao da execucao do programa
                                   ,pr_idcontrole OUT tbgen_batch_controle.idcontrole%TYPE  -- ID de Controle
                                   ,pr_cdcritic   OUT crapcri.cdcritic%TYPE                 -- Codigo da critica
                                   ,pr_dscritic   OUT crapcri.dscritic%TYPE);               -- Descricao da critica

  /* Finaliza o controle do batch por agencia ou convenio */
  PROCEDURE pc_finaliza_batch_controle(pr_idcontrole IN tbgen_batch_controle.idcontrole%TYPE -- ID de Controle
                                      ,pr_cdcritic  OUT crapcri.cdcritic%TYPE                -- Codigo da critica
                                      ,pr_dscritic  OUT crapcri.dscritic%TYPE);              -- Descricao da critica
  

  -- Definição de tabela de memória que compreende a mesma estrutura da crapcri
  -- Chamado 665812
  TYPE typ_reg_crapcri IS
    RECORD(
     cdcritic            crapcri.cdcritic%TYPE
    ,dscritic            crapcri.dscritic%TYPE
    ,progress_recid      crapcri.progress_recid%TYPE
    ,tpcritic            crapcri.tpcritic%TYPE
    ,flgchama            crapcri.flgchama%TYPE);

  TYPE typ_tab_crapcri IS
    TABLE OF typ_reg_crapcri
    INDEX BY BINARY_INTEGER;

  -- Vetor para armazenar as informações de crapcri
  vr_tab_crapcri typ_tab_crapcri; 
  
  /* Retorno do cadastro de critica crapcri */
  -- Chamado 665812
  PROCEDURE pc_le_crapcri(pr_cdcritic     IN  crapcri.cdcritic%TYPE
                         ,pr_tab_crapcri  OUT GENE0001.typ_tab_crapcri
                         ,pr_dsretorno    OUT varchar2
                         ,pr_cdretorno    OUT number);

  /* Informação do modulo em execução na sessão */
  -- Chamado 660327
  PROCEDURE pc_set_modulo(pr_module IN VARCHAR2
                         ,pr_action IN VARCHAR2 DEFAULT NULL);

                         
  /* Procedimento para verificar/controlar a execução de programas */
  -- Chamado 714566
  PROCEDURE pc_controle_exec ( pr_cdcooper  IN crapcop.cdcooper%TYPE        --> Código da coopertiva
                              ,pr_cdtipope  IN VARCHAR2                     --> Tipo de operacao I-incrementar e C-Consultar
                              ,pr_dtmvtolt  IN DATE                         --> Data do movimento
                              ,pr_cdprogra  IN crapprg.cdprogra%TYPE        --> Codigo do programa
                              ,pr_flultexe OUT INTEGER                       --> Retorna se é a ultima execução do procedimento
                              ,pr_qtdexec  OUT INTEGER                       --> Retorna a quantidade
                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE        --> Codigo da critica de erro
                              ,pr_dscritic OUT VARCHAR2);                   --> descrição do erro se ocorrer                         

  /* Informação de quantidade máxima de jobs para o paralelismo */
  FUNCTION fn_retorna_qt_paralelo( pr_cdcooper  IN crapcop.cdcooper%TYPE    --> Código da coopertiva
                                  ,pr_cdprogra  IN crapprg.cdprogra%TYPE)   --> Codigo do programa
           RETURN tbgen_batch_param.qtparalelo%TYPE; 
  
  /* Informação de quantidade máxima número de registro para realizar commit por transação*/
  FUNCTION fn_retorna_qt_reg_commit( pr_cdcooper  IN crapcop.cdcooper%TYPE    --> Código da coopertiva
                                   , pr_cdprogra  IN crapprg.cdprogra%TYPE)   --> Codigo do programa
           RETURN tbgen_batch_param.qtreg_transacao%TYPE;

  /* Informação de registro para restart da execução da rotina*/
  FUNCTION fn_retorna_restart(pr_cdcooper    IN tbgen_batch_controle.cdcooper%TYPE,    --> Código da coopertiva
                              pr_cdprogra    IN tbgen_batch_controle.cdprogra%TYPE,    --> Codigo do programa
                              pr_nrexecucao  IN tbgen_batch_controle.nrexecucao%TYPE,  --> Número da execução do programa
                              pr_cdagrupador IN tbgen_batch_controle.cdagrupador%TYPE) --Código agrupadar do job paralelo
           RETURN tbgen_batch_controle.cdrestart%TYPE;
           
  FUNCTION fn_ret_qt_erro_paralelo(pr_cdcooper    IN tbgen_batch_controle.cdcooper%TYPE    -- Codigo da Cooperativa
                                  ,pr_cdprogra    IN tbgen_batch_controle.cdprogra%TYPE    -- Codigo do Programa
                                  ,pr_dtmvtolt    IN tbgen_batch_controle.dtmvtolt%TYPE    -- Data de Movimento
                                  ,pr_tpagrupador IN tbgen_batch_controle.tpagrupador%TYPE -- Tipo de Agrupador (1-PA/ 2-Convenio)
                                  ,pr_nrexecucao  IN tbgen_batch_controle.nrexecucao%TYPE  -- Numero de identificacao da execucao do programa
                                  ) RETURN NUMBER;
--           
END GENE0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.GENE0001 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : GENE0001
  --  Sistema  : Rotinas genéricas
  --  Sigla    : GENE
  --  Autor    : Marcos E. Martini - Supero
  --  Data     : Novembro/2012.                   Ultima atualizacao: 24/10/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas genéricas focando em tratamento de seções e SO e paralelismos
  --
  -- Alterações: 06/04/2016 - Ajuste na pc_OScommand para verificar via parametro o modo
  --                          de execucao do comando shell para o comando RM
  --                          (shell, shell_remoto ou nao executar) (Odirlei-AMcom) 
  --
  --             10/06/2016 - Ajuste para retirar a chamada da função dbms_scheduler.generate_job_name
  --                          ao pegar o nome do JOB a ser criado
  --                         (Adriano - SD 464856).
  --
  --             12/01/2017 - #551192 Na função fn_busca_critica, mudança para parâmetros opcionais cd e 
  --                          dscritic para centralizar a lógica de captura dos erros (Carlos) 
  --
  --             09/05/2017 - #660297 Alterado o tipo do parâmetro pr_cdprogra de crapprg.cdprogra para 
  --                          VARCHAR2 na rotina pc_submit_job (Carlos)
  --
  --             08/06/2017 - #665812 le cadastro de critica CRAPCRI (Belli-Envolti)
  --             09/06/2017 - #660327 Criada a procudere pc_set_moduloLe informação do modulo (Belli-Envolti)
  --             09/06/2017 - #660327 informa acesso dispara a procedure pc_set_modulo (Belli-Envolti)
  --             16/06/2017 - #660327 Alteração incluindo num comando setar a forma de data e o decimal (Belli-Envolti)
  --             29/06/2017 - #660306 Alteração incluindo a possibilidade de setar somente a Action do Oracle (Belli-Envolti)
  --
  --             30/08/2017 - Ajuste para verificar se deve mudar permissões do arquivo ou não 
  --                          (Adriano - SD 734960).
  --
  --             24/10/2017 - #714566 Procedimento para verificar/controlar a execução de programas (Belli-Envolti)
  --
  --             14/12/2017 - Criação nova funçao para busca de quantidade total de paralelismo por cooperativa
  --                          e por programa - Projeto Ligeirinho. (Jonatas Jaqmam - AMcom)  
  --
  --             18/12/2017 - Criação nova funçao para busca de quantidade total registro por commit
  --                          Projeto Ligeirinho. (Jonatas Jaqmam - AMcom)   
  ---------------------------------------------------------------------------------------------------------------

  -- Busca do diretório conforme a cooperativa conectada
  CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.dsdircop
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;

  /* Tratamento de erro */
  vr_des_erro VARCHAR2(32000);
  vr_exc_erro EXCEPTION;

  /* Informação do modulo em execução na sessão */
  PROCEDURE pc_informa_acesso(pr_module IN VARCHAR2
                             ,pr_action IN VARCHAR2 DEFAULT NULL) IS
    -- ..........................................................................
    --
    --  Programa : pc_informa_acesso
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : 
    --  Data     :                                  Ultima atualizacao: 09/06/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia  : Sempre que chamado por outros programas.
    --   Objetivo    : Setar padrões de banco para data e number
    --
    --   Alterações  : 09/06/2017 - Setar padrões de data e number em um só comando
    --                              (Belli - Envolti) Chamado 660327
    -- .............................................................................
  BEGIN
    -- Chamado 660327
    -- Alteração incluindo num comando setar a forma de data e o decimal
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT = ''MM/DD/YYYY''
                                         NLS_NUMERIC_CHARACTERS = '',.''';
    
    -- Seta modulo
		GENE0001.pc_set_modulo(pr_module => pr_module, pr_action => pr_action);      
    
  END;

  /* Função que retorna o database name conectado */
  FUNCTION fn_database_name RETURN VARCHAR2 IS
    -- ..........................................................................
    --
    --  Programa : fn_database_name
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Marcos(Supero)
    --  Data     : Dezembro/2012.                   Ultima atualizacao: 04/01/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia  : Sempre que chamado por outros programas.
    --   Objetivo    : Retornar o nome do banco de dados conectado
    --   Observações : Isto é importante para tratarmos no programa
    --                 se determinada rotina pode ser executada
    --
    --   Alterações  : 04/01/2016 - Alteração para busca através do instance name
    --                              já que o ora_database_name durante o processo de
    --                              restore ainda compreendia o AYLLOSP (Marcos-Supero)
    -- .............................................................................
  BEGIN
    DECLARE
      CURSOR cr_instance IS
        SELECT UPPER(substr(instance_name,1,7))
          FROM v$instance;
      vr_dbname VARCHAR2(7);
    BEGIN
      OPEN cr_instance;
      FETCH cr_instance
       INTO vr_dbname;
      CLOSE cr_instance;
      RETURN vr_dbname;
    END;
  END fn_database_name;

  /* Função para retorno do OSUSer conectado a seção */
  FUNCTION fn_OSuser RETURN VARCHAR2 IS
  BEGIN
    -- ..........................................................................
    --
    --  Programa : fn_OSuser
    --  Sistema  : Rotinas genéricas
    --  Sigla    : GENE
    --  Autor    : Marcos E. Martini - Supero
    --  Data     : Novembro/2012.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: ---
    --   Objetivo  : Retornar a informação OSUser da sessão
    --
    --   Alteracoes: 99/99/9999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    -- .............................................................................
    BEGIN
      -- Retornar o usuário através da função SYS_CONTEXT
      RETURN NVL(SYS_CONTEXT('USERENV', 'OS_USER'),'CECRED');
    EXCEPTION
      WHEN OTHERS THEN
        RETURN 'CECRED';
    END;
  END fn_OSuser;

  /* Busca dos usuários que estão lockando a tabela */
  PROCEDURE pc_ver_lock(pr_nmtabela     IN VARCHAR2                      --> Nome da tabela
                       ,pr_nrdrecid     IN NUMBER DEFAULT NULL           --> Recid da tabela
                       ,pr_des_reto    OUT VARCHAR2                     --> Retorno (OK - Sem Lock, NOK - Com Lock)
                       ,pt_tab_locktab OUT gene0001.typ_tab_locktab) IS --> Vetor com usuários do lock
  BEGIN
    -- ..........................................................................
    --
    --  Programa : pc_ver_lock
    --  Sistema  : Rotinas genéricas
    --  Sigla    : GENE
    --  Autor    : Marcos E. Martini - Supero
    --  Data     : Junho/2014.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: ---
    --   Objetivo  : Retornar a lista de usuários que estão lockando a tabela ou
    --               tabela e registro solicitados
    --
    --   Alteracoes: 99/99/9999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    -- .............................................................................
    DECLARE
      -- Busca dos locks
      CURSOR cr_lock IS
        SELECT ss.OSUSER    loginusr
              ,ss.TERMINAL   dsdevice
              ,ss.LOGON_TIME dtconnec
          FROM V$LOCKED_OBJECT lo
              ,V$SESSION       ss
              ,DBA_OBJECTS     ob
         WHERE ob.owner       = 'CECRED'
           AND ob.OBJECT_TYPE = 'TABLE'
           AND ss.SID         = lo.SESSION_ID
           AND lo.OBJECT_ID   = ob.OBJECT_ID
           AND ob.OBJECT_NAME = pr_nmtabela;
      -- Sequenciador para a tabela
      vr_cont PLS_integer;
      -- Retorno da OSCOmmand
      vr_typ_saida VARCHAR2(100);
      vr_des_saida VARCHAR2(4000);
    BEGIN
      -- Varrear a tabela de lock
      FOR rw_lock IN cr_lock LOOP
        -- Para cada registro:
        -- 1º Gerar novo sequenciador
        vr_cont := pt_tab_locktab.COUNT+1;
        -- 2º Gravar os dados basicos
        pt_tab_locktab(vr_cont).loginusr := rw_lock.loginusr;
        pt_tab_locktab(vr_cont).dsdevice := rw_lock.dsdevice;
        pt_tab_locktab(vr_cont).dtconnec := rw_lock.dtconnec;
        -- 3º Usar pwget para buscar o nome do usuario
        pc_OScommand_Shell(pr_des_comando => GENE0001.fn_param_sistema(pr_nmsistem => 'CRED',pr_cdacesso => 'SCRIPT_EXEC_SHELL') || ' pwget ' || rw_lock.loginusr
                          ,pr_typ_saida   => vr_typ_saida
                          ,pr_des_saida   => vr_des_saida);
        -- Se houve retorno OUT
        IF vr_typ_saida = 'OUT' THEN
          -- Copiar o username
          pt_tab_locktab(vr_cont).nmusuari := gene0002.fn_busca_entrada(1,gene0002.fn_busca_entrada(5,vr_des_saida,':'),'-');

        ELSE
          -- Usar vazio
          pt_tab_locktab(vr_cont).nmusuari := ' ';
        END IF;
      END LOOP;
      -- Se houver algum registro na tabela de lock
      IF pt_tab_locktab.count > 0 THEN
        pr_des_reto := 'OK';
      ELSE
        pr_des_reto := 'NOK';
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_reto := 'NOK';
    END;
  END pc_ver_lock;

  /* Função que retorna os parâmetros de sistema */
  FUNCTION fn_param_sistema(pr_nmsistem IN crapprm.nmsistem%TYPE
                           ,pr_cdcooper IN crapprm.cdcooper%TYPE DEFAULT 0 --> Zero é utilizado para todas as COOPs
                           ,pr_cdacesso IN crapprm.cdacesso%TYPE)          --> Chave de acesso do parametro
                                                                  RETURN crapprm.dsvlrprm%TYPE IS
  BEGIN
    -- ..........................................................................
    --
    --  Programa : fn_param_sistema
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Marcos(Supero)
    --  Data     : Dezembro/2012.                   Ultima atualizacao: 11/12/2012
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia  : Sempre que chamado por outros programas.
    --   Objetivo    : Buscar o parâmetro conforme as chaves passadas
    --   Observações : Quando um parâmetro é independente de cooperativa,
    --                 ele possui o valor 0 neste campo
    --
    --   Alteracoes:
    --
    -- .............................................................................
    DECLARE
      -- Efetuar a busca do valor na tabela
      CURSOR cr_crapprm IS
        SELECT prm.dsvlrprm
          FROM crapprm prm
         WHERE prm.nmsistem = pr_nmsistem
           AND prm.cdcooper IN(pr_cdcooper,0) --> Busca tanto da passada, quanto da geral (se existir)
           AND prm.cdacesso = pr_cdacesso
         ORDER BY prm.cdcooper DESC; --> Trará a cooperativa passada primeiro, e caso não encontre nela, trará da 0(zero)
      vr_dsvlrprm crapprm.dsvlrprm%TYPE;
    BEGIN
      -- Busca descrição da critica cfme parâmetro passado
      OPEN cr_crapprm;
      FETCH cr_crapprm
       INTO vr_dsvlrprm;
      -- Apenas fechar o cursor
      CLOSE cr_crapprm;
      -- Retornar o valor encontrado
      RETURN vr_dsvlrprm;
    END;
  END fn_param_sistema;

  /* Função que retorna os parâmetros de sistema */
  PROCEDURE pc_param_sistema(pr_nmsistem  IN crapprm.nmsistem%TYPE
                            ,pr_cdcooper  IN crapprm.cdcooper%TYPE DEFAULT 0 --> Zero é utilizado para todas as COOPs
                            ,pr_cdacesso  IN crapprm.cdacesso%TYPE          --> Chave de acesso do parametro
                            ,pr_dsvlrprm OUT crapprm.dsvlrprm%TYPE) IS
    -- ..........................................................................
    --
    --  Programa : pc_param_sistema
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Odirlei Busana(AMcom)
    --  Data     : Janeiro/2015.                   Ultima atualizacao: 23/01/2015
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia  : Sempre que chamado por outros programas.
    --   Objetivo    : Buscar o parâmetro conforme as chaves passadas
    --   Observações : Procedimento criado para ser chamado via progress devido
    --                 a limitação para utilização de functions
    --
    --   Alteracoes:
    --
    -- .............................................................................
  BEGIN
     pr_dsvlrprm := fn_param_sistema(pr_nmsistem => pr_nmsistem
                                    ,pr_cdcooper => pr_cdcooper
                                    ,pr_cdacesso => pr_cdacesso);

  END pc_param_sistema;

  /* Mostrar o texto das criticas na tela de acordo com o ocorrido. */
  FUNCTION fn_busca_critica(pr_cdcritic IN crapcri.cdcritic%TYPE DEFAULT 0,
                            pr_dscritic IN crapcri.dscritic%TYPE DEFAULT NULL) RETURN VARCHAR2 IS
  BEGIN
    -- ..........................................................................
    --
    --  Programa : fn_busca_critica (Antigo Fontes/critic.p)
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Deborah/Edson
    --  Data     : Setembro/1991.                   Ultima atualizacao: 12/01/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que chamado por outros programas.
    --   Objetivo  : Mostrar o texto das criticas na tela de acordo com o ocorrido.
    --
    --   Alteracoes: 08/12/2004 - Inclusao do nome do banco antes das tabelas (Julio)
    --
    --               04/06/2012 - Adaptação dos fontes para projeto Oracle. Retirada
    --                            do prefixo "banco" (Guilherme Maba).
    --
    --               13/11/2012 - Conversão Progress >> Oracle PLSQL
    --
    --               12/01/2017 - #551192 Mudança para parâmetros opcionais cd e dscritic para centralizar
    --                            a lógica de captura dos erros (Carlos) 
    -- .............................................................................

    DECLARE
      -- Efetuar a busca da descrição na tabela
      CURSOR cr_crapcri IS
        SELECT cri.dscritic
          FROM crapcri cri
         WHERE cri.cdcritic = pr_cdcritic;
      vr_dscritic crapcri.dscritic%TYPE;
    BEGIN
      -- Se veio código de crítica e não veio descrição
      IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
    
      -- Busca descrição da critica cfme parâmetro passado
      OPEN cr_crapcri;
      FETCH cr_crapcri
       INTO vr_dscritic;
      -- Se não encontrou nenhum registro
      IF cr_crapcri%NOTFOUND THEN
        -- Montar descrição padrão
        vr_dscritic := pr_cdcritic || ' - Critica nao cadastrada!';
      END IF;
      -- Apenas fechar o cursor
      CLOSE cr_crapcri;
      -- Retornar a string montada
      RETURN vr_dscritic;

      END IF;      
      
      -- Retorna apenas as descrição
      RETURN pr_dscritic;
      
    END;
  END fn_busca_critica;

  /* Mostrar mensagem dbms_output.put_line */
  PROCEDURE pc_print(pr_des_mensag IN VARCHAR2) IS
  BEGIN
    -- ..........................................................................
    --
    --  Programa : pc_print
    --  Sistema  : Rotinas genéricas
    --  Sigla    : GENE
    --  Autor    : Marcos E. Martini - Supero
    --  Data     : Novembro/2012.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: ---
    --   Objetivo  : Enviar texto ao DBMS_OUTPUT
    --
    --   Alteracoes: 99/99/9999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    -- .............................................................................

    DECLARE
      vr_string long default PR_DES_MENSAG;
    BEGIN
      -- Imprimir na tela quebrando o texto em 100 caracteres
      -- para evitar estouro de buffer definido por linha
      loop
       exit when vr_string is null;
       dbms_output.put_line( substr( vr_string, 1, 100 ) );
       vr_string := substr( vr_string, 101 );
     end loop;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  END pc_print;

  /* Função que retorna o caminho fisico de um diretório cfme a cooperativa passada */
  FUNCTION fn_diretorio(pr_tpdireto IN VARCHAR2
                       ,pr_cdcooper IN crapcop.cdcooper%TYPE
                       ,pr_nmsubdir IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS
  BEGIN
    -- ..........................................................................
    --
    --  Programa : fn_diretorio
    --  Sistema  : Rotinas genéricas
    --  Sigla    : GENE
    --  Autor    : Marcos E. Martini - Supero
    --  Data     : Novembro/2012.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: ---
    --   Objetivo  : Montar o caminho padrão de gravação de arquivos de uma cooperativa
    --               - pr_tpdireto -> 'C' --> Diretório COOP
    --                             -> 'M' --> Diretório MICROS
    --               - Caso o desenvolvedor passe o parâmetro pr_nmsubdir, utilizamos
    --                 o mesmo para formular o caminho completo, do contrário enviamos
    --                 o caminho somente até a raiz da cooperativa
    --
    --   Alteracoes: 11/11/2016 - Ajustado para garantir não ficar lixo na variavel 
    --                            vr_dsdircop. (Odirlei-AMcom)
    -- .............................................................................
    DECLARE
      -- Diretório base
      vr_nmdireto_base VARCHAR2(200);
      -- Diretório temp
      vr_nmsubdir VARCHAR2(200);
      vr_dsdircop crapcop.dsdircop%TYPE;
      
    BEGIN
      -- Preencher Diretório base conforme tipo diretório passado
      IF upper(pr_tpdireto) = 'C' THEN
        vr_nmdireto_base := gene0001.fn_param_sistema('CRED',pr_cdcooper,'ROOT_DIRCOOP');
      ELSIF upper(pr_tpdireto) = 'M' THEN
        vr_nmdireto_base := gene0001.fn_param_sistema('CRED',pr_cdcooper,'ROOT_MICROS');
      ELSIF upper(pr_tpdireto) = 'S' THEN
        vr_nmdireto_base := gene0001.fn_param_sistema('CRED',pr_cdcooper,'ROOT_SCRIPT');
      ELSIF upper(pr_tpdireto) = 'W' THEN
        vr_nmdireto_base := gene0001.fn_param_sistema('CRED',pr_cdcooper,'ROOT_WIN12');
      ELSE
        vr_nmdireto_base := gene0001.fn_param_sistema('CRED',pr_cdcooper,'ROOT_TMP');
      END IF;
      
      vr_dsdircop := NULL;
      
      -- Buscar nome do diretório no cadastro da cooperativa
      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop
       INTO vr_dsdircop;
      CLOSE cr_crapcop;
      -- Incluir o diretório da cooperativa no caminho
      vr_nmdireto_base := vr_nmdireto_base || vr_dsdircop;
      -- Se foi passado algum sud-diretório
      IF pr_nmsubdir IS NOT NULL THEN
        -- Remover espaços do diretório passado e deixar em minúsculo
        vr_nmsubdir := LOWER(TRIM(pr_nmsubdir));
        -- Remover barras a esquerda e a direita do diretório
        -- para garantir que o caminho montado não fique inválido
        vr_nmsubdir := LTRIM(LTRIM(vr_nmsubdir,'\'),'/');
        vr_nmsubdir := RTRIM(RTRIM(vr_nmsubdir,'\'),'/');
        -- Adicionar o caminho processado ao caminho completo
        vr_nmdireto_base := vr_nmdireto_base || '/' || vr_nmsubdir;
      END IF;
      -- Retornar o caminho montado
      RETURN vr_nmdireto_base;
    END;
  END fn_diretorio;

  /* Procedimento que serve de interface do Oracle para Java */
  PROCEDURE pc_interface_OScommand(pr_des_script  IN VARCHAR2
                                  ,pr_typ_comando IN VARCHAR2
                                  ,pr_des_comando IN VARCHAR2)
    AS LANGUAGE JAVA NAME 'OSCommand.executeCommand(java.lang.String,java.lang.String,java.lang.String)';

  /* Função para listar arquivos contidos um uma pasta - interface para classe Java com opção de filtro */
  FUNCTION fn_lista_arquivos(pr_path IN VARCHAR2
                            ,pr_pesq IN VARCHAR2) RETURN VARCHAR2 AS
    LANGUAGE JAVA NAME 'ListaArquivos.listar(java.lang.String, java.lang.String) returns java.lang.String';
  /*..............................................................................

       Programa: FN_LISTA_ARQUIVOS
       Autor   : Petter (Supero)
       Data    : Outubro/2013                      Ultima atualizacao:

       Dados referentes ao programa:

       Objetivo  : Invocar classe Java ancorada no Banco de Dados para realizar
                   listagem de arquivos do path informado, com a opção de utilizar filtros
                   de pesquisa.

       Alteracoes:

    ..............................................................................*/

  /* Procedure para listar arquivos com controle de erros */
  PROCEDURE pc_lista_arquivos(pr_path     IN VARCHAR2
                             ,pr_pesq     IN VARCHAR2 DEFAULT NULL
                             ,pr_listarq  OUT VARCHAR2
                             ,pr_des_erro OUT VARCHAR2) IS
    /*..............................................................................

       Programa: PC_LISTA_ARQUIVOS
       Autor   : Petter (Supero)
       Data    : Dezembro/2013                      Ultima atualizacao:

       Dados referentes ao programa:

       Objetivo  : Invocar função que é a interface para classe Java ancorada no
                   Banco de Dados para realizar listagem de arquivos do path
                   informado, com a opção de utilizar filtros de pesquisa.

       Alteracoes:

    ..............................................................................*/
  BEGIN
    BEGIN
      -- Acionar função de interface para classe Java
      pr_listarq := fn_lista_arquivos(pr_path => pr_path, pr_pesq => pr_pesq);

      -- Tratar saída para identificar erro ou sucesso no processo
      IF substr(pr_listarq, 1, 2) = '1-' THEN
        pr_listarq := substr(pr_listarq, 3, length(pr_listarq));
      ELSIF substr(pr_listarq, 1, 2) = '2-' THEN
        pr_des_erro := substr(pr_listarq, 3, length(pr_listarq));
        pr_listarq := NULL;
      END IF;
    END;
  END pc_lista_arquivos;

  /* Procedimento para listar arquivos contidos em uma pasta - interface para classe Java com opção de filtro */
  PROCEDURE pc_lista_arquivos(pr_lista_arquivo OUT TYP_SIMPLESTRINGARRAY
                             ,pr_path          IN VARCHAR2
                             ,pr_pesq          IN VARCHAR2) AS
    LANGUAGE JAVA NAME 'ListaArquivosArray.getArquivos(oracle.sql.ARRAY[], java.lang.String, java.lang.String)';
  /*..............................................................................

       Programa: PC_LISTA_ARQUIVOS
       Autor   : Petter (Supero)
       Data    : Março/2015                           Ultima atualizacao:

       Dados referentes ao programa:

       Objetivo  : Invocar classe Java ancorada no Banco de Dados para realizar
                   listagem de arquivos do path informado, com a opção de utilizar filtros
                   de pesquisa.
                   Irá retornar um ArrayList com a listagem de arquivos.

       Alteracoes:

    ..............................................................................*/

  /* Função para validar os tipos de comando passado */
  FUNCTION fn_type_comando(pr_typ_comando IN VARCHAR2
                          ,pr_des_erro   OUT VARCHAR2) RETURN VARCHAR2 IS
    -- Var para testar o tipo pois podemos enviar o prefixo apenas
    vr_typ_comando VARCHAR2(100);
  BEGIN
    -- Testar se foi enviado alguma opção válida
    IF UPPER(pr_typ_comando) IN ('P','PERL') THEN
      vr_typ_comando := 'perl';
    ELSIF UPPER(pr_typ_comando) IN ('S','SHELL') THEN
      vr_typ_comando := 'shell';
    ELSIF UPPER(pr_typ_comando) IN ('L','LP') THEN
      vr_typ_comando := 'lp';
    ELSIF UPPER(pr_typ_comando) IN ('SR') THEN
      vr_typ_comando := 'shell_remoto';
    ELSE
      -- Gerar erro
      pr_des_erro := 'PT_TYP_COMANDO :'||pr_typ_comando||' não suportado';
      vr_typ_comando := null;
    END IF;
    -- Retornar
    RETURN vr_typ_comando;
  END;

    /* Rotina para executar o comando solicitado  */
  PROCEDURE pc_executa_OSCommand(pr_nrseqsol    IN crapcso.nrseqsol%TYPE    --> Sequencia da solicitação
                                ,pr_typ_saida  OUT VARCHAR2
                                ,pr_des_saida  OUT VARCHAR2) IS
  BEGIN
    -- ..........................................................................
    --
    --  Programa : pc_executa_OSCommand
    --  Sistema  : Rotinas genéricas
    --  Sigla    : GENE
    --  Autor    : Andrino Carlos de Souza Junior - RKAM
    --  Data     : Outubro/2013.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --  Frequencia: Sempre que for chamado
    --  Objetivo  : Executar o comando informado da tabela CRAPCSO
    --
    --  Alteracoes: 07/10/2013 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    -- ...........................................................................
    DECLARE
      -- Buscar dados da solicitação
      CURSOR cr_crapcso IS
        SELECT crapcso.tpcomand,
               crapcso.dscomand,
               crapcso.flgsaida
          FROM crapcso
         WHERE crapcso.nrseqsol = pr_nrseqsol;
      rw_crapcso cr_crapcso%ROWTYPE;

      -- Var para testar o tipo pois podemos enviar o prefixo apenas
      vr_typ_comando VARCHAR2(100);
      -- Busca da saída na DBMS_OUTPUT
      vr_dsout DBMS_OUTPUT.chararr;
      vr_qtlin INTEGER := 1000;

      -- Variavel responsavel em armazenar o inicio da execucao
      vr_dtiniexe DATE;

    BEGIN
      -- Busca das informaçoes do relatório solicitado
      OPEN cr_crapcso;
      FETCH cr_crapcso
       INTO rw_crapcso;
      -- Somente se encontrar
      IF cr_crapcso%FOUND THEN
        -- fechar o cursor
        CLOSE cr_crapcso;
        vr_dtiniexe := SYSDATE;

        IF rw_crapcso.flgsaida = 'S' THEN -- Se deverá guardar a saida do comando
          BEGIN
            -- Ativar a saida
            DBMS_OUTPUT.disable;
            DBMS_OUTPUT.enable(1000000);
            DBMS_JAVA.set_output(1000000);
            -- Validar o typo de comando passado
            vr_typ_comando := fn_type_comando(rw_crapcso.tpcomand,vr_des_erro);
            -- Se encontrou erro, sair
            IF vr_des_erro IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
            -- Efetuar a instrução passada diretamente no shell
            pc_interface_OScommand(gene0001.fn_param_sistema('CRED',0,'SCRIPT_EXEC_SHELL'),vr_typ_comando,rw_crapcso.dscomand);
            -- Armazenar o retorno
            DBMS_OUTPUT.get_lines(vr_dsout,vr_qtlin);
            -- Processar o retorno
            FOR vr_ind IN 1..vr_qtlin LOOP
              -- Na primeira interação
              IF vr_ind = 1 THEN
                -- Se o tamanho for superior a 3 bytes
                IF LENGTH(vr_dsout(vr_ind)) > 3 THEN
                  -- Gerar erro
                  pr_typ_saida := 'ERR';
                  -- Incluir esta informação na saída
                  pr_des_saida := pr_des_saida || vr_dsout(vr_ind) ||chr(10);
                ELSE
                  -- Retorna o tipo da saída
                  pr_typ_saida := vr_dsout(vr_ind);
                END IF;
              ELSE
                -- Adicionar na variável de retorno
                pr_des_saida := pr_des_saida || vr_dsout(vr_ind) ||chr(10);
              END IF;
            END LOOP;
          EXCEPTION
            WHEN vr_exc_erro THEN
              pr_typ_saida := 'ERR';
              pr_des_saida := 'Erro gene0001.pc_executa_OSCommand: '||vr_des_erro;
            WHEN OTHERS THEN
              pr_typ_saida := 'ERR';
              pr_des_saida := 'Erro geral gene0001.pc_executa_OSCommand: '||SQLERRM;
          END;
        ELSE
          BEGIN
            -- Validar o typo de comando passado
            vr_typ_comando := fn_type_comando(rw_crapcso.tpcomand,vr_des_erro);
            -- Se encontrou erro, sair
            IF vr_des_erro IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
            -- Efetuar a instrução passada diretamente no shell
            pc_interface_OScommand(gene0001.fn_param_sistema('CRED',0,'SCRIPT_EXEC_SHELL'),vr_typ_comando,rw_crapcso.dscomand);
          EXCEPTION
            WHEN vr_exc_erro THEN
              pr_typ_saida := 'ERR';
              pr_des_saida := 'Erro gene0001.pc_executa_OSCommand: '||vr_des_erro;
            WHEN OTHERS THEN
              pr_typ_saida := 'ERR';
              pr_des_saida := 'Erro geral gene0001.pc_executa_OSCommand: '||SQLERRM;
          END;

        END IF;

        -- Atualiza tabela
        BEGIN
          UPDATE crapcso
             SET crapcso.dtiniexe = vr_dtiniexe,
                 crapcso.dtfimexe = SYSDATE,
                 crapcso.flgexecu = 'S',
                 crapcso.dssaidac = pr_des_saida,
                 crapcso.tpsaidac = pr_typ_saida
           WHERE crapcso.nrseqsol = pr_nrseqsol;
        EXCEPTION
          WHEN OTHERS THEN
            pr_typ_saida := 'ERR';
            pr_des_saida := 'Erro atualizacao tabela crapcso: '||SQLERRM;
        END;
      ELSE
        CLOSE cr_crapcso;
      END IF;
    END;
  END pc_executa_OSCommand;

  --> valida se o comando deve ser executado conforme o modo do parametro MODOEXECSHELL
  FUNCTION fn_valid_comando_mod (pr_des_comando IN VARCHAR2) RETURN BOOLEAN  IS
    
    vr_lscmdmod     crapprm.dsvlrprm%TYPE;
    vr_tab_lscmdmod gene0002.typ_split;
    vr_flgachou     BOOLEAN := FALSE; 
  BEGIN
    
    --> Buscar a lista de comandos que devem ser executados conforme o modo definido no parametro MODOEXECSHELL
    vr_lscmdmod := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                             pr_cdcooper => 0, 
                                             pr_cdacesso => 'COMANDOS_MODOEXECSHELL');   
    
    vr_tab_lscmdmod := gene0002.fn_quebra_string(pr_string => vr_lscmdmod ,pr_delimit => ';');
      
    --> Varrer a lista de comando
    IF vr_tab_lscmdmod.count > 0 THEN
       
      FOR i IN vr_tab_lscmdmod.first..vr_tab_lscmdmod.last LOOP
        --> Verificar se é um comando a ser executado conforme o modo
        IF upper(pr_des_comando) LIKE upper(vr_tab_lscmdmod(i)) THEN
          -- achou
          vr_flgachou := TRUE;
          EXIT;
        END IF;
      END LOOP;        
    END IF;    
      
    --> Retornar  boolean
    RETURN vr_flgachou;
      
  EXCEPTION
    WHEN OTHERS THEN
      RETURN  FALSE; 
  END fn_valid_comando_mod;
  
  PROCEDURE pc_process_OSCommand_penden(pr_nrseqsol  IN crapcso.nrseqsol%TYPE DEFAULT NULL
                                       ,pr_typ_saida  OUT VARCHAR2
                                       ,pr_des_saida  OUT VARCHAR2) IS
  BEGIN
    -- ..........................................................................
    --
    --  Programa : pc_process_OSCommand_penden
    --  Sistema  : Rotinas genéricas
    --  Sigla    : GENE
    --  Autor    : Andrino Carlos de Souza Juniot
    --  Data     : Outubro/2013.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Esta rotina tem as seguintes funcionalidades:
    --               1 - Limpar solicitações de comandos antigas
    --               2.1 - Processar as <n> ultimas solicitações pendentes e chamar seu envio
    --               2.2 - Processar somente a solicitaçao passada
    --               3 - Enviar para os campos tpsaidac e dssaidac os erros encontrados na execução do comando
    --   Obs: A rotina nao para o processo em caso de erro na solicitaçao, pois todas devem ser processadas
    --
    --   Alteracoes: 99/99/9999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    -- .............................................................................
    DECLARE
      -- Guardar quantidade de dias a manter os emails
      vr_qtddiacommand NUMBER;
      -- Quantidade de de emails a processar no Job
      vr_qtdcommandjob NUMBER;
      -- Busca dos comandos pendentes de execução
      CURSOR cr_crapcso IS
        SELECT crapcso.nrseqsol
          FROM crapcso
         WHERE crapcso.flgexecu = 'N' --> Ainda não executado
           AND ROWNUM <= vr_qtdcommandjob --> Somente qtde parametrizada por Job
         ORDER BY crapcso.nrseqsol; --> Os mais antigos primeiro
    BEGIN
      -- Se estiver rodando no processo automatizado
      IF pr_nrseqsol IS NULL THEN
        -- Buscar quantidade de dias que os comandos devem ficar armazenados
        BEGIN
          vr_qtddiacommand := NVL(gene0001.fn_param_sistema('CRED',0,'DIAS_LOG_COMANDOS'),7);
        EXCEPTION
          WHEN OTHERS THEN
            -- Ocorreu erro pq o parametros nao era number, então usar qtde padrao (7)
            vr_qtddiacommand := 7;
        END;
        -- Efetuar limpeza da tabela de comandos executados
        BEGIN
          DELETE
            FROM crapcso
           WHERE crapcso.dtsolici < TRUNC(SYSDATE) - vr_qtddiacommand
             AND crapcso.flgexecu = 'S';
        EXCEPTION
          WHEN OTHERS THEN
            btch0001.pc_gera_log_batch(pr_cdcooper     => 0
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || 'GENE0001.pc_process_OScommand_pendend ' || ' --> ATENCAO !! '
                                                     || 'Erro ao excluir CRAPCSO: '||SQLERRM);
        END;
        -- Buscar quantidade de comandos a processar no Job
        BEGIN
          vr_qtdcommandjob := NVL(gene0001.fn_param_sistema('CRED',0,'QTDE_COMANDO_POR_JOB'),500);
        EXCEPTION
          WHEN OTHERS THEN
            -- Ocorreu erro pq o parametros nao era number, então usar qtde padrao (500)
            vr_qtdcommandjob := 500;
        END;
        -- Busca de todos os comandos pendentes de execução
        FOR rw_crapcso IN cr_crapcso LOOP
          -- Chamar rotina de execução do comando
          pc_executa_OSCommand(pr_nrseqsol  => rw_crapcso.nrseqsol,
                               pr_typ_saida => pr_typ_saida,
                               pr_des_saida => pr_des_saida); -- Se existit erro sera desconsiderado, apenas gravado na tabela de log
          -- Commitar registro por registro, para não executar o mesmo comando duas vezes
          COMMIT;
        END LOOP;
      ELSE
        -- Processar somente a solicitação passada
        pc_executa_OSCommand(pr_nrseqsol => pr_nrseqsol,
                             pr_typ_saida => pr_typ_saida,
                             pr_des_saida => pr_des_saida); -- Se existit erro voltará para a rotina chamadora
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- Gerar Log
        pr_typ_saida := 'ERR';
        pr_des_saida := 'Erro GENE0001.pc_process_OScommand_penden: '||SQLERRM;
        -- Gravar pois não podemos reexecutar os comandos
        COMMIT;
    END;
  END pc_process_OSCommand_penden;

  /* Executar um comando no Host usando a interface com saída */
  PROCEDURE pc_OScommand(pr_typ_comando IN VARCHAR2
                        ,pr_des_comando IN VARCHAR2
                        ,pr_flg_aguard  IN VARCHAR2 DEFAULT 'S' -- O processo deverá aguardar a execução do comando
                        ,pr_typ_saida  OUT VARCHAR2
                        ,pr_des_saida  OUT VARCHAR2) IS
    vr_nrseqsol crapcso.nrseqsol%TYPE;
    vr_dsexshel VARCHAR2(100);
    vr_tpcomand crapcso.tpcomand%TYPE; 
    
  BEGIN
    -- Inicializar variavel com o valor do parametro
    vr_tpcomand := pr_typ_comando;
    
    -- Se for shell 
    IF nvl(upper(pr_typ_comando),'S') = 'S' THEN 
      
      --> Buscar qual forma deve ser executado o comando 
      vr_dsexshel := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                               pr_cdcooper => 0, 
                                               pr_cdacesso => 'MODOEXECSHELL');

      -- Se for 2 - Shell remoto 
      -- ou 0 - nao executar
      IF vr_dsexshel IN (2,0)  THEN 
        -- e estiver executando um comando definido no parametro COMANDOS_MODOEXECSHELL
        IF fn_valid_comando_mod(pr_des_comando) THEN
              
          --> Definir como shell remoto    
          IF vr_dsexshel = 2 THEN
            vr_tpcomand := 'SR';
          -- se 0 - Não executar  
          ELSIF vr_dsexshel = 0 THEN
            -- sair sem erro
            RETURN;      
          END IF;  
        END IF;
      END IF;  
    -- 1 ou nulo - seria Shell, logo nao necessario realizar alteracao                                                     
    END IF;
    
    -- Insere na tabela de solicitacao de comando com indicador FLGSAIDA igual a S, onde obriga retorno
    BEGIN
      INSERT INTO crapcso
        (dtsolici,
         tpcomand,
         dscomand,
         flgexecu,
         flgsaida)
      VALUES
        (SYSDATE,
         vr_tpcomand,
         pr_des_comando,
         'N',
         'S') RETURNING nrseqsol INTO vr_nrseqsol;
    EXCEPTION
      WHEN OTHERS THEN
        pr_typ_saida := 'ERR';
        pr_des_saida := 'Erro ao inserir CRAPCSO: '||SQLERRM;
        RETURN;
    END;

    -- Se não foi solicitado para aguardar, então processamos o comando na hora
    IF pr_flg_aguard = 'S' THEN
      pc_process_OSCommand_penden(pr_nrseqsol  => vr_nrseqsol
                                 ,pr_typ_saida => pr_typ_saida
                                 ,pr_des_saida => pr_des_saida);
    END IF;

  END pc_OScommand;

  /* Executar um comando no Host usando a interface sem saída */
  PROCEDURE pc_OScommand(pr_typ_comando IN VARCHAR2
                        ,pr_des_comando IN VARCHAR2
                        ,pr_flg_aguard  IN VARCHAR2 DEFAULT 'S') IS -- O processo deverá aguardar a execução do comando
    vr_nrseqsol  crapcso.nrseqsol%TYPE;
    vr_typ_saida VARCHAR2(03);
    vr_des_saida VARCHAR2(4000);
    vr_dsexshel VARCHAR2(100);
    vr_tpcomand crapcso.tpcomand%TYPE; 
    
  BEGIN
    
    -- Inicializar variavel com o valor do parametro
    vr_tpcomand := pr_typ_comando;
    
    -- Se for shell 
    IF nvl(upper(pr_typ_comando),'S') = 'S' THEN 
      
      --> Buscar qual forma deve ser executado o comando 
      vr_dsexshel := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', 
                                               pr_cdcooper => 0, 
                                               pr_cdacesso => 'MODOEXECSHELL');

      -- Se for 2 - Shell remoto 
      -- ou 0 - nao executar
      IF vr_dsexshel IN (2,0)  THEN 
        -- e estiver executando um comando definido no parametro COMANDOS_MODOEXECSHELL
        IF fn_valid_comando_mod(pr_des_comando) THEN
              
          --> Definir como shell remoto    
          IF vr_dsexshel = 2 THEN
            vr_tpcomand := 'SR';
          -- se 0 - Não executar  
          ELSIF vr_dsexshel = 0 THEN
            -- sair sem erro
            RETURN;      
          END IF;  
       -- 1 ou nulo - seria Shell, logo nao necessario realizar alteracao                                                     
       END IF;                                                
      END IF;                                                
    END IF;
    
    -- Insere na tabela de solicitacao de comando com indicador FLGSAIDA igual a N, onde nao necessita retorno
    BEGIN
      INSERT INTO crapcso
        (dtsolici,
         tpcomand,
         dscomand,
         flgexecu,
         flgsaida)
      VALUES
        (SYSDATE,
         vr_tpcomand,
         pr_des_comando,
         'N',
         'N') RETURNING nrseqsol INTO vr_nrseqsol;
    EXCEPTION
      WHEN OTHERS THEN
        vr_typ_saida := 'ERR';
        vr_des_saida := 'Erro ao inserir CRAPCSO: '||SQLERRM;
        RETURN;
    END;

    -- Se não foi solicitado para aguardar, então processamos o comando na hora
    IF pr_flg_aguard = 'S' THEN
      pc_process_OSCommand_penden(pr_nrseqsol  => vr_nrseqsol
                                 ,pr_typ_saida => vr_typ_saida
                                 ,pr_des_saida => vr_des_saida);
    END IF;
  END pc_OScommand;

  /* Executar um comando no Host usando a interface sem saída */
  PROCEDURE pc_OScommand_Perl(pr_des_comando IN VARCHAR2
                             ,pr_flg_aguard  IN VARCHAR2 DEFAULT 'S') IS -- O processo deverá aguardar a execução do comando
  BEGIN
    -- Apenas faz overload da OScomand e já sugere o Type=Perl
    pc_OScommand(pr_typ_comando => 'P'
                ,pr_des_comando => pr_des_comando
                ,pr_flg_aguard  => pr_flg_aguard);
  END;

  /* Executar um comando no Host usando a interface com saída */
  PROCEDURE pc_OScommand_Perl(pr_des_comando IN VARCHAR2
                             ,pr_flg_aguard  IN VARCHAR2 DEFAULT 'S' -- O processo deverá aguardar a execução do comando
                             ,pr_typ_saida  OUT VARCHAR2
                             ,pr_des_saida  OUT VARCHAR2) IS
  BEGIN
    -- Apenas faz overload da OScomand e já sugere o Type=Perl
    pc_OScommand(pr_typ_comando => 'P'
                ,pr_des_comando => pr_des_comando
                ,pr_flg_aguard  => pr_flg_aguard
                ,pr_typ_saida   => pr_typ_saida
                ,pr_des_saida   => pr_des_saida);
  END;

  /* Executar um comando no Host usando a interface sem saída */
  PROCEDURE pc_OScommand_Shell(pr_des_comando IN VARCHAR2
                              ,pr_flg_aguard  IN VARCHAR2 DEFAULT 'S') IS -- O processo deverá aguardar a execução do comando
  BEGIN
    -- Apenas faz overload da OScomand e já sugere o Type=Shell
    pc_OScommand(pr_typ_comando => 'S'
                ,pr_des_comando => pr_des_comando
                ,pr_flg_aguard  => pr_flg_aguard);
  END;

  /* Executar um comando no Host usando a interface com saída */
  PROCEDURE pc_OScommand_Shell(pr_des_comando IN VARCHAR2
                              ,pr_flg_aguard  IN VARCHAR2 DEFAULT 'S' -- O processo deverá aguardar a execução do comando
                              ,pr_typ_saida  OUT VARCHAR2
                              ,pr_des_saida  OUT VARCHAR2) IS
  BEGIN
    -- Apenas faz overload da OScomand e já sugere o Type=Shell
    pc_OScommand(pr_typ_comando => 'S'
                ,pr_des_comando => pr_des_comando
                ,pr_flg_aguard  => pr_flg_aguard
                ,pr_typ_saida   => pr_typ_saida
                ,pr_des_saida   => pr_des_saida);
  END;

  /* Executar o comando LP no Host usando a interface sem saída */
  PROCEDURE pc_OScommand_LP(pr_des_comando IN VARCHAR2
                           ,pr_flg_aguard  IN VARCHAR2 DEFAULT 'S') IS -- O processo deverá aguardar a execução do comando
  BEGIN
    -- Apenas faz overload da OScomand e já sugere o Type=LP
    pc_OScommand(pr_typ_comando => 'LP'
                ,pr_des_comando => pr_des_comando
                ,pr_flg_aguard  => pr_flg_aguard);
  END;

  /* Executar o comando LP no Host usando a interface com saída */
  PROCEDURE pc_OScommand_LP(pr_des_comando IN VARCHAR2
                           ,pr_flg_aguard  IN VARCHAR2 DEFAULT 'S' -- O processo deverá aguardar a execução do comando
                           ,pr_typ_saida  OUT VARCHAR2
                           ,pr_des_saida  OUT VARCHAR2) IS
  BEGIN
    -- Apenas faz overload da OScomand e já sugere o Type=LP
    pc_OScommand(pr_typ_comando => 'LP'
                ,pr_des_comando => pr_des_comando
                ,pr_flg_aguard  => pr_flg_aguard
                ,pr_typ_saida   => pr_typ_saida
                ,pr_des_saida   => pr_des_saida);
  END;

  /* Retorno de erro da BO */
  PROCEDURE pc_gera_erro(pr_cdcooper IN craperr.cdcooper%TYPE
                        ,pr_cdagenci IN craperr.cdagenci%TYPE
                        ,pr_nrdcaixa IN craperr.nrdcaixa%TYPE
                        ,pr_nrsequen IN craperr.nrsequen%TYPE
                        ,pr_cdcritic IN craperr.cdcritic%TYPE
                        ,pr_dscritic IN OUT craperr.dscritic%TYPE
                        ,pr_tab_erro IN OUT GENE0001.typ_tab_erro) IS
  BEGIN
    /*..............................................................................

       Programa: pc_gera_erro (Antigo gera_erro.i)
       Autor   : David
       Data    : Outubro/2007                      Ultima atualizacao: 03/12/2012

       Dados referentes ao programa:

       Objetivo  : Include para geracao de erros
                   Necessita a definicao da temp-table "tt-erro" no programa que
                   efetua chamada da include.

       Alteracoes: 08/11/2007 - Output no parametro par_dscritic (David).
                   03/12/2012 - Conversão da rotina de Progress > Oracle PLSQL

    ..............................................................................*/
    DECLARE
      vr_seq BINARY_INTEGER;
    BEGIN
      -- Guardar a próxima sequencia para gravação na tabela de erros
      vr_seq := pr_tab_erro.COUNT;
      -- Criar o registro de erro (Rowtype da CRAPERR)
      pr_tab_erro(vr_seq).cdcooper := pr_cdcooper;
      pr_tab_erro(vr_seq).cdagenci := pr_cdagenci;
      pr_tab_erro(vr_seq).nrdcaixa := pr_nrdcaixa;
      pr_tab_erro(vr_seq).nrsequen := pr_nrsequen;
      pr_tab_erro(vr_seq).erro     := 1;
      pr_tab_erro(vr_seq).cdcritic := pr_cdcritic;
      pr_tab_erro(vr_seq).dscritic := pr_dscritic;
      -- Se foi enviado o código de crítica e não foi enviada descrição
      IF pr_cdcritic <> 0 AND pr_dscritic IS NULL THEN
        -- Gravar na descrição da crítica a busca da função
        pr_tab_erro(vr_seq).dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
        pr_dscritic         := pr_tab_erro(vr_seq).dscritic;
      END IF;
    END;
  END pc_gera_erro;

  /* Gerar ou ler xml da temptable de erros*/
  PROCEDURE pc_xml_tab_erro(pr_tab_erro   IN OUT GENE0001.typ_tab_erro, --> TempTable de erro
                            pr_xml_erro   IN OUT CLOB,                  --> XML dos registros da temptable de erro
                            pr_tipooper   IN INTEGER,                   --> Tipo de operação, 1 - Gerar XML, 2 --Gerar pltable
                            pr_dscritic   OUT VARCHAR2) IS              --> descrição da critica do erro

  /*..............................................................................

       Programa: pc_xml_tab_erro
       Autor   : Odirlei-AMcom
       Data    : Julho/2014                      Ultima atualizacao: 30/07/2014

       Dados referentes ao programa:

       Objetivo  : Manipular as informações da temptable de erro a fim de receber/enviar
                   para o progress

                   pr_tipooper:
                     1 - Gerar XML: Ler o parametro pr_tab_erro e retornar XML no parametro pr_xml_erro
                     2 - Gerar pltable: Ler o XML no parametro pr_xml_erro e retornar temptable no parametro pr_tab_erro

   ..............................................................................*/


    vr_xml_temp  VARCHAR2(32100);
    -- Variáveis para tratamento do XML
    vr_node_list xmldom.DOMNodeList;
    vr_parser    xmlparser.Parser;
    vr_doc       xmldom.DOMDocument;
    vr_lenght    NUMBER;
    vr_node_name VARCHAR2(100);
    vr_item_node xmldom.DOMNode;
    vr_idx       PLS_INTEGER;

    -- Arq XML
    vr_xmltype   sys.xmltype;

  BEGIN
    -- Gerar xml apartir da temp-table
    IF pr_tipooper = 1 THEN
      -- Criar documento XML dbms_lob.createtemporary(pr_clobxml, TRUE);
      dbms_lob.createtemporary(pr_xml_erro, TRUE);
      dbms_lob.open(pr_xml_erro, dbms_lob.lob_readwrite);

      -- Insere o cabeçalho do XML
      gene0002.pc_escreve_xml(pr_xml            => pr_xml_erro
                             ,pr_texto_completo => vr_xml_temp
                             ,pr_texto_novo     => '<?xml version="1.0" encoding="ISO-8859-1"?><raiz>');

      -- varrer registros de erro
      FOR idx IN pr_tab_erro.FIRST..pr_tab_erro.LAST LOOP
        -- escrever registros xml
        gene0002.pc_escreve_xml(pr_xml => pr_xml_erro
                               ,pr_texto_completo => vr_xml_temp
                               ,pr_texto_novo => '<registro>'||
                                                   '<cdcooper>'||pr_tab_erro(idx).cdcooper||'</cdcooper>'||
                                                   '<cdagenci>'||pr_tab_erro(idx).cdagenci||'</cdagenci>'||
                                                   '<nrdcaixa>'||pr_tab_erro(idx).nrdcaixa||'</nrdcaixa>'||
                                                   '<nrsequen>'||pr_tab_erro(idx).nrsequen||'</nrsequen>'||
                                                   '<cdcritic>'||pr_tab_erro(idx).cdcritic||'</cdcritic>'||
                                                   '<dscritic>'||pr_tab_erro(idx).dscritic||'</dscritic>'||
                                                   '<erro>'||pr_tab_erro(idx).erro||'</erro>'||
                                                   '<progress_recid>'||pr_tab_erro(idx).progress_recid||'</progress_recid>'||
                                                 '</registro>');
      END LOOP;

      -- descarregar buffer
      gene0002.pc_escreve_xml( pr_xml => pr_xml_erro
                              ,pr_texto_completo => vr_xml_temp
                              ,pr_texto_novo => '</raiz>'
                              ,pr_fecha_xml => TRUE);

    -- Gerar Temptable a partir do xml
    ELSIF pr_tipooper = 2 THEN
      -- Cria o XML a partir do CLOB carregado
      vr_xmltype := XMLType.createxml(pr_xml_erro);
      -- Faz o parse do XMLTYPE para o XMLDOM e libera o parser ao fim
      vr_parser  := xmlparser.newParser;
      xmlparser.parseClob(vr_parser,vr_xmltype.getClobVal());
      vr_doc     := xmlparser.getDocument(vr_parser);
      xmlparser.freeParser(vr_parser);

      -- Faz o get de toda a lista de elementos
      vr_node_list := xmldom.getElementsByTagName(vr_doc, '*');
      vr_lenght    := xmldom.getLength(vr_node_list);
      vr_idx       := 0;

      -- Percorrer os elementos
      FOR i IN 0..vr_lenght-1 LOOP
        -- Pega o item
        vr_item_node := xmldom.item(vr_node_list, i);
        -- Captura o nome do nodo
        vr_node_name := xmldom.getNodeName(vr_item_node);
        -- Verifica qual nodo esta sendo lido
        IF vr_node_name IN ('raiz') THEN
          -- Descer para o próximo filho
          CONTINUE;
        ELSIF vr_node_name IN ('registro') THEN
          -- se está no nó registro deve definir index da pltable
          vr_idx := nvl(vr_idx,0) + 1;
        -- Atribuir valores das tags nos registros da temptable
        ELSIF vr_node_name IN ('cdcooper') THEN
          pr_tab_erro(vr_idx).cdcooper := xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node));
        ELSIF vr_node_name IN ('cdagenci') THEN
          pr_tab_erro(vr_idx).cdagenci := xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node));
        ELSIF vr_node_name IN ('nrdcaixa') THEN
          pr_tab_erro(vr_idx).nrdcaixa := xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node));
        ELSIF vr_node_name IN ('nrsequen') THEN
          pr_tab_erro(vr_idx).nrsequen := xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node));
        ELSIF vr_node_name IN ('cdcritic') THEN
          pr_tab_erro(vr_idx).cdcritic := xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node));
        ELSIF vr_node_name IN ('dscritic') THEN
          pr_tab_erro(vr_idx).dscritic := xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node));
        ELSIF vr_node_name IN ('erro') THEN
          pr_tab_erro(vr_idx).erro := xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node));
        ELSIF vr_node_name IN ('progress_recid') THEN
          pr_tab_erro(vr_idx).progress_recid := xmldom.getnodevalue(xmldom.getfirstchild(vr_item_node));
        END IF;
      END LOOP;
    ELSE
      pr_dscritic := 'Opção invalida para o procedimento pc_xml_tab_erro';
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      pr_dscritic := 'Erro no procedimento GENE0001.pc_xml_tab_erro: '||SQLErrm;
  END pc_xml_tab_erro;

  /* Inclusão de log com retorno do rowid */
  PROCEDURE pc_gera_log(pr_cdcooper IN craplgm.cdcooper%TYPE
                       ,pr_cdoperad IN craplgm.cdoperad%TYPE
                       ,pr_dscritic IN craplgm.dscritic%TYPE
                       ,pr_dsorigem IN craplgm.dsorigem%TYPE
                       ,pr_dstransa IN craplgm.dstransa%TYPE
                       ,pr_dttransa IN craplgm.dttransa%TYPE
                       ,pr_flgtrans IN craplgm.flgtrans%TYPE
                       ,pr_hrtransa IN craplgm.hrtransa%TYPE
                       ,pr_idseqttl IN craplgm.idseqttl%TYPE
                       ,pr_nmdatela IN craplgm.nmdatela%TYPE
                       ,pr_nrdconta IN craplgm.nrdconta%TYPE
                       ,pr_nrdrowid OUT ROWID) IS
  BEGIN
    /*..............................................................................

       Programa: gera_log (Antigo gera_log.i>proc_gerar_log.i)
       Autor   : David
       Data    : Novembro/2007                      Ultima atualizacao: 02/03/2016

       Dados referentes ao programa:

       Objetivo  : Include para geracao de log

       Alteracoes: 19/04/2010 - Criar procedure proc_gerar_log_tab (Jose Luis/DB1)

                   22/08/2011 - Alterar parametro cdoperad para CHAR na procedure
                                proc_gerar_log_tab (David).
                   04/12/2012 - Conversão da rotina de Progress > Oracle PLSQL

                   17/04/2014 - Nao popular o campo nrsequen, pois sera atualizado
                                via trigger (Andrino - RKAM)

                   02/03/2015 - Tratar para não estourar o campo de dscritic (Odirlei-AMcom)             

    ..............................................................................*/
    BEGIN
      -- Criar registro do LOG guardando o Rowid
      INSERT INTO craplgm(cdcooper
                         ,cdoperad
                         ,dscritic
                         ,dsorigem
                         ,dstransa
                         ,dttransa
                         ,flgtrans
                         ,hrtransa
                         ,idseqttl
                         ,nmdatela
                         ,nrdconta)
                   VALUES(pr_cdcooper
                         ,pr_cdoperad
                         ,substr(pr_dscritic,1,245)
                         ,pr_dsorigem
                         ,pr_dstransa
                         ,pr_dttransa
                         ,pr_flgtrans
                         ,pr_hrtransa
                         ,pr_idseqttl
                         ,pr_nmdatela
                         ,pr_nrdconta)
                RETURNING ROWID INTO pr_nrdrowid;
    END;
  END pc_gera_log;

  /* Chamada para ser usada no progress
     Inclusão de log com retorno do rowid */
  PROCEDURE pc_gera_log_prog (pr_cdcooper IN craplgm.cdcooper%TYPE
                             ,pr_cdoperad IN craplgm.cdoperad%TYPE
                             ,pr_dscritic IN craplgm.dscritic%TYPE
                             ,pr_dsorigem IN craplgm.dsorigem%TYPE
                             ,pr_dstransa IN craplgm.dstransa%TYPE
                             ,pr_dttransa IN craplgm.dttransa%TYPE
                             ,pr_flgtrans IN craplgm.flgtrans%TYPE
                             ,pr_hrtransa IN craplgm.hrtransa%TYPE
                             ,pr_idseqttl IN craplgm.idseqttl%TYPE
                             ,pr_nmdatela IN craplgm.nmdatela%TYPE
                             ,pr_nrdconta IN craplgm.nrdconta%TYPE
                             ,pr_nrrecid OUT craplgm.progress_recid%TYPE) IS
    /*..............................................................................

       Programa: pc_gera_log_prog   (Antigo gera_log.i>proc_gerar_log.i)
       Autor   : David
       Data    : Novembro/2007                      Ultima atualizacao: 17/04/2014

       Dados referentes ao programa:

       Objetivo  : Chamada para ser usada no progress
                   Include para geracao de log

       Alteracoes:

    ..............................................................................*/
    --------------> CURSORES <-------------
    CURSOR cr_craplgm (pr_nrdrowid ROWID) IS
      SELECT progress_recid
        FROM craplgm
       WHERE craplgm.rowid = pr_nrdrowid;

    ------------> VARIAVEIS <--------------
    vr_nrdrowid   ROWID;


  BEGIN

    -- Gerar log ao cooperado (b1wgen0014 - gera_log);
    GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                        ,pr_cdoperad => pr_cdoperad
                        ,pr_dscritic => pr_dscritic
                        ,pr_dsorigem => pr_dsorigem
                        ,pr_dstransa => pr_dstransa
                        ,pr_dttransa => pr_dttransa
                        ,pr_flgtrans => pr_flgtrans
                        ,pr_hrtransa => pr_hrtransa
                        ,pr_idseqttl => pr_idseqttl
                        ,pr_nmdatela => pr_nmdatela
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);

    pr_nrrecid := NULL;
    -- buscar progress recid para retornar para o progress
    OPEN cr_craplgm (pr_nrdrowid => vr_nrdrowid);
    FETCH cr_craplgm INTO pr_nrrecid;
    CLOSE cr_craplgm;

  END pc_gera_log_prog;

  /* Inclusão de log a nível de item  */
  PROCEDURE pc_gera_log_item(pr_nrdrowid IN ROWID
                            ,pr_nmdcampo IN craplgi.nmdcampo%TYPE
                            ,pr_dsdadant IN craplgi.dsdadant%TYPE
                            ,pr_dsdadatu IN craplgi.dsdadatu%TYPE) IS
  BEGIN
    /*..............................................................................

       Programa: pc_gera_log_item (Antigo gera_log.i>>proc_gerar_log_item)
       Autor   : David
       Data    : Novembro/2007                      Ultima atualizacao: 06/02/2013

       Dados referentes ao programa:

       Objetivo  : Cria o registro dos itens log das transacoes vinculado ao registro que
                   foi passado via parametro da tabela principal

       Alteracoes: 06/02/2013 - Conversão da rotina de Progress > Oracle PLSQL

    ..............................................................................*/
    DECLARE
      -- Busca as informações no cabeçalho de Log
      CURSOR cr_craplgm IS
        SELECT lgm.cdcooper
              ,lgm.nrdconta
              ,lgm.idseqttl
              ,lgm.dttransa
              ,lgm.hrtransa
              ,lgm.nrsequen
          FROM craplgm lgm
         WHERE lgm.rowid = pr_nrdrowid;
      rw_craplgm cr_craplgm%ROWTYPE;
      -- Busca do ultimo sequencia de LOG do item
      CURSOR cr_craplgi IS
        SELECT lgi.nrseqcmp
          FROM craplgi lgi
         WHERE lgi.cdcooper = rw_craplgm.cdcooper
           AND lgi.nrdconta = rw_craplgm.nrdconta
           AND lgi.idseqttl = rw_craplgm.idseqttl
           AND lgi.dttransa = rw_craplgm.dttransa
           AND lgi.hrtransa = rw_craplgm.hrtransa
           AND lgi.nrsequen = rw_craplgm.nrsequen
         ORDER BY lgi.nrseqcmp DESC;
      -- Sequencia para inserção
      vr_nrseqcmp craplgi.nrseqcmp%TYPE;
    BEGIN
      -- Busca as informações no cabeçalho de Log
      OPEN cr_craplgm;
      FETCH cr_craplgm
       INTO rw_craplgm;
      -- Somente continuar se tiver encontrado
      IF cr_craplgm%FOUND THEN
        -- Busca do ultimo sequencia de LOG do item
        OPEN cr_craplgi;
        FETCH cr_craplgi
         INTO vr_nrseqcmp;
        -- Se encontrou
        IF cr_craplgi%FOUND THEN
          -- Incrementa a sequencia
          vr_nrseqcmp := vr_nrseqcmp + 1;
        ELSE
          -- Nova sequencia
          vr_nrseqcmp := 1;
        END IF;
        -- Fechar o cursor
        CLOSE cr_craplgi;
        -- Criar registro do LOG guardando o Rowid
        INSERT INTO craplgi(cdcooper
                           ,dsdadant
                           ,dsdadatu
                           ,nmdcampo
                           ,dttransa
                           ,hrtransa
                           ,idseqttl
                           ,nrdconta
                           ,nrsequen
                           ,nrseqcmp)
                     VALUES(rw_craplgm.cdcooper
                           ,pr_dsdadant
                           ,pr_dsdadatu
                           ,pr_nmdcampo
                           ,rw_craplgm.dttransa
                           ,rw_craplgm.hrtransa
                           ,rw_craplgm.idseqttl
                           ,rw_craplgm.nrdconta
                           ,rw_craplgm.nrsequen
                           ,vr_nrseqcmp);
      END IF;
    END;
  END pc_gera_log_item;

  /* Chamada para ser usada no progress
     Inclusão de log a nível de item  */
  PROCEDURE pc_gera_log_item_prog (pr_nrrecid  IN craplgm.progress_recid%TYPE
                                  ,pr_nmdcampo IN craplgi.nmdcampo%TYPE
                                  ,pr_dsdadant IN craplgi.dsdadant%TYPE
                                  ,pr_dsdadatu IN craplgi.dsdadatu%TYPE) IS

    /*..............................................................................

       Programa: pc_gera_log_item_prog (Antigo gera_log.i>>proc_gerar_log_item)
       Autor   : David
       Data    : Novembro/2007                      Ultima atualizacao: 06/02/2013

       Dados referentes ao programa:

       Objetivo  : Cria o registro dos itens log das transacoes vinculado ao registro que
                   foi passado via parametro da tabela principal

       Alteracoes: 06/02/2013 - Conversão da rotina de Progress > Oracle PLSQL

    ..............................................................................*/
    --------------> CURSORES <-------------
    CURSOR cr_craplgm (pr_nrrecid craplgm.progress_recid%TYPE) IS
      SELECT craplgm.rowid
        FROM craplgm
       WHERE craplgm.progress_recid = pr_nrrecid;

    ------------> VARIAVEIS <--------------
    vr_nrdrowid   ROWID;

  BEGIN
    -- buscar rowid
    OPEN cr_craplgm (pr_nrrecid => pr_nrrecid);
    FETCH cr_craplgm INTO vr_nrdrowid;
    CLOSE cr_craplgm;

    pc_gera_log_item(pr_nrdrowid => vr_nrdrowid
                    ,pr_nmdcampo => pr_nmdcampo
                    ,pr_dsdadant => pr_dsdadant
                    ,pr_dsdadatu => pr_dsdadatu);

  END pc_gera_log_item_prog;

  /* Procedimento para gravar log na tabela craplog */
  PROCEDURE pc_gera_craplog(pr_cdcooper IN craplog.cdcooper%TYPE
                           ,pr_nrdconta IN craplog.nrdconta%TYPE
                           ,pr_cdoperad IN craplog.cdoperad%TYPE
                           ,pr_dstransa IN craplog.dstransa%TYPE
                           ,pr_cdprogra IN craplog.cdprogra%TYPE) IS
  BEGIN
    /*..............................................................................

       Programa: pc_gera_craplog   (Antigo Fontes/gera_log.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Edson
       Data    : Maio/2005.                          Ultima atualizacao: 05/12/2013

       Dados referentes ao programa:

       Frequencia: Sempre que for chamado.
       Objetivo  : Gerar log da transacao - DEVE HAVER UMA TRANSACAO DECLARADA NO
                   PROGRAMA QUE FEZ A CHAMADA.

       Alteracoes: 05/12/2013 - Inclusao de VALIDATE craplog (Carlos)

                   08/04/2015 - Conversão Progress -> Oracle (Odirlei-AMcom)

    ..............................................................................*/
    -- Loop utilizado para ficar tentando inserir, visto que o time
    -- faz parte da chave da tabela, logo necessario virar o segundo para tentar novamente
    LOOP
      BEGIN
      -- Criar registro do LOG
      INSERT INTO craplog
                  ( craplog.dttransa
                   ,craplog.hrtransa
                   ,craplog.cdoperad
                   ,craplog.cdcooper
                   ,craplog.dstransa
                   ,craplog.nrdconta
                   ,craplog.cdprogra)
            VALUES( trunc(SYSDATE)          -- craplog.dttransa
                   ,GENE0002.fn_busca_time  -- craplog.hrtransa
                   ,pr_cdoperad            -- craplog.cdoperad
                   ,pr_cdcooper            -- craplog.cdcooper
                   ,pr_dstransa            -- craplog.dstransa
                   ,pr_nrdconta            -- craplog.nrdconta
                   ,pr_cdprogra);          -- craplog.cdprogra
      EXCEPTION
        WHEN dup_val_on_index THEN
          -- aguardar 1 seg. antes de tentar novamente
          sys.dbms_lock.sleep(1);
          continue;
      END;
      -- se conseguiu inserir sair do loop
      EXIT;
    END LOOP;
  END pc_gera_craplog;

  /* Procedimento que separa o path e o nome do arquivo de um path completo */
  PROCEDURE pc_separa_arquivo_path(pr_caminho  IN VARCHAR2
                                  ,pr_direto  OUT VARCHAR2
                                  ,pr_arquivo OUT VARCHAR2) IS
  BEGIN
    /*..............................................................................

       Programa: pc_separa_arquivo_path
       Autor   : Marcos (Supero)
       Data    : Dezembro/2012                      Ultima atualizacao: 05/12/2012

       Dados referentes ao programa:

       Objetivo  : Efetuar a separação do diretório e do nome do arquivo a partir de um caminho completo

       Alteracoes:

    ..............................................................................*/
    BEGIN
      -- Nome do arquivo está após a ultima ocorrência do '/'
      pr_arquivo := SUBSTR(pr_caminho,INSTR(pr_caminho,'/',-1)+1);
      pr_direto  := SUBSTR(pr_caminho,1,INSTR(pr_caminho,'/',-1)-1);
    END;
  END pc_separa_arquivo_path;

  /* Procedimento para abertura de arquivo fisico */
  PROCEDURE pc_abre_arquivo(pr_nmdireto IN VARCHAR2            --> Diretório do arquivo
                           ,pr_nmarquiv IN VARCHAR2            --> Nome do arquivo
                           ,pr_tipabert IN VARCHAR2            --> Modo de abertura (R,W,A)
                           ,pr_flaltper IN INTEGER DEFAULT 1   --> Altera permissão de acesso do arquivo (0 - Não altera / 1 - Altera)
                           ,pr_utlfileh IN OUT NOCOPY UTL_FILE.file_type --> Handle do arquivo aberto
                           ,pr_des_erro OUT VARCHAR2) IS       --> Saída de erros
    /*..............................................................................

       Programa: pc_abre_arquivo (Caminho e nome do arquivos passados separadamente)
       Autor   : Marcos (Supero)
       Data    : Maio/2013                      Ultima atualizacao: 30/08/2017

       Dados referentes ao programa:

       Objetivo  : Centralizar a abertura de arquivos pelo Oracle, assim garantimos
                   que logo após sua abertura, ocorra chmod para liberar o acesso aos
                   arquivos para outros usuários. Se isto não ocorrer, sempre que um
                   arquivo novo é criado, o Progress e os outros usuários da rede não
                   conseguem acessar este arquivo.

       Parametro pr_tipabert: "A" : Abre um arquivo e se existirem informações, posiciona na ultima linha sem limpá-las.
                              "R" : Abre o arquivo somente para leitura;
                              "W" : Abre o arquivo e limpa o mesmo, ou seja, sempre recria um arquivo novo.

       Alteracoes: 13/03/2015 - Adicionado parametro linesize 32767 na utl_file.fopen
                                (Alisson AMcom)

                   30/08/2017 - Ajuste para verificar se deve mudar permissões do arquivo ou não
                               (Adriano - SD 734960).             
                   

    ..............................................................................*/
  BEGIN
    BEGIN
      -- Testar modo de abertura enviado
      IF pr_tipabert NOT IN('R','W','A') THEN
        pr_des_erro := 'Modo de abertura "'||pr_tipabert||'" inválido, opções disponíveis: "R", "W" e "A"';
        RAISE vr_exc_erro;
      END IF;
      -- Tenta abrir o arquivo no modo solicitado
      BEGIN
        pr_utlfileh := UTL_FILE.fopen(pr_nmdireto,pr_nmarquiv,pr_tipabert,32767);
      EXCEPTION
        WHEN OTHERS THEN
          pr_des_erro := 'Problema ao abrir o arquivo <'||pr_nmdireto||'/'||pr_nmarquiv||'>: ' || sqlerrm;
          RAISE vr_exc_erro;
      END;
      
      IF pr_flaltper = 1                                                    AND 
         NVL(gene0001.fn_param_sistema('CRED',0,'ALTERA_PERMIS_ARQ'),0) = 1 THEN
         
      -- Ao final, tenta setar as propriedades para garantir que o arquivo seja acessível por outros usuários
      pc_OScommand_Shell(pr_des_comando => 'chmod 666 '||pr_nmdireto||'/'||pr_nmarquiv);
        
      END IF;
      
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Montar o erro
        pr_des_erro := 'Erro na rotina gene0001.pc_abre_arquivo --> '||pr_des_erro;
      WHEN OTHERS THEN
        -- Montar o erro
        pr_des_erro := 'Erro na rotina gene0001.pc_abre_arquivo --> Erro ao abrir o arquivo: '||sqlerrm;
    END;
  END pc_abre_arquivo;

  /* Procedimento para abertura de arquivo fisico passando o caminho completo */
  PROCEDURE pc_abre_arquivo(pr_nmcaminh IN VARCHAR2            --> Nome do caminho completo
                           ,pr_tipabert IN VARCHAR2            --> Modo de abertura (R,W,A)
                           ,pr_utlfileh IN OUT NOCOPY UTL_FILE.file_type --> Handle do arquivo aberto
                           ,pr_des_erro OUT VARCHAR2) IS       --> Saída de erros
    /*..............................................................................

       Programa: pc_abre_arquivo (Caminho completo)
       Autor   : Marcos (Supero)
       Data    : Maio/2013                      Ultima atualizacao: 06/05/2012

       Dados referentes ao programa:

       Objetivo  : Apenas efetuar overload da rotina de abertura do arquivo passando
                   o diretório e nome do arquivo separadamente, pois nesta rotina
                   é recebido o caminho completo

       Alteracoes:

    ..............................................................................*/
  BEGIN
    DECLARE
      -- Variaveis para separar o path do nome
      vr_nmdireto VARCHAR2(4000);
      vr_nmarquiv VARCHAR2(4000);
    BEGIN
      -- Chamar rotina de separação do caminho do nome
      pc_separa_arquivo_path(pr_caminho => pr_nmcaminh
                            ,pr_direto  => vr_nmdireto
                            ,pr_arquivo => vr_nmarquiv);
      -- Enfim, chamar a rotina de abertura do arquivo
      pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                     ,pr_nmarquiv => vr_nmarquiv
                     ,pr_tipabert => pr_tipabert
                     ,pr_utlfileh => pr_utlfileh
                     ,pr_des_erro => pr_des_erro);
    END;
  END pc_abre_arquivo;

  /* Procedimento para fechamento de arquivo fisico */
  PROCEDURE pc_fecha_arquivo(pr_utlfileh IN OUT NOCOPY UTL_FILE.file_type) IS --> Handle do arquivo aberto
    /*..............................................................................

       Programa: pc_fecha_arquivo
       Autor   : Marcos (Supero)
       Data    : Maio/2013                      Ultima atualizacao: 06/05/2012

       Dados referentes ao programa:

       Objetivo  : Centralizar o fechamento de arquivos fisicos abertos pelo Oracle.

       Alteracoes:

    ..............................................................................*/
  BEGIN
    BEGIN
      -- Libera o arquivo
      UTL_FILE.fclose(pr_utlfileh);
    END;
  END pc_fecha_arquivo;

  /* Procedimento para escrita em arquivo fisico */
  PROCEDURE pc_escr_linha_arquivo(pr_utlfileh  IN OUT NOCOPY UTL_FILE.file_type --> Handle do arquivo aberto
                                 ,pr_des_text  IN VARCHAR2) IS                  --> Texto para escrita
    /*..............................................................................

       Programa: pc_escr_linha_arquivo
       Autor   : Marcos (Supero)
       Data    : Maio/2013                      Ultima atualizacao: 06/05/2012

       Dados referentes ao programa:

       Objetivo  : Centralizar escrita em arquivos abertos pelo Oracle
                   ao final do envio, é enviado uma quebra de linha

       Alteracoes:

    ..............................................................................*/
  BEGIN
    BEGIN
      -- Escreve o texto enviado no arquivo
      UTL_FILE.put_line(pr_utlfileh,pr_des_text);
    END;
  END pc_escr_linha_arquivo;

  /* Procedimento para escrita em arquivo fisico sem quebrar a linha */
  PROCEDURE pc_escr_texto_arquivo(pr_utlfileh  IN OUT NOCOPY UTL_FILE.file_type --> Handle do arquivo aberto
                                 ,pr_des_text  IN VARCHAR2) IS                  --> Texto para escrita
    /*..............................................................................

       Programa: pc_escreve_arquivo_semqueb
       Autor   : Marcos (Supero)
       Data    : Maio/2013                      Ultima atualizacao: 06/05/2012

       Dados referentes ao programa:

       Objetivo  : Centralizar escrita em arquivos abertos pelo Oracle
                   sem enviar quebra de linha no arquivo

       Alteracoes:

    ..............................................................................*/
  BEGIN
    BEGIN
      -- Escreve o texto enviado no arquivo
      UTL_FILE.put(pr_utlfileh,pr_des_text);
    END;
  END pc_escr_texto_arquivo;

  /* Rotina para leitura de arquivo fisico */
  PROCEDURE pc_le_linha_arquivo(pr_utlfileh  IN OUT NOCOPY UTL_FILE.file_type --> Handle do arquivo aberto
                              ,pr_des_text OUT VARCHAR2) IS                  --> Texto lido
    /*..............................................................................

       Programa: pc_leitura_arquivo
       Autor   : Marcos (Supero)
       Data    : Maio/2013                      Ultima atualizacao: 06/05/2012

       Dados referentes ao programa:

       Objetivo  : Centralizar leitura em arquivos abertos pelo Oracle

       Alteracoes:

    ..............................................................................*/
  BEGIN
    BEGIN
      -- Ler a linha atual posicionada do arquivo
      UTL_FILE.get_line(pr_utlfileh,pr_des_text);
    EXCEPTION
      WHEN no_data_found THEN
        -- Levantar novamente a exceção pois a rotina chamadora
        -- terá de tratar quando o arquivo não possuir mais informações
        RAISE no_data_found;
    END;
  END pc_le_linha_arquivo;

  /* Verifica se existe um arquivo na pasta */
  FUNCTION fn_exis_arquivo(pr_caminho IN VARCHAR2) RETURN BOOLEAN IS
  /*..............................................................................

       Programa: fn_exis_arquivo
       Autor   : Petter (Supero)
       Data    : Setembro/2013                    Ultima atualizacao:

       Dados referentes ao programa:

       Objetivo  : Verificar se o arquivo informado existe no path.

       Alteracoes:

    ..............................................................................*/
  BEGIN
    DECLARE
      vr_arq_path   VARCHAR2(1000);
      vr_arq_name   VARCHAR2(1000);
      vr_arq_handle utl_file.file_type;

    BEGIN
      -- Busca somente o nome do arquivo a partir do path completo passado
      pc_separa_arquivo_path(pr_caminho => pr_caminho
                            ,pr_direto  => vr_arq_path
                            ,pr_arquivo => vr_arq_name);
      -- Testa se o arquivo foi criado com sucesso
      -- Abre arquivo somente para leitura
      vr_arq_handle := utl_file.fopen(vr_arq_path, vr_arq_name, 'r');
      utl_file.fclose(vr_arq_handle);
      RETURN TRUE;
    EXCEPTION
      WHEN no_data_found THEN
        RETURN FALSE;
      WHEN utl_file.INVALID_PATH THEN
        RETURN FALSE;
      WHEN utl_file.INVALID_OPERATION THEN
        RETURN FALSE;
      WHEN others THEN
        RETURN FALSE;
    END;
  END fn_exis_arquivo;

  /* Verifica se existe diretorio */
  FUNCTION fn_exis_diretorio(pr_caminho IN VARCHAR2) RETURN BOOLEAN IS
  /*..............................................................................

       Programa: fn_exis_arquivo
       Autor   : Odirlei (AMcom)
       Data    : Junho/2014                    Ultima atualizacao:

       Dados referentes ao programa:

       Objetivo  : Verificar se o diretorio.

       Alteracoes:

    ..............................................................................*/
  BEGIN
    DECLARE
      -- Saída do Shell
      vr_typ_saida VARCHAR2(3);
      vr_des_erro      VARCHAR2(4000);

    BEGIN

      -- Efetuar a execução do comando ls, para verificar se existe diretorio
      gene0001.pc_OScommand(pr_typ_comando  => 'S'
                            ,pr_des_comando => 'ls -ltr '||pr_caminho
                            ,pr_typ_saida   => vr_typ_saida
                            ,pr_des_saida   => vr_des_erro);
      -- Se retornou erro
      IF vr_typ_saida = 'ERR' THEN
        -- Se apresentou erro, diretorio não existe
        RETURN FALSE;
      ELSIF  vr_typ_saida = 'OUT' THEN
        -- se retornou saida porém vazio, diretorio não existe
        -- sempre retorna, até mesmo diretorio vazio, retorna o tamanho
        IF vr_des_erro is null THEN
           RETURN FALSE;
        ELSE
          -- diretorio existe
          RETURN TRUE;
        end if;
      ELSE
        -- diretorio não existe
        RETURN FALSE;
      END IF;


    EXCEPTION
      WHEN OTHERS THEN
        RETURN FALSE;
    END;
  END fn_exis_diretorio;

  /* Retornar o tamanho (bytes) do arquivo */
  FUNCTION fn_tamanho_arquivo(pr_caminho IN VARCHAR2) RETURN NUMBER IS
  BEGIN
    /*..............................................................................

       Programa: fn_tamanho_arquivo
       Autor   : Marcos (Supero)
       Data    : Outubro/2013                      Ultima atualizacao:

       Dados referentes ao programa:

       Objetivo  : Verificar se o arquivo passado existe

       Alteracoes:

    ..............................................................................*/
    DECLARE
      -- Diretório e nome do arquivo
      vr_direto VARCHAR2(4000);
      vr_arquivo VARCHAR2(4000);
      -- Teste no arquivo gerado
      vr_exists BOOLEAN;
      vr_tamanh NUMBER;
      vr_bsize  NUMBER;
    BEGIN
      -- Busca somente o nome do arquivo a partir do path completo passado
      pc_separa_arquivo_path(pr_caminho => pr_caminho
                            ,pr_direto  => vr_direto
                            ,pr_arquivo => vr_arquivo);
      -- Testa se o arquivo foi criado com sucesso
      utl_file.fgetattr(vr_direto,vr_arquivo,vr_exists,vr_tamanh,vr_bsize);
      -- Retornar o tamanho
      RETURN NVL(vr_tamanh,0);
    EXCEPTION
      WHEN OTHERS THEN
        RETURN 0;
    END;
  END fn_tamanho_arquivo;

  /* Função para retornar a extensão de um arquivo */
  FUNCTION fn_extensao_arquivo(pr_arquivo IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /*..............................................................................

       Programa: fn_extensao_arquivo
       Autor   : Marcos (Supero)
       Data    : Janeiro/2013                    Ultima atualizacao: 05/12/2012

       Dados referentes ao programa:

       Objetivo  : Retornar a extensao do arquivo

       Alteracoes:

          21/01/2014 - Ajustar rotina para retornar null, quando o arquivo não
                       possuir extensão. ( Renato - Supero )
    ..............................................................................*/
    BEGIN
      -- Verifica se há a presença de "." no nome do arquivo
      IF INSTR(pr_arquivo,'.') > 0 THEN
        -- Retornar todo o texto após o ultimo "."
        RETURN(SUBSTR(pr_arquivo,INSTR(pr_arquivo,'.',-1)+1));
      END IF;

      -- Retornar null
      RETURN NULL;

    EXCEPTION
      WHEN OTHERS THEN
        RETURN '';
    END;
  END fn_extensao_arquivo;

  /* Geração de ID para paralelismo */
  FUNCTION fn_gera_ID_paralelo RETURN INTEGER IS
  BEGIN
    /*..............................................................................

       Programa: fn_gera_ID_paralelo (Antiga sistema/generico/procedures/bo_paralelo.p --> geraID)
       Autor   : Marcos (Supero)
       Data    : Janeiro/2013                    Ultima atualizacao: 05/12/2012

       Dados referentes ao programa:

       Objetivo  : Função que gera um identificador randomico para cada programa que
                   executara em paralelo

       Alteracoes:

    ..............................................................................*/
    DECLARE
      -- Variável para saída
      vr_id INTEGER;
      -- Busca da existência do randomico encontrado
      CURSOR cr_crappar IS
        SELECT 'S'
          FROM crappar par
         WHERE par.idparale = vr_id;
      vr_achou VARCHAR2(1) := 'N';
    BEGIN
      -- Criar um laço pois precisamos buscar um ID único
      LOOP
        -- Gerar um Randômico entre 1 e 999999
        vr_id := ROUND(DBMS_RANDOM.VALUE(1,999999));
        -- Testar se o mesmo já existe
        vr_achou := 'N';
        OPEN cr_crappar;
        FETCH cr_crappar
         INTO vr_achou;
        -- Fechar o cursor
        CLOSE cr_crappar;
        -- Podemos sair do laço se não encontrou
        EXIT WHEN vr_achou = 'N';
      END LOOP;
      -- Retornar o ID encontrado
      RETURN vr_id;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN 0; --> Retorno com erro
    END;
  END fn_gera_ID_paralelo;

  /* Inicializa os controles do paralelismo */
  PROCEDURE pc_ativa_paralelo(pr_idparale IN crappar.idparale%TYPE
                             ,pr_idprogra IN crappar.idprogra%TYPE
                             ,pr_des_erro OUT VARCHAR2) IS
    -- Cria uma nova seção para commitar
    -- somente esta escopo de alterações
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    /*..............................................................................

       Programa: pc_ativa_paralelo (Antiga sistema/generico/procedures/bo_paralelo.p --> ativa_paralelo)
       Autor   : Marcos (Supero)
       Data    : Janeiro/2013                    Ultima atualizacao: 05/12/2012

       Dados referentes ao programa:

       Objetivo  : Procedure que inicializa os controles de um programa em paralelo

       Alteracoes:

    ..............................................................................*/

    BEGIN
      -- Inserir registro na tabela de controle de paralelismo
      INSERT INTO crappar par
                 (par.idparale
                 ,par.idprogra
                 ,par.flcontro)
           VALUES(pr_idparale
                 ,pr_idprogra
                 ,1); -- 'Sim'
      -- Gravar o Insert
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        -- Efetuar rollback
        ROLLBACK;
        -- Montar o erro
        pr_des_erro := 'Erro na rotina gene0001.pc_ativa_paralelo --> Erro ao inserir CRAPPAR: '||sqlerrm;
    END;
  END pc_ativa_paralelo;

  /* Procedure para aguardar a finalizacao dos programas em paralelo */
  PROCEDURE pc_aguarda_paralelo(pr_idparale IN crappar.idparale%TYPE
                               ,pr_qtdproce IN NUMBER
                               ,pr_des_erro OUT VARCHAR2) IS
  BEGIN
    /*..............................................................................

       Programa: pc_aguarda_paralelo (Antiga sistema/generico/procedures/bo_paralelo.p --> aguarda_paralelos)
       Autor   : Marcos (Supero)
       Data    : Janeiro/2013                    Ultima atualizacao: 05/12/2012

       Dados referentes ao programa:

       Objetivo  : Procedure para aguardar a finalizacao dos programas em paralelo

       Alteracoes:

    ..............................................................................*/
    DECLARE
      -- Buscar qtde em execução
      CURSOR cr_crappar IS
        SELECT COUNT(1)
          FROM crappar par
         WHERE par.idparale = pr_idparale
           AND par.flcontro = 1; --> Em execução
      vr_qtdproce NUMBER;
    BEGIN
      -- Efetuar laço para deixar o processo em aguardo
      -- até atingir determinada condição cfme o parâmetro
      -- pr_qtdproce passado e a qtde em execução
      LOOP
        -- Buscar quantidade em execução
        OPEN cr_crappar;
        FETCH cr_crappar
         INTO vr_qtdproce;
        CLOSE cr_crappar;
        -- Se não foi passado uma quantidade
        IF pr_qtdproce = 0 THEN
          -- Sair somente quando todos processarem
          EXIT WHEN vr_qtdproce = 0;
        ELSE
          -- Sair se a quantidade em execução for
          -- inferior a quantidade solicitada
          EXIT WHEN vr_qtdproce < pr_qtdproce;
        END IF;
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
        -- Efetuar rollback
        ROLLBACK;
        -- Montar o erro
        pr_des_erro := 'Erro na rotina gene0001.pc_aguarda_paralelo: '||sqlerrm;
    END;
  END pc_aguarda_paralelo;

  /* Inicializa os controles do paralelismo */
  PROCEDURE pc_encerra_paralelo(pr_idparale IN crappar.idparale%TYPE
                               ,pr_idprogra IN crappar.idprogra%TYPE
                               ,pr_des_erro OUT VARCHAR2) IS
     -- Cria uma nova seção para commitar
     -- somente esta escopo de alterações
     PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    /*..............................................................................

       Programa: pc_encerra_paralelo (Antiga sistema/generico/procedures/bo_paralelo.p --> finaliza_paralelo)
       Autor   : Marcos (Supero)
       Data    : Janeiro/2013                    Ultima atualizacao: 05/12/2012

       Dados referentes ao programa:

       Objetivo  : Procedure que inicializa os controles de um programa em paralelo

       Alteracoes:

    ..............................................................................*/
    BEGIN
      -- Inserir registro na tabela de controle de paralelismo
      DELETE crappar par
       WHERE par.idparale = pr_idparale
         AND par.idprogra = pr_idprogra
         AND par.flcontro = 1; -- 'Sim'
      -- Gravar
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        -- Efetuar rollback
        ROLLBACK;
        -- Montar o erro
        pr_des_erro := 'Erro na rotina gene0001.pc_encerra_paralelo --> Erro ao eliminar CRAPPAR: '||sqlerrm;
    END;
  END pc_encerra_paralelo;

  /* Incluir log de Jobs executados no Banco */
  PROCEDURE pc_gera_log_job(pr_cdcooper IN crapcop.cdcooper%TYPE
                           ,pr_des_log  IN VARCHAR2) IS
  BEGIN
    -- ..........................................................................
    --
    --  Programa : pc_gera_log_job
    --  Sistema  : Processos Genéricos
    --  Sigla    : GENE
    --  Autor    : Marcos E. Martini - Supero
    --  Data     : Janeiro/2013.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: ---
    --   Objetivo  : Prever método centralizado de log de Jobs
    --
    --   Alteracoes: 31/10/2013 - Troca do arquivo de log para salvar a partir
    --                            de agora no diretório log das Cooperativas (Marcos-Supero)
    -- .............................................................................

    DECLARE
      vr_ind_arqlog UTL_FILE.file_type; -- Handle para o arquivo de log
      vr_des_erro VARCHAR2(4000); -- Descrição de erro
      vr_exc_saida EXCEPTION; -- Saída com exception
      vr_des_complet VARCHAR2(100);
      vr_des_diretor VARCHAR2(100);
      vr_des_arquivo VARCHAR2(100);
    BEGIN
      -- Busca o diretório de log da Cooperativa
      vr_des_complet := gene0001.fn_diretorio(pr_tpdireto => 'C'
                                             ,pr_cdcooper => pr_cdcooper
                                             ,pr_nmsubdir => 'log');
      -- Buscar o nome de arquivo de log cfme parâmetros de sistema, se não vier nada, usa o default
      vr_des_complet := vr_des_complet ||'/'|| NVL(gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_JOBS'),'proc_job.log');
      -- Separa o diretório e o nome do arquivo
      gene0001.pc_separa_arquivo_path(pr_caminho => vr_des_complet
                                     ,pr_direto  => vr_des_diretor
                                     ,pr_arquivo => vr_des_arquivo);
      -- Tenta abrir o arquivo de log em modo append
      gene0001.pc_abre_arquivo(pr_nmdireto => vr_des_diretor   --> Diretório do arquivo
                              ,pr_nmarquiv => vr_des_arquivo   --> Nome do arquivo
                              ,pr_tipabert => 'A'              --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_ind_arqlog    --> Handle do arquivo aberto
                              ,pr_des_erro => vr_des_erro);
      IF vr_des_erro IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      -- Adiciona a linha de log
      BEGIN
        pc_escr_linha_arquivo(vr_ind_arqlog,pr_des_log);
      EXCEPTION
        WHEN OTHERS THEN
          -- Apenas imprimir na DMBS_OUTPUT e ignorar o log
          vr_des_erro := 'Problema ao escrever no arquivo <'||vr_des_diretor||'/'||vr_des_arquivo||'>: ' || sqlerrm;
          RAISE vr_exc_saida;
      END;
      -- Libera o arquivo
      BEGIN
        pc_fecha_arquivo(pr_utlfileh => vr_ind_arqlog);
      EXCEPTION
        WHEN OTHERS THEN
          -- Gerar erro
          vr_des_erro := 'Problema ao fechar o arquivo <'||vr_des_diretor||'/'||vr_des_arquivo||'>: ' || sqlerrm;
          RAISE vr_exc_saida;
      END;
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Enviar a mensagem de erro ao DMBS_OUTPUT e ignorar o log
        gene0001.pc_print(to_char(sysdate,'hh24:mi:ss')||' - '|| 'GENE0002.pc_gera_log_job --> '||vr_des_erro);
      WHEN OTHERS THEN
        -- Temporariamente apenas imprimir na tela
        gene0001.pc_print(pr_des_mensag => to_char(sysdate,'hh24:mi:ss')||' - '
                                           || 'GENE0002.pc_gera_log_job'
                                           || ' --> Erro não tratado : ' || sqlerrm);
    END;
  END pc_gera_log_job;

  /* Rotina para submeter um Job ao Banco */
  PROCEDURE pc_submit_job(pr_cdcooper  IN crapcop.cdcooper%TYPE          --> Código da cooperativa
                         ,pr_cdprogra  IN VARCHAR2                       --> Código do programa
                         ,pr_dsplsql   IN VARCHAR2                       --> Bloco PLSQL a executar
                         ,pr_dthrexe   IN TIMESTAMP WITH TIME ZONE DEFAULT SYSTIMESTAMP --> Data/Hora de execução
                         ,pr_interva   IN VARCHAR2 DEFAULT NULL          --> Função para calculo da próxima execução, ex: 'sysdate+1'
                         ,pr_jobname IN OUT VARCHAR2                     --> Nome único para o Job
                         ,pr_des_erro OUT VARCHAR2) IS                   --> Saída com erro
    -- Cria uma nova seção para commitar
    -- somente esta escopo de alterações
    PRAGMA AUTONOMOUS_TRANSACTION;
    
  BEGIN
    /*..............................................................................

       Programa: pc_submit_job
       Autor   : Marcos (Supero)
       Data    : Janeiro/2013                    Ultima atualizacao: 17/06/2016

       Dados referentes ao programa:

       Objetivo  : Rotina que agenda e submete ao banco um bloco PLSQL para executar

       Alteracoes: 17/10/2013 - Alteração para auto eliminar (auto_drop) o job quando
                                não houveram mais execuções agendadas (Marcos-Supero)

                   16/12/2015 - Alterado tipo do parametro pr_dthrexe para que permita incluir
                                timezone nomeado. SD361440 (Odirlei-AMcom)

                   10/06/2016 - Ajuste para retirar a chamada da função dbms_scheduler.generate_job_name
                                ao pegar o nome do JOB a ser criado
                                (Adriano - SD 464856).
                                
                   17/06/2016 - Ajustes para quando for uma rotina paralela(não possui intervalo) incremente o 
                                nome do job, para garantir a execução e caso ocorra erro, execute o rollback, 
                                devido a rotina ser autonoma. (Odirlei-AMcom)             
                                
    ..............................................................................*/
    
    BEGIN
      -- Efetuar geração de nome para o JOB
      pr_jobname := pr_jobname;
      
      --Caso o job não possuir intervalo, significa que é um job paralelo.
      -- que será executado e destruido.
      -- para isso devemos garantir que o nome não se repita
      IF TRIM(pr_interva) IS NULL THEN
        pr_jobname := dbms_scheduler.generate_job_name(substr(pr_jobname,1,18));
      END IF;      
      
      -- Chamar a rotina padrão do banco (dbms_scheduler.create_job)
      dbms_scheduler.create_job(job_name        => pr_jobname
                               ,job_type        => 'PLSQL_BLOCK' --> Indica que é um bloco PLSQL
                               ,job_action      => pr_dsplsql    --> Bloco PLSQL para execução
                               ,start_date      => pr_dthrexe    --> Data/hora para executar
                               ,repeat_interval => pr_interva    --> Função para calculo da próxima execução, ex: 'sysdate+1'
                               ,auto_drop       => TRUE          --> Quando não houver mais agendamentos, "dropar"
                               ,enabled         => TRUE);        --> Criar o JOB já ativando-o
                               
      -- Gerar LOG do Job que será executado
      -- Obs. Utilizamos um arquivo chamado (ProcJob)
      pc_gera_log_job(pr_cdcooper
                     ,'*******************************************************************************************************'||chr(13)
                    ||'Coop: '||pr_cdcooper||' --> Progr: '||pr_cdprogra||' Em: '||to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||chr(13)
                    ||'JobNM: '||pr_jobname||' - Data Agendada: '|| to_char(pr_dthrexe,'dd/mm/yyyy hh24:mi:ss')
                    ||' - Prox Exec: '||pr_interva|| chr(13) ||'Bloco PLSQL: '||chr(13)||pr_dsplsql||chr(13)
                    ||' Nenhum registro de erro no momento da submissao '||chr(13)
                    ||'*******************************************************************************************************');

      COMMIT;
      
    EXCEPTION
      WHEN OTHERS THEN
      cecred.pc_internal_exception(pr_compleme => '_'||pr_jobname ||'_');  
      
        ROLLBACK;
        -- Preparar saída com erro
        pr_des_erro := 'Erro na rotina gene0001.pc_submit_job --> '||sqlerrm;
        
        -- Adiciona também o erro no LOG
        pc_gera_log_job(pr_cdcooper
                      ,'*******************************************************************************************************'||chr(13)
                      ||'Coop: '||pr_cdcooper||' --> Progr: '||pr_cdprogra||' Em: '||to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||chr(13)
                      ||'JobNM: '||pr_jobname||' - Data Agendada: '|| to_char(pr_dthrexe,'dd/mm/yyyy hh24:mi:ss')
                      ||' - Prox Exec: '||pr_interva|| chr(13) ||'Bloco PLSQL: '||chr(13)||pr_dsplsql||chr(13)
                      ||' Erro encontrado: '||pr_des_erro||chr(13)
                      ||'*******************************************************************************************************');
      COMMIT;
    END;
  END pc_submit_job;

  /* Rotina para gravar log de item campo a campo */
  PROCEDURE pc_grava_campos_log_item(pr_nmtabela IN VARCHAR2                   --> Nome da tabela
                                    ,pr_rowidlgm IN ROWID                      --> Numero do ROWID do registro que foi inserido na CRAPLGM
                                    ,pr_rowidtab IN ROWID                      --> Numero do ROWID do registro que foi inserido na CRAPLGM
                                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da critica
                                    ,pr_dscritic OUT crapcri.dscritic%TYPE) IS --> Descricao da critica

  BEGIN
    /*..............................................................................

       Programa: pc_grava_campos_log_item
       Autor   : Jean Michel (CECRED)
       Data    : Agosto/2014                    Ultima atualizacao: 15/08/2014

       Dados referentes ao programa:

       Objetivo  : Rotina referente a gravação de log's de itens campo a campo

       Alteracoes:
    ..............................................................................*/
    DECLARE

      -- Variaveis de ERRO
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;

      -- Tratamento de erros
      vr_exc_saida EXCEPTION;

      -- Variaveis locais
      vr_indconta NUMBER := 0;
      vr_campchar VARCHAR2(4000);
      vr_campnume NUMBER;
      vr_campdate DATE;
      vr_dscursor NUMBER; --> ID da execução DBMS
      vr_execucao NUMBER; --> Identificação da execução
      vr_fetchlop NUMBER; --> Identificação do FETCH (iteração do LOOP)
      vr_dscampos VARCHAR2(1000);
      vr_dsconsul VARCHAR2(5000); -- Variavel de consulta SQL

      -- Temp table para armazenar registros de log
      type typ_reg_campos is record
        (dscampo varchar2(80),
        cdtipo  varchar2(80),
        qtchar  number);

      type typ_tab_campos is table of typ_reg_campos index by pls_integer;

      vr_tab_campos typ_tab_campos;

      CURSOR cr_ustacol(pr_nmtabela IN VARCHAR2) IS
        SELECT
          utc.column_name
         ,utc.data_type
         ,utc.data_length
        FROM
          user_tab_columns utc
        WHERE
              utc.TABLE_NAME = pr_nmtabela
          AND UPPER(utc.DATA_TYPE) in ('VARCHAR2','DATE','NUMBER','CHAR')
          AND UPPER(utc.column_name) <> 'PROGRESS_RECID'
          ORDER BY column_id;

      rw_ustacol cr_ustacol%ROWTYPE;

    BEGIN

      -- Buscar os campos da tabela
      OPEN cr_ustacol(pr_nmtabela => pr_nmtabela);

      LOOP

        FETCH cr_ustacol INTO rw_ustacol;

        -- Sai do loop quando chegar ao final dos regsitros
        EXIT WHEN cr_ustacol%NOTFOUND;

        -- Inicializa contador
        vr_indconta := vr_indconta + 1;

        -- Armeza informacoes relacionadas a campos
        vr_tab_campos(vr_indconta).dscampo :=  rw_ustacol.column_name;
        vr_tab_campos(vr_indconta).cdtipo  :=  rw_ustacol.data_type;
        vr_tab_campos(vr_indconta).qtchar  :=  rw_ustacol.data_length;

        -- Monta estrutura de campos para consulta
        IF vr_indconta > 1 THEN
          vr_dscampos := vr_dscampos || ',' || vr_tab_campos(vr_indconta).dscampo;
        ELSE
          vr_dscampos := vr_dscampos || vr_tab_campos(vr_indconta).dscampo;
        END IF;

      END LOOP;

      -- Buscar ID da execução DBMS
      vr_dscursor := dbms_sql.open_cursor;

      vr_dsconsul := 'SELECT ' || vr_dscampos || ' FROM ' || pr_nmtabela || ' WHERE rowid = ''' || pr_rowidtab || '''';
      -- Parser do SQL dinâmico
      -- Definir a query a ser executada
      dbms_sql.parse(vr_dscursor,  vr_dsconsul, 1);

      -- Definir os campos que serão extaridos
      FOR i IN vr_tab_campos.first..vr_tab_campos.last LOOP

        IF vr_tab_campos(i).cdtipo IN ('CHAR','VARCHAR2') THEN
          dbms_sql.define_column(vr_dscursor, i, vr_campchar, vr_tab_campos(i).qtchar);
        ELSIF vr_tab_campos(i).cdtipo = 'NUMBER' THEN
          dbms_sql.define_column(vr_dscursor, i, vr_campnume);
        ELSIF vr_tab_campos(i).cdtipo = 'DATE' THEN
          dbms_sql.define_column(vr_dscursor, i, vr_campdate);
        END IF;

      END LOOP;

      vr_execucao := dbms_sql.EXECUTE(vr_dscursor);

      -- Realizar FETCH sob os resultados retornados
      LOOP

        vr_fetchlop := dbms_sql.fetch_rows(vr_dscursor);

        EXIT WHEN vr_fetchlop = 0;

        -- Leitura da tabela temporaria para consulta de dados e gravacao de log
        FOR i IN vr_tab_campos.first..vr_tab_campos.last LOOP

          vr_campchar := NULL;
          vr_campnume  := NULL;

          -- Verifica qual o tipo de dados
          IF vr_tab_campos(i).cdtipo IN ('CHAR','VARCHAR2') THEN
            dbms_sql.column_value(vr_dscursor, i, vr_campchar);
          ELSIF vr_tab_campos(i).cdtipo = 'NUMBER' THEN
            dbms_sql.column_value(vr_dscursor, i, vr_campnume);
          ELSIF vr_tab_campos(i).cdtipo = 'DATE' THEN
            dbms_sql.column_value(vr_dscursor, i, vr_campdate);
            vr_campchar := to_char(vr_campdate,'DD/MM/RRRR');
          END IF;

          -- Gera item de log com informacao nova
          GENE0001.pc_gera_log_item(pr_nrdrowid => pr_rowidlgm
                                   ,pr_nmdcampo => vr_tab_campos(i).dscampo
                                   ,pr_dsdadant => ''
                                   ,pr_dsdadatu => nvl(vr_campchar, vr_campnume));

        END LOOP;

      END LOOP ;

    EXCEPTION
      WHEN vr_exc_saida THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

      WHEN OTHERS THEN

        pr_cdcritic := 0;
        pr_dscritic := 'Erro na rotina GENE0001.pc_grava_campos_log_item --> ' || SQLERRM;

    END;
  END pc_grava_campos_log_item;

  /* Geração de lista das cooperativas ativas */
  PROCEDURE pc_lista_cooperativas (pr_des_lista OUT VARCHAR2) IS
  BEGIN
    /*..............................................................................

       Programa: pc_lista_cooperativas
       Autor   : Marcos Martini (Supero)
       Data    : Setembro/2014                    Ultima atualizacao: 24/09/2014

       Dados referentes ao programa:

       Objetivo  : Rotina que gera uma lista das cooperativas trazendo seu código,
                   nome e agência centralizadora.

       Alteracoes:
    ..............................................................................*/
    DECLARE
  	  CURSOR cr_crapcop IS
  	    SELECT cdcooper
              ,nmrescop
  			  ,cdagectl
  		  FROM crapcop
  	     WHERE flgativo = 1
  	     ORDER BY cdcooper;
    BEGIN
  	  FOR rw_cop IN cr_crapcop LOOP
  	    IF pr_des_lista IS NOT NULL THEN
          pr_des_lista := pr_des_lista || '#';
  	    END IF;
  	    pr_des_lista := pr_des_lista || rw_cop.cdcooper||';'||rw_cop.nmrescop||';'||lpad(rw_cop.cdagectl,4,'0');
  	  END LOOP;
    END;
  END pc_lista_cooperativas;

  /* Verificacao do controle do batch por agencia ou convenio */
  PROCEDURE pc_verifica_batch_controle(pr_cdcooper    IN tbgen_batch_controle.cdcooper%TYPE    -- Codigo da Cooperativa
                                      ,pr_cdprogra    IN tbgen_batch_controle.cdprogra%TYPE    -- Codigo do Programa
                                      ,pr_dtmvtolt    IN tbgen_batch_controle.dtmvtolt%TYPE    -- Data de Movimento
                                      ,pr_tpagrupador IN tbgen_batch_controle.tpagrupador%TYPE -- Tipo de Agrupador (1-PA/ 2-Convenio)
                                      ,pr_cdagrupador IN tbgen_batch_controle.cdagrupador%TYPE -- Codigo do agrupador conforme (tpagrupador)
                                      ,pr_nrexecucao  IN tbgen_batch_controle.nrexecucao%TYPE  -- Numero de identificacao da execucao do programa
                                      ,pr_cdrestart  OUT tbgen_batch_controle.cdrestart%TYPE   -- Controle do registro de restart em caso de erro na execucao
                                      ,pr_insituacao OUT tbgen_batch_controle.insituacao%TYPE  -- Situacao da execucao (1-Executado erro/ 2-Executado sucesso)
                                      ,pr_cdcritic   OUT crapcri.cdcritic%TYPE                 -- Codigo da critica
                                      ,pr_dscritic   OUT crapcri.dscritic%TYPE) IS             -- Descricao da critica

  BEGIN
    /*..............................................................................

       Programa: pc_verifica_batch_controle
       Autor   : Jaison
       Data    : Agosto/2017                    Ultima atualizacao: 

       Dados referentes ao programa:

       Objetivo: Verifica o controle do batch por agencia ou convenio.

       Alteracoes: 

    ..............................................................................*/
    DECLARE
      -- Busca a existencia do registro
      CURSOR cr_controle IS
        SELECT tbc.cdrestart
              ,tbc.insituacao
          FROM tbgen_batch_controle tbc
         WHERE tbc.cdcooper    = pr_cdcooper
           AND tbc.cdprogra    = pr_cdprogra
           AND tbc.dtmvtolt    = pr_dtmvtolt
           AND tbc.tpagrupador = pr_tpagrupador
           AND tbc.cdagrupador = pr_cdagrupador
           AND tbc.nrexecucao  = pr_nrexecucao;
      rw_controle cr_controle%ROWTYPE;

      -- Variavel
      vr_flgachou BOOLEAN;

    BEGIN
      -- Inicializa
      pr_cdrestart  := 0;
      pr_insituacao := 1;

      -- Leitura do controle
      OPEN cr_controle;
      FETCH cr_controle INTO rw_controle;
      vr_flgachou := cr_controle%FOUND;
      CLOSE cr_controle;

      -- Se achou
      IF vr_flgachou THEN
        pr_cdrestart  := NVL(rw_controle.cdrestart,0);
        pr_insituacao := NVL(rw_controle.insituacao,1);
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na rotina GENE0001.pc_verifica_batch_controle: ' || SQLERRM;
    END;

  END pc_verifica_batch_controle;

  /* Grava o controle do batch por agencia ou convenio */
  PROCEDURE pc_grava_batch_controle(pr_cdcooper    IN tbgen_batch_controle.cdcooper%TYPE    -- Codigo da Cooperativa
                                   ,pr_cdprogra    IN tbgen_batch_controle.cdprogra%TYPE    -- Codigo do Programa
                                   ,pr_dtmvtolt    IN tbgen_batch_controle.dtmvtolt%TYPE    -- Data de Movimento
                                   ,pr_tpagrupador IN tbgen_batch_controle.tpagrupador%TYPE -- Tipo de Agrupador (1-PA/ 2-Convenio)
                                   ,pr_cdagrupador IN tbgen_batch_controle.cdagrupador%TYPE -- Codigo do agrupador conforme (tpagrupador)
                                   ,pr_cdrestart   IN tbgen_batch_controle.cdrestart%TYPE   -- Controle do registro de restart em caso de erro na execucao
                                   ,pr_nrexecucao  IN tbgen_batch_controle.nrexecucao%TYPE  -- Numero de identificacao da execucao do programa
                                   ,pr_idcontrole OUT tbgen_batch_controle.idcontrole%TYPE  -- ID de Controle
                                   ,pr_cdcritic   OUT crapcri.cdcritic%TYPE                 -- Codigo da critica
                                   ,pr_dscritic   OUT crapcri.dscritic%TYPE) IS             -- Descricao da critica
    PRAGMA AUTONOMOUS_TRANSACTION;  
  
  BEGIN
    /*..............................................................................

       Programa: pc_grava_batch_controle
       Autor   : Jaison
       Data    : Agosto/2017                    Ultima atualizacao: 

       Dados referentes ao programa:

       Objetivo: Grava o controle do batch por agencia ou convenio.

       Alteracoes: 

    ..............................................................................*/
    BEGIN
      -- Atualiza registro na tabela de controle
      UPDATE tbgen_batch_controle tbc
         SET tbc.cdrestart   = pr_cdrestart
       WHERE tbc.cdcooper    = pr_cdcooper
         AND tbc.cdprogra    = pr_cdprogra
         AND tbc.dtmvtolt    = pr_dtmvtolt
         AND tbc.tpagrupador = pr_tpagrupador
         AND tbc.cdagrupador = pr_cdagrupador
         AND tbc.nrexecucao  = pr_nrexecucao
   RETURNING tbc.idcontrole 
        INTO pr_idcontrole;

      -- Caso NAO tenha alterado, inclui
      IF SQL%ROWCOUNT = 0 THEN
        -- Insere registro na tabela de controle
        INSERT INTO tbgen_batch_controle tbc
                   (tbc.cdcooper
                   ,tbc.cdprogra
                   ,tbc.dtmvtolt
                   ,tbc.tpagrupador
                   ,tbc.cdagrupador
                   ,tbc.cdrestart
                   ,tbc.insituacao
                   ,tbc.nrexecucao)
             VALUES(pr_cdcooper
                   ,pr_cdprogra
                   ,pr_dtmvtolt
                   ,pr_tpagrupador
                   ,pr_cdagrupador
                   ,0
                   ,1 -- Executado com erro
                   ,pr_nrexecucao)
          RETURNING tbc.idcontrole 
               INTO pr_idcontrole;
      END IF;
      
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na rotina GENE0001.pc_grava_batch_controle: ' || SQLERRM;
    END;
    --
    COMMIT;   
    --
  END pc_grava_batch_controle;

  /* Finaliza o controle do batch por agencia ou convenio */
  PROCEDURE pc_finaliza_batch_controle(pr_idcontrole IN tbgen_batch_controle.idcontrole%TYPE -- ID de Controle
                                      ,pr_cdcritic  OUT crapcri.cdcritic%TYPE                -- Codigo da critica
                                      ,pr_dscritic  OUT crapcri.dscritic%TYPE) IS            -- Descricao da critica
  

    PRAGMA AUTONOMOUS_TRANSACTION;   
  
  BEGIN
    /*..............................................................................

       Programa: pc_finaliza_batch_controle
       Autor   : Jaison
       Data    : Agosto/2017                    Ultima atualizacao: 

       Dados referentes ao programa:

       Objetivo: Finaliza o controle do batch por agencia ou convenio.

       Alteracoes: 

    ..............................................................................*/

    BEGIN
      -- Atualiza registro na tabela de controle
      UPDATE tbgen_batch_controle tbc
         SET tbc.insituacao = 2 -- Executado com sucesso
            ,tbc.cdrestart  = 0
       WHERE tbc.idcontrole = pr_idcontrole;
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na rotina GENE0001.pc_finaliza_batch_controle: ' || SQLERRM;
    END;
    --
    COMMIT;
    --

  END pc_finaliza_batch_controle;

/* Retorno do cadastro de critica crapcri */
  PROCEDURE pc_le_crapcri 
    (pr_cdcritic     IN  crapcri.cdcritic%TYPE
    ,pr_tab_crapcri  OUT GENE0001.typ_tab_crapcri
    ,pr_dsretorno    OUT varchar2
    ,pr_cdretorno    OUT number)
  IS
  BEGIN
    /*..............................................................................

       Programa: pc_le_crapcri
       Autor   : Belli (Envolti)
       Data    : Junho/2017                    Ultima atualizacao: 08/06/2017

       Dados referentes ao programa:

       Objetivo  : Rotina que retorna ás informações do cadastro de critica.

       Alteracoes:
    ..............................................................................*/

    DECLARE
  	  CURSOR cr_crapcri IS
  	    SELECT dscritic
              ,progress_recid
              ,tpcritic
              ,flgchama 
  		  FROM crapcri
  	     WHERE cdcritic = pr_cdcritic;
         
      vr_dscritic         crapcri.dscritic%TYPE := NULL;
      vr_progress_recid   crapcri.progress_recid%TYPE := NULL;
      vr_tpcritic         crapcri.tpcritic%TYPE := NULL;
      vr_flgchama         crapcri.flgchama%TYPE := NULL;
      vr_seq              BINARY_INTEGER;
      vr_teste            number (1) := 0;
      
    PROCEDURE MONTA_TYPE 
      IS
    BEGIN  
      -- Guardar a próxima sequencia para gravação na tabela de erros
      vr_seq := pr_tab_crapcri.COUNT;
      -- Criar o registro de erro (Rowtype da CRAPERR)
      pr_tab_crapcri(vr_seq).cdcritic       := pr_cdcritic;
      pr_tab_crapcri(vr_seq).dscritic       := vr_dscritic;
      pr_tab_crapcri(vr_seq).progress_recid := vr_progress_recid;
      pr_tab_crapcri(vr_seq).tpcritic       := vr_tpcritic;
      pr_tab_crapcri(vr_seq).flgchama       := vr_flgchama;
    END;
    --
    --   INICIO  PROCESSO
    BEGIN
      
      pr_cdretorno   := 0;
      pr_dsretorno   := 'Inicio';
      vr_seq         := 0;
      
      IF pr_cdcritic is NULL THEN
        
          pr_cdretorno   := 3;
          pr_dsretorno   := 'Paramêtro de entrada nulo';
      
      ELSE          
          -- Busca cadastro da critica cfme parâmetro passado
          OPEN cr_crapcri;
          BEGIN
            FETCH cr_crapcri
            INTO 
             vr_dscritic
            ,vr_progress_recid
            ,vr_tpcritic
            ,vr_flgchama
            ;
      
            IF cr_crapcri%NOTFOUND THEN
               -- Se não encontrou nenhum registro
               pr_cdretorno      := 2; 
               pr_dsretorno      := 'Cadastro crapcri não existe';
            ELSE
               -- Se encontrou o registro
               MONTA_TYPE;      
               pr_cdretorno      := 1; 
               pr_dsretorno      := 'Sucesso';        
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              pr_cdretorno := 8;
              pr_dsretorno := 'Erro na rotina GENE0001.pc_le_crapcri FETCH --> ' || SQLERRM;
          END;
         
          -- Apenas fechar o cursor
          CLOSE cr_crapcri;    
      END IF; 
      
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdretorno := 9;
        pr_dsretorno := 'Erro na rotina GENE0001.pc_le_crapcri FINAL --> ' || SQLERRM;
    END;
  END pc_le_crapcri;

  /* Informação do modulo em execução na sessão */
  PROCEDURE pc_set_modulo    (pr_module IN VARCHAR2
                             ,pr_action IN VARCHAR2 DEFAULT NULL) IS
  BEGIN
  /*---------------------------------------------------------------------------------------------------------------
   Programa : pc_set_modulo
   Autor    : Cesar Belli
   Data     : 09/06/2017                        Ultima atualizacao: 29/06/2017   
   Chamado  : 660327

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Seta modulo e ação no banco de dados Oracle

   Alteracoes: 
               29/06/2017 - #660306 Alteração incluindo a possibilidade de setar somente a Action do Oracle (Belli-Envolti)
      
  ---------------------------------------------------------------------------------------------------------------*/

    if pr_module is null then
      -- Limpar qualquer informação anterior
      DBMS_APPLICATION_INFO.SET_ACTION('');
      -- Isto facilita monitoramento posterior
      DBMS_APPLICATION_INFO.SET_ACTION(action_name => pr_action);
    else
      -- Limpar qualquer informação anterior
      DBMS_APPLICATION_INFO.SET_MODULE('','');
      -- Isto facilita monitoramento posterior
      DBMS_APPLICATION_INFO.SET_MODULE(module_name => pr_module
                                    ,action_name => pr_action);
    end if;       
  END;

  /* Procedimento para verificar/controlar a execução de programas */
  PROCEDURE pc_controle_exec ( pr_cdcooper  IN crapcop.cdcooper%TYPE        --> Código da coopertiva
                              ,pr_cdtipope  IN VARCHAR2                     --> Tipo de operacao I-incrementar, C-Consultar e V-Validar
                              ,pr_dtmvtolt  IN DATE                         --> Data do movimento
                              ,pr_cdprogra  IN crapprg.cdprogra%TYPE        --> Codigo do programa
                              ,pr_flultexe OUT INTEGER                      --> Retorna se é a ultima execução do procedimento
                              ,pr_qtdexec  OUT INTEGER                      --> Retorna a quantidade
                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE        --> Codigo da critica de erro
                              ,pr_dscritic OUT VARCHAR2) IS                 --> descrição do erro se ocorrer
  /*---------------------------------------------------------------------------------------------------------------
  --  Programa : pc_controle_exec_deb
  --   Sistema : Conta-Corrente - Cooperativa de Credito
  --   Sigla   : CRED
  --   Autor   : Belli - Envolti
  --   Data    : Agosto/2017                       Ultima atualizacao: 
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Sempre que chamado
  -- Objetivo  : Procedimento para verificar/controlar a quantidade de execuções de programa por dia
  --
  -- Referência: Chamado 714566
  --
  -- Observação: Rotina Copiada/Refeita da SICR0001 pc_controle_exec_deb, sendo atualizada para ser genérica
  --
  --  Alteracoes:
  --
  --------------------------------------------------------------------------------------------------------------------*/
    ------------- Variaveis ---------------
    vr_exc_mensagem  EXCEPTION;
    vr_exc_erro  EXCEPTION;
    vr_dscritic  VARCHAR2(1000);

    vr_cdprogra  crapprg.cdprogra%TYPE;
    vr_tbdados   gene0002.typ_split;
    vr_dtctlexc  DATE   := NULL;
    vr_qtctlexc  INTEGER := 0;
    vr_qtdexec   INTEGER := 0;
    
    --
    vr_nmsistem        crapprm.nmsistem%TYPE := 'CRED';
    vr_cdacesso_ctl    crapprm.cdacesso%TYPE;
    vr_dsvlrprm_ctl    crapprm.dsvlrprm%TYPE;
    vr_dsvlrprm_qtd    crapprm.dsvlrprm%TYPE;
    vr_cdacesso_qtd    crapprm.dsvlrprm%TYPE;

    -- Controla Controla log em banco de dados
    PROCEDURE pc_controla_log_programa
    IS
      vr_idprglog           tbgen_prglog.idprglog%TYPE := 0;
      vr_tpocorrencia       tbgen_prglog_ocorrencia.tpocorrencia%type;
      vr_dstipoocorrencia   VARCHAR2   (10);    
    BEGIN         
      vr_dstipoocorrencia := 'ERRO: '; 
      vr_tpocorrencia     := 2; 
      --> Controlar geração de log de execução dos jobs                                
      CECRED.pc_log_programa(pr_dstiplog      => 'E', 
                             pr_cdprograma    => 'GENE0001', 
                             pr_cdcooper      => pr_cdcooper, 
                             pr_tpexecucao    => 2, --job
                             pr_tpocorrencia  => vr_tpocorrencia,
                             pr_cdcriticidade => 0, --baixa
                             pr_dsmensagem    => to_char(sysdate,'hh24:mi:ss') ||' - ' || 'GENE0001' || 
                                                         ' --> ' || vr_dstipoocorrencia || pr_dscritic ||
                                                         ' - pr_dtmvtolt: ' || pr_dtmvtolt ||
                                                         ' ,pr_cdcooper: ' || pr_cdcooper ||
                                                         ' ,pr_cdtipope: ' || pr_cdtipope ||
                                                         ' ,pr_cdprogra: ' || pr_cdprogra,
                             pr_idprglog      => vr_idprglog);
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log  
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);                                                             
    END pc_controla_log_programa;
    
  BEGIN
    --Limpar parametros saida
    pr_cdcritic:= NULL;
    pr_dscritic:= NULL;
    
    -- Incluir nome do modulo logado
    GENE0001.pc_set_modulo(pr_module => 'GENE0001', pr_action => 'pc_controle_exec');
    
    --Posiciona variaveis      
    vr_cdprogra     := pr_cdprogra;    
    vr_cdacesso_ctl := 'CTRL_'||upper(vr_cdprogra)||'_EXEC';

    BEGIN
      -- Confere se parâmetros chegaram
      IF pr_cdcooper IS NULL OR
         pr_cdtipope IS NULL OR
         pr_dtmvtolt IS NULL OR
         pr_cdprogra IS NULL   THEN
        vr_dscritic := 'Todos parâmetros devem ser preenchidos.';
        RAISE vr_exc_mensagem;
      END IF;
                             
      --> buscar parametro de controle de execução
      pc_param_sistema(pr_nmsistem  => vr_nmsistem      --> Nome do sistema
                      ,pr_cdcooper  => pr_cdcooper      --> Zero é utilizado para todas as COOPs
                      ,pr_cdacesso  => vr_cdacesso_ctl  --> Chave de acesso do parametro
                      ,pr_dsvlrprm  => vr_dsvlrprm_ctl  --> Deescrição do valor do parâmetro
                      );
    EXCEPTION
      WHEN vr_exc_mensagem THEN  
        RAISE vr_exc_mensagem;
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log  
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
        --Variavel de erro recebe erro ocorrido  
        vr_dscritic := 'Retorno pc_param_sistema - ' ||
                       ' vr_nmsistem: ' || vr_nmsistem ||
                       ' ,pr_cdcooper: ' || pr_cdcooper ||
                       ' ,vr_cdacesso_ctl: ' || vr_cdacesso_ctl ||
                       ' - ' || SQLERRM;
        RAISE vr_exc_erro;
    END;
    IF vr_dsvlrprm_ctl IS NULL THEN
      vr_dscritic := 'Parâmetro de sistema '|| vr_cdacesso_ctl || ' não encontrado.';
      RAISE vr_exc_mensagem;
    END IF;
        
    -- tratar dados do parametro
    vr_tbdados := gene0002.fn_quebra_string(pr_string  => vr_dsvlrprm_ctl,
                                            pr_delimit => '#');
    vr_dtctlexc := NULL;
    vr_qtctlexc := 0;
    --> Buscar data
    IF vr_tbdados.exists(1) THEN
      vr_dtctlexc := to_date(vr_tbdados(1),'DD/MM/RRRR');
    END IF;
    --> Buscar qtd
    IF vr_tbdados.exists(2) THEN
      vr_qtctlexc := vr_tbdados(2);
    END IF;
    
    -- Monta chave para cessar quantidade máxima de execuções por dia
    vr_cdacesso_qtd := 'QTD_EXEC_'||upper(vr_cdprogra);
    BEGIN
      --> buscar parametro de qtd de execução
      pc_param_sistema(pr_nmsistem  => vr_nmsistem      --> Nome do sistema
                      ,pr_cdcooper  => pr_cdcooper      --> Zero é utilizado para todas as COOPs
                      ,pr_cdacesso  => vr_cdacesso_qtd  --> Chave de acesso do parametro
                      ,pr_dsvlrprm  => vr_dsvlrprm_qtd  --> Deescrição do valor do parâmetro
                      );
    EXCEPTION
      WHEN vr_exc_mensagem THEN  
        RAISE vr_exc_mensagem;
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log  
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
        --Variavel de erro recebe erro ocorrido  
        vr_dscritic := 'Retorno pc_param_sistema - ' ||
                       ' vr_nmsistem: ' || vr_nmsistem ||
                       ' ,pr_cdcooper: ' || pr_cdcooper ||
                       ' ,vr_cdacesso_qtd: ' || vr_cdacesso_qtd ||
                       ' - ' || SQLERRM;
        RAISE vr_exc_erro;
    END;
    -- Critica se não tem registro
    IF vr_dsvlrprm_qtd IS NULL THEN
      vr_dscritic := 'Parâmetro de sistema ' || vr_cdacesso_qtd || ' não encontrado.';
      RAISE vr_exc_mensagem;
    END IF;

    --  Se tipo de operação for Incrementar
    IF pr_cdtipope = 'I' THEN
      -- Se mudou a data, deve reiniciar o parametro
      IF nvl(vr_dtctlexc,to_date('01/01/2001','DD/MM/RRRR')) <> pr_dtmvtolt THEN
        vr_qtdexec := 1;
      ELSIF vr_qtctlexc >= vr_dsvlrprm_qtd THEN
        vr_dscritic := 'Processo '||vr_cdprogra||' já ultrapassou o limite diario de execução.';
        RAISE vr_exc_mensagem;
      ELSE
        vr_qtdexec := nvl(vr_qtctlexc,0) + 1;
      END IF;            

      BEGIN
        UPDATE crapprm
           SET crapprm.dsvlrprm = to_char(pr_dtmvtolt,'DD/MM/RRRR')||'#'||vr_qtdexec
         WHERE nmsistem =  vr_nmsistem
           AND cdcooper IN (pr_cdcooper,0) --> Busca tanto da passada, quanto da geral (se existir)
           AND cdacesso =  vr_cdacesso_ctl;
        
        IF SQL%ROWCOUNT <> 1 THEN
          vr_dscritic := 'Não foi possível atualizar parâmetro , SQL%ROWCOUNT: '||SQL%ROWCOUNT;
          RAISE vr_exc_erro;
        END IF;
      EXCEPTION
        WHEN vr_exc_mensagem THEN  
          RAISE vr_exc_mensagem;
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log  
          CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
          vr_dscritic := 'Não foi possível atualizar parâmetro '||vr_cdacesso_ctl||':'||SQLERRM;
          RAISE vr_exc_erro;
      END;
    --> Validar
    ELSIF pr_cdtipope = 'V' THEN
      -- Se mudou a data, deve reiniciar o parametro
      IF nvl(vr_dtctlexc,to_date('01/01/2001','DD/MM/RRRR')) <> nvl(pr_dtmvtolt,to_date('01/01/2001','DD/MM/RRRR')) THEN
        vr_qtdexec := 1;
      ELSIF vr_qtctlexc >= vr_dsvlrprm_qtd THEN
        vr_dscritic := 'Processo '||vr_cdprogra||' já ultrapassou o limite diario de execução.';
        RAISE vr_exc_mensagem;
      ELSE
        vr_qtdexec := nvl(vr_qtctlexc,0) + 1;
      END IF;
    ELSE --> Consulta
      vr_qtdexec := vr_qtctlexc;
    END IF;

    --> Verificar se é a ultima execucao
    IF vr_qtdexec >= vr_dsvlrprm_qtd THEN
      pr_flultexe := 1;
    ELSE
      pr_flultexe := 0;
    END IF;

    pr_qtdexec := vr_qtdexec;

  EXCEPTION
    WHEN vr_exc_mensagem THEN  
      -- Efetuar retorno do erro tratado
      pr_dscritic := vr_dscritic;
    WHEN vr_exc_erro THEN  
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 9999;
      pr_dscritic := vr_dscritic;
      -- Controla Controla log em banco de dados
      pc_controla_log_programa;
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log  
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);   
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 9999;
      pr_dscritic := SQLERRM;
      -- Controla Controla log em banco de dados
      pc_controla_log_programa;
  END;
  --
  FUNCTION fn_retorna_qt_paralelo( pr_cdcooper  IN crapcop.cdcooper%TYPE    --> Código da coopertiva
                                 , pr_cdprogra  IN crapprg.cdprogra%TYPE)   --> Codigo do programa
           RETURN tbgen_batch_param.qtparalelo%TYPE IS
 
    -- ..........................................................................
    --
    --  Programa : fn_retorna_qt_paralelo
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Jonatas Jaqmam(AMcom)
    --  Data     : Dezembro/2017.                   Ultima atualizacao: 14/12/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia  : Sempre que chamado por outros programas.
    --   Objetivo    : Buscar o parâmetro de quantidade de jobs paralelos
    --   Observações : Projeto Ligeirinho
    --                 
    --
    --   Alteracoes:
    --
    -- .............................................................................
  
    vr_qtparalelo tbgen_batch_param.qtparalelo%TYPE;
                                
  BEGIN
    
    BEGIN
      SELECT t.qtparalelo
        INTO vr_qtparalelo
        FROM tbgen_batch_param t
       WHERE t.cdcooper   = pr_cdcooper
         AND t.cdprograma = pr_cdprogra;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        vr_qtparalelo := 0;  
    END;

    RETURN vr_qtparalelo;

  END fn_retorna_qt_paralelo;                                 
  --
  FUNCTION fn_retorna_qt_reg_commit( pr_cdcooper  IN crapcop.cdcooper%TYPE    --> Código da coopertiva
                                   , pr_cdprogra  IN crapprg.cdprogra%TYPE)   --> Codigo do programa
           RETURN tbgen_batch_param.qtreg_transacao%TYPE IS
 
    -- ..........................................................................
    --
    --  Programa : fn_retorna_qt_reg_commit
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Jonatas Jaqmam(AMcom)
    --  Data     : Dezembro/2017.                   Ultima atualizacao: 18/12/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia  : Sempre que chamado por outros programas.
    --   Objetivo    : Buscar o parâmetro de quantidade de registro para realizar commit
    --   Observações : Projeto Ligeirinho
    --                 
    --
    --   Alteracoes:
    --
    -- .............................................................................
  
    vr_registro tbgen_batch_param.qtreg_transacao%TYPE;
                                
  BEGIN
    
    BEGIN
      SELECT t.qtreg_transacao
        INTO vr_registro
        FROM tbgen_batch_param t
       WHERE t.cdcooper   = pr_cdcooper
         AND t.cdprograma = pr_cdprogra;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        vr_registro := 0;  
    END;

    RETURN vr_registro;

  END fn_retorna_qt_reg_commit;      
  -- 
  FUNCTION fn_retorna_restart(pr_cdcooper    IN tbgen_batch_controle.cdcooper%TYPE,
                              pr_cdprogra    IN tbgen_batch_controle.cdprogra%TYPE,
                              pr_nrexecucao  IN tbgen_batch_controle.nrexecucao%TYPE,
                              pr_cdagrupador IN tbgen_batch_controle.cdagrupador%TYPE) 
           RETURN tbgen_batch_controle.cdrestart%TYPE IS
  
    -- ..........................................................................
    --
    --  Programa : fn_retorna_restart
    --  Sistema  : Conta-Corrente - Cooperativa de Credito
    --  Sigla    : CRED
    --  Autor    : Jonatas Jaqmam(AMcom)
    --  Data     : Dezembro/2017.                   Ultima atualizacao: 18/12/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia  : Sempre que chamado por outros programas.
    --   Objetivo    : Buscar o identificador de restart das rotinas 
    --   Observações : Projeto Ligeirinho
    --                 
    --
    --   Alteracoes:
    --
    -- .............................................................................   
  
   CURSOR cr_controle IS
      SELECT tbc.cdrestart
        FROM tbgen_batch_controle tbc
       WHERE tbc.cdcooper    = pr_cdcooper 
         and tbc.cdprogra    = pr_cdprogra
         and tbc.nrexecucao  = pr_nrexecucao
         and tbc.cdagrupador = pr_cdagrupador
         and tbc.dtmvtolt    = (select max(a.dtmvtolt)
                                  from tbgen_batch_controle a
                                 where a.cdcooper = tbc.cdcooper
                                   and a.cdprogra = tbc.cdprogra
                                   and a.nrexecucao = tbc.nrexecucao
                                   and a.cdagrupador = tbc.cdagrupador);

    vr_cdrestart tbgen_batch_controle.cdrestart%TYPE;
    
  BEGIN
    
    OPEN cr_controle;
    FETCH cr_controle INTO vr_cdrestart;
    IF cr_controle%NOTFOUND THEN  
      vr_cdrestart := 0;
    END IF;
    CLOSE cr_controle;
    
    RETURN vr_cdrestart; 
    
  END fn_retorna_restart;
  
  FUNCTION fn_ret_qt_erro_paralelo(pr_cdcooper    IN tbgen_batch_controle.cdcooper%TYPE    -- Codigo da Cooperativa
                                  ,pr_cdprogra    IN tbgen_batch_controle.cdprogra%TYPE    -- Codigo do Programa
                                  ,pr_dtmvtolt    IN tbgen_batch_controle.dtmvtolt%TYPE    -- Data de Movimento
                                  ,pr_tpagrupador IN tbgen_batch_controle.tpagrupador%TYPE -- Tipo de Agrupador (1-PA/ 2-Convenio)
                                  ,pr_nrexecucao  IN tbgen_batch_controle.nrexecucao%TYPE  -- Numero de identificacao da execucao do programa
                                  ) RETURN NUMBER IS
    
    v_qt_erro NUMBER := 0;
  BEGIN
    
    BEGIN
      select count(*)
        into v_qt_erro
        from tbgen_batch_controle c
       where c.cdcooper    = pr_cdcooper
         and c.cdprogra    = pr_cdprogra
         and c.dtmvtolt    = pr_dtmvtolt
         and c.nrexecucao  = pr_nrexecucao
         AND c.tpagrupador = pr_tpagrupador
         and c.insituacao  = 1;
     EXCEPTION
       WHEN OTHERS THEN
         v_qt_erro := 0;
     END; 
     
     RETURN v_qt_erro; 
    
  END;  

END GENE0001;
/
