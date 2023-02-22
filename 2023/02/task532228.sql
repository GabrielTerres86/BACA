DECLARE
  TYPE typ_reg_principal IS
  RECORD( cdcooper  tbrisco_operacoes.cdcooper%TYPE
         ,nrdconta  tbrisco_operacoes.nrdconta%TYPE
         ,nrctremp  tbrisco_operacoes.nrctremp%TYPE
         ,tpctrato  tbrisco_operacoes.tpctrato%TYPE
         ,nrcpfcnpj_base  tbrisco_operacoes.nrcpfcnpj_base%TYPE
         );
  TYPE typ_tab_principal_bulk IS TABLE OF typ_reg_principal INDEX BY PLS_INTEGER;
  TYPE typ_tab_cr_principal IS TABLE OF typ_reg_principal INDEX BY VARCHAR2(25); 
  vr_tab_cr_principal typ_tab_cr_principal;
  vr_tab_cr_principal_bulk typ_tab_principal_bulk;
  idx_principal VARCHAR2(25);
  
  CURSOR cr_principal IS
      SELECT cdcooper,
             nrdconta,
             nrctremp,
             tpctrato,
             nrcpfcnpj_base
        FROM tbrisco_operacoes opr
        WHERE 1=1
          AND opr.tpctrato = 11          -- ADP sem contrato
          AND opr.flencerrado = 0
          AND opr.dtvencto_rating < (select dtmvtolt from crapdat where cdcooper = opr.cdcooper);
  rw_principal cr_principal%ROWTYPE;
  
BEGIN
 
 vr_tab_cr_principal_bulk.DELETE;
 OPEN cr_principal;
 FETCH cr_principal BULK COLLECT INTO vr_tab_cr_principal_bulk;
 CLOSE cr_principal;
 
 IF vr_tab_cr_principal_bulk.count > 0 THEN 
  BEGIN
  FORALL idx in vr_tab_cr_principal_bulk.first .. vr_tab_cr_principal_bulk.last SAVE EXCEPTIONS  
        UPDATE tbrisco_operacoes
       SET flencerrado = 1
     WHERE cdcooper = vr_tab_cr_principal_bulk(idx).cdcooper
       AND nrdconta = vr_tab_cr_principal_bulk(idx).nrdconta
       AND nrctremp = vr_tab_cr_principal_bulk(idx).nrctremp
       AND tpctrato = vr_tab_cr_principal_bulk(idx).tpctrato
       AND nrcpfcnpj_base = vr_tab_cr_principal_bulk(idx).nrcpfcnpj_base;
    EXCEPTION
    WHEN OTHERS 
    THEN
    FOR i IN 1 .. SQL%BULK_EXCEPTIONS.COUNT
    LOOP
       dbms_output.put_line('Erro ao atualizar o registro - Cooper: ' || vr_tab_cr_principal_bulk(SQL%BULK_EXCEPTIONS(i).ERROR_INDEX).cdcooper || ' Conta: ' || vr_tab_cr_principal_bulk(SQL%BULK_EXCEPTIONS(i).ERROR_INDEX).nrdconta || ' Contrato: ' || vr_tab_cr_principal_bulk(SQL%BULK_EXCEPTIONS(i).ERROR_INDEX).nrctremp);
    END LOOP;
  END;
 END IF;
 COMMIT;
END;