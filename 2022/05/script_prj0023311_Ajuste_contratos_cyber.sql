BEGIN
 
UPDATE   CREDITO.tbepr_contrato_imobiliario a
SET  a.nrdconta_avalprimeiro = DECODE(a.nrctremp,381139, 3131
                                                ,381140, 9210
                                                ,364915, 176770
                                                ,364894,186406
                                                ,381101,231924
                                                ,364978,361712
                                                ,364963,470600,a.nrdconta_avalprimeiro )
    ,a.nrdconta_avalsegundo = DECODE(a.nrctremp,381139,4103
                                               ,381140,9512
                                               ,364915,184020
                                               ,364894,186708,a.nrdconta_avalsegundo )                                            
  ,a.cdlcremp = 10000
  ,a.cdfinemp = 100                                               
WHERE a.cdcooper = 16 
AND a.valor_atraso >0;
    
  COMMIT;
EXCEPTION WHEN OTHERS THEN
  ROLLBACK;
END;
/