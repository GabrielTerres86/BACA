PL/SQL Developer Test script 3.0
51
DECLARE 
  CURSOR cr_cop IS
    SELECT c.cdcooper
      FROM crapcop c
     WHERE c.flgativo = 1;
     
  CURSOR cr_param(pr_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT nmsistem, cdcooper, cdacesso
      FROM crapprm
      WHERE cdcooper       = pr_cdcooper
        AND nmsistem       = 'CRED'
        AND cdacesso       = 'HABILITA_RATING_NOVO';
  rw_crapprm cr_param%ROWTYPE;
  
BEGIN
  dbms_output.put_line('inicio: ' || to_char(SYSDATE,'hh24:mi:ss'));

  --Tratar cooperados
  FOR rw_cop IN cr_cop LOOP
    OPEN cr_param(pr_cdcooper => rw_cop.cdcooper);
    FETCH cr_param INTO rw_crapprm;
    IF cr_param%NOTFOUND THEN
      IF rw_cop.cdcooper = 3 THEN
        INSERT INTO crapprm 
              VALUES('CRED'
                    ,rw_cop.cdcooper
                    ,'HABILITA_RATING_NOVO'
                    ,'Habilita novo rating nas cooperativas P450 (S/N)'
                    ,'N'
                    ,NULL);
        dbms_output.put_line('Adicionado parâmetro habilita rating novo na coop N: ' || rw_cop.cdcooper);
      ELSE
        INSERT INTO crapprm 
              VALUES('CRED'
                    ,rw_cop.cdcooper
                    ,'HABILITA_RATING_NOVO'
                    ,'Habilita novo rating nas cooperativas P450 (S/N)'
                    ,'S'
                    ,NULL);
        dbms_output.put_line('Adicionado parâmetro habilita rating novo na coop S: ' || rw_cop.cdcooper);
      END IF;
    ELSE
      dbms_output.put_line('Parâmetro existente na coop: ' || rw_cop.cdcooper);
    END IF;
    CLOSE cr_param;
  END LOOP;
  --Grava atualizações
  COMMIT;
  dbms_output.put_line('fim: ' || to_char(SYSDATE,'hh24:mi:ss'));
  
END;
0
0
