
DECLARE
  vr_nrdolote integer;
  vr_busca    VARCHAR2(4000);
  vr_nrdocmto INTEGER;
  vr_nrseqdig INTEGER;
  vr_dtmvtolt DATE;
  
  
BEGIN
           SELECT dtmvtolt
             INTO vr_dtmvtolt
             FROM crapdat
            WHERE cdcooper = 16;
               
 
            vr_nrdolote := 600040;

            vr_busca := TRIM(to_char(16)) || ';' ||
                        TRIM(to_char(vr_dtmvtolt,'DD/MM/RRRR')) || ';' ||
                        TRIM(to_char(3)) || ';' ||
                        '100;' || --cdbccxlt
                        vr_nrdolote;

            vr_nrdocmto := fn_sequence('CRAPLCT','NRDOCMTO', vr_busca);

            vr_nrseqdig := fn_sequence('CRAPLOT','NRSEQDIG',''||16||';'||
                                                                to_char(vr_dtmvtolt,'DD/MM/RRRR')||';'||
                                                                3||
                                                                ';100;'|| --cdbccxlt
                                                                vr_nrdolote);


            --Inserir registro de debito
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
                                 ,3
                                 ,100
                                 ,vr_nrdolote
                                 ,vr_dtmvtolt
                                 ,61
                                 ,0
                                 ,61450
                                 ,vr_nrdocmto
                                 ,vr_nrseqdig
                                 ,251.93);    
                                 
       COMMIT;                          
                                                                         

  
end;