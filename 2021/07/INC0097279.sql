UPDATE crapprm p 
SET p.dsvlrprm = '12/07/2021#2'
WHERE 
   (p.cdacesso LIKE 'CTRL%CRPS663%'
OR cdacesso LIKE 'CTRL%CRPS674%' 
or CDACESSO LIKE 'CTRL%DEBBAN%' 
or CDACESSO LIKE 'CTRL%DEBNET%'
or CDACESSO LIKE 'CTRL%DEBSIC%'
or CDACESSO LIKE 'CTRL%DEBUNITAR%' 
or CDACESSO LIKE 'CTRL%JOBAGERCEL%')
AND cdcooper = 1;
COMMIT;
