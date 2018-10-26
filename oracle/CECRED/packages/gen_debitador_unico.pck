CREATE OR REPLACE PACKAGE CECRED.gen_debitador_unico AS

  -----------------------------------------------------------------------------------------------
  --
  --  Programa  : GEN_DEBITADOR_UNICO
  --  Sistema   : Pacote de Rotinas genéricas focando nas funcionalidades do Debitador Único
  --  Autor     : Marcelo Elias Gonçalves - AMcom Sistemas de Informação
  --  Data      : Maio/2018                               Última atualização:
  --  Frequência: Conforme chamada
  --  Objetivo  : Empacotar as rotinas referente ao Debitador Único
  --
  --  Alterações:
  --   
  --  26/10/2018 1) pc_job_debitador_unico: alterada frequencia do job (repeat_interval).
  --             2) pc_verifica_job_running: adicionado espaco antes do percent (dava erro: procurava por 1 e encontrava 16).
  --
  -----------------------------------------------------------------------------------------------

  -- Variáveis de críticas
  vr_cdcritic       crapcri.cdcritic%TYPE;
  vr_dscritic       crapcri.dscritic%TYPE;

  -- Variável de exceção/erro
  vr_exc_email      EXCEPTION;

  /* Gera LOG de execução dos programas */
  PROCEDURE pc_gera_log_execucao(pr_nmprgexe IN VARCHAR2
                                ,pr_indexecu IN VARCHAR2
                                ,pr_cdcooper IN INTEGER
                                ,pr_tpexecuc IN VARCHAR2
                                ,pr_idtiplog IN VARCHAR2 -- I = Inicio, O = Ocorrencia, E = Erro ou F = Fim
                                ,pr_dtmvtolt IN DATE);

  /* Atualiza Parâmetro de qual programa/cooperativa ocasionou erro no Debitador Único */
  PROCEDURE pc_atualiz_erro_prg_debitador(pr_nmsistem IN crapprm.nmsistem%TYPE
                                         ,pr_cdcooper IN crapprm.cdcooper%TYPE
                                         ,pr_cdacesso IN crapprm.cdacesso%TYPE
                                         ,pr_dsvlrprm IN crapprm.dsvlrprm%TYPE);

  /* Verifica se executou a integração ABBC do dia anterior */
  PROCEDURE pc_valida_integracao_abbc(pr_cdcooper                 IN tbgen_prglog.cdcooper%TYPE
                                     ,pr_tpexecucao               IN tbgen_prglog.tpexecucao%TYPE
                                     ,pr_cdprograma               IN tbgen_prglog.cdprograma%TYPE
                                     ,pr_dtprglog                 IN DATE
                                     ,pr_flgsucesso               IN tbgen_prglog.flgsucesso%TYPE
                                     ,pr_inexecutou_integra_abbc OUT VARCHAR2
                                     ,pr_dscritic                OUT crapcri.dscritic%TYPE);

  /* Valida Horário do Processo */
  PROCEDURE pc_valida_hora_processo(pr_dhprocessamento IN tbgen_debitador_horario.dhprocessamento%TYPE
                                   ,pr_cdprocesso      IN tbgen_debitador_horario_proc.cdprocesso%TYPE
                                   ,pr_ininterromper  OUT BOOLEAN
                                   ,pr_ds_erro        OUT crapcri.dscritic%TYPE);

  /* Valida Exclusão do Horário do Processo */
  PROCEDURE pc_valida_exclus_hora_processo(pr_idhora_processamento IN tbgen_debitador_horario.idhora_processamento%TYPE
                                          ,pr_dhprocessamento IN tbgen_debitador_horario.dhprocessamento%TYPE
                                          ,pr_cdprocesso      IN tbgen_debitador_horario_proc.cdprocesso%TYPE
                                          ,pr_ininterromper  OUT BOOLEAN
                                          ,pr_ds_erro        OUT crapcri.dscritic%TYPE);

  /* Valida se o programa pode ser chamado na execução emergencial de Programas Específicos */
  PROCEDURE pc_valida_exec_emergencial_prg (pr_cdcooper     IN crapcop.cdcooper%TYPE
                                           ,pr_cdprocesso   IN VARCHAR2
                                           ,pr_ds_erro     OUT crapcri.dscritic%TYPE);

  /* Valida dados para Execução Emergencial */
  PROCEDURE pc_valida_exec_emergencial(pr_cdcooper           IN crapcop.cdcooper%TYPE
                                      ,pr_tpexec_emergencial IN VARCHAR2 --P=Programa(s) Específicos ou E=Apartir da prioridade do programa que ocasionou erro no debitador
                                      ,pr_dh_erro            OUT DATE
                                      ,pr_cd_prg_erro        OUT tbgen_debitador_param.cdprocesso%TYPE
                                      ,pr_nrprioridade       OUT tbgen_debitador_param.nrprioridade%TYPE
                                      ,pr_cd_erro            OUT crapcri.cdcritic%TYPE
                                      ,pr_ds_erro            OUT crapcri.dscritic%TYPE);

  /* Decrementa quantidade no controle de execuções do programa */
  PROCEDURE pc_atualiza_ctrl_exec_prg (pr_cdcooper              IN crapcop.cdcooper%TYPE
                                      ,pr_ds_cdprocesso         IN VARCHAR2
                                      ,pr_nrprioridade_prg_erro IN tbgen_debitador_param.nrprioridade%TYPE
                                      ,pr_ds_erro              OUT crapcri.dscritic%TYPE);

  /* Verifica quantidade de execuções do programa durante o dia no Debitador Único */
  PROCEDURE pc_qt_hora_prg_debitador(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                    ,pr_cdprocesso IN tbgen_debitador_param.cdprocesso%TYPE
                                    ,pr_ds_erro   OUT crapcri.dscritic%TYPE);

  /* Verificar se há algun JOB do Debitador rodando para a Cooperativa */
  PROCEDURE pc_verifica_job_running(pr_cdcooper             IN crapcop.cdcooper%TYPE
                                   ,pr_idhora_processamento IN tbgen_debitador_horario_proc.idhora_processamento%TYPE
                                   ,pr_job_name_running    OUT dba_scheduler_jobs.job_name%TYPE
                                   ,pr_start_date          OUT VARCHAR2
                                   ,pr_ds_erro             OUT crapcri.dscritic%TYPE);

  /* Dropa e Recria JOB's do Debitador Único conforme parametrização tela (tbgen_debitador_param) */
  PROCEDURE pc_job_debitador_unico(pr_idhora_processamento IN tbgen_debitador_horario_proc.idhora_processamento%TYPE
                                  ,pr_idtipo_operacao      IN VARCHAR2); --I=Incluir ou E=Excluir

  /* Executar Debitador Único */
  PROCEDURE pc_executa_debitador_unico(pr_cdcooper              IN crapcop.cdcooper%TYPE
                                      ,pr_idhora_processamento  IN tbgen_debitador_horario_proc.idhora_processamento%TYPE
                                      ,pr_ds_cdprocesso         IN VARCHAR2
                                      ,pr_nrprioridade_prg_erro IN tbgen_debitador_param.nrprioridade%TYPE);

  PROCEDURE pc_verifica_ctrl_ult_execucao(pr_cdcooper         IN crapcop.cdcooper%TYPE
                                         ,pr_cdprocesso       IN tbgen_debitador_horario_proc.cdprocesso%TYPE
                                         ,pr_flultexe        OUT INTEGER                      --> Retorna se é a ultima execução do procedimento
                                         ,pr_qtdexec         OUT INTEGER                      --> Retorna a quantidade
                                         ,pr_qtdexectot      OUT INTEGER                      --> Retorna a quantidade total do programa
                                         ,pr_temhorproxdia   OUT BOOLEAN                      --> Retorna se existe algum horario para o próximo dia
                                         ,pr_dataagenproxdia OUT DATE                         --> Retorna a data que foi agendado o próximo horario
                                         ,pr_cdcritic        OUT crapcri.cdcritic%TYPE        --> Codigo da critica de erro
                                         ,pr_dscritic        OUT VARCHAR2);

  PROCEDURE pc_atlz_hora_proces_prox_dia(pr_dhprocessamento IN tbgen_debitador_horario.dhprocessamento%TYPE
                                        ,pr_cdprocesso      IN tbgen_debitador_horario_proc.cdprocesso%TYPE
                                        ,pr_ds_erro        OUT crapcri.dscritic%TYPE);

  PROCEDURE pc_controle_exec_deb ( pr_cdcooper         IN crapcop.cdcooper%TYPE        --> Código da coopertiva
                                  ,pr_cdtipope         IN VARCHAR2                     --> Tipo de operacao I-incrementar, C-Consultar e V-Validar
                                  ,pr_dtmvtolt         IN DATE                         --> Data do movimento
                                  ,pr_cdprogra         IN crapprg.cdprogra%TYPE        --> Codigo do programa
                                  ,pr_flultexe        OUT INTEGER                      --> Retorna se é a ultima execução do procedimento
                                  ,pr_qtdexec         OUT INTEGER                      --> Retorna a quantidade
                                  ,pr_qtdexectot      OUT INTEGER                      --> Retorna a quantidade total
                                  ,pr_temhorproxdia   OUT BOOLEAN                      --> Retorna se existe algum horario para o próximo dia
                                  ,pr_dataagenproxdia OUT DATE                         --> Retonar data se existe agendamento para o dia posterior
                                  ,pr_cdcritic        OUT crapcri.cdcritic%TYPE        --> Codigo da critica de erro
                                  ,pr_dscritic        OUT VARCHAR2);

END gen_debitador_unico;
/
CREATE OR REPLACE PACKAGE BODY CECRED.gen_debitador_unico AS

  -----------------------------------------------------------------------------------------------
  --
  --  Programa  : GEN_DEBITADOR_UNICO
  --  Sistema   : Pacote de Rotinas genéricas focando nas funcionalidades do Debitador Único
  --  Autor     : Marcelo Elias Gonçalves - AMcom Sistemas de Informação
  --  Data      : Maio/2018                               Última atualização:
  --  Frequência: Conforme chamada
  --  Objetivo  : Empacotar as rotinas referente ao Debitador Único
  --
  --  Alterações:
  --   
  --  26/10/2018 1) pc_job_debitador_unico: alterada frequencia do job (repeat_interval).
  --             2) pc_verifica_job_running: adicionado espaco antes do percent (dava erro: procurava por 1 e encontrava 16).
  --
  -----------------------------------------------------------------------------------------------


  /* Gera LOG de execução dos programas */
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
      --> Definir descrição do log
      vr_desdolog := 'Automatizado - '||to_char(SYSDATE,'HH24:MI:SS')||' --> Coop.:'|| pr_cdcooper ||' '|| pr_tpexecuc ||' - '||SubStr(pr_nmprgexe,4)|| ': '|| pr_indexecu;

      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 1,
                                 pr_des_log      => vr_desdolog,
                                 pr_nmarqlog     => vr_nmarqlog,
                                 pr_cdprograma   => SubStr(pr_nmprgexe,4));
    END IF;
    
    --Provisório (Revisão dos LOgs) 07/08/2018
    vr_nmarqlog := 'proc_message.log';

    -- Logs Programas Gerais
    -- Incluir log no proc_batch.log
    IF pr_idtiplog = 'I' THEN --> Inicio
      -- inicializar o tempo
      vr_tempo := to_char(SYSDATE,'SSSSS');
      vr_desdolog := to_char(SYSDATE,'HH24:MI:SS')||' - '|| pr_nmprgexe ||' --> Inicio da execucao.';
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 1,
                                 pr_des_log      => vr_desdolog,
                                 pr_nmarqlog     => vr_nmarqlog, --Provisório (Revisão dos LOgs) 07/08/2018
                                 pr_dstiplog     => 'I',
                                 pr_cdprograma   => pr_nmprgexe);

    ELSIF pr_idtiplog = 'O' THEN --> Ocorrencia
      vr_desdolog := to_char(SYSDATE,'HH24:MI:SS')||' - '|| pr_nmprgexe ||' --> Ocorrencia: '||pr_indexecu;
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 1,
                                 pr_des_log      => vr_desdolog,
                                 pr_nmarqlog     => vr_nmarqlog, --Provisório (Revisão dos LOgs) 07/08/2018
                                 pr_dstiplog     => 'O',
                                 pr_cdprograma   => pr_nmprgexe);

    ELSIF pr_idtiplog = 'E' THEN --> Erro
      vr_desdolog := to_char(SYSDATE,'HH24:MI:SS')||' - '|| pr_nmprgexe ||' --> Erro: '||pr_indexecu;
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 1,
                                 pr_des_log      => vr_desdolog,
                                 pr_nmarqlog     => vr_nmarqlog, --Provisório (Revisão dos LOgs) 07/08/2018
                                 pr_dstiplog     => 'E',
                                 pr_cdprograma   => pr_nmprgexe);

    ELSIF pr_idtiplog = 'F' THEN --> Fim
      vr_desdolog := to_char(SYSDATE,'HH24:MI:SS')||' - '|| pr_nmprgexe ||' --> Stored Procedure rodou em '||to_char(to_date(to_char(SYSDATE,'SSSSS') - vr_tempo,'SSSSS'),'HH24:MI:SS');
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 1,
                                 pr_des_log      => vr_desdolog,
                                 pr_nmarqlog     => vr_nmarqlog, --Provisório (Revisão dos LOgs) 07/08/2018
                                 pr_dstiplog     => 'F',
                                 pr_cdprograma   => pr_nmprgexe);
    END IF;
    --Somente para compilar sem warnings
    if vr_tempo is null then
      null;
    end if;
  END pc_gera_log_execucao;


  /* Atualiza Parâmetro de qual programa/cooperativa ocasionou erro no Debitador Único */
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
        vr_dscritic := 'Erro ao Atualizar Parâmetro (crapprm) CTRL_ERRO_PRG_DEBITADOR - Cooperativa: '||pr_cdcooper||' . Erro: '||SubStr(SQLERRM,1,255);
        RAISE vr_exc_email;
    END;
    --
    COMMIT;
    --
  END pc_atualiz_erro_prg_debitador;


  /* Verifica se executou a integração ABBC do dia anterior */
  PROCEDURE pc_valida_integracao_abbc(pr_cdcooper                 IN tbgen_prglog.cdcooper%TYPE
                                     ,pr_tpexecucao               IN tbgen_prglog.tpexecucao%TYPE
                                     ,pr_cdprograma               IN tbgen_prglog.cdprograma%TYPE
                                     ,pr_dtprglog                 IN DATE
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
      AND    dhinicio  >= pr_dtprglog
      AND    dhfim     <  pr_dtprglog + 1
      AND    flgsucesso = pr_flgsucesso
      AND    ROWNUM     = 1;
    EXCEPTION
      WHEN No_Data_Found THEN
        pr_inexecutou_integra_abbc := 'N';
      WHEN OTHERS THEN
        pr_dscritic := 'Erro ao validar integração ABBC - Cooperativa: '||pr_cdcooper||' . Erro: '||SubStr(SQLERRM,1,255);
    END;
  END pc_valida_integracao_abbc;



  /* Valida Horário do Processo */
  PROCEDURE pc_valida_hora_processo(pr_dhprocessamento IN tbgen_debitador_horario.dhprocessamento%TYPE
                                   ,pr_cdprocesso      IN tbgen_debitador_horario_proc.cdprocesso%TYPE
                                   ,pr_ininterromper  OUT BOOLEAN
                                   ,pr_ds_erro        OUT crapcri.dscritic%TYPE) IS
    vr_erro                 EXCEPTION;
    vr_ds_erro              crapcri.dscritic%TYPE;
    --vr_dhprocessamento_max  tbgen_debitador_horario.dhprocessamento%TYPE;
    vr_flultexe             INTEGER;
    vr_qtdexec              INTEGER;
    vr_qtdexectot           INTEGER;
    vr_temhorproxdia        BOOLEAN;
    vr_dataagenproxdia      DATE;
    vr_cdcritic             crapcri.cdcritic%TYPE;
    vr_dscritic             VARCHAR2(4000);
  BEGIN

    --Busca Maior Hora de Execução do Dia para o Programa
    --Comentado pois irá utilizar a nova função para controle de última execução
    /*BEGIN
      SELECT Max(tdh.dhprocessamento)   dhprocessamento
      INTO   vr_dhprocessamento_max
      FROM   tbgen_debitador_horario_proc  tdhp
            ,tbgen_debitador_horario       tdh
      WHERE  tdhp.idhora_processamento = tdh.idhora_processamento
      AND    tdhp.cdprocesso           = pr_cdprocesso;
    EXCEPTION
      WHEN OTHERS THEN
        vr_ds_erro := 'Erro ao Buscar Maior Hora de Execução do Dia para o Programa. Programa: '||pr_cdprocesso||'.';
        RAISE vr_erro;
    END;

    --Validação se o horário pode ser agendado para o programa
    IF vr_dhprocessamento_max IS NOT NULL THEN
      IF To_Date(To_Char(vr_dhprocessamento_max,'hh24:mi'),'hh24:mi') < To_Date(To_Char(SYSDATE,'hh24:mi'),'hh24:mi')
        AND To_Date(To_Char(pr_dhprocessamento,'hh24:mi'),'hh24:mi') > To_Date(To_Char(vr_dhprocessamento_max,'hh24:mi'),'hh24:mi') THEN
          vr_ds_erro := 'O Programa não pode ser agendado para este horário pois o controle da última execução do dia já ocorreu.';
          RAISE vr_erro;
      END IF;
    END IF;*/
    
    gen_debitador_unico.pc_verifica_ctrl_ult_execucao(pr_cdcooper        => NULL
                                                     ,pr_cdprocesso      => pr_cdprocesso
                                                     ,pr_flultexe        => vr_flultexe
                                                     ,pr_qtdexec         => vr_qtdexec
                                                     ,pr_qtdexectot      => vr_qtdexectot
                                                     ,pr_temhorproxdia   => vr_temhorproxdia
                                                     ,pr_dataagenproxdia => vr_dataagenproxdia
                                                     ,pr_cdcritic        => vr_cdcritic
                                                     ,pr_dscritic        => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      vr_ds_erro      := vr_dscritic;
      pr_ininterromper := TRUE;
      RAISE vr_erro;
    END IF;

    

    -- VErificar se já foi a última execução
    -- Neste caso já vai considerar o parâmetro de execução da cadeia.
    -- Executa a inserção do horario, porém informa com a mensagem abaixo para o usuário
    IF vr_flultexe = 1 THEN
      vr_ds_erro := 'O Programa será agendado para este horário a partir do próximo dia pois o controle da última execução do dia já ocorreu.';
      pr_ininterromper := FALSE;
      RAISE vr_erro;
    END IF;
    
    -- VErificar se já foi a última execução
    -- Neste caso já vai considerar o parâmetro de execução da cadeia.
    -- Executa a inserção do horario, porém informa com a mensagem abaixo para o usuário
    IF NVL(vr_flultexe,0) = 0 AND 
       To_Date(To_Char(pr_dhprocessamento,'hh24:mi'),'hh24:mi') < To_Date(To_Char(SYSDATE,'hh24:mi'),'hh24:mi') THEN
      vr_ds_erro := 'O Programa será agendado para este horário a partir do próximo dia pois é anterior a hora atual.';
      pr_ininterromper := FALSE;
      RAISE vr_erro;
    END IF;    
    --
    pr_ininterromper := FALSE;
    --
  EXCEPTION
    WHEN vr_erro THEN
      pr_ds_erro := vr_ds_erro;
    WHEN OTHERS THEN
      pr_ds_erro := 'Erro ao validar horário para o processo. Erro: '||SubStr(SQLERRM,1,255);
      pr_ininterromper := TRUE;
  END pc_valida_hora_processo;


  /* Valida Exclusão do Horário do Processo */
  PROCEDURE pc_valida_exclus_hora_processo(pr_idhora_processamento IN tbgen_debitador_horario.idhora_processamento%TYPE
                                          ,pr_dhprocessamento IN tbgen_debitador_horario.dhprocessamento%TYPE
                                          ,pr_cdprocesso      IN tbgen_debitador_horario_proc.cdprocesso%TYPE
                                          ,pr_ininterromper  OUT BOOLEAN
                                          ,pr_ds_erro        OUT crapcri.dscritic%TYPE) IS

    -- Alterações na rotina para executar na cadeia noturna além do debitador
    CURSOR cr_tbgen_param_debit_unico IS
      SELECT tdp.inexec_cadeia_noturna,
             tdp.incontrole_exec_prog
        FROM tbgen_debitador_param  tdp
       WHERE EXISTS (SELECT 1
                       FROM tbgen_debitador_horario_proc  tdhp
                      WHERE tdhp.cdprocesso = tdp.cdprocesso) --Programa deve estar associado a algum horário do Debitador Único
         AND nrprioridade IS NOT NULL --Programa deve ter prioridade informada
         AND upper(tdp.cdprocesso) = upper(pr_cdprocesso);
    rw_tbgen_param_debit_unico cr_tbgen_param_debit_unico%ROWTYPE;

   CURSOR cr_id_proces IS
      select 1  ww_id_proces
      from crapdat a, crapcop b
      where a.inproces > 1
      and a.cdcooper = b.cdcooper
      and b.flgativo =1
      ;
    rw_id_proces cr_id_proces%ROWTYPE;

    vr_erro                 EXCEPTION;
    vr_erro_nao_interrompe  EXCEPTION;
    vr_ds_erro              crapcri.dscritic%TYPE;
    vr_flultexe             INTEGER;
    vr_qtdexec              INTEGER;
    vr_qtdexectot           INTEGER;
    vr_qtdexectot_tela      INTEGER;
    vr_temhorproxdia        BOOLEAN;
    vr_dataagenproxdia      DATE;
    vr_cdcritic             crapcri.cdcritic%TYPE;
    vr_dscritic             VARCHAR2(4000);
    vr_qtpendentes          INTEGER := 0;
    vr_id_proces            NUMBER(1);
  BEGIN

      --> buscar se para alguma cooperativa, está executando a cadeia
      BEGIN
        select 1  --- 
        into vr_id_proces
        from crapdat a, crapcop b
        where a.inproces > 1
        and a.cdcooper = b.cdcooper
        and b.flgativo =1
        and rownum =1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          vr_id_proces := 0;
        WHEN OTHERS THEN
          vr_ds_erro := 'Erro ao verificar id proces coop. '||sqlerrm;
          RAISE vr_erro;
      END;
    -- Buscar parâmetro de execução na cadeia noturna além do debitador único.
    -- Valida Programa do cadastro do Debitador
    OPEN cr_tbgen_param_debit_unico;
    FETCH cr_tbgen_param_debit_unico INTO rw_tbgen_param_debit_unico;
    IF cr_tbgen_param_debit_unico%NOTFOUND THEN
      CLOSE cr_tbgen_param_debit_unico;
      vr_ds_erro := 'Erro ao buscar parâmetro de indicador de execução do programa do debitador na cadeia noturna para realizar a exclusão. Parâmetro não encontrado.';
      RAISE vr_erro;
    ELSE
      CLOSE cr_tbgen_param_debit_unico;
    END IF;

    -- Verifica se tem controle de execução
    IF rw_tbgen_param_debit_unico.incontrole_exec_prog IN (2,3) THEN
      --> Buscar dados dos parâmetros
      gen_debitador_unico.pc_verifica_ctrl_ult_execucao(pr_cdcooper        => NULL
                                                       ,pr_cdprocesso      => pr_cdprocesso
                                                       ,pr_flultexe        => vr_flultexe
                                                       ,pr_qtdexec         => vr_qtdexec
                                                       ,pr_qtdexectot      => vr_qtdexectot
                                                       ,pr_temhorproxdia   => vr_temhorproxdia
                                                       ,pr_dataagenproxdia => vr_dataagenproxdia
                                                       ,pr_cdcritic        => vr_cdcritic
                                                       ,pr_dscritic        => vr_dscritic);
      IF vr_dscritic IS NOT NULL THEN
        vr_ds_erro := vr_dscritic;
        RAISE vr_erro;
      END IF;

      --> Buscar a quantidade de horarios que tem na tela
      BEGIN
        SELECT COUNT(*)-- - 1 -- Subtrair o que está excluindo
          INTO vr_qtdexectot_tela
          FROM tbgen_debitador_horario_proc  tdhp
              ,tbgen_debitador_horario       tdh
         WHERE tdhp.idhora_processamento = tdh.idhora_processamento
           AND upper(tdhp.cdprocesso)    = upper(pr_cdprocesso);
      EXCEPTION
        WHEN OTHERS THEN
          vr_ds_erro := 'Erro ao buscar quantidade total de execuções existentes na tela do debitador para o programa '||upper(pr_cdprocesso);
          RAISE vr_erro;
      END;

      IF NVL(rw_tbgen_param_debit_unico.inexec_cadeia_noturna,'N') = 'N' THEN
        -- Verifica se já excluiu algum na tela e a rotina ainda não atualizou o parâmetro
        -- Utilizaremos a quantidade de horarios da tela para validar.
        -- Pode ter excluído ou incluído e ainda não executou a rotina
        IF vr_qtdexectot_tela <> vr_qtdexectot THEN
          vr_qtdexectot := vr_qtdexectot_tela;
        END IF;

        -- Só irá validar se não executou a última vez ainda.
        IF vr_flultexe = 0 THEN
          -- Neste caso já vai considerar o parâmetro de execução da cadeia.
          -- Se possui controle de execução e falta executar a última vez do dia, irá bloquear

          -- Quantidade de horarios no debitador que são após a esta ação
          -- Tem que existir pelo menos um superior a data atual
          -- para que ele atue como ultima execução
          FOR rec_pendentes IN (SELECT tbdebhor.idhora_processamento,
                                       tbdebhor.dhprocessamento
                                  FROM tbgen_debitador_horario_proc tbdebhor_proc,
                                       tbgen_debitador_horario tbdebhor
                                 WHERE tbdebhor_proc.idhora_processamento = tbdebhor.idhora_processamento
                                   AND tbdebhor_proc.cdprocesso = upper(pr_cdprocesso)
                                   AND To_Date(To_Char(tbdebhor.dhprocessamento,'hh24:mi'),'hh24:mi') > To_Date(To_Char(SYSDATE + 15/1440,'hh24:mi'),'hh24:mi')) LOOP
            vr_qtpendentes := vr_qtpendentes + 1;

            IF rec_pendentes.idhora_processamento = pr_idhora_processamento THEN
              vr_qtpendentes := vr_qtpendentes - 1;
            END IF;
          END LOOP;

          -- Tem que ficar pelo menos um horario no debitador para que ele trabalhe como a última execução
          IF /*(vr_qtdexectot - vr_qtdexec) = 1 AND*/ nvl(vr_qtpendentes,0) < 1 
              or (To_Date(To_Char(pr_dhprocessamento,'hh24:mi'),'hh24:mi') <= To_Date(To_Char(SYSDATE,'hh24:mi'),'hh24:mi'))  THEN
            vr_ds_erro := 'Exclusão de horário '||To_Char(pr_dhprocessamento,'hh24:mi')||' não permitida pois o controle de execução já está na última execução ou o horário já executou, exclusão permitida apenas para horários não executados.';
            RAISE vr_erro;
          END IF;

        END IF;
      ELSE -- somente para programas que tem também execução na cadeia
        IF To_Date(To_Char(pr_dhprocessamento,'hh24:mi'),'hh24:mi') <= To_Date(To_Char(SYSDATE,'hh24:mi'),'hh24:mi') 
          or vr_id_proces = 1 -- se cadeia executando para alguma cooperativa, não permite excluir horário
          or (to_number(To_Char(SYSDATE,'hh24')) between 0 and 1) THEN  -- entre meia noite e 1h, não permite excluir horário        
          vr_ds_erro := 'Exclusão de horário '||To_Char(pr_dhprocessamento,'hh24:mi')||' não permitida pois o controle de execução já está na última execução ou o horário já executou, exclusão permitida apenas para horários não executados.';
          RAISE vr_erro;          
      END IF;
    END IF;
    END IF;
    --
    pr_ininterromper := FALSE;
    --
  EXCEPTION
    WHEN vr_erro THEN
      pr_ininterromper := TRUE;
      pr_ds_erro := vr_ds_erro;
    WHEN vr_erro_nao_interrompe THEN
      pr_ininterromper := FALSE;
      pr_ds_erro := vr_ds_erro;
    WHEN OTHERS THEN
      pr_ds_erro := 'Erro ao validar horário para o processo. Erro: '||SubStr(SQLERRM,1,255);
  END pc_valida_exclus_hora_processo;

  /* Valida se o programa pode ser chamado na execução emergencial de Programas Específicos */
  PROCEDURE pc_valida_exec_emergencial_prg (pr_cdcooper   IN crapcop.cdcooper%TYPE
                                           ,pr_cdprocesso IN VARCHAR2
                                           ,pr_ds_erro   OUT crapcri.dscritic%TYPE) IS
    --Varável de Exceção
    vr_erro                 EXCEPTION;
    vr_ds_erro              crapcri.dscritic%TYPE;
    vr_cdacesso             VARCHAR2(100);
    --vr_prg_tem_ctrl         VARCHAR2(1) := 'N';
    --vr_dhprocessamento_max  tbgen_debitador_horario.dhprocessamento%TYPE;
    vr_flultexe             INTEGER;
    vr_qtdexec              INTEGER;
    vr_qtdexectot           INTEGER;
    vr_temhorproxdia        BOOLEAN;
    vr_dataagenproxdia      DATE;
    vr_cdcritic             crapcri.cdcritic%TYPE;
    vr_dscritic             VARCHAR2(4000);
  BEGIN
    --Comentado pois irá utilizar a nova função para controle de última execução
    --Monta acesso ao Parametro na (crapprm)
    /*IF Upper(pr_cdprocesso) = 'PC_CRPS642' THEN
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
        vr_ds_erro := 'Erro ao Verificar se o Programa tem Controle de Excução. Programa: '||pr_cdprocesso||'.';
        RAISE vr_erro;
    END;

    IF Nvl(vr_prg_tem_ctrl,'N') = 'S' THEN

      --Busca Menor/Maior Hora de Execução do Dia para o Programa
      BEGIN
        SELECT Max(tdh.dhprocessamento)  dhprocessamento_max
        INTO   vr_dhprocessamento_max
        FROM   tbgen_debitador_horario_proc  tdhp
              ,tbgen_debitador_horario       tdh
        WHERE  tdhp.idhora_processamento = tdh.idhora_processamento
        AND    tdhp.cdprocesso           = pr_cdprocesso;
      EXCEPTION
        WHEN OTHERS THEN
          vr_ds_erro := 'Erro ao Buscar Maior Hora de Execução do Dia para o Programa. Programa: '||pr_cdprocesso||'.';
          RAISE vr_erro;
      END;

      --Se programa já rodou última execução do dia
      IF To_Date(To_Char(SYSDATE,'hh24:mi'),'hh24:mi') >= To_Date(To_Char(vr_dhprocessamento_max,'hh24:mi'),'hh24:mi') THEN
        vr_ds_erro := 'Não é possível selecionar o programa, pois o mesmo já teve a sua última execução do dia.';
        RAISE vr_erro;
      END IF;
    END IF; */

    gen_debitador_unico.pc_verifica_ctrl_ult_execucao(pr_cdcooper        => NULL
                                                     ,pr_cdprocesso      => pr_cdprocesso
                                                     ,pr_flultexe        => vr_flultexe
                                                     ,pr_qtdexec         => vr_qtdexec
                                                     ,pr_qtdexectot      => vr_qtdexectot
                                                     ,pr_temhorproxdia   => vr_temhorproxdia
                                                     ,pr_dataagenproxdia => vr_dataagenproxdia
                                                     ,pr_cdcritic        => vr_cdcritic
                                                     ,pr_dscritic        => vr_dscritic);
    IF vr_dscritic IS NOT NULL THEN
      vr_ds_erro := vr_dscritic;
      RAISE vr_erro;
    END IF;

    -- VErificar se já foi a última execução
    -- Neste caso já vai considerar o parâmetro de execução da cadeia.
    -- a inserção do horario para o processo
    IF vr_flultexe = 1 THEN
      vr_ds_erro := 'Não é possível selecionar o programa, pois o mesmo já teve a sua última execução do dia.';
      RAISE vr_erro;
    END IF;

  EXCEPTION
    WHEN vr_erro THEN
      pr_ds_erro := vr_ds_erro;
    WHEN OTHERS THEN
      pr_ds_erro := 'Erro ao validar Execução Emergencial. Erro: '||SubStr(SQLERRM,1,255);
  END pc_valida_exec_emergencial_prg;


  /* Valida dados para Execução Emergencial */
  PROCEDURE pc_valida_exec_emergencial(pr_cdcooper           IN crapcop.cdcooper%TYPE
                                      ,pr_tpexec_emergencial IN VARCHAR2 --P=Programa(s) Específicos ou E=Apartir da prioridade do programa que ocasionou erro no debitador
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

    -- Verificação do calendário
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

    -- Verifica dia útil
    vr_dtdiahoje := Trunc(SYSDATE);
    vr_dtvalida  := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                               ,pr_dtmvtolt => vr_dtdiahoje
                                               ,pr_tipo     => 'A' --Não considera útil o último dia do ano
                                               ,pr_feriado  => TRUE);
    -- Valida Dia Útil
    IF vr_dtvalida <> vr_dtdiahoje THEN
      -- Montar mensagem de critica
      vr_ds_erro := 'A Execução Emergencial é permitida somente em dias úteis: '||To_Char(vr_dtdiahoje,'dd/mm/rrrr')||'.';
      RAISE vr_erro;
    END IF;

    -- Verificar se há algun JOB do Debitador rodando para a Cooperativa
    pc_verifica_job_running(pr_cdcooper             => pr_cdcooper
                           ,pr_idhora_processamento => NULL
                           ,pr_job_name_running     => vr_job_name_running
                           ,pr_start_date           => vr_start_date
                           ,pr_ds_erro              => vr_ds_erro);
    -- Tratamento Erro
    IF vr_ds_erro IS NOT NULL THEN
      RAISE vr_erro;
    END IF;

    -- Se a há algun JOB do Debitador rodando para a Cooperativa (Running)
    IF vr_job_name_running IS NOT NULL THEN
      vr_ds_erro := 'Execução Emergencial não permitida. Há um JOB ainda executando o Debitador: '||vr_job_name_running||' com Start em '||vr_start_date||'. (Cooperativa: '||pr_cdcooper||')';
      RAISE vr_erro;
    END IF;

    -- Verifica se executou a integração ABBC do dia anterior
    pc_valida_integracao_abbc(pr_cdcooper                => pr_cdcooper           --Coopertativa
                             ,pr_tpexecucao              => 1                     --Batch
                             ,pr_cdprograma              => 'CRPS538'             --Processo ABBC
                             ,pr_dtprglog                => rw_crapdat.dtmvtoan+1 --Data Anterior da Cooperativa + 1 (O log do integração é gerado na madrugada do dia seguinte da data atual da cooperativa. Ex: Integração referente ao dia 19/06/2018, no log da integração a data do log será de 20/06/2018)
                             ,pr_flgsucesso              => 1                     --Indicador de sucesso da execução
                             ,pr_inexecutou_integra_abbc => vr_inexecutou_integra_abbc
                             ,pr_dscritic                => vr_ds_erro);
    -- Tratamento Erro
    IF vr_ds_erro IS NOT NULL THEN
      RAISE vr_erro;
    END IF;
    -- Se a Integração ABBC ainda não foi processada
    IF Nvl(vr_inexecutou_integra_abbc,'N') = 'N' THEN
      vr_ds_erro := 'Execução Emergencial não permitida. CRPS538 - Integração ABBC ainda não foi processada em '||To_Char(rw_crapdat.dtmvtolt,'dd/mm/rrrr')||'. (Cooperativa: '||pr_cdcooper||').';
      RAISE vr_erro;
    END IF;

    -- Se a Cooperativa ainda estiver executando o Processo Batch (Noturna)
    IF rw_crapdat.inproces > 1 THEN
      vr_ds_erro := 'Execução Emergencial não permitida. A Cooperativa '||pr_cdcooper||' ainda está executando o Processo Batch (Noturna).';
      RAISE vr_erro;
    END IF;

    -- Verifica se há erro no debitador e qual programa/cooperativa ocasionou erro no Debitador Único
    vr_ds_dh_prg_errp := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                                  ,pr_cdcooper => pr_cdcooper
                                                  ,pr_cdacesso => 'CTRL_ERRO_PRG_DEBITADOR');
    -- Se não encontrou o parâmetro
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
          vr_ds_erro := 'Erro na Execução Emergencial. Não foi possível verificar Data e/ou Programa que ocasionou o erro no Debitador Único. Cooperativa: '||pr_cdcooper||'.';
          RAISE vr_erro;
      END;
    END IF;

    IF pr_tpexec_emergencial = 'P' THEN
      --Se tem Programa que causou erro no Debitador no dia
      IF Trunc(pr_dh_erro) = Trunc(SYSDATE) THEN
        vr_ds_erro := 'A Execução Emergencial de Processos Específicos não pode ser executada pois existe Erro ocoasionado no Debitador através do processo '||pr_cd_prg_erro||'. A Execução Emergencial deve ser feita apartir da prioridade deste processo.';
          RAISE vr_erro;
      END IF;

    ELSIF pr_tpexec_emergencial = 'E' THEN
      --Data do erro deve ser a data atual do sistema
      IF Trunc(pr_dh_erro) <> Trunc(SYSDATE) THEN
        -- Montar mensagem de critica
        vr_ds_erro := 'Erro na Execução Emergencial. Não há erro ocasionado no debitador para a data atual: '||To_Char(SYSDATE,'dd/mm/rrrr')||'.';
        RAISE vr_erro;
      END IF;

      --Valida se tem programa que ocasionou erro
      IF pr_cd_prg_erro = 'XXXXXXX' THEN
        -- Montar mensagem de critica
        vr_ds_erro := 'Erro na Execução Emergencial. Não há programa que ocasionou erro no debitador.';
        RAISE vr_erro;
      END IF;

      -- Valida Programa do cadastro do Debitador
      BEGIN
        SELECT nrprioridade
        INTO   pr_nrprioridade
        FROM   tbgen_debitador_param  tdp
        WHERE  EXISTS (SELECT 1
                       FROM   tbgen_debitador_horario_proc  tdhp
                       WHERE  tdhp.cdprocesso = tdp.cdprocesso) --Programa deve estar associado a algum horário do Debitador Único
        AND    nrprioridade IS NOT NULL --Programa deve ter prioridade informada
        AND    cdprocesso = pr_cd_prg_erro;
      EXCEPTION
        WHEN No_Data_Found THEN
          -- Montar mensagem de critica
          vr_ds_erro := 'Erro na Execução Emergencial. Programa '||pr_cd_prg_erro||' que o casionou erro no Debitador não encontrado, sem prioridade ou sem horário associado.';
          RAISE vr_erro;
        WHEN OTHERS THEN
          -- Montar mensagem de critica
          vr_ds_erro := 'Erro na Execução Emergencial. Erro ao buscar prioridade do programa '||pr_cd_prg_erro||'. Erro: '||SubStr(SQLERRM,1,255);
          RAISE vr_erro;
      END;
    END IF;
  EXCEPTION
    WHEN vr_erro THEN
      pr_cd_erro := vr_cd_erro;
      pr_ds_erro := vr_ds_erro;
    WHEN OTHERS THEN
      pr_ds_erro := 'Erro ao validar Execução Emergencial. Erro: '||SubStr(SQLERRM,1,255);
  END pc_valida_exec_emergencial;


  /* Decrementa quantidade no controle de execuções do programa */
  PROCEDURE pc_atualiza_ctrl_exec_prg (pr_cdcooper              IN crapcop.cdcooper%TYPE
                                      ,pr_ds_cdprocesso         IN VARCHAR2
                                      ,pr_nrprioridade_prg_erro IN tbgen_debitador_param.nrprioridade%TYPE
                                      ,pr_ds_erro              OUT crapcri.dscritic%TYPE) IS
    --Busca processos
    CURSOR cr_processo_horario(pr_ds_cdprocesso         IN VARCHAR2
                              ,pr_nrprioridade_prg_erro IN tbgen_debitador_param.nrprioridade%TYPE) IS
      --Execução Emergencial de Programas Específicos
      SELECT Upper(tdp.cdprocesso)  cdprocesso
            ,tdp.nrprioridade       nrprioridade
            ,SYSDATE                dhprocessamento
      FROM   tbgen_debitador_param  tdp
      WHERE  InStr(pr_ds_cdprocesso,tdp.cdprocesso||',') > 0
      AND    EXISTS (SELECT 1
                     FROM   tbgen_debitador_horario_proc  tdhp
                     WHERE  tdhp.cdprocesso = tdp.cdprocesso) --Programas que estão associados a algum horário do Debitador Único
      AND    pr_ds_cdprocesso IS NOT NULL --Quando Chamado por Execução Emergencial de Programas Específicos
      AND    tdp.nrprioridade IS NOT NULL --Com Prioridade informada no Debitador Único
      UNION ALL
      --Execução Emergencial de Apartir do Programa que gerou Erro
      SELECT Upper(tdp.cdprocesso)  cdprocesso
            ,tdp.nrprioridade       nrprioridade
            ,SYSDATE                dhprocessamento
      FROM   tbgen_debitador_param  tdp
      WHERE  tdp.nrprioridade = pr_nrprioridade_prg_erro
      AND    EXISTS (SELECT 1
                     FROM   tbgen_debitador_horario_proc  tdhp
                     WHERE  tdhp.cdprocesso = tdp.cdprocesso) --Programas que estão associados a algum horário do Debitador Único
      AND    pr_nrprioridade_prg_erro IS NOT NULL --Quando Chamado por Execução Emergencial apartir do programa que gerou erro no Debitador Único
      AND    tdp.nrprioridade         IS NOT NULL --Com Prioridade informada no Debitador Único
      ORDER BY nrprioridade;

    --Varável de Exceção
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

      -- Busca a qtde do Controle de execução do programa
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
          vr_ds_erro := 'Erro ao verificar controle de execuções do programa '||r_processo_horario.cdprocesso||'. Erro: '||SubStr(SQLERRM,255);
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
            vr_ds_erro := 'Erro ao atualizar controle de execuções do programa '||r_processo_horario.cdprocesso||'. Erro: '||SubStr(SQLERRM,255);
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


  /* Verifica quantidade de execuções do programa durante o dia no Debitador Único */
  PROCEDURE pc_qt_hora_prg_debitador(pr_cdcooper   IN crapcop.cdcooper%TYPE
                                    ,pr_cdprocesso IN tbgen_debitador_param.cdprocesso%TYPE
                                    ,pr_ds_erro   OUT crapcri.dscritic%TYPE) IS

    -- Alterações na rotina para executar na cadeia noturna além do debitador
    CURSOR cr_tbgen_param_debit_unico IS
      SELECT tdp.inexec_cadeia_noturna
        FROM tbgen_debitador_param  tdp
       WHERE EXISTS (SELECT 1
                       FROM tbgen_debitador_horario_proc  tdhp
                      WHERE tdhp.cdprocesso = tdp.cdprocesso) --Programa deve estar associado a algum horário do Debitador Único
         AND nrprioridade IS NOT NULL --Programa deve ter prioridade informada
         AND upper(tdp.cdprocesso) = upper(pr_cdprocesso);
    rw_tbgen_param_debit_unico cr_tbgen_param_debit_unico%ROWTYPE;

    CURSOR cr_crapprm (pr_cdcooper crapprm.cdcooper%TYPE,
                       pr_cdacesso crapprm.cdacesso%TYPE) IS
      SELECT prm.dsvlrprm,
             prm.cdacesso,
             prm.rowid
        FROM crapprm prm
       WHERE prm.nmsistem = 'CRED'
         AND prm.cdcooper IN (pr_cdcooper,0)
         AND prm.cdacesso = pr_cdacesso
       ORDER BY prm.cdcooper DESC;
    rw_crapprm_ctrl cr_crapprm%ROWTYPE;

    --Varável de Exceção
    vr_erro                   EXCEPTION;
    vr_ds_erro                crapcri.dscritic%TYPE;

    --Variável de Controle
    vr_qt_hora_prg_debitador     NUMBER;
    vr_qt_hora_prg_debitador_dia NUMBER;
    vr_ds_hora_prg_debitador     VARCHAR2(50);
    vr_cdacesso                  VARCHAR2(100);
    vr_cdacesso_ctrl             VARCHAR2(100);

    -- buscar inproces da coop atual
    rw_crapdat                  btch0001.cr_crapdat%ROWTYPE;
    vr_tbdados   gene0002.typ_split;
    vr_dtctlexc  DATE   := NULL;
    vr_qtctlexc  INTEGER := 0;
    vr_datagenproxdia Date := NULL;
    
  BEGIN

    OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;

    IF btch0001.cr_crapdat%NOTFOUND THEN
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_ds_erro := gene0001.fn_busca_critica(pr_cdcritic => 1); --Sistema sem data de movimento.
      RAISE vr_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;
    
    -- Busca quantidade de execuções do programa durante o dia no Debitador Único
    BEGIN
      SELECT Count(1)  qt_hora_prg_debitador
      INTO   vr_qt_hora_prg_debitador
      FROM   tbgen_debitador_param         tdp
            ,tbgen_debitador_horario_proc  tdhp
      WHERE  tdhp.cdprocesso       = tdp.cdprocesso
      AND    Upper(tdp.cdprocesso) = Upper(pr_cdprocesso);
    EXCEPTION
      WHEN OTHERS THEN
        vr_ds_erro := 'Erro ao verificar quantidade de execuções do programa '||pr_cdprocesso||' durante o dia no Debitador Único. Erro: '||SubStr(SQLERRM,255);
        RAISE vr_erro;
    END;

    -- Buscar parâmetro de execução na cadeia noturna além do debitador único.
    -- Valida Programa do cadastro do Debitador
    OPEN cr_tbgen_param_debit_unico;
    FETCH cr_tbgen_param_debit_unico INTO rw_tbgen_param_debit_unico;
    IF cr_tbgen_param_debit_unico%NOTFOUND THEN
      CLOSE cr_tbgen_param_debit_unico;
      vr_ds_erro := 'Erro ao buscar parâmetro de indicador de execução do programa do debitor na cadeia noturna. Parâmetro não encontrado.';
      RAISE vr_erro;
    ELSE
      CLOSE cr_tbgen_param_debit_unico;
    END IF;

    -- Se a rotina executa na cadeia noturna, atribui mais uma execução no contador.
    IF NVL(rw_tbgen_param_debit_unico.inexec_cadeia_noturna,'N') = 'S' THEN
      vr_qt_hora_prg_debitador := vr_qt_hora_prg_debitador + 1;
    END IF;

    --Monta acesso ao Parametro na (crapprm)
    IF Upper(pr_cdprocesso) = 'PC_CRPS642' THEN
      vr_cdacesso := 'QTD_EXEC_DEBSIC';
      vr_cdacesso_ctrl := 'DEBSIC';
    ELSIF Upper(pr_cdprocesso) = 'PC_CRPS642_PRIORI' THEN
      vr_cdacesso := 'QTD_EXEC_DEBSIC_PRIORI';
      vr_cdacesso_ctrl := 'DEBSIC_PRIORI';
    ELSIF Upper(pr_cdprocesso) = 'PC_CRPS509' THEN
      vr_cdacesso := 'QTD_EXEC_DEBNET';
      vr_cdacesso_ctrl := 'DEBNET';
    ELSIF Upper(pr_cdprocesso) = 'PC_CRPS509_PRIORI' THEN
      vr_cdacesso := 'QTD_EXEC_DEBNET_PRIORI';
      vr_cdacesso_ctrl := 'DEBNET_PRIORI';
    ELSIF Upper(pr_cdprocesso) = 'RCEL0001.PC_PROCES_AGENDAMENTOS_RECARGA' THEN
      vr_cdacesso := 'QTD_EXEC_'||'JOBAGERCEL';
      vr_cdacesso_ctrl := 'JOBAGERCEL';
    ELSIF Upper(pr_cdprocesso) = 'PAGA0003.PC_PROCESSA_AGEND_BANCOOB' THEN
      vr_cdacesso := 'QTD_EXEC_DEBBAN';
      vr_cdacesso_ctrl := 'DEBBAN';
    ELSIF upper(pr_cdprocesso) = 'TARI0001.PC_DEB_TARIFA_PEND' THEN
         vr_cdacesso := 'QTD_EXEC_DEBUNITAR';
         vr_cdacesso_ctrl:= 'DEBUNITAR';
    ELSE
      vr_cdacesso := 'QTD_EXEC_'||SubStr(pr_cdprocesso,4);
      vr_cdacesso_ctrl := SubStr(pr_cdprocesso,4);
    END IF;

    --2#09/08/2018#3
    FOR rec_crapprm IN (SELECT prm.dsvlrprm
                               --to_date(TRIM(substr(prm.dsvlrprm, INSTR(prm.dsvlrprm,'#')+1, 10)),'DD/MM/RRRR') datagenproxdia
                          FROM crapprm  prm
                         WHERE prm.nmsistem = 'CRED' --Fixo
                           AND prm.cdcooper = pr_cdcooper
                           AND prm.cdacesso = vr_cdacesso) LOOP

      -- Tamanho do parâmetro maior que 3 tem horario agendado para o próximo dia
      IF length(rec_crapprm.dsvlrprm) > 3 THEN  

        BEGIN
          SELECT to_date(TRIM(substr(prm.dsvlrprm, INSTR(prm.dsvlrprm,'#')+1, 10)),'DD/MM/RRRR') 
          INTO  vr_datagenproxdia
          FROM crapprm  prm
          WHERE prm.nmsistem = 'CRED' --Fixo
          AND prm.cdcooper = pr_cdcooper
          AND prm.cdacesso = vr_cdacesso;
        EXCEPTION
          WHEN OTHERS THEN
            vr_ds_erro := 'Erro ao verificar data agendamento proximo dia, '||pr_cdprocesso||' durante o dia no Debitador Único. Erro: '||SubStr(SQLERRM,255);
            RAISE vr_erro;
        END;     
        IF rw_crapdat.inproces = 1 THEN --- para não contar quando executando na cadeia
            -- Busca quantidade de execuções faltantes no dia do programa durante o dia no Debitador Único
            BEGIN
              SELECT Count(1) + 1  qt_hora_prg_debitador_dia
                INTO vr_qt_hora_prg_debitador_dia
                FROM tbgen_debitador_param         tdp
                    ,tbgen_debitador_horario_proc  tdhp
                    ,tbgen_debitador_horario       tdh
               WHERE tdhp.cdprocesso           = tdp.cdprocesso
                 AND tdhp.idhora_processamento = tdh.idhora_processamento
                 AND Upper(tdp.cdprocesso)     = Upper(pr_cdprocesso)
                 AND To_Date(To_Char(tdh.dhprocessamento,'hh24:mi'),'hh24:mi') >= To_Date(To_Char(SYSDATE+(1/60/24),'hh24:mi'),'hh24:mi')
                 and rw_crapdat.inproces = 1; --- para não contar quando executando na cadeia
            EXCEPTION
              WHEN OTHERS THEN
                vr_ds_erro := 'Erro ao verificar quantidade de execuções faltantes no dia do programa '||pr_cdprocesso||' durante o dia no Debitador Único. Erro: '||SubStr(SQLERRM,255);
                RAISE vr_erro;
            END;     
    END IF;

        -- Se a rotina executa na cadeia noturna, atribui mais uma execução no contador.
        IF NVL(rw_tbgen_param_debit_unico.inexec_cadeia_noturna,'N') = 'S' THEN
          vr_qt_hora_prg_debitador_dia := nvl(vr_qt_hora_prg_debitador_dia,0) + 1;
        END IF;        
        
        -- Buscar a quantidade de execuções já realizadas no dia        
        --> buscar parametro de controle de execução
        OPEN cr_crapprm (pr_cdcooper => pr_cdcooper,
                         pr_cdacesso => 'CTRL_'||upper(vr_cdacesso_ctrl)||'_EXEC');
        FETCH cr_crapprm INTO rw_crapprm_ctrl;
        IF cr_crapprm%NOTFOUND THEN
          vr_ds_erro := 'Parametro de sistema '||'CTRL_'||vr_cdacesso_ctrl||'_EXEC não encontrado.';
          CLOSE cr_crapprm;
          RAISE vr_erro;
        END IF;
        CLOSE cr_crapprm;

        -- tratar dados do parametro
        vr_tbdados := gene0002.fn_quebra_string(pr_string  => rw_crapprm_ctrl.dsvlrprm,
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

        -- Se mudou a data, deve zerar 
        IF nvl(vr_dtctlexc,to_date('01/01/2001','DD/MM/RRRR')) <> rw_crapdat.dtmvtolt THEN
          vr_qtctlexc := 0;
        END IF;  
        ---
        
        -- vr_datagenproxdia = Data que existe agendamento de horario para o dia posterior ao atual
        IF vr_datagenproxdia <= TRUNC(SYSDATE) AND  rw_crapdat.inproces = 1 THEN          
          vr_ds_hora_prg_debitador := vr_qt_hora_prg_debitador;
        ELSE
          -- realizado esse comando para ajustar a quantidade de horarios do dia, isso para o caso:
          -- no mesmo dia adicionou horarios anteriores a execução atual e também adicionou horários posteriores a execução atual
          vr_ds_hora_prg_debitador := to_char(vr_qt_hora_prg_debitador_dia + nvl(vr_qtctlexc,0))||'#'||substr(rec_crapprm.dsvlrprm,instr(rec_crapprm.dsvlrprm,'#')+1);
        END IF;
      ELSE
        vr_ds_hora_prg_debitador := vr_qt_hora_prg_debitador;
      END IF;
      
      
      -- Atualizar quantidade de execuções do programa durante o dia na crapprm
      BEGIN
        UPDATE crapprm  prm
        --SET    prm.dsvlrprm  = vr_qt_hora_prg_debitador
        SET    prm.dsvlrprm  = vr_ds_hora_prg_debitador        
        WHERE  prm.nmsistem = 'CRED' --Fixo
        AND    prm.cdcooper = pr_cdcooper
        AND    prm.cdacesso = vr_cdacesso;
      EXCEPTION
        WHEN OTHERS THEN
          vr_ds_erro := 'Erro ao atualizar quantidade de execuções do programa durante o dia na crapprm. Cd.Acesso: '||vr_cdacesso||'. Erro: '||SubStr(SQLERRM,255);
          RAISE vr_erro;
      END;
    
    END LOOP;

    -- Valida se alterou o registro na crapprm
    IF SQL%ROWCOUNT = 0 THEN
      vr_ds_erro := 'Parâmetro de quantidade de execuções do programa durante o dia na crapprm não encontrado. Cd.Acesso: '||vr_cdacesso||'.';
      RAISE vr_erro;
    END IF;

    -- Salva Alteração
    COMMIT;

  EXCEPTION
    WHEN vr_erro THEN
      pr_ds_erro := vr_ds_erro;
    WHEN OTHERS THEN
      pr_ds_erro := 'Erro Geral na gen_debitador_unico.pc_qt_hora_prg_debitador. Erro: '||SubStr(SQLERRM,1,255);
  END pc_qt_hora_prg_debitador;

  /* Verificar se há algun JOB do Debitador rodando para a Cooperativa */
  PROCEDURE pc_verifica_job_running(pr_cdcooper             IN crapcop.cdcooper%TYPE
                                   ,pr_idhora_processamento IN tbgen_debitador_horario_proc.idhora_processamento%TYPE
                                   ,pr_job_name_running    OUT dba_scheduler_jobs.job_name%TYPE
                                   ,pr_start_date          OUT VARCHAR2
                                   ,pr_ds_erro             OUT crapcri.dscritic%TYPE) IS
    --Variável Exceção
    vr_erro           EXCEPTION;
    vr_ds_erro        crapcri.dscritic%TYPE;
  BEGIN
    -- Verifica se há algum JOB do Debitador/Cooperativa executando
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
      AND    UPPER(j.job_action) LIKE '%PR_CDCOOPER              => '||pr_cdcooper||' %' -- Obrigatorio "espaco" antes do "percent" (26/10/2018).
      -- Que não seja o próprio
      AND  ((UPPER(j.job_action) NOT LIKE '%PR_IDHORA_PROCESSAMENTO  => '||pr_idhora_processamento||'%' AND pr_idhora_processamento IS NOT NULL)
       OR    pr_idhora_processamento IS NULL)
      AND    ROWNUM = 1;
    EXCEPTION
      WHEN No_Data_Found THEN
        pr_job_name_running  := NULL;
        pr_start_date        := NULL;
      WHEN OTHERS THEN
        vr_ds_erro := 'Erro ao verificar se existe algum job do Debitador Único em execução. Erro: '||SubStr(SQLERRM,1,255);
        RAISE vr_erro;
    END;
  EXCEPTION
    WHEN vr_erro THEN
      pr_ds_erro := vr_ds_erro;
    WHEN OTHERS THEN
      pr_ds_erro := 'Erro Geral na gen_debitador_unico.pc_verifica_job_running. Erro: '||SubStr(SQLERRM,1,255);
  END pc_verifica_job_running;


  /* Dropa e Recria JOB do Debitador Único conforme parametrização (tbgen_debitador_param) */
  PROCEDURE pc_job_debitador_unico(pr_idhora_processamento IN tbgen_debitador_horario_proc.idhora_processamento%TYPE
                                  ,pr_idtipo_operacao      IN VARCHAR2) IS --I=Incluir ou E=Excluir

    --Busca todas as Cooperativas Ativas (Exceto Cecred)
    CURSOR cr_cooperativa IS
      SELECT cdcooper
      FROM   crapcop  cop
      WHERE  flgativo  = 1 --Cooperativas Ativas
      AND    cdcooper <> 3 --Exceto CECRED
      ORDER BY cdcooper;

    --Busca o horário de execução do debitar
    CURSOR cr_horario_debitador(pr_idhora_processamento IN tbgen_debitador_horario_proc.idhora_processamento%TYPE) IS
      SELECT tdh.idhora_processamento  idhora_processamento
            ,tdh.dhprocessamento       dhprocessamento
      FROM   cecred.tbgen_debitador_horario  tdh
      WHERE  idhora_processamento = pr_idhora_processamento
      ORDER BY tdh.dhprocessamento;

    -- Busca os JOB's do Debitador Único conforme Id do Horário
    CURSOR cr_job_debitador(pr_idhora_processamento IN tbgen_debitador_horario_proc.idhora_processamento%TYPE) IS
      SELECT job.owner
            ,job.job_name
            ,job.next_run_date
      FROM   dba_scheduler_jobs job
      WHERE  job.owner = 'CECRED' --Fixo
      AND   (job.job_name LIKE 'JBDEB_UNICO_HORA'||Lpad(pr_idhora_processamento,2,'0')||'%'
        OR   job.job_name LIKE 'JBDEB_UNI_'||Lpad(pr_idhora_processamento,2,'0')||'%' )
      ORDER BY job.job_name;

    -- Variáveis de controle de calendário
    rw_crapdat         btch0001.cr_crapdat%ROWTYPE;

    -- Variáveis de controle
    vr_cdcooper        crapcop.cdcooper%TYPE := 3; --Fixo
    vr_dthrexe         VARCHAR2(21);
    vr_nm_job          VARCHAR2(100);
    vr_ds_bloco_plsql  VARCHAR2(30000);
    vr_cdprogra        tbgen_debitador_param.cdprocesso%TYPE := 'PC_JOB_DEBITADOR_UNICO';
    vr_email_dest      VARCHAR2(1000);
    vr_conteudo        VARCHAR2(4000);

  BEGIN

    -- Verificação do calendário
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

    -- Excluir JOB do Debitador Único
    IF pr_idtipo_operacao = 'E' THEN

      -- Log de ocorrência
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

        -- Log de ocorrência
        pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra
                            ,pr_indexecu => 'JOB '||r_job_debitador.job_name||' excluido.'
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_tpexecuc => NULL
                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                            ,pr_idtiplog => 'O');
      END LOOP;

    --Incluir JOB do Debitador Único
    ELSIF pr_idtipo_operacao = 'I' THEN

      -- Log de ocorrência
      pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra
                          ,pr_indexecu => 'Buscando Horario do Debitador Unico...'
                          ,pr_cdcooper => vr_cdcooper
                          ,pr_tpexecuc => NULL
                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                          ,pr_idtiplog => 'O');

      -- Para cada horário do Debitador Único
      FOR r_horario_debitador IN cr_horario_debitador(pr_idhora_processamento => pr_idhora_processamento) LOOP

        -- Log de ocorrência
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

          -- Monta Ação (PL/SQL) do Job
          vr_ds_bloco_plsql := 'BEGIN'||CHR(13)||
                               '  gen_debitador_unico.pc_executa_debitador_unico(pr_cdcooper              => '||r_cooperativa.cdcooper||CHR(13)||
                               '                                                ,pr_idhora_processamento  => '||r_horario_debitador.idhora_processamento||CHR(13)||
                               '                                                ,pr_ds_cdprocesso         => '||'NULL'||CHR(13)||
                               '                                                ,pr_nrprioridade_prg_erro => '||'NULL'||');'||CHR(13)||
                               'END;';

          --Se a hora inclusa for menor que a hora atual
          IF To_Date(To_Char(r_horario_debitador.dhprocessamento,'dd/mm/rrrr hh24:mi'),'dd/mm/rrrr hh24:mi') < To_Date(To_Char(SYSDATE,'dd/mm/rrrr hh24:mi'),'dd/mm/rrrr hh24:mi') THEN
            -- O JOB será criado com disparo somente no próximo dia
            vr_dthrexe := To_Char(r_horario_debitador.dhprocessamento + 1,'dd/mm/rrrr hh24:mi:ss');
          --Se a hora inclusa for maior ou igual a hora atual
          ELSE
            -- O JOB será criado com disparo no dia atual
            vr_dthrexe := To_Char(r_horario_debitador.dhprocessamento,'dd/mm/rrrr hh24:mi:ss');
          END IF;

          -- Log de ocorrência
          pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra
                              ,pr_indexecu => 'Criando JOB do Debitador Unico: '||vr_nm_job||'...'
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_tpexecuc => NULL
                              ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                              ,pr_idtiplog => 'O');

          --Cria o JOB para Cada Horário do Debitador Único e para cada Cooperativa
          gene0001.pc_submit_job(pr_cdcooper  => r_cooperativa.cdcooper
                                ,pr_cdprogra  => vr_nm_job
                                ,pr_dsplsql   => vr_ds_bloco_plsql
                                ,pr_dthrexe   => TO_TIMESTAMP_TZ(vr_dthrexe||' America/Sao_Paulo','DD/MM/RRRR HH24:MI:SS TZR')
                                ,pr_interva   => 'Freq=daily;ByDay=MON, TUE, WED, THU, FRI;ByHour='||to_char(to_date(vr_dthrexe,'DD/MM/RRRR HH24:MI:SS'),'hh24')||';ByMinute='||to_char(to_date(vr_dthrexe,'DD/MM/RRRR HH24:MI:SS'),'mi')||';BySecond=0' --'SYSDATE+1'--26/10/2018.
                                ,pr_jobname   => vr_nm_job
                                ,pr_des_erro  => vr_dscritic);

          -- Tratamento de erro
          IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
            vr_dscritic := 'Falha na criacao do JOB do Debitador Unico. (Cooperativa:'||r_cooperativa.cdcooper||' Job: '||vr_nm_job||'). Erro: '||vr_dscritic;
            RAISE vr_exc_email;
          END IF;

          -- Log de ocorrência
          pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra
                              ,pr_indexecu => 'JOB '||vr_nm_job||' criado.'
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_tpexecuc => NULL
                              ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                              ,pr_idtiplog => 'O');

        END LOOP; --Fim Loop Cooperativas

      END LOOP; --Fim Loop Horários do Debitador

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

      -- Gravar conteudo do email, controle com substr para não estourar campo texto
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
                                ,pr_flg_remete_coop => 'N' --> Se o envio ser¿ do e-mail da Cooperativa
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

      -- Gravar conteudo do email, controle com substr para não estourar campo texto
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
                                ,pr_flg_remete_coop => 'N' --> Se o envio será do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic);
      COMMIT;
  END pc_job_debitador_unico;


  /* Executar Debitador Único */
  PROCEDURE pc_executa_debitador_unico(pr_cdcooper              IN crapcop.cdcooper%TYPE
                                      ,pr_idhora_processamento  IN tbgen_debitador_horario_proc.idhora_processamento%TYPE
                                      ,pr_ds_cdprocesso         IN VARCHAR2
                                      ,pr_nrprioridade_prg_erro IN tbgen_debitador_param.nrprioridade%TYPE) IS

    /*
	| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | 
    | Alterações                                                                                                                                                                 |
    | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | 
    | 08/08/2108 - Vitor Shimada Assanuma (GFT) - Inclusão da PC_CRPS735                                                                                                         |
    | ------------------------------------------------------------------------------------------------------------------------ | ---------------- | -------------- | ----------- |
    | Programa                                                                                                                 | Debita Sem Saldo | Debita Parcial | Repescagem  |
    | ------------------------------------------------------------------------------------------------------------------------ | ---------------- | -------------- | ----------- |
    | OK - PC_CRPS509_PRIORI - DEBNET - EFETUAR DEBITO DE AGENDAMENTOS DE CONVENIOS PRIORITARIOS DA CECRED FEITOS NA INTERNET  | Não              | Não            | Não         |
    | OK - PC_CRPS509 - DEBNET - EFETUAR DEBITO DE AGENDAMENTOS DE CONVENIOS DA CECRED FEITOS NA INTERNET                      | Não              | Não            | Não         |
    | OK - PC_CRPS642_PRIORI - DEBSIC - EFETUAR DEBITO DE AGENDAMENTOS DE CONVENIOS PRIORITARIOS DA SICREDI FEITOS NA INTERNET | Não              | Não            | Não         |
    | OK - PC_CRPS642 - DEBSIC - EFETUAR DEBITO DE AGENDAMENTOS DE CONVENIOS DA SICREDI FEITOS NA INTERNET                     | Não              | Não            | Não         |
    | OK - PC_CRPS750 - PAGAMENTOS DAS PARCELAS DE EMPRÉSTIMOS (TR E PP)                                                       | Não              | Sim            | Não         |
    | OK - TARI0001.PC_DEB_TARIFA_PEND - COBRANCA DE TARIFAS PENDENTES                                                         | Não              | Sim            | Não         |
    | OK - PC_CRPS172 - DEBITO EM CONTA DAS PRESTACOES DE PLANO DE CAPITAL                                                     | Não              | Não            | Não         |
    | OK - PC_CRPS145 - DEBITO EM CONTA REF POUPANCA PROGRAMADA                                                                | Não              | Não            | Não         |
    | OK - PC_CRPS439 - DEBITO DIARIO DO SEGURO                                                                                | Sim              | Não            | Não         |
    | OK - PC_CRPS654 - TENTATIVA DIARIA DEBITO DE COTAS                                                                       | Não              | Sim            | Não         |
    | OK - PC_CRPS674 - DEBITO DE FATURA - LANCAMENTO DE DEBITO AUTOMATICO - BANCOOB/CABAL                                     | Não              | Sim            | 1 = Repique |
    | OK - PC_CRPS688 - EFETUAR RESGATE DE APLICAÇÕES AGENDADAS PELO INTERNET BANK                                             | Não              | Não            | Não         |
    | OK - RCEL0001.PC_PROCES_AGENDAMENTOS_RECARGA - EFETIVAR OS AGENDAMENTOS DE RECARGA DE CELULAR                            | Não              | Não            | Não         |
    | OK - EMPR0009.PC_EFETIVA_LCTO_PENDENTE_JOB - EFETIVAR LANCAMENTO PENDENTE MULTA/JUROS TR CONTRATOS EMP/FINANC POS-FIXADA | Não              | Não            | Não         |
    | OK - PC_CRPS123 - EFETUAR OS LANCAMENTOS AUTOMATICOS NO SISTEMA REF. A DEBITO EM CONTA                                   | Sim              | Não            | Não         |
    | OK - PC_CRPS724 - PAGAR AS PARCELAS DOS CONTRATOS DO PRODUTO POS-FIXADO                                                  | Não              | Sim            | Não         |
    | OK - PC_CRPS663 - DEBCNS - EFETUAR DEBITOS DE CONSORCIOS PENDENTES                                                       | Não              | Não            | Não         |
    | OK - PC_CRPS268 - DEBITO EM CONTA REFERENTE SEGURO DE VIDA EM GRUPO                                                      | Sim              | Não            | Não         |
    | OK - PAGA0003.PC_PROCESSA_AGEND_BANCOOB - DEBITO AGENDADOS DE PAGAMENTO BONCOOB                                          | Não              | Não            | Não         |
	| OK - PC_CRPS735 - DESCONTO DE TÍTULOS                                                                                    | Não              | Sim            | Não         |
    | ------------------------------------------------------------------------------------------------------------------------ | ---------------- | -------------- | ----------- |
    */

    --Busca s processos/programas do debitador por ordem de prioridade
    CURSOR cr_processo_horario(pr_idhora_processamento  IN cecred.tbgen_debitador_horario_proc.idhora_processamento%TYPE
                              ,pr_ds_cdprocesso         IN VARCHAR2
                              ,pr_nrprioridade_prg_erro IN tbgen_debitador_param.nrprioridade%TYPE) IS
      --Execução via Job do Debitador Único
      SELECT Upper(tdp.cdprocesso)  cdprocesso
            ,tdp.nrprioridade       nrprioridade
            ,tdh.dhprocessamento    dhprocessamento
      FROM   tbgen_debitador_param         tdp
            ,tbgen_debitador_horario_proc  tdhp
            ,tbgen_debitador_horario       tdh
      WHERE  tdp.cdprocesso            = tdhp.cdprocesso
      AND    tdhp.idhora_processamento = tdh.idhora_processamento
      AND    tdh.idhora_processamento  = pr_idhora_processamento
      AND    pr_idhora_processamento IS NOT NULL --Quando Chamado por Job do Debitador Único
      AND    tdp.nrprioridade        IS NOT NULL --Com Prioridade informada no Debitador Único
      UNION ALL
      --Execução Emergencial de Programas Específicos
      SELECT Upper(tdp.cdprocesso)  cdprocesso
            ,tdp.nrprioridade       nrprioridade
            ,SYSDATE                dhprocessamento
      FROM   tbgen_debitador_param  tdp
      WHERE  InStr(pr_ds_cdprocesso,tdp.cdprocesso||',') > 0
      AND    EXISTS (SELECT 1
                     FROM   tbgen_debitador_horario_proc  tdhp
                     WHERE  tdhp.cdprocesso = tdp.cdprocesso) --Programas que estão associados a algum horário do Debitador Único
      AND    pr_ds_cdprocesso IS NOT NULL --Quando Chamado por Execução Emergencial de Programas Específicos
      AND    tdp.nrprioridade IS NOT NULL --Com Prioridade informada no Debitador Único
      UNION ALL
      --Execução Emergencial de Apartir do Programa que gerou Erro
      SELECT Upper(tdp.cdprocesso)  cdprocesso
            ,tdp.nrprioridade       nrprioridade
            ,SYSDATE                dhprocessamento
      FROM   tbgen_debitador_param  tdp
      WHERE  tdp.nrprioridade >= pr_nrprioridade_prg_erro
      AND    EXISTS (SELECT 1
                     FROM   tbgen_debitador_horario_proc  tdhp
                     WHERE  tdhp.cdprocesso = tdp.cdprocesso) --Programas que estão associados a algum horário do Debitador Único
      AND    pr_nrprioridade_prg_erro IS NOT NULL --Quando Chamado por Execução Emergencial apartir do programa que gerou erro no Debitador Único
      AND    tdp.nrprioridade         IS NOT NULL --Com Prioridade informada no Debitador Único
      ORDER BY nrprioridade;

    -- Variáveis de controle de calendário
    rw_crapdat                  btch0001.cr_crapdat%ROWTYPE;

    -- Variáveis de controle
    vr_cdprogra_raiz            tbgen_debitador_param.cdprocesso%TYPE := 'PC_EXECUTA_DEBITADOR_UNICO';
    vr_cdprogra                 tbgen_debitador_param.cdprocesso%TYPE := 'PC_EXECUTA_DEBITADOR_UNICO';
    vr_minutos                  NUMBER;
    vr_nm_job                   VARCHAR2(100);
    vr_ds_bloco_plsql           VARCHAR2(30000);
    vr_dtvalida                 DATE;
    vr_dtdiahoje                DATE;
    vr_stprogra                 PLS_INTEGER;--Não utilizada
    vr_infimsol                 PLS_INTEGER;--Não utilizada
    vr_email_dest               VARCHAR2(1000);
    vr_conteudo                 VARCHAR2(4000);
    vr_dh_erro                  DATE;
    vr_cd_prg_erro              tbgen_debitador_param.cdprocesso%TYPE;
    vr_nrprioridade             tbgen_debitador_param.nrprioridade%TYPE;
    vr_tpexec_emergencial       VARCHAR2(1);
    vr_inexecutou_integra_abbc  VARCHAR2(1) := 'N';
    vr_interminou_anterior      VARCHAR2(1) := 'S'; -- 26/10/2018.
    vr_job_name_running         dba_scheduler_jobs.job_name%TYPE;
    vr_start_date               VARCHAR2(18);
    -- Controle de agendamento para o próximo dia
    vr_flultexe                 INTEGER;
    vr_qtdexec                  INTEGER;
    vr_qtdexectot               INTEGER;
    vr_temhorproxdia            BOOLEAN;
    vr_dataagenproxdia          DATE;
    vr_cdcritic                 crapcri.cdcritic%TYPE;
    vr_dscritic                 VARCHAR2(4000);

  BEGIN
    --
    -- Verificação do calendário
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

    --Se for Execução Emergencial (Chamada pela tela de Parâmetros do Debitador)
    IF pr_nrprioridade_prg_erro IS NOT NULL OR pr_ds_cdprocesso IS NOT NULL THEN
      -- Monta Tipo de Execução Emergencail
      IF pr_nrprioridade_prg_erro IS NOT NULL THEN
        vr_tpexec_emergencial := 'E'; --E=Apartir da prioridade do programa que ocasionou erro no debitador
      ELSIF pr_ds_cdprocesso IS NOT NULL THEN
        vr_tpexec_emergencial := 'P'; --P=Programa(s) Específicos
      END IF;


      -- Log de ocorrência
      pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                          ,pr_indexecu => 'Validando informacoes para Execucao Emergencial...'
                          ,pr_cdcooper => pr_cdcooper
                          ,pr_tpexecuc => NULL
                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                          ,pr_idtiplog => 'O');

      -- Validações para Execução Emergencial
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
      
      -- Decrementa Qtde no Controle de Execução do Programa
      pc_atualiza_ctrl_exec_prg (pr_cdcooper              => pr_cdcooper
                                ,pr_ds_cdprocesso         => pr_ds_cdprocesso
                                ,pr_nrprioridade_prg_erro => pr_nrprioridade_prg_erro
                                ,pr_ds_erro               => vr_dscritic);
      -- Tratamento Erro
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_email;
      END IF;      
    END IF;

    -- Log de ocorrência
    pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                        ,pr_indexecu => 'Verificando Dia Util...'
                        ,pr_cdcooper => pr_cdcooper
                        ,pr_tpexecuc => NULL
                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                        ,pr_idtiplog => 'O');

    -- Verifica dia útil
    vr_dtdiahoje := Trunc(SYSDATE);
    vr_dtvalida  := gene0005.fn_valida_dia_util(pr_cdcooper  => pr_cdcooper
                                               ,pr_dtmvtolt  => vr_dtdiahoje
                                               ,pr_tipo      => 'A'
                                               ,pr_feriado   => TRUE
                                               ,pr_excultdia => TRUE);

    -- Se for Dia Útil e não for o último dia do ano
    -- Somente Segunda, Terça, Quarta, Quinta e Sexta-Feira, exceto feriados e exceto último dia do ano
    IF vr_dtvalida = vr_dtdiahoje THEN

      -- Log de ocorrência
      pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                          ,pr_indexecu => 'Verificando se ha algum JOB do Debitador rodando para a Cooperativa...'
                          ,pr_cdcooper => pr_cdcooper
                          ,pr_tpexecuc => NULL
                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                          ,pr_idtiplog => 'O');

      -- Verificar se há algun JOB do Debitador rodando para a Cooperativa
      pc_verifica_job_running(pr_cdcooper             => pr_cdcooper
                             ,pr_idhora_processamento => pr_idhora_processamento
                             ,pr_job_name_running     => vr_job_name_running
                             ,pr_start_date           => vr_start_date
                             ,pr_ds_erro              => vr_dscritic);
      -- Tratamento Erro
      vr_interminou_anterior := 'S';
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        --RAISE vr_exc_email; -- 26/10/2018 trocado raise pelo flag para poder reagendar o job.
        vr_interminou_anterior := 'N'; 
      END IF;

      -- Se a há algun JOB do Debitador rodando para a Cooperativa (Running)
      IF vr_job_name_running IS NOT NULL THEN
        vr_dscritic := 'Debitador Abortado em '||To_Char(SYSDATE,'dd/mm/rrrr hh24:mi')||' devido a existir um JOB ainda executando o Debitador: '||vr_job_name_running||' com Start em '||vr_start_date||'. (Cooperativa: '||pr_cdcooper||')';
        RAISE vr_exc_email;
      END IF;

      -- Log de ocorrência
      pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                          ,pr_indexecu => 'Verificando se ja executou a integracao ABBC...'
                          ,pr_cdcooper => pr_cdcooper
                          ,pr_tpexecuc => NULL
                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                          ,pr_idtiplog => 'O');

      -- Verifica se executou a integração ABBC do dia anterior
      pc_valida_integracao_abbc(pr_cdcooper                => pr_cdcooper           --Coopertativa
                               ,pr_tpexecucao              => 1                     --Batch
                               ,pr_cdprograma              => 'CRPS538'             --Processo ABBC
                               ,pr_dtprglog                => rw_crapdat.dtmvtoan+1 --Data Anterior da Cooperativa + 1 (O log do integração é gerado na madrugada do dia seguinte da data atual da cooperativa. Ex: Integração referente ao dia 19/06/2018, no log da integração a data do log será de 20/06/2018)
                               ,pr_flgsucesso              => 1                     --Indicador de sucesso da execução
                               ,pr_inexecutou_integra_abbc => vr_inexecutou_integra_abbc
                               ,pr_dscritic                => vr_dscritic);
      -- Tratamento Erro
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_email;
      END IF;

      --19/06/2018
      --Alteração: Solicitado por Rodrigo Siewerdt/Cecred para não abortar o debitador e sim reprogramar o JOB caso a integração ABBC (CRPS538) ainda não foi processada
      -- Se a Integração ABBC ainda não foi processada
      --IF Nvl(vr_inexecutou_integra_abbc,'N') = 'N' THEN
        --vr_dscritic := 'Debitador Abortado. CRPS538 - Integração ABBC ainda não foi processada em '||To_Char(rw_crapdat.dtmvtolt,'dd/mm/rrrr')||'. (Cooperativa: '||pr_cdcooper||').';
        --RAISE vr_exc_email;
      --END IF;

      -- Log de ocorrência
      pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                          ,pr_indexecu => 'Verificando se a Cooperativa ainda esta executando o Processo Batch (Noturno)...'
                          ,pr_cdcooper => pr_cdcooper
                          ,pr_tpexecuc => NULL
                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                          ,pr_idtiplog => 'O');

      -- Se a Cooperativa ainda estiver executando o Processo Batch (Noturna) 
      -- ou a integração ABBC (CRPS538) ainda não foi processada
      -- ou o job anterior (debitador) ainda nao terminou ENTAO REAGENDA JOB ATUAL:	  
      IF rw_crapdat.inproces > 1 
      OR Nvl(vr_inexecutou_integra_abbc,'N') = 'N' 
      OR Nvl(vr_interminou_anterior,'N') = 'N' THEN --26/10/2018.

        -- Log de ocorrência
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
        -- Se não encontrou o parâmetro
        IF Nvl(vr_minutos,0) = 0 THEN
          -- Montar mensagem de critica
           vr_cdcritic := 10200; --Parametro de qtde em minutos para reagendar JOBs do Debitador Unico nao encontrado.
           vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
           RAISE vr_exc_email;
        END IF;

        -- Monta nome do JOB com no máximo 18 caractecres devido a limitação do Oracle para casos de Jobs sem intervalo
        vr_nm_job := 'JBDEB_UNI_'||Lpad(Nvl(pr_idhora_processamento,99),2,'0')||'_'||Lpad(pr_cdcooper,2,'0')||'_R_';

        -- Monta Bloco PL/SQL (Ação do Job)
        vr_ds_bloco_plsql := 'BEGIN'||CHR(13)||
                             '  gen_debitador_unico.pc_executa_debitador_unico(pr_cdcooper              => '||pr_cdcooper||CHR(13)||
                             '                                                ,pr_idhora_processamento  => '||pr_idhora_processamento||CHR(13)||
                             '                                                ,pr_ds_cdprocesso         => '||Nvl(pr_ds_cdprocesso,'NULL')||CHR(13)||
                             '                                                ,pr_nrprioridade_prg_erro => '||Nvl(To_Char(pr_nrprioridade_prg_erro),'NULL')||');'||CHR(13)||
                             'END;';

        -- Log de ocorrência
        pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                            ,pr_indexecu => 'Reagendando JOB '||vr_nm_job||', pois ainda esta executando o Processo Batch (Noturno) ou a Integração ABBC ainda não foi processada...'
                            ,pr_cdcooper => pr_cdcooper
                            ,pr_tpexecuc => NULL
                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                            ,pr_idtiplog => 'O');

        --Reagendar JOB para minutos posteriores (Conforme qtde de minutos recuperado no parâmetro QTD_MIN_REAGEN_DEBITADOR)
        gene0001.pc_submit_job(pr_cdcooper  => pr_cdcooper
                              ,pr_cdprogra  => vr_nm_job
                              ,pr_dsplsql   => vr_ds_bloco_plsql
                              ,pr_dthrexe   => To_TimeStamp_TZ(To_Char(SYSDATE + (vr_minutos/60/24),'dd/mm/rrrr hh24:mi:ss')||' America/Sao_Paulo','DD/MM/RRRR HH24:MI:SS TZR')
                              ,pr_interva   => NULL
                              ,pr_jobname   => vr_nm_job
                              ,pr_des_erro  => vr_dscritic);

        -- Tratamento Erro
        IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
          vr_dscritic := 'Falha no reagendamento do JOB do Debitador Unico. (Cooperativa:'||pr_cdcooper||' Job: '||vr_nm_job||'). Erro: '||vr_dscritic;
          RAISE vr_exc_email;
        END IF;

        -- Log de ocorrência
        pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                            ,pr_indexecu => 'JOB '||vr_nm_job||' reagendado para '||To_Char(SYSDATE + (vr_minutos/60/24),'DD/MM/RRRR HH24:MI')||'.'
                            ,pr_cdcooper => pr_cdcooper
                            ,pr_tpexecuc => NULL
                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                            ,pr_idtiplog => 'O');

      -- Se a Cooperativa NÃO estiver executando o Processo Batch (Noturna)
      ELSE

        -- Log de ocorrência
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

          --> verifificação de controle de horario agendado para o próximo dia
          -- Faz o controle para não executar um horario que foi agendado para o próximo dia
          -- devido a inserção após a última execução do programa
          gen_debitador_unico.pc_verifica_ctrl_ult_execucao(pr_cdcooper        => NULL
                                                           ,pr_cdprocesso      => Upper(r_processo_horario.cdprocesso)
                                                           ,pr_flultexe        => vr_flultexe
                                                           ,pr_qtdexec         => vr_qtdexec
                                                           ,pr_qtdexectot      => vr_qtdexectot
                                                           ,pr_temhorproxdia   => vr_temhorproxdia
                                                           ,pr_dataagenproxdia => vr_dataagenproxdia
                                                           ,pr_cdcritic        => vr_cdcritic
                                                           ,pr_dscritic        => vr_dscritic);


          -- Tratamento de erro
          IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
            --
            -- Atualiza Parâmetro de qual programa/cooperativa ocasionou erro no Debitador Único.
            pc_atualiz_erro_prg_debitador(pr_nmsistem => 'CRED'
                                         ,pr_cdcooper => pr_cdcooper
                                         ,pr_cdacesso => 'CTRL_ERRO_PRG_DEBITADOR'
                                         ,pr_dsvlrprm => To_Char(SYSDATE,'dd/mm/rrrr')||' '||To_Char(r_processo_horario.dhprocessamento,'hh24:mi')||'#'||Upper(r_processo_horario.cdprocesso));
            -- Log de erro de execucao
            pc_gera_log_execucao(pr_nmprgexe => Upper(r_processo_horario.cdprocesso)
                                ,pr_indexecu => 'Fim Execucao com Critica: '||vr_dscritic
                                ,pr_cdcooper => pr_cdcooper
                                ,pr_tpexecuc => NULL
                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                ,pr_idtiplog => 'E');
            RAISE vr_exc_email;
          END IF;


          -- Não realizar execução do programa pois o próximo horario é apenas para o dia seguinte.
          -- Se a execução está no mesmo dia do parametro de agendamento, permitirá executar
          IF (vr_temhorproxdia AND vr_dataagenproxdia <> rw_crapdat.dtmvtolt) AND
              vr_flultexe = 1 THEN --e já executou a última do dia
            NULL;
          ELSE
            --PC_CRPS509_PRIORI - DEBNET - EFETUAR DEBITO DE AGENDAMENTOS DE CONVENIOS PRIORITARIOS DA CECRED FEITOS NA INTERNET
            IF Upper(r_processo_horario.cdprocesso) = 'PC_CRPS509_PRIORI' THEN
              vr_cdprogra := 'PC_CRPS509_PRIORI';

              -- Log de ocorrência
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
              pc_crps509_priori(pr_cdcooper => pr_cdcooper   --IN crapcop.cdcooper%TYPE   --> Código Cooperativa
                               ,pr_flgresta => 0             --IN PLS_INTEGER             --> Flag padrão para utilização de restart
                               ,pr_stprogra => vr_stprogra   --OUT PLS_INTEGER            --> Saída de termino da execução
                               ,pr_infimsol => vr_infimsol   --OUT PLS_INTEGER            --> Saída de termino da solicitação
                               ,pr_cdcritic => vr_cdcritic   --OUT crapcri.cdcritic%TYPE  --> Código da Critica
                               ,pr_dscritic => vr_dscritic); --OUT VARCHAR2               --> Descricao da Critica

              -- Tratamento de erro
              IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
                --
                -- Atualiza Parâmetro de qual programa/cooperativa ocasionou erro no Debitador Único.
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

              -- Log de ocorrência
              pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                                  ,pr_indexecu => 'Programa '||vr_cdprogra||' Executado.'
                                  ,pr_cdcooper => pr_cdcooper
                                  ,pr_tpexecuc => NULL
                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                  ,pr_idtiplog => 'O');
              --
            --PC_CRPS509 - DEBNET - EFETUAR DEBITO DE AGENDAMENTOS DE CONVENIOS DA CECRED FEITOS NA INTERNET
            ELSIF Upper(r_processo_horario.cdprocesso) = 'PC_CRPS509' THEN
              vr_cdprogra := 'PC_CRPS509';

              -- Log de ocorrência
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
              pc_crps509(pr_cdcooper => pr_cdcooper --IN crapcop.cdcooper%TYPE   --> Código Cooperativa
                        ,pr_flgresta => 0           --IN PLS_INTEGER             --> Flag padrão para utilização de restart
                        ,pr_stprogra => vr_stprogra --OUT PLS_INTEGER            --> Saída de termino da execução
                        ,pr_infimsol => vr_infimsol --OUT PLS_INTEGER            --> Saída de termino da solicitação
                        ,pr_cdcritic => vr_cdcritic --OUT crapcri.cdcritic%TYPE  --> Código da Critica
                        ,pr_dscritic => vr_dscritic --OUT VARCHAR2               --> Descricao da Critica
                        ,pr_inpriori => 'N');       --IN VARCHAR2 DEFAULT 'T'    --> Indicador de prioridade para o debitador unico ("S"= agua/luz, "N"=outros, "T"=todos)

              -- Tratamento de erro
              IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
                --
                -- Atualiza Parâmetro de qual programa/cooperativa ocasionou erro no Debitador Único.
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

              -- Log de ocorrência
              pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                                  ,pr_indexecu => 'Programa '||vr_cdprogra||' Executado.'
                                  ,pr_cdcooper => pr_cdcooper
                                  ,pr_tpexecuc => NULL
                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                  ,pr_idtiplog => 'O');
              --
            --PC_CRPS642_PRIORI - DEBSIC - EFETUAR DEBITO DE AGENDAMENTOS DE CONVENIOS PRIORITARIOS DA SICREDI FEITOS NA INTERNET
            ELSIF Upper(r_processo_horario.cdprocesso) = 'PC_CRPS642_PRIORI' THEN
              vr_cdprogra := 'PC_CRPS642_PRIORI';

              -- Log de ocorrência
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
              pc_crps642_priori(pr_cdcooper => pr_cdcooper   --IN crapcop.cdcooper%TYPE   --> Código da cooperativa
                               ,pr_flgresta => 0             --IN PLS_INTEGER             --> Flag 0/1 para utilizar restart na chamada
                               ,pr_stprogra => vr_stprogra   --OUT PLS_INTEGER            --> Saída de termino da execução
                               ,pr_infimsol => vr_infimsol   --OUT PLS_INTEGER            --> Saída de termino da solicitação
                               ,pr_cdcritic => vr_cdcritic   --OUT crapcri.cdcritic%TYPE  --> Código da Critica
                               ,pr_dscritic => vr_dscritic); --OUT VARCHAR2               --> Descricao da Critica

              -- Tratamento de erro
              IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
                --
                -- Atualiza Parâmetro de qual programa/cooperativa ocasionou erro no Debitador Único.
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

              -- Log de ocorrência
              pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                                  ,pr_indexecu => 'Programa '||vr_cdprogra||' Executado.'
                                  ,pr_cdcooper => pr_cdcooper
                                  ,pr_tpexecuc => NULL
                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                  ,pr_idtiplog => 'O');
              --
            --PC_CRPS642 - DEBSIC - EFETUAR DEBITO DE AGENDAMENTOS DE CONVENIOS DA SICREDI FEITOS NA INTERNET
            ELSIF Upper(r_processo_horario.cdprocesso) = 'PC_CRPS642' THEN
              vr_cdprogra := 'PC_CRPS642';

              -- Log de ocorrência
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
              pc_crps642(pr_cdcooper => pr_cdcooper --IN crapcop.cdcooper%TYPE   --> Código da cooperativa
                        ,pr_flgresta => 0           --IN PLS_INTEGER             --> Flag 0/1 para utilizar restart na chamada
                        ,pr_stprogra => vr_stprogra --OUT PLS_INTEGER            --> Saída de termino da execução
                        ,pr_infimsol => vr_infimsol --OUT PLS_INTEGER            --> Saída de termino da solicitação
                        ,pr_cdcritic => vr_cdcritic --OUT crapcri.cdcritic%TYPE  --> Código da Critica
                        ,pr_dscritic => vr_dscritic --OUT VARCHAR2               --> Descricao da Critica
                        ,pr_inpriori => 'N');       --IN VARCHAR2 DEFAULT 'T'    --> Indicador de prioridade para o debitador unico ("S"= agua/luz, "N"=outros, "T"=todos)

              -- Tratamento de erro
              IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
                --
                -- Atualiza Parâmetro de qual programa/cooperativa ocasionou erro no Debitador Único.
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

               -- Log de ocorrência
              pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                                  ,pr_indexecu => 'Programa '||vr_cdprogra||' Executado.'
                                  ,pr_cdcooper => pr_cdcooper
                                  ,pr_tpexecuc => NULL
                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                  ,pr_idtiplog => 'O');
              --
            --PC_CRPS750 - PAGAMENTOS DAS PARCELAS DE EMPRÉSTIMOS (TR E PP)
            ELSIF Upper(r_processo_horario.cdprocesso) = 'PC_CRPS750' THEN
              vr_cdprogra := 'PC_CRPS750';

              -- Log de ocorrência
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
                -- Atualiza Parâmetro de qual programa/cooperativa ocasionou erro no Debitador Único.
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

              -- Log de ocorrência
              pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                                  ,pr_indexecu => 'Programa '||vr_cdprogra||' Executado.'
                                  ,pr_cdcooper => pr_cdcooper
                                  ,pr_tpexecuc => NULL
                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                  ,pr_idtiplog => 'O');

            --TARI0001.PC_DEB_TARIFA_PEND - COBRANCA DE TARIFAS PENDENTES
            ELSIF Upper(r_processo_horario.cdprocesso) = 'TARI0001.PC_DEB_TARIFA_PEND' THEN
              vr_cdprogra := 'TARI0001.PC_DEB_TARIFA_PEND';

              -- Log de ocorrência
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
                                         ,pr_dtinicio => NULL          --IN DATE                    --> data de inicio para verificação das tarifas
                                         ,pr_dtafinal => NULL          --IN DATE                    --> data final para verificação das tarifas
                                         ,pr_cdcritic => vr_cdcritic   --OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                         ,pr_dscritic => vr_dscritic); --OUT VARCHAR2               --> Texto de erro/critica encontrada

              -- Tratamento de erro
              IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
                --
                -- Atualiza Parâmetro de qual programa/cooperativa ocasionou erro no Debitador Único.
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

              -- Log de ocorrência
              pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                                  ,pr_indexecu => 'Programa '||vr_cdprogra||' Executado.'
                                  ,pr_cdcooper => pr_cdcooper
                                  ,pr_tpexecuc => NULL
                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                  ,pr_idtiplog => 'O');
              --
            --PC_CRPS172 - DEBITO EM CONTA DAS PRESTACOES DE PLANO DE CAPITAL
            ELSIF Upper(r_processo_horario.cdprocesso) = 'PC_CRPS172' THEN
              vr_cdprogra := 'PC_CRPS172';

              -- Log de ocorrência
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
              pc_crps172(pr_cdcooper => pr_cdcooper   -- in craptab.cdcooper%type
                        ,pr_flgresta => 0             -- in pls_integer           --> Flag padrão para utilização de restart
                        ,pr_stprogra => vr_stprogra   --out pls_integer           --> Saída de termino da execução
                        ,pr_infimsol => vr_infimsol   --out pls_integer           --> Saída de termino da solicitação,
                        ,pr_cdcritic => vr_cdcritic   --out crapcri.cdcritic%type --> Codigo da Critica
                        ,pr_dscritic => vr_dscritic); --out varchar2              --> Descricao da Critica

              -- Tratamento de erro
              IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
                --
                -- Atualiza Parâmetro de qual programa/cooperativa ocasionou erro no Debitador Único.
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

              -- Log de ocorrência
              pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                                  ,pr_indexecu => 'Programa '||vr_cdprogra||' Executado.'
                                  ,pr_cdcooper => pr_cdcooper
                                  ,pr_tpexecuc => NULL
                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                  ,pr_idtiplog => 'O');
              --
            --PC_CRPS145 - DEBITO EM CONTA REF POUPANCA PROGRAMADA
            ELSIF Upper(r_processo_horario.cdprocesso) = 'PC_CRPS145' THEN
              vr_cdprogra := 'PC_CRPS145';

              -- Log de ocorrência
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
              pc_crps145(pr_cdcooper => pr_cdcooper   --IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                        ,pr_flgresta => 0             --IN PLS_INTEGER             --> Flag padrão para utilização de restart
                        ,pr_stprogra => vr_stprogra   --OUT PLS_INTEGER            --> Saída de termino da execução
                        ,pr_infimsol => vr_infimsol   --OUT PLS_INTEGER            --> Saída de termino da solicitação
                        ,pr_cdcritic => vr_cdcritic   --OUT crapcri.cdcritic%TYPE  --> Codigo da Critica
                        ,pr_dscritic => vr_dscritic); --OUT VARCHAR2               --> Descricao da Critica

              -- Tratamento de erro
              IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
                --
                -- Atualiza Parâmetro de qual programa/cooperativa ocasionou erro no Debitador Único.
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

              -- Log de ocorrência
              pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                                  ,pr_indexecu => 'Programa '||vr_cdprogra||' Executado.'
                                  ,pr_cdcooper => pr_cdcooper
                                  ,pr_tpexecuc => NULL
                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                  ,pr_idtiplog => 'O');
              --                        
            --PC_CRPS439 - DEBITO DIARIO DO SEGURO
            ELSIF Upper(r_processo_horario.cdprocesso) = 'PC_CRPS439' THEN
              vr_cdprogra := 'PC_CRPS439';

              -- Log de ocorrência
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
              pc_crps439(pr_cdcooper => pr_cdcooper   -- in craptab.cdcooper%type  --> Cooperativa solicitada
                        ,pr_flgresta => 0             -- in pls_integer            --> Flag padrão para utilização de restart
                        ,pr_stprogra => vr_stprogra   --out pls_integer            --> Saída de termino da execução
                        ,pr_infimsol => vr_infimsol   --out pls_integer            --> Saída de termino da solicitação,
                        ,pr_cdcritic => vr_cdcritic   --out crapcri.cdcritic%type  --> Codigo da Critica
                        ,pr_dscritic => vr_dscritic); --out varchar2               --> Codigo da Critica

              -- Tratamento de erro
              IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
                --
                -- Atualiza Parâmetro de qual programa/cooperativa ocasionou erro no Debitador Único.
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

              -- Log de ocorrência
              pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                                  ,pr_indexecu => 'Programa '||vr_cdprogra||' Executado.'
                                  ,pr_cdcooper => pr_cdcooper
                                  ,pr_tpexecuc => NULL
                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                  ,pr_idtiplog => 'O');
              --
            --PC_CRPS654 - TENTATIVA DIARIA DEBITO DE COTAS
            ELSIF Upper(r_processo_horario.cdprocesso) = 'PC_CRPS654' THEN
              vr_cdprogra := 'PC_CRPS654';

              -- Log de ocorrência
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
              pc_crps654 (pr_cdcooper => pr_cdcooper   --IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                         ,pr_cdoperad => '1'           --IN crapope.cdoperad%TYPE   --> Codigo do operador
                         ,pr_flgresta => 0             --IN PLS_INTEGER             --> Flag padrão para utilização de restart
                         ,pr_stprogra => vr_stprogra   --OUT PLS_INTEGER            --> Saída de termino da execução
                         ,pr_infimsol => vr_infimsol   --OUT PLS_INTEGER            --> Saída de termino da solicitação
                         ,pr_cdcritic => vr_cdcritic   --OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                         ,pr_dscritic => vr_dscritic); --OUT VARCHAR2               --> Texto de erro/critica encontrada

              -- Tratamento de erro
              IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
                --
                -- Atualiza Parâmetro de qual programa/cooperativa ocasionou erro no Debitador Único.
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

              -- Log de ocorrência
              pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                                  ,pr_indexecu => 'Programa '||vr_cdprogra||' Executado.'
                                  ,pr_cdcooper => pr_cdcooper
                                  ,pr_tpexecuc => NULL
                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                  ,pr_idtiplog => 'O');
              --
            --PC_CRPS674 - DEBITO DE FATURA - LANCAMENTO DE DEBITO AUTOMATICO - BANCOOB/CABAL
            ELSIF Upper(r_processo_horario.cdprocesso) = 'PC_CRPS674' THEN
              vr_cdprogra := 'PC_CRPS674';

              -- Log de ocorrência
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
              pc_crps674(pr_cdcooper => pr_cdcooper   --IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                        ,pr_flgresta => 0             --IN PLS_INTEGER             --> Flag padrão para utilização de restart
                        ,pr_stprogra => vr_stprogra   --OUT PLS_INTEGER            --> Saída de termino da execução
                        ,pr_infimsol => vr_infimsol   --OUT PLS_INTEGER            --> Saída de termino da solicitação
                        ,pr_cdoperad => '1'           --IN crapnrc.cdoperad%TYPE   --> Código do operador
                        ,pr_cdcritic => vr_cdcritic   --OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                        ,pr_dscritic => vr_dscritic); --OUT VARCHAR2               --> Texto de erro/critica encontrada

              -- Tratamento de erro
              IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
                --
                -- Atualiza Parâmetro de qual programa/cooperativa ocasionou erro no Debitador Único.
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

              -- Log de ocorrência
              pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                                  ,pr_indexecu => 'Programa '||vr_cdprogra||' Executado.'
                                  ,pr_cdcooper => pr_cdcooper
                                  ,pr_tpexecuc => NULL
                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                  ,pr_idtiplog => 'O');
              --
            --PC_CRPS688 - EFETUAR RESGATE DE APLICAÇÕES AGENDADAS PELO INTERNET BANK
            ELSIF Upper(r_processo_horario.cdprocesso) = 'PC_CRPS688' THEN
              vr_cdprogra := 'PC_CRPS688';

              -- Log de ocorrência
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
              pc_crps688(pr_cdcooper => pr_cdcooper   --IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                        ,pr_flgresta => 0             --IN PLS_INTEGER             --> Flag padrão para utilização de restart
                        ,pr_stprogra => vr_stprogra   --OUT PLS_INTEGER            --> Saída de termino da execução
                        ,pr_infimsol => vr_infimsol   --OUT PLS_INTEGER            --> Saída de termino da solicitação
                        ,pr_cdcritic => vr_cdcritic   --OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                        ,pr_dscritic => vr_dscritic); --OUT VARCHAR2               --> Texto de erro/critica encontrada

              -- Tratamento de erro
              IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
                --
                -- Atualiza Parâmetro de qual programa/cooperativa ocasionou erro no Debitador Único.
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

              -- Log de ocorrência
              pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                                  ,pr_indexecu => 'Programa '||vr_cdprogra||' Executado.'
                                  ,pr_cdcooper => pr_cdcooper
                                  ,pr_tpexecuc => NULL
                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                  ,pr_idtiplog => 'O');
              --
            --RCEL0001.PC_PROCES_AGENDAMENTOS_RECARGA - EFETIVAR OS AGENDAMENTOS DE RECARGA DE CELULAR EM TODAS AS COOPERATIVAS
            ELSIF Upper(r_processo_horario.cdprocesso) = 'RCEL0001.PC_PROCES_AGENDAMENTOS_RECARGA' THEN
              vr_cdprogra := 'RCEL0001.PC_PROCES_AGENDAMENTOS_RECARGA';

              -- Log de ocorrência
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
              rcel0001.pc_proces_agendamentos_recarga(pr_cdcooper => pr_cdcooper
                                                     ,pr_nmdatela => 'JOBAGERCEL'
                                                     ,pr_cdcritic => vr_cdcritic
                                                     ,pr_dscritic => vr_dscritic);

              IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
                --
                -- Atualiza Parâmetro de qual programa/cooperativa ocasionou erro no Debitador Único.
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

              -- Log de ocorrência
              pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                                  ,pr_indexecu => 'Programa '||vr_cdprogra||' Executado.'
                                  ,pr_cdcooper => pr_cdcooper
                                  ,pr_tpexecuc => NULL
                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                  ,pr_idtiplog => 'O');
              --
            -- EMPR0009.PC_EFETIVA_LCTO_PENDENTE_JOB - EFETIVAR LANCAMENTO PENDENTE MULTA/JUROS TR CONTRATOS EMP/FINANC POS-FIXADA
            ELSIF Upper(r_processo_horario.cdprocesso) = 'EMPR0009.PC_EFETIVA_LCTO_PENDENTE_JOB' THEN
              vr_cdprogra := 'EMPR0009.PC_EFETIVA_LCTO_PENDENTE_JOB';

              -- Log de ocorrência
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
              empr0009.pc_efetiva_lcto_pendente_job(pr_cdcooper => pr_cdcooper);

              -- Tratamento de erro
              IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
                --
                -- Atualiza Parâmetro de qual programa/cooperativa ocasionou erro no Debitador Único.
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

              -- Log de ocorrência
              pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                                  ,pr_indexecu => 'Programa '||vr_cdprogra||' Executado.'
                                  ,pr_cdcooper => pr_cdcooper
                                  ,pr_tpexecuc => NULL
                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                  ,pr_idtiplog => 'O');
              --
            --PC_CRPS123 - EFETUAR OS LANCAMENTOS AUTOMATICOS NO SISTEMA REF. A DEBITO EM CONTA
            ELSIF Upper(r_processo_horario.cdprocesso) = 'PC_CRPS123' THEN
              vr_cdprogra := 'PC_CRPS123';

              -- Log de ocorrência
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
              pc_crps123(pr_cdcooper => pr_cdcooper   --IN crapcop.cdcooper%TYPE  --> Cooperativa solicitada
                        ,pr_flgresta => 0             --IN PLS_INTEGER            --> Flag padrão para utilização de restart
                        ,pr_stprogra => vr_stprogra   --OUT PLS_INTEGER           --> Saída de termino da execução
                        ,pr_infimsol => vr_infimsol   --OUT PLS_INTEGER           --> Saída de termino da solicitação
                        ,pr_cdcritic => vr_cdcritic   --OUT crapcri.cdcritic%TYPE --> Critica encontrada
                        ,pr_dscritic => vr_dscritic); --OUT VARCHAR2              --> Texto de erro/critica encontrada

              -- Tratamento de erro
              IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
                --
                -- Atualiza Parâmetro de qual programa/cooperativa ocasionou erro no Debitador Único.
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

              -- Log de ocorrência
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

              -- Log de ocorrência
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
                -- Atualiza Parâmetro de qual programa/cooperativa ocasionou erro no Debitador Único.
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

              -- Log de ocorrência
              pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                                  ,pr_indexecu => 'Programa '||vr_cdprogra||' Executado.'
                                  ,pr_cdcooper => pr_cdcooper
                                  ,pr_tpexecuc => NULL
                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                  ,pr_idtiplog => 'O');
              --            
            --PC_CRPS663 - DEBCNS - EFETUAR DEBITOS DE CONSORCIOS PENDENTES
            ELSIF Upper(r_processo_horario.cdprocesso) = 'PC_CRPS663' THEN
              vr_cdprogra := 'PC_CRPS663';

              -- Log de ocorrência
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
              pc_crps663(pr_cdcooper => pr_cdcooper   --IN crapcop.cdcooper%TYPE  --> Codigo Cooperativa
                        ,pr_flgresta => 0             --IN PLS_INTEGER            --> Flag padrão para utilização de restart
                        ,pr_stprogra => vr_stprogra   --OUT PLS_INTEGER           --> Saida de termino da execucao
                        ,pr_infimsol => vr_infimsol   --OUT PLS_INTEGER           --> Saida de termino da solicitacao
                        ,pr_cdcritic => vr_cdcritic   --OUT crapcri.cdcritic%TYPE --> Codigo da Critica
                        ,pr_dscritic => vr_dscritic); --OUT crapcri.dscritic%TYPE --> Descricao da Critica

              -- Tratamento de erro
              IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
                --
                -- Atualiza Parâmetro de qual programa/cooperativa ocasionou erro no Debitador Único.
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

              -- Log de ocorrência
              pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                                  ,pr_indexecu => 'Programa '||vr_cdprogra||' Executado.'
                                  ,pr_cdcooper => pr_cdcooper
                                  ,pr_tpexecuc => NULL
                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                  ,pr_idtiplog => 'O');
              --
            --PC_CRPS268 - DEBITO EM CONTA REFERENTE SEGURO DE VIDA EM GRUPO
            ELSIF Upper(r_processo_horario.cdprocesso) = 'PC_CRPS268' THEN
              vr_cdprogra := 'PC_CRPS268';

              -- Log de ocorrência
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
              pc_crps268(pr_cdcooper => pr_cdcooper   --IN crapcop.cdcooper%TYPE  --> Codigo Cooperativa
                        ,pr_flgresta => 0             --IN PLS_INTEGER            --> Flag padrão para utilização de restart
                        ,pr_stprogra => vr_stprogra   --OUT PLS_INTEGER           --> Saida de termino da execucao
                        ,pr_infimsol => vr_infimsol   --OUT PLS_INTEGER           --> Saida de termino da solicitacao
                        ,pr_cdcritic => vr_cdcritic   --OUT crapcri.cdcritic%TYPE --> Codigo da Critica
                        ,pr_dscritic => vr_dscritic); --OUT crapcri.dscritic%TYPE --> Descricao da Critica

              -- Tratamento de erro
              IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
                --
                -- Atualiza Parâmetro de qual programa/cooperativa ocasionou erro no Debitador Único.
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

              -- Log de ocorrência
              pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                                  ,pr_indexecu => 'Programa '||vr_cdprogra||' Executado.'
                                  ,pr_cdcooper => pr_cdcooper
                                  ,pr_tpexecuc => NULL
                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                  ,pr_idtiplog => 'O');
             --
            --PAGA0003.PC_PROCESSA_AGEND_BANCOOB - DEBITO AGENDADOS DE PAGAMENTO BONCOOB
            ELSIF Upper(r_processo_horario.cdprocesso) = 'PAGA0003.PC_PROCESSA_AGEND_BANCOOB' THEN
              vr_cdprogra := 'PAGA0003.PC_PROCESSA_AGEND_BANCOOB';

              -- Log de ocorrência
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
              paga0003.pc_processa_agend_bancoob(pr_cdcooper => pr_cdcooper   --> Código da cooperativa
                                                ,pr_cdcritic => vr_cdcritic   --> Codigo da critica
                                                ,pr_dscritic => vr_dscritic); --> descrição da critica

              -- Tratamento de erro
              IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
                --
                -- Atualiza Parâmetro de qual programa/cooperativa ocasionou erro no Debitador Único.
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

              -- Log de ocorrência
              pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                                  ,pr_indexecu => 'Programa '||vr_cdprogra||' Executado.'
                                  ,pr_cdcooper => pr_cdcooper
                                  ,pr_tpexecuc => NULL
                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                  ,pr_idtiplog => 'O');
              --

		  -- PC_CRPS735         
            ELSIF Upper(r_processo_horario.cdprocesso) = 'PC_CRPS735' THEN
            vr_cdprogra := 'PC_CRPS735';  
            
            -- Log de ocorrência
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
            CECRED.PC_CRPS735(pr_cdcooper => pr_cdcooper,   -- IN crapcop.cdcooper%TYPE  --> Codigo Cooperativa
                              pr_stprogra => vr_stprogra,   -- OUT PLS_INTEGER           --> Saida de termino da execucao
                              pr_infimsol => vr_infimsol,   -- OUT PLS_INTEGER           --> Saida de termino da solicitacao
                              pr_cdcritic => vr_cdcritic,   -- OUT crapcri.cdcritic%TYPE --> Codigo da Critica                
                              pr_dscritic => vr_dscritic);  -- OUT crapcri.dscritic%TYPE --> Descricao da Critica                             
                                                            
            -- Tratamento de erro                                 
            IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN 
              --
              -- Atualiza Parâmetro de qual programa/cooperativa ocasionou erro no Debitador Único.
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
                                
            -- Log de ocorrência
            pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                                ,pr_indexecu => 'Programa '||vr_cdprogra||' Executado.'
                                  ,pr_cdcooper => pr_cdcooper
                                  ,pr_tpexecuc => NULL
                                  ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                  ,pr_idtiplog => 'O');
              --  
			END IF;
          END IF; -- Fim tratamento para agendamentos do próximo dia
        END LOOP; --Fim Loop Processo/Programa do respectivo horário do debitador

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
        -- Log de ocorrência
        pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                            ,pr_indexecu => 'Salvando Execucao.'
                            ,pr_cdcooper => pr_cdcooper
                            ,pr_tpexecuc => NULL
                            ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                            ,pr_idtiplog => 'O');

        COMMIT;
        --
      END IF; --Processamento Batch (Noturna)

    -- Se for Não Dia Útil
    ELSE
      -- Log de ocorrência
      pc_gera_log_execucao(pr_nmprgexe => vr_cdprogra_raiz
                          ,pr_indexecu => 'Debitador não executado pois não é dia util. Data: '||To_Char(vr_dtdiahoje,'dd/mm/rrrr')||'.'
                          ,pr_cdcooper => pr_cdcooper
                          ,pr_tpexecuc => NULL
                          ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                          ,pr_idtiplog => 'O');
    END IF; --Dia Útil

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

      -- Gravar conteudo do email, controle com substr para não estourar campo texto
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
                                ,pr_flg_remete_coop => 'N' --> Se o envio ser¿ do e-mail da Cooperativa
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

      -- Gravar conteudo do email, controle com substr para não estourar campo texto
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
                                ,pr_flg_remete_coop => 'N' --> Se o envio será do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic);
      COMMIT;
  END pc_executa_debitador_unico;

  PROCEDURE pc_verifica_ctrl_ult_execucao(pr_cdcooper         IN crapcop.cdcooper%TYPE
                                         ,pr_cdprocesso       IN tbgen_debitador_horario_proc.cdprocesso%TYPE
                                         ,pr_flultexe        OUT INTEGER                      --> Retorna se é a ultima execução do procedimento
                                         ,pr_qtdexec         OUT INTEGER                      --> Retorna a quantidade
                                         ,pr_qtdexectot      OUT INTEGER                      --> Retorna a quantidade total do programa
                                         ,pr_temhorproxdia   OUT BOOLEAN                      --> Retorna se existe algum horario para o próximo dia
                                         ,pr_dataagenproxdia OUT DATE                         --> Retorna a data que foi agendado o próximo horario
                                         ,pr_cdcritic        OUT crapcri.cdcritic%TYPE        --> Codigo da critica de erro
                                         ,pr_dscritic        OUT VARCHAR2) IS                 --> Descrição da crítica de erro

    -- Alterações na rotina para executar na cadeia noturna além do debitador
    CURSOR cr_tbgen_param_debit_unico IS
      SELECT tdp.inexec_cadeia_noturna,
             tdp.incontrole_exec_prog
        FROM tbgen_debitador_param  tdp
       WHERE EXISTS (SELECT 1
                       FROM tbgen_debitador_horario_proc  tdhp
                      WHERE tdhp.cdprocesso = tdp.cdprocesso) --Programa deve estar associado a algum horário do Debitador Único
         AND nrprioridade IS NOT NULL --Programa deve ter prioridade informada
         AND upper(tdp.cdprocesso) = upper(pr_cdprocesso);
    rw_tbgen_param_debit_unico cr_tbgen_param_debit_unico%ROWTYPE;

    vr_cdcooper        crapcop.cdcooper%TYPE;
    vr_flultexe        INTEGER;
    vr_qtdexec         INTEGER;
    vr_qtdexectot      INTEGER;
    vr_temhorproxdia   BOOLEAN;
    vr_dataagenproxdia DATE;
    vr_cdcritic        crapcri.cdcritic%TYPE;
    vr_dscritic        VARCHAR2(4000);
    vr_cdacesso        VARCHAR2(50);
    vr_ctrl_max_exec   INTEGER;

  BEGIN

    -- Buscar parâmetro de execução na cadeia noturna além do debitador único.
    -- Valida Programa do cadastro do Debitador
    OPEN cr_tbgen_param_debit_unico;
    FETCH cr_tbgen_param_debit_unico INTO rw_tbgen_param_debit_unico;
    IF cr_tbgen_param_debit_unico%NOTFOUND THEN
      CLOSE cr_tbgen_param_debit_unico;
      pr_cdcritic := 0;
      vr_dscritic := 'Erro ao buscar parâmetro de indicador de execução do programa do debitor na cadeia noturna. Parâmetro não encontrado.';
    ELSE
      CLOSE cr_tbgen_param_debit_unico;
    END IF;

    -- Verifica se tem controle de execução.
    IF rw_tbgen_param_debit_unico.incontrole_exec_prog IN (2,3) AND vr_dscritic IS NULL THEN
      --
      vr_cdcooper := pr_cdcooper;
      --
      --Monta acesso ao Parametro na (crapprm)
      IF upper(pr_cdprocesso) = 'PC_CRPS642' THEN
        vr_cdacesso := 'DEBSIC';
      ELSIF upper(pr_cdprocesso) = 'PC_CRPS642_PRIORI' THEN
        vr_cdacesso := 'DEBSIC_PRIORI';
      ELSIF upper(pr_cdprocesso) = 'PC_CRPS509' THEN
        vr_cdacesso := 'DEBNET';
      ELSIF upper(pr_cdprocesso) = 'PC_CRPS509_PRIORI' THEN
        vr_cdacesso := 'DEBNET_PRIORI';
      ELSIF upper(pr_cdprocesso) = 'RCEL0001.PC_PROCES_AGENDAMENTOS_RECARGA' THEN
        vr_cdacesso := 'JOBAGERCEL';
      ELSIF upper(pr_cdprocesso) = 'PAGA0003.PC_PROCESSA_AGEND_BANCOOB' THEN
        vr_cdacesso := 'DEBBAN';
      ELSIF upper(pr_cdprocesso) = 'TARI0001.PC_DEB_TARIFA_PEND' THEN
        vr_cdacesso :=  'DEBUNITAR';
      ELSE
        vr_cdacesso := upper(SubStr(pr_cdprocesso,4));
      END IF;

      IF vr_cdcooper IS NULL THEN
        --> O debitador não trabalha com a cooperativa, por este motivo estamos buscando a cooperativa com maior execuções para a data atual
        -- Aqui será utilizado como validação na tela do debitador, por este motivo usa a data atual.
        vr_ctrl_max_exec := 0;
        FOR rec_coop IN (SELECT q.cdcooper,
                                to_number(TRIM(substr(q.dsvlrprm,INSTR(q.dsvlrprm,'#')+1))) qtexec
                           FROM crapprm q
                          WHERE upper(q.cdacesso) = 'CTRL_'||vr_cdacesso||'_EXEC'
                            AND to_date(substr(q.dsvlrprm,1,10),'DD/MM/RRRR') = trunc(SYSDATE)) LOOP
          --
          IF rec_coop.qtexec > vr_ctrl_max_exec THEN
            vr_cdcooper      := rec_coop.cdcooper;
            vr_ctrl_max_exec := rec_coop.qtexec;
          END IF;
        END LOOP;
      END IF;

      -- Se a cooperativa for null então não executou ainda para o dia
      -- Deverá permitir alterar na tela do debitador.
      IF vr_cdcooper IS NOT NULL THEN
        --> Verificar/controlar a execução.
        --> Criado nova rotina abaixo interna apenas para consultar de acordo com o novo formato do paramentro
        pc_controle_exec_deb (  pr_cdcooper        => vr_cdcooper         --> Código da coopertiva
                               ,pr_cdtipope        => 'C'                 --> Tipo de operacao I-incrementar e C-Consultar
                               ,pr_dtmvtolt        => trunc(SYSDATE)      --> rw_crapdat.dtmvtolt --> Data do dia da alteração do horario na tela do debitador
                               ,pr_cdprogra        => vr_cdacesso         --> Codigo do programa
                               ,pr_flultexe        => vr_flultexe         --> Retorna se é a ultima execução do procedimento
                               ,pr_qtdexec         => vr_qtdexec          --> Retorna a quantidade
                               ,pr_qtdexectot      => vr_qtdexectot       --> Retorna a quantidade total
                               ,pr_temhorproxdia   => vr_temhorproxdia    --> Retorna se existe horario agendado para proximo dia
                               ,pr_dataagenproxdia => vr_dataagenproxdia  --> Retorna data se existe horario agendado para proximo dia
                               ,pr_cdcritic        => vr_cdcritic         --> Codigo da critica de erro
                               ,pr_dscritic        => vr_dscritic);       --> descrição do erro se ocorrer

        IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
          -- Se foi retornado apenas codigo
          IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
            -- Buscar a descricao
            vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
          END IF;
          -- Devolvemos codigo e critica encontradas
          pr_cdcritic := NVL(vr_cdcritic,0);
          pr_dscritic := vr_dscritic;
        ELSE
          pr_flultexe        := nvl(vr_flultexe,0); -- se for nulo não é a última execução
          pr_qtdexec         := nvl(vr_qtdexec,0);  -- se for nulo não executou nenhuma vez ainda no dia
          pr_qtdexectot      := nvl(vr_qtdexectot,999); -- se for nulo ainda não tem definido a quantidade total
          pr_temhorproxdia   := nvl(vr_temhorproxdia, FALSE); -- se for nulo não tem data agendada para o próximo dia
          pr_dataagenproxdia := vr_dataagenproxdia;
        END IF;
        --
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Erro geral ao validar controle de última execução. '||SQLERRM;
  END pc_verifica_ctrl_ult_execucao;

  /* Atualiza parametro de quantidade de execuções para marcar com uma
     string diferenciada permitindo identificar se existe horarios novos para o próximo dia de referência */
  PROCEDURE pc_atlz_hora_proces_prox_dia(pr_dhprocessamento IN tbgen_debitador_horario.dhprocessamento%TYPE
                                        ,pr_cdprocesso      IN tbgen_debitador_horario_proc.cdprocesso%TYPE
                                        ,pr_ds_erro        OUT crapcri.dscritic%TYPE) IS

    CURSOR cr_crapprm (--pr_cdcooper crapprm.cdcooper%TYPE,
                       pr_cdacesso crapprm.cdacesso%TYPE) IS
      SELECT to_number(TRIM(substr(prm.dsvlrprm,1,decode(instr(prm.dsvlrprm,'#'),0,length(prm.dsvlrprm),instr(prm.dsvlrprm,'#')-1)))) dsvlrprm,
             prm.cdacesso,
             prm.rowid
        FROM crapprm prm
       WHERE prm.nmsistem = 'CRED'
         --AND prm.cdcooper IN (pr_cdcooper,0)
         AND prm.cdacesso = pr_cdacesso
       ORDER BY prm.cdcooper DESC;
    rw_crapprm_qtd  cr_crapprm%ROWTYPE;

    -- Alterações na rotina para executar na cadeia noturna além do debitador
    CURSOR cr_tbgen_param_debit_unico IS
      SELECT tdp.inexec_cadeia_noturna,
             tdp.incontrole_exec_prog
        FROM tbgen_debitador_param  tdp
       WHERE EXISTS (SELECT 1
                       FROM tbgen_debitador_horario_proc  tdhp
                      WHERE tdhp.cdprocesso = tdp.cdprocesso) --Programa deve estar associado a algum horário do Debitador Único
         AND nrprioridade IS NOT NULL --Programa deve ter prioridade informada
         AND upper(tdp.cdprocesso) = upper(pr_cdprocesso);
    rw_tbgen_param_debit_unico cr_tbgen_param_debit_unico%ROWTYPE;

    vr_erro            EXCEPTION;
    vr_ds_erro         crapcri.dscritic%TYPE;
    vr_cdacesso        VARCHAR2(50);
    vr_qtdexectot_tela INTEGER;

  BEGIN

    --> Buscar a quantidade de horarios que tem na tela
    BEGIN
      SELECT COUNT(*)
        INTO vr_qtdexectot_tela
        FROM tbgen_debitador_horario_proc  tdhp
            ,tbgen_debitador_horario       tdh
       WHERE tdhp.idhora_processamento = tdh.idhora_processamento
         AND upper(tdhp.cdprocesso)    = upper(pr_cdprocesso);
    EXCEPTION
      WHEN OTHERS THEN
        vr_ds_erro := 'Erro ao buscar quantidade total de execuções existentes na tela do debitador para o programa '||upper(pr_cdprocesso);
        RAISE vr_erro;
    END;

    -- Buscar parâmetro de execução na cadeia noturna além do debitador único.
    -- Valida Programa do cadastro do Debitador
    OPEN cr_tbgen_param_debit_unico;
    FETCH cr_tbgen_param_debit_unico INTO rw_tbgen_param_debit_unico;
    IF cr_tbgen_param_debit_unico%NOTFOUND THEN
      CLOSE cr_tbgen_param_debit_unico;
      vr_ds_erro := 'Erro ao buscar parâmetro de indicador de execução do programa do debitador na cadeia noturna. Parâmetro não encontrado.';
      RAISE vr_erro;
    ELSE
      CLOSE cr_tbgen_param_debit_unico;
    END IF;

    IF NVL(rw_tbgen_param_debit_unico.inexec_cadeia_noturna,'N') = 'S' THEN
      vr_qtdexectot_tela := vr_qtdexectot_tela + 1;
    END IF;

    -- Verifica se tem controle de execução.
    IF rw_tbgen_param_debit_unico.incontrole_exec_prog IN (2,3) THEN

      --Monta acesso ao Parametro na (crapprm)
      IF upper(pr_cdprocesso) = 'PC_CRPS642' THEN
        vr_cdacesso := 'DEBSIC';
      ELSIF upper(pr_cdprocesso) = 'PC_CRPS642_PRIORI' THEN
        vr_cdacesso := 'DEBSIC_PRIORI';
      ELSIF upper(pr_cdprocesso) = 'PC_CRPS509' THEN
        vr_cdacesso := 'DEBNET';
      ELSIF upper(pr_cdprocesso) = 'PC_CRPS509_PRIORI' THEN
        vr_cdacesso := 'DEBNET_PRIORI';
      ELSIF upper(pr_cdprocesso) = 'RCEL0001.PC_PROCES_AGENDAMENTOS_RECARGA' THEN
        vr_cdacesso := 'JOBAGERCEL';
      ELSIF upper(pr_cdprocesso) = 'PAGA0003.PC_PROCESSA_AGEND_BANCOOB' THEN
        vr_cdacesso := 'DEBBAN';
      ELSIF upper(pr_cdprocesso) = 'TARI0001.PC_DEB_TARIFA_PEND' THEN
        vr_cdacesso := 'DEBUNITAR';
      ELSE
        vr_cdacesso := upper(SubStr(pr_cdprocesso,4));
      END IF;

      FOR rec_crapprm IN cr_crapprm ('QTD_EXEC_'||vr_cdacesso) LOOP
        --
        BEGIN
          UPDATE crapprm c
             SET c.dsvlrprm = to_char(rec_crapprm.dsvlrprm)||'#'||to_char(TRUNC(SYSDATE)+1,'DD/MM/RRRR')||'#'||to_char(vr_qtdexectot_tela)
           WHERE ROWID = rec_crapprm.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_ds_erro      := 'Erro ao atualizar programação de horário para o dia seguinte. '||SubStr(SQLERRM,1,255);
            RAISE vr_erro;
        END;
        --
      END LOOP;
    END IF;
  EXCEPTION
    WHEN vr_erro THEN
      pr_ds_erro := vr_ds_erro;
    WHEN OTHERS THEN
      pr_ds_erro := 'Erro geral ao atualizar programação de horário para o dia seguinte. '||SubStr(SQLERRM,1,255);
  END pc_atlz_hora_proces_prox_dia;

  /* Procedimento para verificar/controlar a execução pelo debitador
     Rotina será utilizada apenas para consulta*/
  PROCEDURE pc_controle_exec_deb ( pr_cdcooper         IN crapcop.cdcooper%TYPE        --> Código da coopertiva
                                  ,pr_cdtipope         IN VARCHAR2                     --> Tipo de operacao I-incrementar, C-Consultar e V-Validar
                                  ,pr_dtmvtolt         IN DATE                         --> Data do movimento
                                  ,pr_cdprogra         IN crapprg.cdprogra%TYPE        --> Codigo do programa
                                  ,pr_flultexe        OUT INTEGER                      --> Retorna se é a ultima execução do procedimento
                                  ,pr_qtdexec         OUT INTEGER                      --> Retorna a quantidade
                                  ,pr_qtdexectot      OUT INTEGER                      --> Retorna a quantidade total
                                  ,pr_temhorproxdia   OUT BOOLEAN                      --> Retorna se existe algum horario para o próximo dia
                                  ,pr_dataagenproxdia OUT DATE                         --> Retonar data se existe agendamento para o dia posterior
                                  ,pr_cdcritic        OUT crapcri.cdcritic%TYPE        --> Codigo da critica de erro
                                  ,pr_dscritic        OUT VARCHAR2) IS                 --> descrição do erro se ocorrer
    -------------> CURSOR <--------------
    CURSOR cr_crapprm (pr_cdcooper crapprm.cdcooper%TYPE,
                       pr_cdacesso crapprm.cdacesso%TYPE) IS
      SELECT prm.dsvlrprm,
             prm.cdacesso,
             prm.rowid
        FROM crapprm prm
       WHERE prm.nmsistem = 'CRED'
         AND prm.cdcooper IN (pr_cdcooper,0)
         AND prm.cdacesso = pr_cdacesso
       ORDER BY prm.cdcooper DESC;
    rw_crapprm_ctrl cr_crapprm%ROWTYPE;
    rw_crapprm_qtd  cr_crapprm%ROWTYPE;

    ------------- Variaveis ---------------
    vr_exc_erro  EXCEPTION;
    vr_dscritic  VARCHAR2(1000);

    vr_cdprogra  VARCHAR2(50);--crapprg.cdprogra%TYPE;
    vr_tbdados   gene0002.typ_split;
    vr_dtctlexc  DATE   := NULL;
    vr_qtctlexc  INTEGER := 0;
    vr_qtdexec   INTEGER := 0;


  BEGIN
    --
    vr_cdprogra := pr_cdprogra;

    --> buscar parametro de controle de execução
    OPEN cr_crapprm (pr_cdcooper => pr_cdcooper,
                     pr_cdacesso => 'CTRL_'||upper(vr_cdprogra)||'_EXEC');
    FETCH cr_crapprm INTO rw_crapprm_ctrl;
    IF cr_crapprm%NOTFOUND THEN
      vr_dscritic := 'Parametro de sistema '||'CTRL_'||vr_cdprogra||'_EXEC não encontrado.';
      CLOSE cr_crapprm;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapprm;

    -- tratar dados do parametro
    vr_tbdados := gene0002.fn_quebra_string(pr_string  => rw_crapprm_ctrl.dsvlrprm,
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

    --> buscar parametro de qtd de execução
    OPEN cr_crapprm (pr_cdcooper => pr_cdcooper,
                     pr_cdacesso => 'QTD_EXEC_'||upper(vr_cdprogra));
    FETCH cr_crapprm INTO rw_crapprm_qtd;
    IF cr_crapprm%NOTFOUND THEN
      vr_dscritic := 'Parametro de sistema '||'QTD_EXEC_'||upper(vr_cdprogra)||' não encontrado.';
      CLOSE cr_crapprm;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapprm;

    --  Se tipo de operação for Incrementar
    IF pr_cdtipope = 'I' THEN
      NULL;
    ELSIF pr_cdtipope = 'V' THEN
      NULL;
    ELSE --> Consulta
      vr_qtdexec := vr_qtctlexc;
    END IF;

    --> Verifica se no parametro tem algum horario para o proximo dia
    IF NVL(INSTR(rw_crapprm_qtd.dsvlrprm,'#'),0) > 0 THEN
      pr_temhorproxdia   := TRUE;
      pr_dataagenproxdia := to_date(TRIM(substr(rw_crapprm_qtd.dsvlrprm, INSTR(rw_crapprm_qtd.dsvlrprm,'#')+1, 10)),'DD/MM/RRRR');
    ELSE
      pr_temhorproxdia := FALSE;
    END IF;

    --> Não utilizei a função de quebra de string, pois pode ser que não tenha o #
    BEGIN
      SELECT to_number(TRIM(substr(rw_crapprm_qtd.dsvlrprm,1,decode(instr(rw_crapprm_qtd.dsvlrprm,'#'),0,length(rw_crapprm_qtd.dsvlrprm),instr(rw_crapprm_qtd.dsvlrprm,'#')-1))))
        INTO rw_crapprm_qtd.dsvlrprm
        FROM dual;
    END;

    pr_qtdexectot := rw_crapprm_qtd.dsvlrprm;

    --> Verificar se é a ultima execucao
    IF vr_qtdexec >= rw_crapprm_qtd.dsvlrprm THEN
      pr_flultexe := 1;
    ELSE
      pr_flultexe := 0;
    END IF;

    pr_qtdexec := vr_qtdexec;

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_dscritic := vr_dscritic;
  END pc_controle_exec_deb;

END gen_debitador_unico;
/
