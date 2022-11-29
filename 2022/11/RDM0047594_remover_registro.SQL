
BEGIN

  DELETE FROM CECRED.tbcred_parametro_analise prm
   WHERE prm.tpproduto = 1;
  COMMIT;
  
END;