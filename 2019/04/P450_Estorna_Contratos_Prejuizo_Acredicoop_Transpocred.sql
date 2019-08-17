--
-- Ajuste de saldo de contas com movimentos gerados indevidamente em prejuizo
--
declare 
  CURSOR cr_nrdocmto(pr_cdcooper NUMBER
                   , pr_nrdconta NUMBER) IS
  SELECT nvl(MAX(nrdocmto), 0) + 1 nrdocmto
    FROM craplem
   WHERE cdcooper = pr_cdcooper
     AND dtmvtolt = TRUNC(SYSDATE)
     AND cdagenci = 1
     AND cdbccxlt = 100
     AND nrdolote = 600029
     AND nrdconta = pr_nrdconta
  ;
     
  CURSOR cr_nrseqdig(pr_cdcooper NUMBER) IS
  SELECT nvl(MAX(nrseqdig), 0) + 1 nrseqdig
    FROM craplem
   WHERE cdcooper = pr_cdcooper
     AND dtmvtolt = TRUNC(SYSDATE)
     AND cdagenci = 1
     AND cdbccxlt = 100
     AND nrdolote = 600029
  ;
  
  vr_nrdocmto  NUMBER(18);
  vr_nrseqdig  NUMBER(18);
  vr_cdhistor  NUMBER(18);
  vr_vlpago    NUMBER(18,4);
-------------------------------------
BEGIN

  FOR rw_craplem IN 
  (SELECT cdcooper
        , nrdconta
        , nrctremp
        , cdagenci
        , cdbccxlt
        , nrdolote
        , cdhistor
        , vllanmto
        , cdorigem
        , progress_recid
     FROM craplem
    WHERE cdcooper = 9
      AND nrdconta = 106720
      AND nrctremp = 106720
      AND dtmvtolt BETWEEN to_date('18/03/2019', 'DD/MM/YYYY') AND to_date('31/03/2019', 'DD/MM/YYYY')
      AND cdhistor IN (2701, 2388, 2390, 2473)
  ) LOOP
    OPEN cr_nrdocmto(rw_craplem.cdcooper
                   , rw_craplem.nrdconta);
    FETCH cr_nrdocmto INTO vr_nrdocmto;
    CLOSE cr_nrdocmto;

    OPEN cr_nrseqdig(rw_craplem.cdcooper);
    FETCH cr_nrseqdig INTO vr_nrseqdig;
    CLOSE cr_nrseqdig;
    
    IF rw_craplem.cdhistor = 2701 THEN
      vr_cdhistor := 2702;
    ELSIF rw_craplem.cdhistor = 2388 THEN
      vr_cdhistor := 2392;
    ELSIF rw_craplem.cdhistor = 2390 THEN
      vr_cdhistor := 2394;
    ELSIF rw_craplem.cdhistor = 2473 THEN
      vr_cdhistor := 2474;
    END IF;
    
    INSERT INTO craplem (
        dtmvtolt
      , cdagenci
      , cdbccxlt
      , nrdolote
      , nrdconta
      , nrdocmto
      , cdhistor
      , nrseqdig
      , nrctremp
      , vllanmto
      , dtpagemp
      , dthrtran
      , cdorigem
      , cdcooper
    )
    VALUES (
        trunc(SYSDATE)
      , rw_craplem.cdagenci
      , rw_craplem.cdbccxlt
      , rw_craplem.nrdolote
      , rw_craplem.nrdconta
      , vr_nrdocmto
      , vr_cdhistor
      , vr_nrseqdig
      , rw_craplem.nrctremp
      , rw_craplem.vllanmto
      , TRUNC(SYSDATE)
      , SYSDATE
      , rw_craplem.cdorigem
      , rw_craplem.cdcooper
    );
    
    UPDATE craplem
       SET dtestorn = trunc(SYSDATE)
     WHERE progress_recid = rw_craplem.progress_recid;
  END LOOP rw_craplem; 
 
  vr_vlpago := 0;
  SELECT nvl(SUM(vllanmto), 0) INTO vr_vlpago
    FROM craplem
   WHERE cdcooper = 9
     AND nrdconta = 106720
     AND nrctremp = 106720
     AND cdhistor = 2701
     AND dtmvtolt >= to_date('18/03/2019', 'DD/MM/YYYY');

  UPDATE crapepr e
     SET vlpgjmpr = 0
       , vlpgmupr = 0
       , vlsdprej = vlsdprej + vr_vlpago
   WHERE cdcooper = 9
     AND nrdconta = 106720
     AND nrctremp = 106720;

-------------------  
  FOR rw_craplem IN 
  (SELECT cdcooper
        , nrdconta
        , nrctremp
        , cdagenci
        , cdbccxlt
        , nrdolote
        , cdhistor
        , vllanmto
        , cdorigem
        , progress_recid
     FROM craplem
    WHERE cdcooper = 9
      AND nrdconta = 106720
      AND nrctremp = 4010
      AND dtmvtolt BETWEEN to_date('18/03/2019', 'DD/MM/YYYY') AND to_date('31/03/2019', 'DD/MM/YYYY')
      AND cdhistor IN (2701, 2388, 2390, 2473)
      AND vllanmto <> 423.85
  ) LOOP
    OPEN cr_nrdocmto(rw_craplem.cdcooper
                   , rw_craplem.nrdconta);
    FETCH cr_nrdocmto INTO vr_nrdocmto;
    CLOSE cr_nrdocmto;

    OPEN cr_nrseqdig(rw_craplem.cdcooper);
    FETCH cr_nrseqdig INTO vr_nrseqdig;
    CLOSE cr_nrseqdig;
    
    IF rw_craplem.cdhistor = 2701 THEN
      vr_cdhistor := 2702;
    ELSIF rw_craplem.cdhistor = 2388 THEN
      vr_cdhistor := 2392;
    ELSIF rw_craplem.cdhistor = 2390 THEN
      vr_cdhistor := 2394;
    ELSIF rw_craplem.cdhistor = 2473 THEN
      vr_cdhistor := 2474;
    END IF;
    
    INSERT INTO craplem (
        dtmvtolt
      , cdagenci
      , cdbccxlt
      , nrdolote
      , nrdconta
      , nrdocmto
      , cdhistor
      , nrseqdig
      , nrctremp
      , vllanmto
      , dtpagemp
      , dthrtran
      , cdorigem
      , cdcooper
    )
    VALUES (
        trunc(SYSDATE)
      , rw_craplem.cdagenci
      , rw_craplem.cdbccxlt
      , rw_craplem.nrdolote
      , rw_craplem.nrdconta
      , vr_nrdocmto
      , vr_cdhistor
      , vr_nrseqdig
      , rw_craplem.nrctremp
      , rw_craplem.vllanmto
      , TRUNC(SYSDATE)
      , SYSDATE
      , rw_craplem.cdorigem
      , rw_craplem.cdcooper
    );
    
    UPDATE craplem
       SET dtestorn = trunc(SYSDATE)
     WHERE progress_recid = rw_craplem.progress_recid;
  END LOOP rw_craplem;
  
  vr_vlpago := 0;
  SELECT nvl(SUM(vllanmto), 0) INTO vr_vlpago
    FROM craplem
   WHERE cdcooper = 9
     AND nrdconta = 106720
     AND nrctremp = 4010
     AND cdhistor = 2701
     AND dtmvtolt >= to_date('18/03/2019', 'DD/MM/YYYY')     
     AND vllanmto <> 423.85;

  UPDATE crapepr e
     SET vlpgjmpr = 0
    -- , vlpgmupr = 0
       , vlsdprej = vlsdprej + vr_vlpago
   WHERE cdcooper = 9
     AND nrdconta = 106720
     AND nrctremp = 4010;

-------------------  
  FOR rw_craplem IN 
  (SELECT cdcooper
        , nrdconta
        , nrctremp
        , cdagenci
        , cdbccxlt
        , nrdolote
        , cdhistor
        , vllanmto
        , cdorigem
        , progress_recid
     FROM craplem
    WHERE cdcooper = 9
      AND nrdconta = 50873
      AND nrctremp = 2840
      AND dtmvtolt BETWEEN to_date('18/03/2019', 'DD/MM/YYYY') AND to_date('31/03/2019', 'DD/MM/YYYY')
      AND cdhistor IN (2701, 2388, 2390)
    AND vllanmto <> 9.65
  ) LOOP
    OPEN cr_nrdocmto(rw_craplem.cdcooper
                   , rw_craplem.nrdconta);
    FETCH cr_nrdocmto INTO vr_nrdocmto;
    CLOSE cr_nrdocmto;

    OPEN cr_nrseqdig(rw_craplem.cdcooper);
    FETCH cr_nrseqdig INTO vr_nrseqdig;
    CLOSE cr_nrseqdig;
    
    IF rw_craplem.cdhistor = 2701 THEN
      vr_cdhistor := 2702;
    ELSIF rw_craplem.cdhistor = 2388 THEN
      vr_cdhistor := 2392;
    ELSIF rw_craplem.cdhistor = 2390 THEN
      vr_cdhistor := 2394;
    END IF;
    
    INSERT INTO craplem (
        dtmvtolt
      , cdagenci
      , cdbccxlt
      , nrdolote
      , nrdconta
      , nrdocmto
      , cdhistor
      , nrseqdig
      , nrctremp
      , vllanmto
      , dtpagemp
      , dthrtran
      , cdorigem
      , cdcooper
    )
    VALUES (
        trunc(SYSDATE)
      , rw_craplem.cdagenci
      , rw_craplem.cdbccxlt
      , rw_craplem.nrdolote
      , rw_craplem.nrdconta
      , vr_nrdocmto
      , vr_cdhistor
      , vr_nrseqdig
      , rw_craplem.nrctremp
      , rw_craplem.vllanmto
      , TRUNC(SYSDATE)
      , SYSDATE
      , rw_craplem.cdorigem
      , rw_Craplem.cdcooper
    );
    
    UPDATE craplem
       SET dtestorn = trunc(SYSDATE)
     WHERE progress_recid = rw_craplem.progress_recid;
  END LOOP  rw_craplem;
  
  COMMIT;
  
  vr_vlpago := 0;
  SELECT nvl(SUM(vllanmto), 0) INTO vr_vlpago
    FROM craplem
   WHERE cdcooper = 9
     AND nrdconta = 50873
     AND nrctremp = 2840
     AND cdhistor = 2701
     AND dtmvtolt BETWEEN to_date('18/03/2019', 'DD/MM/YYYY') AND to_date('31/03/2019', 'DD/MM/YYYY')     
     AND vllanmto <> 9.65 ;

  UPDATE crapepr e
     SET vlsdprej = vlsdprej + vr_vlpago
       , vlpgjmpr = 0
    --   , vlpgmupr = 0
   WHERE cdcooper = 9
     AND nrdconta = 50873
     AND nrctremp = 2840  ;

COMMIT;
-------------------------------------------------------
  
  FOR rw_craplem IN 
  (SELECT cdcooper
        , nrdconta
        , nrctremp
        , cdagenci
        , cdbccxlt
        , nrdolote
        , cdhistor
        , vllanmto
        , cdorigem
        , progress_recid
     FROM craplem
    WHERE cdcooper = 2
      AND nrdconta = 583375
      AND nrctremp = 237602
      AND dtmvtolt BETWEEN to_date('18/03/2019', 'DD/MM/YYYY') AND to_date('31/03/2019', 'DD/MM/YYYY')
      AND cdhistor IN (2701, 2388)
  ) LOOP
    OPEN cr_nrdocmto(rw_craplem.cdcooper
                   , rw_craplem.nrdconta);
    FETCH cr_nrdocmto INTO vr_nrdocmto;
    CLOSE cr_nrdocmto;

    OPEN cr_nrseqdig(rw_craplem.cdcooper);
    FETCH cr_nrseqdig INTO vr_nrseqdig;
    CLOSE cr_nrseqdig;
    
    IF rw_craplem.cdhistor = 2701 THEN
      vr_cdhistor := 2702;
    ELSIF rw_craplem.cdhistor = 2388 THEN
      vr_cdhistor := 2392;
    ELSIF rw_craplem.cdhistor = 2390 THEN
      vr_cdhistor := 2394;
    ELSIF rw_craplem.cdhistor = 2473 THEN
      vr_cdhistor := 2474;
    END IF;
    
    INSERT INTO craplem (
        dtmvtolt
      , cdagenci
      , cdbccxlt
      , nrdolote
      , nrdconta
      , nrdocmto
      , cdhistor
      , nrseqdig
      , nrctremp
      , vllanmto
      , dtpagemp
      , dthrtran
      , cdorigem
      , cdcooper
    )
    VALUES (
        trunc(SYSDATE)
      , rw_craplem.cdagenci
      , rw_craplem.cdbccxlt
      , rw_craplem.nrdolote
      , rw_craplem.nrdconta
      , vr_nrdocmto
      , vr_cdhistor
      , vr_nrseqdig
      , rw_craplem.nrctremp
      , rw_craplem.vllanmto
      , TRUNC(SYSDATE)
      , SYSDATE
      , rw_craplem.cdorigem
      , rw_Craplem.cdcooper
    );
    
    UPDATE craplem
       SET dtestorn = trunc(SYSDATE)
     WHERE progress_recid = rw_craplem.progress_recid;
  END LOOP rw_craplem;
  
  vr_vlpago := 0;
  SELECT nvl(SUM(vllanmto), 0) INTO vr_vlpago
    FROM craplem
   WHERE cdcooper = 2
     AND nrdconta = 583375
     AND nrctremp = 237602
     AND cdhistor = 2701
     AND dtmvtolt >= to_date('18/03/2019', 'DD/MM/YYYY') ;

  UPDATE crapepr e
     SET vlpgjmpr = 0
       , vlpgmupr = 0
       , vlsdprej = vlsdprej + vr_vlpago
   WHERE cdcooper = 2
     AND nrdconta = 583375
     AND nrctremp = 237602;
  
  --------------------
  FOR rw_craplem IN 
  (SELECT cdcooper
        , nrdconta
        , nrctremp
        , cdagenci
        , cdbccxlt
        , nrdolote
        , cdhistor
        , vllanmto
        , cdorigem
        , progress_recid
     FROM craplem
    WHERE cdcooper = 2
     AND nrdconta = 583375
     AND nrctremp = 238189
      AND dtmvtolt BETWEEN to_date('18/03/2019', 'DD/MM/YYYY') AND to_date('31/03/2019', 'DD/MM/YYYY')
      AND cdhistor IN (2701, 2388, 2390, 2473)
  ) LOOP
    OPEN cr_nrdocmto(rw_craplem.cdcooper
                   , rw_craplem.nrdconta);
    FETCH cr_nrdocmto INTO vr_nrdocmto;
    CLOSE cr_nrdocmto;

    OPEN cr_nrseqdig(rw_craplem.cdcooper);
    FETCH cr_nrseqdig INTO vr_nrseqdig;
    CLOSE cr_nrseqdig;
    
    IF rw_craplem.cdhistor = 2701 THEN
      vr_cdhistor := 2702;
    ELSIF rw_craplem.cdhistor = 2388 THEN
      vr_cdhistor := 2392;
    ELSIF rw_craplem.cdhistor = 2390 THEN
      vr_cdhistor := 2394;
    ELSIF rw_craplem.cdhistor = 2473 THEN
      vr_cdhistor := 2474;
    END IF;
    
    INSERT INTO craplem (
        dtmvtolt
      , cdagenci
      , cdbccxlt
      , nrdolote
      , nrdconta
      , nrdocmto
      , cdhistor
      , nrseqdig
      , nrctremp
      , vllanmto
      , dtpagemp
      , dthrtran
      , cdorigem
      , cdcooper
    )
    VALUES (
        trunc(SYSDATE)
      , rw_craplem.cdagenci
      , rw_craplem.cdbccxlt
      , rw_craplem.nrdolote
      , rw_craplem.nrdconta
      , vr_nrdocmto
      , vr_cdhistor
      , vr_nrseqdig
      , rw_craplem.nrctremp
      , rw_craplem.vllanmto
      , TRUNC(SYSDATE)
      , SYSDATE
      , rw_craplem.cdorigem
      , rw_craplem.cdcooper
    );
    
    UPDATE craplem
       SET dtestorn = trunc(SYSDATE)
     WHERE progress_recid = rw_craplem.progress_recid;
  END LOOP rw_craplem;
  
  vr_vlpago := 0;
  SELECT nvl(SUM(vllanmto), 0) INTO vr_vlpago
    FROM craplem
   WHERE cdcooper = 2
     AND nrdconta = 583375
     AND nrctremp = 238189
     AND cdhistor = 2701
     AND dtmvtolt BETWEEN to_date('18/03/2019', 'DD/MM/YYYY') AND to_date('31/03/2019', 'DD/MM/YYYY');

  UPDATE crapepr e
     SET vlpgjmpr = 0
       , vlpgmupr = 0
       , vlsdprej = vlsdprej + vr_vlpago
   WHERE cdcooper = 2
     AND nrdconta = 583375
     AND nrctremp = 238189;
  
  UPDATE crapsld dd
     SET dd.dtrisclq  = to_date('31/07/2018', 'DD/MM/YYYY')
   WHERE dd.cdcooper = 2
     AND dd.nrdconta = 583375;
  
  COMMIT;

end;
