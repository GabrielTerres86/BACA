DECLARE
  CURSOR cr_crapcop IS
    SELECT c.cdcooper
      FROM cecred.crapcop c
     WHERE c.flgativo = 1
       AND c.cdcooper <> 3;
     
  vr_code NUMBER;
  vr_errm VARCHAR2(64);
BEGIN
  
  FOR rg_crapcop IN cr_crapcop LOOP
    INSERT INTO CECRED.CRAPPRM P
    (nmsistem
    ,cdcooper
    ,cdacesso
    ,dstexprm
    ,dsvlrprm)
    VALUES
    ('CRED'
    ,rg_crapcop.cdcooper
    ,'LIMITE_VALORDEVPIX'
    ,'Limite maximo, por cooperativa, do valor a ser devolvido via Pix no ASVR98'
    ,'1000');
  END LOOP;
  
  COMMIT;    
    
EXCEPTION
  WHEN OTHERS THEN
    vr_code := sqlcode;
    vr_errm := sqlerrm;
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,'Erro ao inserir as Contas Administrativas - ' || vr_code || ' / ' || vr_errm);
END;
