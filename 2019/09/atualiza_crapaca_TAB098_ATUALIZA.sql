BEGIN
  UPDATE CRAPACA
     SET LSTPARAM = 'pr_cdcooper, pr_cdoperad, pr_prz_baixa_cip, pr_vlvrboleto, pr_vlcontig_cip, pr_sit_pag_divergente, pr_pag_a_menor, pr_pag_a_maior, pr_tip_tolerancia, pr_vl_tolerancia'
   WHERE NMDEACAO = 'TAB098_ATUALIZA';
EXCEPTION
  WHEN OTHERS THEN
    CECRED.PC_INTERNAL_EXCEPTION;
END;
