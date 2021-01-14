BEGIN
  /*
    INC0052209 - Script para mudar o nome fantasia no portal do lojista
    ID: 245 Nome LUAN CARLOS LEITE para APPPHONE    
    André Ricardo Würges - Mout'S
  */
  
  UPDATE tbepr_cdc_vendedor 
     SET nmvendedor = 'APPPHONE' 
   WHERE idvendedor = 245;
     
  COMMIT;
END;
