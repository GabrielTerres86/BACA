DECLARE

  CURSOR cr_crapcop IS
    SELECT c.cdcooper
      FROM cecred.crapcop c
     WHERE c.flgativo = 1;
  rw_crapcop cr_crapcop%ROWTYPE;

  vr_dsprmris    cecred.crapprm.dsvlrprm%TYPE;
  vr_tipsplit    cecred.gene0002.typ_split;
  vr_dscritic    VARCHAR2(1000);

BEGIN
  
  FOR rw_crapcop IN cr_crapcop LOOP
    vr_dsprmris := gene0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                            ,pr_cdcooper => rw_crapcop.cdcooper
                                            ,pr_cdacesso => 'RISCO_CARTAO_BACEN');
                                                       
    vr_tipsplit := gene0002.fn_quebra_string(pr_string => vr_dsprmris, pr_delimit => ';');
    vr_tipsplit(4) := 1;
    CECRED.RISC0002.pc_atualiza_param_risco_cartao(pr_cdcooper => rw_crapcop.cdcooper
                                                  ,pr_tipsplit => vr_tipsplit
                                                  ,pr_dscritic => vr_dscritic);
  END LOOP;
  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20000, SQLERRM || ' - ' || dbms_utility.format_error_backtrace);
END;
