--DESABILITAR PROGRAMAS DA HRCOMPE

UPDATE craphec
SET    flgativo = 0 --Desativar 
WHERE  Upper(cdprogra) IN ('CRPS688','DEBNET','DEBSIC','DEBBAN')
AND    flgativo = 1;

COMMIT;


Update craphec SET FLGATIVO = 0 --Desativar
 where dsprogra like '%DEBCNS%';

COMMIT;