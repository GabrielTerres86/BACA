-- Atualização  convenio CREDICOMIN - 841112678
UPDATE craptab
   SET dstextab = 841403828 -- numero novo
 WHERE cdcooper = 10        -- CREDICOMIN 
   AND nmsistem = 'CRED'
   AND tptabela = 'GENERI'
   AND cdempres = 0
   AND cdacesso = 'COMPEARQBB'
   AND tpregist = 444;
COMMIT;
