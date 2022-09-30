BEGIN
      UPDATE cecred.crapprm
      SET DSVLRPRM = 0
      WHERE NMSISTEM = 'CRED'
      AND CDCOOPER = 0
      AND CDACESSO = 'TRAVA_TRANSF_INTER_ATIVO'
      AND DSTEXPRM = 'Desabilita transferencia inter cooperativa'
      AND DSVLRPRM = 1;
    COMMIT;
END;    
/
