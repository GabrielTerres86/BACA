DECLARE
  CURSOR c_titulares_delete IS
    SELECT a.NRCPFCGC      "Cpf titular",
           a.NMEXTTTL      "Nome titular",
           b.CDCOOPER      "Cooperativa",
           b.nrdconta      "Conta",
           b.nmprimtl      "Nome titular conta",
           c.TPCALCULADORA "Calculadora",
           c.TPCOOPERADO   "Tp cooperado"
      FROM crapttl a, crapass b, tbcalris_tanque c
     WHERE a.idseqttl > 1
       AND b.cdcooper = a.cdcooper
       AND b.nrdconta = a.nrdconta
       AND c.NRCPFCGC = b.nrcpfcgc
       AND c.TPCALCULADORA IN (1, 2)
       AND EXISTS
     (SELECT 1
              FROM tbcalris_tanque x
             WHERE x.tpcalculadora IN (1, 2)
               AND b.nrcpfcgc = x.nrcpfcgc)
       AND a.nrcpfcgc IN (SELECT x.nrcpfcgc
                            FROM tbcalris_tanque x
                           WHERE x.tpcalculadora IN (1, 2));

  v_cpf_titular TBCALRIS_TANQUE.NRCPFCGC%TYPE;

BEGIN
  FOR r IN c_titulares_delete LOOP
    v_cpf_titular := r."Cpf titular";
  
    DELETE TBCALRIS_TANQUE WHERE NRCPFCGC = v_cpf_titular;
  
  END LOOP;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line(SQLERRM);
    dbms_output.put_line(SQLCODE);
    ROLLBACK;
END;