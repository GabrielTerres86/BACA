BEGIN 
  -- Credicomin
  UPDATE crapprm p
     SET p.dsvlrprm = '32484027095'
   WHERE p.cdacesso = 'USUARIO_AUTH_REG_CTR' 
     AND p.cdcooper = 10;
     
  COMMIT;
END;