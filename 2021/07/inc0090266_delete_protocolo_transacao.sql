/* Remove registro de teste inserido da tabela crappro */
BEGIN
  DELETE from crappro
   WHERE DTMVTOLT = TO_DATE('08/03/2021', 'dd/mm/yyyy')
     AND CDCOOPER = 1
     AND NRDCONTA = 10122133
     and VLDOCMTO = 800
     AND NRDOCMTO = 4224239
     AND DSPROTOC is null;
  COMMIT;
END;