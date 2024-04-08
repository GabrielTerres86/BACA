DECLARE
  vr_cdcooper  crapcop.cdcooper%TYPE := 1;
  vr_nrdconta  crapass.nrdconta%TYPE := 85448;
  vr_dscritica VARCHAR2(4000);
BEGIN

  BEGIN
    UPDATE cecred.crapccc t
       SET t.idretorn = 3
     WHERE t.cdcooper = vr_cdcooper
       AND t.nrdconta = vr_nrdconta;
    
    pagamento.inserirAdesaoVan(pr_cdcooperativa    => vr_cdcooper
                              ,pr_nrconta_corrente => vr_nrdconta
                              ,pr_cdproduto        => 'CST'
                              ,pr_dscritica        => vr_dscritica);
  
    IF vr_dscritica IS NOT NULL THEN
      RAISE_APPLICATION_ERROR(-20004, 'Erro inserirAdesaoVan: ' || vr_dscritica);
    END IF;
  
    COMMIT;
  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
    
      btch0001.pc_gera_log_batch(pr_cdcooper     => 3
                                ,pr_ind_tipo_log => 3
                                ,pr_des_log      => SQLERRM
                                ,pr_cdprograma   => 'RITM0382061'
                                ,pr_dstiplog     => 'O');
    
      COMMIT;
  END;

END;
/
