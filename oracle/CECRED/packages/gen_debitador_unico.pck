CREATE OR REPLACE PACKAGE cecred.gen_debitador_unico AS

  -----------------------------------------------------------------------------------------------
  --
  --  Programa  : GEN_DEBITADOR_UNICO
  --  Sistema   : Pacote de Rotinas gen�ricas focando nas funcionalidades do Debitador �nico 
  --  Autor     : Marcelo Elias Gon�alves - AMcom Sistemas de Informa��o
  --  Data      : Maio/2018                               �ltima atualiza��o: 
  --  Frequ�ncia: Conforme chamada
  --  Objetivo  : Empacotar as rotinas referente ao Debitador �nico
  --
  --  Altera��es: 
  -- 
  -----------------------------------------------------------------------------------------------
  
  -- Vari�veis de cr�ticas
  vr_cdcritic       crapcri.cdcritic%TYPE;               
  vr_dscritic       crapcri.dscritic%TYPE;
    
  -- Vari�vel de exce��o/erro     
  vr_exc_email      EXCEPTION;
  
  /* Gera LOG de execu��o dos programas */
  PROCEDURE pc_gera_log_execucao(pr_nmprgexe IN VARCHAR2
                                ,pr_indexecu IN VARCHAR2
                                ,pr_cdcooper IN INTEGER 
                                ,pr_tpexecuc IN VARCHAR2
                                ,pr_idtiplog IN VARCHAR2 -- I = Inicio, O = Ocorrencia, E = Erro ou F = Fim
                                ,pr_dtmvtolt IN DATE);
  
  /* Atualiza Par�metro de qual programa/cooperativa ocasionou erro no Debitador �nico */
  PROCEDURE pc_atualiz_erro_prg_debitador(pr_nmsistem IN crapprm.nmsistem%TYPE
                                         ,pr_cdcooper IN crapprm.cdcooper%TYPE
                                         ,pr_cdacesso IN crapprm.cdacesso%TYPE
                                         ,pr_dsvlrprm IN crapprm.dsvlrprm%TYPE);
                                         
  /* Verifica se a j� executou a integra��o ABBC */  
  PROCEDURE pc_valida_integracao_abbc(pr_cdcooper                 IN tbgen_prglog.cdcooper%TYPE
                                     ,pr_tpexecucao               IN tbgen_prglog.tpexecucao%TYPE
                                     ,pr_cdprograma               IN tbgen_prglog.cdprograma%TYPE
                                     ,pr_dhinicio                 IN tbgen_prglog.dhinicio%TYPE
                                     ,pr_dhfim                    IN tbgen_prglog.dhfim%TYPE
                                     ,pr_flgsucesso               IN tbgen_prglog.flgsucesso%TYPE
                                     ,pr_inexecutou_integra_abbc OUT VARCHAR2                                  
                                     ,pr_dscritic                OUT crapcri.dscritic%TYPE);                                         
   
  /* Valida Hor�rio do Processo */
  PROCEDURE pc_valida_hora_processo(pr_dhprocessamento IN tbgen_debitador_horario.dhprocessamento%TYPE
                                   ,pr_cdprocesso      IN tbgen_debitador_horario_proc.cdprocesso%TYPE                           
                                   ,pr_ds_erro        OUT crapcri.dscritic%TYPE);
   
  /* Valida se o programa pode ser chamado na execu��o emergencial de Programas Espec�ficos */
  PROCEDURE pc_valida_exec_emergencial_prg (pr_cdcooper     IN crapcop.cdcooper%TYPE                                
                                           ,pr_cdprocesso   IN VARCHAR2
                                           ,pr_ds_erro     OUT crapcri.dscritic%TYPE);
                                                                                                              
  /* Valida dados para Execu��o Emergencial */
  PROCEDURE pc_valida_exec_emergencial(pr_cdcooper           IN crapcop.cdcooper%TYPE
                                      ,pr_tpexec_emergencial IN VARCHAR2 --P=Programa(s) Espec�ficos ou E=Apartir da prioridade do programa que ocasionou erro no debitador
                                      ,pr_dh_erro            OUT DATE
                                      ,pr_cd_prg_erro        OUT tbgen_debitador_param.cdprocesso%TYPE
                                      ,pr_nrprioridade       OUT tbgen_debitador_param.nrprioridade%TYPE                                
                                      ,pr_cd_erro            OUT crapcri.cdcritic%TYPE              
                                      ,pr_ds_erro            OUT crapcri.dscritic%TYPE); 
                                      
  /* Decrementa quantidade no controle de execu��es do programa */
  PROCEDURE pc_atualiza_ctrl_exec_prg (pr_cdcooper              IN crapcop.cdcooper%TYPE                                
                                      ,pr_ds_cdprocesso         IN VARCHAR2
                                      ,pr_nrprioridade_prg_erro IN tbgen_debitador_param.nrprioridade%TYPE
                                      ,pr_ds_erro              OUT crapcri.dscritic%TYPE);                                      
                                      
  /* Verifica quantidade de execu��es do programa durante o dia no Debitador �nico */
  PROCEDURE pc_qt_hora_prg_debitador(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                    ,pr_cdprocesso IN tbgen_debitador_param.cdprocesso%TYPE                                
                                    ,pr_ds_erro   OUT crapcri.dscritic%TYPE); 
                                    
  /* Verificar se h� algun JOB do Debitador rodando para a Cooperativa */
  PROCEDURE pc_verifica_job_running(pr_cdcooper             IN crapcop.cdcooper%TYPE   
                                   ,pr_idhora_processamento IN tbgen_debitador_horario_proc.idhora_processamento%TYPE
                                   ,pr_job_name_running    OUT dba_scheduler_jobs.job_name%TYPE
                                   ,pr_start_date          OUT VARCHAR2                                                         
                                   ,pr_ds_erro             OUT crapcri.dscritic%TYPE);                                                                                                                 
                                         
  /* Dropa e Recria JOB's do Debitador �nico conforme parametriza��o tela (tbgen_debitador_param) */
  PROCEDURE pc_job_debitador_unico(pr_idhora_processamento IN tbgen_debitador_horario_proc.idhora_processamento%TYPE
                                  ,pr_idtipo_operacao      IN VARCHAR2); --I=Incluir ou E=Excluir
                                                                               
  /* Executar Debitador �nico */
  PROCEDURE pc_executa_debitador_unico(pr_cdcooper              IN crapcop.cdcooper%TYPE
                                      ,pr_idhora_processamento  IN tbgen_debitador_horario_proc.idhora_processamento%TYPE
                                      ,pr_ds_cdprocesso         IN VARCHAR2
                                      ,pr_nrprioridade_prg_erro IN tbgen_debitador_param.nrprioridade%TYPE);
                                      
END gen_debitador_unico;
/
CREATE OR REPLACE PACKAGE BODY cecred.gen_debitador_unico AS 
                                                 
  -----------------------------------------------------------------------------------------------
  --
  --  Programa  : GEN_DEBITADOR_UNICO
  --  Sistema   : Pacote de Rotinas gen�ricas focando nas funcionalidades do Debitador �nico 
  --  Autor     : Marcelo Elias Gon�alves - AMcom Sistemas de Informa��o
  --  Data      : Maio/2018                               �ltima atualiza��o: 
  --  Frequ�ncia: Conforme chamada
  --  Objetivo  : Empacotar as rotinas referente ao Debitador �nico
  --
  --  Altera��es: 
  -- 
  -----------------------------------------------------------------------------------------------
  
  
  /* Gera LOG de execu��o dos programas */
  PROCEDURE pc_gera_log_execucao(pr_nmprgexe  IN VARCHAR2
                                ,pr_indexecu  IN VARCHAR2
                                ,pr_cdcooper  IN INTEGER 
                                ,pr_tpexecuc  IN VARCHAR2
                                ,pr_idtiplog  IN VARCHAR2 -- I = Inicio, O = Ocorrencia, E = Erro ou F = Fim
                                ,pr_dtmvtolt  IN DATE) IS
    vr_nmarqlog  VARCHAR2(500);
    vr_desdolog  VARCHAR2(2000);
    vr_tempo     NUMBER;
  BEGIN      
    
    -- Log prcctl: Exclusivo para DBNET, DBSIC e CRPS688          
    IF Upper(pr_nmprgexe) IN ('PC_CRPS509_PRIORI','PC_CRPS509','PC_CRPS642_PRIORI','PC_CRPS642','PC_CRPS688') THEN
      -- Definir nome do log
      vr_nmarqlog := 'prcctl_'||to_char(pr_dtmvtolt,'RRRRMMDD')||'.log';
      --> Definir descri��o do log
      vr_desdolog := 'Automatizado - '||to_char(SYSDATE,'HH24:MI:SS')||' --> Coop.:'|| pr_cdcooper ||' '|| pr_tpexecuc ||' - '||SubStr(pr_nmprgexe,4)|| ': '|| pr_indexecu;        
    
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper, 
                                 pr_ind_tipo_log => 1, 
                                 pr_des_log      => vr_desdolog, 
                                 pr_nmarqlog     => vr_nmarqlog,
                                 pr_cdprograma   => SubStr(pr_nmprgexe,4));
    END IF;                              
     
    -- Logs Programas Gerais                                                                 
    -- Incluir log no proc_batch.log
    IF pr_idtiplog = 'I' THEN --> Inicio
      -- inicializar o tempo
      vr_tempo := to_char(SYSDATE,'SSSSS');           
      vr_desdolog := to_char(SYSDATE,'HH24:MI:SS')||' - '|| pr_nmprgexe ||' --> Inicio da execucao.';      
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper, 
                                 pr_ind_tipo_log => 1, 
                                 pr_des_log      => vr_desdolog,
                                 pr_dstiplog     => 'I',
                                 pr_cdprograma   => pr_nmprgexe); 
                                 
    ELSIF pr_idtiplog = 'O' THEN --> Ocorrencia             
      vr_desdolog := to_char(SYSDATE,'HH24:MI:SS')||' - '|| pr_nmprgexe ||' --> Ocorrencia: '||pr_indexecu;      
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper, 
                                 pr_ind_tipo_log => 1, 
                                 pr_des_log      => vr_desdolog,
                                 pr_dstiplog     => 'O',
                                 pr_cdprograma   => pr_nmprgexe);                                 
                                     
    ELSIF pr_idtiplog = 'E' THEN --> Erro             
      vr_desdolog := to_char(SYSDATE,'HH24:MI:SS')||' - '|| pr_nmprgexe ||' --> Erro: '||pr_indexecu;      
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper, 
                                 pr_ind_tipo_log => 1, 
                                 pr_des_log      => vr_desdolog,
                                 pr_dstiplog     => 'E',
                                 pr_cdprograma   => pr_nmprgexe);
                                     
    ELSIF pr_idtiplog = 'F' THEN --> Fim               
      vr_desdolog := to_char(SYSDATE,'HH24:MI:SS')||' - '|| pr_nmprgexe ||' --> Stored Procedure rodou em '||to_char(to_date(to_char(SYSDATE,'SSSSS') - vr_tempo,'SSSSS'),'HH24:MI:SS');                     
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper, 
                                 pr_ind_tipo_log => 1, 
                                 pr_des_log      => vr_desdolog,                                   
                                 pr_dstiplog     => 'F',
                                 pr_cdprograma   => pr_nmprgexe); 
    END IF; 
    --Somente para compilar sem warnings 
    if vr_tempo is null then
      null;
    end if;                                                                    
  END pc_gera_log_execucao; 
    
  
  /* Atualiza Par�metro de qual programa/cooperativa ocasionou erro no Debitador �nico */
  PROCEDURE pc_atualiz_erro_prg_debitador(pr_nmsistem IN crapprm.nmsistem%TYPE
                                         ,pr_cdcooper IN crapprm.cdcooper%TYPE
                                         ,pr_cdacesso IN crapprm.cdacesso%TYPE
                                         ,pr_dsvlrprm IN crapprm.dsvlrprm%TYPE) IS
  BEGIN
    BEGIN
      UPDATE crapprm
      SET    dsvlrprm = pr_dsvlrprm
      WHERE  nmsistem = pr_nmsistem
      AND    cdcooper = pr_cdcooper
      AND    cdacesso = pr_cdacesso;   
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao Atualizar Par�metro (crapprm) CTRL_ERRO_PRG_DEBITADOR - Cooperativa: '||pr_cdcooper||' . Erro: '||SubStr(SQLERRM,1,255); 
        RAISE vr_exc_email;
    END;
    --
    COMMIT;
    --
  END pc_atualiz_erro_prg_debitador; 
  
  
  /* Verifica se a j� executou a integra��o ABBC */  
  PROCEDURE pc_valida_integracao_abbc(pr_cdcooper                 IN tbgen_prglog.cdcooper%TYPE
                                     ,pr_tpexecucao               IN tbgen_prglog.tpexecucao%TYPE
                                     ,pr_cdprograma               IN tbgen_prglog.cdprograma%TYPE
                                     ,pr_dhinicio                 IN tbgen_prglog.dhinicio%TYPE
                                     ,pr_dhfim                    IN tbgen_prglog.dhfim%TYPE
                                     ,pr_flgsucesso               IN tbgen_prglog.flgsucesso%TYPE
                                     ,pr_inexecutou_integra_abbc OUT VARCHAR2                                  
                                     ,pr_dscritic                OUT crapcri.dscritic%TYPE) IS 
  BEGIN 
    BEGIN 
      SELECT 'S'
      INTO   pr_inexecutou_integra_abbc 
      FROM   tbgen_prglog
      WHERE  cdcooper   = pr_cdcooper
      AND    tpexecucao = pr_tpexecucao                               
      AND    cdprograma = pr_cdprograma
      AND    dhinicio  >= pr_dhinicio  
      AND    dhfim     <  pr_dhfim + 1
      AND    flgsucesso = pr_flgsucesso
      AND    ROWNUM     = 1;
    EXCEPTION
      WHEN No_Data_Found THEN
        pr_inexecutou_integra_abbc := 'N';
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao validar integra��o ABBC - Cooperativa: '||pr_cdcooper||' . Erro: '||SubStr(SQLERRM,1,255);        
    END;    
  END pc_valida_integracao_abbc;  
  
  
  
  /* Valida Hor�rio do Processo */
  PROCEDURE pc_valida_hora_processo(pr_dhprocessamento IN tbgen_debitador_horario.dhprocessamento%TYPE
                                   ,pr_cdprocesso      IN tbgen_debitador_horario_proc.cdprocesso%TYPE                           
                                   ,pr_ds_erro        OUT crapcri.dscritic%TYPE) IS
    vr_erro                     EXCEPTION;                                   
    vr_ds_erro              crapcri.dscritic%TYPE;                                 
    vr_dhprocessamento_max  tbgen_debitador_horario.dhprocessamento%TYPE;                               
  BEGIN
    
    --Busca Maior Hora de Execu��o do Dia para o Programa
    BEGIN
      SELECT Max(tdh.dhprocessamento)   dhprocessamento
      INTO   vr_dhprocessamento_max
      FROM   tbgen_debitador_horario_proc  tdhp
            ,tbgen_debitador_horario       tdh   
      WHERE  tdhp.idhora_processamento = tdh.idhora_processamento       
      AND    tdhp.cdprocesso           = pr_cdprocesso;
    EXCEPTION
      WHEN OTHERS THEN
        vr_ds_erro := 'Erro ao Buscar Maior Hora de Execu��o do Dia para o Programa. Programa: '||pr_cdprocesso||'.'; 
        RAISE vr_erro;
    END;  

    --Valida��o se o hor�rio pode ser agendado para o programa
    IF vr_dhprocessamento_max IS NOT NULL THEN
      IF To_Date(To_Char(vr_dhprocessamento_max,'hh24:mi'),'hh24:mi') < To_Date(To_Char(SYSDATE,'hh24:mi'),'hh24:mi') 
        AND To_Date(To_Char(pr_dhprocessamento,'hh24:mi'),'hh24:mi') > To_Date(To_Char(vr_dhprocessamento_max,'hh24:mi'),'hh24:mi') THEN
          vr_ds_erro := 'O Programa n�o pode ser agendado para este hor�rio pois o controle da �ltima execu��o do dia j� ocorreu.';
          RAISE vr_erro;       
      END IF;
    END IF;  
    
  EXCEPTION
    WHEN vr_erro THEN   
      pr_ds_erro := vr_ds_erro;
    WHEN OTHERS THEN      
      pr_ds_erro := 'Erro ao validar hor�rio para o processo. Erro: '||SubStr(SQLERRM,1,255);
  END pc_valida_hora_processo; 
  
  /* Valida se o programa pode ser chamado na execu��o emergencial de Programas Espec�ficos */
  PROCEDURE pc_valida_exec_emergencial_prg (pr_cdcooper   IN crapcop.cdcooper%TYPE                                
                                           ,pr_cdprocesso IN VARCHAR2
                                           ,pr_ds_erro   OUT crapcri.dscritic%TYPE) IS                                           
    --Var�vel de Exce��o                                  
    vr_erro                 EXCEPTION;
    vr_ds_erro              crapcri.dscritic%TYPE;
    vr_cdacesso             VARCHAR2(100); 
    vr_prg_tem_ctrl         VARCHAR2(1) := 'N';
    vr_dhprocessamento_max  tbgen_debitador_horario.dhprocessamento%TYPE;
  BEGIN  
         
    --Monta acesso ao Parametro na (crapprm)
    IF Upper(pr_cdprocesso) = 'PC_CRPS642' THEN
      vr_cdacesso := 'CTRL_DEBSIC_EXEC';      
    ELSIF Upper(pr_cdprocesso) = 'PC_CRPS642_PRIORI' THEN
      vr_cdacesso := 'CTRL_DEBSIC_PRIORI_EXEC';
    ELSIF Upper(pr_cdprocesso) = 'PC_CRPS509' THEN
      vr_cdacesso := 'CTRL_DEBNET_EXEC';
    ELSIF Upper(pr_cdprocesso) = 'PC_CRPS509_PRIORI' THEN
      vr_cdacesso := 'CTRL_DEBNET_PRIORI_EXEC';
    ELSIF Upper(pr_cdprocesso) = 'RCEL0001.PC_PROCES_AGENDAMENTOS_RECARGA' THEN
      vr_cdacesso := 'CTRL_JOBAGERCEL_EXEC';
    ELSIF Upper(pr_cdprocesso) = 'PAGA0003.PC_PROCESSA_AGEND_BANCOOB' THEN
      vr_cdacesso := 'CTRL_DEBBAN_EXEC';     
    ELSE
      vr_cdacesso := 'CTRL_'||SubStr(pr_cdprocesso,4)||'_EXEC';
    END IF;
      
    BEGIN
      SELECT 'S'
      INTO   vr_prg_tem_ctrl 
      FROM   crapprm 
      WHERE  cdacesso = vr_cdacesso
      AND    cdcooper = pr_cdcooper;
    EXCEPTION   
      WHEN No_Data_Found THEN
        vr_prg_tem_ctrl := 'N';    
      WHEN OTHERS THEN
        vr_ds_erro := 'Erro ao Verificar se o Programa tem Controle de Excu��o. Programa: '||pr_cdprocesso||'.'; 
        RAISE vr_erro;
    END;
      
    IF Nvl(vr_prg_tem_ctrl,'N') = 'S' THEN
      
      --Busca Menor/Maior Hora de Execu��o do Dia para o Programa
      BEGIN
        SELECT Max(tdh.dhprocessamento)  dhprocessamento_max
        INTO   vr_dhprocessamento_max
        FROM   tbgen_debitador_horario_proc  tdhp
              ,tbgen_debitador_horario       tdh   
        WHERE  tdhp.idhora_processamento = tdh.idhora_processamento       
        AND    tdhp.cdprocesso           = pr_cdprocesso;
      EXCEPTION       
        WHEN OTHERS THEN
          vr_ds_erro := 'Erro ao Buscar Maior Hora de Execu��o do Dia para o Programa. Programa: '||pr_cdprocesso||'.'; 
          RAISE vr_erro;
      END;
                                             
      --Se programa j� rodou �ltima execu��o do dia                              
      IF To_Date(To_Char(SYSDATE,'hh24:mi'),'hh24:mi') >= To_Date(To_Char(vr_dhprocessamento_max,'hh24:mi'),'hh24:mi') THEN
        vr_ds_erro := 'N�o � poss�vel selecionar o programa, pois o mesmo j� teve a sua �ltima execu��o do dia.';
        RAISE vr_erro;
      END IF;     
    END IF;                               
  EXCEPTION                                                                                                     
    WHEN vr_erro THEN   
      pr_ds_erro := vr_ds_erro;
    WHEN OTHERS THEN      
      pr_ds_erro := 'Erro ao validar Execu��o Emergencial. Erro: '||SubStr(SQLERRM,1,255);
  END pc_valida_exec_emergencial_prg; 
  
  
  /* Valida dados para Execu��o Emergencial */
  PROCEDURE pc_valida_exec_emergencial(pr_cdcooper           IN crapcop.cdcooper%TYPE
                                      ,pr_tpexec_emergencial IN VARCHAR2 --P=Programa(s) Espec�ficos ou E=Apartir da prioridade do programa que ocasionou erro no debitador
                                      ,pr_dh_erro            OUT DATE
                                      ,pr_cd_prg_erro        OUT tbgen_debitador_param.cdprocesso%TYPE
                                      ,pr_nrprioridade       OUT tbgen_debitador_param.nrprioridade%TYPE                                
                                      ,pr_cd_erro            OUT crapcri.cdcritic%TYPE              
                                      ,pr_ds_erro            OUT crapcri.dscritic%TYPE) IS             
    rw_crapdat                  btch0001.cr_crapdat%ROWTYPE;                                      
    vr_erro                     EXCEPTION;
    vr_cd_erro                  crapcri.cdcritic%TYPE;              
    vr_ds_erro                  crapcri.dscritic%TYPE;   
    vr_dtvalida                 DATE;                              
    vr_dtdiahoje                DATE; 
    vr_ds_dh_prg_errp           crapprm.dsvlrprm%TYPE;     
    vr_inexecutou_integra_abbc  VARCHAR2(1) := 'N';
    vr_job_name_running         dba_scheduler_jobs.job_name%TYPE;
    vr_start_date               VARCHAR2(18);
  BEGIN 
    
    -- Verifica��o do calend�rio
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
              
    IF btch0001.cr_crapdat%NOTFOUND THEN     
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1; --Sistema sem data de movimento.
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_email;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;           
  
    -- Verifica dia �til
    vr_dtdiahoje := Trunc(SYSDATE);
    vr_dtvalida  := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                               ,pr_dtmvtolt => vr_dtdiahoje
                                               ,pr_tipo     => 'A' --N�o considera �til o �ltimo dia do ano
                                               ,pr_feriado  => TRUE);    
    -- Valida Dia �til
    IF vr_dtvalida <> vr_dtdiahoje THEN
      -- Montar mensagem de critica        
      vr_ds_erro := 'A Execu��o Emergencial � permitida somente em dias �teis: '||To_Char(vr_dtdiahoje,'dd/mm/rrrr')||'.';
      RAISE vr_erro;
    END IF;   
    
    -- Verificar se h� algun JOB do Debitador rodando para a Cooperativa
    pc_verifica_job_running(pr_cdcooper             => pr_cdcooper    
                           ,pr_idhora_processamento => NULL                    
                           ,pr_job_name_running     => vr_job_name_running
                           ,pr_start_date           => vr_start_date
                           ,pr_ds_erro              => vr_ds_erro);
    -- Tratamento Erro
    IF vr_ds_erro IS NOT NULL THEN        
      RAISE vr_erro;              
    END IF;  
    
    -- Se a h� algun JOB do Debitador rodando para a Cooperativa (Running)
    IF vr_job_name_running IS NOT NULL THEN    
      vr_ds_erro := 'Execu��o Emergencial n�o permitida. H� um JOB ainda executando o Debitador: '||vr_job_name_running||' com Start em '||vr_start_date||'. (Cooperativa: '||pr_cdcooper||')';
      RAISE vr_erro; 
    END IF;   
  
    -- Verifica se a j� executou a integra��o ABBC   
    pc_valida_integracao_abbc(pr_cdcooper                => pr_cdcooper         --Coopertativa
                             ,pr_tpexecucao              => 1                   --Batch 
                             ,pr_cdprograma              => 'CRPS538'           --Processo ABBC
                             ,pr_dhinicio                => rw_crapdat.dtmvtolt --Data Inicial
                             ,pr_dhfim                   => rw_crapdat.dtmvtolt --Data Final
                             ,pr_flgsucesso              => 1                   --Indicador de sucesso da execu��o
                             ,pr_inexecutou_integra_abbc => vr_inexecutou_integra_abbc                              
                             ,pr_dscritic                => vr_ds_erro); 
    -- Tratamento Erro
    IF vr_ds_erro IS NOT NULL THEN        
      RAISE vr_erro;              
    END IF;  
    -- Se a Integra��o ABBC ainda n�o foi processada
    IF Nvl(vr_inexecutou_integra_abbc,'N') = 'N' THEN 
      vr_ds_erro := 'Execu��o Emergencial n�o permitida. CRPS538 - Integra��o ABBC ainda n�o foi processada em '||To_Char(rw_crapdat.dtmvtolt,'dd/mm/rrrr')||'. (Cooperativa: '||pr_cdcooper||').';
      RAISE vr_erro;
    END IF;            
                  
    -- Se a Cooperativa ainda estiver executando o Processo Batch (Noturna)
    IF rw_crapdat.inproces > 1 THEN
      vr_ds_erro := 'Execu��o Emergencial n�o permitida. A Cooperativa '||pr_cdcooper||' ainda est� executando o Processo Batch (Noturna).';
      RAISE vr_erro;
    END IF;                 
            
    -- Verifica se h� erro no debitador e qual programa/cooperativa ocasionou erro no Debitador �nico
    vr_ds_dh_prg_errp := gene0001.fn_param_sistema(pr_nmsistem => 'CRED' 
                                                  ,pr_cdcooper => pr_cdcooper
                                                  ,pr_cdacesso => 'CTRL_ERRO_PRG_DEBITADOR');  
    -- Se n�o encontrou o par�metro
    IF Nvl(vr_ds_dh_prg_errp,'X') = 'X' THEN
      -- Montar mensagem de critica
      vr_cd_erro := 10201; --Parametro de Controle de qual programa/cooperativa ocasionou erro no Debitador Unico. nao encontrado.
      vr_ds_erro := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);      
      RAISE vr_erro;   
    ELSE   
      -- Monta Data e Programa
      BEGIN
        pr_dh_erro     := To_Date(Trim(SubStr(vr_ds_dh_prg_errp,1,InStr(vr_ds_dh_prg_errp,'#')-1)),'dd/mm/rrrr hh24:mi');
        pr_cd_prg_erro := Trim(SubStr(vr_ds_dh_prg_errp,InStr(vr_ds_dh_prg_errp,'#')+1));
      EXCEPTION
        WHEN OTHERS THEN
          vr_ds_erro := 'Erro na Execu��o Emergencial. N�o foi poss�vel verificar Data e/ou Programa que ocasionou o erro no Debitador �nico. Cooperativa: '||pr_cdcooper||'.'; 
          RAISE vr_erro;
      END;
    END IF;                                                                                          
    
    IF pr_tpexec_emergencial = 'P' THEN
      --Se tem Programa que causou erro no Debitador no dia 
      IF Trunc(pr_dh_erro) = Trunc(SYSDATE) THEN
        vr_ds_erro := 'A Execu��o Emergencial de Processos Espec�ficos n�o pode ser executada pois existe Erro ocoasionado no Debitador atrav�s do processo '||pr_cd_prg_erro||'. A Execu��o Emergencial deve ser feita apartir da prioridade deste processo.'; 
          RAISE vr_erro;
      END IF; 
           
    ELSIF pr_tpexec_emergencial = 'E' THEN
      --Data do erro deve ser a data atual do sistema 
      IF Trunc(pr_dh_erro) <> Trunc(SYSDATE) THEN
        -- Montar mensagem de critica        
        vr_ds_erro := 'Erro na Execu��o Emergencial. N�o h� erro ocasionado no debitador para a data atual: '||To_Char(SYSDATE,'dd/mm/rrrr')||'.';         
        RAISE vr_erro;
      END IF;   
    
      --Valida se tem programa que ocasionou erro                                              
      IF pr_cd_prg_erro = 'XXXXXXX' THEN
        -- Montar mensagem de critica           
        vr_ds_erro := 'Erro na Execu��o Emergencial. N�o h� programa que ocasionou erro no debitador.';         
        RAISE vr_erro;
      END IF;                                                                                                     
                 
      -- Valida Programa do cadastro do Debitador
      BEGIN
        SELECT nrprioridade
        INTO   pr_nrprioridade
        FROM   tbgen_debitador_param  tdp
        WHERE  EXISTS (SELECT 1 
                       FROM   tbgen_debitador_horario_proc  tdhp 
                       WHERE  tdhp.cdprocesso = tdp.cdprocesso) --Programa deve estar associado a algum hor�rio do Debitador �nico        
        AND    nrprioridade IS NOT NULL --Programa deve ter prioridade informada
        AND    cdprocesso = pr_cd_prg_erro;
      EXCEPTION
        WHEN No_Data_Found THEN
          -- Montar mensagem de critica           
          vr_ds_erro := 'Erro na Execu��o Emergencial. Programa '||pr_cd_prg_erro||' que o casionou erro no Debitador n�o encontrado, sem prioridade ou sem hor�rio associado.';         
          RAISE vr_erro;
        WHEN OTHERS THEN
          -- Montar mensagem de critica        
          vr_ds_erro := 'Erro na Execu��o Emergencial. Erro ao buscar prioridade do programa '||pr_cd_prg_erro||'. Erro: '||SubStr(SQLERRM,1,255);         
          RAISE vr_erro;
      END;                     
    END IF;                      
  EXCEPTION
    WHEN vr_erro THEN
      pr_cd_erro := vr_cd_erro;
      pr_ds_erro := vr_ds_erro;
    WHEN OTHERS THEN      
      pr_ds_erro := 'Erro ao validar Execu��o Emergencial. Erro: '||SubStr(SQLERRM,1,255);
  END pc_valida_exec_emergencial;
  
  
  /* Decrementa quantidade no controle de execu��es do programa */
  PROCEDURE pc_atualiza_ctrl_exec_prg (pr_cdcooper              IN crapcop.cdcooper%TYPE                                
                                      ,pr_ds_cdprocesso         IN VARCHAR2
                                      ,pr_nrprioridade_prg_erro IN tbgen_debitador_param.nrprioridade%TYPE
                                      ,pr_ds_erro              OUT crapcri.dscritic%TYPE) IS 
    --Busca processos
    CURSOR cr_processo_horario(pr_ds_cdprocesso         IN VARCHAR2
                              ,pr_nrprioridade_prg_erro IN tbgen_debitador_param.nrprioridade%TYPE) IS  
      --Execu��o Emergencial de Programas Espec�ficos
      SELECT Upper(tdp.cdprocesso)  cdprocesso  
            ,tdp.nrprioridade       nrprioridade   
            ,SYSDATE                dhprocessamento            
      FROM   tbgen_debitador_param  tdp     
      WHERE  InStr(pr_ds_cdprocesso,tdp.cdprocesso||',') > 0
      AND    EXISTS (SELECT 1 
                     FROM   tbgen_debitador_horario_proc  tdhp 
                     WHERE  tdhp.cdprocesso = tdp.cdprocesso) --Programas que est�o associados a algum hor�rio do Debitador �nico
      AND    pr_ds_cdprocesso IS NOT NULL --Quando Chamado por Execu��o Emergencial de Programas Espec�ficos
      AND    tdp.nrprioridade IS NOT NULL --Com Prioridade informada no Debitador �nico
      UNION ALL
      --Execu��o Emergencial de Apartir do Programa que gerou Erro
      SELECT Upper(tdp.cdprocesso)  cdprocesso  
            ,tdp.nrprioridade       nrprioridade   
            ,SYSDATE                dhprocessamento            
      FROM   tbgen_debitador_param  tdp     
      WHERE  tdp.nrprioridade = pr_nrprioridade_prg_erro 
      AND    EXISTS (SELECT 1 
                     FROM   tbgen_debitador_horario_proc  tdhp 
                     WHERE  tdhp.cdprocesso = tdp.cdprocesso) --Programas que est�o associados a algum hor�rio do Debitador �nico
      AND    pr_nrprioridade_prg_erro IS NOT NULL --Quando Chamado por Execu��o Emergencial apartir do programa que gerou erro no Debitador �nico
      AND    tdp.nrprioridade         IS NOT NULL --Com Prioridade informada no Debitador �nico
      ORDER BY nrprioridade;  

    --Var�vel de Exce��o                                  
    vr_erro                   EXCEPTION;
    vr_ds_erro                crapcri.dscritic%TYPE;
    
    vr_cdacesso           VARCHAR2(100); 
    vr_dt_controle        VARCHAR2(10);
    vr_qtde_ja_executada  NUMBER := 0;
  BEGIN
    --Para cada processo
    FOR r_processo_horario IN cr_processo_horario(pr_ds_cdprocesso         => pr_ds_cdprocesso
                                                 ,pr_nrprioridade_prg_erro => pr_nrprioridade_prg_erro) LOOP                                                  
      --Monta acesso ao Parametro na (crapprm)
      IF Upper(r_processo_horario.cdprocesso) = 'PC_CRPS642' THEN
        vr_cdacesso := 'CTRL_DEBSIC_EXEC';
      ELSIF Upper(r_processo_horario.cdprocesso) = 'PC_CRPS642_PRIORI' THEN
        vr_cdacesso := 'CTRL_DEBSIC_PRIORI_EXEC';
      ELSIF Upper(r_processo_horario.cdprocesso) = 'PC_CRPS509' THEN
        vr_cdacesso := 'CTRL_DEBNET_EXEC';
      ELSIF Upper(r_processo_horario.cdprocesso) = 'PC_CRPS509_PRIORI' THEN
        vr_cdacesso := 'CTRL_DEBNET_PRIORI_EXEC';
      ELSIF Upper(r_processo_horario.cdprocesso) = 'RCEL0001.PC_PROCES_AGENDAMENTOS_RECARGA' THEN
        vr_cdacesso := 'CTRL_JOBAGERCEL_EXEC';
      ELSIF Upper(r_processo_horario.cdprocesso) = 'PAGA0003.PC_PROCESSA_AGEND_BANCOOB' THEN
        vr_cdacesso := 'CTRL_DEBBAN_EXEC';     
      ELSE
        vr_cdacesso := 'CTRL_'||SubStr(r_processo_horario.cdprocesso,4)||'_EXEC';
      END IF;   
      
      -- Busca a qtde do Controle de execu��o do programa
      BEGIN
        SELECT Trim(SubStr(dsvlrprm,1,10))
              ,Trim(SubStr(dsvlrprm,12)) 
        INTO   vr_dt_controle
              ,vr_qtde_ja_executada 
        FROM   crapprm 
        WHERE  cdacesso = vr_cdacesso
        AND    cdcooper = pr_cdcooper;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          vr_qtde_ja_executada := 0;
        WHEN OTHERS THEN
          vr_ds_erro := 'Erro ao verificar controle de execu��es do programa '||r_processo_horario.cdprocesso||'. Erro: '||SubStr(SQLERRM,255);
          RAISE vr_erro;
      END;    
      --
      IF Nvl(vr_qtde_ja_executada,0) > 0 AND  To_Date(vr_dt_controle,'dd/mm/rrrr') = Trunc(SYSDATE) THEN
        BEGIN
          UPDATE crapprm
          SET    dsvlrprm = SubStr(dsvlrprm,1,10)||'#'||(vr_qtde_ja_executada-1)
          WHERE  cdacesso = vr_cdacesso
          AND    cdcooper = pr_cdcooper;
        EXCEPTION
          WHEN No_Data_Found THEN
            vr_qtde_ja_executada := 0;
          WHEN OTHERS THEN
            vr_ds_erro := 'Erro ao atualizar controle de execu��es do programa '||r_processo_horario.cdprocesso||'. Erro: '||SubStr(SQLERRM,255);
            RAISE vr_erro;
        END;   
        --
        COMMIT;
        --  
      END IF;
    END LOOP;   
  EXCEPTION
    WHEN vr_erro THEN
      pr_ds_erro := vr_ds_erro;
    WHEN OTHERS THEN  
      pr_ds_erro := 'Erro Geral na gen_debitador_unico.pc_atualiza_ctrl_exec_prg. Erro: '||SubStr(SQLERRM,1,255);  
  END pc_atualiza_ctrl_exec_prg;
 
        
  /* Verifica quantidade de execu��es do programa durante o dia no Debitador �nico */
  PROCEDURE pc_qt_hora_prg_debitador(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                    ,pr_cdprocesso IN tbgen_debitador_param.cdprocesso%TYPE                                
                                    ,pr_ds_erro   OUT crapcri.dscritic%TYPE) IS 
    --Var�vel de Exce��o                                  
    vr_erro                   EXCEPTION;
    vr_ds_erro                crapcri.dscritic%TYPE;
    
    --Vari�vel de Controle
    vr_qt_hora_prg_debitador  NUMBER;
    vr_cdacesso               VARCHAR2(100);      
                               
  BEGIN       

    -- Busca quantidade de execu��es do programa durante o dia no Debitador �nico
    BEGIN
      SELECT Count(1)  qt_hora_prg_debitador
      INTO   vr_qt_hora_prg_debitador
      FROM   tbgen_debitador_param         tdp
            ,tbgen_debitador_horario_proc  tdhp
      WHERE  tdhp.cdprocesso       = tdp.cdprocesso      
      AND    Upper(tdp.cdprocesso) = Upper(pr_cdprocesso);
    EXCEPTION
      WHEN OTHERS THEN
        vr_ds_erro := 'Erro ao verificar quantidade de execu��es do programa '||pr_cdprocesso||' durante o dia no Debitador �nico. Erro: '||SubStr(SQLERRM,255);
        RAISE vr_erro;
    END;    
   
    --Monta acesso ao Parametro na (crapprm)
    IF Upper(pr_cdprocesso) = 'PC_CRPS642' THEN
      vr_cdacesso := 'QTD_EXEC_DEBSIC';
    ELSIF Upper(pr_cdprocesso) = 'PC_CRPS642_PRIORI' THEN
      vr_cdacesso := 'QTD_EXEC_DEBSIC_PRIORI';
    ELSIF Upper(pr_cdprocesso) = 'PC_CRPS509' THEN
      vr_cdacesso := 'QTD_EXEC_DEBNET';
    ELSIF Upper(pr_cdprocesso) = 'PC_CRPS509_PRIORI' THEN
      vr_cdacesso := 'QTD_EXEC_DEBNET_PRIORI';
    ELSIF Upper(pr_cdprocesso) = 'RCEL0001.PC_PROCES_AGENDAMENTOS_RECARGA' THEN
      vr_cdacesso := 'QTD_EXEC_'||'JOBAGERCEL';
    ELSIF Upper(pr_cdprocesso) = 'PAGA0003.PC_PROCESSA_AGEND_BANCOOB' THEN
      vr_cdacesso := 'QTD_EXEC_DEBBAN';     
    ELSE
      vr_cdacesso := 'QTD_EXEC_'||SubStr(pr_cdprocesso,4);
    END IF;     
    
    -- Atualizar quantidade de execu��es do programa durante o dia na crapprm
    BEGIN  
      UPDATE crapprm  prm
      SET    prm.dsvlrprm  = vr_qt_hora_prg_debitador
      WHERE  prm.nmsistem = 'CRED' --Fixo
      AND    prm.cdcooper = pr_cdcooper
      AND    prm.cdacesso = vr_cdacesso;
    EXCEPTION
      WHEN OTHERS THEN
        vr_ds_erro := 'Erro ao atualizar quantidade de execu��es do programa durante o dia na crapprm. Cd.Acesso: '||vr_cdacesso||'. Erro: '||SubStr(SQLERRM,255);
        RAISE vr_erro;
    END; 
    
    -- Valida se alterou o registro na crapprm
    IF SQL%ROWCOUNT = 0 THEN
      vr_ds_erro := 'Par�metro de quantidade de execu��es do programa durante o dia na crapprm n�o encontrado. Cd.Acesso: '||vr_cdacesso||'.';
      RAISE vr_erro;
    END IF;
    
    -- Salva Altera��o
    COMMIT;
    
  EXCEPTION
    WHEN vr_erro THEN
      pr_ds_erro := vr_ds_erro;
    WHEN OTHERS THEN  
      pr_ds_erro := 'Erro Geral na gen_debitador_unico.pc_qt_hora_prg_debitador. Erro: '||SubStr(SQLERRM,1,255);  
  END pc_qt_hora_prg_debitador;
  
  /* Verificar se h� algun JOB do Debitador rodando para a Cooperativa */
  PROCEDURE pc_verifica_job_running(pr_cdcooper             IN crapcop.cdcooper%TYPE   
                                   ,pr_idhora_processamento IN tbgen_debitador_horario_proc.idhora_processamento%TYPE
                                   ,pr_job_name_running    OUT dba_scheduler_jobs.job_name%TYPE
                                   ,pr_start_date          OUT VARCHAR2                                                         
                                   ,pr_ds_erro             OUT crapcri.dscritic%TYPE) IS 
    --Vari�vel Exce��o
    vr_erro           EXCEPTION;  
    vr_ds_erro        crapcri.dscritic%TYPE;    
  BEGIN
    -- Verifica se h� algum JOB do Debitador/Cooperativa executando
    BEGIN
      SELECT j.job_name                                      job_name_running
            ,To_Char(j.last_start_date,'dd/mm/rrrr hh24:mi') start_date
      INTO   pr_job_name_running
            ,pr_start_date
      FROM   dba_scheduler_jobs          j
            ,dba_scheduler_running_jobs  r
      WHERE  j.owner = 'CECRED' --Fixo                                                                                                                              
      AND    j.owner    = r.owner
      AND    j.job_name = r.job_name
      AND    UPPER(j.job_action) LIKE '%GEN_DEBITADOR_UNICO.PC_EXECUTA_DEBITADOR_UNICO%'
      AND    UPPER(j.job_action) LIKE '%PR_CDCOOPER              => '||pr_cdcooper||'%'
      -- Que n�o seja o pr�prio
      AND  ((UPPER(j.job_action) NOT LIKE '%PR_IDHORA_PROCESSAMENTO  => '||pr_idhora_processamento||'%' AND pr_idhora_processamento IS NOT NULL)
       OR    pr_idhora_processamento IS NULL) 
      AND    ROWNUM = 1; 
    EXCEPTION          
      WHEN No_Data_Found THEN  
        pr_job_name_running  := NULL;
        pr_start_date        := NULL;
      WHEN OTHERS THEN   
        vr_ds_erro := 'Erro ao verificar se existe algum job do Debitador �nico em execu��o. Erro: '||SubStr(SQLERRM,1,255);
        RAISE vr_erro;
    END;  
  EXCEPTION
    WHEN vr_erro THEN
      pr_ds_erro := vr_ds_erro;
    WHEN OTHERS THEN  
      pr_ds_erro := 'Erro Geral na gen_debitador_unico.pc_verifica_job_running. Erro: '||SubStr(SQLERRM,1,255);          
  END pc_verifica_job_running;  
  
  
  /* Dropa e Recria JOB do Debitador �nico conforme parametriza��o (tbgen_debitador_param) */
  PROCEDURE pc_job_debitador_unico(pr_idhora_processamento IN tbgen_debitador_horario_proc.idhora_processamento%TYPE
                                  ,pr_idtipo_operacao      IN VARCHAR2) IS --I=Incluir ou E=Excluir
  
    --Busca todas as Cooperativas Ativas (Exceto Cecred)
    CURSOR cr_cooperativa IS
      SELECT cdcooper     
      FROM   crapcop  cop  
      WHERE  flgativo  = 1 --Cooperativas Ativas
      AND    cdcooper <> 3 --Exceto CECRED                    
      ORDER BY cdcooper;
    
    --Busca o hor�rio de execu��o do debitar
    CURSOR cr_horario_debitador(pr_idhora_processamento IN tbgen_debitador_horario_proc.idhora_processamento%TYPE) IS
      SELECT tdh.idhora_processamento  idhora_processamento
            ,tdh.dhprocessamento       dhprocessamento
      FROM   cecred.tbgen_debitador_horario  tdh  
      WHERE  idhora_processamento = pr_idhora_processamento            
      ORDER BY tdh.dhprocessamento;           
  
    -- Busca os JOB's do Debitador �nico conforme Id do Hor�rio
    CURSOR cr_job_debitador(pr_idhora_processamento IN tbgen_debitador_horario_proc.idhora_processamento%TYPE) IS
      SELECT job.owner
            ,job.job_name
            ,job.next_run_date
      FROM   dba_scheduler_jobs job
      WHERE  job.owner = 'CECRED' --Fixo
      AND   (job.job_name LIKE 'JBDEB_UNICO_HORA'||Lpad(pr_idhora_processamento,2,'0')||'%'
        OR   job.job_name LIKE 'JBDEB_UNI_'||Lpad(pr_idhora_processamento,2,'0')||'%' )
      ORDER BY job.job_name; 
      
    -- Vari�veis de controle de calend�rio
    rw_crapdat         btch0001.cr_crapdat%ROWTYPE;       
  
    -- Vari�veis de controle
    vr_cdcooper        crapcop.cdcooper%TYPE := 3; --Fixo
    vr_dthrexe         VARCHAR2(21);
    vr_nm_job          VARCHAR2(100); 
    vr_ds_bloco_plsql  VARCHAR2(30000);  
    vr_cdprogra        tbgen_debitador_param.cdprocesso%TYPE := 'PC_JOB_DEBITADOR_UNICO';    
    vr_email_dest      VARCHAR2(1000); 
    vr_conteudo        VARCHAR2(4000);     
  
  BEGIN 
    
    -- Verifica��o do calend�rio
    OPEN btch0001.cr_crapdat(pr_cdcooper => vr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
              
    IF btch0001.cr_crapdat%NOTFOUND THEN     
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1; --Sistema sem data de movimento.
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_email;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;
    
    -- Log de inicio de execucao programa raiz   
    pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra
                        ,pr_indexecu => 'Inicio Execucao'
                        ,pr_cdcooper => vr_cdcooper 
                        ,pr_tpexecuc => NULL
                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                        ,pr_idtiplog => 'I');                            
    
    -- Excluir JOB do Debitador �nico
    IF pr_idtipo_operacao = 'E' THEN
      
      -- Log de ocorr�ncia
      pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra
                          ,pr_indexecu => 'Excluindo JOB do Debitador Unico...'
                          ,pr_cdcooper => vr_cdcooper
                          ,pr_tpexecuc => NULL
                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                          ,pr_idtiplog => 'O');
      
      FOR r_job_debitador IN cr_job_debitador(pr_idhora_processamento => pr_idhora_processamento) LOOP    
        dbms_scheduler.drop_job(job_name => r_job_debitador.owner||'.'||r_job_debitador.job_name);
        -- Gera Log de Job
        gene0001.pc_gera_log_job(pr_cdcooper => vr_cdcooper
                                ,pr_des_log  => '*******************************************************************************************************'||chr(13)||
                                                'Coop: '||vr_cdcooper||' --> Progr: '||r_job_debitador.job_name||' Em: '||to_char(sysdate,'dd/mm/yyyy hh24:mi:ss')||chr(13)||
                                                'JobNM: '||r_job_debitador.owner||'.'||r_job_debitador.job_name||' - Agendado para: '||to_char(r_job_debitador.next_run_date,'dd/mm/yyyy hh24:mi:ss')||chr(13)||
                                                'Descricao: Job dropado devido a recriacao dos horarios do Debitador Unico (tbgen_debitador_horario).');                                               
                                                
        -- Log de ocorr�ncia
        pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra
                            ,pr_indexecu => 'JOB '||r_job_debitador.job_name||' excluido.'
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_tpexecuc => NULL
                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt 
                            ,pr_idtiplog => 'O');                                                
      END LOOP;
    
    --Incluir JOB do Debitador �nico  
    ELSIF pr_idtipo_operacao = 'I' THEN
      
      -- Log de ocorr�ncia
      pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra
                          ,pr_indexecu => 'Buscando Horario do Debitador Unico...'
                          ,pr_cdcooper => vr_cdcooper
                          ,pr_tpexecuc => NULL
                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                          ,pr_idtiplog => 'O');   
    
      -- Para cada hor�rio do Debitador �nico 
      FOR r_horario_debitador IN cr_horario_debitador(pr_idhora_processamento => pr_idhora_processamento) LOOP
        
        -- Log de ocorr�ncia
        pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra
                            ,pr_indexecu => 'Buscando Cooperativas...'
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_tpexecuc => NULL
                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                            ,pr_idtiplog => 'O');
          
        -- Para cada Cooperativa Ativa (Exceto Cecred)
        FOR r_cooperativa IN cr_cooperativa LOOP                                      
             
          -- Monta nome do Job    
          vr_nm_job := 'JBDEB_UNICO_HORA'||Lpad(r_horario_debitador.idhora_processamento,2,'0')||'_COOP'||Lpad(r_cooperativa.cdcooper,2,'0');
          
          -- Monta A��o (PL/SQL) do Job
          vr_ds_bloco_plsql := 'BEGIN'||CHR(13)||
                               '  gen_debitador_unico.pc_executa_debitador_unico(pr_cdcooper              => '||r_cooperativa.cdcooper||CHR(13)||
                               '                                                ,pr_idhora_processamento  => '||r_horario_debitador.idhora_processamento||CHR(13)||
                               '                                                ,pr_ds_cdprocesso         => '||'NULL'||CHR(13)||
                               '                                                ,pr_nrprioridade_prg_erro => '||'NULL'||');'||CHR(13)||
                               'END;';
          
          --Se a hora inclusa for menor que a hora atual                     
          IF To_Date(To_Char(r_horario_debitador.dhprocessamento,'dd/mm/rrrr hh24:mi'),'dd/mm/rrrr hh24:mi') < To_Date(To_Char(SYSDATE,'dd/mm/rrrr hh24:mi'),'dd/mm/rrrr hh24:mi') THEN
            -- O JOB ser� criado com disparo somente no pr�ximo dia
            vr_dthrexe := To_Char(r_horario_debitador.dhprocessamento + 1,'dd/mm/rrrr hh24:mi:ss');                                            
          --Se a hora inclusa for maior ou igual a hora atual   
          ELSE
            -- O JOB ser� criado com disparo no dia atual
            vr_dthrexe := To_Char(r_horario_debitador.dhprocessamento,'dd/mm/rrrr hh24:mi:ss');  
          END IF;
          
          -- Log de ocorr�ncia
          pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra
                              ,pr_indexecu => 'Criando JOB do Debitador Unico: '||vr_nm_job||'...'
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_tpexecuc => NULL
                              ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                              ,pr_idtiplog => 'O');
          
          --Cria o JOB para Cada Hor�rio do Debitador �nico e para cada Cooperativa
          gene0001.pc_submit_job(pr_cdcooper  => r_cooperativa.cdcooper
                                ,pr_cdprogra  => vr_nm_job
                                ,pr_dsplsql   => vr_ds_bloco_plsql
                                ,pr_dthrexe   => To_TimeStamp(vr_dthrexe,'dd/mm/rrrr hh24:mi:ss')
                                ,pr_interva   => 'SYSDATE+1'
                                ,pr_jobname   => vr_nm_job          
                                ,pr_des_erro  => vr_dscritic); 
                                                                                                           
          -- Tratamento de erro 
          IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
            vr_dscritic := 'Falha na criacao do JOB do Debitador Unico. (Cooperativa:'||r_cooperativa.cdcooper||' Job: '||vr_nm_job||'). Erro: '||vr_dscritic;
            RAISE vr_exc_email;              
          END IF;     
          
          -- Log de ocorr�ncia
          pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra
                              ,pr_indexecu => 'JOB '||vr_nm_job||' criado.'
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_tpexecuc => NULL
                              ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                              ,pr_idtiplog => 'O');             
                
        END LOOP; --Fim Loop Cooperativas                             
                
      END LOOP; --Fim Loop Hor�rios do Debitador  
      
    END IF; -- Incluir /Excluir JOB  
    
    -- Log de inicio de execucao programa   
    pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra
                        ,pr_indexecu => 'Fim Execucao'
                        ,pr_cdcooper => vr_cdcooper 
                        ,pr_tpexecuc => NULL
                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                        ,pr_idtiplog => 'F');
                        
  EXCEPTION  
    WHEN vr_exc_email THEN
      -- Efetuar rollback
      ROLLBACK;
        
      /* Se aconteceu erro, gera o log e envia o erro por e-mail */
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper,
                                 pr_ind_tipo_log => 2, --> erro tratado
                                 pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||' - '||vr_cdprogra ||' --> ' || vr_dscritic,
                                 pr_dstiplog     => 'E',
                                 pr_cdprograma   => vr_cdprogra,
                                 pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
        
      -- buscar destinatarios do email                           
      vr_email_dest := gene0001.fn_param_sistema('CRED',vr_cdcooper,'ERRO_EMAIL_JOB');
                    
      -- Gravar conteudo do email, controle com substr para n�o estourar campo texto
      vr_conteudo := substr('ERRO NA CRIACAO JOB DO DEBITADOR:'|| vr_nm_job          ||
                            '<br>Cooperativa: '     || to_char(vr_cdcooper, '990')||                      
                            '<br>Critica: '         || vr_dscritic,1,4000);
                        
      vr_dscritic := NULL;
      
      --/* Envia e-mail para o Operador */
      gene0003.pc_solicita_email(pr_cdcooper        => vr_cdcooper
                                ,pr_cdprogra        => vr_cdprogra
                                ,pr_des_destino     => vr_email_dest
                                ,pr_des_assunto     => 'ERRO NA CRIACAO JOB DO DEBITADOR:'|| vr_cdprogra 
                                ,pr_des_corpo       => vr_conteudo
                                ,pr_des_anexo       => NULL
                                ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'N' --> Se o envio ser� do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic);
      COMMIT;                              
    WHEN OTHERS THEN
      vr_dscritic := SQLERRM;      
    
      -- Efetuar rollback
      ROLLBACK;
        
      /* Se aconteceu erro, gera o log e envia o erro por e-mail */
      btch0001.pc_gera_log_batch(pr_cdcooper     => vr_cdcooper,
                                 pr_ind_tipo_log => 2, --> erro tratado
                                 pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||' - '||vr_cdprogra ||' --> ' || vr_dscritic,
                                 pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
        
      -- buscar destinatarios do email                           
      vr_email_dest := gene0001.fn_param_sistema('CRED',vr_cdcooper,'ERRO_EMAIL_JOB');
        
      -- Gravar conteudo do email, controle com substr para n�o estourar campo texto
      vr_conteudo := substr('ERRO NA CRIACAO JOB DO DEBITADOR:'|| vr_nm_job          ||
                            '<br>Cooperativa: '     || to_char(vr_cdcooper, '990')||                      
                            '<br>Critica: '         || vr_dscritic,1,4000);
                        
      cecred.pc_internal_exception(vr_cdcooper, vr_conteudo);
                        
      vr_dscritic := NULL;
      
      --/* Envia e-mail para o Operador */
      gene0003.pc_solicita_email(pr_cdcooper        => vr_cdcooper
                                ,pr_cdprogra        => vr_cdprogra
                                ,pr_des_destino     => vr_email_dest
                                ,pr_des_assunto     => 'ERRO NA CRIACAO JOB DO DEBITADOR:'|| vr_nm_job 
                                ,pr_des_corpo       => vr_conteudo
                                ,pr_des_anexo       => NULL
                                ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'N' --> Se o envio ser� do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic);
      COMMIT;                     
  END pc_job_debitador_unico;

       
  /* Executar Debitador �nico */
  PROCEDURE pc_executa_debitador_unico(pr_cdcooper              IN crapcop.cdcooper%TYPE
                                      ,pr_idhora_processamento  IN tbgen_debitador_horario_proc.idhora_processamento%TYPE
                                      ,pr_ds_cdprocesso         IN VARCHAR2
                                      ,pr_nrprioridade_prg_erro IN tbgen_debitador_param.nrprioridade%TYPE) IS
                                      
    /*
    | ------------------------------------------------------------------------------------------------------------------------ | ---------------- | -------------- | ----------- | 
    | Programa                                                                                                                 | Debita Sem Saldo | Debita Parcial | Repescagem  | 
    | ------------------------------------------------------------------------------------------------------------------------ | ---------------- | -------------- | ----------- | 
    | OK - PC_CRPS509_PRIORI - DEBNET - EFETUAR DEBITO DE AGENDAMENTOS DE CONVENIOS PRIORITARIOS DA CECRED FEITOS NA INTERNET  | N�o              | N�o            | N�o         | 
    | OK - PC_CRPS509 - DEBNET - EFETUAR DEBITO DE AGENDAMENTOS DE CONVENIOS DA CECRED FEITOS NA INTERNET                      | N�o              | N�o            | N�o         |
    | OK - PC_CRPS642_PRIORI - DEBSIC - EFETUAR DEBITO DE AGENDAMENTOS DE CONVENIOS PRIORITARIOS DA SICREDI FEITOS NA INTERNET | N�o              | N�o            | N�o         |
    | OK - PC_CRPS642 - DEBSIC - EFETUAR DEBITO DE AGENDAMENTOS DE CONVENIOS DA SICREDI FEITOS NA INTERNET                     | N�o              | N�o            | N�o         |
    | OK - PC_CRPS750 - PAGAMENTOS DAS PARCELAS DE EMPR�STIMOS (TR E PP)                                                       | N�o              | Sim            | N�o         |
    | OK - TARI0001.PC_DEB_TARIFA_PEND - COBRANCA DE TARIFAS PENDENTES                                                         | N�o              | Sim            | N�o         |
    | OK - PC_CRPS172 - DEBITO EM CONTA DAS PRESTACOES DE PLANO DE CAPITAL                                                     | N�o              | N�o            | N�o         |
    | OK - PC_CRPS145 - DEBITO EM CONTA REF POUPANCA PROGRAMADA                                                                | N�o              | N�o            | N�o         |
    | OK - PC_CRPS439 - DEBITO DIARIO DO SEGURO                                                                                | Sim              | N�o            | N�o         |
    | OK - PC_CRPS654 - TENTATIVA DIARIA DEBITO DE COTAS                                                                       | N�o              | Sim            | N�o         |
    | OK - PC_CRPS674 - DEBITO DE FATURA - LANCAMENTO DE DEBITO AUTOMATICO - BANCOOB/CABAL                                     | N�o              | Sim            | 1 = Repique |
    | OK - PC_CRPS688 - EFETUAR RESGATE DE APLICA��ES AGENDADAS PELO INTERNET BANK                                             | N�o              | N�o            | N�o         |    
    | OK - RCEL0001.PC_PROCES_AGENDAMENTOS_RECARGA - EFETIVAR OS AGENDAMENTOS DE RECARGA DE CELULAR                            | N�o              | N�o            | N�o         |    
    | OK - EMPR0009.PC_EFETIVA_LCTO_PENDENTE_JOB - EFETIVAR LANCAMENTO PENDENTE MULTA/JUROS TR CONTRATOS EMP/FINANC POS-FIXADA | N�o              | N�o            | N�o         |    
    | OK - PC_CRPS123 - EFETUAR OS LANCAMENTOS AUTOMATICOS NO SISTEMA REF. A DEBITO EM CONTA                                   | Sim              | N�o            | N�o         |    
    | OK - PC_CRPS724 - PAGAR AS PARCELAS DOS CONTRATOS DO PRODUTO POS-FIXADO                                                  | N�o              | Sim            | N�o         |    
    | OK - PC_CRPS663 - DEBCNS - EFETUAR DEBITOS DE CONSORCIOS PENDENTES                                                       | N�o              | N�o            | N�o         |
    | OK - PC_CRPS268 - DEBITO EM CONTA REFERENTE SEGURO DE VIDA EM GRUPO                                                      | Sim              | N�o            | N�o         |
    | OK - PAGA0003.PC_PROCESSA_AGEND_BANCOOB - DEBITO AGENDADOS DE PAGAMENTO BONCOOB                                          | N�o              | N�o            | N�o         |
    | ------------------------------------------------------------------------------------------------------------------------ | ---------------- | -------------- | ----------- |     
    */                                      
          
    --Busca s processos/programas do debitador por ordem de prioridade
    CURSOR cr_processo_horario(pr_idhora_processamento  IN cecred.tbgen_debitador_horario_proc.idhora_processamento%TYPE
                              ,pr_ds_cdprocesso         IN VARCHAR2
                              ,pr_nrprioridade_prg_erro IN tbgen_debitador_param.nrprioridade%TYPE) IS                                  
      --Execu��o via Job do Debitador �nico
      SELECT Upper(tdp.cdprocesso)  cdprocesso  
            ,tdp.nrprioridade       nrprioridade 
            ,tdh.dhprocessamento    dhprocessamento             
      FROM   tbgen_debitador_param         tdp
            ,tbgen_debitador_horario_proc  tdhp  
            ,tbgen_debitador_horario       tdh      
      WHERE  tdp.cdprocesso            = tdhp.cdprocesso
      AND    tdhp.idhora_processamento = tdh.idhora_processamento
      AND    tdh.idhora_processamento  = pr_idhora_processamento
      AND    pr_idhora_processamento IS NOT NULL --Quando Chamado por Job do Debitador �nico
      AND    tdp.nrprioridade        IS NOT NULL --Com Prioridade informada no Debitador �nico
      UNION ALL
      --Execu��o Emergencial de Programas Espec�ficos
      SELECT Upper(tdp.cdprocesso)  cdprocesso  
            ,tdp.nrprioridade       nrprioridade   
            ,SYSDATE                dhprocessamento            
      FROM   tbgen_debitador_param  tdp     
      WHERE  InStr(pr_ds_cdprocesso,tdp.cdprocesso||',') > 0
      AND    EXISTS (SELECT 1 
                     FROM   tbgen_debitador_horario_proc  tdhp 
                     WHERE  tdhp.cdprocesso = tdp.cdprocesso) --Programas que est�o associados a algum hor�rio do Debitador �nico
      AND    pr_ds_cdprocesso IS NOT NULL --Quando Chamado por Execu��o Emergencial de Programas Espec�ficos
      AND    tdp.nrprioridade IS NOT NULL --Com Prioridade informada no Debitador �nico
      UNION ALL
      --Execu��o Emergencial de Apartir do Programa que gerou Erro
      SELECT Upper(tdp.cdprocesso)  cdprocesso  
            ,tdp.nrprioridade       nrprioridade   
            ,SYSDATE                dhprocessamento            
      FROM   tbgen_debitador_param  tdp     
      WHERE  tdp.nrprioridade >= pr_nrprioridade_prg_erro 
      AND    EXISTS (SELECT 1 
                     FROM   tbgen_debitador_horario_proc  tdhp 
                     WHERE  tdhp.cdprocesso = tdp.cdprocesso) --Programas que est�o associados a algum hor�rio do Debitador �nico
      AND    pr_nrprioridade_prg_erro IS NOT NULL --Quando Chamado por Execu��o Emergencial apartir do programa que gerou erro no Debitador �nico
      AND    tdp.nrprioridade         IS NOT NULL --Com Prioridade informada no Debitador �nico
      ORDER BY nrprioridade;            
    
    -- Vari�veis de controle de calend�rio
    rw_crapdat                  btch0001.cr_crapdat%ROWTYPE; 
    
    -- Vari�veis de controle    
    vr_cdprogra_raiz            tbgen_debitador_param.cdprocesso%TYPE := 'PC_EXECUTA_DEBITADOR_UNICO';
    vr_cdprogra                 tbgen_debitador_param.cdprocesso%TYPE := 'PC_EXECUTA_DEBITADOR_UNICO';
    vr_minutos                  NUMBER;
    vr_nm_job                   VARCHAR2(100); 
    vr_ds_bloco_plsql           VARCHAR2(30000);
    vr_dtvalida                 DATE;                              
    vr_dtdiahoje                DATE;
    vr_stprogra                 PLS_INTEGER;--N�o utilizada
    vr_infimsol                 PLS_INTEGER;--N�o utilizada     
    vr_email_dest               VARCHAR2(1000); 
    vr_conteudo                 VARCHAR2(4000);
    vr_dh_erro                  DATE;
    vr_cd_prg_erro              tbgen_debitador_param.cdprocesso%TYPE;
    vr_nrprioridade             tbgen_debitador_param.nrprioridade%TYPE;
    vr_tpexec_emergencial       VARCHAR2(1);
    vr_inexecutou_integra_abbc  VARCHAR2(1) := 'N'; 
    vr_job_name_running         dba_scheduler_jobs.job_name%TYPE;
    vr_start_date               VARCHAR2(18);
         
  BEGIN 
    --
    -- Verifica��o do calend�rio
    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
              
    IF btch0001.cr_crapdat%NOTFOUND THEN     
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1; --Sistema sem data de movimento.
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_email;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;    
    
    -- Log de inicio de execucao programa raiz   
    pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                        ,pr_indexecu => 'Inicio Execucao'
                        ,pr_cdcooper => pr_cdcooper 
                        ,pr_tpexecuc => NULL
                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                        ,pr_idtiplog => 'I');                                                                                                                                                                                          
     
    --Se for Execu��o Emergencial (Chamada pela tela de Par�metros do Debitador)
    IF pr_nrprioridade_prg_erro IS NOT NULL OR pr_ds_cdprocesso IS NOT NULL THEN          
      -- Monta Tipo de Execu��o Emergencail
      IF pr_nrprioridade_prg_erro IS NOT NULL THEN
        vr_tpexec_emergencial := 'E'; --E=Apartir da prioridade do programa que ocasionou erro no debitador
      ELSIF pr_ds_cdprocesso IS NOT NULL THEN
        vr_tpexec_emergencial := 'P'; --P=Programa(s) Espec�ficos  
      END IF;
      
      -- Decrementa Qtde no Controle de Execu��o do Programa
      pc_atualiza_ctrl_exec_prg (pr_cdcooper              => pr_cdcooper
                                ,pr_ds_cdprocesso         => pr_ds_cdprocesso
                                ,pr_nrprioridade_prg_erro => pr_nrprioridade_prg_erro
                                ,pr_ds_erro               => vr_dscritic);
      -- Tratamento Erro
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN        
        RAISE vr_exc_email;              
      END IF;                                
            
      -- Log de ocorr�ncia
      pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                          ,pr_indexecu => 'Validando informacoes para Execucao Emergencial...'
                          ,pr_cdcooper => pr_cdcooper
                          ,pr_tpexecuc => NULL
                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                          ,pr_idtiplog => 'O');  
                        
      -- Valida��es para Execu��o Emergencial
      pc_valida_exec_emergencial(pr_cdcooper           => pr_cdcooper
                                ,pr_tpexec_emergencial => vr_tpexec_emergencial 
                                ,pr_dh_erro            => vr_dh_erro
                                ,pr_cd_prg_erro        => vr_cd_prg_erro
                                ,pr_nrprioridade       => vr_nrprioridade
                                ,pr_cd_erro            => vr_cdcritic          
                                ,pr_ds_erro            => vr_dscritic);                                                            
      -- Tratamento Erro
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN        
        RAISE vr_exc_email;              
      END IF;                                                
    END IF; 
    
    -- Log de ocorr�ncia
    pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                        ,pr_indexecu => 'Verificando Dia Util...'
                        ,pr_cdcooper => pr_cdcooper
                        ,pr_tpexecuc => NULL
                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                        ,pr_idtiplog => 'O');      
    
    -- Verifica dia �til
    vr_dtdiahoje := Trunc(SYSDATE);
    vr_dtvalida  := gene0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper
                                               ,pr_dtmvtolt  => vr_dtdiahoje
                                               ,pr_tipo      => 'A'
                                               ,pr_feriado   => TRUE
                                               ,pr_excultdia => TRUE);
    
    -- Se for Dia �til e n�o for o �ltimo dia do ano
    -- Somente Segunda, Ter�a, Quarta, Quinta e Sexta-Feira, exceto feriados e exceto �ltimo dia do ano
    IF vr_dtvalida = vr_dtdiahoje THEN  
      
      -- Log de ocorr�ncia
      pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                          ,pr_indexecu => 'Verificando se ha algum JOB do Debitador rodando para a Cooperativa...'
                          ,pr_cdcooper => pr_cdcooper
                          ,pr_tpexecuc => NULL
                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                          ,pr_idtiplog => 'O');                                                                                           
       
      -- Verificar se h� algun JOB do Debitador rodando para a Cooperativa
      pc_verifica_job_running(pr_cdcooper             => pr_cdcooper
                             ,pr_idhora_processamento => pr_idhora_processamento
                             ,pr_job_name_running     => vr_job_name_running
                             ,pr_start_date           => vr_start_date
                             ,pr_ds_erro              => vr_dscritic);
      -- Tratamento Erro
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN        
        RAISE vr_exc_email;              
      END IF;  
      
      -- Se a h� algun JOB do Debitador rodando para a Cooperativa (Running)
      IF vr_job_name_running IS NOT NULL THEN 
        vr_dscritic := 'Debitador Abortado em '||To_Char(SYSDATE,'dd/mm/rrrr hh24:mi')||' devido a existir um JOB ainda executando o Debitador: '||vr_job_name_running||' com Start em '||vr_start_date||'. (Cooperativa: '||pr_cdcooper||')';
        RAISE vr_exc_email;
      END IF; 
      
      -- Log de ocorr�ncia
      pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                          ,pr_indexecu => 'Verificando se ja executou a integracao ABBC...'
                          ,pr_cdcooper => pr_cdcooper
                          ,pr_tpexecuc => NULL
                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                          ,pr_idtiplog => 'O');                           
      
      -- Verifica se a j� executou a integra��o ABBC   
      pc_valida_integracao_abbc(pr_cdcooper                => pr_cdcooper         --Coopertativa
                               ,pr_tpexecucao              => 1                   --Batch 
                               ,pr_cdprograma              => 'CRPS538'           --Processo ABBC
                               ,pr_dhinicio                => rw_crapdat.dtmvtolt --Data Inicial
                               ,pr_dhfim                   => rw_crapdat.dtmvtolt --Data Final
                               ,pr_flgsucesso              => 1                   --Indicador de sucesso da execu��o
                               ,pr_inexecutou_integra_abbc => vr_inexecutou_integra_abbc                              
                               ,pr_dscritic                => vr_dscritic); 
      -- Tratamento Erro
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN        
        RAISE vr_exc_email;              
      END IF;         
      
      -- Se a Integra��o ABBC ainda n�o foi processada
      IF Nvl(vr_inexecutou_integra_abbc,'N') = 'N' THEN 
        vr_dscritic := 'Debitador Abortado. CRPS538 - Integra��o ABBC ainda n�o foi processada em '||To_Char(rw_crapdat.dtmvtolt,'dd/mm/rrrr')||'. (Cooperativa: '||pr_cdcooper||').';
        RAISE vr_exc_email;
      END IF;                                   
      
      -- Log de ocorr�ncia
      pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                          ,pr_indexecu => 'Verificando se a Cooperativa ainda esta executando o Processo Batch (Noturno)...'
                          ,pr_cdcooper => pr_cdcooper
                          ,pr_tpexecuc => NULL
                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                          ,pr_idtiplog => 'O'); 
                
      -- Se a Cooperativa ainda estiver executando o Processo Batch (Noturna)
      IF rw_crapdat.inproces > 1 THEN    
        
        -- Log de ocorr�ncia
        pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                            ,pr_indexecu => 'Buscando Qtde de Minutos para Reagendamento de JOB do Debitador Unico...'
                            ,pr_cdcooper => pr_cdcooper
                            ,pr_tpexecuc => NULL
                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                            ,pr_idtiplog => 'O');              
        
        -- Buscar quantidade em minutos para reagendar a JOB
        vr_minutos := gene0001.fn_param_sistema(pr_nmsistem => 'CRED' 
                                               ,pr_cdcooper => 0 
                                               ,pr_cdacesso => 'QTD_MIN_REAGEN_DEBITADOR'); 
        -- Se n�o encontrou o par�metro
        IF Nvl(vr_minutos,0) = 0 THEN
          -- Montar mensagem de critica
           vr_cdcritic := 10200; --Parametro de qtde em minutos para reagendar JOBs do Debitador Unico nao encontrado.
           vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
           RAISE vr_exc_email;
        END IF;                                                
          
        -- Monta nome do JOB com no m�ximo 18 caractecres devido a limita��o do Oracle para casos de Jobs sem intervalo                
        vr_nm_job := 'JBDEB_UNI_'||Lpad(Nvl(pr_idhora_processamento,99),2,'0')||'_'||Lpad(pr_cdcooper,2,'0')||'_R_'; 
        
        -- Monta Bloco PL/SQL (A��o do Job) 
        vr_ds_bloco_plsql := 'BEGIN'||CHR(13)||
                             '  gen_debitador_unico.pc_executa_debitador_unico(pr_cdcooper              => '||pr_cdcooper||CHR(13)||
                             '                                                ,pr_idhora_processamento  => '||pr_idhora_processamento||CHR(13)||
                             '                                                ,pr_ds_cdprocesso         => '||Nvl(pr_ds_cdprocesso,'NULL')||CHR(13)||
                             '                                                ,pr_nrprioridade_prg_erro => '||Nvl(To_Char(pr_nrprioridade_prg_erro),'NULL')||');'||CHR(13)||
                             'END;';                                                 
                             
        -- Log de ocorr�ncia
        pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                            ,pr_indexecu => 'Reagendando JOB '||vr_nm_job||', pois ainda esta executando o Processo Batch (Noturno)...'
                            ,pr_cdcooper => pr_cdcooper
                            ,pr_tpexecuc => NULL
                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                            ,pr_idtiplog => 'O');                             
          
        --Reagendar JOB para minutos posteriores (Conforme qtde de minutos recuperado no par�metro QTD_MIN_REAGEN_DEBITADOR)
        gene0001.pc_submit_job(pr_cdcooper  => pr_cdcooper
                              ,pr_cdprogra  => vr_nm_job
                              ,pr_dsplsql   => vr_ds_bloco_plsql 
                              ,pr_dthrexe   => To_TimeStamp(To_Char(SYSDATE + (vr_minutos/60/24),'dd/mm/rrrr hh24:mi:ss'),'dd/mm/rrrr hh24:mi:ss')                                                        
                              ,pr_interva   => NULL
                              ,pr_jobname   => vr_nm_job          
                              ,pr_des_erro  => vr_dscritic);
                                                                         
        -- Tratamento Erro
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          vr_dscritic := 'Falha no reagendamento do JOB do Debitador Unico. (Cooperativa:'||pr_cdcooper||' Job: '||vr_nm_job||'). Erro: '||vr_dscritic;
          RAISE vr_exc_email;              
        END IF;
        
        -- Log de ocorr�ncia
        pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                            ,pr_indexecu => 'JOB '||vr_nm_job||' reagendado para '||To_Char(SYSDATE + (vr_minutos/60/24),'DD/MM/RRRR HH24:MI')||'.'
                            ,pr_cdcooper => pr_cdcooper
                            ,pr_tpexecuc => NULL
                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                            ,pr_idtiplog => 'O');                                
            
      -- Se a Cooperativa N�O estiver executando o Processo Batch (Noturna) 
      ELSE  
        
        -- Log de ocorr�ncia
        pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                            ,pr_indexecu => 'Buscando Programas para Execucao do Debitador...'
                            ,pr_cdcooper => pr_cdcooper
                            ,pr_tpexecuc => NULL
                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                            ,pr_idtiplog => 'O'); 
                                     
        -- Para cada Processo/Programa
        FOR r_processo_horario IN cr_processo_horario(pr_idhora_processamento  => pr_idhora_processamento
                                                     ,pr_ds_cdprocesso         => pr_ds_cdprocesso
                                                     ,pr_nrprioridade_prg_erro => pr_nrprioridade_prg_erro) LOOP
                             
          --PC_CRPS750 - PAGAMENTOS DAS PARCELAS DE EMPR�STIMOS (TR E PP)            
          IF Upper(r_processo_horario.cdprocesso) = 'PC_CRPS750' THEN  
            vr_cdprogra := 'PC_CRPS750';   
            
            -- Log de ocorr�ncia
            pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                                ,pr_indexecu => 'Executando Programa '||vr_cdprogra||'...'
                                ,pr_cdcooper => pr_cdcooper
                                ,pr_tpexecuc => NULL
                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                ,pr_idtiplog => 'O');             
            --  
            -- Log de inicio de execucao
            pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra
                                ,pr_indexecu => 'Inicio Execucao'
                                ,pr_cdcooper => pr_cdcooper 
                                ,pr_tpexecuc => NULL
                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                ,pr_idtiplog => 'I');     
             
            -- Executa processo/programa
            pc_crps750(pr_cdcooper => pr_cdcooper   --IN crapcop.cdcooper%TYPE  --> Codigo Cooperativa
                      ,pr_cdagenci => 0             --IN crapage.cdagenci%TYPE  --> Codigo Agencia
                      ,pr_nmdatela => 'crps750'     --IN VARCHAR2               --> Nome Tela (Coforme Chamado no JOB Antigo = crps750
                      ,pr_idparale => 1             --IN crappar.idparale%TYPE  --> Indicador de processoparalelo
                      ,pr_stprogra => vr_stprogra   --OUT PLS_INTEGER           --> Saida de termino da execucao
                      ,pr_infimsol => vr_infimsol   --OUT PLS_INTEGER           --> Saida de termino da solicitacao
                      ,pr_cdcritic => vr_cdcritic   --OUT crapcri.cdcritic%TYPE --> Codigo da Critica
                      ,pr_dscritic => vr_dscritic); --OUT VARCHAR2              --> Descricao da Critica                     
            
            -- Tratamento de erro                                 
            IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN 
              --
              -- Atualiza Par�metro de qual programa/cooperativa ocasionou erro no Debitador �nico.
              pc_atualiz_erro_prg_debitador(pr_nmsistem => 'CRED'
                                           ,pr_cdcooper => pr_cdcooper
                                           ,pr_cdacesso => 'CTRL_ERRO_PRG_DEBITADOR'
                                           ,pr_dsvlrprm => To_Char(SYSDATE,'dd/mm/rrrr')||' '||To_Char(r_processo_horario.dhprocessamento,'hh24:mi')||'#'||vr_cdprogra);
              -- Log de erro de execucao 
              pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra
                                  ,pr_indexecu => 'Fim Execucao com Critica: '||vr_dscritic
                                  ,pr_cdcooper => pr_cdcooper
                                  ,pr_tpexecuc => NULL
                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                  ,pr_idtiplog => 'E');
              RAISE vr_exc_email;
            END IF;  
            --
            -- Log de fim de execucao
            pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra
                                ,pr_indexecu => 'Fim Execucao'
                                ,pr_cdcooper => pr_cdcooper 
                                ,pr_tpexecuc => NULL
                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                ,pr_idtiplog => 'F');
                                
            -- Log de ocorr�ncia
            pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                                ,pr_indexecu => 'Programa '||vr_cdprogra||' Executado.'
                                ,pr_cdcooper => pr_cdcooper
                                ,pr_tpexecuc => NULL
                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                ,pr_idtiplog => 'O');                                
            
            --
          --TARI0001.PC_DEB_TARIFA_PEND - COBRANCA DE TARIFAS PENDENTES          
          ELSIF Upper(r_processo_horario.cdprocesso) = 'TARI0001.PC_DEB_TARIFA_PEND' THEN     
            vr_cdprogra := 'TARI0001.PC_DEB_TARIFA_PEND';  
            
            -- Log de ocorr�ncia
            pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                                ,pr_indexecu => 'Executando Programa '||vr_cdprogra||'...'
                                ,pr_cdcooper => pr_cdcooper
                                ,pr_tpexecuc => NULL
                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                ,pr_idtiplog => 'O');              
            --  
            -- Log de inicio de execucao
            pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra
                                ,pr_indexecu => 'Inicio Execucao'
                                ,pr_cdcooper => pr_cdcooper 
                                ,pr_tpexecuc => NULL
                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                ,pr_idtiplog => 'I');                                     
             
            -- Executa processo/programa   
            tari0001.pc_deb_tarifa_pend(pr_cdcooper => pr_cdcooper   --IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                       ,pr_dtinicio => NULL          --IN DATE                    --> data de inicio para verifica��o das tarifas
                                       ,pr_dtafinal => NULL          --IN DATE                    --> data final para verifica��o das tarifas
                                       ,pr_cdcritic => vr_cdcritic   --OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                       ,pr_dscritic => vr_dscritic); --OUT VARCHAR2               --> Texto de erro/critica encontrada                                                   
            
            -- Tratamento de erro                                 
            IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN 
              --
              -- Atualiza Par�metro de qual programa/cooperativa ocasionou erro no Debitador �nico.
              pc_atualiz_erro_prg_debitador(pr_nmsistem => 'CRED'
                                           ,pr_cdcooper => pr_cdcooper
                                           ,pr_cdacesso => 'CTRL_ERRO_PRG_DEBITADOR'
                                           ,pr_dsvlrprm => To_Char(SYSDATE,'dd/mm/rrrr')||' '||To_Char(r_processo_horario.dhprocessamento,'hh24:mi')||'#'||vr_cdprogra);
              -- Log de erro de execucao 
              pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra
                                  ,pr_indexecu => 'Fim Execucao com Critica: '||vr_dscritic
                                  ,pr_cdcooper => pr_cdcooper
                                  ,pr_tpexecuc => NULL
                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                  ,pr_idtiplog => 'E');
              RAISE vr_exc_email;
            END IF;  
            --
            -- Log de fim de execucao
            pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra
                                ,pr_indexecu => 'Fim Execucao'
                                ,pr_cdcooper => pr_cdcooper 
                                ,pr_tpexecuc => NULL
                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                ,pr_idtiplog => 'F');
                                
            -- Log de ocorr�ncia
            pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                                ,pr_indexecu => 'Programa '||vr_cdprogra||' Executado.'
                                ,pr_cdcooper => pr_cdcooper
                                ,pr_tpexecuc => NULL
                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                ,pr_idtiplog => 'O');                                                                                    
            --
          --PC_CRPS724 - PAGAR AS PARCELAS DOS CONTRATOS DO PRODUTO POS-FIXADO          
          ELSIF Upper(r_processo_horario.cdprocesso) = 'PC_CRPS724' THEN   
            vr_cdprogra := 'PC_CRPS724';  
            
            -- Log de ocorr�ncia
            pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                                ,pr_indexecu => 'Executando Programa '||vr_cdprogra||'...'
                                ,pr_cdcooper => pr_cdcooper
                                ,pr_tpexecuc => NULL
                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                ,pr_idtiplog => 'O');               
            --  
            -- Log de inicio de execucao
            pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra
                                ,pr_indexecu => 'Inicio Execucao'
                                ,pr_cdcooper => pr_cdcooper 
                                ,pr_tpexecuc => NULL
                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                ,pr_idtiplog => 'I');     
             
            -- Executa processo/programa
            pc_crps724(pr_cdcooper => pr_cdcooper   --IN crapcop.cdcooper%TYPE  --> Codigo Cooperativa
                      ,pr_stprogra => vr_stprogra   --OUT PLS_INTEGER           --> Saida de termino da execucao
                      ,pr_infimsol => vr_infimsol   --OUT PLS_INTEGER           --> Saida de termino da solicitacao
                      ,pr_cdcritic => vr_cdcritic   --OUT crapcri.cdcritic%TYPE --> Codigo da Critica
                      ,pr_dscritic => vr_dscritic); --OUT crapcri.dscritic%TYPE --> Descricao da Critica                                                         
            
            -- Tratamento de erro                                 
            IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN 
              --
              -- Atualiza Par�metro de qual programa/cooperativa ocasionou erro no Debitador �nico.
              pc_atualiz_erro_prg_debitador(pr_nmsistem => 'CRED'
                                           ,pr_cdcooper => pr_cdcooper
                                           ,pr_cdacesso => 'CTRL_ERRO_PRG_DEBITADOR'
                                           ,pr_dsvlrprm => To_Char(SYSDATE,'dd/mm/rrrr')||' '||To_Char(r_processo_horario.dhprocessamento,'hh24:mi')||'#'||vr_cdprogra);
              -- Log de erro de execucao 
              pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra
                                  ,pr_indexecu => 'Fim Execucao com Critica: '||vr_dscritic
                                  ,pr_cdcooper => pr_cdcooper
                                  ,pr_tpexecuc => NULL
                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                  ,pr_idtiplog => 'E');
              RAISE vr_exc_email;
            END IF;  
            --
            -- Log de fim de execucao
            pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra
                                ,pr_indexecu => 'Fim Execucao'
                                ,pr_cdcooper => pr_cdcooper 
                                ,pr_tpexecuc => NULL
                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                ,pr_idtiplog => 'F');
                                
            -- Log de ocorr�ncia
            pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                                ,pr_indexecu => 'Programa '||vr_cdprogra||' Executado.'
                                ,pr_cdcooper => pr_cdcooper
                                ,pr_tpexecuc => NULL
                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                ,pr_idtiplog => 'O');                                
            --                       
          END IF;                                                                   
                                          
        END LOOP; --Fim Loop Processo/Programa do respectivo hor�rio do debitador
        
        --Limpar Controle de Erro do Debitador        
        BEGIN  
          UPDATE crapprm 
          SET    dsvlrprm = '01/01/1900 00:00#XXXXXXX' --Limpa Data/Programa Erro
          WHERE  nmsistem = 'CRED'
          AND    cdcooper = pr_cdcooper
          AND    cdacesso = 'CTRL_ERRO_PRG_DEBITADOR'
          AND    SubStr(dsvlrprm,1,10) = To_Char(SYSDATE,'dd/mm/rrrr'); --Se erro for do dia atual    
        EXCEPTION
          WHEN OTHERS THEN
            vr_dscritic := 'Erro ao atualizar Controle de Erro do Debitador (Cooperativa:'||pr_cdcooper||'). Erro: '||SubStr(SQLERRM,1,255);
            RAISE vr_exc_email; 
        END;    
        --
        -- Log de ocorr�ncia
        pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                            ,pr_indexecu => 'Salvando Execucao.'
                            ,pr_cdcooper => pr_cdcooper
                            ,pr_tpexecuc => NULL
                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                            ,pr_idtiplog => 'O');
                                
        COMMIT;
        --                             
      END IF; --Processamento Batch (Noturna)
    
    -- Se for N�o Dia �til  
    ELSE  
      -- Log de ocorr�ncia
      pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                          ,pr_indexecu => 'Debitador n�o executado pois n�o � dia util. Data: '||To_Char(vr_dtdiahoje,'dd/mm/rrrr')||'.'
                          ,pr_cdcooper => pr_cdcooper
                          ,pr_tpexecuc => NULL
                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                          ,pr_idtiplog => 'O');
    END IF; --Dia �til    
    
    -- Log de inicio de execucao programa raiz  
    pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                        ,pr_indexecu => 'Fim Execucao'
                        ,pr_cdcooper => pr_cdcooper 
                        ,pr_tpexecuc => NULL
                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                        ,pr_idtiplog => 'F');
                         
  EXCEPTION  
    WHEN vr_exc_email THEN      
      -- Efetuar rollback
      ROLLBACK; 
        
      /* Se aconteceu erro, gera o log e envia o erro por e-mail */
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, --> erro tratado
                                 pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||' - '||vr_cdprogra ||' --> ' || vr_dscritic,
                                 pr_dstiplog     => 'E',
                                 pr_cdprograma   => 'PC_EXECUTA_DEBITADOR_UNICO',
                                 pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
                                 
      -- buscar destinatarios do email                           
      vr_email_dest := gene0001.fn_param_sistema('CRED',pr_cdcooper,'ERRO_EMAIL_JOB');
                    
      -- Gravar conteudo do email, controle com substr para n�o estourar campo texto
      vr_conteudo := substr('ERRO NA EXECUCAO DO DEBITADOR:'|| vr_cdprogra          ||
                            '<br>Cooperativa: '    || to_char(pr_cdcooper, '990')||                      
                            '<br>Critica: '        || vr_dscritic,1,4000);
                        
      vr_dscritic := NULL;
      
      --/* Envia e-mail para o Operador */
      gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                ,pr_cdprogra        => 'PC_EXECUTA_DEBITADOR_UNICO'
                                ,pr_des_destino     => vr_email_dest
                                ,pr_des_assunto     => 'ERRO NA EXECUCAO DO DEBITADOR:'|| vr_cdprogra 
                                ,pr_des_corpo       => vr_conteudo
                                ,pr_des_anexo       => NULL
                                ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'N' --> Se o envio ser� do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic);
      COMMIT;                              
    WHEN OTHERS THEN      
      vr_dscritic := SQLERRM;      
        
      -- Efetuar rollback
      ROLLBACK;
        
      /* Se aconteceu erro, gera o log e envia o erro por e-mail */
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, --> erro tratado
                                 pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||' - PC_EXECUTA_DEBITADOR_UNICO: '||vr_cdprogra ||' --> ' || vr_dscritic,
                                 pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
        
      -- buscar destinatarios do email                           
      vr_email_dest := gene0001.fn_param_sistema('CRED',pr_cdcooper,'ERRO_EMAIL_JOB');
        
      -- Gravar conteudo do email, controle com substr para n�o estourar campo texto
      vr_conteudo := substr('ERRO NA EXECUCAO DO DEBITADOR:'|| vr_cdprogra          ||
                            '<br>Cooperativa: '     || to_char(pr_cdcooper, '990')||                      
                            '<br>Critica: '         || vr_dscritic,1,4000);
                        
      cecred.pc_internal_exception(pr_cdcooper, vr_conteudo);
                        
      vr_dscritic := NULL;
      
      --/* Envia e-mail para o Operador */
      gene0003.pc_solicita_email(pr_cdcooper        => pr_cdcooper
                                ,pr_cdprogra        => 'PC_EXECUTA_DEBITADOR_UNICO'
                                ,pr_des_destino     => vr_email_dest
                                ,pr_des_assunto     => 'ERRO NA EXECUCAO DO DEBITADOR:'|| vr_cdprogra 
                                ,pr_des_corpo       => vr_conteudo
                                ,pr_des_anexo       => NULL
                                ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'N' --> Se o envio ser� do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic);
      COMMIT;                       
  END pc_executa_debitador_unico;


END gen_debitador_unico;
/
