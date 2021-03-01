
	UPDATE TBCADAST_PESSOA_ENDERECO
	   SET dscomplemento = REPLACE( dscomplemento, CHR(26) )
	WHERE INSTR( dscomplemento, chr(26) ) > 0; 
    
    COMMIT;
