BEGIN

  --deletar configurações de limite
  DELETE FROM tbcrd_config_categoria a WHERE a.cdadmcrd = 19;
  --deletar configurações de grupo de afinidade
  DELETE FROM crapadc a WHERE a.cdadmcrd = 19;
  --atualizar nome da modalidade de cartão 18 - cartão expresso para cartão personalizado
  UPDATE crapadc a 
     SET a.nmadmcrd = 'AILOS MASTERCARD NOW PERSONALIZADO',
         a.nmresadm = 'AILOS NOW PERSONALIZADO'
   WHERE a.cdadmcrd = 18;
  --deletar grupo de afinidade da modalidade cartão expresso
  DELETE FROM crapacb a WHERE a.cdadmcrd = 18;
  --atualizar código da modalidade cartão personalizado para 18;	
   UPDATE crapacb a 
      SET a.cdadmcrd = 18
    WHERE a.cdadmcrd = 19;
   
   COMMIT;    
END;
