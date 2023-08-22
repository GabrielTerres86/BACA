BEGIN
 UPDATE cecred.crapprm prm
        SET dsvlrprm = 0
  WHERE prm.nmsistem = 'CRED'         
      AND prm.cdacesso = 'TRAVA_TRANSF_ATIVO';
COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_application_error(-20500, SQLERRM);
END;
