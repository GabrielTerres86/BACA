BEGIN
  UPDATE pagamento.tb_baixa_pcr_remessa tbprem
     SET tbprem.nrprogress_craptit = NULL
   WHERE tbprem.nrprogress_craptit IN (231312047
                                      ,231312048
                                      ,231313277
                                      ,231313281
                                      ,231313282
                                      ,231313283
                                      ,231313284
                                      ,231313285
                                      ,231313286
                                      ,231314069
                                      ,231314073
                                      ,231314074
                                      ,231314075
                                      ,231314076
                                      ,231314077
                                      ,231314078
                                      ,231314371
                                      ,231314372);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_compleme => 'INC0329816 EDDA0076');
    ROLLBACK;
    RAISE;
END;