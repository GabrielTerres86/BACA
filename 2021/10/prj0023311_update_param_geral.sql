BEGIN
  UPDATE tbrat_param_geral a
  SET a.qtdias_atencede_atualizacao = a.qtdias_atencede_atualizacao+3
  WHERE a.cdcooper =1
  AND a.tpproduto = 90;
 COMMIT;
END;
