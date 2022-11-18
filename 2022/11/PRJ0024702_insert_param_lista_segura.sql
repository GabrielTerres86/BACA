BEGIN
 insert into cecred.crapaca aca (aca.nmdeacao, 
                                 aca.nmpackag, 
                                 aca.nmproced, 
                                 aca.lstparam, 
                                 aca.nrseqrdr)
 values ('CADA0006_ATUALIZA_LISTA_SEGURA',
         'CADA0006',
         'pc_atualiza_lista_segura',
         'pr_cdcooper,pr_nrdconta,pr_lstlsdif,pr_inaddexc',
          1106);
    
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/

