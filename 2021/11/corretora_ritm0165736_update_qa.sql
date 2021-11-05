BEGIN
  FOR st_conta IN (SELECT u.cdcooper,
                          u.nrdconta,
                          to_char(u.nrcrcard) nrcrcard
                     FROM craplau u
                    WHERE u.cdcooper = 1 --- cooperativa Viacredi
                      AND u.cdhistor = 2074
                      AND dtmvtopg > TRUNC(SYSDATE) - 30
                      AND insitlau = 3
                      AND NOT EXISTS
                    (SELECT 1
                       FROM craplau a
                      WHERE a.cdcooper = u.cdcooper
                        AND a.nrdconta = u.nrdconta
                        AND a.cdhistor = u.cdhistor
                        AND a.vllanaut = u.vllanaut
                        AND a.nrcrcard = u.nrcrcard
                        AND a.dtmvtopg BETWEEN u.dtmvtopg AND
                            u.dtmvtopg + 30
                        AND a.insitlau = 2)) LOOP
    UPDATE tbseg_producao_sigas s
       SET s.nrapolice_certificado = st_conta.nrcrcard
     WHERE s.cden2 = st_conta.cdcooper
       AND s.nrdconta = st_conta.nrdconta;
  END LOOP;
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  DBMS_OUTPUT.put_line(SQLERRM);
  ROLLBACK;
END;
/
