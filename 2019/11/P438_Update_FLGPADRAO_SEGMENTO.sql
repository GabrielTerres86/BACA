UPDATE TBEPR_SEGMENTO_TPPESSOA_PERM p
  SET p.FLGPADRAO = 1 
WHERE (p.tppessoa = 1 
  AND p.idsegmento = 1 )
  OR (p.tppessoa = 2 
  AND p.idsegmento = 2);
  
COMMIT;  
  
