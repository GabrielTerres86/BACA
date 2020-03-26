BEGIN

UPDATE tbgen_cid_atuacao_coop t
   SET t.idautoriza_ente_pub = 1
      ,t.dsata_avaliacao     = 'AGO 25.04.2019'
 WHERE t.cdcooper = 11 -- Credifoz
   AND t.cdcidade IN (8039
                     ,8251
                     ,8061
                     ,8161
                     ,8221
                     ,8245);
					 

UPDATE tbgen_cid_atuacao_coop t
   SET t.idautoriza_ente_pub = 1
      ,t.dsata_avaliacao     = 'AGO 03.04.2019'
 WHERE t.cdcooper = 5 -- ACENTRA
   AND t.cdcidade IN (8027
                     ,888
                     ,890
                     ,1192
                     ,8053
                     ,5545
                     ,5543
                     ,914
                     ,973
                     ,8121
                     ,8137
                     ,8171
                     ,8173
                     ,8185
                     ,8189
                     ,8391
                     ,8219
                     ,5539
                     ,8227
                     ,8229
                     ,8243
                     ,5547
                     ,9967
                     ,8335
                     ,8347
                     ,8349
                     ,8393
                     ,948
                     ,8361
                     ,8367
                     ,8369
                     ,8373
                     ,8211);
											 

UPDATE tbgen_cid_atuacao_coop t
   SET t.idautoriza_ente_pub = 1
      ,t.dsata_avaliacao     = 'AGO 11.04.2019'
 WHERE t.cdcooper = 13 -- CIVIA
   AND t.cdcidade IN (8063
                     ,8087
                     ,7567
                     ,8199
                     ,7761
                     ,8267
                     ,8295
                     ,7823
                     ,8311
                     ,7887
                     ,7937);
												

UPDATE tbgen_cid_atuacao_coop t
   SET t.idautoriza_ente_pub = 1
      ,t.dsata_avaliacao     = 'AGO 17.04.2019'
 WHERE t.cdcooper = 2 -- Acredicoop
   AND t.cdcidade IN (8025
                     ,5549
                     ,8041
                     ,8115
                     ,9985
                     ,8179
                     ,8319
                     ,5551);


UPDATE tbgen_cid_atuacao_coop t
   SET t.idautoriza_ente_pub = 1
      ,t.dsata_avaliacao     = 'AGO 05.04.2019'
 WHERE t.cdcooper = 14 -- Evolua
   AND t.cdcidade IN (7417
                     ,7449
                     ,834
                     ,5471
                     ,838
                     ,5473
                     ,7541
                     ,7545
                     ,5475
                     ,7617
                     ,864
                     ,7695
                     ,5477
                     ,7995
                     ,7751
                     ,7759
                     ,5495
                     ,7805
                     ,7809
                     ,7833
                     ,7837
                     ,7851
                     ,7857
                     ,7881
                     ,7945
                     ,7947);										
												
                        
	COMMIT;

END;

												