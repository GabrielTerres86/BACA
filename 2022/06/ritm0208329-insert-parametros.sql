begin 
  
  insert into CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 0, 'CDFASE_NAO_EXPRESS_ENV', 'Lista com as fases de envio que não passam pelo JD Express.', '40');

  insert into CRAPPRM (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 0, 'CDFASE_NAO_EXPRESS_REC', 'Lista com as fases de recebimento que não passam pelo JD Express.', '105');

  commit;

exception
  
  when others then
    raise_application_error(-20500, sqlerrm);
    rollback;
  
end;