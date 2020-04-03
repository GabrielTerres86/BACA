PL/SQL Developer Test script 3.0
76
DECLARE
  CURSOR cr_crapace IS
    SELECT DISTINCT
           p.cdoperad
          ,p.cdcooper
      FROM crapace p
     WHERE p.nmdatela = 'RISCO'
       AND p.cddopcao = 'F'
       AND p.idambace = 1; -- Aimaro Caractere

BEGIN

  BEGIN
    UPDATE craptel t
      SET t.cdopptel = t.cdopptel ||',P,Q'
         ,t.lsopptel = t.lsopptel ||',PREVIA 3040 MES ANT,PREVIA 3040 DIA ANT'
    WHERE t.nmdatela = 'RISCO' AND t.cdopptel NOT LIKE '%,P,Q';
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Erro: ' || SQLERRM);
    END;
  COMMIT;

  --FAZ O INSERT PARA OPERADORES COM OPCAO "F" NA TELA "RISCO"
  FOR rw_crapace IN cr_crapace LOOP
      BEGIN
        INSERT INTO crapace
          (nmdatela,
           cddopcao,
           cdoperad,
           nmrotina,
           cdcooper,
           nrmodulo,
           idevento,
           idambace)
        VALUES
          ('RISCO',
           'P',
           rw_crapace.cdoperad,
           ' ',
           rw_crapace.cdcooper,
           1,
           0,
           2);
      EXCEPTION
        WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE('Erro: cdcoperd:' || rw_crapace.cdoperad || 'cdoperad:' || rw_crapace.cdcooper || ' - '  || SQLERRM);
      END;

      BEGIN
        INSERT INTO crapace
          (nmdatela,
           cddopcao,
           cdoperad,
           nmrotina,
           cdcooper,
           nrmodulo,
           idevento,
           idambace)
        VALUES
          ('RISCO',
           'Q',
           rw_crapace.cdoperad,
           ' ',
           rw_crapace.cdcooper,
           1,
           0,
           2);
      EXCEPTION
        WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE('Erro: cdcoperd:' || rw_crapace.cdoperad || 'cdoperad:' || rw_crapace.cdcooper || ' - '  || SQLERRM);
      END;
  END LOOP;

  COMMIT;
END;
0
0
