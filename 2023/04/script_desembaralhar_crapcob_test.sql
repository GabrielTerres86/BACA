-- Created on 17/04/2023 by F0030248 
declare 
  -- Local variables here
  i integer;

begin
  
  FOR cop IN (SELECT cdcooper FROM crapcop 
	             WHERE cdcooper <> 3 
                 AND cdcooper > 1 
                 AND flgativo = 1) LOOP
   
    FOR rw IN ( SELECT cco.cdcooper, ceb.nrdconta, cco.nrconven, cco.nrdctabb 
                  FROM crapcco cco, 
                       crapceb ceb
                 WHERE cco.cdcooper = cop.cdcooper
                   AND cco.cddbanco = 85
                   AND ceb.cdcooper = cco.cdcooper
                   AND ceb.nrconven = cco.nrconven
                   ) LOOP  
     
        -- update para desembaralhar base de dados
        UPDATE crapcob cob SET nrdctabb = rw.nrdctabb, nrnosnum = to_char(cob.nrdconta,'fm00000000') || to_char(cob.nrdocmto,'fm000000000')
         WHERE cob.cdcooper = rw.cdcooper
           AND cob.nrdconta = rw.nrdconta
           AND cob.nrcnvcob = rw.nrconven;
    
    END LOOP;
    
    COMMIT;

  END LOOP;
  
  EXCEPTION
		WHEN OTHERS THEN
			ROLLBACK;
     
end;
