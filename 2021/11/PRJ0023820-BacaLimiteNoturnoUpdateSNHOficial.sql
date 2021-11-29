DECLARE
    i INTEGER := 0;
    BEGIN
        FOR rw_crapcop IN (SELECT cop.cdcooper
                            FROM crapcop cop
                            WHERE cop.flgativo = 1
                            ORDER BY cop.cdcooper DESC) 
        LOOP
        dbms_output.put_line('Cooperativa: ' || rw_crapcop.cdcooper);
            FOR rw_crapass IN (SELECT ass.nrdconta
                                FROM crapass ass
                                    ,crapsnh snh
                                WHERE ass.cdcooper = rw_crapcop.cdcooper
                                AND   snh.cdcooper = ass.cdcooper
                                AND   snh.nrdconta = ass.nrdconta
                                AND   snh.tpdsenha = 1) 
            LOOP
                UPDATE crapsnh snh
                   SET snh.vllimnottrans = least(snh.vllimweb, 1000)
                       ,snh.vllimnotpgbo = least(snh.vllimweb, 1000)
                 WHERE snh.tpdsenha = 1
                   AND snh.cdcooper = rw_crapcop.cdcooper
                   AND snh.nrdconta = rw_crapass.nrdconta;
                i := i + 1;
                IF i = 5000 THEN
                    i := 0;
                    COMMIT;
                END IF;
            END LOOP;

            COMMIT;
            i := 0;
        END LOOP;
    COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
END;