CREATE OR REPLACE PACKAGE CECRED.CYBE0002 IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa: CYBE0002
  --  Autor   : Andre Santos - SUPERO
  --  Data    : Outubro/2013                     Ultima Atualizacao: 20/07/2017
  --
  --  Dados referentes ao programa:
  --
  --  Objetivo  : Package referente a regras de reabilitação forçada dos cooperados
  --
  --  Alteracoes: 12/06/2015 - Ajustando os tamanho dos campos de operador
  --                           (Andre Santos - SUPERO)
  --
  --              06/10/2015 - Tornar publica a procedure pc_solicita_remessa.
  --                           (Jaison/Cechet)
  --
  --              07/10/2015 - Remocao do campo hrinterv da pc_grava_gerais_prmrbc.
  --                           Inclusao dos campos hrinterv e idtpsoli na
  --                           pc_grava_bureaux_prmrbc. (Jaison/Marcos-Supero)
  --
  --              13/11/2015 - Correcao na rotina pc_grava_arquivo_reafor, existia uma
  --                           chamada da rotina pc_incrementa_linha passando 8 como parametro
  --                           quando o correto seria passar 1. Chamado 347582 (Heitor - RKAM)                            
  --
  --              20/07/2017 - Inclusão do módulo e ação logado no oracle
  --                         - Inclusão da  chamada de procedure em exception others
  --                         - Colocado logs no padrão
  --                         - Tratamento tipo do log da critica de retorno de remessa
  --                           ( Belli - Envolti - Chamado 669487/719114 )
  --
  --              10/10/2017 - M434 - Adicionar dois novos parâmetros para atender o SPC/Brasil que usa chave 
  --                           de criptografia para o acesso ao SFTP. (Oscar)
  -- 
  ---------------------------------------------------------------------------------------------------------------

  -- Funcao generica para buscar o nome resumido da cooperativa --
  FUNCTION fn_nom_cooperativa(pr_cdcooper IN crapcop.cdcooper%TYPE) RETURN VARCHAR2;

  -- Descrição do evento da remessa
  FUNCTION fn_des_evento_remessa(pr_cdesteve IN craperb.cdesteve%TYPE) RETURN VARCHAR2;

  -- Função para montagem da string de busca da remessa de envio de arquivos COBEMP --
  FUNCTION fn_chbusca_cobemp(pr_rowid ROWID) return VARCHAR2;

  -- Função para montagem da string de busca da remessa de envio --
  FUNCTION fn_chbusca_ppware(pr_rowid ROWID) return VARCHAR2;

  -- Funcao para renomeação do arquivo antes do envio ao Serasa --
  FUNCTION fn_nmarquiv_env_serasa(pr_rowid IN ROWID) RETURN VARCHAR2;

  -- Funcao para montagem do nome do arquivo a retornar do Serasa --
  FUNCTION fn_nmarquiv_ret_serasa(pr_rowid IN ROWID) RETURN VARCHAR2;

  -- Funcao para validar a ligação do arquivo enviado com o retornado em parâmetro
  FUNCTION fn_valida_retor_serasa(pr_rowid IN ROWID
                                 ,pr_dsret IN VARCHAR2) RETURN VARCHAR2;

  -- Função para montagem da chave da remessa serasa
  FUNCTION fn_chvrem_serasa(pr_rowid ROWID) RETURN VARCHAR2;

  -- Funcao para renomeação do nome do arquivo a retornar do Serasa ao PPWare --
  FUNCTION fn_nmarquiv_dev_serasa(pr_rowid IN ROWID) RETURN VARCHAR2;

  -- Funcao para montagem do nome do arquivo a retornar da HUMAN --
  FUNCTION fn_nmarquiv_ret_sms(pr_rowid IN ROWID) RETURN VARCHAR2;

  -- Funcao para montagem do nome do arquivo a retornar do SPC --
  FUNCTION fn_nmarquiv_ret_spc(pr_rowid IN ROWID) RETURN VARCHAR2;

  /* Procedimento para retornar a situação de cada evento do Bureaux */
  PROCEDURE pc_lst_estagio_bureaux(pr_idtpreme IN crapcrb.idtpreme%TYPE     --> Tipo do Bureaux
                                  ,pr_dtmvtolt IN crapcrb.dtmvtolt%TYPE     --> Data da Remessa
                                  ,pr_dssitpre OUT VARCHAR2                 --> Situação do recebimento da PPWare
                                  ,pr_dssitenv OUT VARCHAR2                 --> Situação do envio ao Bureaux
                                  ,pr_dssitret OUT VARCHAR2                 --> Situação do retorno do Bureaux
                                  ,pr_dssitdev OUT VARCHAR2                 --> Situação da devolução a PPWare
                                  );

  /* Centralização da gravação dos Eventos da Remessa */
  PROCEDURE pc_insere_evento_remessa(pr_idtpreme IN VARCHAR2            --> Tipo da remessa
                                    ,pr_dtmvtolt IN DATE                --> Data da remessa
                                    ,pr_nrseqarq IN NUMBER DEFAULT NULL --> Sequencial do arquivo (Opcional)
                                    ,pr_cdesteve IN PLS_INTEGER         --> Estágio do evento
                                    ,pr_flerreve IN PLS_INTEGER         --> Flag de evento de erro
                                    ,pr_dslogeve IN VARCHAR2            --> Log do evento
                                    ,pr_dscritic OUT VARCHAR2);         --> Retorno de crítica

  -- Busca todos os Bureaux cadastrados conforme a tela chamadora
  PROCEDURE pc_lista_bureaux(pr_cdprogra IN crapprg.cdprogra%TYPE
                            ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  -- Busca lista de contas do associado
  PROCEDURE pc_lista_contas_associ(pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE
                                  ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  -- Busca lista de contratos relacionados a conta
  PROCEDURE pc_lista_contratos_associ(pr_nrdconta IN VARCHAR2
                                     ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2);

  -- Busca lista de contratos relacionados a conta
  PROCEDURE pc_grava_reafor(pr_dtmvtolt IN VARCHAR2
                           ,pr_cdoperad IN VARCHAR2
                           ,pr_nrcpfcgc IN VARCHAR2
                           ,pr_nrdconta IN VARCHAR2
                           ,pr_nrctremp IN VARCHAR2
                           ,pr_rowid    IN VARCHAR2
                           ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2);

  -- Busca lista de contratos relacionados a conta
  PROCEDURE pc_exclui_reafor(pr_rowid    IN VARCHAR2
                            ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2);

  -- Busca dados para exibir na tela REAFOR
  PROCEDURE pc_lista_dados_reafor(pr_dtmvtolt IN VARCHAR2              --> Data informada na tela
                                 ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2);           --> Erros do processo

  -- Busca dados para exibir na tela REAFOR
  PROCEDURE pc_retorna_reafor(pr_rowid    IN VARCHAR2
                             ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2);

  -- Procedimento de busca os dados das remessas no periodo de data informado em tela
  PROCEDURE pc_lista_dados_logrbc(pr_idtpreme IN VARCHAR2              --> Tipo de Remessa
                                 ,pr_dtmvtolt IN VARCHAR2              --> Data do Movimento
                                 ,pr_idpenden IN VARCHAR2              --> Filtro de Registros Pendentes
                                 ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2);

  -- Procedimento de busca os detalhes dos dados da remessa selecionado em tela
  PROCEDURE pc_lista_eventos_logrcb(pr_rowid    IN VARCHAR2              --> ID dos eventos de remessas
                                   ,pr_nmarquiv IN VARCHAR2              --> Nome do arquivo de remessa
                                   ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2);

  -- Procedimento de solicitacao de cancelamento de remessa
  PROCEDURE pc_solic_cancel_remes_logrbc(pr_rowid    IN VARCHAR2
                                        ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                        ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                        ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2);

  -- Procedimento de cancelamento de remessa
  PROCEDURE pc_cancel_remessa_logrbc(pr_rowid    IN VARCHAR2
                                    ,pr_dsmotcan IN VARCHAR2
                                    ,pr_nmarqcan IN VARCHAR2
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2);

  -- Procedimento que busca os dados de parametros de sistema para exibir na tela
  PROCEDURE pc_dados_gerais_prmrbc(pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                  ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro  OUT VARCHAR2);

  -- Procedimento que busca os dados de parametros de sistema para exibir na tela
  PROCEDURE pc_dados_bureaux_prmrbc(pr_idtpreme  IN VARCHAR2              --> Tipo de Remessa
                                   ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro  OUT VARCHAR2);

  -- Procedimento de gravacao de parametros de sistema
  PROCEDURE pc_grava_gerais_prmrbc(pr_hrdenvio  IN VARCHAR2
                                  ,pr_hrdreton  IN VARCHAR2
                                  ,pr_hrdencer  IN VARCHAR2
                                  ,pr_hrdencmx  IN VARCHAR2
                                  ,pr_dsdirarq  IN VARCHAR2
                                  ,pr_desemail  IN VARCHAR2
                                  ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                  ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro  OUT VARCHAR2);

  PROCEDURE pc_grava_bureaux_prmrbc(pr_lstpreme  IN VARCHAR2
                                   ,pr_idtpreme  IN VARCHAR2
                                   ,pr_flgativo  IN VARCHAR2
                                   ,pr_idenvseg  IN VARCHAR2
                                   ,pr_flremseq  IN VARCHAR2
                                   ,pr_idtpsoli  IN VARCHAR2
                                   ,pr_dsfnchrm  IN VARCHAR2
                                   ,pr_idtpenvi  IN VARCHAR2
                                   ,pr_dsdirenv  IN VARCHAR2
                                   ,pr_dsfnburm  IN VARCHAR2
                                   ,pr_dssitftp  IN VARCHAR2
                                   ,pr_dsusrftp  IN VARCHAR2
                                   ,pr_dspwdftp  IN VARCHAR2
                                   ,pr_dsdreftp  IN VARCHAR2
                                   ,pr_dsdrencd  IN VARCHAR2
                                   ,pr_dsdrevcd  IN VARCHAR2
                                   ,pr_dsfnrnen  IN VARCHAR2
                                   ,pr_idopreto  IN VARCHAR2
                                   ,pr_qthorret  IN VARCHAR2
                                   ,pr_hrinterv  IN VARCHAR2
                                   ,pr_dsdrrftp  IN VARCHAR2
                                   ,pr_dsdrrecd  IN VARCHAR2
                                   ,pr_dsdrrtcd  IN VARCHAR2
                                   ,pr_dsdirret  IN VARCHAR2
                                   ,pr_dsfnrndv  IN VARCHAR2
                                   ,pr_dsfnburt  IN VARCHAR2
                                   ,pr_dsfnchrt  IN VARCHAR2
                                   ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro  OUT VARCHAR2);

  -- Limpeza centralizada de diretório
  PROCEDURE pc_limpeza_diretorio(pr_nmdireto IN VARCHAR2      --> Diretório para limpeza
                                ,pr_dscritic OUT VARCHAR2);   --> Retorno de crítica

  -- Rotina para solicitar o processo de envio / retorno dos arquivos dos Bureaux
  PROCEDURE pc_solicita_remessa(pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data da solicitação
                               ,pr_idtpreme IN crapcrb.idtpreme%TYPE --> Tipo da remessa
                               ,pr_dscritic OUT VARCHAR2);

  -- Rotina para efetuar a busca do arquivos da remessa passada
  PROCEDURE pc_busca_arq_remessa(pr_idtpreme IN crapcrb.idtpreme%TYPE --> Tipo da Remessa
                                ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data da Remessa
                                ,pr_dscritic OUT VARCHAR2);          --> Retorno de crítica

  -- Rotina para preparar e direcionar o envio dos arquivos da remessa ao Bureaux
  PROCEDURE pc_envio_remessa(pr_idtpreme IN crapcrb.idtpreme%TYPE --> Tipo da Remessa
                            ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data da Remessa
                            ,pr_dscritic OUT VARCHAR2);           --> Retorno de crítica

  -- Rotina para preparar e direcionar o retorno dos arquivos da remessa
  PROCEDURE pc_retorno_remessa(pr_idtpreme IN crapcrb.idtpreme%TYPE --> Tipo da Remessa
                              ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data da Remessa
                              ,pr_dscritic OUT VARCHAR2            --> Retorno de crítica
                              ,pr_dstiplog OUT VARCHAR2            --> Tipo de Log
                              );

  -- Rotina para direcionar a devolução diária dos retornos
  PROCEDURE pc_devolu_diaria(pr_idtpreme IN crapcrb.idtpreme%TYPE --> Tipo da Remessa
                            ,pr_dscritic OUT VARCHAR2);           --> Retorno de crítica

  -- Rotina para controlar todo o processo de envio / retorno dos arquivos dos Bureaux
  PROCEDURE pc_controle_remessas(pr_dscritic OUT VARCHAR2);

  -- Geracao do arquivo da Reabilitação Forçada
  PROCEDURE pc_grava_arquivo_reafor(pr_cdcooper IN crapcop.cdcooper%TYPE);

  -- Controla log em banco de dados
  PROCEDURE pc_controla_log_batch(pr_dstiplog   IN VARCHAR2,              -- Tipo de Log
                                  pr_dscritic   IN VARCHAR2 DEFAULT NULL, -- Descrição do Log
                                  pr_cdprograma IN VARCHAR2               -- Código da rotina
                                  ); 
  --
END CYBE0002;
/
CREATE OR REPLACE PACKAGE BODY CECRED.CYBE0002 IS

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa: CYBE0002
  --  Autor   : Andre Santos - SUPERO
  --  Data    : Outubro/2013                     Ultima Atualizacao: 09/01/2018
  --
  --  Dados referentes ao programa:
  --
  --  Objetivo  : Package referente a regras de reabilitação forçada dos cooperados
  --
  --  Alteracoes: 12/06/2015 - Ajustando os tamanho dos campos de operador
  --                           (Andre Santos - SUPERO)
  --  
  --              13/11/2015 - Correcao na rotina pc_grava_arquivo_reafor, existia uma
  --                           chamada da rotina pc_incrementa_linha passando 8 como parametro
  --                           quando o correto seria passar 1. Chamado 347582 (Heitor - RKAM)
  --
  --              20/09/2016 - #523936 Criação de log de controle de início, erros e fim de execução
  --                           do job pc_controle_remessas (Carlos)
  --
  --              31/10/2016 - #550394 Tratadas as mensagens de críticas de busca de arquivos do ftp 
  --                           da rotina pc_controle_remessas para não enviar mais email, apenas 
  --                           logar no proc_message (Carlos)
  --
  --              17/02/2017 - #551213 Log de início, erros e fim de execução do procedimento
  --                           pc_gra_arquivo_reafor (jbcybe_arquivo_reafor) (Carlos)
  --  
  --              27/04/2017 - #654523 Retirada do vr_cdprogra pois o procedimento do job não é 
  --                           um programa da crapprg, utilizada para crps (Carlos)
  --
  --              23/06/2017 - #674963 Retirado o log do proc_message e inserido apenas na tabela 
  --                           tbgen_prglog_ocorrencia concatenando os parâmetros idtpreme, dtmvtolt
  --                           e nrseqarq (Carlos)
  --
  --              21/07/2017 - Inclusão do módulo e ação logado no oracle
  --                         - Inclusão da  chamada de procedure em exception others
  --                         - Colocado logs no padrão
  --                         - Tratamento tipo do log da critica de retorno de remessa
  --                           ( Belli - Envolti - Chamado 669487/719114 )
  --
  --              10/10/2017 - M434 - Adicionar dois novos parâmetros para atender o SPC/Brasil que usa chave 
  --                          de criptografia para o acesso ao SFTP. (Oscar)
  -- 
  -- 23/11/2017 - #799360 Rotina pc_controle_remessas - Inclusão de limite de dias na busca dos 
  --              retornos das remessas enviadas, dos tipos COBEMP e SMS; inclusão de retorno de 
  --              crítica para o job; definição de horários de execução: entre 8h e 22h (Carlos)
  --              09/01/2018 - #826598 Tratamento na rotina pc_controle_remessas para enviar e-mail e abrir
  --                           chamado quando ocorrer erro (Carlos)
  --              
  --              03/08/2018 - Ajustes e comentários para definir onde estiver COBEMP para funcionar para COBTIT também - Luis Fernando (GFT)
  --              25/09/2018 - Ajuste para organizar os arquivos antes de começar o envio para o Bureaux. (Saquetta)
  ---------------------------------------------------------------------------------------------------------------

  -- Tratamento de erros
  vr_nrseqare craparb.nrseqarq%TYPE;
  vr_dscritic VARCHAR2(4000);
  vr_excerror EXCEPTION;

  -- Busca cabeçalho da remessa quando passado Rowid
  CURSOR cr_crapcrb(pr_rowid IN ROWID) IS
    SELECT idtpreme
          ,dtmvtolt
      FROM crapcrb
     WHERE ROWID = pr_rowid;
  rw_crapcrb cr_crapcrb%ROWTYPE;

  -- Busca do nome do arquivo enviado no rowid
  CURSOR cr_nmarquiv_r(pr_rowid IN ROWID) IS
    SELECT nmarquiv
      FROM craparb
     WHERE ROWID = pr_rowid;
  vr_nmarquiv craparb.nmarquiv%TYPE;

  -- Busca do rowid do arquivo cfme chave
  CURSOR cr_rowid_arq(pr_idtpreme IN craparb.idtpreme%TYPE
                     ,pr_dtmvtolt IN craparb.dtmvtolt%TYPE
                     ,pr_nrseqarq IN craparb.nrseqarq%TYPE) IS
    SELECT ROWID
      FROM craparb
     WHERE idtpreme = pr_idtpreme
       AND dtmvtolt = pr_dtmvtolt
       AND nrseqarq = pr_nrseqarq;
  vr_rowid_arq ROWID;

  -- Busca cabeçalho do arquivo quando passado Rowid
  CURSOR cr_craparb_r(pr_rowid IN ROWID) IS
    SELECT idtpreme
          ,dtmvtolt
          ,nrseqarq
          ,nmarquiv
          ,blarquiv
      FROM craparb
     WHERE ROWID = pr_rowid;
  rw_craparb_r cr_craparb_r%ROWTYPE;

  -- Bureaux sem remessas agendadas no dia
  CURSOR cr_agen_penden(pr_dtmvtolt IN crapcrb.dtmvtolt%TYPE DEFAULT NULL) IS
    SELECT pbc.idtpreme
      FROM crappbc pbc
     WHERE pbc.flgativo = 1   --> Somente Bureauxs Ativos
       AND pbc.idtpsoli = 'A' --> Somente Bureauxs Automáticos
       -- Sem o remessa de agendamento para o dia
       AND NOT EXISTS(SELECT 1
                        FROM crapcrb crb
                       WHERE crb.idtpreme = pbc.idtpreme
                         AND crb.dtmvtolt = trunc(pr_dtmvtolt)) --> Preparação
     ORDER BY pbc.idtpreme;

  -- Bureaux com remessas agendadas
  CURSOR cr_prep_penden(pr_idtpreme IN crapcrb.idtpreme%TYPE DEFAULT NULL
                       ,pr_dtmvtolt IN crapcrb.dtmvtolt%TYPE DEFAULT NULL) IS
    SELECT crb.idtpreme
          ,crb.dtmvtolt
          ,pbc.idtpsoli
      FROM crapcrb crb
          ,crappbc pbc
     WHERE crb.idtpreme = nvl(pr_idtpreme,crb.idtpreme)
       AND crb.dtmvtolt = nvl(pr_dtmvtolt,crb.dtmvtolt)
       AND crb.idtpreme = pbc.idtpreme
       AND pbc.idtpreme <> 'SMSDEBAUT'  -- Darosci - 26/10/2016
       AND pbc.flgativo = 1   --> Somente Bureauxs Ativos
       AND crb.dtcancel IS NULL --> Desconsiderar as canceladas
       -- Sem o arquivo da preparação ou Envio
       AND NOT EXISTS(SELECT 1
                        FROM craparb arb
                       WHERE crb.idtpreme = arb.idtpreme
                         AND crb.dtmvtolt = arb.dtmvtolt
                         AND arb.cdestarq IN(2,3)) --> Preparação ou Envio
     GROUP BY crb.dtmvtolt
             ,crb.idtpreme
             ,pbc.idtpsoli;

  -- Remessas pendentes de envio
  CURSOR cr_env_penden(pr_idtpreme IN crapcrb.idtpreme%TYPE DEFAULT NULL
                      ,pr_dtmvtolt IN crapcrb.dtmvtolt%TYPE DEFAULT NULL
                      ,pr_flcsdcnl IN VARCHAR2 DEFAULT 'S') IS --> Validar o cancelamento do Bureaux
    SELECT crb.idtpreme
          ,crb.dtmvtolt
          ,pbc.idtpsoli
      FROM crapcrb crb
          ,crappbc pbc
     WHERE crb.idtpreme = nvl(pr_idtpreme,crb.idtpreme)
       AND crb.dtmvtolt = nvl(pr_dtmvtolt,crb.dtmvtolt)
       AND crb.idtpreme = pbc.idtpreme
       AND pbc.idtpreme <> 'SMSDEBAUT'  -- Darosci - 26/10/2016
       AND pbc.flgativo = 1   --> Somente ativos
       AND ((pr_flcsdcnl = 'S' AND crb.dtcancel IS NULL) OR pr_flcsdcnl = 'N') --> Desconsiderar as canceladas quando solicitado
       -- Existe envio pendentes
       AND EXISTS(SELECT 1
                    FROM craparb arb
                   WHERE crb.idtpreme = arb.idtpreme
                     AND crb.dtmvtolt = arb.dtmvtolt
                     AND arb.cdestarq = 3     --> Envio
                     AND arb.dtcancel IS NULL --> Não cancelado
                     AND arb.flproces = 0)    --> Não enviado
     ORDER BY crb.dtmvtolt;
  rw_env cr_env_penden%ROWTYPE;

  -- Remessas pendentes de retorno
  CURSOR cr_ret_penden(pr_idtpreme IN crapcrb.idtpreme%TYPE DEFAULT NULL
                      ,pr_dtmvtolt IN crapcrb.dtmvtolt%TYPE DEFAULT NULL
                      ,pr_flcsdcnl IN VARCHAR2 DEFAULT 'S') IS
    SELECT crb.idtpreme
          ,crb.dtmvtolt
      FROM crapcrb crb
          ,crappbc pbc
     WHERE crb.idtpreme = nvl(pr_idtpreme,crb.idtpreme)
       AND crb.dtmvtolt = nvl(pr_dtmvtolt,crb.dtmvtolt)
       AND crb.idtpreme = pbc.idtpreme
       AND pbc.flgativo = 1           --> Ativos
       AND nvl(pbc.idopreto,'S') <> 'S'        --> Somente aqueles com retorno
       AND ((pr_flcsdcnl = 'S' AND crb.dtcancel IS NULL) OR pr_flcsdcnl = 'N') --> Desconsiderar as canceladas quando solicitado
       -- Tenha havido algum envio
       AND EXISTS(SELECT 1
                    FROM craparb arb
                   WHERE crb.idtpreme = arb.idtpreme
                     AND crb.dtmvtolt = arb.dtmvtolt
                     AND arb.cdestarq = 3     --> Envio
                     AND arb.dtcancel IS NULL --> Não cancelado
                     AND arb.flproces = 1)    --> enviado
       -- Existem retornos pendentes
       AND (  -- Remessas com retorno único
              (nvl(pbc.idopreto,'U') = 'U'   --> Retorno único
              -- Não pode ter havido nenhum retorno
              AND NOT EXISTS(SELECT 1
                               FROM craparb arb
                              WHERE crb.idtpreme = arb.idtpreme
                                AND crb.dtmvtolt = arb.dtmvtolt
                                AND arb.cdestarq = 4)     --> Retorno
              )
            OR
              -- Remessas com retorno para cada envio
              (pbc.idopreto = 'M'   --> Retorno Multiplo
              -- Deve haver um retorno para cada envio não cancelado
              AND EXISTS(SELECT 1
                           FROM craparb arb
                          WHERE crb.idtpreme = arb.idtpreme
                            AND crb.dtmvtolt = arb.dtmvtolt
                            AND arb.cdestarq = 3     --> Envio
                            AND arb.dtcancel IS NULL --> Não cancelado
                            AND arb.flproces = 1     --> Processado
                            -- Sem o devido retorno
                            AND NOT EXISTS(SELECT 1
                                             FROM craparb arbR
                                            WHERE arb.idtpreme = arbR.idtpreme
                                              AND arb.dtmvtolt = arbR.dtmvtolt
                                              AND arb.nrseqarq = arbR.Nrseqant
                                              AND arbR.cdestarq = 4)     --> Retorno
                        )
              )
           )
     ORDER BY crb.dtmvtolt;
  rw_ret cr_ret_penden%ROWTYPE;

  -- Remessas com algum retorno não processado (Agrupadas por Bureaux)
  CURSOR cr_dev_penden(pr_idtpreme IN crapcrb.idtpreme%TYPE DEFAULT NULL
                      ,pr_dtmvtolt IN crapcrb.dtmvtolt%TYPE DEFAULT NULL
                      ,pr_idtpsoli IN crappbc.idtpsoli%TYPE DEFAULT NULL
                      ,pr_flcsdcnl IN VARCHAR2 DEFAULT 'S') IS
    SELECT crb.idtpreme
      FROM crappbc pbc
          ,crapcrb crb
     WHERE crb.idtpreme = nvl(pr_idtpreme,crb.idtpreme)
       AND crb.dtmvtolt = nvl(pr_dtmvtolt,crb.dtmvtolt)
       AND pbc.idtpsoli = nvl(pr_idtpsoli,pbc.idtpsoli)
       AND pbc.idtpreme = crb.idtpreme
       AND pbc.flgativo = 1   --> Somente ativos
       AND ((pr_flcsdcnl = 'S' AND crb.dtcancel IS NULL) OR pr_flcsdcnl = 'N') --> Desconsiderar as canceladas quando solicitado
       -- Com algum arquivo de retorno não processado
       AND EXISTS(SELECT 1
                    FROM craparb arb
                   WHERE crb.idtpreme = arb.idtpreme
                     AND crb.dtmvtolt = arb.dtmvtolt
                     AND arb.cdestarq = 4 --> Retorno
                     AND arb.flproces = 0 --> Ainda não processado
                     AND arb.dtcancel IS NULL) --> Não cancelado
     GROUP BY crb.idtpreme;
  rw_dev cr_dev_penden%ROWTYPE;

  -- Testar estágio específico
  CURSOR cr_exis_estagio(pr_idtpreme IN crapcrb.idtpreme%TYPE
                        ,pr_dtmvtolt IN crapcrb.dtmvtolt%TYPE
                        ,pr_nrseqarq IN craparb.nrseqarq%TYPE DEFAULT NULL
                        ,pr_cdesteve IN craperb.cdesteve%TYPE) IS
    SELECT 'S'
      FROM craperb erb
     WHERE erb.idtpreme = pr_idtpreme
       AND erb.dtmvtolt = pr_dtmvtolt
       AND erb.cdesteve = pr_cdesteve
       AND erb.flerreve = 0 --> Sem erro
       AND (pr_nrseqarq IS NULL OR erb.nrseqarq = pr_nrseqarq)
       -- E não exista outro evento evento de erro após
       AND NOT EXISTS(SELECT 1
                        FROM craperb erbErr
                       WHERE erbErr.idtpreme        = erb.idtpreme
                         AND erbErr.dtmvtolt        = erb.dtmvtolt
                         AND erbErr.cdesteve        = erb.cdesteve
                         AND nvl(erbErr.nrseqarq,0) = nvl(erb.nrseqarq,0)
                         AND erbErr.nrseqeve        > erb.nrseqeve
                         AND erbErr.flerreve        = 1); --> com erro
  vr_dsexiste VARCHAR2(1);

  -- Função para invocação dinamica de outra função
  FUNCTION fn_dinamic_function(pr_nmfuncao IN VARCHAR2
                              ,pr_rowid    IN ROWID) RETURN VARCHAR2 IS
  BEGIN
    /* .............................................................................
    Programa: fn_dinamic_function
    Autor   : Marcos Martini - SUPERO.
    Data    : 30/12/2014                     Ultima atualizacao:

    Dados referentes ao programa:

    Objetivo  : Funcao generica invocação dinamica de outra função repassada
                nos parâmetros enviados

    Alteracoes :

    /* ...........................................................................*/
    DECLARE
      vr_dscomd VARCHAR2(4000);
      vr_retval varchar2(4000);
    BEGIN
	    -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
	    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.fn_dinamic_function');
      -- Montagem do comando
      vr_dscomd := 'begin :result := ' || pr_nmfuncao || '('''||pr_rowid||'''); end;';
      -- Executar dinamicamente
      execute immediate vr_dscomd using out vr_retval;
      -- Retornar o resultado
      return vr_retval;
    END;
  END fn_dinamic_function;

  -- Função para invocação dinamica de outra função com o rowid e uma parâmetro descrição auxiliar
  FUNCTION fn_dinamic_function(pr_nmfuncao IN VARCHAR2
                              ,pr_rowid    IN ROWID
                              ,pr_dsaux    IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /* .............................................................................
    Programa: fn_dinamic_function
    Autor   : Marcos Martini - SUPERO.
    Data    : 06/04/2015                     Ultima atualizacao:

    Dados referentes ao programa:

    Objetivo  : Funcao generica invocação dinamica de outra função repassada
                nos parâmetros enviados

    Alteracoes :

    /* ...........................................................................*/
    DECLARE
      vr_dscomd VARCHAR2(4000);
      vr_retval varchar2(4000);
    BEGIN
	    -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
	    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.fn_dinamic_function 2');
      -- Montagem do comando
      vr_dscomd := 'begin :result := ' || pr_nmfuncao || '('''||pr_rowid||''','''||pr_dsaux||'''); end;';
      -- Executar dinamicamente
      execute immediate vr_dscomd using out vr_retval;
      -- Retornar o resultado
      return vr_retval;
    END;
  END fn_dinamic_function;

  /* Quebra string com base no delimitador e retorna array de resultados */
  FUNCTION fn_quebra_string(pr_string   IN VARCHAR2
                           ,pr_delimit  IN CHAR DEFAULT ',') RETURN gene0002.typ_split IS

    -- ..........................................................................
    --
    --  Programa : fn_quebra_string
    --  Autor    : Marcos Martini - Supero
    --  Data     : Janeiro/2015.                   Ultima atualizacao: --/--/----
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: Sempre que for chamado
    --   Objetivo  : Retornar array com os campos referentes a quebra da string
    --               com base no delimitador informado.
    --   Observações: Esta é uma variante da gene0002.fn_quebra_string, porém esta
    --                não faz trim nas separações.
    --   Alteracoes: 99/99/9999 - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    -- ............................................................................

    vr_vlret    gene0002.typ_split := gene0002.typ_split();
    vr_quebra   LONG DEFAULT pr_string || pr_delimit;
    vr_idx      NUMBER;

  BEGIN
	  -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
	  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.fn_quebra_string');
    
    --Se a string estiver nula retorna count = 0 no vetor
    IF nvl(pr_string,'#') = '#' THEN
      RETURN vr_vlret;
    END IF;

    LOOP
      -- Identifica ponto de quebra inicial
      vr_idx := instr(vr_quebra, pr_delimit);
      -- Clausula de saída para o loop
      exit WHEN nvl(vr_idx, 0) = 0;
      -- Acrescenta elemento para a coleção
      vr_vlret.EXTEND;
      -- Acresce mais um registro gravado no array com o bloco de quebra
      vr_vlret(vr_vlret.count) := substr(vr_quebra, 1, vr_idx - 1);
      -- Atualiza a variável com a string integral eliminando o bloco quebrado
      vr_quebra := substr(vr_quebra, vr_idx + LENGTH(pr_delimit));
    END LOOP;
    -- Retorno do array com as substrings separadas em cada registro
    RETURN vr_vlret;
  END fn_quebra_string;

  -- Funcao generica para buscar o nome resumido da cooperativa --
  FUNCTION fn_nom_cooperativa(pr_cdcooper IN crapcop.cdcooper%TYPE) RETURN VARCHAR2 IS
  /* .............................................................................
  Programa: fn_nom_cooperativa
  Autor   : Andre Santos - SUPERO.
  Data    : 25/11/2014                     Ultima atualizacao:

  Dados referentes ao programa:

  Objetivo  : Funcao generica para buscar o nome resumido da
              cooperativa informada por parametro, caso contrario
              retornar branco.

  Paramentros: pr_cdcooper -- Codigo da Cooperativa

  Alteracoes :

  /* ...........................................................................*/

  -- CURSOR
  -- Busca o nome resumido da cooperativa
  CURSOR cr_nmrescop IS
     SELECT cop.nmrescop
       FROM crapcop cop
      WHERE cop.cdcooper = pr_cdcooper;
  vr_nmrescop crapcop.nmrescop%TYPE := ' ';

  BEGIN
	  -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
	  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.fn_nom_cooperativa');
    
    -- Coop 16 - Viacredi AV - Retornamos Altovale
    IF pr_cdcooper = 16 THEN
      RETURN 'ALTOVALE';
    ELSE
      -- Buscamos cfme o cadastro
      OPEN cr_nmrescop;
      FETCH cr_nmrescop INTO vr_nmrescop;
      CLOSE cr_nmrescop;
      RETURN vr_nmrescop;
    END IF;
  END fn_nom_cooperativa;


  FUNCTION fn_remessa_encerrada(pr_idtpreme IN crapcrb.idtpreme%TYPE
                               ,pr_dtmvtolt IN crapcrb.dtmvtolt%TYPE) RETURN VARCHAR2 IS
  BEGIN
    /* .............................................................................
    Programa: fn_remessa_encerrada
    Autor   : Andre Santos - SUPERO.
    Data    : 25/11/2014                     Ultima atualizacao: 15/10/2015

    Dados referentes ao programa:

    Objetivo  : Funcao generica que centraliza as regras que definem se uma remessa
                esta encerrada ou nao. Isso se deve pois por exemplo existem remessa
                que nao tem retorno, entao nao podemos considera-la como em aberto
                apos o envio, mas como concluida.

    Paramentros: pr_idtpreme -- Identificado de Tipo de Remessa
                 pr_dtmvtolt -- Data da remessa

    Alteracoes :

     06/04/2015 - Ajuste para verificar se as remessas já foram preparadas antes
                  de fazer os testes padrão, remessas não preparadas já devem
                  ser retornadas como pendentes, senão o sistema entende que elas já
                  foram encerradas pois não há retorno nem envio pendente (Marcos-Supero)

     15/10/20158 - Ajuste para quando as remessas foram preparadas mas não enviadas,
                   já que o sistema considerava que a preparação já era o envio, e então
                   checava direto retornos pendentes (Marcos-Supero)

    /* ...........................................................................*/
    DECLARE
      -- Busca do tipo do retorno do Bureaux
      CURSOR cr_crappbc IS
        SELECT nvl(idopreto,'S') idopreto
              ,flgativo
          FROM crappbc
         WHERE idtpreme = pr_idtpreme;
      vr_idopreto crappbc.idopreto%TYPE;
      vr_flgativo crappbc.flgativo%TYPE;
      rw_prep     cr_prep_penden%ROWTYPE;
    BEGIN
	    -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
  	  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.fn_remessa_encerrada');
      
      -- Buscar o tipo de retorno do Bureaux
      OPEN cr_crappbc;
      FETCH cr_crappbc
       INTO vr_idopreto,vr_flgativo;
      CLOSE cr_crappbc;
      -- Bureaux desativado não pode ser cancelado
      IF vr_flgativo = 0 THEN
        RETURN 'S';
      END IF;
      -- Se a remessa ainda nem foi preparada
      OPEN cr_prep_penden(pr_idtpreme,pr_dtmvtolt);
      FETCH cr_prep_penden
       INTO rw_prep;
      -- Se encontrou
      IF cr_prep_penden%FOUND THEN
        CLOSE cr_prep_penden;
        -- Remessa ainda nem foi preparada, então retornamos false
        RETURN 'N';
      ELSE
        CLOSE cr_prep_penden;
      END IF;
      -- Testar se há envio pendente
      OPEN cr_env_penden(pr_idtpreme,pr_dtmvtolt);
      FETCH cr_env_penden
       INTO rw_env;
      -- Se encontrou
      IF cr_env_penden%FOUND THEN
        -- Retornamos false pois ainda temos de enviar
        CLOSE cr_env_penden;
        RETURN 'N';
      ELSE
        CLOSE cr_env_penden;
      END IF;
      --> Remessas Sem retorno
      IF vr_idopreto = 'S' THEN
        --> Podemos encerrar pois o envio já foi efetuado e não há retorno
        RETURN 'S';
      ELSE --> Remessas Com retorno
        -- Se não há mais nenhum retorno pendente
        OPEN cr_ret_penden(pr_idtpreme,pr_dtmvtolt);
        FETCH cr_ret_penden
         INTO rw_ret;
        -- Se encontrou
        IF cr_ret_penden%FOUND THEN
          -- Retornamos false pois ainda temos algum retorno pendente
          CLOSE cr_ret_penden;
          RETURN 'N';
        ELSE
          -- Retornamos true pois não há mais nada a retorno
          CLOSE cr_ret_penden;
          RETURN 'S';
        END IF;
      END IF;
    END;
  END fn_remessa_encerrada;


  -- Funcao para retornar o código do cliente conforme a cooperativa (SERASA) --
  FUNCTION fn_cdclient_serasa(pr_cdcooper IN crapcop.cdcooper%TYPE) RETURN VARCHAR2 IS
  /* .............................................................................
  Programa: fn_cdclient_serasa
  Autor   : Marcos Martini - Supero
  Data    : 30/12/2014                     Ultima atualizacao:

  Dados referentes ao programa:

  Objetivo  : Função para retornar o código do cliente cfme cooperativa
              codigo este previamente cadastrado na CADCOP

  Alteracoes : 27/01/2015 - Buscar Codigo SERASA da CRAPCOP (Guilherme/SUPERO)

  /* ...........................................................................*/

  -- Buscar as informação SERASA da cooperativa
  CURSOR cr_crapcop(p_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT crapcop.cdcliser
      FROM crapcop
     WHERE crapcop.cdcooper = p_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  BEGIN
	  -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
  	GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.fn_cdclient_serasa');
      
     -- Buscar dados da cooperativa
     OPEN  cr_crapcop(pr_cdcooper);
     FETCH cr_crapcop INTO rw_crapcop;
        -- Se não encontrar dados
        IF cr_crapcop%NOTFOUND THEN
           -- Fecha cursor
           CLOSE cr_crapcop;
           RETURN '0';
        END IF;
     CLOSE cr_crapcop;

     RETURN rw_crapcop.cdcliser;

  END fn_cdclient_serasa;

  -- Função para montagem da string de busca da remessa de envio --
  FUNCTION fn_chbusca_ppware(pr_rowid ROWID) return VARCHAR2 IS
  BEGIN
    /* .............................................................................
    Programa: fn_chbusca_ppware
    Autor   : Marcos Martini - Supero
    Data    : 08/01/2015                     Ultima atualizacao:

    Dados referentes ao programa:

    Objetivo  : Funcao para montagem do nome do arquivo da remessa
    --          a buscar da PPWare. Lembrando que as remessas de envio e
    --          retorno são processas de 2ª a 6ª, e sempre enviado o arquivo
    --          recebido pela PPWare no dia atual, com exceção da 2ª que irá
    --          trabalhar com o arquivo de sábado, já que segunda não há
    --          processamento pelo PPware

    Alteracoes :

    /* ...........................................................................*/
    DECLARE
      vr_dtbasbus VARCHAR2(8);
    BEGIN
	    -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
  	  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.fn_chbusca_ppware');
      
      -- Busca cabeçalho da remessa
      OPEN cr_crapcrb(pr_rowid);
      FETCH cr_crapcrb
       INTO rw_crapcrb;
      CLOSE cr_crapcrb;
      -- Somente para segundas
      IF to_char(rw_crapcrb.dtmvtolt,'d') = 2 THEN
        -- Usaremos o sábado (2 dias antes)
        vr_dtbasbus := to_char(rw_crapcrb.dtmvtolt-2,'rrrrmmdd');
      ELSE
        -- Usaremos a data atual
        vr_dtbasbus := to_char(rw_crapcrb.dtmvtolt,'rrrrmmdd');
      END IF;
      -- Retornar o padrão
      RETURN vr_dtbasbus||'_%_'||rw_crapcrb.idtpreme||'.zip';
    END;
  END fn_chbusca_ppware;

  -- Função para montagem da string de busca da remessa de envio de arquivos COBEMP/COBTIT --
  FUNCTION fn_chbusca_cobemp(pr_rowid ROWID) return VARCHAR2 IS
  BEGIN
    /* .............................................................................
    Programa: fn_chbusca_cobemp
    Autor   : Marcos Martini - Supero
    Data    : 07/10/2015                     Ultima atualizacao:

    Dados referentes ao programa:

    Objetivo  : Funcao para montagem do nome do arquivo da remessa
    --          a buscar da COBEMP.

    Alteracoes :

    /* ...........................................................................*/
    BEGIN
	    -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
  	  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.fn_chbusca_cobemp');
      
      -- Busca cabeçalho da remessa
      OPEN cr_crapcrb(pr_rowid);
      FETCH cr_crapcrb
       INTO rw_crapcrb;
      CLOSE cr_crapcrb;
      -- Arquivo no formato AAAAMMDD_HHMISS_%_COBEMP.%
      RETURN to_char(rw_crapcrb.dtmvtolt,'RRRRMMDD_HH24MISS')||'_%_'||rw_crapcrb.idtpreme||'.%';
    END;
  END fn_chbusca_cobemp;


  -- Funcao para renomeação do arquivo antes do envio ao Serasa --
  FUNCTION fn_nmarquiv_env_serasa(pr_rowid IN ROWID) RETURN VARCHAR2 IS
  BEGIN
    /* .............................................................................
    Programa: fn_nmarquiv_env_serasa
    Autor   : Marcos Martini - Supero
    Data    : 30/12/2014                     Ultima atualizacao: 07/04/2015

    Dados referentes ao programa:

    Objetivo  : Funcao para renomeação do arquivo antes do envio ao Serasa

    Alteracoes : 07/04/2015 - Remoção de teste conforme database, pois o prefixo HOM
                              não é utilizado pelo Searasa como adiantado anteriormente
                              pelo Bruno do Serasa (Marcos-Supero)

    /* ...........................................................................*/
    DECLARE
      -- Código da cooperativa e do cliente
      vr_cdcooper NUMBER;
      vr_cdclient VARCHAR2(5);
    BEGIN
	    -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
  	  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.fn_nmarquiv_env_serasa');
      
      -- Busca do nome do arquivo a renomear
      OPEN cr_nmarquiv_r(pr_rowid);
      FETCH cr_nmarquiv_r
       INTO vr_nmarquiv;
      CLOSE cr_nmarquiv_r;
      -- Buscamos agora o código do cliente nas posições
      -- 7 e 8 do nome do arquivo original. EX: CY_EMP01_00000263_envserasa.txt
      vr_cdcooper := substr(vr_nmarquiv,7,2);
      -- Buscamos o código do cliente
      vr_cdclient := fn_cdclient_serasa(vr_cdcooper);
      -- Nome de Envio Pefin:
      --   NDM.NDXXXXX.PEFIN.Dddmmaa.Hhhmmss
      -- Onde XXXXX é o código do cliente
      RETURN 'NDM.ND' || vr_cdclient || '.PEFIN.D' || to_char(Sysdate,'ddmmyy') || '.H' || to_char(Sysdate,'hh24miss');
    END;
  END fn_nmarquiv_env_serasa;


  -- Funcao para montagem do nome do arquivo a retornar do Serasa --
  FUNCTION fn_nmarquiv_ret_serasa(pr_rowid IN ROWID) RETURN VARCHAR2 IS
  BEGIN
    /* .............................................................................
    Programa: fn_nmarquiv_ret_serasa
    Autor   : Marcos Martini - Supero
    Data    : 30/12/2014                     Ultima atualizacao: 07/04/2015

    Dados referentes ao programa:

    Objetivo  : Funcao para montagem do nome do arquivo a retornar do Serasa

    Alteracoes :  07/04/2015 - Correção na nomenclatura de retorno, conforme
                               regras enfim repassadas pelo Serasa (Marcos-Supero)

    /* ...........................................................................*/
    DECLARE
      -- Código da cooperativa e do cliente
      vr_cdcooper NUMBER;
      vr_cdclient VARCHAR2(5);
    BEGIN
	    -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
  	  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.fn_nmarquiv_ret_serasa');
      
      -- Busca do nome do arquivo enviado para montagem do retorno
      OPEN cr_nmarquiv_r(pr_rowid);
      FETCH cr_nmarquiv_r
       INTO vr_nmarquiv;
      CLOSE cr_nmarquiv_r;
      -- Buscamos agora o código do cliente nas posições
      -- 7 e 8 do nome do arquivo original. EX: CY_EMP01_00000263_envserasa.txt
      vr_cdcooper := substr(vr_nmarquiv,7,2);
      -- Buscamos o código do cliente
      vr_cdclient := fn_cdclient_serasa(vr_cdcooper);
      -- Nome de Retorno Pefin:
      --   NDM.NDXXXXX.PEFIN.RET.Dddmmaa.Hhhmmss
      -- Onde XXXXX é o código do cliente
      -- Obs: Usamos o caracter curinga % nos campos data e hora
      RETURN 'NDM.ND'||vr_cdclient||'.PEFIN.RET.D%.H%';
    END;
  END fn_nmarquiv_ret_serasa;

  -- Funcao para validar a ligação do arquivo enviado com o retornado em parâmetro
  FUNCTION fn_valida_retor_serasa(pr_rowid IN ROWID
                                 ,pr_dsret IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    /* .............................................................................
    Programa: fn_valida_retor_serasa
    Autor   : Marcos Martini - Supero
    Data    : 06/04/2015                     Ultima atualizacao:

    Dados referentes ao programa:

    Objetivo  : Funcao para checagem da ligação envolvendo o arquivo enviado X
                o arquivo retornado, pois se não forem da mesma remessa, não poderemos
                considerá-los como dependentes

    Observação: O número da remessa está na posição 123, com 3 caracteres

    Alteracoes :

    /* ...........................................................................*/
    DECLARE
      -- Auxiliares para leitura do clob e arquivo
      vr_qtdbytes PLS_INTEGER := 3;
      vr_idposlei PLS_INTEGER := 123;
      vr_utl_file utl_file.file_type;
      vr_nmdireto VARCHAR2(300);
      vr_nmarquiv VARCHAR2(300);
      vr_dscritic VARCHAR2(4000);
      vr_deslinha VARCHAR2(32767);
      -- Busca do CLOB do arquivo enviado
      CURSOR cr_arqenv IS
        SELECT blarquiv
          FROM craparb
         WHERE ROWID = pr_rowid;
      vr_blarquiv craparb.blarquiv%TYPE;
      -- Variaveis para o número da remessa
      vr_nrremenv VARCHAR2(3);
      vr_nrremret VARCHAR2(3);
    BEGIN
	    -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
  	  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.fn_valida_retor_serasa');
      
      -- Busca da remessa dentro do clob do arquivo enviado
      OPEN cr_arqenv;
      FETCH cr_arqenv
       INTO vr_blarquiv;
      CLOSE cr_arqenv;
      -- Ler a remessa no clob
      dbms_lob.read(vr_blarquiv, vr_qtdbytes, vr_idposlei, vr_deslinha);
      -- Convertemos de Raw para Varchar2, pois os Blobs estão em Raw
      vr_nrremenv := UTL_RAW.CAST_TO_VARCHAR2(vr_deslinha);
      -- Separamos o diretório e nome do arquivo de retorno recebido
      gene0001.pc_separa_arquivo_path(pr_caminho => pr_dsret
                                     ,pr_direto  => vr_nmdireto
                                     ,pr_arquivo => vr_nmarquiv);
      -- Abertura do arquivo retorno
      gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                              ,pr_nmarquiv => vr_nmarquiv
                              ,pr_tipabert => 'R'
                              ,pr_utlfileh => vr_utl_file
                              ,pr_des_erro => vr_dscritic);
      -- Se houve erro, não podemos validar
      IF vr_dscritic IS NOT NULL THEN
        RETURN 'N';
      END IF;
      -- lemos a primeira linha do arquivo
      gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_utl_file
                                  ,pr_des_text => vr_deslinha);
      -- fechamos o arquivo
      gene0001.pc_fecha_arquivo(pr_utlfileh => vr_utl_file);
      -- Subtrair da linha somente o número da remessa
      vr_nrremret := SUBSTR(vr_deslinha,vr_idposlei,vr_qtdbytes);
      -- Somente validar se os números de remessa batem
      IF vr_nrremenv = vr_nrremret THEN
        RETURN 'S';
      ELSE
        RETURN 'N';
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN 'N';
    END;
  END fn_valida_retor_serasa;

  -- Função para montagem da chave da remessa serasa
  FUNCTION fn_chvrem_serasa(pr_rowid ROWID) RETURN VARCHAR2 IS
  BEGIN
    /* .............................................................................
    Programa: fn_chvrem_serasa
    Autor   : Marcos Martini - Supero
    Data    : 08/01/2015                     Ultima atualizacao:

    Dados referentes ao programa:

    Objetivo  : Funcao para a partir do nome do arquivo da remessa
                passada, definir qual a chave do mesmo, ou seja, qual
                padrão repetirá em outras remessas da mesma coop

    Alteracoes :

    /* ...........................................................................*/
    BEGIN
	    -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
  	  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.fn_chvrem_serasa');
      
      -- Busca do nome do arquivo enviado para montagem do retorno
      OPEN cr_nmarquiv_r(pr_rowid);
      FETCH cr_nmarquiv_r
       INTO vr_nmarquiv;
      CLOSE cr_nmarquiv_r;
      -- Abaixo o exemplo de dois arquivos Serasa da mesma Coop mas
      -- de datas diferentes:
      -- Ex: CY_EMP01_00000228_envserasa.txt e CY_EMP01_00000227_envserasa.txt
      --     A função retornará CY_EMP01_%_envserasa.txt
      RETURN substr(vr_nmarquiv,1,9)||'%'||substr(vr_nmarquiv,18);
    END;
  END fn_chvrem_serasa;


  -- Funcao para renomeação do nome do arquivo a retornar do Serasa ao PPWare --
  FUNCTION fn_nmarquiv_dev_serasa(pr_rowid IN ROWID) RETURN VARCHAR2 IS
  BEGIN
    /* .............................................................................
    Programa: fn_nmarquiv_dev_serasa
    Autor   : Marcos Martini - Supero
    Data    : 30/12/2014                     Ultima atualizacao: 25/08/2016

    Dados referentes ao programa:

    Objetivo  : Funcao para renomeação do nome do arquivo a retornar do Serasa ao PPWare

    Alteracoes : 07/04/2015 - Ajuste para usar o dia do arquivo na lógica de criação do nome
                              e assim evitar sobreposição durante a geração do ZIP de devolução
                              a PPWare quando houver mais de uma remessa a devolver. (Marcos-Supero)

                 13/05/2015 - Ajuste para alterar o padrao do nome do arquivo, conforme
                              solicitado pela PeopleWare, alterando de "SER008" para "SER00008"
                              (Guilherme/SUPERO)

                 25/08/2016 - SD511112 - Ajuste para incluir o numero da remessa na extensao de 
				              retorno (Marcos-Supero)
    /* ...........................................................................*/
    DECLARE
      -- Cooperativa conforme codigo cliente serasa
      CURSOR cr_crapcop(pr_cdcliser crapcop.cdcliser%TYPE) IS
        SELECT crapcop.cdcooper
          FROM crapcop
         WHERE crapcop.cdcliser = pr_cdcliser;
      -- Código da cooperativa e do cliente
      vr_cdcooper NUMBER;
      vr_cdclient VARCHAR2(5);
      -- Nome da cooperativa
      vr_nmrescop crapcop.nmrescop%TYPE;
      -- Extensão aleatória
      vr_nmextale VARCHAR2(20);
      -- Auxiliares para leitura do clob e arquivo
      vr_qtdbytes PLS_INTEGER := 3;
      vr_idposlei PLS_INTEGER := 123;
      vr_deslinha VARCHAR2(32767);      
      vr_nrremret VARCHAR2(3);
    BEGIN
	    -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
  	  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.fn_nmarquiv_dev_serasa');
      
      -- Busca informações do arquivo retornado
      OPEN cr_craparb_r(pr_rowid);
      FETCH cr_craparb_r
       INTO rw_craparb_r;
      CLOSE cr_craparb_r;
      -- Buscamos agora o código do cliente nas posições
      -- 07 a 11 do nome do arquivo retornado.
      -- EX: NDM.NDXXXXX.PEFIN.RET.Dddmmaa.Hhhmmss
      vr_cdclient := substr(rw_craparb_r.nmarquiv,07,5);
      -- Buscamos o código da cooperativa cfme codigo do cliente
      OPEN  cr_crapcop(vr_cdclient);
      FETCH cr_crapcop
       INTO vr_cdcooper;
      CLOSE cr_crapcop;
      -- Buscamos o nome da Cooperativa conforme o código encontrado
      vr_nmrescop := fn_nom_cooperativa(vr_cdcooper);
      -- Ler a remessa no clob
      dbms_lob.read(rw_craparb_r.blarquiv, vr_qtdbytes, vr_idposlei, vr_deslinha);
      -- Convertemos de Raw para Varchar2, pois os Blobs estão em Raw
      vr_nrremret := UTL_RAW.CAST_TO_VARCHAR2(vr_deslinha);
      -- Montamos a extensão genérica conforme o dia + remessa
      vr_nmextale := 'D'||to_char(rw_craparb_r.dtmvtolt,'dd')||'_'||vr_nrremret;
      -- Nome de Retorno ao PPWare:
      -- XXXXXXXXXXXXXXXXXXXXXXSER00008.Ddd_RRR
      -- Onde:
      --      X é o nome da Cooperativa
      --      D é fixo o caracter 'D'
      --      d é o dia da remessa
      --      R é o numero da remessa
      RETURN vr_nmrescop||'SER00008.'||vr_nmextale;
    END;
  END fn_nmarquiv_dev_serasa;


  -- Funcao para montagem do nome do arquivo a retornar da HUMAN --
  FUNCTION fn_nmarquiv_ret_sms(pr_rowid IN ROWID) RETURN VARCHAR2 IS
  BEGIN
    /* .............................................................................
    Programa: fn_nmarquiv_ret_sms
    Autor   : Marcos Martini - Supero
    Data    : 30/12/2014                     Ultima atualizacao: 09/10/2015

    Dados referentes ao programa:

    Objetivo  : Funcao para montagem do nome do arquivo a retornar da HUMAN

    Alteracoes :
       09/10/2015 - PRJ210 - Adaptação para utilizar a mesma função as remessas
                    COBEMP - Marcos(Supero)


    /* ...........................................................................*/
    DECLARE
      -- Buscaremos o nome do arquivo enviado excluindo o CFG
      CURSOR cr_nmarquiv_c(pr_idtpreme craparb.idtpreme%TYPE
                          ,pr_dtmvtolt craparb.dtmvtolt%TYPE) IS
        SELECT arb.nmarquiv
          FROM craparb arb
         WHERE arb.idtpreme = pr_idtpreme
           AND arb.dtmvtolt = pr_dtmvtolt
           AND arb.cdestarq = 3 --> Envio
           AND upper(arb.nmarquiv) NOT LIKE '%.CFG';
      vr_nmarquiv craparb.nmarquiv%TYPE;
      vr_nmextarq VARCHAR2(100);
    BEGIN
	    -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
  	  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.fn_nmarquiv_ret_sms');
      
      -- Busca cabeçalho da remessa
      OPEN cr_crapcrb(pr_rowid);
      FETCH cr_crapcrb
       INTO rw_crapcrb;
      CLOSE cr_crapcrb;
      -- Busca o arquivo da remesssa
      OPEN cr_nmarquiv_c(rw_crapcrb.idtpreme,rw_crapcrb.dtmvtolt);
      FETCH cr_nmarquiv_c
       INTO vr_nmarquiv;
      CLOSE cr_nmarquiv_c;
      -- Guardamos a extensão
      vr_nmextarq := gene0001.fn_extensao_arquivo(vr_nmarquiv);
      -- Removemos a extensão do nome do arquivo
      vr_nmarquiv := rtrim(rtrim(vr_nmarquiv,vr_nmextarq),'.');
      -- Depois adicionamos o terminador no nome a buscar e a extensão enviada
      vr_nmarquiv := vr_nmarquiv || '*ret*.txt';
      --
      RETURN vr_nmarquiv;
    END;
  END fn_nmarquiv_ret_sms;


  -- Funcao para montagem do nome do arquivo a retornar do SPC --
  FUNCTION fn_nmarquiv_ret_spc(pr_rowid IN ROWID) RETURN VARCHAR2 IS
  BEGIN
    /* .............................................................................
    Programa: fn_nmarquiv_ret_spc
    Autor   : Marcos Martini - Supero
    Data    : 30/12/2014                     Ultima atualizacao:

    Dados referentes ao programa:

    Objetivo  : Funcao para montagem do nome do arquivo a retornar do SPC

    Alteracoes :

    /* ...........................................................................*/
    DECLARE
      -- Buscaremos o nome do arquivo enviado (Somente há um)
      CURSOR cr_nmarquiv_c(pr_idtpreme craparb.idtpreme%TYPE
                          ,pr_dtmvtolt craparb.dtmvtolt%TYPE) IS
        SELECT arb.nmarquiv
          FROM craparb arb
         WHERE arb.idtpreme = pr_idtpreme
           AND arb.dtmvtolt = pr_dtmvtolt
           AND arb.cdestarq = 3; --> Envio
      vr_nmarquiv craparb.nmarquiv%TYPE;
    BEGIN
	    -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
  	  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.fn_nmarquiv_ret_spc');
      
      -- Busca cabeçalho da remessa
      OPEN cr_crapcrb(pr_rowid);
      FETCH cr_crapcrb
       INTO rw_crapcrb;
      CLOSE cr_crapcrb;
      -- Busca do nome do arquivo enviado para montagem do retorno
      OPEN cr_nmarquiv_c(rw_crapcrb.idtpreme,rw_crapcrb.dtmvtolt);
      FETCH cr_nmarquiv_c
       INTO vr_nmarquiv;
      CLOSE cr_nmarquiv_c;
      -- Depois adicionamos o terminador no nome a buscar
      vr_nmarquiv := vr_nmarquiv || '.RET';
      RETURN vr_nmarquiv;
    END;
  END fn_nmarquiv_ret_spc;

  /* Procedimento para retornar a situação de cada evento do Bureaux */
  PROCEDURE pc_lst_estagio_bureaux(pr_idtpreme IN crapcrb.idtpreme%TYPE     --> Tipo do Bureaux
                                  ,pr_dtmvtolt IN crapcrb.dtmvtolt%TYPE     --> Data da Remessa
                                  ,pr_dssitpre OUT VARCHAR2                 --> Situação do recebimento da PPWare
                                  ,pr_dssitenv OUT VARCHAR2                 --> Situação do envio ao Bureaux
                                  ,pr_dssitret OUT VARCHAR2                 --> Situação do retorno do Bureaux
                                  ,pr_dssitdev OUT VARCHAR2                 --> Situação da devolução a PPWare
                                  ) IS
  /* .............................................................................
  Programa: pc_lst_estagio_bureaux
  Autor   : Marcos Martini - SUPERO.
  Data    : 09/01/2015                     Ultima atualizacao:

  Dados referentes ao programa:

  Objetivo  : Procedimento para retornar a situação de cada evento do Bureaux
              Eventos: Preparação
                       Envio
                       Retorno
                       Devolução
              Legenda de situação: PE - Pendente
                                   PC - Parcial
                                   OK - Concluído

  Alteracoes :

  /* ...........................................................................*/
  -- Busca o estagio da remessa e sua data de cancelamento
  BEGIN
    DECLARE
      -- Caracteristica do Bureaux e se há cancelamento
      CURSOR cr_crapcrb IS
        SELECT crb.dtcancel
              ,pbc.flgativo
              ,nvl(pbc.idopreto,'S') idopreto
          FROM crapcrb crb
              ,crappbc pbc
         WHERE crb.idtpreme = pbc.idtpreme
           AND crb.idtpreme = pr_idtpreme
           AND crb.dtmvtolt = pr_dtmvtolt;
      rw_crapcrb cr_crapcrb%ROWTYPE;

    BEGIN
	    -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
  	  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_lst_estagio_bureaux');

      -- Busca detalhes da remessa
      OPEN cr_crapcrb;
      FETCH cr_crapcrb INTO rw_crapcrb;
      CLOSE cr_crapcrb;

      -- Valores iniciais
      pr_dssitpre := 'PE';
      pr_dssitenv := 'PE';

      -- Remessas sem retorno
      IF rw_crapcrb.idopreto = 'S' THEN
        pr_dssitret := '  ';
        pr_dssitdev := '  ';
      ELSE
        -- Há retorno
        pr_dssitret := 'PE';
        pr_dssitdev := 'PE';
      END IF;

      -- Testar se já houve a preparação
      vr_dsexiste := 'N';
      OPEN cr_exis_estagio(pr_idtpreme => pr_idtpreme
                          ,pr_dtmvtolt => pr_dtmvtolt
                          ,pr_cdesteve => 2); -- Prep
      FETCH cr_exis_estagio
       INTO vr_dsexiste;
      CLOSE cr_exis_estagio;

      -- Se ainda não houve a preparação
      IF vr_dsexiste = 'N' THEN
        -- Retornamos pois todos os estágios continuam pendentes
        RETURN;
      END IF;

      -- Já preparou
      pr_dssitpre := 'OK';

      -- TEstar se já houve algum envio
      vr_dsexiste := 'N';
      OPEN cr_exis_estagio(pr_idtpreme => pr_idtpreme
                          ,pr_dtmvtolt => pr_dtmvtolt
                          ,pr_cdesteve => 3); -- Envio
      FETCH cr_exis_estagio
       INTO vr_dsexiste;
      CLOSE cr_exis_estagio;

      -- Se não houve nenhum envio
      IF vr_dsexiste = 'N' THEN
        -- Retornamos e fica pendente todos os eventos superiores
        RETURN;
      ELSE
        -- Já envio pelo menos um arquivo
        pr_dssitenv := 'PA';
        -- Testar se ainda há envio pendente (desconsiderar cancelamento do Bureaux)
        OPEN cr_env_penden(pr_idtpreme,pr_dtmvtolt,'N');
        FETCH cr_env_penden
         INTO rw_env;
        -- Se não encontrou
        IF cr_env_penden%NOTFOUND THEN
          -- Remessa totalmente enviada
          CLOSE cr_env_penden;
          pr_dssitenv := 'OK';
        ELSE
          CLOSE cr_env_penden;
        END IF;
      END IF;

      -- Remessas sem retorno podemos sair
      IF rw_crapcrb.idopreto = 'S' THEN
        RETURN;
      END IF;

      -- Testar se já houve retorno
      vr_dsexiste := 'N';
      OPEN cr_exis_estagio(pr_idtpreme => pr_idtpreme
                          ,pr_dtmvtolt => pr_dtmvtolt
                          ,pr_cdesteve => 4); -- Retorno
      FETCH cr_exis_estagio
       INTO vr_dsexiste;
      CLOSE cr_exis_estagio;

      -- Se não houve nenhum retorno
      IF vr_dsexiste = 'N' THEN
        -- Retornamos e fica pendente todos os eventos superiores
        RETURN;
      ELSE
        -- Já retornou pelo menos um arquivo
        pr_dssitret := 'PA';
        -- Testar se ainda há retorno pendente (Não considerar o cancelamento do Bureax)
        OPEN cr_ret_penden(pr_idtpreme,pr_dtmvtolt,'N');
        FETCH cr_ret_penden
         INTO rw_ret;
        -- Se não encontrou e o Envio também já está concluído
        IF cr_ret_penden%NOTFOUND AND pr_dssitenv = 'OK' THEN
          -- Remessa já retornou todos os arquivos
          CLOSE cr_ret_penden;
          pr_dssitret := 'OK';
        ELSE
          CLOSE cr_ret_penden;
        END IF;
      END IF;

      -- Testar se já houve devolução
      vr_dsexiste := 'N';
      OPEN cr_exis_estagio(pr_idtpreme => pr_idtpreme
                          ,pr_dtmvtolt => pr_dtmvtolt
                          ,pr_cdesteve => 5); -- Devolução
      FETCH cr_exis_estagio
       INTO vr_dsexiste;
      CLOSE cr_exis_estagio;

      -- Se não houve devolução
      IF vr_dsexiste = 'N' THEN
        -- Retornamos e fica pendente só a mesma
        RETURN;
      ELSE
        -- Já devolveu pelo menos um arquivo
        pr_dssitdev := 'PA';
        -- Testar se ainda há retornos pendentes de devolução (Não considerar o cancelamento do Bureax)
        OPEN cr_dev_penden(pr_idtpreme,pr_dtmvtolt,NULL,'N');
        FETCH cr_dev_penden
         INTO rw_dev;
        -- Se não encontrou e não há nem retorno nem envio pendentes
        IF cr_dev_penden%NOTFOUND AND pr_dssitenv = 'OK' AND pr_dssitret = 'OK' THEN
          -- Remessa concluída
          CLOSE cr_dev_penden;
          pr_dssitdev := 'OK';
        ELSE
          CLOSE cr_dev_penden;
        END IF;
      END IF;
    END;
  END pc_lst_estagio_bureaux;


  /* Procedimento para retornar a situação de cada evento da Remessa do Bureaux */
  PROCEDURE pc_lst_estagio_remessa(pr_idtpreme IN crapcrb.idtpreme%TYPE     --> Tipo do Bureaux
                                  ,pr_dtmvtolt IN crapcrb.dtmvtolt%TYPE     --> Data da Remessa
                                  ,pr_nrseqarq IN craparb.nrseqarq%TYPE     --> Sequencia da remessa
                                  ,pr_dssitenv OUT VARCHAR2                 --> Situação do envio ao Bureaux
                                  ,pr_dssitret OUT VARCHAR2                 --> Situação do retorno do Bureaux
                                  ,pr_dssitdev OUT VARCHAR2                 --> Situação da devolução a PPWare
                                  ) IS
  /* .............................................................................
  Programa: pc_lst_estagio_remessa
  Autor   : Marcos Martini - SUPERO.
  Data    : 09/01/2015                     Ultima atualizacao:

  Dados referentes ao programa:

  Objetivo  : Procedimento para retornar a situação de cada evento da Remessa
              Eventos: Envio
                       Retorno
                       Devolução
              Legenda de situação: PE - Pendente
                                   OK - Concluído

  Alteracoes :

  /* ...........................................................................*/
  -- Busca o estagio da remessa e sua data de cancelamento
  BEGIN
    DECLARE
      -- Busca do nrseqarq do arquivo de retorno
      CURSOR cr_nrseqret IS
        SELECT nrseqarq
          FROM craparb
         WHERE idtpreme = pr_idtpreme
           AND dtmvtolt = pr_dtmvtolt
           AND nrseqant = pr_nrseqarq --> Chave da remessa é anterior ao de retorno
           AND cdestarq = 4;          --> Retorno
      vr_nrseqret craparb.nrseqarq%TYPE;
    BEGIN
	    -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
  	  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_lst_estagio_remessa');

      -- Valores iniciais
      pr_dssitenv := 'PE';
      pr_dssitret := 'PE';
      pr_dssitdev := 'PE';

      -- TEstar se já houve envio
      vr_dsexiste := 'N';
      OPEN cr_exis_estagio(pr_idtpreme => pr_idtpreme
                          ,pr_dtmvtolt => pr_dtmvtolt
                          ,pr_nrseqarq => pr_nrseqarq
                          ,pr_cdesteve => 3); -- Envio
      FETCH cr_exis_estagio
       INTO vr_dsexiste;
      CLOSE cr_exis_estagio;

      -- Se não houve nenhum envio
      IF vr_dsexiste = 'N' THEN
        -- Retornamos e ficam pendente todos os eventos superiores
        RETURN;
      ELSE
        -- Já enviou pelo menos um arquivo
        pr_dssitenv := 'OK';
      END IF;

      -- Busca do nrseqarq do arquivo de retorno
      OPEN cr_nrseqret;
      FETCH cr_nrseqret
       INTO vr_nrseqret;
      CLOSE cr_nrseqret;

      -- Se não achou o arquivo de retorno
      IF vr_nrseqret IS NULL THEN
        -- Retornamos
        RETURN;
      ELSE
        -- Já retornou arquivo
        pr_dssitret := 'OK';
      END IF;

      -- Testar se já houve devolução do arquivo de retorno
      vr_dsexiste := 'N';
      OPEN cr_exis_estagio(pr_idtpreme => pr_idtpreme
                          ,pr_dtmvtolt => pr_dtmvtolt
                          ,pr_nrseqarq => vr_nrseqret --> Achado acima
                          ,pr_cdesteve => 5); -- Devolução
      FETCH cr_exis_estagio
       INTO vr_dsexiste;
      CLOSE cr_exis_estagio;

      -- Se não houve devolução
      IF vr_dsexiste = 'N' THEN
        -- Retornamos e fica pendente só a mesma
        RETURN;
      ELSE
        -- Já devolveu o mesmo a PPWare
        pr_dssitdev := 'OK';
      END IF;
    END;
  END pc_lst_estagio_remessa;


  FUNCTION fn_des_evento_remessa(pr_cdesteve IN craperb.cdesteve%TYPE) RETURN VARCHAR2 IS
  /* .............................................................................
  Programa: fn_des_evento_remessa
  Autor   : Andre Santos - SUPERO.
  Data    : 25/11/2014                     Ultima atualizacao:

  Dados referentes ao programa:

  Objetivo  : Funcao generica que centraliza as regras de traducao do estagio
              do evento remessa para texto.

  Paramentros: pr_cdesteve -- Codigo de Estagio da Remessa

  Consideracao: Retornar os valores em maiusculo para o caso
                de ser utilizado em alguma comparacao. Se for
                necessario usar como um texto, deve ser utilizado
                a INITCAP no retorno funcao.

  Alteracoes :

  /* ...........................................................................*/
  BEGIN
	    -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
  	  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.fn_des_evento_remessa');
      
     -- Verifica a Situacao do Estagio
     IF pr_cdesteve = 1 THEN    -- Agendada
        RETURN 'AGENDAMENTO';
     ELSIF pr_cdesteve = 2 THEN -- Preparada
        RETURN 'PREPARACAO';
     ELSIF pr_cdesteve = 3 THEN -- Enviada
        RETURN 'ENVIO';
     ELSIF pr_cdesteve = 4 THEN -- Retornada
        RETURN 'RETORNO';
     ELSIF pr_cdesteve = 5 THEN -- Encerrada
        RETURN 'DEVOLUCAO';
     ELSIF pr_cdesteve = 9 THEN -- Encerrada
        RETURN 'CANCELAMENTO';
     ELSE
        RETURN ' '; -- Retornar em Branco
     END IF;
  END fn_des_evento_remessa;


  /* Centralização da gravação dos Eventos da Remessa */
  PROCEDURE pc_insere_evento_remessa(pr_idtpreme IN VARCHAR2            --> Tipo da remessa
                                    ,pr_dtmvtolt IN DATE                --> Data da remessa
                                    ,pr_nrseqarq IN NUMBER DEFAULT NULL --> Sequencial do arquivo (Opcional)
                                    ,pr_cdesteve IN PLS_INTEGER         --> Estágio do evento
                                    ,pr_flerreve IN PLS_INTEGER         --> Flag de evento de erro
                                    ,pr_dslogeve IN VARCHAR2            --> Log do evento
                                    ,pr_dscritic OUT VARCHAR2) IS       --> Retorno de crítica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_insere_evento_remessa
    --  Sistema  : CYBER
    --  Sigla    : CRED
    --  Autor    : Andre Santos - SUPERO
    --  Data     : Novembro/2014.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Efetuar o inclusao do novo evento da remessa conforme os paramtros informados
    -- Alteracoes:
    --
    ---------------------------------------------------------------------------------------------------------------
    DECLARE

      -- Busca a ultima sequencia de eventos
      CURSOR cr_nrseqenv IS
         SELECT NVL(MAX(erb.nrseqeve),0) + 1
           FROM craperb erb
          WHERE erb.idtpreme = pr_idtpreme
            AND erb.dtmvtolt = pr_dtmvtolt;
      vr_nrseqenv craperb.nrseqeve%TYPE;
    BEGIN
	    -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
  	  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_insere_evento_remessa');
      
      -- Busca a ultima sequencia do evento
      OPEN cr_nrseqenv;
      FETCH cr_nrseqenv
       INTO vr_nrseqenv;
      CLOSE cr_nrseqenv;
      -- Inserindo o evento na remessa conforme
      -- parâmetros + Data e Sequencia buscadas
      INSERT INTO CRAPERB erb(erb.idtpreme
                             ,erb.dtmvtolt
                             ,erb.nrseqeve
                             ,erb.nrseqarq
                             ,erb.dtexeeve
                             ,erb.cdesteve
                             ,erb.flerreve
                             ,erb.dslogeve)
       VALUES(pr_idtpreme
             ,pr_dtmvtolt
             ,vr_nrseqenv
             ,pr_nrseqarq
             ,SYSDATE
             ,pr_cdesteve
             ,pr_flerreve
             ,pr_dslogeve);
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
        CECRED.pc_internal_exception; 
        -- Retorna o erro para a procedure chamadora
        pr_dscritic := 'Erro --> rotina CYBE0002.pc_insere_evento_remessa -->  '||SQLERRM;
    END;
  END pc_insere_evento_remessa;


  PROCEDURE pc_lista_bureaux(pr_cdprogra IN crapprg.cdprogra%TYPE
                            ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  /* .............................................................................
  Programa: pc_lista_bureaux
  Autor   : Andre Santos - SUPERO.
  Data    : 09/01/2015                     Ultima atualizacao:

  Dados referentes ao programa:

  Objetivo  : Busca todos os Bureaux cadastrados conforme a tela chamadora

  Alteracoes :

  /* ...........................................................................*/

  -- Busca todos Bureaux Cadastrados
  CURSOR cr_bureaux IS
     SELECT pbc.idtpreme
       FROM crappbc pbc
      ORDER BY pbc.idtpreme;
  rw_bureaux cr_bureaux%ROWTYPE;

  -- Busca a quantidade de Bureaux Cadastrados
  CURSOR cr_qtd_bureaux IS
     SELECT COUNT(*)
       FROM crappbc pbc
      ORDER BY pbc.idtpreme;
  vr_qtd         NUMBER(10);

  -- Variaveis
  vr_excerror EXCEPTION;

  vr_cdcooper    NUMBER;
  vr_nmdatela    VARCHAR2(25);
  vr_nmeacao     VARCHAR2(25);
  vr_cdagenci    VARCHAR2(25);
  vr_nrdcaixa    VARCHAR2(25);
  vr_idorigem    VARCHAR2(25);
  vr_cdoperad    VARCHAR2(500);

  vr_lista       VARCHAR2(4000) := '';
  vr_qtd_bureaux NUMBER(10)     := 0;

  BEGIN
	  -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
  	GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_lista_bureaux');
      
     -- Extrair informações padrão do xml - parametros
     gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                             ,pr_cdcooper => vr_cdcooper
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nmeacao  => vr_nmeacao
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_idorigem => vr_idorigem
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dscritic => pr_dscritic);

     -- Criar cabeçalho do XML
     pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

     -- Busca todos Bureaux Cadastrados
     OPEN cr_bureaux;
     FETCH cr_bureaux INTO rw_bureaux;

        -- Busca a quantidade de Bureaux Cadastrados
        OPEN cr_qtd_bureaux;
        FETCH cr_qtd_bureaux INTO vr_qtd;
        CLOSE cr_qtd_bureaux;

        IF vr_qtd = 1 THEN -- Monta uma lista com o Bureaux encontrado
           vr_lista := rw_bureaux.idtpreme;

           IF pr_cdprogra = 'LOGRBC' THEN -- Chamada pela tela LOGRBC
              vr_lista := 'TODOS'||','||vr_lista;
              vr_qtd_bureaux := vr_qtd+1;
           ELSIF pr_cdprogra = 'PRMRBC' THEN  -- Chamada pela tela PRMRBC
              vr_lista := 'NOVO'||','||vr_lista;
              vr_qtd_bureaux := vr_qtd+1;
           END IF;

        ELSIF vr_qtd > 1 THEN
           -- Busca todos os arquivo e monta uma lista
           LOOP
              EXIT WHEN cr_bureaux%NOTFOUND;

              -- Monta lista de arquivos de remessa
              vr_lista := rw_bureaux.idtpreme||','||vr_lista;

              FETCH cr_bureaux INTO rw_bureaux;
           END LOOP;

           IF pr_cdprogra = 'LOGRBC' THEN -- Chamada pela tela LOGRBC
              vr_lista := 'TODOS'||','||vr_lista;
              vr_qtd_bureaux := vr_qtd+1;
           ELSIF pr_cdprogra = 'PRMRBC' THEN  -- Chamada pela tela PRMRBC
              vr_lista := 'NOVO'||','||vr_lista;
              vr_qtd_bureaux := vr_qtd+1;
           END IF;
        END IF;

        -- Nome do Primeiro Titular
        pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                           ,'/Root'
                                           ,XMLTYPE('<Dados lista="'|| vr_lista ||'" qtd="'||TO_CHAR(vr_qtd_bureaux)||'" ></Dados>'));

     CLOSE cr_bureaux;

   EXCEPTION
     WHEN vr_excerror THEN
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>Rotina com erros</Dados></Root>');
     WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
        CECRED.pc_internal_exception; 
        
        pr_des_erro := 'Erro geral na rotina pc_lista_bureaux: '||SQLERRM;
        pr_dscritic := 'Erro geral na rotina pc_lista_bureaux: '||SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>Rotina com erros</Dados></Root>');
  END pc_lista_bureaux;


  PROCEDURE pc_lista_contas_associ(pr_nrcpfcgc IN crapass.nrcpfcgc%TYPE
                                  ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_lista_contas_associ
  --  Sistema  : Busca lista de contas do associado
  --  Sigla    : CRED
  --  Autor    : Andre Santos - SUPERO
  --  Data     : Junho/2014.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Busca lista de contas do associado
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Cursores

  -- Buscar as informações da cooperativa
  CURSOR cr_crapcop(p_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT crapcop.cdbcoctl
         , crapcop.cdagectl
         , crapcop.nmrescop
      FROM crapcop
     WHERE crapcop.cdcooper = p_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  -- Verifica se existe o associado
  CURSOR cr_associado(p_cdcooper IN crapcop.cdcooper%TYPE
                     ,p_nrcpfcgc IN crapass.nrcpfcgc%TYPE) IS
     SELECT ass.nrdconta
           ,ass.nmprimtl
       FROM crapass ass
      WHERE ass.cdcooper = p_cdcooper
        AND ass.nrcpfcgc = p_nrcpfcgc;
  rw_associado cr_associado%ROWTYPE;

  -- Busca o numero da conta distintas do associado no sistema CYBER
  CURSOR cr_busca_conta(p_cdcooper IN crapcop.cdcooper%TYPE
                       ,p_nrcpfcgc IN crapass.nrcpfcgc%TYPE) IS
     SELECT (SELECT COUNT(DISTINCT(cyb1.nrdconta))
               FROM crapass ass1
                   ,crapcyb cyb1
              WHERE ass1.cdcooper = cyb1.cdcooper
                AND ass1.nrdconta = cyb1.nrdconta
                AND ass1.cdcooper = cyb.cdcooper
                AND ass1.nrcpfcgc = ass.nrcpfcgc) qtdContas
           ,ass.nrdconta
           ,ass.nmprimtl
       FROM crapass ass
           ,crapcyb cyb
      WHERE ass.cdcooper = cyb.cdcooper
        AND ass.nrdconta = cyb.nrdconta
        AND ass.cdcooper = p_cdcooper
        AND ass.nrcpfcgc = p_nrcpfcgc
      GROUP BY cyb.cdcooper
              ,ass.nrcpfcgc
              ,ass.nrdconta
              ,ass.nmprimtl
      ORDER BY ass.nrdconta DESC;
  rw_busca_conta cr_busca_conta%ROWTYPE;

  -- Variaveis
  vr_excerror EXCEPTION;

  vr_cdcooper    NUMBER;
  vr_nmdatela    VARCHAR2(25);
  vr_nmeacao     VARCHAR2(25);
  vr_cdagenci    VARCHAR2(25);
  vr_nrdcaixa    VARCHAR2(25);
  vr_idorigem    VARCHAR2(25);
  vr_cdoperad    VARCHAR2(500);
  vr_qtd_conta   PLS_INTEGER;

  vr_lstconta    VARCHAR2(32767);

  BEGIN
	  -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
  	GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_lista_contas_associ');

     -- Extrair informações padrão do xml - parametros
     gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                             ,pr_cdcooper => vr_cdcooper
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nmeacao  => vr_nmeacao
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_idorigem => vr_idorigem
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dscritic => pr_dscritic);

     -- Criar cabeçalho do XML
     pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

     -- Buscar dados da cooperativa
     OPEN  cr_crapcop(vr_cdcooper);
     FETCH cr_crapcop INTO rw_crapcop;
        -- Se não encontrar dados
        IF cr_crapcop%NOTFOUND THEN
           -- Fecha cursor
           CLOSE cr_crapcop;
           pr_des_erro := 'Cooperativa nao encontrada. VR_CDCOOPER = '||vr_cdcooper;
           RAISE vr_excerror;
        END IF;
     CLOSE cr_crapcop;

     OPEN cr_associado(vr_cdcooper
                      ,pr_nrcpfcgc);
     FETCH cr_associado INTO rw_associado;
        -- Nao encontrou associado
        IF cr_associado%NOTFOUND THEN
           -- Fecha cursor
           CLOSE cr_associado;
           -- Gera critica
           pr_des_erro := GENE0001.fn_busca_critica(9);
           RAISE vr_excerror;
        END IF;
     CLOSE cr_associado;

     -- Busca a conta do associado
     OPEN cr_busca_conta(vr_cdcooper
                        ,pr_nrcpfcgc);
     FETCH cr_busca_conta INTO rw_busca_conta;

        -- Nao encontrou associado
        IF cr_busca_conta%NOTFOUND THEN
           -- Fecha cursor
           CLOSE cr_busca_conta;
           -- Gera critica
           pr_des_erro := 'Contrato nao encontrado para exclusao!';
           RAISE vr_excerror;
        END IF;

        -- Se o nro CPF/CNPJ possui uma conta associada
        IF rw_busca_conta.qtdContas = 1 THEN

           -- Grava a conta do associado
           vr_qtd_conta := rw_busca_conta.qtdContas;
           vr_lstconta  := TRIM(GENE0002.fn_mask_conta(rw_busca_conta.nrdconta));

        ELSE

           -- Inicializa a variavel
           vr_lstconta := ' ';
           -- Verifica se o associado possui mais de uma conta
           LOOP
              EXIT WHEN cr_busca_conta%NOTFOUND;

              -- Monta lista de contas do associado
              vr_lstconta := TRIM(GENE0002.fn_mask_conta(rw_busca_conta.nrdconta))||','||vr_lstconta;

              FETCH cr_busca_conta INTO rw_busca_conta;
           END LOOP;

           -- Grava a quantidade de contas mais um para a TODAS
           vr_qtd_conta := rw_busca_conta.qtdContas + 1;
           vr_lstconta := 'TODAS'||','||vr_lstconta;

       END IF;

       -- Nome do Primeiro Titular
       pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                          ,'/Root'
                                          ,XMLTYPE('<Dados nmprimtl="'|| rw_busca_conta.nmprimtl ||'" lstconta="'||vr_lstconta||'" qtcontas="'|| vr_qtd_conta ||'" ></Dados>'));

     CLOSE cr_busca_conta;

  EXCEPTION
     WHEN vr_excerror THEN
        pr_dscritic := pr_des_erro;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>Rotina com erros</Dados></Root>');
     WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
        CECRED.pc_internal_exception; 
        
        pr_des_erro := 'Erro geral na rotina pc_lista_contas_associ: '||SQLERRM;
        pr_dscritic := 'Erro geral na rotina pc_lista_contas_associ: '||SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>Rotina com erros</Dados></Root>');
  END pc_lista_contas_associ;


  PROCEDURE pc_lista_contratos_associ(pr_nrdconta IN VARCHAR2
                                     ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                     ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_lista_contratos_associ
  --  Sistema  : Busca lista de contratos relacionados a conta
  --  Sigla    : CRED
  --  Autor    : Andre Santos - SUPERO
  --  Data     : Junho/2014.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Busca lista de contratos relacionados a conta
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Cursores

  -- Buscar as informações da cooperativa
  CURSOR cr_crapcop(p_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT crapcop.cdbcoctl
         , crapcop.cdagectl
         , crapcop.nmrescop
      FROM crapcop
     WHERE crapcop.cdcooper = p_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  -- Busca os contratos cadastrados no sistema CYBER
  CURSOR cr_cyber(p_cdcooper IN crapcop.cdcooper%TYPE
                 ,p_nrdconta IN crapass.nrdconta%TYPE) IS
     SELECT DECODE(cyb.cdorigem,1,'C',2,'D',3,'E',4,'F',5,'T','') ||' - '||
            TRIM(GENE0002.fn_mask_contrato(cyb.nrctremp)) nrctremp
       FROM crapcyb cyb
      WHERE cyb.cdcooper = p_cdcooper
        AND cyb.nrdconta = p_nrdconta
   ORDER BY cyb.cdorigem DESC,cyb.nrctremp DESC;
  rw_cyber cr_cyber%ROWTYPE;

  -- Verifica a quantidade de contratos relacionados a conta
  CURSOR cr_qtd_restricao(p_cdcooper IN crapcop.cdcooper%TYPE
                         ,p_nrdconta IN crapass.nrdconta%TYPE) IS
     SELECT COUNT(cyb.nrctremp) qtdrestricao
       FROM crapcyb cyb
      WHERE cyb.cdcooper = p_cdcooper
        AND cyb.nrdconta = p_nrdconta;
  vr_qtd_restricao PLS_INTEGER;

  -- Variaveis
  vr_excerror EXCEPTION;

  vr_cdcooper    NUMBER;
  vr_nmdatela    VARCHAR2(25);
  vr_nmeacao     VARCHAR2(25);
  vr_cdagenci    VARCHAR2(25);
  vr_nrdcaixa    VARCHAR2(25);
  vr_idorigem    VARCHAR2(25);
  vr_cdoperad    VARCHAR2(500);

  vr_contrato    VARCHAR2(32767);

  BEGIN
	  -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
  	GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_lista_contratos_associ');
      
     -- Extrair informações padrão do xml - parametros
     gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                             ,pr_cdcooper => vr_cdcooper
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nmeacao  => vr_nmeacao
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_idorigem => vr_idorigem
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dscritic => pr_dscritic);

     -- Criar cabeçalho do XML
     pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

     -- Buscar dados da cooperativa
     OPEN  cr_crapcop(vr_cdcooper);
     FETCH cr_crapcop INTO rw_crapcop;
        -- Se não encontrar dados
        IF cr_crapcop%NOTFOUND THEN
           -- Fecha cursor
           CLOSE cr_crapcop;
           pr_des_erro := 'Cooperativa nao encontrada. VR_CDCOOPER = '||vr_cdcooper;
           RAISE vr_excerror;
        END IF;
     CLOSE cr_crapcop;

     -- Busca os contratos cadastrados no sistema CYBER
     OPEN cr_cyber(vr_cdcooper
                  ,pr_nrdconta);
     FETCH cr_cyber INTO rw_cyber;
        -- Nao encontrou contratos
        IF cr_cyber%NOTFOUND THEN
           -- Fecha cursor
           CLOSE cr_cyber;
           -- Gera critica
           pr_des_erro := 'Associado sem restricoes no sistema CYBER.';
           RAISE vr_excerror;
        END IF;

        -- Verifica a quantidade de contratos relacionados a conta
        OPEN cr_qtd_restricao(vr_cdcooper
                             ,pr_nrdconta);
        FETCH cr_qtd_restricao INTO vr_qtd_restricao;
        CLOSE cr_qtd_restricao;

        -- Se o nro CPF/CNPJ possui uma conta associada
        IF NVL(vr_qtd_restricao,0) = 1 THEN
           -- Grava a conta do associado
           vr_contrato := rw_cyber.nrctremp;
        ELSE
            -- Verifica se o associado possui mais de uma conta
            LOOP
               EXIT WHEN cr_cyber%NOTFOUND;

               -- Monta lista de contas do associado
               vr_contrato := rw_cyber.nrctremp||','||vr_contrato;

               FETCH cr_cyber INTO rw_cyber;
            END LOOP;

            vr_qtd_restricao := vr_qtd_restricao + 1;
            vr_contrato := 'TODOS'||','||vr_contrato;

        END IF;

        -- Retorna o contrato e sua quantidade
        pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                           ,'/Root'
                                           ,XMLTYPE('<Dados lstcontrato="'||vr_contrato||'" qtd="'||vr_qtd_restricao||'" ></Dados>'));

     CLOSE cr_cyber;

  EXCEPTION
     WHEN vr_excerror THEN
        pr_dscritic := pr_des_erro;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>Rotina com erros</Dados></Root>');
     WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
        CECRED.pc_internal_exception; 
        
        pr_des_erro := 'Erro geral na rotina pc_lista_contratos_associ: '||SQLERRM;
        pr_dscritic := 'Erro geral na rotina pc_lista_contratos_associ: '||SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>Rotina com erros</Dados></Root>');
  END pc_lista_contratos_associ;

  PROCEDURE pc_grava_reafor(pr_dtmvtolt IN VARCHAR2
                           ,pr_cdoperad IN VARCHAR2
                           ,pr_nrcpfcgc IN VARCHAR2
                           ,pr_nrdconta IN VARCHAR2
                           ,pr_nrctremp IN VARCHAR2
                           ,pr_rowid    IN VARCHAR2
                           ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                           ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                           ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                           ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                           ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                           ,pr_des_erro OUT VARCHAR2) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_grava_reafor
  --  Sistema  : Busca lista de contratos relacionados a conta
  --  Sigla    : CRED
  --  Autor    : Andre Santos - SUPERO
  --  Data     : Junho/2014.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Busca lista de contratos relacionados a conta
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Cursor


  -- Buscar as informações da cooperativa
  CURSOR cr_crapcop(p_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT crapcop.cdbcoctl
         , crapcop.cdagectl
         , crapcop.nmrescop
      FROM crapcop
     WHERE crapcop.cdcooper = p_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  -- Verifica se o registro já foi processado
  CURSOR cr_valida_rea(p_cdcooper IN crapcop.cdcooper%TYPE
                      ,p_dtmvtolt IN crapdat.dtmvtolt%TYPE
                      ,p_nrcpfcgc IN crapass.nrcpfcgc%TYPE
                      ,p_rowid    IN VARCHAR2) IS
     SELECT (SELECT COUNT(rea.nrdconta)
               FROM craprea
              WHERE rea.cdcooper = rea.cdcooper
                AND rea.dtmvtolt = rea.dtmvtolt
                AND rea.nrcpfcgc = rea.nrcpfcgc
                AND rea.nrdconta = rea.nrdconta
                AND rea.nrctremp = rea.nrctremp) qtdContas
           ,rea.nrdconta
           ,rea.nrctremp
       FROM craprea rea
      WHERE rea.cdcooper = p_cdcooper
        AND rea.dtmvtolt = p_dtmvtolt
        AND rea.nrcpfcgc = p_nrcpfcgc
        AND (rea.rowid   <> p_rowid
         OR p_rowid IS NULL);
  rw_valida_rea cr_valida_rea%ROWTYPE;

  -- Variaveis
  vr_excerror EXCEPTION;

  vr_dtmvtolt    DATE;
  vr_cdcooper    NUMBER;
  vr_nmdatela    VARCHAR2(25);
  vr_nmeacao     VARCHAR2(25);
  vr_cdagenci    VARCHAR2(25);
  vr_nrdcaixa    VARCHAR2(25);
  vr_idorigem    VARCHAR2(25);
  vr_cdoperad    VARCHAR2(500);
  vr_erro        BOOLEAN;

  BEGIN
	  -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
  	GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_grava_reafor');
      
     -- Inicializa Variavel
     vr_erro := FALSE;
     -- Extrair informações padrão do xml - parametros
     gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                             ,pr_cdcooper => vr_cdcooper
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nmeacao  => vr_nmeacao
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_idorigem => vr_idorigem
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dscritic => pr_dscritic);

     -- Criar cabeçalho do XML
     pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

     vr_dtmvtolt := TO_DATE(pr_dtmvtolt,'DD/MM/RRRR');

     -- Buscar dados da cooperativa
     OPEN  cr_crapcop(vr_cdcooper);
     FETCH cr_crapcop INTO rw_crapcop;
        -- Se não encontrar dados
        IF cr_crapcop%NOTFOUND THEN
           -- Fecha cursor
           CLOSE cr_crapcop;
           pr_des_erro := 'Cooperativa nao encontrada. VR_CDCOOPER = '||vr_cdcooper;
           RAISE vr_excerror;
        END IF;
     CLOSE cr_crapcop;

     -- Verifica se o associado já possui uma reabilitacao
     OPEN cr_valida_rea(vr_cdcooper
                       ,vr_dtmvtolt
                       ,TO_NUMBER(REPLACE(REPLACE(REPLACE(pr_nrcpfcgc,'.',''),'-',''),'/',''))
                       ,pr_rowid);
     FETCH cr_valida_rea INTO rw_valida_rea;
        LOOP
           EXIT WHEN cr_valida_rea%NOTFOUND;

           IF TO_NUMBER(pr_nrdconta) = 0 AND rw_valida_rea.nrdconta = 0 THEN
              pr_des_erro := 'Ja cadastrada reabilitacao para todas as contas desse associado.';
              vr_erro := TRUE;
              EXIT; -- Sair do Loop
           ELSIF ((TO_NUMBER(pr_nrdconta) <> 0 AND TO_NUMBER(NVL(SUBSTR(pr_nrctremp,2,LENGTH(pr_nrctremp)),0)) = 0) AND
                 (rw_valida_rea.nrdconta = TO_NUMBER(pr_nrdconta) AND rw_valida_rea.nrctremp = 0))  THEN
              pr_des_erro := 'Ja cadastrada reabilitacao para todos os contratos desta conta.';
              vr_erro := TRUE;
              EXIT; -- Sair do Loop
           ELSIF ((TO_NUMBER(pr_nrdconta) <> 0 AND TO_NUMBER(NVL(SUBSTR(pr_nrctremp,2,LENGTH(pr_nrctremp)),0)) = 0) AND
                 (rw_valida_rea.nrdconta = TO_NUMBER(pr_nrdconta) AND rw_valida_rea.nrctremp <> 0))  THEN
              pr_des_erro := 'Ja cadastrada reabilitacao para essa conta! #br /#'||
                             'Voce nao pode [Incluir ou Alterar] uma reabilitacao para todos os contratos do mesmo.';
              vr_erro := TRUE;
              EXIT; -- Sair do Loop
           ELSIF ((TO_NUMBER(pr_nrdconta) <> 0 AND TO_NUMBER(NVL(SUBSTR(pr_nrctremp,2,LENGTH(pr_nrctremp)),0)) <> 0) AND
                 (rw_valida_rea.nrdconta = TO_NUMBER(pr_nrdconta) AND rw_valida_rea.nrctremp = 0))  THEN
              pr_des_erro := 'Ja cadastrada reabilitacao para todos os contratos desta conta, #br /#'||
                             'para reabilitar um contrato especifico, remova a reabilitacao TODOS.';
              vr_erro := TRUE;
              EXIT; -- Sair do Loop
           ELSIF (((TO_NUMBER(pr_nrdconta) <> 0 AND TO_NUMBER(NVL(SUBSTR(pr_nrctremp,2,LENGTH(pr_nrctremp)),0)) <> 0) AND
                 (rw_valida_rea.nrdconta = 0 AND rw_valida_rea.nrctremp = 0)) AND NVL(pr_rowid,' ') = ' ' ) THEN
              pr_des_erro := 'Ja cadastrada reabilitacao para todas as contas desse associado, #br /#'||
                             'para reabilitar apenas a conta especificada, remova a reabilitacao TODAS.';
              vr_erro := TRUE;
              EXIT; -- Sair do Loop
           ELSIF ((TO_NUMBER(pr_nrdconta) = 0 AND TO_NUMBER(NVL(SUBSTR(pr_nrctremp,2,LENGTH(pr_nrctremp)),0)) = 0) AND
                 (rw_valida_rea.nrdconta <> 0 AND rw_valida_rea.nrctremp <> 0)) THEN
              pr_des_erro := 'Ja cadastrada reabilitacao para esse associado! #br /#'||
                             'Voce nao pode [Incluir ou Alterar] uma reabilitacao para todas as contas do mesmo.';
              vr_erro := TRUE;
              EXIT; -- Sair do Loop
           ELSIF rw_valida_rea.nrdconta = TO_NUMBER(pr_nrdconta) AND rw_valida_rea.nrctremp = TO_NUMBER(NVL(SUBSTR(pr_nrctremp,2,LENGTH(pr_nrctremp)),0)) THEN
              pr_des_erro := 'Ja cadastrada reabilitacao para esta conta e contrato!';
              vr_erro := TRUE;
              EXIT; -- Sair do Loop
           END IF;

           FETCH cr_valida_rea INTO rw_valida_rea;
        END LOOP;
     CLOSE cr_valida_rea;

     -- Se houver erro
     IF vr_erro THEN
        RAISE vr_excerror;
     END IF;

     IF NVL(pr_rowid,' ') = ' ' OR pr_rowid IS NULL THEN -- Inserir

        -- Insere o registro na CRAPREA
        BEGIN
           INSERT INTO craprea(cdcooper
                              ,dtmvtolt
                              ,nrcpfcgc
                              ,nrdconta
                              ,cdorigem
                              ,nrctremp
                              ,cdoperad
                              ,flenvarq)
           VALUES(vr_cdcooper
                 ,vr_dtmvtolt
                 ,TO_NUMBER(REPLACE(REPLACE(REPLACE(pr_nrcpfcgc,'.',''),'-',''),'/',''))
                 ,DECODE(pr_nrdconta,'0',0,pr_nrdconta)
                 ,DECODE(pr_nrctremp,'0',0,DECODE(SUBSTR(pr_nrctremp,1,1),'C',1,'D',2,'E',3,'F',4,'T',5,0))
                 ,DECODE(pr_nrctremp,'0',0,TO_NUMBER(SUBSTR(pr_nrctremp,2,LENGTH(pr_nrctremp))))
                 ,pr_cdoperad
                 ,0);

        EXCEPTION
           WHEN OTHERS THEN
             -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
             CECRED.pc_internal_exception; 
        
              pr_des_erro := 'Erro ao inserir o registro na CRAPREA: '||SQLERRM;
              RAISE vr_excerror;
        END;

     ELSE -- Atualizacao
        -- Atualiza o registro na CRAPREA
        BEGIN
           UPDATE craprea rea
              SET rea.nrdconta = DECODE(pr_nrdconta,'0',0,pr_nrdconta)
                 ,rea.nrctremp = DECODE(pr_nrctremp,'0',0,TO_NUMBER(SUBSTR(pr_nrctremp,2,LENGTH(pr_nrctremp))))
                 ,rea.cdorigem = DECODE(pr_nrctremp,'0',0,DECODE(SUBSTR(pr_nrctremp,1,1),'C',1,'D',2,'E',3,0))
                 ,rea.cdoperad = pr_cdoperad
            WHERE rea.rowid = pr_rowid;
        EXCEPTION
           WHEN OTHERS THEN
             -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
             CECRED.pc_internal_exception;
             
              pr_des_erro := 'Erro ao atualizar o registro na CRAPREA: '||SQLERRM;
              RAISE vr_excerror;
        END;
     END IF;

     COMMIT;

  EXCEPTION
     WHEN vr_excerror THEN
        ROLLBACK;
        pr_dscritic := pr_des_erro;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>Rotina com erros</Dados></Root>');
     WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
        CECRED.pc_internal_exception; 
        
        ROLLBACK;
        pr_des_erro := 'Erro geral na rotina pc_grava_reafor: '||SQLERRM;
        pr_dscritic := 'Erro geral na rotina pc_grava_reafor: '||SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>Rotina com erros</Dados></Root>');
  END pc_grava_reafor;


  PROCEDURE pc_exclui_reafor(pr_rowid    IN VARCHAR2
                            ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                            ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                            ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                            ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                            ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                            ,pr_des_erro OUT VARCHAR2) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_grava_reafor
  --  Sistema  : Busca lista de contratos relacionados a conta
  --  Sigla    : CRED
  --  Autor    : Andre Santos - SUPERO
  --  Data     : Junho/2014.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Busca lista de contratos relacionados a conta
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Cursor

  -- Buscar as informações da cooperativa
  CURSOR cr_crapcop(p_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT crapcop.cdbcoctl
         , crapcop.cdagectl
         , crapcop.nmrescop
      FROM crapcop
     WHERE crapcop.cdcooper = p_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  -- Verifica se o registro já foi processado
  CURSOR cr_flenvarq(p_flenvarq IN VARCHAR2) IS
     SELECT rea.flenvarq
       FROM craprea rea
      WHERE ROWID = p_flenvarq;
  vr_flenvarq PLS_INTEGER;

  -- Variaveis
  vr_excerror EXCEPTION;

  vr_cdcooper    NUMBER;
  vr_nmdatela    VARCHAR2(25);
  vr_nmeacao     VARCHAR2(25);
  vr_cdagenci    VARCHAR2(25);
  vr_nrdcaixa    VARCHAR2(25);
  vr_idorigem    VARCHAR2(25);
  vr_cdoperad    VARCHAR2(500);

  BEGIN
	  -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
  	GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_exclui_reafor');
      
     -- Extrair informações padrão do xml - parametros
     gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                             ,pr_cdcooper => vr_cdcooper
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nmeacao  => vr_nmeacao
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_idorigem => vr_idorigem
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dscritic => pr_dscritic);

     -- Criar cabeçalho do XML
     pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

     -- Buscar dados da cooperativa
     OPEN  cr_crapcop(vr_cdcooper);
     FETCH cr_crapcop INTO rw_crapcop;
        -- Se não encontrar dados
        IF cr_crapcop%NOTFOUND THEN
           CLOSE cr_crapcop;
           pr_des_erro := 'Cooperativa nao encontrada. VR_CDCOOPER = '||vr_cdcooper;
           RAISE vr_excerror;
        END IF;
     CLOSE cr_crapcop;

     -- Verifica se o rowid corrente já foi processado
     OPEN cr_flenvarq(pr_rowid);
     FETCH cr_flenvarq INTO vr_flenvarq;
        IF vr_flenvarq = 1 THEN
           -- Fecha cursor
           CLOSE cr_flenvarq;
           pr_des_erro := 'A reabilitacao ja foi processada, nao foi possivel eliminar o '||
                          'registro selecionado!';
           RAISE vr_excerror;
        END IF;
     CLOSE cr_flenvarq;

     -- Se não houve registro processado, preparar para elimina-los
     BEGIN
        DELETE craprea rea
         WHERE rea.rowid = pr_rowid;
     EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
          CECRED.pc_internal_exception; 
           pr_des_erro := 'Erro ao deletar o registro na CRAPREA: '||SQLERRM;
           RAISE vr_excerror;
     END;

     COMMIT;

  EXCEPTION
     WHEN vr_excerror THEN
        ROLLBACK;
        pr_dscritic := pr_des_erro;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>Rotina com erros</Dados></Root>');
     WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
        CECRED.pc_internal_exception; 
        
        ROLLBACK;
        pr_des_erro := 'Erro geral na rotina pc_exclui_reafor: '||SQLERRM;
        pr_dscritic := 'Erro geral na rotina pc_exclui_reafor: '||SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>Rotina com erros</Dados></Root>');
  END pc_exclui_reafor;


  PROCEDURE pc_lista_dados_reafor(pr_dtmvtolt IN VARCHAR2              --> Data informada na tela
                                 ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_lista_dados_reafor
  --  Sistema  : Busca dados para exibir na tela REAFOR
  --  Sigla    : CRED
  --  Autor    : Andre Santos - SUPERO
  --  Data     : Junho/2014.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Busca dados para exibir na tela REAFOR
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Cursores

  -- Buscar as informações da cooperativa
  CURSOR cr_crapcop(p_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT crapcop.cdbcoctl
         , crapcop.cdagectl
         , crapcop.nmrescop
      FROM crapcop
     WHERE crapcop.cdcooper = p_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  -- Busca os dados para exibir na tela REAFOR
  CURSOR cr_busca_dados(p_cdcooper IN crapcop.cdcooper%TYPE
                       ,p_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
     SELECT rea.flenvarq
           ,rea.cdcooper
           ,rea.dtmvtolt
           ,rea.cdoperad ||' - '|| ope.nmoperad cdoperad
           ,gene0002.fn_mask_cpf_cnpj(rea.nrcpfcgc,ass.inpessoa) nrcpfcgc
           ,DECODE(rea.nrdconta,0,'TODAS',gene0002.fn_mask_conta(DECODE(rea.nrdconta,0,rea.nrdconta,ass.nrdconta))) nrdconta
           ,UPPER(ass.nmprimtl) nmprimtl
           ,DECODE(rea.cdorigem,0,DECODE(rea.nrctremp,0,'TODOS',gene0002.fn_mask_contrato(rea.nrctremp)),TRIM(DECODE(rea.cdorigem,1,'C',2,'D',3,'E',4,'F',5,'T',''))||' - '||DECODE(rea.nrctremp,0,'TODOS',TRIM(gene0002.fn_mask_contrato(rea.nrctremp))))nrctremp
           ,rea.ROWID
       FROM crapass ass
           ,crapope ope
           ,craprea rea
      WHERE ass.cdcooper = rea.cdcooper
        AND ope.cdcooper = rea.cdcooper
        AND UPPER(ope.cdoperad) = UPPER(rea.cdoperad)
        AND ass.nrcpfcgc = rea.nrcpfcgc
        AND ass.nrdconta = DECODE(rea.nrdconta,0,ass.nrdconta,rea.nrdconta)
        AND rea.dtmvtolt = p_dtmvtolt
        AND rea.cdcooper = p_cdcooper
      GROUP BY rea.flenvarq
           ,rea.cdcooper
           ,rea.dtmvtolt
           ,rea.cdoperad ||' - '|| ope.nmoperad
           ,gene0002.fn_mask_cpf_cnpj(rea.nrcpfcgc,ass.inpessoa)
           ,DECODE(rea.nrdconta,0,'TODAS',gene0002.fn_mask_conta(DECODE(rea.nrdconta,0,rea.nrdconta,ass.nrdconta)))
           ,ass.nmprimtl
           ,rea.cdorigem
           ,rea.nrctremp
           ,rea.ROWID
      ORDER BY rea.dtmvtolt
              ,nrcpfcgc
              ,nrdconta
              ,rea.nrctremp;
  rw_busca_dados cr_busca_dados%ROWTYPE;

  -- Variaveis
  vr_excerror EXCEPTION;

  vr_dtmvtolt    DATE;
  vr_cdcooper    NUMBER;
  vr_nmdatela    varchar2(25);
  vr_nmeacao     varchar2(25);
  vr_cdagenci    varchar2(25);
  vr_nrdcaixa    varchar2(25);
  vr_idorigem    varchar2(25);
  vr_cdoperad    varchar2(500);

  vr_index PLS_INTEGER;

  -- Variavel Tabela Temporaria
  vr_tab_dados   gene0007.typ_mult_array;       --> PL Table para armazenar dados para formar o XML
  vr_tab_tags    gene0007.typ_tab_tagxml;       --> PL Table para armazenar TAG´s do XML

  BEGIN
	  -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
  	GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_lista_dados_reafor');

     -- Extrair informações padrão do xml - parametros
     gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                             ,pr_cdcooper => vr_cdcooper
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nmeacao  => vr_nmeacao
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_idorigem => vr_idorigem
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dscritic => pr_dscritic);

     -- Inicializa Variavel
     vr_dtmvtolt := TO_DATE(pr_dtmvtolt,'DD/MM/RRRR');

     -- Criar cabeçalho do XML
     pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

     -- Buscar dados da cooperativa
     OPEN  cr_crapcop(vr_cdcooper);
     FETCH cr_crapcop INTO rw_crapcop;
        -- Se não encontrar dados
        IF cr_crapcop%NOTFOUND THEN
           -- Fecha cursor
           CLOSE cr_crapcop;
           pr_des_erro := 'Cooperativa não encontrada. VR_CDCOOPER = '||vr_cdcooper;
           RAISE vr_excerror;
        END IF;
     CLOSE cr_crapcop;

     -- Busca os dados para exibir na tela REAFOR
     OPEN cr_busca_dados(vr_cdcooper
                        ,vr_dtmvtolt);
     FETCH cr_busca_dados INTO rw_busca_dados;
        LOOP
           EXIT WHEN cr_busca_dados%NOTFOUND;

           -- Captura último indice da PL Table
           vr_index := nvl(vr_tab_dados.count, 0) + 1;
           -- Gravando registros
           vr_tab_dados(vr_index)('indrowid') := rw_busca_dados.rowid;
           vr_tab_dados(vr_index)('flenvarq') := rw_busca_dados.flenvarq;
           vr_tab_dados(vr_index)('dtmvtolt') := to_char(rw_busca_dados.dtmvtolt, 'DD/MM/RRRR');
           vr_tab_dados(vr_index)('cdoperad') := rw_busca_dados.cdoperad;
           vr_tab_dados(vr_index)('nrcpfcgc') := rw_busca_dados.nrcpfcgc;
           vr_tab_dados(vr_index)('nmprimtl') := rw_busca_dados.nmprimtl;
           vr_tab_dados(vr_index)('nrdconta') := rw_busca_dados.nrdconta;
           vr_tab_dados(vr_index)('nrctremp') := rw_busca_dados.nrctremp;

           FETCH cr_busca_dados INTO rw_busca_dados;
        END LOOP;
     CLOSE cr_busca_dados;

     -- Geração de TAG's
     gene0007.pc_gera_tag('indrowid',vr_tab_tags);
     gene0007.pc_gera_tag('flenvarq',vr_tab_tags);
     gene0007.pc_gera_tag('dtmvtolt',vr_tab_tags);
     gene0007.pc_gera_tag('cdoperad',vr_tab_tags);
     gene0007.pc_gera_tag('nrcpfcgc',vr_tab_tags);
     gene0007.pc_gera_tag('nmprimtl',vr_tab_tags);
     gene0007.pc_gera_tag('nrdconta',vr_tab_tags);
     gene0007.pc_gera_tag('nrctremp',vr_tab_tags);

     -- Forma XML de retorno para casos de sucesso (listar dados)
     gene0007.pc_gera_xml(pr_tab_dados => vr_tab_dados
                         ,pr_tab_tag   => vr_tab_tags
                         ,pr_XMLType   => pr_retxml
                         ,pr_path_tag  => '/Root'
                         ,pr_tag_no    => 'retorno'
                         ,pr_des_erro  => pr_des_erro);

  EXCEPTION
     WHEN vr_excerror THEN
        pr_dscritic := pr_des_erro;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>Rotina com erros</Dados></Root>');
     WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
        CECRED.pc_internal_exception; 
        
        pr_des_erro := 'Erro geral na rotina pc_lista_dados_reafor: '||SQLERRM;
        pr_dscritic := 'Erro geral na rotina pc_lista_dados_reafor: '||SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>Rotina com erros</Dados></Root>');
  END;


  PROCEDURE pc_retorna_reafor(pr_rowid    IN VARCHAR2
                             ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                             ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                             ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                             ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                             ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                             ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_retorna_reafor
  --  Sistema  : Busca dados para exibir e atualizar na tela REAFOR
  --  Sigla    : CRED
  --  Autor    : Andre Santos - SUPERO
  --  Data     : Junho/2014.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Busca dados para exibir e atualizar na tela REAFOR
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------
  -- Cursores

  -- Buscar as informações da cooperativa
  CURSOR cr_crapcop(p_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT crapcop.cdbcoctl
         , crapcop.cdagectl
         , crapcop.nmrescop
      FROM crapcop
     WHERE crapcop.cdcooper = p_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  -- Consulta o registro de reabilitacao para altera-lo
  CURSOR cr_craprea(p_rowid IN VARCHAR2) IS
     SELECT rea.flenvarq
           ,rea.cdcooper
           ,rea.dtmvtolt
           ,rea.cdoperad ||' - '|| ope.nmoperad cdoperad
           ,rea.nrcpfcgc
           ,ass.inpessoa
           ,DECODE(rea.nrdconta,0,'TODAS',gene0002.fn_mask_conta(DECODE(rea.nrdconta,0,rea.nrdconta,ass.nrdconta))) nrdconta
           ,UPPER(ass.nmprimtl) nmprimtl
           ,DECODE(rea.cdorigem,0,DECODE(rea.nrctremp,0,'TODOS',gene0002.fn_mask_contrato(rea.nrctremp)),TRIM(DECODE(rea.cdorigem,1,'C',2,'D',3,'E',4,'F',5,'T',''))||' - '||DECODE(rea.nrctremp,0,'TODOS',TRIM(gene0002.fn_mask_contrato(rea.nrctremp))))nrctremp
           ,rea.ROWID
       FROM crapass ass
           ,crapope ope
           ,craprea rea
      WHERE ass.cdcooper = rea.cdcooper
        AND ope.cdcooper = rea.cdcooper
        AND UPPER(ope.cdoperad) = UPPER(rea.cdoperad)
        AND ass.nrcpfcgc = rea.nrcpfcgc
        AND ass.nrdconta = DECODE(rea.nrdconta,0,ass.nrdconta,rea.nrdconta)
        AND rea.rowid = p_rowid
      GROUP BY rea.flenvarq
           ,rea.cdcooper
           ,rea.dtmvtolt
           ,rea.cdoperad ||' - '|| ope.nmoperad
           ,rea.nrcpfcgc
           ,ass.inpessoa
           ,DECODE(rea.nrdconta,0,'TODAS',gene0002.fn_mask_conta(DECODE(rea.nrdconta,0,rea.nrdconta,ass.nrdconta)))
           ,ass.nmprimtl
           ,rea.cdorigem
           ,rea.nrctremp
           ,rea.ROWID;
  rw_craprea cr_craprea%ROWTYPE;

  -- Busca o numero da conta do associado
  CURSOR cr_busca_conta(p_cdcooper IN crapcop.cdcooper%TYPE
                       ,p_nrcpfcgc IN crapass.nrcpfcgc%TYPE) IS
     SELECT (SELECT COUNT(DISTINCT(cyb1.nrdconta))
               FROM crapass ass1
                   ,crapcyb cyb1
              WHERE ass1.cdcooper = cyb1.cdcooper
                AND ass1.nrdconta = cyb1.nrdconta
                AND ass1.cdcooper = cyb.cdcooper
                AND ass1.nrcpfcgc = ass.nrcpfcgc) qtdContas
           ,ass.nrdconta
           ,ass.nmprimtl
       FROM crapass ass
           ,crapcyb cyb
      WHERE ass.cdcooper = cyb.cdcooper
        AND ass.nrdconta = cyb.nrdconta
        AND ass.cdcooper = p_cdcooper
        AND ass.nrcpfcgc = p_nrcpfcgc
      GROUP BY cyb.cdcooper
              ,ass.nrcpfcgc
              ,ass.nrdconta
              ,ass.nmprimtl
      ORDER BY ass.nrdconta DESC;
  rw_busca_conta cr_busca_conta%ROWTYPE;

  -- Busca os contratos cadastrados na CREAPREA
  CURSOR cr_contrato(p_cdcooper IN crapcop.cdcooper%TYPE
                    ,p_nrcpfcgc IN crapass.nrcpfcgc%TYPE
                    ,p_nrdconta IN NUMBER) IS
     SELECT DECODE(cyb.cdorigem,1,'C',2,'D',3,'E',4,'F',5,'T','') ||' - '||
            TRIM(GENE0002.fn_mask_contrato(cyb.nrctremp)) nrctremp
            ,ass.nrdconta
        FROM crapass ass
            ,crapcyb cyb
       WHERE ass.cdcooper = cyb.cdcooper
         AND ass.nrdconta = cyb.nrdconta
         AND ass.cdcooper = p_cdcooper
         AND ass.nrcpfcgc = p_nrcpfcgc
         AND cyb.nrdconta =  DECODE(p_nrdconta,0,cyb.nrdconta,p_nrdconta)
       GROUP BY cyb.cdcooper
               ,ass.nrcpfcgc
               ,ass.nrdconta
               ,ass.nmprimtl
               ,cyb.nrctremp
               ,cyb.cdorigem
       ORDER BY cyb.cdorigem DESC
               ,cyb.nrctremp DESC;
  rw_contrato cr_contrato%ROWTYPE;

  -- Verifica a quantidade de contratos relacionados a conta
  CURSOR cr_qtd_restricao(p_cdcooper IN crapcop.cdcooper%TYPE
                         ,p_nrcpfcgc IN crapass.nrcpfcgc%TYPE
                         ,p_nrdconta IN NUMBER) IS
     SELECT COUNT(cyb.nrctremp) qtdrestricao
           FROM crapass ass
           ,crapcyb cyb
      WHERE ass.cdcooper = cyb.cdcooper
        AND ass.nrdconta = cyb.nrdconta
        AND ass.cdcooper = p_cdcooper
        AND ass.nrcpfcgc = p_nrcpfcgc
        AND cyb.nrdconta = DECODE(p_nrdconta,0,cyb.nrdconta,p_nrdconta)
      GROUP BY cyb.cdcooper
              ,ass.nrcpfcgc
              ,ass.nrdconta
              ,ass.nmprimtl;
  vr_qtd_restricao PLS_INTEGER;

  -- Variaveis
  vr_excerror EXCEPTION;

  vr_cdcooper    NUMBER;
  vr_nmdatela    VARCHAR2(25);
  vr_nmeacao     VARCHAR2(25);
  vr_cdagenci    VARCHAR2(25);
  vr_nrdcaixa    VARCHAR2(25);
  vr_idorigem    VARCHAR2(25);
  vr_cdoperad    VARCHAR2(500);
  vr_qtd_conta   PLS_INTEGER;

  vr_index       PLS_INTEGER;

  vr_lstconta    VARCHAR2(32767);
  vr_contrato    VARCHAR2(32767);

  -- Variavel Tabela Temporaria
  vr_tab_dados   gene0007.typ_mult_array;       --> PL Table para armazenar dados para formar o XML
  vr_tab_tags    gene0007.typ_tab_tagxml;       --> PL Table para armazenar TAG´s do XML

  BEGIN
	  -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
  	GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_retorna_reafor');

     -- Extrair informações padrão do xml - parametros
     gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                             ,pr_cdcooper => vr_cdcooper
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nmeacao  => vr_nmeacao
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_idorigem => vr_idorigem
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dscritic => pr_dscritic);

     -- Criar cabeçalho do XML
     pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

     -- Buscar dados da cooperativa
     OPEN  cr_crapcop(vr_cdcooper);
     FETCH cr_crapcop INTO rw_crapcop;
        -- Se não encontrar dados
        IF cr_crapcop%NOTFOUND THEN
           CLOSE cr_crapcop;
           pr_des_erro := 'Cooperativa nao encontrada. VR_CDCOOPER = '||vr_cdcooper;
           RAISE vr_excerror;
        END IF;
     CLOSE cr_crapcop;

     -- Consulta o registro de reabilitacao para altera-lo
     OPEN cr_craprea(pr_rowid);
     FETCH cr_craprea INTO rw_craprea;

        IF cr_craprea%NOTFOUND THEN
           CLOSE cr_craprea;
           pr_des_erro := 'Registro de reabilitacao nao encontrado!';
           RAISE vr_excerror;
        END IF;

        -- Verifica se já foi processado o registro
        IF rw_craprea.flenvarq = 1 THEN
           CLOSE cr_craprea;
           pr_des_erro := 'A reabilitacao ja foi processada, nao e possivel altera-la!';
           RAISE vr_excerror;
        END IF;

        -- Busca a conta do associado
        OPEN cr_busca_conta(rw_craprea.cdcooper
                           ,rw_craprea.nrcpfcgc);
        FETCH cr_busca_conta INTO rw_busca_conta;
           -- Nao encontrou associado
           IF cr_busca_conta%NOTFOUND THEN
              -- Fecha cursor
              CLOSE cr_busca_conta;
              -- Gera critica
              pr_des_erro := 'Contrato nao encontrado para exclusao!';
              RAISE vr_excerror;
           END IF;

           -- Se o nro CPF/CNPJ possui uma conta associada
           IF rw_busca_conta.qtdContas = 1 THEN
              -- Grava a conta do associado
              vr_qtd_conta := rw_busca_conta.qtdContas;
              vr_lstconta := TRIM(GENE0002.fn_mask_conta(rw_busca_conta.nrdconta));
           ELSE
              -- Verifica se o associado possui mais de uma conta
              LOOP
                 EXIT WHEN cr_busca_conta%NOTFOUND;

                 -- Monta lista de contas do associado
                 vr_lstconta := TRIM(GENE0002.fn_mask_conta(rw_busca_conta.nrdconta))||','||vr_lstconta;

                 FETCH cr_busca_conta INTO rw_busca_conta;
              END LOOP;

              vr_qtd_conta := rw_busca_conta.qtdContas + 1;
              vr_lstconta := 'TODAS'||','||vr_lstconta;

          END IF;

        CLOSE cr_busca_conta;

        -- Verifica se a conta e igual a ZERO - Todas as opcoes de contas
        IF TO_NUMBER(TRIM(REPLACE(REPLACE(rw_craprea.nrdconta,'.',''),'TODAS',0))) <> 0 THEN

           -- Busca o numero do contrato do associado
           OPEN cr_contrato(rw_craprea.cdcooper
                           ,rw_craprea.nrcpfcgc
                           ,TRIM(REPLACE(REPLACE(rw_craprea.nrdconta,'.',''),'TODAS',0)));
           FETCH cr_contrato INTO rw_contrato;
              -- Nao encontrou contratos
              IF cr_contrato%NOTFOUND THEN
                 -- Fecha cursor
                 CLOSE cr_contrato;
                 -- Gera critica
                 pr_des_erro := 'Associado sem restricoes no sistema CYBER.';
                 RAISE vr_excerror;
              END IF;

              -- Verifica a quantidade de contratos relacionados a conta
              OPEN cr_qtd_restricao(rw_craprea.cdcooper
                                   ,rw_craprea.nrcpfcgc
                                   ,TRIM(REPLACE(REPLACE(rw_craprea.nrdconta,'.',''),'TODAS',0)));
              FETCH cr_qtd_restricao INTO vr_qtd_restricao;
              CLOSE cr_qtd_restricao;

              -- Se o nro CPF/CNPJ possui uma conta associada
              IF NVL(vr_qtd_restricao,0) = 1 THEN
                 -- Grava a conta do associado
                 vr_contrato := rw_contrato.nrctremp;
              ELSE
                  -- Verifica se o associado possui mais de uma conta
                  LOOP
                     EXIT WHEN cr_contrato%NOTFOUND;

                     -- Monta lista de contas do associado
                     vr_contrato := rw_contrato.nrctremp||','||vr_contrato;

                     FETCH cr_contrato INTO rw_contrato;
                  END LOOP;

                  vr_qtd_restricao := vr_qtd_restricao + 1;
                  vr_contrato := 'TODOS'||','||vr_contrato;

              END IF;

           CLOSE cr_contrato;
        ELSE
           -- Exibe a palavra TODOS
           vr_contrato := 'TODOS';
           vr_qtd_restricao := 1;
        END IF;

        -- Inicializa o index
        vr_index := 1;
        -- Gravando registros
        vr_tab_dados(vr_index)('indrowid') := rw_craprea.rowid;
        vr_tab_dados(vr_index)('nrcpfcgc') := gene0002.fn_mask_cpf_cnpj(rw_craprea.nrcpfcgc,rw_craprea.inpessoa);
        vr_tab_dados(vr_index)('nmprimtl') := rw_craprea.nmprimtl;
        vr_tab_dados(vr_index)('nrdconta') := rw_craprea.nrdconta;
        vr_tab_dados(vr_index)('nrctremp') := rw_craprea.nrctremp;
     CLOSE cr_craprea;

     -- Geração de TAG's
     gene0007.pc_gera_tag('indrowid',vr_tab_tags);
     gene0007.pc_gera_tag('flenvarq',vr_tab_tags);
     gene0007.pc_gera_tag('dtmvtolt',vr_tab_tags);
     gene0007.pc_gera_tag('cdoperad',vr_tab_tags);
     gene0007.pc_gera_tag('nrcpfcgc',vr_tab_tags);
     gene0007.pc_gera_tag('nmprimtl',vr_tab_tags);
     gene0007.pc_gera_tag('nrdconta',vr_tab_tags);
     gene0007.pc_gera_tag('nrctremp',vr_tab_tags);

     -- Nome do Primeiro Titular
     pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                        ,'/Root'
                                        ,XMLTYPE('<Dados nmprimtl="'|| rw_busca_conta.nmprimtl ||'" nrdconta="'|| TRIM(rw_craprea.nrdconta) ||'" nrctremp="'|| rw_craprea.nrctremp ||'" nrcpfcgc="'||rw_craprea.nrcpfcgc||'" lstconta="'||vr_lstconta||'" qtcontas="'|| vr_qtd_conta ||'" lstcontrato="'||vr_contrato||'" qtd="'||vr_qtd_restricao||'" ></Dados>'));

     -- Forma XML de retorno para casos de sucesso (listar dados)
     gene0007.pc_gera_xml(pr_tab_dados => vr_tab_dados
                         ,pr_tab_tag   => vr_tab_tags
                         ,pr_XMLType   => pr_retxml
                         ,pr_path_tag  => '/Root/Dados'
                         ,pr_tag_no    => 'retorno'
                         ,pr_des_erro  => pr_des_erro);

  EXCEPTION
     WHEN vr_excerror THEN
        pr_dscritic := pr_des_erro;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>Rotina com erros</Dados></Root>');
     WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
        CECRED.pc_internal_exception; 
        
        pr_des_erro := 'Erro geral na rotina pc_retorna_reafor: '||SQLERRM;
        pr_dscritic := 'Erro geral na rotina pc_retorna_reafor: '||SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>Rotina com erros</Dados></Root>');
  END pc_retorna_reafor;


  PROCEDURE pc_lista_dados_logrbc(pr_idtpreme IN VARCHAR2              --> Tipo de Remessa
                                 ,pr_dtmvtolt IN VARCHAR2              --> Data do Movimento
                                 ,pr_idpenden IN VARCHAR2              --> Filtro de Registros Pendentes
                                 ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                 ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                 ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro OUT VARCHAR2) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_lista_dados_logrbc
  --  Sistema  : Procedimento de busca os dados das remessas no periodo de data informado em tela
  --  Sigla    : CRED
  --  Autor    : Andre Santos - SUPERO
  --  Data     : Junho/2014.                   Ultima atualizacao: 07/10/2015
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Busca os dados das remessas no periodo de data informado em tela
  --
  -- Alteracoes:  07/10/2015 - Alteracao na mascara do campo dtmvtolt. (Jaison/Marcos-Supero)
  --
  ---------------------------------------------------------------------------------------------------------------
  -- Cursores

  -- Buscar as informações da cooperativa
  CURSOR cr_crapcop(p_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT crapcop.cdbcoctl
         , crapcop.cdagectl
         , crapcop.nmrescop
      FROM crapcop
     WHERE crapcop.cdcooper = p_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  -- Busca os registros da remessa
  CURSOR cr_remessa(p_dtmvtolt IN DATE
                   ,p_idtpreme IN VARCHAR2) IS
     SELECT crb.ROWID
           ,TO_CHAR(crb.dtmvtolt,'DD/MM/RRRR HH24:MI:SS') dthrcons
           ,TO_CHAR(crb.dtmvtolt,DECODE(pbc.idtpsoli,'A','DD/MM/RRRR','DD/MM/RRRR HH24:MI:SS')) dtmvtolt
           ,crb.idtpreme
           ,crb.dtcancel
           ,pbc.flgativo
           ,NVL(pbc.idopreto,'S') idopreto
       FROM crapcrb crb
           ,crappbc pbc
      WHERE crb.idtpreme = pbc.idtpreme
        AND crb.idtpreme = DECODE(p_idtpreme,'TODOS',crb.idtpreme,p_idtpreme)
        AND (   (p_dtmvtolt IS NULL)
             OR (p_dtmvtolt IS NOT NULL AND TRUNC(crb.dtmvtolt) = p_dtmvtolt) )
      ORDER BY crb.dtmvtolt DESC
              ,crb.idtpreme;

  -- Variaveis
  vr_excerror EXCEPTION;

  vr_dtmvtolt    DATE;
  vr_cdcooper    NUMBER;
  vr_nmdatela    VARCHAR2(25);
  vr_nmeacao     VARCHAR2(25);
  vr_cdagenci    VARCHAR2(25);
  vr_nrdcaixa    VARCHAR2(25);
  vr_idorigem    VARCHAR2(25);
  vr_cdoperad    VARCHAR2(500);

  vr_index PLS_INTEGER;

  vr_dssitpre VARCHAR2(5);
  vr_dssitenv VARCHAR2(5);
  vr_dssitret VARCHAR2(5);
  vr_dssitdev VARCHAR2(5);

  -- Variavel Tabela Temporaria
  vr_tab_dados   gene0007.typ_mult_array;       --> PL Table para armazenar dados para formar o XML
  vr_tab_tags    gene0007.typ_tab_tagxml;       --> PL Table para armazenar TAG´s do XML

  BEGIN
	  -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
  	GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_lista_dados_logrbc');
      
     -- Extrair informações padrão do xml - parametros
     gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                             ,pr_cdcooper => vr_cdcooper
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nmeacao  => vr_nmeacao
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_idorigem => vr_idorigem
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dscritic => pr_dscritic);

     -- Converte a STRING data para DATE
     vr_dtmvtolt := TO_DATE(pr_dtmvtolt,'DD/MM/RRRR');

     -- Inicializa Variavel
     vr_dssitpre := NULL;
     vr_dssitenv := NULL;
     vr_dssitret := NULL;
     vr_dssitdev := NULL;

     -- Criar cabeçalho do XML
     pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

     -- Buscar dados da cooperativa
     OPEN  cr_crapcop(vr_cdcooper);
     FETCH cr_crapcop INTO rw_crapcop;
        -- Se não encontrar dados
        IF cr_crapcop%NOTFOUND THEN
           -- Fecha o cursor
           CLOSE cr_crapcop;
           pr_des_erro := 'Cooperativa nao encontrada. VR_CDCOOPER = '||vr_cdcooper;
           RAISE vr_excerror;
        END IF;
     -- Fecha o cursor
     CLOSE cr_crapcop;

     -- Busca os dados da remessa
     FOR rw_remessa IN cr_remessa(vr_dtmvtolt
                                 ,pr_idtpreme) LOOP

        -- Inicializa Variavel Para Pesquisa
        vr_dssitpre := NULL;
        vr_dssitenv := NULL;
        vr_dssitret := NULL;
        vr_dssitdev := NULL;

        pc_lst_estagio_bureaux(rw_remessa.idtpreme
                              ,TO_DATE(rw_remessa.dthrcons,'DD/MM/RRRR HH24:MI:SS')
                              ,vr_dssitpre
                              ,vr_dssitenv
                              ,vr_dssitret
                              ,vr_dssitdev);

        -- Se nao precisar filtrar, busca todos os registros
        IF pr_idpenden = 0 THEN

           -- Captura último indice da PL Table
           vr_index := nvl(vr_tab_dados.count, 0) + 1;
           -- Gravando registros
           vr_tab_dados(vr_index)('indrowid') := rw_remessa.rowid;
           vr_tab_dados(vr_index)('dtmvtolt') := rw_remessa.dtmvtolt;
           vr_tab_dados(vr_index)('idtpreme') := rw_remessa.idtpreme;

           IF rw_remessa.dtcancel IS NOT NULL THEN
              vr_tab_dados(vr_index)('dtcancel') := 'Cancelada' ;
           ELSIF rw_remessa.flgativo = 0 THEN
              vr_tab_dados(vr_index)('dtcancel') := 'Bureaux Inativo' ;
           ELSE
              vr_tab_dados(vr_index)('dtcancel') := '' ;
           END IF;

           vr_tab_dados(vr_index)('dssitpre') := vr_dssitpre;
           vr_tab_dados(vr_index)('dssitenv') := vr_dssitenv;
           vr_tab_dados(vr_index)('dssitret') := vr_dssitret;
           vr_tab_dados(vr_index)('dssitdev') := vr_dssitdev;

        ELSE -- Filtra somente os registros pendentes

           -- Captura último indice da PL Table
           vr_index := nvl(vr_tab_dados.count, 0) + 1;

           -- Se a remessa for sem arquivo de retorno, exibir os registros
           IF rw_remessa.idopreto = 'S' AND rw_remessa.dtcancel IS NULL THEN

              -- Verifica se estao pendentes e que nao estao canceladas
              IF (NVL(vr_dssitpre,'PE') = 'PE' OR NVL(vr_dssitpre,'PA') = 'PA'   OR
                  NVL(vr_dssitenv,'PE') = 'PE' OR NVL(vr_dssitenv,'PA') = 'PA') AND
                  rw_remessa.dtcancel IS NULL THEN

                  -- Gravando registros
                  vr_tab_dados(vr_index)('indrowid') := rw_remessa.rowid;
                  vr_tab_dados(vr_index)('dtmvtolt') := rw_remessa.dtmvtolt;
                  vr_tab_dados(vr_index)('idtpreme') := rw_remessa.idtpreme;

                  IF rw_remessa.dtcancel IS NOT NULL THEN
                     vr_tab_dados(vr_index)('dtcancel') := 'Cancelada' ;
                  ELSIF rw_remessa.flgativo = 0 THEN
                     vr_tab_dados(vr_index)('dtcancel') := 'Bureaux Inativo' ;
                  ELSE
                     vr_tab_dados(vr_index)('dtcancel') := '' ;
                  END IF;

                  vr_tab_dados(vr_index)('dssitpre') := vr_dssitpre;
                  vr_tab_dados(vr_index)('dssitenv') := vr_dssitenv;
                  vr_tab_dados(vr_index)('dssitret') := vr_dssitret;
                  vr_tab_dados(vr_index)('dssitdev') := vr_dssitdev;

              END IF;

           ELSE -- Se for qualquer outra remessa com retorno

              -- Verifica se estao pendentes e que nao estao canceladas
              IF (NVL(vr_dssitpre,'PE') = 'PE' OR NVL(vr_dssitpre,'PA') = 'PA'   OR
                  NVL(vr_dssitenv,'PE') = 'PE' OR NVL(vr_dssitenv,'PA') = 'PA'   OR
                  NVL(vr_dssitret,'PE') = 'PE' OR NVL(vr_dssitret,'PA') = 'PA'   OR
                  NVL(vr_dssitdev,'PE') = 'PE' OR NVL(vr_dssitdev,'PA') = 'PA') AND
                  rw_remessa.dtcancel IS NULL THEN

                 -- Gravando registros
                 vr_tab_dados(vr_index)('indrowid') := rw_remessa.rowid;
                 vr_tab_dados(vr_index)('dtmvtolt') := rw_remessa.dtmvtolt;
                 vr_tab_dados(vr_index)('idtpreme') := rw_remessa.idtpreme;

                 IF rw_remessa.flgativo = 0 THEN
                    vr_tab_dados(vr_index)('dtcancel') := 'Bureaux Inativo' ;
                 ELSE
                    vr_tab_dados(vr_index)('dtcancel') := '' ;
                 END IF;

                 vr_tab_dados(vr_index)('dssitpre') := vr_dssitpre;
                 vr_tab_dados(vr_index)('dssitenv') := vr_dssitenv;
                 vr_tab_dados(vr_index)('dssitret') := vr_dssitret;
                 vr_tab_dados(vr_index)('dssitdev') := vr_dssitdev;

              END IF;

           END IF;

        END IF;

     END LOOP;

     -- Geração de TAG's
     gene0007.pc_gera_tag('indrowid',vr_tab_tags);
     gene0007.pc_gera_tag('dtmvtolt',vr_tab_tags);
     gene0007.pc_gera_tag('idtpreme',vr_tab_tags);
     gene0007.pc_gera_tag('dtcancel',vr_tab_tags);
     gene0007.pc_gera_tag('dssitpre',vr_tab_tags);
     gene0007.pc_gera_tag('dssitenv',vr_tab_tags);
     gene0007.pc_gera_tag('dssitret',vr_tab_tags);
     gene0007.pc_gera_tag('dssitdev',vr_tab_tags);

     -- Forma XML de retorno para casos de sucesso (listar dados)
     gene0007.pc_gera_xml(pr_tab_dados => vr_tab_dados
                         ,pr_tab_tag   => vr_tab_tags
                         ,pr_XMLType   => pr_retxml
                         ,pr_path_tag  => '/Root'
                         ,pr_tag_no    => 'retorno'
                         ,pr_des_erro  => pr_des_erro);

  EXCEPTION
     WHEN vr_excerror THEN
        pr_dscritic := pr_des_erro;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>Rotina com erros</Dados></Root>');
     WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
        CECRED.pc_internal_exception; 
        
        pr_des_erro := 'Erro geral na rotina pc_lista_dados_logrbc: '||SQLERRM;
        pr_dscritic := 'Erro geral na rotina pc_lista_dados_logrbc: '||SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>Rotina com erros</Dados></Root>');
  END pc_lista_dados_logrbc;


  PROCEDURE pc_lista_eventos_logrcb(pr_rowid    IN VARCHAR2              --> ID dos eventos de remessas
                                   ,pr_nmarquiv IN VARCHAR2              --> Nome do arquivo de remessa
                                   ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro OUT VARCHAR2) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_lista_eventos_logrcb
  --  Sistema  : Procedimento de busca os detalhes dos dados da remessa selecionado em tela
  --  Sigla    : CRED
  --  Autor    : Andre Santos - SUPERO
  --  Data     : Novembro/2014.                   Ultima atualizacao: 07/10/2015
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Busca os detalhes dos dados da remessa selecionado em tela
  --
  -- Alteracoes: 07/10/2015 - Alteracao na mascara do campo dtmvtolt. (Jaison/Marcos-Supero)
  --
  ---------------------------------------------------------------------------------------------------------------
  -- Cursores

  -- Buscar as informações da cooperativa
  CURSOR cr_crapcop(p_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT crapcop.cdbcoctl
         , crapcop.cdagectl
         , crapcop.nmrescop
      FROM crapcop
     WHERE crapcop.cdcooper = p_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  -- Busca as informacoes da remessa
  CURSOR cr_remessa(p_rowid IN VARCHAR2) IS
     SELECT crb.idtpreme                       idtpreme
           ,crb.dtmvtolt                       dtmvtolt
           ,NVL(pbc.idopreto,'S')              idopreto
           ,TO_CHAR(crb.dtmvtolt,DECODE(pbc.idtpsoli,'A','DD/MM/RRRR','DD/MM/RRRR HH24:MI:SS')) dtformat
       FROM crapcrb crb
           ,crappbc pbc
      WHERE crb.ROWID    = p_rowid
        AND crb.idtpreme = pbc.idtpreme;
  rw_remessa cr_remessa%ROWTYPE;

  -- Busca todos os arquivos de origem da remessa
  CURSOR cr_arquivos(p_idtpreme crapcrb.idtpreme%TYPE
                    ,p_dtmvtolt crapcrb.dtmvtolt%TYPE) IS
     SELECT arb.idtpreme
           ,arb.dtmvtolt
           ,arb.nmarquiv
           ,arb.nrseqarq
       FROM craparb arb
      WHERE arb.idtpreme = p_idtpreme
        AND arb.dtmvtolt = p_dtmvtolt
        AND arb.cdestarq = 3
        ORDER BY arb.nmarquiv DESC; -- Somente os arquivos de envio de remessas(origem)
  rw_arquivos cr_arquivos%ROWTYPE;

  -- Busca a quantidade de arquivos de origem da remessa
  CURSOR cr_qtd_arquivos(p_idtpreme crapcrb.idtpreme%TYPE
                        ,p_dtmvtolt crapcrb.dtmvtolt%TYPE) IS
     SELECT COUNT(*) qtd_arquivos
       FROM craparb arb
      WHERE arb.idtpreme = p_idtpreme
        AND arb.dtmvtolt = p_dtmvtolt
        AND arb.cdestarq = 3; -- Somente os arquivos de envio de remessas(origem)
  vr_qtd NUMBER(10);

  -- Busca os arquivos de origem da remessa passado como parametro
  CURSOR cr_arq_remessa(p_idtpreme crapcrb.idtpreme%TYPE
                       ,p_dtmvtolt crapcrb.dtmvtolt%TYPE
                       ,p_nmarquiv craparb.nmarquiv%TYPE) IS
     SELECT arb.nmarquiv
           ,arb.nrseqarq
           ,arb.nrseqant
       FROM craparb arb
      WHERE arb.idtpreme = p_idtpreme
        AND arb.dtmvtolt = p_dtmvtolt
        AND UPPER(arb.nmarquiv) = UPPER(p_nmarquiv);
  rw_arq_remessa cr_arq_remessa%ROWTYPE;

  -- Busca os arquivos de origem da remessa
  CURSOR cr_seq_arquivo(p_idtpreme crapcrb.idtpreme%TYPE
                       ,p_dtmvtolt crapcrb.dtmvtolt%TYPE
                       ,p_nrseqarq craparb.nrseqarq%TYPE) IS
     SELECT arb.nmarquiv
       FROM craparb arb
      WHERE arb.idtpreme = p_idtpreme
        AND arb.dtmvtolt = p_dtmvtolt
        AND arb.nrseqarq = p_nrseqarq;
  rw_seq_arquivo cr_seq_arquivo%ROWTYPE;

  -- Busca todos os eventos da remessa informada
  CURSOR cr_eventos(p_idtpreme IN VARCHAR2
                   ,p_dtmvtolt IN DATE
                   ,p_nrseqarq IN NUMBER
                   ,p_nmarquiv IN VARCHAR2) IS
     SELECT erb.idtpreme
           ,erb.dtmvtolt
           ,TO_CHAR(erb.dtexeeve,'DD/MM HH24:MI:SS')              dtprceve
           ,INITCAP(CYBE0002.fn_des_evento_remessa(erb.cdesteve)) dsesteve
           ,erb.dslogeve                                          dslogeve
           ,erb.nrseqarq                                          nrseqarq
       FROM craperb erb
      WHERE erb.idtpreme = p_idtpreme
        AND erb.dtmvtolt = p_dtmvtolt
        AND (   (UPPER(p_nmarquiv) = 'TODOS')
             OR (UPPER(p_nmarquiv) <> 'TODOS' AND erb.nrseqarq IN (p_nrseqarq,(SELECT arb.nrseqarq
                                                                          FROM craparb arb
                                                                         WHERE arb.nrseqant = p_nrseqarq
                                                                           AND arb.idtpreme = erb.idtpreme
                                                                           AND arb.dtmvtolt = erb.dtmvtolt))
                )
            )
      ORDER BY erb.nrseqeve;
      rw_eventos cr_eventos%ROWTYPE;

  -- Variaveis
  vr_excerror EXCEPTION;

  vr_cdcooper    NUMBER;
  vr_nmdatela    VARCHAR2(25);
  vr_nmeacao     VARCHAR2(25);
  vr_cdagenci    VARCHAR2(25);
  vr_nrdcaixa    VARCHAR2(25);
  vr_idorigem    VARCHAR2(25);
  vr_cdoperad    VARCHAR2(500);

  vr_index       PLS_INTEGER;

  vr_qtd_arquivos NUMBER(10);
  vr_lsarquiv    VARCHAR2(32767):= '';
  vr_lsespaco    VARCHAR2(32767):= '';
  vr_nmarquiv    craparb.nmarquiv%TYPE;

  vr_dssitenv VARCHAR2(5);
  vr_dssitret VARCHAR2(5);
  vr_dssitdev VARCHAR2(5);

  -- Variavel Tabela Temporaria
  vr_tab_dados   gene0007.typ_mult_array;       --> PL Table para armazenar dados para formar o XML
  vr_tab_tags    gene0007.typ_tab_tagxml;       --> PL Table para armazenar TAG´s do XML

  BEGIN
	  -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
  	GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_lista_eventos_logrcb');      

     -- Extrair informações padrão do xml - parametros
     gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                             ,pr_cdcooper => vr_cdcooper
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nmeacao  => vr_nmeacao
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_idorigem => vr_idorigem
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dscritic => pr_dscritic);

     -- Criar cabeçalho do XML
     pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

     -- Buscar dados da cooperativa
     OPEN  cr_crapcop(vr_cdcooper);
     FETCH cr_crapcop INTO rw_crapcop;
        -- Se não encontrar dados
        IF cr_crapcop%NOTFOUND THEN
           -- Fecha o cursor
           CLOSE cr_crapcop;
           pr_des_erro := 'Cooperativa nao encontrada. VR_CDCOOPER = '||vr_cdcooper;
           RAISE vr_excerror;
        END IF;
     -- Fecha o cursor
     CLOSE cr_crapcop;

     -- Busca as informacoes da remessa
     OPEN cr_remessa(pr_rowid);
     FETCH cr_remessa INTO rw_remessa;
     CLOSE cr_remessa;

     -- Se o nome do arquivo esta NULL, monta a lista dos arquivos de remessa
     IF pr_nmarquiv IS NULL THEN

        -- Se Remessa for Multi-Arquivos
        IF rw_remessa.idopreto = 'M' THEN

           -- Busca os arquivos da remessa quando existir
           OPEN cr_arquivos(rw_remessa.idtpreme
                           ,rw_remessa.dtmvtolt);
           FETCH cr_arquivos INTO rw_arquivos;

              -- Busca a quantidade de arquivos da remessa quando existir
              OPEN cr_qtd_arquivos(rw_remessa.idtpreme
                                  ,rw_remessa.dtmvtolt);
              FETCH cr_qtd_arquivos INTO vr_qtd;
              CLOSE cr_qtd_arquivos;

              IF vr_qtd = 1 THEN
                 -- Busca os estagios da remessa
                 pc_lst_estagio_remessa(rw_arquivos.idtpreme
                                       ,rw_arquivos.dtmvtolt
                                       ,rw_arquivos.nrseqarq
                                       ,vr_dssitenv
                                       ,vr_dssitret
                                       ,vr_dssitdev);

                 -- lista de arquivos de remessa
                 vr_lsarquiv := rw_arquivos.nmarquiv;
                 vr_qtd_arquivos := vr_qtd;

              ELSIF vr_qtd > 1 THEN -- Se existe varios arquivos, monta uma lista
                 -- Busca todos os arquivo e monta uma lista
                 LOOP
                    EXIT WHEN cr_arquivos%NOTFOUND;

                    -- Busca os estagios da remessa
                    pc_lst_estagio_remessa(rw_arquivos.idtpreme
                                          ,rw_arquivos.dtmvtolt
                                          ,rw_arquivos.nrseqarq
                                          ,vr_dssitenv
                                          ,vr_dssitret
                                          ,vr_dssitdev);

                    -- Seta o nome do arquivo truncando
                    vr_nmarquiv := SUBSTR(rw_arquivos.nmarquiv,1,34);

                    -- Monta a quantidade de espacos necessario
                    vr_lsespaco := '';
                    FOR vr_index IN 1..(35 - LENGTH(vr_nmarquiv)) LOOP
                      vr_lsespaco := vr_lsespaco || 'nbsp';
                    END LOOP;

                    -- Concatena a lista de arquivos com os eventos ocorridos
                    vr_lsarquiv := vr_nmarquiv || vr_lsespaco || 'nbspnbsp' ||
                                   RPAD('|'||vr_dssitenv||'|',24,'nbsp')||
                                   RPAD('|'||vr_dssitret||'|',28,'nbsp')||
                                   '|'||vr_dssitdev||'| ' || ',' || vr_lsarquiv;

                    FETCH cr_arquivos INTO rw_arquivos;
                 END LOOP;

                 vr_lsarquiv := 'TODOS'||','||vr_lsarquiv;
                 vr_qtd_arquivos := vr_qtd+1;

              END IF;

           CLOSE cr_arquivos;
        END IF;

     END IF;

     -- Se houve enivio de parametro de nome de arquivo
     IF NVL(pr_nmarquiv,'TODOS') <> 'TODOS' THEN

        OPEN cr_arq_remessa(rw_remessa.idtpreme
                           ,rw_remessa.dtmvtolt
                           ,pr_nmarquiv);
        FETCH cr_arq_remessa INTO rw_arq_remessa;
        CLOSE cr_arq_remessa;

     END IF;

     -- Busca todos os eventos da remessa informada
     FOR rw_eventos IN cr_eventos(rw_remessa.idtpreme
                                 ,rw_remessa.dtmvtolt
                                 ,NVL(rw_arq_remessa.nrseqarq,0)
                                 ,NVL(pr_nmarquiv,'TODOS')) LOOP

         -- Captura último indice da PL Table
         vr_index := nvl(vr_tab_dados.count, 0) + 1;

         -- Se Remessa for Multi-Arquivos
         IF rw_remessa.idopreto = 'M' THEN
            -- Busca o nome do arquivo
            OPEN cr_seq_arquivo(rw_eventos.idtpreme
                               ,rw_eventos.dtmvtolt
                               ,rw_eventos.nrseqarq);
            -- Inicializa a variavel rowtype
            rw_seq_arquivo:=NULL;
            FETCH cr_seq_arquivo INTO rw_seq_arquivo;
            CLOSE cr_seq_arquivo;

            -- Grava o nome do arquivo
            vr_tab_dados(vr_index)('nmarquiv') := NVL(rw_seq_arquivo.nmarquiv,' ');
         END IF;

         -- Gravando registros
         vr_tab_dados(vr_index)('dtprceve') := rw_eventos.dtprceve;
         vr_tab_dados(vr_index)('dsesteve') := rw_eventos.dsesteve;
         vr_tab_dados(vr_index)('dslogeve') := GENE0007.fn_acento_xml(rw_eventos.dslogeve);

     END LOOP;

     -- Geração de TAG's
     gene0007.pc_gera_tag('dtprceve',vr_tab_tags);
     gene0007.pc_gera_tag('dsesteve',vr_tab_tags);
     gene0007.pc_gera_tag('dslogeve',vr_tab_tags);

     -- Se Remessa for Multi-Arquivos
     IF rw_remessa.idopreto = 'M' THEN
        -- Gera a tag com o nome dos arquivos
        gene0007.pc_gera_tag('nmarquiv',vr_tab_tags);
     END IF;

     -- Retorna o Tipo de Remessa, data remessa, os arquivos da remessa(quando existir), e o rowid da tabela CRAPCRB
     pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                        ,'/Root'
                                        ,XMLTYPE('<Dados idtpreme="'||rw_remessa.idtpreme||'" dtmvtolt="'||rw_remessa.dtformat||'" qtarquiv="'||TO_CHAR(vr_qtd_arquivos)||'" lsarquiv="'||vr_lsarquiv||'" idopreto="'||rw_remessa.idopreto||'" rowid="'||pr_rowid||'" ></Dados>'));

     -- Forma XML de retorno para casos de sucesso (listar dados)
     gene0007.pc_gera_xml(pr_tab_dados => vr_tab_dados
                         ,pr_tab_tag   => vr_tab_tags
                         ,pr_XMLType   => pr_retxml
                         ,pr_path_tag  => '/Root/Dados'
                         ,pr_tag_no    => 'retorno'
                         ,pr_des_erro  => pr_des_erro);
  EXCEPTION
     WHEN vr_excerror THEN
        pr_dscritic := pr_des_erro;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>Rotina com erros</Dados></Root>');
     WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
        CECRED.pc_internal_exception; 
        
        pr_des_erro := 'Erro geral na rotina pc_lista_eventos_logrcb: '||SQLERRM;
        pr_dscritic := 'Erro geral na rotina pc_lista_eventos_logrcb: '||SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>Rotina com erros</Dados></Root>');
  END pc_lista_eventos_logrcb;


  PROCEDURE pc_solic_cancel_remes_logrbc(pr_rowid    IN VARCHAR2
                                        ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                        ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                        ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                        ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                        ,pr_des_erro OUT VARCHAR2) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_solic_cancel_remes_logrbc
  --  Sistema  : Procedimento de solicitacao de cancelamento de remessa
  --  Sigla    : CRED
  --  Autor    : Andre Santos - SUPERO
  --  Data     : Novembro/2014.                   Ultima atualizacao: 07/10/2015
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Solicitacao de cancelamento de remessa
  --
  -- Alteracoes: 07/10/2015 - Alteracao na mascara do campo dtmvtolt. (Jaison/Marcos-Supero)
  --
  ---------------------------------------------------------------------------------------------------------------
  -- Cursores

  -- Buscar as informações da cooperativa
  CURSOR cr_crapcop(p_cdcooper crapcop.cdcooper%TYPE) IS
     SELECT crapcop.cdbcoctl
          , crapcop.cdagectl
          , crapcop.nmrescop
       FROM crapcop
      WHERE crapcop.cdcooper = p_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  -- Busca a remessa informada no parametro
  CURSOR cr_remessa(p_rowid IN VARCHAR2) IS
     SELECT crb.idtpreme
           ,crb.dtmvtolt
           ,nvl(pbc.idopreto,'S') idopreto
           ,TO_CHAR(crb.dtmvtolt,DECODE(pbc.idtpsoli,'A','DD/MM/RRRR','DD/MM/RRRR HH24:MI:SS')) dtformat
       FROM crapcrb crb
           ,crappbc pbc
      WHERE crb.ROWID    = p_rowid
        AND crb.idtpreme = pbc.idtpreme;
  rw_remessa cr_remessa%ROWTYPE;

  -- Busca todos os arquivos de origem da remessa
  CURSOR cr_arquivos(p_idtpreme crapcrb.idtpreme%TYPE
                    ,p_dtmvtolt crapcrb.dtmvtolt%TYPE) IS
     SELECT arb.idtpreme
           ,arb.dtmvtolt
           ,arb.nmarquiv
           ,arb.nrseqarq
       FROM craparb arb
      WHERE arb.idtpreme = p_idtpreme
        AND arb.dtmvtolt = p_dtmvtolt
        AND arb.dtcancel IS NULL
        AND arb.cdestarq = 3; -- Somente os arquivos de envio de remessas(origem)
  rw_arquivos cr_arquivos%ROWTYPE;

  -- Busca a quantidade de arquivos de origem da remessa
  CURSOR cr_qtd_arquivos(p_idtpreme crapcrb.idtpreme%TYPE
                        ,p_dtmvtolt crapcrb.dtmvtolt%TYPE) IS
     SELECT COUNT(*) qtd_arquivos
       FROM craparb arb
      WHERE arb.idtpreme = p_idtpreme
        AND arb.dtmvtolt = p_dtmvtolt
        AND arb.dtcancel IS NULL
        AND arb.cdestarq = 3; -- Somente os arquivos de envio de remessas(origem)
  vr_qtd NUMBER(10);

  -- Variaveis
  vr_excerror EXCEPTION;

  vr_qtd_arquivos NUMBER(10);
  vr_lsarquiv    VARCHAR2(32767):= '';

  vr_dssitenv VARCHAR2(5);
  vr_dssitret VARCHAR2(5);
  vr_dssitdev VARCHAR2(5);

  vr_cdcooper    NUMBER;
  vr_nmdatela    VARCHAR2(25);
  vr_nmeacao     VARCHAR2(25);
  vr_cdagenci    VARCHAR2(25);
  vr_nrdcaixa    VARCHAR2(25);
  vr_idorigem    VARCHAR2(25);
  vr_cdoperad    VARCHAR2(500);

  BEGIN
	  -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
  	GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_solic_cancel_remes_logrbc');      

     -- Extrair informações padrão do xml - parametros
     gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                             ,pr_cdcooper => vr_cdcooper
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nmeacao  => vr_nmeacao
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_idorigem => vr_idorigem
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dscritic => pr_dscritic);

     -- Criar cabeçalho do XML
     pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

     -- Buscar dados da cooperativa
     OPEN  cr_crapcop(vr_cdcooper);
     FETCH cr_crapcop INTO rw_crapcop;
        -- Se não encontrar dados
        IF cr_crapcop%NOTFOUND THEN
           -- Fecha o cursor
           CLOSE cr_crapcop;
           pr_des_erro := 'Cooperativa nao encontrada. VR_CDCOOPER = '||vr_cdcooper;
           RAISE vr_excerror;
        END IF;
     -- Fecha o cursor
     CLOSE cr_crapcop;

     OPEN cr_remessa(pr_rowid);
     FETCH cr_remessa INTO rw_remessa;
     CLOSE cr_remessa;

     -- Verifica se a remessa ja foi cancelada ou retornada
     IF fn_remessa_encerrada(rw_remessa.idtpreme
                            ,rw_remessa.dtmvtolt)='S' THEN
        pr_des_erro := 'A remessa ja foi RETORNADA ou CANCELADA!';
        RAISE vr_excerror;
     END IF;

     -- Se Remessa for Multi-Arquivos
     IF rw_remessa.idopreto = 'M' THEN

        -- Busca os arquivos da remessa quando existir
        OPEN cr_arquivos(rw_remessa.idtpreme
                        ,rw_remessa.dtmvtolt);
        FETCH cr_arquivos INTO rw_arquivos;

           -- Busca a quantidade de arquivos da remessa quando existir
           OPEN cr_qtd_arquivos(rw_remessa.idtpreme
                               ,rw_remessa.dtmvtolt);
           FETCH cr_qtd_arquivos INTO vr_qtd;
           CLOSE cr_qtd_arquivos;

           IF vr_qtd = 1 THEN
              -- Busca os estagios da remessa
              pc_lst_estagio_remessa(rw_arquivos.idtpreme
                                    ,rw_arquivos.dtmvtolt
                                    ,rw_arquivos.nrseqarq
                                    ,vr_dssitenv
                                    ,vr_dssitret
                                    ,vr_dssitdev);

              -- lista de arquivos de remessa
              vr_lsarquiv := rw_arquivos.nmarquiv||' nbsp nbsp nbsp nbsp nbsp nbsp '
                                                 ||RPAD('|'||vr_dssitenv||'|',40,' nbsp ')
                                                 ||RPAD('|'||vr_dssitret||'|',40,' nbsp ')
                                                 ||'|'||vr_dssitdev||'| ';
              vr_qtd_arquivos := vr_qtd;

           ELSIF vr_qtd > 1 THEN -- Se existe varios arquivos, monta uma lista

              -- Inicializa Variavel
              vr_qtd := 1;

              -- Busca todos os arquivo e monta uma lista
              LOOP
                 EXIT WHEN cr_arquivos%NOTFOUND;

                 -- Busca os estagios da remessa
                 pc_lst_estagio_remessa(rw_arquivos.idtpreme
                                       ,rw_arquivos.dtmvtolt
                                       ,rw_arquivos.nrseqarq
                                       ,vr_dssitenv
                                       ,vr_dssitret
                                       ,vr_dssitdev);

                 IF vr_dssitenv = 'PE' OR vr_dssitret = 'PE' OR vr_dssitdev = 'PE' THEN
                    -- Concatena a lista de arquivos com os eventos ocorridos
                    vr_lsarquiv := rw_arquivos.nmarquiv||' nbsp nbsp nbsp nbsp nbsp nbsp '
                                                       ||RPAD('|'||vr_dssitenv||'|',40,' nbsp ')
                                                       ||RPAD('|'||vr_dssitret||'|',40,' nbsp ')
                                                       ||'|'||vr_dssitdev||'| '
                                                       ||','
                                                       ||vr_lsarquiv;

                    vr_qtd := vr_qtd+1; -- Soma os registros pendentes
                 END IF;

                 FETCH cr_arquivos INTO rw_arquivos;
              END LOOP;

              vr_lsarquiv := 'TODOS'||','||vr_lsarquiv;
              vr_qtd_arquivos := vr_qtd;

           END IF;

        CLOSE cr_arquivos;
     END IF;

     -- Retorna o Tipo de Remessa, data remessa, os arquivos da remessa(quando existir), e o rowid da tabela CRAPCRB
     pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                        ,'/Root'
                                        ,XMLTYPE('<Dados idtpreme="'||rw_remessa.idtpreme||'" dtmvtolt="'||rw_remessa.dtformat||'" qtarquiv="'||TO_CHAR(vr_qtd_arquivos)||'" lsarquiv="'||vr_lsarquiv||'" idopreto="'||rw_remessa.idopreto||'" rowid="'||pr_rowid||'" ></Dados>'));

  EXCEPTION
     WHEN vr_excerror THEN
        pr_dscritic := pr_des_erro;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>Rotina com erros</Dados></Root>');
     WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
        CECRED.pc_internal_exception; 
        
        pr_des_erro := 'Erro geral na rotina pc_solic_cancel_remes_logrbc: '||SQLERRM;
        pr_dscritic := 'Erro geral na rotina pc_solic_cancel_remes_logrbc: '||SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>Rotina com erros</Dados></Root>');
  END pc_solic_cancel_remes_logrbc;


  PROCEDURE pc_cancel_remessa_logrbc(pr_rowid    IN VARCHAR2
                                    ,pr_dsmotcan IN VARCHAR2
                                    ,pr_nmarqcan IN VARCHAR2
                                    ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                    ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                    ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                    ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                    ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                    ,pr_des_erro OUT VARCHAR2) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_cancel_remessa_logrbc
  --  Sistema  : Procedimento de cancelamento de remessa
  --  Sigla    : CRED
  --  Autor    : Andre Santos - SUPERO
  --  Data     : Novembro/2014.                   Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Efetuar o cancelamento de remessa
  -- Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------
  -- Cursores

  -- Buscar as informações da cooperativa
  CURSOR cr_crapcop(p_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT crapcop.cdbcoctl
         , crapcop.cdagectl
         , crapcop.nmrescop
      FROM crapcop
     WHERE crapcop.cdcooper = p_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  -- Busca a remessa informada no parametro
  CURSOR cr_remessa(p_rowid IN VARCHAR2) IS
     SELECT crb.idtpreme
           ,crb.dtmvtolt
           ,nvl(pbc.idopreto,'S') idopreto
       FROM crapcrb crb
           ,crappbc pbc
      WHERE crb.ROWID = p_rowid
        AND crb.idtpreme = pbc.idtpreme;
  rw_remessa cr_remessa%ROWTYPE;

  -- Busca a remessa para verificar se esta cancelada
  CURSOR cr_remessa_cancel(p_idtpreme IN VARCHAR2
                          ,p_dtmvtolt IN DATE
                          ,p_nmarquiv IN VARCHAR2) IS
     SELECT arb.dtcancel
           ,arb.nrseqarq
       FROM craparb arb
      WHERE arb.idtpreme = p_idtpreme
        AND arb.dtmvtolt = p_dtmvtolt
        AND arb.nmarquiv = p_nmarquiv;
  rw_remessa_cancel cr_remessa_cancel%ROWTYPE;

  -- Busca a remessa para verificar se foi retornada
  CURSOR cr_remessa_retorn(p_idtpreme IN VARCHAR2
                          ,p_dtmvtolt IN DATE
                          ,p_nrseqarq IN VARCHAR2) IS
     SELECT 1
       FROM craparb arb
      WHERE arb.idtpreme = p_idtpreme
        AND arb.dtmvtolt = p_dtmvtolt
        AND arb.cdestarq = 4 -- Retorno
        AND arb.nrseqant = p_nrseqarq;
  rw_remessa_retorn cr_remessa_retorn%ROWTYPE;

  -- Variaveis
  vr_dscritic VARCHAR2(4000 ) := '';
  vr_excerror EXCEPTION;
  vr_exc_upd  EXCEPTION;

  vr_cdcooper    NUMBER;
  vr_nmdatela    VARCHAR2(25);
  vr_nmeacao     VARCHAR2(25);
  vr_cdagenci    VARCHAR2(25);
  vr_nrdcaixa    VARCHAR2(25);
  vr_idorigem    VARCHAR2(25);
  vr_cdoperad    VARCHAR2(25);

  vr_dscancel    VARCHAR(4000);
  vr_dsmotcan    VARCHAR(4000);


  BEGIN
	  -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
  	GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_cancel_remessa_logrbc');      

     -- Inicia Variavel
     vr_dscancel := '';
     vr_dsmotcan := '';

     -- Extrair informações padrão do xml - parametros
     gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                             ,pr_cdcooper => vr_cdcooper
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nmeacao  => vr_nmeacao
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_idorigem => vr_idorigem
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dscritic => pr_dscritic);

     -- Criar cabeçalho do XML
     pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

     -- Buscar dados da cooperativa
     OPEN  cr_crapcop(vr_cdcooper);
     FETCH cr_crapcop INTO rw_crapcop;
        -- Se não encontrar dados
        IF cr_crapcop%NOTFOUND THEN
           -- Fecha o cursor
           CLOSE cr_crapcop;
           pr_des_erro := 'Cooperativa não encontrada. VR_CDCOOPER = '||vr_cdcooper;
           RAISE vr_excerror;
        END IF;
     -- Fecha o cursor
     CLOSE cr_crapcop;

     -- Verifica novamente se a remessa esta cancelada ou concluida
     OPEN cr_remessa(pr_rowid);
     FETCH cr_remessa INTO rw_remessa;
     CLOSE cr_remessa;

     -- Verifica se a remessa ja foi cancelada ou retornada
     IF fn_remessa_encerrada(rw_remessa.idtpreme
                            ,rw_remessa.dtmvtolt)='S' THEN
        pr_des_erro := 'A remessa ja foi RETORNADA ou CANCELADA!';
        RAISE vr_excerror;
     END IF;

     /* Removendo o tratamento de caracteres especiais da variavel DSMOTCAN
     para evitar erro de requisicao */
     vr_dscancel := TRIM(REPLACE(REPLACE(pr_dsmotcan,'<![CDATA['),']]>'));

     -- Verificacao do motivo do cancelamento
     IF LENGTH(vr_dscancel) < 20 THEN
        pr_des_erro := 'Descricao do motivo insuficiente ou vazia!';
        RAISE vr_excerror;
     END IF;

     -- Verifica se o registro eh multi-arquivo
     IF rw_remessa.idopreto = 'M' AND NVL(pr_nmarqcan,'TODOS') <> 'TODOS' THEN

        -- Busca a remessa para verificar se esta cancelada
        OPEN cr_remessa_cancel(rw_remessa.idtpreme
                              ,rw_remessa.dtmvtolt
                              ,pr_nmarqcan);
        FETCH cr_remessa_cancel INTO rw_remessa_cancel;
           -- Verifica se o arquivo esta cancelado
           IF rw_remessa_cancel.dtcancel IS NOT NULL THEN
              -- Fecha o cursor
              CLOSE cr_remessa_cancel;
              pr_des_erro := 'A remessa deste arquivo ja foi CANCELADA!';
              RAISE vr_excerror;
           END IF;
        CLOSE cr_remessa_cancel;

        -- Busca a remessa para verificar se foi retornada
        OPEN cr_remessa_retorn(rw_remessa.idtpreme
                              ,rw_remessa.dtmvtolt
                              ,rw_remessa_cancel.nrseqarq);
        FETCH cr_remessa_retorn INTO rw_remessa_retorn;
           /* Se encontrou registro, o mesmo ja foi retornado e
           nao pode ser cancelado */
           IF cr_remessa_retorn%FOUND THEN
              -- Fecha o cursor
              CLOSE cr_remessa_retorn;
              pr_des_erro := 'A remessa deste arquivo ja foi RETORNADA!';
              RAISE vr_excerror;
           END IF;
        CLOSE cr_remessa_retorn;

        -- Atualiza o arquivo especificado
        BEGIN
           UPDATE craparb arb
              SET arb.dtcancel = SYSDATE     --> DATA CORRENTE
                 ,arb.cdopecan = vr_cdoperad --> OPERADOR
                 ,arb.dsmotcan = vr_dscancel --> MOTIVO DO CANCELAMENTO
            WHERE arb.idtpreme = rw_remessa.idtpreme
              AND arb.dtmvtolt = rw_remessa.dtmvtolt
              AND arb.nrseqarq = rw_remessa_cancel.nrseqarq;

           --Se nao atualizou registro
           IF SQL%ROWCOUNT = 0 THEN
              pr_cdcritic:= 0;
              pr_dscritic:= 'Erro Sistema - Nenhum registro atualizado na tabela CRAPARB.';
              RAISE vr_exc_upd;
           END IF;

        EXCEPTION
          WHEN vr_exc_upd THEN
             RAISE vr_excerror;
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
            CECRED.pc_internal_exception; 
             pr_des_erro := 'Nao foi possivel efetuar o cancelamento. Erro: '||SQLERRM;
             RAISE vr_excerror;
        END;

        -- Motivo do cancelamento
        vr_dsmotcan := 'Remessa Cancelada por '||vr_cdoperad||'. Motivo: '||vr_dscancel;

        -- Inserindo o cancelamento
        pc_insere_evento_remessa(pr_idtpreme => rw_remessa.idtpreme        --> Remessa
                                ,pr_dtmvtolt => rw_remessa.dtmvtolt        --> Data da Remessa
                                ,pr_nrseqarq => rw_remessa_cancel.nrseqarq --> Sequencia do arquivo
                                ,pr_cdesteve => 9 -- Fixo                  --> Cancelado
                                ,pr_flerreve => 1 -- Sucesso               --> Flag
                                ,pr_dslogeve => vr_dsmotcan                --> Motivo Log Evento
                                ,pr_dscritic => vr_dscritic);              --> Descrisao da Critica

	      -- Retorno do módulo e ação logado - Chamado 719114 - 21/07/2017
  	    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_cancel_remessa_logrbc');  	                                
        -- Se houve erro
        IF vr_dscritic IS NOT NULL THEN
           pr_des_erro := 'Erro na rotina PC_INSERE_EVENTO_REMESSA. Erro: '||vr_dscritic;
           RAISE vr_excerror;
        END IF;

     ELSE -- Se a remessa for unica ou foi selecionado todos os arquivos de uma remessa mult-arquivos

        -- Atualizando a remessa para CANCELADA
        BEGIN
           UPDATE crapcrb crb
              SET crb.dtcancel = SYSDATE     --> DATA CORRENTE
                 ,crb.cdopecan = vr_cdoperad --> OPERADOR
                 ,crb.dsmotcan = vr_dscancel --> MOTIVO DO CANCELAMENTO
            WHERE ROWID = pr_rowid; -- ROWID DA SELECIONADO NA TELA

            --Se nao atualizou registro
            IF SQL%ROWCOUNT = 0 THEN
               pr_cdcritic:= 0;
               pr_dscritic:= 'Erro Sistema - Nenhum registro atualizado na tabela CRAPCRB.';
               RAISE vr_exc_upd;
            END IF;

        EXCEPTION
           WHEN vr_exc_upd THEN
              RAISE vr_excerror;
           WHEN OTHERS THEN
             -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
             CECRED.pc_internal_exception; 
              pr_des_erro := 'Nao foi possivel efetuar o cancelamento na tabela CRAPCRB. Erro: '||SQLERRM;
              RAISE vr_excerror;
        END;

        -- Motivo do cancelamento
        vr_dsmotcan := 'Remessa Cancelada por '||vr_cdoperad||'. Motivo: '||vr_dscancel;

        -- Inserindo o cancelamento
        pc_insere_evento_remessa(pr_idtpreme => rw_remessa.idtpreme        --> Remessa
                                ,pr_dtmvtolt => rw_remessa.dtmvtolt        --> Data da Remessa
                                ,pr_cdesteve => 9 -- Fixo                  --> Cancelado
                                ,pr_flerreve => 1 -- Sucesso               --> Flag
                                ,pr_dslogeve => vr_dsmotcan                --> Motivo Log Evento
                                ,pr_dscritic => vr_dscritic);              --> Descrisao da Critica
	      -- Retorno do módulo e ação logado - Chamado 719114 - 21/07/2017
  	    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_cancel_remessa_logrbc');  
        -- Se houve erro
        IF vr_dscritic IS NOT NULL THEN
           pr_des_erro := 'Erro na rotina PC_INSERE_EVENTO_REMESSA. Erro: '||vr_dscritic;
           RAISE vr_excerror;
        END IF;

     END IF;

     -- Commit
     COMMIT;

  EXCEPTION
     WHEN vr_excerror THEN
        -- Desfaz as alteracoes
        ROLLBACK;
        pr_dscritic := pr_des_erro;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>Rotina com erros</Dados></Root>');
     WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
        CECRED.pc_internal_exception; 
        
        ROLLBACK;
        pr_des_erro := 'Erro geral na rotina pc_cancel_remessa_logrbc: '||SQLERRM;
        pr_dscritic := 'Erro geral na rotina pc_cancel_remessa_logrbc: '||SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>Rotina com erros</Dados></Root>');
  END pc_cancel_remessa_logrbc;


  -- Procedimento que busca os dados de parametros de sistema para exibir na tela
  PROCEDURE pc_dados_gerais_prmrbc(pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                  ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro  OUT VARCHAR2)IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_dados_gerais_prmrbc
  --  Sistema  : Procedimento que busca os dados de parametros de sistema para exibir na tela
  --  Sigla    : CRED
  --  Autor    : Andre Santos - SUPERO
  --  Data     : Novembro/2014.                   Ultima atualizacao: 07/10/2015
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Busca os dados de parametros de sistema para exibir na tela
  --
  -- Alteracoes: 07/10/2015 - Remocao do campo hrinterv. (Jaison/Marcos-Supero)
  --
  ---------------------------------------------------------------------------------------------------------------
  -- Cursores

  -- Buscar as informações da cooperativa
  CURSOR cr_crapcop(p_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT crapcop.cdbcoctl
         , crapcop.cdagectl
         , crapcop.nmrescop
      FROM crapcop
     WHERE crapcop.cdcooper = p_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  -- Busca os parametros de sistema
  CURSOR cr_param IS
     SELECT GENE0001.fn_param_sistema('CRED',0,'AUTBUR_HORA_ENVIO')      hrdenvio
           ,GENE0001.fn_param_sistema('CRED',0,'AUTBUR_HORA_RETOR')      hrdreton
           ,GENE0001.fn_param_sistema('CRED',0,'AUTBUR_HORA_ENCER')      hrdencer
           ,GENE0001.fn_param_sistema('CRED',0,'AUTBUR_HORA_ENCER_MAX')  hrdencmx
           ,GENE0001.fn_param_sistema('CRED',0,'AUTBUR_EMAIL_ALERT')     desemail
           ,GENE0001.fn_param_sistema('CRED',0,'AUTBUR_DIR_TEMP')        dsdirarq
     FROM DUAL;
  rw_param cr_param%ROWTYPE;

  -- Variaveis
  vr_excerror EXCEPTION;

  vr_cdcooper    NUMBER;
  vr_nmdatela    VARCHAR2(25);
  vr_nmeacao     VARCHAR2(25);
  vr_cdagenci    VARCHAR2(25);
  vr_nrdcaixa    VARCHAR2(25);
  vr_idorigem    VARCHAR2(25);
  vr_cdoperad    VARCHAR2(500);

  BEGIN
	  -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
  	GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_dados_gerais_prmrbc');      

     -- Extrair informações padrão do xml - parametros
     gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                             ,pr_cdcooper => vr_cdcooper
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nmeacao  => vr_nmeacao
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_idorigem => vr_idorigem
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dscritic => pr_dscritic);

     -- Criar cabeçalho do XML
     pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

     -- Buscar dados da cooperativa
     OPEN  cr_crapcop(vr_cdcooper);
     FETCH cr_crapcop INTO rw_crapcop;
        -- Se não encontrar dados
        IF cr_crapcop%NOTFOUND THEN
           -- Fecha cursor
           CLOSE cr_crapcop;
           pr_des_erro := 'Cooperativa nao encontrada. VR_CDCOOPER = '||vr_cdcooper;
           RAISE vr_excerror;
        END IF;
     CLOSE cr_crapcop;

     -- Busca os parametros de sistema
     OPEN cr_param;
     FETCH cr_param INTO rw_param;
     CLOSE cr_param;

     -- Envia ao php os parametros como atributos da tag
     pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                          ,'/Root'
                                          ,XMLTYPE('<Dados hrdenvio="'||rw_param.hrdenvio||'" hrdreton="'||rw_param.hrdreton||'" hrdencer="'||rw_param.hrdencer||'" hrdencmx="'||rw_param.hrdencmx||'" desemail="'||rw_param.desemail||'" dsdirarq="'||rw_param.dsdirarq||'" ></Dados>'));

  EXCEPTION
     WHEN vr_excerror THEN
        pr_dscritic := pr_des_erro;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>Rotina com erros</Dados></Root>');
     WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
        CECRED.pc_internal_exception;
        
        pr_des_erro := 'Erro geral na rotina pc_dados_gerais_prmrbc: '||SQLERRM;
        pr_dscritic := 'Erro geral na rotina pc_dados_gerais_prmrbc: '||SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>Rotina com erros</Dados></Root>');
  END pc_dados_gerais_prmrbc;


  -- Procedimento que busca os dados de parametros de sistema para exibir na tela
  PROCEDURE pc_dados_bureaux_prmrbc(pr_idtpreme  IN VARCHAR2              --> Tipo de Remessa
                                   ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro  OUT VARCHAR2)IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_dados_bureaux_prmrbc
  --  Sistema  : Procedimento que busca os dados de parametros de sistema para exibir na tela
  --  Sigla    : CRED
  --  Autor    : Andre Santos - SUPERO
  --  Data     : Novembro/2014.                   Ultima atualizacao: 23/03/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Busca os dados de parametros de sistema para exibir na tela
  --
  -- Alteracoes: 07/10/2015 - Inclusao dos campos hrinterv e idtpsoli. (Jaison/Marcos-Supero)
  --             
  --             23/03/2016 - Inclusão do campo idenvseg conforme solicitado no 
  --                          chamado 412682. (Kelvin)
  ---------------------------------------------------------------------------------------------------------------
  -- Cursores

  -- Buscar as informações da cooperativa
  CURSOR cr_crapcop(p_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT crapcop.cdbcoctl
         , crapcop.cdagectl
         , crapcop.nmrescop
      FROM crapcop
     WHERE crapcop.cdcooper = p_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  -- Busca os parametros de sistema
  CURSOR cr_bureaux(p_idtpreme IN VARCHAR2) IS
     SELECT idtpreme
           ,idtpenvi
           ,dsdirenv
           ,dssitftp
           ,dsusrftp
           ,dspwdftp
           ,dsdreftp
           ,dsdrencd
           ,dsdrevcd
           ,idopreto
           ,qthorret
           ,dsdrrftp
           ,dsdrrecd
           ,dsdrrtcd
           ,dsdirret
           ,dsfnrnen
           ,dsfnburt
           ,dsfnrndv
           ,flgativo
           ,flremseq
           ,dsfnchrm
           ,dsfnburm
           ,dsfnchrt
           ,idtpsoli
           ,qtinterr
           ,idenvseg
       FROM crappbc pbc
      WHERE UPPER(pbc.idtpreme) = UPPER(p_idtpreme);
  rw_bureaux cr_bureaux%ROWTYPE;

   -- Variaveis
  vr_excerror EXCEPTION;

  vr_cdcooper    NUMBER;
  vr_nmdatela    VARCHAR2(25);
  vr_nmeacao     VARCHAR2(25);
  vr_cdagenci    VARCHAR2(25);
  vr_nrdcaixa    VARCHAR2(25);
  vr_idorigem    VARCHAR2(25);
  vr_cdoperad    VARCHAR2(500);

  BEGIN
	  -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
  	GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_dados_bureaux_prmrbc');      

     -- Extrair informações padrão do xml - parametros
     gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                             ,pr_cdcooper => vr_cdcooper
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nmeacao  => vr_nmeacao
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_idorigem => vr_idorigem
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dscritic => pr_dscritic);

     -- Criar cabeçalho do XML
     pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

     -- Buscar dados da cooperativa
     OPEN  cr_crapcop(vr_cdcooper);
     FETCH cr_crapcop INTO rw_crapcop;
        -- Se não encontrar dados
        IF cr_crapcop%NOTFOUND THEN
           -- Fecha cursor
           CLOSE cr_crapcop;
           pr_des_erro := 'Cooperativa nao encontrada. VR_CDCOOPER = '||vr_cdcooper;
           RAISE vr_excerror;
        END IF;
     CLOSE cr_crapcop;

     -- Busca os parametros de sistema
     OPEN cr_bureaux(pr_idtpreme);
     FETCH cr_bureaux INTO rw_bureaux;
     CLOSE cr_bureaux;

     -- Envia ao php os parametros como atributos da tag
     pr_retxml := XMLTYPE.appendChildXML(pr_retxml
                                          ,'/Root'
                                          ,XMLTYPE('<Dados idtpreme="'||rw_bureaux.idtpreme||'" idtpenvi="'||rw_bureaux.idtpenvi||'" dsdirenv="'||rw_bureaux.dsdirenv||'" dssitftp="'||rw_bureaux.dssitftp||'" dsusrftp="'||rw_bureaux.dsusrftp||'" dspwdftp="'||rw_bureaux.dspwdftp||'" dsdreftp="'||rw_bureaux.dsdreftp||'" dsdrencd="'||rw_bureaux.dsdrencd||'" dsdrevcd="'||rw_bureaux.dsdrevcd||'" idopreto="'||rw_bureaux.idopreto||'" qthorret="'||rw_bureaux.qthorret||'" dsdrrftp="'||rw_bureaux.dsdrrftp||'" dsdrrecd="'||rw_bureaux.dsdrrecd||'" dsdrrtcd="'||rw_bureaux.dsdrrtcd||'" dsdirret="'||rw_bureaux.dsdirret||'" dsfnrnen="'||rw_bureaux.dsfnrnen||'" dsfnburt="'||rw_bureaux.dsfnburt||'" dsfnrndv="'||rw_bureaux.dsfnrndv||'" flgativo="'||rw_bureaux.flgativo||'" flremseq="'||rw_bureaux.flremseq||'" dsfnchrm="'||rw_bureaux.dsfnchrm||'" dsfnburm="'||rw_bureaux.dsfnburm||'" dsfnchrt="'||rw_bureaux.dsfnchrt||'" idtpsoli="'||rw_bureaux.idtpsoli||'" hrinterv="'||rw_bureaux.qtinterr||'" idenvseg="'||rw_bureaux.idenvseg ||'"></Dados>'));

  EXCEPTION
     WHEN vr_excerror THEN
        pr_dscritic := pr_des_erro;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>Rotina com erros</Dados></Root>');
     WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
        CECRED.pc_internal_exception;
        
        pr_des_erro := 'Erro geral na rotina pc_dados_bureaux_prmrbc: '||SQLERRM;
        pr_dscritic := 'Erro geral na rotina pc_dados_bureaux_prmrbc: '||SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>Rotina com erros</Dados></Root>');
  END pc_dados_bureaux_prmrbc;


  -- Procedimento de gravacao de parametros de sistema
  PROCEDURE pc_grava_gerais_prmrbc(pr_hrdenvio  IN VARCHAR2
                                  ,pr_hrdreton  IN VARCHAR2
                                  ,pr_hrdencer  IN VARCHAR2
                                  ,pr_hrdencmx  IN VARCHAR2
                                  ,pr_dsdirarq  IN VARCHAR2
                                  ,pr_desemail  IN VARCHAR2
                                  ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                  ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                  ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                  ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro  OUT VARCHAR2) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_grava_gerais_prmrbc
  --  Sistema  : Procedimento de gravacao de parametros de sistema
  --  Sigla    : CRED
  --  Autor    : Andre Santos - SUPERO
  --  Data     : Novembro/2014.                   Ultima atualizacao: 07/10/2015
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Efetuar a gravacao de parametros de sistema
  -- Alteracoes: 06/04/2015 - Incremento na quantidade máxima de horas para rechecagem de retorno
  --                          de 4 para 6 horas (Marcos-Supero)
  --
  --             07/10/2015 - Remocao do campo hrinterv. (Jaison/Marcos-Supero)
  --
  ---------------------------------------------------------------------------------------------------------------
  -- Cursores

  -- Buscar as informações da cooperativa
  CURSOR cr_crapcop(p_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT crapcop.cdbcoctl
         , crapcop.cdagectl
         , crapcop.nmrescop
      FROM crapcop
     WHERE crapcop.cdcooper = p_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  -- Variaveis
  vr_excerror EXCEPTION;

  vr_cdcooper    NUMBER;
  vr_nmdatela    VARCHAR2(25);
  vr_nmeacao     VARCHAR2(25);
  vr_cdagenci    VARCHAR2(25);
  vr_nrdcaixa    VARCHAR2(25);
  vr_idorigem    VARCHAR2(25);
  vr_cdoperad    VARCHAR2(500);

  vr_hrdenvio    VARCHAR2(25);

     PROCEDURE pc_valida_horario(pr_horario IN VARCHAR2
                                ,pr_dscriti OUT VARCHAR2) IS
     /*******************************************************
     Objetivo: Procedure interna com o objetivo de validar
     os campos de horas

     Parametros: pr_horario --> Campo de Hora a ser validado
                 pr_dscriti --> Retorno da critica

     *******************************************************/

     BEGIN
        -- Inicializa Variavel
        pr_dscriti:=NULL;
        -- Verifica se o parametro esta null
        IF pr_horario IS NULL THEN
           pr_dscriti := 'Horario Invalido! Favor informar o horario no formato [HH:MM].';
        END IF;
        -- Verifica se o horario esta correto
        IF LENGTH(pr_horario) <> 5 OR SUBSTR(pr_horario,3,1) <> ':' THEN
           pr_dscriti := 'Horario Invalido! Favor informar o horario no formato [HH:MM].';
        END IF;
        -- Valida se o campo esta no formato numerico
        DECLARE
          vr_validahr    NUMBER(5);
        BEGIN
           vr_validahr := TO_NUMBER(REPLACE(pr_horario,':',''));
        EXCEPTION
           WHEN OTHERS THEN
              -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
              CECRED.pc_internal_exception;
              
              pr_dscriti := 'Horario Invalido! Favor informar o horario no formato [HH:MM].';
        END;
        -- Validacao eh um horario valido
        BEGIN
           vr_hrdenvio:= TO_CHAR(TO_DATE(pr_horario,'HH24:MI'),'HH24:MI');
        EXCEPTION
           WHEN OTHERS THEN
              -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
              CECRED.pc_internal_exception; 
              pr_dscriti := 'Horario Invalido! Favor informar o horario no formato [HH:MM].';
        END;
     END;

  BEGIN
	  -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
  	GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_grava_gerais_prmrbc');      

     -- Extrair informações padrão do xml - parametros
     gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                             ,pr_cdcooper => vr_cdcooper
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nmeacao  => vr_nmeacao
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_idorigem => vr_idorigem
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dscritic => pr_dscritic);

     -- Criar cabeçalho do XML
     pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

     -- Buscar dados da cooperativa
     OPEN  cr_crapcop(vr_cdcooper);
     FETCH cr_crapcop INTO rw_crapcop;
        -- Se não encontrar dados
        IF cr_crapcop%NOTFOUND THEN
           -- Fecha o cursor
           CLOSE cr_crapcop;
           pr_des_erro := 'Cooperativa nao encontrada. VR_CDCOOPER = '||vr_cdcooper;
           RAISE vr_excerror;
        END IF;
     -- Fecha o cursor
     CLOSE cr_crapcop;

     -- Verificando os parametros obrigatorios
     IF pr_hrdenvio IS NULL OR
        pr_hrdreton IS NULL OR
        pr_hrdencer IS NULL OR
        pr_hrdencmx IS NULL OR
        pr_dsdirarq IS NULL THEN
        -- Retorna critica
        pr_des_erro := 'Horarios de Envio, Retorno, Encerramento ou Diretorio Temporario sao campos obrigatorios!';
        RAISE vr_excerror;
     END IF;

     -- Verifica se o parametro esta null
     pc_valida_horario(pr_hrdenvio
                      ,pr_des_erro);
     IF pr_des_erro IS NOT NULL THEN
        RAISE vr_excerror;
     END IF;

     -- Verifica se o parametro esta null
     pc_valida_horario(pr_hrdreton
                      ,pr_des_erro);
     IF pr_des_erro IS NOT NULL THEN
        RAISE vr_excerror;
     END IF;

     -- Verifica se o parametro esta null
     pc_valida_horario(pr_hrdencer
                      ,pr_des_erro);
     IF pr_des_erro IS NOT NULL THEN
        RAISE vr_excerror;
     END IF;

     -- Verifica se o parametro esta null
     pc_valida_horario(pr_hrdencmx
                      ,pr_des_erro);
     IF pr_des_erro IS NOT NULL THEN
        RAISE vr_excerror;
     END IF;

     -- Validacao de horario
     IF TO_CHAR(TO_DATE(pr_hrdencer,'HH24:MI'),'HH24:MI') >= TO_CHAR(TO_DATE(pr_hrdencmx,'HH24:MI'),'HH24:MI') THEN
        pr_des_erro := 'Horario inicial nao pode ser superior ao horario final de devolucao!';
        RAISE vr_excerror;
     END IF;

     -- Atualiza a hora de envio - Parametros de Sistema
     BEGIN
        UPDATE crapprm prm
           SET prm.dsvlrprm = pr_hrdenvio
         WHERE prm.nmsistem = 'CRED'
           AND prm.cdcooper = 0
           AND prm.cdacesso = 'AUTBUR_HORA_ENVIO';

     EXCEPTION
        WHEN OTHERS THEN
           -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
           CECRED.pc_internal_exception; 
           pr_des_erro := 'Nao foi possivel atualizar o horario de envio! Erro: '||SQLERRM;
           RAISE vr_excerror;
     END;

     -- Atualiza a hora de retorno - Parametros de Sistema
     BEGIN
        UPDATE crapprm prm
           SET prm.dsvlrprm = pr_hrdreton
         WHERE prm.nmsistem = 'CRED'
           AND prm.cdcooper = 0
           AND prm.cdacesso = 'AUTBUR_HORA_RETOR';

     EXCEPTION
        WHEN OTHERS THEN
           -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
           CECRED.pc_internal_exception; 
           pr_des_erro := 'Nao foi possivel atualizar o horario de retorno! Erro: '||SQLERRM;
           RAISE vr_excerror;
     END;

     -- Atualiza a hora de encerramento - Parametros de Sistema
     BEGIN
        UPDATE crapprm prm
           SET prm.dsvlrprm = pr_hrdencer
         WHERE prm.nmsistem = 'CRED'
           AND prm.cdcooper = 0
           AND prm.cdacesso = 'AUTBUR_HORA_ENCER';

     EXCEPTION
        WHEN OTHERS THEN
           -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
           CECRED.pc_internal_exception; 
           pr_des_erro := 'Nao foi possivel atualizar o horario de encerramento! Erro: '||SQLERRM;
           RAISE vr_excerror;
     END;

     -- Atualiza a hora de encerramento - Parametros de Sistema
     BEGIN
        UPDATE crapprm prm
           SET prm.dsvlrprm = pr_hrdencmx
         WHERE prm.nmsistem = 'CRED'
           AND prm.cdcooper = 0
           AND prm.cdacesso = 'AUTBUR_HORA_ENCER_MAX';

     EXCEPTION
        WHEN OTHERS THEN
           -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
           CECRED.pc_internal_exception; 
           pr_des_erro := 'Nao foi possivel atualizar o horario de encerramento! Erro: '||SQLERRM;
           RAISE vr_excerror;
     END;

     -- Atualiza o e-mail de alerta ao usuario - Parametros de Sistema
     BEGIN
        UPDATE crapprm prm
           SET prm.dsvlrprm = pr_desemail
         WHERE prm.nmsistem = 'CRED'
           AND prm.cdcooper = 0
           AND prm.cdacesso = 'AUTBUR_EMAIL_ALERT';

     EXCEPTION
        WHEN OTHERS THEN
           -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
           CECRED.pc_internal_exception; 
           pr_des_erro := 'Nao foi possivel atualizar a lista de e-mail! Erro: '||SQLERRM;
           RAISE vr_excerror;
     END;

     -- Atualiza o diretorio temporario com os arquivos - Parametros de Sistema
     BEGIN
        UPDATE crapprm prm
           SET prm.dsvlrprm = pr_dsdirarq
         WHERE prm.nmsistem = 'CRED'
           AND prm.cdcooper = 0
           AND prm.cdacesso = 'AUTBUR_DIR_TEMP';

     EXCEPTION
        WHEN OTHERS THEN
           -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
           CECRED.pc_internal_exception; 
           pr_des_erro := 'Nao foi possivel atualizar o diretorio temporario! Erro: '||SQLERRM;
           RAISE vr_excerror;
     END;

     -- Finaliza a Operacao
     COMMIT;

  EXCEPTION
     WHEN vr_excerror THEN
        -- Desfaz as Alteracao
        ROLLBACK;
        pr_dscritic := pr_des_erro;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>Rotina com erros</Dados></Root>');
     WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
        CECRED.pc_internal_exception; 
        
        -- Desfaz as Alteracao
        ROLLBACK;

        pr_des_erro := 'Erro geral na rotina pc_grava_gerais_prmrbc: '||SQLERRM;
        pr_dscritic := 'Erro geral na rotina pc_grava_gerais_prmrbc: '||SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>Rotina com erros</Dados></Root>');
  END pc_grava_gerais_prmrbc;


  -- Procedimento de gravacao de parametros de sistema
  PROCEDURE pc_grava_bureaux_prmrbc(pr_lstpreme  IN VARCHAR2
                                   ,pr_idtpreme  IN VARCHAR2
                                   ,pr_flgativo  IN VARCHAR2
                                   ,pr_idenvseg  IN VARCHAR2
                                   ,pr_flremseq  IN VARCHAR2
                                   ,pr_idtpsoli  IN VARCHAR2
                                   ,pr_dsfnchrm  IN VARCHAR2
                                   ,pr_idtpenvi  IN VARCHAR2
                                   ,pr_dsdirenv  IN VARCHAR2
                                   ,pr_dsfnburm  IN VARCHAR2
                                   ,pr_dssitftp  IN VARCHAR2
                                   ,pr_dsusrftp  IN VARCHAR2
                                   ,pr_dspwdftp  IN VARCHAR2
                                   ,pr_dsdreftp  IN VARCHAR2
                                   ,pr_dsdrencd  IN VARCHAR2
                                   ,pr_dsdrevcd  IN VARCHAR2
                                   ,pr_dsfnrnen  IN VARCHAR2
                                   ,pr_idopreto  IN VARCHAR2
                                   ,pr_qthorret  IN VARCHAR2
                                   ,pr_hrinterv  IN VARCHAR2
                                   ,pr_dsdrrftp  IN VARCHAR2
                                   ,pr_dsdrrecd  IN VARCHAR2
                                   ,pr_dsdrrtcd  IN VARCHAR2
                                   ,pr_dsdirret  IN VARCHAR2
                                   ,pr_dsfnrndv  IN VARCHAR2
                                   ,pr_dsfnburt  IN VARCHAR2
                                   ,pr_dsfnchrt  IN VARCHAR2
                                   ,pr_xmllog    IN VARCHAR2              --> XML com informações de LOG
                                   ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                   ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                   ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                   ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                   ,pr_des_erro  OUT VARCHAR2) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_grava_bureaux_prmrbc
  --  Sistema  : Procedimento de gravacao de parametros de sistema
  --  Sigla    : CRED
  --  Autor    : Andre Santos - SUPERO
  --  Data     : Novembro/2014.                   Ultima atualizacao: 23/03/2016
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Efetuar a gravacao de parametros de sistema
  --
  -- Alteracoes: 07/10/2015 - Inclusao dos campos hrinterv e idtpsoli. (Jaison/Marcos-Supero)
  --                       
  --             23/03/2016 - Inclusão do campo idenvseg conforme solicitado no 
  --                          chamado 412682. (Kelvin)
  ---------------------------------------------------------------------------------------------------------------
  -- Cursores

  -- Buscar as informações da cooperativa
  CURSOR cr_crapcop(p_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT crapcop.cdbcoctl
         , crapcop.cdagectl
         , crapcop.nmrescop
      FROM crapcop
     WHERE crapcop.cdcooper = p_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  -- Variaveis
  vr_excerror EXCEPTION;

  vr_cdcooper    NUMBER;
  vr_nmdatela    VARCHAR2(25);
  vr_nmeacao     VARCHAR2(25);
  vr_cdagenci    VARCHAR2(25);
  vr_nrdcaixa    VARCHAR2(25);
  vr_idorigem    VARCHAR2(25);
  vr_cdoperad    VARCHAR2(500);

  BEGIN
	  -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
  	GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_grava_bureaux_prmrbc');      

     -- Extrair informações padrão do xml - parametros
     gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                             ,pr_cdcooper => vr_cdcooper
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nmeacao  => vr_nmeacao
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_idorigem => vr_idorigem
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dscritic => pr_dscritic);

     -- Criar cabeçalho do XML
     pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

     -- Buscar dados da cooperativa
     OPEN  cr_crapcop(vr_cdcooper);
     FETCH cr_crapcop INTO rw_crapcop;
        -- Se não encontrar dados
        IF cr_crapcop%NOTFOUND THEN
           -- Fecha o cursor
           CLOSE cr_crapcop;
           pr_des_erro := 'Cooperativa nao encontrada. VR_CDCOOPER = '||vr_cdcooper;
           RAISE vr_excerror;
        END IF;
     -- Fecha o cursor
     CLOSE cr_crapcop;

     -- Verifica se foram informado os campos de Bureaux ou Funcao de chaveamento remessa
     IF pr_idtpreme IS NULL OR pr_dsdirenv IS NULL THEN
        pr_des_erro := 'Nome do Bureaux e pasta Diretorio Arquivos da Remessa sao Obrigatorios!';

        -- Se for registro novo ou vazio
        IF NVL(pr_idtpreme,'NOVO')='NOVO' THEN
           pr_nmdcampo := 'idtpreme';
        ELSE /* Se for alteracao, o campo "idtpreme" estara
             desabilitado e com valor, nesse caso focar no campo "dsdirenv" */
           pr_nmdcampo := 'dsdirenv';
        END IF;

        RAISE vr_excerror;
     END IF;

     -- Quantidade de horas de retorno nao pode ser maior que 24 horas
     IF pr_hrinterv > 24 THEN
        pr_des_erro := 'Quantidade de intervalo de horas nao pode ser superior a 24 horas!';
        -- Focar no campo "hrinterv"
        pr_nmdcampo := 'hrinterv';
        RAISE vr_excerror;
     END IF;

     -- Quantidade de horas de retorno nao pode ser maior que 16
     IF pr_qthorret > 16 THEN
        pr_des_erro := 'Quantidade de horas de retorno nao pode ser superior a 16 horas!';
        -- Focar no campo "qthorret"
        pr_nmdcampo := 'qthorret';
        RAISE vr_excerror;
     END IF;

     -- Se o tipo de Envio for via FTP
     IF pr_idtpenvi = 'F' THEN
        -- Verifica se as informacoes obrigatorias de conexao FTP estao preenchidas
        IF pr_dssitftp IS NULL THEN
           pr_des_erro := 'Informacoes de conexao FTP incompletas, campo site obrigatorio!';
           -- Focar no campo "dssitftp"
           pr_nmdcampo := 'dssitftp';
           RAISE vr_excerror;
        END IF;
        IF pr_dsusrftp IS NULL THEN
           pr_des_erro := 'Informacoes de conexao FTP incompletas, campo usuario obrigatorio!';
           -- Focar no campo "dsusrftp"
           pr_nmdcampo := 'dsusrftp';
           RAISE vr_excerror;
        END IF;
        IF pr_dspwdftp IS NULL THEN
           pr_des_erro := 'Informacoes de conexao FTP incompletas, campo senha obrigatorio!';
           -- Focar no campo "dspwdftp"
           pr_nmdcampo := 'dspwdftp';
           RAISE vr_excerror;
        END IF;
        IF pr_dsdreftp IS NULL THEN
           pr_des_erro := 'Informacoes de conexao FTP incompletas, campo Pasta Envio obrigatorio!';
           -- Focar no campo "dsdreftp"
           pr_nmdcampo := 'dsdreftp';
           RAISE vr_excerror;
        END IF;
     END IF;

     -- Se o tipo de Envio for via ConnectDirect
     IF pr_idtpenvi = 'C' THEN
        -- Verifica se as informacoes obrigatorias de conexao ConnectDirect estao preenchidas
        IF pr_dsdrencd IS NULL THEN
           pr_des_erro := 'Informacoes de conexao ConnectDirect incompletas, campo Pasta Envia obrigatorio!';
           pr_nmdcampo := 'dsdrencd';
           RAISE vr_excerror;
        END IF;
        IF pr_dsdrevcd IS NULL THEN
           pr_des_erro := 'Informacoes de conexao ConnectDirect incompletas, campo Pasta Enviados obrigatorio!';
           pr_nmdcampo := 'dsdrevcd';
           RAISE vr_excerror;
        END IF;
     END IF;

     IF pr_idtpenvi = 'F' AND pr_idopreto <> 'S' AND pr_dsdirret IS NULL THEN
        pr_des_erro := 'Campo Diretorio Devolucao PPWare Obrigatorio!';
        pr_nmdcampo := 'dsdirret';
        RAISE vr_excerror;
     END IF;

     IF pr_idtpenvi = 'F' AND pr_idopreto <> 'S' AND pr_dsdrrftp IS NULL THEN
        pr_des_erro := 'Campo Pasta Retorno Obrigatorio!';
        pr_nmdcampo := 'dsdrrftp';
        RAISE vr_excerror;
     END IF;

     IF pr_idtpenvi = 'C' AND pr_idopreto <> 'S' AND pr_dsdrrecd IS NULL THEN
        pr_des_erro := 'Campo Pasta Recebe Obrigatorio!';
        pr_nmdcampo := 'dsdrrecd';
        RAISE vr_excerror;
     END IF;

     IF pr_idtpenvi = 'C' AND pr_idopreto <> 'S' AND pr_dsdrrtcd IS NULL THEN
        pr_des_erro := 'Campo Pasta Recebidos Obrigatorio!';
        pr_nmdcampo := 'dsdrrtcd';
        RAISE vr_excerror;
     END IF;

     IF pr_idopreto <> 'S' AND pr_dsfnburt IS NULL THEN
        pr_des_erro := 'Campo Funcao Busca Retorno Obrigatorio!';
        pr_nmdcampo := 'dsfnburt';
        RAISE vr_excerror;
     END IF;

     -- Verifica o parametro de atualizacao ou inclusao
     IF pr_lstpreme IS NULL THEN
        pr_des_erro := 'Erro no parametro de atualizacao ou inclusao do registro!';
        RAISE vr_excerror;
     END IF;

     -- Se for um registro novo
     IF pr_lstpreme = 'NOVO' THEN
        -- Grava as informacoes do bureaux
        BEGIN
           INSERT INTO crappbc pbc (pbc.idtpreme
                                   ,pbc.flgativo
                                   ,pbc.idenvseg
                                   ,pbc.flremseq
                                   ,pbc.dsfnchrm
                                   ,pbc.idtpenvi
                                   ,pbc.dsdirenv
                                   ,pbc.dsfnburm
                                   ,pbc.dssitftp
                                   ,pbc.dsusrftp
                                   ,pbc.dspwdftp
                                   ,pbc.dsdreftp
                                   ,pbc.dsdrencd
                                   ,pbc.dsdrevcd
                                   ,pbc.dsfnrnen
                                   ,pbc.idopreto
                                   ,pbc.qthorret
                                   ,pbc.dsdrrftp
                                   ,pbc.dsdrrecd
                                   ,pbc.dsdrrtcd
                                   ,pbc.dsdirret
                                   ,pbc.dsfnrndv
                                   ,pbc.dsfnburt
                                   ,pbc.dsfnchrt
                                   ,pbc.qtinterr
                                   ,pbc.idtpsoli)
                             VALUES(pr_idtpreme
                                   ,pr_flgativo
                                   ,pr_idenvseg
                                   ,pr_flremseq
                                   ,pr_dsfnchrm
                                   ,pr_idtpenvi
                                   ,pr_dsdirenv
                                   ,pr_dsfnburm
                                   ,pr_dssitftp
                                   ,pr_dsusrftp
                                   ,pr_dspwdftp
                                   ,pr_dsdreftp
                                   ,pr_dsdrencd
                                   ,pr_dsdrevcd
                                   ,pr_dsfnrnen
                                   ,pr_idopreto
                                   ,pr_qthorret
                                   ,pr_dsdrrftp
                                   ,pr_dsdrrecd
                                   ,pr_dsdrrtcd
                                   ,pr_dsdirret
                                   ,pr_dsfnrndv
                                   ,pr_dsfnburt
                                   ,pr_dsfnchrt
                                   ,pr_hrinterv
                                   ,pr_idtpsoli);
        EXCEPTION
           WHEN OTHERS THEN
              -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
              CECRED.pc_internal_exception; 
              pr_des_erro := 'Nao foi possivel inserir o registro na tabela CRAPPBC! Erro: '||SQLERRM;
              RAISE vr_excerror;
        END;
     ELSE -- Atualiza o registro
        -- Grava as informacoes do bureaux
        BEGIN
           UPDATE crappbc pbc
              SET pbc.flgativo = pr_flgativo
                 ,pbc.idenvseg = pr_idenvseg
                 ,pbc.flremseq = pr_flremseq
                 ,pbc.dsfnchrm = pr_dsfnchrm
                 ,pbc.idtpenvi = pr_idtpenvi
                 ,pbc.dsdirenv = pr_dsdirenv
                 ,pbc.dsfnburm = pr_dsfnburm
                 ,pbc.dssitftp = pr_dssitftp
                 ,pbc.dsusrftp = pr_dsusrftp
                 ,pbc.dspwdftp = pr_dspwdftp
                 ,pbc.dsdreftp = pr_dsdreftp
                 ,pbc.dsdrencd = pr_dsdrencd
                 ,pbc.dsdrevcd = pr_dsdrevcd
                 ,pbc.dsfnrnen = pr_dsfnrnen
                 ,pbc.idopreto = pr_idopreto
                 ,pbc.qthorret = pr_qthorret
                 ,pbc.dsdrrftp = pr_dsdrrftp
                 ,pbc.dsdrrecd = pr_dsdrrecd
                 ,pbc.dsdrrtcd = pr_dsdrrtcd
                 ,pbc.dsdirret = pr_dsdirret
                 ,pbc.dsfnrndv = pr_dsfnrndv
                 ,pbc.dsfnburt = pr_dsfnburt
                 ,pbc.dsfnchrt = pr_dsfnchrt
                 ,pbc.qtinterr = pr_hrinterv
                 ,pbc.idtpsoli = pr_idtpsoli
            WHERE pbc.idtpreme = pr_idtpreme;
        EXCEPTION
           WHEN OTHERS THEN
              -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
              CECRED.pc_internal_exception; 
              pr_des_erro := 'Nao foi possivel atualizar o registro na tabela CRAPPBC! Erro: '||SQLERRM;
              RAISE vr_excerror;
        END;
     END IF;
     -- Finaliza a Operacao
     COMMIT;

  EXCEPTION
     WHEN vr_excerror THEN
        -- Retorna Erro Tratado
        pr_dscritic := pr_des_erro;
        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>Rotina com erros</Dados></Root>');
     WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
        CECRED.pc_internal_exception; 
        
        pr_des_erro := 'Erro geral na rotina pc_grava_bureaux_prmrbc: '||SQLERRM;
        pr_dscritic := 'Erro geral na rotina pc_grava_bureaux_prmrbc: '||SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Dados>Rotina com erros</Dados></Root>');
  END pc_grava_bureaux_prmrbc;


  -- Centralização da gravação dos Arquivos do Bureaux
  PROCEDURE pc_insere_arquivo_bureaux(pr_idtpreme IN craparb.idtpreme%TYPE  --> Tipo da remessa
                                     ,pr_dtmvtolt IN craparb.dtmvtolt%TYPE  --> Data da remessa
                                     ,pr_cdestarq IN craparb.cdestarq%TYPE  --> Estágio do evento
                                     ,pr_nmdireto IN VARCHAR2               --> Diretório do arquivo
                                     ,pr_nmarquiv IN craparb.nmarquiv%TYPE  --> Nome do arquivo
                                     ,pr_nrseqant IN craparb.nrseqant%TYPE DEFAULT NULL  --> Sequencia do arquivo de origem (Quando Multi-Retornos)
                                     ,pr_flproces IN craparb.flproces%TYPE DEFAULT 0 --> Indicador de arquivo já processado
                                     ,pr_nrseqarq OUT craparb.nrseqarq%TYPE --> Retorno do sequencial do arquivo criado
                                     ,pr_dscritic OUT VARCHAR2) IS          --> Retorno de crítica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_insere_arquivo_bureaux
    --  Sistema  : CYBER
    --  Sigla    : CRED
    --  Autor    : Andre Santos - SUPERO
    --  Data     : Novembro/2014.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Efetuar o inclusao do arquivo ao Bureaux
    -- Alteracoes:
    --
    ---------------------------------------------------------------------------------------------------------------
    DECLARE

      -- Busca a ultima sequencia de eventos
      CURSOR cr_nrseqarq IS
         SELECT NVL(MAX(arb.nrseqarq),0) + 1
           FROM craparb arb
          WHERE arb.idtpreme = pr_idtpreme
            AND arb.dtmvtolt = pr_dtmvtolt;
    BEGIN
  	  -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
    	GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_insere_arquivo_bureaux');      

      -- Busca a ultima sequencia do evento
      OPEN cr_nrseqarq;
      FETCH cr_nrseqarq
       INTO pr_nrseqarq;
      CLOSE cr_nrseqarq;
      -- Inserindo o arquivo da remessa conforme
      -- parâmetros + Data e Sequencia buscadas
      INSERT INTO craparb (idtpreme
                          ,dtmvtolt
                          ,nrseqarq
                          ,nrseqant
                          ,cdestarq
                          ,nmarquiv
                          ,blarquiv
                          ,flproces)
       VALUES(pr_idtpreme
             ,pr_dtmvtolt
             ,pr_nrseqarq
             ,pr_nrseqant
             ,pr_cdestarq
             ,pr_nmarquiv
             ,gene0002.fn_arq_para_blob(pr_caminho => pr_nmdireto, pr_arquivo => pr_nmarquiv)
             ,pr_flproces);
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
        CECRED.pc_internal_exception;
        
        -- Retorna o erro para a procedure chamadora
        pr_dscritic := 'Erro --> rotina CYBE0002.pc_insere_arquivo_bureaux --> '||SQLERRM;
    END;
  END pc_insere_arquivo_bureaux;


  -- Limpeza centralizada de diretório
  PROCEDURE pc_limpeza_diretorio(pr_nmdireto IN VARCHAR2      --> Diretório para limpeza
                                ,pr_dscritic OUT VARCHAR2) IS --> Retorno de crítica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_limpeza_diretorio
    --  Sistema  : CYBER
    --  Sigla    : CRED
    --  Autor    : Andre Santos - SUPERO
    --  Data     : Novembro/2014.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Centralizar a limpeza de diretório, que deve tratar algumas situações
    --             pois para diretórios vazios não se pode passar o comando RM, senão é
    --             retornado erro.
    -- Alteracoes:
    --
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      vr_typ_said VARCHAR2(3);    -- Saída da rotina de chamada ao OS
      vr_dslista  VARCHAR2(4000); -- Lista de arquivos do diretório
      vr_lstarqre gene0002.typ_split; -- Lista de arquivos
    BEGIN
  	  -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
    	GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_limpeza_diretorio');      

      -- Primeiro testamos se o diretório já não está vazio
      gene0001.pc_lista_arquivos(pr_path => pr_nmdireto         --> Dir a limpar
                                ,pr_pesq => NULL                --> Qualquer arquivo
                                ,pr_listarq => vr_dslista       --> Lista encontrada
                                ,pr_des_erro => pr_dscritic);   --> Erro encontrado
      -- Se houve erro já na listagem
      IF pr_dscritic IS NOT NULL THEN
        -- Incrementar a mensagem
        pr_dscritic := 'Erro Ao verificar arquivos do dir para limpeza '||pr_nmdireto||' --> '||pr_dscritic;
        RETURN;
      END IF;
      -- Se houverem arquivos
      IF vr_dslista IS NOT NULL THEN
        -- Separar a lista de arquivos encontradas com função existente
        vr_lstarqre := fn_quebra_string(pr_string => vr_dslista, pr_delimit => ',');
        -- Se não encontrou nenhum arquivo sair
        IF vr_lstarqre.count() = 0 THEN
          RETURN;
        END IF;
        -- Para cada arquivo encontrado no DIR
        FOR vr_idx IN 1..vr_lstarqre.count LOOP
          -- Removeremos os arquivos um a um (Isto se fez necessário
          -- pois durante os testes ocorria erro quando um arquivo
          -- com espaço no começo do nome estava presente no diretório)
          gene0001.pc_OScommand_Shell(pr_des_comando => 'rm "'||pr_nmdireto||'/'||vr_lstarqre(vr_idx)||'"'
                                     ,pr_typ_saida   => vr_typ_said
                                     ,pr_des_saida   => pr_dscritic);
          -- Testar retorno de erro
          IF vr_typ_said = 'ERR' THEN
            -- Incrementar o erro
            pr_dscritic := 'Erro ao limpar dir '||pr_nmdireto||' --> Ao remover arquivo "'||vr_lstarqre(vr_idx)||'"--> '||pr_dscritic;
            RETURN;
          END IF;
        END LOOP;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
        CECRED.pc_internal_exception; 
        -- Retorna o erro para a procedure chamadora
        pr_dscritic := 'Erro --> na rotina CYBE0002.pc_limpeza_diretorio -->  '||SQLERRM;
    END;
  END pc_limpeza_diretorio;


  -- Rotina para solicitar o processo de envio / retorno dos arquivos dos Bureaux
  PROCEDURE pc_solicita_remessa(pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data da solicitação
                               ,pr_idtpreme IN crapcrb.idtpreme%TYPE --> Tipo da remessa
                               ,pr_dscritic OUT VARCHAR2) IS         --> Retorno de crítica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_solicita_remessa
    --  Sistema  : CYBER
    --  Sigla    : CRED
    --  Autor    : Marcos - SUPERO
    --  Data     : Dezembro/2014.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Procedimento que agenda o processo de envio/retorno dos arquivos dos Bureaux.
    --             O agendamento ocorre através da criação dos registros na CRAPCRB
    --             As remessas sempre estarão ligadas a chamada desta rotina, que deverá ser efetuada
    --             pelo processo controlador 1 vez ao dia
    -- Alteracoes:
    --   07/10/2015 - PRJ210 - Adaptação para remessas sob-demanda (Marcos-Supero)
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      CURSOR cr_pbc IS
        SELECT pbc.idtpsoli
          FROM crappbc pbc
         WHERE pbc.idtpreme = pr_idtpreme;
      vr_idtpsoli crappbc.idtpsoli%TYPE;
    BEGIN
  	  -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
    	GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_solicita_remessa');      

      -- Buscar tipo do Bureaux
      OPEN cr_pbc;
      FETCH cr_pbc
       INTO vr_idtpsoli;
      CLOSE cr_pbc;
      -- Inserir o agendamento
      BEGIN
        INSERT INTO CRAPCRB(idtpreme
                           ,dtmvtolt)
                     VALUES(pr_idtpreme     --> Bureaux passado
                           ,pr_dtmvtolt);   --> Data passada
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
          CECRED.pc_internal_exception; 
          -- Retorna o erro para a procedure chamadora
          pr_dscritic := 'Erro ao inserir CRAPCRB ['||pr_idtpreme||'] --> '||SQLERRM;
          RETURN;
      END;
      -- Inserir o evento do agendamento com mensagem customizada conforme tipo de solicitação do Bureaux
      IF vr_idtpsoli = 'A' THEN
        -- Automática
        pc_insere_evento_remessa(pr_idtpreme => pr_idtpreme        --> Bureaux passado
                                ,pr_dtmvtolt => pr_dtmvtolt        --> Data passada
                                ,pr_cdesteve => 1                  --> Agendamento
                                ,pr_flerreve => 0                  --> Não houve erro
                                ,pr_dslogeve => 'Remessa ao Bureaux '||pr_idtpreme||' agendada com sucesso pelo processo controlador em '||to_char(SYSDATE,'dd/mm/yyyy')||' as '||to_char(SYSDATE,'hh24:mi:ss')
                                ,pr_dscritic => pr_dscritic);   --> Retorno de crítica
	      -- Retorno do módulo e ação logado - Chamado 719114 - 21/07/2017
  	    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_solicita_remessa 1');  
      ELSE
        -- Sob-Demanda
        pc_insere_evento_remessa(pr_idtpreme => pr_idtpreme        --> Bureaux passado
                                ,pr_dtmvtolt => pr_dtmvtolt        --> Data passada
                                ,pr_cdesteve => 1                  --> Agendamento
                                ,pr_flerreve => 0                  --> Não houve erro
                                ,pr_dslogeve => 'Remessa ao Bureaux '||pr_idtpreme||' solicitada sob-demanda com sucesso em '||to_char(SYSDATE,'dd/mm/yyyy')||' as '||to_char(SYSDATE,'hh24:mi:ss')
                                ,pr_dscritic => pr_dscritic);   --> Retorno de crítica
	      -- Retorno do módulo e ação logado - Chamado 719114 - 21/07/2017
  	    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_solicita_remessa 2');  
      END IF;
      -- Se retornou erro
      IF pr_dscritic IS NOT NULL THEN
        RETURN;
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
        CECRED.pc_internal_exception; 
        -- Retorna o erro para a procedure chamadora
        pr_dscritic := 'Erro --> rotina CYBE0002.pc_solicita_remessa --> '||SQLERRM;
    END;
  END pc_solicita_remessa;


  -- Rotina para efetuar a busca do arquivos da remessa passada
  PROCEDURE pc_busca_arq_remessa(pr_idtpreme IN crapcrb.idtpreme%TYPE --> Tipo da Remessa
                                ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data da Remessa
                                ,pr_dscritic OUT VARCHAR2) IS         --> Retorno de crítica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_busca_arq_remessa
    --  Sistema  : CYBER
    --  Sigla    : CRED
    --  Autor    : Marcos - SUPERO
    --  Data     : Dezembro/2014.                   Ultima atualizacao: 06/10/2015
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Preparar a busca e verificar a existência da remessa passada
    -- Alteracoes:
    --   06/10/2015 - PRJ210 - Mudar a rotina para não considerar que a origem é apenas ZIP
    --
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      -- Variaveis auxiliares
      vr_dschvbsc VARCHAR2(100);      --> Chave para busca com caracter curinga
      vr_dir_temp VARCHAR2(1000);     --> Diretório temporário
      vr_typ_saida VARCHAR2(3);           --> Saída de comando no OS

      -- Busca diretório base do Arq da remessa
      CURSOR cr_crappbc IS
        SELECT crb.rowid
              ,pbc.dsdirenv
              ,pbc.dsfnburm
          FROM crappbc pbc
              ,crapcrb crb
         WHERE crb.idtpreme = pr_idtpreme
           AND crb.dtmvtolt = pr_dtmvtolt
           AND pbc.idtpreme = crb.idtpreme;
      vr_rowid    ROWID;
      vr_dsdirenv crappbc.dsdirenv%TYPE;
      vr_dsfnburm crappbc.dsfnburm%TYPE;
      --
      vr_dslstarq VARCHAR2(4000);        --> Lista de arquivos encontrados
      vr_lstarqre gene0002.typ_split;    --> Split de arquivos encontrados
      vr_lstarqzp gene0002.typ_split;    --> Split de arquivos encontrados no zip
      vr_nrseqarq craparb.nrseqarq%TYPE; --> Sequencia de gravação do arquivo
      vr_nrseqori craparb.nrseqarq%TYPE; --> Sequencia de gravação do arquivo Zip
      vr_nmarqret  VARCHAR2(1000);        --> Nome do arquivo de retorno
    BEGIN
  	  -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
    	GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_busca_arq_remessa');      

      -- Resetar controle de erro
      vr_nrseqare := NULL;
      -- Armazenar o diretório de arquivos temporário
      vr_dir_temp := gene0001.fn_param_sistema('CRED',0,'AUTBUR_DIR_TEMP');
      -- Limpamos a pasta temporária (Parâmetro AUTBUR_DIR_TEMP)
      pc_limpeza_diretorio(pr_nmdireto => vr_dir_temp   --> Diretório para limpeza
                          ,pr_dscritic => vr_dscritic);
      -- Testar retorno de erro
      IF vr_dscritic IS NOT NULL THEN
        -- Incrementar o erro
        vr_dscritic := 'CYBE0002.pc_busca_arquivos_remessa - Ao limpar dir temp - '||vr_dscritic;
        RAISE vr_excerror;
      END IF;
      -- Busca diretório base do arquivo origem da remessa
      OPEN cr_crappbc;
      FETCH cr_crappbc
       INTO vr_rowid,vr_dsdirenv,vr_dsfnburm;
      CLOSE cr_crappbc;
      -- Chamar função dinâmica para montagem do nome do arquivo para busca
      BEGIN
        vr_dschvbsc := fn_dinamic_function(vr_dsfnburm,vr_rowid);
      EXCEPTION
        WHEN OTHERS THEN
          -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
          CECRED.pc_internal_exception; 
          vr_dscritic := 'Erro ao acionar funcao dinâmica para busca dos arquivos da remessa --> '||SQLERRM;
          RAISE vr_excerror;
      END;
      -- Com o diretório e nome do arquivo montado, verificamos se o mesmo existe:
      gene0001.pc_lista_arquivos(pr_path     => vr_dsdirenv   --> Dir busca
                                ,pr_pesq     => vr_dschvbsc   --> Chave busca
                                ,pr_listarq  => vr_dslstarq   --> Lista encontrada
                                ,pr_des_erro => vr_dscritic); --> Possível erro
      -- Se retorno erro:
      IF vr_dscritic IS NOT NULL THEN
        -- Incrementar o erro
        vr_dscritic := 'Erro ao listar arquivos --> '||vr_dscritic;
        RAISE vr_excerror;
      END IF;
      -- Separar a lista de arquivos encontradas com função existente
      vr_lstarqre := fn_quebra_string(pr_string => vr_dslstarq, pr_delimit => ',');
      -- Se não encontrou nenhum arquivo
      IF vr_lstarqre.count() = 0 THEN
        -- Gerar erro
        vr_dscritic := 'Arquivo da remessa '||vr_dschvbsc|| ' nao encontrado no diretorio '||vr_dsdirenv;
        RAISE vr_excerror;
      END IF;
      -- Para cada arquivo encontrado no diretório
      FOR vr_id1 IN 1..vr_lstarqre.count LOOP
        -- Guardar o nome do arquivo
        vr_nmarqret := vr_lstarqre(vr_id1);
        -- Iremos copiar o arquivo para a pasta temporária
        gene0001.pc_OScommand_Shell(pr_des_comando => 'cp '||vr_dsdirenv||'/'||vr_nmarqret||' '||vr_dir_temp
                                   ,pr_typ_saida   => vr_typ_saida
                                   ,pr_des_saida   => vr_dscritic);
        -- Se houve erro
        IF vr_typ_saida = 'ERR' THEN
          RAISE vr_excerror;
        END IF;
        -- Se o arquivo encontrado for um ZIP
        IF gene0001.fn_extensao_arquivo(pr_arquivo => lower(vr_nmarqret)) = 'zip' THEN
          -- Efetuamos a gravação do arquivo indicando que ele já foi processado
          pc_insere_arquivo_bureaux(pr_idtpreme => pr_idtpreme  --> Tipo da remessa
                                   ,pr_dtmvtolt => pr_dtmvtolt  --> Data da remessa
                                   ,pr_cdestarq => 2            --> Estágio do evento (Preparação)
                                   ,pr_nmdireto => vr_dir_temp  --> Diretório do arquivo
                                   ,pr_nmarquiv => vr_nmarqret  --> Nome do arquivo
                                   ,pr_nrseqarq => vr_nrseqori  --> Sequencia do arquivo gravado
                                   ,pr_flproces => 1            --> Já processado
                                   ,pr_dscritic => vr_dscritic);--> Retorno de crítica
          -- Tratar retorno de erro
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_excerror;
          END IF;
          -- Inserir evento na remessa para indicar o encontro do arquivo ZIP e o início de sua descompactação
          pc_insere_evento_remessa(pr_idtpreme => pr_idtpreme
                                  ,pr_dtmvtolt => pr_dtmvtolt
                                  ,pr_nrseqarq => vr_nrseqori
                                  ,pr_cdesteve => 2 --> Fixo - Preparação
                                  ,pr_flerreve => 0 --> Sucesso
                                  ,pr_dslogeve => 'Arquivo '||vr_nmarqret||' encontrado! Iniciando descompactacao...'
                                  ,pr_dscritic => vr_dscritic);
	        -- Retorno do módulo e ação logado - Chamado 719114 - 21/07/2017
  	      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_busca_arq_remessa 1');  
          -- Se retornou erro
          IF vr_dscritic IS NOT NULL THEN
            vr_nrseqare := vr_nrseqori;
            RAISE vr_excerror;
          END IF;
          -- Neste momento gravamos as informações até então
          COMMIT;
          -- Depois procedemos com os próximos passos,
          -- que envolvem a descompactação do arquivo
          gene0002.pc_zipcecred(pr_cdcooper => 3                             --> Sempre Cecred
                               ,pr_tpfuncao => 'E'                           --> Extrair
                               ,pr_dsorigem => vr_dir_temp||'/'||vr_nmarqret --> Arquivo original
                               ,pr_dsdestin => vr_dir_temp                   --> Diretório descompactação
                               ,pr_dspasswd => NULL                          --> Sem senha
                               ,pr_des_erro => vr_dscritic);                 --> Erros
  	      -- Retorna do módulo e ação logado - Chamado 719114 - 21/07/2017
    	    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_busca_arq_remessa'); 
          -- Se houve retorno de erro
          IF vr_dscritic IS NOT NULL THEN
            vr_nrseqare := vr_nrseqori;
            RAISE vr_excerror;
          END IF;
          -- Agora, listamos todos os arquivos descompactados
          gene0001.pc_lista_arquivos(pr_path     => vr_dir_temp   --> Dir busca
                                    ,pr_pesq     => NULL          --> Chave busca(Tudo)
                                    ,pr_listarq  => vr_dslstarq   --> Lista encontrada
                                    ,pr_des_erro => vr_dscritic); --> Possível erro
          -- Se retorno erro:
          IF vr_dscritic IS NOT NULL THEN
            vr_nrseqare := vr_nrseqori;
            RAISE vr_excerror;
          END IF;
          -- Separar a lista de arquivos encontradas com função existente
          vr_lstarqzp := fn_quebra_string(pr_string => vr_dslstarq, pr_delimit => ',');
          -- Se não encontrou nenhum arquivo além do zip
          IF vr_lstarqzp.count() <= 1 THEN
            -- Gerar erro
            vr_nrseqare := vr_nrseqori;
            vr_dscritic := 'Nenhum arquivo descompactado do ZIP '||vr_dsdirenv||'/'||vr_nmarqret;
            RAISE vr_excerror;
          END IF;
          -- Para cada arquivo encontrado no ZIP
          FOR vr_id2 IN 1..vr_lstarqzp.count LOOP
            -- Ignorar o próprio arquivo Zip
            IF vr_lstarqzp(vr_id2) <> vr_nmarqret THEN
              -- Chamamos a rotina que direciona a gravação na tabela de arquivos
              pc_insere_arquivo_bureaux(pr_idtpreme => pr_idtpreme        --> Tipo da remessa
                                       ,pr_dtmvtolt => pr_dtmvtolt        --> Data da remessa
                                       ,pr_nrseqant => vr_nrseqori        --> Zip é o anterior
                                       ,pr_cdestarq => 3                  --> Estágio do evento (Envio)
                                       ,pr_nmdireto => vr_dir_temp        --> Diretório do arquivo
                                       ,pr_nmarquiv => vr_lstarqzp(vr_id2)--> Nome do arquivo
                                       ,pr_nrseqarq => vr_nrseqarq        --> Seq do arquivo gravado
                                       ,pr_dscritic => vr_dscritic);      --> Retorno de crítica
              -- Tratar retorno de erro
              IF vr_dscritic IS NOT NULL THEN
                vr_nrseqare := vr_nrseqarq;
                RAISE vr_excerror;
              END IF;
              -- Inserir evento na remessa para indicar o encontro do arquivo ZIP
              pc_insere_evento_remessa(pr_idtpreme => pr_idtpreme
                                      ,pr_dtmvtolt => pr_dtmvtolt
                                      ,pr_nrseqarq => vr_nrseqarq
                                      ,pr_cdesteve => 2 --> Fixo - Preparação
                                      ,pr_flerreve => 0 --> Sucesso
                                      ,pr_dslogeve => 'Arquivo '||vr_lstarqzp(vr_id2)||' descompactado.'
                                      ,pr_dscritic => vr_dscritic);
	            -- Retorno do módulo e ação logado - Chamado 719114 - 21/07/2017
  	          GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_busca_arq_remessa 2');  
              -- Se retornou erro
              IF vr_dscritic IS NOT NULL THEN
                vr_nrseqare := vr_nrseqarq;
                RAISE vr_excerror;
              END IF;
              -- Gravamos as informações
              COMMIT;
            END IF;
          END LOOP; --> Arquivos do ZIP
        ELSE
          -- Não é ZIP, então adicionamos o arquivo como não processado para que o arquivo a enviar seja esse
          pc_insere_arquivo_bureaux(pr_idtpreme => pr_idtpreme  --> Tipo da remessa
                                   ,pr_dtmvtolt => pr_dtmvtolt  --> Data da remessa
                                   ,pr_cdestarq => 3            --> Estágio do evento (Envio)
                                   ,pr_nmdireto => vr_dir_temp  --> Diretório do arquivo
                                   ,pr_nmarquiv => vr_nmarqret  --> Nome do arquivo
                                   ,pr_nrseqarq => vr_nrseqori  --> Sequencia do arquivo gravado
                                   ,pr_flproces => 0            --> Ainda não processado
                                   ,pr_dscritic => vr_dscritic);--> Retorno de crítica
          -- Tratar retorno de erro
          IF vr_dscritic IS NOT NULL THEN
            RAISE vr_excerror;
          END IF;
          -- Inserir evento na remessa para indicar o encontro do arquivo ZIP
          pc_insere_evento_remessa(pr_idtpreme => pr_idtpreme
                                  ,pr_dtmvtolt => pr_dtmvtolt
                                  ,pr_nrseqarq => vr_nrseqori
                                  ,pr_cdesteve => 2 --> Fixo - Preparação
                                  ,pr_flerreve => 0 --> Sucesso
                                  ,pr_dslogeve => 'Arquivo '||vr_nmarqret||' para envio encontrado! '
                                  ,pr_dscritic => vr_dscritic);
	        -- Retorno do módulo e ação logado - Chamado 719114 - 21/07/2017
  	      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_busca_arq_remessa 3');  
          -- Se retornou erro
          IF vr_dscritic IS NOT NULL THEN
            vr_nrseqare := vr_nrseqori;
            RAISE vr_excerror;
          END IF;
          -- Neste momento gravamos as informações até então
          COMMIT;
        END IF; --> Se arquivo é ZIP
        -- Limpamos o diretório temporário para processar o próximo arquivo
        pc_limpeza_diretorio(pr_nmdireto => vr_dir_temp   --> Diretório para limpeza
                            ,pr_dscritic => vr_dscritic);
        -- Testar retorno de erro
        IF vr_dscritic IS NOT NULL THEN
          -- Incrementar o erro
          vr_dscritic := 'CYBE0002.pc_busca_arquivos_remessa - Ao limpar dir temp - '||vr_dscritic;
          RAISE vr_excerror;
        END IF;
      END LOOP; --> Arquivos retornados
    EXCEPTION
      WHEN vr_excerror THEN
        -- Devemos inserir o evento do erro e
        pc_insere_evento_remessa(pr_idtpreme => pr_idtpreme
                                ,pr_dtmvtolt => pr_dtmvtolt
                                ,pr_nrseqarq => vr_nrseqare
                                ,pr_cdesteve => 2 --> Fixo - Preparação
                                ,pr_flerreve => 1 --> Erro
                                ,pr_dslogeve => vr_dscritic
                                ,pr_dscritic => pr_dscritic);
	      -- Retorno do módulo e ação logado - Chamado 719114 - 21/07/2017
  	    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_busca_arq_remessa 4');  
        -- Gravamos
        COMMIT;
        -- Devolvemos o problema
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
        CECRED.pc_internal_exception; 
        -- Retorna o erro para a procedure chamadora
        pr_dscritic := 'CYBE0002.pc_busca_arquivos_remessa - '||SQLERRM;
    END;
  END pc_busca_arq_remessa;


  -- Rotina para enviar a remessa de arquivos via Connect Direct
  PROCEDURE pc_envia_remessa_cd(pr_nmarquiv IN VARCHAR2              --> Nome do arquivo a enviar
                               ,pr_nmdireto IN VARCHAR2              --> Caminho dos arquivos a enviar
                               ,pr_dsdirenv IN VARCHAR2              --> Diretório a enviar ao CD
                               ,pr_dsdirend IN VARCHAR2              --> Diretório enviados ao CD
                               ,pr_dscritic OUT VARCHAR2) IS         --> Retorno de crítica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_envia_remessa_cd
    --  Sistema  : CYBER
    --  Sigla    : CRED
    --  Autor    : Marcos - SUPERO
    --  Data     : Dezembro/2014.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Efetuar o envio dos arquivos repassados ao ConnectDirect
    --             Precisamos apenas mover os arquivos para a pasta correspondente
    --             do envio e aguardar o Software enviar o arquivos. Após, o Software
    --             move estes arquivos para a pasta enviados
    -- Alteracoes:
    --
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      vr_flenviad   BOOLEAN := FALSE; --> Flag para indicar que o arquivo foi enviado
      vr_typ_saida  VARCHAR2(3);      --> Saída do comando no OS
    BEGIN
  	  -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
    	GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_envia_remessa_cd');      

      -- Primeiramente checamos se o arquivo por ventura já não está na pasta enviados
      IF gene0001.fn_exis_arquivo(pr_caminho => pr_dsdirend||'/'||pr_nmarquiv) THEN
        -- O que ocorreu é que a cópia anterior não havia sido enviada nos 5 minutos que
        -- a rotina espera, então, após esta nova execução o envio ocorreu com sucesso.
        -- Apenas retornamos
        RETURN;
      ELSE
        -- Checamos se o arquivo já não foi copiado a envia
        IF NOT gene0001.fn_exis_arquivo(pr_caminho => pr_dsdirenv||'/'||pr_nmarquiv) THEN
          -- Devemos movê-lo para a pasta envia
          gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||pr_nmdireto||'/'||pr_nmarquiv||' '||pr_dsdirenv
                                     ,pr_typ_saida   => vr_typ_saida
                                     ,pr_des_saida   => pr_dscritic);
          -- Se retornou erro, incrementar a mensagem e retornoar
          IF vr_typ_saida = 'ERR' THEN
            RETURN;
          END IF;
        END IF;
        -- Agora devemos checar o envio do arquivo, que é garantido quando o arquivo
        -- é movido da envia para enviados pelo Connect Direct. Checaremos de 10 em 10
        -- segundos e aguardaremos no máximo 5 minutos.
        FOR vr_tent IN 1..30 LOOP
          -- Testar envio (Existencia na enviados)
          IF gene0001.fn_exis_arquivo(pr_caminho => pr_dsdirend||'/'||pr_nmarquiv) THEN
            -- Validar flag e sair da espera
            vr_flenviad := TRUE;
            EXIT;
          END IF;
          -- Aguardar 10 segundos
          sys.dbms_lock.sleep(10);
        END LOOP;
        -- Se não conseguiu enviar:
        IF NOT vr_flenviad THEN
          -- Montar critica
          pr_dscritic := 'Arquivo persiste na pasta ENVIA';
          RETURN;
        END IF;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
        CECRED.pc_internal_exception; 
        -- Retorna o erro para a procedure chamadora
        pr_dscritic := 'Erro --> rotina CYBE0002.pc_envia_remessa_cd --> '||SQLERRM;
    END;
  END pc_envia_remessa_cd;


  -- Rotina enviar a remessa de arquivos ao FTP passado
  PROCEDURE pc_envio_remessa_ftp(pr_nmarquiv IN VARCHAR2              --> Nome arquivo a enviar
                                ,pr_nmdireto IN VARCHAR2              --> Diretório do arquivo a enviar
                                ,pr_idenvseg IN crapcrb.idtpreme%TYPE --> Indicador de utilizacao de protocolo seguro (SFTP)
                                ,pr_ftp_site IN VARCHAR2              --> Site de acesso ao FTP
                                ,pr_ftp_user IN VARCHAR2              --> Usuário para acesso ao FTP
                                ,pr_ftp_pass IN VARCHAR2              --> Senha para acesso ao FTP
                                ,pr_ftp_path IN VARCHAR2              --> Pasta no FTP para envio do arquivo
                                ,pr_key_path IN VARCHAR2              --> Caminho da chave de criptografia quando o (SFTP) usar.
                                ,pr_passphra IN VARCHAR2              --> Senha da chave de criptografica quando o (SFTP) usar.
                                ,pr_dscritic OUT VARCHAR2) IS         --> Retorno de crítica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_envio_remessa_ftp
    --  Sistema  : CYBER
    --  Sigla    : CRED
    --  Autor    : Marcos - SUPERO
    --  Data     : Dezembro/2014.                   Ultima atualizacao: 10/10/2017
    --
    -- Dados referentes ao programa: 23/03/2016
    --
    -- Frequencia: -----
    -- Objetivo  : Efetuar envio do arquivo repassado para o FTP enviado como parâmetro
    --
    -- Alteracoes: 23/03/2016 - Adicionado tratamento para identificar se é necessário fazer
    --                          a chamada do ftp seguro conforme solicitado no chamado 412682. (Kelvin)
    --
    --             10/10/2017 - M434 - Adicionar dois novos parâmetros para atender o SPC/Brasil que usa chave 
    --                          de criptografia para o acesso ao SFTP. (Oscar)
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
    
      vr_script_ftp VARCHAR2(1000); --> Script FTP
      vr_comand_ftp VARCHAR2(4000); --> Comando montado do envio ao FTP
      vr_typ_saida  VARCHAR2(3);    --> Saída de erro
      vr_prmkeysftp VARCHAR2(4000); --> Paramentros de chave de criptografia apenas para SFTP
    BEGIN
  	  -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
    	GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_envio_remessa_ftp');      

      --Chama script específico para conexão de ftp segura
      IF pr_idenvseg = 'S' THEN
        vr_script_ftp := gene0001.fn_param_sistema('CRED',0,'AUTBUR_SCRIPT_SFTP');
        vr_prmkeysftp := ' -caminhoarquivochave ' || CHR(39) || pr_key_path|| CHR(39) || ' -senhadachave ' || pr_passphra;
      ELSE
        -- Buscar script para conexão FTP
        vr_script_ftp := gene0001.fn_param_sistema('CRED',0,'AUTBUR_SCRIPT_FTP');
      END IF;                                      
      
      -- Preparar o comando de conexão e envio ao FTP
      vr_comand_ftp := vr_script_ftp
                    || ' -envia'
                    || ' -srv '          || pr_ftp_site
                    || ' -usr '          || pr_ftp_user
                    || ' -pass '         || pr_ftp_pass
                    || ' -arq '          || CHR(39) || pr_nmarquiv || CHR(39)
                    || ' -dir_local '    || CHR(39) || pr_nmdireto || CHR(39)
                    || ' -dir_remoto '   || CHR(39) || pr_ftp_path || CHR(39)
                    || ' -log /usr/coop/cecred/log/proc_autbur.log'
                    || vr_prmkeysftp;
      
      -- Chama procedure de envio e recebimento via ftp
      GENE0001.pc_OScommand_Shell(pr_des_comando => vr_comand_ftp
                                 ,pr_typ_saida   => vr_typ_saida
                                 ,pr_des_saida   => pr_dscritic);

      -- Se ocorreu erro dar RAISE
      IF vr_typ_saida = 'ERR' THEN
        RETURN;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
        CECRED.pc_internal_exception; 
        -- Retorna o erro para a procedure chamadora
        pr_dscritic := 'Erro --> rotina CYBE0002.pc_envio_arquivo_ftp --> '||SQLERRM;
    END;
  END pc_envio_remessa_ftp;


  -- Rotina para preparar e direcionar o envio dos arquivos da remessa ao Bureaux
  PROCEDURE pc_envio_remessa(pr_idtpreme IN crapcrb.idtpreme%TYPE --> Tipo da Remessa
                            ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data da Remessa
                            ,pr_dscritic OUT VARCHAR2) IS         --> Retorno de crítica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_envio_remessa
    --  Sistema  : CYBER
    --  Sigla    : CRED
    --  Autor    : Marcos - SUPERO
    --  Data     : Dezembro/2014.                   Ultima atualizacao: 10/10/2017
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Identificar o tipo de remessa, buscar informações específicas e chamar
    --             as rotinas responsáveis pelo envio da remessa conforme seu tipo.
    -- Alteracoes:
    --
    -- 07/10/2015 - PRJ210 - Adaptar envio para remessas sob-demanda (Marcos-Supero)
    -- 10/10/2017 - M434 - Adicionar novos parametros para o SPC Brasil neste momento será fixo em caracter 
    --                     emergencial posteriormente deverá ser criado parametros na tela LOGRBC. (Oscar)
	-- 25/09/2018 - Ajuste para organizar os arquivos antes de começar o envio para o Bureaux. (Saquetta)
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      -- Variaveis auxiliares
      vr_dir_temp VARCHAR2(4000);
      vr_nmarquiv VARCHAR2(400);
      vr_flgerror NUMBER;
      vr_dslogeve VARCHAR2(1000);
      vr_qtdenvio NUMBER := 0;
      vr_dschvrem VARCHAR2(4000);
      vr_key_path VARCHAR2(4000);
      vr_passphra VARCHAR2(4000);


      -- Busca das informações para envio da remessa
      CURSOR cr_pbc IS
        SELECT pbc.idtpenvi
              ,pbc.dssitftp
              ,pbc.dsusrftp
              ,pbc.dspwdftp
              ,pbc.dsdreftp
              ,pbc.dsdrencd
              ,pbc.dsdrevcd
              ,pbc.dsfnrnen
              ,nvl(pbc.idopreto,'S') idopreto
              ,pbc.dsfnchrm
              ,pbc.flremseq
              ,pbc.idenvseg
          FROM crappbc pbc
         WHERE pbc.idtpreme = pr_idtpreme;
      rw_pbc cr_pbc%ROWTYPE;

      -- Teste para verificar se por ventura há outra remessa anterior
      -- ainda não preparada, ou seja, sem o arquivo ZIP de início da remessa
      CURSOR cr_prep_penden IS
        SELECT 'S'
          FROM crapcrb crb
              ,crappbc pbc
         WHERE crb.idtpreme = pr_idtpreme
           AND crb.dtmvtolt < pr_dtmvtolt
           AND crb.idtpreme = pbc.idtpreme
           AND pbc.flgativo = 1   --> Somente Bureauxs Ativos
           AND crb.dtcancel IS NULL --> Desconsiderar as canceladas
           -- Sem o arquivo da preparação
           AND NOT EXISTS(SELECT 1
                            FROM craparb arb
                           WHERE crb.idtpreme = arb.idtpreme
                             AND crb.dtmvtolt = arb.dtmvtolt
                             AND arb.cdestarq = 2) --> Preparação
           -- Desde que esta também tenha tido preparação
           AND EXISTS(SELECT 1
                        FROM craparb arb
                       WHERE crb.idtpreme = pr_idtpreme
                         AND crb.dtmvtolt = pr_dtmvtolt
                         AND arb.cdestarq = 2); --> Preparação

      -- Buscamos todos os arquivos relacionados ao Envio e ainda não processados
      -- e com data anterior a data da remessa em execução
      CURSOR cr_arb_out(pr_dschvrem VARCHAR2) IS
        SELECT 'S'
          FROM craparb arb
              ,crapcrb crb
         WHERE crb.idtpreme = arb.idtpreme
           AND crb.dtmvtolt = arb.dtmvtolt
           AND arb.idtpreme = pr_idtpreme
           AND arb.cdestarq <= 3  --> Envio ou inferior
           AND crb.dtcancel IS NULL --> Remessa não cancelada
           AND arb.flproces = 0 --> Não processado
           AND arb.dtcancel IS NULL --> Não cancelado
           AND arb.dtmvtolt < pr_dtmvtolt
           -- Se foi enviado chave de busca
           AND ((pr_dschvrem IS NOT NULL AND arb.nmarquiv LIKE pr_dschvrem) OR (pr_dschvrem IS NULL));
      vr_existe VARCHAR2(1);

      -- Buscamos todos os arquivos relacionados ao Envio e ainda não processados
      CURSOR cr_arb IS
        SELECT arb.nrseqarq
              ,arb.nmarquiv
              ,arb.nmarqren
              ,arb.blarquiv
              ,arb.rowid
          FROM craparb arb_org
              ,craparb arb
              ,crapcrb crb
         WHERE arb_org.nrseqarq (+) = arb.nrseqant
           AND arb_org.dtmvtolt (+) = arb.dtmvtolt
           AND arb_org.idtpreme (+) = arb.idtpreme
           --
           AND crb.idtpreme = arb.idtpreme
           AND crb.dtmvtolt = arb.dtmvtolt
           AND arb.dtmvtolt = pr_dtmvtolt
           AND arb.idtpreme = pr_idtpreme
           AND arb.cdestarq = 3  --> Envio
           AND arb.flproces = 0  --> Não processado
           AND arb.dtcancel IS NULL
           AND crb.dtcancel IS NULL
         order by arb_org.nmarquiv asc, arb.nmarquiv asc;
      rw_arb cr_arb%ROWTYPE;
    BEGIN
  	  -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
    	GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_envio_remessa');      

      -- LImpar sequencia arquivo com erro
      vr_nrseqare := NULL;
      -- Armazenar o diretório de arquivos temporário
      vr_dir_temp := gene0001.fn_param_sistema('CRED',0,'AUTBUR_DIR_TEMP');

      -- Primeiramente limpamos a pasta temporária (PArâmetro AUTBUR_DIR_TEMP)
      pc_limpeza_diretorio(pr_nmdireto => vr_dir_temp   --> Diretório para limpeza
                          ,pr_dscritic => vr_dscritic);
      -- Testar retorno de erro
      IF vr_dscritic IS NOT NULL THEN
        -- Incrementar o erro
        raise vr_excerror;
      END IF;

      -- Buscamos as informações para envio da remessa
      OPEN cr_pbc;
      FETCH cr_pbc
       INTO rw_pbc;
      CLOSE cr_pbc;

      -- Montar mensagem diferenciada caso já houve algo envio antes
      vr_dsexiste := 'N';
      OPEN cr_exis_estagio(pr_idtpreme => pr_idtpreme
                          ,pr_dtmvtolt => pr_dtmvtolt
                          ,pr_cdesteve => 3); -- Envio
      FETCH cr_exis_estagio
       INTO vr_dsexiste;
      CLOSE cr_exis_estagio;
      -- Se não houve nenhum envio
      IF vr_dsexiste = 'N' THEN
        vr_dscritic := 'Iniciando envio de remessa ao Bureaux...';
      ELSE
        vr_dscritic := 'Retomando envio de remessa ao Bureaux...';
      END IF;

      -- Incluir evento avisando da tentativa de envio
      pc_insere_evento_remessa(pr_idtpreme => pr_idtpreme
                              ,pr_dtmvtolt => pr_dtmvtolt
                              ,pr_cdesteve => 3 --> Fixo - Envio
                              ,pr_flerreve => 0 --> Sucesso
                              ,pr_dslogeve => vr_dscritic
                              ,pr_dscritic => vr_dscritic);
	    -- Retorno do módulo e ação logado - Chamado 719114 - 21/07/2017
  	  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_envio_remessa 1');  
      -- Se retornou erro, incrementar a mensagem e retornoar
      IF vr_dscritic IS NOT NULL THEN
        raise vr_excerror;
      END IF;
      -- Gravar evento de envio..
      COMMIT;

      -- Entao, buscamos todos os arquivos relacionados ao Envio e ainda não processados
      FOR rw_arb IN cr_arb LOOP

        -- Somente verificar predecessão se a remessa possuir este tipo de controle
        IF nvl(rw_pbc.flremseq,0) = 1 THEN

          -- Se for uma remessa Multi-Retorno, então checaremos cada
          -- arquivo se não existe algum arquivo anterior e não processado
          IF rw_pbc.idopreto = 'M' THEN
            -- Devemos montar a chave única da remessa usando a função
            BEGIN
              vr_dschvrem := fn_dinamic_function(rw_pbc.dsfnchrm,rw_arb.rowid);
            EXCEPTION
              WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
                CECRED.pc_internal_exception; 
                pr_dscritic := 'Erro ao acionar funcao dinamica para montar chave da remessa --> '||SQLERRM;
                RETURN;
            END;
          ELSE
            -- Não há chave de procura
            vr_dschvrem := NULL;
          END IF;

          -- Primeiro busca se não existe remessa anterior sem a preparação, ou seja,
          -- sem o arquivo ZIP que é recebido diariamente da PPware
          vr_existe := 'N';
          OPEN cr_prep_penden;
          FETCH cr_prep_penden
           INTO vr_existe;
          CLOSE cr_prep_penden;

          -- Se não encontrou
          IF vr_existe = 'N' THEN
            -- Busca se existe remessa com a mesma chave(para Multi)
            -- em algum dia anterior e pendente de processamento
            OPEN cr_arb_out(pr_dschvrem => vr_dschvrem);
            FETCH cr_arb_out INTO vr_existe;
            CLOSE cr_arb_out;
          END IF;

          -- Se encontrou alguma pendência, ou não achou nenhum
          -- arquivo enviado (Remessa não preparada)
          IF vr_existe = 'S' THEN
            -- Adicionar no LOG para que seja explicito que não haverá
            -- envio até esta remessa for recebida
            pc_insere_evento_remessa(pr_idtpreme => pr_idtpreme
                                    ,pr_dtmvtolt => pr_dtmvtolt
                                    ,pr_nrseqarq => rw_arb.nrseqarq
                                    ,pr_cdesteve => 3 --> Fixo - Envio
                                    ,pr_flerreve => 1 --> Erro
                                    ,pr_dslogeve => 'Remessa aguardando envio de remessas precedentes.'
                                    ,pr_dscritic => pr_dscritic);
	          -- Retorno do módulo e ação logado - Chamado 719114 - 21/07/2017
  	        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_envio_remessa 2');  
            -- Se retornou erro, incrementar a mensagem e retornoar
            IF pr_dscritic IS NOT NULL THEN
              RETURN;
            END IF;
            -- Pular esta remessa e somente processar quando não
            -- houver nenhuma outra pendência
            COMMIT;
            -- Para remessas com Multi-Retorno
            IF rw_pbc.idopreto = 'M' THEN
              -- Apenas continuar ao proximo arquivo
              continue;
            ELSE
              -- Sair para que a mensagem apareça uma única vez
              EXIT;
            END IF;
          END IF;
        END IF;

        -- Se há função de rename e a mesma ainda não foi acionada
        IF rw_pbc.dsfnrnen IS NOT NULL AND rw_arb.nmarqren IS NULL THEN
          -- Chamaremos dinamicamente a função
          BEGIN
            rw_arb.nmarqren := fn_dinamic_function(rw_pbc.dsfnrnen,rw_arb.rowid);
          EXCEPTION
            WHEN OTHERS THEN
              -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
              CECRED.pc_internal_exception; 
              vr_nrseqare := rw_arb.nrseqarq;
              vr_dscritic := 'Erro ao acionar funcao para renomeamento dos arquivo a enviar ao Bureaux --> '||SQLERRM;
              raise vr_excerror;
          END;

          -- Atualizamos na tabela
          BEGIN
            -- Atualização arquivo
            UPDATE craparb arb
               SET arb.nmarqren = rw_arb.nmarqren
             WHERE arb.rowid = rw_arb.rowid;
            -- Adicionar o evento referente ao rename
            pc_insere_evento_remessa(pr_idtpreme => pr_idtpreme
                                    ,pr_dtmvtolt => pr_dtmvtolt
                                    ,pr_nrseqarq => rw_arb.nrseqarq
                                    ,pr_cdesteve => 3 --> Fixo - Envio
                                    ,pr_flerreve => 0 --> Sucesso
                                    ,pr_dslogeve => 'Arquivo renomeado para envio. Novo nome: '||rw_arb.nmarqren
                                    ,pr_dscritic => vr_dscritic);
	          -- Retorno do módulo e ação logado - Chamado 719114 - 21/07/2017
        	  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_envio_remessa 3');  
            -- Gravar as informações
            COMMIT;
          EXCEPTION
            WHEN OTHERS THEN
              -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
              CECRED.pc_internal_exception; 
              -- Retornar descrição do problema
              vr_nrseqare := rw_arb.nrseqarq;
              vr_dscritic := 'Erro durante atualizacao do rename do arquivo: '||SQLERRM;
              raise vr_excerror;
          END;
        END IF;
        -- Se o arquivo foi renomeado
        IF rw_arb.nmarqren IS NOT NULL THEN
          -- Usaremos este
          vr_nmarquiv := rw_arb.nmarqren;
        ELSE
          -- Usaremos o original
          vr_nmarquiv := rw_arb.nmarquiv;
        END IF;
        -- Devemos criar o arquivo na pasta temp, usando função que converte BLOB em arquivo
        gene0002.pc_blob_para_arquivo(pr_blob     => rw_arb.blarquiv --> Bytes do arquivo
                                     ,pr_caminho  => vr_dir_temp     --> Dir temp
                                     ,pr_arquivo  => vr_nmarquiv     --> Nome original
                                     ,pr_des_erro => vr_dscritic);
  	    -- Retorna do módulo e ação logado - Chamado 719114 - 21/07/2017
    	  GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_envio_remessa'); 
        -- Se retornou erro, incrementar a mensagem e retornoar
        IF vr_dscritic IS NOT NULL THEN
          vr_nrseqare := rw_arb.nrseqarq;
          raise vr_excerror;
        END IF;
        -- Chamar rotina específica de Envio
        IF rw_pbc.idtpenvi = 'F' THEN
          
          vr_key_path := NULL;
          vr_passphra := NULL;
          IF rw_pbc.idenvseg = 'S' THEN
             vr_key_path := gene0001.fn_param_sistema('CRED',0, pr_idtpreme || '_BRASIL_KEYPATH');
             vr_passphra := gene0001.fn_param_sistema('CRED',0, pr_idtpreme || '_BRASIL_PASSPHR');
          END IF;

          -- Envio FTP
          pc_envio_remessa_ftp(pr_nmarquiv => vr_nmarquiv           --> Nome arquivo a enviar
                              ,pr_nmdireto => vr_dir_temp           --> Diretório do arquivo a enviar
                              ,pr_idenvseg => rw_pbc.idenvseg       --> Indicador de utilizacao de protocolo seguro (SFTP)    
                              ,pr_ftp_site => rw_pbc.dssitftp       --> Site de acesso ao FTP
                              ,pr_ftp_user => rw_pbc.dsusrftp       --> Usuário para acesso ao FTP
                              ,pr_ftp_pass => rw_pbc.dspwdftp       --> Senha para acesso ao FTP
                              ,pr_ftp_path => rw_pbc.dsdreftp       --> Pasta no FTP para envio do arquivo
                              ,pr_key_path => vr_key_path           --> Caminho da chave de criptografia quando o (SFTP) usar.
                              ,pr_passphra => vr_passphra           --> Senha da chave de criptografica quando o (SFTP) usar.
                              ,pr_dscritic => vr_dscritic);         --> Retorno de crítica
        ELSIF rw_pbc.idtpenvi = 'C' THEN
          -- Envio Connect Direct
          pc_envia_remessa_cd(pr_nmarquiv => vr_nmarquiv           --> Nome do arquivo a enviar
                             ,pr_nmdireto => vr_dir_temp           --> Caminho dos arquivos a enviar
                             ,pr_dsdirenv => rw_pbc.dsdrencd       --> Diretório a enviar ao CD
                             ,pr_dsdirend => rw_pbc.dsdrevcd       --> Diretório enviados ao CD
                             ,pr_dscritic => vr_dscritic);         --> Retorno de crítica
        END IF;

        -- Código comum, para gravação do LOG independente de sucesso ou não
        IF vr_dscritic IS NOT NULL THEN
          -- Houve erro
          vr_flgerror := 1;
          vr_dslogeve := 'Erro no envio do arquivo '||vr_nmarquiv||' -> '|| vr_dscritic;
        ELSE
          -- Sucesso
          vr_qtdenvio := vr_qtdenvio + 1;
          vr_flgerror := 0;
          vr_dslogeve := 'Arquivo '||vr_nmarquiv||' enviado com sucesso!';
        END IF;
        -- Adicionar o evento referente ao envio
        pc_insere_evento_remessa(pr_idtpreme => pr_idtpreme
                                ,pr_dtmvtolt => pr_dtmvtolt
                                ,pr_nrseqarq => rw_arb.nrseqarq
                                ,pr_cdesteve => 3 --> Fixo - Envio
                                ,pr_flerreve => vr_flgerror --> Testado acima
                                ,pr_dslogeve => vr_dslogeve
                                ,pr_dscritic => vr_dscritic);
	      -- Retorno do módulo e ação logado - Chamado 719114 - 21/07/2017
  	    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_envio_remessa 4');  
        -- Gravamos os eventos
        COMMIT;
        -- Validação de erro ocorrido anteriormente e somente parar
        -- nos casos sem Retorno ou com Retorno ÚNico.
        -- Nos casos de Multi-Retorno, temos que continuar e tentar
        -- enviar o méximo de arquivos ao Bureaux
        IF vr_flgerror = 1 AND rw_pbc.idopreto = 'U' THEN
          -- Retornar descrição genérica pois o erro específico já foi gravado
          vr_dscritic := 'Erro durante envio dos arquivos ao Bureaux, o envio sera encerrado.';
          raise vr_excerror;
        --> Indicar o processamento do arquivo quando não houve erro
        ELSIF vr_flgerror = 0 THEN
          -- Se não houver erro, então atualizamos a situação do arquivo como processado.
          BEGIN
            -- Atualização arquivo
            UPDATE craparb arb
               SET arb.flproces = 1
             WHERE arb.rowid = rw_arb.rowid;
            -- Gravar as informações
            COMMIT;
          EXCEPTION
            WHEN OTHERS THEN
              -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
              CECRED.pc_internal_exception; 
              -- Gravamos o evento relacionado ao arquivo
              pc_insere_evento_remessa(pr_idtpreme => pr_idtpreme
                                      ,pr_dtmvtolt => pr_dtmvtolt
                                      ,pr_nrseqarq => rw_arb.nrseqarq
                                      ,pr_cdesteve => 3 --> Fixo - Envio
                                      ,pr_flerreve => 1 --> Erro
                                      ,pr_dslogeve => 'Arquivo enviado, porem houve erro ao atualizar sua situacao: '||SQLERRM
                                      ,pr_dscritic => vr_dscritic);
	            -- Retorno do módulo e ação logado - Chamado 719114 - 21/07/2017
  	          GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_envio_remessa 5');  
              -- Gravamos os eventos
              COMMIT;
              -- Retornar descrição genérica pois o erro específico já foi gravado
              vr_dscritic := 'Erro durante envio dos arquivos ao Bureaux, o envio sera encerrado.';
              raise vr_excerror;
          END;
        END IF;
      END LOOP;
      -- Ao final, se houve envio de pelo menos um arquivo
      IF vr_qtdenvio > 0 THEN
        -- Adicionamos no log de eventos
        pc_insere_evento_remessa(pr_idtpreme => pr_idtpreme
                                ,pr_dtmvtolt => pr_dtmvtolt
                                ,pr_cdesteve => 3 --> Fixo - Envio
                                ,pr_flerreve => 0 -- Sucesso
                                ,pr_dslogeve => 'Total de arquivos enviados ao Bureaux: '||vr_qtdenvio
                                ,pr_dscritic => vr_dscritic);
	      -- Retorno do módulo e ação logado - Chamado 719114 - 21/07/2017
  	    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_envio_remessa 6');  
        -- Gravamos os eventos
        COMMIT;
      END IF;
    EXCEPTION
      WHEN vr_excerror THEN
        -- Escrevemos no log
        pc_insere_evento_remessa(pr_idtpreme => pr_idtpreme
                                ,pr_dtmvtolt => pr_dtmvtolt
                                ,pr_nrseqarq => vr_nrseqare
                                ,pr_cdesteve => 3 --> Fixo - Envio
                                ,pr_flerreve => 1 -- Erro
                                ,pr_dslogeve => vr_dscritic
                                ,pr_dscritic => vr_dscritic);
        -- Gravamos os eventos
        COMMIT;
        -- Retornar o problema encontrado
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
        CECRED.pc_internal_exception; 
        -- Retorna o erro para a procedure chamadora
        pr_dscritic := 'Erro --> rotina CYBE0002.pc_envio_remessa --> '||SQLERRM;
    END;
  END pc_envio_remessa;


  -- Inclusão do parâmetro tipo de log - Chamado 719114 - 07/08/2017
  -- Rotina para efetuar o retorno dos arquivos de remessas Connect Direct
  PROCEDURE pc_retorno_arquivo_cd(pr_idtpreme IN crapcrb.idtpreme%TYPE --> Tipo da Remessa
                                 ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data da Remessa
                                 ,pr_nrseqarq IN craparb.nrseqarq%TYPE --> Sequencia do arq da remessa (Quando Multi-Retorno)
                                 ,pr_dsdirrec IN crappbc.dsdrrecd%TYPE --> Diretório recebe
                                 ,pr_dsdirrcd IN crappbc.dsdrrtcd%TYPE --> Diretório recebidos
                                 ,pr_nmarquiv IN craparb.nmarquiv%TYPE --> Nome do padrão de retorno
                                 ,pr_dsfnchrt IN crappbc.dsfnchrt%TYPE --> Função que faz a checagem dos retornos para garatir a relação com o envio
                                 ,pr_qtretorn OUT NUMBER               --> Numero de arquivos retornados
                                 ,pr_dstiplog OUT VARCHAR2             --> Tipo de Log
                                 ,pr_dscritic OUT VARCHAR2) IS         --> Retorno de crítica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_retorno_arquivo_cd
    --  Sistema  : CYBER
    --  Sigla    : CRED
    --  Autor    : Marcos - SUPERO
    --  Data     : Dezembro/2014.                   Ultima atualizacao: 21/07/2017
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Verificar o retorno dos arquivos na pasta de recebe
    --             do Connect Direct e após consumí-los, mover a pasta recebidos
    --
    -- Alteracoes: 06/04/2015 - Alteração para recebimento e acionamento de função de checagem de retorno
    --                          para validar se o retorno encontrado é vinculado ao arquivo enviado (Marcos-Supero)
    --
    --             21/07/2017 - Inclusão do módulo e ação logado no oracle
    --                          Inclusão da chamada de procedure em exception others
    --                          Colocado logs no padrão
    --                        ( Belli - Envolti - Chamado 719114)
    --    
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      vr_typ_saida  VARCHAR2(3);         --> Saída do comando no OS
      vr_dslstarq VARCHAR2(4000);        --> Lista de arquivos encontrados
      vr_lstarqre gene0002.typ_split;    --> Split de arquivos encontrados
      vr_nrseqarq craparb.nrseqarq%TYPE; --> Sequencia de gravação do arquivo
      vr_flchkret VARCHAR2(1);           --> Retorno S/N de validação do retorno atual X arquivo enviado
    BEGIN
  	  -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
    	GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_retorno_arquivo_cd');

      -- Inicializar sem tipo de log - Chamado 719114 - 07/08/2017      
      pr_dstiplog := NULL;    

      -- Inicializar quantidade de retornos
      pr_qtretorn := 0;
      -- Usamos rotina para listar os arquivos da pasta conforme padrão passado
      gene0001.pc_lista_arquivos(pr_path     => pr_dsdirrec   --> Dir busca
                                ,pr_pesq     => pr_nmarquiv   --> Chave busca(Padrão passado)
                                ,pr_listarq  => vr_dslstarq   --> Lista encontrada
                                ,pr_des_erro => pr_dscritic); --> Possível erro
      -- Se retorno erro:
      IF pr_dscritic IS NOT NULL THEN
      -- Ajuste rastrear Log - Chamado 719114 - 07/08/2017  
        pr_dscritic := 'pc_retorno_arquivo_cd - gene0001.pc_lista_arquivos - ' || pr_dscritic;
        RETURN;
      END IF;
      -- Separar a lista de arquivos encontradas com função existente
      vr_lstarqre := fn_quebra_string(pr_string => vr_dslstarq, pr_delimit => ',');
      -- Se não encontrou nenhum arquivo
      IF vr_lstarqre.count() = 0 THEN
        -- Gerar erro
        pr_dscritic := 'Arquivo ainda nao retornado pelo SERASA';
        -- Situação tratada como ocorrencia - Chamado 719114 - 07/08/2017
        pr_dstiplog := 'O';
        RETURN;
      END IF;
      -- Para cada arquivo encontrado na pasta
      FOR vr_idx IN 1..vr_lstarqre.count LOOP
        -- Se houver função para checagem dos arquivos retornados
        IF pr_dsfnchrt IS NOT NULL THEN
          -- Buscar o rowid do arquivo de envio
          OPEN cr_rowid_arq(pr_idtpreme => pr_idtpreme
                           ,pr_dtmvtolt => pr_dtmvtolt
                           ,pr_nrseqarq => pr_nrseqarq);
          FETCH cr_rowid_arq
           INTO vr_rowid_arq;
          CLOSE cr_rowid_arq;
          -- Acionaremos dinamicamente esta função, que checa se o arquivo
          -- retornado está vinculado ao arquivo enviado ao Bureaux
          BEGIN
            vr_flchkret := fn_dinamic_function(pr_dsfnchrt,vr_rowid_arq,pr_dsdirrec||'/'||vr_lstarqre(vr_idx));
          EXCEPTION
            WHEN OTHERS THEN
              -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
              CECRED.pc_internal_exception; 
              pr_dscritic := 'Erro ao acionar funcao dinamica para checagem do retorno --> '||SQLERRM;
              RETURN;
          END;
          -- Se a função não validou o arquivo
          IF vr_flchkret != 'S' THEN
            -- Iremos ignorar o arquivo atual, pois ele é um retorno de outra remessa enviada
            continue;
          END IF;
        END IF;
        -- Chamamos a rotina que direciona a gravação na tabela de arquivos
        pc_insere_arquivo_bureaux(pr_idtpreme => pr_idtpreme        --> Tipo da remessa
                                 ,pr_dtmvtolt => pr_dtmvtolt        --> Data da remessa
                                 ,pr_nrseqant => pr_nrseqarq        --> Se veio informação, é uma Multi-Retorno e precisamos gravar o vinculo
                                 ,pr_cdestarq => 4                  --> Estágio do evento (Retorno)
                                 ,pr_nmdireto => pr_dsdirrec        --> Diretório do arquivo
                                 ,pr_nmarquiv => vr_lstarqre(vr_idx)--> Nome do arquivo
                                 ,pr_nrseqarq => vr_nrseqarq        --> Seq do arquivo gravado
                                 ,pr_dscritic => pr_dscritic);      --> Retorno de crítica
        -- Tratar retorno de erro
        IF pr_dscritic IS NOT NULL THEN
          -- Incrementar erro
          RETURN;
        END IF;
        -- Mover o arquivo da pasta recebe para recebidos
        gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||pr_dsdirrec||'/'||vr_lstarqre(vr_idx)||' '||pr_dsdirrcd
                                   ,pr_typ_saida   => vr_typ_saida
                                   ,pr_des_saida   => pr_dscritic);
        -- Se retornou erro, retornoar
        IF vr_typ_saida = 'ERR' THEN
          RETURN;
        END IF;
        -- Inserir evento na remessa para indicar o encontro do arquivo
        pc_insere_evento_remessa(pr_idtpreme => pr_idtpreme
                                ,pr_dtmvtolt => pr_dtmvtolt
                                ,pr_nrseqarq => vr_nrseqarq
                                ,pr_cdesteve => 4 --> Fixo - Retorno
                                ,pr_flerreve => 0 --> Sucesso
                                ,pr_dslogeve => 'Arquivo '||vr_lstarqre(vr_idx)||' retornado com sucesso.'
                                ,pr_dscritic => pr_dscritic);
	      -- Retorno do módulo e ação logado - Chamado 719114 - 21/07/2017
  	    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_retorno_arquivo_cd 1');  
        -- Se retornou erro
        IF pr_dscritic IS NOT NULL THEN
          RETURN;
        END IF;
        -- Gravar
        COMMIT;
        -- Incrementar quantidade retornada
        pr_qtretorn := pr_qtretorn + 1;
      END LOOP; --> Arquivos retornados
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
        CECRED.pc_internal_exception; 
        -- Retorna o erro para a procedure chamadora
        pr_dscritic := 'pc_retorno_arquivo_cd - '||SQLERRM;
    END;
  END pc_retorno_arquivo_cd;


  -- Rotina retornar o arquivo ao FTP passado
  PROCEDURE pc_retorno_arquivo_ftp(pr_idtpreme IN crapcrb.idtpreme%TYPE --> Tipo da Remessa
                                  ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data da Remessa
                                  ,pr_nrseqarq IN craparb.nrseqarq%TYPE --> Sequencia do arq da remessa (Quando Multi-Retorno)
                                  ,pr_nmarquiv IN craparb.nmarquiv%TYPE --> Nome do padrão de retorno
                                  ,pr_idenvseg IN crapcrb.idtpreme%TYPE --> Indicador de utilizacao de protocolo seguro (SFTP)
                                  ,pr_ftp_site IN VARCHAR2              --> Site de acesso ao FTP
                                  ,pr_ftp_user IN VARCHAR2              --> Usuário para acesso ao FTP
                                  ,pr_ftp_pass IN VARCHAR2              --> Senha para acesso ao FTP
                                  ,pr_ftp_path IN VARCHAR2              --> Pasta no FTP para busca do arquivo
                                  ,pr_dsfnchrt IN crappbc.dsfnchrt%TYPE --> Função que faz a checagem dos retornos para garatir a relação com o envio
                                  ,pr_key_path IN VARCHAR2              --> Caminho da chave de criptografia quando o (SFTP) usar.
                                  ,pr_passphra IN VARCHAR2              --> Senha da chave de criptografica quando o (SFTP) usar.
                                  ,pr_qtretorn OUT NUMBER               --> Numero de arquivos retornados
                                  ,pr_dscritic OUT VARCHAR2) IS         --> Retorno de crítica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_retorno_arquivo_ftp
    --  Sistema  : CYBER
    --  Sigla    : CRED
    --  Autor    : Marcos - SUPERO
    --  Data     : Dezembro/2014.                   Ultima atualizacao: 10/10/2017
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Buscar os arquivos no FTP passado conforme chave de pesquisa.
    --             Ao encontrar, gravar os mesmos na tabela de arquivos.
    -- Alteracoes: 07/04/2015 - Alteração para recebimento e acionamento de função de checagem de retorno
    --                          para validar se o retorno encontrado é vinculado ao arquivo enviado (Marcos-Supero)
    --
    --             23/03/2016 - Adicionado tratamento para identificar se é necessário fazer
    --                          a chamada do ftp seguro conforme solicitado no chamado 412682. (Kelvin)
    --
    --             21/07/2017 - Inclusão do módulo e ação logado no oracle
    --                          Inclusão da chamada de procedure em exception others
    --                          Colocado logs no padrão
    --                        ( Belli - Envolti - Chamado 719114)
    --
    --             10/10/2017 - M434 - Adicionar dois novos parâmetros para atender o SPC/Brasil que usa chave 
    --                          de criptografia para o acesso ao SFTP. (Oscar)
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      vr_dir_temp VARCHAR2(4000);        -- Armazenar o diretório de arquivos temporário
      vr_script_ftp VARCHAR2(4000);      --> Script FTP
      vr_comand_ftp VARCHAR2(1000);      --> Comando montado do envio ao FTP
      vr_typ_saida  VARCHAR2(3);         --> Saída de erro
      vr_dslstarq VARCHAR2(4000);        --> Lista de arquivos encontrados
      vr_lstarqre gene0002.typ_split;    --> Split de arquivos encontrados
      vr_nrseqarq craparb.nrseqarq%TYPE; --> Sequencia de gravação do arquivo
      vr_flchkret VARCHAR2(1);           --> Retorno S/N de validação do retorno atual X arquivo enviado

  	  -- Excluida variavel vr_idprglog - Chamado 719114 - 07/08/2017  
      
  	  -- Variaveis para módulo e ação logado - Chamado 719114 - 21/07/2017 
      vr_modulo    VARCHAR2(100);
      vr_acao      VARCHAR2(100);
      vr_idprglog PLS_INTEGER := 0;
      vr_prmkeysftp VARCHAR2(4000);      --> Paramentros de chave de criptografia apenas para SFTP
    BEGIN
  	  -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
      DBMS_APPLICATION_INFO.read_module(module_name => vr_modulo, action_name => vr_acao);
      vr_acao := 'CYBE0002.pc_retorno_arquivo_ftp';
    	GENE0001.pc_set_modulo(pr_module => vr_modulo, pr_action => vr_acao);      

      -- Inicializar quantidade de retornos
      pr_qtretorn := 0;
      vr_prmkeysftp := '';
      -- Buscar diretório temporário
      vr_dir_temp := gene0001.fn_param_sistema('CRED',0,'AUTBUR_DIR_TEMP');
      -- Primeiramente limpamos a pasta temporária (PArâmetro AUTBUR_DIR_TEMP)
      pc_limpeza_diretorio(pr_nmdireto => vr_dir_temp   --> Diretório para limpeza
                          ,pr_dscritic => pr_dscritic);
      -- Testar retorno de erro
      IF pr_dscritic IS NOT NULL THEN
        -- Incrementar o erro
        RETURN;
      END IF;
      
      IF pr_idenvseg = 'S' THEN
        -- Buscar script para conexão FTP
        vr_script_ftp := gene0001.fn_param_sistema('CRED',0,'AUTBUR_SCRIPT_SFTP');
        vr_prmkeysftp := ' -caminhoarquivochave ' || CHR(39) || pr_key_path|| CHR(39) || ' -senhadachave ' || pr_passphra;
      ELSE 
        -- Buscar script para conexão FTP
        vr_script_ftp := gene0001.fn_param_sistema('CRED',0,'AUTBUR_SCRIPT_FTP');   
      END IF;                      
      
      
      -- Preparar o comando de conexão e envio ao FTP
      vr_comand_ftp := vr_script_ftp
                    || ' -recebe'
                    || ' -srv '          || pr_ftp_site
                    || ' -usr '          || pr_ftp_user
                    || ' -pass '         || pr_ftp_pass
                    || ' -arq '          || CHR(39) || pr_nmarquiv || CHR(39)
                    || ' -dir_local '    || CHR(39) || vr_dir_temp || CHR(39)
                    || ' -dir_remoto '   || CHR(39) || pr_ftp_path || CHR(39)
                    || ' -log /usr/coop/cecred/log/proc_autbur.log'
                    || vr_prmkeysftp;
                      
      
      -- Chama procedure de envio e recebimento via ftp
      GENE0001.pc_OScommand_Shell(pr_des_comando => vr_comand_ftp
                                 ,pr_typ_saida   => vr_typ_saida
                                 ,pr_des_saida   => pr_dscritic);

      -- Se ocorreu erro dar RAISE
      IF vr_typ_saida = 'ERR' THEN
        RETURN;
      ELSE
        -- Agora, listamos todos os arquivos baixados ao diretório passado
        gene0001.pc_lista_arquivos(pr_path     => vr_dir_temp   --> Dir busca
                                  ,pr_pesq     => NULL          --> Chave busca(Tudo)
                                  ,pr_listarq  => vr_dslstarq   --> Lista encontrada
                                  ,pr_des_erro => pr_dscritic); --> Possível erro
        -- Se retorno erro:
        IF pr_dscritic IS NOT NULL THEN
          RETURN;
        END IF;
        -- Separar a lista de arquivos encontradas com função existente
        vr_lstarqre := fn_quebra_string(pr_string => vr_dslstarq, pr_delimit => ',');
        -- Se não encontrou nenhum arquivo
        IF vr_lstarqre.count() = 0 THEN
          -- Atualização de log para o padrão - 21/07/2017 - Chamado 719114
          -- Gravar na tabela tbgen_prglog_ocorrencia e retornar para o programa
          pc_controla_log_batch(pr_dstiplog   => 'O',
                                pr_dscritic   => 'Retorno ainda nao encontrado no FTP.' ||
                                                 ' - pr_idtpreme: ' || pr_idtpreme ||
                                                 ' ,pr_dtmvtolt: ' || pr_dtmvtolt ||
                                                 ' ,pr_nrseqarq: ' || pr_nrseqarq ||
                                                 ' ,arq: '         || pr_nmarquiv || 
                                                 ' ,dir_local: '   || vr_dir_temp || 
                                                 ' ,dir_remoto: '  || pr_ftp_path,
                                pr_cdprograma => 'jbcyb_controle_remessas');
          RETURN;
        END IF;
        -- Para cada arquivo encontrado no ZIP
        FOR vr_idx IN 1..vr_lstarqre.count LOOP
          -- Se houver função para checagem dos arquivos retornados
          IF pr_dsfnchrt IS NOT NULL THEN
            -- Buscar o rowid do arquivo de envio
            OPEN cr_rowid_arq(pr_idtpreme => pr_idtpreme
                             ,pr_dtmvtolt => pr_dtmvtolt
                             ,pr_nrseqarq => pr_nrseqarq);
            FETCH cr_rowid_arq
             INTO vr_rowid_arq;
            CLOSE cr_rowid_arq;
            -- Acionaremos dinamicamente esta função, que checa se o arquivo
            -- retornado está vinculado ao arquivo enviado ao Bureaux
            BEGIN
              vr_flchkret := fn_dinamic_function(pr_dsfnchrt,vr_rowid_arq,vr_dir_temp||'/'||vr_lstarqre(vr_idx));
            EXCEPTION
              WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
                CECRED.pc_internal_exception; 
                pr_dscritic := 'Erro ao acionar funcao dinamica para checagem do retorno --> '||SQLERRM;
                RETURN;
            END;
            -- Se a função não validou o arquivo
            IF vr_flchkret != 'S' THEN
              -- Iremos ignorar o arquivo atual, pois ele é um retorno de outra remessa enviada
              continue;
            END IF;
          END IF;
          -- Chamamos a rotina que direciona a gravação na tabela de arquivos
          pc_insere_arquivo_bureaux(pr_idtpreme => pr_idtpreme        --> Tipo da remessa
                                   ,pr_dtmvtolt => pr_dtmvtolt        --> Data da remessa
                                   ,pr_nrseqant => pr_nrseqarq        --> Se veio informação, é uma Multi-Retorno e precisamos gravar o vinculo
                                   ,pr_cdestarq => 4                  --> Estágio do evento (Retorno)
                                   ,pr_nmdireto => vr_dir_temp        --> Diretório do arquivo
                                   ,pr_nmarquiv => vr_lstarqre(vr_idx)--> Nome do arquivo
                                   ,pr_nrseqarq => vr_nrseqarq        --> Seq do arquivo gravado
                                   ,pr_dscritic => pr_dscritic);      --> Retorno de crítica
          -- Tratar retorno de erro
          IF pr_dscritic IS NOT NULL THEN
            RETURN;
          END IF;
          -- Inserir evento na remessa para indicar o encontro do arquivo ZIP
          pc_insere_evento_remessa(pr_idtpreme => pr_idtpreme
                                  ,pr_dtmvtolt => pr_dtmvtolt
                                  ,pr_nrseqarq => vr_nrseqarq
                                  ,pr_cdesteve => 4 --> Fixo - Retorno
                                  ,pr_flerreve => 0 --> Sucesso
                                  ,pr_dslogeve => 'Arquivo '||vr_lstarqre(vr_idx)||' retornado com sucesso.'
                                  ,pr_dscritic => pr_dscritic);
	        -- Retorno do módulo e ação logado - Chamado 719114 - 21/07/2017
  	      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_retorno_arquivo_ftp 1');  
          -- Se retornou erro
          IF pr_dscritic IS NOT NULL THEN
            RETURN;
          END IF;
          -- Gravar
          COMMIT;
          -- Incrementar quantidade retornada
          pr_qtretorn := pr_qtretorn + 1;
        END LOOP; --> Arquivos retornados
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
        CECRED.pc_internal_exception; 
        -- Retorna o erro para a procedure chamadora
        pr_dscritic := 'Erro --> rotina CYBE0002.pc_retorno_arquivo_ftp --> '||SQLERRM;
    END;
  END pc_retorno_arquivo_ftp;

  -- Rotina para direcionar a devolução sob-demanda dos retornos a PPWare
  PROCEDURE pc_devolu_demanda(pr_idtpreme IN crapcrb.idtpreme%TYPE --> Tipo da Remessa
                             ,pr_dtmvtolt IN crapcrb.dtmvtolt%TYPE --> Data da remessa
                             ,pr_dscritic OUT VARCHAR2) IS         --> Retorno de crítica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_devolu_demanda
    --  Sistema  : CYBER
    --  Sigla    : CRED
    --  Autor    : Marcos - SUPERO
    --  Data     : Outubro/2015.                   Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Efetuar a decolução sob demanda dos retornos conforme eles chegam
    -- Alteracoes:
    --
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      -- Buscar caracteristicas do Bureaux
      CURSOR cr_crappbc IS
        SELECT pbc.dsdirret
              ,pbc.dsfnrndv
          FROM crappbc pbc
         WHERE pbc.idtpreme = pr_idtpreme;
      rw_pbc cr_crappbc%ROWTYPE;

      -- Arquivos retornados deste Bureaux e
      -- vinculados a remessas não canceladas
      CURSOR cr_arb IS
        SELECT arb.nmarquiv
              ,arb.blarquiv
              ,arb.nrseqarq
              ,arb.rowid
              ,arb.dtmvtolt
          FROM craparb arb
              ,crapcrb crb
         WHERE crb.idtpreme = arb.idtpreme
           AND crb.dtmvtolt = arb.dtmvtolt
           AND crb.dtcancel IS NULL --> Rem não cancelada
           AND arb.dtcancel IS NULL --> Arq não cancelado
           AND arb.idtpreme = pr_idtpreme
           AND arb.dtmvtolt = pr_dtmvtolt
           AND arb.cdestarq = 4 --> Retorno
           AND arb.flproces = 0;--> Não processados ainda
      --
      vr_nmarquiv   VARCHAR2(100);         --> Nome temporário dos arquivos
      vr_dir_temp   VARCHAR2(1000);        --> Dir temporário para trabalho com os arquivos
      vr_typ_said   VARCHAR2(3);           --> Retorno das chamadas ao SO
      --
    BEGIN
  	  -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
    	GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_devolu_demanda');      

      -- Buscar caracteristicas do Bureaux
      OPEN cr_crappbc;
      FETCH cr_crappbc
       INTO rw_pbc;
      CLOSE cr_crappbc;
      -- Buscar dir temporário
      vr_dir_temp := gene0001.fn_param_sistema('CRED',0,'AUTBUR_DIR_TEMP');
      -- Limpar diretório temporário
      pc_limpeza_diretorio(pr_nmdireto => vr_dir_temp   --> Diretório para limpeza
                          ,pr_dscritic => vr_dscritic);
      -- Testar retorno de erro
      IF vr_dscritic IS NOT NULL THEN
        raise vr_excerror;
      END IF;

      -- Buscamos todos os arquivos de retorno não processados
      FOR rw_arb IN cr_arb LOOP
        -- Se há função para renomeamento do arquivo antes de devolver a PPWare
        IF rw_pbc.dsfnrndv is not NULL THEN
          -- Chamamos a mesma dinamicamente para renomeamento do arquivo
          BEGIN
            vr_nmarquiv := fn_dinamic_function(rw_pbc.dsfnrndv,rw_arb.rowid);
          EXCEPTION
            WHEN OTHERS THEN
              -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
              CECRED.pc_internal_exception; 
              -- Devemos inserir o evento do erro e
              pc_insere_evento_remessa(pr_idtpreme => pr_idtpreme
                                      ,pr_dtmvtolt => rw_arb.dtmvtolt
                                      ,pr_nrseqarq => rw_arb.nrseqarq
                                      ,pr_cdesteve => 5 --> Fixo - Devolução
                                      ,pr_flerreve => 1 --> Erro
                                      ,pr_dslogeve => 'Erro ao chamar funcao para renomeamento do arquivo a devolver: '||SQLERRM
                                      ,pr_dscritic => pr_dscritic);
              -- Gravamos
              COMMIT;
              raise vr_excerror;
          END;
        ELSE
          -- Mantemos o nome original
          vr_nmarquiv := rw_arb.nmarquiv;
        END IF;
        -- Devemos criar o arquivo na pasta temp, usando função que converte BLOB em arquivo
        gene0002.pc_blob_para_arquivo(pr_blob     => rw_arb.blarquiv --> Bytes do arquivo
                                     ,pr_caminho  => vr_dir_temp     --> Dir temp
                                     ,pr_arquivo  => vr_nmarquiv     --> Nome a devolver
                                     ,pr_des_erro => vr_dscritic);
  	    -- Retorna do módulo e ação logado - Chamado 719114 - 21/07/2017
      	GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_devolu_demanda');
        -- Se retornou erro, incrementar a mensagem e retornoar
        IF vr_dscritic IS NOT NULL THEN
          -- Devemos inserir o evento do erro e
          pc_insere_evento_remessa(pr_idtpreme => pr_idtpreme
                                  ,pr_dtmvtolt => rw_arb.dtmvtolt
                                  ,pr_nrseqarq => rw_arb.nrseqarq
                                  ,pr_cdesteve => 2 --> Fixo - Preparação
                                  ,pr_flerreve => 1 --> Erro
                                  ,pr_dslogeve => vr_dscritic
                                  ,pr_dscritic => pr_dscritic);
          -- Gravamos
          COMMIT;
          raise vr_excerror;
        END IF;
        -- Usarei a variavel de critica para montar o log que será enviado
        -- Obs: Quando o arquivo for renomeado, a mensagem é diferenciada
        IF vr_nmarquiv <> rw_arb.nmarquiv THEN
          vr_dscritic := 'Arquivo '||rw_arb.nmarquiv||' devolvido como '||vr_nmarquiv||' apos retorno';
        ELSE
          vr_dscritic := 'Arquivo '||rw_arb.nmarquiv||' devolvido apos retorno.';
        END IF;
        -- Inserir evento na remessa para indicar a geração do ZIP a remessa
        pc_insere_evento_remessa(pr_idtpreme => pr_idtpreme
                                ,pr_dtmvtolt => rw_arb.dtmvtolt
                                ,pr_nrseqarq => rw_arb.nrseqarq
                                ,pr_cdesteve => 5 --> Fixo - Encerramento
                                ,pr_flerreve => 0 --> Sucesso
                                ,pr_dslogeve => vr_dscritic
                                ,pr_dscritic => vr_dscritic);
        -- Se retornou erro
        IF vr_dscritic IS NOT NULL THEN
          -- Se houve erro, temos de desfazer essa atualização, senão
          -- o arquivo poderá ficar marcado como devolvido só que não
          ROLLBACK;
          -- Devemos inserir o evento do erro e
          pc_insere_evento_remessa(pr_idtpreme => pr_idtpreme
                                  ,pr_dtmvtolt => rw_arb.dtmvtolt
                                  ,pr_nrseqarq => rw_arb.nrseqarq
                                  ,pr_cdesteve => 2 --> Fixo - Preparação
                                  ,pr_flerreve => 1 --> Erro
                                  ,pr_dslogeve => vr_dscritic
                                  ,pr_dscritic => pr_dscritic);
          -- Gravamos
          COMMIT;
          raise vr_excerror;
        END IF;
        -- Atualizamos o arquivo como processado e guardar também o resultado do renato
        BEGIN
          UPDATE craparb
             SET flproces = 1
                ,nmarqren = decode(rw_pbc.dsfnrndv,NULL,NULL,vr_nmarquiv)
           WHERE ROWID = rw_arb.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
            CECRED.pc_internal_exception;
            
            -- Se houve erro, temos de desfazer essa atualização, senão
            -- o arquivo poderá ficar marcado como devolvido só que não
            ROLLBACK;
            -- Montar descrição
            vr_dscritic := 'Erro ao atualizar situação do arquivo de retorno: '||SQLERRM;
            -- Devemos inserir o evento do erro e
            pc_insere_evento_remessa(pr_idtpreme => pr_idtpreme
                                    ,pr_dtmvtolt => rw_arb.dtmvtolt
                                    ,pr_nrseqarq => rw_arb.nrseqarq
                                    ,pr_cdesteve => 2 --> Fixo - Preparação
                                    ,pr_flerreve => 1 --> Erro
                                    ,pr_dslogeve => vr_dscritic
                                    ,pr_dscritic => pr_dscritic);
            -- Gravamos
            COMMIT;
            raise vr_excerror;
        END;

        -- Mover do diretório temp ao final
        gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_dir_temp||'/'||vr_nmarquiv||' '||rw_pbc.dsdirret
                                   ,pr_typ_saida   => vr_typ_said
                                   ,pr_des_saida   => vr_dscritic);
        -- Testar retorno de erro
        IF vr_typ_said = 'ERR' THEN
          -- Retornar e desfazer as alterações
          ROLLBACK;
          raise vr_excerror;
        END IF;

        -- Se não houve erro, então commitamos para elimiar o arquivo da lista a retornar
        COMMIT;

      END LOOP;

    EXCEPTION
      WHEN vr_excerror THEN
        -- Devolvemos o problema
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
        CECRED.pc_internal_exception;
        
        -- Retorna o erro para a procedure chamadora
        pr_dscritic := 'Erro --> na rotina CYBE0002.pc_devolu_demanda --> '||SQLERRM;
    END;
  END pc_devolu_demanda;

  -- Inclusão do parâmetro tipo de log - Chamado 719114 - 07/08/2017
  -- Rotina para preparar e direcionar o retorno dos arquivos da remessa
  PROCEDURE pc_retorno_remessa(pr_idtpreme IN crapcrb.idtpreme%TYPE --> Tipo da Remessa
                              ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE --> Data da Remessa
                              ,pr_dscritic OUT VARCHAR2             --> Retorno de crítica
                              ,pr_dstiplog OUT VARCHAR2             --> Tipo de Log
                                ) IS  
                                     
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_retorno_remessa
    --  Sistema  : CYBER
    --  Sigla    : CRED
    --  Autor    : Marcos - SUPERO
    --  Data     : Dezembro/2014.                   Ultima atualizacao: 10/10/2017
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Identificar o tipo de remessa, buscar informações específicas e chamar
    --             as rotinas responsáveis pelo retorno da remessa conforme seu tipo.
    --
    -- Alteracoes: 06/04/2015 - Passagem da função de checagem do retorno (Marcos-Supero)
    --
    --             07/10/2015 - PRJ210 - Remoção de parâmetro global para parâmetro por Bureaux
    --                          e também devolução no retorno sob-demanda (Marcos-Supero)
    --
    --             21/07/2017 - Inclusão do módulo e ação logado no oracle
    --                          Inclusão da chamada de procedure em exception others
    --                          Colocado logs no padrão
    --                        ( Belli - Envolti - Chamado 719114)
    --
    --             10/10/2017 - M434 - Adicionar novos parametros para o SPC Brasil neste momento será fixo em caracter 
    --                         emergencial posteriormente deverá ser criado parametros na tela LOGRBC. (Oscar)
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      -- Busca das informações para retorno da remessa
      CURSOR cr_crb IS
        SELECT crb.rowid
              ,pbc.qthorret
              ,pbc.dssitftp
              ,pbc.dsusrftp
              ,pbc.dspwdftp
              ,pbc.dsdrrftp
              ,pbc.dsdrrecd
              ,pbc.dsdrrtcd
              ,pbc.dsfnburt
              ,pbc.idtpenvi
              ,nvl(pbc.idopreto,'S') idopreto
              ,pbc.dsfnchrm
              ,pbc.flremseq
              ,pbc.dsfnchrt
              ,pbc.qtinterr
              ,pbc.idtpsoli
              ,pbc.idenvseg
          FROM crapcrb crb
              ,crappbc pbc
         WHERE crb.idtpreme = pr_idtpreme
           AND crb.dtmvtolt = pr_dtmvtolt
           AND crb.idtpreme = pbc.idtpreme;
      rw_crb cr_crb%ROWTYPE;
      -- VAriáveis auxiliares
      vr_nmarquiv VARCHAR2(100); --> Nome do arquivo de retorno
      -- Para reaproveitamento de código, a query abaixo irá
      -- trazer dois grupos de informação:
      -- 1º Quando a remessa possui multi-retorno, traremos
      --    todos os arquivos enviados e que não tem o retorno
      --    ainda.
      -- 2º QUando a remessa possui retorno únivo, traremos
      --    apenas o rowid da capa da remessa, pois esta
      --    informação que deve ser usada para a busca do retorno

      CURSOR cr_retor(pr_idopreto crappbc.idopreto%TYPE) IS
        -- Arquivos de remessas Multi-Retorno
        SELECT arb.nrseqarq
              ,arb.rowid
          FROM craparb arb
         WHERE arb.idtpreme = pr_idtpreme
           AND arb.dtmvtolt = pr_dtmvtolt
           AND pr_idopreto = 'M' --> Bureaux Multi-Retorno
           AND arb.cdestarq = 3 --> Envio
           AND arb.flproces = 1 --> Processados
           AND arb.dtcancel IS NULL --> Arquivo não cancelado
           -- Não retornado ainda
           AND NOT EXISTS(SELECT 1
                            FROM craparb arbR
                           WHERE arbR.idtpreme = arb.idtpreme
                             AND arbR.dtmvtolt = arb.dtmvtolt
                             AND arbR.Nrseqant = arb.nrseqarq)
        --
        UNION
        -- Remessas retorno único
        SELECT to_number(NULL) nrseqarq
              ,crb.rowid
          FROM crapcrb crb
         WHERE crb.idtpreme = pr_idtpreme
           AND crb.dtmvtolt = pr_dtmvtolt
           AND pr_idopreto = 'U' --> Bureaux Retorno Único
           -- Sem retorno ainda
           AND NOT EXISTS(SELECT 1
                            FROM craparb arbR
                           WHERE arbR.idtpreme = crb.idtpreme
                             AND arbR.dtmvtolt = crb.dtmvtolt
                             AND arbR.cdestarq = 4); --> Retorno

      -- Busca do horário do ultimo evento de envio com sucesso da remessa
      CURSOR cr_erb_ult_eve(pr_idtpreme crapcrb.idtpreme%TYPE
                           ,pr_dtmvtolt crapcrb.dtmvtolt%TYPE
                           ,pr_nrseqarq craparb.nrseqarq%TYPE
                           ,pr_cdesteve craperb.cdesteve%TYPE
                           ,pr_flerreve craperb.flerreve%TYPE) IS
        SELECT MAX(erb.dtexeeve)
          FROM craperb erb
         WHERE erb.idtpreme = pr_idtpreme
           AND erb.dtmvtolt = pr_dtmvtolt
           AND erb.cdesteve = pr_cdesteve
           AND erb.flerreve = pr_flerreve
           -- Podemos ou não ter a sequencia do arquivo
           AND nvl(erb.nrseqarq,0) = nvl(pr_nrseqarq,0);
      vr_max_dtexeeve DATE;

      -- Busca de outra remessa pendente e anterior a passada
      CURSOR cr_crb_out(pr_idtpreme crapcrb.idtpreme%TYPE
                       ,pr_dtmvtolt crapcrb.dtmvtolt%TYPE
                       ,pr_dschvrem VARCHAR2
                       ,pr_idopreto crappbc.idopreto%TYPE) IS
        SELECT nvl(arb.nmarqren,arb.nmarquiv)
          FROM craparb arb
              ,crapcrb crb
         WHERE arb.idtpreme = crb.idtpreme
           AND arb.dtmvtolt = crb.dtmvtolt
           AND arb.idtpreme = pr_idtpreme
           AND arb.dtmvtolt < pr_dtmvtolt
           AND ( pr_dschvrem is NULL OR arb.nmarquiv LIKE pr_dschvrem )
           AND arb.cdestarq = 3     --> Remessa de envio
           AND arb.dtcancel IS NULL --> Arquivo não cancelado
           AND crb.dtcancel IS NULL --> Remessa não cancelada
           -- E não há o retorno ainda
           AND NOT EXISTS(SELECT 1
                            FROM craparb arbR
                           WHERE arbR.idtpreme = arb.idtpreme
                             AND arbR.dtmvtolt = arb.dtmvtolt
                             -- Para multi verificamos a hierarquia
                             -- Para unicas deve haver ao menos um arquivo de retorno (Estágio 4)
                             AND ((pr_idopreto = 'M' AND arbR.Nrseqant = arb.nrseqarq)
                                  OR
                                  (pr_idopreto = 'U' AND arbR.Cdestarq = 4)
                                 ));
      vr_nmarquiv_penden craparb.nmarquiv%TYPE;

      -- Indicar que já houve o log de inicio de retorno
      vr_fllogeve BOOLEAN := FALSE;
      -- String para armazenar o resultado da funçaõ
      -- que retorna o padrão de busca da chave da remessa
      vr_dschvrem VARCHAR2(4000);
      -- Quantidade retornada
      vr_qtretorn NUMBER := 0;
      vr_qtretaux NUMBER;
      --listagem de erros para montagem do e-mail
      vr_dslsterr VARCHAR2(4000);
      
      -- Variavel para tratar o parâmetro tipo de log - Chamado 719114 - 07/08/2017
      vr_dstiplog VARCHAR2(1) := NULL;
      vr_key_path VARCHAR2(4000);
      vr_passphra VARCHAR2(4000);
    BEGIN
  	  -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
    	GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_retorno_remessa');

      -- inicializar parâmetro tipo de log - Chamado 719114 - 07/08/2017      
      pr_dstiplog := NULL; 

      -- Busca das informações para retorno da remessa
      OPEN cr_crb;
      FETCH cr_crb
       INTO rw_crb;
      CLOSE cr_crb;

      -- Laço genérico que irá ser usado para reaproveitamento de código.
      -- Obs: Neste cursor poderemos ter:
      --      Quando Multi-Retorno: todos os arquivos da remessa que
      --                            ainda não tiveram retorno
      --      Quando Unico :        Os dados da Remessa
      FOR rw_ret IN cr_retor(pr_idopreto => rw_crb.idopreto) LOOP
        -- Devemos observar também os tempos para retorno, ou seja, somente iremos
        -- prosseguir se o tempo médio de retorno após o envio foi alcançado. Para tal:
        -- Buscamos do cadastro do Bureaux o tempo de retorno (em horas) .
        -- Buscamos o horário do ultimo evento de envio com sucesso da remessa
        vr_max_dtexeeve := NULL;
        OPEN cr_erb_ult_eve(pr_idtpreme => pr_idtpreme
                           ,pr_dtmvtolt => pr_dtmvtolt
                           ,pr_nrseqarq => rw_ret.nrseqarq
                           ,pr_cdesteve => 3   --> Envio
                           ,pr_flerreve => 0); --> Sem erro
        FETCH cr_erb_ult_eve
         INTO vr_max_dtexeeve;
        CLOSE cr_erb_ult_eve;

        -- Com o último evento de envio, somente continuaremos se a quantidade de horas
        -- decorridas entre este horário e a hora atual, seja superior a quantidades de horas
        -- média para início da checagem do retorno, buscada acima conforme a remessa
        IF NOT ((SYSDATE - vr_max_dtexeeve)*24 > rw_crb.qthorret) THEN
          -- Pular a próxima remessa pois ainda não se passaram "n" horas de aguardo do retorno
          continue;
        END IF;

        -- Também devemos checar se já não ocorreu uma tentativa de retorno na ultima hora, ou seja,
        -- as novas tentativas de retorno só devem ocorrer duas horas (parâmetro AUTBUR_QTD_INTERV_ERR)
        -- após o insucesso da anterior.
        -- Então, novamente vamos a tabela de eventos para buscar desta vez quando foi a ultima tentativa
        -- de retorno com erro:
        vr_max_dtexeeve := NULL;
        OPEN cr_erb_ult_eve(pr_idtpreme => pr_idtpreme
                           ,pr_dtmvtolt => pr_dtmvtolt
                           ,pr_nrseqarq => rw_ret.nrseqarq
                           ,pr_cdesteve => 4   --> Retorno
                           ,pr_flerreve => 1); --> Com erro
        FETCH cr_erb_ult_eve
         INTO vr_max_dtexeeve;
        CLOSE cr_erb_ult_eve;
        -- Somente se houve retorno
        IF vr_max_dtexeeve IS NOT NULL THEN
          -- Validamos se a quantidade de horas decorridas do ultimo erro até agora é superior ao parâmetro
          -- que define o intervalo. Do contrário a nova checagem só deverá ocorrer na próxima hora.
          IF NOT ((SYSDATE - vr_max_dtexeeve)*24 > rw_crb.qtinterr) THEN
            -- Não é, vamos igorar esta remessa e checaremos na próxima hora
            continue;
          END IF;
        END IF;

        -- Se ainda não houve envio do evento
        IF NOT vr_fllogeve THEN
          -- Montar mensagem diferenciada caso já houve algo retorno antes
          vr_dsexiste := 'N';
          OPEN cr_exis_estagio(pr_idtpreme => pr_idtpreme
                              ,pr_dtmvtolt => pr_dtmvtolt
                              ,pr_cdesteve => 4); -- Retorno
          FETCH cr_exis_estagio
           INTO vr_dsexiste;
          CLOSE cr_exis_estagio;
          -- Se não houve nenhum retorno
          IF vr_dsexiste = 'N' THEN
            vr_dscritic := 'Iniciando checagem do retorno da remessa...';
          ELSE
            vr_dscritic := 'Retomando checagem do retorno da remessa...';
          END IF;
          -- Inserir log na tabela de eventos
          pc_insere_evento_remessa(pr_idtpreme => pr_idtpreme
                                  ,pr_dtmvtolt => pr_dtmvtolt
                                  ,pr_cdesteve => 4 --> Fixo - Retorno
                                  ,pr_flerreve => 0 --> Sucesso
                                  ,pr_dslogeve => vr_dscritic
                                  ,pr_dscritic => pr_dscritic);
	        -- Retorno do módulo e ação logado - Chamado 719114 - 21/07/2017
  	      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_retorno_remessa 1');  
          -- Se retornou erro, incrementar a mensagem e retornoar
          IF pr_dscritic IS NOT NULL THEN
            RETURN;
          END IF;
          -- Gravar evento
          COMMIT;
          -- Indicar que já enviamos o LOG
          vr_fllogeve := TRUE;
        END IF;

        -- Somente verificar predecessão se a remessa possuir este tipo de controle
        IF nvl(rw_crb.flremseq,0) = 1 THEN
          -- Para remessas Multi-Arquivos
          IF rw_crb.idopreto = 'M' THEN
            -- Devemos usar a função para buscar a chave desta remessa
            -- Isto é possível com a função DSFNCHRM, que deve ser chamada
            -- dinamicamente e retornará o texto padrão que define a chave
            -- da remessa e poderá ser usado para pesquisar se em outras
            -- datas, o mesmo arquivo está ainda pendente de retorno.
            -- Ex: CY_EMP01_00000228_envserasa.txt e CY_EMP01_00000227_envserasa.txt
            --     A função retornará CY_EMP01_%_envserasa.txt
            BEGIN
              vr_dschvrem := fn_dinamic_function(rw_crb.dsfnchrm,rw_ret.rowid);
            EXCEPTION
              WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
                CECRED.pc_internal_exception; 
                pr_dscritic := 'Erro ao acionar funcao dinamica para montar chave da remessa --> '||SQLERRM;
                RETURN;
            END;
          ELSE
            -- Para remessas com um único retorno, temos de garantir também que
            -- não há nenhuma outra remessa anterior e que ainda não foi retornada
            vr_dschvrem := NULL;
          END IF;
          -- Com a chave de busca, verificamos se existe remessa
          -- deste mesmo Bureaux em data anterior ao retorno (4)
          vr_nmarquiv_penden := NULL;
          OPEN cr_crb_out(pr_idtpreme => pr_idtpreme
                         ,pr_dtmvtolt => pr_dtmvtolt
                         ,pr_dschvrem => vr_dschvrem
                         ,pr_idopreto => rw_crb.idopreto);
          FETCH cr_crb_out
           INTO vr_nmarquiv_penden;
          CLOSE cr_crb_out;
          -- Se existir remessa anterior pendente
          IF vr_nmarquiv_penden IS NOT NULL THEN
            -- Adicionar no LOG para que seja explicito que não haverá
            -- retorno até esta remessa for recebida
            pc_insere_evento_remessa(pr_idtpreme => pr_idtpreme
                                    ,pr_dtmvtolt => pr_dtmvtolt
                                    ,pr_nrseqarq => rw_ret.nrseqarq
                                    ,pr_cdesteve => 4 --> Fixo - Retorno
                                    ,pr_flerreve => 1 --> Erro
                                    ,pr_dslogeve => 'Remessa aguardando recebimento de todas as remessas precedentes.'
                                    ,pr_dscritic => pr_dscritic);
	          -- Retorno do módulo e ação logado - Chamado 719114 - 21/07/2017
  	        GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_retorno_remessa 2');
            -- Se retornou erro, incrementar a mensagem e retornoar
            IF pr_dscritic IS NOT NULL THEN
              RETURN;
            END IF;
            -- Pular esta remessa e somente processar quando não
            -- houver nenhuma outra pendência
            COMMIT;
            continue;
          END IF;
        END IF;

        -- Montagem do padrão para busca do arquivo de retorno no Bureaux
        BEGIN
          vr_nmarquiv := fn_dinamic_function(rw_crb.dsfnburt,rw_ret.rowid);
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
            CECRED.pc_internal_exception;
            
            pr_dscritic := 'Ao acionar funcao dinamica para montar padrao de retorno do Bureaux - '||SQLERRM;
            RETURN;
        END;
        -- Esta função deverá obrigatoriamente retorno algum padrão de busca
        IF vr_nmarquiv IS NULL THEN
          pr_dscritic := 'Funcao '||rw_crb.dsfnburt||' nao trouxe padrao para retorno do Bureaux. Favor solicitar a equipe de TI a validacao da mesma! !';
          RETURN;
        END IF;

        -- Se chegou neste ponto, passamos por todas as consistências
        -- e podemos enfim, prosseguir com o processo de retorno
        IF rw_crb.idtpenvi = 'C' THEN
          -- Inclusão do parâmetro tipo de log - Chamado 719114 - 07/08/2017  
          -- Retorno via Connect Direct
          pc_retorno_arquivo_cd(pr_idtpreme => pr_idtpreme      --> Tipo da Remessa
                               ,pr_dtmvtolt => pr_dtmvtolt      --> Data da Remessa
                               ,pr_nrseqarq => rw_ret.nrseqarq  --> Sequencia do arq da remessa (Quando Multi-Retorno)
                               ,pr_dsdirrec => rw_crb.dsdrrecd  --> Diretório recebe
                               ,pr_dsdirrcd => rw_crb.dsdrrtcd  --> Diretório recebidos
                               ,pr_nmarquiv => vr_nmarquiv      --> Nome do padrão de retorno
                               ,pr_dsfnchrt => rw_crb.dsfnchrt  --> Função para checagem da ligação retorno X envio
                               ,pr_qtretorn => vr_qtretaux      --> Quantidade retornada
                               ,pr_dstiplog => vr_dstiplog      --> Tipo de Log
                               ,pr_dscritic => pr_dscritic);    --> Retorno de crítica
        ELSIF rw_crb.idtpenvi = 'F' THEN
          
          vr_key_path := NULL;
          vr_passphra := NULL;
          IF rw_crb.idenvseg = 'S' THEN
             vr_key_path := gene0001.fn_param_sistema('CRED',0, pr_idtpreme || '_BRASIL_KEYPATH');
             vr_passphra := gene0001.fn_param_sistema('CRED',0, pr_idtpreme || '_BRASIL_PASSPHR');
          END IF;
        
          -- Retorno via FTP
          pc_retorno_arquivo_ftp(pr_idtpreme => pr_idtpreme     --> Tipo da Remessa
                                ,pr_dtmvtolt => pr_dtmvtolt     --> Data da Remessa
                                ,pr_nrseqarq => rw_ret.nrseqarq --> Sequencia do arq da remessa (Quando Multi-Retorno)
                                ,pr_nmarquiv => vr_nmarquiv     --> Nome do padrão de retorno
                                ,pr_idenvseg => rw_crb.idenvseg --> Indicador de utilizacao de protocolo seguro (SFTP)
                                ,pr_ftp_site => rw_crb.dssitftp --> Site de acesso ao FTP
                                ,pr_ftp_user => rw_crb.dsusrftp --> Usuário para acesso ao FTP
                                ,pr_ftp_pass => rw_crb.dspwdftp --> Senha para acesso ao FTP
                                ,pr_ftp_path => rw_crb.dsdrrftp --> Pasta no FTP para busca do arquivo
                                ,pr_dsfnchrt => rw_crb.dsfnchrt --> Função para checagem da ligação retorno X envio
                                ,pr_key_path => vr_key_path     --> Caminho da chave de criptografia quando o (SFTP) usar.
                                ,pr_passphra => vr_passphra     --> Senha da chave de criptografica quando o (SFTP) usar.
                                ,pr_qtretorn => vr_qtretaux     --> Quantidade retornada
                                ,pr_dscritic => pr_dscritic);   --> Retorno de crítica
        END IF;
        -- Gravamos os eventos ocorridos
        COMMIT;

        -- Se houve retorno, incrementar
        vr_qtretorn := vr_qtretorn + vr_qtretaux;
        -- Se houve erro
        IF pr_dscritic IS NOT NULL THEN
          -- Então devemos inserir nos eventos
          pc_insere_evento_remessa(pr_idtpreme => pr_idtpreme
                                  ,pr_dtmvtolt => pr_dtmvtolt
                                  ,pr_nrseqarq => rw_ret.nrseqarq
                                  ,pr_cdesteve => 4 --> Fixo - Retorno
                                  ,pr_flerreve => 1 --> Erro
                                  ,pr_dslogeve => pr_dscritic
                                  ,pr_dscritic => vr_dscritic); --> Usamos a auxiliar para evitar sobescrita
	        -- Retorno do módulo e ação logado - Chamado 719114 - 21/07/2017
  	      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_retorno_remessa 3');                                  
          -- Se retornou erro, incrementar a mensagem e retornoar
          IF vr_dscritic IS NOT NULL THEN
            RETURN;
          END IF;
          -- Gravar evento
          COMMIT;
        END IF;
        -- Se houve erro em remessas Multi-Retorno, apenas guardamos o erro e continuamos
        -- pois é necessário testar todos os retorno antes de sair. QUando for um só
        -- retorno, só haverá um registro neste loop e logo abaixo sairemos
        IF pr_dscritic IS NOT NULL AND rw_crb.idopreto = 'M' THEN
          -- Incrementamos a listagem de erros para montagem do e-mail
          vr_dslsterr := vr_dslsterr || '<br>Nao foi possivel retornar '||vr_nmarquiv||'. Motivo: ' || pr_dscritic;
        END IF;
      END LOOP;

      -- Se houve algum retorno
      IF vr_qtretorn > 0 THEN
        -- Enviar ao log genérico
        pc_insere_evento_remessa(pr_idtpreme => pr_idtpreme
                                ,pr_dtmvtolt => pr_dtmvtolt
                                ,pr_cdesteve => 4 --> Fixo - Retorno
                                ,pr_flerreve => 0 -- Sucesso
                                ,pr_dslogeve => 'Total de arquivos recebidos do Bureaux: '||vr_qtretorn
                                ,pr_dscritic => vr_dscritic);
	      -- Retorno do módulo e ação logado - Chamado 719114 - 21/07/2017
  	    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_retorno_remessa 4');
        -- Se a remessa for do tipo de controle sob-demanda
        IF rw_crb.idtpsoli = 'D' THEN
          -- Acionamos a rotina que faz a devolução de remessas sob-demanda
          -- Chegando neste ponto, temos remessas retornadas do Bureaux
          -- então procedemos com encerramento da remessa com a cópia dos
          -- arquivos retornados ao Cyber e atualização da situação
          pc_devolu_demanda(pr_idtpreme => pr_idtpreme
                           ,pr_dtmvtolt => pr_dtmvtolt
                           ,pr_dscritic => pr_dscritic);
          -- Efetuar gravação
          COMMIT;
        END IF;
      END IF;

      -- Gravar eventos ocorridos
      COMMIT;

      -- Se houve montagem de erros em Multi_Retornos
      IF vr_dslsterr IS NOT NULL THEN
        -- Retornamos no parâmetro
        pr_dscritic := vr_dslsterr;
        -- Retorna parâmetro tipo de log - Chamado 719114 - 07/08/2017  
        pr_dstiplog := vr_dstiplog;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
        CECRED.pc_internal_exception;
        
        -- Retorna o erro para a procedure chamadora
        pr_dscritic := 'Erro --> rotina CYBE0002.pc_retorno_remessa --> '||SQLERRM;
    END;
  END pc_retorno_remessa;

  -- Rotina para direcionar a devolução diária dos retornos a PPWare
  PROCEDURE pc_devolu_diaria(pr_idtpreme IN crapcrb.idtpreme%TYPE --> Tipo da Remessa
                            ,pr_dscritic OUT VARCHAR2) IS         --> Retorno de crítica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_devolu_diaria
    --  Sistema  : CYBER
    --  Sigla    : CRED
    --  Autor    : Marcos - SUPERO
    --  Data     : Dezembro/2014.                   Ultima atualizacao: 25/08/2016
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Efetuar o encerramento diário do Bureaux, gerando um ZIP com todos os arquivos pendentes
    --             e copiando-os para a pasta de retorno ao PPWare Cyber
    -- Alteracoes:
    --
    -- 07/10/2015 - PRJ210 - Adaptação para que a rotina fique genérica e não mais específica a PPWare (Marcos-Supero)
    --
    -- 25/08/2016 - SD511112 - Utilizar função gene0001.pc_lista_arquivos ao invés do OSCOmmand, pois quando 
    --                         havia muitos arquivos ocorria erro. (Marcos-Supero)
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      -- Buscar caracteristicas do Bureaux
      CURSOR cr_crappbc IS
        SELECT pbc.dsdirret
              ,pbc.dsfnrndv
          FROM crappbc pbc
         WHERE pbc.idtpreme = pr_idtpreme;
      rw_pbc cr_crappbc%ROWTYPE;

      -- Arquivos retornados deste Bureaux e
      -- vinculados a remessas não canceladas
      CURSOR cr_arb IS
        SELECT arb.nmarquiv
              ,arb.blarquiv
              ,arb.nrseqarq
              ,arb.rowid
              ,arb.dtmvtolt
          FROM craparb arb
              ,crapcrb crb
         WHERE crb.idtpreme = arb.idtpreme
           AND crb.dtmvtolt = arb.dtmvtolt
           AND crb.dtcancel IS NULL --> Rem não cancelada
           AND arb.dtcancel IS NULL --> Arq não cancelado
           AND arb.idtpreme = pr_idtpreme
           AND arb.cdestarq = 4 --> Retorno
           AND arb.flproces = 0;--> Não processados ainda
      --
      vr_nom_arquiv VARCHAR2(100);         --> Nome do arquivo final
      vr_nmarquiv   VARCHAR2(100);         --> Nome temporário dos arquivos
      vr_dir_temp   VARCHAR2(1000);        --> Dir temporário para trabalho com os arquivos
      vr_typ_said   VARCHAR2(3);           --> Retorno das chamadas ao SO
      --
      vr_dslstarq cecred.typ_simplestringarray; --> Lista de arquivos encontrados
    BEGIN
  	  -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
    	GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_devolu_diaria');      

      -- Buscar caracteristicas do Bureaux
      OPEN cr_crappbc;
      FETCH cr_crappbc
       INTO rw_pbc;
      CLOSE cr_crappbc;
      -- Nome do arquivo final, padrão:
      --   AAAAMMDD_HHMISS_NNNNNN, onde:
      --     AAAA = Ano
      --     MM   = Mês
      --     DD   = Dia
      --     HH   = Hora
      --     MI   = Minuto
      --     SS   = Segundo
      --     NNNNNN = Nome do Bureaux
      vr_nom_arquiv := to_char(SYSDATE,'YYYYMMDD_HH24MISS')||'_'||pr_idtpreme||'.zip';
      -- Buscar dir temporário
      vr_dir_temp := gene0001.fn_param_sistema('CRED',0,'AUTBUR_DIR_TEMP');
      -- Limpar diretório temporário
      pc_limpeza_diretorio(pr_nmdireto => vr_dir_temp   --> Diretório para limpeza
                          ,pr_dscritic => vr_dscritic);
      -- Testar retorno de erro
      IF vr_dscritic IS NOT NULL THEN
        raise vr_excerror;
      END IF;

      -- Testar se há arquivos movidos manualmente a pasta RECEBE do Bureaux
      -- Notem que desconsideramos ZIP e zip o resultado total e os sub-diretorios existentes
      gene0001.pc_lista_arquivos(pr_lista_arquivo => vr_dslstarq 
                                ,pr_path          => rw_pbc.dsdirret 
                                ,pr_pesq          => '');

        -- Se encontrou algum arquivo
      IF vr_dslstarq.count() > 0 THEN
          -- Para cada arquivo encontrado no dir
        FOR vr_idx IN 1..vr_dslstarq.count LOOP
          -- Se há informação, e não for um arquivo ZIP/RAR
          IF trim(vr_dslstarq(vr_idx)) IS NOT NULL AND lower(gene0001.fn_extensao_arquivo(vr_dslstarq(vr_idx))) NOT IN('zip','rar')  THEN
              -- Temos de mover todos os arquivos que não estão compactados
              -- para a pasta temporária para que os mesmos sejam
            gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||rw_pbc.dsdirret||'/'||vr_dslstarq(vr_idx)||' '||vr_dir_temp);
              -- Obs: Não fazemos tratamento de erro pois está é uma situação
              --      que não precisa parar o processo de devolução ao Cyber
              --      se houver problema.
            END IF;
          END LOOP;
        END IF;

      -- Buscamos todos os arquivos de retorno não processados
      FOR rw_arb IN cr_arb LOOP
        -- Se há função para renomeamento do arquivo antes de devolver a PPWare
        IF rw_pbc.dsfnrndv is not NULL THEN
          -- Chamamos a mesma dinamicamente para renomeamento do arquivo
          BEGIN
            vr_nmarquiv := fn_dinamic_function(rw_pbc.dsfnrndv,rw_arb.rowid);
          EXCEPTION
            WHEN OTHERS THEN
              -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
              CECRED.pc_internal_exception; 
              -- Devemos inserir o evento do erro e
              pc_insere_evento_remessa(pr_idtpreme => pr_idtpreme
                                      ,pr_dtmvtolt => rw_arb.dtmvtolt
                                      ,pr_nrseqarq => rw_arb.nrseqarq
                                      ,pr_cdesteve => 5 --> Fixo - Devolução
                                      ,pr_flerreve => 1 --> Erro
                                      ,pr_dslogeve => 'Erro chamar funcao para renomeamento do arquivo a devolver: '||SQLERRM
                                      ,pr_dscritic => pr_dscritic);
              -- Gravamos
              COMMIT;
              raise vr_excerror;
          END;
        ELSE
          -- Mantemos o nome original
          vr_nmarquiv := rw_arb.nmarquiv;
        END IF;
        -- Devemos criar o arquivo na pasta temp, usando função que converte BLOB em arquivo
        gene0002.pc_blob_para_arquivo(pr_blob     => rw_arb.blarquiv --> Bytes do arquivo
                                     ,pr_caminho  => vr_dir_temp     --> Dir temp
                                     ,pr_arquivo  => vr_nmarquiv     --> Nome a devolver
                                     ,pr_des_erro => vr_dscritic);
  	    -- Retorna do módulo e ação logado - Chamado 719114 - 21/07/2017
      	GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_devolu_diaria');
        -- Se retornou erro, incrementar a mensagem e retornoar
        IF vr_dscritic IS NOT NULL THEN
          -- Devemos inserir o evento do erro e
          pc_insere_evento_remessa(pr_idtpreme => pr_idtpreme
                                  ,pr_dtmvtolt => rw_arb.dtmvtolt
                                  ,pr_nrseqarq => rw_arb.nrseqarq
                                  ,pr_cdesteve => 5 --> Fixo - Devolucao
                                  ,pr_flerreve => 1 --> Erro
                                  ,pr_dslogeve => vr_dscritic
                                  ,pr_dscritic => pr_dscritic);
          -- Gravamos
          COMMIT;
          raise vr_excerror;
        END IF;
        -- Usarei a variavel de critica para montar o log que será enviado
        -- Obs: Quando o arquivo for renomeado, a mensagem é diferenciada
        IF vr_nmarquiv <> rw_arb.nmarquiv THEN
          vr_dscritic := 'Arquivo '||rw_arb.nmarquiv||' compactado como '||vr_nmarquiv||' no retorno a PPWare: '||vr_nom_arquiv||'.';
        ELSE
          vr_dscritic := 'Arquivo '||rw_arb.nmarquiv||' compactado no retorno '||vr_nom_arquiv||'.';
        END IF;
        -- Inserir evento na remessa para indicar a geração do ZIP a remessa
        pc_insere_evento_remessa(pr_idtpreme => pr_idtpreme
                                ,pr_dtmvtolt => rw_arb.dtmvtolt
                                ,pr_nrseqarq => rw_arb.nrseqarq
                                ,pr_cdesteve => 5 --> Fixo - Encerramento
                                ,pr_flerreve => 0 --> Sucesso
                                ,pr_dslogeve => vr_dscritic
                                ,pr_dscritic => vr_dscritic);
        -- Se retornou erro
        IF vr_dscritic IS NOT NULL THEN
          -- Se houve erro, temos de desfazer essa atualização, senão
          -- o arquivo poderá ficar marcado como devolvido só que não
          ROLLBACK;
          -- Devemos inserir o evento do erro e
          pc_insere_evento_remessa(pr_idtpreme => pr_idtpreme
                                  ,pr_dtmvtolt => rw_arb.dtmvtolt
                                  ,pr_nrseqarq => rw_arb.nrseqarq
                                  ,pr_cdesteve => 5 --> Fixo - Encerramento
                                  ,pr_flerreve => 1 --> Erro
                                  ,pr_dslogeve => vr_dscritic
                                  ,pr_dscritic => pr_dscritic);
          -- Gravamos
          COMMIT;
          raise vr_excerror;
        END IF;
        -- Atualizamos o arquivo como processado e guardar também o resultado do renato
        BEGIN
          UPDATE craparb
             SET flproces = 1
                ,nmarqren = decode(rw_pbc.dsfnrndv,NULL,NULL,vr_nmarquiv)
           WHERE ROWID = rw_arb.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
            CECRED.pc_internal_exception; 
            -- Se houve erro, temos de desfazer essa atualização, senão
            -- o arquivo poderá ficar marcado como devolvido só que não
            ROLLBACK;
            -- Montar descrição
            vr_dscritic := 'Erro ao atualizar situação do arquivo de retorno: '||SQLERRM;
            -- Devemos inserir o evento do erro e
            pc_insere_evento_remessa(pr_idtpreme => pr_idtpreme
                                    ,pr_dtmvtolt => rw_arb.dtmvtolt
                                    ,pr_nrseqarq => rw_arb.nrseqarq
                                    ,pr_cdesteve => 5 --> Fixo - Encerramento
                                    ,pr_flerreve => 1 --> Erro
                                    ,pr_dslogeve => vr_dscritic
                                    ,pr_dscritic => pr_dscritic);
            -- Gravamos
            COMMIT;
            raise vr_excerror;
        END;
      END LOOP;

      -- Após a criação de todos os arquivos na pasta temp, devemos compactá-los
      -- gerando o arquivo final conforme o nome montado na rotina chamadora
      gene0002.pc_zipcecred(pr_cdcooper => 3                               --> Sempre Cecred
                           ,pr_tpfuncao => 'A'                             --> Adicionar
                           ,pr_dsorigem => vr_dir_temp||'/*'               --> Todos os Arquivos do dir temp
                           ,pr_dsdestin => vr_dir_temp||'/'||vr_nom_arquiv --> Arquivo ZIP
                           ,pr_dspasswd => NULL                            --> Sem senha
                           ,pr_des_erro => vr_dscritic);                   --> Erros
  	  -- Retorna do módulo e ação logado - Chamado 719114 - 21/07/2017
      GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_devolu_diaria');
      -- Se houve retorno de erro
      IF vr_dscritic IS NOT NULL THEN
        -- Retornar e desfazer as alterações
        ROLLBACK;
        raise vr_excerror;
      END IF;

      -- Mover do diretório temp ao final
      gene0001.pc_OScommand_Shell(pr_des_comando => 'mv '||vr_dir_temp||'/'||vr_nom_arquiv||' '||rw_pbc.dsdirret
                                 ,pr_typ_saida   => vr_typ_said
                                 ,pr_des_saida   => vr_dscritic);
      -- Testar retorno de erro
      IF vr_typ_said = 'ERR' THEN
        -- Retornar e desfazer as alterações
        ROLLBACK;
        raise vr_excerror;
      END IF;

      -- Gravar o encerramento do Bureaux
      COMMIT;

    EXCEPTION
      WHEN vr_excerror THEN
        -- Devolvemos o problema
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
        CECRED.pc_internal_exception; 
        -- Retorna o erro para a procedure chamadora
        pr_dscritic := 'Erro --> na rotina CYBE0002.pc_devolu_diaria --> '||SQLERRM;
    END;
  END pc_devolu_diaria;


  -- Rotina para controlar todo o processo de envio / retorno dos arquivos dos Bureaux
  PROCEDURE pc_controle_remessas(pr_dscritic OUT VARCHAR2) IS --> Retorno de crítica
  BEGIN
    ---------------------------------------------------------------------------------------------------------------
    --
    --  Programa : pc_controle_remessas
    --  Sistema  : CYBER
    --  Sigla    : CRED
    --  Autor    : Marcos - SUPERO
    --  Data     : Dezembro/2014.                   Ultima atualizacao: 21/07/2017
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: -----
    -- Objetivo  : Esta rotina será encarregada de controlar todo o Workflow
    --             das remessas aos Bureaux do Cyber e será chamada a cada
    --             hora através de agendamentos no banco Oracle.
    --
    --             A mesma só será executada de 2ª a 6ª.
    --
    --             Em resumo, o processo irá gerar as remessas pendentes caso ainda
    --             não existam, e apóps buscar seu arquivo ZIP, processar envio ou
    --             retornos pendentes, e em cada caso irá acionar a rotina específica.
    --
    --             Ao final, uma vez ao dia, agrupará todas as remessas retornadas
    --             para compacta-las e retornar o arquivo a PPWare.
    --             É interessante salientar que devemos observar a ordem das remessas
    --             do mesmo Bureaux pois em determinadas situações podemos ter duas
    --             ou mais remessas pendentes do mesmo Bureaux e Cooperativa, e as
    --             mais antigas devem sempre ser enviadas e retornadas antes das
    --             mais atuais, assim garantimos o sequenciamento das remessas.

    -- Alteracoes:
    --
    -- 06/04/2015 - Correção no processo de criação da remessa, pois quando o dia
    --              anterior não é util, não há ZIP criado pela PPWare, e cosnequen-
    --              temente não há necessidade de gerar a remessa (Marcos-Supero)
    --            - Melhorias nos textos dos e-mails (Marcos-Supero)
    --
    -- 09/06/2015 - Inclusão de lógica para não mais devolver ZIP a PPWare
    --              em feriados, pois eles não vem buscar os arquivos (Marcos-Supero)
    --
    -- 26/10/2016 - Incluir condição nos cursores CR_PREP_PENDEM e CR_ENV_PENDEM para não retornar
    --              registros referente ao tipo de remessa SMSDEBAUT. (Renato Darosci - Supero)
    --
    -- 21/07/2017 - Inclusão do módulo e ação logado no oracle
    --            - Inclusão da chamada de procedure em exception others
    --            - Colocado logs no padrão
    --              ( Belli - Envolti - Chamado 719114)
    --
    ---------------------------------------------------------------------------------------------------------------
    DECLARE
      -- Variaveis para exceção
      vr_excerror EXCEPTION;
      vr_dscritic VARCHAR2(4000);

      vr_datautil DATE;

      -- Verificação de encerramento efetuado no dia atual para este Bureaux
      CURSOR cr_enc_bur(pr_idtpreme crapcrb.idtpreme%TYPE) IS

        SELECT 'S'
          FROM craperb erb
         WHERE erb.idtpreme = pr_idtpreme
           AND trunc(erb.dtexeeve) = trunc(SYSDATE)
           AND erb.cdesteve = 5    --> Encerramento
           AND erb.flerreve = 0;   --> Desconsiderar erros
      vr_enc_bur VARCHAR2(1);

      -- Verifica os arquivos de remessa
      CURSOR cr_verf_remessa(p_idtpreme IN crapcrb.idtpreme%TYPE
                            ,p_dtmvtolt IN crapcrb.dtmvtolt%TYPE) IS
         SELECT 1
           FROM craparb arb
          WHERE arb.idtpreme <> p_idtpreme
            AND arb.dtmvtolt = p_dtmvtolt
            AND arb.cdestarq = 2; --> Preparação
      rw_verf_remessa cr_verf_remessa%ROWTYPE;

      -- Verifica se o dia passado é um feriado
      CURSOR cr_feriad(pr_dtproces DATE) IS
        SELECT 'S'
          FROM crapfer
         WHERE cdcooper = 3
           AND dtferiad = pr_dtproces;
      vr_flgferiad VARCHAR2(1);

      -- Parâmetros gerais
      vr_hora_envio      VARCHAR2(10);   --> Hora de início da preparação / Envio
      vr_hora_retor      VARCHAR2(10);   --> Hora de início da chegagem dos retornos
      vr_hora_encer      VARCHAR2(10);   --> Hora para encerramento das remessas
      vr_hora_encer_max  VARCHAR2(10);   --> Hora máximo para encerramento das remessas
      vr_email_alert     VARCHAR2(4000); --> Lista de e-mails que recebem alertas
      vr_dias_cobemp_sms INTEGER;

      -- Motivo do cancelamento remessa
      vr_dsmotcan    VARCHAR(4000);

      -- Dia anterior
      vr_dtprocan    DATE;

      vr_nomdojob    VARCHAR2(30) := 'JBCYB_CONTROLE_REMESSAS';
  
      -- Excluida variavel vr_flgerlog - Chamado 719114 - 07/08/2017
	    -- Excluida PROCEDURE pc_controla_log_batch interna e incluida como externa - Chamado 719114 - 07/08/2017          
      
      -- Variaveis tratamento tipo do log da critica de retorno de remessa - Chamado 719114 - 07/08/2017
      vr_dstiplog    VARCHAR2(1);
      vr_flgerlog    BOOLEAN := FALSE;

      vr_dstexto VARCHAR2(2000);
      vr_titulo VARCHAR2(1000);
      vr_destinatario_email VARCHAR2(500);
      vr_idprglog   tbgen_prglog.idprglog%TYPE;

    BEGIN
	    -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
	    GENE0001.pc_set_modulo(pr_module => vr_nomdojob, pr_action => 'CYBE0002.pc_controle_remessas');

      -- Esta rotina somente poderá ser executada de 2ª a 6ª
      IF to_char(SYSDATE,'d') NOT IN(1,7) THEN

        -- Incluido parametro - Chamado 719114 - 07/08/2017
        -- Log de inicio de execucao
        pc_controla_log_batch(pr_dstiplog   => 'I',
                              pr_cdprograma => vr_nomdojob);

        -- Buscar parâmetros gerais
        vr_hora_envio      := gene0001.fn_param_sistema('CRED',0,'AUTBUR_HORA_ENVIO');      --> Hora de início da preparação / Envio
        vr_hora_retor      := gene0001.fn_param_sistema('CRED',0,'AUTBUR_HORA_RETOR');      --> Hora de início da chegagem dos retornos
        vr_hora_encer      := gene0001.fn_param_sistema('CRED',0,'AUTBUR_HORA_ENCER');      --> Hora para encerramento das remessas
        vr_hora_encer_max  := gene0001.fn_param_sistema('CRED',0,'AUTBUR_HORA_ENCER_MAX');  --> Hora Máximo para encerramento das remessas
        vr_email_alert     := gene0001.fn_param_sistema('CRED',0,'AUTBUR_EMAIL_ALERT');     --> Lista de e-mails que recebem alertas
        vr_dias_cobemp_sms := nvl(gene0001.fn_param_sistema('CRED',0,'AUTBUR_DIAS_COBEMP_SMS'), 2); --> Dias limite para buscar arquivos enviados

        ----- 0 - Necessidade de Agendamento ---
        -- Buscamos o dia anterior
        IF to_char(SYSDATE,'D') = 2 THEN
          vr_dtprocan := trunc(SYSDATE)-3; -- Sexta anterior
        ELSE
          vr_dtprocan := trunc(SYSDATE)-1; -- Dia anterior
        END IF;

        -- Testamos se a data anterior não é um feriado
        vr_flgferiad := 'N';
        OPEN cr_feriad(pr_dtproces => vr_dtprocan);
        FETCH cr_feriad
         INTO vr_flgferiad;
        CLOSE cr_feriad;
        -- Somente continuamos se o o dia anterior foi util
        IF vr_flgferiad = 'N' THEN
          FOR rw_pbc IN cr_agen_penden(pr_dtmvtolt => trunc(SYSDATE)) LOOP
            -- Para cada Bureaux sem agendamento para o dia atual
            pc_solicita_remessa(pr_dtmvtolt => trunc(SYSDATE)  --> Data da solicitação
                               ,pr_idtpreme => rw_pbc.idtpreme --> Tipo da remessa
                               ,pr_dscritic => vr_dscritic);   --> Retorno de crítica
            -- Se houver retorno de crítica
            IF vr_dscritic IS NOT NULL THEN
              -- Desfazer agendamentos
              ROLLBACK;
              
              -- Incluido parametro - Chamado 719114 - 07/08/2017
              -- Log de erro de execucao
              pc_controla_log_batch(pr_dstiplog   => 'E',
                                    pr_dscritic   => vr_dscritic,
                                    pr_cdprograma => vr_nomdojob);
              
              -- Enviaremos e-mail para a área de crédito para avisar do problema na busca do
              -- arquivo deste Bureaux juntamente dos problemas ocorridos.
              gene0003.pc_solicita_email(pr_cdcooper    => 3
                                        ,pr_cdprogra    => 'CYBE0002'
                                        ,pr_des_destino => vr_email_alert
                                        ,pr_des_assunto => 'Agendamento Bureaux '||rw_pbc.idtpreme||' Data-base '||to_char(SYSDATE,'dd/mm/yyyy')||' com erros'
                                        ,pr_des_anexo   => ''
                                        ,pr_des_corpo   => 'Houveram problemas durante o agendamento da remessa ao Bureaux, '||
                                                           'abaixo segue o detalhamento do erro encontrado:<br><br> '||vr_dscritic
                                        ,pr_flg_enviar  => 'N'
                                        ,pr_des_erro    => vr_dscritic);
            END IF;
            -- Gravar as informações processadas
            COMMIT;
          END LOOP;
        END IF; --> Validação de feriado


        ----- 1 - Preparação dos Bureaux Agendadss -----
        FOR rw_crb IN cr_prep_penden LOOP
          -- Se a remessa for referente ao dia atual e automática
          IF rw_crb.dtmvtolt = trunc(SYSDATE) AND rw_crb.idtpsoli = 'A' THEN
            -- Somente podemos continuar se o horário do sistema for superior
            -- ao horário parametrizado para início da Preparação/Envio
            -- Usaremos o parâmetro AUTBUR_HORA_ENVIO, que deverá conter
            -- um horário no formato hh24:mi. Ex: 09:00
            IF To_char(sysdate,'hh24:mi') < vr_hora_envio THEN
              -- Pular a remessa pois ainda não chegou no horário da execução
              continue;
            END IF;
          END IF;
          -- Chegando neste ponto, chamaremos a rotina que irá buscar os arquivos
          -- de origem da remessa e então prepará-los para seu devido envio ao Bureaux
          pc_busca_arq_remessa(pr_idtpreme => rw_crb.idtpreme
                              ,pr_dtmvtolt => rw_crb.dtmvtolt
                              ,pr_dscritic => vr_dscritic);
          -- Se houver retorno de crítica
          IF vr_dscritic IS NOT NULL THEN

            -- Incluido parametro - Chamado 719114 - 07/08/2017
            -- Log de erro de execucao
            pc_controla_log_batch(pr_dstiplog   => 'E',
                                  pr_dscritic   => vr_dscritic,
                                  pr_cdprograma => vr_nomdojob);

            -- Enviaremos e-mail para a área de crédito para avisar do problema na busca do
            -- arquivo deste Bureaux juntamente dos problemas ocorridos.
            gene0003.pc_solicita_email(pr_cdcooper    => 3
                                      ,pr_cdprogra    => 'CYBE0002'
                                      ,pr_des_destino => vr_email_alert
                                      ,pr_des_assunto => 'Preparacao Bureaux '||rw_crb.idtpreme||' Data-base - '||to_char(rw_crb.dtmvtolt,'dd/mm/yyyy')||' com erros'
                                      ,pr_des_anexo   => ''
                                      ,pr_des_corpo   => 'Houveram problemas durante a procura pelo arquivo desta remessa ao Bureaux, e '||
                                                         'abaixo segue o detalhamento do erro encontrado:<br> '||vr_dscritic
                                      ,pr_flg_enviar  => 'N'
                                      ,pr_des_erro    => vr_dscritic);
          END IF;
          -- Gravar as informações processadas
          COMMIT;
        END LOOP;

        ----- 1.1 - Verificação do cancelamento automático -----
        -- Se existir pelo menos um arquivo ZIP de qualquer outra remessa
        -- as demais remessas devem ser canceladas, pois a PPWare envia apenas
        -- uma vez os arquivos ZIP, e se não enviou é porque não existem informações
        -- a enviar para aquele Bureaux na data

        -- Inicializa a variavel
        vr_dsmotcan := 'Remessa Cancelada por SUPER-USUARIO. Recebido Arquivo ZIP de outros Bureaux, portanto '||
                       'nao existem informacoes para essa data nesse Bureaux.';
        -- Busca todas aquelas ainda sem ZIP
        FOR rw_crb IN cr_prep_penden LOOP
          -- Verifica se outras remessas do mesmo dia tem o ZIP
          OPEN cr_verf_remessa (rw_crb.idtpreme
                               ,rw_crb.dtmvtolt);
          -- Inicializa variavel
          rw_verf_remessa:=NULL;
          FETCH cr_verf_remessa
          INTO rw_verf_remessa;
          -- Se encontrou registro
          IF cr_verf_remessa%FOUND THEN
            -- Atualizando a remessa para CANCELADA
            BEGIN
              UPDATE crapcrb crb
                 SET crb.dtcancel = SYSDATE     --> DATA CORRENTE
                    ,crb.cdopecan = '1'         --> OPERADOR
                    ,crb.dsmotcan = vr_dsmotcan --> MOTIVO DO CANCELAMENTO
               WHERE crb.idtpreme = rw_crb.idtpreme
                 AND crb.dtmvtolt = rw_crb.dtmvtolt;
            EXCEPTION
              WHEN OTHERS THEN
                -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
                CECRED.pc_internal_exception; 
                
                -- rollback das informa
                ROLLBACK;
                -- Fecha cursor
                IF cr_verf_remessa%ISOPEN THEN
                   CLOSE cr_verf_remessa;
                END IF;
               -- Continua o processo
               CONTINUE;
            END;
            -- Inserindo o evento de cancelamento
            pc_insere_evento_remessa(pr_idtpreme => rw_crb.idtpreme        --> Remessa
                                    ,pr_dtmvtolt => rw_crb.dtmvtolt        --> Data da Remessa
                                    ,pr_cdesteve => 9 -- Fixo              --> Cancelado
                                    ,pr_flerreve => 1 -- Sucesso           --> Flag
                                    ,pr_dslogeve => vr_dsmotcan            --> Motivo Log Evento
                                    ,pr_dscritic => vr_dscritic);          --> Descrisao da Critica
            -- Se houve erro
            IF vr_dscritic IS NOT NULL THEN
              -- rollback das informa
              ROLLBACK;

              -- Incluido parametro - Chamado 719114 - 07/08/2017
              -- Log de erro de execucao
              pc_controla_log_batch(pr_dstiplog   => 'E',
                                    pr_dscritic   => vr_dscritic,
                                    pr_cdprograma => vr_nomdojob);

              -- Fecha cursor
              IF cr_verf_remessa%ISOPEN THEN
                CLOSE cr_verf_remessa;
              END IF;
            END IF;
          END IF;  -- Fim do IF cr_verf_remessa%FOUND
          -- Fecha cursor
          IF cr_verf_remessa%ISOPEN THEN
             CLOSE cr_verf_remessa;
          END IF;
          -- Commit das alterações
          COMMIT;
        END LOOP; -- Fim do FOR

        ----- 2 - Envio das Remesass Preparadas -----
        FOR rw_crb IN cr_env_penden LOOP
          -- Se a remessa for referente ao dia atual e Automática
          IF rw_crb.dtmvtolt = trunc(SYSDATE) AND rw_crb.idtpsoli = 'A' THEN
            -- Somente podemos continuar se o horário do sistema for superior
            -- ao horário parametrizado para início da Preparação/Envio
            -- Usaremos o parâmetro AUTBUR_HORA_ENVIO, que deverá conter
            -- um horário no formato hh24:mi. Ex: 09:00
            IF To_char(sysdate,'hh24:mi') < vr_hora_envio THEN
              -- Pular a remessa pois ainda não chegou no horário da execução
              continue;
            END IF;
          END IF;
          -- Para cada remessa preparada, procedemos com o processo de envio
          -- dos arquivos ao seu devido Bureaux
          pc_envio_remessa(pr_idtpreme => rw_crb.idtpreme
                          ,pr_dtmvtolt => rw_crb.dtmvtolt
                          ,pr_dscritic => vr_dscritic);
          -- Se houver retorno de crítica
          IF vr_dscritic IS NOT NULL THEN

            -- Incluido parametro - Chamado 719114 - 07/08/2017
            -- Log de erro de execucao
            pc_controla_log_batch(pr_dstiplog   => 'E',
                                  pr_dscritic   => vr_dscritic,
                                  pr_cdprograma => vr_nomdojob);  

            -- Enviaremos e-mail para a área de crédito para avisar do problema no envio
            -- do arquivo deste Bureaux juntamente dos problemas ocorridos.
            gene0003.pc_solicita_email(pr_cdcooper    => 3
                                      ,pr_cdprogra    => 'CYBE0002'
                                      ,pr_des_destino => vr_email_alert
                                      ,pr_des_assunto => 'Envio Bureaux '||rw_crb.idtpreme||' Data-base - '||to_char(rw_crb.dtmvtolt,'dd/mm/yyyy hh24:mi')||' com erros'
                                      ,pr_des_anexo   => ''
                                      ,pr_des_corpo   => 'Houveram problemas durante a comunicacao para envio do arquivo da remessa ao Bureaux, '||
                                                         'abaixo seguem os detalhes do erro encontrado: <br><br> '||vr_dscritic
                                      ,pr_flg_enviar  => 'N'
                                      ,pr_des_erro    => vr_dscritic);
          END IF;
          -- Efetuar gravação
          COMMIT;
        END LOOP;

        ----- 3 - Retorno das Remesassa Enviadas -----
        FOR rw_crb IN cr_ret_penden LOOP
          -- Se a remessa for referente ao dia atual
          IF rw_crb.dtmvtolt = trunc(SYSDATE) THEN
            -- Somente podemos continuar se o horário do sistema for superior
            -- ao horário parametrizado para busca do Retorno
            -- Usaremos o parâmetro AUTBUR_HORA_RETOR, que deverá conter
            -- um horário no formato hh24:mi. Ex: 14:00
            IF To_char(sysdate,'hh24:mi') < vr_hora_retor THEN
              -- Pular a remessa pois ainda não chegou no horário da execução
              continue;
            END IF;
          END IF;

          /* Ignorar se for cobemp/cobtit ou sms e crb.dtmvtolt < (dia util anterior dias_param) */
          vr_datautil := SYSDATE;
          FOR i IN 1 .. vr_dias_cobemp_sms LOOP
            vr_datautil := vr_datautil - 1;
            vr_datautil := gene0005.fn_valida_dia_util(pr_cdcooper => 3, 
                                                       pr_dtmvtolt => vr_datautil, 
                                                       pr_tipo     => 'A');
          END LOOP;
                                      
          IF UPPER(rw_crb.idtpreme) IN ('COBEMP','SMS') AND rw_crb.dtmvtolt < vr_datautil THEN
            continue;
          END IF;

          -- Tratamento tipo do log da critica de retorno de remessa - Chamado 719114 - 07/08/2017
          -- Proceder com o retorno das remessas
          pc_retorno_remessa(pr_idtpreme => rw_crb.idtpreme
                            ,pr_dtmvtolt => rw_crb.dtmvtolt
                            ,pr_dscritic => vr_dscritic
                            ,pr_dstiplog => vr_dstiplog);
          
          -- Se houver retorno de crítica
          IF vr_dscritic IS NOT NULL THEN
            
            -- Incluido parametro - Chamado 719114 - 07/08/2017
            -- Log de erro de execucao
            pc_controla_log_batch(pr_dstiplog   => NVL(vr_dstiplog,'E'),
                                  pr_dscritic   => vr_dscritic,
                                  pr_cdprograma => vr_nomdojob);

            -- Enviaremos e-mail para a área de crédito para avisar do problema no envio
            -- do arquivo deste Bureaux juntamente dos problemas ocorridos.
            gene0003.pc_solicita_email(pr_cdcooper    => 3
                                      ,pr_cdprogra    => 'CYBE0002'
                                      ,pr_des_destino => vr_email_alert
                                      ,pr_des_assunto => 'Retorno Bureaux '||rw_crb.idtpreme||' Data-base '||to_char(rw_crb.dtmvtolt,'dd/mm/yyyy')||' com erros'
                                      ,pr_des_anexo   => ''
                                      ,pr_des_corpo   => 'Houveram problemas durante a comunicacao para retorno do arquivo da remessa do Bureaux, '||
                                                         'abaixo seguem os detalhes do erro encontrado:<br><br> '||vr_dscritic
                                      ,pr_flg_enviar  => 'N'
                                      ,pr_des_erro    => vr_dscritic);
          END IF;
          -- Efetuar gravação
          COMMIT;
        END LOOP;

        ----- 4 - Encerramento diário dos Bureaux  -----
        -- Primeiramente verificamos se a hora atual está dentre o horário parametrizado
        -- Início - Param AUTBUR_HORA_ENCER ---- Fim - Param AUTBUR_HORA_ENCER_MAX
        -- Este encerramento ocorre apenas uma vez ao dia, e compreende todos os
        -- arquivos retornados daquele Bureaux no dia.
        IF To_char(sysdate,'hh24:mi') >= vr_hora_encer AND To_char(sysdate,'hh24:mi') <= vr_hora_encer_max THEN
          -- Testamos se a data atual não é feriado
          vr_flgferiad := 'N';
          OPEN cr_feriad(pr_dtproces => trunc(SYSDATE));
          FETCH cr_feriad
           INTO vr_flgferiad;
          CLOSE cr_feriad;
          -- Somente continuamos se o o dia atual for util, ou seja, em feriados não
          -- devolvemos ZIP a PPware
          IF vr_flgferiad = 'N' THEN
            -- Trazer todas as remessas pendentes de encerramento agrupando por Bureaux
            -- (Nesta consulta trazemos apenas as automáticas, com apenas uma devolução por dia)
            FOR rw_crb IN cr_dev_penden(pr_idtpsoli => 'A') LOOP
              -- Os encerramentos das remessas ocorrerão uma única vez por dia
              -- para cada Bureaux, independente da data. Portanto, se já houve
              -- encerramento no dia de hoje, então os retornos pendentes serão
              -- enviados a PPWAre somente no próximo dia.
              OPEN cr_enc_bur(pr_idtpreme => rw_crb.idtpreme);
              FETCH cr_enc_bur
               INTO vr_enc_bur;
              CLOSE cr_enc_bur;
              -- Se já houve o retorno
              IF nvl(vr_enc_bur,'N') = 'S' THEN
                -- Já houve, então, somente amanhã
                continue;
              END IF;
              -- Chegando neste ponto, temos remessas retornadas do Bureaux
              -- então procedemos com encerramento da remessa com a cópia dos
              -- arquivos retornados ao Cyber e atualização da situação
              pc_devolu_diaria(pr_idtpreme => rw_crb.idtpreme
                              ,pr_dscritic => vr_dscritic);
              -- Se houver retorno de crítica
              IF vr_dscritic IS NOT NULL THEN

                -- Incluido parametro - Chamado 719114 - 07/08/2017
                -- Log de erro de execucao
                pc_controla_log_batch(pr_dstiplog   => 'E',
                                      pr_dscritic   => vr_dscritic,
                                      pr_cdprograma => vr_nomdojob);  

                -- Enviaremos e-mail para a área de crédito para avisar do problema na busca do
                -- arquivo deste Bureaux juntamente dos problemas ocorridos.
                gene0003.pc_solicita_email(pr_cdcooper    => 3
                                          ,pr_cdprogra    => 'CYBE0002'
                                          ,pr_des_destino => vr_email_alert
                                          ,pr_des_assunto => 'Encerramento Bureaux '||rw_crb.idtpreme|| ' com erros'
                                          ,pr_des_anexo   => ''
                                          ,pr_des_corpo   => 'Houveram problemas durante o encerramento das remessas do Bureaux, Abaixo seguem os detalhes do erro encontrado:<br><br> '||vr_dscritic
                                          ,pr_flg_enviar  => 'N'
                                          ,pr_des_erro    => vr_dscritic);
              END IF;
              -- Efetuar gravação
              COMMIT;
            END LOOP;
          END IF;
        END IF;

        -- Ao final limpamos o diretório temp pra não ficar nenhum arquivo indesejado
        -- Limpar diretório temporário
        pc_limpeza_diretorio(pr_nmdireto => gene0001.fn_param_sistema('CRED',0,'AUTBUR_DIR_TEMP')   --> Diretório para limpeza
                            ,pr_dscritic =>  vr_dscritic);
        -- Gravação final
        COMMIT;

        -- Incluido parametro - Chamado 719114 - 07/08/2017
        -- Log de fim da execucao
        pc_controla_log_batch(pr_dstiplog   => 'F',
                              pr_cdprograma => vr_nomdojob);

      END IF; --> Somente de 2ª a 6ª

      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_excerror;
      END IF;

    EXCEPTION
      WHEN vr_excerror THEN
        -- Atualização de log para o padrão - 21/07/2017 - Chamado 719114
        pr_dscritic := to_char(sysdate,'hh24:mi:ss')||' - ' || vr_nomdojob || ' --> ' || 
                               'ERRO: ' || 'CYBE0002.pc_controle_remessas - ' || vr_dscritic;                                                                  
        -- Gerar o erro no arquivo de log do Batch
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 3
                                  ,pr_des_log      => pr_dscritic
                                  ,pr_nmarqlog     => 'proc_autbur'
                                  ,pr_cdprograma   => vr_nomdojob);
      WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
        CECRED.pc_internal_exception (pr_cdcooper => 3);
        -- Atualização de log para o padrão - 21/07/2017 - Chamado 719114
        pr_dscritic := to_char(sysdate,'hh24:mi:ss')||' - ' || vr_nomdojob || ' --> ' || 
                               'ERRO: ' || 'CYBE0002.pc_controle_remessas - ' || SQLERRM;   

        -- Abrir chamado - Texto para utilizar na abertura do chamado e no email enviado
        vr_dstexto := to_char(sysdate,'hh24:mi:ss') || ' - ' || vr_nomdojob || ' --> ' ||
                     'Erro na execucao do programa. Critica: ' || nvl(vr_dscritic,' ');

        -- Parte inicial do texto do chamado e do email
        vr_titulo := '<b>Abaixo os erros encontrados no job '|| vr_nomdojob || '</b><br><br>';

        -- Buscar e-mails dos destinatarios do produto cyber
        vr_destinatario_email := gene0001.fn_param_sistema('CRED',3,'CYBER_RESPONSAVEL');

        cecred.pc_log_programa(
            PR_DSTIPLOG      => 'E'           --> Tipo do log: I - início; F - fim; O - ocorrência
           ,PR_CDPROGRAMA    => vr_nomdojob   --> Codigo do programa ou do job
           ,pr_tpexecucao    => 2             --> Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
           -- Parametros para Ocorrencia
           ,pr_tpocorrencia  => 2             --> tp ocorrencia (1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem)
           ,pr_cdcriticidade => 2             --> Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
           ,pr_dsmensagem    => vr_dstexto    --> dscritic       
           ,pr_flgsucesso    => 0             --> Indicador de sucesso da execução
           ,pr_flabrechamado => 1             --> Abrir chamado (Sim=1/Nao=0)
           ,pr_texto_chamado => vr_titulo
           ,pr_destinatario_email => vr_destinatario_email
           ,pr_flreincidente => 1             --> Erro pode ocorrer em dias diferentes, devendo abrir chamado
           ,PR_IDPRGLOG      => vr_idprglog); --> Identificador unico da tabela (sequence)

        -- Gerar o erro no arquivo de log do Batch
        btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                  ,pr_ind_tipo_log => 3
                                  ,pr_des_log      => pr_dscritic
                                  ,pr_nmarqlog     => 'proc_autbur'
                                  ,pr_cdprograma   => vr_nomdojob);
    END;
  END pc_controle_remessas;


  -- Geracao do arquivo da Reabilitação Forçada
  PROCEDURE pc_grava_arquivo_reafor(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_grava_arquivo_reafor
  --  Sistema  : Rotina para gravar os arquivos em ZIP
  --  Sigla    : CRED
  --  Autor    : Andre Santos - SUPERO
  --  Data     : Janeiro/2015.                   Ultima atualizacao: 21/07/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Geração do arquivo de reabilitação forçada e inclusão do mesmo
  --             no ZIP diário gerado e enviado a PPWare
  -- Alteracoes:  05/05/2015 - Geração do arquivo CY_REAF_DDMMAA conforme data do ciclo
  --                           e não mais data atual, conforme previsto inicialmente
  --                           no projeto (Marcos-Supero)
  --
  --              11/09/2015 - Inclusao dos nomes dos parametros na chamada da
  --                           pc_clob_para_arquivo. (Jaison/Marcos-Supero)
  --
  --              21/07/2017 - Inclusão do módulo e ação logado no oracle
  --                           Inclusão da chamada de procedure em exception others
  --                           Colocado logs no padrão
  --                           ( Belli - Envolti - Chamado 719114)
  --
  ---------------------------------------------------------------------------------------------------------------
  -- Cursores

  /* Verifica se existe registro para iniciar
  o processo de reabilitacao forcada de credito */
  CURSOR cr_craprea IS
    SELECT rea.flenvarq
      FROM craprea rea
     WHERE rea.flenvarq = 0;
  rw_craprea cr_craprea%ROWTYPE;

  -- Selecionar os dados da Cooperativa
  CURSOR cr_crapcop1 (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT crapcop.cdcooper
          ,crapcop.nmrescop
          ,crapcop.nrtelura
          ,crapcop.cdbcoctl
          ,crapcop.cdagectl
          ,crapcop.dsdircop
          ,crapcop.nrctactl
          ,crapcop.cdagedbb
          ,crapcop.cdageitg
          ,crapcop.nrdocnpj
    FROM crapcop crapcop
    WHERE crapcop.cdcooper = pr_cdcooper;
  rw_crapcop1 cr_crapcop1%ROWTYPE;

  -- Selecionar os dados da Cooperativa
  CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT crapcop.cdcooper
          ,crapcop.nmrescop
          ,crapcop.nrtelura
          ,crapcop.cdbcoctl
          ,crapcop.cdagectl
          ,crapcop.dsdircop
          ,crapcop.nrctactl
          ,crapcop.cdagedbb
          ,crapcop.cdageitg
          ,crapcop.nrdocnpj
    FROM crapcop crapcop
    WHERE crapcop.cdcooper <> pr_cdcooper
      AND crapcop.flgativo = 1
    ORDER BY crapcop.cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  TYPE typ_tab_contlinh IS VARRAY(1) OF PLS_INTEGER;
  TYPE typ_tab_nmclob   IS VARRAY(1) OF VARCHAR2(100);
  TYPE typ_tab_linha    IS VARRAY(1) OF VARCHAR2(5000);

  vr_tab_contlinh typ_tab_contlinh:= typ_tab_contlinh(0);
  vr_tab_nmclob   typ_tab_nmclob:= typ_tab_nmclob(NULL);
  vr_tab_linha    typ_tab_linha:= typ_tab_linha (NULL);

  --Registro do tipo calendario
  rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;

  --Variaveis Locais
  vr_caminho         VARCHAR2(1000);
  vr_tempoatu        VARCHAR2(1000);
  vr_comando         VARCHAR2(1000);
  vr_typ_saida       VARCHAR2(1000);
  vr_setlinha        VARCHAR2(5000);
  vr_proc_arq        BOOLEAN;
  vr_qtdlinha        INTEGER;
  vr_index           INTEGER;

  -- Variavel CLOB
  vr_des_xml1        CLOB;

  -- Variavel de Critica
  vr_cdcritic        NUMBER;
  vr_dscritic        VARCHAR2(32767);
  vr_exc_saida EXCEPTION;

  vr_nomdojob  CONSTANT VARCHAR2(30) := 'JBCYB_ARQUIVO_REAFOR';
  
  -- Excluida variavel vr_flgerlog - Chamado 719114 - 07/08/2017  

  --Funcao para retornar cpf/cnpj
  FUNCTION fn_busca_cpfcgc (pr_nrcpfcgc IN NUMBER) RETURN VARCHAR2 IS
     BEGIN
        DECLARE
           --Variaveis Locais
           vr_stsnrcal BOOLEAN;
           vr_inpessoa INTEGER;
        BEGIN
           --Validar o cpf/cnpj
           gene0005.pc_valida_cpf_cnpj (pr_nrcalcul => pr_nrcpfcgc
                                       ,pr_stsnrcal => vr_stsnrcal
                                       ,pr_inpessoa => vr_inpessoa);
           --Se o parametro esta preenchido
           IF pr_nrcpfcgc IS NOT NULL AND pr_nrcpfcgc <> 0 THEN
              --Se for pessoa fisica
              IF vr_inpessoa = 1 THEN
                 RETURN(gene0002.fn_mask(pr_nrcpfcgc,'99999999999'));
              ELSE
                 RETURN(gene0002.fn_mask(pr_nrcpfcgc,'99999999999999'));
              END IF;
           END IF;
           RETURN(NULL);
        EXCEPTION
           WHEN OTHERS THEN
              -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
              CECRED.pc_internal_exception; 
              vr_cdcritic:= 0;
              vr_dscritic:= 'Erro ao validar cpf/cnpj. '||SQLERRM;
              RAISE vr_exc_saida;
        END;
     END fn_busca_cpfcgc;

  --Procedure para Inicializar os CLOBs
  PROCEDURE pc_inicializa_clob IS
     BEGIN
        dbms_lob.createtemporary(vr_des_xml1, TRUE);
        dbms_lob.open(vr_des_xml1, dbms_lob.lob_readwrite);
     EXCEPTION
        WHEN OTHERS THEN
        -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
        CECRED.pc_internal_exception;
        
        --Variavel de erro recebe erro ocorrido
        vr_cdcritic:= 0;
        vr_dscritic:= 'Erro ao inicializar CLOB. Rotina pc_crps652.pc_inicializa_clob. '||sqlerrm;
        --Sair do programa
        RAISE vr_exc_saida;
     END pc_inicializa_clob;

  --Escrever no arquivo CLOB
  PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2
                          ,pr_nro_clob  IN INTEGER
                          ,pr_flmsmlin  IN BOOLEAN DEFAULT FALSE) IS
     -- identifica se deve inclui informações na mesma linha
     vr_linha VARCHAR2(5000);
     BEGIN
        --Se foi passada infomacao
        IF pr_des_dados IS NOT NULL THEN
           --Atribuir o parametro para a variavel
           vr_linha:= pr_des_dados;
        ELSE
           --Atribuir a string do array para variavel quebrando linha
           IF pr_flmsmlin THEN --verificar se deve ser incluido registro na mesma linha
              vr_linha:= vr_tab_linha(pr_nro_clob);
           ELSE
              vr_linha:= vr_tab_linha(pr_nro_clob)||chr(10);
           END IF;
           --Limpar string
           vr_tab_linha(pr_nro_clob):= NULL;
        END IF;

        --Escrever no arquivo XML
        CASE pr_nro_clob
           WHEN 1 THEN dbms_lob.writeappend(vr_des_xml1,length(vr_linha),vr_linha);
        END CASE;
     EXCEPTION
        WHEN OTHERS THEN
           -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
           CECRED.pc_internal_exception;
           
           vr_cdcritic:= 0;
           vr_dscritic:= 'Erro ao escrever no CLOB. '||sqlerrm;
           --Levantar Excecao
           RAISE vr_exc_saida;
     END pc_escreve_xml;

  --Procedure para incrementar contador linha
  PROCEDURE pc_incrementa_linha(pr_nrolinha IN INTEGER) IS
     BEGIN
        vr_tab_contlinh(pr_nrolinha):= vr_tab_contlinh(pr_nrolinha) + 1;
     END pc_incrementa_linha;

  PROCEDURE pc_monta_linha(pr_text    in varchar2,
                           pr_nrposic in integer,
                           pr_arquivo in integer) IS
     vr_linha       varchar2(5000) := null;
     vr_tam_linha   integer;
     vr_qtd_brancos integer;
     BEGIN
        vr_linha := vr_tab_linha(pr_arquivo);
        -- Verifica quantos caracteres já existem na linha
        vr_tam_linha := nvl(length(vr_linha), 0);
        -- Calcula quantidade de espaços a incluir na linha
        vr_qtd_brancos := pr_nrposic - vr_tam_linha - 1;
        -- Concatena os espaços em branco e o novo texto
        vr_linha := vr_linha || rpad(' ', vr_qtd_brancos, ' ') || pr_text;
        --Modificar vetor com a linha atualizada
        vr_tab_linha(pr_arquivo) := vr_linha;
     END pc_monta_linha;

  -- Procedimento de Reabilitacao Forcada de Credito
  PROCEDURE pc_reab_forcada_credito(pr_cdcooper    IN crapcop.cdcooper%TYPE -- Cooperativa
                                   ,pr_sequencia   IN PLS_INTEGER           -- Sequencia de linhas dentro do arquivo
                                   ,pr_escreve_arq IN BOOLEAN               -- Determina a escrita do arquivo (TRUE-Escreve/FALSE-Nao Escreve)
                                   ,pr_dscritic    OUT VARCHAR2) IS         -- Descricao da Critica
     -- PL-TABLES
     TYPE typ_reg_craprea IS RECORD
        -- Campos da craprea
        (cdcooper craprea.cdcooper%TYPE
        ,cdoperad craprea.cdoperad%TYPE
        ,cdorigem craprea.cdorigem%TYPE
        ,dtmvtolt craprea.dtmvtolt%TYPE
        ,flenvarq craprea.flenvarq%TYPE
        ,nrcpfcgc craprea.nrcpfcgc%TYPE
        ,nrctremp craprea.nrctremp%TYPE
        ,nrdconta craprea.nrdconta%TYPE);

     TYPE typ_tab_craprea  IS TABLE OF typ_reg_craprea INDEX BY PLS_INTEGER;

     -- Cursores
     -- Busca os registros da craprea
     CURSOR cr_reabilitacao(p_cdcooper crapcop.cdcooper%TYPE) IS
        SELECT rea.cdcooper
              ,rea.cdoperad
              ,rea.cdorigem
              ,rea.dtmvtolt
              ,rea.flenvarq
              ,rea.nrcpfcgc
              ,rea.nrctremp
              ,rea.nrdconta
          FROM craprea rea
         WHERE rea.cdcooper = p_cdcooper
           AND rea.flenvarq = 0
         ORDER BY rea.cdcooper
                 ,rea.dtmvtolt
                 ,rea.nrcpfcgc
                 ,rea.nrdconta
                 ,rea.nrctremp
                 ,rea.cdorigem;

     -- Verificando Dados do Associado
     CURSOR cr_crapass(p_cdcooper crapcop.cdcooper%TYPE
                      ,p_nrcpfcgc crapass.nrcpfcgc%TYPE
                      ,p_nrdconta crapass.nrdconta%TYPE) IS
        SELECT ass.cdcooper
              ,ass.nrcpfcgc
              ,ass.nrdconta
              ,ass.inpessoa
              ,(SELECT COUNT(ass1.nrdconta)
                  FROM crapass ass1
                 WHERE ass1.cdcooper = p_cdcooper
                   AND ass1.nrcpfcgc = DECODE(ass.nrdconta,0,ass1.nrcpfcgc,ass.nrcpfcgc)
                   AND ass1.nrdconta = DECODE(ass.nrdconta,0,ass.nrdconta,ass1.nrdconta)) qtdContas
          FROM crapass ass
         WHERE ass.cdcooper = p_cdcooper
           AND ass.nrcpfcgc = DECODE(p_nrdconta,0,p_nrcpfcgc,ass.nrcpfcgc)
           AND ass.nrdconta = DECODE(p_nrdconta,0,ass.nrdconta,p_nrdconta);
     rw_crapass cr_crapass%ROWTYPE;

     -- Verificando Dados do Associado no Sistema CYBER
     CURSOR cr_crapcyb(p_cdcooper crapcop.cdcooper%TYPE
                      ,p_nrdconta crapass.nrdconta%TYPE
                      ,p_nrctremp crapcyb.nrctremp%TYPE
                      ,p_cdorigem crapcyb.cdorigem%TYPE) IS
        SELECT cyb.cdcooper
              ,cyb.nrdconta
              ,cyb.nrctremp
              ,cyb.cdorigem
              ,(SELECT COUNT(cyb1.nrctremp)
                  FROM crapcyb cyb1
                 WHERE cyb1.cdcooper = p_cdcooper
                   AND cyb1.nrdconta = p_nrdconta
                   AND cyb1.nrctremp = DECODE(p_nrctremp,0,cyb1.nrctremp,p_nrctremp)
                   AND cyb1.cdorigem = DECODE(p_cdorigem,0,cyb1.cdorigem,p_cdorigem)) qtdContrato
         FROM crapcyb cyb
        WHERE cyb.cdcooper = p_cdcooper
          AND cyb.nrdconta = p_nrdconta
          AND cyb.nrctremp = DECODE(p_nrctremp,0,cyb.nrctremp,p_nrctremp)
          AND cyb.cdorigem = DECODE(p_cdorigem,0,cyb.cdorigem,p_cdorigem);
     rw_crapcyb cr_crapcyb%ROWTYPE;

     -- Tabela de Memoria
     vr_tab_craprea typ_tab_craprea;
     -- Variavel
     vr_index     PLS_INTEGER;
     vr_sequencia PLS_INTEGER := 0;
     -- Variavel de EXCEPTION
     vr_exe_saida EXCEPTION;

     BEGIN
        -- Verifica se o arquivo deve ser escrito
        IF NOT pr_escreve_arq THEN
           RAISE vr_exe_saida;
        END IF;

        -- Inicializa Variavel
        pr_dscritic := NULL;
        vr_tab_craprea.DELETE;
        vr_sequencia :=pr_sequencia;

        -- Carrega dados para memoria
        FOR rw_reabilitacao IN cr_reabilitacao(pr_cdcooper) LOOP
           -- Index
           vr_index := vr_tab_craprea.COUNT()+1;
           -- Campos
           vr_tab_craprea(vr_index).cdcooper := rw_reabilitacao.cdcooper;
           vr_tab_craprea(vr_index).cdoperad := rw_reabilitacao.cdoperad;
           vr_tab_craprea(vr_index).cdorigem := rw_reabilitacao.cdorigem;
           vr_tab_craprea(vr_index).dtmvtolt := rw_reabilitacao.dtmvtolt;
           vr_tab_craprea(vr_index).flenvarq := rw_reabilitacao.flenvarq;
           vr_tab_craprea(vr_index).nrcpfcgc := rw_reabilitacao.nrcpfcgc;
           vr_tab_craprea(vr_index).nrctremp := rw_reabilitacao.nrctremp;
           vr_tab_craprea(vr_index).nrdconta := rw_reabilitacao.nrdconta;
        END LOOP;

        -- Processa todos os registro em memoria
        vr_index := vr_tab_craprea.FIRST();
        WHILE vr_index IS NOT NULL LOOP

           -- Verificando Dados do Associado
           OPEN cr_crapass(vr_tab_craprea(vr_index).cdcooper
                          ,vr_tab_craprea(vr_index).nrcpfcgc
                          ,vr_tab_craprea(vr_index).nrdconta);
           FETCH cr_crapass INTO rw_crapass;

              -- Se o associado possui somente uma conta
              IF rw_crapass.qtdContas = 1 THEN

                 -- Verificando Dados do Associado no Sistema CYBER
                 OPEN cr_crapcyb(rw_crapass.cdcooper
                                ,rw_crapass.nrdconta
                                ,vr_tab_craprea(vr_index).nrctremp
                                ,vr_tab_craprea(vr_index).cdorigem);
                 FETCH cr_crapcyb INTO rw_crapcyb;

                    -- Se o associado possui somente um contrato
                    IF rw_crapcyb.qtdContrato = 1 THEN

                       -- Incrementar Contador Linha
                       pc_incrementa_linha(1);
                       vr_sequencia := vr_sequencia + 1;

                       -- Montar Linha
                       pc_monta_linha(' ',1,1); -- FIXO
                       pc_monta_linha('1',2,1); -- FIXO 1 -- Grupo de Cobranca
                       pc_monta_linha(TRIM(LPAD(gene0002.fn_mask(rw_crapcyb.cdcooper,'9999')||
                                                gene0002.fn_mask(rw_crapcyb.cdorigem,'9999')||
                                                gene0002.fn_mask(rw_crapcyb.nrdconta,'99999999')||
                                                gene0002.fn_mask(rw_crapcyb.nrctremp,'99999999'),25,' ')),3,1); -- Contrato de Cobranca
                       pc_monta_linha(RPAD(fn_busca_cpfcgc(rw_crapass.nrcpfcgc),24,' '),28,1); -- FIXO
                       pc_monta_linha(' ',53,1); -- FIXO
                       pc_monta_linha(LPAD(vr_sequencia,7,0),54,1); -- Sequencial de linhas dentro do arquivo

                       -- Gravar linha no arquivo
                       pc_escreve_xml(NULL,1);

                    ELSE -- Processa todos os contratos relacionados a conta

                       LOOP
                          EXIT WHEN cr_crapcyb%NOTFOUND;

                          -- Incrementar Contador Linha
                          pc_incrementa_linha(1);
                          vr_sequencia := vr_sequencia + 1;

                          -- Montar Linha
                          pc_monta_linha(' ',1,1); -- FIXO
                          pc_monta_linha('1',2,1); -- FIXO 1 -- Grupo de Cobranca
                          pc_monta_linha(TRIM(LPAD(gene0002.fn_mask(rw_crapcyb.cdcooper,'9999')||
                                                   gene0002.fn_mask(rw_crapcyb.cdorigem,'9999')||
                                                   gene0002.fn_mask(rw_crapcyb.nrdconta,'99999999')||
                                                   gene0002.fn_mask(rw_crapcyb.nrctremp,'99999999'),25,' ')),3,1); -- Contrato de Cobranca
                          pc_monta_linha(RPAD(fn_busca_cpfcgc(rw_crapass.nrcpfcgc),24,' '),28,1); -- FIXO
                          pc_monta_linha(' ',53,1); -- FIXO
                          pc_monta_linha(LPAD(vr_sequencia,7,0),54,1); -- Sequencial de linhas dentro do arquivo

                          -- Gravar linha no arquivo
                          pc_escreve_xml(NULL,1);

                          FETCH cr_crapcyb INTO rw_crapcyb;
                       END LOOP;

                    END IF;
                 CLOSE cr_crapcyb;

              ELSE -- Verificando todas as contas relacionadas ao CPF/CNPJ

                 LOOP
                    EXIT WHEN cr_crapass%NOTFOUND;

                    -- Verificando Dados do Associado no Sistema CYBER
                    OPEN cr_crapcyb(rw_crapass.cdcooper
                                   ,rw_crapass.nrdconta
                                   ,vr_tab_craprea(vr_index).nrctremp
                                   ,vr_tab_craprea(vr_index).cdorigem);
                    FETCH cr_crapcyb INTO rw_crapcyb;

                       -- Se o associado possui somente um contrato
                       IF rw_crapcyb.qtdContrato = 1 THEN

                          -- Incrementar Contador Linha
                          pc_incrementa_linha(1);
                          vr_sequencia := vr_sequencia + 1;

                          -- Montar Linha
                          pc_monta_linha(' ',1,1); -- FIXO
                          pc_monta_linha('1',2,1); -- FIXO 1 -- Grupo de Cobranca
                          pc_monta_linha(TRIM(LPAD(gene0002.fn_mask(rw_crapcyb.cdcooper,'9999')||
                                                   gene0002.fn_mask(rw_crapcyb.cdorigem,'9999')||
                                                   gene0002.fn_mask(rw_crapcyb.nrdconta,'99999999')||
                                                   gene0002.fn_mask(rw_crapcyb.nrctremp,'99999999'),25,' ')),3,1); -- Contrato de Cobranca
                          pc_monta_linha(RPAD(fn_busca_cpfcgc(rw_crapass.nrcpfcgc),24,' '),28,1); -- FIXO
                          pc_monta_linha(' ',53,1); -- FIXO
                          pc_monta_linha(LPAD(vr_sequencia,7,0),54,1); -- Sequencial de linhas dentro do arquivo

                          -- Gravar linha no arquivo
                          pc_escreve_xml(NULL,1);

                       ELSE -- Processa todos os contratos relacionados a conta

                          LOOP
                             EXIT WHEN cr_crapcyb%NOTFOUND;

                             -- Incrementar Contador Linha
                             pc_incrementa_linha(1);
                             vr_sequencia := vr_sequencia + 1;

                             -- Montar Linha
                             pc_monta_linha(' ',1,1); -- FIXO
                             pc_monta_linha('1',2,1); -- FIXO 1 -- Grupo de Cobranca
                             pc_monta_linha(TRIM(LPAD(gene0002.fn_mask(rw_crapcyb.cdcooper,'9999')||
                                                      gene0002.fn_mask(rw_crapcyb.cdorigem,'9999')||
                                                      gene0002.fn_mask(rw_crapcyb.nrdconta,'99999999')||
                                                      gene0002.fn_mask(rw_crapcyb.nrctremp,'99999999'),25,' ')),3,1); -- Contrato de Cobranca
                             pc_monta_linha(RPAD(fn_busca_cpfcgc(rw_crapass.nrcpfcgc),24,' '),28,1); -- FIXO
                             pc_monta_linha(' ',53,1); -- FIXO
                             pc_monta_linha(LPAD(vr_sequencia,7,0),54,1); -- Sequencial de linhas dentro do arquivo

                             -- Gravar linha no arquivo
                             pc_escreve_xml(NULL,1);

                             FETCH cr_crapcyb INTO rw_crapcyb;
                          END LOOP;
                       END IF;
                    CLOSE cr_crapcyb;

                    FETCH cr_crapass INTO rw_crapass;
                 END LOOP;

              END IF;
           CLOSE cr_crapass;

           -- Proximo registro
           vr_index := vr_tab_craprea.NEXT(vr_index);
        END LOOP;

        -- Atualizando os registros
        BEGIN
           UPDATE craprea rea
              SET rea.flenvarq = 1 -- Registro processado
            WHERE rea.cdcooper = pr_cdcooper
              AND rea.flenvarq = 0;
        EXCEPTION
           WHEN OTHERS THEN
              -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
              CECRED.pc_internal_exception; 
        
              -- Limpa Tabela de Memoria
              vr_tab_craprea.DELETE;
              -- Erro do Sistema
              pr_dscritic := 'Erro ao atualizar a CRAPREA: '||SQLERRM;
        END;

        -- Limpa Tabela de Memoria
        vr_tab_craprea.DELETE;

     EXCEPTION
        WHEN vr_exe_saida THEN
           NULL; -- Finaliza a operacao
        WHEN OTHERS THEN
           -- No caso de erro de programa gravar tabela especifica de log - 21/07/2017 - Chamado 719114
           CECRED.pc_internal_exception;
        
           -- Limpa Tabela de Memoria
           vr_tab_craprea.DELETE;
           -- Erro do Sistema
           pr_dscritic := 'Erro na rotina pc_reab_forcada_credito: '||SQLERRM;
     END pc_reab_forcada_credito;

     -- Excluida PROCEDURE pc_controla_log_batch interna e incluida como externa - Chamado 719114 - 07/08/2017 

  -- INICIO DA PROCEDURE
  BEGIN
	  -- Inclusão do módulo e ação logado - Chamado 719114 - 21/07/2017
  	GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_grava_arquivo_reafor');      

     -- Incluido parametro - Chamado 719114 - 07/08/2017
     -- Início do programa
     pc_controla_log_batch( pr_dstiplog   => 'I'
                           ,pr_cdprograma => vr_nomdojob);

     -- Verifica se a cooperativa esta cadastrada
     OPEN cr_crapcop1(pr_cdcooper => pr_cdcooper);
     FETCH cr_crapcop1 INTO rw_crapcop1;
     -- Se nao encontrar
     IF cr_crapcop1%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE cr_crapcop1;
        -- Montar mensagem de critica
        vr_cdcritic:= 651;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
     ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapcop1;
     END IF;

     -- Verifica se a data esta cadastrada
     OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
     FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
     -- Se nao encontrar
     IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
     ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
     END IF;

     --Buscar Caminho Cyber para Envio
     vr_caminho:= gene0001.fn_param_sistema('CRED',pr_cdcooper,'CRPS652_CYBER_ENVIA');

     IF vr_caminho IS NULL THEN
        vr_cdcritic:= 0;
        vr_dscritic:= 'Erro ao buscar caminho Cyber para envio.';
        RAISE vr_exc_saida;
     END IF;


     -- Inicializa Variavel
     vr_tempoatu:= TO_CHAR(SYSDATE,'HH24MISS');

     --Inicializar os CLOBs
     pc_inicializa_clob;

     --Montar nome do arquivo
     vr_setlinha := vr_caminho; -- Inicializa a variavel
     vr_setlinha := vr_setlinha ||'CY_REAF_'||TO_CHAR(rw_crapdat.dtmvtoan,'DDMMYYYY')||'.txt'; /* Reabilitacao */

     -- Monta o cabecalho do arquivo de reabilitação forcada de credito
     -- Verifica se existe registro para iniciar o processo
     OPEN cr_craprea;
     FETCH cr_craprea INTO rw_craprea;
        -- Se nao encontrar registro
        IF cr_craprea%FOUND THEN
           -- Incrementa a linha do HEADER
           pc_incrementa_linha(1);
        END IF;

        -- Inicia o processo
        vr_proc_arq := TRUE;
        -- Salvar o nome de cada CLOB no vetor
        vr_tab_nmclob(1):= vr_setlinha;
        -- Montar linha que sera gravada no arquivo
        vr_setlinha:= RPAD('A',1,' ')||                         -- Fixo
                      to_char(rw_crapdat.dtmvtoan,'YYYYMMDD')|| -- Data Geracao de Arquivo
                      RPAD(TO_CHAR(SYSDATE,'hh24miss'),6,' ')|| -- Hota Geracao de Arquivo
                      RPAD('REABILITACAO   ',15,' ')||          -- Fixo
                      RPAD('f001000',8,' ')||                   -- Login Solicitante - GENERICO
                      RPAD('               ',15,' ')||          -- Brancos
                      LPAD(0000001,7,'0')||                     -- Sequencial de linhas
                      chr(10);                                  -- Quebra de linha
        -- Escrever Header no CLOB
        pc_escreve_xml(vr_setlinha,1);
     CLOSE cr_craprea;

     --Percorrer Cooperativas
     FOR rw_crapcop IN cr_crapcop (pr_cdcooper => pr_cdcooper) LOOP

         -- Procedimento de Reabilitacao Forcada de Credito
         pc_reab_forcada_credito(rw_crapcop.cdcooper -- Cooperativa
                                ,vr_tab_contlinh(1)  -- Sequencia de registro dentro do arquivo
                                ,vr_proc_arq         -- Indica se deve processar os registros de reabilitacao
                                ,vr_dscritic);       -- Descricao da critica

     END LOOP;

     -- Arquivo de Reabilitacao Forcada de Credito
     --Incrementar Contador
     vr_qtdlinha:= vr_tab_contlinh(1) + 1; -- Linha Trailler

     --Montar Linha
     vr_setlinha:= 'Z'||                     -- Fixo
                   LPAD(vr_qtdlinha-2,8,0)|| -- Quantidade de Registros
                   LPAD(' ',44,' ')||        -- Brancos
                   LPAD(vr_qtdlinha,7,0)||   -- Sequencia da linha do arquivo
                   chr(10);

     --Escrever linha no arquivo
     pc_escreve_xml(vr_setlinha,1);

     --Gerar arquivo fisicamente
     gene0002.pc_clob_para_arquivo(pr_clob     => vr_des_xml1
                                  ,pr_caminho  => vr_caminho
                                  ,pr_arquivo  => vr_tab_nmclob(1)
                                  ,pr_des_erro => vr_dscritic);
	   -- Retorna do módulo e ação logado - Chamado 719114 - 21/07/2017
  	 GENE0001.pc_set_modulo(pr_module => NULL, pr_action => 'CYBE0002.pc_grava_arquivo_reafor');   
     -- Testa retorno
     IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
     END IF;

     -- Fecha CLOB
     dbms_lob.close(vr_des_xml1);
     dbms_lob.freetemporary(vr_des_xml1);

     -- Testar se há arquivos ZIP para o dia corrente
     GENE0001.pc_OScommand_Shell(pr_des_comando => 'ls '||vr_caminho||to_char(rw_crapdat.dtmvtolt,'YYYYMMDD')||'*'||'_CYBER.zip'
                                 ,pr_typ_saida   => vr_typ_saida
                                 ,pr_des_saida   => vr_dscritic);
     -- Somente se houver retorno OUT
     IF vr_typ_saida = 'OUT' THEN
        -- Abre o ZIP que foi localizado
        -- vr_dscritic --> Contem o diretorio e o arquivo ZIP
        -- Add ou Sobreescreve caso exista dentro o arquivo ZIP que foi localizado ignorando o diretorio do arquivo
        vr_comando:= 'zip '||vr_dscritic||' -j '
                           ||vr_caminho||'CY_REAF_'||to_char(rw_crapdat.dtmvtoan,'DDMMYYYY')||'.txt '||
                           '1> /dev/null';

        --Executar o comando no unix
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_comando
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic);
        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
           vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
           RAISE vr_exc_saida;
        END IF;
     ELSE
        -- Arquivo ZIP nao foi localizado
        -- Gera o Arquivo ZIP com o arquivo para envio
        vr_comando:= 'zip '||vr_caminho||'/'||to_char(rw_crapdat.dtmvtolt,'YYYYMMDD')||'_'||vr_tempoatu||'_CYBER.zip -j '||
                           vr_caminho||'/'||'CY_REAF_'||TO_CHAR(rw_crapdat.dtmvtoan,'DDMMYYYY')||'.txt '||
                           '1> /dev/null';

        --Executar o comando no unix
        GENE0001.pc_OScommand(pr_typ_comando => 'S'
                             ,pr_des_comando => vr_comando
                             ,pr_typ_saida   => vr_typ_saida
                             ,pr_des_saida   => vr_dscritic);
        --Se ocorreu erro dar RAISE
        IF vr_typ_saida = 'ERR' THEN
           vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
           RAISE vr_exc_saida;
        END IF;
     END IF;

     --Eliminar arquivos
     IF vr_caminho IS NOT NULL THEN
       --Montar Comando
       vr_comando:= 'rm '||vr_caminho||'/'||'CY_REAF_'||TO_CHAR(rw_crapdat.dtmvtoan,'DDMMYYYY') ||'.txt '||
                           '2> /dev/null';
       --Executar o comando no unix
       GENE0001.pc_OScommand(pr_typ_comando => 'S'
                            ,pr_des_comando => vr_comando
                            ,pr_typ_saida   => vr_typ_saida
                            ,pr_des_saida   => vr_dscritic);
       --Se ocorreu erro dar RAISE
       IF vr_typ_saida = 'ERR' THEN
          vr_dscritic:= 'Nao foi possivel executar comando unix. '||vr_comando;
          RAISE vr_exc_saida;
       END IF;
     END IF;

     --Salvar informacoes no banco de dados
     COMMIT;

     -- Incluido parametro - Chamado 719114 - 07/08/2017
     -- Log de fim do programa
     pc_controla_log_batch( pr_dstiplog   => 'F'
                           ,pr_cdprograma => vr_nomdojob);     

  EXCEPTION
    WHEN vr_exc_saida THEN

        -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic, vr_dscritic);

      -- Incluido parametro - Chamado 719114 - 07/08/2017
      -- Log de erro no programa
      pc_controla_log_batch( pr_dstiplog   => 'E'
                            ,pr_dscritic   => vr_dscritic || 
                             ' - pr_cdcooper: ' || pr_cdcooper
                            ,pr_cdprograma => vr_nomdojob);

      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN

      cecred.pc_internal_exception(pr_cdcooper);
    
      -- Efetuar retorno do erro nao tratado
      vr_dscritic := SQLERRM;
      
      -- Incluido parametro - Chamado 719114 - 07/08/2017      
      -- Log de erro no programa
      pc_controla_log_batch( pr_dstiplog   => 'E'
                            ,pr_dscritic   => vr_dscritic || 
                             ' - pr_cdcooper: ' || pr_cdcooper
                            ,pr_cdprograma => vr_nomdojob);

      -- Efetuar rollback
      ROLLBACK;
  END pc_grava_arquivo_reafor;


  -- Controla Controla log em banco de dados
  PROCEDURE pc_controla_log_batch(pr_dstiplog   IN VARCHAR2,              -- Tipo de Log
                                  pr_dscritic   IN VARCHAR2 DEFAULT NULL, -- Descrição do Log
                                  pr_cdprograma IN VARCHAR2               -- Código da rotina
                                  )
  IS
  -----------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_controla_log_batch
  --  Sistema  : Rotina para gravar os arquivos em ZIP
  --  Sigla    : CRED
  --  Autor    : Cesar Belli - Envolti 
  --  Data     : Agosto/2017.                   Ultima atualizacao: 07/08/2017
  --  Chamado  : 669487/719114.
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: Rotina executada em qualquer frequencia.
  -- Objetivo  : Controla log em banco de dados.
  --
  -- Alteracoes:  
  --             
  ------------------------------------------------------------------------------------------------------------   
    vr_idprglog           tbgen_prglog.idprglog%TYPE := 0;
    vr_tpocorrencia       tbgen_prglog_ocorrencia.tpocorrencia%type;
    --
  BEGIN         
    IF pr_dstiplog IN ('O', 'I', 'F') THEN
      vr_tpocorrencia     := 4; 
    ELSE
      vr_tpocorrencia     := 2; 
    END IF;      
    --> Controlar geração de log de execução dos jobs                                
    CECRED.pc_log_programa(pr_dstiplog      => NVL(pr_dstiplog,'E'), 
                           pr_cdprograma    => NVL(pr_cdprograma,'CYBE0002'), 
                           pr_cdcooper      => 3, 
                           pr_tpexecucao    => 2, --job
                           pr_tpocorrencia  => vr_tpocorrencia,
                           pr_cdcriticidade => 0, --baixa
                           pr_dsmensagem    => pr_dscritic,                             
                           pr_idprglog      => vr_idprglog,
                           pr_nmarqlog      => NULL);
  EXCEPTION
    WHEN OTHERS THEN
      CECRED.pc_internal_exception (pr_cdcooper => 3);                                                             
  END pc_controla_log_batch;
    
END  CYBE0002;
/
