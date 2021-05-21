begin

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
  values ('CRED', 3, 'HABILITA_LOG_CONTA_CRD', 'Habilita LOG Conta Cartão via trigger - TBCRD_LOG_CONTA_CARTAO (1 - Ativado / 0 - Desativado)', '1', null);

  commit;
  
end;
