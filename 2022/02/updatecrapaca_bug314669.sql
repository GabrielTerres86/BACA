BEGIN
  UPDATE crapaca n 
    SET n.lstparam = 'pr_cdcooper,pr_tipooperacao,pr_nrdconta,pr_nrcontrato,pr_dtsolicitaca,pr_status'
  WHERE n.nmdeacao = 'CONSULTA_RETORNOS_PEAC'
    AND n.nmpackag = 'TELA_PEAC' ;
  COMMIT;
END;