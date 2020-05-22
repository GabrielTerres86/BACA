BEGIN 
  
  -- Excluir dados de valores
  DELETE crapfco x
   WHERE x.cdfaixav IN (SELECT f.cdfaixav
                          FROM crapfvl f
                         WHERE f.cdtarifa IN (419,420,421,422,423,424,425,426,427,428
                                             ,429,430,431,432,433,434,435,436,437));
    
   -- Excluir dados de faixa valores                
   DELETE crapfvl t
    WHERE t.cdtarifa IN (419,420,421,422,423,424,425,426,427,428
                        ,429,430,431,432,433,434,435,436,437);
                        
  -- Excluir as tarifas
  DELETE craptar t
    WHERE t.cdtarifa IN (419,420,421,422,423,424,425,426,427,428
                        ,429,430,431,432,433,434,435,436,437);
  
  COMMIT;
END;
