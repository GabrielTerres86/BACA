declare
begin  
UPDATE cecred.crapprm
   SET dsvlrprm = 'true'
WHERE cdacesso = 'DATATRUST_ATIVO_ADM_P'; 
UPDATE cecred.crapprm
 SET dsvlrprm = 'true'
WHERE cdacesso = 'DATATRUST_ATIVO_ADM_D';
commit;
end;
/