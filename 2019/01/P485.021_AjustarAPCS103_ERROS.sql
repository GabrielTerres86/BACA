BEGIN         

  -- Atualiza os registros que tiveram APROVAÇÃO
  UPDATE tbcc_portabilidade_recebe t
     SET t.dtretorno        = NULL
       , t.dsdominio_motivo = NULL -- Sem motivo pois foram aprovadas
       , t.cdmotivo         = NULL -- Sem motivo pois foram aprovadas
   WHERE t.idsituacao       = 2
     AND t.dtavaliacao IS NOT NULL
     AND t.dtretorno   IS NULL;
  
  
  UPDATE tbcc_portabilidade_recebe t
     SET t.dtretorno        = NULL
       , t.dsdominio_motivo = 'MOTVREPRVCPORTDDCTSALR'
       , t.cdmotivo         = 7
   WHERE t.nrnu_portabilidade IN (201901230000080559611  -- 007
                                 ,201901230000080559535  -- 007
                                 ,201901230000080562592  -- 007
                                 ,201901230000080538796  -- 007
                                 ,201901250000080809266  -- 007
                                 ,201901240000080604069  -- 007
                                 ,201901240000080639667  -- 007
                                 ,201901240000080640224  -- 007
                                 ,201901240000080740142  -- 007
                                 ,201901250000080854193  -- 007
                                 ,201901250000080876261  -- 007
                                 ,201901250000080930781  -- 007
                                 ,201901290000081242647  -- 007
                                 ,201901290000081204987  -- 007
                                 ,201901290000081204864  -- 007
                                 ,201901290000081240316  -- 007
                    );
                         
                            
  UPDATE tbcc_portabilidade_recebe t
     SET t.dtretorno        = NULL
       , t.dsdominio_motivo = 'MOTVREPRVCPORTDDCTSALR'
       , t.cdmotivo         = 1
   WHERE t.nrnu_portabilidade IN (201901230000080559572  -- 001
                                 ,201901240000080657265  -- 001
                                 ,201901290000081239207  -- 001
                    );
  
  
  UPDATE tbcc_portabilidade_recebe t
     SET t.dtretorno        = NULL
       , t.dsdominio_motivo = 'MOTVREPRVCPORTDDCTSALR'
       , t.cdmotivo         = 2
   WHERE t.nrnu_portabilidade IN (201901290000081166224  -- 002
                    );
  
  
  UPDATE tbcc_portabilidade_recebe t
     SET t.dtretorno        = NULL
       , t.dsdominio_motivo = NULL
       , t.cdmotivo         = NULL
       , t.dtavaliacao      = NULL
       , t.idsituacao       = 1 -- Pendente
       , t.nmarquivo_resposta = NULL
   WHERE t.nrnu_portabilidade IN (201901290000081230021  -- REVERTER
                    );
  
  COMMIT;
  
END;
  
  
