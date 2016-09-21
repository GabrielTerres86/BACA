CREATE OR REPLACE PROCEDURE CECRED.PC_BANCOOB_ENVIA_ARQUIVO_SALDO IS
 /* ..........................................................................

   JOB: PC_BANCOOB_ENVIA_ARQUIVO_SALDO
   Sistema : Conta-Corrente - Cooperativa de Credito
   Autor   : VANESSA KLEIN
   Data    : Janeiro/2015.                     Ultima atualizacao: 10/08/2015

   Dados referentes ao programa:

   Frequencia: Diário.
   Objetivo  : procedimento para a geração do arquivo de Saldo Disp. dos Associados
               dos Cartões de Crédito BANCOOB/CABAL.

   Alteracoes: 10/08/2015 - Alterado rotina para ver se o job pode ser executado
                            gene0004.pc_executa_job, caso não possa ser rodado
                            e reprogramado para rodar na proxima hora(Odirlei -AMcom)       

  ..........................................................................*/

  ------------------------- VARIAVEIS PRINCIPAIS ------------------------------
  vr_cdprogra   crapprg.cdprogra%TYPE;           --> Código do programa
  vr_infimsol   PLS_INTEGER;                     --> Variável de Retorno Nome do Campo
  vr_cdcritic   PLS_INTEGER;                     --> Variável de Retorno Nome do Campo
  vr_dserro varchar2(2000);
  vr_dtvalida DATE;                              --> Variavel que retorna o dia valido
  vr_dtdiahoje DATE;

  BEGIN

    vr_dtdiahoje := TRUNC(SYSDATE);
    vr_dtvalida  := gene0005.fn_valida_dia_util(pr_cdcooper => 3,
                                                   pr_dtmvtolt => vr_dtdiahoje,
                                                   pr_tipo     => 'A',
                                                   pr_feriado  => TRUE );


    -- SE FOR DIA UTIL EXECUTA O CRPS
    IF vr_dtvalida = vr_dtdiahoje THEN
      gene0004.pc_executa_job( pr_cdcooper => 3   --> Codigo da cooperativa
                              ,pr_fldiautl => 0   --> Flag se deve validar dia util
                              ,pr_flproces => 1   --> Flag se deve validar se esta no processo    
                              ,pr_flrepjob => 1   --> Flag para reprogramar o job
                              ,pr_flgerlog => 1   --> indicador se deve gerar log
                              ,pr_nmprogra => 'PC_BANCOOB_ENVIA_ARQUIVO_SALDO'   --> Nome do programa que esta sendo executado no job
                              ,pr_dscritic => vr_dserro);
                    
      -- senao retornou critica  chama rotina
      IF TRIM(vr_dserro) IS NULL THEN 
        pc_crps669(pr_cdcooper => 3,
                   pr_flgresta => 1,
                   pr_stprogra =>  vr_cdprogra,
                   pr_infimsol =>  vr_infimsol,
                   pr_cdoperad =>  1,
                   pr_cdcritic =>  vr_cdcritic,
                   pr_dscritic =>  vr_dserro );
                   
        IF TRIM(vr_dserro) IS NOT NULL THEN       
          btch0001.pc_gera_log_batch(pr_cdcooper     => 3, 
                                     pr_ind_tipo_log => 2, --> erro tratado 
                                     pr_des_log      => to_char(SYSDATE,'DD/MM/RRRR hh24:mi:ss') ||
                                                        ' - PC_BANCOOB_ENVIA_ARQUIVO_SALDO --> ' || vr_dserro, 
                                     pr_nmarqlog     => gene0001.fn_param_sistema(pr_nmsistem => 'CRED', pr_cdacesso => 'NOME_ARQ_LOG_MESSAGE'));
        END IF;
      END IF;            
      
    END IF;

END PC_BANCOOB_ENVIA_ARQUIVO_SALDO;
/

