DECLARE
    i INTEGER := 0;
BEGIN
    FOR rw IN (SELECT a.cdcooper,
                      a.nrdconta,
                      s.vllimite_pix_cooperado,
                      s.idseqttl
               FROM   crapass a,
                      crapcop c,
                      crapsnh s
               WHERE  c.flgativo = 1
                      AND a.cdcooper = c.cdcooper
                      AND a.dtdemiss IS NULL
                      AND s.cdcooper = a.cdcooper
                      AND s.nrdconta = a.nrdconta
                      AND s.tpdsenha = 1
                      AND s.vllimite_pix IS NOT NULL) LOOP

        INSERT INTO pix.tbpix_limite
                    (cdcooper,
                     nrdconta,
                     idseqttl,
                     dhcadastro,
                     vllimite_noturno,
                     vllim_not_cooperado)
        VALUES      ( rw.cdcooper,
                     rw.nrdconta,
                     rw.idseqttl,
                     SYSDATE,
                     Least(rw.vllimite_pix_cooperado, 1000),
                     Least(rw.vllimite_pix_cooperado, 1000) );

        i := i + 1;

        IF i = 5000 THEN
          i := 0;
          COMMIT;
        END IF;

    END LOOP;

    COMMIT;
END;