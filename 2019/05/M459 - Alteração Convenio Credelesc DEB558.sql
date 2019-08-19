-- Atualização convenio DEB558 CREDELESC - 841111386 (número antigo)
UPDATE craptab
   SET dstextab =  841111914 -- Numero novo
 WHERE cdcooper = 8        -- CREDELESC
   AND nmsistem = 'CRED'
   AND tptabela = 'GENERI'
   AND cdempres = 0
   AND cdacesso = 'COMPEARQBB'
   AND tpregist = 444;
COMMIT;

