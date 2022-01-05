declare
begin  
UPDATE cecred.crapprm
   SET dsvlrprm = 'prev.fraudes03@ailos.coop.br'
WHERE cdacesso = 'EMAIL_RISCOFRAUDE_ADM';

UPDATE cecred.crapprm
   SET dsvlrprm = 'false'
WHERE cdacesso = 'DATATRUST_ATIVO_ADM_P'; 

update crapprm
 set dsvlrprm = 'false'
where cdacesso = 'DATATRUST_ATIVO_ADM_D';
commit;
end;
/