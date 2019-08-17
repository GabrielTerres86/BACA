BEGIN
  
  -- Atualiza as reprovadas pelo motivo 1
  UPDATE tbcc_portabilidade_recebe t
     SET t.dsdominio_motivo = 'MOTVREPRVCPORTDDCTSALR'
       , t.cdmotivo         = 1
       , t.dtretorno        = NULL
       , t.dtavaliacao      = SYSDATE
       , t.idsituacao       = 3   -- 2 Aprovada / 3 Reprovada
   WHERE t.nrnu_portabilidade IN (201812240000078182473);


  -- Atualiza as reprovadas pelo motivo 2
  UPDATE tbcc_portabilidade_recebe t
     SET t.dsdominio_motivo = 'MOTVREPRVCPORTDDCTSALR'
       , t.cdmotivo         = 2
       , t.dtretorno        = NULL
       , t.dtavaliacao      = SYSDATE
       , t.idsituacao       = 3   -- 2 Aprovada / 3 Reprovada
   WHERE t.nrnu_portabilidade IN (201812210000078102965
                                 ,201812240000078194675
                                 ,201812240000078199339
                                 ,201812280000078571603
                                 ,201901020000078712129
                                 ,201901040000078877779
                                 ,201901070000079017476
                                 ,201901040000078980012
                                 ,201901030000078849802
                                 ,201901030000078778824
                                 ,201901080000079252486
                                 ,201901080000079225703
                                 ,201901100000079476913
                                 ,201901110000079560178
                                 ,201901110000079607927
                                 ,201901290000081166224);


  -- Atualiza as reprovadas pelo motivo 3
  UPDATE tbcc_portabilidade_recebe t
     SET t.dsdominio_motivo = 'MOTVREPRVCPORTDDCTSALR'
       , t.cdmotivo         = 3
       , t.dtretorno        = NULL
       , t.dtavaliacao      = SYSDATE
       , t.idsituacao       = 3   -- 2 Aprovada / 3 Reprovada
   WHERE t.nrnu_portabilidade IN (201812210000078073526 
                                 ,201812210000078066701
                                 ,201812270000078399691
                                 ,201812270000078392485
                                 ,201812270000078431785
                                 ,201812270000078461527
                                 ,201812260000078290887
                                 ,201812260000078274187
                                 ,201812260000078273505
                                 ,201812280000078545292
                                 ,201812280000078587881
                                 ,201901040000078944654
                                 ,201901030000078838007
                                 ,201901030000078849488);

  -- Atualiza as reprovadas pelo motivo 7
  UPDATE tbcc_portabilidade_recebe t
     SET t.dsdominio_motivo = 'MOTVREPRVCPORTDDCTSALR'
       , t.cdmotivo         = 7
       , t.dtretorno        = NULL
       , t.dtavaliacao      = SYSDATE
       , t.idsituacao       = 3   -- 2 Aprovada / 3 Reprovada
   WHERE t.nrnu_portabilidade IN (201812260000078230542
                                 ,201901250000080930781
                                 ,201901040000078984165
                                 ,201901070000079120367
                                 ,201901160000079942654);

  -- Atualiza para aprovação
  UPDATE tbcc_portabilidade_recebe t
     SET t.dsdominio_motivo = NULL
       , t.cdmotivo         = NULL
       , t.dtretorno        = NULL
       , t.dtavaliacao      = SYSDATE
       , t.idsituacao       = 2   -- 2 Aprovada / 3 Reprovada
   WHERE t.nrnu_portabilidade IN (201901030000078779406
                                 ,201901210000080280325
                                 ,201901210000080285732
                                 ,201901110000079579620
                                 ,201901240000080657006
                                 ,201812280000078603171
                                 ,201901230000080568807
                                 ,201901090000079275320
                                 ,201901300000081283536
                                 ,201902010000081584453);

  COMMIT;
END;
