BEGIN

UPDATE CECRED.CRAPPRM
SET    DSVLRPRM = 'N'
WHERE  NMSISTEM = 'CRED'
AND    CDACESSO = 'FL_SALVAR_ARQ_RET_BIRO';

COMMIT;
END;