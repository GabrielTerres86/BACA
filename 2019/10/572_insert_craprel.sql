DECLARE
  
  CURSOR cr_crapcop is
  select cop.cdcooper
    from crapcop cop;
    
begin
  
  FOR rw_crapcop IN cr_crapcop LOOP
    BEGIN
		INSERT INTO CRAPREL (CDRELATO
							, NMRELATO
							, NMDESTIN
							, NMFORMUL
							, CDCOOPER) 
					VALUES (774
							, 'CESSAO NAO LOCALIZADA'
							, 'RECUPERACAO DE CREDITO'
							, '132col'
							, rw_crapcop.cdcooper);
	EXCEPTION
      WHEN dup_val_on_index THEN
        RAISE_APPLICATION_ERROR(-20001,'Relatorio ja cadastrado: '||SQLERRM);
      WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002,'Erro ao inserir CRAPREL: '||SQLERRM);
    END;
  END LOOP;
  COMMIT;

END;