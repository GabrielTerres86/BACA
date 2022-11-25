BEGIN 
  UPDATE CECRED.crapprm p
     SET p.dsvlrprm = 'S'
   WHERE p.cdacesso = 'PROPOSTA_API_ICATU'
     AND p.cdcooper IN (2, 5, 6, 8, 9, 10, 13, 14);
  COMMIT;
END;
/
