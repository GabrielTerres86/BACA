CREATE OR REPLACE PACKAGE CECRED.SSPB0004 AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: SSPB0004
  --    Autor   : Everton Souza - Mouts
  --    Data    : Julho/2018                      Ultima Atualizacao:   /  /
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : Gerar arquivo com as mensagens de controle fora do padrão, servirão de entrada para
  --                controle da operação
  --                Construido para o Projeto 475
  --
  --    Alteracoes:
  --
  ---------------------------------------------------------------------------------------------------------------

  -- Rotina para verificar execução das fases de mensagens
  PROCEDURE pc_verifica_fase_mensagem(pr_cdcritic   OUT crapcri.cdcritic%TYPE,         --> Codigo do erro
                                      pr_dscritic   OUT crapcri.dscritic%TYPE);        --> Mensagem do erro

  PROCEDURE pc_executa_fase_mensagem(pr_cdfase          IN tbspb_fase_mensagem.cdfase%TYPE,            --> Codigo da fase da mensagem
                                     pr_nmfase_anterior IN tbspb_fase_mensagem.nmfase%TYPE,
                                     pr_qtalerta        IN tbspb_fase_mensagem.qtmensagem_alerta%TYPE, --> Quantidade de mensagens fora do padrao para geracao de alerta
                                     pr_cdcritic       OUT crapcri.cdcritic%TYPE,                      --> Codigo do erro
                                     pr_dscritic       OUT crapcri.dscritic%TYPE);                     --> Mensagem do erro

  PROCEDURE pc_adiciona_arquivo(pr_linha        IN VARCHAR2                 --> Mensagem aviso Nagios
                               ,pr_abre_arquivo IN VARCHAR2                 --> Abre aquivo (SIM/NAO)
                               ,pr_cdcritic    OUT crapcri.cdcritic%TYPE    --> Codigo do erro
                               ,pr_dscritic    OUT crapcri.dscritic%TYPE);  --> Mensagem do erro

END SSPB0004;
/
CREATE OR REPLACE PACKAGE BODY CECRED.SSPB0004 AS
  ---------------------------------------------------------------------------------------------------------------
  --
  --    Programa: SSPB0004
  --    Autor   : Everton Souza - Mouts
  --    Data    : Julho/2018                       Ultima Atualizacao:   /  /
  --
  --    Dados referentes ao programa:
  --
  --    Objetivo  : Gerar arquivo com as mensagens de controle fora do padrão, servirão de entrada para
  --                controle da operação
  --
  --    Alteracoes:
  ---------------------------------------------------------------------------------------------------------------
  -- Variáveis
  vr_data_execucao     DATE;
  vr_linha             VARCHAR2(4000);
  vr_dircop_log        VARCHAR2(200);      -- Diretório para gravação
  vr_ind_arqlog        UTL_FILE.file_type; -- Handle para o arquivo de log
  vr_nom_arquivo       VARCHAR2(100);     -- Nome do arquivo
  vr_ind_modo_abertura VARCHAR2(1); -- Modo de abertura do Log

  PROCEDURE pc_verifica_fase_mensagem(pr_cdcritic   OUT crapcri.cdcritic%TYPE,         --> Codigo do erro
                                      pr_dscritic   OUT crapcri.dscritic%TYPE) IS      --> Mensagem do erro  BEGIN
  BEGIN
    /* .............................................................................
    Programa: pc_verifica_fase_mensagem
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Everton Souza_Mouts
    Data    : 13/07/2018                        Ultima atualizacao: 8

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para verificar execução das fases de mensagens

    Alteracoes:
    ............................................................................. */
    DECLARE
    --Cursor para pegar fases das mensagens SPB
      CURSOR cr_fase_msg IS
        SELECT a.cdfase,
               a.nmfase nmfase_atual,
               a.cdfase_anterior,
               b.nmfase nmfase_anterior,
               a.qttempo_alerta,
               a.qtmensagem_alerta,
               NVL(a.dtultima_execucao,to_date('01/01/1900','dd/mm/yyyy')) dtultima_execucao,
               NVL(a.dtultima_execucao,to_date('01/01/1900','dd/mm/yyyy')) + (a.qttempo_alerta/1440) dtproxima_execucao
          FROM tbspb_fase_mensagem a
              ,tbspb_fase_mensagem b
         WHERE a.idativo = 1                  -- ativa
           AND a.idfase_controlada = 1        -- controlada
           AND a.cdfase_anterior  IS NOT NULL -- e com fase anterior para comparação
           AND b.cdfase            = a.cdfase_anterior
          ORDER BY a.cdfase;

    rw_fase_msg cr_fase_msg%ROWTYPE;

    -- Variaveis de erro
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;
    -- Controle de erro
    vr_exc_erro EXCEPTION;

    BEGIN
      -- Abrir arquivo com o cabeçalho
      vr_linha := RPAD('FASE ATUAL'    ,30) ||'|'||
                  RPAD('FASE ANTERIOR' ,30) ||'|'||
                  RPAD('MENSAGEM'      ,20) ||'|'||
                  RPAD('NR.CONTROLE'   ,20) ||'|'||
                  RPAD('HR.FASE.ANT'   ,11) ||'|'||
                  RPAD('TEMPO ATRASO'  ,12) ||'|'||
                  LPAD('QTD.MSG.ATRASO',14) ||'|';
      --
      pc_adiciona_arquivo(pr_linha        => vr_linha
                         ,pr_abre_arquivo => 'SIM'
                         ,pr_cdcritic     => vr_cdcritic
                         ,pr_dscritic     => vr_dscritic);
      --
      IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) is not null THEN
        RAISE vr_exc_erro;
      END IF;
      --
      -- Abrir arquivo com o cabeçalho
      vr_linha := RPAD('-',30,'-') ||'|'||
                  RPAD('-',30,'-') ||'|'||
                  RPAD('-',20,'-') ||'|'||
                  RPAD('-',20,'-') ||'|'||
                  RPAD('-',11,'-') ||'|'||
                  LPAD('-',12,'-') ||'|'||
                  LPAD('-',14,'-') ||'|';
      --
      pc_adiciona_arquivo(pr_linha        => vr_linha
                         ,pr_abre_arquivo => 'NAO'
                         ,pr_cdcritic     => vr_cdcritic
                         ,pr_dscritic     => vr_dscritic);
      --
      IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) is not null THEN
        RAISE vr_exc_erro;
      END IF;
      --
      -- Carrega data de execução
      vr_data_execucao := sysdate;
      -- Carregar arquivo com a tabela tbspb_fase_mensagem
      FOR rw_fase_msg in cr_fase_msg LOOP
        --
        -- Se a data da próxima execução de fase estiver dentro do período de execução
-- Não verificar se está na range de execução
--        IF rw_fase_msg.dtproxima_execucao <= vr_data_execucao THEN
          --
          pc_executa_fase_mensagem(pr_cdfase          => rw_fase_msg.cdfase,
                                   pr_nmfase_anterior => rw_fase_msg.nmfase_anterior,
                                   pr_qtalerta        => rw_fase_msg.qtmensagem_alerta,
                                   pr_cdcritic        => vr_cdcritic,
                                   pr_dscritic        => vr_dscritic);
          --
          IF nvl(pr_cdcritic,0) <> 0 OR trim(pr_dscritic) is not null THEN
            RAISE vr_exc_erro;
          END IF;
          --
--        END IF;
        --
      END LOOP;
      --
      COMMIT;
      --
      -- Libera o arquivo
      BEGIN
        gene0001.pc_fecha_arquivo(vr_ind_arqlog);
      EXCEPTION
        WHEN OTHERS THEN
          -- Retornar erro
          vr_dscritic := 'Problema ao fechar o arquivo <'||vr_dircop_log||'/'||vr_nom_arquivo||'>: ' || sqlerrm;
          RAISE vr_exc_erro;
      END;
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Erro
        IF vr_cdcritic <> 0 THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na SSPB0004.pc_verifica_fase_mensagem.' || SQLERRM;
    END;
  END pc_verifica_fase_mensagem;
  --

  PROCEDURE pc_executa_fase_mensagem(pr_cdfase          IN tbspb_fase_mensagem.cdfase%TYPE,            --> Codigo da fase da mensagem
                                     pr_nmfase_anterior IN tbspb_fase_mensagem.nmfase%TYPE,
                                     pr_qtalerta        IN tbspb_fase_mensagem.qtmensagem_alerta%TYPE, --> Quantidade de mensagens fora do padrao para geracao de alerta
                                     pr_cdcritic       OUT crapcri.cdcritic%TYPE,                      --> Codigo do erro
                                     pr_dscritic       OUT crapcri.dscritic%TYPE) IS                   --> Mensagem do erro  BEGIN
  BEGIN
    /* .............................................................................
    Programa: pc_executa_fase_mensagem
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Everton Souza_Mouts
    Data    : 13/07/2018                        Ultima atualizacao: 8

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Rotina para verificar execução das fases de mensagens

    Alteracoes:
    ............................................................................. */
    DECLARE
    --Cursor para pegar informações para arquivo
      CURSOR cr_arquivo1 IS
        SELECT intipo
              ,nmfase
              ,MIN(nrseq_mensagem) nrseq_mensagem
              ,SUM(qtd_msg_atraso) qtd_msg_atraso
          FROM (
/*
                SELECT 1 intipo
                      ,c.nmfase
                      ,MIN(a.nrseq_mensagem) nrseq_mensagem
                      ,TRIM(TO_CHAR(COUNT(a.nrcontrole_if),'00000')) qtd_msg_atraso
                  FROM tbspb_msg_enviada      a
                      ,tbspb_msg_enviada_fase b
                      ,tbspb_fase_mensagem    c
                      ,tbspb_msg_enviada_fase d
                 WHERE b.nrseq_mensagem = a.nrseq_mensagem
                   AND b.cdfase         = c.cdfase
                   AND b.insituacao     = 'OK'
                   AND b.nrseq_mensagem = d.nrseq_mensagem
                   AND d.cdfase         = c.cdfase_anterior
                   AND b.dhmensagem     > TRUNC(SYSDATE)
                   AND b.dhmensagem     > nvl(c.dtultima_execucao, to_date('01/01/1900','dd/mm/yyyy'))
                   AND ((b.dhmensagem - d.dhmensagem) * 1440)
                                        > nvl(c.qttempo_alerta, 0)
                   AND b.cdfase         = pr_cdfase
                   AND a.nmmensagem    <> 'STR0007'
                 GROUP BY c.nmfase
                UNION
*/
                SELECT 2 intipo
                      ,c.nmfase
                      ,MIN(a.nrseq_mensagem) nrseq_mensagem
                      ,TRIM(TO_CHAR(COUNT(a.nrcontrole_if),'00000')) qtd_msg_atraso
                  FROM tbspb_msg_enviada      a
                      ,tbspb_msg_enviada_fase b
                      ,tbspb_fase_mensagem    c
                 WHERE b.nrseq_mensagem = a.nrseq_mensagem
                   AND b.cdfase         = c.cdfase_anterior
                   AND b.insituacao     = 'OK'
                   AND c.cdfase         = pr_cdfase
                   AND b.dhmensagem     > TRUNC(SYSDATE)
                   AND ((SYSDATE - b.dhmensagem) * 1440)
                                        > nvl(c.qttempo_alerta, 0)
                   AND NOT EXISTS (SELECT 1
                                     FROM tbspb_msg_enviada_fase bb
                                    WHERE bb.nrseq_mensagem = b.nrseq_mensagem
                                      AND bb.cdfase         = c.cdfase)
                   AND a.nmmensagem    <> 'STR0007'
                 GROUP BY c.nmfase)
          GROUP BY nmfase,intipo
        UNION ALL
        SELECT intipo
              ,nmfase
              ,MIN(nrseq_mensagem) nrseq_mensagem
              ,SUM(qtd_msg_atraso) qtd_msg_atraso
          FROM (
/*
                SELECT 1 intipo
                      ,c.nmfase
                      ,MIN(a.nrseq_mensagem) nrseq_mensagem
                      ,TRIM(TO_CHAR(COUNT(a.nrcontrole_str_pag),'00000')) qtd_msg_atraso
                  FROM tbspb_msg_recebida      a
                      ,tbspb_msg_recebida_fase b
                      ,tbspb_fase_mensagem     c
                      ,tbspb_msg_recebida_fase d
                 WHERE b.nrseq_mensagem = a.nrseq_mensagem
                   AND b.cdfase         = c.cdfase
                   AND b.insituacao     = 'OK'
                   AND b.nrseq_mensagem = d.nrseq_mensagem
                   AND d.cdfase         = c.cdfase_anterior
                   AND b.dhmensagem     > TRUNC(SYSDATE)
                   AND b.dhmensagem     > nvl(c.dtultima_execucao, to_date('01/01/1900','dd/mm/yyyy'))
                   AND ((b.dhmensagem - d.dhmensagem) * 1440)
                                        > nvl(c.qttempo_alerta, 0)
                   AND b.cdfase         = pr_cdfase
                   AND a.nmmensagem    <> 'STR0007'
                 GROUP BY c.nmfase
                UNION
*/
                SELECT 2 intipo
                      ,c.nmfase
                      ,MIN(a.nrseq_mensagem) nrseq_mensagem
                      ,TRIM(TO_CHAR(COUNT(a.nrcontrole_str_pag),'00000')) qtd_msg_atraso
                  FROM tbspb_msg_recebida      a
                      ,tbspb_msg_recebida_fase b
                      ,tbspb_fase_mensagem     c
                 WHERE b.nrseq_mensagem = a.nrseq_mensagem
                   AND b.cdfase         = c.cdfase_anterior
                   AND b.insituacao     = 'OK'
                   AND c.cdfase         = pr_cdfase
                   AND b.dhmensagem     > TRUNC(SYSDATE)
                   AND ((SYSDATE - b.dhmensagem) * 1440)
                                        > nvl(c.qttempo_alerta, 0)
                   AND NOT EXISTS (SELECT 1
                                     FROM tbspb_msg_recebida_fase bb
                                    WHERE bb.nrseq_mensagem = b.nrseq_mensagem
                                      AND (bb.cdfase        = c.cdfase
                                        OR bb.cdfase        = DECODE(c.cdfase,115,992,c.cdfase) -- para mensagens não tratadas no PC_CRPS531_1 a fase 115 passa a ser 992 ou 999
                                        OR bb.cdfase        = DECODE(c.cdfase,115,999,c.cdfase)))
                   AND a.nmmensagem    <> 'STR0007'
                 GROUP BY c.nmfase)
          GROUP BY nmfase,intipo;
    rw_arquivo1 cr_arquivo1%ROWTYPE;

    --Cursor para pegar informações para arquivo
      CURSOR cr_arquivo2(pr_nrseq_mensagem tbspb_msg_enviada.nrseq_mensagem%type) IS
/*
        SELECT a.nmmensagem
              ,TO_CHAR(b.dhmensagem,'HH24:MI:SS') hra_mensagem
              ,TO_CHAR(d.dhmensagem,'HH24:MI:SS') hra_mensagem_ant
              ,((b.dhmensagem - d.dhmensagem) * 1440) qtd_min_atraso
              ,TO_CHAR(TRUNC((((b.dhmensagem - d.dhmensagem) * 1440) * 60) / 3600), 'FM9900') || ':' ||
               TO_CHAR(TRUNC(MOD((((b.dhmensagem - d.dhmensagem) * 1440) * 60), 3600) / 60), 'FM00') || ':' ||
               TO_CHAR(MOD((((b.dhmensagem - d.dhmensagem) * 1440) * 60), 60), 'FM00') tempo_formatado
              ,a.nrcontrole_if
          FROM tbspb_msg_enviada      a
              ,tbspb_msg_enviada_fase b
              ,tbspb_fase_mensagem    c
              ,tbspb_msg_enviada_fase d
         WHERE b.nrseq_mensagem = a.nrseq_mensagem
           AND b.cdfase         = c.cdfase
           AND b.insituacao     = 'OK'
           AND b.nrseq_mensagem = d.nrseq_mensagem
           AND d.cdfase         = c.cdfase_anterior
           AND b.dhmensagem     > TRUNC(SYSDATE)
           AND b.dhmensagem     > nvl(c.dtultima_execucao, to_date('01/01/1900','dd/mm/yyyy'))
           AND ((b.dhmensagem - d.dhmensagem) * 1440)
                                > nvl(c.qttempo_alerta, 0)
           AND b.cdfase         = pr_cdfase
           AND a.nrseq_mensagem = pr_nrseq_mensagem
           AND a.nmmensagem    <> 'STR0007'
        UNION
*/
        SELECT a.nmmensagem
              ,'00:00:00' hra_mensagem
              ,TO_CHAR(b.dhmensagem,'HH24:MI:SS') hra_mensagem_ant
              ,((SYSDATE - b.dhmensagem) * 1440) qtd_min_atraso
              ,TO_CHAR(TRUNC((((SYSDATE - b.dhmensagem) * 1440) * 60) / 3600), 'FM9900') || ':' ||
               TO_CHAR(TRUNC(MOD((((SYSDATE - b.dhmensagem) * 1440) * 60), 3600) / 60), 'FM00') || ':' ||
               TO_CHAR(MOD((((SYSDATE - b.dhmensagem) * 1440) * 60), 60), 'FM00') tempo_formatado
              ,a.nrcontrole_if
          FROM tbspb_msg_enviada      a
              ,tbspb_msg_enviada_fase b
              ,tbspb_fase_mensagem    c
         WHERE b.nrseq_mensagem = a.nrseq_mensagem
           AND b.cdfase         = c.cdfase_anterior
           AND b.insituacao     = 'OK'
           AND c.cdfase         = pr_cdfase
           AND b.dhmensagem     > TRUNC(SYSDATE)
           AND ((SYSDATE - b.dhmensagem) * 1440)
                                > nvl(c.qttempo_alerta, 0)
           AND a.nrseq_mensagem = pr_nrseq_mensagem
           AND NOT EXISTS (SELECT 1
                             FROM tbspb_msg_enviada_fase bb
                            WHERE bb.nrseq_mensagem = b.nrseq_mensagem
                              AND bb.cdfase         = c.cdfase)
           AND a.nmmensagem    <> 'STR0007'
      UNION ALL
/*
        SELECT a.nmmensagem
              ,TO_CHAR(b.dhmensagem,'HH24:MI:SS') hra_mensagem
              ,TO_CHAR(d.dhmensagem,'HH24:MI:SS') hra_mensagem_ant
              ,((b.dhmensagem - d.dhmensagem) * 1440) qtd_min_atraso
              ,TO_CHAR(TRUNC((((b.dhmensagem - d.dhmensagem) * 1440) * 60) / 3600), 'FM9900') || ':' ||
               TO_CHAR(TRUNC(MOD((((b.dhmensagem - d.dhmensagem) * 1440) * 60), 3600) / 60), 'FM00') || ':' ||
               TO_CHAR(MOD((((b.dhmensagem - d.dhmensagem) * 1440) * 60), 60), 'FM00') tempo_formatado
              ,a.nrcontrole_str_pag nrcontrole_if
          FROM tbspb_msg_recebida      a
              ,tbspb_msg_recebida_fase b
              ,tbspb_fase_mensagem     c
              ,tbspb_msg_recebida_fase d
         WHERE b.nrseq_mensagem     = a.nrseq_mensagem
           AND b.cdfase             = c.cdfase
           AND b.nrseq_mensagem     = d.nrseq_mensagem
           AND d.cdfase             = c.cdfase_anterior
           AND b.dhmensagem         > TRUNC(SYSDATE)
           AND b.dhmensagem         > nvl(c.dtultima_execucao, to_date('01/01/1900','dd/mm/yyyy'))
           AND ((b.dhmensagem - d.dhmensagem) * 1440)
                                    > nvl(c.qttempo_alerta, 0)
           AND b.cdfase             = pr_cdfase
           AND a.nrseq_mensagem     = pr_nrseq_mensagem
           AND a.nmmensagem        <> 'STR0007'
        UNION
*/
        SELECT a.nmmensagem
              ,'00:00:00' hra_mensagem
              ,TO_CHAR(b.dhmensagem,'HH24:MI:SS') hra_mensagem_ant
              ,((SYSDATE - b.dhmensagem) * 1440) qtd_min_atraso
              ,TO_CHAR(TRUNC((((SYSDATE - b.dhmensagem) * 1440) * 60) / 3600), 'FM9900') || ':' ||
               TO_CHAR(TRUNC(MOD((((SYSDATE - b.dhmensagem) * 1440) * 60), 3600) / 60), 'FM00') || ':' ||
               TO_CHAR(MOD((((SYSDATE - b.dhmensagem) * 1440) * 60), 60), 'FM00') tempo_formatado
              ,a.nrcontrole_str_pag nrcontrole_if
          FROM tbspb_msg_recebida      a
              ,tbspb_msg_recebida_fase b
              ,tbspb_fase_mensagem     c
         WHERE b.nrseq_mensagem     = a.nrseq_mensagem
           AND b.cdfase             = c.cdfase_anterior
           AND c.cdfase             = pr_cdfase
           AND b.dhmensagem         > TRUNC(SYSDATE)
           AND a.nrseq_mensagem     = pr_nrseq_mensagem
           AND NOT EXISTS (SELECT 1
                             FROM tbspb_msg_recebida_fase bb
                            WHERE bb.nrseq_mensagem = b.nrseq_mensagem
                              AND (bb.cdfase        = c.cdfase
                                OR bb.cdfase        = DECODE(c.cdfase,115,992,c.cdfase) -- para mensagens não tratadas no PC_CRPS531_1 a fase 115 passa a ser 992 ou 999
                                OR bb.cdfase        = DECODE(c.cdfase,115,999,c.cdfase)))
           AND a.nmmensagem        <> 'STR0007';
    rw_arquivo2 cr_arquivo2%ROWTYPE;

    --Cursor para pegar informações para arquivo
      CURSOR cr_arquivo3 IS
        SELECT SUM(qtd_msg_total) qtd_msg_total
          FROM (SELECT SUM(qtd_msg_total) qtd_msg_total
          FROM (SELECT TRIM(TO_CHAR(COUNT(a.nrcontrole_if),'00000')) qtd_msg_total
                  FROM tbspb_msg_enviada      a
                      ,tbspb_msg_enviada_fase b
                      ,tbspb_fase_mensagem    c
                      ,tbspb_msg_enviada_fase d
                 WHERE b.nrseq_mensagem = a.nrseq_mensagem
                   AND b.cdfase         = c.cdfase
                   AND b.insituacao     = 'OK'
                   AND b.nrseq_mensagem = d.nrseq_mensagem
                   AND d.cdfase         = c.cdfase_anterior
                   AND b.dhmensagem     > TRUNC(SYSDATE)
                   AND b.dhmensagem     > nvl(c.dtultima_execucao, to_date('01/01/1900','dd/mm/yyyy'))
                   AND b.cdfase         = pr_cdfase
                UNION
                SELECT TRIM(TO_CHAR(COUNT(a.nrcontrole_if),'00000')) qtd_msg_total
                  FROM tbspb_msg_enviada      a
                      ,tbspb_msg_enviada_fase b
                      ,tbspb_fase_mensagem    c
                 WHERE b.nrseq_mensagem = a.nrseq_mensagem
                   AND b.cdfase         = c.cdfase_anterior
                   AND b.insituacao     = 'OK'
                   AND b.dhmensagem     > TRUNC(SYSDATE)
                   AND c.cdfase         = pr_cdfase
                   AND NOT EXISTS (SELECT 1
                                     FROM tbspb_msg_enviada_fase bb
                                    WHERE bb.nrseq_mensagem = b.nrseq_mensagem
                                              AND bb.cdfase         = c.cdfase)
                           AND a.nmmensagem    <> 'STR0007')
      UNION ALL
        SELECT SUM(qtd_msg_total) qtd_msg_total
          FROM (SELECT TRIM(TO_CHAR(COUNT(a.nrcontrole_str_pag),'00000')) qtd_msg_total
                  FROM tbspb_msg_recebida      a
                      ,tbspb_msg_recebida_fase b
                      ,tbspb_fase_mensagem     c
                      ,tbspb_msg_recebida_fase d
                 WHERE b.nrseq_mensagem = a.nrseq_mensagem
                   AND b.cdfase         = c.cdfase
                   AND b.insituacao     = 'OK'
                   AND b.nrseq_mensagem = d.nrseq_mensagem
                   AND d.cdfase         = c.cdfase_anterior
                   AND b.dhmensagem     > TRUNC(SYSDATE)
                   AND b.dhmensagem     > nvl(c.dtultima_execucao, to_date('01/01/1900','dd/mm/yyyy'))
                   AND b.cdfase         = pr_cdfase
                UNION
                SELECT TRIM(TO_CHAR(COUNT(a.nrcontrole_str_pag),'00000')) qtd_msg_total
                  FROM tbspb_msg_recebida      a
                      ,tbspb_msg_recebida_fase b
                      ,tbspb_fase_mensagem     c
                 WHERE b.nrseq_mensagem = a.nrseq_mensagem
                   AND b.cdfase         = c.cdfase_anterior
                   AND b.insituacao     = 'OK'
                   AND c.cdfase         = pr_cdfase
                   AND b.dhmensagem     > TRUNC(SYSDATE)
                   AND NOT EXISTS (SELECT 1
                                     FROM tbspb_msg_recebida_fase bb
                                    WHERE bb.nrseq_mensagem = b.nrseq_mensagem
                                              AND (bb.cdfase        = c.cdfase
                                                OR bb.cdfase        = DECODE(c.cdfase,115,992,c.cdfase) -- para mensagens não tratadas no PC_CRPS531_1 a fase 115 passa a ser 992 ou 999
                                                OR bb.cdfase        = DECODE(c.cdfase,115,999,c.cdfase)))
                           AND a.nmmensagem    <> 'STR0007')
                                                );
    rw_arquivo3 cr_arquivo3%ROWTYPE;
    --
    vr_cdcritic crapcri.cdcritic%TYPE;
    vr_dscritic crapcri.dscritic%TYPE;

    --Controle de erro
    vr_exc_erro EXCEPTION;
    --
    BEGIN
      -- Carregar arquivo com a tabela tbspb_fase_mensagem
      FOR rw_arquivo1 in cr_arquivo1 LOOP
        --
        -- Se a qtd de atrasos for maior ou igual a qtd de alertas da tabela de fases
        IF rw_arquivo1.qtd_msg_atraso >= pr_qtalerta THEN
          --
          -- verifica tempo primeira mensagem atrasada
          OPEN cr_arquivo2(rw_arquivo1.nrseq_mensagem);
          FETCH cr_arquivo2 INTO rw_arquivo2;

          -- Se não existe
          IF cr_arquivo2%NOTFOUND THEN
              -- Fecha cursor
              CLOSE cr_arquivo2;
              -- Gera crítica
              vr_cdcritic := 0;
              vr_dscritic := 'Primeiro mensagem atrasada não encontrada!';
              -- Levanta exceção
              RAISE vr_exc_erro;
          END IF;
          -- Fecha cursor
          CLOSE cr_arquivo2;
          --
          -- verifica quantidade total mensagens
          OPEN cr_arquivo3;
          FETCH cr_arquivo3 INTO rw_arquivo3;

          -- Se não existe
          IF cr_arquivo3%NOTFOUND THEN
              -- Fecha cursor
              CLOSE cr_arquivo3;
              -- Gera crítica
              vr_cdcritic := 0;
              vr_dscritic := 'Quantidade total de msgs não encontrada!';
              -- Levanta exceção
              RAISE vr_exc_erro;
          END IF;
          -- Fecha cursor
          CLOSE cr_arquivo3;
          --
        END IF;
        --
        vr_linha := RPAD(SUBSTR(rw_arquivo1.nmfase,1,30),30) ||'|'||
                    RPAD(SUBSTR(pr_nmfase_anterior,1,30),30) ||'|'||
                    RPAD(rw_arquivo2.nmmensagem         ,20) ||'|'||
                    RPAD(rw_arquivo2.nrcontrole_if      ,20) ||'|'||
                    RPAD(rw_arquivo2.hra_mensagem_ant   ,11) ||'|'||
                    RPAD(rw_arquivo2.tempo_formatado    ,12) ||'|'||
                    LPAD(rw_arquivo1.qtd_msg_atraso     ,14) ||'|';
        --
        pc_adiciona_arquivo(pr_linha        => vr_linha
                           ,pr_abre_arquivo => 'NAO'
                           ,pr_cdcritic     => vr_cdcritic
                           ,pr_dscritic     => vr_dscritic);
        --
        IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) is not null THEN
          RAISE vr_exc_erro;
        END IF;
        --
      END LOOP;
      --
      BEGIN
        UPDATE tbspb_fase_mensagem a
           SET a.dtultima_execucao = vr_data_execucao
         WHERE a.cdfase = pr_cdfase;
      EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao alterar tbspb_fase_mensagem - '||sqlerrm;
        RAISE vr_exc_erro;
      END;
      --
      --
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Erro
        IF vr_cdcritic <> 0 THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na SSPB0004.pc_executa_fase_mensagem.' || SQLERRM;
    END;
  END pc_executa_fase_mensagem;

  PROCEDURE pc_adiciona_arquivo(pr_linha        IN VARCHAR2                  --> Mensagem aviso Nagios
                               ,pr_abre_arquivo IN VARCHAR2                  --> Abre aquivo (SIM/NAO)
                               ,pr_cdcritic    OUT crapcri.cdcritic%TYPE     --> Codigo do erro
                               ,pr_dscritic    OUT crapcri.dscritic%TYPE) IS --> Mensagem do erro
  BEGIN
    /* .............................................................................
    Programa: pc_adiciona_arquivo
    Sistema : Conta-Corrente - Cooperativa de Credito
    Sigla   : CRED
    Autor   : Everton Souza_Mouts
    Data    : 19/07/2018                        Ultima atualizacao:

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado
    Objetivo  : Gerar arquivo de mensagens de alerta Nagios

    Alteracoes:
    ............................................................................. */
    DECLARE

      -- Variaveis de erro
      vr_cdcritic crapcri.cdcritic%TYPE;
      vr_dscritic crapcri.dscritic%TYPE;
      -- Controle de erro
      vr_exc_erro      EXCEPTION;

    BEGIN
      --
      IF pr_abre_arquivo = 'SIM' THEN
        vr_dircop_log := gene0001.fn_diretorio(pr_tpdireto => 'C', pr_cdcooper => 3)||'/nagios';
        vr_nom_arquivo := 'SPB_OCORRENCIAS_'||TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS')||'.txt';
        vr_ind_modo_abertura := 'W'; --> W_Write, A=Append
        --
        -- Tenta abrir o arquivo
        gene0001.pc_abre_arquivo(pr_nmdireto => vr_dircop_log         --> Diretório do arquivo
                                ,pr_nmarquiv => vr_nom_arquivo        --> Nome do arquivo
                                ,pr_tipabert => vr_ind_modo_abertura  --> Modo de abertura (R,W,A)
                                ,pr_utlfileh => vr_ind_arqlog         --> Handle do arquivo aberto
                                ,pr_des_erro => vr_dscritic);
        IF vr_dscritic IS NOT NULL THEN
          vr_cdcritic := 0;
          RAISE vr_exc_erro;
        END IF;
      END IF;
      -- Adiciona a linha de log
      BEGIN
        gene0001.pc_escr_linha_arquivo(vr_ind_arqlog,pr_linha);
      EXCEPTION
        WHEN OTHERS THEN
          -- Retornar erro
          vr_dscritic := 'Problema ao escrever no arquivo <'||vr_dircop_log||'/'||vr_nom_arquivo||'>: ' || sqlerrm;
          RAISE vr_exc_erro;
      END;
      --
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Erro
        IF vr_cdcritic <> 0 THEN
            pr_cdcritic := vr_cdcritic;
            pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        ELSE
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := vr_dscritic;
        END IF;

      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na SSPB0004.pc_adiciona_arquivo.' || SQLERRM;
    END;
  END pc_adiciona_arquivo;
  --
END SSPB0004;
/
