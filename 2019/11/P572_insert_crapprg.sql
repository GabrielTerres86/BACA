DECLARE
  
  CURSOR cr_crapcop is
  select cop.cdcooper
    from crapcop cop;
    
begin
  
  FOR rw_crapcop IN cr_crapcop LOOP
    BEGIN
		INSERT INTO CRAPPRG (NMSISTEM, 
						CDPROGRA, 
						DSPROGRA##1, 
						NRSOLICI, 
						CDRELATO##1, 
						CDCOOPER) 
				VALUES ('CRED', 
						'CCRD0009', 
						'GERAR O RELATORIO CESSAO NAO LOCALIZADA', 
						572, 
						774, 
						rw_crapcop.cdcooper);
	EXCEPTION
      WHEN dup_val_on_index THEN
        RAISE_APPLICATION_ERROR(-20001,'Programa ja cadastrado: '||SQLERRM);
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002,'Erro ao inserir CRAPPRG: '||SQLERRM);
    END;
  END LOOP;
  COMMIT;

END;