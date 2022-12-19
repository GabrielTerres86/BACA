BEGIN 
  UPDATE crapprm p
     SET p.dsvlrprm = '20/09/2022'
   WHERE p.cdcooper = 14
     AND p.cdacesso = 'DIA_ATIVA_CONTRB_SEGPRE';
  COMMIT;
END;
/
