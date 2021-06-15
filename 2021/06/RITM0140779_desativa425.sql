--RITM0140779_desativa425.sql 17 registros
UPDATE crapprg p
   SET p.NRSOLICI = 999
      ,p.INLIBPRG = 2
 WHERE p.CDPROGRA = 'CRPS425';

COMMIT;
