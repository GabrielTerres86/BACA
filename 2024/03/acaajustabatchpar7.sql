BEGIN
delete from crapsqu
 where UPPER(nmtabela) = upper('CRAPNEG')
   and UPPER(nmdcampo) = upper('NRSEQDIG')
   and UPPER(dsdchave) like upper('10;%');

insert into crapsqu
  (nmtabela
  ,nmdcampo
  ,dsdchave
  ,nrseqatu)
  select 'CRAPNEG'
        ,'NRSEQDIG'
        ,'10;' || nrdconta
        ,2210
    from crapass
   where cdcooper = 10;
   

DELETE FROM cecred.tbgen_batch_paralelo bp
 WHERE bp.cdcooper = 10
   AND bp.dtmvtolt >= trunc(to_date('01/01/2024', 'dd/mm/yyyy'));
   
    
  COMMIT;  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000, 'ERRO: ' || SQLERRM);
END;