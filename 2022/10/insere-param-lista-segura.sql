DECLARE
BEGIN

  insert into CECRED.crapaca (nmdeacao,
                              nmpackag,
                              nmproced,
                              lstparam,
			      nrseqrdr)
  values   
     ('CADA0006_ATUALIZA_LISTA_SEGURA',
      'CADA0006',
      'pc_atualiza_lista_segura',
      'pr_cdcooper,pr_nrdconta,pr_lstlsdif,pr_inaddexc',
       1106);

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
	RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;