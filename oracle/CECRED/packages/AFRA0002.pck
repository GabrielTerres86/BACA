CREATE OR REPLACE PACKAGE CECRED.AFRA0002 is
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : AFRA0002
      Sistema  : Rotinas referentes as Filas de Analise de Fraude
      Sigla    : AFRA
      Autor    : Odirlei Busana - AMcom
      Data     : Fevereiro/2017.                   Ultima atualizacao: 03/02/2017

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas referentes as Filas de Analise de Fraude.

      Alteracoes:

  ---------------------------------------------------------------------------------------------------------------*/
  
  --> Rotina para incluir analise na fila  
  PROCEDURE pc_incluir_analise_fila (pr_idanalis   IN tbgen_analise_fraude.idanalise_fraude%TYPE, --> Identificador da analise 
                                     pr_qtsegret   IN NUMBER,                                     --> Tempo em segundos que irá aguardar na fila
                                     pr_cdcritic  OUT INTEGER,
                                     pr_dscritic  OUT VARCHAR2 );
                                       
  --> Rotina para remover analise na fila  
  PROCEDURE pc_remover_analise_fila (pr_idanalis  tbgen_analise_fraude.idanalise_fraude%TYPE, --> Identificador da analise 
                                     pr_cdcritic  OUT INTEGER,
                                     pr_dscritic  OUT VARCHAR2 ) ;                                     
                                       
END AFRA0002;
/
CREATE OR REPLACE PACKAGE BODY CECRED.AFRA0002 is
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : AFRA0002
      Sistema  : Rotinas referentes as Filas de Analise de Fraude
      Sigla    : AFRA
      Autor    : Odirlei Busana - AMcom
      Data     : Fevereiro/2017.                   Ultima atualizacao: 03/02/2017

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas referentes as Filas de Analise de Fraude.  - PRJ335 - Analise de Fraude

      Alteracoes:

  ---------------------------------------------------------------------------------------------------------------*/     
  
  --> Rotina para incluir analise na fila  
  PROCEDURE pc_incluir_analise_fila (pr_idanalis   IN tbgen_analise_fraude.idanalise_fraude%TYPE, --> Identificador da analise 
                                     pr_qtsegret   IN NUMBER,                                     --> Tempo em segundos que irá aguardar na fila
                                     pr_cdcritic  OUT INTEGER,
                                     pr_dscritic  OUT VARCHAR2 ) IS
  /* ..........................................................................
    
      Programa : pc_incluir_analise_fila        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Fevereiro/2017.                   Ultima atualizacao: 03/02/2017
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel em incluir analise na fila  
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;   
    
    --> Variaveis de configuração da fila
    vr_nmfilfra        crapprm.dsvlrprm%TYPE;
    vr_nmfilexc        crapprm.dsvlrprm%TYPE;
    vr_enqoptin        dbms_aq.enqueue_options_t;
    vr_msgprope        dbms_aq.message_properties_t;
    vr_msghandl        RAW(16);
    vr_messagem        admfilascecred.tpmensagem;
    --message_id         NUMBER;
    vr_qtseqexp        NUMBER := 10; 
    
    
  BEGIN
    vr_nmfilexc := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',  
                                             pr_cdacesso => 'NOME_FILA_EXCEPTI_FRAUDE' );
    IF vr_nmfilexc IS NULL THEN
      vr_dscritic := 'Parametro na tabela crapprm NOME_FILA_EXCEPTI_FRAUDE nao encontrado.';
      RAISE vr_exc_erro;
    END IF;
  
   vr_nmfilfra := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',  
                                                      pr_cdacesso => 'NOME_FILA_ANALISE_FRAUDE' );
    IF vr_nmfilfra IS NULL THEN
      vr_dscritic := 'Parametro na tabela crapprm NOME_FILA_ANALISE_FRAUDE nao encontrado.';
      RAISE vr_exc_erro;
    END IF;                                           
    
    --> Atribuir conteudo da mensagem que ficará na fila
    vr_messagem := admfilascecred.tpmensagem(pr_idanalis);
  
    --> Definir parametros da fila
    vr_enqoptin.VISIBILITY         := DBMS_AQ.ON_COMMIT;
    vr_enqoptin.DELIVERY_MODE      := DBMS_AQ.PERSISTENT;
    
    --> Definir tempo de expiração(em segundos)
    vr_qtseqexp := pr_qtsegret;
        
    --> Atribuir propriedades mensagem 
    vr_msgprope.PRIORITY        := pr_idanalis;
    vr_msgprope.DELAY           := 0;
    vr_msgprope.EXPIRATION      := vr_qtseqexp;
    vr_msgprope.CORRELATION     := TO_CHAR(pr_idanalis);
    vr_msgprope.EXCEPTION_QUEUE := vr_nmfilexc;
  
    --> Incluir dados na fila
    DBMS_AQ.ENQUEUE(queue_name         => vr_nmfilfra,
                    enqueue_options    => vr_enqoptin,
                    message_properties => vr_msgprope,
                    payload            => vr_messagem,
                    msgid              => vr_msghandl);
  

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
      pr_dscritic := 'Não foi possivel incluir analise na fila: '||SQLERRM;
  END pc_incluir_analise_fila; 
  
  
  --> Rotina para remover analise na fila  
  PROCEDURE pc_remover_analise_fila (pr_idanalis  tbgen_analise_fraude.idanalise_fraude%TYPE, --> Identificador da analise 
                                     pr_cdcritic  OUT INTEGER,
                                     pr_dscritic  OUT VARCHAR2 ) IS
  /* ..........................................................................
    
      Programa : pc_remover_analise_fila        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Fevereiro/2017.                   Ultima atualizacao: 03/02/2017
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para remover analise na fila  
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(4000);
    vr_exc_erro EXCEPTION;   
    
    --> Variaveis de configuração da fila
    vr_nmfilfra        crapprm.dsvlrprm%TYPE;
    vr_messagem        admfilascecred.tpmensagem;    
    vr_denqopti        dbms_aq.dequeue_options_t;
    vr_msgprope        dbms_aq.message_properties_t;
    vr_msghandl        RAW(16);
  BEGIN
    vr_nmfilfra  := gene0001.fn_param_sistema(pr_nmsistem => 'CRED',  
                                                      pr_cdacesso => 'NOME_FILA_ANALISE_FRAUDE' );
    IF vr_nmfilfra IS NULL THEN
      vr_dscritic := 'Parametro na tabela crapprm NOME_FILA_ANALISE_FRAUDE nao encontrado.';
      RAISE vr_exc_erro;
    END IF;                                           
    
    vr_denqopti.navigation    := DBMS_AQ.FIRST_MESSAGE;
    vr_denqopti.CONSUMER_NAME := NULL;
    vr_denqopti.DEQUEUE_MODE  := DBMS_AQ.REMOVE;
    vr_denqopti.VISIBILITY    := DBMS_AQ.ON_COMMIT;
    vr_denqopti.WAIT          := DBMS_AQ.NO_WAIT;
    vr_denqopti.DELIVERY_MODE := DBMS_AQ.PERSISTENT;
    vr_denqopti.MSGID         := NULL;
    vr_denqopti.CORRELATION   := pr_idanalis;
    
    --> Remover analise da fila
    DBMS_AQ.DEQUEUE(queue_name         => vr_nmfilfra,
                    dequeue_options    => vr_denqopti,
                    message_properties => vr_msgprope,
                    payload            => vr_messagem,
                    msgid              => vr_msghandl);


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
      pr_dscritic := 'Não foi possivel remover analise da fila: '||SQLERRM;
  END pc_remover_analise_fila; 
  
  
  
END AFRA0002;
/
