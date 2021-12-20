BEGIN
  UPDATE crapaca a SET a.lstparam = 'pr_nrdconta,pr_cdprodut,pr_vlcontra,pr_cddchave,pr_vltrnot,pr_vlboont,pr_cdvltrn,pr_cdvlbon'
   WHERE a.nmdeacao = 'VALIDA_VALOR_ADESAO'
     AND a.nmpackag = 'CADA0006';
  COMMIT;     
END;
