CREATE OR REPLACE PROCEDURE CECRED.PC_JOB_GPS(pr_cdcooper in crapcop.cdcooper%TYPE) IS

  /* ..........................................................................

   JOB: PC_JOB_GPS
   Sistema : Conta-Corrente - Cooperativa de Credito
   Autor   : Guilherme/SUPERO
   Data    : Outubro/2016.                     Ultima atualizacao: 01/12/2017

   Dados referentes ao programa:

   Frequencia: Bimestral
   Objetivo  : Excluir Guias GPS canceladas pelo sistema após 2 meses

   Alteracoes:
   
   01/12/2017 - Nome do job paralelo alterado para JBGPS_DEL_INAT_01$ pois a rotina
                generate_job_name suporta o nome até 18 caracteres não terminando
                em número (Carlos)
  ..........................................................................*/
      ------------------------- VARIAVEIS PRINCIPAIS ------------------------------
    vr_cdprogra    CONSTANT VARCHAR2(40) := 'PC_JOB_GPS';
    vr_des_reto    VARCHAR2(1000);
    vr_tab_erro    gene0001.typ_tab_erro;
    vr_cdcritic    PLS_INTEGER;
    vr_dscritic    VARCHAR2(4000);
    vr_dsplsql     VARCHAR2(2000);
    vr_jobname     VARCHAR2(30);
    vr_minuto      NUMBER;

    vr_exc_erro    EXCEPTION;

    -- Variáveis de controle de calendário
    rw_crapdat     BTCH0001.cr_crapdat%ROWTYPE;

    --> Buscar todas as cooperativas ativas
    CURSOR cr_crapcop IS
      SELECT cop.cdcooper
        FROM crapcop cop
       WHERE cop.flgativo = 1
         AND cop.cdcooper <> 3 -- Não deve rodar para a CECRED
       ORDER BY cop.cdcooper;


    /******************************/
    --> LOG de execucao
    PROCEDURE pc_gera_log_execucao(pr_dsexecut  IN VARCHAR2,
                                   pr_cdcooper  IN INTEGER,
                                   pr_dtmvtolt  IN DATE) IS
      vr_nmarqlog VARCHAR2(500);
      vr_desdolog VARCHAR2(2000);

    BEGIN

      --> Definir nome do log
      vr_nmarqlog := 'gpsjob.log';
      --> Definir descrição do log
      vr_desdolog := 'JOB GPS - '||to_char(pr_dtmvtolt,'DD/MM/YYYY')||' - '||to_char(SYSDATE,'HH24:MI:SS')||
                     ' [Exclusao Guias Inativas] - Coop: '|| pr_cdcooper ||' - '||pr_dsexecut;

      -- Gera o Log
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 1,
                                 pr_des_log      => vr_desdolog,
                                 pr_nmarqlog     => vr_nmarqlog);

    END pc_gera_log_execucao;
    /******************************/

  BEGIN

    --> Se for coop 3, deve criar o job para cada coop
    IF pr_cdcooper = 3 THEN

      --> Buscar as cooperativas
      FOR rw_crapcop IN cr_crapcop LOOP

        -- Verificação do calendário
        OPEN  BTCH0001.cr_crapdat(pr_cdcooper => rw_crapcop.cdcooper);
        FETCH BTCH0001.cr_crapdat INTO rw_crapdat;

        IF BTCH0001.cr_crapdat%NOTFOUND THEN
          CLOSE BTCH0001.cr_crapdat;
          -- Montar mensagem de critica
          vr_cdcritic:= 1;
          vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

          -- Forma a frase de erro para incluir no log
          vr_dscritic:= 'Erro: '||vr_dscritic;

          RAISE vr_exc_erro;
        ELSE
          -- Apenas fechar o cursor
          CLOSE BTCH0001.cr_crapdat;
        END IF;

        -- Criar o nome para o job
        -- 15 chars + 2 (coop) + 1 ($) = 18 chars não terminando com número
        vr_jobname := 'JBGPS_DEL_INAT_'||LPAD(rw_crapcop.cdcooper,2,'0')||'$';

        vr_dsplsql := 'begin cecred.PC_JOB_GPS(pr_cdcooper => '||rw_crapcop.cdcooper ||'); end;';

        vr_minuto := 0; --(1/24/60); -- 1 minuto

        -- Faz a chamada ao programa paralelo atraves de JOB
        gene0001.pc_submit_job(pr_cdcooper  => rw_crapcop.cdcooper  --> Código da cooperativa
                              ,pr_cdprogra  => vr_cdprogra          --> Código do programa
                              ,pr_dsplsql   => vr_dsplsql           --> Bloco PLSQL a executar
                              ,pr_dthrexe   => TO_TIMESTAMP(to_char((SYSDATE + vr_minuto),'DD/MM/RRRR HH24:MI')||':'||to_char(rw_crapcop.cdcooper,'fm00'),
                                                                                          'DD/MM/RRRR HH24:MI:SS') --> Incrementar o tempo
                              ,pr_jobname   => vr_jobname           --> Nome randomico criado
                              ,pr_des_erro  => vr_dscritic);

        IF TRIM(vr_dscritic) is not null THEN
          vr_dscritic := 'Falha na criacao do Job (Coop:'||rw_crapcop.cdcooper||' Job: '||vr_jobname||'): '|| vr_dscritic;
          RAISE vr_exc_erro;
        END IF;

      END LOOP;

    -- Realizar a chamada da rotina para cada cooperativa
    ELSE -- TODAS AS OUTRAS COOPs (EXCETO 3)

      -- Verificação do calendário
      OPEN  BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;

      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        CLOSE BTCH0001.cr_crapdat;
        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);

        -- Forma a frase de erro para incluir no log
        vr_dscritic:= 'Erro: '||vr_dscritic;
        RAISE vr_exc_erro;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;


      -- Log de inicio de execucao
      pc_gera_log_execucao(pr_dsexecut  => 'Inicio execucao - Periodo <= '
                                           || to_char(add_months(rw_crapdat.dtmvtolt, -2))
                          ,pr_cdcooper  => pr_cdcooper
                          ,pr_dtmvtolt  => rw_crapdat.dtmvtolt);


      BEGIN
        DELETE craplgp lgp
         WHERE lgp.cdcooper  = pr_cdcooper
           AND lgp.idsicred  = 0  -- Guias Nao Autenticadas pelo Sicredi
           AND lgp.nrseqagp  > 0  -- Guias Agendadas
           AND lgp.flgativo  = 0  -- Apenas os que foram cancelados pelo processo
           AND EXISTS (SELECT 1
                         FROM craplau lau
                        WHERE lau.cdcooper = lgp.cdcooper
                          AND lau.nrdconta = lgp.nrctapag
                          AND lau.nrseqagp = lgp.nrseqagp
                          AND lau.dtdebito <= add_months(rw_crapdat.dtmvtolt, -2)) -- Inferior a 2 Meses atrás
          ;
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Job PC_JOB_GPS nao foi executado pois ocorreu erro '||
                         'ao excluir craplgp: '||SQLERRM;
          RAISE vr_exc_erro;
      END;

      pc_gera_log_execucao(pr_dsexecut  => ' => QTDE Guias Excluidas: ' || to_char(SQL%ROWCOUNT)
                          ,pr_cdcooper  => pr_cdcooper
                          ,pr_dtmvtolt  => rw_crapdat.dtmvtolt);


      -- Log de Termino de execucao
      pc_gera_log_execucao(pr_dsexecut  => 'Termino execucao'
                          ,pr_cdcooper  => pr_cdcooper
                          ,pr_dtmvtolt  => rw_crapdat.dtmvtolt);


    END IF; -- FIM IF COOP = 3

    -- Efetivar os dados
    COMMIT;

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Efetuar rollback
      ROLLBACK;

      -- Log de execução NOK
      pc_gera_log_execucao(pr_dsexecut  => vr_dscritic
                          ,pr_cdcooper  => pr_cdcooper
                          ,pr_dtmvtolt  => TRUNC(SYSDATE));

    WHEN OTHERS THEN
      vr_dscritic := SQLERRM;
      -- Efetuar rollback
      ROLLBACK;

      -- Log de execução NOK
      pc_gera_log_execucao(pr_dsexecut  => 'Erro na PC_JOB_GPS: '||vr_dscritic
                          ,pr_cdcooper  => pr_cdcooper
                          ,pr_dtmvtolt  => TRUNC(SYSDATE));
 END PC_JOB_GPS;
/
