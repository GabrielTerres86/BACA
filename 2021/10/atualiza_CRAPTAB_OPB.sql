BEGIN
 UPDATE 
	CRAPTAB 
 SET 
	DSTEXTAB = "000000050000,00;99;3;000000000000,00;024;000000050000,00;000000700000,00;99;3;000000000000,00;024;000000700000,00;000000050000,00;000000700000,00;000000050000,00;000000700000,00;999;010;010;3;3;3;000000250000,00;000000000002,00;000000020000,00;000000250000,00;000000000002,00;000000250000,00;003;003;024;024;024;024;000000020000,00;000000200000,00;000000005000,00;000000005000,00"
 WHERE 
	CDCOOPER = 12 
	AND TPTABELA = 'GENERI'
	AND CDACESSO = 'LIMINTERNT'
	AND TPREGIST = 2;
 commit;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;    
END;