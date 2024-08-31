DECLARE

 pr_cdcooper NUMBER := 9;
 pr_dtrefere DATE   := to_date('31/08/2024','DD/MM/RRRR');
 vr_registros NUMBER := 0;

BEGIN

    LOOP 
      
      DELETE /*+ parallel(20) */ cecred.crapvri x WHERE x.cdcooper = pr_cdcooper 
         AND x.dtrefere = pr_dtrefere AND rownum < 10000;
      vr_registros := SQL%ROWCOUNT;
      
      COMMIT;
      
      EXIT WHEN vr_registros = 0;
    
    END LOOP;
      
    COMMIT; 
    
    LOOP 
      
      DELETE /*+ parallel(20) */ cecred.crapris x WHERE x.cdcooper = pr_cdcooper 
         AND x.dtrefere = pr_dtrefere AND rownum < 10000;
      vr_registros := SQL%ROWCOUNT;
      
      COMMIT;
      
      EXIT WHEN vr_registros = 0;
    
    END LOOP;
      
    COMMIT;

    LOOP 
      
      DELETE /*+ parallel(20) */ gestaoderisco.htrisco_central_retorno x WHERE x.cdcooper = pr_cdcooper 
         AND x.dtreferencia = pr_dtrefere AND rownum < 10000;
      vr_registros := SQL%ROWCOUNT;
      
      COMMIT;
      
      EXIT WHEN vr_registros = 0;
    
    END LOOP;
      
    COMMIT;     
    
    update cecred.crapdat set dtmvcentral = to_date('29/08/2024', 'DD/MM/RRRR') where cdcooper = 9;
    commit;

END;
