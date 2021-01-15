BEGIN 
  -- RITM0082154
  UPDATE crapprm t
    SET t.dsvlrprm = 16
  WHERE t.cdacesso = 'LINHA_FOLHA_PGTO_BNDES'
  AND t.cdcooper = 3;
  COMMIT;
END; 
