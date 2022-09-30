BEGIN
      UPDATE cecred.crapprm
      SET CDCOOPER = 1
      WHERE NMSISTEM = 'CRED'
      AND CDCOOPER = 0
      AND CDACESSO = 'TRAVA_TRANSF_INTER_ATIVO'
      AND DSTEXPRM = 'Desabilita transferencia inter cooperativa'
      AND DSVLRPRM = 1;
    COMMIT;
END;    
/
