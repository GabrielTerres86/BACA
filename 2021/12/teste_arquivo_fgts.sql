DECLARE
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  
  vr_dtmvtolt crapdat.dtmvtolt%TYPE := to_date('29/11/2021','DD/MM/YYYY');
  vr_dtmvtopr crapdat.dtmvtopr%TYPE := to_date('29/11/2021','DD/MM/YYYY');
  vr_dtmvtoan crapdat.dtmvtoan%TYPE := to_date('29/11/2021','DD/MM/YYYY');
  vr_dtmvtocd crapdat.dtmvtocd%TYPE := to_date('29/11/2021','DD/MM/YYYY');
BEGIN

  OPEN btch0001.cr_crapdat(pr_cdcooper => :pr_cdcooper);
  FETCH btch0001.cr_crapdat INTO rw_crapdat;
  CLOSE btch0001.cr_crapdat;
  
  UPDATE crapdat 
     SET dtmvtolt = vr_dtmvtolt
        ,dtmvtopr = vr_dtmvtopr
        ,dtmvtoan = vr_dtmvtoan
        ,dtmvtocd = vr_dtmvtocd
  WHERE cdcooper = :pr_cdcooper;

  update craplft lft set lft.insitfat = 1, lft.dtdenvio = null
    where lft.cdcooper = :pr_cdcooper
       and lft.cdhistor in (3192,3194,3196,3198,3200,3202,3204)
       and lft.dtmvtolt = vr_dtmvtolt; --(select dtmvtolt from crapdat where cdcooper = 7);    
     
  dbms_output.put_line('craplft = ' || SQL%ROWCOUNT);

  --Cooperativas  
  delete from gncvuni t
  where t.cdcooper = :pr_cdcooper
    and t.dtmvtolt = vr_dtmvtolt;
    
  --Ailos
  delete from gncvuni t
  where t.cdcooper = 3
    and t.dtmvtolt = vr_dtmvtolt;    
    
  dbms_output.put_line('gncvuni = ' || SQL%ROWCOUNT);    
    
  --Cooperativas  
  DELETE from gncontr t
  where t.dtmvtolt = vr_dtmvtolt
    AND t.cdconven between 163 and 169
    AND t.cdcooper = :pr_cdcooper;
    
  --Ailos
  DELETE from gncontr t
  where t.dtmvtolt = vr_dtmvtolt
    AND t.cdconven between 163 and 169
    AND t.cdcooper = 3;
    
  dbms_output.put_line('gncontr = ' || SQL%ROWCOUNT);
  
  -- delete para regerar arquivo contábil referente ao repasse de FGTS
  DELETE from craplcm
   WHERE cdcooper = 3
     AND nrdconta IN (SELECT nrctactl FROM crapcop WHERE cdcooper = :pr_cdcooper)
     AND dtmvtolt = vr_dtmvtolt
     AND cdhistor IN (3193,3195,3197,3199,3201,3203,3205) -- históricos de repasse
     ;
     
  -- delete para regerar arquivo contábil complementar YYYYMMDD_LCTOSSPB.txt
  DELETE from tbspb_arquivo_contabil tac
   WHERE trunc(tac.dtlancamento_contabil) = vr_dtmvtolt
     AND tac.cdhistor = 3480;     
            
  -- Call the procedure
  cecred.pc_crps385(pr_cdcooper => :pr_cdcooper,
                    pr_flgresta => :pr_flgresta,
                    pr_stprogra => :pr_stprogra,
                    pr_infimsol => :pr_infimsol,
                    pr_cdcritic => :pr_cdcritic,
                    pr_dscritic => :pr_dscritic);
                    
  UPDATE crapdat 
     SET dtmvtolt = rw_crapdat.dtmvtolt
        ,dtmvtopr = rw_crapdat.dtmvtopr
        ,dtmvtoan = rw_crapdat.dtmvtoan
        ,dtmvtocd = rw_crapdat.dtmvtocd
  WHERE cdcooper = :pr_cdcooper;
  
  COMMIT;
end;
/