UPDATE crapprg p 
   SET p.inlibprg = 2 -- Bloqueado
 WHERE upper(p.cdprogra) IN ('CRPS637');
COMMIT;
