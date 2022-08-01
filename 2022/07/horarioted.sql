BEGIN
  UPDATE cecred.crapprm
     SET crapprm.dsvlrprm = 61200
   WHERE crapprm.nmsistem = 'CRED'
     AND crapprm.cdacesso = 'HORARIO_CANCELAMENTO_TED';
  COMMIT;
END;