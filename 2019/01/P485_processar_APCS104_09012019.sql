BEGIN
  
  UPDATE tbcc_portabilidade_envia t
     SET t.idsituacao        = 3 -- Aprovada
       , t.dsdominio_motivo  = NULL
       , t.cdmotivo          = NULL
       , t.dtretorno         = to_date('08/01/2019', 'DD/MM/YYYY')
       , t.nmarquivo_retorno = 'APCS104_05463212_20190108_00063'
   WHERE t.nrnu_portabilidade IN (201812240000078204689
                                 ,201812240000078199956
                                 ,201812240000078202333
                                 ,201812240000078204850
                                 ,201812240000078204870
                                 ,201812240000078202331
                                 ,201812240000078204872
                                 ,201812240000078174352
                                 ,201812240000078202336
                                 ,201812240000078199951
                                 ,201812240000078199953
                                 ,201812240000078164258
                                 ,201812240000078193403 
                                 ,201812240000078193378
                                 ,201812240000078202352
                                 ,201812240000078164278
                                 ,201812240000078199967
                                 ,201812240000078174357
                                 ,201812240000078204863
                                 ,201812240000078164288
                                 ,201812240000078193381
                                 ,201812240000078204868
                                 ,201812240000078193374
                                 ,201812240000078199959
                                 ,201812240000078204855
                                 ,201812240000078204686
                                 ,201812240000078182443
                                 ,201812240000078193398
                                 ,201812240000078174349
                                 ,201812240000078193383);
  
  UPDATE tbcc_portabilidade_envia t
     SET t.idsituacao        = 3 -- Aprovada
       , t.dsdominio_motivo  = NULL
       , t.cdmotivo          = NULL
       , t.dtretorno         = to_date('09/01/2019', 'DD/MM/YYYY')
       , t.nmarquivo_retorno = 'APCS104_05463212_20190109_00019'
   WHERE t.nrnu_portabilidade IN (201812240000078193396
                                 ,201812240000078193405
                                 ,201812240000078199946
                                 ,201812240000078199950
                                 ,201812240000078199962
                                 ,201812240000078199963
                                 ,201812240000078199965
                                 ,201812240000078202341
                                 ,201812240000078202342
                                 ,201812240000078202344
                                 ,201812240000078204678
                                 ,201812240000078204685
                                 ,201812240000078204700
                                 ,201812240000078204702
                                 ,201812240000078204859
                                 ,201812240000078204869);
  
  UPDATE tbcc_portabilidade_envia t
     SET t.idsituacao          = 4 -- Reprovada
       , t.dsdominio_motivo    = 'MOTVREPRVCPORTDDCTSALR'
       , t.cdmotivo            = 2
       , t.dtretorno           = to_date('09/01/2019', 'DD/MM/YYYY')
       , t.nmarquivo_retorno   = 'APCS104_05463212_20190109_00019'
   WHERE t.nrnu_portabilidade IN (201901080000079227788
                                 ,201901080000079239270);
  
  UPDATE tbcc_portabilidade_envia t
     SET t.idsituacao          = 4 -- Reprovada
       , t.dsdominio_motivo    = 'MOTVREPRVCPORTDDCTSALR'
       , t.cdmotivo            = 1
       , t.dtretorno           = to_date('09/01/2019', 'DD/MM/YYYY')
       , t.nmarquivo_retorno   = 'APCS104_05463212_20190109_00019'
   WHERE t.nrnu_portabilidade  = 201901080000079227784;
  
  COMMIT;
  
END;
