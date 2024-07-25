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
        ,7000
    from crapass
   where cdcooper = 16;

DELETE FROM cecred.tbgen_batch_paralelo bp
 WHERE bp.cdcooper = 16
   AND bp.dtmvtolt >= trunc(to_date('23/05/2024', 'dd/mm/yyyy'));

    
  COMMIT;  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000, 'ERRO: ' || SQLERRM);
END;