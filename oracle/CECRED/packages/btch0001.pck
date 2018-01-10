CREATE OR REPLACE PACKAGE CECRED.btch0001 AS

  ---------------------------------------------------------------------------------------------------------------
  --
  -- Programa : BTCH0001
  --  Sistema : Processos Batch
  --  Sigla   : BTCH
  --  Autor   : Marcos E. Martini - Supero
  --  Data    : Novembro/2012.                   Ultima atualizacao: 01/11/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas do processamento batch
  --
  -- Alterações:
  --             03/07/2017 - Colocada descrição da mensagem de erro no padrão
  --                        - incluido tratamento de excptions nos cursores para melhorar os erros
  --                          (Belli - Envolti - Chamado 667957)
  --
  --             01/11/2017 - Alterada procedure pc_gera_log_batch incluindo o parâmetro de codigo da mensagem
  --                          Origem da informação da tabela crapcri e atributo cdcritic
  --                          Passar o parâmetro de codigo da mensagem para procedure pc_log_programa
  --                          (Belli - Envolti - Chamado 786752)
  --                         
  ---------------------------------------------------------------------------------------------------------------

  /* Cursor genérico de calendário */
  CURSOR cr_crapdat(pr_cdcooper IN craptab.cdcooper%TYPE) IS
    SELECT dat.dtmvtolt
          ,dat.dtmvtopr
          ,dat.dtmvtoan
          ,dat.inproces
          ,dat.qtdiaute
          ,dat.cdprgant
          ,dat.dtmvtocd
          ,trunc(dat.dtmvtolt,'mm')               dtinimes -- Pri. Dia Mes Corr.
          ,trunc(Add_Months(dat.dtmvtolt,1),'mm') dtpridms -- Pri. Dia mes Seguinte
          ,last_day(add_months(dat.dtmvtolt,-1))  dtultdma -- Ult. Dia Mes Ant.
          ,last_day(dat.dtmvtolt)                 dtultdia -- Utl. Dia Mes Corr.
          ,rowid
      FROM crapdat dat
     WHERE dat.cdcooper = pr_cdcooper;
  rw_crapdat cr_crapdat%ROWTYPE;

  /* Cursor genérico de parametrização */
  CURSOR cr_craptab(pr_cdcooper IN craptab.cdcooper%TYPE           --> Cooperativa
                   ,pr_nmsistem IN craptab.nmsistem%TYPE           --> Nome sistema
                   ,pr_tptabela IN craptab.tptabela%TYPE           --> Tipo de tabela
                   ,pr_cdempres IN craptab.cdempres%TYPE           --> Código empresa
                   ,pr_cdacesso IN craptab.cdacesso%TYPE           --> Código de acesso
                   ,pr_tpregist IN craptab.tpregist%TYPE           --> Tipo de registro
                   ,pr_dstextab IN craptab.dstextab%TYPE) IS       --> Texto de parâmetros
    SELECT tab.dstextab
          ,tab.rowid
    FROM craptab tab
    WHERE tab.cdcooper = pr_cdcooper
      AND upper(tab.nmsistem) = nvl(upper(pr_nmsistem), upper(tab.nmsistem))
      AND upper(tab.tptabela) = nvl(upper(pr_tptabela), upper(tab.tptabela))
      AND tab.cdempres = nvl(pr_cdempres, tab.cdempres)
      AND upper(tab.cdacesso) = nvl(upper(pr_cdacesso), upper(tab.cdacesso))
      AND tab.tpregist = nvl(pr_tpregist, tab.tpregist)
      AND SUBSTR(tab.dstextab,1,7) = nvl(pr_dstextab, SUBSTR(tab.dstextab,1,7));
  rw_craptab cr_craptab%ROWTYPE;

  /* Tipo para armazenamento de informações de timestamp
     para auxilio de contagem de performance */
  TYPE typ_timestamp IS
    RECORD(vr_timinici TIMESTAMP
          ,vr_tottempo NUMBER(15,6)
          ,vr_qtdconta NUMBER(10)
          ,vr_dsauxili VARCHAR2(200));
  TYPE typ_tab_timestamp IS
    TABLE OF typ_timestamp
    INDEX BY BINARY_INTEGER;

  /* Função para retornar se o processo noturno esta executando */
  FUNCTION fn_procnot_exec(pr_cdcooper IN crapcop.cdcooper%TYPE) RETURN BOOLEAN;

  /* Função para retornar se o processo diurno esta executando */
  FUNCTION fn_procdia_exec(pr_cdcooper IN crapcop.cdcooper%TYPE) RETURN BOOLEAN;

  /* Função para retornar se os relatórios do processo estão sendo gerados */
  FUNCTION fn_procrel_exec(pr_cdcooper IN crapcop.cdcooper%TYPE) RETURN BOOLEAN;

  /* Função para retornar se todas as cooperativas estão online (sem processos rodando) */
  FUNCTION fn_cooperativas_online RETURN BOOLEAN;

  /* Procedimento para criar o arquivo de controle do início de geração dos relatórios da cadeia */
  PROCEDURE pc_atuali_procrel(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
                             ,pr_flgsitua IN VARCHAR2              --> Situação (E-Execução, O-OK)
                             ,pr_des_erro OUT VARCHAR2);           --> Saída de erro

  /* Incluir log de execução. */
  PROCEDURE pc_gera_log_batch(pr_cdcooper     IN crapcop.cdcooper%TYPE     --> Cooperativa
                             ,pr_ind_tipo_log IN NUMBER                    --> Nivel criticidade do log
                             ,pr_des_log      IN VARCHAR2                  --> Descrição do log em si
                             ,pr_nmarqlog     IN VARCHAR2 DEFAULT NULL     --> Nome para gravação de log em arquivo específico
                             ,pr_flnovlog     IN VARCHAR2 DEFAULT 'N'      --> Flag S/N para criar um arquivo novo
                             ,pr_flfinmsg     IN VARCHAR2 DEFAULT 'S'      --> Flag S/N  para informar ao fim da msg [PL/SQL]
                             ,pr_dsdirlog     IN VARCHAR2 DEFAULT NULL     --> Diretorio onde será gerado o log
                             ,pr_dstiplog     IN VARCHAR2 DEFAULT 'O'      --> Tipo do log: I - início; F - fim; O || E - ocorrênci
                             ,pr_cdprograma   IN VARCHAR2 DEFAULT NULL     --> Programa/job
                             ,pr_tpexecucao    IN tbgen_prglog.tpexecucao%TYPE DEFAULT 1 -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                             ,pr_cdcriticidade IN tbgen_prglog_ocorrencia.cdcriticidade%TYPE DEFAULT 0 -- Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                             ,pr_flgsucesso    IN tbgen_prglog.flgsucesso%TYPE DEFAULT 1 -- Indicador de sucesso da execução
                             ,pr_cdmensagem    IN tbgen_prglog_ocorrencia.cdmensagem%TYPE DEFAULT 0 -- Codigo da mensagem ou critica (Pode ser crapcri.cdcritic)
                             );

  /* Controlar geração de log de execução dos jobs */
  PROCEDURE pc_log_exec_job(pr_cdcooper     IN crapcop.cdcooper%TYPE     --> Cooperativa
                           ,pr_cdprogra     IN crapprg.cdprogra%TYPE     --> Codigo do programa
                           ,pr_nomdojob     IN VARCHAR2                  --> Nome do job
                           ,pr_dstiplog     IN VARCHAR2                  --> Tipo de log(I-inicio,F-Fim,E-Erro)
                           ,pr_dscritic     IN VARCHAR2                  --> Critica a ser apresentada em caso de erro
                           ,pr_nmarqlog     IN VARCHAR2 DEFAULT NULL     --> Nome para gravação de log em arquivo específico
                           ,pr_flgerlog IN OUT BOOLEAN);                 --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim
                           
                           
  /* Rotina de validacao da antiga iniprg.p */
  PROCEDURE pc_valida_iniprg (pr_cdcooper IN crapdat.cdcooper%TYPE --> Cooperativa
                             ,pr_flgbatch IN PLS_INTEGER           --> Indicador de execução em batch
                             ,pr_cdprogra IN crapprg.cdprogra%TYPE --> Programa que está executando
                             ,pr_infimsol OUT PLS_INTEGER          --> Inidicador de termino de solicitação
                             ,pr_cdcritic OUT PLS_INTEGER);        --> Código do Retorno do Erro

  /* Tratamento e retorno de valores de restart */
  PROCEDURE pc_valida_restart(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                             ,pr_cdprogra  IN crapprg.cdprogra%TYPE --> Código do programa
                             ,pr_flgresta  IN PLS_INTEGER           --> Indicador de restart
                             ,pr_nrctares OUT crapass.nrdconta%TYPE --> Número da conta de restart
                             ,pr_dsrestar OUT VARCHAR2              --> String genérica com informações para restart
                             ,pr_inrestar OUT INTEGER               --> Indicador de Restart
                             ,pr_cdcritic OUT PLS_INTEGER           --> Código de critica
                             ,pr_des_erro OUT VARCHAR2);            --> Saída de erro

  /* Eliminação dos registros de restart */
  PROCEDURE pc_elimina_restart(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                              ,pr_cdprogra  IN crapprg.cdprogra%TYPE --> Código do programa
                              ,pr_flgresta  IN PLS_INTEGER           --> Indicador de restart
                              ,pr_des_erro OUT VARCHAR2);            --> Saída de erro

  /* Rotina de validacao da antiga fimprg.p */
  PROCEDURE pc_valida_fimprg (pr_cdcooper IN crapdat.cdcooper%TYPE  --> Cooperativa
                             ,pr_cdprogra IN crapprg.cdprogra%TYPE  --> Programa que está executando
                             ,pr_infimsol IN OUT PLS_INTEGER        --> Indicador de fim de solicitação da cadeia
                             ,pr_stprogra IN OUT PLS_INTEGER);      --> Indicador de situação OK de execução);         --> Descrição do Retorno do Erro

  /* Função para calculo de diferença de tempos de execução com timestamp */
  FUNCTION fn_dif_timestamp_segundos(pr_time_ini IN TIMESTAMP
                                    ,pr_time_fim IN TIMESTAMP) RETURN NUMBER;

   /* Rotina para ativação de ponto de análise de performance */
  PROCEDURE pc_inicia_captura_perf(pr_nrseqsol IN OUT crappfm.nrseqsol%TYPE              --> Id da análise (na primeira vez busca e retorna)
                                  ,pr_cdcooper IN crappfm.cdcooper%TYPE                  --> Cooperativa conectada
                                  ,pr_cdprogra IN crapprg.cdprogra%TYPE                  --> Programa que está executando
                                  ,pr_cdoperad IN crappfm.cdoperad%TYPE DEFAULT 'BATCH'  --> Operador do processo em execução
                                  ,pr_dschvpfm IN crappfm.dschvpfm%TYPE                  --> Chave de acesso da análise
                                  ,pr_dsparame IN crappfm.dsparame%TYPE DEFAULT ' ');   --> Parametros auxiliares para análise


  /* Rotina para encerramento de ponto de análise de performance */
  PROCEDURE pc_encerra_captura_perf(pr_nrseqsol IN crappfm.nrseqsol%TYPE                  --> Id da análise (na primeira vez busca e retorna)
                                   ,pr_dschvpfm IN crappfm.dschvpfm%TYPE                  --> Chave de acesso da análise
                                   ,pr_dsparame IN crappfm.dsparame%TYPE DEFAULT ' ');   --> Parametros auxiliares para análise

  PROCEDURE pc_log_internal_exception(pr_cdcooper IN crapcop.cdcooper%TYPE DEFAULT 3); --> Cooperativa

END btch0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.btch0001 AS
/*
  ------------------------------------------------------------------------------------------------------------
  --
  -- Programa : BTCH0001
  --  Sistema : Processos Batch
  --  Sigla   : BTCH
  --  Autor   : Marcos E. Martini - Supero
  --  Data    : Novembro/2012.                   Ultima atualizacao: 01/11/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo  : Agrupar rotinas do processamento batch
  --
  -- 11/01/2017 - #551199 Criada a função fn_cooperativas_online para retornar se todas as cooperativas 
  --              estão online (Carlos)
  --              
  -- 12/01/2017 - #551192 Alterada a mensagem "PROGRAMA COM ERRO" para "PROGRAMA COM ALERTA" na rotina 
  --              pc_log_exec_job quando o tipo de log não for de início, fim ou erro e for informada a
  --              crítica (Carlos)
  --  
  -- 16/02/2017 - #601794 Inclusão do log em tabela pelo procedimento cecred.pc_log_programa no procedimento
  --              pc_log_exec_job para que seja possível desativar o log dos jobs em arquivo (Carlos)
  
  10/04/2017 - No procedimento pc_log_exec_job, retirado o cursor de cálculo de tempo de execução do job.
               Inclusão do parâmetro pr_nmarlog na chamada da rotina pc_log_programa e melhoria na
               extração do CDPROGRAMA da mensagem (Carlos)
  
  18/05/2017 - No procedimento pc_gera_log_batch, simplificada a lógica de extração do nome do programa da
               mensagem enviada. Se não encontrar a seta '-->' o programa ficará vazio; Mensagem irá
               acrescida de module e action (read_module) para melhorar o rastreio do mesmo (Carlos)  
  
  03/07/2017 - Colocada descrição da mensagem de erro no padrão 
             - incluido tratamento de excptions nos cursores para melhorar os erros
               (Belli - Envolti - Chamado 667957)
  
  17/08/2017 - #738346 Alteração da rotina pc_log_exec_job para gravar no proc_batch apenas os erros.
               Os log s de Início e Fim de execução irão apenas para as tabelas tbgen_prglog e 
               tbgen_prglog_ocorrencia quando o arquivo for proc_batch ou proc_message (Carlos)
  
  01/11/2017 - Alterada procedure pc_gera_log_batch incluindo o parâmetro de codigo da mensagem
               Origem da informação da tabela crapcri e atributo cdcritic
               Passar o parâmetro de codigo da mensagem para procedure pc_log_programa
               (Belli - Envolti - Chamado 786752)

  ------------------------------------------------------------------------------------------------------------ */

  -- Tratamento de erros
  vr_exc_erro exception;
  vr_des_erro varchar2(4000);

  -- Selecionar informacoes dos programas
  CURSOR cr_crapprg (pr_cdcooper IN crapprg.cdcooper%TYPE
                    ,pr_cdprogra IN crapprg.cdprogra%TYPE) IS
    SELECT crapprg.inctrprg
          ,crapprg.nrsolici
          ,crapprg.rowid
      FROM crapprg crapprg
     WHERE crapprg.cdcooper = pr_cdcooper
       AND crapprg.cdprogra = pr_cdprogra;
  rw_crapprg cr_crapprg%ROWTYPE;

  --Selecionar informacoes das solicitacoes
  CURSOR cr_crapsol(pr_cdcooper IN crapsol.cdcooper%TYPE
                   ,pr_nrsolici IN crapsol.nrsolici%TYPE) IS
    SELECT crapsol.insitsol
          ,crapsol.rowid
      FROM crapsol crapsol
     WHERE crapsol.cdcooper = pr_cdcooper
       AND crapsol.nrsolici = pr_nrsolici;
  rw_crapsol cr_crapsol%ROWTYPE;

  /* Função para retornar se o processo noturno esta executando */
  FUNCTION fn_procnot_exec(pr_cdcooper IN crapcop.cdcooper%TYPE) RETURN BOOLEAN IS
  BEGIN
    -- ..........................................................................

    -- Programa: fn_procnot_exec
    -- Sistema : Conta-Corrente - Cooperativa de Credito
    -- Sigla   : CRED
    -- Autor   : Marcos (Supero)
    -- Data    : Outubro/2013.                     Ultima atualizacao: 18/12/2013

    -- Dados referentes ao programa:

    -- Frequencia: Diario (Batch - Background)
    -- Objetivo  : A função tem o intúito de retornar se o processo noturno está em execuçao.
    --             Isto é encontrado através dos parâmetros de sistema ARQ_PROCNOT_OK e ARQ_PROCNOT_EXEC
    --             que possuem os caminhos dos arquivos que indicam a execução e fim do processo.
    --             A princípio temos os seguintes valores:
    --             ARQ_PROCNOT_EXEC => /usr/coop/COOPERATIVA/controles/Proc_Noturno.Exec
    --             ARQ_PROCNOT_OK => /usr/coop/COOPERATIVA/controles/crps359.ok
    -- Alterações
    --
    -- 18/12/2013 - Alterada a rotina para usar o novo arquivo de controle (crps000.ok)
    --              e também testar a não existencia dele para definir ser o processo
    --              está em execução (Marcos-Supero)
    -- .............................................................................
    DECLARE
      -- Armazenamento do caminho completo dos arquivos
      vr_dsarq      VARCHAR2(300);
      vr_dsarq_exec VARCHAR2(300);
      vr_dsarq_ok   VARCHAR2(300);
    BEGIN
      -- Primeiro buscar o diretório padrão da Cooperativa logada
      vr_dsarq := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                       ,pr_cdcooper => pr_cdcooper);
      -- Concatenar os parâmetros de sistema que indicam o caminho e o arquivos
      vr_dsarq_exec := vr_dsarq || '/' || NVL(gene0001.fn_param_sistema('CRED',pr_cdcooper,'ARQ_PROCNOT_EXEC'),'controles/Proc_Noturno.Exec');
      vr_dsarq_ok   := vr_dsarq || '/' || NVL(gene0001.fn_param_sistema('CRED',pr_cdcooper,'ARQ_PROCNOT_OK'),'controles/crps359.ok');
      -- A cadeia está em execução se existir o arquivo .Exec e não existir o arquivo .OK
      RETURN gene0001.fn_exis_arquivo(vr_dsarq_exec) AND NOT gene0001.fn_exis_arquivo(vr_dsarq_ok);
    END;
  END fn_procnot_exec;

  /* Função para retornar se o processo diurno esta executando */
  FUNCTION fn_procdia_exec(pr_cdcooper IN crapcop.cdcooper%TYPE) RETURN BOOLEAN IS
  BEGIN
    -- ..........................................................................

    -- Programa: fn_procdia_exec
    -- Sistema : Conta-Corrente - Cooperativa de Credito
    -- Sigla   : CRED
    -- Autor   : Marcos (Supero)
    -- Data    : Outubro/2013.                     Ultima atualizacao: 18/12/2013

    -- Dados referentes ao programa:

    -- Frequencia: Diario (Batch - Background)
    -- Objetivo  : A função tem o intúito de retornar se o processo diário está em execuçao.
    --             Isto é encontrado através dos parâmetros de sistema ARQ_PROCDIA_OK e ARQ_PROCDIA_EXEC
    --             que possuem os caminhos dos arquivos que indicam a execução e fim do processo.
    --             A princípio temos os seguintes valores:
    --             ARQ_PROCDIA_EXEC => /usr/coop/COOPERATIVA/controles/Proc_Diario.Exec
    --             ARQ_PROCDIA_OK => /usr/coop/COOPERATIVA/controles/crps000.ok
    -- Alterações:
    --
    -- 18/12/2013 - Alterada a rotina para usar o novo arquivo de controle (crps000.ok)
    --              e também testar a não existencia dele para definir ser o processo
    --              está em execução (Marcos-Supero)
    -- .............................................................................
    DECLARE
      -- Armazenamento do caminho completo do arquivo
      vr_dsarq      VARCHAR2(300);
      vr_dsarq_exec VARCHAR2(300);
      vr_dsarq_ok   VARCHAR2(300);
    BEGIN
      -- Primeiro buscar o diretório padrão da Cooperativa logada
      vr_dsarq := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                       ,pr_cdcooper => pr_cdcooper);
      -- Concatenar os parâmetros de sistema que indicam o caminho e o arquivos
      vr_dsarq_exec := vr_dsarq || '/' || NVL(gene0001.fn_param_sistema('CRED',pr_cdcooper,'ARQ_PROCDIA_EXEC'),'controles/Proc_Diario.Exec');
      vr_dsarq_ok   := vr_dsarq || '/' || NVL(gene0001.fn_param_sistema('CRED',pr_cdcooper,'ARQ_PROCDIA_OK'),'controles/crps000.ok');
      -- A cadeia está em execução se existir o arquivo .Exec e não existir o arquivo .OK
      RETURN gene0001.fn_exis_arquivo(vr_dsarq_exec) AND NOT gene0001.fn_exis_arquivo(vr_dsarq_ok);
    END;
  END fn_procdia_exec;

  /* Função para retornar se os relatórios do processo estão sendo gerados */
  FUNCTION fn_procrel_exec(pr_cdcooper IN crapcop.cdcooper%TYPE) RETURN BOOLEAN IS
  BEGIN
    -- ..........................................................................

    -- Programa: fn_procrel_exec
    -- Sistema : Conta-Corrente - Cooperativa de Credito
    -- Sigla   : CRED
    -- Autor   : Marcos (Supero)
    -- Data    : Outubro/2013.                     Ultima atualizacao:

    -- Dados referentes ao programa:

    -- Frequencia: Diario (Batch - Background)
    -- Objetivo  : A função tem o intúito de retornar se houve o início do processo de
    --             geração dos relatórios da cadeia.
    --             Isto é encontrado através do parâmetro de sistema ARQ_PROCREL_EXEC
    --             que possue o caminho do arquivo que indica o início do processo.
    --             A princípio o mesmo encontra-se em:
    --             /usr/coop/COOPERATIVA/controles/Proc_Relato.Exec
    -- .............................................................................
    DECLARE
      -- Armazenamento da raiz da Coop
      vr_dsroot  VARCHAR2(300);
      -- Armazenamento dos caminhos completos do arquivos Exec e OK
      vr_dsarqex VARCHAR2(300);
      vr_dsarqok VARCHAR2(300);
    BEGIN
      -- Primeiro buscar o diretório padrão da Cooperativa logada
      vr_dsroot := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                        ,pr_cdcooper => pr_cdcooper);
      -- Concatenar os parâmetros de sistema que indicam o SubDir e os nomes arquivos .Exec e .Ok
      vr_dsarqex := vr_dsroot || '/' || NVL(gene0001.fn_param_sistema('CRED',pr_cdcooper,'ARQ_PROCREL_EXEC'),'controles/Proc_Relato.Exec');
      vr_dsarqok := vr_dsroot || '/' || NVL(gene0001.fn_param_sistema('CRED',pr_cdcooper,'ARQ_PROCREL_OK'),'controles/Proc_Relato.Ok');
      -- Se existir o arquivo .Exec
      IF gene0001.fn_exis_arquivo(vr_dsarqex) THEN
        -- Já retornar OK
        RETURN true;
      ELSE
        -- Se não existir o arquivo .OK
        IF NOT gene0001.fn_exis_arquivo(vr_dsarqok) THEN
          -- Tratar situação problemática onde não haja nenhum dos arquivos
          -- e então devemos criar o arquivo .Exec
          btch0001.pc_atuali_procrel(pr_cdcooper => pr_cdcooper   --> Coop conectada
                                    ,pr_flgsitua => 'E'           --> Em execução
                                    ,pr_des_erro => vr_des_erro); --> Saída de erro
          -- Se houve erro
          IF vr_des_erro IS NOT NULL THEN
            -- Gerar log
            gene0002.pc_gera_log_relato(pr_cdcooper => 0
                                       ,pr_des_log  => to_char(SYSDATE,'hh24:mi:ss')||' --> '||vr_des_erro);
          END IF;
          -- Retornar true pois criamos o arquivo
          RETURN true;
        ELSE
          -- Retornar falso pois existe o arquivo de OK
          RETURN false;
        END IF;
      END IF;
    END;
  END fn_procrel_exec;

  /* Função para retornar se todas as cooperativas estão online (sem processos rodando) */
  FUNCTION fn_cooperativas_online RETURN BOOLEAN IS
  BEGIN
    -- ..........................................................................
    -- Programa: fn_cooperativas_online
    -- Sistema : Conta-Corrente - Cooperativa de Credito
    -- Sigla   : CRED
    -- Autor   : Carlos Henrique
    -- Data    : Janeiro/2017.                     Ultima atualizacao:
    --
    -- Dados referentes ao programa:
    --
    -- Frequencia: Sempre que necessário
    -- Objetivo  : A função tem o intuito de retornar se todas as cooperativas estão online.
    -- .............................................................................  
  
    DECLARE
    vr_online number(1);

    BEGIN
      SELECT CASE
               WHEN EXISTS (SELECT 1
                       FROM crapdat
                           ,crapcop
                      WHERE crapcop.flgativo = 1
                        AND crapdat.cdcooper = crapcop.cdcooper
                        AND crapdat.inproces <> 1) THEN
                0  -- não estão online todas as cooperativas ativas
               ELSE
                1  -- online
             END
        INTO vr_online
        FROM dual;
      RETURN vr_online = 1;
    END;
  END fn_cooperativas_online;
  
  /* Procedimento para atualizar o arquivo de controle de geração dos relatórios da cadeia */
  PROCEDURE pc_atuali_procrel(pr_cdcooper IN crapcop.cdcooper%TYPE --> Cooperativa
                             ,pr_flgsitua IN VARCHAR2              --> Situação (E-Execução, O-OK)
                             ,pr_des_erro OUT VARCHAR2) IS         --> Saída de erro
  BEGIN
    -- ..........................................................................

    -- Programa: pc_atuali_procrel
    -- Sistema : Conta-Corrente - Cooperativa de Credito
    -- Sigla   : CRED
    -- Autor   : Marcos (Supero)
    -- Data    : Outubro/2013.                     Ultima atualizacao:

    -- Dados referentes ao programa:

    -- Frequencia: Diario (Batch - Background)
    -- Objetivo  : Este procedimento tem o intúito de atualizar o arquivo que sinaliza
    --             o início da geração dos relatórios da cadeia.ou seu termino

    --             Através dos parâmetros de sistema ARQ_PROCREL_EXEC e ARQ_PROCREL_OK
    --             temos o caminho dos arquivos que indicam o início e fim do processo.
    --             A princípio os mesmos são:
    --             /usr/coop/COOPERATIVA/controles/Proc_Relato.Exec
    --             /usr/coop/COOPERATIVA/controles/Proc_Relato.Ok
    --
    --             Obs: Ao criar um, o outro é eliminado.
    -- .............................................................................
    DECLARE
      -- Armazenar o diretório da cooperativa
      vr_dsdircop VARCHAR2(200);
      -- Armazenamento do caminho completo dos arquivos
      vr_dsarqori VARCHAR2(200); --> Arquivo original
      vr_dsarqdst VARCHAR2(200); --> Arquivo final
      -- Saída da OSCommand
      vr_typ_saida VARCHAR2(3);
      vr_des_saida VARCHAR2(4000);
    BEGIN
      -- Busca do diretório da cooperativa
      vr_dsdircop := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                          ,pr_cdcooper => pr_cdcooper);
      -- Se foi solicitado para iniciar a execução
      IF pr_flgsitua = 'E' THEN
        -- Substituir o OK pelo Exec
        vr_dsarqori := NVL(gene0001.fn_param_sistema('CRED',pr_cdcooper,'ARQ_PROCREL_OK'),'controles/Proc_Relato.Ok');
        vr_dsarqdst := NVL(gene0001.fn_param_sistema('CRED',pr_cdcooper,'ARQ_PROCREL_EXEC'),'controles/Proc_Relato.Exec');
      ELSE
        -- Substituir o Exec pelo OK
        vr_dsarqori := NVL(gene0001.fn_param_sistema('CRED',pr_cdcooper,'ARQ_PROCREL_EXEC'),'controles/Proc_Relato.Exec');
        vr_dsarqdst := NVL(gene0001.fn_param_sistema('CRED',pr_cdcooper,'ARQ_PROCREL_OK'),'controles/Proc_Relato.Ok');
      END IF;
      -- Se o arquivo de origem existe
      IF gene0001.fn_exis_arquivo(vr_dsdircop||'/'||vr_dsarqori) THEN
        -- Renomeá-lo para o nome de destino
        gene0001.pc_OSCommand_Shell(pr_des_comando => 'mv '||vr_dsdircop||'/'||vr_dsarqori||' '||vr_dsdircop||'/'||vr_dsarqdst
                                   ,pr_typ_saida   => vr_typ_saida
                                   ,pr_des_saida   => vr_des_saida);
      ELSE
        -- Apenas criar o arquivo destino, não precisamos mecher no original pois ele não existe
        gene0001.pc_OSCommand_Shell(pr_des_comando => 'touch '||vr_dsdircop||'/'||vr_dsarqdst
                                   ,pr_typ_saida   => vr_typ_saida
                                   ,pr_des_saida   => vr_des_saida);
        -- Setar as propriedades para garantir que o arquivo seja acessível por outros usuários
        gene0001.pc_OScommand_Shell(pr_des_comando => 'chmod 666 '||vr_dsdircop||'/'||vr_dsarqdst);
      END IF;
      -- Se houve erro em algum dos comandos Shell
      IF vr_des_saida IS NOT NULL AND vr_typ_saida = 'ERR' THEN
        -- Retornar
        pr_des_erro := 'Erro ao criar/atualizar arquivo de controle Proc_Relato: '||vr_des_saida;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro := 'Erro nao tratado ao criar/atualizar arquivo de controle Proc_Relato: '||sqlerrm;
    END;
  END pc_atuali_procrel;

  /* Incluir log de execução. */
  PROCEDURE pc_gera_log_batch(pr_cdcooper     IN crapcop.cdcooper%TYPE     --> Cooperativa
                             ,pr_ind_tipo_log IN NUMBER                    --> Tipo de mensagem do log
                             ,pr_des_log      IN VARCHAR2                  --> Descrição do log em si
                             ,pr_nmarqlog     IN VARCHAR2 DEFAULT NULL     --> Nome para gravação de log em arquivo específico
                             ,pr_flnovlog     IN VARCHAR2 DEFAULT 'N'      --> Flag S/N para criar um arquivo novo
                             ,pr_flfinmsg     IN VARCHAR2 DEFAULT 'S'      --> Flag S/N  para informaR ao fim da msg [PL/SQL]
                             ,pr_dsdirlog     IN VARCHAR2 DEFAULT NULL     --> Diretorio onde será gerado o log
                             ,pr_dstiplog     IN VARCHAR2 DEFAULT 'O'      --> Tipo do log: I - início; F - fim; O || E - ocorrência
                             ,pr_cdprograma   IN VARCHAR2 DEFAULT NULL     --> Programa/job
                             ,pr_tpexecucao    IN tbgen_prglog.tpexecucao%type DEFAULT 1 -- Tipo de execucao (0-Outro/ 1-Batch/ 2-Job/ 3-Online)
                             ,pr_cdcriticidade IN tbgen_prglog_ocorrencia.cdcriticidade%TYPE DEFAULT 0 -- Nivel criticidade (0-Baixa/ 1-Media/ 2-Alta/ 3-Critica)
                             ,pr_flgsucesso    IN tbgen_prglog.flgsucesso%TYPE DEFAULT 1 -- Indicador de sucesso da execução
                             ,pr_cdmensagem    IN tbgen_prglog_ocorrencia.cdmensagem%TYPE DEFAULT 0 -- Codigo da mensagem ou critica (Pode ser crapcri.cdcritic)
                             ) IS
  BEGIN
    -- ..........................................................................
    --
    --  Programa : pc_gera_log_batch
    --  Sistema  : Processos Batch
    --  Sigla    : BTCH
    --  Autor    : Marcos E. Martini - Supero
    --  Data     : Novembro/2012.                   Ultima atualizacao: 12/04/2016
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: ---
    --   Objetivo  : Prever método centralizado de log de execução Batch
    --
    --   Alteracoes: 30/09/2013 - Troca do nome do parâmetro pr_cdprogra para pr_nmarquiv
    --                            por melhor se enquadrar (Marcos-Supero)
    --
    --               12/04/2016 - Inclusao do parametro para poder definir diretorio para geracao do log
    --                            PRJ305-e-financeiro  (Odirlei-AMcom) 
    --
    --               01/11/2017 - Alterada procedure pc_gera_log_batch incluindo o parâmetro de codigo da mensagem
    --                            Origem da informação da tabela crapcri e atributo cdcritic
    --                            Passar o parâmetro de codigo da mensagem para procedure pc_log_programa
    --                           (Belli - Envolti - Chamado 786752)
    --
    -- .............................................................................

    -- .............................................................................
    --
    --  Opções para o parâmetro pr_ind_tipo_log:
    --   1 - Processo Normal
    --   2 - Erro tratato
    --   3 - Erro não tratado
    --
    --  Observação para o parâmetro pr_cdprogra:
    --    Quando preenchido, é criado um arquivo de log específico do programa enviado
    --    ficando no mesmo diretório do log, porem com o nome igual ao código do programa
    --
    --  Observaçao para o parametro pr_flnovlog:
    --    Quando informado S, a rotina cria um novo arquivo de LOG, do contrario
    --    a rotina ira usar o arquivo ja existente

    -- .............................................................................
    DECLARE
      vr_dircop_log VARCHAR2(200);      -- Diretório para gração do LOG
      vr_ind_arqlog UTL_FILE.file_type; -- Handle para o arquivo de log
      vr_des_erro VARCHAR2(4000);       -- Descrição de erro
      vr_exc_saida EXCEPTION;           -- Saída com exception
      vr_nom_arquivo VARCHAR2(30);      -- Nome do arquivo
      vr_ind_modo_abertura VARCHAR2(1); -- Modo de abertura do Log
      vr_fim_da_msg VARCHAR2(10) := ''; -- [PL/SQL] final da mensagem

      vr_idprglog tbgen_prglog.idprglog%TYPE := 0;      
      vr_tipomensagem tbgen_prglog_ocorrencia.tpocorrencia%TYPE := 0;
      vr_cdprograma   tbgen_prglog.cdprograma%TYPE := '';
      vr_nmarqlog VARCHAR2(4000);
      
      vr_tab_erro gene0002.typ_split;
      vr_des_log VARCHAR2(4000);
      
      vr_modulo VARCHAR2(100);
      vr_acao   VARCHAR2(100);
    BEGIN
      
    CASE pr_ind_tipo_log
      WHEN 1 THEN
        -- 4 mensagem
        vr_tipomensagem := 4;
      WHEN 2 THEN
        -- 1 erro de negócio
        vr_tipomensagem := 1;
      WHEN 3 THEN
        -- 2 erro nao tratado
        vr_tipomensagem := 2;
      ELSE
        -- 3 alerta
        vr_tipomensagem := 3;
      END CASE;   

      vr_nmarqlog := TRIM(lower(pr_nmarqlog));
      
      IF vr_nmarqlog IS NULL THEN
        vr_nmarqlog := NVL(gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_BATCH'),'proc_batch.log');
      END IF;
      
      -- Extrair apenas a mensagem depois da seta
      IF INSTR(pr_des_log, '-->', 1, 1) > 0 THEN
        vr_des_log := TRIM(substr(pr_des_log, (INSTR(pr_des_log, '-->', 1, 1)) + 3));
      ELSE 
        vr_des_log := pr_des_log;
      END IF;

      IF TRIM(pr_cdprograma) IS NOT NULL THEN
        vr_cdprograma := TRIM(pr_cdprograma);
      ELSE 
        -- Extrair CDPROGRAMA da mensagem
        -- 23/03/2017 11:30:00 - CRPS123 --> erro qualquer
        IF INSTR(pr_des_log, '-->', 1, 1) > 0 THEN
          vr_tab_erro := gene0002.fn_quebra_string(
                        pr_string => TRIM(SUBSTR(pr_des_log, 1, INSTR(pr_des_log, '-->', 1, 1) -1)),
                        pr_delimit => ' ');
          vr_cdprograma := vr_tab_erro(vr_tab_erro.count());
        ELSE          
          vr_cdprograma := '';
        END IF;
        
      END IF;

      DBMS_APPLICATION_INFO.read_module(module_name => vr_modulo, action_name => vr_acao);
      vr_des_log := vr_des_log || ' - Module: ' || vr_modulo ||
                                  ' - Action: ' || vr_acao;

      -- Incluido código de mensagem na chamada da pc log programa - 01/11/2017 - Ch 786752
      -- Gera Log em banco de dados
      cecred.pc_log_programa(PR_DSTIPLOG   => pr_dstiplog,      -- tbgen_prglog
                             PR_CDPROGRAMA => vr_cdprograma,    -- tbgen_prglog
                             pr_cdcooper   => pr_cdcooper,      -- tbgen_prglog
                             pr_tpexecucao => pr_tpexecucao,    -- tbgen_prglog
                             pr_tpocorrencia  => vr_tipomensagem,  -- tbgen_prglog_ocorrencia
                             pr_cdcriticidade => pr_cdcriticidade, -- tbgen_prglog_ocorrencia
                             pr_dsmensagem   => vr_des_log,        -- tbgen_prglog_ocorrencia
                             pr_flgsucesso   => pr_flgsucesso,  -- tbgen_prglog
                             pr_nmarqlog     => vr_nmarqlog,
                             PR_IDPRGLOG     => vr_idprglog,                            
                             pr_cdmensagem   => pr_cdmensagem         --tbgen_prglog_ocorrencia
                             );
      
      IF pr_dsdirlog IS NOT NULL THEN
        vr_dircop_log := pr_dsdirlog;
      ELSE
      -- Buscar o diretório log da cooperativa conectada
      vr_dircop_log := gene0001.fn_diretorio(pr_tpdireto => 'C' --> Usr/Coop
                                            ,pr_cdcooper => pr_cdcooper
                                            ,pr_nmsubdir => 'log');
      END IF;
      -- Se foi enviado nome de arquivo específico
      IF pr_nmarqlog IS NOT NULL THEN
        -- Criar o arquivo com o nome solicitado
        -- Retirar .log se vier no nome do arq para nao duplicar a extensao
        vr_nom_arquivo  := REPLACE(pr_nmarqlog,'.log','')||'.log';
      ELSE --> Processo normal
        -- Buscar o nome de arquivo de log cfme parâmetros de sistema, se não vier nada, usa o default
        vr_nom_arquivo := NVL(gene0001.fn_param_sistema('CRED',pr_cdcooper,'NOME_ARQ_LOG_BATCH'),'proc_batch.log');
      END IF;
      -- Se foi solicitado para criar um novo arquivo
      IF pr_flnovlog = 'S' THEN
        -- Usar W, pois esta opçao cria um arquivo novo
        vr_ind_modo_abertura := 'W';
      ELSE
        -- Usar A, pois esta opçao adiciona ao final do arquivo
        vr_ind_modo_abertura := 'A';
      END IF;
      -- Tenta abrir o arquivo de log em modo append
      gene0001.pc_abre_arquivo(pr_nmdireto => vr_dircop_log         --> Diretório do arquivo
                              ,pr_nmarquiv => vr_nom_arquivo        --> Nome do arquivo
                              ,pr_tipabert => vr_ind_modo_abertura  --> Modo de abertura (R,W,A)
                              ,pr_utlfileh => vr_ind_arqlog         --> Handle do arquivo aberto
                              ,pr_des_erro => vr_des_erro);
      IF vr_des_erro IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      -- Adiciona a linha de log
      BEGIN
        IF upper(pr_flfinmsg) = 'S' THEN
           vr_fim_da_msg := ' [PL/SQL]';
        END IF;          
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog,pr_des_log||vr_fim_da_msg);
      EXCEPTION
        WHEN OTHERS THEN
          -- Retornar erro
          vr_des_erro := 'Problema ao escrever no arquivo <'||vr_dircop_log||'/'||vr_nom_arquivo||'>: ' || sqlerrm;
          RAISE vr_exc_saida;
      END;
      -- Libera o arquivo
      BEGIN
        gene0001.pc_fecha_arquivo(vr_ind_arqlog);
      EXCEPTION
        WHEN OTHERS THEN
          -- Retornar erro
          vr_des_erro := 'Problema ao fechar o arquivo <'||vr_dircop_log||'/'||vr_nom_arquivo||'>: ' || sqlerrm;
          RAISE vr_exc_saida;
      END;
    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Enviar a mensagem de erro ao DMBS_OUTPUT e ignorar o log
        gene0001.pc_print(to_char(sysdate,'hh24:mi:ss')||' - '|| 'BTCH0001.pc_gera_log_batch --> '||vr_des_erro);
      WHEN OTHERS THEN
        -- Temporariamente apenas imprimir na tela
        GENE0001.pc_print(pr_des_mensag => to_char(sysdate,'hh24:mi:ss')||' - '
                                           || 'BTCH0001.pc_gera_log_batch'
                                           || ' --> Erro não tratado : ' || sqlerrm);
    END;
  END pc_gera_log_batch;

  /* Controlar geração de log de execução dos jobs */
  PROCEDURE pc_log_exec_job(pr_cdcooper     IN crapcop.cdcooper%TYPE     --> Cooperativa
                           ,pr_cdprogra     IN crapprg.cdprogra%TYPE     --> Codigo do programa
                           ,pr_nomdojob     IN VARCHAR2                  --> Nome do job
                           ,pr_dstiplog     IN VARCHAR2                  --> Tipo de log(I-inicio,F-Fim,E-Erro)
                           ,pr_dscritic     IN VARCHAR2                  --> Critica a ser apresentada em caso de erro
                           ,pr_nmarqlog     IN VARCHAR2 DEFAULT NULL     --> Nome para gravação de log em arquivo específico
                           ,pr_flgerlog IN OUT BOOLEAN                   --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim
                           ) IS
    -- ..........................................................................
    --
    --  Programa : pc_log_exec_job
    --  Sistema  : Processos Batch
    --  Sigla    : BTCH
    --  Autor    : Odirlei Busana - AMcom
    --  Data     : Maio/2016.                   Ultima atualizacao: 03/07/2017
    --
    --  Dados referentes ao programa:
    --
    --   Frequencia: ---
    --   Objetivo  : Gerar log de execução dos jobs
    --
    --   Alteracoes: 
    --               03/07/2017 - Colocada descrição da mensagem de erro no padrão 
    --                          - incluido tratamento de excptions nos cursores para melhorar os erros
    --                            (Belli - Envolti - Chamado 667957)
    --               
    -- .............................................................................
    
    ------------------------------- CURSORES ---------------------------------
    -- Buscar nome do programa
    CURSOR cr_crapprg IS
      SELECT crapprg.dsprogra##1
        FROM crapprg 
       WHERE cdcooper = pr_cdcooper
         AND upper(cdprogra) = pr_cdprogra;
    rw_crapprg cr_crapprg%ROWTYPE;    
    
    ------------------------------- VARIAVEIS -------------------------------
    vr_dscdolog VARCHAR2(4000);
    vr_dslogmes VARCHAR2(400);
    
    -- Trata Erro - Chamado 667957 - 034/07/2018
    vr_exc_saida  EXCEPTION;
    vr_dscritic   VARCHAR2(4000);
    vr_flgsucesso tbgen_prglog.flgsucesso%TYPE := 1;
    vr_idprglog   tbgen_prglog.idprglog%TYPE := 0;
    
  BEGIN
  
    -- Buscar nome do programa
    BEGIN
      OPEN cr_crapprg;
      FETCH cr_crapprg INTO rw_crapprg;
      CLOSE cr_crapprg;
      -- incluido tratamento de excptions nos cursores para melhorar os erros - Chamado 667957 - 04/07/2017            
      
    EXCEPTION
      WHEN OTHERS THEN
        
        CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper);
        
        vr_dscritic := 'cursor cr_crapprg - com erro: ' || SQLERRM;
        RAISE vr_exc_saida;
    END;        
     
    --> Log de inicio de execução
    IF pr_dstiplog = 'I' AND pr_flgerlog = FALSE THEN
      -- Gerar log
      vr_dscdolog := 'Inicio da execucao';

      IF trim(rw_crapprg.dsprogra##1) IS NOT NULL THEN
        vr_dscdolog := vr_dscdolog || ' - ' || trim(rw_crapprg.dsprogra##1);
      END IF;
      
      IF pr_dscritic IS NOT NULL THEN
        vr_dscdolog   := vr_dscdolog || ' ' || pr_dscritic;
        vr_flgsucesso := 0;
      END IF;
      
      -- Logs que iriam para o proc_batch ou proc_message irão apenas para tabela
      IF pr_nmarqlog IS NULL OR
         INSTR(pr_nmarqlog, 'proc_batch',   1, 1) > 0 OR
         INSTR(pr_nmarqlog, 'proc_message', 1, 1) > 0 THEN
         
        cecred.pc_log_programa(PR_DSTIPLOG   => pr_dstiplog, 
                               PR_CDPROGRAMA => nvl(pr_nomdojob,'JOB'), 
                               pr_cdcooper   => pr_cdcooper, 
                               pr_flgsucesso => vr_flgsucesso,
                               PR_IDPRGLOG   => vr_idprglog);
      ELSE
      -- Colocada descrição da mensagem de erro no padrão - Chamado 667957 - 04/07/2017      
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 1, 
                                 pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||
                                                    ' - ' || nvl(pr_nomdojob,'JOB') || ' --> ' || 
                                                    'ALERTA: ' || vr_dscdolog,
                                 pr_dstiplog     => pr_dstiplog,
                                 pr_nmarqlog     => pr_nmarqlog,
                                 pr_cdprograma   => pr_nomdojob,
                                 pr_tpexecucao   => 2);
      END IF;
      
      pr_flgerlog := TRUE;
    --> Log de final da execução
    ELSIF pr_dstiplog = 'F' AND pr_flgerlog THEN
    
      vr_dscdolog := 'Execucao ok';

      -- Logs que iriam para o proc_batch ou proc_message irão apenas para tabela
      IF pr_nmarqlog IS NULL OR
         INSTR(pr_nmarqlog, 'proc_batch',   1, 1) > 0 OR
         INSTR(pr_nmarqlog, 'proc_message', 1, 1) > 0 THEN
         
        cecred.pc_log_programa(PR_DSTIPLOG   => pr_dstiplog, 
                               PR_CDPROGRAMA => nvl(pr_nomdojob,'JOB'), 
                               pr_cdcooper   => pr_cdcooper, 
                               PR_IDPRGLOG   => vr_idprglog);  
      ELSE
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 1, 
                                 pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||
                                                    ' - ' || pr_nomdojob || ' --> ' || 
                                                    'ALERTA: ' || vr_dscdolog,
                                 pr_dstiplog     => pr_dstiplog,
                                 pr_cdprograma   => pr_nomdojob,
                                 pr_nmarqlog     => pr_nmarqlog,
                                 pr_tpexecucao   => 2);
      END IF;

    --> Log Final com erro
    ELSIF pr_dstiplog = 'E' AND pr_flgerlog THEN
      
      -- Colocada descrição da mensagem de erro no padrão - Chamado 667957 - 04/07/2017
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 1, 
                                 pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||
                                                    ' - ' || pr_nomdojob || ' --> ' || 
                                                    'ERRO: ' || pr_dscritic,
                                 pr_dstiplog     => pr_dstiplog,
                                 pr_cdprograma   => pr_nomdojob,
                                 pr_nmarqlog     => pr_nmarqlog,
                                 pr_tpexecucao   => 2);

    --> Caso passado critica e nao caiu em nenhuma situalção acima
    ELSIF pr_dscritic IS NOT NULL THEN
      
      -- Colocada descrição da mensagem de erro no padrão - Chamado 667957 - 04/07/2017
    
      vr_dslogmes := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE');
      vr_dscdolog := 'pr_dstiplog fora do padrão:' || pr_dstiplog || ' - ' ||pr_dscritic;
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 3, 
                                 pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||
                                                    ' - ' || pr_nomdojob || ' --> ' || 
                                                    'ERRO: ' || vr_dscdolog,
                                 pr_nmarqlog     => vr_dslogmes,
                                 pr_dstiplog     => 'E',
                                 pr_cdprograma   => pr_nomdojob,
                                 pr_tpexecucao   => 2);
     
    END IF; 
  
  EXCEPTION
    WHEN vr_exc_saida THEN 
      -- incluido tratamento de excptions nos cursores para melhorar os erros - Chamado 667957 - 04/07/2017
      vr_dslogmes := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE');
      vr_dscdolog := pr_dscritic || ' - ' || vr_dscritic;
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, 
                                 pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||
                                                    ' - ' || pr_nomdojob || ' --> ' || 
                                                    'ERRO: ' || vr_dscdolog,
                                 pr_nmarqlog     => vr_dslogmes,
                                 pr_tpexecucao   => 2);
      
    WHEN OTHERS THEN
                                 
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcooper); 
      
      -- Colocada descrição da mensagem de erro no padrão - Chamado 667957 - 04/07/2017
      vr_dslogmes := gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE');
      vr_dscdolog := pr_dscritic || ' - Log com problema: '||SQLERRM ;
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2, 
                                 pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||
                                                    ' - ' || pr_nomdojob || ' --> ' || 
                                                    'ERRO: ' || vr_dscdolog,
                                 pr_nmarqlog     => vr_dslogmes,
                                 pr_tpexecucao   => 2);                          
    
  END pc_log_exec_job;
  
  
  /* Rotina de validacao da antiga iniprg.p */
  PROCEDURE pc_valida_iniprg(pr_cdcooper IN crapdat.cdcooper%TYPE  --> Cooperativa
                            ,pr_flgbatch IN PLS_INTEGER            --> Indicador de execução em batch
                            ,pr_cdprogra IN crapprg.cdprogra%TYPE  --> Programa que está executando
                            ,pr_infimsol OUT PLS_INTEGER           --> Inidicador de termino de solicitação
                            ,pr_cdcritic OUT PLS_INTEGER) IS       --> Código do Retorno do Erro
  BEGIN
    -- ..........................................................................

    -- Programa: pc_valida_iniprg (Antigo Fontes/iniprg.p)
    -- Sistema : Conta-Corrente - Cooperativa de Credito
    -- Sigla   : CRED
    -- Autor   : Alisson (AMcom)
    -- Data    : Janeiro/2013.                     Ultima atualizacao:

    -- Dados referentes ao programa:

    -- Frequencia: Diario (Batch - Background)
    -- Objetivo  : Realizar as validações iniciais de cadastro dos programas

    -- Alteracoes: 07/01/2013 - Conversão Progress --> Oracle PLSQL (Alisson - Amcom)
    --
    --             30/07/2013 - Incluir controle para quando executando pela cadeia Progress
    --                          não efetuar nenhuma validação, pois isto setá executado pela
    --                          rotina na cadeia híbrida Progress (Marcos - Supero)
    --
    -- .............................................................................
    DECLARE
      --Selecionar Informacoes da Ordem de Execucao das solicitacoes
      CURSOR cr_crapord (pr_cdcooper IN crapord.cdcooper%TYPE
                        ,pr_nrsolici IN crapord.nrsolici%TYPE) IS
        SELECT crapord.cdcooper
        FROM crapord crapord
        WHERE crapord.cdcooper = pr_cdcooper
        AND   crapord.nrsolici = pr_nrsolici;
      rw_crapord cr_crapord%ROWTYPE;

      /* Variaveis locais da rotina pc_valida_iniprg */
      vr_regexist   BOOLEAN;
      vr_flgatend   BOOLEAN;
    BEGIN

      -- Somente efetuar os testes se não estivermos na cadeia Progress
      IF NVL(gene0001.fn_param_sistema('CRED',0,'FL_CADEIA_PROGRESS'),'N') = 'N' THEN

        -- Inicializando critica e indicador de termino de solicitação com false
        pr_cdcritic := 0;
        pr_infimsol := 0;

        --Selecionar informacoes das datas
        OPEN cr_crapdat (pr_cdcooper => pr_cdcooper);
        --Posicionar no proximo registro
        FETCH cr_crapdat INTO rw_crapdat;
        --Fechar Cursor
        CLOSE cr_crapdat;

        -- Se for programa batch
        IF pr_flgbatch = 1 THEN
          --Se o indicador do processo < 3
          IF rw_crapdat.inproces < 3 THEN
            IF rw_crapdat.inproces IN (1,2) THEN

              --Selecionar informações dos programas
              OPEN cr_crapprg (pr_cdcooper => pr_cdcooper
                              ,pr_cdprogra => pr_cdprogra);
              FETCH cr_crapprg INTO rw_crapprg;
              --Se nao encontrar registro
              IF cr_crapprg%NOTFOUND THEN
                --Atribuir código de erro
                pr_cdcritic:= 145;
              END IF;
            ELSE
              --Atribuir código de erro
              pr_cdcritic:= 141;
            END IF;
            --Fechar cursor
            CLOSE cr_crapprg;
          END IF;

          --Se o codigo do programa anterior for nulo
          IF  rw_crapdat.cdprgant <> ' ' THEN
            --Selecionar informações dos programas
            OPEN cr_crapprg (pr_cdcooper => pr_cdcooper
                            ,pr_cdprogra => rw_crapdat.cdprgant);
            FETCH cr_crapprg INTO rw_crapprg;
            --Se nao encontrar registro
            IF cr_crapprg%NOTFOUND THEN
              --Atribuir código de erro
              pr_cdcritic:= 143;
            ELSE
              IF  rw_crapprg.inctrprg <> 2 THEN
                pr_cdcritic:= 144;
              END IF;
            END IF;
            --Fechar Cursor
            CLOSE cr_crapprg;
          END IF;
        END IF;  --pr_flgbatch

        --Selecionar informações dos programas
        OPEN cr_crapprg (pr_cdcooper => pr_cdcooper
                        ,pr_cdprogra => pr_cdprogra);
        FETCH cr_crapprg INTO rw_crapprg;
        --Se nao encontrar registro
        IF cr_crapprg%NOTFOUND THEN
          --Atribuir código de erro
          pr_cdcritic:= 145;
        ELSE
          IF rw_crapprg.inctrprg <> 1 AND pr_flgbatch = 1 THEN
            --Atribuir código de erro
            pr_cdcritic:= 146;
          END IF;
        END IF;
        --Fechar cursor
        CLOSE cr_crapprg;

        --setar variaveis de controle
        vr_regexist:= FALSE;
        vr_flgatend:= FALSE;

        --Selecionar informacoes das solicitacoes
        FOR rw_crapsol IN cr_crapsol (pr_cdcooper => pr_cdcooper
                                     ,pr_nrsolici => rw_crapprg.nrsolici) LOOP
          --verificar se a situacao é igual a 1
          IF rw_crapsol.insitsol = 1 THEN
            vr_regexist:= TRUE;
            vr_flgatend:= FALSE;
          ELSE
            vr_regexist:= TRUE;
            vr_flgatend:= TRUE;
          END IF;
        END LOOP;

        --Se nao encontrou
        IF NOT vr_regexist THEN
          pr_cdcritic:= 149;
        ELSE
          IF vr_flgatend THEN
            --Selecionar Informacoes da Ordem de Execucao das solicitacoes
            OPEN cr_crapord (pr_cdcooper => pr_cdcooper
                            ,pr_nrsolici => rw_crapprg.nrsolici);
            --Posicionar no proximo registro
            FETCH cr_crapord INTO rw_crapord;
            --Se nao encontrou
            IF cr_crapord%NOTFOUND THEN
              pr_cdcritic:= 664;
            END IF;
            --Fechar Cursor
            CLOSE cr_crapord;
          END IF;
        END IF;
      END IF; --> Fora da cadeia Progress
    END;

  END pc_valida_iniprg;

  /* Tratamento e retorno de valores de restart */
  PROCEDURE pc_valida_restart(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                             ,pr_cdprogra  IN crapprg.cdprogra%TYPE --> Código do programa
                             ,pr_flgresta  IN PLS_INTEGER           --> Indicador de restart
                             ,pr_nrctares OUT crapass.nrdconta%TYPE --> Número da conta de restart
                             ,pr_dsrestar OUT VARCHAR2              --> String genérica com informações para restart
                             ,pr_inrestar OUT INTEGER               --> Indicador de Restart
                             ,pr_cdcritic OUT PLS_INTEGER           --> Código de critica
                             ,pr_des_erro OUT VARCHAR2) IS          --> Saída de erro
  BEGIN
    -- ..........................................................................

    -- Programa: pc_valida_restart (Antigo trecho Fontes/iniprg.p)
    -- Sistema : Conta-Corrente - Cooperativa de Credito
    -- Sigla   : CRED
    -- Autor   : Marcos (Supero)
    -- Data    : Fevereiro/2013.                     Ultima atualizacao:

    -- Dados referentes ao programa:

    -- Frequencia: Diario (Batch - Background)
    -- Objetivo  : Realizar a busca ou criação de registros para controle de restart

    -- Alteracoes:
    -- 30/07/2013 - Incluir controle para quando executando pela cadeia Progress
    --              apenas copiar as informações da crapres, já que todo controle
    --              foi efetuado pelo Progrress (Marcos - Supero)
    --
    -- 25/11/2013 - Ajuste na tipagem do paràmetro pr_flgresta cfme padrão (Marcos-Supero)
    --
    -- .............................................................................
    DECLARE
      --Selecionar informacoes de restart do programa
      CURSOR cr_crapres IS
        SELECT crapres.nrdconta
              ,crapres.dsrestar
          FROM crapres crapres
         WHERE crapres.cdcooper = pr_cdcooper
           AND crapres.cdprogra = pr_cdprogra;
      rw_crapres cr_crapres%ROWTYPE;
    BEGIN
      -- Se for restart de programa
      IF pr_flgresta = 1 THEN
        -- Selecionar informacoes de controle de restart de programa
        OPEN cr_crapres;
        -- Posicionar no proximo registro
        FETCH cr_crapres
         INTO rw_crapres;
        -- Para execução na cadeia Progress
        IF NVL(gene0001.fn_param_sistema('CRED',0,'FL_CADEIA_PROGRESS'),'N') = 'S' THEN
          -- Apenas retorna as informação da CRAPRES
          -- Atribuir numero da conta de restart
          pr_nrctares := rw_crapres.nrdconta;
          -- Limpar o campo caso o mesmo seja composto por um único espaço
          IF rw_crapres.dsrestar = ' ' THEN
            pr_dsrestar := null;
          ELSE
            pr_dsrestar := rw_crapres.dsrestar;
          END IF;
          -- Somente setar 1 se encontrou ou "Se o restart esta zerado"  (Renato - Supero - 04/04/14)
          IF cr_crapres%FOUND AND NVL(rw_crapres.nrdconta,0) > 0 THEN
            pr_inrestar := 1;
          ELSE
            pr_inrestar := 0;
          END IF;
        ELSE
          -- Se nao encontrar
          IF cr_crapres%NOTFOUND THEN
            -- Criar o registro para atualização posterior
            BEGIN
              INSERT INTO crapres (cdprogra
                                  ,nrdconta
                                  ,dsrestar
                                  ,cdcooper)
                          VALUES  (pr_cdprogra
                                  ,0
                                  ,' '
                                  ,pr_cdcooper);
            EXCEPTION
              WHEN OTHERS THEN
                --Fechar Cursor
                CLOSE cr_crapres;
                --Montar mensagem de erro
                pr_des_erro := 'Erro ao inserir na tabela crapres. '||sqlerrm;
            END;
            -- Atribuir zero para numero da conta de restart
            pr_nrctares := 0;
            -- Indicador de restart
            pr_inrestar := 0;
            -- Descrição do restart
            pr_dsrestar := NULL;
          ELSE
            -- Atribuir numero da conta de restart
            pr_nrctares := rw_crapres.nrdconta;
            -- Atribuir descricao de restart
            pr_dsrestar := rw_crapres.dsrestar;
            -- Atribuir indicador de restart
            pr_inrestar := 1;
            -- Mostrar mensagem de restart no log
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                      ,pr_ind_tipo_log => 2 -- Erro tratato
                                      ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || pr_cdprogra || ' --> '
                                                       || gene0001.fn_busca_critica(pr_cdcritic => 152)
                                                       || gene0002.fn_mask_conta(pr_nrctares));
          END IF;
        END IF;
        --Fechar Cursor
        CLOSE cr_crapres;
      ELSE
        -- Atribuir zero para numero da conta de restart
        pr_nrctares := 0;
        -- Indicador de restart
        pr_inrestar := 0;
        -- Descrição do restart
        pr_dsrestar := NULL;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_des_erro := 'Erro na rotina btch0001.pc_valida_restart. '||sqlerrm;
    END;
  END pc_valida_restart;

  /* Eliminação dos registros de restart */
  PROCEDURE pc_elimina_restart(pr_cdcooper  IN crapcop.cdcooper%TYPE --> Cooperativa conectada
                              ,pr_cdprogra  IN crapprg.cdprogra%TYPE --> Código do programa
                              ,pr_flgresta  IN PLS_INTEGER           --> Indicador de restart
                              ,pr_des_erro OUT VARCHAR2) IS          --> Saída de erro
  BEGIN
    -- ..........................................................................

    -- Programa: pc_elimina_restart (Antigo trecho Fontes/fimprg.p)
    -- Sistema : Conta-Corrente - Cooperativa de Credito
    -- Sigla   : CRED
    -- Autor   : Marcos (Supero)
    -- Data    : Fevereiro/2013.                     Ultima atualizacao:

    -- Dados referentes ao programa:

    -- Frequencia: Diario (Batch - Background)
    -- Objetivo  : Realizar a eliminação de registros para controle de restart

    -- Alteracoes:
    -- 30/07/2013 - Incluir controle para quando executando pela cadeia Progress
    --              não efetuar a eliminação do registro de restart (Marcos - Supero)
    --
    -- 04/10/2013 - Incluir teste caso não existir crapres para gerar critica 151 (Marcos-Supero)
    --
    -- 25/11/2013 - Ajuste na tipagem do paràmetro pr_flgresta cfme padrão (Marcos-Supero)
    --
    -- .............................................................................
    BEGIN
      -- Se for restart de programa e a cadeia não estiver rodando pelo Progress
      IF pr_flgresta = 1 AND NVL(gene0001.fn_param_sistema('CRED',0,'FL_CADEIA_PROGRESS'),'N') = 'N'  THEN
        -- Eliminar os registros da tabela crapres
        DELETE
          FROM crapres
         WHERE cdcooper = pr_cdcooper
           AND cdprogra = pr_cdprogra;
        -- Se não atualizou nenhum registro
        IF SQL%ROWCOUNT = 0 THEN
          -- Gerar critica 151
          btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                    ,pr_ind_tipo_log => 2
                                    ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                     || pr_cdprogra || ' --> '
                                                     || gene0001.fn_busca_critica(151) );

        END IF;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        pr_des_erro := 'Erro na rotina btch0001.pc_elimina_restart - Ao eliminar CRAPRES: '||sqlerrm;
    END;
  END pc_elimina_restart;

  /* Rotina de validacao da antiga fimprg.p */
  PROCEDURE pc_valida_fimprg (pr_cdcooper IN crapdat.cdcooper%TYPE  --> Cooperativa
                             ,pr_cdprogra IN crapprg.cdprogra%TYPE  --> Programa que está executando
                             ,pr_infimsol IN OUT PLS_INTEGER        --> Indicador de fim de solicitação da cadeia
                             ,pr_stprogra IN OUT PLS_INTEGER) IS    --> Descrição do Retorno do Erro
  BEGIN
    -- ..........................................................................

    -- Programa: pc_valida_fimprg (Antigo Fontes/fimprg.p)
    -- Sistema : Conta-Corrente - Cooperativa de Credito
    -- Sigla   : CRED
    -- Autor   : Marcos (Supero)
    -- Data    : Outubro/2013.                     Ultima atualizacao:

    -- Dados referentes ao programa:

    -- Frequencia: Diario (Batch - Background)
    -- Objetivo  : Realizar as validações finais no termino da execução e retorno indicadores

    -- Alteracoes: 04/10/2013 - Conversão Progress --> Oracle PLSQL (Marcos - Supero)
    --
    -- .............................................................................
    DECLARE
      /* Saida com critica */
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_exc_crit exception;
    BEGIN
      -- Somente se não estivermos executando a cadeia híbrida Progress
      IF NVL(gene0001.fn_param_sistema('CRED',0,'FL_CADEIA_PROGRESS'),'N') = 'N' THEN

        -- Selecionar informacoes das datas
        OPEN cr_crapdat(pr_cdcooper => pr_cdcooper);
        FETCH cr_crapdat
         INTO rw_crapdat;
        CLOSE cr_crapdat;

        -- Selecionar informações dos programas
        OPEN cr_crapprg(pr_cdcooper => pr_cdcooper
                       ,pr_cdprogra => pr_cdprogra);
        FETCH cr_crapprg
         INTO rw_crapprg;
        --Se nao encontrar registro
        IF cr_crapprg%NOTFOUND THEN
          -- Fechar o cursor e sair com critica 145
          CLOSE cr_crapprg;
          vr_cdcritic:= 145;
          RAISE vr_exc_crit;
        ELSE
          -- Fechar cursor
          CLOSE cr_crapprg;
        END IF;

        -- Se for fim da solicitação
        IF pr_infimsol = 1 THEN
          -- Selecionar informacoes das solicitacoes
          OPEN cr_crapsol (pr_cdcooper => pr_cdcooper
                          ,pr_nrsolici => rw_crapprg.nrsolici);
          FETCH cr_crapsol
           INTO rw_crapsol;
          -- Se não encontrar
          IF cr_crapsol%NOTFOUND THEN
            -- Fechar o cursor e sair com critica 115
            CLOSE cr_crapsol;
            vr_cdcritic:= 145;
            RAISE vr_exc_crit;
          ELSE
            -- Fechar o cursor
            CLOSE cr_crapsol;
          END IF;
          -- Atualizar a situação da solicitação como atendida
          BEGIN
            UPDATE crapsol
               SET insitsol = 2
             WHERE rowid = rw_crapsol.rowid;
          EXCEPTION
            WHEN OTHERS THEN
              vr_des_erro := 'Problema ao executar a fimprg: Erro ao atualizar CRAPSOL = '||sqlerrm;
              RAISE vr_exc_erro;
          END;
          -- Desativar a flag
          pr_infimsol := 0;
        END IF;

        -- Atualizar situação da solicitação do programa
        BEGIN
          UPDATE crapprg
             SET inctrprg = 2
           WHERE rowid = rw_crapprg.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_des_erro := 'Problema ao executar a fimprg: Erro ao atualizar CRAPPRG = '||sqlerrm;
            RAISE vr_exc_erro;
        END;

        -- Atualizar código do programa anterior na crapdat
        BEGIN
          UPDATE crapdat
             SET cdprgant = pr_cdprogra
           WHERE rowid = rw_crapdat.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            vr_des_erro := 'Problema ao executar a fimprg: Erro ao atualizar CRAPDAT = '||sqlerrm;
            RAISE vr_exc_erro;
        END;

        -- Indicar encerramento da solicitação com sucesso
        pr_stprogra := 1;

      END IF; --> Fora da cadeia Progress
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Escrever no log a mensagem ja formatada
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || pr_cdprogra || ' --> '
                                                   || vr_des_erro );
      WHEN vr_exc_crit THEN
        -- Escrever no log
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2
                                  ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                   || pr_cdprogra || ' --> '
                                                   || gene0001.fn_busca_critica(vr_cdcritic) );
    END;
  END pc_valida_fimprg;

  /* Função para calculo de diferença de tempos de execução com timestamp */
  FUNCTION fn_dif_timestamp_segundos(pr_time_ini IN TIMESTAMP
                                    ,pr_time_fim IN TIMESTAMP) RETURN NUMBER IS
  BEGIN
    -- ..........................................................................

    -- Programa: fn_dif_timestamp_segundos
    -- Sistema : Conta-Corrente - Cooperativa de Credito
    -- Sigla   : CRED
    -- Autor   : Daniel (Supero)
    -- Data    : Outubro/2013.                     Ultima atualizacao:

    -- Dados referentes ao programa:

    -- Frequencia: Diario (Batch - Background)
    -- Objetivo  : A função retorna a diferença entre os dois timestamp, em segundos, com precisão de microsegundos
    --             - pr_time_ini: é o timestamp definido antes de executar o trecho que se quer marcar o tempo
    --             - pr_time_fim: é o timestamp definido após executar o trecho que se quer marcar o tempo
    --
    -- Alteracoes: 04/10/2013 - Conversão Progress --> Oracle PLSQL (Marcos - Supero)
    --
    -- .............................................................................
    DECLARE
      -- Auxiliar para o cálculo
      vr_qtsegund  number(15,6) := 0;
    BEGIN
      -- Efetuar a diferença das datas, retornando-as no final
      vr_qtsegund := extract(day from (pr_time_fim - pr_time_ini)) * 24 * 60 * 60 +
                     extract(hour from (pr_time_fim - pr_time_ini)) * 60 * 60 +
                     extract(minute from (pr_time_fim - pr_time_ini)) * 60 +
                     extract(second from (pr_time_fim - pr_time_ini));
      return(vr_qtsegund);
    END;
  END fn_dif_timestamp_segundos;

  /* Rotina para ativação de ponto de análise de performance */
  PROCEDURE pc_inicia_captura_perf(pr_nrseqsol IN OUT crappfm.nrseqsol%TYPE              --> Id da análise (na primeira vez busca e retorna)
                                  ,pr_cdcooper IN crappfm.cdcooper%TYPE                  --> Cooperativa conectada
                                  ,pr_cdprogra IN crapprg.cdprogra%TYPE                  --> Programa que está executando
                                  ,pr_cdoperad IN crappfm.cdoperad%TYPE DEFAULT 'BATCH'  --> Operador do processo em execução
                                  ,pr_dschvpfm IN crappfm.dschvpfm%TYPE                  --> Chave de acesso da análise
                                  ,pr_dsparame IN crappfm.dsparame%TYPE DEFAULT ' ') IS --> Parametros auxiliares para análise
    -- Cria uma nova seção para commitar
    -- somente este escopo de alterações
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    -- ..........................................................................

    -- Programa: pc_inicia_captura_perf
    -- Sistema : Conta-Corrente - Cooperativa de Credito
    -- Sigla   : CRED
    -- Autor   : Marcos (Supero)
    -- Data    : Outubro/2013.                     Ultima atualizacao:

    -- Dados referentes ao programa:

    -- Frequencia: Diario (Batch - Background)
    -- Objetivo  : Realizar acumulo de informações para análise de performance em processos específicos

    -- Alteracoes:
    --
    -- .............................................................................
    DECLARE

      -- Guardar sequencia para inserção
      vr_nrseqpfm crappfm.nrseqpfm%TYPE := 0;

      -- Busca do ultimo registro desta analise de performance
      CURSOR cr_crappfm IS
        SELECT nvl(max(nrseqpfm),0)+1 nrseqpfm
          FROM crappfm
         WHERE nrseqsol = pr_nrseqsol;

    BEGIN

      -- Se não foi passada sequencia
      IF pr_nrseqsol IS NULL THEN
        -- É a primeira execução, então devemos buscar a
        -- sequencia e retornar ao processo chamador
        SELECT NVL(CRAPPFM_NRSEQSOL.Nextval,0)+1 INTO pr_nrseqsol FROM DUAL;
        -- Também iniciamos a sequencia de registro dentro da solicitação
        vr_nrseqpfm := 1;
      ELSE
        -- Busca do ultimo registro desta analise de performance
        OPEN cr_crappfm;
        FETCH cr_crappfm
         INTO vr_nrseqpfm;
        CLOSE cr_crappfm;
      END IF;

      -- Por fim, inserir na tabela
      BEGIN
        INSERT INTO crappfm (nrseqsol
                            ,nrseqpfm
                            ,cdcooper
                            ,cdoperad
                            ,cdprogra
                            ,dschvpfm
                            ,dsparame
                            ,tsinipfm
                            ,tsfimpfm)
                      VALUES(pr_nrseqsol
                            ,vr_nrseqpfm
                            ,pr_cdcooper
                            ,pr_cdoperad
                            ,pr_cdprogra
                            ,pr_dschvpfm
                            ,pr_dsparame
                            ,systimestamp
                            ,' ');
      EXCEPTION
        WHEN OTHERS THEN
          -- Escrever no dbms_output
          gene0001.pc_print(to_char(sysdate,'hh24:mi:ss')||' - Seq: '|| pr_nrseqsol
                            || ' --> Erro tratado na btch0001.pc_inicia_captura_perf -'
                            || ' ao inserir crappfm: '|| sqlerrm );

      END;
      -- Gravar
      COMMIT;
    EXCEPTION
      WHEN others THEN
        -- Escrever no dbms_output
        gene0001.pc_print(to_char(sysdate,'hh24:mi:ss')||' - Seq: '|| pr_nrseqsol
                          || ' --> Erro não tradado na btch0001.pc_inicia_captura_perf: '|| sqlerrm );
        -- Efetuar commit para liberar a seção
        COMMIT;
    END;
  END pc_inicia_captura_perf;

  /* Rotina para encerramento de ponto de análise de performance */
  PROCEDURE pc_encerra_captura_perf(pr_nrseqsol IN crappfm.nrseqsol%TYPE                  --> Id da análise (na primeira vez busca e retorna)
                                   ,pr_dschvpfm IN crappfm.dschvpfm%TYPE                  --> Chave de acesso da análise
                                   ,pr_dsparame IN crappfm.dsparame%TYPE DEFAULT ' ') IS --> Parametros auxiliares para análise
    -- Cria uma nova seção para commitar
    -- somente este escopo de alterações
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    -- ..........................................................................

    -- Programa: pc_encerra_captura_perf
    -- Sistema : Conta-Corrente - Cooperativa de Credito
    -- Sigla   : CRED
    -- Autor   : Marcos (Supero)
    -- Data    : Outubro/2013.                     Ultima atualizacao:

    -- Dados referentes ao programa:

    -- Frequencia: Diario (Batch - Background)
    -- Objetivo  : Realizar encerramento do ponto de análise

    -- Alteracoes:
    --
    -- .............................................................................
    DECLARE

      -- Guardar sequencia para atualização
      vr_rowid rowid;

      -- Busca do ultimo registro desta analise de performance
      CURSOR cr_crappfm IS
        SELECT rowid
          FROM crappfm
         WHERE nrseqsol = pr_nrseqsol
           AND dschvpfm = pr_dschvpfm
           AND NVL(dsparame,' ') = NVL(pr_dsparame,' ')
           AND tsfimpfm IS NULL;
    BEGIN

      -- Busca do ultimo registro desta analise de performance
      OPEN cr_crappfm;
      FETCH cr_crappfm
       INTO vr_rowid;
      CLOSE cr_crappfm;

      -- Por fim, atualizar na tabela o encerramento
      BEGIN
        UPDATE crappfm
           SET tsfimpfm = systimestamp
         WHERE rowid = vr_rowid;
      EXCEPTION
        WHEN OTHERS THEN
          -- Escrever no dbms_output
          gene0001.pc_print(to_char(sysdate,'hh24:mi:ss')||' - Seq: '|| pr_nrseqsol
                            || ' --> Erro tratado na btch0001.pc_encerra_captura_perf -'
                            || ' ao atualizar crappfm: '|| sqlerrm );

      END;
      -- Gravar
      COMMIT;
    EXCEPTION
      WHEN others THEN
        -- Escrever no dbms_output
        gene0001.pc_print(to_char(sysdate,'hh24:mi:ss')||' - Seq: '|| pr_nrseqsol
                          || ' --> Erro não tradado na btch0001.pc_inicia_captura_perf: '|| sqlerrm );
        -- Efetuar commit para liberar a seção
        COMMIT;
    END;
  END pc_encerra_captura_perf;


  -- Programa: pc_log_internal_exception
  -- Autor   : Carlos
  -- Data    : Julho/2015.                        Ultima atualizacao: 03/02/2017
  -- Objetivo  : Verificar e criar log de exceções internas do oracle, tais como: string maior que o limite 
  --             definido no tipo varchar, divisão por zero e outras.
  --             Deve ser usado na exception OTHERS. 
  --             Ex. de caminho do log: viacredi/log/internal_exception.log 
  -- Alterações
  --
  -- 03/02/2017 - #601772 Procedure defasado pelo pc_internal_exception. Modificado o corpo da 
  --              rotina para ficar retrocompatível (Carlos)
  PROCEDURE pc_log_internal_exception(pr_cdcooper IN crapcop.cdcooper%TYPE DEFAULT 3) IS
  BEGIN
    cecred.pc_internal_exception(pr_cdcooper);
  END pc_log_internal_exception;

END btch0001;
/
