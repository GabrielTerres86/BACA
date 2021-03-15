BEGIN 
  -- EVOLUA
  UPDATE crapprm p
     SET p.dsvlrprm = '58354041077'
   WHERE p.cdacesso = 'USUARIO_AUTH_REG_CTR' 
     AND p.cdcooper = 14;
     
   UPDATE crapprm p
     SET p.dsvlrprm = '45:LxDgs'
   WHERE p.cdacesso = 'SENHA_AUTH_REG_CTR' 
     AND p.cdcooper = 14;
     
  COMMIT;
END;