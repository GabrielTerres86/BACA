DECLARE

  CURSOR cr_craplcm_insert IS
    select cdcooper, nrdconta, dtmvtolt, nrdocmto, cdagenci, vllanmto, cdhistor, cdbccxlt from craplcm where nrdconta = 3813223 AND cdhistor = 2680 and vllanmto =  0.93 AND dtmvtolt = to_date('07/03/2019','DD/MM/RRRR')
    UNION
    select cdcooper, nrdconta, dtmvtolt, nrdocmto, cdagenci, vllanmto, cdhistor, cdbccxlt from craplcm where nrdconta = 6954502 AND cdhistor = 2680 and vllanmto =  0.06 AND dtmvtolt = to_date('14/03/2019','DD/MM/RRRR') and nrdocmto = 43588
    UNION
    select cdcooper, nrdconta, dtmvtolt, nrdocmto, cdagenci, vllanmto, cdhistor, cdbccxlt from craplcm where nrdconta = 2801 AND cdhistor = 2758 and vllanmto =  27.16 AND dtmvtolt = to_date('25/03/2019','DD/MM/RRRR')
    UNION
    select cdcooper, nrdconta, dtmvtolt, nrdocmto, cdagenci, vllanmto, cdhistor, cdbccxlt from craplcm where nrdconta = 2352389 AND cdhistor = 2680 and vllanmto =  0.32 AND dtmvtolt = to_date('25/03/2019','DD/MM/RRRR')
    UNION
    select cdcooper, nrdconta, dtmvtolt, nrdocmto, cdagenci, vllanmto, cdhistor, cdbccxlt from craplcm where nrdconta = 2455056 AND cdhistor = 2680 and vllanmto =  8.24 AND dtmvtolt = to_date('25/03/2019','DD/MM/RRRR')
    UNION
    select cdcooper, nrdconta, dtmvtolt, nrdocmto, cdagenci, vllanmto, cdhistor, cdbccxlt from craplcm where nrdconta = 2623080 AND cdhistor = 2680 and vllanmto =  0.59 AND dtmvtolt = to_date('25/03/2019','DD/MM/RRRR')
    UNION
    select cdcooper, nrdconta, dtmvtolt, nrdocmto, cdagenci, vllanmto, cdhistor, cdbccxlt from craplcm where nrdconta = 6500129 AND cdhistor = 2680 and vllanmto =  1.17 AND dtmvtolt = to_date('25/03/2019','DD/MM/RRRR')
    UNION
    select cdcooper, nrdconta, dtmvtolt, nrdocmto, cdagenci, vllanmto, cdhistor, cdbccxlt from craplcm where nrdconta = 6500129 AND cdhistor = 2680 and vllanmto =  1.63 AND dtmvtolt = to_date('25/03/2019','DD/MM/RRRR')
    UNION
    select cdcooper, nrdconta, dtmvtolt, nrdocmto, cdagenci, vllanmto, cdhistor, cdbccxlt from craplcm where nrdconta = 6500129 AND cdhistor = 2680 and vllanmto =  0.52 AND dtmvtolt = to_date('25/03/2019','DD/MM/RRRR')
    UNION
    select cdcooper, nrdconta, dtmvtolt, nrdocmto, cdagenci, vllanmto, cdhistor, cdbccxlt from craplcm where nrdconta = 9146270 AND cdhistor = 2680 and vllanmto =  0.61 AND dtmvtolt = to_date('25/03/2019','DD/MM/RRRR')
    UNION
    select cdcooper, nrdconta, dtmvtolt, nrdocmto, cdagenci, vllanmto, cdhistor, cdbccxlt from craplcm where nrdconta = 9144200 AND cdhistor = 2680 and vllanmto =  0.83 AND dtmvtolt = to_date('29/03/2019','DD/MM/RRRR')
    UNION
    select cdcooper, nrdconta, dtmvtolt, nrdocmto, cdagenci, vllanmto, cdhistor, cdbccxlt from craplcm where nrdconta = 8976694 AND cdhistor = 2680 and vllanmto =  0.47 AND dtmvtolt = to_date('01/04/2019','DD/MM/RRRR')
    UNION
    select cdcooper, nrdconta, dtmvtolt, nrdocmto, cdagenci, vllanmto, cdhistor, cdbccxlt from craplcm where nrdconta = 6196640 AND cdhistor = 2758 and vllanmto =  0.49 AND dtmvtolt = to_date('01/04/2019','DD/MM/RRRR');  
  rw_craplcm_insert cr_craplcm_insert%ROWTYPE;
  
  vr_nrdolote   craplot.nrdolote%TYPE;
  
  CURSOR cr_craplot (pr_cdcooper IN craplot.cdcooper%TYPE
                    ,pr_dtmvtolt IN craplot.dtmvtolt%TYPE
                    ,pr_cdagenci IN craplot.cdagenci%TYPE
                    ,pr_cdbccxlt IN craplot.cdbccxlt%TYPE
                    ,pr_nrdolote IN craplot.nrdolote%TYPE) IS
    SELECT  craplot.nrdolote
           ,craplot.nrseqdig
           ,craplot.cdbccxlt
           ,craplot.dtmvtolt
           ,craplot.cdagenci
           ,craplot.rowid
    FROM craplot craplot
    WHERE craplot.cdcooper = pr_cdcooper
    AND   craplot.dtmvtolt = pr_dtmvtolt
    AND   craplot.cdagenci = pr_cdagenci
    AND   craplot.cdbccxlt = pr_cdbccxlt
    AND   craplot.nrdolote = pr_nrdolote;
  rw_craplot cr_craplot%ROWTYPE;
  rw_craplcm craplcm%ROWTYPE;
  
  CURSOR cr_crapdat(pr_cdcooper IN craptab.cdcooper%TYPE) IS
    SELECT dat.dtmvtolt
          ,dat.dtmvtopr
          ,dat.dtmvtoan
          ,dat.inproces
          ,dat.qtdiaute
          ,dat.cdprgant
          ,dat.dtmvtocd
          ,trunc(dat.dtmvtolt,'mm')               dtinimes -- Pri. Dia Mes Corr.
          ,trunc(Add_Months(dat.dtmvtolt,1),'mm') dtpridms -- Pri. Dia mes Seguinte
          ,last_day(add_months(dat.dtmvtolt,-1))  dtultdma -- Ult. Dia Mes Ant.
          ,last_day(dat.dtmvtolt)                 dtultdia -- Utl. Dia Mes Corr.
          ,rowid
      FROM crapdat dat
     WHERE dat.cdcooper = pr_cdcooper;
  rw_crapdat cr_crapdat%ROWTYPE;
  
BEGIN
  
  OPEN  cr_crapdat(pr_cdcooper => 1);
  FETCH cr_crapdat into rw_crapdat;
  CLOSE cr_crapdat;

  FOR rw_craplcm_insert IN cr_craplcm_insert LOOP
  
    vr_nrdolote := fn_sequence(pr_nmtabela => 'CRAPLOT'
                              ,pr_nmdcampo => 'NRDOLOTE'
                              ,pr_dsdchave => TO_CHAR(rw_craplcm_insert.cdcooper)|| ';' 
                                              || TO_CHAR(rw_craplcm_insert.dtmvtolt,'DD/MM/RRRR') || ';'
                                              || TO_CHAR(rw_craplcm_insert.cdagenci)|| ';'
                                              || '100');  
  
  
    --1) inserir histórico de estorno (360) com a data do cursor na craplcm
    OPEN cr_craplot (pr_cdcooper => rw_craplcm_insert.cdcooper
                    ,pr_dtmvtolt => rw_craplcm_insert.dtmvtolt
                    ,pr_cdagenci => rw_craplcm_insert.cdagenci
                    ,pr_cdbccxlt => rw_craplcm_insert.cdbccxlt
                    ,pr_nrdolote => vr_nrdolote);
    --Posicionar no proximo registro
    FETCH cr_craplot INTO rw_craplot;
    --Se encontrou registro
    IF cr_craplot%NOTFOUND THEN
      --Fechar Cursor
      --CLOSE cr_craplot;
      --Criar lote
      INSERT INTO craplot
        (craplot.cdcooper
        ,craplot.dtmvtolt
        ,craplot.cdagenci
        ,craplot.cdbccxlt
        ,craplot.nrdolote
        ,craplot.cdoperad
        ,craplot.tplotmov
        ,craplot.cdhistor)
      VALUES
        (rw_craplcm_insert.cdcooper
        ,rw_craplcm_insert.dtmvtolt
        ,rw_craplcm_insert.cdagenci
        ,100
        ,vr_nrdolote
        ,1
        ,1
        ,360)
      RETURNING ROWID
        ,craplot.dtmvtolt
        ,craplot.cdagenci
        ,craplot.cdbccxlt
        ,craplot.nrdolote
        ,craplot.nrseqdig
      INTO rw_craplot.ROWID
        ,rw_craplot.dtmvtolt
        ,rw_craplot.cdagenci
        ,rw_craplot.cdbccxlt
        ,rw_craplot.nrdolote
        ,rw_craplot.nrseqdig;
         
    END IF;
    
    CLOSE cr_craplot;
    
    INSERT INTO craplcm
        (craplcm.dtmvtolt
        ,craplcm.cdagenci
        ,craplcm.cdbccxlt
        ,craplcm.nrdolote
        ,craplcm.nrdconta
        ,craplcm.nrdocmto
        ,craplcm.vllanmto
        ,craplcm.cdhistor
        ,craplcm.nrseqdig
        ,craplcm.nrdctabb
        ,craplcm.nrautdoc
        ,craplcm.cdcooper
        ,craplcm.cdpesqbb)
    VALUES
        (rw_craplcm_insert.dtmvtolt
        ,rw_craplcm_insert.cdagenci
        ,100
        ,vr_nrdolote
        ,rw_craplcm_insert.nrdconta
        ,nvl(rw_craplcm_insert.nrdocmto, Nvl(rw_craplot.nrseqdig,0))
        ,rw_craplcm_insert.vllanmto
        ,360
        ,Nvl(rw_craplot.nrseqdig,0) + 1 -- Merge 02/05/2018 - Chamado 851591 
        ,rw_craplcm_insert.nrdconta
        ,0
        ,rw_craplcm_insert.cdcooper
        ,rw_craplcm_insert.nrdocmto)
    RETURNING craplcm.nrseqdig
             ,craplcm.vllanmto
    INTO rw_craplcm.nrseqdig
        ,rw_craplcm.vllanmto;
    
    UPDATE craplot SET craplot.qtinfoln = Nvl(craplot.qtinfoln,0) + 1
                      ,craplot.qtcompln = Nvl(craplot.qtcompln,0) + 1
                      ,craplot.nrseqdig = Nvl(rw_craplcm.nrseqdig,0) + 1
                      ,craplot.vlinfocr = Nvl(craplot.vlinfocr,0) + rw_craplcm_insert.vllanmto
                      ,craplot.vlcompcr = Nvl(craplot.vlcompcr,0) + rw_craplcm_insert.vllanmto
    WHERE craplot.ROWID = rw_craplot.ROWID;
     
    --2) Inserir histórico do cursor com a data atual do sistema na LCM
    vr_nrdolote := fn_sequence(pr_nmtabela => 'CRAPLOT'
                              ,pr_nmdcampo => 'NRDOLOTE'
                              ,pr_dsdchave => TO_CHAR(rw_craplcm_insert.cdcooper)|| ';' 
                                              || TO_CHAR(rw_crapdat.dtmvtolt,'DD/MM/RRRR') || ';'
                                              || TO_CHAR(rw_craplcm_insert.cdagenci)|| ';'
                                              || '100');  
  
  
    --1) inserir histórico de estorno (360) com a data do cursor na craplcm
    OPEN cr_craplot (pr_cdcooper => rw_craplcm_insert.cdcooper
                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                    ,pr_cdagenci => rw_craplcm_insert.cdagenci
                    ,pr_cdbccxlt => rw_craplcm_insert.cdbccxlt
                    ,pr_nrdolote => vr_nrdolote);
    --Posicionar no proximo registro
    FETCH cr_craplot INTO rw_craplot;
    --Se encontrou registro
    IF cr_craplot%NOTFOUND THEN
      --Fechar Cursor
      --CLOSE cr_craplot;
      --Criar lote
      INSERT INTO craplot
        (craplot.cdcooper
        ,craplot.dtmvtolt
        ,craplot.cdagenci
        ,craplot.cdbccxlt
        ,craplot.nrdolote
        ,craplot.cdoperad
        ,craplot.tplotmov
        ,craplot.cdhistor)
      VALUES
        (rw_craplcm_insert.cdcooper
        ,rw_crapdat.dtmvtolt
        ,rw_craplcm_insert.cdagenci
        ,100
        ,vr_nrdolote
        ,1
        ,1
        ,rw_craplcm_insert.cdhistor)
      RETURNING ROWID
        ,craplot.dtmvtolt
        ,craplot.cdagenci
        ,craplot.cdbccxlt
        ,craplot.nrdolote
        ,craplot.nrseqdig
      INTO rw_craplot.ROWID
        ,rw_craplot.dtmvtolt
        ,rw_craplot.cdagenci
        ,rw_craplot.cdbccxlt
        ,rw_craplot.nrdolote
        ,rw_craplot.nrseqdig;
         
    END IF;
    
    CLOSE cr_craplot;
    
    INSERT INTO craplcm
        (craplcm.dtmvtolt
        ,craplcm.cdagenci
        ,craplcm.cdbccxlt
        ,craplcm.nrdolote
        ,craplcm.nrdconta
        ,craplcm.nrdocmto
        ,craplcm.vllanmto
        ,craplcm.cdhistor
        ,craplcm.nrseqdig
        ,craplcm.nrdctabb
        ,craplcm.nrautdoc
        ,craplcm.cdcooper
        ,craplcm.cdpesqbb)
    VALUES
        (rw_crapdat.dtmvtolt
        ,rw_craplcm_insert.cdagenci
        ,100
        ,vr_nrdolote
        ,rw_craplcm_insert.nrdconta
        ,nvl(rw_craplcm_insert.nrdocmto, Nvl(rw_craplot.nrseqdig,0))
        ,rw_craplcm_insert.vllanmto
        ,rw_craplcm_insert.cdhistor
        ,Nvl(rw_craplot.nrseqdig,0) + 1 -- Merge 02/05/2018 - Chamado 851591 
        ,rw_craplcm_insert.nrdconta
        ,0
        ,rw_craplcm_insert.cdcooper
        ,rw_craplcm_insert.nrdocmto)
    RETURNING craplcm.nrseqdig
             ,craplcm.vllanmto
    INTO rw_craplcm.nrseqdig
        ,rw_craplcm.vllanmto;
    
    UPDATE craplot SET craplot.qtinfoln = Nvl(craplot.qtinfoln,0) + 1
                      ,craplot.qtcompln = Nvl(craplot.qtcompln,0) + 1
                      ,craplot.nrseqdig = Nvl(rw_craplcm.nrseqdig,0) + 1
                      ,craplot.vlinfocr = Nvl(craplot.vlinfocr,0) + rw_craplcm_insert.vllanmto
                      ,craplot.vlcompcr = Nvl(craplot.vlcompcr,0) + rw_craplcm_insert.vllanmto
    WHERE craplot.ROWID = rw_craplot.ROWID;
    
  END LOOP;
  COMMIT;  
END;

