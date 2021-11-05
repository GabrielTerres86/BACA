BEGIN
  UPDATE tbseg_producao_sigas s
   SET s.tpproposta = 'CANCELAMENTO'
 WHERE s.cden2 = 1
   and s.nrdconta = 10792481
   AND s.nrapolice_certificado = '930181111111' 
   AND s.id = 40901625791;
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE(SQLERRM);
  ROLLBACK;
END;
/
BEGIN
  UPDATE tbseg_producao_sigas s
   SET s.tpproposta = 'CANCELAMENTO'
 WHERE s.cden2 = 1
   and s.nrdconta = 3866734
   AND s.nrapolice_certificado = '930181111111' 
   AND s.id = 18561623457;
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE(SQLERRM);
  ROLLBACK;
END;
/
