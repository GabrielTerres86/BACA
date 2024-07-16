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
        ,4500
    from crapass
   where cdcooper = 16;

DELETE FROM cecred.tbgen_batch_paralelo bp
 WHERE bp.cdcooper = 16
   AND bp.dtmvtolt >= trunc(to_date('22/05/2024', 'dd/mm/yyyy'));
   
  DELETE FROM crapsld s
   WHERE s.cdcooper = 16
         AND s.dtrefere = to_date('21/05/2024', 'dd/mm/yyyy');

  UPDATE crapsld s
     SET s.dtrefere = to_date('21/05/2024', 'dd/mm/yyyy')
   WHERE s.cdcooper = 16
         AND s.dtrefere = to_date('23/04/2024', 'dd/mm/yyyy');
    
  COMMIT;  
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20000, 'ERRO: ' || SQLERRM);
END;