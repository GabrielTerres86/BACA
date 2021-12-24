-- Created on 23/12/2021 by T0032717 
DECLARE
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  
BEGIN
  dbms_output.enable(NULL);
  
  OPEN  btch0001.cr_crapdat(6);
  FETCH btch0001.cr_crapdat INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;

  BEGIN 
    UPDATE TBRISCO_OPERACOES t
       SET t.inrisco_melhora = 8
          ,t.dtrisco_melhora = rw_crapdat.dtmvtolt
          ,t.cdcritica_melhora = NULL -- Quando atualizar, zera a critica
     WHERE t.cdcooper = 6
       AND t.nrdconta = 153656
       AND t.nrctremp = 250026
       AND t.tpctrato = 90;

    UPDATE crawepr t
       SET t.dsnivris = 'G'
     WHERE t.cdcooper = 6
       AND t.nrdconta = 153656
       AND t.nrctremp = 250026;


  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Erro ao atualizar crapepr. Coop: 6 Conta: 153656 Contrato: 250026');
  END;

  ------------------------------------------------------------------------------------------------------------------------------------------------------------
  OPEN  btch0001.cr_crapdat(8);
  FETCH btch0001.cr_crapdat INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;
  
  BEGIN 
    UPDATE TBRISCO_OPERACOES t
       SET t.inrisco_melhora = 7
          ,t.dtrisco_melhora = rw_crapdat.dtmvtolt
          ,t.cdcritica_melhora = NULL -- Quando atualizar, zera a critica
     WHERE t.cdcooper = 8
       AND t.nrdconta = 47554
       AND t.nrctremp = 10254
       AND t.tpctrato = 90;

    UPDATE crawepr t
       SET t.dsnivris = 'F'
     WHERE t.cdcooper = 8
       AND t.nrdconta = 47554
       AND t.nrctremp = 10254;


  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Erro ao atualizar crapepr. Coop: 8 Conta: 47554 Contrato: 10254');
  END;

  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20100, 'Erro ao atualizar contratos - ' || SQLERRM);
END;
