UPDATE crapprg p 
   SET p.inlibprg = 2 -- Bloqueado
 WHERE upper(p.cdprogra) IN ('CRPS266','CRPS637');
COMMIT;
