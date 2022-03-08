BEGIN
    DECLARE
    CURSOR c_coop
    IS
        SELECT 
            CDCOOPER
        FROM 
            crapcop;
    BEGIN
    FOR r_coop IN c_coop
    LOOP
        insert into CRAPPRM(NMSISTEM, CDCOOPER,CDACESSO,DSTEXPRM,DSVLRPRM) values ('CDC', r_coop.CDCOOPER,'SNINTEGRA_CONVENIO_CDC', 'Ativa/Desativa integração de convênios CDC com esteira de crédito', '0');
    END LOOP;
    END;
END;
/
