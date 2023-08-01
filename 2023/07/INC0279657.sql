BEGIN

 update cecred.crapass set inpessoa = 3
  where progress_recid in (1045509,1046343,1046350,1128216,1588484)
  and cdcooper = 1;
  
 update cecred.crapass set inpessoa = 3
  where progress_recid in (435542,435543)
    and cdcooper = 2;
    
 update cecred.crapass set inpessoa = 3
  where progress_recid = 1257178
    and cdcooper = 13;
    
 update cecred.crapass set inpessoa = 3
  where progress_recid = 1093991
    and cdcooper = 11;
  
  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000,
                            'Erro ao efetuar atualização de tipo de pessoa (' ||sqlerrm);
END;
/