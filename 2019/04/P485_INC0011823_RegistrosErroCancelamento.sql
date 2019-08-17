BEGIN
  
  -- Atualizar portabilidade para CANCELADA
  UPDATE tbcc_portabilidade_envia t 
     SET t.idsituacao        = 7 -- Cancelada
       , t.dtretorno         = SYSDATE
       , t.nmarquivo_retorno = 'ATUALIZADO VIA SCRIPT'
   WHERE t.cdcooper          = 1 
     AND t.nrdconta          = 10301216 
     AND t.nrsolicitacao     = 1;
     
  -- Atualizar portabilidade para CANCELADA
  UPDATE tbcc_portabilidade_envia t 
     SET t.idsituacao        = 7 -- Cancelada
       , t.dtretorno         = SYSDATE
       , t.nmarquivo_retorno = 'ATUALIZADO VIA SCRIPT'
   WHERE t.cdcooper          = 13 
     AND t.nrdconta          = 296546 
     AND t.nrsolicitacao     = 1;
  
  -- Atribuir o motivo de cancelamento para as portabilidades
  UPDATE tbcc_portabilidade_envia t 
     SET t.dsdominio_motivo = 'MOTVCANCELTPORTDDCTSALR'
       , t.cdmotivo         = 1
   WHERE t.nrnu_portabilidade IN (201902250000084419772,201902250000084407110);
  
  COMMIT;
  
END;
