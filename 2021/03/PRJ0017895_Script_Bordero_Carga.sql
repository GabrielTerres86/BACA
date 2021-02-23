DECLARE
BEGIN

  FOR rw_crapcop IN (SELECT cop.cdcooper
                       FROM crapcop cop
                      WHERE cop.flgativo = 1) LOOP
  
    FOR rw_craplim IN (SELECT DISTINCT (lim.nrdconta) nrdconta
                         FROM craplim lim
                        WHERE lim.cdcooper = rw_crapcop.cdcooper
                          AND lim.tpctrlim = 2) LOOP
    
      UPDATE crapbdc bdc
         SET bdc.insitapr = 2 -- Aprovado
            ,bdc.insitest = 3 -- Analise Finalizada
       WHERE bdc.cdcooper = rw_crapcop.cdcooper
         AND bdc.nrdconta = rw_craplim.nrdconta
         AND bdc.dtlibbdc IS NOT NULL;
    
    END LOOP;
  
   COMMIT;
  
  END LOOP;
END;
/
                    
                      
         
     
