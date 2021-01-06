DECLARE

vr_nrdocmto INTEGER;
vr_nrseqdig INTEGER;
vr_dtmvtolt DATE;

BEGIN
  


                      UPDATE TBCOTAS_DEVOLUCAO
                         SET VLCAPITAL = VLCAPITAL + 6.79
                       WHERE CDCOOPER = 16
                         AND NRDCONTA = 504270
                         AND TPDEVOLUCAO = 3;

                    UPDATE crapcot
                       SET vldcotas = vldcotas - 6.79
                     WHERE cdcooper = 16
                       AND nrdconta = 504270 ; 
                       
               SELECT dtmvtolt
                 INTO vr_dtmvtolt
                 FROM crapdat 
                 WHERE cdcooper =16;
                 
vr_nrdocmto := fn_sequence('CRAPLAU','NRDOCMTO', '16;' || TRIM(to_char( vr_dtmvtolt,'DD/MM/YYYY')) ||';16;100;600040');
vr_nrseqdig := fn_sequence('CRAPLOT','NRSEQDIG','16;' ||to_char(vr_dtmvtolt,'DD/MM/YYYY') || ';16;100;600040');

         INSERT INTO craplct(cdcooper
                                 ,cdagenci
                                 ,cdbccxlt
                                 ,nrdolote
                                 ,dtmvtolt
                                 ,cdhistor
                                 ,nrctrpla
                                 ,nrdconta
                                 ,nrdocmto
                                 ,nrseqdig
                                 ,vllanmto)
                          VALUES (16
                                 ,16
                                 ,100
                                 ,600040
                                 ,vr_dtmvtolt
                                 ,2080
                                 ,0
                                 ,504270 
                                 ,vr_nrdocmto
                                 ,vr_nrseqdig
                                 ,6.79);  
                                 
   UPDATE CRAPASS
      SET DTDEMISS = vr_dtmvtolt
        , CDSITDCT = 4
    WHERE CDCOOPER = 16
      AND NRDCONTA = 504270;   

   commit;	  
                                 
 END  ;                              
