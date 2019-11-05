
BEGIN
  UPDATE craptel
     SET cdopptel = cdopptel || ',L,T',
         lsopptel = lsopptel || ',ANALISAR,ALTERAR RATING'
   where nmdatela like '%ATENDA%'
     and nmrotina like 'DSC CHQS - LIMITE'
     and (cdopptel not like '%L%' AND cdopptel not like '%T%');
  COMMIT;
END;
