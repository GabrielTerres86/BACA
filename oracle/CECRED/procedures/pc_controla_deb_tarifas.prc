create or replace procedure cecred.PC_CONTROLA_DEB_TARIFAS IS
/* ..........................................................................

   JOB: PC_CONTROLA_DEB_TARIFAS
   Sistema : Conta-Corrente - Cooperativa de Credito
   Autor   : Lucas Ranghetti
   Data    : Abril/2016.                     Ultima atualizacao: 

   Dados referentes ao programa:

   Frequencia: Diário.

   Objetivo  : Procedimento responsável por controlar os débitos de tarifas para contas integração.

   Alteracoes: 

  ..........................................................................*/
   ------------------------- VARIAVEIS PRINCIPAIS ------------------------------

    vr_infimsol   PLS_INTEGER;                     --> Variável de Retorno Nome do Campo
    vr_cdcritic   PLS_INTEGER;                     --> Variável de Retorno Nome do Campo
    vr_dserro varchar2(2000);    
    vr_cdcooper NUMBER;
    
    CURSOR cr_diautil IS
    SELECT cecred.gene0005.fn_valida_dia_util(pr_cdcooper => 1
                                             ,pr_dtmvtolt => (SELECT (TRUNC(SYSDATE,'MM')) +
                                                                     (DECODE(to_char(TRUNC(SYSDATE,'MM')
                                                                                    ,'D'),1,5,2,4,6))
                                                                FROM dual)
                                             ,pr_tipo     => 'P') diautil
      FROM dual;
    rw_diautil cr_diautil%ROWTYPE;
         
  -- Código do programa
  vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'TARIFA';
        
BEGIN

  OPEN cr_diautil;
      FETCH cr_diautil 
      INTO rw_diautil;
    CLOSE cr_diautil;
    
    /*1.Se for o quinto dia útil executa
      2.No dia 24/02/2016 será a liberação e foi preciso colocar
      a data fixa para ela ser executada a primeira vez*/
  IF TRUNC(SYSDATE) = rw_diautil.diautil THEN 
 
    gene0004.pc_executa_job( pr_cdcooper => 3   --> Codigo da cooperativa
                            ,pr_fldiautl => 0   --> Flag se deve validar dia util
                            ,pr_flproces => 1   --> Flag se deve validar se esta no processo
                            ,pr_flrepjob => 1   --> Flag para reprogramar o job
                            ,pr_flgerlog => 1   --> indicador se deve gerar log
                            ,pr_nmprogra => 'PC_CONTROLA_DEB_TARIFAS'   --> Nome do programa que esta sendo executado no job
                            ,pr_dscritic => vr_dserro);

    -- senao retornou critica  chama rotina
    IF trim(vr_dserro) IS NULL THEN
      tari0001.pc_integra_deb_tarifa(pr_cdcooper => vr_cdcooper);
      
    END IF;

  END IF;

end PC_CONTROLA_DEB_TARIFAS;
/
