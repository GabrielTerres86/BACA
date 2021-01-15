DECLARE 
  
  CURSOR crapprg_ord IS
    SELECT NVL(MAX(t.nrordprg),0) + 10
      FROM crapprg t
     WHERE t.cdcooper = 1
       AND t.nrsolici = 999;

  vr_nrordprg  NUMBER;
  
BEGIN
  
  -- Encontrar a ordem do programa na fila 999
  OPEN  crapprg_ord;
  FETCH crapprg_ord INTO vr_nrordprg;
  CLOSE crapprg_ord;

  UPDATE crapprg t 
     SET t.nrsolici = 999 -- Retirar da execução do processo batch
       , t.nrordprg = vr_nrordprg
   WHERE t.cdprogra = 'CRPS691'
     AND t.cdcooper = 1;
     
  COMMIT;
  
END;
