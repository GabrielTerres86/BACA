PL/SQL Developer Test script 3.0
70
-- Created on 04/05/2020 by T0031898 for RITM0072958
declare 

  CURSOR cr_contas IS
    SELECT f.nrctremp,
           f.vlbloqueado,
           f.vldesbloqueado,
           f.cdcooper,
           f.nrdconta 
        FROM tbepr_folha_pagto_saldo f
       WHERE f.cdcooper = 1
         AND f.nrdconta in (9688722, 
                            10659510,
                            10692061,
                            10003282,
                            10003517,
                            10879447)
         AND f.vldesbloqueado = 0;
         
  CURSOR cr_crapdat IS
    SELECT d.dtmvtolt
      FROM crapdat d
     WHERE d.cdcooper = 1;
  rw_crapdat cr_crapdat%ROWTYPE;
  
  vr_cdprogra crapprg.cdprogra%TYPE;
  vr_cdagenci crapage.cdagenci%TYPE;
  vr_nrdcaixa craplot.nrdcaixa%TYPE;
  vr_cdoperad crapope.cdoperad%TYPE;
  vr_dtmvtolt crapdat.dtmvtolt%TYPE;
  vr_vllanmto craplcm.vllanmto%TYPE;
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic crapcri.dscritic%TYPE;
  
  vr_exc_erro EXCEPTION;
  
begin
  OPEN cr_crapdat;
  FETCH cr_crapdat INTO rw_crapdat;
  CLOSE cr_crapdat;  

  FOR rw_contas IN cr_contas LOOP
    
    EMPR0016.pc_desbloquear_credito_folha (  pr_cdcooper  => rw_contas.cdcooper   --> Codigo da Cooperativa
                                            ,pr_nrdconta  => rw_contas.nrdconta   --> Numero da Conta
                                            ,pr_cdprogra  => 'FOLH0001'           --> Codigo Programa
                                            ,pr_cdagenci  => 1                    --> Codigo da agencia
                                            ,pr_nrdcaixa  => 100                  --> Numero do caixa
                                            ,pr_cdoperad  => 1                    --> Codigo do Operador
                                            ,pr_dtmvtolt  => rw_crapdat.dtmvtolt  --> Data do movimento
                                            ,pr_vllanmto  => 0                    --> Valor do lançamento
                                            ,pr_cdcritic => vr_cdcritic           --> Codigo da critica
                                            ,pr_dscritic => vr_dscritic);
                                            
    IF nvl(vr_cdcritic, 0) > 0 OR 
       TRIM(vr_dscritic) IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF; 
     
  END LOOP;
  
  COMMIT;
  
  EXCEPTION  
    WHEN vr_exc_erro THEN
      -- Desfazer a operacao
      ROLLBACK;
      -- efetuar o raise
      raise_application_error(-25001, 'EMPR0016.pc_desbloquear_credito_folha: '||vr_dscritic);
end;
0
0
