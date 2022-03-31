DECLARE

  CURSOR cr_alteracao IS
    select 'F9010011' operador, '@' acesso1, 'A' acesso2, 'C' acesso3 from dual 
    union all
    select 'F9010039' operador, '@' acesso1, 'A' acesso2, 'C' acesso3 from dual  
    union all
    select 'F9010020' operador, '@' acesso1, 'A' acesso2, 'C' acesso3 from dual 
    union all
    select 'F9010009' operador, '@' acesso1, 'A' acesso2, 'C' acesso3 from dual 
    union all
    select 'F9010031' operador, '@' acesso1, 'A' acesso2, 'C' acesso3 from dual 
    union all
    select 'F9010004' operador, '@' acesso1, 'A' acesso2, 'C' acesso3 from dual 
    union all
    select 'F9010002' operador, '@' acesso1, 'A' acesso2, 'C' acesso3 from dual 
    union all
    select 'F9010040' operador, '@' acesso1, 'A' acesso2, 'C' acesso3 from dual 
    union all
    select 'F9010001' operador, '@' acesso1, 'A' acesso2, 'C' acesso3 from dual 
    union all
    select 'F0033552' operador, '@' acesso1, 'A' acesso2, 'C' acesso3 from dual 
    union all
    select 'F0030367' operador, '@' acesso1, 'A' acesso2, 'C' acesso3 from dual 
    union all
    select 'F0031411' operador, '@' acesso1, 'A' acesso2, 'C' acesso3 from dual 
    union all
    select 'F0033485' operador, '@' acesso1, 'A' acesso2, 'C' acesso3 from dual; 
  rw_alteracao cr_alteracao%ROWTYPE;
  
  CURSOR cr_consulta IS
    select 'F9010025' operador, '@' acesso1, 'C' acesso2 from dual
    union all
    select 'F9010062' operador, '@' acesso1, 'C' acesso2 from dual
    union all
    select 'F9010041' operador, '@' acesso1, 'C' acesso2 from dual
    union all
    select 'F9010038' operador, '@' acesso1, 'C' acesso2 from dual
    union all
    select 'F9010023' operador, '@' acesso1, 'C' acesso2 from dual
    union all
    select 'F9010010' operador, '@' acesso1, 'C' acesso2 from dual
    union all
    select 'F9010022' operador, '@' acesso1, 'C' acesso2 from dual
    union all
    select 'F9010030' operador, '@' acesso1, 'C' acesso2 from dual
    union all
    select 'F9010007' operador, '@' acesso1, 'C' acesso2 from dual
    union all
    select 'F9010019' operador, '@' acesso1, 'C' acesso2 from dual
    union all
    select 'F9010037' operador, '@' acesso1, 'C' acesso2 from dual
    union all
    select 'F9010012' operador, '@' acesso1, 'C' acesso2 from dual
    union all
    select 'F9010032' operador, '@' acesso1, 'C' acesso2 from dual
    union all
    select 'F9010063' operador, '@' acesso1, 'C' acesso2 from dual
    union all
    select 'F9010024' operador, '@' acesso1, 'C' acesso2 from dual
    union all
    select 'F9010016' operador, '@' acesso1, 'C' acesso2 from dual
    union all
    select 'F9010035' operador, '@' acesso1, 'C' acesso2 from dual;
  rw_consulta cr_consulta%ROWTYPE;

BEGIN
  
  DELETE CRAPACE WHERE NMDATELA = 'SEGPRE';

  COMMIT;
   
  FOR rw_consulta in cr_consulta LOOP   
  
    insert into crapace (nmdatela,cddopcao,cdoperad,nmrotina,cdcooper,nrmodulo,idevento,idambace) values ('SEGPRE', rw_consulta.acesso1, rw_consulta.operador,' ', 3, 1, 0, 2);
    insert into crapace (nmdatela,cddopcao,cdoperad,nmrotina,cdcooper,nrmodulo,idevento,idambace) values ('SEGPRE', rw_consulta.acesso2, rw_consulta.operador,' ', 3, 1, 0, 2);
  
  END LOOP;
  
  
  FOR rw_alteracao in cr_alteracao LOOP   
  
    insert into crapace (nmdatela,cddopcao,cdoperad,nmrotina,cdcooper,nrmodulo,idevento,idambace) values ('SEGPRE', rw_alteracao.acesso1, rw_alteracao.operador,' ', 3, 1, 0, 2);
    insert into crapace (nmdatela,cddopcao,cdoperad,nmrotina,cdcooper,nrmodulo,idevento,idambace) values ('SEGPRE', rw_alteracao.acesso2, rw_alteracao.operador,' ', 3, 1, 0, 2);
    insert into crapace (nmdatela,cddopcao,cdoperad,nmrotina,cdcooper,nrmodulo,idevento,idambace) values ('SEGPRE', rw_alteracao.acesso3, rw_alteracao.operador,' ', 3, 1, 0, 2);
  
  END LOOP;
   
  
  COMMIT;

EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/
