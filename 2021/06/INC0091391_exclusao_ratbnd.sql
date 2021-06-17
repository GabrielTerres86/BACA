-- Created on 02/06/2021 by T0033801 
DECLARE 

CURSOR C1 IS
SELECT REGEXP_SUBSTR('115266,118613,157031,218332','[^,]+', 1, LEVEL) AS PR_NRDCONTA,
       REGEXP_SUBSTR('26458,1736845,1,21002','[^,]+', 1, LEVEL) AS PR_NRCTRATO,
       REGEXP_SUBSTR('14,14,10,14','[^,]+', 1, LEVEL) AS PR_CDCOOPER 
  FROM DUAL 
CONNECT BY REGEXP_SUBSTR('115266,118613,157031,218332','[^,]+', 1, LEVEL) IS NOT NULL;

  -- Local variables here
VR_EXCSAIDA EXCEPTION;
VR_MSGSAIDA VARCHAR2(200);
PR_DSCRITIC VARCHAR2(200);
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
           VR_MSGSAIDA := 'Erro ao limpar a tabela CRAPPRP -->'||SQLERRM;
           RAISE VR_EXCSAIDA;
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
           VR_MSGSAIDA := 'Erro ao limpar a tabela CRAPRPR -->'||SQLERRM;
           RAISE VR_EXCSAIDA;
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
           VR_MSGSAIDA := 'Erro ao limpar a tabela CRAPBPR -->'||SQLERRM;
           RAISE VR_EXCSAIDA;
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
           VR_MSGSAIDA := 'Erro ao limpar a tabela CRAPAVT -->'||SQLERRM;
           RAISE VR_EXCSAIDA;
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
           VR_MSGSAIDA := 'Erro ao limpar a tabela CRAPNRC -->'||SQLERRM;
           RAISE VR_EXCSAIDA;
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
           VR_MSGSAIDA := 'Erro ao limpar a tabela TBRAT_HIST_NOTA_CONTRATO -->'||SQLERRM;
           RAISE VR_EXCSAIDA;
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
           VR_MSGSAIDA := 'Erro ao limpar a tabela TBRAT_INFORMACAO_RATING -->'||SQLERRM;
           RAISE VR_EXCSAIDA;
      END;
      DBMS_OUTPUT.PUT_LINE('Exclusão de contrato realizada com sucesso do contrato: '||R1.PR_NRCTRATO||' e conta: '||R1.PR_NRDCONTA);
      COMMIT;
    END LOOP;
EXCEPTION
  WHEN VR_EXCSAIDA THEN
    DBMS_OUTPUT.PUT_LINE(VR_MSGSAIDA);
    ROLLBACK;
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erro geral ao excluir o contrato: '||SQLERRM);
    ROLLBACK;
END;
