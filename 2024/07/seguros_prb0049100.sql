BEGIN
  UPDATE cecred.crapaca p
     SET p.lstparam = p.lstparam || ',pr_dtdpagto'
   WHERE p.nmproced = 'pc_retorna_tpcuspr';
  
  UPDATE cecred.crapaca p
     SET p.lstparam = p.lstparam || ',pr_dtdpagto'
   WHERE p.nmproced = 'pc_busca_dados_simulacao';
  
  COMMIT;
END;
/
