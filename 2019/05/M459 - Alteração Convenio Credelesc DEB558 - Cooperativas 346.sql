-- Atualização convenio DEB558 CREDELESC - 841111914 (número antigo - cooperativas)
UPDATE craptab
   SET dstextab =  841405624 -- Numero novo
 WHERE cdcooper = 8        -- CREDELESC
   AND nmsistem = 'CRED'
   AND tptabela = 'GENERI'
   AND cdempres = 0
   AND cdacesso = 'COMPEARQBB'
   AND tpregist = 346;   -- Cooperativa
COMMIT;

