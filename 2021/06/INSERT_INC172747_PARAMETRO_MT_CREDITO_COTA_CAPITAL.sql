/*Insere parametro LMT_CREDITO_COTA_CAPITAL na tabela crapprm */
begin
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
  values ('CRED', 0, 'LMT_CREDITO_COTA_CAPITAL', 'Cooperativa para desconsiderar o limite de crédito em débito de cotas',
   ',6,7,9,13,16,', null);
   commit;
end;  
/