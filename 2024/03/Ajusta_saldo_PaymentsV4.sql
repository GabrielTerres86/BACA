DECLARE
  vr_data_saldo DATE;
  vr_data_sistema DATE;
  vr_nrdconta INTEGER := 9836250;
  vr_cdcooper INTEGER := 1;
BEGIN
  SELECT d.dtmvtolt
    INTO vr_data_sistema
    FROM crapdat d
   WHERE d.cdcooper = vr_cdcooper;
  
  SELECT max(s.dtmvtolt)
    INTO vr_data_saldo
    FROM crapsda s
   WHERE s.nrdconta = vr_nrdconta
     AND s.cdcooper = vr_cdcooper;

  INSERT INTO crapsda (nrdconta, 
    dtmvtolt, 
    vlsddisp, 
    vlsdchsl, 
    vlsdbloq, 
    vlsdblpr, 
    vlsdblfp, 
    vlsdindi, 
    vllimcre, 
    cdcooper, 
    vlsdeved, 
    vldeschq, 
    vllimutl, 
    vladdutl, 
    vlsdrdca, 
    vlsdrdpp, 
    vllimdsc, 
    vlprepla, 
    vlprerpp, 
    vlcrdsal, 
    qtchqliq, 
    qtchqass, 
    dtdsdclq, 
    vltotpar, 
    vlopcdia, 
    vlavaliz, 
    vlavlatr, 
    qtdevolu, 
    vltotren, 
    vldestit, 
    vllimtit, 
    vlsdempr, 
    vlsdfina, 
    vlsrdc30, 
    vlsrdc60, 
    vlsrdcpr, 
    vlsrdcpo, 
    vlsdcota, 
    vlblqjud)
SELECT nrdconta, 
    refere.dtrefere, 
    vlsddisp, 
    vlsdchsl, 
    vlsdbloq, 
    vlsdblpr, 
    vlsdblfp, 
    vlsdindi, 
    vllimcre, 
    cdcooper, 
    vlsdeved, 
    vldeschq, 
    vllimutl, 
    vladdutl, 
    vlsdrdca, 
    vlsdrdpp, 
    vllimdsc, 
    vlprepla, 
    vlprerpp, 
    vlcrdsal, 
    qtchqliq, 
    qtchqass, 
    dtdsdclq, 
    vltotpar, 
    vlopcdia, 
    vlavaliz, 
    vlavlatr, 
    qtdevolu, 
    vltotren, 
    vldestit, 
    vllimtit, 
    vlsdempr, 
    vlsdfina, 
    vlsrdc30, 
    vlsrdc60, 
    vlsrdcpr, 
    vlsrdcpo, 
    vlsdcota, 
    vlblqjud
      FROM crapsda
         , (SELECT dtrefere
                FROM (SELECT TRUNC(vr_data_saldo) + LEVEL dtrefere
                        FROM dual
                      CONNECT BY LEVEL <= TO_NUMBER(vr_data_sistema- vr_data_saldo)) x
               WHERE to_number(TO_char(dtrefere, 'D')) NOT IN (1, 7) )   refere
     WHERE dtmvtolt = vr_data_saldo 
       AND cdcooper = vr_cdcooper
       AND nrdconta = vr_nrdconta;
  
  COMMIT;
   
END;
