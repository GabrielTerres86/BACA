CREATE OR REPLACE PROCEDURE CECRED.PC_BANCOOB_ENVIA_ARQUIVO_SALDO(pr_dscritic OUT VARCHAR2)  IS
 /* ..........................................................................

   JOB: PC_BANCOOB_ENVIA_ARQUIVO_SALDO
   Sistema : Conta-Corrente - Cooperativa de Credito
   Autor   : VANESSA KLEIN
   Data    : Janeiro/2015.                     Ultima atualizacao: 28/02/2018

   Dados referentes ao programa:

   Frequencia: Diário.
   Objetivo  : procedimento para a geração do arquivo de Saldo Disp. dos Associados
               dos Cartões de Crédito BANCOOB/CABAL.

   Alteracoes: 10/08/2015 - Alterado rotina para ver se o job pode ser executado
                            gene0004.pc_executa_job, caso não possa ser rodado
                            e reprogramado para rodar na proxima hora(Odirlei -AMcom)       

               30/06/2016 - #454336 Incluído log de início, fim e erro na execução do job
                            (Carlos)

               08/01/2018 - #796943 Criação do parâmetro de retorno de erro para o job; Tratado 
                            para não executar sábado depois do meio dia, apenas pela manhã (Carlos)
                            
               28/02/2018 - #858915 Validar processo apenas até sexta-feira, pois sábado a CECRED
                            fica com o indicador de processo como solicitado (Carlos)
  ..........................................................................*/

  ------------------------- VARIAVEIS PRINCIPAIS ------------------------------
  vr_cdprogra   crapprg.cdprogra%TYPE;           --> Código do programa
  vr_infimsol   PLS_INTEGER;                     --> Variável de Retorno Nome do Campo
  vr_cdcritic   PLS_INTEGER;                     --> Variável de Retorno Nome do Campo
  vr_dserro varchar2(2000);

  vr_nomdojob  CONSTANT VARCHAR2(100) := 'jbcrd_bancoob_envia_saldo';
  vr_flgerlog  BOOLEAN := FALSE;

  --> Controla log proc_batch, para apenas exibir qnd realmente processar informação
  PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2, -- 'I' início; 'F' fim; 'E' erro
                                  pr_dscritic IN VARCHAR2 DEFAULT NULL) IS
  BEGIN

    --> Controlar geração de log de execução dos jobs 
    BTCH0001.pc_log_exec_job( pr_cdcooper  => 3    --> Cooperativa
                             ,pr_cdprogra  => vr_cdprogra    --> Codigo do programa
                             ,pr_nomdojob  => vr_nomdojob    --> Nome do job
                             ,pr_dstiplog  => pr_dstiplog    --> Tipo de log(I-inicio,F-Fim,E-Erro)
                             ,pr_dscritic  => pr_dscritic    --> Critica a ser apresentada em caso de erro
                             ,pr_flgerlog  => vr_flgerlog);  --> Controla se gerou o log de inicio, sendo assim necessario apresentar log fim

  END pc_controla_log_batch;

  BEGIN

    -- Se for sabádo depois de meio dia, não executa. Sábado o job executa apenas pela manhã.
    IF to_char(SYSDATE,'d')    = 7 AND
       to_char(SYSDATE,'hh24') > 12 THEN
      RETURN;
    END IF;

    -- Validar processo apenas até sexta-feira, pois sábado a CECRED fica com o indicador de processo como solicitado
    IF to_char(SYSDATE,'d') < 7 THEN
      gene0004.pc_executa_job( pr_cdcooper => 3   --> Codigo da cooperativa
                              ,pr_fldiautl => 0   --> Flag se deve validar dia util
                              ,pr_flproces => 1   --> Flag se deve validar se esta no processo    
                              ,pr_flrepjob => 1   --> Flag para reprogramar o job
                              ,pr_flgerlog => 1   --> indicador se deve gerar log
                              ,pr_nmprogra => 'PC_BANCOOB_ENVIA_ARQUIVO_SALDO'   --> Nome do programa que esta sendo executado no job
                              ,pr_dscritic => vr_dserro);
    END IF;

    -- Se nao retornou critica, chama rotina
    IF TRIM(vr_dserro) IS NULL THEN 

      -- Início da execução do job
      pc_controla_log_batch(pr_dstiplog => 'I');

      pc_crps669(pr_cdcooper => 3,
                 pr_flgresta => 1,
                 pr_stprogra =>  vr_cdprogra,
                 pr_infimsol =>  vr_infimsol,
                 pr_cdoperad =>  1,
                 pr_cdcritic =>  vr_cdcritic,
                 pr_dscritic =>  vr_dserro );

      IF TRIM(vr_dserro) IS NOT NULL THEN
        pr_dscritic := vr_dserro;
        pc_controla_log_batch(pr_dstiplog => 'E',
                              pr_dscritic => vr_dserro);
      END IF;

      -- Fim da execução do job
      pc_controla_log_batch(pr_dstiplog => 'F');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      cecred.pc_internal_exception;

      -- Efetuar retorno do erro não tratado
      pr_dscritic := sqlerrm;
      pc_controla_log_batch(pr_dstiplog => 'E',
                            pr_dscritic => pr_dscritic);

END PC_BANCOOB_ENVIA_ARQUIVO_SALDO;
/
