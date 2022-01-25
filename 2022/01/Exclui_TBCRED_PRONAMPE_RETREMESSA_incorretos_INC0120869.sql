DECLARE
  CURSOR C1 IS
    SELECT NRREGISTRO,
           IDCONTRATO,
           NRREMESSA
      FROM TBCRED_PRONAMPE_RETREMESSA 
     WHERE NRREMESSA BETWEEN 75 AND 87 -- s�o as remessas que gerados erroneamente
       AND TPREGISTRO = '04' -- significa que s�o registros de Libera��o de Cr�dito
       AND CDRETORNO <> '0'; -- siginifca que houve cr�tica no retorno
 
BEGIN
  FOR R1 IN C1 LOOP
    DELETE FROM TBCRED_PRONAMPE_RETREMESSA
     WHERE NRREGISTRO = R1.NRREGISTRO
       AND IDCONTRATO = R1.IDCONTRATO
       AND NRREMESSA = R1.NRREMESSA; 
  END LOOP; 
  COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
END;
