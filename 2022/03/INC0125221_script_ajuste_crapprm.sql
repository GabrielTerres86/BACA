BEGIN

  UPDATE crapprm
     SET dsvlrprm = '0'
   WHERE cdcooper = 0
     AND cdacesso = 'RATING_RENOVACAO_ATIVO';

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500, SQLERRM);
    ROLLBACK;
END;
