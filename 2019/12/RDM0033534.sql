UPDATE tbgar_cobertura_operacao
   SET INAPLICACAO_PROPRIA = 0
     , INAPLICACAO_TERCEIRO = 1
 WHERE cdcooper = 1
   AND nrdconta = 2396521
   AND nrcontrato = 1632635 ;   


commit;
