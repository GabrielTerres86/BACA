UPDATE tbdscc_ocorrencias oco
   SET oco.flgbloqueio = 0
      ,oco.dsocorre    = 'Cooperado possui ou causou prejuízo'
 WHERE oco.cdocorre = 13;
 
COMMIT;