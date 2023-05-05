BEGIN
  UPDATE crapaca ca
     SET ca.lstparam = null
   WHERE ca.nmdeacao = UPPER('GRAVAR_DADOS_CONVEN_LIB');
  COMMIT;
END;