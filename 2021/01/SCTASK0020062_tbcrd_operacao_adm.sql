BEGIN

  insert into tbcrd_operacao_adm
    (IDOPERACAO_ADM, CDTIPO_REGISTRO, CDOPERACAO, DSOPERACAO, CDACAO)
  values
    (null, 2, 99, 'EXCLUSÃO DE CARTÃO', 4);
  
  UPDATE tbcrd_operacao_adm
     SET CDACAO = 4
   WHERE CDTIPO_REGISTRO = 1
     AND CDOPERACAO = 99;
     
  COMMIT;

END;
