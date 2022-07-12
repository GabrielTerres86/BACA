BEGIN
  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
  values ('CRED', 1, 'VALIDA_BENEFICIARIO_APTO', 'Emitir mensagem de critica de beneficiario nao cadastrado por cooperativa', 'S', NULL);

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
  values ('CRED', 2, 'VALIDA_BENEFICIARIO_APTO', 'Emitir mensagem de critica de beneficiario nao cadastrado por cooperativa', 'S', NULL);

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
  values ('CRED', 5, 'VALIDA_BENEFICIARIO_APTO', 'Emitir mensagem de critica de beneficiario nao cadastrado por cooperativa', 'N', NULL);

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
  values ('CRED', 6, 'VALIDA_BENEFICIARIO_APTO', 'Emitir mensagem de critica de beneficiario nao cadastrado por cooperativa', 'S', NULL);

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
  values ('CRED', 7, 'VALIDA_BENEFICIARIO_APTO', 'Emitir mensagem de critica de beneficiario nao cadastrado por cooperativa', 'S', NULL);

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
  values ('CRED', 8, 'VALIDA_BENEFICIARIO_APTO', 'Emitir mensagem de critica de beneficiario nao cadastrado por cooperativa', 'N', NULL);

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
  values ('CRED', 9, 'VALIDA_BENEFICIARIO_APTO', 'Emitir mensagem de critica de beneficiario nao cadastrado por cooperativa', 'S', NULL);

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
  values ('CRED', 10, 'VALIDA_BENEFICIARIO_APTO', 'Emitir mensagem de critica de beneficiario nao cadastrado por cooperativa', 'S', NULL);

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
  values ('CRED', 11, 'VALIDA_BENEFICIARIO_APTO', 'Emitir mensagem de critica de beneficiario nao cadastrado por cooperativa', 'S', NULL);

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
  values ('CRED', 12, 'VALIDA_BENEFICIARIO_APTO', 'Emitir mensagem de critica de beneficiario nao cadastrado por cooperativa', 'S', NULL);

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
  values ('CRED', 13, 'VALIDA_BENEFICIARIO_APTO', 'Emitir mensagem de critica de beneficiario nao cadastrado por cooperativa', 'S', NULL);

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
  values ('CRED', 14, 'VALIDA_BENEFICIARIO_APTO', 'Emitir mensagem de critica de beneficiario nao cadastrado por cooperativa', 'S', NULL);

  insert into crapprm (NMSISTEM, CDCOOPER, CDACESSO, DSTEXPRM, DSVLRPRM, PROGRESS_RECID)
  values ('CRED', 16, 'VALIDA_BENEFICIARIO_APTO', 'Emitir mensagem de critica de beneficiario nao cadastrado por cooperativa', 'S', NULL);
 
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    SISTEMA.excecaoInterna(pr_compleme => 'INC0192895');
    ROLLBACK;

END;
