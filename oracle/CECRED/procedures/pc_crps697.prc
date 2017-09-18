CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS697(pr_cdcooper IN  crapcop.cdcooper%TYPE  --> Codigo da cooperativa
                                             ,pr_flgresta IN  PLS_INTEGER            --> Indicador para utilização de restart
                                             ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                             ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                             ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                             ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
BEGIN

    /*..............................................................................

     Programa: pc_crps697
     Sistema : Mensagens - Internet Bank
     Sigla   : CRED
     Autor   : Carlos Rafael Tanholi
     Data    : Setembro/2015                       Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Diaria.

     Objetivo  : Criacao de mensagens no Internet Bank para GPS (Guias da Previdencia Social)

     Alterações: 29/12/2015 - Incluso tratamento 'DD/MM/YYYY' ao usar o to_date (Daniel)

	             04/10/2016 - Ajuste erro encontrado na execução do processo Batch (Daniel)
    ...............................................................................*/

    DECLARE

    ------------------------------- VARIAVEIS -------------------------------
    -- Código do programa
    vr_cdprogra   CONSTANT crapprg.cdprogra%TYPE := 'CRPS697';
    -- Tratamento de erros
    vr_exc_erro   EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
    vr_des_erro   VARCHAR2(4000);
    -- Rowid de retorno lançamento de tarifa
    vr_rowid      ROWID;
    -- variaveis de LOG
    vr_dsassunto    VARCHAR2(300);
    vr_dsmensagem   VARCHAR2(1000);

    vr_dtmvtolt crapdat.dtmvtolt%TYPE;
    vr_dtmvtopr crapdat.dtmvtopr%TYPE;
    vr_nmrescop crapcop.nmrescop%TYPE;

    -------------------------- TABELAS TEMPORARIAS --------------------------
    -- Tabela Temporaria para erros
    vr_tab_erro GENE0001.typ_tab_erro;


    ------------------------------- CURSORES --------------------------------
    -- Cursor Genérico de Calendário
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;

    -- cursor para verificar se existem agendamentos pendentes e nao pagos
    CURSOR cr_count_gps (p_cdcooper IN crapcop.cdcooper%TYPE
                        ,p_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
    SELECT lgp.nrctapag
          ,lgp.cddpagto
          ,lgp.cdidenti
          ,lgp.vlrtotal
          ,COUNT(lgp.nrctapag) "COUNT"
      FROM tbinss_agendamento_gps gps,
           craplgp lgp
     WHERE gps.cdcooper   = p_cdcooper
       AND gps.insituacao = 0 -- FIXO (0 - Agendadas)
       AND lgp.cdcooper   = gps.cdcooper
       AND lgp.nrctapag   = gps.nrdconta
       AND lgp.nrseqagp   = gps.nrseqagp
       AND lgp.flgpagto   = 0  -- FIXO (0 - Não Efetivado)       
       AND (p_dtmvtolt - NVL(gps.dtultimo_aviso,to_date('01/01/'|| TO_CHAR(p_dtmvtolt, 'RRRR'),'DD/MM/YYYY'))) > 10 -- Verificar a data do ultimo aviso é superior a 10 dias
     GROUP BY lgp.nrctapag
             ,lgp.cddpagto
             ,lgp.cdidenti
             ,lgp.vlrtotal
    HAVING COUNT(lgp.nrctapag) <= 2 -- Onde possuem 2 ou menos agendamentos restantes.
     ORDER BY lgp.nrctapag ASC, "COUNT" DESC;
    rw_count_gps cr_count_gps%ROWTYPE;


    -- cursor para recuperar os dados do agendamento
    CURSOR cr_dados_gps(p_cdcooper IN crapcop.cdcooper%TYPE
                       ,p_nrdconta IN craplgp.nrctapag%TYPE
                       ,p_cddpagto IN craplgp.cddpagto%TYPE
                       ,p_cdidenti IN craplgp.cdidenti%TYPE
                       ,p_vlrtotal IN craplgp.vlrtotal%TYPE) IS
    SELECT gps.rowid
      FROM tbinss_agendamento_gps gps ,craplgp lgp
     WHERE lgp.cdcooper   = p_cdcooper
       AND lgp.nrctapag   = p_nrdconta
       AND lgp.cddpagto   = p_cddpagto
       AND lgp.cdidenti   = p_cdidenti
       AND lgp.vlrtotal   = p_vlrtotal
       AND lgp.flgpagto   = 0  -- FIXO (0 - Não Efetivado)   
       AND gps.cdcooper   = lgp.cdcooper
       AND gps.nrdconta   = lgp.nrctapag
       AND gps.nrseqagp   = lgp.nrseqagp
       AND gps.insituacao = 0 -- FIXO (0 - Agendadas)
       ;
     rw_dados_gps cr_dados_gps%ROWTYPE;



    -- verifica se alguma conta teve algum agendamento de GPS pago no ano que passou
    CURSOR cr_mensal_gps(pr_cdcooper IN crapcop.cdcooper%TYPE
                        ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
    SELECT gps.nrdconta
          ,COUNT(gps.nrseqagp) "COUNT"
      FROM tbinss_agendamento_gps gps
     WHERE gps.cdcooper   = pr_cdcooper
       AND gps.insituacao = 2 -- 2-Pagas
       AND gps.dtagendamento >= to_date('01/01/'|| TO_CHAR(pr_dtmvtolt, 'RRRR'),'DD/MM/YYYY') -- 01/01/ do ano da pr_dtmvtolt (ano que finalizou)
       AND gps.dtagendamento <= to_date('31/12/'|| TO_CHAR(pr_dtmvtolt, 'RRRR'),'DD/MM/YYYY') -- 31/12/ do ano da pr_dtmvtolt (ano que finalizou)
     GROUP BY gps.nrdconta
    HAVING COUNT(gps.nrdconta) >= 1;
    rw_mensal_gps cr_mensal_gps%ROWTYPE;


    -- cursor para listar mensagens pendentes do ano anterior
    CURSOR cr_pendentes_gps(pr_cdcooper IN crapcop.cdcooper%TYPE
                           ,pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
    SELECT gps.rowid
          ,gps.nrdconta
      FROM tbinss_agendamento_gps gps
     WHERE gps.cdcooper   = pr_cdcooper
       AND gps.insituacao = 0 -- FIXO 0 - Agendadas
       AND gps.dtagendamento >= to_date('01/01/'||TO_CHAR(pr_dtmvtolt, 'RRRR'),'DD/MM/YYYY') -- 01/01/ do ano da pr_dtmvtolt (ano que finalizou)
       AND gps.dtagendamento <= to_date('31/12/'||TO_CHAR(pr_dtmvtolt, 'RRRR'),'DD/MM/YYYY'); -- 31/12/ do ano da pr_dtmvtolt (ano que finalizou)
    rw_pendentes_gps cr_pendentes_gps%ROWTYPE;


    -- cursor de cooperativa
    CURSOR cr_crapcop(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT nmrescop
      FROM crapcop
     WHERE cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;


    BEGIN

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

      OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
      FETCH cr_crapcop INTO rw_crapcop;
      -- Se não encontrar
      IF cr_crapcop%NOTFOUND THEN
        -- Fechar o cursor pois efetuaremos raise
        CLOSE cr_crapcop;
        -- Montar mensagem de critica
        vr_cdcritic := 1;
        RAISE vr_exc_erro;
      ELSE
        vr_nmrescop := rw_crapcop.nmrescop;
        -- Apenas fechar o cursor
        CLOSE cr_crapcop;
      END IF;

      vr_dtmvtolt := rw_crapdat.dtmvtolt;
      vr_dtmvtopr := rw_crapdat.dtmvtopr;

      -- processo mensal (mês da dtmvtolt diferente do mês da dtmvtopr)
      -- e o mês da dtmvtopr  for JANEIRO
      IF (TO_CHAR(vr_dtmvtolt, 'MM') <> TO_CHAR(vr_dtmvtopr, 'MM') ) 
      AND TO_CHAR(vr_dtmvtopr, 'MM') = '01' THEN
        --
        FOR rw_mensal_gps IN cr_mensal_gps( pr_cdcooper => pr_cdcooper,
                                            pr_dtmvtolt => vr_dtmvtolt)
          LOOP
            vr_dsassunto := 'Guia Previdência Social – Agendamentos para ' || TO_CHAR(vr_dtmvtopr, 'RRRR');

            vr_dsmensagem := 'Novos agendamentos de GPS para ' || TO_CHAR(vr_dtmvtopr, 'RRRR') ||
                             '.</br></br>Você cooperado, que efetuou agendamentos e pagamentos de GPS para o ano de ' ||
                             TO_CHAR(vr_dtmvtolt, 'RRRR') || ', esta mensagem é para lembrá-lo de fazer novos agendamentos para ' ||
                             TO_CHAR(vr_dtmvtopr, 'RRRR') || ', e também salientar que os novos agendamentos devem ser ' ||
                             'realizados com base no reajuste do salário mínimo.';

            GENE0003.pc_gerar_mensagem(pr_cdcooper => pr_cdcooper,
                                       pr_nrdconta => rw_mensal_gps.nrdconta,
                                       pr_idseqttl => 1, -- fixo Primeiro titular
                                       pr_cdprogra => 'CRPS697',
                                       pr_inpriori => 0,
                                       pr_dsdmensg => vr_dsmensagem,
                                       pr_dsdassun => vr_dsassunto,
                                       pr_dsdremet => vr_nmrescop,
                                       pr_dsdplchv => 'GPS',
                                       pr_cdoperad => '1',
                                       pr_cdcadmsg => '0',
                                       pr_dscritic => vr_dscritic);


            IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
              -- Envio centralizado de log de erro
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                        ,pr_ind_tipo_log => 2 -- Erro tratato
                                        ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                            || vr_cdprogra || ' --> '
                                                            || vr_cdcritic || ' - '
                                                            || vr_dscritic );

            ELSE -- se nao gerar erro na criacao de avisos
              COMMIT;
            END IF;

          END LOOP;

          -- processa Agendamentos pendentes e desativa
          FOR rw_pendentes_gps IN cr_pendentes_gps(pr_cdcooper => pr_cdcooper,
                                                   pr_dtmvtolt => vr_dtmvtolt)
            LOOP
              -- rotina que fara o processo de desativacao da mensagem
              INSS0002.pc_gps_agmto_desativar(pr_cdcooper => pr_cdcooper,
                                              pr_nrdconta => rw_pendentes_gps.nrdconta,
                                              pr_idorigem => 1,
                                              pr_cdoperad => '1',
                                              pr_nmdatela => 'AYLLOS',
                                              pr_dsdrowid => rw_pendentes_gps.rowid,
                                              pr_nrcpfope => 0, 
                                              pr_dscritic => vr_dscritic);

              IF TRIM(vr_dscritic) IS NOT NULL THEN
                -- Envio centralizado de log de erro
                btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                          ,pr_ind_tipo_log => 2 -- Erro tratato
                                          ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                              || vr_cdprogra || ' --> '
                                                              || vr_dscritic );
              END IF;

          END LOOP;

      ELSE -- Não é virada de Ano
        -- Verificar se tem 1 ou 2 agendamentos pendentes
        FOR rw_count_gps IN cr_count_gps( p_cdcooper => pr_cdcooper,
                                          p_dtmvtolt => vr_dtmvtolt)
         LOOP
              vr_dsassunto := 'Guia Previdência Social - Vencimento de Agendamentos';

              -- Se o mês atual for Outubro ou Novembro: gravar valor para a variável “Mensagem”:
              IF TO_CHAR(vr_dtmvtolt, 'MM') IN ('10','11') THEN
                vr_dsmensagem := 'O Pagamento de GPS para o Identificador: ' || rw_count_gps.cdidenti ||
                                 ' no valor de R$ ' || TO_CHAR(rw_count_gps.vlrtotal,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.') ||
                                 ' possui apenas '  || rw_count_gps.count || ' agendamento(s) pendente(s).' ||
                                 '</br></br>Novos agendamentos deverão ser realizados a partir de Jan/'  || to_char(add_months(vr_dtmvtolt,12),'RRRR') ||
                                 ', acessando o link Transações -> Guia Previdência Social -> Agendamentos de GPS.' ||
                                 '</br>Salientamos que os novos agendamentos de GPS devem ser realizados com base no reajuste do salário mínimo.' ||
                                 '</br></br>Caso não sejam realizados novos agendamentos, não haverá mais a contribuição para ' ||
                                 'a Previdência Social.';
              ELSE
                vr_dsmensagem := 'O Pagamento de GPS para o Identificador: ' || rw_count_gps.cdidenti ||
                                 ' no valor de R$ ' || TO_CHAR(rw_count_gps.vlrtotal,'FM9G999G999G999G990D00','NLS_NUMERIC_CHARACTERS=,.') ||
                                 ' possui apenas '  || rw_count_gps.count || ' agendamento(s) pendente(s).' ||
                                 '</br></br>Se desejar realizar novos agendamentos, clique em Transações -> Guia Previdência Social -> Agendamentos de GPS.' ||
                                 '</br></br>Caso não sejam realizados novos agendamentos, não haverá mais a contribuição para a Previdência Social.';
              END IF;


              GENE0003.pc_gerar_mensagem(pr_cdcooper => pr_cdcooper,
                                         pr_nrdconta => rw_count_gps.nrctapag ,
                                         pr_idseqttl => 1, -- fixo Primeiro titular
                                         pr_cdprogra => 'CRPS697',
                                         pr_inpriori => 0,
                                         pr_dsdmensg => vr_dsmensagem,
                                         pr_dsdassun => vr_dsassunto,
                                         pr_dsdremet => vr_nmrescop,
                                         pr_dsdplchv => 'GPS',
                                         pr_cdoperad => '1',
                                         pr_cdcadmsg => '0',
                                         pr_dscritic => vr_dscritic);

              IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
                -- Envio centralizado de log de erro
                btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                          ,pr_ind_tipo_log => 2 -- Erro tratato
                                          ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                              || vr_cdprogra || ' --> '
                                                              || vr_cdcritic || ' - '
                                                              || vr_dscritic );

              ELSE -- se nao gerar erro na criacao de avisos, atualizar Dt Ultimo Aviso
                
                FOR rw_dados_gps IN cr_dados_gps(p_cdcooper => pr_cdcooper
                                                ,p_nrdconta => rw_count_gps.nrctapag
                                                ,p_cddpagto => rw_count_gps.cddpagto
                                                ,p_cdidenti => rw_count_gps.cdidenti
                                                ,p_vlrtotal => rw_count_gps.vlrtotal)
                  LOOP
                    BEGIN
                      -- atualiza a data do ultimo aviso
                      UPDATE tbinss_agendamento_gps gps
                         SET gps.dtultimo_aviso = vr_dtmvtolt
                       WHERE gps.rowid = rw_dados_gps.rowid;
                    END;                  
                  
                END LOOP;

              END IF;

         END LOOP;

      END IF; -- IF ( vr_dtmvtolt <> vr_dtmvtopr )

    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 THEN
          -- Buscar a descrição
          pr_cdcritic := vr_cdcritic;
          pr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        ELSE
          pr_cdcritic := 0;
          pr_dscritic := vr_dscritic;
        END IF;
        -- Efetuar rollback
        ROLLBACK;
      WHEN OTHERS THEN
        -- Efetuar retorno do erro não tratado
        pr_cdcritic := 0;
        pr_dscritic := sqlerrm;
        -- Efetuar rollback
        ROLLBACK;
    END;

END PC_CRPS697;
/
