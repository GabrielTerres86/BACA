BEGIN
  UPDATE crapprm prm
    SET prm.dsvlrprm = '04/01/2021#2'
  WHERE prm.cdcooper  = 7 
    AND prm.cdacesso IN ('CTRL_CRPS663_EXEC',
                      'CTRL_CRPS674_EXEC',
                      'CTRL_CRPS688_EXEC',
                      'CTRL_CRPS724_EXEC',
                      'CTRL_CRPS750_EXEC',
                      'CTRL_DEBBAN_EXEC',
                      'CTRL_DEBNET_EXEC',
                      'CTRL_DEBNET_PRIORI_EXEC',
                      'CTRL_DEBSIC_EXEC',
                      'CTRL_DEBSIC_PRIORI_EXEC',
                      'CTRL_DEBUNITAR_EXEC',
                      'CTRL_JOBAGERCEL_EXEC');
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
END;
