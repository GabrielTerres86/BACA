-- Created on 27/07/2021 by T0033801 
DECLARE 

CURSOR C1 IS
SELECT REGEXP_SUBSTR('148776,259195,154725,35165,79022,78883,401129','[^,]+', 1, LEVEL) AS PR_NRDCONTA,
       REGEXP_SUBSTR('40398,41485,26967,12799,7019,2,1','[^,]+', 1, LEVEL) AS PR_NRCTRATO,
       REGEXP_SUBSTR('5,5,14,14,14,14,13','[^,]+', 1, LEVEL) AS PR_CDCOOPER 
  FROM DUAL 
CONNECT BY REGEXP_SUBSTR('148776,259195,154725,35165,79022,78883,401129','[^,]+', 1, LEVEL) IS NOT NULL;

BEGIN
   
    FOR R1 IN C1 LOOP           
      --Exclusao da proposta
      BEGIN
       DELETE
         FROM CRAPPRP
        WHERE CDCOOPER = R1.PR_CDCOOPER
          AND NRDCONTA = R1.PR_NRDCONTA
          AND NRCTRATO = R1.PR_NRCTRATO;
       EXCEPTION
         WHEN OTHERS THEN
           ROLLBACK;
      END;

      --Exclusão do rendimento
      BEGIN
       DELETE
         FROM CRAPRPR
        WHERE CDCOOPER = R1.PR_CDCOOPER
          AND NRDCONTA = R1.PR_NRDCONTA
          AND NRCTRATO = R1.PR_NRCTRATO;
      EXCEPTION
         WHEN OTHERS THEN
           ROLLBACK;
      END;

      --Exclusão do bem da proposta
      BEGIN
       DELETE
         FROM CRAPBPR
        WHERE CDCOOPER = R1.PR_CDCOOPER
          AND NRDCONTA = R1.PR_NRDCONTA
          AND NRCTRPRO = R1.PR_NRCTRATO;
      EXCEPTION
         WHEN OTHERS THEN
           ROLLBACK;
      END;

      --Exclusão do SCR para do aval
      BEGIN
       DELETE
         FROM CRAPAVT
        WHERE CDCOOPER = R1.PR_CDCOOPER
          AND NRDCONTA = R1.PR_NRDCONTA
          AND NRCTREMP = R1.PR_NRCTRATO;
      EXCEPTION
         WHEN OTHERS THEN
           ROLLBACK;
      END;

      --Exclusão das notas do rating por contrato
      BEGIN
       DELETE
         FROM CRAPNRC
        WHERE CDCOOPER = R1.PR_CDCOOPER
          AND NRDCONTA = R1.PR_NRDCONTA
          AND NRCTRRAT = R1.PR_NRCTRATO;
      EXCEPTION
         WHEN OTHERS THEN
           ROLLBACK;
      END;

      --Exclusão do historico das notas por contrato
      BEGIN
       DELETE
         FROM CECRED.TBRAT_HIST_NOTA_CONTRATO
        WHERE CDCOOPER = R1.PR_CDCOOPER
          AND NRDCONTA = R1.PR_NRDCONTA
          AND NRCTRRAT = R1.PR_NRCTRATO;
      EXCEPTION
         WHEN OTHERS THEN
           ROLLBACK;
      END;

      --Exclusão das informações do rating por contrato
      BEGIN
       DELETE
         FROM CECRED.TBRAT_INFORMACAO_RATING
        WHERE CDCOOPER = R1.PR_CDCOOPER
          AND NRDCONTA = R1.PR_NRDCONTA
          AND NRCTRRAT = R1.PR_NRCTRATO;
      EXCEPTION
         WHEN OTHERS THEN
           ROLLBACK;
      END;
      COMMIT;
    END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;