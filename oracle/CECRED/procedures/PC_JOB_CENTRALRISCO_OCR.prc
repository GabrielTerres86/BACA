CREATE OR REPLACE PROCEDURE CECRED.PC_JOB_CENTRALRISCO_OCR(pr_cdcooper in crapcop.cdcooper%TYPE) IS

  /* ..........................................................................

   JOB: PC_JOB_CENTRALRISCO_OCR
   Sistema : AYLLOS
   Autor   : Daniel(AMcom)
   Data    : Abril/2018.                     Ultima atualizacao: /  /

   Dados referentes ao programa:

   Frequencia: Diária
   Objetivo  : Grava dados brutos da Central de Risco

   Alteracoes:

  ..........................................................................*/
      ------------------------- VARIAVEIS PRINCIPAIS ------------------------------
    vr_cdprogra    CONSTANT VARCHAR2(40) := 'PC_JOB_CENTRALRISCO_OCR';
    vr_cdcritic    PLS_INTEGER;
    vr_dscritic    VARCHAR2(4000);
    vr_dsplsql     VARCHAR2(2000);
    vr_jobname     VARCHAR2(30);
    vr_minuto      NUMBER;

    vr_exc_erro    EXCEPTION;

    -- Variáveis de controle
    rw_crapdat             BTCH0001.cr_crapdat%ROWTYPE;

    --> Buscar todas as cooperativas ativas
    CURSOR cr_crapcop IS
      SELECT cop.cdcooper
        FROM crapcop cop
       WHERE cop.flgativo = 1
         AND cop.cdcooper <> 3 -- Não deve rodar para a CECRED
       ORDER BY cop.cdcooper;

    CURSOR cr_tbrisco_centralocr(pr_cdcooper number) IS
      SELECT distinct max(t.dtrefere) dtrefere
        FROM TBRISCO_CENTRAL_OCR t
       WHERE t.cdcooper = pr_cdcooper;
    rw_tbrisco_centralocr cr_tbrisco_centralocr%ROWTYPE;       

    /******************************/
    --> LOG de execucao
    PROCEDURE pc_gera_log_execucao(pr_dsexecut  IN VARCHAR2,
                                   pr_cdcooper  IN INTEGER,
                                   pr_dtmvtolt  IN DATE) IS
      vr_nmarqlog VARCHAR2(500);
      vr_desdolog VARCHAR2(2000);

    BEGIN

      --> Definir nome do log
      vr_nmarqlog := 'centralrisco.log';
      --> Definir descrição do log
      vr_desdolog := 'JOB CENTRALRISCO_OCR - '||to_char(pr_dtmvtolt,'DD/MM/YYYY')||' - '||to_char(SYSDATE,'HH24:MI:SS')||
                     ' [Dados Brutos] - Coop: '|| pr_cdcooper ||' - '||pr_dsexecut;

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

        -- Verifica TBRISCO_CENTRAL_OCR
        OPEN  cr_tbrisco_centralocr(pr_cdcooper => rw_crapcop.cdcooper);
        FETCH cr_tbrisco_centralocr INTO rw_tbrisco_centralocr;
        
		-- Somente cria o job de execução se a diária estiver concluída e se não houver atualização na tabela tbrisco_central_ocr		
        IF rw_crapdat.inproces = 1 and rw_crapdat.dtmvtoan > rw_tbrisco_centralocr.dtrefere then
          -- Criar o nome para o job
          vr_jobname := 'JOB_CENTRALRISCO_OCR'||LPAD(rw_crapcop.cdcooper,2,'0')||'_$';
  
          vr_dsplsql := 'begin cecred.PC_JOB_CENTRALRISCO_OCR(pr_cdcooper => '||rw_crapcop.cdcooper ||'); end;';
  
  
          vr_minuto := 0;
  
          
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
        RISC0003.pc_risco_central_ocr(pr_cdcooper  => pr_cdcooper
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Job PC_JOB_CENTRALRISCO_OCR.prc nao foi executado pois ocorreu erro '||
                         'ao excluir craplgp: '||SQLERRM;
          RAISE vr_exc_erro;
      END;

      pc_gera_log_execucao(pr_dsexecut  => ' => QTDE Registros: ' || to_char(SQL%ROWCOUNT)
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
      pc_gera_log_execucao(pr_dsexecut  => 'Erro na PC_JOB_CENTRALRISCO_OCR: '||vr_dscritic
                          ,pr_cdcooper  => pr_cdcooper
                          ,pr_dtmvtolt  => TRUNC(SYSDATE));
 END PC_JOB_CENTRALRISCO_OCR;
/