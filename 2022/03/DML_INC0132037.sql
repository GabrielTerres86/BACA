DECLARE 
 
  CURSOR cr_crapcop IS
    SELECT c.cdcooper
      FROM cecred.crapcop c
     WHERE c.flgativo = 1
       AND c.cdcooper <> 3; 
       
  
  CURSOR cr_crapris (pr_cdcooper NUMBER)IS
    SELECT r.cdcooper
          ,r.nrdconta
          ,r.vlsld59d
          ,r.vljura60
          ,r.vldivida
          ,r.DTREFERE
          ,r.CDMODALI
      FROM cecred.crapris r
          ,cecred.crapdat d
     WHERE r.cdcooper = d.cdcooper
       AND r.cdcooper = pr_cdcooper
       AND r.dtrefere = d.dtmvtoan
       AND r.cdmodali = 101
       AND r.qtdiaatr >= 60
       AND (r.vlsld59d + r.vljura60) <> r.vldivida
     ORDER BY r.CDCOOPER
             ,r.NRDCONTA;

  vr_cont_lanc NUMBER := 0;
  vr_cont_adp NUMBER := 0;

BEGIN 
  
  
  FOR rw_crapcop IN cr_crapcop LOOP
    FOR rw_crapris IN cr_crapris(pr_cdcooper => rw_crapcop.cdcooper) LOOP
        
    DELETE gestaoderisco.tbcc_historico_juros_lanc l
      WHERE EXISTS(SELECT 1 
                     FROM gestaoderisco.tbcc_historico_juros_adp h
                    WHERE h.cdcooper = rw_crapris.cdcooper
                      AND h.nrdconta = rw_crapris.nrdconta
                      AND h.dtmvtolt = rw_crapris.dtrefere
                      AND h.idhistorico_juros_adp = l.idhistorico_juros_adp); 
                       
      vr_cont_lanc := vr_cont_lanc + SQL%ROWCOUNT;
      
      DELETE gestaoderisco.tbcc_historico_juros_adp h
       WHERE h.cdcooper = rw_crapris.cdcooper
         AND h.nrdconta = rw_crapris.nrdconta
         AND h.dtmvtolt = rw_crapris.dtrefere; 
                       
      vr_cont_adp := vr_cont_adp + SQL%ROWCOUNT;
    END LOOP;  
    COMMIT;
  END LOOP;
  COMMIT;
  
  dbms_output.put_line('vr_cont_lanc :'||vr_cont_lanc);  
  dbms_output.put_line('vr_cont_adp :'||vr_cont_adp);

end;
