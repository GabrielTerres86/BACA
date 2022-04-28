BEGIN
	UPDATE crapaca c
       SET c.lstparam = lstparam || ',pr_qtpreemp'
     WHERE c.nmpackag = 'TELA_ATENDA_SEGURO'
       AND c.nmdeacao = 'CONSULTA_CRAPLCR_TPCUSPR';
	
	INSERT INTO crapprm(nmsistem, cdcooper, cdacesso, dstexprm, dsvlrprm)
    VALUES('CRED', 0, 'FIM_VIG_PRESTAMISTA', 'Quantidade de anos para fim de vigência contratação seguro prestamista', '5');
	
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/
