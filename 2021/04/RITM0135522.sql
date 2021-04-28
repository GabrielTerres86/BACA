-- RITM0135522
BEGIN
	
	DELETE FROM CRAPACE
    WHERE UPPER(NMDATELA) = 'RECJUD'
    AND UPPER(CDOPERAD) = '1'
    AND UPPER(NMROTINA) = ' '
    AND UPPER(CDDOPCAO) = 'C'
    AND cdcooper IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17)

	UPDATE craptel t   
	SET t.cdopptel = '@,I,E,R'
      	,t.lsopptel = 'ACESSO,INCLUSAO,EXCLUSAO,RELATORIO'
 	WHERE UPPER(t.NMDATELA) = 'RECJUD'
   	AND UPPER(t.NMROTINA) = ' '
   	AND t.cdcooper IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17)

	COMMIT;
END;