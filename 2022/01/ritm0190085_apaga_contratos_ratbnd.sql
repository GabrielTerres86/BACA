-- Created on 10/01/2022 by T0034423
DECLARE
    CURSOR c1 IS
		--CIVIA
        SELECT regexp_substr('637254,184730,426440,535672,335070,634727,140996', '[^,]+', 1, LEVEL) AS pr_nrdconta,
               regexp_substr('148900,54430,146553,145864,142991,147781,142958', '[^,]+', 1, LEVEL) AS pr_nrctrato,
               regexp_substr('13,13,13,13,13,13,13', '[^,]+', 1, LEVEL) AS pr_cdcooper
        FROM   dual
        CONNECT BY regexp_substr('637254,184730,426440,535672,335070,634727,140996', '[^,]+', 1, LEVEL) IS NOT NULL
        UNION ALL
        --EVOLUA 
        SELECT regexp_substr('167649,256412,256412,280020,275239,214647', '[^,]+', 1, LEVEL) AS pr_nrdconta,
               regexp_substr('24007,1,28985,1,1,23567', '[^,]+', 1, LEVEL) AS pr_nrctrato,
               regexp_substr('14,14,14,14,14,14', '[^,]+', 1, LEVEL) AS pr_cdcooper
        FROM   dual
        CONNECT BY regexp_substr('167649,256412,256412,280020,275239,214647', '[^,]+', 1, LEVEL) IS NOT NULL
        UNION ALL
        --CREDCREA
        SELECT regexp_substr('178314', '[^,]+', 1, LEVEL) AS pr_nrdconta,
               regexp_substr('65386', '[^,]+', 1, LEVEL) AS pr_nrctrato,
               regexp_substr('7', '[^,]+', 1, LEVEL) AS pr_cdcooper
        FROM   dual
        CONNECT BY regexp_substr('178314', '[^,]+', 1, LEVEL) IS NOT NULL
        UNION ALL
        --ACREDICOOP
        SELECT regexp_substr('738581,754501,1050265,823252,836354', '[^,]+', 1, LEVEL) AS pr_nrdconta,
               regexp_substr('335553,321088,325959,2,338032', '[^,]+', 1, LEVEL) AS pr_nrctrato,
               regexp_substr('2,2,2,2,2', '[^,]+', 1, LEVEL) AS pr_cdcooper
        FROM   dual
        CONNECT BY regexp_substr('738581,754501,1050265,823252,836354', '[^,]+', 1, LEVEL) IS NOT NULL
        UNION ALL
        --TRANSPOCRED
        SELECT regexp_substr('366005', '[^,]+', 1, LEVEL) AS pr_nrdconta,
               regexp_substr('58772', '[^,]+', 1, LEVEL) AS pr_nrctrato,
               regexp_substr('9', '[^,]+', 1, LEVEL) AS pr_cdcooper
        FROM   dual
        CONNECT BY regexp_substr('366005', '[^,]+', 1, LEVEL) IS NOT NULL;
BEGIN
    FOR r1 IN c1 LOOP
        --Exclusao da proposta
        BEGIN
            DELETE FROM crapprp
            WHERE  cdcooper = r1.pr_cdcooper
                   AND nrdconta = r1.pr_nrdconta
                   AND nrctrato = r1.pr_nrctrato;
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
        END;
        --Exclusão do rendimento
        BEGIN
            DELETE FROM craprpr
            WHERE  cdcooper = r1.pr_cdcooper
                   AND nrdconta = r1.pr_nrdconta
                   AND nrctrato = r1.pr_nrctrato;
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
        END;
        --Exclusão do bem da proposta
        BEGIN
            DELETE FROM crapbpr
            WHERE  cdcooper = r1.pr_cdcooper
                   AND nrdconta = r1.pr_nrdconta
                   AND nrctrpro = r1.pr_nrctrato;
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
        END;
        --Exclusão do SCR para do aval
        BEGIN
            DELETE FROM crapavt
            WHERE  cdcooper = r1.pr_cdcooper
                   AND nrdconta = r1.pr_nrdconta
                   AND nrctremp = r1.pr_nrctrato;
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
        END;
        --Exclusão das notas do rating por contrato
        BEGIN
            DELETE FROM crapnrc
            WHERE  cdcooper = r1.pr_cdcooper
                   AND nrdconta = r1.pr_nrdconta
                   AND nrctrrat = r1.pr_nrctrato;
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
        END;
        --Exclusão do historico das notas por contrato
        BEGIN
            DELETE FROM cecred.tbrat_hist_nota_contrato
            WHERE  cdcooper = r1.pr_cdcooper
                   AND nrdconta = r1.pr_nrdconta
                   AND nrctrrat = r1.pr_nrctrato;
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
        END;
        --Exclusão das informações do rating por contrato
        BEGIN
            DELETE FROM cecred.tbrat_informacao_rating
            WHERE  cdcooper = r1.pr_cdcooper
                   AND nrdconta = r1.pr_nrdconta
                   AND nrctrrat = r1.pr_nrctrato;
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
