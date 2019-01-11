begin 
/*
  SCTASK0032664 - Ajustado o sistema para enviar o tipo de cart�o como internacional nos arquivos COO410 da integra��o com o banco do brasil.

*/

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 0, 'COO410_TPCARTAO_INTER', 'Indica se deve enviar os cart�es com o tipo internacional para o Banco do Brasil', '1');

  commit;

exception
  
  when others then
  
    rollback;

end;