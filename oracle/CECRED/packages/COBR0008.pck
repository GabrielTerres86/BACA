CREATE OR REPLACE PACKAGE CECRED.COBR0008 IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : COBR0008
  --  Sistema  : Procedimentos gerais de convenio
  --  Sigla    : CRED
  --  Autor    : Odirlei Busana - AMcom
  --  Data     : Maio/2016                     Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas gerais para manter convenio
  --
  --  Alteracoes:
  ---------------------------------------------------------------------------------------------------------------   
  
  --> Procedimento para gravar o log de adesao ou bloqueio do convenio
  PROCEDURE pc_gera_log_ceb (pr_idorigem      IN INTEGER,
                             pr_cdcooper      IN crapcop.cdcooper%TYPE,
                             pr_cdoperad      IN crapope.cdoperad%TYPE,
                             pr_nrdconta      IN crapass.nrdconta%TYPE,
                             pr_nrconven      IN crapceb.nrconven%TYPE,     
                             pr_dstransa      IN VARCHAR2 DEFAULT NULL, --> Descricao de transacao
                             pr_insitceb_ant  IN crapceb.insitceb%TYPE DEFAULT 0, -- Situacao anterior
                             pr_insitceb      IN crapceb.insitceb%TYPE,
                             pr_dscritic     OUT VARCHAR2);  

  --> Procedimento para alterar situacao do ceb
  PROCEDURE pc_alter_insitceb (pr_idorigem      IN INTEGER,               --> Sistema origem
                               pr_cdcooper      IN crapcop.cdcooper%TYPE, --> Codigo da cooperativa
                               pr_cdoperad      IN crapope.cdoperad%TYPE, --> Codigo do operador
                               pr_nrdconta      IN crapass.nrdconta%TYPE, --> Numero da conta do cooperado
                               pr_nrconven      IN crapceb.nrconven%TYPE, --> Numero do convenio
                               pr_nrcnvceb      IN crapceb.nrcnvceb%TYPE, --> Numero do bloqueto
                               pr_insitceb      IN crapceb.insitceb%TYPE, --> Nova situação
                               pr_dscritic     OUT VARCHAR2);             --> Retorna critica
END COBR0008;
/
CREATE OR REPLACE PACKAGE BODY CECRED.COBR0008 IS

 ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : COBR0008
  --  Sistema  : Procedimentos gerais de convenio
  --  Sigla    : CRED
  --  Autor    : Odirlei Busana - AMcom
  --  Data     : Maio/2016                     Ultima atualizacao:
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Rotinas gerais para manter convenio
  --
  --  Alteracoes:
  ---------------------------------------------------------------------------------------------------------------   
  
  ------------------------------- CURSORES ---------------------------------    
  
  
  --> Procedimento para gravar o log do convenio
  PROCEDURE pc_gera_log_ceb (pr_idorigem      IN INTEGER,
                             pr_cdcooper      IN crapcop.cdcooper%TYPE,
                             pr_cdoperad      IN crapope.cdoperad%TYPE,
                             pr_nrdconta      IN crapass.nrdconta%TYPE,
                             pr_nrconven      IN crapceb.nrconven%TYPE,     
                             pr_dstransa      IN VARCHAR2 DEFAULT NULL, --> Descricao de transacao
                             pr_insitceb_ant  IN crapceb.insitceb%TYPE DEFAULT 0, -- Situacao anterior
                             pr_insitceb      IN crapceb.insitceb%TYPE,
                             pr_dscritic     OUT VARCHAR2) IS
        
  /* .............................................................................

    Programa: pc_gera_log_ceb           
    Sistema : Ayllos Web
    Autor   : Odirlei Busana - AMcom
    Data    : Abril/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Rotina para gerar log ceb dos convenios

    Alteracoes:
  ..............................................................................*/  
    vr_nrdrowid ROWID;
    vr_dsorigem VARCHAR2(100);
    vr_dstransa VARCHAR2(100);
    vr_dsstatus VARCHAR2(100);
    vr_exc_erro EXCEPTION;
    vr_dscritic VARCHAR2(4000);

        
  BEGIN
    vr_dsorigem := gene0001.vr_vet_des_origens(pr_idorigem); --'AYLLOS'
        
    --> Definir descricao
    CASE pr_insitceb
      WHEN 1 THEN vr_dsstatus := 'ATIVO';
      WHEN 2 THEN vr_dsstatus := 'INATIVO';
      WHEN 3 THEN vr_dsstatus := 'PENDENTE';
      WHEN 4 THEN vr_dsstatus := 'BLOQUEADO';
      WHEN 5 THEN vr_dsstatus := 'APROVADO';
      WHEN 6 THEN vr_dsstatus := 'NAO APROVADO';
      ELSE vr_dsstatus := NULL;
    END CASE;  
    
    --> verificar se informacao veio via parametro
    IF pr_dstransa IS NOT NULL THEN
      vr_dstransa := pr_dstransa;    
    ELSIF pr_insitceb = 1 THEN
      vr_dstransa := 'Adesao de convenio de cobranca';
    ELSIF pr_insitceb = 2 THEN
      vr_dstransa := 'Cancelamento do convenio de cobranca';
    ELSIF pr_insitceb = 5 THEN
      vr_dstransa := 'Convênio ' || pr_nrconven || ' foi aprovado';        
    ELSE -- 'BLOQUEADO' ou 'PENDENTE'
      vr_dstransa := 'Convenio de cobranca ' || pr_nrconven ||' '||upper(vr_dsstatus); 
    END IF;  

    -- Gera log na lgm
    gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper,
                         pr_cdoperad => pr_cdoperad,
                         pr_dscritic => '',
                         pr_dsorigem => vr_dsorigem,
                         pr_dstransa => vr_dstransa,
                         pr_dttransa => TRUNC(SYSDATE),
                         pr_flgtrans => 1,
                         pr_hrtransa => GENE0002.fn_char_para_number(to_char(SYSDATE,'SSSSSSS')),
                         pr_idseqttl => 1,
                         pr_nmdatela => 'COBRANCA',
                         pr_nrdconta => pr_nrdconta,
                         pr_nrdrowid => vr_nrdrowid);

    -- Convenio
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'Convenio',
                              pr_dsdadant => '',
                              pr_dsdadatu => pr_nrconven);

    -- Convenio
    gene0001.pc_gera_log_item(pr_nrdrowid => vr_nrdrowid,
                              pr_nmdcampo => 'Status',
                              pr_dsdadant => pr_insitceb_ant,
                              pr_dsdadatu => upper(vr_dsstatus));


    --> Gerar LOG para tela ATENDA >> COBRANCA >> Log
    BEGIN
      INSERT INTO TBCOBRAN_LOG_CONV
             (cdcooper, 
              nrdconta, 
              nrconven, 
              dhlog, 
              dslog, 
              insit_anterior, 
              insit_atual, 
              cdoperad, 
              idorigem)
       VALUES(pr_cdcooper, 
              pr_nrdconta, 
              pr_nrconven, 
              SYSDATE,        -- dhlog
              vr_dstransa,    -- dslog
              pr_insitceb_ant,-- insit_anterior,
              pr_insitceb,    -- insit_atual, 
              pr_cdoperad, 
              pr_idorigem);      
        
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Nao foi possivel gerar log(TBCOBRAN_LOG_CONV):'||SQLERRM;
        RAISE vr_exc_erro;
    END;
        
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel gerar log:'||SQLERRM;
  END pc_gera_log_ceb;
  
  --> Procedimento para alterar situacao do ceb
  PROCEDURE pc_alter_insitceb (pr_idorigem      IN INTEGER,               --> Sistema origem
                               pr_cdcooper      IN crapcop.cdcooper%TYPE, --> Codigo da cooperativa
                               pr_cdoperad      IN crapope.cdoperad%TYPE, --> Codigo do operador
                               pr_nrdconta      IN crapass.nrdconta%TYPE, --> Numero da conta do cooperado
                               pr_nrconven      IN crapceb.nrconven%TYPE, --> Numero do convenio
                               pr_nrcnvceb      IN crapceb.nrcnvceb%TYPE, --> Numero do bloqueto
                               pr_insitceb      IN crapceb.insitceb%TYPE, --> Nova situação
                               pr_dscritic     OUT VARCHAR2) IS           --> Retorna critica
        
  /* .............................................................................

    Programa: pc_alter_insitceb           
    Sistema : Ayllos Web
    Autor   : Odirlei Busana - AMcom
    Data    : Maio/2016                 Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  :Procedimento para alterar situacao do ceb

    Alteracoes:
  ..............................................................................*/  
    
  ------------------------------- CURSORES ---------------------------------  
    -- Cadastro de Bloquetos
    CURSOR cr_crapceb(pr_cdcooper IN crapceb.cdcooper%TYPE
                     ,pr_nrdconta IN crapceb.nrdconta%TYPE
                     ,pr_nrconven IN crapceb.nrconven%TYPE
                     ,pr_nrcnvceb IN crapceb.nrcnvceb%TYPE) IS
      SELECT crapceb.rowid
            ,crapceb.insitceb
        FROM crapceb
       WHERE crapceb.cdcooper = pr_cdcooper
         AND crapceb.nrdconta = pr_nrdconta
         AND crapceb.nrconven = pr_nrconven
         AND crapceb.nrcnvceb = pr_nrcnvceb;
    rw_crapceb cr_crapceb%ROWTYPE;
  ------------------------------- VARIAVEIS -------------------------------
    vr_exc_erro EXCEPTION;
    vr_cdcritic INTEGER;
    vr_dscritic VARCHAR2(4000);
        
  BEGIN
    /* INSITCEB
       --> 1 => 'ATIVO'
       --> 2 => 'INATIVO'
       --> 3 => 'PENDENTE'
       --> 4 => 'BLOQUEADO'
       --> 5 => 'APROVADO'
       --> 6 => 'NAO APROVADO' */
   
    --> Verificar situacao informada
    IF pr_insitceb NOT BETWEEN 1 AND 6 THEN
      vr_dscritic := 'Situação do convenio inválida.';
      RAISE vr_exc_erro;
    END IF;  
    
    -- Cadastro de bloquetos
    OPEN cr_crapceb(pr_cdcooper => pr_cdcooper
                   ,pr_nrdconta => pr_nrdconta
                   ,pr_nrconven => pr_nrconven
                   ,pr_nrcnvceb => pr_nrcnvceb);
    FETCH cr_crapceb INTO rw_crapceb;
    IF cr_crapceb%NOTFOUND THEN
      CLOSE cr_crapceb;
      vr_cdcritic := 563; --563 - Convenio nao cadastrado.
      RAISE vr_exc_erro;
    ELSE
      CLOSE cr_crapceb;
    END IF;
    
  
    ------->> ATUALIZAR CONVENIO <<--------
    BEGIN
      -- se convenio for aprovado ou reprovado
      -- gravar o operador que fez a analise
      IF pr_insitceb IN (5,6) THEN
        UPDATE crapceb ceb
           SET ceb.insitceb = pr_insitceb
              ,ceb.cdopeana = pr_cdoperad
              ,ceb.dhanalis = SYSDATE
         WHERE ceb.rowid = rw_crapceb.rowid;              
      ELSE
        UPDATE crapceb ceb
           SET ceb.insitceb = pr_insitceb
         WHERE ceb.rowid = rw_crapceb.rowid;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Não foi possivel atualizar convenio :'||SQLERRM;
        RAISE vr_exc_erro;                         
    END;
            
    ------->> GRAVAR LOG <<--------
    COBR0008.pc_gera_log_ceb
                    (pr_idorigem  => pr_idorigem,
                     pr_cdcooper  => pr_cdcooper,
                     pr_cdoperad  => pr_cdoperad,
                     pr_nrdconta  => pr_nrdconta,
                     pr_nrconven  => pr_nrconven,
                     pr_insitceb_ant => nvl(rw_crapceb.insitceb,0),
                     pr_insitceb  => pr_insitceb, 
                     pr_dscritic  => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      IF nvl(vr_cdcritic,0) <> 0 AND 
         TRIM(vr_dscritic) IS NULL THEN
        pr_dscritic := GENE0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      ELSE
        pr_dscritic := vr_dscritic;
      END IF;
    WHEN OTHERS THEN
      pr_dscritic := 'Nao foi possivel gerar log:'||SQLERRM;  
  END pc_alter_insitceb;
  
END COBR0008;
/
