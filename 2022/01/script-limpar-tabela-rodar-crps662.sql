BEGIN
  
UPDATE craphec d 
  SET d.dtultexc = NULL,
      d.hrultexc = 0
WHERE d.cdcooper = 3 AND d.dsprogra LIKE 'DEVOLUCAO DIURNA' AND d.cdprogra LIKE 'crps264.p';
COMMIT;
END;
