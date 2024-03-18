DECLARE

  vr_reg_devolucao_nossa_remessa cecred.PAGA0009.typ_reg_devolucao_nossa_remessa;
  vr_cdcritic                    NUMBER;
  vr_dscritic                    VARCHAR2(2000);

BEGIN

  FOR r_ctit IN (
                 
                 SELECT 227976649 nrprogress_recid_craptit
                   FROM dual
                 UNION ALL
                 SELECT 227977330 nrprogress_recid_craptit
                   FROM dual
                 UNION ALL
                 SELECT 227981368 nrprogress_recid_craptit
                   FROM dual
                 UNION ALL
                 SELECT 227987571 nrprogress_recid_craptit
                   FROM dual
                 UNION ALL
                 SELECT 227990283 nrprogress_recid_craptit
                   FROM dual
                 UNION ALL
                 SELECT 227991200 nrprogress_recid_craptit
                   FROM dual
                 UNION ALL
                 SELECT 227991818 nrprogress_recid_craptit
                   FROM dual
                 UNION ALL
                 SELECT 228035796 nrprogress_recid_craptit
                   FROM dual
                 
                 )
  LOOP
  
    vr_reg_devolucao_nossa_remessa.nrprogress_recid_craptit := r_ctit.nrprogress_recid_craptit;
    vr_reg_devolucao_nossa_remessa.idrejeitado              := 1;
  
    pagamento.processarDevolucaoNossaRemessa(pr_tab_devolucao_nossa_remessa => vr_reg_devolucao_nossa_remessa
                                            ,pr_cdcritic                    => vr_cdcritic
                                            ,pr_dscritic                    => vr_dscritic);
  
    IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
      raise_application_error(-20001
                             ,nvl(vr_cdcritic, 0) || '-' || vr_dscritic || ' - ' ||
                              vr_reg_devolucao_nossa_remessa.nrprogress_recid_craptit);
    END IF;
  
    COMMIT;
  
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_compleme => 'PRJ0024441 INC0321179');
    ROLLBACK;
    RAISE;
END;
