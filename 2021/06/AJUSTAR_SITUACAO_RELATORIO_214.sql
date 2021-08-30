BEGIN

UPDATE crapslr a
   SET a.dtiniger = NULL
      ,a.dtfimger = NULL
      ,a.flgerado = 'N'
      ,a.dserrger = NULL
 WHERE a.nrseqsol IN (28028428, 28028432, 28028436, 28028416, 28028420, 28028424);

COMMIT;

END;