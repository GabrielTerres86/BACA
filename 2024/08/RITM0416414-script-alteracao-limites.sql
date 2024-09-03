DECLARE
    TYPE Terminais is VARRAY(61) of NUMBER;
    terminaisId Terminais := Terminais(292, 293, 431, 549);
BEGIN  
    FOR i IN 1..terminaisId.COUNT LOOP
        INSERT INTO cecred.craptab (NMSISTEM,TPTABELA,CDEMPRES,CDACESSO,TPREGIST,DSTEXTAB,CDCOOPER)  
               VALUES ('CRED' ,'GENERI',0 ,'SAQMAXCASH' ,terminaisId(i) ,'2000,00' ,1);                     
    END LOOP;
    COMMIT;
END;