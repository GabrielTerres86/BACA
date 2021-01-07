BEGIN
  -- PRM para controlar a quantidade de tentativas de uma operacao de recarga de celular quando ocorre timeout 
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 3, 'RCELL_TENTATIVAS_TIMEOUT', 'Limite de tentativas para enviar email de notificaocao', '10');

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM)
  values ('CRED', 3, 'RCELL_PROCESSA_PENDT', 'Parametro para executar ou nao o job de registros pendentes', 'S');
  COMMIT;
END;




