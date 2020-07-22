BEGIN
  UPDATE CRAPACA T 
     SET t.lstparam = 'pr_cddopcao, pr_cdcidade, pr_dscidade, pr_cdestado, pr_tpoperac, pr_idautoriza_ente_pub, pr_dsata_avaliacao'
   WHERE t.nmdeacao = 'MANTERMUN';
   
  COMMIT;
END;
