DECLARE

    -- A tela deverá ser criara para as coops ativas
    CURSOR cr_crapcop IS
        SELECT c.cdcooper FROM crapcop c WHERE c.flgativo = 1 ORDER BY c.cdcooper;

BEGIN

    BEGIN
        INSERT INTO tbrecip_parame_indica_calculo
            (idparame_reciproci
            ,idindicador
            ,vlminimo
            ,vlmaximo
            ,perscore
            ,pertolera
            ,vlpercentual_peso
            ,vlpercentual_desconto)
        VALUES
            (1, 2, 10000.00, 150000.00, 45.00, 2.00, 40.00, 20.00);
    EXCEPTION
        WHEN dup_val_on_index THEN
            UPDATE tbrecip_parame_indica_calculo
               SET vlminimo              = 10000.00
                  ,vlmaximo              = 150000.00
                  ,vlpercentual_peso     = 40.00
                  ,vlpercentual_desconto = 20.00
             WHERE idparame_reciproci = 1
               AND idindicador = 2;
    END;

    BEGIN
        INSERT INTO tbrecip_parame_indica_calculo
            (idparame_reciproci
            ,idindicador
            ,vlminimo
            ,vlmaximo
            ,perscore
            ,pertolera
            ,vlpercentual_peso
            ,vlpercentual_desconto)
        VALUES
            (1, 3, 20.00, 200.00, 45.00, 2.00, 40.00, 20.00);
    EXCEPTION
        WHEN dup_val_on_index THEN
            UPDATE tbrecip_parame_indica_calculo
               SET vlminimo              = 20.00
                  ,vlmaximo              = 200.00
                  ,vlpercentual_peso     = 40.00
                  ,vlpercentual_desconto = 20.00
             WHERE idparame_reciproci = 1
               AND idindicador = 3;
    END;

    BEGIN
        INSERT INTO tbrecip_parame_indica_calculo
            (idparame_reciproci
            ,idindicador
            ,vlminimo
            ,vlmaximo
            ,perscore
            ,pertolera
            ,vlpercentual_peso
            ,vlpercentual_desconto)
        VALUES
            (1, 21, 1.00, 5.00, NULL, NULL, 20.00, 20.00);
    EXCEPTION
        WHEN dup_val_on_index THEN
            UPDATE tbrecip_parame_indica_calculo
               SET vlminimo = 1.00, vlmaximo = 5.00, vlpercentual_peso = 20.00, vlpercentual_desconto = 20.00
             WHERE idparame_reciproci = 1
               AND idindicador = 21;
    END;

    BEGIN
        INSERT INTO tbrecip_parame_indica_calculo
            (idparame_reciproci
            ,idindicador
            ,vlminimo
            ,vlmaximo
            ,perscore
            ,pertolera
            ,vlpercentual_peso
            ,vlpercentual_desconto)
        VALUES
            (1, 22, 1000.00, 30000.00, NULL, NULL, 50.00, 10.00);
    EXCEPTION
        WHEN dup_val_on_index THEN
            UPDATE tbrecip_parame_indica_calculo
               SET vlminimo              = 1000.00
                  ,vlmaximo              = 30000.00
                  ,vlpercentual_peso     = 50.00
                  ,vlpercentual_desconto = 10.00
             WHERE idparame_reciproci = 1
               AND idindicador = 22;
    END;

    BEGIN
        INSERT INTO tbrecip_parame_indica_calculo
            (idparame_reciproci
            ,idindicador
            ,vlminimo
            ,vlmaximo
            ,perscore
            ,pertolera
            ,vlpercentual_peso
            ,vlpercentual_desconto)
        VALUES
            (1, 23, 1000.00, 30000.00, NULL, NULL, 50.00, 10.00);
    EXCEPTION
        WHEN dup_val_on_index THEN
            UPDATE tbrecip_parame_indica_calculo
               SET vlminimo              = 1000.00
                  ,vlmaximo              = 30000.00
                  ,vlpercentual_peso     = 50.00
                  ,vlpercentual_desconto = 10.00
             WHERE idparame_reciproci = 1
               AND idindicador = 23;
    END;

    -- OUTROS INDICADORES
    BEGIN
        INSERT INTO tbrecip_parame_indica_calculo
            (idparame_reciproci
            ,idindicador
            ,vlminimo
            ,vlmaximo
            ,perscore
            ,pertolera
            ,vlpercentual_peso
            ,vlpercentual_desconto)
        VALUES
            (1, 5, 1.00, 1.00, NULL, NULL, 0.00, 0.00);
    EXCEPTION
        WHEN dup_val_on_index THEN
            UPDATE tbrecip_parame_indica_calculo
               SET vlminimo = 1.00, vlmaximo = 1.00, vlpercentual_peso = 0.00, vlpercentual_desconto = 0.00
             WHERE idparame_reciproci = 1
               AND idindicador = 5;
    END;

    BEGIN
        INSERT INTO tbrecip_parame_indica_calculo
            (idparame_reciproci
            ,idindicador
            ,vlminimo
            ,vlmaximo
            ,perscore
            ,pertolera
            ,vlpercentual_peso
            ,vlpercentual_desconto)
        VALUES
            (2, 5, 1.00, 1.00, NULL, NULL, 0.00, 0.00);
    EXCEPTION
        WHEN dup_val_on_index THEN
            UPDATE tbrecip_parame_indica_calculo
               SET vlminimo = 1.00, vlmaximo = 1.00, vlpercentual_peso = 0.00, vlpercentual_desconto = 0.00
             WHERE idparame_reciproci = 2
               AND idindicador = 5;
    END;

    BEGIN
        INSERT INTO tbrecip_parame_indica_calculo
            (idparame_reciproci
            ,idindicador
            ,vlminimo
            ,vlmaximo
            ,perscore
            ,pertolera
            ,vlpercentual_peso
            ,vlpercentual_desconto)
        VALUES
            (3, 5, 1.00, 1.00, NULL, NULL, 0.00, 0.00);
    EXCEPTION
        WHEN dup_val_on_index THEN
            UPDATE tbrecip_parame_indica_calculo
               SET vlminimo = 1.00, vlmaximo = 1.00, vlpercentual_peso = 0.00, vlpercentual_desconto = 0.00
             WHERE idparame_reciproci = 3
               AND idindicador = 5;
    END;

    BEGIN
        INSERT INTO tbrecip_parame_indica_calculo
            (idparame_reciproci
            ,idindicador
            ,vlminimo
            ,vlmaximo
            ,perscore
            ,pertolera
            ,vlpercentual_peso
            ,vlpercentual_desconto)
        VALUES
            (4, 5, 1.00, 1.00, NULL, NULL, 0.00, 0.00);
    EXCEPTION
        WHEN dup_val_on_index THEN
            UPDATE tbrecip_parame_indica_calculo
               SET vlminimo = 1.00, vlmaximo = 1.00, vlpercentual_peso = 0.00, vlpercentual_desconto = 0.00
             WHERE idparame_reciproci = 4
               AND idindicador = 5;
    END;

    BEGIN
        INSERT INTO tbrecip_parame_indica_calculo
            (idparame_reciproci
            ,idindicador
            ,vlminimo
            ,vlmaximo
            ,perscore
            ,pertolera
            ,vlpercentual_peso
            ,vlpercentual_desconto)
        VALUES
            (1, 6, 1.00, 1.00, NULL, NULL, 0.00, 0.00);
    EXCEPTION
        WHEN dup_val_on_index THEN
            UPDATE tbrecip_parame_indica_calculo
               SET vlminimo = 1.00, vlmaximo = 1.00, vlpercentual_peso = 0.00, vlpercentual_desconto = 0.00
             WHERE idparame_reciproci = 1
               AND idindicador = 6;
    END;

    BEGIN
        INSERT INTO tbrecip_parame_indica_calculo
            (idparame_reciproci
            ,idindicador
            ,vlminimo
            ,vlmaximo
            ,perscore
            ,pertolera
            ,vlpercentual_peso
            ,vlpercentual_desconto)
        VALUES
            (2, 6, 1.00, 1.00, NULL, NULL, 0.00, 0.00);
    EXCEPTION
        WHEN dup_val_on_index THEN
            UPDATE tbrecip_parame_indica_calculo
               SET vlminimo = 1.00, vlmaximo = 1.00, vlpercentual_peso = 0.00, vlpercentual_desconto = 0.00
             WHERE idparame_reciproci = 2
               AND idindicador = 6;
    END;

    BEGIN
        INSERT INTO tbrecip_parame_indica_calculo
            (idparame_reciproci
            ,idindicador
            ,vlminimo
            ,vlmaximo
            ,perscore
            ,pertolera
            ,vlpercentual_peso
            ,vlpercentual_desconto)
        VALUES
            (3, 6, 1.00, 1.00, NULL, NULL, 0.00, 0.00);
    EXCEPTION
        WHEN dup_val_on_index THEN
            UPDATE tbrecip_parame_indica_calculo
               SET vlminimo = 1.00, vlmaximo = 1.00, vlpercentual_peso = 0.00, vlpercentual_desconto = 0.00
             WHERE idparame_reciproci = 3
               AND idindicador = 6;
    END;

    BEGIN
        INSERT INTO tbrecip_parame_indica_calculo
            (idparame_reciproci
            ,idindicador
            ,vlminimo
            ,vlmaximo
            ,perscore
            ,pertolera
            ,vlpercentual_peso
            ,vlpercentual_desconto)
        VALUES
            (4, 6, 1.00, 1.00, NULL, NULL, 0.00, 0.00);
    EXCEPTION
        WHEN dup_val_on_index THEN
            UPDATE tbrecip_parame_indica_calculo
               SET vlminimo = 1.00, vlmaximo = 1.00, vlpercentual_peso = 0.00, vlpercentual_desconto = 0.00
             WHERE idparame_reciproci = 4
               AND idindicador = 6;
    END;

    BEGIN
        INSERT INTO tbrecip_parame_indica_calculo
            (idparame_reciproci
            ,idindicador
            ,vlminimo
            ,vlmaximo
            ,perscore
            ,pertolera
            ,vlpercentual_peso
            ,vlpercentual_desconto)
        VALUES
            (1, 7, 1.00, 1.00, NULL, NULL, 0.00, 0.00);
    EXCEPTION
        WHEN dup_val_on_index THEN
            UPDATE tbrecip_parame_indica_calculo
               SET vlminimo = 1.00, vlmaximo = 1.00, vlpercentual_peso = 0.00, vlpercentual_desconto = 0.00
             WHERE idparame_reciproci = 1
               AND idindicador = 7;
    END;

    BEGIN
        INSERT INTO tbrecip_parame_indica_calculo
            (idparame_reciproci
            ,idindicador
            ,vlminimo
            ,vlmaximo
            ,perscore
            ,pertolera
            ,vlpercentual_peso
            ,vlpercentual_desconto)
        VALUES
            (2, 7, 1.00, 1.00, NULL, NULL, 0.00, 0.00);
    EXCEPTION
        WHEN dup_val_on_index THEN
            UPDATE tbrecip_parame_indica_calculo
               SET vlminimo = 1.00, vlmaximo = 1.00, vlpercentual_peso = 0.00, vlpercentual_desconto = 0.00
             WHERE idparame_reciproci = 2
               AND idindicador = 7;
    END;

    BEGIN
        INSERT INTO tbrecip_parame_indica_calculo
            (idparame_reciproci
            ,idindicador
            ,vlminimo
            ,vlmaximo
            ,perscore
            ,pertolera
            ,vlpercentual_peso
            ,vlpercentual_desconto)
        VALUES
            (3, 7, 1.00, 1.00, NULL, NULL, 0.00, 0.00);
    EXCEPTION
        WHEN dup_val_on_index THEN
            UPDATE tbrecip_parame_indica_calculo
               SET vlminimo = 1.00, vlmaximo = 1.00, vlpercentual_peso = 0.00, vlpercentual_desconto = 0.00
             WHERE idparame_reciproci = 3
               AND idindicador = 7;
    END;

    BEGIN
        INSERT INTO tbrecip_parame_indica_calculo
            (idparame_reciproci
            ,idindicador
            ,vlminimo
            ,vlmaximo
            ,perscore
            ,pertolera
            ,vlpercentual_peso
            ,vlpercentual_desconto)
        VALUES
            (4, 7, 1.00, 1.00, NULL, NULL, 0.00, 0.00);
    EXCEPTION
        WHEN dup_val_on_index THEN
            UPDATE tbrecip_parame_indica_calculo
               SET vlminimo = 1.00, vlmaximo = 1.00, vlpercentual_peso = 0.00, vlpercentual_desconto = 0.00
             WHERE idparame_reciproci = 4
               AND idindicador = 7;
    END;

    FOR rw_crapcop IN cr_crapcop LOOP
    
        BEGIN
            INSERT INTO tbrecip_parame_indica_coop
                (cdcooper
                ,idindicador
                ,cdproduto
                ,inpessoa
                ,vlminimo
                ,vlmaximo
                ,perscore
                ,pertolera
                ,flgativo
                ,vlpercentual_peso
                ,vlpercentual_desconto)
            VALUES
                (rw_crapcop.cdcooper, 2, 6, 1, 1000.00, 100000.00, 0.00, 0.00, 1, NULL, NULL);
        EXCEPTION
            WHEN dup_val_on_index THEN
                UPDATE tbrecip_parame_indica_coop
                   SET vlminimo              = 1000.00
                      ,vlmaximo              = 100000.00
                      ,perscore              = 0.00
                      ,pertolera             = 0.00
                      ,flgativo              = 1
                      ,vlpercentual_peso     = NULL
                      ,vlpercentual_desconto = NULL
                 WHERE cdcooper = rw_crapcop.cdcooper
                   AND idindicador = 2
                   AND cdproduto = 6
                   AND inpessoa = 1;
        END;
    
        BEGIN
            INSERT INTO tbrecip_parame_indica_coop
                (cdcooper
                ,idindicador
                ,cdproduto
                ,inpessoa
                ,vlminimo
                ,vlmaximo
                ,perscore
                ,pertolera
                ,flgativo
                ,vlpercentual_peso
                ,vlpercentual_desconto)
            VALUES
                (rw_crapcop.cdcooper, 3, 6, 1, 5.00, 100.00, 0.00, 0.00, 1, NULL, NULL);
        EXCEPTION
            WHEN dup_val_on_index THEN
                UPDATE tbrecip_parame_indica_coop
                   SET vlminimo              = 5.00
                      ,vlmaximo              = 100.00
                      ,perscore              = 0.00
                      ,pertolera             = 0.00
                      ,flgativo              = 1
                      ,vlpercentual_peso     = NULL
                      ,vlpercentual_desconto = NULL
                 WHERE cdcooper = rw_crapcop.cdcooper
                   AND idindicador = 3
                   AND cdproduto = 6
                   AND inpessoa = 1;
        END;
    
        BEGIN
            INSERT INTO tbrecip_parame_indica_coop
                (cdcooper
                ,idindicador
                ,cdproduto
                ,inpessoa
                ,vlminimo
                ,vlmaximo
                ,perscore
                ,pertolera
                ,flgativo
                ,vlpercentual_peso
                ,vlpercentual_desconto)
            VALUES
                (rw_crapcop.cdcooper, 21, 6, 1, 1.00, 5.00, NULL, NULL, 1, 20.00, 20.00);
        EXCEPTION
            WHEN dup_val_on_index THEN
                UPDATE tbrecip_parame_indica_coop
                   SET vlminimo              = 1.00
                      ,vlmaximo              = 5.00
                      ,perscore              = NULL
                      ,pertolera             = NULL
                      ,flgativo              = 1
                      ,vlpercentual_peso     = 20.00
                      ,vlpercentual_desconto = 20.00
                 WHERE cdcooper = rw_crapcop.cdcooper
                   AND idindicador = 21
                   AND cdproduto = 6
                   AND inpessoa = 1;
        END;
    
        BEGIN
            INSERT INTO tbrecip_parame_indica_coop
                (cdcooper
                ,idindicador
                ,cdproduto
                ,inpessoa
                ,vlminimo
                ,vlmaximo
                ,perscore
                ,pertolera
                ,flgativo
                ,vlpercentual_peso
                ,vlpercentual_desconto)
            VALUES
                (rw_crapcop.cdcooper, 22, 6, 1, 1000.00, 30000.00, NULL, NULL, 1, 50.00, 10.00);
        EXCEPTION
            WHEN dup_val_on_index THEN
                UPDATE tbrecip_parame_indica_coop
                   SET vlminimo              = 1000.00
                      ,vlmaximo              = 30000.00
                      ,perscore              = NULL
                      ,pertolera             = NULL
                      ,flgativo              = 1
                      ,vlpercentual_peso     = 50.00
                      ,vlpercentual_desconto = 10.00
                 WHERE cdcooper = rw_crapcop.cdcooper
                   AND idindicador = 22
                   AND cdproduto = 6
                   AND inpessoa = 1;
        END;
    
        BEGIN
            INSERT INTO tbrecip_parame_indica_coop
                (cdcooper
                ,idindicador
                ,cdproduto
                ,inpessoa
                ,vlminimo
                ,vlmaximo
                ,perscore
                ,pertolera
                ,flgativo
                ,vlpercentual_peso
                ,vlpercentual_desconto)
            VALUES
                (rw_crapcop.cdcooper, 23, 6, 1, 1000.00, 30000.00, NULL, NULL, 1, 50.00, 10.00);
        EXCEPTION
            WHEN dup_val_on_index THEN
                UPDATE tbrecip_parame_indica_coop
                   SET vlminimo              = 1000.00
                      ,vlmaximo              = 30000.00
                      ,perscore              = NULL
                      ,pertolera             = NULL
                      ,flgativo              = 1
                      ,vlpercentual_peso     = 50.00
                      ,vlpercentual_desconto = 10.00
                 WHERE cdcooper = rw_crapcop.cdcooper
                   AND idindicador = 23
                   AND cdproduto = 6
                   AND inpessoa = 1;
            
        END;
    
        -- INPESSOA 2
        BEGIN
            INSERT INTO tbrecip_parame_indica_coop
                (cdcooper
                ,idindicador
                ,cdproduto
                ,inpessoa
                ,vlminimo
                ,vlmaximo
                ,perscore
                ,pertolera
                ,flgativo
                ,vlpercentual_peso
                ,vlpercentual_desconto)
            VALUES
                (rw_crapcop.cdcooper, 21, 6, 2, 1.00, 5.00, NULL, NULL, 1, 20.00, 20.00);
        EXCEPTION
            WHEN dup_val_on_index THEN
                UPDATE tbrecip_parame_indica_coop
                   SET vlminimo              = 1.00
                      ,vlmaximo              = 5.00
                      ,perscore              = NULL
                      ,pertolera             = NULL
                      ,flgativo              = 1
                      ,vlpercentual_peso     = 20.00
                      ,vlpercentual_desconto = 20.00
                 WHERE cdcooper = rw_crapcop.cdcooper
                   AND idindicador = 21
                   AND cdproduto = 6
                   AND inpessoa = 2;
        END;
    
        BEGIN
            INSERT INTO tbrecip_parame_indica_coop
                (cdcooper
                ,idindicador
                ,cdproduto
                ,inpessoa
                ,vlminimo
                ,vlmaximo
                ,perscore
                ,pertolera
                ,flgativo
                ,vlpercentual_peso
                ,vlpercentual_desconto)
            VALUES
                (rw_crapcop.cdcooper, 22, 6, 2, 1000.00, 30000.00, NULL, NULL, 1, 50.00, 10.00);
        EXCEPTION
            WHEN dup_val_on_index THEN
                UPDATE tbrecip_parame_indica_coop
                   SET vlminimo              = 1000.00
                      ,vlmaximo              = 30000.00
                      ,perscore              = NULL
                      ,pertolera             = NULL
                      ,flgativo              = 1
                      ,vlpercentual_peso     = 50.00
                      ,vlpercentual_desconto = 10.00
                 WHERE cdcooper = rw_crapcop.cdcooper
                   AND idindicador = 22
                   AND cdproduto = 6
                   AND inpessoa = 2;
        END;
    
        BEGIN
            INSERT INTO tbrecip_parame_indica_coop
                (cdcooper
                ,idindicador
                ,cdproduto
                ,inpessoa
                ,vlminimo
                ,vlmaximo
                ,perscore
                ,pertolera
                ,flgativo
                ,vlpercentual_peso
                ,vlpercentual_desconto)
            VALUES
                (rw_crapcop.cdcooper, 23, 6, 2, 1000.00, 30000.00, NULL, NULL, 1, 50.00, 10.00);
        EXCEPTION
            WHEN dup_val_on_index THEN
                UPDATE tbrecip_parame_indica_coop
                   SET vlminimo              = 1000.00
                      ,vlmaximo              = 30000.00
                      ,perscore              = NULL
                      ,pertolera             = NULL
                      ,flgativo              = 1
                      ,vlpercentual_peso     = 50.00
                      ,vlpercentual_desconto = 10.00
                 WHERE cdcooper = rw_crapcop.cdcooper
                   AND idindicador = 23
                   AND cdproduto = 6
                   AND inpessoa = 2;
        END;
    
    END LOOP;

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Erro: ' || SQLERRM);
        ROLLBACK;
END;
