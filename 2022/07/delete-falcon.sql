BEGIN
  
  delete from CECRED.tbsegcorp_analise_fraude_pix_recebidos;
  delete from CECRED.tbsegcorp_analise_fraude_chave_dict;
  delete from CECRED.TBSEGCORP_ANALISE_FRAUDE_CHAVE_DICT_CONTADORES;
    
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20000, 'ERRO: ' || SQLERRM);
END;
