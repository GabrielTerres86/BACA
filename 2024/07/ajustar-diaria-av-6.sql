BEGIN

delete from crapsqu
 where UPPER(nmtabela) = upper('CRAPNEG')
   and UPPER(nmdcampo) = upper('NRSEQDIG')
   and UPPER(dsdchave) like upper('16;%');

insert into crapsqu
  (nmtabela
  ,nmdcampo
  ,dsdchave
  ,nrseqatu)
  select 'CRAPNEG'
        ,'NRSEQDIG'
        ,'16;' || nrdconta
        ,6000
    from crapass
   where cdcooper = 16;

    
  COMMIT;  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000, 'ERRO: ' || SQLERRM);
END;