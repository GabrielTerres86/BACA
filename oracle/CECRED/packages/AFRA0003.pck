CREATE OR REPLACE PACKAGE CECRED.AFRA0003 IS

  /* ---------------------------------------------------------------------------------------------------------------
  
      Programa : AFRA0003
      Sistema  : Gerenciar análises/mensagens com tempo renteção expirado.
      Sigla    : AFRA
      Autor    : Oscar Alcantara Junior
      Data     : Fevereiro/2017.                   Ultima atualizacao: 14/02/2017
  
      Dados referentes ao programa:
  
      Frequencia: -----
      Objetivo  : Processar as análises/msg's com o tempo de retenção expirado (fila de exceção) 
                  ou seja sem retorno do sistema antifraude.   PRJ335 - Analise de Fraude
  
      Alteracoes:
  
  ---------------------------------------------------------------------------------------------------------------*/

  PROCEDURE pc_inicializafila;
  PROCEDURE pc_finalizafila;

  --> Gerar log das filas de analise de fraude
  PROCEDURE pc_geralog_fila(pr_nmdireto IN VARCHAR2 --> Diretório do arquivo
                           ,pr_nmarquiv IN VARCHAR2 --> Nome do arquivo
                           ,pr_des_text IN VARCHAR2,
                            pr_des_erro OUT VARCHAR2);
  

end AFRA0003;
/
CREATE OR REPLACE PACKAGE BODY CECRED.AFRA0003 IS

  /* ---------------------------------------------------------------------------------------------------------------
  
      Programa : AFRA0003
      Sistema  : Gerenciar análises/mensagens com tempo renteção expirado.
      Sigla    : AFRA
      Autor    : Oscar Alcantara Junior
      Data     : Fevereiro/2017.                   Ultima atualizacao: 14/02/2017
  
      Dados referentes ao programa:
  
      Frequencia: -----
      Objetivo  : Processar as análises/msg's com o tempo de retenção expirado (fila de exceção) 
                  ou seja sem retorno do sistema antifraude.   PRJ335 - Analise de Fraude
  
      Alteracoes:
      
      
  ---------------------------------------------------------------------------------------------------------------*/

  /* Feito assim pois como a rotina fica executando em um loop eterno em background as procedures
  GEN0001 e GEN0002 ficaram bloqueadas e não poderiam ser compiladas numa liberação sem baixar
  o gerenciador de filas */

  CURSOR cr_crapprm(pr_cdcooper IN crapprm.cdcooper%TYPE,
                    pr_nmsistem IN crapprm.nmsistem%TYPE,
                    pr_cdacesso IN crapprm.cdacesso%TYPE) IS
    SELECT prm.dsvlrprm
      FROM crapprm prm
     WHERE prm.nmsistem = pr_nmsistem
       AND prm.cdcooper IN (pr_cdcooper, 0) --> Busca tanto da passada, quanto da geral (se existir)
       AND prm.cdacesso = pr_cdacesso
     ORDER BY prm.cdcooper DESC; --> Trará a cooperativa passada primeiro, e caso não encontre nela, trará da 0(zero)

  CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.dsdircop FROM crapcop cop WHERE cop.cdcooper = pr_cdcooper;

  --> Gerar log das filas de analise de fraude
  PROCEDURE pc_geralog_fila(pr_nmdireto IN VARCHAR2 --> Diretório do arquivo
                           ,pr_nmarquiv IN VARCHAR2 --> Nome do arquivo
                           ,pr_des_text IN VARCHAR2,
                            pr_des_erro OUT VARCHAR2) IS
    
    /* ..........................................................................
    
      Programa : pc_geralog_fila        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Oscar
      Data     : Fevereiro/2017.                   Ultima atualizacao: 22/02/2017
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Gerar log das filas de analise de fraude
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    
    -----------> VARIAVEIS <-----------
    --> Saída de erros
  
    vr_utlfileh UTL_FILE.file_type;
    vr_exc_erro EXCEPTION; -- Saída com exception
  
  BEGIN
    BEGIN
      BEGIN
        vr_utlfileh := UTL_FILE.fopen(pr_nmdireto, pr_nmarquiv, 'A', 32767);
        UTL_FILE.put(vr_utlfileh,
                     TO_CHAR(sysdate, 'DD/MM/RRRR hh24:mi:ss') || ' - ' ||
                     pr_des_text || ' [PL/SQL]');
        UTL_FILE.fclose(vr_utlfileh);
      EXCEPTION
        WHEN OTHERS THEN
          pr_des_erro := 'Problema ao gravar o arquivo <' || pr_nmdireto || '/' ||
                         pr_nmarquiv || '>: ' || sqlerrm;
          RAISE vr_exc_erro;
      END;
    
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Montar o erro
        pr_des_erro := 'Erro na rotina afra0003.pc_geralog_fila --> ' ||
                       pr_des_erro;
      WHEN OTHERS THEN
        -- Montar o erro
        pr_des_erro := 'Erro na rotina afra0003.pc_geralog_fila --> Erro ao abrir o arquivo: ' ||
                       sqlerrm;
    END;
  END pc_geralog_fila;

  --> Monitorar fila de execption das mensagens de analise de fraude 
  PROCEDURE pc_start_proc_fila(pr_cdcritic OUT INTEGER,
                               pr_dscritic OUT VARCHAR2,
                               pr_nmfilexc IN VARCHAR2) IS
  
    /* ..........................................................................
    
      Programa : pc_start_proc_fila        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Oscar
      Data     : Fevereiro/2017.                   Ultima atualizacao: 22/02/2017
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Monitorar fila de execption das mensagens de analise de fraude 
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    
    -----------> VARIAVEIS <-----------
    vr_dequeue_options    dbms_aq.dequeue_options_t;
    vr_message_properties dbms_aq.message_properties_t;
    vr_message_handle     RAW(16);
    vr_message            admfilascecred.tpmensagem;
    vr_exc_fim EXCEPTION;
    vr_nmfilexc crapprm.dsvlrprm%TYPE;
    vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(4000);
    vr_dsdetcri VARCHAR2(4000);
    vr_des_erro VARCHAR2(4000);
    vr_cdprogra VARCHAR2(50);
    vr_nmarqlog crapprm.dsvlrprm%TYPE;    
    vr_dsdircop crapcop.dsdircop%TYPE;
    vr_nmdireto crapprm.dsvlrprm%TYPE;
    vr_dsplsql  VARCHAR2(15000);
    vr_jobname  VARCHAR2(150);
        
  
  BEGIN
    
    vr_nmarqlog := NULL;
    OPEN cr_crapprm(pr_cdcooper => 0,
                    pr_nmsistem => 'CRED',
                    pr_cdacesso => 'NOME_ARQLOG_FILA');
    FETCH cr_crapprm
      INTO vr_nmarqlog;
  
    CLOSE cr_crapprm;
  
    IF vr_nmarqlog IS NULL THEN
      vr_dscritic := 'Parametro na tabela crapprm NOME_ARQLOG_FILA nao encontrado.';
      RAISE vr_exc_fim;
    END IF;
  
    OPEN cr_crapcop(pr_cdcooper => 3);
    FETCH cr_crapcop
      INTO vr_dsdircop;
    CLOSE cr_crapcop;
  
    IF vr_dsdircop IS NULL THEN
      vr_dscritic := 'Parametro na tabela crapcop DSDIRCOP nao encontrado.';
      RAISE vr_exc_fim;
    END IF;
  
    vr_nmdireto := NULL;
    OPEN cr_crapprm(pr_cdcooper => 3,
                    pr_nmsistem => 'CRED',
                    pr_cdacesso => 'ROOT_DIRCOOP');
    FETCH cr_crapprm
      INTO vr_nmdireto;
  
    CLOSE cr_crapprm;
  
    IF vr_nmdireto IS NULL THEN
      vr_dscritic := 'Parametro na tabela crapprm ROOT_DIRCOOP nao encontrado.';
      RAISE vr_exc_fim;
    END IF;
  
    vr_nmdireto := vr_nmdireto || vr_dsdircop || '/log/';
  
    vr_nmfilexc := NULL;
    OPEN cr_crapprm(pr_cdcooper => 0,
                    pr_nmsistem => 'CRED',
                    pr_cdacesso => 'NOME_FILA_EXCEPTI_FRAUDE');
    FETCH cr_crapprm
      INTO vr_nmfilexc;
  
    CLOSE cr_crapprm;
  
    IF vr_nmfilexc IS NULL THEN
      vr_dscritic := 'Parametro na tabela crapprm NOME_FILA_EXCEPTI_FRAUDE nao encontrado.';
      RAISE vr_exc_fim;
    END IF;
  
    vr_cdprogra := 'cecred.afra0003.pc_start_proc_fila';        
    
    vr_nmfilexc := pr_nmfilexc; -- Fila de exception
  
    vr_dequeue_options.navigation    := DBMS_AQ.FIRST_MESSAGE;
    vr_dequeue_options.CONSUMER_NAME := NULL;
    vr_dequeue_options.DEQUEUE_MODE  := DBMS_AQ.REMOVE;
    vr_dequeue_options.VISIBILITY    := DBMS_AQ.IMMEDIATE;
    vr_dequeue_options.WAIT          := DBMS_AQ.FOREVER;
    vr_dequeue_options.DELIVERY_MODE := DBMS_AQ.PERSISTENT;
    vr_dequeue_options.MSGID         := NULL;
    vr_dequeue_options.CORRELATION   := NULL;
    LOOP
      DBMS_AQ.DEQUEUE(queue_name         => vr_nmfilexc,
                      dequeue_options    => vr_dequeue_options,
                      message_properties => vr_message_properties,
                      payload            => vr_message,
                      msgid              => vr_message_handle);
    
      /* Para o processamento na fila */
      IF vr_message.idanalise_fraude = -1 THEN
        RAISE vr_exc_fim;
      END IF;
    
      /* Processar mensagem retirada da fila */
      vr_cdcritic := 0;
      vr_dscritic := NULL;
    
      vr_dsplsql := '
      DECLARE
        vr_cdcritic number;
        vr_dscritic varchar2(2000);
        vr_dsdetcri varchar2(2000);
        vr_des_erro varchar2(2000);
      
      BEGIN
        AFRA0001.pc_reg_reto_analise_antifraude
                                               (pr_idanalis => '||vr_message.idanalise_fraude||', 
                                                pr_cdparece => 0,
                                                pr_flganama => 1,
                                                pr_cdcanal  => 1,
                                                pr_fingerpr => ''NOFINGERPRINT'',
                                                pr_cdcritic => vr_cdcritic,
                                                pr_dscritic => vr_dscritic,
                                                pr_dsdetcri => vr_dsdetcri);
      
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        
          vr_dscritic := ''IdAnalise: '||vr_message.idanalise_fraude||': '' || vr_dsdetcri;
          
          AFRA0003.pc_geralog_fila(pr_nmdireto => '''|| vr_nmdireto||''',
                          pr_nmarquiv => '''|| vr_nmarqlog||''',
                          pr_des_text => '''|| vr_cdprogra ||' --> '' || vr_cdcritic,
                          pr_des_erro => vr_des_erro);
          
        END IF;
      END;';
      
      /*
      AFRA0001.pc_reg_reto_analise_antifraude(pr_idanalis => vr_message.idanalise_fraude, --> Id Unico da transação 
                                              pr_cdparece => 0, --> Parecer da análise antifraude
                                              --> 0 - Pendente
                                              --> 1 - Aprovada
                                              --> 2 - Reprovada
                                              pr_flganama => 1, --> Indentificador de analise manual 
                                              pr_cdcanal  => 1, --> Canal origem da operação
                                              pr_fingerpr => 'NOFINGERPRINT', --> Identifica a comunicação partiu do antifraude
                                              pr_cdcritic => vr_cdcritic, --> Código da Crítica 
                                              pr_dscritic => vr_dscritic, --> Descrição da Crítica 
                                              pr_dsdetcri => vr_dsdetcri); --> Detalhe da critica 
    
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      
        vr_dscritic := 'IdAnalise: '||vr_message.idanalise_fraude||': '||vr_dscritic;
        
        pc_geralog_fila(pr_nmdireto => vr_nmdireto,
                        pr_nmarquiv => vr_nmarqlog,
                        pr_des_text => vr_cdprogra || ' --> ' || vr_cdcritic,
                        pr_des_erro => vr_des_erro);
        
      END IF;*/
      
      vr_jobname := dbms_scheduler.generate_job_name(substr('JBGEN_FILAEXCEP$',1,18));
      -- Chamar a rotina padrão do banco 
      dbms_scheduler.create_job(job_name        => vr_jobname
                               ,job_type        => 'PLSQL_BLOCK' --> Indica que é um bloco PLSQL
                               ,job_action      => vr_dsplsql    --> Bloco PLSQL para execução
                               ,start_date      => SYSDATE    --> Data/hora para executar
                               ,repeat_interval => NULL    --> Função para calculo da próxima execução, ex: 'sysdate+1'
                               ,auto_drop       => TRUE          --> Quando não houver mais agendamentos, "dropar"
                               ,enabled         => TRUE);        --> Criar o JOB já ativando-o
      
    
      COMMIT;
    
      vr_dequeue_options.NAVIGATION := DBMS_AQ.NEXT_MESSAGE;
    
    END LOOP;
  
  EXCEPTION
    WHEN vr_exc_fim THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Monitor finalizado na fila ' || vr_nmfilexc;
    WHEN OTHERS THEN
      ROLLBACK;
      pr_cdcritic := 0;
      pr_dscritic := 'Falha ao inicializar monitor na fila ' || vr_nmfilexc ||
                     ' - ' || SQLERRM;
  END pc_start_proc_fila;

  --> Inserir mensagem afim de parar o monitoramento da fila de execption
  PROCEDURE pc_stop_proc_fila(pr_cdcritic OUT INTEGER,
                              pr_dscritic OUT VARCHAR2,
                              pr_nmfilfra IN VARCHAR2,
                              pr_nmfilexc IN VARCHAR2) IS
  
    /* ..........................................................................
    
      Programa : pc_stop_proc_fila        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Oscar
      Data     : Fevereiro/2017.                   Ultima atualizacao: 22/02/2017
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Inserir mensagem afim de parar o monitoramento da fila de execption
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    
    -----------> VARIAVEIS <-----------
    
    vr_enqoptin dbms_aq.enqueue_options_t;
    vr_msgprope dbms_aq.message_properties_t;
    vr_msghandl RAW(16);
    vr_messagem admfilascecred.tpmensagem;
    vr_qtseqexp NUMBER := 1; /* Expira em 1 segundo */
    vr_idmensag NUMBER := -1; /* Prioridade máxima */
    vr_nmfilexc crapprm.dsvlrprm%TYPE;
    vr_nmfilfra crapprm.dsvlrprm%TYPE;
  
  BEGIN
    vr_nmfilfra := pr_nmfilfra; -- Fila de normal
    vr_nmfilexc := pr_nmfilexc; -- Fila de exceção
  
    --> Atribuir conteudo da mensagem que ficará na fila
    vr_messagem := admfilascecred.tpmensagem(vr_idmensag);
  
    --> Definir parametros da fila
    vr_enqoptin.VISIBILITY    := DBMS_AQ.IMMEDIATE;
    vr_enqoptin.DELIVERY_MODE := DBMS_AQ.PERSISTENT;
  
    --> Atribuir propriedades mensagem 
    vr_msgprope.PRIORITY        := vr_idmensag;
    vr_msgprope.DELAY           := 0;
    vr_msgprope.EXPIRATION      := vr_qtseqexp;
    vr_msgprope.CORRELATION     := TO_CHAR(vr_idmensag);
    vr_msgprope.EXCEPTION_QUEUE := vr_nmfilexc;
  
    --> Incluir dados na fila
    DBMS_AQ.ENQUEUE(queue_name         => vr_nmfilfra,
                    enqueue_options    => vr_enqoptin,
                    message_properties => vr_msgprope,
                    payload            => vr_messagem,
                    msgid              => vr_msghandl);
  
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      pr_cdcritic := 0;
      pr_dscritic := 'Falha ao finalizar monitor na fila ' || vr_nmfilexc ||
                     ' - ' || SQLERRM;
  END pc_stop_proc_fila;

  --> Rotina para inicializar monitoramento da fila
  PROCEDURE pc_inicializafila IS
  
    /* ..........................................................................
    
      Programa : pc_inicializafila        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Oscar
      Data     : Fevereiro/2017.                   Ultima atualizacao: 22/02/2017
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para inicializar monitoramento da fila
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    
    -----------> VARIAVEIS <-----------
    
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;
    vr_cdcritic NUMBER := 0;
    vr_cdprogra VARCHAR2(50);
    vr_nmarqlog crapprm.dsvlrprm%TYPE;
    vr_nmfilexc crapprm.dsvlrprm%TYPE;
    vr_dsdircop crapcop.dsdircop%TYPE;
    vr_nmdireto crapprm.dsvlrprm%TYPE;
    vr_des_erro VARCHAR2(4000);
  
  begin
    vr_nmarqlog := NULL;
    OPEN cr_crapprm(pr_cdcooper => 0,
                    pr_nmsistem => 'CRED',
                    pr_cdacesso => 'NOME_ARQLOG_FILA');
    FETCH cr_crapprm
      INTO vr_nmarqlog;
  
    CLOSE cr_crapprm;
  
    IF vr_nmarqlog IS NULL THEN
      vr_dscritic := 'Parametro na tabela crapprm NOME_ARQLOG_FILA nao encontrado.';
      RAISE vr_exc_erro;
    END IF;
  
    OPEN cr_crapcop(pr_cdcooper => 3);
    FETCH cr_crapcop
      INTO vr_dsdircop;
    CLOSE cr_crapcop;
  
    IF vr_dsdircop IS NULL THEN
      vr_dscritic := 'Parametro na tabela crapcop DSDIRCOP nao encontrado.';
      RAISE vr_exc_erro;
    END IF;
  
    vr_nmdireto := NULL;
    OPEN cr_crapprm(pr_cdcooper => 3,
                    pr_nmsistem => 'CRED',
                    pr_cdacesso => 'ROOT_DIRCOOP');
    FETCH cr_crapprm
      INTO vr_nmdireto;
  
    CLOSE cr_crapprm;
  
    IF vr_nmdireto IS NULL THEN
      vr_dscritic := 'Parametro na tabela crapprm ROOT_DIRCOOP nao encontrado.';
      RAISE vr_exc_erro;
    END IF;
  
    vr_nmdireto := vr_nmdireto || vr_dsdircop || '/log/';
  
    vr_nmfilexc := NULL;
    OPEN cr_crapprm(pr_cdcooper => 0,
                    pr_nmsistem => 'CRED',
                    pr_cdacesso => 'NOME_FILA_EXCEPTI_FRAUDE');
    FETCH cr_crapprm
      INTO vr_nmfilexc;
  
    CLOSE cr_crapprm;
  
    IF vr_nmfilexc IS NULL THEN
      vr_dscritic := 'Parametro na tabela crapprm NOME_FILA_EXCEPTI_FRAUDE nao encontrado.';
      RAISE vr_exc_erro;
    END IF;
  
    vr_cdprogra := 'cecred.afra0003.pc_start_proc_fila';
    pc_geralog_fila(pr_nmdireto => vr_nmdireto,
                    pr_nmarquiv => vr_nmarqlog,
                    pr_des_text => vr_cdprogra || ' --> ' || vr_cdcritic ||
                                   ' - ' || 'Monitor inicializado na fila ' ||
                                   vr_nmfilexc,
                    pr_des_erro => vr_des_erro);
  
    pc_start_proc_fila(pr_cdcritic => vr_cdcritic,
                       pr_dscritic => vr_dscritic,
                       pr_nmfilexc => vr_nmfilexc);
  
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      pc_geralog_fila(pr_nmdireto => vr_nmdireto,
                      pr_nmarquiv => vr_nmarqlog,
                      pr_des_text => vr_cdprogra || ' --> ' || vr_cdcritic ||
                                     ' - ' || vr_dscritic,
                      pr_des_erro => vr_des_erro);
    
    END IF;
  
    COMMIT;
  
  EXCEPTION 
    WHEN vr_exc_erro THEN
      raise_application_error(-20501,vr_dscritic);      
    WHEN OTHERS THEN
      raise_application_error(-20501,'Nao foi possivel incializar servico: '|| SQLERRM);  
  END pc_inicializafila;

  --> Rotina para finalizar/Parar o monitoramento da fila de exception
  PROCEDURE pc_finalizafila IS
  
    /* ..........................................................................
    
      Programa : pc_finalizafila        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Oscar
      Data     : Fevereiro/2017.                   Ultima atualizacao: 22/02/2017
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para finalizar/Parar o monitoramento da fila de exception
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    
    -----------> VARIAVEIS <-----------
    vr_nmfilfra crapprm.dsvlrprm%TYPE;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;
    vr_cdcritic NUMBER := 0;
    vr_cdprogra VARCHAR2(50);
    vr_nmarqlog crapprm.dsvlrprm%TYPE;
    vr_nmfilexc crapprm.dsvlrprm%TYPE;
    vr_dsdircop crapcop.dsdircop%TYPE;
    vr_nmdireto crapprm.dsvlrprm%TYPE;
    vr_des_erro VARCHAR2(4000);
  
  begin
    vr_nmarqlog := NULL;
    OPEN cr_crapprm(pr_cdcooper => 0,
                    pr_nmsistem => 'CRED',
                    pr_cdacesso => 'NOME_ARQLOG_FILA');
    FETCH cr_crapprm
      INTO vr_nmarqlog;
  
    CLOSE cr_crapprm;
  
    IF vr_nmarqlog IS NULL THEN
      vr_dscritic := 'Parametro na tabela crapprm NOME_ARQLOG_FILA nao encontrado.';
      RAISE vr_exc_erro;
    END IF;
  
    OPEN cr_crapcop(pr_cdcooper => 3);
    FETCH cr_crapcop
      INTO vr_dsdircop;
    CLOSE cr_crapcop;
  
    IF vr_dsdircop IS NULL THEN
      vr_dscritic := 'Parametro na tabela crapcop DSDIRCOP nao encontrado.';
      RAISE vr_exc_erro;
    END IF;
  
    vr_nmdireto := NULL;
    OPEN cr_crapprm(pr_cdcooper => 3,
                    pr_nmsistem => 'CRED',
                    pr_cdacesso => 'ROOT_DIRCOOP');
    FETCH cr_crapprm
      INTO vr_nmdireto;
  
    CLOSE cr_crapprm;
  
    IF vr_nmdireto IS NULL THEN
      vr_dscritic := 'Parametro na tabela crapprm ROOT_DIRCOOP nao encontrado.';
      RAISE vr_exc_erro;
    END IF;
  
    vr_nmdireto := vr_nmdireto || vr_dsdircop || '/log/';
  
    vr_nmfilexc := NULL;
    OPEN cr_crapprm(pr_cdcooper => 0,
                    pr_nmsistem => 'CRED',
                    pr_cdacesso => 'NOME_FILA_EXCEPTI_FRAUDE');
    FETCH cr_crapprm
      INTO vr_nmfilexc;
  
    CLOSE cr_crapprm;
  
    IF vr_nmfilexc IS NULL THEN
      vr_dscritic := 'Parametro na tabela crapprm NOME_FILA_EXCEPTI_FRAUDE nao encontrado.';
      RAISE vr_exc_erro;
    END IF;
  
    vr_nmfilfra := NULL;
    OPEN cr_crapprm(pr_cdcooper => 0,
                    pr_nmsistem => 'CRED',
                    pr_cdacesso => 'NOME_FILA_ANALISE_FRAUDE');
    FETCH cr_crapprm
      INTO vr_nmfilfra;
  
    CLOSE cr_crapprm;
  
    IF vr_nmfilfra IS NULL THEN
      vr_dscritic := 'Parametro na tabela crapprm NOME_FILA_ANALISE_FRAUDE nao encontrado.';
      RAISE vr_exc_erro;
    END IF;
  
    vr_cdprogra := 'cecred.afra0003.pc_stop_proc_fila';
  
    pc_geralog_fila(pr_nmdireto => vr_nmdireto,
                    pr_nmarquiv => vr_nmarqlog,
                    pr_des_text => vr_cdprogra || ' --> ' || vr_cdcritic ||
                                   ' - ' || 'Parando monitor na fila ' ||
                                   vr_nmfilexc,
                    pr_des_erro => vr_des_erro);
  
    pc_stop_proc_fila(pr_cdcritic => vr_cdcritic,
                      pr_dscritic => vr_dscritic,
                      pr_nmfilfra => vr_nmfilfra,
                      pr_nmfilexc => vr_nmfilexc);
  
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
    
      pc_geralog_fila(pr_nmdireto => vr_nmdireto,
                      pr_nmarquiv => vr_nmarqlog,
                      pr_des_text => vr_cdprogra || ' --> ' || vr_cdcritic ||
                                     ' - ' || vr_dscritic,
                      pr_des_erro => vr_des_erro);
    
    END IF;
  
    COMMIT;
  
  EXCEPTION 
    WHEN vr_exc_erro THEN
      raise_application_error(-20501,vr_dscritic);      
    WHEN OTHERS THEN
      raise_application_error(-20501,'Nao foi possivel finalizar servico: '|| SQLERRM);
  END pc_finalizafila;

end AFRA0003;
/
