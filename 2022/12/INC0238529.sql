BEGIN
  UPDATE crapcrb
     SET crapcrb.Dtcancel = NULL
        ,crapcrb.Cdopecan = NULL
        ,crapcrb.Dsmotcan = NULL
   WHERE TRUNC(crapcrb.dtmvtolt) = TRUNC(SYSDATE)
     AND crapcrb.idtpreme IN ('SERASA', 'SPC', 'BOAVISTA');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    raise_application_error(-20500, SQLERRM);
END;
