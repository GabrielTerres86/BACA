UPDATE gnsbmod 
SET dssubmod = 'Empréstimo Garantido'
WHERE cdmodali = '02'
  AND cdsubmod = '99';
COMMIT;
/