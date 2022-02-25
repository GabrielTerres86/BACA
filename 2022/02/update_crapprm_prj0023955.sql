BEGIN
  UPDATE CRAPPRM prm
   SET prm.dsvlrprm = 'S'
 WHERE prm.cdacesso = 'FLG_UTL_API_PV_SICREDI';
 COMMIT;
END;
