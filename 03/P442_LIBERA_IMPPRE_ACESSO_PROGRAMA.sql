DECLARE
  idx PLS_INTEGER := 1;
  
  CURSOR cr_busca_cad(pr_cdcooper IN NUMBER) IS
    SELECT cdcooper
    FROM crapprg
    WHERE cdprogra = UPPER('imppre')
      AND cdcooper = pr_cdcooper;
  rw_busca_cad cr_busca_cad%ROWTYPE;

BEGIN
  WHILE idx <= 17 LOOP
    OPEN cr_busca_cad(pr_cdcooper => idx);
    FETCH cr_busca_cad INTO rw_busca_cad;
    
    IF cr_busca_cad%NOTFOUND THEN
      INSERT INTO crapprg(nmsistem
                         ,cdprogra
                         ,dsprogra##1
                         ,nrsolici
                         ,nrordprg
                         ,inctrprg
                         ,cdrelato##1
                         ,cdrelato##2
                         ,cdrelato##3
                         ,cdrelato##4
                         ,cdrelato##5
                         ,inlibprg
                         ,cdcooper)
        VALUES('CRED'
              ,'IMPPRE'
              ,'CRIACAO E IMPORTACAO DE CARGAS MANUAIS'
              ,994
              ,300
              ,1
              ,0
              ,0
              ,0
              ,0
              ,0
              ,1
              ,idx);
    END IF;
    
    CLOSE cr_busca_cad;
    
    idx := idx + 1;
  END LOOP;
END;
