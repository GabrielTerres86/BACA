CREATE OR REPLACE PROCEDURE CECRED.PC_BANCOOB_CHEQUES_DEPOSITOS(pr_cdcooper in crapcop.cdcooper%TYPE,
                                                                pr_dscritic OUT VARCHAR2) IS
 /* ..........................................................................

   JOB: PC_BANCOOB_RECEBE_ARQUIVO_CEXT
   Sistema : Conta-Corrente - Cooperativa de Credito
   Autor   : CARLOS HENRIQUE WEINHOLD
   Data    : Novembro/2015.                     Ultima atualizacao: 20/02/2017

   Dados referentes ao programa:

   Frequencia: Diário.
   Objetivo  : Executar a importação dos arquivos referentes aos programas crps250 e crps252. Só executará
               os programas se os respectivos arquivos existirem. As cooperativas são verificadas 
               individualmente. Se não encontrar os arquivos na cooperativa em questão, o job da mesma 
               será reagendado para a próxima hora.

   Alteracoes: 30/11/2015 - Verificando individualmente a existência de arquivos para o programa crps250 ou
                            crps252 executarem (Carlos)
                            
               30/11/2015 - #366319 Retirada do programa crps250 do job (Carlos)

               20/02/2017 - #551202 Ajuste da nomenclatura do job para JBCOMPE_CRPS252 (Carlos)
  ..........................................................................*/
      ------------------------- VARIAVEIS PRINCIPAIS ------------------------------
  vr_cdprogra   crapprg.cdprogra%TYPE;           --> Código do programa
  vr_infimsol   PLS_INTEGER;                     --> Variável de Retorno Nome do Campo
  vr_stprogra   PLS_INTEGER;
  vr_cdcritic   PLS_INTEGER;                     --> Variável de Retorno Nome do Campo
  vr_dserro     VARCHAR2(2000);
  vr_dtvalida   DATE;                              --> Variavel que retorna o dia valido 
  vr_dtdiahoje  DATE;
  vr_dsplsql    VARCHAR2(2000);
  vr_jobname    VARCHAR2(20);
  vr_exc_saida  EXCEPTION;
  vr_dirintegra  VARCHAR2(200);
  vr_listadir    VARCHAR2(2000);
  vr_dscritic    VARCHAR2(4000);
  pr_cdcritic    PLS_INTEGER;
  vr_flgexecu252 BOOLEAN := FALSE;

  
  CURSOR cr_crapcop is
    SELECT cdcooper
      FROM crapcop
     WHERE cdcooper <> 3
       AND flgativo = 1;

  -- Busca dos dados da cooperativa
  CURSOR cr_crapcop_atual (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT cop.nmrescop
          ,cop.nmextcop
          ,cop.cdcooper
          ,cop.cdagebcb
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;         
  rw_crapcop_atual cr_crapcop_atual%ROWTYPE;


  BEGIN

    vr_dtdiahoje := TRUNC(SYSDATE);
    vr_dtvalida  := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,
                                                pr_dtmvtolt => vr_dtdiahoje,
                                                pr_tipo     => 'A',
                                                pr_feriado  => TRUE );


    -- SE FOR DIA UTIL E NÃO FOR O ULTIMO DIA DO ANO, EXECUTA O CRPS
    IF vr_dtvalida = vr_dtdiahoje THEN
      
      --> se for coop 3, deve criar o job para cada coop
      IF pr_cdcooper = 3 THEN
        FOR rw_crapcop IN cr_crapcop LOOP
          
          vr_dsplsql := 'DECLARE vr_dscritic VARCHAR2(500); 
            begin cecred.PC_BANCOOB_CHEQUES_DEPOSITOS(pr_cdcooper => '||rw_crapcop.cdcooper ||', 
              pr_dscritic => vr_dscritic); 
              IF vr_dscritic IS NOT NULL THEN
                raise_application_error(-20001, vr_dscritic);
              END IF;
            end;';
          vr_jobname := 'JBCOMPE_252_'||rw_crapcop.cdcooper||'$';
          
          -- Faz a chamada ao programa paralelo atraves de JOB
          gene0001.pc_submit_job(pr_cdcooper  => pr_cdcooper       --> Código da cooperativa
                                ,pr_cdprogra  => 'CRPS252'     --> Código do programa
                                ,pr_dsplsql   => vr_dsplsql        --> Bloco PLSQL a executar
                                ,pr_dthrexe   => TO_TIMESTAMP_tz(to_char((SYSDATE + (1/24)),'DD/MM/RRRR HH24:MI'),
                                                                                            'DD/MM/RRRR HH24:MI') --> Incrementar 1 hora
                                ,pr_interva   => NULL              --> apenas uma vez
                                ,pr_jobname   => vr_jobname        --> Nome randomico criado
                                ,pr_des_erro  => vr_dserro);  
          
          IF TRIM(vr_dserro) IS NOT NULL THEN
            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                       pr_ind_tipo_log => 2, --> erro tratado
                                       pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                          ' - ' || vr_jobname || ' --> (Coop:'||rw_crapcop.cdcooper||')' || vr_dserro,
                                       pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'),
                                       pr_dstiplog     => 'E',
                                       pr_cdprograma   => vr_jobname);
          END IF;  
          
        END LOOP;--> Fim loop coop
              
      ELSE
        
        -- Valida se executa o job
        gene0004.pc_executa_job( pr_cdcooper => pr_cdcooper   --> Codigo da cooperativa
                                ,pr_fldiautl => 0   --> Flag se deve validar dia util
                                ,pr_flproces => 1   --> Flag se deve validar se esta no processo (true = não roda no processo)
                                ,pr_flrepjob => 1   --> Flag para reprogramar o job
                                ,pr_flgerlog => 1   --> indicador se deve gerar log
                                ,pr_nmprogra => 'PC_BANCOOB_CHEQUES_DEPOSITOS'   --> Nome do programa que esta sendo executado no job
                                ,pr_dscritic => vr_dserro);

        -- se nao retornou critica  chama rotina
        IF TRIM(vr_dserro) IS NULL THEN       

          -- diretorio integra da cooperativa
          vr_dirintegra := gene0001.fn_diretorio(pr_tpdireto => 'C' 
                                                ,pr_cdcooper => pr_cdcooper
                                                ,pr_nmsubdir => 'integra'); 
        
          -- Lista arquivos para crps252
          gene0001.pc_lista_arquivos(pr_path     => vr_dirintegra 
                                    ,pr_pesq     => '3' || TO_CHAR(rw_crapcop_atual.cdagebcb,'fm0000') || '%.RT%'  
                                    ,pr_listarq  => vr_listadir 
                                    ,pr_des_erro => vr_dscritic);      
                                      
          --Ocorreu um erro no lista_arquivos
          IF TRIM(vr_dscritic) IS NOT NULL THEN
            vr_flgexecu252 := FALSE;
          ELSE
            vr_flgexecu252 := vr_listadir IS NOT NULL;
          END IF;  
          
          vr_dsplsql := 'DECLARE vr_dscritic VARCHAR2(500); 
            begin cecred.PC_BANCOOB_CHEQUES_DEPOSITOS(pr_cdcooper => '|| pr_cdcooper ||', 
              pr_dscritic => vr_dscritic); 
              IF vr_dscritic IS NOT NULL THEN
                raise_application_error(-20001, vr_dscritic);
              END IF;
            end;';
          
          vr_jobname := 'JBCOMPE_252_'||pr_cdcooper;
          
          -- Verifica se executa crps252
          IF vr_flgexecu252 THEN
            pc_crps252(pr_cdcooper => pr_cdcooper,
                       pr_cdprogra =>  vr_jobname,
                       pr_stprogra =>  vr_cdprogra,
                       pr_infimsol =>  vr_infimsol,
                       pr_cdcritic =>  vr_cdcritic,
                       pr_dscritic =>  vr_dserro );

            IF TRIM(vr_dserro) IS NOT NULL THEN
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                         pr_ind_tipo_log => 2, --> erro tratado
                                         pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||
                                                            ' - ' || vr_jobname || ' --> ' || vr_dserro,
                                         pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'),
                                         pr_dstiplog     => 'E',
                                         pr_cdprograma   => vr_jobname);
            END IF;

            btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                         pr_ind_tipo_log => 2, --> erro tratado
                                         pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||
                                                            ' - ' || vr_jobname || ' --> Executado',
                                         pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'),
                                         pr_dstiplog     => 'E',
                                         pr_cdprograma   => vr_jobname);

          ELSIF (SYSDATE < trunc(SYSDATE)+(15/24)) THEN -- Se for antes das 15:00 (trunc(SYSDATE)+(15/24)) pode reagendar

            vr_jobname := vr_jobname||'$';

            -- Faz a chamada ao programa paralelo atraves de JOB
            gene0001.pc_submit_job(pr_cdcooper  => pr_cdcooper     --> Código da cooperativa
                                  ,pr_cdprogra  => 'CRPS252'       --> Código do programa
                                  ,pr_dsplsql   => vr_dsplsql      --> Bloco PLSQL a executar
                                  ,pr_dthrexe   => TO_TIMESTAMP_tz(to_char((SYSDATE + (1/24)),'DD/MM/RRRR HH24:MI'),
                                                                                              'DD/MM/RRRR HH24:MI') --> Incrementar mais 1 hora
                                  ,pr_interva   => NULL            --> apenas uma vez
                                  ,pr_jobname   => vr_jobname      --> Nome randomico criado
                                  ,pr_des_erro  => vr_dserro);  
            
            IF TRIM(vr_dserro) is not null then
              btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                         pr_ind_tipo_log => 2, --> erro tratado
                                         pr_des_log      => to_char(SYSDATE,'hh24:mi:ss') ||
                                                            ' - ' || vr_jobname || ' --> (Coop:'||pr_cdcooper||')' || vr_dserro,
                                         pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'),
                                         pr_dstiplog     => 'E',
                                         pr_cdprograma   => vr_jobname);
            END IF;            
          END IF;

        END IF;

      END IF; -- cdcooper = 3

    END IF; -- data válida

  EXCEPTION
    WHEN vr_exc_saida THEN      
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
    
      cecred.pc_internal_exception(pr_cdcooper);
    
      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := vr_dscritic || sqlerrm;
      -- Efetuar rollback
      ROLLBACK;


 END PC_BANCOOB_CHEQUES_DEPOSITOS;
/

