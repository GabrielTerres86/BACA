BEGIN
  UPDATE crapprm c
     SET c.dsvlrprm = '25/04/2022'
   WHERE c.cdacesso = 'DATA_ATIVA_SEGPRE_CONTRB'
     AND c.cdcooper = 9;
  COMMIT;
END;
/
BEGIN
  UPDATE crapprm c
     SET c.dsvlrprm = '25/04/2022'
   WHERE c.cdacesso = 'DATA_ATIVA_SEGPRE_CONTRB'
     AND c.cdcooper = 13;
  COMMIT;
END;
/