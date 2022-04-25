BEGIN
	UPDATE crapaca c
	   SET c.lstparam = lstparam || ', pr_flgassum, pr_flggarad'
	 WHERE c.nmpackag = 'TELA_ATENDA_SIMULACAO'
	   AND c.nmdeacao = 'SIMULA_GRAVA_SIMULACAO';
	 
	COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
/

